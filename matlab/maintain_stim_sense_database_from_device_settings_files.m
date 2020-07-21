function maintain_stim_sense_database_from_device_settings_files()
%% find all the device settings files 
close all; clear all; clc; 
warning('off','MATLAB:table:RowsAddedExistingVars');

start = tic; 
rootdir = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/'; 
database_dir = fullfile(rootdir,'database');
allDeviceSettingsOut = findFilesBVQX(rootdir,'DeviceSettings.json');
fprintf('took %.2f to find all device settings\n',toc(start));

%% loop on device settings and get all the meta data from each session 
masterTableOut = table();
deviceSettingsOut = struct();
stimStatusOut = struct();
stimStateOut = struct();
fftTableOut = struct();
powerTableOut = struct();
adaptiveSettingsOut = struct();

cnt = 1; 
bdfile = 1; 
for a = 1:length(allDeviceSettingsOut)
    try
        deviceSettingsFn = allDeviceSettingsOut{a};
        masterTableOut(cnt,:) = get_device_id_return_meta_data(deviceSettingsFn);
        [dirname,~] = fileparts(deviceSettingsFn);
        [deviceSettings,stimStatus,stimState,fftTable,powerTable] = loadDeviceSettingsForMontage(deviceSettingsFn);
        deviceSettingsOut(cnt).deviceSettings = deviceSettings;
        stimStatusOut(cnt).stimStatus = stimStatus;
        stimStateOut(cnt).stimState = stimState;
        fftTableOut(cnt).fftTable = fftTable;
        powerTableOut(cnt).powerTable = powerTable;
        adaptiveSettingsOut(cnt).adaptiveSettings =  loadAdaptiveSettings(deviceSettingsFn);
        % check if detection is streaming
        fnAdaptive = fullfile(dirname,'AdaptiveLog.json');
        timeReport = report_start_end_time_td_file_rcs(fnAdaptive);
        if timeReport.duration > seconds(0)
            detectionStreamingOut(cnt) = 1;
        else
            detectionStreamingOut(cnt) = 0;
        end
        % check if td is streaming
        fnAdaptive = fullfile(dirname,'RawDataTD.json');
        timeReport = report_start_end_time_td_file_rcs(fnAdaptive);
         if timeReport.duration > seconds(0)
            timeDomainStreamingOut(cnt) = 1;
        else
            timeDomainStreamingOut(cnt) = 0;
        end
        % check if power is streaming
        fnAdaptive = fullfile(dirname,'RawDataPower.json');
        timeReport = report_start_end_time_td_file_rcs(fnAdaptive);
        if timeReport.duration > seconds(0)
            powerStreamingOut(cnt) = 1;
        else
            powerStreamingOut(cnt) = 0;
        end
        % check if fft is streaming
        fnAdaptive = fullfile(dirname,'RawDataFFT.json');
        timeReport = report_start_end_time_td_file_rcs(fnAdaptive);
        if timeReport.duration > seconds(0)
            fftStreamingOut(cnt) = 1;
        else
            fftStreamingOut(cnt) = 0;
        end
        % check if acc is streaming
        fnAdaptive = fullfile(dirname,'RawDataAccel.json');
        timeReport = report_start_end_time_td_file_rcs(fnAdaptive);
        if timeReport.duration > seconds(0)
            accStreamingOut(cnt) = 1;
        else
            accStreamingOut(cnt) = 0;
        end
        cnt = cnt + 1;
    catch
        badFilesOut{bdfile} = deviceSettingsFn;
        bdfile = bdfile + 1; 
    end
end
fnsave = fullfile(database_dir,'database_raw_from_device_settings.mat');
save(fnsave,'*Out');
end
