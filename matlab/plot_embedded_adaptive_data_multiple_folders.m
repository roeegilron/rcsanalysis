function plot_embedded_adaptive_data_multiple_folders()

%% clear stuff
clear all; close all; clc;
%% get folder list
dirname = '/Volumes/RCS_DATA/RCS02/SummitContinuousBilateralStreaming/New Data/Adaptive/RCS02L';
filenameload = fullfile(dirname,'database.mat');
load(filenameload);
startTime = '10-Mar-2020 13:45:45.660';
endTime   = '13-Mar-2020 08:05:47.036';

dirname = '/Volumes/RCS_DATA/RCS02/SummitContinuousBilateralStreaming/New Data/Adaptive/RCS02R';
filenameload = fullfile(dirname,'database.mat');
load(filenameload);
startTime = '11-Mar-2020 07:55:57.139';
endTime   = '13-Mar-2020 08:06:16.173';
titleuse = 'RCS02 R'; 


% dirname = '/Volumes/RCS_DATA/RCS07/v18_remote_adaptive/SCBS/RCS07L';
% filenameload = fullfile(dirname,'database.mat');
% load(filenameload);
% startTime = '11-Mar-2020 09:26:19.038';
% endTime   = '11-Mar-2020 13:35:34.960';
% titleuse = 'RCS07 L'; 

% dirname = '/Volumes/RCS_DATA/RCS07/v18_remote_adaptive/SCBS/RCS07R';
% filenameload = fullfile(dirname,'database.mat');
% load(filenameload);
% startTime = '11-Mar-2020 09:26:23.783';
% endTime   = '11-Mar-2020 12:15:29.600';
% titleuse = 'RCS07 R'; 

dirname = '/Volumes/RCS_DATA/RCS07/v19_remote_adaptive/RCS07L';
filenameload = fullfile(dirname,'database.mat');
load(filenameload);
startTime = '19-Mar-2020 11:39:11.301';
endTime   = '19-Mar-2020 14:29:36.263';
titleuse = 'RCS07 L'; 

dirname = '/Volumes/RCS_DATA/RCS07/v19_remote_adaptive/RCS07R';
filenameload = fullfile(dirname,'database.mat');
load(filenameload);
startTime = '19-Mar-2020 11:39:11.301';
endTime   = '19-Mar-2020 16:13:43.108';
titleuse = 'RCS07 R'; 


try
    idxuse = tblout.rectime > startTime & tblout.rectime < endTime;
    motherTable = tblout(idxuse,:);
    alldays = day(motherTable.startTime);
catch
    idxkeep = ~cellfun(@(x) isempty(x),tblout.sessname);
    tblout = tblout(idxkeep,:); 
    if iscell(tblout.rectime)
        idxuse = cellfun(@(x) x > startTime,tblout.rectime) & ...
            cellfun(@(x) x < endTime,tblout.rectime);
    else
        idxuse = tblout.rectime  > startTime & tblout.rectime  < endTime;
    end
    motherTable = tblout(idxuse,:);
    alldays = day([motherTable.startTime{:}]);
end
unqdays = unique(alldays);
for u = 1:length(unqdays)
    idxday = alldays ==unqdays(u);
    tblUse = motherTable(idxday,:);
    %% set up figure
    hfig = figure;
    hfig.Color = 'w';
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
            prctile_99 = prctile(ld0,99);
            prctile_1  = prctile(ld0,1); 
            ylim([prctile_1 prctile_99]);
            title(hsb(1),'detector');
            set(hsb(1),'FontSize',16);
            % plot power
            uxtimesPower = datetime(res.timing.PacketGenTime/1000,...
                'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
            
            yearUsePower = mode(year(uxtimesPower));
            idxKeepYearPower = year(uxtimesPower)==yearUsePower;
            uxtimesPowerUse = uxtimesPower(idxKeepYearPower);
            powerBand = powerTable.Band1(idxKeepYearPower);
            
            hplt = plot(hsb(2),uxtimesPowerUse,powerBand,'LineWidth',3);
            hplt.Color = [0.8 0 0 0.7];
            prctile_99 = prctile(powerBand,99);
            prctile_1  = prctile(powerBand,1);
            ylim([prctile_1 prctile_99]);
            title(hsb(2),'power');
            set(hsb(2),'FontSize',16);
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
            avgMoveSmoothed = movmean(avgMov,[64*30 0]);
            avgMovePercent = avgMoveSmoothed;
            
            hp = plot(hsb(3),insTimesToUse, avgMovePercent);
            hp.LineWidth = 3;
            hp.Color = [0 0 0.8 0.8];
            title(hsb(3),'Internal accelrometer');
            set(hsb(3),'FontSize',16);
        catch
            x=2;
        end
        
    end
    linkaxes(hsb,'x');
    axis tight;
    sgtitle(titleuse,'FontSize',24);
end

end