function load_and_save_stim_titration_data(dirname)

[outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerOut,adaptiveTable] =  MAIN_load_rcs_data_from_folder(dirname);

% get times for power data 
timestamps   = powerOut.powerTable.timestamp;
systemTicks  = powerOut.powerTable.systemTick;
rxUnixTimes  = powerOut.powerTable.PacketRxUnixTime;

timesOut = getTimesFromPowerOrAdaptive(timestamps,systemTicks,rxUnixTimes);
powerOut.powerTable = powerOut.powerTable(2:end,:); % get rid of first idx 
powerOut.powerTable.derivedTimes = timesOut;


% allign even times to ins times 
eventTable = allign_events_time_domain_time(eventTable,outdatcomplete);

% find all rest events 
idxrest = cellfun(@(x) any(strfind(x,'block')),  eventTable.EventSubType);

figure;
plot(powerOut.powerTable.Band1);
end

