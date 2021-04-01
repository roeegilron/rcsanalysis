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

%%










GETPD = 1;
GETGP = 0;
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
        run_rcs_plotter(patDBtoConcat,outputfolder,'stim-off')
        concatenate_data(patDBtoConcat,outputfolder,'stim-off')
        
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
        run_rcs_plotter(patDBtoConcat,outputfolder,'stim-on_2.2')
        concatenate_data(patDBtoConcat,outputfolder,'stim-on_2.2')
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
        run_rcs_plotter(patDBtoConcat,outputfolder,'stim-off')
        concatenate_data(patDBtoConcat,outputfolder,'stim-off')
        
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
        run_rcs_plotter(patDBtoConcat,outputfolder,'stim-on_2.7')
        concatenate_data(patDBtoConcat,outputfolder,'stim-on_2.7')
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
        run_rcs_plotter(patDBtoConcat,outputfolder,'stim-off')
        concatenate_data(patDBtoConcat,outputfolder,'stim-off')
        
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
        run_rcs_plotter(patDBtoConcat,outputfolder,'stim-on_1.8')
        concatenate_data(patDBtoConcat,outputfolder,'stim-on_1.8')
        
        
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
        run_rcs_plotter(patDBtoConcat,outputfolder,'stim-off')
        concatenate_data(patDBtoConcat,outputfolder,'stim-off')
        
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
        run_rcs_plotter(patDBtoConcat,outputfolder,'stim-on_1.3')
        concatenate_data(patDBtoConcat,outputfolder,'stim-on_1.3')
    end
    %%
    
    %% RCS06 L
    try    outputfolder = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/processed_data';
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
        
        % before stim
        run_rcs_plotter(patDBtoConcat,outputfolder,'stim-off')
        concatenate_data(patDBtoConcat,outputfolder,'stim-off')
        
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
        
        run_rcs_plotter(patDBtoConcat,outputfolder,'stim-on_0.9')
        concatenate_data(patDBtoConcat,outputfolder,'stim-on_0.9')
        
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
        %         concatenate_and_plot_TD_data_from_database_table(patDBtoConcat,outputfolder,'adaptive_data_rcs06_in_paper');
        
        
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
        run_rcs_plotter(patDBtoConcat,outputfolder,'stim-off')
        concatenate_data(patDBtoConcat,outputfolder,'stim-off')
        
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
        run_rcs_plotter(patDBtoConcat,outputfolder,'stim-on_0.9')
        concatenate_data(patDBtoConcat,outputfolder,'stim-on_0.9')
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
        run_rcs_plotter(patDBtoConcat,outputfolder,'stim-off')
        concatenate_data(patDBtoConcat,outputfolder,'stim-off')
        
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
        run_rcs_plotter(patDBtoConcat,outputfolder,'stim-on_2.0')
        concatenate_data(patDBtoConcat,outputfolder,'stim-on_2.0')
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
        run_rcs_plotter(patDBtoConcat,outputfolder,'stim-off')
        concatenate_data(patDBtoConcat,outputfolder,'stim-off')
        
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
        run_rcs_plotter(patDBtoConcat,outputfolder,'stim-on_1.8')
        concatenate_data(patDBtoConcat,outputfolder,'stim-on_1.8')
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
        run_rcs_plotter(patDBtoConcat,outputfolder,'stim-off')
        concatenate_data(patDBtoConcat,outputfolder,'stim-off')
        
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
        run_rcs_plotter(patDBtoConcat,outputfolder,'stim-on_2.7')
        concatenate_data(patDBtoConcat,outputfolder,'stim-on_2.7')
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
        run_rcs_plotter(patDBtoConcat,outputfolder,'stim-off')
        concatenate_data(patDBtoConcat,outputfolder,'stim-off')
        
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
        run_rcs_plotter(patDBtoConcat,outputfolder,'stim-on_1.7')
        concatenate_data(patDBtoConcat,outputfolder,'stim-on_1.7')
    end
    %%
    
    
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
        run_rcs_plotter(patDBtoConcat,outputfolder,'stim-off')
        concatenate_data(patDBtoConcat,outputfolder,'stim-off')
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
        run_rcs_plotter(patDBtoConcat,outputfolder,'stim-off')
        concatenate_data(patDBtoConcat,outputfolder,'stim-off')
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
        run_rcs_plotter(patDBtoConcat,outputfolder,'stim-off')
        concatenate_data(patDBtoConcat,outputfolder,'stim-off')
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
        run_rcs_plotter(patDBtoConcat,outputfolder,'stim-off')
        concatenate_data(patDBtoConcat,outputfolder,'stim-off')
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
        run_rcs_plotter(patDBtoConcat,outputfolder,'stim-off')
        concatenate_data(patDBtoConcat,outputfolder,'stim-off')
        
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
        run_rcs_plotter(patDBtoConcat,outputfolder,'stim-on_4.3')
        concatenate_data(patDBtoConcat,outputfolder,'stim-on_4.3')
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
        run_rcs_plotter(patDBtoConcat,outputfolder,'stim-off')
        concatenate_data(patDBtoConcat,outputfolder,'stim-off')
        
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
        run_rcs_plotter(patDBtoConcat,outputfolder,'stim-on_2.6')
        concatenate_data(patDBtoConcat,outputfolder,'stim-on_2.6')
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
        run_rcs_plotter(patDBtoConcat,outputfolder,'stim-off')
        concatenate_data(patDBtoConcat,outputfolder,'stim-off')
        
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
        run_rcs_plotter(patDBtoConcat,outputfolder,'stim-on_1.8_above')
        concatenate_data(patDBtoConcat,outputfolder,'stim-on_1.8_above')
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
        run_rcs_plotter(patDBtoConcat,outputfolder,'stim-off')
        concatenate_data(patDBtoConcat,outputfolder,'stim-off')
        
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
        run_rcs_plotter(patDBtoConcat,outputfolder,'stim-on_1.8_above')
        concatenate_data(patDBtoConcat,outputfolder,'stim-on_1.8_above')
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
        run_rcs_plotter(patDBtoConcat,outputfolder,'stim-off')
        concatenate_data(patDBtoConcat,outputfolder,'stim-off')
        
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
        run_rcs_plotter(patDBtoConcat,outputfolder,'stim-on_3.4_above')
        concatenate_data(patDBtoConcat,outputfolder,'stim-on_3.4_above')
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
        run_rcs_plotter(patDBtoConcat,outputfolder,'stim-off')
        concatenate_data(patDBtoConcat,outputfolder,'stim-off')
        
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
        run_rcs_plotter(patDBtoConcat,outputfolder,'stim-on_4.6_above')
        concatenate_data(patDBtoConcat,outputfolder,'stim-on_4.6_above')
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
    run_rcs_plotter(patDBtoConcat,outputfolder,'stim-off')
    concatenate_data(patDBtoConcat,outputfolder,'stim-off')
end










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

function concatenate_data(patDBtoConcat,outputfolder,label)
cnt = 1;
for ss = 1:size(patDBtoConcat,1)
    [pn,fn] = fileparts( patDBtoConcat.deviceSettingsFn{ss});
    if exist(fullfile(pn,'AllDataPSD.mat'),'file')
        load(fullfile(pn,'AllDataPSD.mat'))
        psdDataOut(cnt) = psdData;
        cnt = cnt + 1;
        clear psdData;
        fprintf('%d file done\n',cnt);
    end
end
dataOut = [];
psdTimesOut = [];
cntpsd = 1;
for i = 1:size(psdDataOut,2)
    data = psdDataOut(i).data;
    
    if size(data,1) == 126
        psdTimes = psdDataOut(i).psdTimes;
        psdTimesOut = [psdTimesOut; psdTimes];
        for j = 1:size(data,2)
            dataOut(:,cntpsd,:) = data(:,j,:);
            
            cntpsd = cntpsd + 1;
        end
    end
end
database = patDBtoConcat;
fnsave = sprintf('%s_%s_psdNewOpenMindAlgo__%s.mat',database.patient{1},database.side{1}, label);
save( fullfile(outputfolder,fnsave),'psdDataOut','dataOut','database','psdTimesOut')

end


function plot_amp_amp_corrs()

% only select daylight times and do some artifact removal
%%
idxWhisker = [];
for c = 1:4
    dat = dataOut(:,:,1)';
    meanVals = mean(dat(:,40:60),2);
    q75_test=quantile(meanVals,0.75);
    q25_test=quantile(meanVals,0.25);
    w=2.0;
    wUpper(c) = w*(q75_test-q25_test)+q75_test;
    idxWhisker(:,c) = meanVals < wUpper(c);
end
idxkeep = idxWhisker(:,1) &  idxWhisker(:,2) & idxWhisker(:,3) & idxWhisker(:,4) ;
idxtimekeep = hour(psdTimesOut) >= 8 &  hour(psdTimesOut) <= 22;
%% verify
hfig = figure;
hfig.Color = 'w';
for c = 1:4
    subplot(2,2,c);
    dat = dataOut(:,:,c)';
    plot(log10(dat(idxkeep & idxtimekeep,: )'),'LineWidth',0.1,'Color',[0.8 0 0 0.1]);
end
%%

pairsuse = [1 3; 1 4; 2 3; 2 4];

hfig = figure;
hfig.Color = 'w';
hsbAll = gobjects();
for c = 1:4
    hsbAll(c,1)  = subplot(2,2,c);
end

for pp = 1:size(pairsuse,1)
    
    hsb = hsbAll(pp,1);
    
    fnuse = sprintf('chan%d_tdSettings',pairsuse(pp,1));
    xlab = psdDataOut(1).(fnuse)(1:5);
    fnuse = sprintf('chan%d_tdSettings',pairsuse(pp,2));
    ylab = psdDataOut(1).(fnuse)(1:5);
    
    dat = dataOut(:,:,2)';
    rescaledMvMean1 = zscore(dat(idxkeep & idxtimekeep,:));
    
    dat = dataOut(:,:,3)';
    rescaledMvMean2 = zscore(dat(idxkeep & idxtimekeep,:));
    
    dur = size(dat,1)*psdDataOut(1).psdDuration;
    dur.Format = 'hh:mm';
    
    [corrs pvals] = corr(rescaledMvMean1,rescaledMvMean2,'type','Spearman');
    % [corrs pvals] = corrcoef(rescaledMvMean1,rescaledMvMean4);
    %     pvalsCorr = pvals < 0.05/length(pvals(:));
    corrsDiff = corrs;
    %     corrsDiff(corrs<0.6 & corrs>0 ) = NaN;
    %     corrsDiff(corrs<0 & corrs>-0.3 ) = NaN;
    
    % plotting
    
    axes(hsb);
    b = imagesc(corrsDiff');
    % set(b,'AlphaData',~isnan(corrsDiff'))
    cmin = -0.6;
    cmax = 0.7;
    caxis([cmin cmax]);
    colorbar;
    
    set(hsb,'YDir','normal')
    
    % get xlabel
    xlabel(xlab);
    
    % get ylabel
    ylabel(ylab);
    
    
    
    ticks = [4 12 30 50 60 65 70 75 80 100];
    
    
    set(gca,'YDir','normal')
    yticks = [4 12 30 50 60 65 70 75 80 100];
    tickLabels = {};
    ticksuse = [];
    fff = psdDataOut.freqs;
    for yy = 1:length(yticks)
        [~,idx] = min(abs(yticks(yy)-fff));
        ticksuse(yy) = idx;
        tickLabels{yy} = sprintf('%d',yticks(yy));
    end
    hsb.YTick = ticksuse;
    hsb.YTickLabel = tickLabels;
    hsb.XTick = ticksuse;
    hsb.XTickLabel = tickLabels;
    axis tight;
    %         axis square;
    grid(hsb,'on');
    hsb.GridAlpha = 0.8;
    hsb.Layer = 'top';
    
    ttluse  = sprintf('%s %s %s',database.patient{1},database.side{1},dur);
    title(ttluse);
end

end