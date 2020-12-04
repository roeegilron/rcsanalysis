function plot_all_embedded_adaptive_from_database()
addpath(genpath(fullfile(pwd,'toolboxes','panel-2.14')));
close all; clc; clear all;
%% load database
rootdir_orig = '/Users/roee/Starr Lab Dropbox/';
patientFolders  = fullfile(rootdir_orig,'RC+S Patient Un-Synced Data');

database_folder = fullfile(rootdir_orig,'RC+S Patient Un-Synced Data','database');
figdir          = fullfile(database_folder,'figures_adaptive');
% XXX 
% database_folder = '/Volumes/RCS_DATA/adaptive_at_home_testing/temp_data_power_shut_off/database';
% XXXX 


params.group = 'D';
params.stim  = 1;
params.min_size = hours(1);


%% new version of doing this 
reloadDB = 1;

if reloadDB
    load(fullfile(database_folder,'database_from_device_settings.mat'));
    db = masterTableOut;

    idxDetection  = masterTableOut.detectionStreaming==1;
    idxRcsPatient = cellfun(@(x) any(strfind(x,'RCS')),masterTableOut.patient);
    idxuse        = idxDetection & idxRcsPatient; 
    dbWithDetection = masterTableOut(idxuse,:); 
    dbWithDetection.allFilesWithDetection = dbWithDetection.deviceSettingsFn;
    % loop on the database with detection and make sure current is changing
    for d = 1:size(dbWithDetection)
        adaptiveSettings = dbWithDetection.adaptiveSettings{d};
        cur(1,1) = adaptiveSettings.currentMa_state0(1);
        cur(1,2) = adaptiveSettings.currentMa_state1(1);
        cur(1,3) = adaptiveSettings.currentMa_state2(1);
        dbWithDetection.cur(d,:) = cur; 
    end
    dbWithDetection.duration.Format = 'hh:mm:ss';
    save(fullfile(database_folder,'database_adaptive_only_from_device_settings.mat'),'dbWithDetection');
else
    load(fullfile(database_folder,'database_adaptive_only_from_device_settings.mat'));
end
%% SUB SELECT ONE SUBJECT 
% plot only 
% sub select part of the database to plot 
dbWithDetectionRaw = dbWithDetection;
timeUse = datetime; 
timeUse.TimeZone = dbWithDetectionRaw.timeStart.TimeZone;
timeUse = timeUse - days(20); 
ts = dbWithDetectionRaw.timeStart; 
idxkeep = strcmp(dbWithDetectionRaw.patient,'RCS02') & ... 
          ts > timeUse & ... 
          dbWithDetection.recordedWithScbs;
dbWithDetection = dbWithDetectionRaw(idxkeep,:);
%%  Report latest events to text file 
timeUse = datetime; 
timeUse.TimeZone = dbWithDetectionRaw.timeStart.TimeZone;
timeUse = timeUse - days(20); 
ts = dbWithDetectionRaw.timeStart; 
idxkeep = strcmp(dbWithDetectionRaw.patient,'RCS05') & ... 
          ts > timeUse; 
dbEvents = dbWithDetectionRaw(idxkeep,:);

eventOut = table();
for s = 1:size(dbEvents,1) 
    [devdir,~]  = fileparts(dbEvents.allFilesWithDetection{s});
    fnEvents = fullfile(devdir,'EventLog.json');
    eventTable = loadEventLog(fnEvents);
    if s == 1
        eventOut = eventTable;
    else
        eventOut = [eventOut; eventTable];
    end
end
idxDontKeep = cellfun(@(x) any(strfind(x,'BatteryLevel')),eventOut.EventType);
eventsPrint = eventOut(~idxDontKeep,:); 
%% 

%% loop on adaptive database and create plots on a daily basis
% ploy only adaptive with large chnages 
uniquePatients = unique(dbWithDetection.patient);
for p = 1:length(uniquePatients)
    patDB = dbWithDetection(strcmp(dbWithDetection.patient,uniquePatients{p}) , :);
    
    % find the unique days in each recordings
    tbl = table();
    [tbl.y,tbl.m,tbl.d] = ymd(patDB.timeStart);
    unqDays = unique(tbl,'rows');
    % only look at 2020 data 
    for u = 1:size(unqDays,1)
        idxPlot = year(patDB.timeStart) == unqDays.y(u) & ...
            month(patDB.timeStart) == unqDays.m(u) & ...
            day(patDB.timeStart) == unqDays.d(u);
        aDBSplot = patDB(idxPlot,:);
        hasSCBSdata = cellfun(@(x) any(strfind(x,'SummitContinuousBilateralStreaming')),aDBSplot.allFilesWithDetection) ;
        totalTime = sum(aDBSplot.duration); 
        totalTime.Format = 'hh:mm:ss';
        if sum(hasSCBSdata) >= 1  
%             plot_adbs_day(aDBSplot,figdir,patDB)
            compare_current_and_log_file_current(aDBSplot,figdir,patDB);
        else % sometiems it's worth checking if you have reocded from SCBS somteims not... 
            warning('not reocrded with SCBS according to path');
%             plot_adbs_day(aDBSplot,figdir,patDB)
        end
    end
end
end

function plot_adbs_day(db,figdir,backupdb)
close all;
% db is what you will use to plot the aDBS session from one day 
% fid dir is output 
% backupdb is all aDBS session database for this subject 
% this is in order to get prio settings (fft, power) in case they don't
% exist in this days database since aDBS was not configured) 

%% decide which files actually have current changes 
%% and find all the files / load data 
for s = 1:size(db,1) 
    [devdir,~]  = fileparts(db.allFilesWithDetection{s});
    fnAdaptive = fullfile(devdir,'AdaptiveLog.json');
    fnDeviceSettings = fullfile(devdir,'DeviceSettings.json');
    fnEvents = fullfile(devdir,'EventLog.json');
    eventTable = loadEventLog(fnEvents);
    ffTxt = findFilesBVQX(devdir, '*LOG.txt');
    if ~isempty(ffTxt)
        adaptiveLog = read_adaptive_txt_log(ffTxt{1});
    end
    mintrim = 10;
    
    % load adapative 
    res = readAdaptiveJson(fnAdaptive);
    currentTimeSeries = res.adaptive.CurrentProgramAmplitudesInMilliamps(1,:);
    timestamps = datetime(datevec(res.timing.timestamp./86400 + datenum(2000,3,1,0,0,0))); % medtronic time - LSB is seconds
    uxtimes = datetime(res.timing.PacketGenTime/1000,...
        'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
    yearUse = mode(year(uxtimes));
    idxKeepYear = year(uxtimes)==yearUse;
    
    
    
    % inputs
    ld0 = res.adaptive.LD0_output(idxKeepYear);
    ld0_high = res.adaptive.LD0_highThreshold(idxKeepYear);
    ld0_low  = res.adaptive.LD0_lowThreshold(idxKeepYear);
    timesUseDetector = uxtimes(idxKeepYear);
    idxkeepdet = timesUseDetector > (timesUseDetector(1) + minutes(mintrim));
    
    timesUseDetector = timesUseDetector(idxkeepdet);
    ld0 = ld0(idxkeepdet);
    ld0_high = ld0_high(idxkeepdet);
    ld0_low = ld0_low(idxkeepdet);
    
    % get rid of negative diffs (e.g. times for past)
    idxbad = find(seconds(diff(timesUseDetector))<0)+1;
    idxkeep = setxor(1:length(timesUseDetector),idxbad);
    timesUseDetector = timesUseDetector(idxkeep);
    ld0 = ld0(idxkeep);
    ld0_high = ld0_high(idxkeep);
    ld0_low = ld0_low(idxkeep);
    
    timesUseCur = uxtimes(idxKeepYear);
    idxkeepcur = timesUseCur > (timesUseCur(1) + minutes(mintrim));
    timesUseCur = timesUseCur(idxkeepcur);
    
    % trim start of file
    currentTimeSeriesTrimmed = currentTimeSeries(idxkeepcur);
    
    db.currentTimeSeries{s} = currentTimeSeriesTrimmed; 
    db.timesUseDetector{s} = timesUseDetector;
    db.timesUseCur{s} = timesUseCur;
    db.ld0{s} =  ld0;
    db.ld0_high{s}  = ld0_high;
    db.ld0_low{s} = ld0_low; 
    db.eventTable{s} = eventTable;
    db.adaptiveLog{s}  = adaptiveLog;
    uniqCurrents = unique(currentTimeSeriesTrimmed); 
    if length(uniqCurrents) == 1
        db.adaptive_running(s) = 0; 
    else
        db.adaptive_running(s) = 1; 
    end

end

%% set up figure
hfig = figure;
hfig.Color = 'w';
hpanel = panel();
hpanel.pack('h',{15 [] 15});
hpanel(2).pack({5 24 24 24 24});
hpanel.select('all');
hpanel.fontsize = 12;

nrows = 5;
cntpltPanel = 1; 
titles = {'control signal L','current L', 'control signal R','current R'};
for i = 2:nrows
    hpanel(2,i).select();
    hsb(cntpltPanel) = gca;
    hold(hsb(cntpltPanel),'on');
    title(titles{cntpltPanel});
    cntpltPanel = cntpltPanel + 1;
end
%% plot data
% idxSCBS  = cellfun(@(x) any(strfind(x,'SummitContinuousBilateralStreaming')),db.allFilesWithDetection);
% dbTiming = db(idxSCBS,:);
dbTiming = db;
xAxisLimits = [min(dbTiming.timeStart) max(dbTiming.timeEnd)];

unqSides = unique(db.side);
for ss = 1:length(unqSides)
    
    idxuse = strcmp(db.side,unqSides{ss});
    dbuse = db(idxuse,:);
    adbsSettings = struct();
    % get the last device settings on this day
    idxDeviceSettings = find(cellfun(@(x) (istable(x) & size(x,1)>=1),dbuse.senseSettingsMultiple) == 1,1,'last');
    if ~isempty(idxDeviceSettings)
        adbsSettings.deviceSettings = dbuse.senseSettingsMultiple{idxDeviceSettings};
    else
        % need to find ffet settings from the backup database
        backupdbCorrectSide = backupdb( strcmp(backupdb.side,unqSides{ss}), :);
        backupdbCorrectSide = sortrows(backupdbCorrectSide,'timeStart');
        idxBaxkupBeforeThisSession = backupdbCorrectSide.timeStart < dbuse.timeStart(1);
        backupUse = backupdbCorrectSide(idxBaxkupBeforeThisSession,:);
        idxDeviceSettings = find(cellfun(@(x) (istable(x) & size(x,1)>=1),backupUse.senseSettingsMultiple) == 1,1,'last');
        if isempty(idxDeviceSettings)
            % device settings  missing
            adbsSettings.deviceSettings = table();
        else
            adbsSettings.deviceSettings = backupUse.deviceSettings{idxDeviceSettings};
        end
    end

    % get the last stim status on this day 
    adbsSettings.stimStatus = dbuse.stimStateChanges{end};
    idxStimSettings = find(cellfun(@(x) (istable(x) & size(x,1)>=1),dbuse.stimStateChanges) == 1,1,'last');
    if ~isempty(idxStimSettings)
        adbsSettings.stimStatus = dbuse.stimStateChanges{idxStimSettings};
    end
    
    % get the last stim state on this day 
    idxStimStatus = find(cellfun(@(x) (istable(x) & size(x,1)>=1),dbuse.stimState) == 1,1,'last');
    if ~isempty(idxStimStatus)
        adbsSettings.stimState = dbuse.stimState{idxStimStatus};
    end
    
     
    % get the last adaptive settings on this day 
    idxAdaptiveSettings = find(cellfun(@(x) (istable(x) & size(x,1)>=1),dbuse.adaptiveSettings) == 1,1,'last');
    if ~isempty(idxAdaptiveSettings)
        adbsSettings.adaptiveSettings = dbuse.adaptiveSettings{idxAdaptiveSettings};
    end
    
    
    % get the last power and fft table in this day 
    idxFft = find(cellfun(@(x) (size(x,1)),dbuse.fftTable) == 1,1,'last');
    if ~isempty(idxFft)
        adbsSettings.ffTable = dbuse.fftTable{idxFft};
    else
        % need to find ffet settings from the backup database 
        backupdbCorrectSide = backupdb( strcmp(backupdb.side,unqSides{ss}), :);
        backupdbCorrectSide = sortrows(backupdbCorrectSide,'timeStart');
        idxBaxkupBeforeThisSession = backupdbCorrectSide.timeStart < dbuse.timeStart(1);
        backupUse = backupdbCorrectSide(idxBaxkupBeforeThisSession,:);
        idxFft = find(cellfun(@(x) (size(x,1)),backupUse.fftTable) == 1,1,'last');
        if isempty(idxFft)
            % fft table missing 
            adbsSettings.ffTable = table();
        else
            adbsSettings.ffTable = backupUse.fftTable{idxFft};
        end
    end
    idxPower = find(cellfun(@(x) (size(x,1)),dbuse.powerTable) == 1,1,'last');
    if ~isempty(idxPower)
        adbsSettings.powerTable = dbuse.powerTable{idxPower};
    else
        % need to find ffet settings from the backup database
        backupdbCorrectSide = backupdb( strcmp(backupdb.side,unqSides{ss}), :);
        backupdbCorrectSide = sortrows(backupdbCorrectSide,'timeStart');
        idxBaxkupBeforeThisSession = backupdbCorrectSide.timeStart < dbuse.timeStart(1);
        backupUse = backupdbCorrectSide(idxBaxkupBeforeThisSession,:);
        idxPower = find(cellfun(@(x) (size(x,1)),backupUse.powerTable) == 1,1,'last');
        if isempty(idxPower)
            % fft table missing
            adbsSettings.powerTable = table();
        else
            adbsSettings.powerTable = backupUse.powerTable{idxPower};
        end
    end
    
    % XXXX 
    % don't check to see if recorded with SCBS 
    % XXXX 
%     idxSCBS  = cellfun(@(x) any(strfind(x,'SummitContinuousBilateralStreaming')),dbuse.allFilesWithDetection);
%     dbuse = dbuse(idxSCBS,:);
    % only plot data from 
    for d = 1:size(dbuse,1)
        % plot the detector
        if strcmp(dbuse.side(d),'L')
            idxplot = 1;
        elseif strcmp(dbuse.side(d),'R')
            idxplot = 3;
        end
        timesUseDetector = dbuse.timesUseDetector{d};
        ld0 = dbuse.ld0{d};
        ld0_high = dbuse.ld0_high{d};
        ld0_low = dbuse.ld0_low{d};
        if ~isempty(ld0)
            % only remove outliers in the threshold 
            outlierIdx = isoutlier(ld0_high);
            ld0 = ld0(~outlierIdx);
            ld0_high = ld0_high(~outlierIdx);
            ld0_low = ld0_low(~outlierIdx);
            timesUseDetector = timesUseDetector(~outlierIdx);
            
            
            hplt = plot(hsb(idxplot),timesUseDetector,ld0,'LineWidth',2.5,'Color',[0 0 0.8 ]);
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
            ttlus = sprintf('Control signal %s',unqSides{ss});
            title(hsb(idxplot),ttlus);
            ylabel(hsb(idxplot),'Control signal (a.u.)');
            set(hsb(idxplot),'FontSize',12);
            
            % plot event table 
            ylims = hsb(idxplot).YLim;
            eTable = db.eventTable{d};
            idxMeds = strcmp(eTable.EventType,'medication');
            ePlt = eTable(idxMeds,:);
            for e = 1:size(ePlt)
                xtemp = ePlt.EventSubType{e};
                dateMed = datetime(xtemp(end-21:end),'InputFormat','MM_dd_yyyy hh:mm:SS aa');
                dateMed.TimeZone = timesUseDetector.TimeZone;
                plot(hsb(idxplot),[dateMed dateMed],ylims,'Color',[0.8 0.8 0 0.5],'LineWidth',5);
                medTaken = ePlt.EventSubType{e}(1:end-30);
                text(hsb(idxplot),dateMed,ylims(2)*(0.9-e*0.1),medTaken);
            end
            
            idxCon  = strcmp(eTable.EventType,'conditions');
            ePlt = eTable(idxCon,:);
            for e = 1:size(ePlt)
                dateMed = ePlt.UnixOffsetTime(e);
                dateMed.TimeZone = timesUseDetector.TimeZone;
                plot(hsb(idxplot),[dateMed dateMed],ylims,'Color',[0 0.9 0.8 0.5],'LineWidth',5);
                medTaken = ePlt.EventSubType{e};
                text(hsb(idxplot),dateMed,ylims(2)*(0.5-e*0.1),medTaken);
            end
            
            
            
            idxCom  = strcmp(eTable.EventType,'extra_comments');
            ePlt = eTable(idxCom,:);
            for e = 1:size(ePlt)
                dateMed = ePlt.UnixOffsetTime(e);
                dateMed.TimeZone = timesUseDetector.TimeZone;
                plot(hsb(idxplot),[dateMed dateMed],ylims,'Color',[0.8 0 0.9 0.5],'LineWidth',5);
                medTaken = ePlt.EventSubType{e};
                text(hsb(idxplot),dateMed,ylims(2)*(0.2-e*0.1),medTaken);
            end
            %
            
            
            
            % plot the current
            if strcmp(dbuse.side(d),'L')
                idxplot = 2;
            elseif strcmp(dbuse.side(d),'R')
                idxplot = 4;
            end
            timesUseCur = dbuse.timesUseCur{d};
            cur = dbuse.currentTimeSeries{d};
            % don't  remove outliers for current
            % but remove current above 10 as they are unlikely to be real 
            outlierIdx = cur>10;
            cur = cur(~outlierIdx);
            timesUseCur = timesUseCur(~outlierIdx);
            
            
            
            plot(hsb(idxplot),timesUseCur,cur,'LineWidth',3,'Color',[0 0.8 0 0.7]);
            % plot smoothed version of curernt 
            fftInterval = adbsSettings.ffTable.interval; 
            tenMinuteInIntervals = (10*60*1e3)/fftInterval;
            plot(hsb(idxplot),timesUseCur,movmean( cur,[tenMinuteInIntervals 1]),'LineWidth',4,'Color',[0 0.0 0.8 0.2]);

            for i = 1:3
                states{i} = sprintf('%0.1fmA',dbuse.cur(d,i));
                
                if i == 2
                    if dbuse.cur(d,i) == 25.5
                        states{i} = 'HOLD';
                    end
                end
            end
            ttlus = sprintf('Current in mA %s [%s, %s, %s]',unqSides{ss},states{1},states{2},states{3});
            title(hsb(idxplot) ,ttlus);
            ylabel( hsb(idxplot) ,'Current (mA)');
            set( hsb(idxplot),'FontSize',16);
            ylims = [min([dbuse.currentTimeSeries{:}]) max([dbuse.currentTimeSeries{:}])];
            if ylims(1) == ylims(2) 
               ylims(1) = ylims(1) * 0.9;
               ylims(2) = ylims(2) * 1.1;
            end
            set(hsb(idxplot),'YLim',ylims);
        end
    end
    strPrint = getAdaptiveHumanReadaleSettings(adbsSettings,0);
    if ~isempty(strPrint)
        if strcmp(unqSides{ss},'L')
            hpanel(1).select();
            hsubUse = gca;
            strPrint{1} = [strPrint{1} ' L'];
        else
            hpanel(3).select();
            hsubUse = gca;
            strPrint{1} = [strPrint{1} ' R'];
        end
        hsubUse = gca;
        a = annotation('textbox', hsubUse.Position, 'String', "hi");
        a.FontSize = 12;
        
        set(gca,'FontSize',12);
        set(gca, 'box','off','XTickLabel',[],'XTick',[],'YTickLabel',[],'YTick',[])
        set(gca,'XColor','none')
        set(gca,'YColor','none')
        
        
        a.String = strPrint;
        a.EdgeColor = 'none';
    end
end
% get link axes to work - time zone issue with empty axes
for i  =  1:length(hsb)
    if  ~ isdatetime(hsb(i).XLim)
        plot(hsb(i),[xAxisLimits(1) xAxisLimits(1)],[ 0 0],'Color',[0 0 0 ]);
    end
    if i ~=4
        set(hsb(i), 'box','off','XTick',[])
        set(hsb(i),'XColor','none')
    end
end
linkaxes(hsb,'x');
% hsb(1).XLim = xAxisLimits;
ttlLarge{1,1} = dbuse.patient{1};
[y,m,d] = ymd(dbuse.timeStart(1));
% use the top plot to plot the title 
hpanel(2,1).select();
hsbTitle = gca();
set(gca,'FontSize',16);
set(gca, 'box','off','XTickLabel',[],'XTick',[],'YTickLabel',[],'YTick',[])
set(gca,'XColor','none')
set(gca,'YColor','none')
ttlLarge{2,1} = sprintf('%.4d/%.2d/%.2d',y,m,d);
title(hsbTitle,ttlLarge,'FontSize',16);


hpanel.margintop = 15;
hpanel.marginbottom = 15;
hpanel.de.margin = 7;
hpanel(1).marginright = 55;




% save figure;
fig_title = sprintf('%s_%d_%0.2d-%0.2d',dbuse.patient{1},y,m,d);
prfig.plotwidth           = 28;
prfig.plotheight          = 12;
prfig.figdir              = figdir;
prfig.figtype             = '-djpeg';
prfig.closeafterprint     = 0;
prfig.resolution          = 300;
prfig.figname             = fig_title;
plot_hfig(hfig,prfig);
close(hfig);


end

function compare_current_and_log_file_current(db,figdir,backupdb)
close all;
% db is what you will use to plot the aDBS session from one day 
% fid dir is output 
% backupdb is all aDBS session database for this subject 
% this is in order to get prio settings (fft, power) in case they don't
% exist in this days database since aDBS was not configured) 

%% decide which files actually have current changes 
%% and find all the files / load data 
for s = 1:size(db,1) 
    [devdir,~]  = fileparts(db.allFilesWithDetection{s});
    fnAdaptive = fullfile(devdir,'AdaptiveLog.json');
    fnDeviceSettings = fullfile(devdir,'DeviceSettings.json');
    fnEvents = fullfile(devdir,'EventLog.json');
    eventTable = loadEventLog(fnEvents);
    ffTxt = findFilesBVQX(devdir, '*LOG.txt');
    if ~isempty(ffTxt)
        adaptiveLog = read_adaptive_txt_log(ffTxt{1});
    end
    mintrim = 10;
    
    % load adapative 
    res = readAdaptiveJson(fnAdaptive);
    currentTimeSeries = res.adaptive.CurrentProgramAmplitudesInMilliamps(1,:);
    timestamps = datetime(datevec(res.timing.timestamp./86400 + datenum(2000,3,1,0,0,0))); % medtronic time - LSB is seconds
    uxtimes = datetime(res.timing.PacketGenTime/1000,...
        'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
    yearUse = mode(year(uxtimes));
    idxKeepYear = year(uxtimes)==yearUse;
    
    
    
    % inputs
    ld0 = res.adaptive.LD0_output(idxKeepYear);
    ld0_high = res.adaptive.LD0_highThreshold(idxKeepYear);
    ld0_low  = res.adaptive.LD0_lowThreshold(idxKeepYear);
    timesUseDetector = uxtimes(idxKeepYear);
    idxkeepdet = timesUseDetector > (timesUseDetector(1) + minutes(mintrim));
    
    timesUseDetector = timesUseDetector(idxkeepdet);
    ld0 = ld0(idxkeepdet);
    ld0_high = ld0_high(idxkeepdet);
    ld0_low = ld0_low(idxkeepdet);
    
    % get rid of negative diffs (e.g. times for past)
    idxbad = find(seconds(diff(timesUseDetector))<0)+1;
    idxkeep = setxor(1:length(timesUseDetector),idxbad);
    timesUseDetector = timesUseDetector(idxkeep);
    ld0 = ld0(idxkeep);
    ld0_high = ld0_high(idxkeep);
    ld0_low = ld0_low(idxkeep);
    
    timesUseCur = uxtimes(idxKeepYear);
    idxkeepcur = timesUseCur > (timesUseCur(1) + minutes(mintrim));
    timesUseCur = timesUseCur(idxkeepcur);
    
    % trim start of file
    currentTimeSeriesTrimmed = currentTimeSeries(idxkeepcur);
    
    db.currentTimeSeries{s} = currentTimeSeriesTrimmed; 
    db.timesUseDetector{s} = timesUseDetector;
    db.timesUseCur{s} = timesUseCur;
    db.ld0{s} =  ld0;
    db.ld0_high{s}  = ld0_high;
    db.ld0_low{s} = ld0_low; 
    db.eventTable{s} = eventTable;
    db.adaptiveLog{s}  = adaptiveLog;
    uniqCurrents = unique(currentTimeSeriesTrimmed); 
    if length(uniqCurrents) == 1
        db.adaptive_running(s) = 0; 
    else
        db.adaptive_running(s) = 1; 
    end

end

%% set up figure
hfig = figure;
hfig.Color = 'w';
hpanel = panel();
hpanel.pack('h',{15 [] 15});
hpanel(2).pack({5 24 24 24 24});
hpanel.select('all');
hpanel.fontsize = 12;

nrows = 5;
cntpltPanel = 1; 
titles = {'control signal L','current L', 'control signal R','current R'};
for i = 2:nrows
    hpanel(2,i).select();
    hsb(cntpltPanel) = gca;
    hold(hsb(cntpltPanel),'on');
    title(titles{cntpltPanel});
    cntpltPanel = cntpltPanel + 1;
end
%% plot data
% idxSCBS  = cellfun(@(x) any(strfind(x,'SummitContinuousBilateralStreaming')),db.allFilesWithDetection);
% dbTiming = db(idxSCBS,:);
dbTiming = db;
xAxisLimits = [min(dbTiming.timeStart) max(dbTiming.timeEnd)];

unqSides = unique(db.side);
for ss = 1:length(unqSides)
    
    idxuse = strcmp(db.side,unqSides{ss});
    dbuse = db(idxuse,:);
    adbsSettings = struct();
    % get the last device settings on this day
    idxDeviceSettings = find(cellfun(@(x) (istable(x) & size(x,1)>=1),dbuse.senseSettingsMultiple) == 1,1,'last');
    if ~isempty(idxDeviceSettings)
        adbsSettings.deviceSettings = dbuse.senseSettingsMultiple{idxDeviceSettings};
    else
        % need to find ffet settings from the backup database
        backupdbCorrectSide = backupdb( strcmp(backupdb.side,unqSides{ss}), :);
        backupdbCorrectSide = sortrows(backupdbCorrectSide,'timeStart');
        idxBaxkupBeforeThisSession = backupdbCorrectSide.timeStart < dbuse.timeStart(1);
        backupUse = backupdbCorrectSide(idxBaxkupBeforeThisSession,:);
        idxDeviceSettings = find(cellfun(@(x) (istable(x) & size(x,1)>=1),backupUse.senseSettingsMultiple) == 1,1,'last');
        if isempty(idxDeviceSettings)
            % device settings  missing
            adbsSettings.deviceSettings = table();
        else
            adbsSettings.deviceSettings = backupUse.deviceSettings{idxDeviceSettings};
        end
    end

    % get the last stim status on this day 
    adbsSettings.stimStatus = dbuse.stimStateChanges{end};
    idxStimSettings = find(cellfun(@(x) (istable(x) & size(x,1)>=1),dbuse.stimStateChanges) == 1,1,'last');
    if ~isempty(idxStimSettings)
        adbsSettings.stimStatus = dbuse.stimStateChanges{idxStimSettings};
    end
    
    % get the last stim state on this day 
    idxStimStatus = find(cellfun(@(x) (istable(x) & size(x,1)>=1),dbuse.stimState) == 1,1,'last');
    if ~isempty(idxStimStatus)
        adbsSettings.stimState = dbuse.stimState{idxStimStatus};
    end
    
     
    % get the last adaptive settings on this day 
    idxAdaptiveSettings = find(cellfun(@(x) (istable(x) & size(x,1)>=1),dbuse.adaptiveSettings) == 1,1,'last');
    if ~isempty(idxAdaptiveSettings)
        adbsSettings.adaptiveSettings = dbuse.adaptiveSettings{idxAdaptiveSettings};
    end
    
    
    % get the last power and fft table in this day 
    idxFft = find(cellfun(@(x) (size(x,1)),dbuse.fftTable) == 1,1,'last');
    if ~isempty(idxFft)
        adbsSettings.ffTable = dbuse.fftTable{idxFft};
    else
        % need to find ffet settings from the backup database 
        backupdbCorrectSide = backupdb( strcmp(backupdb.side,unqSides{ss}), :);
        backupdbCorrectSide = sortrows(backupdbCorrectSide,'timeStart');
        idxBaxkupBeforeThisSession = backupdbCorrectSide.timeStart < dbuse.timeStart(1);
        backupUse = backupdbCorrectSide(idxBaxkupBeforeThisSession,:);
        idxFft = find(cellfun(@(x) (size(x,1)),backupUse.fftTable) == 1,1,'last');
        if isempty(idxFft)
            % fft table missing 
            adbsSettings.ffTable = table();
        else
            adbsSettings.ffTable = backupUse.fftTable{idxFft};
        end
    end
    idxPower = find(cellfun(@(x) (size(x,1)),dbuse.powerTable) == 1,1,'last');
    if ~isempty(idxPower)
        adbsSettings.powerTable = dbuse.powerTable{idxPower};
    else
        % need to find ffet settings from the backup database
        backupdbCorrectSide = backupdb( strcmp(backupdb.side,unqSides{ss}), :);
        backupdbCorrectSide = sortrows(backupdbCorrectSide,'timeStart');
        idxBaxkupBeforeThisSession = backupdbCorrectSide.timeStart < dbuse.timeStart(1);
        backupUse = backupdbCorrectSide(idxBaxkupBeforeThisSession,:);
        idxPower = find(cellfun(@(x) (size(x,1)),backupUse.powerTable) == 1,1,'last');
        if isempty(idxPower)
            % fft table missing
            adbsSettings.powerTable = table();
        else
            adbsSettings.powerTable = backupUse.powerTable{idxPower};
        end
    end
    
    % XXXX 
    % don't check to see if recorded with SCBS 
    % XXXX 
%     idxSCBS  = cellfun(@(x) any(strfind(x,'SummitContinuousBilateralStreaming')),dbuse.allFilesWithDetection);
%     dbuse = dbuse(idxSCBS,:);
    % only plot data from 
    for d = 1:size(dbuse,1)
        % plot the detector
        if strcmp(dbuse.side(d),'L')
            idxplot = 1;
        elseif strcmp(dbuse.side(d),'R')
            idxplot = 3;
        end
        timesUseDetector = dbuse.timesUseDetector{d};
        ld0 = dbuse.ld0{d};
        ld0_high = dbuse.ld0_high{d};
        ld0_low = dbuse.ld0_low{d};
        if ~isempty(ld0)
            % only remove outliers in the threshold 
            outlierIdx = isoutlier(ld0_high);
            ld0 = ld0(~outlierIdx);
            ld0_high = ld0_high(~outlierIdx);
            ld0_low = ld0_low(~outlierIdx);
            timesUseDetector = timesUseDetector(~outlierIdx);
            
            
            hplt = plot(hsb(idxplot),timesUseDetector,ld0,'LineWidth',2.5,'Color',[0 0 0.8 ]);
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
            ttlus = sprintf('Control signal %s',unqSides{ss});
            title(hsb(idxplot),ttlus);
            ylabel(hsb(idxplot),'Control signal (a.u.)');
            set(hsb(idxplot),'FontSize',12);
            
            
            
            % plot the current
            if strcmp(dbuse.side(d),'L')
                idxplot = 2;
            elseif strcmp(dbuse.side(d),'R')
                idxplot = 4;
            end
            timesUseCur = dbuse.timesUseCur{d};
            cur = dbuse.currentTimeSeries{d};
            % don't  remove outliers for current
            % but remove current above 10 as they are unlikely to be real 
            outlierIdx = cur>10;
            cur = cur(~outlierIdx);
            timesUseCur = timesUseCur(~outlierIdx);
            
            
            
            plot(hsb(idxplot),timesUseCur,cur,'LineWidth',3,'Color',[0 0.8 0 0.7]);
            % plot smoothed version of curernt 
            fftInterval = adbsSettings.ffTable.interval; 
            tenMinuteInIntervals = (10*60*1e3)/fftInterval;
            plot(hsb(idxplot),timesUseCur,movmean( cur,[tenMinuteInIntervals 1]),'LineWidth',4,'Color',[0 0.0 0.8 0.2]);

            for i = 1:3
                states{i} = sprintf('%0.1fmA',dbuse.cur(d,i));
                
                if i == 2
                    if dbuse.cur(d,i) == 25.5
                        states{i} = 'HOLD';
                    end
                end
            end
            ttlus = sprintf('Current in mA %s [%s, %s, %s]',unqSides{ss},states{1},states{2},states{3});
            title(hsb(idxplot) ,ttlus);
            ylabel( hsb(idxplot) ,'Current (mA)');
            set( hsb(idxplot),'FontSize',16);
            ylims = [min([dbuse.currentTimeSeries{:}]) max([dbuse.currentTimeSeries{:}])];
            if ylims(1) == ylims(2) 
               ylims(1) = ylims(1) * 0.9;
               ylims(2) = ylims(2) * 1.1;
            end
            set(hsb(idxplot),'YLim',ylims);
        end
    end
    % loop on adaptive logs and see if something to plot in range 
    for d = 1:size(dbuse,1)
        % plot the current
        if strcmp(dbuse.side(d),'L')
            idxplot = 2;
        elseif strcmp(dbuse.side(d),'R')
            idxplot = 4;
        end
        if ~isempty(db.adaptiveLog{d})
            aLog = db.adaptiveLog{d};
            xlims = get(hsb(idxplot),'Xlim');
            aLog.time.TimeZone = xlims.TimeZone;
            idxkeep = aLog.time > xlims(1) & aLog.time < xlims(2);
            if sum(idxkeep) > 0
                plot(hsb(idxplot),aLog.time,aLog.prog0,'Color',[0.8 0 0 0.2],'LineWidth',4);
            end
        end
    end
    
    
    strPrint = getAdaptiveHumanReadaleSettings(adbsSettings,0);
    if ~isempty(strPrint)
        if strcmp(unqSides{ss},'L')
            hpanel(1).select();
            hsubUse = gca;
            strPrint{1} = [strPrint{1} ' L'];
        else
            hpanel(3).select();
            hsubUse = gca;
            strPrint{1} = [strPrint{1} ' R'];
        end
        hsubUse = gca;
        a = annotation('textbox', hsubUse.Position, 'String', "hi");
        a.FontSize = 12;
        
        set(gca,'FontSize',12);
        set(gca, 'box','off','XTickLabel',[],'XTick',[],'YTickLabel',[],'YTick',[])
        set(gca,'XColor','none')
        set(gca,'YColor','none')
        
        
        a.String = strPrint;
        a.EdgeColor = 'none';
    end
end
% get link axes to work - time zone issue with empty axes
for i  =  1:length(hsb)
    if  ~ isdatetime(hsb(i).XLim)
        plot(hsb(i),[xAxisLimits(1) xAxisLimits(1)],[ 0 0],'Color',[0 0 0 ]);
    end
    if i ~=4
        set(hsb(i), 'box','off','XTick',[])
        set(hsb(i),'XColor','none')
    end
end
linkaxes(hsb,'x');
% hsb(1).XLim = xAxisLimits;
ttlLarge{1,1} = dbuse.patient{1};
[y,m,d] = ymd(dbuse.timeStart(1));
% use the top plot to plot the title 
hpanel(2,1).select();
hsbTitle = gca();
set(gca,'FontSize',16);
set(gca, 'box','off','XTickLabel',[],'XTick',[],'YTickLabel',[],'YTick',[])
set(gca,'XColor','none')
set(gca,'YColor','none')
ttlLarge{2,1} = sprintf('%.4d/%.2d/%.2d',y,m,d);
title(hsbTitle,ttlLarge,'FontSize',16);


hpanel.margintop = 15;
hpanel.marginbottom = 15;
hpanel.de.margin = 7;
hpanel(1).marginright = 55;




% save figure;
fig_title = sprintf('%s_%d_%0.2d-%0.2d_adaptive_logs',dbuse.patient{1},y,m,d);
prfig.plotwidth           = 28;
prfig.plotheight          = 12;
prfig.figdir              = figdir;
prfig.figtype             = '-djpeg';
prfig.closeafterprint     = 0;
prfig.resolution          = 300;
prfig.figname             = fig_title;
plot_hfig(hfig,prfig);
close(hfig);


end