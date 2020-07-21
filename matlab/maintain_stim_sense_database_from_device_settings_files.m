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
start = tic();
cnt = 1; 
bdfile = 1; 
for a = 1:length(allDeviceSettingsOut)
    try
        deviceSettingsFn = allDeviceSettingsOut{a};
        masterTableOut(cnt,:) = get_meta_data_from_device_settings_file(deviceSettingsFn);
        cnt = cnt + 1;
    catch
        badFilesOut{bdfile} = deviceSettingsFn;
        bdfile = bdfile + 1; 
    end
end
fnsave = fullfile(database_dir,'database_raw_from_device_settings.mat');
save(fnsave,'*Out');
timeTook = seconds(toc(start));
timeTook.Format = 'hh:mm:ss';
fprintf('finished all data base in %s\n',timeTook);
end
