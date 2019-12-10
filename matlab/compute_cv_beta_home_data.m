function compute_cv_beta_home_data()
cnt = 1; 
restoredefaultpath
addpath(fullfile(pwd,'toolboxes','fieldtrip'));
ft_defaults();
 
% RCS06 
dataFiles{cnt}  = '/Volumes/RCS_DATA/RCS06/v10_3_week_before_stimon/data_dump/SummitContinuousBilateralStreaming/RCS06L/processedData.mat'; 
dateChoose{cnt} = datetime('Oct 30 2019','Format','MMM dd yyyy');
peaks(cnt,:)  = [18 22];
channel(cnt) = 1;
figdir{cnt} = '/Volumes/RCS_DATA/RCS06/v10_3_week_before_stimon/data_dump/SummitContinuousBilateralStreaming/RCS06L/figures';
patient{cnt} = 'RCS06 L';
cnt = cnt+1; 

% RCS07
dataFiles{cnt}  = '/Volumes/Samsung_T5/RCS07/v14_data_dump/SummitContinuousBilateralStreaming/RCS07L/processedData.mat'; 
dateChoose{cnt} = datetime('Sep 20 2019','Format','MMM dd yyyy');
peaks(cnt,:)  = [17 21];
channel(cnt) = 1;
figdir{cnt} = '/Volumes/Samsung_T5/RCS07/v14_data_dump/SummitContinuousBilateralStreaming/RCS07L/figures';
patient{cnt} = 'RCS07 L';
cnt = cnt+1; 

% RCS05
dataFiles{cnt}  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS05/v05_3week/data_dump/SummitContinuousBilateralStreaming/RCS05L/processedData.mat'; 
dateChoose{cnt} = datetime('Jul 26 2019','Format','MMM dd yyyy');
peaks(cnt,:)  = [17 21];
channel(cnt) = 0;
figdir{cnt} = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS05/v05_3week/data_dump/SummitContinuousBilateralStreaming/RCS05L/figures';
patient{cnt} = 'RCS05 L';
cnt = cnt+1; 

%RCS02
dataFiles{cnt}  = '/Volumes/Samsung_T5/RCS02/RCS02_all_home_data_processed/data/RCS02L/processedData.mat'; 
dateChoose{cnt} = datetime('May 21 2019','Format','MMM dd yyyy');
peaks(cnt,:)  = [17 20];
channel(cnt) = 0;
figdir{cnt} = '/Volumes/Samsung_T5/RCS02/RCS02_all_home_data_processed/data/RCS02L/figures';
patient{cnt} = 'RCS02 L';
cnt = cnt+1; 


for d = 3%1:length(dataFiles)
    startall = tic;
    load(dataFiles{d}); 
    fprintf('data loaded in %.2f seconds\n',toc(startall));
    times = [tdProcDat.timeStart];
    timeStart = dateChoose{d}; 
    timeEnd = dateChoose{d}; 
    timeStart.TimeZone = times.TimeZone;
    timeStart.Format = times.Format;
    timeEnd.TimeZone = times.TimeZone;
    timeEnd.Format = times.Format;
    timeEnd = timeEnd+hours(23.9); 
    idxkeep = isbetween(times,timeStart,timeEnd);
    
    for i = 1:length( tdProcDat )
        for c = 1:4
            fn = sprintf('key%d',c-1);
            if size(tdProcDat(i).(fn),1) < size(tdProcDat(i).(fn),2)
                tdProcDat(i).(fn) = tdProcDat(i).(fn)';
            end
        end
    end
    

    
    processedData = tdProcDat(idxkeep);
    clear tdProcDat
    
    sr = 250;
    timesUse = [processedData.timeStart];
    fn = sprintf('key%d',channel(d));
    dat = [processedData.(fn)];
    

    
    % compute lag coherence 
    if exist(fullfile(figdir{d},'lagged_coherence_m.mat'),'file')
        load(fullfile(figdir{d},'lagged_coherence_m.mat'),'lagged_coh','foi','lags','explanations');
    else
        foi  = [peaks(d,1):1:peaks(d,2)];
        lags = [3:1:10]; % units - cycles
        dataS.label      = {'stn'};
        dataS.fsample    = 250;           % sampling frequency in Hz, single number
        dataS.trial      = {dat(:,1)'};           % cell-array containing a data matrix for each
        % trial (1*Ntrial), each data matrix is a Nchan*Nsamples matrix
        dataS.time       = {[0:1:(size(dat(:,1),1)-1)]./250};
        
        
        dataS.trial      = {dat'};
        
        for ii = 1:size(dat,2); dataS.label{ii} = sprintf('stn%d',ii); end;
        
        lagged_coh = compute_lagged_coherence(dataS, foi, lags);
        explanations = {'dataS has structure of coherence values, foi, lags'};
        save(fullfile(figdir{d},'lagged_coherence_m.mat'),'lagged_coh','foi','lags','explanations');
    end
    fprintf('compuation finished in %.2f seconds\n',toc(startall));
    
    % compute beta
    [b,a]        = butter(3,[peaks(d,1) peaks(d,2)] / (sr/2),'bandpass'); % user 3rd order butter filter
    y_filt       = filtfilt(b,a,dat); %filter all
    y_filt_hilbert       = abs(hilbert(y_filt));
    % comptute cv of beta
    CV = std(y_filt_hilbert,0,1)./mean(y_filt_hilbert,1);
    
    % plot diffent lags 
    for lg = 1:size(lagged_coh,3)
        
        % plot data
        hfig = figure;
        % beta power
        hsub(1) = subplot(4,1,1);
        scatter(timesUse,mean(y_filt_hilbert,1),10,[0 0 0.8],'filled','MarkerFaceAlpha',0.4,'MarkerEdgeColor','none');
        ttluse = sprintf('beta %d-%d Hz',peaks(d,1),peaks(d,2));
        title(ttluse);
        set(gca,'FontSize',16);
        % coeeficienat of variation of beta
        hsub(2) = subplot(4,1,2);
        scatter(timesUse,CV,10,[0.8 0 0],'filled','MarkerFaceAlpha',0.4,'MarkerEdgeColor','none');
        title('beta CV');
        linkaxes(hsub,'x');
        set(gca,'FontSize',16);
        % lagged coherence
        hsub(3) = subplot(4,1,3);
        freqidx = ceil(length(foi)/2);
        scatter(timesUse,lagged_coh(:,freqidx,lg),10,[0.95 0.6 0],'filled','MarkerFaceAlpha',0.4,'MarkerEdgeColor','none');
        xlabel('times');
        ylabel('lagged coherence');
        ttluse = sprintf('lagged coherence (%d cycles) freq (%dHz)',lags(lg),foi(freqidx));
        title(ttluse);
        set(gca,'FontSize',16);
        % correlation between cv and power
        subplot(4,1,4);
        scatter(CV,mean(y_filt_hilbert,1),10,[0 0.8 0],'filled','MarkerFaceAlpha',0.4,'MarkerEdgeColor','none');
        xlabel('CV');
        ylabel('beta power');
        title('cv (x) beta (y)');
        set(gca,'FontSize',16);
        hfig.Color = 'w';
        
        figtitle = sprintf('%s %s',patient{d},dateChoose{d});
        sgtitle(figtitle);
        
        % plot jpeg of figure
        prfig.plotwidth           = 15;
        prfig.plotheight          = 15*0.6;
        prfig.figdir              = figdir{d};
        prfig.figtype             = '-djpeg';
        prfig.closeafterprint     = 0;
        prfig.resolution          = 300;
        startstr = 'cv_vs_beta';
        figstr = sprintf('%s_%s_%s_lag_%0.2d',startstr,patient{d},dateChoose{d},lags(lg));
        prfig.figname  = figstr;
        plot_hfig(hfig,prfig);
        close(hfig);
    end
    clear processedData lagged_coh
end
end