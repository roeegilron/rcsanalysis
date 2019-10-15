function plot_clusters_from_psdresults(psdResultsFn)
%% this function uses a moving window to plot data from a session in
%% percentile form
close all;
addpath(genpath(fullfile(pwd,'toolboxes','cluster_dp')));
addpath(genpath(fullfile(pwd,'toolboxes','shadedErrorBar')));
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
%% get meta data; 

meta.subname = psdResultsFn(end-20:end-16);
meta.side    = psdResultsFn(end-15);
meta.times   = minutes(4); % time to skip

%% cluster params
prcl.frequse = 2:90;
%%
load(psdResultsFn); 
% instead of sampling every 15 seconds, sample every 4 minutes 
tod = fftResultsTd.timeStart; 
t = 1; 
tcnt = 1; 
tkeep = []; 
while t < length(tod) % while still time left 
    if t == 1 
        tkeep(tcnt) = t; 
        tcnt = tcnt +1;
        t = t+1;
    else
        if (tod(t) - tod(tkeep(end)) ) >= meta.times
            tkeep(tcnt) = t; 
            tcnt = tcnt +1;
            t = t+1;
        else
            t = t+1;
        end
    end
end
fftResultsTd.key0fftOut = fftResultsTd.key0fftOut(:,tkeep);
fftResultsTd.key1fftOut = fftResultsTd.key1fftOut(:,tkeep);
fftResultsTd.key2fftOut = fftResultsTd.key2fftOut(:,tkeep);
fftResultsTd.key3fftOut = fftResultsTd.key3fftOut(:,tkeep);
fftResultsTd.timeStart = fftResultsTd.timeStart(tkeep);
fftResultsTd.timeEnd = fftResultsTd.timeEnd(tkeep);


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
    w=1.5;
    wUpper(c) = w*(q75_test-q25_test)+q75_test;
    wLower(c) = q25_test - w*(q75_test-q25_test);
    idxWhisker(:,c) = (meanVals' < wUpper(c)) & (meanVals' > wLower(c));

end
idxkeep = idxWhisker(:,1) &  idxWhisker(:,2) & idxWhisker(:,3) & idxWhisker(:,4) ; 
close(hfig)




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
sgttluse = sprintf('%s %s %s skip',meta.subname,meta.side,meta.times);
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
    yUse = C(fidx,idxkeep); 
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
    C = fftResultsTd.(fn);
    [~,fidx] = intersect(fftResultsTd.ff, prcl.frequse);
    yUse = C(fidx,:);
    xUse = repmat(fftResultsTd.ff(fidx),1,size(yUse,2));

    % XXX 
    freq = freq(fidx);
    fftD = fftD(idxkeep,fidx);
    % XXX
    % get distance matrix 
    D = pdist(fftD','euclidean');
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



% plot the raw data 
hfig = figure;
colorsUse = {'-r','-g','-b','-go'};
for i = 1:4
    hsub(i) = subplot(2,2,i);
    hold on;
    unqclusters = unique(res(i).cl);
    [colormapuse] = cbrewer('Accent', length(unqclusters));
    for u = unqclusters
        plot(res(i).freq',res(i).fftD(res(i).cl==u,:),...
            'Color',[colormapuse(u,:) 0.4],'LineWidth',2);
    end
    title(chanNames{i});
    % legend({'cluster 1 ','cluster 2'});
    set(gca,'FontSize',20)
end
set(gcf,'Color','w');
ttluse = sprintf('%d 30 sec chunks - all Raw Data',sum(idxkeep));
sgtitle(sgtitle,'FontSize',30)
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