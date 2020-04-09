function create_psd_results_for_stim_on_off_comparison()
%% this function relies on: 
% 1. readme_large_amounts_of_data_function
% 2. running: 
% A. MAIN_report_data_in_folder % creates a database file you need
% B. MAIN_load_rcsdata_from_folders % opens al the data. make sure line 
% C. print_stim_and_sense_settings_in_folders % create a stim database folder
close all; clear all; clc;
%% set params
params.patient = 'RCS04'; 
params.side    = 'L';
%% 
switch params.patient
    case 'RCS04' 
        if ispc 
            params.rootdir = 'D:\Starr Lab Dropbox\RC+S Patient Un-Synced Data\RCS04 Un-Synced Data\SummitData\SummitContinuousBilateralStreaming';
        elseif ismac 
            params.rootdir = '/Volumes/RCS_DATA/RCS04/sense_stim_settings_RCS04';
        end
        params.rootdir = fullfile(params.rootdir,[params.patient params.side]);
        stim_database_fn = fullfile(params.rootdir,'stim_and_sense_settings_table.mat');
        load(stim_database_fn);
        % select data for stim off: 
        
        timeAfter = datetime('13-Jul-2019 08:15:52.728');
        timeAfter.TimeZone = sense_stim_table.start_time.TimeZone;
        idxkeep_stim_off = ... 
            cellfun(@(x) any(strfind(x,'+2-0 lpf1-450Hz lpf2-1700Hz sr-250Hz')),sense_stim_table.chan1) & ... % only use contacts 2-3
            sense_stim_table.duration > minutes(4) & ...  % only choose files over 2 minutes
            sense_stim_table.start_time > timeAfter& ... % only data after this time is real 
            sense_stim_table.stimulation_on == 0;
        tbluse = sense_stim_table(idxkeep_stim_off,:);
        sum(tbluse.duration)
         
        % select data for stim on: 
        idxkeep_stim_on = ...
            cellfun(@(x) any(strfind(x,'+2-0 lpf1-100Hz lpf2-100Hz sr-250Hz')),sense_stim_table.chan1) & ... % only use contacts 2-3
            sense_stim_table.duration > minutes(2) & ...  % only choose files over 2 minutes
            sense_stim_table.amplitude_mA == 0.8 & ... 
            cellfun(@(x) any(strfind(x,'+1 -c ')),sense_stim_table.electrodes) & ... % only use contacts 2-3
            sense_stim_table.stimulation_on == 1;
        tbluse = sense_stim_table(idxkeep_stim_on,:);
        sum(tbluse.duration);
    case 'RCS03'
        if ispc 
            params.rootdir = 'D:\Starr Lab Dropbox\RC+S Patient Un-Synced Data\RCS03 Un-Synced Data\SummitData\SummitContinuousBilateralStreaming';
        elseif ismac 
            params.rootdir = '/Volumes/RCS_DATA/RCS03/from_bobby_computer';
        end
        params.rootdir = fullfile(params.rootdir,[params.patient params.side]);
        stim_database_fn = fullfile(params.rootdir,'stim_and_sense_settings_table.mat');
        load(stim_database_fn);
        % select data for stim off:
        idxkeep_stim_off = ... 
            cellfun(@(x) any(strfind(x,'+3-2 lpf1-450Hz lpf2-1700Hz sr-250Hz')),sense_stim_table.chan2) & ... % only use contacts 2-3
            sense_stim_table.duration > minutes(4) & ...  % only choose files over 2 minutes
            sense_stim_table.stimulation_on == 0;
        tbluse = sense_stim_table(idxkeep_stim_off,:);
        sum(tbluse.duration)
        
         % select data for stim on: 
        idxkeep_stim_on = ...
            cellfun(@(x) any(strfind(x,'+3-2 lpf1-100Hz lpf2-100Hz sr-250Hz')),sense_stim_table.chan2) & ... % only use contacts 2-3
            sense_stim_table.duration > minutes(2) & ...  % only choose files over 2 minutes
            sense_stim_table.amplitude_mA == 4.3 & ... 
            cellfun(@(x) any(strfind(x,'+1 -c ')),sense_stim_table.electrodes) & ... % only use contacts 2-3
            sense_stim_table.stimulation_on == 1;
        tbluse = sense_stim_table(idxkeep_stim_on,:);
        sum(tbluse.duration);



    otherwise 
end

%% load data base file 
stim_database_fn = fullfile(params.rootdir,'stim_and_sense_settings_table.mat');
load(stim_database_fn); 
%%

 

%% loop on stim on / stim off 
skipthis = 0; % if 1 - skpi this part 
if ~skipthis 
for ss = 1:2 % loop on stim off / on 1 = stim off 
    %% data picker 
    if ss == 1 % stim off
        idxkeep = idxkeep_stim_off;
    elseif ss == 2 % stim on
        idxkeep = idxkeep_stim_on;
    end
    tbluse = sense_stim_table(idxkeep,:);
    %% 
    tdProcDat = struct();
    cnttime = 1;
    for t = 1:size(tbluse,1)
        filedir = findFilesBVQX(params.rootdir, tbluse.session{t},struct('dir',1,'depth',1));
        ff = findFilesBVQX(filedir{1},'proc*TD*.mat');
        if ~isempty(ff)
            load(ff{1},'processedData');
            if isempty(fieldnames(tdProcDat))
                if isstruct(processedData)
                    tdProcDat = processedData;
                    timeDomainFileDur(cnttime,1) = processedData(1).timeStart;
                    timeDomainFileDur(cnttime,2) = processedData(end).timeStart;
                    cnttime = cnttime+1;
                end
            else
                if ~isempty(processedData)
                    tdProcDat = [tdProcDat processedData];
                    timeDomainFileDur(cnttime,1) = processedData(1).timeStart;
                    timeDomainFileDur(cnttime,2) = processedData(end).timeStart;
                    cnttime = cnttime+1;
                end
            end
        end
        clear processedData
        fprintf('time domain file %d/%d done\n',t,size(tbluse,1));
    end
    %% do fft but on sep recordings
    for i = 1:length( tdProcDat )
        for c = 1:4
            fn = sprintf('key%d',c-1);
            if size(tdProcDat(i).(fn),1) < size(tdProcDat(i).(fn),2)
                tdProcDat(i).(fn) = tdProcDat(i).(fn)';
            end
        end
    end
    
    for c = 1:4
        start = tic;
        fn = sprintf('key%d',c-1);
        dat = [tdProcDat.(fn)];
        sr = 250;
        [fftOut,ff]   = pwelch(dat,sr,sr/2,0:1:sr/2,sr,'psd');
        fftResultsTd.([fn 'fftOut']) = log10(fftOut);
        fprintf('chanel %d done in %.2f\n',c,toc(start))
    end
    fftResultsTd.ff = ff;
    fftResultsTd.timeStart = [tdProcDat.timeStart];
    fftResultsTd.timeEnd = [tdProcDat.timeEnd];
    %%
    if ss == 1 
        save( fullfile(params.rootdir,'psdResults_off_stim.mat'),'fftResultsTd','tbluse')
    else
        save( fullfile(params.rootdir,'psdResults_on_stim.mat'),'fftResultsTd','tbluse')
    end
end
end