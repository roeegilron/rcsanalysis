% cheat sheets directions for analyzing large amounts of data 

% the primary role of these function is to convert a directory of 
% session with RC+S .json data into .mat files (each .json gets converted
% to a .mat). 
% the secondary role is to create a databse file that will allow further
% drill down - for example seprating stim/ no stim data 


%% data converstion and databasing functions 
MAIN_report_data_in_folder 
% creates a database file you need 
% this function runs very quickly and will enter each TD.json file 
% and compute the the duration of each file 
% it will fail to find data if time domain data was not streamed (so for
% exmpale just power domain data. 


MAIN_load_rcsdata_from_folders 
% this function converts all the .json containedin each session directory
% to .json files 
% note that this function relies on the database folder above. If you have
% added new data, you will need to delete the database.mat folder created
% in the top level session directryo and rerun the load function. 
% note that this function will only convert files that have not already
% been converted 

print_stim_and_sense_settings_in_folders
% this function will create a .mat file and text file 
% 1) 'stim_and_sense_settings_table.mat'
% 2) 'stimAndDeviceSettingsLog.txt' 
% these will can be used to parse data for further analysis 
% stim and sense settings has information about sense and stim settings 
% so that "apples to apples" comaprison is possible from the data 
%
% This function will also plot a sense_stim_text_metrics.txt text file that
% will have infromation about all unique sense and stim combinations and
% their datasize 
% sense_stim_database_operations


concantenate_event_data
% this function is very likely to error out, be warned. 
% it allows you to concatenate all event data from event jsons 
% so that you can do database searches (for example, find all montage
% files) 
% see below some data analysis functions that use this 



%% data analysis functions 


MAIN_run_process_RCS_data_in_parallel()
% this function splits dat into 30 second chunks 
% and reshape the data into this setting (with some overlap depending on
% settings) 
% this rehsaping is mostly so that PSD and such can be caluclated using
% vectorized code which greatly aaccelrates proccessing time for many time
% domai based analysis 
% processes data into 30 second chunks 
analyzeContinouseDataFromSCS % call this function inside to analyze TD data 
analyzeContinouseDataFromSCS_ACC_actigraphy % call this function inside to analyze actigrpahy data 


concatenate_and_plot_TD_data_SCS 
% this function will also error out for most users since it relies on a
% consistent data structure across all data in your folder. So, if for
% example some of your channels contain missing data or are used in
% different smapling rate all the vectorized code won't work since it's
% trying to concatenat 30 seconds of data from 500Hz and 250Hz for example
% (which won't neatly fit in a matrix). 
% most of this type of analysis (for example, comparing stim off / stim on
% data has been migrated to the function below (violin). 
% does a few things:
% 1. processed all the fft data creating an fft from each data chunk  
% 2. concatenates all the data for easy analysis and lines eveythign up with PKG 

% alternate methods to PSD:

create_psd_results_for_stim_on_off_comparison 
% after MAIN_run_process_RCS_data_in_parallel this function will take
% output from print_stim_and_sense_settings_in_folders and create custom
% data sets sets of PSD results for furhter analysis. For example: 

plot_effects_of_chronic_stim
% plots violin plots of chronic stim from psd results create with above
% function 

plot_compare_montage_data_from_saved_montage_files
% compare montage files within a session directory 

violin_plot_compare_stim_no_stim
% this function allows you to compare stim and no stim data in a violin
% plot. 


compute_cv_beta_home_data()

plot_alligned_data_in_folder
% to plot embedded adaptive data 

plot_embedded_adaptive_data_multiple_folders
% plot embedded adaptive data from multiple folders sorted by day 



