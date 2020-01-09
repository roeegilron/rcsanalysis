function plot_ipad_data_rcs_based_on_beeps()
% this is basing RC+S ipad allignment based on the beeps from the ipad task
% and not on deslys allignemtn 

diropen = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS05/v08_RCS05 4 Month/SCBS/RCS05L/Session1578596861133/DeviceNPC700414H';
[outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerOut,adaptiveTable] =  MAIN_load_rcs_data_from_folder(diropen);


eventTable = allign_events_time_domain_time(eventTable,outdatcomplete);
timesRaw = eventTable.insTimes; 
tlower = datetime('09-Jan-2020 11:10:49.785'); 
tlower.TimeZone = timesRaw.TimeZone;
tupper = datetime('09-Jan-2020 11:12:54.040'); 
tupper.TimeZone = timesRaw.TimeZone;
tf = isbetween(timesRaw,tlower,tupper);
timesUse = eventTable.insTimes(tf); 

derivedTimes = outdatcomplete.derivedTimes; 
% chop the time domain data so you don't have to filter as much data 
tf = isbetween(derivedTimes,tlower-seconds(20),tupper+seconds(20));
outdatcomplete = outdatcomplete(tf,:); 
derivedTimes = outdatcomplete.derivedTimes; 

%% plot ipad data based on this alligmment 


% sound starts when trial starts (rest on) 
% the trial is usually 3 parts- fixation (sound starts), prepaeration, movement 
% fixation 2s??preparation 2s??movement 2s??steps 2
timesUse = timesUse + seconds(4); % so movement onset is the first line 
for t = 1:length(timesUse)
    [minDiff(t,1), idxUseIpad(t,1)] = min(abs(derivedTimes-timesUse(t)));
end



timeparams.start_epoch_at_this_time    =  -3000;%-8000; % ms relative to event (before), these are set for whole analysis
timeparams.stop_epoch_at_this_time     =  2000; % ms relative to event (after)
timeparams.start_baseline_at_this_time =  -3000;%-6500; % ms relative to event (before), recommend using ~500 ms *note in the msns folder there is a modified version where you can set baseline bounds by trial (good for varible times, ex. SSD)
timeparams.stop_baseline_at_this_time  =  -2000;%5-6000; % ms relative to event
timeparams.extralines                  = 1; % plot extra line
timeparams.extralinesec                = -2000; % extra line location in seconds
timeparams.analysis                    = 'hold_center';
timeparams.filtertype                  = 'fir1' ; % 'ifft-gaussian' or 'fir1'

pathadd = '/Users/roee/Starr_Lab_Folder/Data_Analysis/First_Pass_Data_Analysis/code/from_nicki';
addpath(genpath(pathadd));
tdDat = outRec(1).tdData;
for c = 1:4  
    cnmIpadData = sprintf('key%d',c-1);
    cnm = sprintf('chan%d',c); 
    rcsIpadDataPlot.(cnm) = outdatcomplete.(cnmIpadData);
    rcsIpadDataPlot.([cnm 'Title']) = tdDat(c).chanFullStr;
end
rcsIpadDataPlot.numChannels = 4; 
plot_ipad_data_rcs_json(idxUseIpad,rcsIpadDataPlot,unique(outdatcomplete.samplerate),diropen,timeparams)
rmpath(genpath(pathadd));