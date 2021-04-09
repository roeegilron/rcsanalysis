
function MAIN_plot_saved_log_data()
params.useDatabase = 0; 
params.sort = 0; 
params.resaveData = 1; 

if params.useDatabase
    %% load the database
    addpath(genpath(fullfile(pwd,'toolboxes','panel-2.14')));
    % set destination folders
    dropboxFolder = findFilesBVQX('/Users','Starr Lab Dropbox',struct('dirs',1,'depth',2));
    if length(dropboxFolder) == 1
        dirname  = fullfile(dropboxFolder{1}, 'RC+S Patient Un-Synced Data');
        rootdir = fullfile(dirname,'database');
        savedir = fullfile(rootdir,'adaptive_log_data','results');
        figdir  = fullfile(rootdir,'adaptive_log_data','figures');
    else
        error('can not find dropbox folder, you may be on a pc');
    end
    
    load(fullfile(rootdir,'database_from_device_settings.mat'),'masterTableLightOut');
    masterTableOut = masterTableLightOut;
    
else
    % if you are plotting stuff from an existing patient that didn't move
    % to databse 
    params.dir = '/Users/roee/Starr Lab Dropbox/RC02LTE/SummitData/SummitContinuousBilateralStreaming';
    create_database_from_device_settings_files(params.dir);
    load(fullfile(params.dir,'database','database_from_device_settings.mat'));
    savedir = fullfile(params.dir,'database','results');
    figdir = fullfile(params.dir,'database','figures');
    mkdir(savedir);
    mkdir(figdir);
    masterTableOut = masterTableLightOut;
end

%% only get data from RCS patients and newer than december 2020
if params.sort
newerThan = datetime('01-Jan-2021 00:00:00','Format','dd-MMM-uuuu HH:mm:ss','TimeZone','America/Los_Angeles');
idxkeep = cellfun(@(x) any(strfind(x,'RCS')),masterTableOut.patient) & ...
    masterTableOut.timeStart > newerThan;
masterTable = masterTableOut(idxkeep,:);
else
    masterTable = masterTableOut;
end

%% loop on data, and look for folders with log data
if params.resaveData
    unqpatients = unique(masterTable.patient);
    unqsides    = unique(masterTable.side);
    for p = 1:length(unqpatients)
        for s = 1:length(unqsides)
            idxuse = cellfun(@(x) strcmp(x,unqpatients{p}),masterTable.patient) & ...
                cellfun(@(x) strcmp(x,unqsides{s}),masterTable.side);
            patTable = masterTable(idxuse,:);
            adaptiveLogTableOut        = table();
            adaptiveDetectionEventsOut = table();
            rechargeSessionsOut        = table();
            groupChangesOut            = table();
            cntA = 1;
            for ss = 1:size(patTable,1)
                [pn,~] = fileparts(patTable.deviceSettingsFn{ss});
                logDirFound = findFilesBVQX(pn,'LogData*',struct('dirs',1));
                
                if ~isempty(logDirFound)
                    % find a device settings file from the this folder to
                    % compute a time to subtract from log files that are in RLP
                    % time
                    timeDiff = fixLogTiming(pn);

                    start = tic;
                    logDir = logDirFound{1};
                    logtime = patTable.timeStart(ss);
                    logtime.Format = 'dd-MMM-uuuu--HH-mm';
                    
                    fnuse = sprintf('%s%s_%s.mat',patTable.patient{ss},patTable.side{ss}, logtime);
                    fnsave = fullfile(logDir,fnuse);
                    
                    if exist(fnsave,'file')
                        load(fnsave);
                        
                        
                        fprintf('found file %s\n',fnuse);
                        if exist('adaptiveLogTable','var')
                            if ~isempty(adaptiveLogTable)
                                % fix the time 
                                adaptiveLogTable.time  = adaptiveLogTable.time + timeDiff;
                                if isempty(adaptiveLogTableOut)
                                    adaptiveLogTableOut = adaptiveLogTable;
                                else
                                    adaptiveLogTableOut = [adaptiveLogTableOut; adaptiveLogTable];
                                end
                            end
                        end
                        
                        fprintf('found file %s\n',fnuse);
                        if exist('adaptiveDetectionEvents','var')
                            if ~isempty(adaptiveLogTable)
                                % fix the time
                                adaptiveLogTable.time  = adaptiveLogTable.time + timeDiff;
                                if isempty(adaptiveLogTableOut)
                                    adaptiveDetectionEventsOut = adaptiveDetectionEvents;
                                else
                                    adaptiveDetectionEventsOut = [adaptiveDetectionEventsOut; adaptiveDetectionEvents];
                                end
                            end
                        end

                        
                        if exist('rechargeSessions','var')
                            if ~isempty(rechargeSessions)
                                rechargeSessions.time  = rechargeSessions.time + timeDiff;
                                if isempty(rechargeSessionsOut)
                                    rechargeSessionsOut = rechargeSessions;
                                else
                                    rechargeSessionsOut = [rechargeSessionsOut; rechargeSessions];
                                end
                            end
                        end
                        
                        
                        if exist('groupChanges','var')
                            if ~isempty(groupChanges)
                                if isempty(groupChangesOut)
                                    groupChanges.time  = groupChanges.time + timeDiff;
                                    groupChangesOut = groupChanges;
                                else
                                    groupChangesOut = [groupChangesOut; groupChanges];
                                end
                            end
                        end
                                
                        clear adaptiveLogTable rechargeSession groupChanges
                    end
                end
            end
            % save the raw data and clear all the dupblicate rows
            if ~isempty(adaptiveLogTableOut)
                % save adaptive table
                [vals,idxs] = unique(adaptiveLogTableOut.time);
                adaptiveLogTableUnique = adaptiveLogTableOut(idxs,:);
                adaptiveLogTableUse =  sortrows(adaptiveLogTableUnique,{'time'});
                adaptiveLogTableAll = adaptiveLogTableUse;
                
                % save gropu data
                [vals,idxs] = unique(groupChangesOut.time);
                groupChangesOutUnique = groupChangesOut(idxs,:);
                groupChangesOutUniqueUse =  sortrows(groupChangesOutUnique,{'time'});
                groupChangesOutUniqueAll = groupChangesOutUniqueUse;
                
                
                fnsave = sprintf('%s%s_log_data.mat',patTable.patient{1},patTable.side{1});
                diruse = fullfile(savedir,patTable.patient{1});
                if ~exist(diruse,'dir')
                    mkdir(diruse);
                end
                fnuse  = fullfile(savedir,patTable.patient{1},fnsave);
                
                
                save(fnuse,'adaptiveLogTableAll','groupChangesOutUniqueAll','patTable','adaptiveDetectionEventsOut');
                clear adaptiveLogTableAll groupChangesOutUniqueAll patTable adaptiveDetectionEventsOut
            end
        end
    end
end


%% loop on saved log data and make some plots

%% plot log adaptive data both sides together 
adaptiveLogFilenames = findFilesBVQX(savedir,'*.mat',struct('depth',2));
adaptiveLogBothSides = table(); 
adaptiveDetectionEventsBothSides = table(); 
for ff = 1:length(adaptiveLogFilenames)
    load(adaptiveLogFilenames{ff});
    % adaptiv log 
    adaptiveLogTableAll.side = repmat(patTable.side{1},size(adaptiveLogTableAll,1),1);
    adaptiveLogTableAll.patient = repmat(patTable.patient{1},size(adaptiveLogTableAll,1),1);
    adaptiveLogTableAll = movevars(adaptiveLogTableAll,{'patient','side'},'Before','time');
    adaptiveLogBothSides = [adaptiveLogBothSides; adaptiveLogTableAll];
    % adaptive detection events 
    adaptiveDetectionEventsOut.side = repmat(patTable.side{1},size(adaptiveDetectionEventsOut,1),1);
    adaptiveDetectionEventsOut.patient = repmat(patTable.patient{1},size(adaptiveDetectionEventsOut,1),1);
    adaptiveDetectionEventsOut = movevars(adaptiveDetectionEventsOut,{'patient','side'},'Before','time');
    adaptiveDetectionEventsBothSides = [adaptiveDetectionEventsBothSides; adaptiveDetectionEventsOut];
end

allDaysLog = dateshift(adaptiveLogBothSides.time,'start','day');
allDaysDet = dateshift(adaptiveDetectionEventsBothSides.time,'start','day');
unqDays = unique(allDaysLog);
% only choose unique days within the last 5 days 
idxdayschoose = unqDays >= (datetime - days(5)) & unqDays <= datetime;
unqDays = unqDays(idxdayschoose); 
for d = 1:length(unqDays)
    idxuseLog = allDaysLog == unqDays(d);
    idxuseDet = allDaysDet == unqDays(d);
    if sum(idxuse) > 0 % data exists
        adaptiveTableDayLog = adaptiveLogBothSides(idxuseLog,:);
        adaptiveTableDayDet = adaptiveDetectionEventsBothSides(idxuseDet,:);
        [hfig, hpanel] = plot_adaptive_day_both_sides(adaptiveTableDayLog,adaptiveTableDayDet);
        % plot adaptive for each day
        datesave = sprintf('%d_%0.2d_%0.2d',year(unqDays(d)),month(unqDays(d)),day(unqDays(d)));
        fnsave = sprintf('%s_%s%s_adaptive_day_both_sides',datesave,patTable.patient{1});
        figdiruse = fullfile(figdir,patTable.patient{1});
        if ~exist(figdiruse)
            mkdir(figdiruse);
        end
        if ~exist(fullfile(figdiruse,fnsave),'file') % check if this has been plotted already
            % plot
            hpanel.margintop = 20;
            hpanel.fontsize = 8;
            hpanel.de.margin = 25;

            prfig.plotwidth           = 10*1.6;
            prfig.plotheight          = 6*1.6;
            prfig.figdir              = figdiruse;
            prfig.figname             = fnsave;
            prfig.figtype             = '-djpeg';
            plot_hfig(hfig,prfig)
            close(hfig);
        end

    end
end

return 

%% plot daily states and group changes - per side ( seperately 
for ff = 1:length(adaptiveLogFilenames)
    load(adaptiveLogFilenames{ff});
    [yy,mm,dd] = ymd(adaptiveLogTableAll.time);
    allDays = dateshift(adaptiveLogTableAll.time,'start','day');
    unqDays = unique(allDays);
    dateCnt = 1;
    hsb = subplot(1,1,1);
    for d = 1:length(unqDays)
        idxuse = allDays == unqDays(d);
        if sum(idxuse) > 0 % data exists
            adaptiveTableDay = adaptiveLogTableAll(idxuse,:);
            aPlot = adaptiveTableDay;
            fprintf('time %d-%d-%d\n',year(aPlot.time(1)),month(aPlot.time(1)),day(aPlot.time(1)));

            % plot adaptive for each day
            datesave = sprintf('%d_%0.2d_%0.2d',year(aPlot.time(1)),month(aPlot.time(1)),day(aPlot.time(1)));
            fnsave = sprintf('%s_%s%s_adaptive_day',datesave,patTable.patient{1},patTable.side{1});
            figdiruse = fullfile(figdir,patTable.patient{1});
            if ~exist(figdiruse)
                mkdir(figdiruse);
            end
            if ~exist(fullfile(figdiruse,fnsave),'file') % check if this has been plotted already
                hfig = plot_adaptive_day(aPlot,groupChangesOutUniqueAll,patTable,masterTableOut);
                % plot
                prfig.plotwidth           = 10;
                prfig.plotheight          = 6;
                prfig.figdir              = figdiruse;
                prfig.figname             = fnsave;
                prfig.figtype             = '-djpeg';
                plot_hfig(hfig,prfig)
                close(hfig);
            end
        end
    end
end





%% plot all data in one day

adaptiveLogFilenames = findFilesBVQX(savedir,'*.mat');
for ff = 1:length(adaptiveLogFilenames)
    load(adaptiveLogFilenames{ff});
    [yy,mm,dd] = ymd(adaptiveLogTableAll.time);
    unqyears = unique(yy);
    unqmonts = unique(mm);
    unqdayss = unique(dd);
    dateCnt = 1;
    hfig = figure;
    hfig.Color = 'w';
    hsb = subplot(1,1,1);
    for y = 1:length(unqyears)
        for m = 1:length(unqmonts)
            for d = 1:length(unqdayss)
                idxuse = (unqyears(y) == yy) & ...
                    (unqmonts(m) == mm) & ...
                    (unqdayss(d) == dd) ;
                if sum(idxuse) > 0 % data exists
                    fprintf('time %d-%d-%d\n',unqyears(y),unqmonts(m) ,unqdayss(d));
                    adaptiveTableDay = adaptiveLogTableAll(idxuse,:);
                    
                    % for this day, get summary metrics of algo
                    stateTable = table();
                    aPlot = adaptiveTableDay;
                    idx = 1;
                    while idx < size(aPlot,1)-1
                        stateTable.current(idx) =  aPlot.prog0(idx);
                        stateTable.state(idx)  = aPlot.newstate(idx);
                        stateTable.numMin(idx)  = minutes(aPlot.time(idx+1) - aPlot.time(idx));
                        idx = idx + 1;
                    end
                    
                    sumTable = table();
                    totalMin = sum(stateTable.numMin);
                    % get unique states and plot % time per state
                    unqStates = unique(stateTable.state);
                    for s = 1:length(unqStates)
                        idxuse = unqStates(s) == stateTable.state;
                        sumTable.unqStates(s) = unqStates(s);
                        sumTable.percInState(s) = sum(stateTable.numMin(idxuse))/totalMin;
                        sumTable.minInState(s) = sumTable.percInState(s).*totalMin;
                        sumTable.current(s) = mean(stateTable.current(idxuse));
                    end
                    % plot in date cnt
                    hold on;
                    hbar = bar(dateCnt, sumTable.percInState','stacked');
                    dateCnt = dateCnt + 1;
                    timeUse = adaptiveTableDay.time(1);
                    timeUse.Format = 'dd-MMM-uuuu';
                    dateLabels{dateCnt} = sprintf('%s',timeUse);
                end
            end
        end
    end
    hsb.XTick = 1:dateCnt-1;
    hsb.XTickLabel = dateLabels;
    hsb.XTickLabelRotation = 45;
end



end

function tCompDiff = fixLogTiming(pn)
DeviceSettings = jsondecode(fixMalformedJson(fileread([pn filesep 'DeviceSettings.json']),'DeviceSettings'));

% figure out a way to use UTC time in future 
% [timeDomainSettings, powerSettings, fftSettings, metaData] = createDeviceSettingsTable(pn);

% Fix format - Sometimes device settings is a struct or cell array
if isstruct(DeviceSettings)
    DeviceSettings = {DeviceSettings};
end

%%
% Get enabled programs from first record; isEnabled = 0 means program is
% enabled; isEnabled = 131 means program is disabled. These are static for
% the full recording. Get contact information for these programs

currentSettings = DeviceSettings{1};

% computer time 
HostUnixTime = currentSettings.RecordInfo.HostUnixTime;
tComp = datetime(HostUnixTime/1e3,'ConvertFrom','posixTime',...
'TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');

% device time 
DeviceTime = currentSettings.GeneralData.deviceTime.seconds;
tDevice = datetime(datevec(DeviceTime./86400 + ...
    datenum(2000,3,1,0,0,0)),...
    'TimeZone','America/Los_Angeles'); % medtronic time - LSB is seconds

% different 
tCompDiff  = tComp -  tDevice;


end

function hfig = plot_adaptive_day(aPlot,groupChanges,patTable,masterTableOut)
%% plot 
groupChanges = sortrows( groupChanges,{'time'});
hfig = [];
if ~isempty(aPlot)
    aPlot = sortrows(aPlot,'time');
    dayPlot = table();
    dCnt = 1;
    for i = 1:size(aPlot,1)
        if i == 1
            dayPlot.time(dCnt) = aPlot.time(i);
            dayPlot.current(dCnt) = aPlot.prog0(i);
            dayPlot.state(dCnt)   = aPlot.newstate(i);
            dCnt = dCnt + 1;
        else
            if aPlot.prog0(i) == 500%aPlot.prog0(i-1)
                dayPlot.time(dCnt) = aPlot.time(i);
                dayPlot.current(dCnt) = aPlot.prog0(i);
                dayPlot.state(dCnt)   = aPlot.newstate(i);
                dCnt = dCnt + 1;
            else
                dayPlot.time(dCnt) = aPlot.time(i);
                dayPlot.current(dCnt) = aPlot.prog0(i-1);
                dayPlot.state(dCnt)   = aPlot.newstate(i-1);
                dCnt = dCnt + 1;
                dayPlot.time(dCnt) = aPlot.time(i);
                dayPlot.current(dCnt) = aPlot.prog0(i);
                dayPlot.state(dCnt)   = aPlot.newstate(i);
                dCnt = dCnt + 1;
            end
        end
    end
    % make a timeline of group changes for the day
    % based on the last time a setting was changed in the log
                groupChangeBeforeIdx = groupChanges.time <= dayPlot.time(1);
                groupChangeBefor = groupChanges(groupChangeBeforeIdx,:);
    %             [yAdaptive,mAdaptive,dAdaptive] = ymd(dayPlot.time(1));
    %             for gc = 1:size(groupChangeBefor,1)
    %                 [yGc,mGc,dGc] = ymd(groupChangeBefor.time(gc));
    %                 if yAdaptive == yGc & mAdaptive == mGc & dGc == dAdaptive
    %                 else
    %                     idxBreak = gc;
    %                     break;
    %                 end
    %             end
    %             groupChangesUse = groupChangeBefor(1:idxBreak,:);
    %             groupChangeCompute = sortrows(groupChangesUse,{'time'});
    %             dateVecFirstEntry = datevec(groupChangeCompute.time(1));
    %             dateVecFirstEntry(1) = yAdaptive;
    %             dateVecFirstEntry(2) = mAdaptive;
    %             dateVecFirstEntry(3) = dAdaptive;
    %             dateVecFirstEntry(4) = 0;
    %             dateVecFirstEntry(5) = 0;
    %             dateVecFirstEntry(6) = 1;
    %             dateFirstEntry = datetime(dateVecFirstEntry);
    %             dateFirstEntry.TimeZone = groupChangeCompute.time(1).TimeZone;
    %             groupChangeCompute.time(1) = dateFirstEntry;
    %             cntGroup = 1;
    %             groupUseOut = [];  timeUse = [];
    %             for gc = 1:size(groupChangeCompute,1)
    %                 switch groupChangeCompute(gc)
    %                     case 'A'
    %                         groupUse = 1;
    %                     case 'B'
    %                         groupUse = 2;
    %                     case 'C'
    %                         groupUse = 3;
    %                     case 'D'
    %                         groupUse = 4;
    %                 end
    %                 if gc > 1
    %                     groupUseOut(cntGroup) = groupUseOut(end);
    %                     timeUse(cntGroup) = groupChangeCompute(gc);
    %                     cntGroup  = cntGroup  + 1;
    %                     groupUseOut(cntGroup) = groupUse;
    %                     timeUse(cntGroup) = groupChangeCompute(gc);
    %                     cntGroup  = cntGroup  + 1;
    %                 else
    %                     groupUseOut(cntGroup) = groupUse;
    %                     timeUse(cntGroup) = groupChangeCompute(gc);
    %                     cntGroup  = cntGroup  + 1;i
    %                 end
    %
    %             end
    
    %plot
    % compute weighted average for the day
    
%     %% XXXX FIX 
%     numSecsPerCurrent = seconds(diff(aPlot.time));
%     currentsUse = aPlot.prog0(2:end);
%     currentsWeighted = {};
%     for a = 1:length(currentsUse)
%         currentsWeighted{a} = repmat(currentsUse(a),1,numSecsPerCurrent(a));
%     end
%     weightedMean  = mean([currentsWeighted{:}]);
%     nonWeightedMean = mean(aPlot.current);
    %% XXXX 
    weightedMean = 0; 
    nonWeightedMean = 0;
     
    fprintf('w mean = %.2f non weighted mean = %.2f\n',weightedMean,nonWeightedMean);
    
    %% plot
    hfig = figure;
    hfig.Color = 'w';
    hpanel = panel();
    hpanel.pack('v',{0.4 0.3 0.2}); 
    
    % plot current 
    hsb = hpanel(1).select(); % current 
    plot_day_current_from_log(dayPlot,patTable,weightedMean,hsb)
    hsb = hpanel(2).select(); % state 
    plot_state_current_from_log(dayPlot,patTable,weightedMean,hsb)
    hsb = hpanel(3).select(); % motor diary - if exists try to find and plot 
    dataExists = plot_motor_diary_forday_log(dayPlot,patTable,weightedMean,hsb);
    % try to find motor diary data if it exisxts 
    
    % format this a bit better 
    hsb = gobjects();
    for i = 1:3 
        hsb(i,1) = hpanel(i).select(); 
    end
    
    
    % formaking 
    if dataExists
        endIdx = 3;
        linkaxes(hsb,'x')
    else
        endIdx = 2;
        linkaxes(hsb(1:endIdx),'x')
    end
    
    for i = 1:endIdx-1 
        hsb(i,1).XTick = [];
        hsb(i,1).XTickLabels = '';
        hsb(i,1).XLabel.String = '';
    end
    hpanel.margintop = 20;
    hpanel.de.margin = 12; 
    
end
end

function plot_day_current_from_log(dayPlot,patTable,weightedMean,hsb)
axes(hsb);
hPlt = plot(hsb,datenum(dayPlot.time),dayPlot.current,'LineWidth',2,'Color',[0 0 0.8 0.5]);
xlabel(hsb,'time');
ylabel(hsb,'current');
hsb = hsb;
ylims = hsb.YLim;
hsb.YLim(1) = hsb.YLim(1)*0.9;
hsb.YLim(2) = hsb.YLim(2)*1.1;
ttluse{1,1} = sprintf('%s %s',dayPlot.patient{1},dayPlot.side{1});
[~,dayRec] = weekday(dayPlot.time(1));
ttluse{1,2} = sprintf('(%s) %d/%d/%d (%.2fmA = avg current)',dayRec,month(dayPlot.time(1)),day(dayPlot.time(1)),year(dayPlot.time(1)),weightedMean);

title(ttluse);

startVec = datevec(dayPlot.time(1));
startVec(4:6) = 0;
xlim(1) = datenum(datetime(dayPlot.time(1)));

endVec = datevec(dayPlot.time(end)-minutes(1));
endVec(4) = 23;
endVec(5) = 59;
endVec(6) = 0;
xlim(2) = datenum(datetime(endVec));


ticksuse = datenum([datetime(startVec): hours(2) : datetime(endVec),  datetime(endVec)]);
hsb.XTick = ticksuse;
datetick('x',15,'keeplimits','keepticks');

end

function plot_state_current_from_log(dayPlot,patTable,weightedMean,hsb)
axes(hsb);
hPlt = plot(hsb,datenum(dayPlot.time),dayPlot.state,'LineWidth',2,'Color',[0.5 0.5 0 0.5]);
xlabel(hsb,'time');
ylabel(hsb,'state');
hsb = hsb;
ylims = hsb.YLim;
hsb.YLim(1) = hsb.YLim(1)*0.9;
hsb.YLim(2) = hsb.YLim(2)*1.1;
ttluse{1,1} = sprintf('%s %s',dayPlot.patient{1},dayPlot.side{1});
ttluse{1,2} = sprintf('%d/%d/%d (%.2fmA = avg current)',month(dayPlot.time(1)),day(dayPlot.time(1)),year(dayPlot.time(1)),weightedMean);

title(ttluse);

% adjust ytick 
ylims = hsb.YLim;
hsb.YTick = unique(dayPlot.state);
hsb.YLim = [min(unique(dayPlot.state))-0.5 max(unique(dayPlot.state))+0.5];


startVec = datevec(dayPlot.time(1));
startVec(4:6) = 0;
xlim(1) = datenum(datetime(dayPlot.time(1)));

endVec = datevec(dayPlot.time(end)-minutes(1));
endVec(4) = 23;
endVec(5) = 59;
endVec(6) = 0;
xlim(2) = datenum(datetime(endVec));


ticksuse = datenum([datetime(startVec): hours(2) : datetime(endVec),  datetime(endVec)]);
hsb.XTick = ticksuse;
datetick('x',15,'keeplimits','keepticks');

end

function dataExists = plot_motor_diary_forday_log(dayPlot,patTable,weightedMean,hsb)
params.resdir = '/Users/roee/Box/RC-S_Studies_Regulatory_and_Data/motor_diary_data/results';
% find patient dir 
dirFound = findFilesBVQX(params.resdir,patTable.patient{1},struct('dirs',1,'depth',1));
if ~isempty(dirFound)
    ff = findFilesBVQX(dirFound{1},'*.mat',struct('depth',1));
    if ~isempty(ff)
        load(ff{1});
        % load file
        dataexists = sum(motorDiary{:,end-7:end},2) > 0 ;
        motorDiaryClean = motorDiary(dataexists,:);
        [yy,mm,dd] = ymd(motorDiaryClean.timeStart);

        [yTarg,mTarg,dTarg] = ymd(dayPlot.time(1));
        idxplot = yTarg == yy & ...
            mTarg == mm & ...
            dTarg== dd;
        diaryPlot = motorDiaryClean(idxplot,:);
        if isempty(diaryPlot)
            dataExists = 0;
        else
            dataExists = 1;
        end
        %% plot motor diary 
        cla(hsb)
        hold(hsb,'on');
        fnmsloop = diaryPlot.Properties.VariableNames(9:end);
        for dd = 1:size(diaryPlot,1)
            for ff = 1:length(fnmsloop)
                % set colors:
                switch fnmsloop{ff}
                    case 'asleep'
                        colorUse = [0 0 0.8];
                    case 'off'
                        colorUse = [0.8 0 0];
                    case 'on_without_dysk'
                        colorUse = [0 0.8 0];
                    case 'on_with_ntrb_dysk'
                        colorUse = [0 0.8 0.8];
                    case 'on_with_trbl_dysk'
                        colorUse = [0.8 0 0.8];
                    case 'no_tremor'
                        colorUse = [0.8 0.8 0.8];
                    case 'non trbl tremor'
                        colorUse = [0.5 0.8 0.8];
                    case 'trbl_tremor'
                end
                if logical(diaryPlot.(fnmsloop{ff})(dd))
                    
                    
                    starttime = diaryPlot.timeStart(dd);
                    endtime = diaryPlot.timeStart(dd) + minutes(30);
                    
                    % get limits in 24 hours clock:
                    startVec = datevec(starttime);
                    startVec(4:6) = 0;
                    xlim(1) = datenum(datetime(startVec));
                    
                    endVec = datevec(endtime-minutes(1));
                    endVec(4) = 23;
                    endVec(5) = 59;
                    endVec(6) = 0;
                    xlim(2) = datenum(datetime(endVec));
                    
                    
                    ticksuse = datenum([datetime(startVec): hours(2) : datetime(endVec),  datetime(endVec)]);
                    
                    
                    x = datenum([starttime endtime endtime starttime]);
                    y = [0 0 1 1];
                    hPatch = patch('XData', x, 'YData',y,'Parent',hsb);
                    
                    starttime.Format = 'dd-MMM-uuuu';
                    [~,dayRec] = weekday(starttime);
                    
                    dataRecPrint{1,1} = sprintf('%s (%s)',starttime,dayRec);
                    dataRecPrint{1,2} = sprintf('%s',diaryPlot.md_description{1});
                    dataRecPrint = {};
                    dataRecPrint{1,1} = sprintf('%s (%s) %s',starttime,dayRec,diaryPlot.md_description{1});
                    %             hyLabel = ylabel( dataRecPrint );
                    %             hyLabel.Rotation = 0;
                    if dd == 1 & ff == 1
                        text(datenum( starttime) ,0.2 ,dataRecPrint,'Parent',hsb,'FontSize',8);
                    end
                    
                    
                    set(hsb,'XLim',xlim);
                    hsb.XTick = ticksuse;
                    hPatch.FaceColor = colorUse;
                    hPatch.FaceAlpha = 0.3;
                    datetick('x',15,'keeplimits','keepticks');
                    hsb.YTick = [];
                    hsb.YTickLabel = '';
                end
            end
        end
        %%
    end
end

end


function [hfig, hpanel] = plot_adaptive_day_both_sides(aPlotBoth,adaptiveTableDayDet)
unqsides = unique(aPlotBoth.side);



for s = 1:length(unqsides)
    idxuse = unqsides(s) == aPlotBoth.side;
    aPlot = aPlotBoth(idxuse,:);
    if ~isempty(aPlot)
        aPlot = sortrows(aPlot,'time');
        dayPlot = table();
        dCnt = 1;
        for i = 1:size(aPlot,1)
            if i == 1
                dayPlot.patient{dCnt} = aPlot.patient(i,:);
                dayPlot.side{dCnt}    =  aPlot.side(i,:);
                
                dayPlot.time(dCnt) = aPlot.time(i);
                dayPlot.current(dCnt) = aPlot.prog0(i);
                dayPlot.state(dCnt)   = aPlot.newstate(i);
                dCnt = dCnt + 1;
            else
                if aPlot.prog0(i) == 500%aPlot.prog0(i-1)
                    dayPlot.patient{dCnt} = aPlot.patient(i,:);
                    dayPlot.side{dCnt}    =  aPlot.side(i,:);
                    
                    dayPlot.time(dCnt) = aPlot.time(i);
                    dayPlot.current(dCnt) = aPlot.prog0(i);
                    dayPlot.state(dCnt)   = aPlot.newstate(i);
                    dCnt = dCnt + 1;
                else
                    dayPlot.patient{dCnt} = aPlot.patient(i,:);
                    dayPlot.side{dCnt}    =  aPlot.side(i,:);
                    dayPlot.time(dCnt) = aPlot.time(i);
                    dayPlot.current(dCnt) = aPlot.prog0(i-1);
                    dayPlot.state(dCnt)   = aPlot.newstate(i-1);
                    dCnt = dCnt + 1;
                    
                    dayPlot.patient{dCnt} = aPlot.patient(i,:);
                    dayPlot.side{dCnt}    =  aPlot.side(i,:);
                    dayPlot.time(dCnt) = aPlot.time(i);
                    dayPlot.current(dCnt) = aPlot.prog0(i);
                    dayPlot.state(dCnt)   = aPlot.newstate(i);
                    dCnt = dCnt + 1;
                end
            end
        end
        outData(s).dayPlot = dayPlot;
        outData(s).side = unqsides(s);
        outData(s).patient = dayPlot.patient{1};
    end
end
%% plot
addpath(genpath(fullfile(pwd,'toolboxes','panel-2.14')));
hfig = figure;
hfig.Color = 'w';
hpanel = panel();
hpanel.pack('v',{0.2 0.2 0.2 0.2});
% format this a bit better
hsb = gobjects();
for i = 1:4
    hsb(i,1) = hpanel(i).select();
end


cntplt = 1;
for s = 1:length(outData)    
    % plot current
    hsbUse = hsb(cntplt,1); cntplt = cntplt + 1; 
    plot_day_current_from_log(outData(s).dayPlot,outData(s).dayPlot,0.0,hsbUse)
    % plot state 
    hsbUse = hsb(cntplt,1); cntplt = cntplt + 1; 
    plot_state_current_from_log(outData(s).dayPlot,outData(s).dayPlot,0.0,hsbUse)
end

for i = 1:4
    hax = hsb(i,1);
    timeStart = dateshift(datetime(datevec(hax.XLim(1))) ,'start','hour');
    timeEnd   = dateshift(datetime(datevec(hax.XLim(2))) ,'end','hour');
    xticks = datenum(timeStart : minutes(30) : timeEnd);
    hax.XTick = xticks;
    datetick(hax,'x',15,'keeplimits','keepticks');
    grid(hax,'on');
    hax.GridAlpha = 0.4;
    hax.Layer = 'top';
    hax.XTickLabelRotation = 45;

end

linkaxes(hsb,'x');
hpanel.margintop = 20;
hpanel.de.margin = 25;


end