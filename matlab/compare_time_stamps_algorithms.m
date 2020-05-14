function compare_time_stamps_algorithms()
close all; clear all; clc;
dirtest = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/bencjtop/benchtop_test_packet_loss/PacketLoss_Juan_Test/Session1586491169892/DeviceNPC700239H';
% dirtest = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/bencjtop/benchtop_test_packet_loss/PacketLoss_Juan_Test/Session1586491879197/DeviceNPC700239H';
dirtest = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/bencjtop/PacketLoss_RoeeJuan/Session1586491169892/DeviceNPC700239H';

[outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerTable] =  MAIN_load_rcs_data_from_folder(dirtest);


% get times for power data 
timestamps   = powerTable.powerTable.timestamp;
systemTicks  = powerTable.powerTable.systemTick;
rxUnixTimes  = powerTable.powerTable.PacketRxUnixTime;

timesOut = getTimesFromPowerOrAdaptive(timestamps,systemTicks,rxUnixTimes);
powerTable.powerTable = powerTable.powerTable(2:end,:); % get rid of first idx 
powerTable.powerTable.derivedTimes = timesOut;

% plot data based on my algorithm
hfig = figure; 
hfig.Color = 'w';
hsb(1) = subplot(2,1,1); 
plot(outdatcomplete.derivedTimes, outdatcomplete.key0); 
title('time domain data'); 

hsb(2) = subplot(2,1,2); 
plot(powerTable.powerTable.derivedTimes,powerTable.powerTable.Band1);
title('power data');
linkaxes(hsb,'x');

%%

% allign even times to ins times 
eventTable = allign_events_time_domain_time(eventTable,outdatcomplete);


addpath(genpath(fullfile(pwd,'toolboxes','KS_UnifyTime')));

jsonobj = deserializeJSON(fullfile(dirtest,'RawDataTD.json'));
[outdat, srates] = unravelData(jsonobj);
outtab = populateTimeStamp_KS2(outdat,srates);



% get power times: 
unifiedTimes = unifyTime_KS(powerTable.powerTable);
% unified time stamps are in units of system tick 
% so resolution is a 10th of am milisecond 

% Convert unifiedTimes to unixtime
staticTimeToAdd = 951897600; % Elapsed time from Jan 1, 1970 to March 1, 2000 at midnight 
calculatedPacketUnixTimes = (unifiedTimes / 10000) + staticTimeToAdd;

power_times = datetime(calculatedPacketUnixTimes,'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');



hfig = figure; 
hfig.Color = 'w';
hsb(1) = subplot(2,1,1); 
plot(outtab.derivedTimes, outtab.key0); 
title('time domain data'); 

hsb(2) = subplot(2,1,2); 
plot(power_times,powerTable.powerTable.Band1);
title('power data');
linkaxes(hsb,'x');


end