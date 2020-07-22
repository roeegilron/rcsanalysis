function check_meta_data_files_that_are_not_opened_properly()
%% load data 
rootdir = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/'; 
database_dir = fullfile(rootdir,'database');
fnsave = fullfile(database_dir,'database_raw_from_device_settings.mat');
load(fnsave);
%%
idxCantOpen = strcmp(masterTableOut.deviceId,'NA');
problemDeviceSettings = allDeviceSettingsOut(idxCantOpen);
fprintf('%d/%d (%.2f%%) files for which meta not extracted properly\n',...
    sum(idxCantOpen),length(allDeviceSettingsOut),sum(idxCantOpen)/length(allDeviceSettingsOut));
for i = 1:length(problemDeviceSettings)
    metaData = get_meta_data_from_device_settings_file(problemDeviceSettings{i});
end
end