function plot_adaptive_json(fnAdaptive)
%% this file plots an adaptive json file as well as current
close all;


%% get data
[pn,fn] = fileparts(fnAdaptive);
fnDeviceSettings = fullfile(pn,'DeviceSettings.json');
ds = get_meta_data_from_device_settings_file(fnDeviceSettings);

%     str = getAdaptiveHumanReadaleSettings(ds);
mintrim = 10;

% load adapative
res = readAdaptiveJson(fnAdaptive);
tim = res.timing;
fnf = fieldnames(tim);
for fff = 1:length(fnf)
    tim.(fnf{fff})= tim.(fnf{fff})';
end

ada = res.adaptive;
fnf = fieldnames(ada);
for fff = 1:length(fnf)
    ada.(fnf{fff})= ada.(fnf{fff})';
end

timingTable = struct2table(tim);
adaptiveTableTemp = struct2table(ada);
adaptiveTable = [timingTable, adaptiveTableTemp];
% get sampling rate
deviceSettingsTable = get_meta_data_from_device_settings_file(fnDeviceSettings);
fftInterval = deviceSettingsTable.fftTable{1}.interval;
samplingRate = 1000/fftInterval;
samplingRateCol = repmat(samplingRate,size(adaptiveTable,1),1);
adaptiveTable.samplerate = samplingRateCol;
adaptiveTable.packetsizes  = repmat(1,size(adaptiveTable,1),1);

adaptiveTable = assignTime(adaptiveTable);
ts = datetime(adaptiveTable.DerivedTime/1000,...
    'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');


adaptiveTable.DerivedTimesFromAssignTimesHumanReadable = ts;



%% plot both lds 
close all;
hfig = figure;
hfig.Color = 'w';
rows = 4; 
cols = 1; 
cntplt = 1;
hsb(cntplt) = subplot(rows,cols,cntplt); cntplt = cntplt + 1; 
hplt = plot(adaptiveTable.DerivedTimesFromAssignTimesHumanReadable, adaptiveTable.LD0_output);
hplt.Color = [0 0 0.8 0.7];
hplt.LineWidth = 2;
title('LD0');

hsb(cntplt) = subplot(rows,cols,cntplt); cntplt = cntplt + 1; 
hplt = plot(adaptiveTable.DerivedTimesFromAssignTimesHumanReadable, adaptiveTable.LD1_output);
hplt.Color = [0 0 0.8 0.7];
hplt.LineWidth = 2;
title('LD1');

hsb(cntplt) = subplot(rows,cols,cntplt); cntplt = cntplt + 1; 
hplt = plot(adaptiveTable.DerivedTimesFromAssignTimesHumanReadable, adaptiveTable.CurrentAdaptiveState);
hplt.Color = [0.8 0 0 0.7];
hplt.LineWidth = 2;
title('state');

hsb(cntplt) = subplot(rows,cols,cntplt); cntplt = cntplt + 1; 
cur  = adaptiveTable.CurrentProgramAmplitudesInMilliamps(:,1);
hplt = plot(adaptiveTable.DerivedTimesFromAssignTimesHumanReadable, cur);
hplt.Color = [0 0.8 0 0.7];
hplt.LineWidth = 2;
title('current');

linkaxes(hsb,'x');




%% plot data

hfig = figure;
hfig.Color = 'w';
for i = 1:3
    hsb(i) = subplot(3,1,i); 
    hold(hsb(i),'on');
end
% only remove outliers in the threshold
timesUseDetector = adaptiveTable.DerivedTimesFromAssignTimesHumanReadable; 
ld0 = adaptiveTable.LD0_output;
ld0_high = adaptiveTable.LD0_highThreshold;
ld0_low = adaptiveTable.LD0_lowThreshold;


outlierIdx = isoutlier(ld0_high);
ld0 = ld0(~outlierIdx);
ld0_high = ld0_high(~outlierIdx);
ld0_low = ld0_low(~outlierIdx);
timesUseDetector = timesUseDetector(~outlierIdx);

idxplot = 1; % first plot is detecorr
hold(hsb(idxplot),'on');
hplt = plot(hsb(idxplot),timesUseDetector,ld0,'LineWidth',2.5,'Color',[0 0 0.8 ]);
plot(hsb(idxplot),timesUseDetector,movmean( ld0,[1 1200]),'LineWidth',4,'Color',[0 0.8 0 0.2]);

hplt = plot(hsb(idxplot),timesUseDetector,ld0_high,'LineWidth',2,'Color',[0.8 0 0 ]);
hplt.LineStyle = '-.';
hplt.Color = [hplt.Color 0.7];
hplt = plot(hsb(idxplot),timesUseDetector,ld0_low,'LineWidth',2,'Color',[0.8 0 0]);
hplt.LineStyle = '-.';
hplt.Color = [hplt.Color 0.7];
prctile_99 = prctile(ld0,99);
prctile_1  = prctile(ld0,1);
if prctile_1 > ld0_low(1)
    prctile_1 = ld0_low(1) * 0.9;
end
if prctile_99 < ld0_high(1)
    prctile_99 = ld0_high(1)*1.1;
end
ylim(hsb(idxplot),[prctile_1 prctile_99]);
ttlus = sprintf('Control signal');
title(hsb(idxplot),ttlus);
ylabel(hsb(idxplot),'Control signal (a.u.)');
set(hsb(idxplot),'FontSize',16);

%% write to screen
clc; 
prctile(ld0,10); 
fprintf('LD0 data:\n\n');

fprintf('\tmean:\t%.2f\n',mean(ld0));
fprintf('\tmedian:\t%.2f\n',median(ld0));
fprintf('\n'); 
for i = 5:5:100
    fprintf('\t prctile %0.2d:\t%.2f\n',i,prctile(ld0,i));
end
%% write to file 
filePrctile = fullfile(pn,'prctilesAdaptiveRun.txt'); 
fid = fopen(filePrctile,'w+');

fprintf(fid,'LD0 data:\n\n');

fprintf(fid,'\tmean:\t%.2f\n',mean(ld0));
fprintf(fid,'\tmedian:\t%.2f\n',median(ld0));
fprintf(fid,'\n'); 
for i = 5:5:100
    fprintf(fid,'\t prctile %0.2d:\t%.2f\n',i,prctile(ld0,i));
end
fclose(fid);

%% state 
idxplot = 2; % current
hold(hsb(idxplot),'on');
timesUseCur = adaptiveTable.DerivedTimesFromAssignTimesHumanReadable;
stateUse = adaptiveTable.CurrentAdaptiveState;
% don't  remove outliers for current
% but remove current above 10 as they are unlikely to be real
outlierIdx = stateUse < 0 | stateUse > 9;
stateUse = stateUse(~outlierIdx);
timesUseCur = timesUseCur(~outlierIdx); 
plot(hsb(idxplot),timesUseCur,stateUse,'LineWidth',3,'Color',[0.8 0 0 0.7]);
ylabel( hsb(idxplot) ,'State');
ylim(hsb(idxplot),[-0.5 2.5]);
hsb(idxplot).YTick = [0 1 2];
title(hsb(idxplot),'State'); 
set( hsb(idxplot),'FontSize',16);



%% current 



idxplot = 3; % current
hold(hsb(idxplot),'on');
timesUseCur = adaptiveTable.DerivedTimesFromAssignTimesHumanReadable;
cur = adaptiveTable.CurrentProgramAmplitudesInMilliamps;
cur = cur(:,1); % assumes only one program running ;
% don't  remove outliers for current
% but remove current above 10 as they are unlikely to be real
outlierIdx = cur>10;
cur = cur(~outlierIdx);
timesUseCur = timesUseCur(~outlierIdx);
title('Current'); 
set( hsb(idxplot),'FontSize',16);



plot(hsb(idxplot),timesUseCur,cur,'LineWidth',3,'Color',[0 0.8 0 0.7]);
plot(hsb(idxplot),timesUseCur,movmean( cur,[1 1200]),'LineWidth',4,'Color',[0 0.0 0.8 0.2]);
%         for i = 1:3
%             states{i} = sprintf('%0.1fmA',dbuse.cur(d,i));
%
%             if i == 2
%                 if dbuse.cur(d,i) == 25.5
%                     states{i} = 'HOLD';
%                 end
%             end
%         end
%         ttlus = sprintf('Current in mA %s [%s, %s, %s]',unqSides{ss},states{1},states{2},states{3});
%         title(hsb(idxplot) ,ttlus);
title('Current'); 
ylabel( hsb(idxplot) ,'Current (mA)');
set( hsb(idxplot),'FontSize',16);

linkaxes(hsb,'x');

%% plot state space 
cur = adaptiveTable.CurrentProgramAmplitudesInMilliamps;
stateUse = adaptiveTable.CurrentAdaptiveState;
outlierIdxCur = cur(:,1)>10;
outlierIdxState = stateUse < 0 | stateUse > 9;
timesUseDetector = adaptiveTable.DerivedTimesFromAssignTimesHumanReadable; 
timesUseDetectorDuration = timesUseDetector - timesUseDetector(1); 
outlierIdxTime = timesUseDetectorDuration < minutes(5);
ld0 = adaptiveTable.LD0_output;
ld0_high = adaptiveTable.LD0_highThreshold;
outlierIdxLD = isoutlier(ld0_high);
outliersUse = outlierIdxLD | outlierIdxCur | outlierIdxState | outlierIdxTime;
atUse = adaptiveTable(~outliersUse,:);
% make table easily divisible by update rate 
controlSignal = atUse.LD0_output;
diffs = diff(controlSignal);
firstIdx = find(diffs>1,1)+1;
atUse = atUse(firstIdx:end,:);
%% 1:1 current 

hfig = figure;
hfig.Color = 'w';
hsb = subplot(1,1,1); 
hold(hsb,'on');
currrent = atUse.CurrentProgramAmplitudesInMilliamps(:,1);
controlSignal = atUse.LD0_output;
scatter(currrent(1:end),controlSignal(1:end),20,'filled','MarkerFaceColor','b','MarkerFaceAlpha',0.2);

xlims = [min(currrent) max(currrent)];
ld0_high = adaptiveTable.LD0_highThreshold;
ld0_low = adaptiveTable.LD0_lowThreshold;

hplt = plot(xlims,[ld0_high(1) ld0_high(end)],'LineWidth',2,'Color',[0.8 0 0 ]);
hplt.LineStyle = '-.';


hplt = plot(xlims,[ld0_low(1) ld0_low(end)],'LineWidth',2,'Color',[0.8 0 0 ]);
hplt.LineStyle = '-.';
%% using update rate to average 
t = atUse.DerivedTimesFromAssignTimesHumanReadable;
current = atUse.CurrentProgramAmplitudesInMilliamps(:,1);
controlSignal = atUse.LD0_output;
curt = t(1); 
cntData = 1; 
outTable = table();
while (curt + seconds(30)) < t(end)
    idxuse = t >= curt & t < (curt+seconds(30));
    
    if length( unique(controlSignal(idxuse))) == 1 
        idxnums = find(idxuse == 1); 
        
    else
        idxnums = find(idxuse == 1); 
        idxEndAt = find(diff(controlSignal(idxnums))~=0==1);
        idxnums = idxnums(1:idxEndAt);
        
    end
    curt = t(idxnums(end)+1);
    controlSignal( idxnums);
    current(idxnums); 
    time = t(idxnums);
    
    outTable.durationUse(cntData)   = time(end) - time(1); 
    outTable.sizeSegment(cntData)   = length(idxnums); 
    outTable.currentAvg(cntData)    = mean(current(idxnums));
    outTable.controlSigAvg(cntData) = mean(controlSignal(idxnums));
    outTable.timeStart(cntData)   = time(1);
    outTable.timeEnd(cntData)   = time(end);
    cntData = cntData + 1; 
end
%%
hfig = figure;
hfig.Color = 'w';
hsb = subplot(1,1,1); 
hold(hsb,'on');
currrent = outTable.currentAvg;
controlSignal = outTable.controlSigAvg;
scatter(currrent(1:end),controlSignal(1:end),20,'filled','MarkerFaceColor','b','MarkerFaceAlpha',0.2);

xlims = [min(currrent) max(currrent)];
ld0_high = adaptiveTable.LD0_highThreshold;
ld0_low = adaptiveTable.LD0_lowThreshold;

hplt = plot(xlims,[ld0_high(1) ld0_high(end)],'LineWidth',2,'Color',[0.8 0 0 ]);
hplt.LineStyle = '-.';


hplt = plot(xlims,[ld0_low(1) ld0_low(end)],'LineWidth',2,'Color',[0.8 0 0 ]);
hplt.LineStyle = '-.';
%%
[autocorr, lags] = xcorr(outTable.currentAvg,outTable.controlSigAvg,20,'none');
hfig = figure;
hfig.Color = 'w';
stem(lags,autocorr)
title('auto correlation'); 

%%
hfig = figure; 
hfig.Color = 'w';
hist3([outTable.currentAvg,outTable.controlSigAvg],'CdataMode','auto','edges',{2.8:0.1:3.5 0:50:max(controlSignal)});
xlabel('current')
ylabel('control signal')
colorbar
view(2)
title('histogram');
axis tight; 

%% plot auto corelation



%% write to csv 
% fnsave = fullfile(pn, [fn '.csv']);
% writetable(adaptiveTable,fnsave);
%%
end