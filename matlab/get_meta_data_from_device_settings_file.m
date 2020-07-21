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
metaData.deviceSettings{1}              = struct();
metaData.stimStatus{1}                  = struct();
metaData.deviceSettings{1}              = struct();
metaData.stimState{1}                   = struct();
metaData.fftTable{1}                    = struct();
metaData.powerTable{1}                  = struct();
metaData.adaptiveSettings{1}            = struct();
metaData.detectionStreaming(1)          = NaN;
metaData.powerStreaming(1)              = NaN;
metaData.fftStreaming(1)                = NaN;
metaData.timeDomainStreaming(1)         = NaN;
metaData.accelerometryStreaming(1)      = NaN;

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
[deviceSettings,stimStatus,stimState,fftTable,powerTable] = loadDeviceSettingsForMontage(deviceSettingsFn);
metaData.deviceSettings{1}              = deviceSettings;
metaData.stimStatus{1}                  = stimStatus;
metaData.stimState{1}                   = stimState;
metaData.fftTable{1}                    = fftTable;
metaData.powerTable{1}                  = powerTable;
catch 
end

% get some adaptive settings
try
    metaData.adaptiveSettings{1}            = loadAdaptiveSettings(deviceSettingsFn);
    % get some logical values to see whihh files have data in them.
    fnAdaptive = fullfile(dirname,'AdaptiveLog.json');
    timeReport = report_start_end_time_td_file_rcs(fnAdaptive);
    if timeReport.duration > seconds(0)
        metaData.detectionStreaming(1)      = 1;
    else
        metaData.detectionStreaming(1)      = 0;
    end
catch
end
% check if td is streaming
try
    fnAdaptive = fullfile(dirname,'RawDataTD.json');
    timeReport = report_start_end_time_td_file_rcs(fnAdaptive);
    if timeReport.duration > seconds(0)
        metaData.timeDomainStreaming(1)     = 1;
    else
        metaData.timeDomainStreaming(1)     = 0;
    end
catch
end
% check if power is streaming
try
    fnAdaptive = fullfile(dirname,'RawDataPower.json');
    timeReport = report_start_end_time_td_file_rcs(fnAdaptive);
    if timeReport.duration > seconds(0)
        metaData.powerStreaming(1)          = 1;
    else
        metaData.powerStreaming(1)          = 0;
    end
catch
end
% check if fft is streaming
try
    fnAdaptive = fullfile(dirname,'RawDataFFT.json');
    timeReport = report_start_end_time_td_file_rcs(fnAdaptive);
    if timeReport.duration > seconds(0)
        metaData.fftStreaming(1)            = 1;
    else
        metaData.fftStreaming(1)            = 0;
    end
catch
end
% check if acc is streaming
try
    metaData.accelerometryStreaming(1)      = NaN;
    timeReport = report_start_end_time_td_file_rcs(fnAdaptive);
    if timeReport.duration > seconds(0)
        metaData.accelerometryStreaming(1)  = 1;
    else
        metaData.accelerometryStreaming(1)  = 0;
    end
catch
end

end