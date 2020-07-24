function metaData = get_meta_data_from_device_settings_file(deviceSettingsFn)
% this functions gets some meta data from a device settings file 
% it depends on having other files that it will also attempt to open in the
% same directory as the device settings file 

metaData = table();
%% set default values 
metaData.deviceId{1}                    = 'NA';
metaData.patient{1}                     = 'NA';
metaData.side{1}                        = 'NA';
metaData.area{1}                        = 'NA';
metaData.diagnosis{1}                   = 'NA';
metaData.timeStart(1)                   = NaT;
metaData.timeStart.TimeZone             = 'America/Los_Angeles';
metaData.timeEnd(1)                     = NaT;
metaData.timeEnd.TimeZone               = 'America/Los_Angeles';
metaData.duration(1)                    = seconds(0); 
metaData.senseSettings{1}               = struct();
metaData.stimStatus{1}                  = struct();
metaData.stimState{1}                   = struct();
metaData.fftTable{1}                    = struct();
metaData.powerTable{1}                  = struct();
metaData.adaptiveSettings{1}            = struct();
metaData.detectionStreaming(1)          = NaN;
metaData.powerStreaming(1)              = NaN;
metaData.fftStreaming(1)                = NaN;
metaData.timeDomainStreaming(1)         = NaN;
metaData.accelerometryStreaming(1)      = NaN;

% get session name 
idxSession = strfind(lower(deviceSettingsFn),'session');
metaData.session{1}                     = deviceSettingsFn( idxSession: idxSession + 19);
% find out if recorded with SCBS or clinician application 
if any(strfind(deviceSettingsFn,'SummitContinuousBilateralStreaming'));
metaData.recordedWithScbs(1)            = 1; 
metaData.recordedWithResearchApp(1)     = 0; 
else
metaData.recordedWithScbs(1)            = 0; 
metaData.recordedWithResearchApp(1)     = 1; 
end


%% attempt to get actual values 
% get the dirname to load other files that have meta data 
[dirname,~] = fileparts(deviceSettingsFn);

% get basic meta data 
try
    masterDataId                            = get_device_id_return_meta_data(deviceSettingsFn);
    metaData.deviceId{1}                    = masterDataId.deviceId{1};
    metaData.patient{1}                     = masterDataId.patient{1};
    metaData.side{1}                        = masterDataId.side{1};
    metaData.area{1}                        = masterDataId.area{1};
    metaData.diagnosis{1}                   = masterDataId.diagnosis{1};
    metaData.timeStart(1)                   = masterDataId.timeStart(1);
    metaData.timeEnd(1)                     = masterDataId.timeEnd(1);
    metaData.duration(1)                    = masterDataId.duration(1);
catch 
end
% more advances meta data
try
    % load device settings
    DeviceSettings = jsondecode(fixMalformedJson(fileread(deviceSettingsFn),'DeviceSettings'));
    % fix issues with device settings sometiems being a cell array and
    % sometimes not
    
    if isstruct(DeviceSettings)
        DeviceSettings = {DeviceSettings};
    end
    
    % load device settings from the first structure of device settings 
    [senseSettings,stimState,stimStatus,fftTable,powerTable,adaptiveSettings]  = ...
        loadDeviceSettingsFromFirstInitialStructure(DeviceSettings);
    metaData.senseSettings{1}               = senseSettings;
    metaData.stimStatus{1}                  = stimStatus;
    metaData.stimState{1}                   = stimState;
    metaData.fftTable{1}                    = fftTable;
    metaData.powerTable{1}                  = powerTable;
    metaData.adaptiveSettings{1}            = adaptiveSettings;
    
    % for each subsequent structure, need to write code that will estimate
    % all settings changes within the file and update the total time for
    % each settings 
%     getSenseSettingsInDeviceSettingsStructure(DeviceSettings,metaData.senseSettings{1}); 
catch
end

% check if files have data in them by opening 
% each text file and looking for a unix time stamp at the start 
% and at the end of the files 
fileNamesCheck = {'AdaptiveLog','RawDataTD','RawDataPower','RawDataFFT','RawDataAccel'};
fileNamesTable = {'detectionStreaming','timeDomainStreaming','powerStreaming','fftStreaming','accelerometryStreaming'};
for fn = 1:length(fileNamesCheck)
    try
        % first set defaul value
        metaData.(fileNamesTable{fn})(1)           = NaN;
        fnUse = sprintf('%s.json',fileNamesCheck{fn});
        fnCheck = fullfile(dirname,fnUse);
        timeReport = report_start_end_time_td_file_rcs(fnCheck);
        if timeReport.duration > seconds(0)
            metaData.(fileNamesTable{fn})(1)       = 1;
        else
            metaData.(fileNamesTable{fn})(1)       = 0;
        end
    catch
    end
end

end