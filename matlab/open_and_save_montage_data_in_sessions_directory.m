function open_and_save_montage_data_in_sessions_directory(dirname)
%% this file opens and saves montage data in a session direcotry

if exist( fullfile(dirname,'allEvents.mat'), 'file')
    load(fullfile(dirname,'allEvents.mat'))
else
    concantenate_event_data(dirname);
    load(fullfile(dirname,'allEvents.mat'))
end

%% Find all the montage directories in this folder
eventData = allEvents.eventOut;
montageEvents = eventData(cellfun(@(x) any(strfind(x,': config')),eventData.EventType) , :);
sessionIds    = unique(montageEvents.sessionid);
if isempty(sessionIds) % new way of doing montages 
    eventData = allEvents.eventOut;
    montageEvents = eventData(cellfun(@(x) any(strfind(x,'Montage Sequence Begin')),eventData.EventType) , :);
    sessionIds    = unique(montageEvents.sessionid);
end

%% loop on each montage session and save the data in a .mat file
clc;
for s = 1:length(sessionIds)
    
    fsessionDir = findFilesBVQX(dirname,sprintf('*%s*',sessionIds{s}),struct('dirs',1));
    fdeviceDir  = findFilesBVQX(fsessionDir{1},sprintf('Device*',sessionIds{s}),struct('dirs',1));
    deviceSettingsFn = fullfile(fdeviceDir{1},'DeviceSettings.json');
    deviceSettings = loadDeviceSettingsForMontage(deviceSettingsFn);
    fileload = fullfile(fdeviceDir{1},'EventLog.json');
    eventTable = loadEventLog(fileload);
    
    % get and save data
    [montageData, montageDataRaw] = extract_montage_data(fdeviceDir{1});
    if ~isempty(montageData)
        savename    = fullfile(fdeviceDir{1},'rawMontageData.mat');
        save(savename,'montageData','montageDataRaw');
    end
    
    
%     % print out montages for quality control
%     fprintf('time %s\n',eventTable.sessionTime(1))
%     fprintf('_________\n');
%     fprintf('_________\n');
%     for i = 1:length(outRec)
%         cellfun(@(x) fprintf('%0.2d %s\n',i,x),{outRec(i).tdData.chanFullStr}')
%         fprintf('_________\n');
%     end
%     fprintf('_________\n');
%     fprintf('_________\n');
%     fprintf('\n');
%     fprintf('\n');
end
%%

end
