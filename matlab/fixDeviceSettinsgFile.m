function fixDeviceSettinsgFile(boxdir)
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

save(fullfile(boxdir,'database_from_device_settings.mat'),'masterTableUse','masterTableOut');
end