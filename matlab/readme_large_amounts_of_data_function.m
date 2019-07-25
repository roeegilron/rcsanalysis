% direction re analyzing large amount of data

MAIN_report_data_in_folder % creates a database file you need

MAIN_load_rcsdata_from_folders % opens al the data. make sure line 
% MAIN_report_data_in_folder(dirname);  - this line should be uncommented
% on first use 

MAIN_run_process_RCS_data_in_parallel() % processes data into 30 second chunks 
analyzeContinouseDataFromSCS % call this function inside 

concatenate_and_plot_TD_data_SCS % does a few things:
% 1. processed all the fft data creating an fft from each data chunk  
% 2. concatenates all the data for easy analysis and lines eveythign up with PKG 


