function check_database_for_error_against_deviceid()
%% load database
close all; clear all; clc;
dirSave = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database';
load(fullfile(dirSave, 'deviceIdMasterList.mat'),'masterTable'); 
load(fullfile(dirSave,'sense_stim_database.mat'));
%%

for m = 1:size(masterTable)
    idxuse = cellfun(@(x) any(strfind(x,masterTable.deviceId{m})),lower(sense_stim_database.device));
    db = sense_stim_database(idxuse,:);
    fprintf('master device:\t%s\n',masterTable.deviceId{m});
    fprintf('master patient:\t%s\n',masterTable.patient{m});
    fprintf('master side:\t%s\n',masterTable.side{m});
    [unqPatients, idx, idx2] = unique(db.patient);
    for u = 1:length(unqPatients)
        [~, idx, idx2] = unique(db.patient);
        fprintf('database patient:\t%s (%d)\n',unqPatients{u},sum(idx2));
    end
    [unqSides, idx, idx2] = unique(db.side);
      for u = 1:length(unqSides)
        [~, idx, idx2] = unique(db.side);
        fprintf('database patient:\t%s (%d)\n',unqSides{u},sum(idx2));
    end
    fprintf('________\n\n');
end
end