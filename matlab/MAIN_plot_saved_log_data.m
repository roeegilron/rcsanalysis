function MAIN_plot_saved_log_data()

%% load the database
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

%% only get data from RCS patients and newer than december 2020
newerThan = datetime('01-Dec-2020 00:00:00','Format','dd-MMM-uuuu HH:mm:ss','TimeZone','America/Los_Angeles');
idxkeep = cellfun(@(x) any(strfind(x,'RCS')),masterTableOut.patient) & ...
    masterTableOut.timeStart > newerThan;
masterTable = masterTableOut(idxkeep,:);

%% loop on data, and look for folders with log data
resaveData = 0;
if resaveData
    unqpatients = unique(masterTable.patient);
    unqsides    = unique(masterTable.side);
    for p = 1:length(unqpatients)
        for s = 1:length(unqsides)
            idxuse = cellfun(@(x) strcmp(x,unqpatients{p}),masterTable.patient) & ...
                cellfun(@(x) strcmp(x,unqsides{s}),masterTable.side);
            patTable = masterTable(idxuse,:);
            adaptiveLogTableOut = table();
            rechargeSessionsOut = table();
            groupChangesOut     = table();
            cntA = 1;
            for ss = 1:size(patTable,1)
                [pn,~] = fileparts(patTable.deviceSettingsFn{ss});
                logDirFound = findFilesBVQX(pn,'LogData*',struct('dirs',1));
                if ~isempty(logDirFound)
                    start = tic;
                    logDir = logDirFound{1};
                    logtime = patTable.timeStart(ss);
                    logtime.Format = 'dd-MMM-uuuu--HH-mm';
                    
                    fnuse = sprintf('%s%s_%s.mat',patTable.patient{s},patTable.side{s}, logtime);
                    fnsave = fullfile(logDir,fnuse);
                    
                    if exist(fnsave,'file')
                        load(fnsave);
                        fprintf('found file %s\n',fnuse);
                        if exist('adaptiveLogTable','var')
                            if ~isempty(adaptiveLogTable)
                                if isempty(adaptiveLogTableOut)
                                    adaptiveLogTableOut = adaptiveLogTable;
                                else
                                    adaptiveLogTableOut = [adaptiveLogTableOut; adaptiveLogTable];
                                end
                            end
                        end
                        
                        if exist('rechargeSessions','var')
                            if ~isempty(rechargeSessions)
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
                
                
                save(fnuse,'adaptiveLogTableAll','groupChangesOutUniqueAll','patTable');
            end
        end
    end
end


%% loop on saved log data and make some plots

%% plot daily states and group changes
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
                    aPlot = adaptiveTableDay;
                    % plot adaptive for each day
                    datesave = sprintf('%d_%d_%d',year(aPlot.time(1)),month(aPlot.time(1)),day(aPlot.time(1)));
                    fnsave = sprintf('%s_%s%s_adaptive_day',datesave,patTable.patient{1},patTable.side{1});
                    figdiruse = fullfile(figdir,patTable.patient{1});
                    if ~exist(figdiruse)
                        mkdir(figdiruse);
                    end
                    if ~exist(fullfile(figdiruse,fnsave),'file') % check if this has been plotted already 
                        hfig = plot_adaptive_day(aPlot,groupChangesOutUniqueAll,patTable,masterTableOut);
                        % plot
                        prfig.plotwidth           = 8;
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
            if aPlot.prog0(i) == aPlot.prog0(i-1)
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
    numSecsPerCurrent = seconds(diff(dayPlot.time));
    currentsUse = dayPlot.current(2:end);
    currentsWeighted = {};
    for a = 1:length(currentsUse)
        currentsWeighted{a} = repmat(currentsUse(a),1,numSecsPerCurrent(a));
    end
    weightedMean  = mean([currentsWeighted{:}]);
    nonWeightedMean = mean(dayPlot.current);
    fprintf('w mean = %.2f non weighted mean = %.2f\n',weightedMean,nonWeightedMean);
    
    % plot
    hfig = figure;
    hfig.Color = 'w';
    hPlt = plot(dayPlot.time,dayPlot.current,'LineWidth',2,'Color',[0 0 0.8 0.5]);
    xlabel('time');
    ylabel('current'); 
    hsb = gca;
    ylims = hsb.YLim;
    hsb.YLim(1) = hsb.YLim(1)*0.9;
    hsb.YLim(2) = hsb.YLim(2)*1.1;
    ttluse{1,1} = sprintf('%s %s',patTable.patient{1},patTable.side{1});
    ttluse{1,2} = sprintf('%d/%d/%d (%.2fmA = avg current)',month(dayPlot.time(1)),day(dayPlot.time(1)),year(dayPlot.time(1)),weightedMean);
    
    title(ttluse);
    
    
end
end