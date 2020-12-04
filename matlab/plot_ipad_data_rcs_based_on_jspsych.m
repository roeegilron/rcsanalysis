function plot_ipad_data_rcs_based_on_jspsych()
% this is basing RC+S ipad allignment based on the beeps from the ipad task
% and not on deslys allignemtn
clc;
close all;
createFileDatabase = 1;
outlierFunc = @isoutlier;
boxdir = '/Users/roee/Box/movement_task_data_at_home/data'; % dektop
boxdir = '/Users/roee/Box/movement_task_data_at_home/data'; % laptop
resdir = '/Users/roee/Box/movement_task_data_at_home/results'; % laptop
figdir = '/Users/roee/Box/movement_task_data_at_home/figures'; % laptop

boxdir = '/Users/roee/Box/RC-S_Studies_Regulatory_and_Data/Patient In-Clinic Data/RCS12/10 Day';
resdir = '/Users/roee/Box/RC-S_Studies_Regulatory_and_Data/Patient In-Clinic Data/RCS12/10 Day/results';
figdir = '/Users/roee/Box/RC-S_Studies_Regulatory_and_Data/Patient In-Clinic Data/RCS12/10 Day/figures';

boxdir = '/Users/roee/Box/RC-S_Studies_Regulatory_and_Data/Patient In-Clinic Data/RCS11/10 Day';
resdir = '/Users/roee/Box/RC-S_Studies_Regulatory_and_Data/Patient In-Clinic Data/RCS11/10 Day/results';
figdir = '/Users/roee/Box/RC-S_Studies_Regulatory_and_Data/Patient In-Clinic Data/RCS11/10 Day/figures';


patdirs = findFilesBVQX(boxdir,'RCS*',struct('dirs',1,'depth',1));

%% create database
if createFileDatabase == 1
    %% data dir
    %% loop on each patient, find sides and possible tasks that work for each directory
    % task data
    % assume all patients use R hand for this case
    taskDataLocs = table();
    cntTasks = 1;
    for p = 1:length(patdirs)
        % find tasks
        % find task dir
        taskDir = findFilesBVQX(patdirs{p},'task*',struct('dirs',1,'depth',1));
        [pn,patient] = fileparts(patdirs{p});
        taskFilesOut = {};
        for t = 1:length(taskDir)
            process_task_logs(taskDir{t})
            % find relevant task directories
            taskFiles = findFilesBVQX(taskDir{t},'task*.mat',struct('depth',1));
            taskFilesOut = [taskFilesOut ; taskFiles];
        end
        for tt = 1:size(taskFilesOut)
            load(taskFilesOut{tt});
            taskDataLocs.patient{cntTasks} = patient;
            taskDataLocs.taskTable{cntTasks} = taskData;
            taskDataLocs.taskStart(cntTasks) = taskData.time(1);
            taskDataLocs.taskEnd(cntTasks) = taskData.time(end);
            taskDataLocs.taskDuration(cntTasks) = taskData.time(end) - taskData.time(1);
            cntTasks = cntTasks + 1;
        end
    end
    % only keep tasks above a minimum size 
    idxKeep = cellfun(@(x) size(x,1),taskDataLocs.taskTable) > 100; % min task size 
    taskDataLocs = taskDataLocs(idxKeep,:);
    % create patient database
    create_database_from_device_settings_files(boxdir)
    load(fullfile(boxdir,'database','database_from_device_settings.mat'));
    masterTableOut.allDeviceSettingsOut = allDeviceSettingsOut;
    idxTable = cellfun(@(x) istable(x), masterTableOut.stimState);
    masterTableUse = masterTableOut(idxTable,:);
    for s = 1:size(masterTableUse,1)
        [pn,fn] = fileparts(masterTableUse.allDeviceSettingsOut{s});
        timeStart = report_start_end_time_td_file_rcs(fullfile(pn,'RawDataTD.json'));
        isValidTime = ~isempty(timeStart.duration);
        if isValidTime
            timeStart.startTime.TimeZone             = 'America/Los_Angeles';
            timeStart.endTime.TimeZone               = 'America/Los_Angeles';
            masterTableUse.idxkeep(s) = 1;
            masterTableUse.timeStart(s) = timeStart.startTime;
            masterTableUse.timeEnd(s) = timeStart.endTime;
            masterTableUse.duration(s) = timeStart.duration;
        else
            masterTableUse.idxkeep(s) = 0;
            masterTableUse.timeStart(s) = NaT;
            masterTableUse.timeEnd(s) = NaT;
            masterTableUse.duration(s) = seconds(0);
            
        end
    end
    masterTableUse = masterTableUse(logical(masterTableUse.idxkeep),:);
    masterTableUse.duration.Format = 'hh:mm:ss';
    [masterTableUse, idxsort] = sortrows(masterTableUse,{'patient','timeStart'});
    
    %% get computer unix time start and stop time for these tasks, also find out which hand was used (if tasks lists hand used) 
    for ss = 1:size(masterTableUse,1)
        [pn,fn] = fileparts(masterTableUse.allDeviceSettingsOut{ss});
        [outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerOut,adaptiveTable] =  MAIN_load_rcs_data_from_folder(pn);
        if ~isempty(outdatcomplete)
            alltimes = outdatcomplete.PacketRxUnixTime(outdatcomplete.PacketRxUnixTime~=0);
            unixTimesTask = datetime(alltimes/1000,'ConvertFrom','posixTime',...
                'TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
            masterTableUse.unixTimeStart(ss) = unixTimesTask(1);
            masterTableUse.unixTimeEnd(ss) = unixTimesTask(end);
        else
            masterTableUse.unixTimeStart(ss) = NaT;
            masterTableUse.unixTimeEnd(ss) = NaT;
        end
        if sum(cellfun(@(x) any(strfind( x,'Movement task JSpsyc right hand')),eventTable.EventSubType)) > 0
            masterTableUse.handUsedForTask {ss} = 'right';
            endllll
        if sum(cellfun(@(x) any(strfind( x,'Movement task JSpsyc left hand')),eventTable.EventSubType)) > 0
            masterTableUse.handUsedForTask {ss} = 'left';
        end
        % if the task isn't "new enough" to have a hand used, then assume
        % the right hand hand was used 
        if sum(cellfun(@(x) any(strfind( x,'Movement task JSpsyc ')),eventTable.EventSubType)) == 0
            masterTableUse.handUsedForTask {ss} = 'right';
        end

    end
    
    % save this database to results
    save(fullfile(resdir,'task_file_database.mat'),'masterTableUse','taskDataLocs');
else
    load(fullfile(resdir,'task_file_database.mat'),'masterTableUse','taskDataLocs');
end


%% loop on task data and plot a nice figure for each subject
% load('/Users/roee/Box/movement_task_data_at_home/results/parrm_no_parrm_figures/masterTableUseAllFilters.mat');
sides = {'L','R'};
% so far all subject are using the ipislateral hand
% XXXX
% % XXXX
% [y,m,d] = ymd(taskDataLocs.taskStart);
% idsUse = taskDataLocs.taskDuration > seconds(30) & ...
%     d >= 28;
% 
% [y,m,d] = ymd(masterTableUse.timeStart);
% idxUseRcs =  d >= 28;
% masterTableUse = masterTableUse(idxUseRcs,:);


for m =1:size(masterTableUse,1)
    masterTableUse.chan1{m} = masterTableUse.senseSettings{m}.chan1{1};
    masterTableUse.chan2{m} = masterTableUse.senseSettings{m}.chan2{1};
    masterTableUse.chan3{m} = masterTableUse.senseSettings{m}.chan3{1};
    masterTableUse.chan4{m} = masterTableUse.senseSettings{m}.chan4{1};
    masterTableUse.active_recharge(m) = masterTableUse.stimStatus{m}.active_recharge(1);
    masterTableUse.stimulation_on(m) = masterTableUse.stimStatus{m}.stimulation_on(1);
    masterTableUse.samplingRate(m)    = masterTableUse.senseSettings{m}.samplingRate;
end 
masterTableUse = sortrows(masterTableUse,{'patient','unixTimeStart'});
masterTableUse(:,{'patient','side', 'unixTimeStart','chan1','chan2','chan3', 'chan4','active_recharge','stimulation_on','samplingRate'})
% taskDataLocs = taskDataLocs(idsUse,:);

% XXXX
% XXXX
idsUse = strcmp(taskDataLocs.patient,'RCS07') | strcmp(taskDataLocs.patient,'RCS08');

idsUse = strcmp(taskDataLocs.patient,'RCS07');
% taskDataLocs = taskDataLocs(idsUse,:);
% XXXX
% XXXX

% XXXXX Plot the behavioural data 
plotBehavioural = 1; 
% xxxxx
handBrainRelation = {'contralateral','ipsilateral'};
ccc = 1;
for ttt = 1:size(taskDataLocs)
    % find the RC+S session for this file
    idxRCdata = taskDataLocs.taskStart(ttt) > masterTableUse.unixTimeStart & ...
        taskDataLocs.taskEnd(ttt) < masterTableUse.unixTimeEnd;
    candidateRCSdata = masterTableUse(idxRCdata,:);
    % load event data
    for pp = 1:size(candidateRCSdata)
        [pn,fn] = fileparts(candidateRCSdata.allDeviceSettingsOut{pp});;
        load(fullfile(pn,'EventLog.mat'));
        if sum(cellfun(@(x) any(strfind( x,'Movement task JSpsyc right hand')),eventTable.EventSubType)) > 0
            candidateRCSdata.handUsedForTask {pp} = 'right';
        end
        if sum(cellfun(@(x) any(strfind( x,'Movement task JSpsyc left hand')),eventTable.EventSubType)) > 0
            candidateRCSdata.handUsedForTask {pp} = 'left';
        end
        if sum(cellfun(@(x) any(strfind( x,'Movement task JSpsyc ')),eventTable.EventSubType)) == 0
            candidateRCSdata.handUsedForTask {pp} = 'NA';
        end
        % exceptions - when we forgot to include in report - the task
        % event: 
        [yy,mm,dd] = ymd(candidateRCSdata.unixTimeStart(pp));
        [hh,MM] = hms(candidateRCSdata.unixTimeStart(pp));
        isExcep = (yy == 2020) & (mm == 11) & (dd == 6) & (hh == 13) & (MM == 2);
        if isExcep
            candidateRCSdata.handUsedForTask {pp} = 'right';
        end
        isExcep = (yy == 2020) & (mm == 11) & (dd == 6) & (hh == 13) & (MM == 13);
        if isExcep
            candidateRCSdata.handUsedForTask {pp} = 'left';
        end
        isExcep = (yy == 2020) & (mm == 11) & (dd == 6) & (hh == 14) & (MM == 48);
        if isExcep
            candidateRCSdata.handUsedForTask {pp} = 'right';
        end

    end
    unqHandUsed = unique(candidateRCSdata.handUsedForTask);
    if strcmp(handBrainRelation{ccc},'contralateral')
        if strcmp(unqHandUsed{1},'right')
            brainSideChoose = 'L';
        elseif strcmp(unqHandUsed{1},'left')
            brainSideChoose = 'R';
        end
    elseif strcmp(handBrainRelation{ccc},'ipsilateral')
        if strcmp(unqHandUsed{1},'right')
            brainSideChoose = 'R';
        elseif strcmp(unqHandUsed{1},'left')
            brainSideChoose = 'L';
        end
    end
    idxSide = strcmp(candidateRCSdata.side,brainSideChoose);
    rcsDataMeta = candidateRCSdata(idxSide,:);
    if isempty(rcsDataMeta)
        % you don't have one side or other conditons aren't met
        break;
    end
    handUsed  = unqHandUsed{1};
    patient  = rcsDataMeta.patient{1};
    if any(strfind(rcsDataMeta.senseSettings{1}.chan4{1},'250Hz'))
        x = 2;
        fprintf('%s %s %s is %s\n',rcsDataMeta.patient{1},rcsDataMeta.side{1},rcsDataMeta.timeStart(1),rcsDataMeta.senseSettings{1}.chan4{1});
    end
    
    if rcsDataMeta.stimStatus{1}.stimulation_on
        stimState = sprintf('stim on (%.2f mA)',rcsDataMeta.stimStatus{1}.amplitude_mA);
    else
        stimState = 'stim off';
    end
        timeStart = taskDataLocs.taskTable{ttt}.time(1);
        timeEnd = taskDataLocs.taskTable{ttt}.time(end);
        [hfig,trialDataResultsUse,taskDataWithTrials] = behaviouralAnalysis_movementTask_data_jspsyc(taskDataLocs.taskTable{ttt});
        taskDataLocs.trialDataResultsUse{ttt} = trialDataResultsUse;
        taskDataLocs.taskDataWithTrials{ttt} = taskDataWithTrials;
        ttlLarge{1,1} = sprintf('%s hand used = %s',patient,handUsed);
        ttlLarge{2,1} = sprintf('%s',stimState);
        ttlLarge{3,1} = sprintf('%s - %s',timeStart, timeEnd);
        sgtitle(ttlLarge,'FontSize',20);
        hfig.PaperSize = [7 10];
        hfig.PaperPosition = [0 0 7 10];
        [y,m,d] = ymd(timeStart);
        [h,mm,s] = hms(timeStart);
        fnmsv = sprintf('behav-results_%s_%d_%0.2d_%0.2d_%0.2d-%0.2d',patient,y,m,d,h,mm);
        % plot the behaviorual data
        if plotBehavioural
            print(hfig,fullfile(figdir,fnmsv),'-djpeg','-r300');
        end

end


handBrainRelation = {'contralateral','ipsilateral'};
for ttt = 1:size(taskDataLocs)
    for ccc = 1:length(handBrainRelation)
        % find the RC+S session for this file
        idxRCdata = taskDataLocs.taskStart(ttt) > masterTableUse.unixTimeStart & ...
            taskDataLocs.taskEnd(ttt) < masterTableUse.unixTimeEnd;
        candidateRCSdata = masterTableUse(idxRCdata,:);
        % load event data
        for pp = 1:size(candidateRCSdata)
            [pn,fn] = fileparts(candidateRCSdata.allDeviceSettingsOut{pp});;
            load(fullfile(pn,'EventLog.mat'));
            if sum(cellfun(@(x) any(strfind( x,'Movement task JSpsyc right hand')),eventTable.EventSubType)) > 0
                candidateRCSdata.handUsedForTask {pp} = 'right';
            end
            if sum(cellfun(@(x) any(strfind( x,'Movement task JSpsyc left hand')),eventTable.EventSubType)) > 0
                candidateRCSdata.handUsedForTask {pp} = 'left';
            end
            if sum(cellfun(@(x) any(strfind( x,'Movement task JSpsyc ')),eventTable.EventSubType)) == 0
                candidateRCSdata.handUsedForTask {pp} = 'NA';
            end
            % exceptions - when we forgot to include in report - the task
            % event:
            [yy,mm,dd] = ymd(candidateRCSdata.unixTimeStart(pp));
            [hh,MM] = hms(candidateRCSdata.unixTimeStart(pp));
            isExcep = (yy == 2020) & (mm == 11) & (dd == 6) & (hh == 13) & (MM == 2);
            if isExcep
                candidateRCSdata.handUsedForTask {pp} = 'right';
            end
            isExcep = (yy == 2020) & (mm == 11) & (dd == 6) & (hh == 13) & (MM == 13);
            if isExcep
                candidateRCSdata.handUsedForTask {pp} = 'left';
            end
            isExcep = (yy == 2020) & (mm == 11) & (dd == 6) & (hh == 14) & (MM == 48);
            if isExcep
                candidateRCSdata.handUsedForTask {pp} = 'left';
            end
        end
        unqHandUsed = unique(candidateRCSdata.handUsedForTask);
        if strcmp(handBrainRelation{ccc},'contralateral')
            if strcmp(unqHandUsed{1},'right')
                brainSideChoose = 'L';
            elseif strcmp(unqHandUsed{1},'left')
                brainSideChoose = 'R';
            end
        elseif strcmp(handBrainRelation{ccc},'ipsilateral')
            if strcmp(unqHandUsed{1},'right')
                brainSideChoose = 'R';
            elseif strcmp(unqHandUsed{1},'left')
                brainSideChoose = 'L';
            end
        end
        idxSide = strcmp(candidateRCSdata.side,brainSideChoose);
        rcsDataMeta = candidateRCSdata(idxSide,:);
        if isempty(rcsDataMeta)
            % you don't have one side or other conditons aren't met
            break;
        end
        handUsed  = unqHandUsed{1};
        patient  = rcsDataMeta.patient{1};
        if any(strfind(rcsDataMeta.senseSettings{1}.chan4{1},'250Hz'))
            break;
        end
        
        if rcsDataMeta.stimStatus{1}.stimulation_on
            stimState = sprintf('stim on (%.2f mA)',rcsDataMeta.stimStatus{1}.amplitude_mA);
        else
            stimState = 'stim off';
        end
        %% load RC+S data
        % find RC+S data
        [sessiondir,~] = fileparts(rcsDataMeta.allDeviceSettingsOut{1});
        [outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerOut,adaptiveTable] =  MAIN_load_rcs_data_from_folder(sessiondir);
        %% load task data
        taskData = taskDataLocs.taskTable{ttt};
        trialDataResultsUse = taskDataLocs.trialDataResultsUse{ttt};
        taskDataWithTrials = taskDataLocs.taskDataWithTrials{ttt};
        % don't plot practice tasks
        if sum(cellfun(@(x) any(strfind(x,' PREP start')),taskData.event)) <= 30 % bcs our task has 60 trials 
            break;
        end
        
        
        %% get task time in RC+S indexes
        tRxUnixTime = datetime(outdatcomplete.PacketRxUnixTime/1000,'ConvertFrom','posixTime',...
            'TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
        % use unix time since it doesn't have jitter built in relative to
        % RC+S time
        tRxGenTime = datetime(outdatcomplete.PacketGenTime/1000,'ConvertFrom','posixTime',...
            'TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
        % get godo trial data 
        idxTrialsUse = trialDataResultsUse.totalTimeToExecute <= seconds(3) & ...
            strcmp(trialDataResultsUse.result,'good trial');
        trialsUse = trialDataResultsUse.trial( idxTrialsUse);
        idxKeep = ismember(taskDataWithTrials.trial,trialsUse);
        taskDataToUse = taskDataWithTrials(idxKeep,:);
        taskData = taskDataToUse;
        for tt = 1:size(taskData)
            taskComputerTime = taskData.time(tt);
            %% rx unix time
            [delta,idxCloest] = min(abs(taskComputerTime - tRxUnixTime));
            deltaUse = taskComputerTime - tRxUnixTime(idxCloest);
            targetInsTime = outdatcomplete.derivedTimes(idxCloest) + deltaUse;
            [~,idxUseRxUnixTime] = min(abs(outdatcomplete.derivedTimes - targetInsTime));
            taskData.idxUseRxUnixTime(tt,1) = idxUseRxUnixTime;
            %% rx gen time
            [delta,idxCloest] = min(abs(taskComputerTime - tRxGenTime));
            deltaUse = taskComputerTime - tRxGenTime(idxCloest);
            targetInsTime = outdatcomplete.derivedTimes(idxCloest) + deltaUse;
            [~,idxUseRxGenTime] = min(abs(outdatcomplete.derivedTimes - targetInsTime));
            taskData.idxUseRxGenTime(tt,1) = idxUseRxGenTime;
        end
        
        analysisToDo = {'center_prep','center_move','center_keyUp'};
%         analysisToDo = {'center_keyUp'};
        for aaa = 1:length(analysisToDo)
            timeparams = getTaskTimings(taskData,analysisToDo{aaa});
            %% plot ipad data based on this alligmment
            pathadd = '/Users/roee/Box/movement_task_data_at_home/code/from_nicki';
            addpath(genpath(pathadd));
            addpath('/Users/roee/Box/movement_task_data_at_home/code/eeglab');
            
            tdDat = outRec(1).tdData;
            % find out what channels to plot 
            cnlcnt = 1; 
            for cc = 1:4 
                if ~any(strfind(tdDat(cc).chanFullStr,'disabled'))
                    chanlsPlot(cnlcnt) = cc;
                    cnlcnt = cnlcnt + 1;
                end
            end
            
            % get the data 
            for c = 1:length(chanlsPlot)
                cnmIpadData = sprintf('key%d',chanlsPlot(c)-1);
                cnm = sprintf('chan%d',c);
                
                rcsIpadDataPlot.(cnm) = outdatcomplete.(cnmIpadData);
                rcsIpadDataPlot.([cnm 'Title']) = tdDat(chanlsPlot(c)).chanFullStr;
            end
            rcsIpadDataPlot.numChannels = length(chanlsPlot);
            % clean stim outliers 
            if rcsDataMeta.stimStatus{1}.stimulation_on
                idxRCOut = cleanDataFromStimulationArtifacts(rcsIpadDataPlot,timeparams.RCidxUse,rcsDataMeta,timeparams,outlierFunc);
                timeparams.RCidxUse = idxRCOut;
            end
            
            if rcsIpadDataPlot.numChannels == 2
                nrows = 1;
            elseif rcsIpadDataPlot.numChannels == 4
                nrows = 2;
            end
            ncols = 2;
            close all;
            idxUseRxUnixTime = timeparams.RCidxUse;
            % plot the .json data 
            timeparams = plot_ipad_data_rcs_json(idxUseRxUnixTime,rcsIpadDataPlot,unique(outdatcomplete.samplerate),figdir,timeparams,...
                nrows,ncols,0,2,250); % nrwos, ncols, save figure, min freq , max freq
            
            %% save figure
            hfig = gcf;
            hfig.PaperSize = [14 6];
            hfig.PaperPosition = [0 0 14 6];
            largeTitle = {};
            largeTitle{1,1} = sprintf('%s %s (brain) %s (hand) (%s)',patient,brainSideChoose,handUsed,handBrainRelation{ccc});
            largeTitle{2,1} = sprintf('%s',stimState);
            largeTitle{3,1} = sprintf('%s',strrep('red line - target presented (prep) green line - go cue (move)','_',' '));
            largeTitle{4,1} = sprintf('%s - %s', rcsDataMeta.unixTimeStart,rcsDataMeta.unixTimeEnd);
            sgtitle(largeTitle);
            timeStart = taskData.time(1);
            fnmsv = sprintf('%s_%s-brain-%s-hand_%s___%s____%d-%0.2d-%0.2d__%0.2d-%0.2d',...
                patient,brainSideChoose,handUsed,...
                handBrainRelation{ccc},...
                timeparams.analysis,...
                year(timeStart),...
                month(timeStart),...
                day(timeStart),...
                hour(timeStart),...
                minute(timeStart));
            
            %% save data
            save(fullfile(resdir,[fnmsv '.mat']),'timeparams','rcsDataMeta','taskData','rcsIpadDataPlot');
            
            print(hfig,fullfile(figdir,fnmsv),'-djpeg','-r300');
        end
    end
end


end

function timeparams = getTaskTimings(taskData,analysisType)
% fixation - 3000
% prep     - 3000
% move up to 5000
% sound starts when trial starts (rest on)
% the trial is usually 3 parts- fixation (sound starts), prepaeration, movement

% changed how it worked on July 28th these are new settings if plotting
% something older need to revert to odler settings
% ideally computer on a per/task basis
% fixation - 2000
% prep     - 2000
% move up to 2000
% sound starts when trial starts (rest on)
% the trial is usually 3 parts- fixation (sound starts), prepaeration, movement


switch analysisType
    case 'center_prep'
        %% get idx for event
        cnt = 1;
        idxcnt = 1;
        lookForKeyUp = 0;
        
        inFixation = 0;
        keyDownDuringFixation = 0;
        inPrep = 0;
        keyUpDuringPrep = 0;
        inMove = 0;
        keyUpDuringMove = 0;
        while cnt <= size(taskData.event,1)
            x = taskData.event{cnt};
            
            % prep
            if  any(strfind(x,'PREP start'))
                inPrep = 1;
                badTrial = 0;
                idxPrep = taskData.idxUseRxUnixTime(cnt);
            end
            if  any(strfind(x,'PREP end'))
                inPrep = 0;
            end
            
            if inPrep & any(strfind(x,'KeyUp'))
                keyUpDuringPrep = 1;
            end
            if ~inPrep & any(strfind(x,'KeyUp'))
                keyUpDuringPrep = 0;
            end
            if keyUpDuringPrep
                badTrial = 1;
            end
            % move
            if  any(strfind(x,'MOVE start'))
                inMove = 1;
            end
            if  any(strfind(x,'MOVE end'))
                inMove = 0;
            end
            
            if inMove & any(strfind(x,'KeyUp'))
                keyUpDuringMove = 1;
            end
            if ~inMove & any(strfind(x,'KeyUp'))
                keyUpDuringMove = 0;
            end
            
            if keyUpDuringMove & ~badTrial
                prepRCidx(idxcnt,1) = idxPrep;
                idxcnt = idxcnt + 1;
            end
            
            cnt = cnt + 1;
        end
        
        unqRCidxs = unique(prepRCidx);
        
        timeparams.RCidxUse                    = unqRCidxs;
        timeparams.start_epoch_at_this_time    =  -1000;%-8000; % ms relative to event (before), these are set for whole analysis
        timeparams.stop_epoch_at_this_time     =  4000; % ms relative to event (after)
        timeparams.start_baseline_at_this_time =  -1000;%-6500; % ms relative to event (before), recommend using ~500 ms *note in the msns folder there is a modified version where you can set baseline bounds by trial (good for varible times, ex. SSD)
        timeparams.stop_baseline_at_this_time  =  0;%5-6000; % ms relative to event
        timeparams.extralines                  = 1; % plot extra line
        timeparams.extralinesec                = 2000; % extra line location in seconds
        timeparams.analysis                    = analysisType;
        timeparams.filtertype                  = 'ifft-gaussian' ; % 'ifft-gaussian' or 'fir1'
        
        
    case 'center_move'
        %% get idx for event
        cnt = 1;
        idxcnt = 1;
        lookForKeyUp = 0;
        
        inFixation = 0;
        keyDownDuringFixation = 0;
        inPrep = 0;
        keyUpDuringPrep = 0;
        inMove = 0;
        keyUpDuringMove = 0;
        while cnt <= size(taskData.event,1)
            x = taskData.event{cnt};
            
            % prep
            if  any(strfind(x,'PREP start'))
                inPrep = 1;
                badTrial = 0;
            end
            if  any(strfind(x,'PREP end'))
                inPrep = 0;
            end
            
            if inPrep & any(strfind(x,'KeyUp'))
                keyUpDuringPrep = 1;
            end
            if ~inPrep & any(strfind(x,'KeyUp'))
                keyUpDuringPrep = 0;
            end
            if keyUpDuringPrep
                badTrial = 1;
            end
            % move
            if  any(strfind(x,'MOVE start'))
                inMove = 1;
                idxMove = taskData.idxUseRxUnixTime(cnt);
            end
            if  any(strfind(x,'MOVE end'))
                inMove = 0;
            end
            
            
            
            if inMove & any(strfind(x,'KeyUp'))
                keyUpDuringMove = 1;
            end
            
            if ~inMove & any(strfind(x,'KeyUp'))
                keyUpDuringMove = 0;
            end
            
            if keyUpDuringMove & ~badTrial
                prepRCidx(idxcnt,1) = idxMove;
                idxcnt = idxcnt + 1;
            end
            
            
            cnt = cnt + 1;
        end
        
        unqRCidxs = unique(prepRCidx);
        
        timeparams.RCidxUse                    = unqRCidxs;
        timeparams.start_epoch_at_this_time    =  -1000;%-8000; % ms relative to event (before), these are set for whole analysis
        timeparams.stop_epoch_at_this_time     =  1000; % ms relative to event (after)
        timeparams.start_baseline_at_this_time =  -1000;%-6500; % ms relative to event (before), recommend using ~500 ms *note in the msns folder there is a modified version where you can set baseline bounds by trial (good for varible times, ex. SSD)
        timeparams.stop_baseline_at_this_time  =  0;%5-6000; % ms relative to event
        timeparams.extralines                  = 0; % plot extra line
        timeparams.extralinesec                = 3000; % extra line location in seconds
        timeparams.analysis                    = analysisType;
        timeparams.filtertype                  = 'ifft-gaussian' ; % 'ifft-gaussian' or 'fir1'
        
    case 'center_keyUp'
        %% get idx for event
        cnt = 1;
        idxcnt = 1;
        lookForKeyUp = 0;
        
        inFixation = 0;
        keyDownDuringFixation = 0;
        inPrep = 0;
        keyUpDuringPrep = 0;
        inMove = 0;
        keyUpDuringMove = 0;
        while cnt <= size(taskData.event,1)
            x = taskData.event{cnt};
            
            % prep
            if  any(strfind(x,'PREP start'))
                inPrep = 1;
                badTrial = 0;
            end
            if  any(strfind(x,'PREP end'))
                inPrep = 0;
            end
            
            if inPrep & any(strfind(x,'KeyUp'))
                keyUpDuringPrep = 1;
            end
            if ~inPrep & any(strfind(x,'KeyUp'))
                keyUpDuringPrep = 0;
            end
            if keyUpDuringPrep
                badTrial = 1;
            end
            % move
            if  any(strfind(x,'MOVE start'))
                inMove = 1;
                
            end
            if  any(strfind(x,'MOVE end'))
                inMove = 0;
            end
            
            
            
            if inMove & any(strfind(x,'KeyUp'))
                keyUpDuringMove = 1;
                idxMove = taskData.idxUseRxUnixTime(cnt);
            end
            
            if ~inMove & any(strfind(x,'KeyUp'))
                keyUpDuringMove = 0;
            end
            
            if keyUpDuringMove & ~badTrial
                prepRCidx(idxcnt,1) = idxMove;
                idxcnt = idxcnt + 1;
            end
            
            
            cnt = cnt + 1;
        end
        
        unqRCidxs = unique(prepRCidx);
        
        timeparams.RCidxUse                    = unqRCidxs;
        timeparams.start_epoch_at_this_time    =  -1000;%-8000; % ms relative to event (before), these are set for whole analysis
        timeparams.stop_epoch_at_this_time     =  1000; % ms relative to event (after)
        timeparams.start_baseline_at_this_time =  -1000;%-6500; % ms relative to event (before), recommend using ~500 ms *note in the msns folder there is a modified version where you can set baseline bounds by trial (good for varible times, ex. SSD)
        timeparams.stop_baseline_at_this_time  =  0;%5-6000; % ms relative to event
        timeparams.extralines                  = 0; % plot extra line
        timeparams.extralinesec                = 3000; % extra line location in seconds
        timeparams.analysis                    = analysisType;
        timeparams.filtertype                  = 'ifft-gaussian' ; % 'ifft-gaussian' or 'fir1'
        
        
    otherwise
end
end

function idxRCOut = cleanDataFromStimulationArtifacts(rcsIpadDataPlot,idxRC,rcsDataMeta,timeparams,outlierFunc)
stimRate = rcsDataMeta.stimStatus{1}.rate_Hz; 
samplingRate = rcsDataMeta.senseSettings{1}.samplingRate;
bp = designfilt('bandpassiir',...
    'FilterOrder',4, ...
    'HalfPowerFrequency1',ceil(stimRate-2),...
    'HalfPowerFrequency2',ceil(stimRate+2), ...
    'SampleRate',samplingRate);
fieldnamesAll = fieldnames(rcsIpadDataPlot);
fieldNameIdxUse = cellfun(@(x) any(strfind(x,'chan')),fieldnamesAll) & ~cellfun(@(x) any(strfind(x,'Title')),fieldnamesAll);
fieldNamesUse = fieldnamesAll(fieldNameIdxUse);
pointSubtract = (timeparams.start_epoch_at_this_time/1e3) * samplingRate;
pointAdd = (timeparams.stop_epoch_at_this_time/1e3) * samplingRate;
idxremove = [];
for i = 1:length(fieldNamesUse)
    fn = fieldNamesUse{i};
    rawData = rcsIpadDataPlot.(fn); 
    filtData = [];
    for t = 1:length(idxRC)
        idxRange = (idxRC(t)+pointSubtract):1:(idxRC(t)+pointAdd-1);
        taskData = rawData(idxRange,1);
        filtData(t,:) = filtfilt(bp,taskData);
        [envpH, envpL] = envelope(filtData(t,:),samplingRate*30,'analytic'); % analytic rms
        mvmean(t,:) = movmean(abs(envpH),[ceil(range(idxRange)/10),0]);
        secs = [1:1:length(taskData)]./samplingRate;
    end
    try 
        idxremove(:,i) = outlierFunc(mean(mvmean,2));
    catch 
        idxremove(:,i) = mean(mvmean,2) < prctile(mean(mvmean,2),95);
    end
    
    figure;
    plot(secs,mvmean');
%     
    
end
% rreport what was removed 
idxremove = sum(idxremove,2)>=1; 
fprintf('removed %d/%d trials (%.2f) bcs of stim artifacts \n',sum(idxremove),length(idxremove),sum(idxremove)/length(idxremove));
idxNotWithStimArtifact = ~idxremove; 
idxRCOut = idxRC(idxNotWithStimArtifact);


end
