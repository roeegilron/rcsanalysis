function MAIN_maintain_database()
%% function to maintain RC+S database in dropbox 
% this function moves files from sycned to unsycned folders 
% and maintains a constantly updated database 

%% move files from synced to unsycned folders 
move_and_delete_folders();
move_and_delete_folders(); % second call is to delete folders that are empty 

%% get stim and sense database 
% maintain_stim_sense_database();

%% new way to matinain a database - replaces previous functions - needs to completly replace it 
dirname  = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/';
create_database_from_device_settings_files(dirname)

%% print reports using the new device settings file method 
print_report_from_device_settings_database_file_per_patient

%% convert all .json files to .mat files
convert_all_files_from_mat_into_json();

%% agregate stim and sense database for easy viewing and query 
agregate_patient_databases()

%% chop up data in 10 min chunk 
process_data_into_10_minute_chunks();

%% print some basic stats about the database 
print_database_stats();

%% plot some basic states 
plot_database_figures()

%% plot impedence values 
plot_impedence_values()

%% plot embededdat 
plot_all_embedded_adaptive_from_database()



end
