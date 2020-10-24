function write_session_fodler_results_to_csv(dirname)
% for witney mostly to work in python 
[outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerOut,adaptiveTable] =  MAIN_load_rcs_data_from_folder(dirname);
%% time domain
filewrite = fullfile(dirname,'TimeDomain.csv');
writetable(outdatcomplete,filewrite);

filewrite = fullfile(dirname,'eventTable.csv');
writetable(eventTable,filewrite);

filewrite = fullfile(dirname,'powerTable.csv');
writetable(powerOut.powerTable,filewrite);

filewrite = fullfile(dirname,'adaptiveTable.csv');
writetable(adaptiveTable,filewrite);

end