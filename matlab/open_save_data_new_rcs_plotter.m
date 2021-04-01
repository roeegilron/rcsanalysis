function open_save_data_new_rcs_plotter()
%% data selection:
%% load the database
clear all; clc; close all;
dropboxdir = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database';
reportsDir = fullfile(dropboxdir,'reports');
databaseFile = fullfile(dropboxdir,'database_from_device_settings.mat');
load(databaseFile);
idxkeep  = cellfun(@(x) istable(x),masterTableOut.stimStatus) & logical(masterTableOut.recordedWithScbs);
dbUse    = masterTableOut(idxkeep,:);
dbUse.duration.Format = 'hh:mm:ss';

%% RCS02 L

% off stim
outputfolder = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/processed_data';
idxpat       = strcmp(dbUse.patient,'RCS02');
idxside      = strcmp(dbUse.side,'L');
idxsense     = strcmp(dbUse.chan1,'+2-0 lpf1-450Hz lpf2-1700Hz sr-250Hz');
idxstim      = dbUse.stimulation_on == 0;
idxTdIsStrm  = dbUse.timeDomainStreaming == 1;
idxAccIsStrm = dbUse.accelerometryStreaming == 1;
idxScbsUsed  = dbUse.recordedWithScbs == 1;

idxconcat = idxpat & idxside & idxsense & idxstim & idxTdIsStrm & idxAccIsStrm & idxScbsUsed;
patDBtoConcat = dbUse(idxconcat,:);
sum(patDBtoConcat.duration)
% run_rcs_plotter(patDBtoConcat,outputfolder,'stim_off')
concatenate_data(patDBtoConcat);
%%
%% RCS02 R

% before stim
outputfolder = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/processed_data';
idxpat       = strcmp(dbUse.patient,'RCS02');
idxside      = strcmp(dbUse.side,'R');
idxsense     = strcmp(dbUse.chan1,'+2-0 lpf1-450Hz lpf2-1700Hz sr-250Hz');
idxstim      = dbUse.stimulation_on == 0;
idxTdIsStrm  = dbUse.timeDomainStreaming == 1;
idxAccIsStrm = dbUse.accelerometryStreaming == 1;
idxScbsUsed = dbUse.recordedWithScbs == 1;

idxconcat = idxpat & idxside & idxsense & idxstim & idxTdIsStrm & idxAccIsStrm & idxScbsUsed;
patDBtoConcat = dbUse(idxconcat,:);
sum(patDBtoConcat.duration)
% run_rcs_plotter(patDBtoConcat,outputfolder,'stim_off')



end


function run_rcs_plotter(database,patdir,label)

for ss = 1:size(database,1)
    [pn,fn] = fileparts( database.deviceSettingsFn{ss});
    try
        rc = rcsPlotter();
        rc.addFolder(pn);
        rc.loadData();
        rc.saveTdChannelPsd();
        clear rc;
    end
end

end

function concatenate_data(patDBtoConcat)
for ss = 1:size(database,1)
    [pn,fn] = fileparts( database.deviceSettingsFn{ss});
end

end