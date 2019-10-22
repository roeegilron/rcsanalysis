function compute_beta_bursts(varargin)
if length(varargin)==1
    dirname = varargin{1}; 
    params.channel = 1; 
    params.freqs   = [17:21]; 
else
    dirname = varargin{1}; 
    params  = varargin{2};
end
[outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerOut,adaptiveTable] =  MAIN_load_rcs_data_from_folder(dirname);
sr = unique(outdatcomplete.samplerate);
if length(sr) == 1
    fn = sprintf('key%d',params.channel-1);
    dataIn = outdatcomplete.(fn);
    [b,a]        = butter(3,[params.freqs(1) params.freqs(end)] / (sr/2),'bandpass'); % user 3rd order butter filter
    y_filt       = filtfilt(b,a,dataIn); %filter all
    y_filt_hilbert       = abs(hilbert(y_filt));
    % plot 75th percentile 
    hfig = figure; 
    hold on; 
    plot(outdatcomplete.derivedTimes,y_filt,'LineWidth',0.5,'Color',[0 0 0.8 0.2]);
    plot(outdatcomplete.derivedTimes,y_filt_hilbert,'LineWidth',3,'Color',[0.8 0 0 0.6]);
    
    ttlsuse = sprintf('%d-%d Hz',params.freqs(1),params.freqs(end)); 
    title(ttlsuse); 
    ylabel('filtered data'); 
    xlims = get(gca,'XLim'); 
    prctilesDisplay = [10 25 50 75 90]; 
    percentilesDisplay = prctile(y_filt_hilbert,prctilesDisplay,'all');
    legendTitles{1} = 'filtered data'; 
    legendTitles{1} = 'hilbert data'; 
    % try to avearage on and off; 
    % on - anything lower than 15th percentile 
    % off - anything higher than 15th percentile 
    % take 75th percentiles of both of these conditions 
    % then average; 
    % on: 
    val = prctile(y_filt_hilbert,15);
    v75th1 = prctile(y_filt_hilbert( y_filt_hilbert <= val ),75); 
    
    val = prctile(y_filt_hilbert,85);
    v75th2 = prctile(y_filt_hilbert( y_filt_hilbert >= val ),75); 
    avg75Percentile = (v75th1 + v75th2)/2;
    
    for p = 1:length(percentilesDisplay)
        plot(xlims,[percentilesDisplay(p) percentilesDisplay(p)],'LineWidth',3); 
        legendTitles{p+2} = sprintf('%d percentile',prctilesDisplay(p)); 
    end
    legendTitles{end+1} = 'avg 75th percentile'; 
    plot(xlims,[avg75Percentile avg75Percentile],'LineWidth',3);
    set(gca,'FontSize',20)
    hfig.Color = 'w';
    legend(legendTitles); 
    figure;
    subplot(1,2,1);
    histogram(y_filt_hilbert,'Normalization','probability');
    subplot(1,2,2);
    histogram(y_filt_hilbert,'Normalization','cdf');
    
    % plot coeeficient of variation in 30 second chunks 
    CV = nanstd(y_filt_hilbert)/nanmean(y_filt_hilbert); 

else
    error('you have data from multiple sample rates')
end

end