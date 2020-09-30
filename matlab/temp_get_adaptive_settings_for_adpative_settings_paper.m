function temp_get_adaptive_settings_for_adpative_settings_paper()
%% load the database
clear all; clc; close all;
dropboxdir = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database';
reportsDir = fullfile(dropboxdir,'reports');
databaseFile = fullfile(dropboxdir,'database_from_device_settings.mat');
load(databaseFile);
idxkeep  = cellfun(@(x) istable(x),masterTableOut.stimStatus) & logical(masterTableOut.recordedWithScbs);
dbUse    = masterTableOut(idxkeep,:);
dbUse.duration.Format = 'hh:mm:ss';
%%

%% rcs06
% during adaptive
yearUse = 2020;
monthUse = 4;
dayUse = 20;
patient = 'RCS06';
outputfolder = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/processed_data';
idxpat       = strcmp(dbUse.patient,'RCS06');
idxside      = strcmp(dbUse.side,'L');
idxsense     = strcmp(dbUse.chan2,'+3-1 lpf1-100Hz lpf2-100Hz sr-250Hz');
idxstim      = dbUse.stimulation_on == 1;
idxstimRate  = dbUse.rate_Hz == 130.2;
idxstimLev   = dbUse.amplitude_mA == 0.9;
idxTdIsStrm  = dbUse.timeDomainStreaming == 1;
idxAccIsStrm = dbUse.accelerometryStreaming == 1;
idxScbsUsed  = dbUse.recordedWithScbs == 1;
idxDates     = year(dbUse.timeStart) == yearUse & ...
    month(dbUse.timeStart) == monthUse & ...
    day(dbUse.timeStart) == dayUse;


idxconcat = idxpat & idxside & idxsense & idxstim  & idxTdIsStrm & idxAccIsStrm  & idxScbsUsed & idxDates;
patDBtoConcat = dbUse(idxconcat,:);
sum(patDBtoConcat.duration)

%% rcs02 
% during adaptive
yearUse = 2020;
monthUse = 4;
dayUse = 27;
patient = 'RCS02';
outputfolder = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/processed_data';
idxpat       = strcmp(dbUse.patient,'RCS02');
idxside      = strcmp(dbUse.side,'R');
idxsense     = strcmp(dbUse.chan1,'+2-0 lpf1-100Hz lpf2-100Hz sr-250Hz');
idxstim      = dbUse.stimulation_on == 1;
idxTdIsStrm  = dbUse.timeDomainStreaming == 1;
idxAccIsStrm = dbUse.accelerometryStreaming == 1;
idxScbsUsed  = dbUse.recordedWithScbs == 1;
idxDates     = year(dbUse.timeStart) == yearUse & ...
    month(dbUse.timeStart) == monthUse & ...
    day(dbUse.timeStart) == dayUse;


idxconcat = idxpat & idxside  & idxstim  & idxTdIsStrm & idxAccIsStrm  & idxScbsUsed & idxDates;
patDBtoConcat = dbUse(idxconcat,:);
sum(patDBtoConcat.duration)