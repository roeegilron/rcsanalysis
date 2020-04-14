function print_database_stats()
rootdir_orig = '/Users/roee/Starr Lab Dropbox/';
rootdir_dest = fullfile(rootdir_orig,'RC+S Patient Un-Synced Data');

savefn = fullfile(rootdir_dest,'database', 'sense_stim_database.mat'); 
load(savefn,'sense_stim_database');

% print the most common stim settings to a notebook 
uniquepatients = unique(sense_stim_database.patient);
uniquesides    = unique(sense_stim_database.side); 
firstcase = 1; 
for p = 1:length(uniquepatients)
    for s = 1:length(uniquesides)
        % get the 5 most recent session on stim 
        idxuse = strcmp(sense_stim_database.patient,uniquepatients{p}) & ... 
            strcmp(sense_stim_database.side,uniquesides{s} ) & ...
            sense_stim_database.stimulation_on;
        if sum(idxuse) > 6
            tblpatient = sense_stim_database(idxuse,:);
            tblpatient = sortrows(tblpatient,{'startTime'});
            tblpatient =  tblpatient(end-4:end,:);
            if firstcase
                firstcase = 0;
                tblout = tblpatient;
            else
                tblout = [tblout;tblpatient];
            end
            clear tblpatient
        end
    end
end
savefn = fullfile(rootdir_dest,'database', 'most_recent_stim.csv'); 
writetable(tblout,savefn);

end