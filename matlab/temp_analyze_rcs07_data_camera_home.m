function temp_analyze_rcs07_data_camera_home()
% data from dec 16 

%% load camera data 
fncamera = '/Users/roee/Documents/Code/drew_ipnb_movement/points_drew_video_motion.csv';
datMotion = csvread(fncamera);
motionDat = table(); 
ts = datetime(datMotion(:,1),...
'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS') + hours(8);
motionDat.time = ts;
motionDat.data = datMotion(:,2); 
% email from RCS07 to my gmail Dec 22 2020: 
% I meant to capture at 5fps, but I may have run at 10fps but set the
% video playback speed to 5. The burned-in times at the top of the frame
% are probably reliable, and they run from 18:19 to 23:18 (GMT).
% 
% In other words, the data start time should be 10:19 (california) and the
% data should last ~5h, but I think its times will run twice that long.
correctTimeStamp = ts(1) : seconds(0.1) : (ts(1) + (ts(end)-ts(1))/2);
motionDat.correctedTs = correctTimeStamp';

figure;
hold on;
plot(motionDat.correctedTs,motionDat.data,...
    'LineWidth',0.2,'Color',[0 0 0.8 0.01]);

smoothedDat = sgolayfilt(motionDat.data,9,5001,kaiser(5001,9));
% smoothedDat = movmean(smoothedDat,20); % 10 fps so 2 second smooth 
plot(motionDat.correctedTs,smoothedDat,...
    'LineWidth',2,'Color',[0 0 0 0.5]);
%% L 
fn = '/Users/roee/Documents/Code/drew_ipnb_movement/rcs_data/RCS07L/Session1608143138843/DeviceNPC700419H';
fnsave = fullfile(fn,'combined_data_table.mat');
if exist(fnsave,'file')
    load(fnsave);
else
    start = tic;
    addpath(genpath(fullfile(pwd,'toolboxes','panel-2.14')));
    [combinedDataTable, debugTable, timeDomainSettings,powerSettings,...
        fftSettings,metaData,stimSettingsOut,stimMetaData,stimLogSettings,...
        DetectorSettings,AdaptiveStimSettings,AdaptiveRuns_StimSettings] = DEMO_ProcessRCS(fn);
    save(fnsave,...
        'combinedDataTable','debugTable','timeDomainSettings','powerSettings',...
        'fftSettings','metaData','stimSettingsOut','stimMetaData',...
        'stimLogSettings','DetectorSettings','AdaptiveStimSettings',...
        'AdaptiveRuns_StimSettings');
    fid = fopen(fullfile(fn,'time_to_save.txt'),'w+');
    fprintf(fid,'took %s time to save this L side data combined data',toc(start));
    fclose(fid);
end
%% plot spectrogram
ts = datetime(combinedDataTable.DerivedTime/1000,...
    'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
combinedDataTable.DerivedTimeHuman = ts;
%%
figure; 
hsb(1) = subplot(2,1,1);
plot(combinedDataTable.DerivedTimeHuman,combinedDataTable.TD_key0);
hsb(2) = subplot(2,1,2);
iduxse = ~isnan(combinedDataTable.Accel_XSamples);
plot(combinedDataTable.DerivedTimeHuman(iduxse),combinedDataTable.Accel_XSamples(iduxse));
linkaxes(hsb,'x');


%% plot spectral 
% first make sure that y does'nt have NaN's at
% check start:
y = combinedDataTable.TD_key3;
timeUse = combinedDataTable.DerivedTimeHuman;
timeUseRaw = timeUse;
cntNan = 1;
if isnan(y(1))
    while isnan(y(cntNan))
        cntNan = cntNan + 1;
    end
end
y = y(cntNan:end);
cntStart = cntNan;
timeUse = timeUse(cntNan:end);
% check end:
cntNan = length(y);
if isnan(y(cntNan))
    while isnan(y(cntNan))
        cntNan = cntNan - 1;
    end
end
cntEnd = cntNan;
y = y(1:cntNan);
timeUse = timeUse(1:cntNan);
% plot spectral
yFilled = fillmissing(y,'constant',0);
srate = 500;
start = tic;
[s,f,t,p] = spectrogram(yFilled',kaiser(256,5),220,512,srate,'yaxis');
secToCompute = toc(start);
timeSpects = [];
% put nan's in gaps for spectral
%%
figure;
idxuse = 1e4:10e4;
pcolor(t(idxuse), f(5:100) ,log10(p(5:100,idxuse)));
colormap('jet')
shading('interp');
%%
yFilled = fillmissing(y,'constant',0);
[sss,fff,ttt,ppp] = spectrogram(yFilled,kaiser(256,5),220,512,srate,'yaxis');
% put nan's in gaps for spectral
TimeUseSpect = timeUse(1) + seconds(ttt);
%%
idxGapStart = find(diff(isnan(y))==1) + 1;
idxGapEnd = find(diff(isnan(y))==-1) + 1;
for te = 1:size(idxGapStart,1)
    timeGap(te,1) = timeUse(idxGapStart(te)) - seconds(0.5);
    timeGap(te,2) = timeUse(idxGapEnd(te)) + seconds(0.5);
    idxBlank = TimeUseSpect >= timeGap(te,1) & TimeUseSpect <= timeGap(te,2);
    ppp(:,idxBlank) = NaN;
end


%%
figure;
surf(TimeUseSpect, fff(5:100) ,ppp(5:100,:));
colormap('jet')
shading('interp');
axis tight 
view(2)


%% % R 
start = tic; 
addpath(genpath(fullfile(pwd,'toolboxes','panel-2.14')));
fn = '/Users/roee/Documents/Code/drew_ipnb_movement/rcs_data/RCS07R/Session1608143137930/DeviceNPC700403H';
[combinedDataTable, debugTable, timeDomainSettings,powerSettings,...
    fftSettings,metaData,stimSettingsOut,stimMetaData,stimLogSettings,...
    DetectorSettings,AdaptiveStimSettings,AdaptiveRuns_StimSettings] = DEMO_ProcessRCS(fn);
fnsave = fullfile(fn,'combined_data_table.mat');
save(fnsave,...
    'combinedDataTable','debugTable','timeDomainSettings','powerSettings',...
    'fftSettings','metaData','stimSettingsOut','stimMetaData',...
    'stimLogSettings','DetectorSettings','AdaptiveStimSettings',...
    'AdaptiveRuns_StimSettings');
fid = fopen(fullfile(fn,'time_to_save.txt'),'w+'); 
fprintf(fid,'took %s time to save this R side data combined data',toc(start));
fclose(fid); 
%%
















%%




%% this file plots an adaptive json file as well as current
fnAdaptive = '/Users/roee/Documents/Code/drew_ipnb_movement/rcs_data/RCS07L/Session1608143138843/DeviceNPC700419H/AdaptiveLog.json';
close all;
addpath(genpath('/Users/roee/Documents/Code/Analysis-rcs-data'));
% get data
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


if length(unique(adaptiveTable.LD1_featureInputs))>1
    %% plot both lds
    
    close all;
    hfig = figure;
    hfig.Color = 'w';
    rows = 4;
    cols = 1;
    cntplt = 1;
    
    % LD0
    hsb(cntplt) = subplot(rows,cols,cntplt); cntplt = cntplt + 1;
    hold on;
    ld0 = adaptiveTable.LD0_output;
    hplt = plot(adaptiveTable.DerivedTimesFromAssignTimesHumanReadable, adaptiveTable.LD0_output);
    hplt.LineWidth = 2;
    hplt.Color = [0 0 0.8 0.7];
    hplt.LineWidth = 2;
    % thresholds ld 0
    xlims = hsb(cntplt-1).XLim;
    ld0_high = adaptiveTable.LD0_highThreshold;
    hplt = plot(adaptiveTable.DerivedTimesFromAssignTimesHumanReadable,ld0_high,'LineWidth',2,'Color',[0.8 0 0 ]);
    hplt.LineStyle = '-.';
    ld0_low = adaptiveTable.LD0_lowThreshold;
    hplt = plot(adaptiveTable.DerivedTimesFromAssignTimesHumanReadable,ld0_low,'LineWidth',2,'Color',[0.8 0 0 ]);
    hplt.LineStyle = '-.';
    title('LD0');
    ylabel('control signal (a.u.)');
    set(gca,'FontSize',16)
    
    % LD1
%     hsb(cntplt) = subplot(rows,cols,cntplt); cntplt = cntplt + 1;
%     hold on;
%     hplt = plot(adaptiveTable.DerivedTimesFromAssignTimesHumanReadable, adaptiveTable.LD1_output);
%     hplt.Color = [0 0 0.8 0.7];
%     hplt.LineWidth = 2;
%     % thresholds ld 0
%     xlims = hsb(cntplt-1).XLim;
%     ld1_high = adaptiveTable.LD1_highThreshold;
%     hplt = plot(adaptiveTable.DerivedTimesFromAssignTimesHumanReadable,ld1_high,'LineWidth',2,'Color',[0.8 0 0 ]);
%     hplt.LineStyle = '-.';
%     ld1_low = adaptiveTable.LD1_lowThreshold;
%     hplt = plot(adaptiveTable.DerivedTimesFromAssignTimesHumanReadable,ld1_low,'LineWidth',2,'Color',[0.8 0 0 ]);
%     hplt.LineStyle = '-.';
%     ylabel('control signal (a.u.)');
%     set(gca,'FontSize',16)
%     title('LD1');
%     ylabel('control signal (a.u.)');
%     set(gca,'FontSize',16)
    
    % State
%     hsb(cntplt) = subplot(rows,cols,cntplt); cntplt = cntplt + 1;
%     states= adaptiveTable.CurrentAdaptiveState;
%     hplt = plot(adaptiveTable.DerivedTimesFromAssignTimesHumanReadable, adaptiveTable.CurrentAdaptiveState);
%     hplt.Color = [0.8 0 0 0.7];
%     hplt.LineWidth = 2;
%     hsb(cntplt-1).YTick = unique(states);
%     title('state');
%     ylabel('states');
%     set(gca,'FontSize',16)
%     ylim([-1 7]);
    
    % current
    hsb(cntplt) = subplot(rows,cols,cntplt); cntplt = cntplt + 1;
    cur  = adaptiveTable.CurrentProgramAmplitudesInMilliamps(:,1);
    hplt = plot(adaptiveTable.DerivedTimesFromAssignTimesHumanReadable, cur);
    hplt.Color = [0 0.8 0 0.7];
    hplt.LineWidth = 2;
    title('current');
    ylabel('Current (mA)');
    set(gca,'FontSize',16)
    
    % actigraphy
    Accel_fileToLoad = fullfile(pn,'RawDataAccel.json');
    if isfile(Accel_fileToLoad)
        jsonobj_Accel = deserializeJSON(Accel_fileToLoad);
        if ~isempty(jsonobj_Accel.AccelData)
            disp('Loading Accelerometer Data')
            [outtable_Accel, srates_Accel] = createAccelTable(jsonobj_Accel);
            disp('Creating derivedTimes for accelerometer:')
            AccelData = assignTime(outtable_Accel);
        else
            AccelData = [];
        end
    else
        AccelData = [];
    end
    ts = datetime(AccelData.DerivedTime/1000,...
        'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
    AccelData.DerivedTimesFromAssignTimesHumanReadable = ts;
    % plot
    hsb(cntplt) = subplot(rows,cols,cntplt); cntplt = cntplt + 1;
    hold on;
    x = AccelData.XSamples - mean(AccelData.XSamples);
    y = AccelData.XSamples - mean(AccelData.YSamples);
    z = AccelData.XSamples - mean(AccelData.ZSamples);
    %     plot(ts,x,'LineWidth',1,'Color',[0.8 0 0 0.6]);
    %     plot(ts,y,'LineWidth',1,'Color',[0.0 0.8 0 0.6]);
    %     plot(ts,z,'LineWidth',1,'Color',[0.0 0 0.8 0.6]);
    % reshape actigraphy over 3 seconds window (64*3)
    accAxes = {'x','y','z'};
    yAvg = [];
    for ac = 1:length(accAxes)
        yDat = eval(accAxes{ac});
        uxtimesPower = ts;
        reshapeFactor = 64*3;
        yDatReshape = yDat(1:end-(mod(size(yDat,1), reshapeFactor)));
        timeToReshape= uxtimesPower(1:end-(mod(size(yDat,1), reshapeFactor)));
        yDatToAverage  = reshape(yDatReshape,reshapeFactor,size(yDatReshape,1)/reshapeFactor);
        timeToAverage  = reshape(timeToReshape,reshapeFactor,size(yDatReshape,1)/reshapeFactor);
        
        yAvg(ac,:) = rms(yDatToAverage - mean(yDatToAverage),1)'; % average rms
        tUse = timeToAverage(reshapeFactor,:);
    end
    rmsAverage = log10(mean(yAvg));
    hplt = plot(tUse,rmsAverage);
    hplt.LineWidth = 1;
    hplt.Color = [0.7 0.7 0 0.1];
    % moving mean - 21 seconds
    mvMean = movmean(rmsAverage,7);
    hplt = plot(tUse,mvMean);
    hplt.LineWidth = 2;
    hplt.Color = [0.5 0.5 0 0.5];
    legend({'rms, 20 sec mov. avg.'});
    title('acc');
    ylabel('RMS of acc (log10(g))');
    set(gca,'FontSize',16)
    
    
    
    
    linkaxes(hsb,'x');
    
    
else
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
    
end



hsb(cntplt) = subplot(rows,cols,cntplt); cntplt = cntplt + 1;

hold on;
plot(motionDat.correctedTs,motionDat.data,...
    'LineWidth',0.2,'Color',[0 0 0.8 0.01]);

smoothedDat = sgolayfilt(motionDat.data,9,5001,kaiser(5001,9));
% smoothedDat = movmean(smoothedDat,20); % 10 fps so 2 second smooth 
plot(motionDat.correctedTs,smoothedDat,...
    'LineWidth',2,'Color',[0 0 0 0.5]);

title('smoothed data from camera');




linkaxes(hsb,'x');


%%












end