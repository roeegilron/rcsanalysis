function MAIN_plot_montage_from_events()
%% load data
% montage dir 
outdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS_test/dbs_montage_test_randy_new_code/Session1556665237861/DeviceNPC700239H'; 
[outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerTable] =  MAIN_load_rcs_data_from_folder(outdir); 
end