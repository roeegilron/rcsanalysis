function MAIN_create_subsets_of_home_data_for_analysis()
%% This function creats subsets of home data for later analysis 
% it uses previous functions to concatenate the data (listed below) and
% process it into small chunks. 

% note this readme is out of date as of aug 4 2020 and now doing this a new
% way
% will try and update these directions sooon 
% below directions refer to previous way of doing databasing 
% this has now changes to a more robust method using device settings to
% determin settings 
% this method is still in flux and will eventually will consist of a new
% data organization structure 

% pre reqs: 
%% data converstion and databasing functions 
% MAIN_report_data_in_folder 
% creates a database file you need 
% this function runs very quickly and will enter each TD.json file 
% and compute the the duration of each file 
% it will fail to find data if time domain data was not streamed (so for
% exmpale just power domain data. 

% MAIN_load_rcsdata_from_folders 
% this function converts all the .json containedin each session directory
% to .json files 
% note that this function relies on the database folder above. If you have
% added new data, you will need to delete the database.mat folder created
% in the top level session directryo and rerun the load function. 
% note that this function will only convert files that have not already
% been converted 

% print_stim_and_sense_settings_in_folders
% this function will create a .mat file and text file 
% 1) 'stim_and_sense_settings_table.mat'
% 2) 'stimAndDeviceSettingsLog.txt' 
% these will can be used to parse data for further analysis 
% stim and sense settings has information about sense and stim settings 
% so that "apples to apples" comaprison is possible from the data 
%
% This function will also plot a sense_stim_text_metrics.txt text file that
% will have infromation about all unique sense and stim combinations and
% their datasize 
% sense_stim_database_operations


% MAIN_run_process_RCS_data_in_parallel()
% this function splits dat into 30 second chunks 
% and reshape the data into this setting (with some overlap depending on
% settings) 
% this rehsaping is mostly so that PSD and such can be caluclated using
% vectorized code which greatly aaccelrates proccessing time for many time
% domai based analysis 
% processes data into 30 second chunks 

% analyzeContinouseDataFromSCS()
% this function is called by MAIN_run_process_RCS_data_in_parallel()
% in this function you will find the params used in order to chop the data
% up into little parts as well as the parameters used to do this choppping
% (like max gap allowed in time between each data segement, segement size
% in seconds etc. 
%%

%% parametrs 
% the first step after running all above functions is to look at the output
% of print_stim_and_sense_settings_in_folders()
% this will create a text file: stimAndDeviceSettingsLog.txt 
% as noted above that will tell you important information about what kind
% of parameters you would want to filter on for your database.
% then you can do your sorting here, and create subsets of your data that
% will then be passed to a concatenateing function 
% note that in order to concatenate data and run PSD's efficiently on
% hundereds of data chunk you need the data to be the same size (for vector
% operations). 
% TODO: make this robust to differnt sampleing rate by introducing
% interpolation to PSD results 

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
%%
GETPD = 0; % stn PD patients 
GETGP = 1; % stn gp patients 
GETDT = 0; % dystonia patinet (stn) 
if GETPD 
%% RCS02 L
try
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
    concatenate_and_plot_TD_data_from_database_table(patDBtoConcat,outputfolder,'stim_off');

   % on stim 
    outputfolder = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/processed_data';
    idxpat       = strcmp(dbUse.patient,'RCS02');
    idxside      = strcmp(dbUse.side,'L');
    idxsense     = strcmp(dbUse.chan2,'+3-1 lpf1-100Hz lpf2-100Hz sr-250Hz');
    idxstim      = dbUse.stimulation_on == 1;
    idxstimLev   = dbUse.amplitude_mA == 2.2;
    idxTdIsStrm  = dbUse.timeDomainStreaming == 1;
    idxAccIsStrm = dbUse.accelerometryStreaming == 1;
    idxScbsUsed = dbUse.recordedWithScbs == 1;

    
    idxconcat = idxpat & idxside & idxsense & idxstim & idxstimLev & idxTdIsStrm & idxAccIsStrm & idxScbsUsed;
    patDBtoConcat = dbUse(idxconcat,:);
    sum(patDBtoConcat.duration)
    concatenate_and_plot_TD_data_from_database_table(patDBtoConcat,outputfolder,'stim_2.2');
end
%%
%% RCS02 R
try
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
    concatenate_and_plot_TD_data_from_database_table(patDBtoConcat,outputfolder,'stim_off');
    
    % on stim
    outputfolder = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/processed_data';
    idxpat       = strcmp(dbUse.patient,'RCS02');
    idxside      = strcmp(dbUse.side,'R');
    idxsense     = strcmp(dbUse.chan1,'+2-0 lpf1-100Hz lpf2-100Hz sr-250Hz');
    idxstim      = dbUse.stimulation_on == 1;
    idxstimLev   = dbUse.amplitude_mA == 2.7;
    idxTdIsStrm  = dbUse.timeDomainStreaming == 1;
    idxAccIsStrm = dbUse.accelerometryStreaming == 1;
    idxScbsUsed = dbUse.recordedWithScbs == 1;
    
    idxconcat = idxpat & idxside & idxsense & idxstim & idxstimLev & idxTdIsStrm & idxAccIsStrm & idxScbsUsed;
    patDBtoConcat = dbUse(idxconcat,:);
    sum(patDBtoConcat.duration)
    concatenate_and_plot_TD_data_from_database_table(patDBtoConcat,outputfolder,'stim_2.7');
end
%%

%% RCS05 L
try
    % before stim 
    outputfolder = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/processed_data';
    idxpat       = strcmp(dbUse.patient,'RCS05');
    idxside      = strcmp(dbUse.side,'L');
    idxsense     = strcmp(dbUse.chan1,'+2-0 lpf1-450Hz lpf2-1700Hz sr-250Hz');
    idxstim      = dbUse.stimulation_on == 0;
    idxTdIsStrm  = dbUse.timeDomainStreaming == 1;
    idxAccIsStrm = dbUse.accelerometryStreaming == 1;
    idxScbsUsed = dbUse.recordedWithScbs == 1;
        
    idxconcat = idxpat & idxside & idxsense & idxstim & idxTdIsStrm & idxAccIsStrm & idxScbsUsed;
    patDBtoConcat = dbUse(idxconcat,:);
    sum(patDBtoConcat.duration)
    concatenate_and_plot_TD_data_from_database_table(patDBtoConcat,outputfolder,'stim_off');
    
    % on stim 
    outputfolder = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/processed_data';
    idxpat       = strcmp(dbUse.patient,'RCS05');
    idxside      = strcmp(dbUse.side,'L');
    idxsense     = strcmp(dbUse.chan2,'+2-0 lpf1-100Hz lpf2-100Hz sr-250Hz');
    idxstim      = dbUse.stimulation_on == 1;
    idxstimLev   = dbUse.amplitude_mA == 1.8;
    idxTdIsStrm  = dbUse.timeDomainStreaming == 1;
    idxAccIsStrm = dbUse.accelerometryStreaming == 1;
    idxScbsUsed = dbUse.recordedWithScbs == 1;

    idxconcat = idxpat & idxside & idxsense & idxstim & idxstimLev & idxTdIsStrm & idxAccIsStrm & idxScbsUsed;
    patDBtoConcat = dbUse(idxconcat,:);
    sum(patDBtoConcat.duration)
    concatenate_and_plot_TD_data_from_database_table(patDBtoConcat,outputfolder,'stim_1.8');
end
%%

%% RCS05 R
try
    % before stim 
    outputfolder = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/processed_data';
    idxpat       = strcmp(dbUse.patient,'RCS05');
    idxside      = strcmp(dbUse.side,'R');
    idxsense     = strcmp(dbUse.chan1,'+2-0 lpf1-450Hz lpf2-1700Hz sr-250Hz');
    idxstim      = dbUse.stimulation_on == 0;
    idxTdIsStrm  = dbUse.timeDomainStreaming == 1;
    idxAccIsStrm = dbUse.accelerometryStreaming == 1;
    idxScbsUsed  = dbUse.recordedWithScbs == 1;
        
    idxconcat = idxpat & idxside & idxsense & idxstim & idxTdIsStrm & idxAccIsStrm & idxScbsUsed;
    patDBtoConcat = dbUse(idxconcat,:);
    sum(patDBtoConcat.duration)
    concatenate_and_plot_TD_data_from_database_table(patDBtoConcat,outputfolder,'stim_off');
    
    % on stim 
    outputfolder = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/processed_data';
    idxpat       = strcmp(dbUse.patient,'RCS05');
    idxside      = strcmp(dbUse.side,'R');
    idxsense     = strcmp(dbUse.chan1,'+2-0 lpf1-100Hz lpf2-100Hz sr-250Hz');
    idxstim      = dbUse.stimulation_on == 1;
    idxstimLev   = dbUse.amplitude_mA == 1.3;
    idxTdIsStrm  = dbUse.timeDomainStreaming == 1;
    idxAccIsStrm = dbUse.accelerometryStreaming == 1;
    idxScbsUsed  = dbUse.recordedWithScbs == 1;
    
    idxconcat = idxpat & idxside & idxsense & idxstim & idxstimLev & idxTdIsStrm & idxAccIsStrm & idxScbsUsed;
    patDBtoConcat = dbUse(idxconcat,:);
    sum(patDBtoConcat.duration)
    concatenate_and_plot_TD_data_from_database_table(patDBtoConcat,outputfolder,'stim_1.3');
end
%%

%% RCS06 L 
try
    % before stim
    outputfolder = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/processed_data';
    idxpat       = strcmp(dbUse.patient,'RCS06');
    idxside      = strcmp(dbUse.side,'L');
    idxsense     = strcmp(dbUse.chan2,'+3-1 lpf1-450Hz lpf2-1700Hz sr-250Hz');
    idxstim      = dbUse.stimulation_on == 0;
    idxTdIsStrm  = dbUse.timeDomainStreaming == 1;
    idxAccIsStrm = dbUse.accelerometryStreaming == 1;
    idxScbsUsed  = dbUse.recordedWithScbs == 1;
        
    idxconcat = idxpat & idxside & idxsense & idxstim & idxTdIsStrm & idxAccIsStrm & idxScbsUsed;
    patDBtoConcat = dbUse(idxconcat,:);
    sum(patDBtoConcat.duration)
    concatenate_and_plot_TD_data_from_database_table(patDBtoConcat,outputfolder,'stim_off');
    
    % during stim 
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

    
    
    idxconcat = idxpat & idxside & idxsense & idxstim & idxstimLev & idxTdIsStrm & idxAccIsStrm & idxstimRate & idxScbsUsed;
    patDBtoConcat = dbUse(idxconcat,:);
    sum(patDBtoConcat.duration)
         % what uniqe months and years are used ? 
    daysUse      = day(patDBtoConcat.timeStart);
    montsUse     = month(patDBtoConcat.timeStart);
    yearsUse     = year(patDBtoConcat.timeStart);
    unqMonthsAndDays = sortrows(unique([montsUse(:,1) daysUse(:,1) yearsUse(:,1) ],'rows'),[1 2],'ascend');

    concatenate_and_plot_TD_data_from_database_table(patDBtoConcat,outputfolder,'stim_0.9');
    
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
    concatenate_and_plot_TD_data_from_database_table(patDBtoConcat,outputfolder,'adaptive_data_rcs06_in_paper');


end
%%
%% RCS06 R
try
    % before stim
    outputfolder = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/processed_data';
    idxpat       = strcmp(dbUse.patient,'RCS06');
    idxside      = strcmp(dbUse.side,'R');
    idxsense     = strcmp(dbUse.chan1,'+2-0 lpf1-450Hz lpf2-1700Hz sr-250Hz');
    idxstim      = dbUse.stimulation_on == 0;
    idxTdIsStrm  = dbUse.timeDomainStreaming == 1;
    idxAccIsStrm = dbUse.accelerometryStreaming == 1;
    idxScbsUsed  = dbUse.recordedWithScbs == 1;
        
    idxconcat = idxpat & idxside & idxsense & idxstim & idxTdIsStrm & idxAccIsStrm & idxScbsUsed;
    patDBtoConcat = dbUse(idxconcat,:);
    sum(patDBtoConcat.duration)
    concatenate_and_plot_TD_data_from_database_table(patDBtoConcat,outputfolder,'stim_off');
    
    % during stim 
    outputfolder = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/processed_data';
    idxpat       = strcmp(dbUse.patient,'RCS06');
    idxside      = strcmp(dbUse.side,'R');
    idxsense     = strcmp(dbUse.chan1,'+2-0 lpf1-100Hz lpf2-100Hz sr-250Hz');
    idxstim      = dbUse.stimulation_on == 1;
    idxstimRate  = dbUse.rate_Hz == 130.2;
    idxstimLev   = dbUse.amplitude_mA == 0.9;
    idxTdIsStrm  = dbUse.timeDomainStreaming == 1;
    idxAccIsStrm = dbUse.accelerometryStreaming == 1;
    idxScbsUsed  = dbUse.recordedWithScbs == 1;
    
    idxconcat = idxpat & idxside & idxsense & idxstim & idxstimLev & idxTdIsStrm & idxAccIsStrm & idxstimRate & idxScbsUsed;
    patDBtoConcat = dbUse(idxconcat,:);
    sum(patDBtoConcat.duration)
    concatenate_and_plot_TD_data_from_database_table(patDBtoConcat,outputfolder,'stim_0.9');
end
%%

%% RCS07 L
try
    % before stim
    outputfolder = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/processed_data';
    idxpat       = strcmp(dbUse.patient,'RCS07');
    idxside      = strcmp(dbUse.side,'L');
    idxsense     = strcmp(dbUse.chan2,'+3-1 lpf1-450Hz lpf2-1700Hz sr-250Hz');
    idxstim      = dbUse.stimulation_on == 0;
    idxTdIsStrm  = dbUse.timeDomainStreaming == 1;
    idxAccIsStrm = dbUse.accelerometryStreaming == 1;
    idxScbsUsed  = dbUse.recordedWithScbs == 1;
        
    idxconcat = idxpat & idxside & idxsense & idxstim & idxTdIsStrm & idxAccIsStrm & idxScbsUsed;
    patDBtoConcat = dbUse(idxconcat,:);
    sum(patDBtoConcat.duration)
    concatenate_and_plot_TD_data_from_database_table(patDBtoConcat,outputfolder,'stim_off');
    
    % durning stim
    outputfolder = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/processed_data';
    idxpat       = strcmp(dbUse.patient,'RCS07');
    idxside      = strcmp(dbUse.side,'L');
    idxsense     = strcmp(dbUse.chan1,'+3-1 lpf1-100Hz lpf2-100Hz sr-250Hz');
    idxstim      = dbUse.stimulation_on == 1;
    idxstimRate  = dbUse.rate_Hz == 130.2;
    idxstimLev   = dbUse.amplitude_mA == 2.0;
    idxTdIsStrm  = dbUse.timeDomainStreaming == 1;
    idxAccIsStrm = dbUse.accelerometryStreaming == 1;
    
    idxconcat = idxpat & idxside & idxsense & idxstim & idxstimLev & idxTdIsStrm & idxAccIsStrm & idxstimRate;
    patDBtoConcat = dbUse(idxconcat,:);
    sum(patDBtoConcat.duration)
    concatenate_and_plot_TD_data_from_database_table(patDBtoConcat,outputfolder,'stim_2.0');
end
%%
%% RCS07 R
try
    % before stim
    outputfolder = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/processed_data';
    idxpat       = strcmp(dbUse.patient,'RCS07');
    idxside      = strcmp(dbUse.side,'R');
    idxsense     = strcmp(dbUse.chan2,'+3-1 lpf1-450Hz lpf2-1700Hz sr-250Hz');
    idxstim      = dbUse.stimulation_on == 0;
    idxTdIsStrm  = dbUse.timeDomainStreaming == 1;
    idxAccIsStrm = dbUse.accelerometryStreaming == 1;
    idxScbsUsed  = dbUse.recordedWithScbs == 1;
    
    idxconcat = idxpat & idxside & idxsense & idxstim & idxTdIsStrm & idxAccIsStrm & idxScbsUsed;
    patDBtoConcat = dbUse(idxconcat,:);
    sum(patDBtoConcat.duration)
    concatenate_and_plot_TD_data_from_database_table(patDBtoConcat,outputfolder,'stim_off');
    
    % during stim 
    outputfolder = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/processed_data';
    idxpat       = strcmp(dbUse.patient,'RCS07');
    idxside      = strcmp(dbUse.side,'R');
    idxsense     = strcmp(dbUse.chan1,'+3-1 lpf1-100Hz lpf2-100Hz sr-250Hz');
    idxstim      = dbUse.stimulation_on == 1;
    idxstimRate  = dbUse.rate_Hz == 130.2;
    idxstimLev   = dbUse.amplitude_mA == 1.8;
    idxTdIsStrm  = dbUse.timeDomainStreaming == 1;
    idxAccIsStrm = dbUse.accelerometryStreaming == 1;
    idxScbsUsed  = dbUse.recordedWithScbs == 1;
        
    idxconcat = idxpat & idxside & idxsense & idxstim & idxstimLev & idxTdIsStrm & idxAccIsStrm & idxstimRate & idxScbsUsed;
    patDBtoConcat = dbUse(idxconcat,:);
    sum(patDBtoConcat.duration)
    concatenate_and_plot_TD_data_from_database_table(patDBtoConcat,outputfolder,'stim_1.8');
end
%%

%% RCS08 L
try
    % before stim
    outputfolder = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/processed_data';
    idxpat       = strcmp(dbUse.patient,'RCS08');
    idxside      = strcmp(dbUse.side,'L');
    idxsense     = strcmp(dbUse.chan1,'+2-0 lpf1-450Hz lpf2-1700Hz sr-250Hz');
    idxstim      = dbUse.stimulation_on == 0;
    idxTdIsStrm  = dbUse.timeDomainStreaming == 1;
    idxAccIsStrm = dbUse.accelerometryStreaming == 1;
    idxScbsUsed  = dbUse.recordedWithScbs == 1;
    
    idxconcat = idxpat & idxside & idxsense & idxstim & idxTdIsStrm & idxAccIsStrm & idxScbsUsed;
    patDBtoConcat = dbUse(idxconcat,:);
    sum(patDBtoConcat.duration)
    concatenate_and_plot_TD_data_from_database_table(patDBtoConcat,outputfolder,'stim_off');
    
    % during stim 
    outputfolder = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/processed_data';
    idxpat       = strcmp(dbUse.patient,'RCS08');
    idxside      = strcmp(dbUse.side,'L');
    idxsense     = strcmp(dbUse.chan1,'+2-0 lpf1-100Hz lpf2-100Hz sr-250Hz');
    idxstim      = dbUse.stimulation_on == 1;
    idxstimRate  = dbUse.rate_Hz == 130.2;
    idxstimLev   = dbUse.amplitude_mA == 2.7;
    idxTdIsStrm  = dbUse.timeDomainStreaming == 1;
    idxAccIsStrm = dbUse.accelerometryStreaming == 1;
    idxScbsUsed  = dbUse.recordedWithScbs == 1;
    
    idxconcat = idxpat & idxside & idxsense & idxstim & idxstimLev & idxTdIsStrm & idxAccIsStrm & idxstimRate & idxScbsUsed;
    patDBtoConcat = dbUse(idxconcat,:);
    sum(patDBtoConcat.duration)
    concatenate_and_plot_TD_data_from_database_table(patDBtoConcat,outputfolder,'stim_2.7');
end
%%
%% RCS08 R
try
    % before stim
    outputfolder = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/processed_data';
    idxpat       = strcmp(dbUse.patient,'RCS08');
    idxside      = strcmp(dbUse.side,'R');
    idxsense     = strcmp(dbUse.chan2,'+3-1 lpf1-450Hz lpf2-1700Hz sr-250Hz');
    idxstim      = dbUse.stimulation_on == 0;
    idxTdIsStrm  = dbUse.timeDomainStreaming == 1;
    idxAccIsStrm = dbUse.accelerometryStreaming == 1;
    idxScbsUsed  = dbUse.recordedWithScbs == 1;
    
    idxconcat = idxpat & idxside & idxsense & idxstim & idxTdIsStrm & idxAccIsStrm & idxScbsUsed;
    patDBtoConcat = dbUse(idxconcat,:);
    sum(patDBtoConcat.duration)
    concatenate_and_plot_TD_data_from_database_table(patDBtoConcat,outputfolder,'stim_off');
    
    % during stim 
    outputfolder = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/processed_data';
    idxpat       = strcmp(dbUse.patient,'RCS08');
    idxside      = strcmp(dbUse.side,'R');
    idxsense     = strcmp(dbUse.chan1,'+3-1 lpf1-100Hz lpf2-100Hz sr-250Hz');
    idxstim      = dbUse.stimulation_on == 1;
    idxstimRate  = dbUse.rate_Hz == 130.2;
    idxstimLev   = dbUse.amplitude_mA == 1.7;
    idxTdIsStrm  = dbUse.timeDomainStreaming == 1;
    idxAccIsStrm = dbUse.accelerometryStreaming == 1;
    idxScbsUsed  = dbUse.recordedWithScbs == 1;
    
    idxconcat = idxpat & idxside & idxsense & idxstim & idxstimLev & idxTdIsStrm & idxAccIsStrm & idxstimRate & idxScbsUsed;
    patDBtoConcat = dbUse(idxconcat,:);
    sum(patDBtoConcat.duration)
    concatenate_and_plot_TD_data_from_database_table(patDBtoConcat,outputfolder,'stim_1.7');
end
%%
end
if GETGP
%% RCS03L
try
    % before stim
    outputfolder = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/processed_data';
    idxpat       = strcmp(dbUse.patient,'RCS03');
    idxside      = strcmp(dbUse.side,'L');
    idxsense     = strcmp(dbUse.chan2,'+3-2 lpf1-450Hz lpf2-1700Hz sr-250Hz');
    idxstim      = dbUse.stimulation_on == 0;
    idxTdIsStrm  = dbUse.timeDomainStreaming == 1;
    idxAccIsStrm = dbUse.accelerometryStreaming == 1;
    idxScbsUsed  = dbUse.recordedWithScbs == 1;
    
    idxconcat = idxpat & idxside & idxsense & idxstim & idxTdIsStrm & idxAccIsStrm & idxScbsUsed;
    patDBtoConcat = dbUse(idxconcat,:);
    sum(patDBtoConcat.duration)
%     concatenate_and_plot_TD_data_from_database_table(patDBtoConcat,outputfolder,'stim_off');
    
    % during stim 
    outputfolder = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/processed_data';
    idxpat       = strcmp(dbUse.patient,'RCS03');
    idxside      = strcmp(dbUse.side,'L');
    idxsense     = strcmp(dbUse.chan2,'+3-2 lpf1-100Hz lpf2-100Hz sr-250Hz');
    idxsense     = strcmp(dbUse.chan2,'+2-0 lpf1-100Hz lpf2-100Hz sr-250Hz');
    idxstim      = dbUse.stimulation_on == 1;
    idxElec      = strcmp(dbUse.electrodes,'+1 -c ');
    idxstimRate  = dbUse.rate_Hz == 130.2;
    idxstimLev   = dbUse.amplitude_mA == 4.3;
    idxTdIsStrm  = dbUse.timeDomainStreaming == 1;
    idxAccIsStrm = dbUse.accelerometryStreaming == 1;
    idxScbsUsed  = dbUse.recordedWithScbs == 1;
    
    idxconcat = idxpat & idxside & idxsense & idxstim & idxstimLev & idxTdIsStrm & idxAccIsStrm & idxstimRate & idxScbsUsed & idxElec;
    idxconcat = idxpat & idxside & idxsense & idxstim;
    patDBtoConcat = dbUse(idxconcat,:);
    sum(patDBtoConcat.duration)
    concatenate_and_plot_TD_data_from_database_table(patDBtoConcat,outputfolder,'stim_4.3_c1');
end
%%
%% RCS03R
try
    % before stim
    outputfolder = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/processed_data';
    idxpat       = strcmp(dbUse.patient,'RCS03');
    idxside      = strcmp(dbUse.side,'R');
    idxsense     = strcmp(dbUse.chan1,'+1-0 lpf1-100Hz lpf2-100Hz sr-250Hz');
    idxstim      = dbUse.stimulation_on == 0;
    idxTdIsStrm  = dbUse.timeDomainStreaming == 1;
    idxAccIsStrm = dbUse.accelerometryStreaming == 1;
    idxScbsUsed  = dbUse.recordedWithScbs == 1;
    
    idxconcat = idxpat & idxside & idxsense & idxstim & idxTdIsStrm & idxAccIsStrm & idxScbsUsed;
    patDBtoConcat = dbUse(idxconcat,:);
    sum(patDBtoConcat.duration)
    concatenate_and_plot_TD_data_from_database_table(patDBtoConcat,outputfolder,'stim_off');
    
    % during stim  - % no data with this configuration need to move files
    % over and reindex 
    outputfolder = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/processed_data';
    idxpat       = strcmp(dbUse.patient,'RCS03');
    idxside      = strcmp(dbUse.side,'R');
    idxsense     = strcmp(dbUse.chan1,'+2-0 lpf1-100Hz lpf2-100Hz sr-250Hz');
    idxstim      = dbUse.stimulation_on == 1;
    idxElec      = strcmp(dbUse.electrodes,'+1 -c ');
    idxstimRate  = dbUse.rate_Hz == 208.3;
    idxstimLev   = dbUse.amplitude_mA == 2.6;
    idxTdIsStrm  = dbUse.timeDomainStreaming == 1;
    idxAccIsStrm = dbUse.accelerometryStreaming == 1;
    idxScbsUsed  = dbUse.recordedWithScbs == 1;
    
    idxconcat = idxpat & idxside & idxsense & idxstim & idxstimLev & idxTdIsStrm & idxAccIsStrm & idxstimRate & idxScbsUsed & idxElec;
    patDBtoConcat = dbUse(idxconcat,:);
    sum(patDBtoConcat.duration)
    concatenate_and_plot_TD_data_from_database_table(patDBtoConcat,outputfolder,'stim_2.6_c1');
end
%%
%% RCS09 L
try
    % before stim
    outputfolder = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/processed_data';
    idxpat       = strcmp(dbUse.patient,'RCS09');
    idxside      = strcmp(dbUse.side,'L');
    idxsense     = strcmp(dbUse.chan2,'+3-2 lpf1-450Hz lpf2-1700Hz sr-250Hz');
    idxstim      = dbUse.stimulation_on == 0;
    idxTdIsStrm  = dbUse.timeDomainStreaming == 1;
    idxAccIsStrm = dbUse.accelerometryStreaming == 1;
    idxScbsUsed  = dbUse.recordedWithScbs == 1;
    
    idxconcat = idxpat & idxside & idxsense & idxstim & idxTdIsStrm & idxAccIsStrm & idxScbsUsed;
    patDBtoConcat = dbUse(idxconcat,:);
    sum(patDBtoConcat.duration)
    concatenate_and_plot_TD_data_from_database_table(patDBtoConcat,outputfolder,'stim_off');
    
    % during stim  - % no data with this configuration need to move files
    % over and reindex 
    outputfolder = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/processed_data';
    idxpat       = strcmp(dbUse.patient,'RCS09');
    idxside      = strcmp(dbUse.side,'L');
    idxsense     = strcmp(dbUse.chan1,'+3-1 lpf1-100Hz lpf2-100Hz sr-250Hz');
    idxstim      = dbUse.stimulation_on == 1;
    idxElec      = strcmp(dbUse.electrodes,'+2 -c ');
    idxstimRate  = dbUse.rate_Hz == 149.30;
    idxstimLev   = dbUse.amplitude_mA >= 1.8;
    idxTdIsStrm  = dbUse.timeDomainStreaming == 1;
    idxAccIsStrm = dbUse.accelerometryStreaming == 1;
    idxScbsUsed  = dbUse.recordedWithScbs == 1;
    
    idxconcat = idxpat & idxside & idxsense & idxstim & idxstimLev & idxTdIsStrm & idxAccIsStrm & idxstimRate & idxScbsUsed & idxElec;
    patDBtoConcat = dbUse(idxconcat,:);
    sum(patDBtoConcat.duration)
    concatenate_and_plot_TD_data_from_database_table(patDBtoConcat,outputfolder,'stim_1.8_above');
end
%%

%% RCS09 R
try
    % before stim
    outputfolder = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/processed_data';
    idxpat       = strcmp(dbUse.patient,'RCS09');
    idxside      = strcmp(dbUse.side,'R');
    idxsense     = strcmp(dbUse.chan2,'+3-2 lpf1-450Hz lpf2-1700Hz sr-250Hz');
    idxstim      = dbUse.stimulation_on == 0;
    idxTdIsStrm  = dbUse.timeDomainStreaming == 1;
    idxAccIsStrm = dbUse.accelerometryStreaming == 1;
    idxScbsUsed  = dbUse.recordedWithScbs == 1;
    
    idxconcat = idxpat & idxside & idxsense & idxstim & idxTdIsStrm & idxAccIsStrm & idxScbsUsed;
    patDBtoConcat = dbUse(idxconcat,:);
    sum(patDBtoConcat.duration)
    concatenate_and_plot_TD_data_from_database_table(patDBtoConcat,outputfolder,'stim_off');
    
    % during stim  - % no data with this configuration need to move files
    % over and reindex 
    outputfolder = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/processed_data';
    idxpat       = strcmp(dbUse.patient,'RCS09');
    idxside      = strcmp(dbUse.side,'R');
    idxsense     = strcmp(dbUse.chan1,'+3-1 lpf1-100Hz lpf2-100Hz sr-250Hz');
    idxstim      = dbUse.stimulation_on == 1;
    idxElec      = strcmp(dbUse.electrodes,'+2 -c ');
    idxstimRate  = dbUse.rate_Hz == 149.30;
    idxstimLev   = dbUse.amplitude_mA >= 1.8;
    idxTdIsStrm  = dbUse.timeDomainStreaming == 1;
    idxAccIsStrm = dbUse.accelerometryStreaming == 1;
    idxScbsUsed  = dbUse.recordedWithScbs == 1;
    
    idxconcat = idxpat & idxside & idxsense & idxstim & idxstimLev & idxTdIsStrm & idxAccIsStrm & idxstimRate & idxScbsUsed & idxElec;
    patDBtoConcat = dbUse(idxconcat,:);
    sum(patDBtoConcat.duration)
    concatenate_and_plot_TD_data_from_database_table(patDBtoConcat,outputfolder,'stim_1.8_above');
end
%%
%% RCS10 L
try
    % before stim
    outputfolder = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/processed_data';
    idxpat       = strcmp(dbUse.patient,'RCS10');
    idxside      = strcmp(dbUse.side,'L');
    idxsense     = strcmp(dbUse.chan1,'+1-0 lpf1-450Hz lpf2-1700Hz sr-250Hz');
    idxstim      = dbUse.stimulation_on == 0;
    idxTdIsStrm  = dbUse.timeDomainStreaming == 1;
    idxAccIsStrm = dbUse.accelerometryStreaming == 1;
    idxScbsUsed  = dbUse.recordedWithScbs == 1;
    
    idxconcat = idxpat & idxside & idxsense & idxstim & idxTdIsStrm & idxAccIsStrm & idxScbsUsed;
    patDBtoConcat = dbUse(idxconcat,:);
    sum(patDBtoConcat.duration)
    concatenate_and_plot_TD_data_from_database_table(patDBtoConcat,outputfolder,'stim_off');
    
    % during stim  - % no data with this configuration need to move files
    % over and reindex 
    outputfolder = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/processed_data';
    idxpat       = strcmp(dbUse.patient,'RCS10');
    idxside      = strcmp(dbUse.side,'L');
    idxsense     = strcmp(dbUse.chan1,'+1-0 lpf1-100Hz lpf2-100Hz sr-250Hz');
    idxstim      = dbUse.stimulation_on == 1;
    idxElec      = strcmp(dbUse.electrodes,'+2 -c ');
    idxstimRate  = dbUse.rate_Hz == 129.9;
    idxstimLev   = dbUse.amplitude_mA >= 3.4;
    idxTdIsStrm  = dbUse.timeDomainStreaming == 1;
    idxAccIsStrm = dbUse.accelerometryStreaming == 1;
    idxScbsUsed  = dbUse.recordedWithScbs == 1;
    
    idxconcat = idxpat & idxside & idxsense & idxstim & idxstimLev & idxTdIsStrm & idxAccIsStrm & idxstimRate & idxScbsUsed & idxElec;
    patDBtoConcat = dbUse(idxconcat,:);
    sum(patDBtoConcat.duration)
    concatenate_and_plot_TD_data_from_database_table(patDBtoConcat,outputfolder,'stim_3.4_above');
end
%%
%% RCS10 R
try
    % before stim
    outputfolder = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/processed_data';
    idxpat       = strcmp(dbUse.patient,'RCS10');
    idxside      = strcmp(dbUse.side,'R');
    idxsense     = strcmp(dbUse.chan1,'+1-0 lpf1-450Hz lpf2-1700Hz sr-250Hz');
    idxstim      = dbUse.stimulation_on == 0;
    idxTdIsStrm  = dbUse.timeDomainStreaming == 1;
    idxAccIsStrm = dbUse.accelerometryStreaming == 1;
    idxScbsUsed  = dbUse.recordedWithScbs == 1;
    
    idxconcat = idxpat & idxside & idxsense & idxstim & idxTdIsStrm & idxAccIsStrm & idxScbsUsed;
    patDBtoConcat = dbUse(idxconcat,:);
    sum(patDBtoConcat.duration)
    concatenate_and_plot_TD_data_from_database_table(patDBtoConcat,outputfolder,'stim_off');
    
    % during stim  - % no data with this configuration need to move files
    % over and reindex 
    outputfolder = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/processed_data';
    idxpat       = strcmp(dbUse.patient,'RCS10');
    idxside      = strcmp(dbUse.side,'R');
    idxsense     = strcmp(dbUse.chan1,'+1-0 lpf1-100Hz lpf2-100Hz sr-250Hz');
    idxstim      = dbUse.stimulation_on == 1;
    idxElec      = strcmp(dbUse.electrodes,'+2 -c ');
    idxstimRate  = dbUse.rate_Hz == 129.9;
    idxstimLev   = dbUse.amplitude_mA >= 4.6;
    idxTdIsStrm  = dbUse.timeDomainStreaming == 1;
    idxAccIsStrm = dbUse.accelerometryStreaming == 1;
    idxScbsUsed  = dbUse.recordedWithScbs == 1;
    
    idxconcat = idxpat & idxside & idxsense & idxstim & idxstimLev & idxTdIsStrm & idxAccIsStrm & idxstimRate & idxScbsUsed & idxElec;
    patDBtoConcat = dbUse(idxconcat,:);
    sum(patDBtoConcat.duration)
    concatenate_and_plot_TD_data_from_database_table(patDBtoConcat,outputfolder,'stim_4.6_above');
end
%%
end

%% RCS04 L
try
    % before stim
    outputfolder = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/processed_data';
    idxpat       = strcmp(dbUse.patient,'RCS04');
    idxside      = strcmp(dbUse.side,'L');
    idxsense     = strcmp(dbUse.chan1,'+1-0 lpf1-450Hz lpf2-1700Hz sr-500Hz');
    idxstim      = dbUse.stimulation_on == 0;
    idxTdIsStrm  = dbUse.timeDomainStreaming == 1;
    idxAccIsStrm = dbUse.accelerometryStreaming == 1;
    
    
    idxconcat = idxpat & idxside & idxsense & idxstim & idxTdIsStrm & idxAccIsStrm ;
    patDBtoConcat = dbUse(idxconcat,:);
    sum(patDBtoConcat.duration)
    concatenate_and_plot_TD_data_from_database_table(patDBtoConcat,outputfolder,'stim_off');
end



%% RCS11L 
try
    % before stim
    outputfolder = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/processed_data';
    idxpat       = strcmp(dbUse.patient,'RCS11');
    idxside      = strcmp(dbUse.side,'L');
    idxsense1     = strcmp(dbUse.chan1,'+2-0 lpf1-450Hz lpf2-1700Hz sr-250Hz');
    idxsense2     = strcmp(dbUse.chan3,'+9-8 lpf1-450Hz lpf2-1700Hz sr-250Hz');
    idxstim      = dbUse.stimulation_on == 0;
    idxTdIsStrm  = dbUse.timeDomainStreaming == 1;
    idxAccIsStrm = dbUse.accelerometryStreaming == 1;
    
    
    idxconcat = idxpat & idxside & idxsense1 & idxsense2 & idxstim & idxTdIsStrm & idxAccIsStrm ;
    patDBtoConcat = dbUse(idxconcat,:);
    sum(patDBtoConcat.duration)
    concatenate_and_plot_TD_data_from_database_table(patDBtoConcat,outputfolder,'stim_off');
end
%%

%% RCS11R
try
    % before stim
    outputfolder = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/processed_data';
    idxpat       = strcmp(dbUse.patient,'RCS11');
    idxside      = strcmp(dbUse.side,'R');
    idxsense1     = strcmp(dbUse.chan1,'+2-0 lpf1-450Hz lpf2-1700Hz sr-250Hz');
    idxsense2     = strcmp(dbUse.chan3,'+9-8 lpf1-450Hz lpf2-1700Hz sr-250Hz');
    idxstim      = dbUse.stimulation_on == 0;
    idxTdIsStrm  = dbUse.timeDomainStreaming == 1;
    idxAccIsStrm = dbUse.accelerometryStreaming == 1;
    
    
    idxconcat = idxpat & idxside & idxsense1 & idxsense2 & idxstim & idxTdIsStrm & idxAccIsStrm ;
    patDBtoConcat = dbUse(idxconcat,:);
    sum(patDBtoConcat.duration)
    concatenate_and_plot_TD_data_from_database_table(patDBtoConcat,outputfolder,'stim_off');
end
%%

%% RCS12L 
try
    % before stim
    outputfolder = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/processed_data';
    idxpat       = strcmp(dbUse.patient,'RCS12');
    idxside      = strcmp(dbUse.side,'L');
    idxsense1     = strcmp(dbUse.chan1,'+2-0 lpf1-450Hz lpf2-1700Hz sr-250Hz');
    idxsense2     = strcmp(dbUse.chan3,'+9-8 lpf1-450Hz lpf2-1700Hz sr-250Hz');
    idxstim      = dbUse.stimulation_on == 0;
    idxTdIsStrm  = dbUse.timeDomainStreaming == 1;
    idxAccIsStrm = dbUse.accelerometryStreaming == 1;
    
    
    idxconcat = idxpat & idxside & idxsense1 & idxsense2 & idxstim & idxTdIsStrm & idxAccIsStrm ;
    patDBtoConcat = dbUse(idxconcat,:);
    sum(patDBtoConcat.duration)
    concatenate_and_plot_TD_data_from_database_table(patDBtoConcat,outputfolder,'stim_off');
end
%%

%% RCS12R
try
    % before stim
    outputfolder = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/processed_data';
    idxpat       = strcmp(dbUse.patient,'RCS12');
    idxside      = strcmp(dbUse.side,'R');
    idxsense1     = strcmp(dbUse.chan1,'+2-0 lpf1-450Hz lpf2-1700Hz sr-250Hz');
    idxsense2     = strcmp(dbUse.chan3,'+9-8 lpf1-450Hz lpf2-1700Hz sr-250Hz');
    idxstim      = dbUse.stimulation_on == 0;
    idxTdIsStrm  = dbUse.timeDomainStreaming == 1;
    idxAccIsStrm = dbUse.accelerometryStreaming == 1;
    
    
    idxconcat = idxpat & idxside & idxsense1 & idxsense2 & idxstim & idxTdIsStrm & idxAccIsStrm ;
    patDBtoConcat = dbUse(idxconcat,:);
    sum(patDBtoConcat.duration)
    concatenate_and_plot_TD_data_from_database_table(patDBtoConcat,outputfolder,'stim_off');
end
%%








return 
%% old way of doing things 

dropboxdir = findFilesBVQX('/Users','Starr Lab Dropbox',struct('dirs',1,'depth',2));
DROPBOX_PATH = dropboxdir; 

%%
% find unsynced data folder on dropbox and then patient needed 
rootfolder = findFilesBVQX(DROPBOX_PATH,'RC+S Patient Un-Synced Data',struct('dirs',1,'depth',1));

% exmaple selections: 
%%
patient= 'RCS03'; 
patdir = findFilesBVQX(rootfolder{1},[patient '*'],struct('dirs',1,'depth',1));
% find the home data folder (SCBS fodler 
scbs_folder = findFilesBVQX(patdir{1},'SummitContinuousBilateralStreaming',struct('dirs',1,'depth',2));
% assumign you want the same settings for L and R side  
pat_side_folders = findFilesBVQX(scbs_folder{1},[patient '*'],struct('dirs',1,'depth',1));
for ss = 1:length(pat_side_folders)
    % check if database file exists, if not create it 
    dbFile = fullfile(pat_side_folders{ss},'stim_and_sense_settings_table.mat');
    if exist(dbFile,'file')
        load(dbFile)
    else
        try
            print_stim_and_sense_settings_in_folders(pat_side_folders{ss});
            load(dbFile)
        catch
            fprintf('error with creating the database');
            fprintf('please run %s function', 'print_stim_and_sense_settings_in_folders.m');
            fprintf('with this folder:\n');
            fprintf('%s\n',pat_side_folders{ss});
            error('error with creating db file');
        end
    end
    % print the database file to screen (the text portion it creats to make
    % this next bit easier 
    databaseReport = fullfile(pat_side_folders{ss},'sense_stim_database_report.txt');
    dbtype(databaseReport);
    
    %% this bit can be specific on a "per patient" basis 
    sideUsed = unique(sense_stim_table.side);
    if strcmp(patient,'RCS03') & strcmp(sideUsed{1},'L') 
        idxuse = strcmp(sense_stim_table.chan1,'+1-0 lpf1-450Hz lpf2-1700Hz sr-500Hz') & ...
            sense_stim_table.stimulation_on == 0;
        stim_off_database = sense_stim_table(idxuse,:);
        concatenate_and_plot_TD_data_from_database_table(stim_off_database,pat_side_folders{ss},'before_stim');
        
        idxuse = strcmp(sense_stim_table.electrodes,'+2 -c ') & ...
            sense_stim_table.stimulation_on == 1;
        stim_on_database = sense_stim_table(idxuse,:);
        concatenate_and_plot_TD_data_from_database_table(stim_on_database,pat_side_folders{ss},'after_stim_2-C');
        
        idxuse = strcmp(sense_stim_table.chan1,'+2-0 lpf1-100Hz lpf2-100Hz sr-250Hz') & ...
            sense_stim_table.stimulation_on == 1;
        stim_on_database = sense_stim_table(idxuse,:);
        concatenate_and_plot_TD_data_from_database_table(stim_on_database,pat_side_folders{ss},'after_stim_1-C');
    end
    if strcmp(patient,'RCS08') 
        idxuse = strcmp(sense_stim_table.chan1,'+2-0 lpf1-450Hz lpf2-1700Hz sr-250Hz') & ...
            sense_stim_table.stimulation_on == 0;
        stim_off_database = sense_stim_table(idxuse,:);
        concatenate_and_plot_TD_data_from_database_table(stim_off_database,pat_side_folders{ss},'before_stim');

    end
    
    % just added coherence to above function 
    
end



end
