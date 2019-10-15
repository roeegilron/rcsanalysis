function plot_prctiles_from_psd_results(psdResultsFn)
%% this function uses a moving window to plot data from a session in
%% percentile form


%% params
[dirname,~] = fileparts(psdResultsFn);
mkdir(fullfile(dirname,'figures')); 
prfig.figdir = fullfile(dirname,'figures');  
prfig.figtype = '-djpeg';
prfig.resolution = 600;
prfig.closeafterprint = 0;
prfig.plotwidth           = 17;
prfig.plotheight          = 12;
prfig.figname             = 'perecentiles_all_from_psd_results';
%%
load(psdResultsFn); 

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
    for i = 1:10:98
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