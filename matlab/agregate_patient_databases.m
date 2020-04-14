function agregate_patient_databases()
%% agregate all stim and sense tables acorss subjects 
rootdir_orig = '/Users/roee/Starr Lab Dropbox/';
rootdir_dest = fullfile(rootdir_orig,'RC+S Patient Un-Synced Data');
ff = 'stim_and_sense_settings_table.mat';
databasefiles = findFilesBVQX(rootdir_dest,ff);

for d = 1:length(databasefiles)
    load(databasefiles{d},'sense_stim_table');
    if d == 1 
        sense_stim_database = sense_stim_table;
    else
        sense_stim_database = [sense_stim_database; sense_stim_table];
    end
end
sense_stim_database = sortrows(sense_stim_database,{'patient','startTime'});
savefn = fullfile(rootdir_dest,'database', 'sense_stim_database.mat'); 
save(savefn,'sense_stim_database');
% write as csv as well 
savefn = fullfile(rootdir_dest,'database', 'sense_stim_database.csv'); 
writetable(sense_stim_database,savefn);
end