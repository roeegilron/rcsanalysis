function temp_reload_device_settings()
% load data
ds = '/Volumes/Samsung_T5/RCS02/RCS02_all_home_data_processed/data';
ff = findFilesBVQX(ds,'DeviceSettings.json');
for f = 1:length(ff)
    try
        loadDeviceSettings(ff{f});
        fprintf('finished file %d out of %d\n',f,length(ff));
    catch
    end
end

end