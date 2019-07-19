function compareStimLongTermRecordings()
addpath(genpath(fullfile(pwd,'toolboxes/'))); 
%% after stim 
close all; 
settings.rootdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/v13_home_data_stim/rcs_data/RCS02L/'; 
settings.file    = 'psdResults.mat'; 
load(fullfile(settings.rootdir, settings.file))
betaIdxUse = 14:30;

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


figure;
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

%data after stim
rawDataAfterStim    = fftResultsTd.key1fftOut(:,idxkeep); 


totalDataOn = sum(fftResultsTd.timeEnd(idxkeep) - fftResultsTd.timeStart(idxkeep));
rawPowerBetaOnStim = mean(fftResultsTd.key1fftOut(betaIdxUse,idxkeep)); 
powerBetaOnStim = rawPowerBetaOnStim ./  median(median(fftResultsTd.key1fftOut(5:45,idxkeep))); 
close(hfig); 

settings.rootdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/v08_all_home_data_before_stim/RCS02_all_home_data_processed/RCS02L/'; 
settings.file    = 'psdResults.mat'; 
load(fullfile(settings.rootdir, settings.file));


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
close(hfig); 


rawPowerBetaOffStim = mean(fftResultsTd.key1fftOut(betaIdxUse,idxkeep)); 
powerBetaOffStim = rawPowerBetaOffStim ./ median(median(fftResultsTd.key1fftOut(5:45,idxkeep))); 
totalDataOff = sum(fftResultsTd.timeEnd(idxkeep) - fftResultsTd.timeStart(idxkeep));

figure;
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

rawDataBeforeStim    = fftResultsTd.key1fftOut(:,idxkeep); 

close all;

groups = [ones(size(powerBetaOnStim,2),1) ; ones(size(powerBetaOffStim,2),1).*2 ];
x      = [powerBetaOnStim' ; powerBetaOffStim'];

figure;
hbox = boxplot(x,groups);
xticklabels({'on stim' , 'off stim'}); 
ylabel('normalized beta'); 
set(gca,'FontSize',20); 
set(gcf,'Color','w')
title('on stim (90 hours) vs off stim (154 hours) - beta STN'); 

figure;
hold on; 
histogram(rawPowerBetaOffStim,'Normalization','probability','BinWidth',0.1); 
histogram(rawPowerBetaOnStim,'Normalization','probability','BinWidth',0.1); 
legend({'off stim','on stim'}); 
ttluse = sprintf('Beta (%d-%dHz) on/off stim - STN',betaIdxUse(1),betaIdxUse(end));
title(ttluse); 
set(gcf,'Color','w')
set(gca,'FontSize',20)


figure; 
hold on; 
shadedErrorBar(fftResultsTd.ff,rawDataBeforeStim',{@median,@(x) std(x)*1.96},'lineprops',{'r','markerfacecolor','k','LineWidth',2});
shadedErrorBar(fftResultsTd.ff,rawDataAfterStim',{@median,@(x) std(x)*1.96},'lineprops',{'b','markerfacecolor','k','LineWidth',2});
legend({'before stim','after stim'}); 
ylabel('Probability'); 
title('on stim (90 hours) vs off stim (154 hours) - STN'); 
set(gcf,'Color','w')
set(gca,'FontSize',20)


return;
%% clustering 
chanNames = {'STN 0-2','STN 1-3','M1 8-10','M1 9-11'};
for i = 1:4
    cfnm = sprintf('key%dfftOut',i-1);
    freq = fftResultsTd.ff;
    
    fftD = fftResultsTd.(cfnm)';
    
    % XXX 
    freq = freq(1:100);
    fftD = fftD(idxkeep,1:100);
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
fnsaveclustring = fullfile(settings.rootdir,'psdResultsClustering.mat'); 
save(fnsaveclustring,'res');

figure; 
hold on; 
shadedErrorBar(freq',fftD(cl==1,:),{@median,@(x) std(x)*1.96},'lineprops',{'r','markerfacecolor','k'});
shadedErrorBar(freq',fftD(cl==2,:),{@median,@(x) std(x)*1.96},'lineprops',{'g','markerfacecolor','k'});
legend({'cluster 1 ','cluster 2'}); 
set(gca,'FontSize',20)


end