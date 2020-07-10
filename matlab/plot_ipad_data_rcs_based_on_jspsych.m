function plot_ipad_data_rcs_based_on_jspsych()
% this is basing RC+S ipad allignment based on the beeps from the ipad task
% and not on deslys allignemtn 
clc;

%% data dir 
boxdir = '/Users/roee/Box/movement_task_data_at_home/data';
patdirs = findFilesBVQX(boxdir,'RCS*',struct('dirs',1,'depth',1));
%% loop on each patient, find sides and possible tasks that work for each directory 
% task data 
% assume all patients use R hand for this case 
taskDataLocs = table();
for p = 1:length(patdirs)
    % find tasks 
    % find task dir 
    taskDir = findFilesBVQX(patdirs{p},'task*',struct('dirs',1,'depth',1));
    process_task_logs(dirname)
    
    [pn, fn] = fileparts(patdirs{p}); 
    sidedirs = findFilesBVQX(patdirs{p},'RCS*',struct('dirs',1,'depth',1));
    for s = 1:length(sidedirs)
        
    end
end



%% load RC+S data 
diropen = '/Users/roee/Documents/RCS02_task_data_test/SummitContinuousBilateralStreaming/RCS02L/Session1594161831245/DeviceNPC700398H';
[outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerOut,adaptiveTable] =  MAIN_load_rcs_data_from_folder(diropen);
[pn,fn] = fileparts(diropen);
[pn,fn] = fileparts(pn);
[pn,fn] = fileparts(pn);
fprintf('\n\n');
fprintf('patient %s side %s\n',fn(1:5),fn(end));
%% load tasks events 
fileload = '/Users/roee/Documents/RCS02_task_data_test/task_logs/task_file_name___2020-07-07 15_44_53___2020-07-07 15_47_25.mat';
load(fileload);
%% 
 
%% get idx for event 
cnt = 1; 
idxcnt = 1;
lookForKeyUp = 0;
while cnt <= size(taskData.event,1)
    x = taskData.event{cnt};
    if  any(strfind(x,'move start'))
        lookForKeyUp = 1; 
    elseif any(strfind(x,'move end'))
        lookForKeyUp = 0;
    end
    if lookForKeyUp
        if any(strfind(x,'KeyUp'))
            idxkeep(idxcnt) = cnt; 
            idxcnt = idxcnt + 1; 
        end
    end
    cnt = cnt + 1; 
end
timesMoveStart = taskData.time(idxkeep);
%%
% XXXXXX
x = 2;
idxUse = cellfun(@(x) any(strfind(x,'target move start')),taskData.event);
timesUse = taskData.time(idxUse);
timesMoveStart = timesUse;
%%

%% get task time in RC+S indexes 
tRxUnixTime = datetime(outdatcomplete.PacketRxUnixTime/1000,'ConvertFrom','posixTime',...
    'TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');

tRxGenTime = datetime(outdatcomplete.PacketGenTime/1000,'ConvertFrom','posixTime',...
    'TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');

timesUse = timesMoveStart;
for tt = 1:length(timesUse)
    taskComputerTime = timesUse(tt);
    %% rx unix time 
    [delta,idxCloest] = min(abs(taskComputerTime - tRxUnixTime));
    deltaUse = taskComputerTime - tRxUnixTime(idxCloest);
    targetInsTime = outdatcomplete.derivedTimes(idxCloest) + deltaUse;
    [~,idxUseRxUnixTime(tt,1)] = min(abs(outdatcomplete.derivedTimes - targetInsTime));
    %% rx gen time
    [delta,idxCloest] = min(abs(taskComputerTime - tRxGenTime));
    deltaUse = taskComputerTime - tRxGenTime(idxCloest);
    targetInsTime = outdatcomplete.derivedTimes(idxCloest) + deltaUse;
    [~,idxUseRxGenTime(tt,1)] = min(abs(outdatcomplete.derivedTimes - targetInsTime));
end

anyalysisTypeIdx = 1;
if anyalysisTypeIdx ==1 
    anytype = 'contralatreal_hand_rx_unix_move_start';
else
    anytype = 'ipsilateral_hand';
end

%% plot ipad data based on this alligmment 

% fixation - 2000 
% prep     - 4000 
% move up to 5000 
% sound starts when trial starts (rest on) 
% the trial is usually 3 parts- fixation (sound starts), prepaeration, movement 
% fixation 2s??preparation 2s??movement 2s??steps 2


timeparams.start_epoch_at_this_time    =  -6000;%-8000; % ms relative to event (before), these are set for whole analysis
timeparams.stop_epoch_at_this_time     =  1000; % ms relative to event (after)
timeparams.start_baseline_at_this_time =  -6000;%-6500; % ms relative to event (before), recommend using ~500 ms *note in the msns folder there is a modified version where you can set baseline bounds by trial (good for varible times, ex. SSD)
timeparams.stop_baseline_at_this_time  =  -5000;%5-6000; % ms relative to event
timeparams.extralines                  = 1; % plot extra line
timeparams.extralinesec                = -4000; % extra line location in seconds
timeparams.analysis                    = anytype;
timeparams.filtertype                  = 'fir1' ; % 'ifft-gaussian' or 'fir1'

pathadd = '/Users/roee/Documents/Code/starr_lab_first_pass/from_nicki';
addpath(genpath(pathadd));
% path to eeglab
addpath(genpath('/Users/roee/Documents/Code/eeglab'));

tdDat = outRec(1).tdData;
for c = 1:4  
    cnmIpadData = sprintf('key%d',c-1);
    cnm = sprintf('chan%d',c); 
    rcsIpadDataPlot.(cnm) = outdatcomplete.(cnmIpadData);
    rcsIpadDataPlot.([cnm 'Title']) = tdDat(c).chanFullStr;
end
rcsIpadDataPlot.numChannels = 4; 
% idxUseRxGenTime
% idxUseRxUnixTime
plot_ipad_data_rcs_json(idxUseRxUnixTime,rcsIpadDataPlot,unique(outdatcomplete.samplerate),diropen,timeparams)
rmpath(genpath(pathadd));