function plot_all_embedded_adaptive_from_database()
addpath(genpath(fullfile(pwd,'toolboxes','panel-2.14')));
close all; clc; clear all;
%% load database
rootdir_orig = '/Users/roee/Starr Lab Dropbox/';
patientFolders  = fullfile(rootdir_orig,'RC+S Patient Un-Synced Data');

database_folder = fullfile(rootdir_orig,'RC+S Patient Un-Synced Data','database');
figdir          = fullfile(database_folder,'figures_adaptive');

load(fullfile(database_folder,'sense_stim_database.mat'));
load(fullfile(database_folder,'database_raw_from_device_settings.mat'));
%%
db = sense_stim_database;


params.group = 'D';
params.stim  = 1;
params.min_size = hours(1);

%% old version of doing this 
reloadDB = 0;

if reloadDB

idxuse = strcmp(db.group,params.group) & ...
    db.stimulation_on == params.stim & ...
    db.duration >= params.min_size;
dbAdapt = db(idxuse,:);

dbAdapt = db;

% loop on this databse and only plot files in which adaptive is actually
% changing
db = dbAdapt;
for d = 1:size(db,1)
    start  = tic;
    patdir = findFilesBVQX(patientFolders,['*', db.patient{d} '*'],struct('dirs',1,'depth',1));
    % don't give it SCBS dir cuz it can also be starr lab dir 
    scbsdir = findFilesBVQX(patdir{1},'SummitContinuousBilateralStreaming',struct('dirs',1));
    patsid = findFilesBVQX(patdir{1},[db.patient{d} ,db.side{d}],struct('dirs',1));
    for ii = 1:length(patsid)
        sessdir = findFilesBVQX(patsid{ii}, ['*',db.sessname{d} ,'*'],struct('dirs',1));
        if ~isempty(sessdir)
            if any(strfind('SummitContinuousBilateralStreaming',sessdir{1}))
                db.recordedUsingSCBS(d) = 1;
            else
                db.recordedUsingSCBS(d) = 0;
            end
            break;
        end
        
    end
    if length(sessdir) > 1 
        if length(sessdir{1}) > length(sessdir{2})
            sessuse = sessdir{2};
        else
            sessuse = sessdir{1};
        end
    else
        sessuse = sessdir{1};
    end
    devdir  = findFilesBVQX(sessuse,'*evice*',struct('dirs',1,'depth',1));
    fnSettings = fullfile(devdir{1},'DeviceSettings.json');
    fnAdaptive = fullfile(devdir{1},'AdaptiveLog.json');
    adaptiveSettings = loadAdaptiveSettings(fnSettings); 
    timeReport = report_start_end_time_td_file_rcs(fnAdaptive);
    if ~isempty(timeReport.startTime)
        db.detectionStreaming(d) = 1; 
        db.detectionTimeStart(d) = timeReport.startTime; 
        db.detectionTimeEnd(d) = timeReport.endTime; 
        db.detectionDuration(d) = timeReport.duration; 
    else
        db.detectionStreaming(d) = 0; 
        db.detectionTimeStart(d) = NaT; 
        db.detectionTimeEnd(d) = NaT; 
        db.detectionDuration(d) = seconds(0); 
    end
    cur(1,1) = adaptiveSettings.currentMa_state0(1);
    cur(1,2) = adaptiveSettings.currentMa_state1(1);
    cur(1,3) = adaptiveSettings.currentMa_state2(1);
    db.CurrentStates(d,:) = cur; 
    db.devdir{d}  = devdir;
    if length( unique(cur) ) > 1 
        db.AdaptiveCurrentChanging(d) = 1;
    else
        db.AdaptiveCurrentChanging(d) = 0;
    end 
    fprintf('%d/%d done in %.2f \n',d,size(db,1),toc(start));
    
end
    save(fullfile(database_folder,'adaptive_database.mat'),'db');
else
    load(fullfile(database_folder,'adaptive_database.mat'),'db');
end
%%
%% new version of doing this 
reloadDB = 1;

if reloadDB
    idxDetection  = masterTableOut.detectionStreaming==1;
    idxRcsPatient = cellfun(@(x) any(strfind(x,'RCS')),masterTableOut.patient);
    idxuse        = idxDetection & idxRcsPatient; 
    dbWithDetection = masterTableOut(idxuse,:); 
    allFilesWithDetection = allDeviceSettingsOut(idxuse);
    dbWithDetection.allFilesWithDetection = allFilesWithDetection;
    % loop on the database with detection and make sure current is changing
    for d = 1:size(dbWithDetection)
        adaptiveSettings = dbWithDetection.adaptiveSettings{d};
        cur(1,1) = adaptiveSettings.currentMa_state0(1);
        cur(1,2) = adaptiveSettings.currentMa_state1(1);
        cur(1,3) = adaptiveSettings.currentMa_state2(1);
        dbWithDetection.cur(d,:) = cur; 
    end
    dbWithDetection.duration.Format = 'hh:mm:ss';
    
end
%%
% plot only 

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
            plot_adbs_day(aDBSplot,figdir,patDB)
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
    mintrim = 10;
    
    % load adapative 
    res = readAdaptiveJson(fnAdaptive);
    cur = res.adaptive.CurrentProgramAmplitudesInMilliamps(1,:);
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
    cur = cur(idxkeepcur);
    
    db.currentTimeSeries{s} = cur; 
    db.timesUseDetector{s} = timesUseDetector;
    db.timesUseCur{s} = timesUseCur;
    db.ld0{s} =  ld0;
    db.ld0_high{s}  = ld0_high;
    db.ld0_low{s} = ld0_low; 
    uniqCurrents = unique(cur); 
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
%%
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
idxSCBS  = cellfun(@(x) any(strfind(x,'SummitContinuousBilateralStreaming')),db.allFilesWithDetection);
dbTiming = db(idxSCBS,:);
xAxisLimits = [min(dbTiming.timeStart) max(dbTiming.timeEnd)];

unqSides = unique(db.side);
for ss = 1:length(unqSides)
    
    idxuse = strcmp(db.side,unqSides{ss});
    dbuse = db(idxuse,:);
    adbsSettings = struct();
    adbsSettings.deviceSettings = dbuse.deviceSettings{end};
    adbsSettings.stimStatus = dbuse.stimStatus{end};
    adbsSettings.stimState = dbuse.stimState{end};
    adbsSettings.adaptiveSettings = dbuse.adaptiveSettings{end};
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
    
    idxSCBS  = cellfun(@(x) any(strfind(x,'SummitContinuousBilateralStreaming')),dbuse.allFilesWithDetection);
    dbuse = dbuse(idxSCBS,:);
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
            % remove outliers
            outlierIdx = isoutlier(ld0);
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
            % remove outliers
            outlierIdx = isoutlier(cur);
            cur = cur(~outlierIdx);
            timesUseCur = timesUseCur(~outlierIdx);
            
            
            
            plot(hsb(idxplot),timesUseCur,cur,'LineWidth',3,'Color',[0 0.8 0 0.7]);
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
hsb(1).XLim = xAxisLimits;
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