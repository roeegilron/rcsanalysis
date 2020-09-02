function plot_ipad_data_rcs_based_on_jspsych_backup_before_new_task_design()
% this is basing RC+S ipad allignment based on the beeps from the ipad task
% and not on deslys allignemtn
clc;
createFileDatabase = 1;

boxdir = '/Users/roee/Box/movement_task_data_at_home/data'; % dektop
boxdir = '/Users/roee/Box/movement_task_data_at_home/data'; % laptop
resdir = '/Users/roee/Box/movement_task_data_at_home/results'; % laptop
figdir = '/Users/roee/Box/movement_task_data_at_home/figures'; % laptop
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
    % create patient database
    create_database_from_device_settings_files(boxdir)
    load(fullfile(boxdir,'database_from_device_settings.mat'));
    idxTable = cellfun(@(x) istable(x), masterTableOut.stimState);
    idxNonZero = masterTableOut.duration > seconds(5);
    idxUse = idxTable & idxNonZero;
    masterTableUse = masterTableOut(idxUse,:);
    allDeviceSettingsOut = allDeviceSettingsOut(idxUse);
    for s = 1:size(masterTableUse,1)
        [pn,fn] = fileparts(allDeviceSettingsOut{s});
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
    allDeviceSettingsOut = allDeviceSettingsOut(logical(masterTableUse.idxkeep));
    masterTableUse.allDeviceSettingsOut = allDeviceSettingsOut;
    [masterTableUse, idxsort] = sortrows(masterTableUse,{'patient','timeStart'});
    
    %% get computer unix time start and stop time for these tasks
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
    end
    
    % save this database to results
    save(fullfile(resdir,'task_file_database.mat'),'masterTableUse','taskDataLocs');
else
    load(fullfile(resdir,'task_file_database.mat'),'masterTableUse','taskDataLocs');
end


%% loop on task data and plot a nice figure for each subject
sides = {'L','R'};
% so far all subject are using the ipislateral hand
% XXXX 
% XXXX 
[y,m,d] = ymd(taskDataLocs.taskStart);
idsUse = strcmp(taskDataLocs.patient,'RCS06') & ...
    taskDataLocs.taskDuration > seconds(30) & ... 
    d == 28;
    
taskDataLocs = taskDataLocs(idsUse,:);
% XXXX 
% XXXX 
for ttt = 1:size(taskDataLocs)
    for sss = 1:length(sides)
        % find the RC+S session for this file
        idxRCdata = taskDataLocs.taskStart(ttt) > masterTableUse.unixTimeStart & ...
            taskDataLocs.taskStart(ttt) < masterTableUse.unixTimeEnd;
        candidateRCSdata = masterTableUse(idxRCdata,:);
        idxSide = strcmp(candidateRCSdata.side,sides{sss});
        rcsDataMeta = candidateRCSdata(idxSide,:);
        if isempty(rcsDataMeta)
            % you don't have one side or other conditons aren't met
            break; 
        end
        side = sides{sss};
        brainSide = side;
        handUsed  = 'R';
        patient  = rcsDataMeta.patient{1};
        session = rcsDataMeta.sessname{1}; 
        if any(strfind(rcsDataMeta.chan4{1},'250Hz'))
            break;
        end
        
        if rcsDataMeta.stimulation_on 
            stimState = sprintf('stim on (%.2f mA)',rcsDataMeta.amplitude_mA);
        else
            stimState = 'stim off';
        end
        %% load RC+S data
        % find RC+S data 
        patdir = findFilesBVQX(boxdir,patient,struct('depth',1,'dirs',1));
        sidedir = findFilesBVQX(patdir{1},['RC*' side],struct('depth',1,'dirs',1));
        sessiondir = findFilesBVQX(sidedir{1},['*' session '*'],struct('depth',1,'dirs',1));
        [outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerOut,adaptiveTable] =  MAIN_load_rcs_data_from_folder(sessiondir{1});
        %% load task data 
        taskData = taskDataLocs.taskTable{ttt};
        % don't plot practice tasks
        if sum(cellfun(@(x) any(strfind(x,' PREP start')),taskData.event)) >= 30
            break;
        end

        
        %% get task time in RC+S indexes 
        tRxUnixTime = datetime(outdatcomplete.PacketRxUnixTime/1000,'ConvertFrom','posixTime',...
            'TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
        % use unix time since it doesn't have jitter built in relative to
        % RC+S time 
        tRxGenTime = datetime(outdatcomplete.PacketGenTime/1000,'ConvertFrom','posixTime',...
            'TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
        
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
        
        analysisToDo = {'center_prep','center_move'};
        for aaa = 1:length(analysisToDo)
            timeparams = getTaskTimings(taskData,analysisToDo{aaa});
            
            %% plot ipad data based on this alligmment
            pathadd = '/Users/roee/Box/movement_task_data_at_home/code/from_nicki';
            addpath(genpath(pathadd));
            addpath('/Users/roee/Box/movement_task_data_at_home/code/eeglab');
            
            tdDat = outRec(1).tdData;
            chanlsPlot = [3:4];
            for c = 1:length(chanlsPlot)
                cnmIpadData = sprintf('key%d',chanlsPlot(c)-1);
                cnm = sprintf('chan%d',c);
                
                rcsIpadDataPlot.(cnm) = outdatcomplete.(cnmIpadData);
                rcsIpadDataPlot.([cnm 'Title']) = tdDat(chanlsPlot(c)).chanFullStr;
            end
            rcsIpadDataPlot.numChannels = length(chanlsPlot);
            % idxUseRxGenTime
            % idxUseRxUnixTime
            nrows = 1;
            ncols = 2;
            close all;
            idxUseRxUnixTime = timeparams.RCidxUse;
            timeparams = plot_ipad_data_rcs_json(idxUseRxUnixTime,rcsIpadDataPlot,unique(outdatcomplete.samplerate),figdir,timeparams,...
                nrows,ncols,0,2,250); % nrwos, ncols, save figure, min freq , max freq
            
            %% save figure
            hfig = gcf;
            hfig.PaperSize = [14 6];
            hfig.PaperPosition = [0 0 14 6];
            largeTitle = {};
            largeTitle{1,1} = sprintf('%s %s (brain) %s (hand)',patient,brainSide,handUsed);
            largeTitle{2,1} = sprintf('%s',stimState);
            largeTitle{3,1} = sprintf('%s',strrep('red line - target presented (prep) green line - go cue (move)','_',' '));
            largeTitle{4,1} = sprintf('%s - %s', rcsDataMeta.unixTimeStart,rcsDataMeta.unixTimeEnd);
            sgtitle(largeTitle);
            timeStart = taskData.time(1);
            fnmsv = sprintf('%s_%s-brain-%s-hand___%s____%d-%0.2d-%0.2d__%0.2d-%0.2d',...
                patient,brainSide,handUsed,...
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
% fixation 2s??preparation 2s??movement 2s??steps 2

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
            timeparams.extralinesec                = 3000; % extra line location in seconds
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
            timeparams.start_epoch_at_this_time    =  -2000;%-8000; % ms relative to event (before), these are set for whole analysis
            timeparams.stop_epoch_at_this_time     =  2000; % ms relative to event (after)
            timeparams.start_baseline_at_this_time =  -2000;%-6500; % ms relative to event (before), recommend using ~500 ms *note in the msns folder there is a modified version where you can set baseline bounds by trial (good for varible times, ex. SSD)
            timeparams.stop_baseline_at_this_time  =  0;%5-6000; % ms relative to event
            timeparams.extralines                  = 0; % plot extra line
            timeparams.extralinesec                = 3000; % extra line location in seconds
            timeparams.analysis                    = analysisType;
            timeparams.filtertype                  = 'ifft-gaussian' ; % 'ifft-gaussian' or 'fir1'
            

        otherwise 
    end
end
