function create_database_from_device_settings_files(dirname)
%% find all the device settings files 
close all; clc; 
warning('off','MATLAB:table:RowsAddedExistingVars');

start = tic; 
rootdir = dirname;
database_dir = fullfile(dirname,'database');
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
        fclose('all');
    catch
        badFilesOut{bdfile} = dseviceSettingsFn;
        bdfile = bdfile + 1; 
        fclose('all');
    end
end
% extracct out some inner commonly use parameters of the table 
for ss = 1:size(masterTableOut,1)
    if istable(masterTableOut.senseSettings{ss})
        masterTableOut.chan1{ss} = masterTableOut.senseSettings{ss}.chan1{1};
        masterTableOut.chan2{ss} = masterTableOut.senseSettings{ss}.chan2{1};
        masterTableOut.chan3{ss} = masterTableOut.senseSettings{ss}.chan3{1};
        masterTableOut.chan4{ss} = masterTableOut.senseSettings{ss}.chan4{1};
    else
        masterTableOut.chan1{ss} = 'NA';
        masterTableOut.chan2{ss} = 'NA';
        masterTableOut.chan3{ss} = 'NA';
        masterTableOut.chan4{ss} = 'NA';
    end
    if istable(masterTableOut.stimStatus{ss})
        masterTableOut.stimulation_on(ss) = masterTableOut.stimStatus{ss}.stimulation_on(1);
        masterTableOut.electrodes{ss} = masterTableOut.stimStatus{ss}.electrodes{1};
        masterTableOut.amplitude_mA(ss) = masterTableOut.stimStatus{ss}.amplitude_mA(1);
        masterTableOut.rate_Hz(ss) = masterTableOut.stimStatus{ss}.rate_Hz(1);
    else
        masterTableOut.stimulation_on(ss) = NaN;
        masterTableOut.electrodes{ss} = 'NA';
        masterTableOut.amplitude_mA(ss) = NaN;
        masterTableOut.rate_Hz(ss) = NaN;
    end
end

if ~exist(database_dir,'dir')
    mkdir(database_dir);
end
fnsave = fullfile(database_dir,'database_from_device_settings.mat');
save(fnsave,'*Out');
timeTook = seconds(toc(start));
timeTook.Format = 'hh:mm:ss';
fprintf('finished all data base in %s\n',timeTook);
end
