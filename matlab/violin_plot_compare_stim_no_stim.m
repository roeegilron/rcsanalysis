function violin_plot_compare_stim_no_stim()
%% this function relies on: 
% 1. readme_large_amounts_of_data_function
% 2. running: 
% A. MAIN_report_data_in_folder % creates a database file you need
% B. MAIN_load_rcsdata_from_folders % opens al the data. make sure line 
% C. print_stim_and_sense_settings_in_folders % create a stim database folder
close all; clear all; clc;
%% set params 
params.rootdir = '/Volumes/RCS_DATA/RCS03/raw_data_push_jan_2020/SCBS/RCS03L';
%% 

%% load data base file 
stim_database_fn = fullfile(params.rootdir,'stim_and_sense_settings_table.mat');
load(stim_database_fn); 
%% 

%% print some states 

idxkeep = ...
    sense_stim_table.stimulation_on == 0;
tbluse = sense_stim_table(idxkeep,:);
sum(tbluse.duration)

idxkeep = ...
    cellfun(@(x) any(strfind(x,'+3-2 lpf1-450Hz lpf2-1700Hz sr-250Hz')),sense_stim_table.chan2) & ... % only use contacts 2-3
    sense_stim_table.duration > minutes(2) & ...  % only choose files over 2 minutes
    sense_stim_table.stimulation_on == 0;
tbluse = sense_stim_table(idxkeep,:);
sum(tbluse.duration)

idxkeep = ...
    sense_stim_table.stimulation_on == 1;
tbluse = sense_stim_table(idxkeep,:);
sum(tbluse.duration)


idxkeep = ...
    cellfun(@(x) any(strfind(x,'+3-1 lpf1-450Hz lpf2-1700Hz sr-250Hz')),sense_stim_table.chan2) & ... % only use contacts 2-3
    cellfun(@(x) any(strfind(x,'+1 -c ')),sense_stim_table.electrodes) & ... % only use contacts 2-3
    sense_stim_table.duration > minutes(2) & ...  % only choose files over 2 minutes
    sense_stim_table.stimulation_on == 1;
tbluse = sense_stim_table(idxkeep,:);
sum(tbluse.duration)

 

%% loop on stim on / stim off 
skipthis = 1; % if 1 - skpi this part 
if ~skipthis 
for ss = 2 %1:2 % loop on stim off / on 1 = stim off 
    %% data picker 
    if ss == 1 % stim off
        idxkeep = ...
            cellfun(@(x) any(strfind(x,'+3-2 lpf1-450Hz lpf2-1700Hz sr-250Hz')),sense_stim_table.chan2) & ... % only use contacts 2-3
            sense_stim_table.duration > minutes(2) & ...  % only choose files over 2 minutes
            sense_stim_table.stimulation_on == 0;
        tbluse = sense_stim_table(idxkeep,:);
    elseif ss == 2 % stim on
        idxkeep = ...
            cellfun(@(x) any(strfind(x,'+3-2 lpf1-450Hz lpf2-1700Hz sr-500Hz')),sense_stim_table.chan2) & ... % only use contacts 2-3
            sense_stim_table.duration > minutes(2) & ...  % only choose files over 2 minutes
            sense_stim_table.stimulation_on == 1;
        % bad settings...
        idxkeep = ...
            cellfun(@(x) any(strfind(x,'+3-1 lpf1-450Hz lpf2-1700Hz sr-250Hz')),sense_stim_table.chan2) & ... % only use contacts 2-3
            cellfun(@(x) any(strfind(x,'+1 -c ')),sense_stim_table.electrodes) & ... % only use contacts 2-3
            sense_stim_table.duration > minutes(2) & ...  % only choose files over 2 minutes
            sense_stim_table.stimulation_on == 1;

        tbluse = sense_stim_table(idxkeep,:);
    end
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
        save( fullfile(params.rootdir,'psdResults_off_stim.mat'),'fftResultsTd')
    else
        save( fullfile(params.rootdir,'psdResults_on_stim2.mat'),'fftResultsTd')
    end
end
end

%% plot violin plots 
% requires these files in rootdir: 
filesoad{1} = fullfile(params.rootdir,'psdResults_off_stim.mat');
filesoad{2} = fullfile(params.rootdir,'psdResults_on_stim2.mat');
stimestate =  {'off', 'on'};
%5% plot the raw data 
for ss = 2 %%  1:2
    load(filesoad{ss});
    ff = fftResultsTd.ff;
    if ss == 1 % stim off
        idxkeep = ...
            cellfun(@(x) any(strfind(x,'+3-2 lpf1-450Hz lpf2-1700Hz sr-250Hz')),sense_stim_table.chan2) & ... % only use contacts 2-3
            sense_stim_table.duration > minutes(2) & ...  % only choose files over 2 minutes
            sense_stim_table.stimulation_on == 0;
        tbluse = sense_stim_table(idxkeep,:);
    elseif ss == 2 % stim on
        idxkeep = ...
            cellfun(@(x) any(strfind(x,'+3-2 lpf1-450Hz lpf2-1700Hz sr-500Hz')),sense_stim_table.chan2) & ... % only use contacts 2-3
            sense_stim_table.duration > minutes(2) & ...  % only choose files over 2 minutes
            sense_stim_table.stimulation_on == 1;
        tbluse = sense_stim_table(idxkeep,:);
        
        % XXXXXX GET RID OF THIS 
        % XXXXXX
        idxkeep = ...
            cellfun(@(x) any(strfind(x,'+3-1 lpf1-450Hz lpf2-1700Hz sr-250Hz')),sense_stim_table.chan2) & ... % only use contacts 2-3
            cellfun(@(x) any(strfind(x,'+1 -c ')),sense_stim_table.electrodes) & ... % only use contacts 2-3
            sense_stim_table.duration > minutes(2) & ...  % only choose files over 2 minutes
            sense_stim_table.stimulation_on == 1;
        tbluse = sense_stim_table(idxkeep,:);
        % XXXXXX
        % XXXXXX
        % XXXXXX

    end

    
    
    hfig = figure; 
    hfig.Color = 'w';
    for c = 1:4
        % get the data 
        fnuse = sprintf('key%dfftOut',c-1);
        hoursrec = hour(fftResultsTd.timeStart);
        idxhoursuse = (hoursrec >= 8) & (hoursrec <= 22);
        fftOut = fftResultsTd.(fnuse)(:,idxhoursuse);
        timesout = fftResultsTd.timeStart(idxhoursuse);
        % plot 
        subplot(2,2,c);
        plot(fftResultsTd.ff,fftOut,'LineWidth',0.01,'Color',[0 0 0.8 0.1]);
        xlabel('Freq (Hz)');
        ylabel('Power (log_1_0\muV^2/Hz)');
        cnfn = sprintf('chan%d',c);
        ttluse = tbluse.(cnfn){1};
        title(ttluse);
        xlim([1 100]);
        set(gca,'FontSize',16);
    end
    ttluse = sprintf('RCS 03 raw data %s stim',stimestate{ss});
    sgtitle(ttluse,'FontSize',24); 
    prfig.plotwidth           = 15;
    prfig.plotheight          = 10;
    prfig.figname             = sprintf('raw_data_BAD_SENSE_%s_stim',stimestate{ss});
    prfig.figdir             = fullfile(params.rootdir,'figures');
    prfig.figtype           = '-djpeg';
    plot_hfig(hfig,prfig)

    %% save plot 
    
    %% 
end

end