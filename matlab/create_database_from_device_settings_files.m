function create_database_from_device_settings_files(varargin)
%% This function craetes a database from RC+S data
% Input: if empty, loads default input assuming dropbox folder is snyced to
% computer (unsynced data) 
%        if dirname is given, it creates a "database" folder in "dirname"
%        (string) and loads existing database, and then fixes it, or
%        creates a new database from scratch 
fprintf('the time is:\n%s\n',datetime('now'));
close all; clc; 
warning('off','MATLAB:table:RowsAddedExistingVars');
startTic = tic;

if isempty(varargin)
    dropboxFolder = findFilesBVQX('/Users','Starr Lab Dropbox',struct('dirs',1,'depth',2));
    if length(dropboxFolder) == 1
        dirname  = fullfile(dropboxFolder{1}, 'RC+S Patient Un-Synced Data');
    else
        error('can not find dropbox folder, you may be on a pc');
    end
elseif length(varargin) == 1 
    dirname = varargin{1};
else
    error('too many input variable , max of one input - string of file folder');
end


%% to avoid recreating the whole database each time new data is added, load the old table, and only add new data:
% find dropbox folders:
% % XXX  this will only work on a Mac....
start = tic;
rootdir = dirname;
allDeviceSettingsOut = findFilesBVQX(rootdir,'DeviceSettings.json');
fprintf('took %.2f to find all device settings\n',toc(start));

start = tic;
% load or create database from screatch 
database_dir = fullfile(dirname,'database');
if ~exist(database_dir,'dir')
    % create a database dir 
    mkdir(database_dir); 
end

% check if a device settings database exists 
fnload = fullfile(database_dir,'database_from_device_settings.mat');
if exist(fnload,'file')
    load(fnload,'masterTableOut');
    fprintf('took %.2f to load device settings database\n',toc(start));
    params.reloadDataBaseFromScratch = 0; 
else
    % if device settings database doesn't exist, need to reload it from
    % scratch 
    params.reloadDataBaseFromScratch = 1; 
end



%% 
%% find all the device settings files 


%% loop on device settings and get all the meta data from each session 
if ~params.reloadDataBaseFromScratch 
    % don't reload database from scratch 
    fileMissingFromDatabase = setdiff(allDeviceSettingsOut,masterTableOut.deviceSettingsFn);
    allDeviceSettingsOut = fileMissingFromDatabase; 
    start = tic();
    cnt = size(masterTableOut,1)+1; 
    bdfile = 1;

else
    masterTableOut = table();
    start = tic();
    cnt = 1;
    bdfile = 1;
end

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


if ~exist(database_dir,'dir')
    mkdir(database_dir);
end
masterTableLightOut = masterTableOut(:,{'patient','side','area','diagnosis','timeStart','timeEnd','duration','detectionStreaming',...
    'powerStreaming','timeDomainStreaming','deviceSettingsFn','recordedWithScbs',...
    'recordedWithResearchApp','chan1','chan2','chan3','chan4',...
    'stimulation_on','electrodes','amplitude_mA','rate_Hz'});
fnsave = fullfile(database_dir,'database_from_device_settings.mat');
save(fnsave,'*Out');
writetable(masterTableLightOut,fullfile(database_dir,'database_from_device_settings.csv'));

timeTook = seconds(toc(startTic));
timeTook.Format = 'hh:mm:ss';
fprintf('finished all data base in %s\n',timeTook);
fprintf('finished job and time is:\n%s\n',datetime('now'))
end
