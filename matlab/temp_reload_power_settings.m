function temp_reload_power_settings()
% load data
ds = '/Volumes/Samsung_T5/RCS02/RCS02_all_home_data_processed/data';
ff = findFilesBVQX(ds,'RawDataPower.json');
for f = 1:length(ff)
    try
        [powerTable, powerBandInHz] = loadPowerData(ff{f});
        [dirname,fn] = fileparts(ff{f});
        save(fullfile(dirname,['RawDataPower' '.mat']),'powerTable','powerBandInHz');
        fprintf('finished file %d out of %d\n',f,length(ff));
    catch
    end
end

end