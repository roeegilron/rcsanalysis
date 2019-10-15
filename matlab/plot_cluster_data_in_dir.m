function plot_cluster_data_in_dir(dirname)
%% params
mkdir(fullfile(dirname,'figures')); 
prfig.figdir = fullfile(dirname,'figures');  
prfig.figtype = '-djpeg';
prfig.resolution = 600;
prfig.closeafterprint = 0;
prfig.plotwidth           = 17;
prfig.plotheight          = 12;
prfig.figname             = 'perecentiles_all';
%% cluster params
prcl.frequse = 2:90;
%% add stuff to path 
addpath(genpath(fullfile(pwd,'toolboxes','cluster_dp')));
addpath(genpath(fullfile(pwd,'toolboxes','shadedErrorBar')));
%%

ff = findFilesBVQX(dirname,'processedTDdata.mat'); 
if length(ff) > 1 
    error('too many files found'); 
elseif length(ff) == 0 
    error('did not find any processed files, need to run concatenate_and_plot_TD_data_SCS.m'); 
end
load(ff{1}); 

tdFile = fullfile(dirname,'RawDataTD.mat');
load(tdFile); 
sr = unique(outdatcomplete.samplerate);

fnsv = fullfile(dirname,'psdResultsInDir.mat');
if exist(fnsv,'file')
    load(fnsv)
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
    save(fnsv,'fftResultsTd');
end

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
    wLower(c) = q25_test - w*(q75_test-q25_test);
    idxWhisker(:,c) = (meanVals' < wUpper(c)) & (meanVals' > wLower(c));
end
idxkeep = idxWhisker(:,1) &  idxWhisker(:,2) & idxWhisker(:,3) & idxWhisker(:,4) ; 
close(hfig)

tStart = datetime(fftResultsTd.timeStart(1),'Format','dd-MMM-yyyy HH:mm');
tEnd   = datetime(fftResultsTd.timeStart(end),'Format','dd-MMM-yyyy HH:mm');
dur    = tEnd - tStart;
sgttluse = sprintf('%s - %s (dur %s)',tStart,tEnd,dur);


% plot all data spectral 
hfig = figure;
ttls = {'STN 0-2','STN 1-3','M1 8-10','M1 9-11'}; 
for c = 1:4 
    hsub(c) = subplot(4,1,c); 
    fn = sprintf('key%dfftOut',c-1); 
    C = fftResultsTd.(fn)(:,idxkeep);
    imagesc(C);
    title(ttls{c});
    set(gca,'YDir','normal') 
    ylabel('Frequency (Hz)');
    set(gca,'FontSize',20); 
end
hfig.Color = 'w'; 
sgtitle(sgttluse,'FontSize',20);
prfig.figname = 'raw_data_spectral_psd_results'; 
plot_hfig(hfig,prfig)
close(hfig); 


% plot the raw data 
hfig = figure;
chanNames = {'STN 0-2','STN 1-3','M1 8-10','M1 9-11'};
for c = 1:4 
    fn = sprintf('key%dfftOut',c-1); 
    hsub = subplot(2,2,c); 
    C = fftResultsTd.(fn);
    [~,fidx] = intersect(fftResultsTd.ff, prcl.frequse);
    yUse = C(fidx,:); 
    xUse = repmat(fftResultsTd.ff(fidx),1,size(yUse,2));
    plot(xUse,yUse,'LineWidth',0.3,'Color',[0 0 0.8 0.1]); 
       title(chanNames{c});
    set(gca,'YDir','normal') 
    ylabel('Power (log_1_0\muV^2/Hz)');
    xlabel('Frequency (Hz)');
    set(gca,'FontSize',20); 
end
hfig.Color = 'w'; 
sgtitle(sgttluse,'FontSize',20);
prfig.figname = 'raw_data_psds'; 
plot_hfig(hfig,prfig)
close(hfig); 

%% clustering 
% cluster each channel invidivudally 
chanNames = {'STN 0-2','STN 1-3','M1 8-10','M1 9-11'};
for i = 1:4
    cfnm = sprintf('key%dfftOut',i-1);
    freq = fftResultsTd.ff;
    
    fftD = fftResultsTd.(cfnm)';
    
    % XXX 
    freq = freq(2:90);
    fftD = fftD(idxkeep,2:90);
    % XXX
    
    % get distance matrix 
    D = pdist(fftD,'euclidean');
    distmat = squareform(D); 
    distMatrices = squareform(distmat,'tovector');
    % get row indices 
    rows = repmat(1:size(distmat,1),size(distmat,2),1)';
    idx = logical(eye(size(rows)));
    rows(idx) = 0; 
    rowsColmn = squareform(rows,'tovector');
    % get column idices 
    colmns = repmat(1:size(distmat,1),size(distmat,2),1);
    idx = logical(eye(size(colmns)));
    colmns(idx) = 0; 
    colsColmn = squareform(colmns,'tovector');
    % save data for rodriges 
    distanceMat = [];
    distanceMat(:,1) = rowsColmn; 
    distanceMat(:,2) = colsColmn;
    distanceMat(:,3) = distMatrices; 
    [cl,halo] =  cluster_dp(distanceMat,cfnm); 
    res(i).cl = cl; 
    res(i).halp = halo;
    res(i).freq = freq; 
    res(i).fftD = fftD; 
    res(i).D = D; 
    res(i).distmat = distmat; 
    res(i).idxkeep = idxkeep;
end

fnsaveclustring = fullfile(dirname,'psdResultsClustering.mat');
save(fnsaveclustring,'res');
close all; 

% plot the raw data 
hfig = figure;
colorsUse = {'-r','-g','-b','-go'};
for i = 1:4
    hsub(i) = subplot(2,2,i);
    hold on;
    unqclusters = unique(res(i).cl);
    [colormapuse] = cbrewer('Pastel1', length(unqclusters));
    for u = unqclusters
        plot(res(i).freq',res(i).fftD(res(i).cl==u,:),...
            'Color',[colormapuse(u,:) 0.2],'LineWidth',0.5);
    end
    title(chanNames{i});
    % legend({'cluster 1 ','cluster 2'});
    set(gca,'FontSize',20)
end
set(gcf,'Color','w');
ttluse = sprintf('%s hours of data, %d 30 sec chunks - all Raw Data',dur,sum(idxkeep));
sgtitle(ttluse,'FontSize',30)
linkaxes(hsub,'x');
set(gcf,'Color','w');
prfig.figname = 'raw_data_by_cluster_each_area_sep'; 
plot_hfig(hfig,prfig)


hfig = figure;
colorsUse = {'-r','-g','-b','-go'};
for i = 1:4
    subplot(2,2,i);
    hold on;
    unqclusters = unique(res(i).cl);
    for u = unqclusters
        shadedErrorBar(res(i).freq',res(i).fftD(res(i).cl==u,:),{@median,@(x) std(x)*1.96},...
            'lineprops',{colorsUse{u},'markerfacecolor',colorsUse{u}(2) });
    end
    title(chanNames{i});
    % legend({'cluster 1 ','cluster 2'});
    set(gca,'FontSize',20)
end
set(gcf,'Color','w');
sgtitle(sgttluse,'FontSize',20);
prfig.figname = 'raw_data_by_cluster_each_area_sep_shaded_error_bars'; 
plot_hfig(hfig,prfig)
close(hfig); 

% cluster all channels together together 

% rescale all the channels between 0-1 and cluster together 
BrowAll = []; 
BcolAll = []; 
clusterIdx = [];
for i = 1:4
    cfnm = sprintf('key%dfftOut',i-1);
    freq = fftResultsTd.ff;
    freq = freq(2:90);
    fftD = fftResultsTd.(cfnm)';
    fftD = fftD(idxkeep,2:90);
    % rescale each column to intreval 0,1 
    rowmin = min(fftD,[],2);
    rowmax = max(fftD,[],2);
    Brow = rescale(fftD,'InputMin',rowmin,'InputMax',rowmax);
    BrowAll = [BrowAll ; Brow];
    colmin = min(fftD);
    colmax = max(fftD);
    Bcol = rescale(fftD,'InputMin',colmin,'InputMax',colmax);
    BcolAll = [BcolAll ; Bcol];
    clusterIdx = [clusterIdx; repmat(i,size(Bcol,1),1)];
end


% get distance matrix
D = pdist(BrowAll,'euclidean');
distmat = squareform(D);
distMatrices = squareform(distmat,'tovector');
% get row indices
rows = repmat(1:size(distmat,1),size(distmat,2),1)';
idx = logical(eye(size(rows)));
rows(idx) = 0;
rowsColmn = squareform(rows,'tovector');
% get column idices
colmns = repmat(1:size(distmat,1),size(distmat,2),1);
idx = logical(eye(size(colmns)));
colmns(idx) = 0;
colsColmn = squareform(colmns,'tovector');
% save data for rodriges
distanceMat = [];
distanceMat(:,1) = rowsColmn;
distanceMat(:,2) = colsColmn;
distanceMat(:,3) = distMatrices;
[cl,halo] =  cluster_dp(distanceMat,cfnm);
resAll(1).cl = cl;
resAll(1).halp = halo;
resAll(1).freq = freq;
resAll(1).fftD = fftD;
resAll(1).D = D;
resAll(1).distmat = distmat;
resAll(1).idxkeep = idxkeep;

% plot the raw data 
hfig = figure;
colorsUse = {'-r','-g','-b','-go'};
for i = 1:4
    hsub(i) = subplot(2,2,i);
    hold on;
    unqclusters = unique(res(1).cl);
    [colormapuse] = cbrewer('Pastel1', length(unqclusters));
    resAll.cl
    for u = unqclusters
        plot(res(i).freq',res(i).fftD(resAll.cl(clusterIdx==i) ==u,:),...
            'Color',[colormapuse(u,:) 0.2],'LineWidth',0.5);
    end
    title(chanNames{i});
    % legend({'cluster 1 ','cluster 2'});
    set(gca,'FontSize',20)
end
set(gcf,'Color','w');
ttluse = sprintf('%s hours of data, %d 30 sec chunks - all Raw Data',dur,sum(idxkeep));
sgtitle(ttluse,'FontSize',30)
linkaxes(hsub,'x');
set(gcf,'Color','w');
prfig.figname = 'raw_data_by_cluster_all_areas_together'; 
plot_hfig(hfig,prfig)

