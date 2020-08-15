function rcsAtHome_figures_figure7_v2()
%% stn beta activity is detectable during stim
% panel a - single subject - on , off and chornic stim
% panel b plot violin plots of average beta power
% panel c - plot embedded adaptive data
close all;

plotpanels = 0;
addpath(genpath(fullfile(pwd,'toolboxes','panel-2.14')));
if ~plotpanels
    hfig = figure;
    hfig.Color = 'w';
    hpanel = panel();
    hpanel.pack({0.4, 0.6});
    hpanel(1).pack(1,3); % panel a + b
    hpanel(2).pack(3,1); % panel c adaptive
    %     hpanel.select('all');
    %     hpanel.identify();
    
end
figdir = '/Users/roee/Starr_Lab_Folder/Writing/papers/2019_LongTerm_RCS_recordings/figures/final_figures/Fig7.1_new_adaptive';
figdir = '/Users/roee/Box/rcs paper paper on first five bilateral implants/revision for nature biotechnology/figures/Fig7.1_new_adaptive';
dirsave = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/adaptive_results_figure';
dirsave = '/Users/roee/Box/rcs paper paper on first five bilateral implants/revision for nature biotechnology/figures/Fig7.1_new_adaptive/adaptive_results_figure';
%% panel A plot adaptive data
close all; clc;
loadBigDB = 0;
if loadBigDB
    dirSave = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database';
    load(fullfile(dirSave, 'database_raw_from_device_settings.mat'));
    idxDetection  = masterTableOut.detectionStreaming==1;
    idxRcsPatient = cellfun(@(x) any(strfind(x,'RCS')),masterTableOut.patient);
    idxuse        = idxDetection & idxRcsPatient;
    dbWithDetection = masterTableOut(idxuse,:);
    allFilesWithDetection = allDeviceSettingsOut(idxuse);
    dbWithDetection.allFilesWithDetection = allFilesWithDetection;
    dbWithDetection.duration.Format = 'hh:mm:ss';
    patient = 'RCS02';
    patDB = dbWithDetection(strcmp(dbWithDetection.patient,patient) , :);


end
%%



%% PLOT ALL 
% feedback 
% put beta in the top only left side 
% then do gamma that requires insetting - and then go to zoom. 
% give more room to the gamma long form during the day. 
% unilateral of each RCS06 April 20th 
% best bilatearl control exmaple. Also show that we did this with 
% bilatarel control. 

% Beta should be. 
% in figure title include the number of hours. 
% Adaptive DBS impelmented at home
% A. subthalamic beta 
% B cortical gamma signals 
% make sure that you 
% 8 hours over several on / off cycles. 

% rcs02 keep April 27th for Gamma. 
% show more territory that shows no changes 
% show noon to 1pm.
% the point being rapid changes in stim to reflect rapid changes 
% to gamma 

% supplement:
% show one bilateral example of RCS06 
% Best one 
% show one bilateral esxampe of Rcs02 
% potentialy showing gamma on the other side 
% not moving. 
% (it might have had a lot of flucutation). 
% get rid of the treshold in the supplermnt for the gamma open loop
% side that didn't have adaptive should go below. 

% add violin plots for stim on/ stim off data 
% for all the other patients 
% break this out into another figure with violin plots 
% include gamma as well. 
% sensing / during stim is the main point. 
% take a look. 

% figure 5 make a correaltion of on/off UDPRS and AUC average score. 
% John. 


% cartoon of schematic cartoon - arrow to cortical lead. 
% add Ken's stragetg 
addpath(genpath(fullfile(pwd,'toolboxes','panel-2.14')));
%%
close all;
clear hsb*

hfig = figure;
hfig.Position = [1281          80        1280        1265];
lineWidth = 0.5;

globalFontSize = 20;
hfig.Color = 'w';
hpanel = panel();
hpanel.pack('v',{0.33 0.67});
idxRCS06 = 1; % top panel 
idxRCS02 = 2; % bottom panel 
hpanel(idxRCS06).pack({50 50});
hpanel(idxRCS02).pack('v',{0.5 0.5}); % divide into adaptive / vs zoom 
hpanel(idxRCS02,1).pack('v',{0.5 0.5}); % adaptive portion 
hpanel(idxRCS02,2).pack('h',{0.5 0.5}); % zoom portion / measures portion 
hpanel(idxRCS02,2,2).pack('h',{0.5 0.5}); % measures portion  - motor diary / PKG 
hpanel(idxRCS02,2,1).pack('v',{0.1 0.45 0.45}); % zoom portion 
% hpanel(idxRCS02,1).pack({0.24 0.24 0.05 0.24 0.24}); % the middle plot is to accomodate zoom 
% hpanel.select('all');
% hpanel.identify();
hpanel.margin = [30 30 30 30];
hpanel.fontsize = 10;
%%


% RCS06
% find the unique days in each recordings
tbl = table();
yearUse = 2020;
monthUse = 4;
dayUse = 20;
patient = 'RCS06';
fnsave = sprintf('%s_%d_%d_%d_adaptive_data.mat',patient,...
    yearUse,monthUse,dayUse);
fullfileName = fullfile(dirsave,fnsave);
if ~exist(fullfileName,'file')
    patDB = dbWithDetection(strcmp(dbWithDetection.patient,patient) , :);

    [tbl.y,tbl.m,tbl.d] = ymd(patDB.timeStart);
    unqDays = unique(tbl,'rows');
    idxPlot = year(patDB.timeStart) == yearUse & ...
        month(patDB.timeStart) == monthUse & ...
        day(patDB.timeStart) == dayUse;
    aDBSplot = patDB(idxPlot,:);
    db = plot_adbs_day(aDBSplot,figdir,patDB);
    idxSCBS = db.recordedWithScbs;
    dbuse = db(logical(idxSCBS),:);

    save(fullfileName,'dbuse');
else
    load(fullfileName);
end
idxL  = strcmp(dbuse.side,'L');
dbuse = dbuse(idxL,:);



% plot 
hsb(1) = hpanel(1,1).select(); % zoom out 
hsb(2) = hpanel(1,2).select(); % zoom out 
plot_adbs_in_pair_of_subplots(dbuse,hsb); 
hsb(1).YLim = [0 1400];
linkaxes(hsb,'x');
hsb(1).Title.String = '8 hours of aDBS using STN beta';
hsb(2).Title.String = 'Current';
set(hsb(1),'FontSize',globalFontSize);
set(hsb(2),'FontSize',globalFontSize);



% RCS02
% find the unique days in each recordings
tbl = table();
yearUse = 2020;
monthUse = 4;
dayUse = 27;
patient = 'RCS02';
fnsave = sprintf('%s_%d_%d_%d_adaptive_data.mat',patient,...
    yearUse,monthUse,dayUse);
fullfileName = fullfile(dirsave,fnsave);
if ~exist(fullfileName,'file')
    [tbl.y,tbl.m,tbl.d] = ymd(patDB.timeStart);
    unqDays = unique(tbl,'rows');
    idxPlot = year(patDB.timeStart) == yearUse & ...
        month(patDB.timeStart) == monthUse & ...
        day(patDB.timeStart) == dayUse;
    aDBSplot = patDB(idxPlot,:);
    db = plot_adbs_day(aDBSplot,figdir,patDB);
    idxSCBS = db.recordedWithScbs;
    dbuse = db(logical(idxSCBS),:);
    idxR  = strcmp(dbuse.side,'R');
    dbuse = dbuse(idxR,:);
    save(fullfileName,'dbuse');
else
    load(fullfileName);
end


% a bunch of hacky fixes: 
%
%
%



hsb2(1) = hpanel(2,1,1).select(); % zoom in 
hsb2(2) = hpanel(2,1,2).select(); % zoom in 
plot_adbs_in_pair_of_subplots(dbuse,hsb2); 
hsb2(1).Title.String = '8 hours of aDBS using cortical gamma control signal';
hsb2(2).Title.String = 'Current';
set(hsb2(1),'FontSize',globalFontSize);
set(hsb2(2),'FontSize',globalFontSize);
hsb2(1).XTickLabel = '';



hsb2(1) = hpanel(2,2,1,2).select(); % zoom in 
hsb2(2) = hpanel(2,2,1,3).select(); % zoom in 
plot_adbs_in_pair_of_subplots(dbuse,hsb2); 
hsb2(1).Title.String = 'aDBS using gamma control signal - ZOOM';
hsb2(2).Title.String = 'Current - ZOOM';
set(hsb2(1),'FontSize',globalFontSize);
set(hsb2(2),'FontSize',globalFontSize);

xlimitsZoom = datetime({'27-Apr-2020 12:00:30.822', '27-Apr-2020 12:59:41.992'});
xlimitsZoom.TimeZone  = dbuse.timeStart.TimeZone;
linkaxes(hsb2,'x');
set(hsb2(1),'XLim',xlimitsZoom);


hsb(1).XTickLabel = '';
hsb2(1).XTickLabel = '';


% fix RCS06  plot to go from 10am - 6pm 
% and axis limits to go from 9am-7pm. 
% fix detector 
haxDet = hpanel(1,1).select();
hLines = haxDet.Children;
xlimitsZoom = datetime({'20-Apr-2020 10:00:00.000', '20-Apr-2020 18:00:00.000'});
xlimitsZoom.TimeZone  = dbuse.timeStart.TimeZone;
for h = 1:length(hLines)
    hplt =  hLines(h); 
    idxXKeep = hplt.XData >= xlimitsZoom(1)  & hplt.XData <= xlimitsZoom(2);
    hplt.XData = hplt.XData(idxXKeep);
    hplt.YData = hplt.YData(idxXKeep);
end
% change scale of detector labels from 0-1 (it's a hack, but easier this
% way).
ylimit = haxDet.YLim(2);
haxDet.YTick = [0 ylimit*0.25 ylimit*0.5 ylimit*0.75 ylimit];
newYLabels = rescale(haxDet.YTick,0,1);
for y = 1:length(newYLabels)
    newLabels{y,1} = sprintf('%.2f',newYLabels(y));
end
haxDet.YTickLabel = newLabels;

% fix current 
haxCur = hpanel(1,2).select();
hLines = haxCur.Children;
xlimitsZoom.TimeZone  = dbuse.timeStart.TimeZone;
for h = 1:length(hLines)
    hplt =  hLines(h); 
    idxXKeep = hplt.XData >= xlimitsZoom(1)  & hplt.XData <= xlimitsZoom(2);
    hplt.XData = hplt.XData(idxXKeep);
    hplt.YData = hplt.YData(idxXKeep);
end
xlimitsZoom = datetime({'20-Apr-2020 09:00:00.000', '20-Apr-2020 19:00:00.000'});
xlimitsZoom.TimeZone  = dbuse.timeStart.TimeZone;
haxCur.XLim = xlimitsZoom;
haxCur.XTick = haxCur.XTick(2):hours(2):haxCur.XTick(end-1);
ylim(haxCur,[-0.1 1.5]);


% fix RCS02  plot to go from 10am - 6pm 
% and axis limits to go from 9am-7pm. 
% fix detector 
haxDet = hpanel(2,1,1).select();
hLines = haxDet.Children;
xlimitsZoom = datetime({'27-Apr-2020 10:00:00.000', '27-Apr-2020 18:00:00.000'});
xlimitsZoom.TimeZone  = dbuse.timeStart.TimeZone;
for h = 1:length(hLines)
    hplt =  hLines(h); 
    idxXKeep = hplt.XData >= xlimitsZoom(1)  & hplt.XData <= xlimitsZoom(2);
    hplt.XData = hplt.XData(idxXKeep);
    hplt.YData = hplt.YData(idxXKeep);
end
ylim(haxDet,[0 4000]);
% change scale of detector labels from 0-1 (it's a hack, but easier this
% way).
haxDet.YTick = [0 haxDet.YTick(end)*0.25 haxDet.YTick(end)*0.5 haxDet.YTick(end)*0.75 haxDet.YTick(end)];
newYLabels = rescale(haxDet.YTick,0,1);
for y = 1:length(newYLabels)
    newLabels{y,1} = sprintf('%.2f',newYLabels(y));
end
haxDet.YTickLabel = newLabels;

% fix current 
haxCur = hpanel(2,1,2).select();
hLines = haxCur.Children;
xlimitsZoom.TimeZone  = dbuse.timeStart.TimeZone;
for h = 1:length(hLines)
    hplt =  hLines(h); 
    idxXKeep = hplt.XData >= xlimitsZoom(1)  & hplt.XData <= xlimitsZoom(2);
    hplt.XData = hplt.XData(idxXKeep);
    hplt.YData = hplt.YData(idxXKeep);
end
linkaxes([haxCur haxDet],'x');
xlimitsZoom = datetime({'27-Apr-2020 09:00:00.000', '27-Apr-2020 19:00:00.000'});
xlimitsZoom.TimeZone  = dbuse.timeStart.TimeZone;
haxCur.XLim = xlimitsZoom;
haxCur.XTick = haxCur.XTick(2):hours(2):haxCur.XTick(end-1);




% fix zoom on detector zoom: 
haxDet = hpanel(2,2,1,2).select();
ylim(haxDet,[0 4000]);
haxDet.YTick = [0 haxDet.YTick(end)*0.25 haxDet.YTick(end)*0.5 haxDet.YTick(end)*0.75 haxDet.YTick(end)];
newYLabels = rescale(haxDet.YTick,0,1);
for y = 1:length(newYLabels)
    newLabels{y,1} = sprintf('%.2f',newYLabels(y));
end
haxDet.YTickLabel = newLabels;


% fix x ticks on current zoom 
haxCur = hpanel(2,2,1,3).select();
haxCur.XTick = haxCur.XTick(1):minutes(20):haxCur.XTick(end);


% zoom spacing plot 
zoomAx = hpanel(2,2,1,1).select();
set(zoomAx,  'box','off','XTickLabel',[],'XTick',[],'YTickLabel',[],'YTick',[])
set(zoomAx,'XColor','none')
set(zoomAx,'YColor','none')

hsb(1).XTickLabel = '';
hsb2(1).XTickLabel = '';

%% add some objective measures and subjective measures 

% plot motor diaries 
%  load motor diaries 
resultdirsave = '/Users/roee/Box/rcs paper paper on first five bilateral implants/revision for nature biotechnology/figures/Fig7.1_new_adaptive';
fnsmv = fullfile(resultdirsave,'motor_diary_results_rcs02_open_loop_vs_closed_loop.mat'); 
filepath = pwd; 
functionname = 'process_motor_diary_RCS02_from_redcap';
load(fnsmv,'motorDiaryTable','filepath','functionname');


y = [];
c = [];

motorDiaryTable = sortrows(motorDiaryTable,{'session'},'descend');
conditionsUse = flipud(unique(motorDiaryTable.session));
for t = 1:2
    idxuse = strcmp(motorDiaryTable.session,conditionsUse{t});
    tblUse = motorDiaryTable(idxuse,:);
    Conditions = categorical(tblUse.state,...
        unique(tblUse.state));

    % old way 
    Conditions = removecats(removecats(Conditions,'sleep'));
    idxremove  = isundefined(Conditions);
    Conditions = Conditions(~idxremove);
    summary(Conditions);
    c = countcats(Conditions);
    cats = categories(Conditions); 
    y (t,:) = c./sum(c); 
end

hpanel(2,2,2,1).select();
hbar = bar(y,'stacked');
hbar(1).FaceColor = [0.8 0 0.2];
hbar(1).FaceAlpha = 0.5;
hbar(2).FaceColor = [0 0.8 0.2];
hbar(2).FaceAlpha = 0.5;
legend(cats);
hsb = gca;
hsb.XTickLabel = conditionsUse;
hsb.XTickLabel = {'open loop','aDBS'};

hsb.XTickLabelRotation = 45; 
ylabel('% time/state');
ttluse{1,1} = 'objective measures:';
ttluse{1,2} = '3 day motor diary';
title(ttluse);
set(gca,'FontSize',10);

% plot pkg
resultdirsave = '/Users/roee/Box/rcs paper paper on first five bilateral implants/revision for nature biotechnology/figures/Fig7.1_new_adaptive';
fnsmv = fullfile(resultdirsave,'process_pkg_data_RCS02_open_loop_vs_closed_loop.mat'); 
filepath = pwd; 
functionname = 'RCS02_open_loop_vs_closed_loop.m';
load(fnsmv,'pkgData','tableLabel','functionname','filepath');

y = [];
c = [];
pkgData = pkgData(3:4); 
for t = 1:length(pkgData);
    Conditions = categorical(pkgData{t}.new_state,...
        unique(pkgData{1}.new_state));
    fprintf('%s\n',tableLabel{t});

    % old way 
    Conditions = removecats(removecats(Conditions,'state unknown'));
    Conditions = removecats(removecats(Conditions,'state rule conflict'));
    Conditions = removecats(removecats(Conditions,'sleep'));
    Conditions = removecats(removecats(Conditions,'tremor'));
    idxremove  = isundefined(Conditions);
    Conditions = Conditions(~idxremove);
    summary(Conditions);
    c = countcats(Conditions);
    cats = categories(Conditions); 
    y (t,:) = c./sum(c); 
    
end
% 

hpanel(2,2,2,2).select();
ttluse{1,1} = 'subjective measures:';
ttluse{1,2} = '4 day pkg report';

hbar = bar(y,'stacked');
hbar(1).FaceColor = [0.8 0 0.2];
hbar(1).FaceAlpha = 0.5;
hbar(2).FaceColor = [0 0.8 0.2];
hbar(2).FaceAlpha = 0.5;
ylim([0 1]);
legend(cats,'Location','northeastoutside');
hsb = gca;
hsb.XTick = 3:4;
% hsb.XTickLabel = tableLabel;
hsb.XTickLabel = {'open loop','aDBS'};
hsb.XTickLabelRotation = 35; 
title(ttluse);
ylabel('% time in category'); 
set(gca,'FontSize',10);

%% plot 
% global figure margines 
hpanel.fontsize = 8;
hpanel.marginright = 20;
hpanel.marginleft = 20;
hpanel.margintop = 12;
hpanel.marginbottom = 20;

hpanel.de.margin = 8 ;
hpanel(1).marginbottom = 13  ;
hpanel(2,1).marginbottom = 18 ;
hpanel(2,2,1).marginright = 15;
hpanel(2,2,1).margintop = 7;
hpanel(2,2,1,1).margintop = 7;
hpanel(2,2,1).marginbottom = 40; 
hsb = hpanel(2,2,2,2).select();
hsb.YTick = []; 
hsb.YLabel.String = '';

datetick(hpanel(1,2).select(),'x',15,'keepticks','keeplimits');
datetick(hpanel(2,1,2).select(),'x',15,'keepticks','keeplimits');
datetick(hpanel(2,2,1,3).select(),'x',15,'keepticks','keeplimits');

figdir = '/Users/roee/Box/rcs paper paper on first five bilateral implants/revision for nature biotechnology/figures/Fig7.1_new_adaptive';
hpanel.fontsize = 10;
hfig.Renderer='Painters';
prfig.figdir = figdir;
prfig.figtype = '-dpdf';
prfig.resolution = 600;
prfig.closeafterprint = 0;
prfig.plotwidth           = 7.2;
prfig.plotheight          = 7.2*1.2;
prfig.figname             = 'figuer_7_v2_new_adaptive_full_day_run_v7';
plot_hfig(hfig,prfig)


end


function dbPlot = plot_adbs_day(db,figdir,backupdb)
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
    uniqCurrents = unique(currentTimeSeriesTrimmed); 
    if length(uniqCurrents) == 1
        db.adaptive_running(s) = 0; 
    else
        db.adaptive_running(s) = 1; 
    end

end
dbPlot = db;

end

function plot_adbs_in_pair_of_subplots(dbuse,hsb)
lineWidth = 1;
% only plot data from 1 side
for d = 1:size(dbuse,1)
    % plot the detector
    idxplot = 1;
    timesUseDetector = dbuse.timesUseDetector{d};
    ld0 = dbuse.ld0{d};
    ld0_high = dbuse.ld0_high{d};
    ld0_low = dbuse.ld0_low{d};
    hold(hsb(idxplot),'on');
    if ~isempty(ld0)
        % only remove outliers in the threshold
        outlierIdx = isoutlier(ld0_high,'movmedian',200);
        ld0 = ld0(~outlierIdx);
        ld0_high = ld0_high(~outlierIdx);
        ld0_low = ld0_low(~outlierIdx);
        timesUseDetector = timesUseDetector(~outlierIdx);
        
        
        hplt = plot(hsb(idxplot),timesUseDetector,ld0,'LineWidth',lineWidth,'Color',[0 0 0.8 0.7]);
        hplt = plot(hsb(idxplot),timesUseDetector,ld0_high,'LineWidth',lineWidth,'Color',[0.8 0 0  0.7]);
        hplt.LineStyle = '-.';
        hplt.Color = [hplt.Color 0.7];
        hplt = plot(hsb(idxplot),timesUseDetector,ld0_low,'LineWidth',lineWidth,'Color',[0.8 0 0 0.7]);
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
        ttlus = sprintf('Control signal %s',dbuse.side{d});
        title(hsb(idxplot),ttlus);
        ylabel(hsb(idxplot),'Control signal (a.u.)'); 
        set(hsb(idxplot),'FontSize',12);
        % plot the current
        idxplot = 2;
        hold(hsb(idxplot),'on');

        timesUseCur = dbuse.timesUseCur{d};
        cur = dbuse.currentTimeSeries{d};
        % don't  remove outliers for current
        % but remove current above 10 as they are unlikely to be real
        outlierIdx = cur>10;
        cur = cur(~outlierIdx);
        timesUseCur = timesUseCur(~outlierIdx);
        
        
        
        plot(hsb(idxplot),timesUseCur,cur,'LineWidth',lineWidth,'Color',[0 0.8 0 0.7]);
        ttlus = sprintf('Current in mA');
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
end