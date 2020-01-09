function compareStimAndNoStimClustering_LongTermRecordings()
restoredefaultpath;
%% after stim 
close all; 
clear all; 
MainLegend = {'Off stimulation','On stimulation'}; 
dataLoc{1} = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/v08_all_home_data_before_stim/RCS02_all_home_data_processed/RCS02L'; % off stim 
dataLoc{2} = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/v13_home_data_stim/rcs_data/RCS02L/'; % on stim 
figDir     = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/presentations/figures';
% set ranges 
% off stim 
tlower(1,1) = datetime(2019,05,20,'TimeZone','America/Los_Angeles');
tupper(2,1) = datetime(2019,05,24,'TimeZone','America/Los_Angeles');
% on stim 
tlower(1,2) = datetime(2019,07,1,'TimeZone','America/Los_Angeles');
tupper(2,2) = datetime(2019,07,4,'TimeZone','America/Los_Angeles');
%% st some params
prfig.figdir = figDir;
prfig.figtype = '-djpeg';
prfig.resolution = 600;
prfig.closeafterprint = 0;
prfig.plotwidth           = 15;
prfig.plotheight          = 10;




%% compare stim no stim no clustering - for paper - preivous analysis belwo 
% avarege psds on 10 minute increments
pruse.minaverage = 10; 
pruse.maxgap = 120; % seconds 

for dd = 1:length(dataLoc)
    settings.rootdir = dataLoc{dd};
    settings.file    = 'psdResults.mat';
    load(fullfile(settings.rootdir, settings.file),'fftResultsTd')
    
    times = [fftResultsTd.timeStart];
    curTime = times(1);
    endTime = curTime + minutes(pruse.minaverage);
    cntavg = 1;
    psdResults = struct();
    while endTime < times(end)
        idxbetween = isbetween(times,curTime,endTime);
        if max(diff(times(idxbetween))) < seconds(pruse.maxgap)
            for c = 1:4
                fn = sprintf('key%dfftOut',c-1);
                psdResults.(fn)(cntavg,:) = mean(fftResultsTd.(fn)(:,idxbetween),2);
            end
            psdResults.timeStart(cntavg) = curTime;
            psdResults.timeEnd(cntavg) = endTime;
            psdResults.numberOfPsds(cntavg) = sum(idxbetween);
            cntavg = cntavg + 1;
        end
        curTime = endTime;
        endTime = curTime + minutes(pruse.minaverage);
    end
    psdResults.ff = fftResultsTd.ff;
    % get rid of outliers
    hfig = figure;
    idxWhisker = [];
    for c = 1:4
        fn = sprintf('key%dfftOut',c-1);
        hsub = subplot(2,2,c);
        meanVals = mean(psdResults.(fn)(:,40:60),2);
        boxplot(meanVals);
        q75_test=quantile(meanVals,0.75);
        q25_test=quantile(meanVals,0.25);
        w=2.0;
        wUpper(c) = w*(q75_test-q25_test)+q75_test;
        idxWhisker(:,c) = meanVals < wUpper(c);
    end
    idxkeep = idxWhisker(:,1) &  idxWhisker(:,2) & idxWhisker(:,3) & idxWhisker(:,4) ;
    sgtitle(sprintf('confriming outlier algo'),'FontSize',20);
%     close(hfig);
    
    % confirm that this is a good way to get rid of outliers
    hfig = figure;
    ttls = {'STN 0-2','STN 1-3','M1 8-10','M1 9-11'};
    for c = 1:4
        fn = sprintf('key%dfftOut',c-1);
        hsub = subplot(2,2,c);
        plot(psdResults.ff,psdResults.(fn)(idxkeep,:),'LineWidth',0.2,'Color',[0 0 0.8 0.2]);
        %             shadedErrorBar(psdResults.ff',psdResults.(fn)(:,idxkeep)',...
        %                 {@median,@(x) std(x)*1.96},...
        %                 'lineprops',{'r','markerfacecolor','r','LineWidth',2})
    end
    sgtitle(sprintf('confriming outlier algo psd '),'FontSize',20);
%     close(hfig);
    psdResults.idxkeep = idxkeep; 
    psdResultsBoth(dd) = psdResults; 
end
dirsave = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/results/long_term_stim_on_stim_off'; 
save(fullfile(dirsave,'psd_at_home_stim_on_vs_stim_off.mat'),'psdResultsBoth'); 

%% plot stim on / stim off with shaded error bars 
close all; clear all; clc; 
dirsave = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/results/long_term_stim_on_stim_off'; 
load(fullfile(dirsave,'psd_at_home_stim_on_vs_stim_off.mat'),'psdResultsBoth'); 
load('/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/pkg_data/figures/pkg_states RCS02 R pkg L _10_min_avgerage.mat')
addpath(genpath(fullfile(pwd,'toolboxes','shadedErrorBar')))

hfig = figure();
hfig.Color = 'w'; 
% on stim vs off stim 
% d = 1 - 
stimstate = {'off stim - mobile','off stim - imobile','on chronic stim'}; 
statesuse = {'off','on'};
colorsUse = [0.8 0 0;
          0   0.8 0,
          0   0   0.8];
titles = {'STN 0-2','STN 1-3','M1 8-10','M1 9-11'};
for c = 1:4
    hSub(c) = subplot(2,2,c); 
    hold on; 
    for d = 1:3
        fn = sprintf('key%dfftOut',c-1);
        if d >=3  % on stim 
            psdResults = psdResultsBoth(2);
            fftOut = psdResults.(fn)(psdResults.idxkeep,:);
            ff = psdResults.ff;
        else
            fftOutRaw = allDataPkgRcsAcc.(fn); 
            idxusestate = strcmp(allstates,statesuse{d});
            fftOut = fftOutRaw(idxusestate,:); 
            ff = psdResults.ff;
        end
        idxusefreq = ff >= 13 &  ff <= 30; 
        meanbetafreq{c,d} = mean(fftOut(:,idxusefreq),2);
        
        idxusefreq = ff >= 65 &  ff <= 85;
        meangammafreq{c,d} = mean(fftOut(:,idxusefreq),2);
        
        
        hsb = shadedErrorBar(ff,fftOut,{@median,@(x) std(x)*2});
        hsb.mainLine.Color = [colorsUse(d,:) 0.5];
        hsb.mainLine.LineWidth = 2;
        hsb.patch.MarkerFaceColor = colorsUse(d,:);
        hsb.patch.FaceColor = colorsUse(d,:);
        hsb.patch.EdgeColor = colorsUse(d,:);
        hsb.edge(1).Color = [colorsUse(d,:) 0.1];
        hsb.edge(2).Color = [colorsUse(d,:) 0.1];
        hsb.patch.EdgeAlpha = 0.1;
        hsb.patch.FaceAlpha = 0.1;
        xlabel('Frequency (Hz)');
        ylabel('Power (log_1_0\muV^2/Hz)');
        title(titles{c}); 
        set(gca,'FontSize',16); 
        hlines(d) = hsb.mainLine;
        xlim([0 100]);
    end
    legend(hlines,stimstate); 
%     totalhours = (length(psdResults.timeStart(psdResults.idxkeep))*10)/60;
%     fprintf('total hours %d %s\n',totalhours,stimstate{d});
end
sgtitle('RCS02 L','FontSize',25); 

figname = sprintf('on stim vs off stim_ %s %s v2','RCS02','L');
prfig.plotwidth           = 15;
prfig.plotheight          = 10;
prfig.figname             = figname;
prfig.figdir              = dirsave;
plot_hfig(hfig,prfig)

%% plot violin plots 
addpath(genpath(fullfile(pwd,'toolboxes','violin')));
toplot{1,1} = meanbetafreq{2,1}; % off off stim 
toplot{1,2} = meanbetafreq{2,2}; % off off stim 
toplot{1,3} = meanbetafreq{2,3}; % on stim 

hfig = figure;
hsb = subplot(1,1,1); 
hfig.Color = 'w'; 
hviolin  = violin(toplot);
hviolin(1).FaceColor = [0.8 0 0];
hviolin(1).FaceAlpha = 0.3;

hviolin(2).FaceColor = [0 0.8 0];
hviolin(2).FaceAlpha = 0.3;

hviolin(3).FaceColor = [0 0 0.8];
hviolin(3).FaceAlpha = 0.3;

ylabel('Average beta power'); 

hsb.XTick = [ 1 2 3]; 
hsb.XTickLabel  = {'off stim imobile', 'off stim mobile','on chornic stim'}; 
hsb.XTickLabelRotation = 45;

title('effect of chronic stim RCS02 L'); 

set(gca,'FontSize',16); 

figname = sprintf('on stim vs off stim_ %s %s violin','RCS02','L');
prfig.plotwidth           = 5;
prfig.plotheight          = 5;
prfig.figname             = figname;
prfig.figdir              = dirsave;
plot_hfig(hfig,prfig)


%% 

for s = 1:2
    settings.rootdir = dataLoc{s};
    settings.file    = 'psdResults.mat';
    load(fullfile(settings.rootdir, settings.file),'fftResultsTd')
    
    % trim data for time 
    idxBetween = isbetween(fftResultsTd.timeStart,tlower(1,s),tupper(2,s));
    for c = 1:4
        fn = sprintf('key%dfftOut',c-1);
        fftResultsTd.(fn) = fftResultsTd.(fn)(:,idxBetween);
    end
    fftResultsTd.timeStart = fftResultsTd.timeStart(idxBetween);
    fftResultsTd.timeEnd = fftResultsTd.timeEnd(idxBetween);
    
    
    % get raw data
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
    
    % trim data for outliers 
    for c = 1:4
        fn = sprintf('key%dfftOut',c-1);
        fftResultsTd.(fn) = fftResultsTd.(fn)(:,idxkeep);
    end
    fftResultsTd.timeStart = fftResultsTd.timeStart(idxkeep);
    fftResultsTd.timeEnd = fftResultsTd.timeEnd(idxkeep);
    
    fftResultsOut(s) = fftResultsTd;
end

% plot all data percentile 
ttls = {'STN 0-2','STN 1-3','M1 8-10','M1 9-11'};
for s = 1:2
    hfig = figure;
    fftResultsTd = fftResultsOut(s);
    for c = 1:4
        hsub(c) = subplot(2,2,c);
        hold on;
        fn = sprintf('key%dfftOut',c-1);
        C = fftResultsTd.(fn);
        for i = 2:0.5:98
            y = prctile(C,i,2);
            x = fftResultsTd(1).ff;
            plot(hsub(c),x,y,'Color',[0 0 0.8 0.5],'LineWidth',0.2);
        end
        set(gca,'YDir','normal')
        ylabel('Power');
        xlabel('Frequency (Hz)');
        set(gca,'FontSize',20);
    end
    totalData = sum(fftResultsTd.timeEnd - fftResultsTd.timeStart)/2;
    ttluse = sprintf('%s %s hours of data, %d 30 sec chunks',MainLegend{s},totalData,length(fftResultsTd.timeEnd));
    sgtitle(ttluse,'FontSize',30)
    linkaxes(hsub,'x');
    prfig.figname             = sprintf('percentiles_%s',MainLegend{s});
    plot_hfig(hfig,prfig)
end
close all;
return

%% clustering 
% run clustering on a subset so just two channgels
runOn = {'key1fftOut','key3fftOut'};
ttls = {'STN 1-3','M1 9-11'};
freqUse = 20:80; % frequencies used to do the clustering; 
for s = 2
    % prep data 
    fftSpecFreqs = [];
    fftResultsTd = fftResultsOut(s);
    % get data 
    for i = 1:length(runOn);
        cfnm = runOn{i};
        freq = fftResultsTd.ff;
        fftD = fftResultsTd.(cfnm)';
        
        % XXX
        idxFreq = ismember(freq,freqUse);
        idxFreqNum = find(idxFreq==1); 
        freqUse = freq(idxFreq); 
        fftSpecFreqs = [fftSpecFreqs, fftD(:,idxFreqNum)]; 
        % XXX
    end
        
        % get distance matrix
        D = pdist(fftSpecFreqs,'euclidean');
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
        % do cluster 
        [cl,halo] =  cluster_dp(distanceMat,cfnm);
        % save results
        res.cl = cl;
        res.halp = halo;
        res.freq = freqUse;
        res.fftD = fftSpecFreqs;
        res.D = D;
        res.distmat = distmat;
        res.idxkeep = idxkeep;
        fileNameUse     = sprintf('pstResultsClustering_from_%s_to_%s.mat',tlower(1,s),tupper(2,s));
        fnsaveclustring{s} = fullfile(dataLoc{s},fileNameUse);
        save(fnsaveclustring{s},'res','-v7.3')
        clear res; 
end

% plot stim on vs stim off 
hfig = figure;
cntplt = 1; 
res = struct();
for s = 1:2
    fftResultsTd = fftResultsOut(s);
    load(fnsaveclustring{s},'res')
    for i = 1:2
        subplot(2,2,cntplt);
        cntplt = cntplt+1; 
        hold on;
        cl1 = res.cl == 1;
        cl2 = res.cl == 2;
        freq = fftResultsTd.ff;
        fftD = fftResultsTd.(runOn{i});
        shadedErrorBar(freq',fftD(:,cl1)',{@median,@(x) std(x)*1.96},'lineprops',{'r','markerfacecolor','k'});
        shadedErrorBar(freq',fftD(:,cl2)',{@median,@(x) std(x)*1.96},'lineprops',{'b','markerfacecolor','k'});
        ylabel('Power (log_1_0\muV^2/Hz)');
        xlabel('Frequency (Hz)');
        xlim([0 100]);
        
        title(sprintf('%s %s',ttls{i},MainLegend{s}));
        % legend({'cluster 1 ','cluster 2'});
        set(gca,'FontSize',20)
    end
end
set(gcf,'Color','w');
sgtitle('Unsupervised clustering of patient states on/off stim','FontSize',30)
prfig.figname             = 'clustering_on_off_stim_rcs02';
plot_hfig(hfig,prfig)





    
    
    res(s).cl = cl;
    res(s).halp = halo;
    res(s).freq = freqUse;
    res(s).fftD = fftSpecFreqs;
    res(s).D = D;
    res(s).distmat = distmat;
    res(s).idxkeep = idxkeep;
    
    
    
    figure;
    for i = 1:4
        subplot(2,2,i);
        hold on;
        unqclusters = unique(resAll(1).cl)
        shadedErrorBar(res(i).freq',res(i).fftD(resAll(1).cl==1,:),{@median,@(x) std(x)*1.96},'lineprops',{'r','markerfacecolor','k'});
        shadedErrorBar(res(i).freq',res(i).fftD(resAll(1).cl==2,:),{@median,@(x) std(x)*1.96},'lineprops',{'b','markerfacecolor','k'});
        
        title(chanNames{i});
        % legend({'cluster 1 ','cluster 2'});
        set(gca,'FontSize',20)
    end
    set(gcf,'Color','w');
    

    
    fnsaveclustring = fullfile(settings.rootdir,'psdResultsClustering_July1-3.mat')
    save(fnsaveclustring,'res','-v7.3')




return 



















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
    ylim([0 80]); 
    set(gca,'YDir','normal') 
    ylabel('Frequency (Hz)');
    set(gca,'FontSize',20); 
end
linkaxes(hsub,'x'); 

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
fnsaveclustring = fullfile(settings.rootdir,'psdResultsClustering_July1-3.mat')
save(fnsaveclustring,'res','-v7.3');

figure;
for i = 1:4
    subplot(2,2,i);
    hold on;
    unqclusters = unique(res(i).cl)
    for u = unqclusters
        shadedErrorBar(res(i).freq',res(i).fftD(res(i).cl==u,:),{@median,@(x) std(x)*1.96},'lineprops',{'r','markerfacecolor','k'});
    end
    title(chanNames{i});
    % legend({'cluster 1 ','cluster 2'});
    set(gca,'FontSize',20)
end
set(gcf,'Color','w');

% try clustering eveything together based on specific freuqnces - beta for
% stn and gamma for m1 
cfnm = sprintf('key%dfftOut',i-1);
freq = fftResultsTd.ff;

% stim data rcs02 
% beta - 20:22 (these are ff idxs) 
% gamma - 65:68
% non stim data rcs02 
% beta 25 gamma 77 

fffMin(:,1) = rescale(mean(fftResultsTd.key0fftOut(25,idxkeep),1),0,1);
fffMin(:,2) = rescale(mean(fftResultsTd.key1fftOut(25,idxkeep),1),0,1);
fffMin(:,3) = rescale(mean(fftResultsTd.key2fftOut(77,idxkeep),1),0,1);
fffMin(:,4) = rescale(mean(fftResultsTd.key3fftOut(77,idxkeep),1),0,1);
% plot raw dat 
figure;
hsubuse(1) = subplot(2,1,1); 
scatter(fftResultsTd.timeStart(idxkeep), fffMin(:,2),20,[0 0 0.8 ],'filled','MarkerFaceAlpha',0.5)
ylabel('Beta power (a.u.)');
xlabel('Time');
set(gca,'FontSize',20);
title('STN beta power'); 

hsubuse(2) = subplot(2,1,2); 
scatter(fftResultsTd.timeStart(idxkeep), fffMin(:,3),20,[0.8 0 0 ],'filled','MarkerFaceAlpha',0.5)
ylabel('Gamma power (a.u.)');
xlabel('Time');
set(gca,'FontSize',20);
title('Cortex gamma power'); 
set(gcf,'Color','w'); 
linkaxes(hsubuse,'x'); 

% get distance matrix 
D = pdist(fffMin,'euclidean');
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
[cl,halo] =  cluster_dp(distanceMat);
resAll(1).cl = cl;
resAll(1).halp = halo;
resAll(1).freq = freq;
resAll(1).fftD = fftD;
resAll(1).D = D;
resAll(1).distmat = distmat;
resAll(1).idxkeep = idxkeep;


figure;
for i = 1:4
    subplot(2,2,i);
    hold on;
    unqclusters = unique(resAll(1).cl)
    shadedErrorBar(res(i).freq',res(i).fftD(resAll(1).cl==1,:),{@median,@(x) std(x)*1.96},'lineprops',{'r','markerfacecolor','k'});
    shadedErrorBar(res(i).freq',res(i).fftD(resAll(1).cl==2,:),{@median,@(x) std(x)*1.96},'lineprops',{'b','markerfacecolor','k'});
    
    title(chanNames{i});
    % legend({'cluster 1 ','cluster 2'});
    set(gca,'FontSize',20)
end
set(gcf,'Color','w');

% XXX
freq = freq(1:100);
fftD = fftD(idxkeep,1:100);

end