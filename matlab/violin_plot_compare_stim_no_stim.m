function violin_plot_compare_stim_no_stim()
%% this function relies on: 
% 1. readme_large_amounts_of_data_function
% 2. running: 
% A. MAIN_report_data_in_folder % creates a database file you need
% B. MAIN_load_rcsdata_from_folders % opens al the data. make sure line 
% C. print_stim_and_sense_settings_in_folders % create a stim database folder

%% set params 
params.rootdir = '/Volumes/RCS_DATA/RCS03/raw_data_push_jan_2020/SCBS/RCS03L';
%% 

%% load data base file 
stim_database_fn = fullfile(params.rootdir,'stim_and_sense_settings_table.mat');
load(stim_database_fn); 
%% 

%% data picker: 
idxkeep = ...
    cellfun(@(x) any(strfind(x,'+3-2 lpf1-450Hz lpf2-1700Hz')),sense_stim_table.chan2) & ... % only use contacts 2-3 
    sense_stim_table.duration > minutes(2) & ... % only choose files over 2 minutes 
    
    
sense_stim_table(idxkeep,:)
%% 

end