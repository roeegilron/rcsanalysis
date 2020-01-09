function print_stim_and_sense_settings_in_folders(dirname)
% this will print the channels recorded from in each file 
databasefile = fullfile(dirname,'database.mat'); 
if exist(databasefile,'file') 
    load(databasefile);
else
    MAIN_report_data_in_folder(dirname); 
end
if iscell(tblout.startTime)
    idxkeep = cellfun(@(x) ~isempty(x),tblout.startTime);
    datTab = tblout(idxkeep,:);
elseif isdatetime( tblout.startTime);
    datTab = tblout;
end

x = 2;