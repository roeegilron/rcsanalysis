function clustering_algo()
%% load data
clear all;
resdir  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v06-home-visit-3-week/results/sleep_data';
load(fullfile(resdir,'sleepChunks2.mat'),'sleepChunks');
load(fullfile(resdir,'sleepChunks2idxkeep.mat'),'idxkeep');
sleepChunks = sleepChunks(logical(idxkeep),:);
load('clidxs.mat'); 
load('distanceMatrices_sleep.mat','res');

%% compute distnaces rodriguz algorithem 
% sleep chunks after nov 8th
% only use frequences up to 50hz. 
idxuse = sleepChunks.time >   datetime('08-Nov-2018 00:22:02.091','TimeZone','America/Los_Angeles');
sleepChunks = sleepChunks(idxuse,:);
chanNames = {'STN 0-2','STN 1-3','M1 8-10','M1 9-11'};
for i = 1:4
    cfnm = sprintf('chan%d_fftOut',i);
    freq = sleepChunks.freq;
    
    fftD = sleepChunks.(cfnm);
    
    % XXX 
    freq = freq(:,1:40);
    fftD = fftD(:,1:40);
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
end
save('distanceMatrices_sleep_after_nov_8th_upTo_40Hz.mat','res');
%% plot raw data
prfig.figdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v06-home-visit-3-week/figures/sleep_analysis_2';
prfig.figtype = '-djpeg';
prfig.plotwidth           = 15;
prfig.plotheight          = 15; 

close all;
hfig = figure;
chanNames = {'STN 0-2','STN 1-3','M1 8-10','M1 9-11'};
alpha = 0.08; 
clrs      = [0.8 0 0 alpha; 0.8 0 0 alpha;  0 0 0.8 alpha; 0 0 0.8 alpha];
for i = 1:4
    hsub(i) = subplot(2,2,i);
    cfnm = sprintf('chan%d_fftOut',i);
    freq = sleepChunks.freq;
    fftD = sleepChunks.(cfnm);
    % XXX 
    freq = freq(:,1:40);
    fftD = fftD(:,1:40);
    % XXX
    plot(freq', fftD','LineWidth',0.001,'Color',clrs(i,:));
    title(chanNames{i});
    ylabel(hsub(i),'Power (log_1_0\muV^2/Hz)');
    xlabel('Frquency (Hz)');
    set(hsub(i),'FontSize',16);
end
prfig.figname = 'raw_data_clustering_25_hours_up_to_40hz'; 

plot_hfig(hfig,prfig)

%% plot data with clusters 

close all;
hfig = figure;
chanNames = {'STN 0-2','STN 1-3','M1 8-10','M1 9-11'};
alpha = 0.08; 
clrs      = [60, 186, 84 ; 244, 194, 13 ;  219, 50, 54 ; 72, 133, 237 ]./255;
clrs      = [clrs , repmat(alpha,4,1)];
for i = 1:4
    hsub(i) = subplot(2,2,i);
    hold on;
    cfnm = sprintf('chan%d_fftOut',i);
    freq = sleepChunks.freq;
    fftD = sleepChunks.(cfnm);
     % XXX 
    freq = freq(:,1:40);
    fftD = fftD(:,1:40);
    % XXX
    cmap = colormap;
    NCLUST = length(unique(res(i).cl)); 
    uniqclusters = unique(res(i).cl); 
    for u = uniqclusters
        ic = int8((u*64.)/(NCLUST*1.));
        clruse = [cmap(ic,:) alpha];
        idxcluster = res(i).cl == u;
        plot(freq(idxcluster,:)', fftD(idxcluster,:)','LineWidth',0.001,'Color',clrs(u,:));
    end
    title(chanNames{i});
    ylabel(hsub(i),'Power (log_1_0\muV^2/Hz)');
    xlabel('Frquency (Hz)');
    set(hsub(i),'FontSize',16);
end
prfig.figname = 'raw_data_clustering_25_hours_colored_upto_40hz'; 
plot_hfig(hfig,prfig)

%% plot data with cluster based on time of day 
hfig = figure; 
for i = 1:4
    hsub(i) = subplot(4,1,i);
    scatter(sleepChunks.time',res(i).cl)
    title(chanNames{i});
end
linkaxes(hsub,'x'); 
%% video player 
close all;
hfig = figure;
chanNames = {'STN 0-2','STN 1-3','M1 8-10','M1 9-11'};
alpha = 0.05; 
clrs      = [60, 186, 84 ; 244, 194, 13 ;  219, 50, 54 ; 72, 133, 237 ]./255;
clrs      = [clrs , repmat(alpha,4,1)];
for i = 1:4
    hsub(i) = subplot(2,2,i);
    hold on;
    cfnm = sprintf('chan%d_fftOut',i);
    freq = sleepChunks.freq;
    fftD = sleepChunks.(cfnm);
    cmap = colormap;
    NCLUST = length(unique(res(i).cl)); 
    uniqclusters = unique(res(i).cl); 
    plotHandles = gobjects(size(freq,1),1); 
    for u = uniqclusters
        ic = int8((u*64.)/(NCLUST*1.));
        clruse = [cmap(ic,:) alpha];
        idxcluster = res(i).cl == u;
        hplt = plot(freq(idxcluster,:)', fftD(idxcluster,:)','LineWidth',0.0001,'Color',clrs(u,:));
        plotHandles(idxcluster') = hplt; 
    end
    handles(i).plotHandles = plotHandles; 
    title(chanNames{i});
    ylabel(hsub(i),'Power (log_1_0\muV^2/Hz)');
    xlabel('Frquency (Hz)');
    set(hsub(i),'FontSize',16);
end
%% video section 
% make all plots invisilble 
for i = 1:4
    for j = 1:size(handles(i).plotHandles,1)
        handles(i).plotHandles(j).Visible = 'off';
    end
end
times = sleepChunks.time; 


hfig.Position =  [1026         536         971         756];
hfig.Color = [1 1 1];
params.vidOut = 'sleep_clustering_video_onlyup_to_40hz_long.mp4'; 
v = VideoWriter(params.vidOut,'MPEG-4'); 
v.Quality = 100; 
v.FrameRate = 24; 
open(v); 

numberOfLines = 10; 
maxLines = size(handles(i).plotHandles,1); 

atEnd = 0; 
idxUse = 1:numberOfLines;
alphs  = linspace(0,0.7,length(idxUse));
lineW  = linspace(0.01,4,length(idxUse));
while ~atEnd
    for i = 1:4
        for j = 1:size(handles(i).plotHandles,1)
            handles(i).plotHandles(j).Visible = 'off';
        end
    end
    for i = 1:4
        cnt = 1; 
        for j = idxUse
            handles(i).plotHandles(j).Visible = 'on';
            handles(i).plotHandles(j).LineWidth = lineW(cnt); 
            handles(i).plotHandles(j).Color(4) = alphs(cnt);             
            cnt = cnt + 1; 
        end
    end
    
    supTitle = sgtitle( sprintf('%s',times(idxUse(end))),'FontSize',25);
    idxUse = idxUse + 1; 
    drawnow; 
    % XXXXXXXXXXXXXXXXXXXXXXXXXXX
    if idxUse(end) == maxLines
        break; 
    end
    fullVidFrame = getframe(hfig);
    writeVideo(v,fullVidFrame);

end
close(v); 

