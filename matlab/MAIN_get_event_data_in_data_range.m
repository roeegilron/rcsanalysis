function MAIN_get_event_data_in_data_range()

%% load the database
clear all; clc; close all; 
dropboxdir = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database';
reportsDir = fullfile(dropboxdir,'reports');
databaseFile = fullfile(dropboxdir,'database_from_device_settings.mat');
load(databaseFile);
idxkeep  = cellfun(@(x) istable(x),masterTableOut.stimStatus) & logical(masterTableOut.recordedWithScbs);
dbUse    = masterTableOut(idxkeep,:); 
dbUse.duration.Format = 'hh:mm:ss';
%%


idxpat       = strcmp(dbUse.patient,'RCS02');
idxtime = isbetween(dbUse.timeStart,datetime('01-Jan-2021 10:37:08','TimeZone','America/Los_Angeles'),...
    datetime('01-Mar-2021 10:37:08','TimeZone','America/Los_Angeles'));
idxconcat = idxpat & idxtime;
patDBtoConcat = dbUse(idxconcat,:);
sum(patDBtoConcat.duration)

%%
eventRawOut = table(); 
for i = 1:size(patDBtoConcat,1)
    [pn,fn] = fileparts(patDBtoConcat.deviceSettingsFn{i})
    [eventLogTable] = createEventLogTable(pn);
    eventRawOut = [eventRawOut; eventLogTable];
end
%%
eventOut = eventRawOut;
idxKeep = ~(strcmp(eventOut.EventType,'CTMLeftBatteryLevel') | ...
    strcmp(eventOut.EventType,'CTMRightBatteryLevel') | ...
    strcmp(eventOut.EventType,'INSRightBatteryLevel') | ...
    strcmp(eventOut.EventType,'INSLeftBatteryLevel'));
idxInfo = (cellfun(@(x) any(strfind(x,'PatientID')),eventOut.EventType(:)) | ...
    cellfun(@(x) any(strfind(x,'LeadLocation')),eventOut.EventType(:)) | ...
    cellfun(@(x) any(strfind(x,'ImplantedLeads')),eventOut.EventType(:)) | ...
    cellfun(@(x) any(strfind(x,'InsImplantLocation')),eventOut.EventType(:)));



% for rest of analyis get rid of that
idxKeep = idxKeep & ~idxInfo;
eventOut = eventOut(idxKeep,:);

if ~isempty(eventOut)
    packtRxTimes    =  datetime(eventOut.UnixOnsetTime/1000,...
        'ConvertFrom','posixTime','Format','dd-MMM-yyyy HH:mm:ss.SSS');
    localTime = packtRxTimes;
    eventOut.localTime = localTime;
    
    eventPrint = eventOut(:,{'localTime','EventType','EventSubType'});
    eventPrint
end



end