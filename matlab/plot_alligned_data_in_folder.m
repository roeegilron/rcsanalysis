function plot_alligned_data_in_folder(dirname)
%% function to plot alligned data in a folder 
fnmload = fullfile(dirname,'all_data_alligned.mat'); 
if exist(fnmload,'file')
    load_and_save_alligned_data_in_folder(dirname);
    load(fnmload,'outdatcomplete','outdatcompleteAcc','outRec',...
    'eventTable','powerOut','adaptiveTable');
else
    load(fnmload,'outdatcomplete','outdatcompleteAcc','outRec',...
    'eventTable','powerOut','adaptiveTable');

end

%% plot all alligne data 
nrows = 2; 
ncols = 4; 
hfig = figure; 
cntplt = 1;



idxTimeCompare = find(outdatcomplete.PacketRxUnixTime~=0,1);
packRxTimeRaw  = outdatcomplete.PacketRxUnixTime(idxTimeCompare); 
packtRxTime    =  datetime(packRxTimeRaw/1000,...
            'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
derivedTime    = outdatcomplete.derivedTimes(idxTimeCompare); 
timeDiff       = derivedTime - packtRxTime;


% plot td data 
for c = 1:4 % loop on channels
    fnm = sprintf('key%d',c-1);
    y = outdatcomplete.(fnm);
    y = y - mean(y);
    hsub(cntplt) = subplot(nrows,ncols,cntplt);
    hplt = plot(hsub(cntplt),outdatcomplete.derivedTimes,y);
    hplt.LineWidth = 2;
    hplt.Color = [0 0 0.8 0.7];
    title( hsub(c),outRec(1).tdData(c).chanFullStr );
    set(hsub(c),'FontSize',12);
   
    

    % plot event numbers 
    [events,eIdxs] = unique(eventTable.EventType);
    colrsUse = distinguishable_colors(length(eIdxs));
    for e = 1:length(eIdxs)
        eventIdxs = strcmp(events(e),eventTable.EventType);
        ylims = get(gca,'YLim');
        hold on;
        t = eventTable.UnixOffsetTime(eventIdxs) + timeDiff;% bcs clock time may be off compared to INS time
        tevents = repmat(t,1,2); 
        yevents = repmat(ylims,size(tevents,1),1);
        hplt = plot(tevents',yevents');
        for p = 1:length(hplt)
            hplt(p).Color = [colrsUse(e,:) 0.6];
            hplt(p).LineWidth = 3;
        end
        hplts(1,e) = hplt(1); 
    end
%     legend(hplts,events');
    
     % plot annotations 
   
    NewAxisTicks  = (eventTable.UnixOffsetTime + timeDiff)';
    NewAxisLabels = eventTable.EventSubType;
    newAxTick     = [ NewAxisTicks];
    newAxLabels   = [ NewAxisLabels];
    [sortedTicks, idxs] = sort(newAxTick);
    try
        if c == 1
            hsub(c).XTick = sortedTicks;
            hsub(c).XTickLabel = newAxLabels(idxs);
        end
    catch 
        fprintf('ticksn not working \n');
    end
    cntplt = cntplt+1;
end

% plot accleratoin
hsub(cntplt) = subplot(nrows,ncols,cntplt); 
hold on;
axsUse = {'X','Y','Z'};
for i = 1:3
    fnm = sprintf('%sSamples',axsUse{i});
    y = outdatcompleteAcc.(fnm);
    y = y - mean(y);
    set(hsub(c+1),'FontSize',18);
    hplt = plot(hsub(c+1),outdatcompleteAcc.derivedTimes,y);
    hplt.LineWidth = 2;
    hplt.Color = [hplt.Color 0.7];
end
title(hsub(c+1),'actigraphy');
legend({'x','y','z'});
linkaxes(hsub,'x');
for h = 1:length(hsub)
    hsub(h).YLimMode = 'auto';
end
cntplt = cntplt+1; 

% plot adaptive 
hsub(cntplt) = subplot(nrows,ncols,cntplt); 
hold(hsub(cntplt),'on');
ld0 = adaptiveTable.LD0_output; 
ld0_high = adaptiveTable.LD0_highThreshold; 
ld0_low  = adaptiveTable.LD0_lowThreshold; 
timeUse = adaptiveTable.derivedTimes;
plot(hsub(cntplt),timeUse,ld0,'LineWidth',3);
hplt = plot(hsub(cntplt),timeUse,ld0_high,'LineWidth',3);
hplt.LineStyle = '-.';
hplt.Color = [hplt.Color 0.7];
hplt = plot(hsub(cntplt),timeUse,ld0_low,'LineWidth',3);
hplt.LineStyle = '-.';
hplt.Color = [hplt.Color 0.7];


ylimsUse(1) = adaptiveTable.LD0_lowThreshold(1)*0.2;
ylimsUse(2) = adaptiveTable.LD0_highThreshold(1)*1.8;


ylimsUse(1) = prctile(ld0,1);
ylimsUse(2) = prctile(ld0,99);

ylim(hsub(cntplt),ylimsUse); 
title(hsub(cntplt),'Detector'); 
ylabel(hsub(cntplt),'Detector (a.u.)'); 
xlabel(hsub(cntplt),'Time'); 
legend(hsub(cntplt),{'Detector','Low threshold','High threshold'}); 
set(gca,'FontSize',12)
cntplt = cntplt + 1;

% state and current 
hsub(cntplt) = subplot(nrows,ncols,cntplt); 
hold(hsub(cntplt),'on');
title(hsub(cntplt),'state and current'); 
state = adaptiveTable.CurrentAdaptiveState;
hplt1 = plot(hsub(cntplt),timeUse,state,'LineWidth',3); 
hplt1.Color = [0.8 0.8 0 0.7]; 
% assuming only one program defined: 
cur = adaptiveTable.CurrentProgramAmplitudesInMilliamps(:,1); 
hplt2 = plot(hsub(cntplt),timeUse,cur,'LineWidth',3); 
hplt2.Color = [0.8 0.8 0 0.2]; 
ylim([-1 4]);
legend([hplt1 hplt2],{'state','current'}); 
set(hsub(cntplt),'FontSize',12)
cntplt = cntplt + 1;

% power 
hsub(cntplt) = subplot(nrows,ncols,cntplt); 
powerTable = powerOut.powerTable; 
plot(hsub(cntplt),powerTable.derivedTimes,powerTable.Band1); 
title(hsub(cntplt),powerOut.bands(1).powerBandInHz{1});


% link all axes 
linkaxes(hsub,'x');


end