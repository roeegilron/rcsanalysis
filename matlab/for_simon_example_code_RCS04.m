function for_simon_example_code_RCS04()
%% loading database 
load('/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/sense_stim_database.mat'); 

idxanalyze  = strcmp(sense_stim_database.patient,'RCS04');

do = sense_stim_database(idxanalyze,:); 

sum(do.duration); 

search_dir = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/RCS04 Un-Synced Data'; 

for f = 1:size(do) 
    ff = findFilesBVQX(search_dir,do.sessname{f},struct('dirs',1)); 
    [outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerOut,adaptiveTable] =  MAIN_load_rcs_data_from_folder(ff{1});
    {outRec.tdData.chanFullStr}'
    do(f,:)
end
end