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

% plot only certain events 
useEvents = 0;
if useEvents == 1
    % find idx of event
    idxevent = ...
        strcmp(eventTable.EventType,'008 Turn Embedded Therapy ON. Number: 1');
    timeStart = eventTable.UnixOnsetTime(idxevent);
    timeEnd   = timeStart+ minutes(22);
else
    timeStart = outdatcomplete.derivedTimes(1) + minutes(2);
    timeEnd = outdatcomplete.derivedTimes(end) - minutes(2);
end



% plot td data 
% idxuse time domain 
timesTD = outdatcomplete.derivedTimes;
idxuseTD = timesTD > timeStart & timesTD < timeEnd;
for c = 1:4 % loop on channels
    fnm = sprintf('key%d',c-1);
    y = outdatcomplete.(fnm)(idxuseTD);
    y = y - mean(y);
    hsub(cntplt) = subplot(nrows,ncols,cntplt);
    hplt = plot(hsub(cntplt),outdatcomplete.derivedTimes(idxuseTD),y);
    hplt.LineWidth = 2;
    hplt.Color = [0 0 0.8 0.7];
    title( hsub(c),outRec(1).tdData(c).chanFullStr );
    set(hsub(c),'FontSize',12);
    cntplt = cntplt+1;
end

% plot accleratoin
timesAcc = outdatcompleteAcc.derivedTimes;
idxuseAcc = timesAcc > timeStart & timesAcc < timeEnd;

hsub(cntplt) = subplot(nrows,ncols,cntplt); 
hold on;
axsUse = {'X','Y','Z'};
for i = 1:3
    fnm = sprintf('%sSamples',axsUse{i});
    y = outdatcompleteAcc.(fnm)(idxuseAcc);
    y = y - mean(y);
    set(hsub(c+1),'FontSize',18);
    hplt = plot(hsub(c+1),outdatcompleteAcc.derivedTimes(idxuseAcc),y);
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
timesAdaptive = adaptiveTable.derivedTimes;
idxuseAdaptive = timesAdaptive > timeStart & timesAdaptive < timeEnd;

hsub(cntplt) = subplot(nrows,ncols,cntplt); 
hold(hsub(cntplt),'on');
ld0 = adaptiveTable.LD0_output(idxuseAdaptive); 
ld0_high = adaptiveTable.LD0_highThreshold(idxuseAdaptive); 
ld0_low  = adaptiveTable.LD0_lowThreshold(idxuseAdaptive); 
timeUse = adaptiveTable.derivedTimes(idxuseAdaptive);
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
state = adaptiveTable.CurrentAdaptiveState(idxuseAdaptive);
hplt1 = plot(hsub(cntplt),timeUse,state,'LineWidth',3); 
hplt1.Color = [0.8 0.8 0 0.7]; 
% assuming only one program defined: 
cur = adaptiveTable.CurrentProgramAmplitudesInMilliamps(idxuseAdaptive,1); 
hplt2 = plot(hsub(cntplt),timeUse,cur,'LineWidth',3); 
hplt2.Color = [0.8 0.8 0 0.2]; 
ylim([-1 4]);
legend([hplt1 hplt2],{'state','current'}); 
set(hsub(cntplt),'FontSize',12)
cntplt = cntplt + 1;

% power 
timesPower = powerOut.powerTable.derivedTimes;
idxusePower = timesPower > timeStart & timesPower < timeEnd;

hsub(cntplt) = subplot(nrows,ncols,cntplt); 
powerTable = powerOut.powerTable; 
plot(hsub(cntplt),powerTable.derivedTimes(idxusePower),powerTable.Band1(idxusePower)); 
title(hsub(cntplt),powerOut.bands(1).powerBandInHz{1});


% link all axes 
linkaxes(hsub,'x');


end