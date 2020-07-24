function check_meta_data_files_that_are_not_opened_properly()
%% load data 
clear all; close all; 
rootdir = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/'; 
database_dir = fullfile(rootdir,'database');
fnsave = fullfile(database_dir,'database_raw_from_device_settings.mat');
load(fnsave);

%%
%%

idxCantOpen = strcmp(masterTableOut.deviceId,'NA');
problemDeviceSettings = allDeviceSettingsOut(idxCantOpen);
okDeviceSettings = allDeviceSettingsOut(~idxCantOpen);
% report error in the database 
masterTable = table();
masterTable = masterTableOut(~idxCantOpen,:); 
masterTable.fileLocs = allDeviceSettingsOut(~idxCantOpen); 
idxDeviceIdExists = cellfun(@(x) any(strfind(x,'n')),masterTable.deviceId);
masterTable = masterTable(idxDeviceIdExists,:);

%%
fid = fopen(fullfile(database_dir,'database_integrity_checks.txt'),'w+');
fprintf(fid,'%d/%d (%.2f%%) files for which meta not extracted properly\n',...
    sum(idxCantOpen),length(allDeviceSettingsOut),sum(idxCantOpen)/length(allDeviceSettingsOut));
for f = 1:size(masterTable,1)
    idxRCS = strfind(masterTable.fileLocs{f},'RCS');
    if isempty(idxRCS)
        % its a benchtop 
        masterTable.FileLocPatient{f} = 'NA';
        masterTable.FileLocSide{f} = 'NA';
    else
        rawRCS = masterTable.fileLocs{f}(idxRCS(end):idxRCS(end)+5);
        masterTable.FileLocPatient{f} = rawRCS(1:end-1);
        masterTable.FileLocSide{f} = rawRCS(end);
    end
end
fprintf('\n\n');

idxWrongPatient = ~strcmp(masterTable.patient , masterTable.FileLocPatient);
fprintf(fid,'%d/%d (%.2f%%) files in the wrong patient location\n',...
    sum(idxWrongPatient),size(masterTable,1),sum(idxWrongPatient)/size(masterTable,1));
fprintf(fid,'\n\n');

fprintf(fid,'details re patient is currently in wrong patient file location:\n'); 
unqPatients = unique(masterTable.patient);
for u = 1:length(unqPatients)
    fprintf(fid, '\tpatient: %s\n',unqPatients{u});
    idxPatient = strcmp(masterTable.patient,unqPatients{u});
    masterTablePatient = masterTable(idxPatient,:);
    idxWrongPatient = ~strcmp(masterTablePatient.patient , masterTablePatient.FileLocPatient);
    fprintf(fid,'\t%d/%d (%.2f%%) files in the wrong patient location\n',...
        sum(idxWrongPatient),size(masterTablePatient,1),sum(idxWrongPatient)/size(masterTablePatient,1));
    fprintf(fid,'\n');
end

fprintf(fid,'\n\n');
fprintf('details re patient data is in the wrong side location:\n'); 
unqPatients = unique(masterTable.patient);
for u = 1:length(unqPatients)
    fprintf(fid,'patient: %s\n',unqPatients{u});
    idxPatient = strcmp(masterTable.patient,unqPatients{u});
    masterTablePatient = masterTable(idxPatient,:);
    idxWrongPatient = ~strcmp(masterTablePatient.side , masterTablePatient.FileLocSide);
    fprintf(fid,'\t%d/%d (%.2f%%) files in the wrong side location\n',...
        sum(idxWrongPatient),size(masterTablePatient,1),sum(idxWrongPatient)/size(masterTablePatient,1));
    fprintf(fid,'\n');
end
fprintf(fid,'\n\n');


fprintf(fid,'\n\n');
fprintf('details re initial structure not extracted:\n'); 
unqPatients = unique(masterTable.patient);
for u = 1:length(unqPatients)
    fprintf(fid,'patient: %s\n',unqPatients{u});
    idxPatient = strcmp(masterTable.patient,unqPatients{u});
    masterTablePatient = masterTable(idxPatient,:);
    idxDataExtractedProperly = cellfun(@(x) istable(x),masterTablePatient.stimState); 
    
    fprintf(fid,'\t%d/%d (%.2f%%) of device settings structure exracted properly \n',...
        sum(idxDataExtractedProperly),size(masterTablePatient,1),sum(idxDataExtractedProperly)/size(masterTablePatient,1));
    fprintf(fid,'\n');
end
fprintf(fid,'\n\n');
clc;
fclose(fid);
dbtype(fullfile(database_dir,'database_integrity_checks.txt'));
%%




clc;
fclose(fid);
dbtype(fullfile(database_dir,'database_integrity_checks.txt'));




return ;

for i = 1:length(problemDeviceSettings)
    metaData = get_meta_data_from_device_settings_file(problemDeviceSettings{i});
end


%%
% try to locate some problems files 
idxPatient = strcmp(masterTable.patient,'RCS08');
masterTablePatient = masterTable(idxPatient,:);
idxDataExtractedProperly = cellfun(@(x) istable(x),masterTablePatient.stimState);
% what percent of RCS08 was recorded before stimaultiion 
masterTablePatient.duration.Format = 'hh:mm:ss';
db  = masterTablePatient(idxDataExtractedProperly,:);
idxUse = ~cellfun(@(x) x.stimulation_on,db.stimStatus) & ... 
                  db.timeDomainStreaming & ... 
                  db.recordedWithScbs & ... 
                  strcmp(db.side,'L');
sum(db.duration(idxUse))
%%

meta = get_meta_data_from_device_settings_file(masterTableProblems.fileLocs{end});




end