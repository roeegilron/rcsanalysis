function plot_raw_data_spectral_with_acc(dirname)

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

% proces or load the data 
if exist(fullfile(dirname,'psdResultsIndivid.mat'),'file')
    load(fullfile(dirname,'psdResultsIndivid.mat'),'fftResultsTd','idxkeep','dur');
else
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
    save(fullfile(dirname,'psdResultsIndivid.mat'),'fftResultsTd','idxkeep','dur');
end

%% process actigraphy data 
if exist(fullfile(dirname,'accResults.mat'),'file')
    load(fullfile(dirname,'accResults.mat'));
else
    load(fullfile(dirname,'processedAccData.mat'));
    for a = 1:size(accData,2)
        start = tic;
        dat = [];
        dat(:,1) = accData(a).XSamples;
        dat(:,2) = accData(a).YSamples;
        dat(:,3) = accData(a).ZSamples;
        datOut = processActigraphyData(dat,64);
        accMean  = mean(datOut);
        accVari  = mean(var(dat));
        accResults(a).('accMean') = accMean;
        accResults(a).('accVari') = accVari;
        accResults(a).('timeStart') = accData(a).timeStart;
        accResults(a).('timeEnd') = accData(a).timeEnd;
    end
    
    % check for outliers
    hfig = figure;
    idxWhisker = [];
    boxplot([accResults.accMean]);
    meanVals = [accResults.accMean];
    q75_test=quantile(meanVals,0.75);
    q25_test=quantile(meanVals,0.25);
    w=2.0;
    wUpper(1) = w*(q75_test-q25_test)+q75_test;
    idxWhisker(:,1) = meanVals' < wUpper;
    idxkeepAcc = idxWhisker;
    close(hfig)
    save( fullfile(dirname,'accResults.mat'),'params','accResults','idxkeepAcc')
end
close all;

% plot all data spectral 
hfig = figure;
ttls = {'STN 0-2','STN 1-3','M1 8-10','M1 9-11'}; 
for c = 1:4 
    hsub(c) = subplot(4,1,c); 
    fn = sprintf('key%dfftOut',c-1); 
    C = fftResultsTd.(fn)(:,idxkeep);
    y = fftResultsTd.ff;
    imagesc(C);
    title(ttls{c});
    set(gca,'YDir','normal') 
    ylabel('Frequency (Hz)');
    set(gca,'FontSize',20); 
end
dataKeep = sum(fftResultsTd.timeEnd(idxkeep) - fftResultsTd.timeStart(idxkeep));
ttluse = sprintf('%s hours of data, %d 30 sec chunks',dur,sum(idxkeep));
sgtitle(ttluse,'FontSize',30)
hfig.Color = 'w';
linkaxes(hsub,'x');


% plot all data spectral time domai n
hfig = figure;
ttls = {'STN 0-2','STN 1-3','M1 8-10','M1 9-11'}; 
for c = 1:4 
    hsub(c) = subplot(5,1,c); 
    fn = sprintf('key%dfftOut',c-1); 
    C = fftResultsTd.(fn)(:,idxkeep);
    y = fftResultsTd.ff;
    freqRepd = repmat(y,1,size(C,2));
    t = fftResultsTd.timeStart(idxkeep); 
    timsRepd = repmat(fftResultsTd.timeStart(idxkeep),size(C,1),1);
    hp = pcolor(seconds(timsRepd-timsRepd(1)),freqRepd,C); 
    hp.EdgeColor = 'none';
    axis xy;
    axis tight; 
    colorbar off; 
    shading interp
    title(ttls{c});
    ylim([0 40]);
    set(gca,'YDir','normal') 
    ylabel('Frequency (Hz)');
    set(gca,'FontSize',20); 
    
end
hsub(5) = subplot(5,1,5); 
t = [accResults.timeStart];
t = seconds(t - t(1));
accMeans = [accResults.accMean];
plot(t,accMeans); 
xlabel('seconds'); 
ylabel('acc mean (a.u.)'); 
linkaxes(hsub,'x');
set(gca,'FontSize',20);
hfig.Color = 'w';
ttluse = sprintf('%s hours of data, %d 30 sec chunks',dur,sum(idxkeep));
sgtitle(ttluse,'FontSize',30)

% plot scatterp plots of the data 
hfig = figure;
% on stim 
% stn = 16 4 
% m1  = 24 7 

% stn =  20 7  key 1 
% m1 =   24 5  key 3
%%
hfig = figure; 
hsub(1) = subplot(3,1,1); 
hold on; 
idxuse = 2e3:3e3; % on stim 
idxuse = 1310:1:2500; % off stim 
y = rescale(fftResultsTd.key1fftOut(8,idxkeep),0,0.5);
x = fftResultsTd.timeStart(idxkeep);
scatter(x(idxuse),y(idxuse),10,'r','filled','MarkerFaceAlpha',0.6);
% scatter(idxuse,y(idxuse),10,'r','filled','MarkerFaceAlpha',0.6);

hold on; 
y = rescale(fftResultsTd.key1fftOut(21,idxkeep),0.5,1);
x = fftResultsTd.timeStart(idxkeep);
scatter(x(idxuse),y(idxuse),10,'b','filled','MarkerFaceAlpha',0.6);
legend({'delta - 7Hz','beta 20hz'});
title('STN'); 
set(gca,'FontSize',18); 


hsub(2) = subplot(3,1,2); 
hold on; 
y = rescale(fftResultsTd.key3fftOut(6,idxkeep),0,0.5);
x = fftResultsTd.timeStart(idxkeep);
scatter(x(idxuse),y(idxuse),10,'r','filled','MarkerFaceAlpha',0.6);

hold on; 
y = rescale(fftResultsTd.key3fftOut(25,idxkeep),0.5,1);
x = fftResultsTd.timeStart(idxkeep);
scatter(x(idxuse),y(idxuse),10,'b','filled','MarkerFaceAlpha',0.6);
legend({'delta/alpha - 5Hz','beta 24hz'});
title('M1'); 
set(gca,'FontSize',18); 
xlims = get(gca,'XLim');

hsub(3) = subplot(3,1,3); 
t = [accResults.timeStart];
accMeans = [accResults.accMean];
plot(t,accMeans); 
xlabel('seconds'); 
ylabel('acc mean (a.u.)'); 
linkaxes(hsub,'x');
title('actigraphy');
set(gca,'FontSize',18);
hfig.Color = 'w';
set(gca,'XLim',xlims);
ttluse = sprintf('%s hours of data, %d 30 sec chunks',dur,sum(idxkeep));
sgtitle(ttluse,'FontSize',30)



end