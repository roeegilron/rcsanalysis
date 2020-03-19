function stim_and_sense_picker_RCS()
%% this function allows you to see unique sense 
%% and stim combinations in an RC+S session folder and choose common
%% data sets 

%% this function assumes you have opened all the files 
%% using:
%% MAIN_load_rcsdata_from_folders.m 

%% set params 
params.rootdir = '/Volumes/RCS_DATA/RCS04/Home_recordL'; % location of session foldres 
params.mindur  = 2; % mininmum file duration in minutes 
%% 

%% load report folder 
dtbsfile = fullfile(params.rootdir,'database.mat');
if exist(dtbsfile,'file')
    load(dtbsfile);
else
    MAIN_report_data_in_folder(dtbsfile); 
    load(dtbsfile);
end
%% 

%% load device settings 
idxkeep = cellfun(@(x) minutes(x) > params.mindur,tblout.duration);
tblout = tblout(idxkeep,:); 
for t = 1:size(tblout,1)
    [pn,fn,ext] = fileparts(tblout.tdfile{t});
    deviceSettingsFile = fullfile(pn,'DeviceSettings.mat'); 
    load(deviceSettingsFile);
    outRec
    fprintf('\n');
end
%% 

end