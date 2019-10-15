function plot_raw_data_prctiles(dirname)
%% this function uses a moving window to plot data from a session in
%% percentile form


%% params
mkdir(fullfile(dirname,'figures')); 
prfig.figdir = fullfile(dirname,'figures');  
prfig.figtype = '-djpeg';
prfig.resolution = 600;
prfig.closeafterprint = 0;
prfig.plotwidth           = 17;
prfig.plotheight          = 12;
prfig.figname             = 'perecentiles_all';
%%

ff = findFilesBVQX(dirname,'processedTDdata.mat'); 
if length(ff) > 1 
    error('too many files found'); 
elseif length(ff) == 0 
    error('did not find any processed files, need to run concatenate_and_plot_TD_data_SCS.m'); 
end
load(ff{1}); 

for c = 1:4
    start = tic;
    fn = sprintf('key%d',c-1);
    dat = [processedData.(fn)];
    sr = 250; 
    [fftOut,ff]   = pwelch(dat,sr,sr/2,0:1:sr/2,sr,'psd');
    fftResultsTd.([fn 'fftOut']) = log10(fftOut); 
    fprintf('chanel %d done in %.2f\n',c,toc(start))
end
fftResultsTd.ff = ff; 
fftResultsTd.timeStart = [processedData.timeStart];
fftResultsTd.timeEnd = [processedData.timeEnd];
dur = fftResultsTd.timeStart(end) - fftResultsTd.timeStart(1); 


% check for outliers 
hfig = figure;
idxWhisker = []; 
for c = 1:4 
    fn = sprintf('key%dfftOut',c-1); 
    hsub = subplot(2,2,c); 
    meanVals = mean(fftResultsTd.(fn)(40:60,:));
    boxplot(meanVals);
    q75_test=quantile(meanVals,0.75);
    q25_test=quantile(meanVals,0.25);
    w=2.0;
    wUpper(c) = w*(q75_test-q25_test)+q75_test;
    idxWhisker(:,c) = meanVals' < wUpper(c);

end
idxkeep = idxWhisker(:,1) &  idxWhisker(:,2) & idxWhisker(:,3) & idxWhisker(:,4) ; 
close(hfig)

% plot all data percentile 
hfig = figure;
ttls = {'STN 0-2','STN 1-3','M1 8-10','M1 9-11'}; 
for c = 1:4 
    hsub(c) = subplot(2,2,c); 
    hold on; 
    fn = sprintf('key%dfftOut',c-1); 
    C = fftResultsTd.(fn)(:,idxkeep);
    for i = 2:0.5:98
        y = prctile(C,i,2); 
        x = fftResultsTd(1).ff; 
        plot(hsub(c),x,y,'Color',[0 0 0.8 0.3],'LineWidth',0.1); 
    end
    set(gca,'YDir','normal') 
    ylabel('Power (log_1_0\muV^2/Hz)');
    title(ttls{c}); 
    xlabel('Frequency (Hz)');
    xlim([0 100]); 
    set(gca,'FontSize',20);
end
ttluse = sprintf('%s hours of data, %d 30 sec chunks',dur,sum(idxkeep));
sgtitle(ttluse,'FontSize',30)
linkaxes(hsub,'x');
set(gcf,'Color','w'); 
plot_hfig(hfig,prfig)


