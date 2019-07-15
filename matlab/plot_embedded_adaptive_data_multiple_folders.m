function plot_embedded_adaptive_data_multiple_folders()

%% clear stuff
clear all; close all; clc;
%% get folder list
load('/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/from_dropbox/SummitContinuousBilateralStreaming/RCS02L/database.mat');
startTime = '28-Jun-2019 14:44:51.456';
endTime   = '03-Jul-2019 09:35:29.553';
idxuse = tblout.rectime > startTime & tblout.rectime < endTime & ...
         cellfun(@(x) ~isempty(x), tblout.duration);
tblUse = tblout(idxuse,:);
%% set up figure
hfig = figure;
nrows = 3;
for i = 1:nrows
    hsb(i) = subplot(nrows,1,i);
    hold(hsb(i),'on');
end

for t = 1:size(tblUse,1)
    try 
    %% set up params
    [pn,fn,ext] = fileparts(tblUse.tdfile{t});
    params.dir    = pn;
    %% load data
    % load acc
    fileload = fullfile(params.dir,'RawDataAccel.json');
    [pn,fn,ext] = fileparts(fileload);
    if exist(fullfile(pn,[fn '.mat']),'file')
        load(fullfile(pn,[fn '.mat']));
        outdatcompleteAcc = outdatcomplete;
        clear outdatcomplete;
    else
        [outdatcompleteAcc, ~, ~] = MAIN(fileload);
    end
    % load device settings
    fileLoadDeviceSettings = fullfile(params.dir,'DeviceSettings.json');
    loadDeviceSettings(fileLoadDeviceSettings)
    % load power
    fileloadPower = fullfile(params.dir,'RawDataPower.json');
    [pn,fn,ext] = fileparts(fileloadPower);
    if exist(fullfile(pn,[fn '.mat']),'file')
        load(fullfile(pn,[fn '.mat']));
    else
        [powerTable, pbOut]  = loadPowerData(fileloadPower);
    end
    
    %% load adaptive
    fnAdaptive = fullfile(params.dir,'AdaptiveLog.json');
    res = readAdaptiveJson(fnAdaptive);
    
    %% plower adaptive + current + power
    
    % plot detector
    cur = res.adaptive.CurrentProgramAmplitudesInMilliamps(1,:);
    timestamps = datetime(datevec(res.timing.timestamp./86400 + datenum(2000,3,1,0,0,0))); % medtronic time - LSB is seconds
    uxtimes = datetime(res.timing.PacketGenTime/1000,...
        'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
    yearUse = mode(year(uxtimes));
    idxKeepYear = year(uxtimes)==yearUse;
    
    
    ld0 = res.adaptive.LD0_output(idxKeepYear);
    ld0_high = res.adaptive.LD0_highThreshold(idxKeepYear);
    ld0_low  = res.adaptive.LD0_lowThreshold(idxKeepYear);
    timesUseDetector = uxtimes(idxKeepYear);
    hplt = plot(hsb(1),timesUseDetector,ld0,'LineWidth',3);
    hplt = plot(hsb(1),timesUseDetector,ld0_high,'LineWidth',3);
    hplt.LineStyle = '-.';
    hplt.Color = [hplt.Color 0.7];
    hplt = plot(hsb(1),timesUseDetector,ld0_low,'LineWidth',3);
    hplt.LineStyle = '-.';
    hplt.Color = [hplt.Color 0.7];
    
    % plot power
    uxtimesPower = datetime(res.timing.PacketGenTime/1000,...
        'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
    
    yearUsePower = mode(year(uxtimesPower));
    idxKeepYearPower = year(uxtimesPower)==yearUsePower;
    uxtimesPowerUse = uxtimesPower(idxKeepYearPower);
    powerBand = powerTable.Band7(idxKeepYearPower);
    
    hplt = plot(hsb(2),uxtimesPowerUse,powerBand,'LineWidth',3);
    hplt.Color = [0.8 0 0 0.7];
    
    
    % plot acc
    insTimes = outdatcompleteAcc.derivedTimes;
    idxwithPacGenTime = find(outdatcompleteAcc.PacketGenTime~=0);
    pacGenTime  = datetime(outdatcompleteAcc.PacketGenTime(idxwithPacGenTime(10))/1000,...
        'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
    insTimesAtThatPoint = insTimes(idxwithPacGenTime(10));
    diff = insTimesAtThatPoint - pacGenTime;
    insTimesCorrected = insTimes - diff;
    yearUsePower = mode(year(insTimesCorrected));
    idxKeepYearPower = year(insTimesCorrected)==yearUsePower;
    insTimesToUse = insTimesCorrected(idxKeepYearPower);
    
    x = outdatcompleteAcc.XSamples(idxKeepYearPower);
    y = outdatcompleteAcc.YSamples(idxKeepYearPower);
    z = outdatcompleteAcc.ZSamples(idxKeepYearPower);
    
    x = x - mean(x);
    y = y - mean(y);
    z = z - mean(z);
    
    avgMov = mean([abs(x) abs(y) abs(z)],2)';
    avgMoveSmoothed = movmean(avgMov,[32*2 0]);
    avgMovePercent = avgMoveSmoothed;
    
    hp = plot(hsb(3),insTimesToUse, avgMovePercent);
    hp.LineWidth = 3;
    hp.Color = [0 0 0.8 0.8];
    title('Internal accelrometer');
    catch
    end
    
end
linkaxes(hsb,'x');

end