function agregate_patient_databases()
%% agregate all stim and sense tables acorss subjects 
rootdir_orig = '/Users/roee/Starr Lab Dropbox/';
rootdir_dest = fullfile(rootdir_orig,'RC+S Patient Un-Synced Data');
ff = 'stim_and_sense_settings_table.mat';
databasefiles = findFilesBVQX(rootdir_dest,ff);

for d = 1:length(databasefiles)
    load(databasefiles{d},'sense_stim_table');
    if d == 1 
        % XXX need to fix an issue with some sense_stim table 
        % not updating with most current code 
        % this code exctract info about adaptive state 
        % and also gives better esimtate of stim state used in 
        % majoirty of file, like when running swithc on adaptive 
        if size(sense_stim_table,2) == 22 
            sense_stim_database = sense_stim_table;
        else
            for i = 1:size(sense_stim_table,1)
                sense_stim_table.active_recharge(i) = NaN;
                sense_stim_table.stimTable{i} = table();
            end
            sense_stim_database = sense_stim_table;
        end
    else
        if size(sense_stim_table,2) == 22
            sense_stim_table = sense_stim_table;
        else
            for i = 1:size(sense_stim_table,1)
                sense_stim_table.active_recharge(i) = NaN;
                sense_stim_table.stimTable{i} = table();
            end
        end
        % for cases in which time zone is empty
        sense_stim_table.rectime.TimeZone = sense_stim_database.rectime.TimeZone;
        sense_stim_table.startTime.TimeZone = sense_stim_database.startTime.TimeZone;
        sense_stim_table.endTime.TimeZone = sense_stim_database.endTime.TimeZone;
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