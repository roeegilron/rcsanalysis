function concatenate_and_plot_TD_data()
if ismac 
    rootdir  = '/Volumes/Samsung_T5/RCS02/RCS02_all_home_data_processed/data/RCS02L';
else isunix
    rootdir  = '/home/starr/ROEE/data/RCS02L/';
end

% save td 
ff = findFilesBVQX(rootdir,'proc*TD*.mat');
tdProcDat = struct();
for f = 1:length(ff)
    
    load(ff{f},'processedData');
    if isempty(fieldnames(tdProcDat))
        tdProcDat = processedData;
    else
        if ~isempty(processedData)
            tdProcDat = [tdProcDat processedData];
        end
    end
    clear processedData
end
save( fullfile(rootdir,'processedData.mat'),'params','accProcDat','-v7.3')

% save acc 
ffAcc = findFilesBVQX(rootdir,'processedAccData.mat');
accProcDat = struct();
for f = 1:length(ffAcc)
%     process and analyze acc data
    load(ffAcc{f},'accData');
    
    if isempty(fieldnames(accProcDat))
        accProcDat = accData;
    else
        if ~isempty(accData)
            accProcDat = [accProcDat accData];
        end
    end
    clear accData;
end
save( fullfile(rootdir,'processedData.mat'),'params','tdProcDat','accProcDat','-v7.3')

%% create a large file that has overlapping data for PKG, ACC, TD data 
load('/Volumes/Samsung_T5/RCS02/RCS02_all_home_data_processed/data/RCS02L/processedDataSepFiles.mat');


%% load processed data and print times for each file 
load('/Volumes/Samsung_T5/RCS02/RCS02_all_home_data_processed/data/RCS02L/processedDataSepFiles.mat');
times = [tdProcDatSep.duration];
for t = 1:length(times)
    fprintf('%d %s\n',t,times(t));
end
tdProcDatSep(36); 


%% plot coverage by day 
for i = 1:length(tdProcDatSep)
    times = [tdProcDatSep(i).res.timeEnd];
    timeStarts(i) = times(1); 
    timeEnds(i) = times(end); 
end
allTimes = sortrows([timeStarts',timeEnds'],1);
% split up recordings that are not in the samy day 
idxNotSameDay = day(allTimes(:,1)) ~= day(allTimes(:,2));
allTimesSameDay = allTimes(~idxNotSameDay,:); 
allTimesDiffDay = allTimes(idxNotSameDay,:); 
% for idx that is not the same day, split it 
newTimesDay1 = [allTimesDiffDay(:,1) (allTimesDiffDay(:,1) - timeofday(allTimesDiffDay(:,1)) + day(1)) - minutes(1)];
newTimesDay2 = [((allTimesDiffDay(:,2) - timeofday(allTimesDiffDay(:,2))) + minutes(2)  ) allTimesDiffDay(:,2) ];
% concatenate all times 
allTimesNew  = sortrows([allTimesSameDay ; newTimesDay1 ; newTimesDay2],1); 
daysUse      = day(allTimesNew); 
ycnt = 1; 
for d = 1:length(daysUse)
    if daysUse(d) == daysUse(d+1)
        yValue(d) = ycnt; 
    else
        yValue(d) = ycnt; 
        ycnt = ycnt+1;
    end
end
% plot figure 
hfig = figure; 
hold on; 
hax = subplot(1,1,1); 
plot(timeofday( allTimesNew' ),[yValue' yValue']',...
    'LineWidth',10,...
    'Color',[0.8 0 0 0.7]);
yticks(1:length(daysUse))
ylabelsUse = {}; 
for d = 1:length(daysUse)
    ylabelsUse{d,1} = sprintf('May %d',daysUse(d));
end
hax.YTickLabel = ylabelsUse;

set(gca,'FontSize',16); 
ttluse = sprintf('Continous Chronic Recording at Home (%.2f hours)',hours(totalHours)); 
title(ttluse);
figdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/v06_home_data/figures';
figname = 'continous recording.fig';
savefig(hfig,fullfile(figdir,figname)); 

%% load actigraphy data, td data, pkg data and create one big database (one for each side) 
% td psd results data - get rid out outliers 

for c = 1:4 
    fn = sprintf('key%dfftOut',c-1); 
    idxkeep = fftResultsTd.(fn)(120,:) < -7;
end
hfig = figure; 
ttls = {'STN 0-2','STN 1-3','M1 8-10','M1 9-11'}; 
for c = 1:4 
    fn = sprintf('key%dfftOut',c-1); 
    hsub = subplot(2,2,c); 
    plot(fftResultsTd.ff,fftResultsTd.(fn)(:,idxkeep),'LineWidth',0.2,'Color',[0 0 0.8 0.2]); 
end

timesPKG = pkgTable.DateTime; 
timesPKG.TimeZone = 'America/Los_Angeles';
idxLoop = find(idxkeep==1); 
cnt = 1; 
dkVals = []; bkVals = []; idxThatHasPKGVals = []; 
for i = 1:length(idxLoop)
    timeGoal = fftResultsTd.timeEnd(idxLoop(i));
    [val(i),idx(i)] = min(abs(timeGoal - timesPKG));
    if val(i) < minutes(3)
        dkVals(cnt) = pkgTable.DK(idx(i));
        bkVals(cnt) = pkgTable.BK(idx(i)); 
        idxThatHasPKGVals(cnt) = idxLoop(i); 
        cnt = cnt + 1; 
    end
end






%% do fft but on sep recordings  
for c = 1:4
    start = tic;
    fn = sprintf('key%d',c-1);
    dat = [tdProcDat.(fn)];
    sr = 250; 
    [fftOut,ff]   = pwelch(dat,sr,sr/2,0:1:sr/2,sr,'psd');
    fftResultsTd.([fn 'fftOut']) = log10(fftOut); 
    fprintf('chanel %d done in %.2f\n',c,toc(start))
end
fftResultsTd.ff = ff; 
fftResultsTd.timeStart = [tdProcDat.timeStart];
fftResultsTd.timeEnd = [tdProcDat.timeEnd];

save( fullfile(rootdir,'psdResults.mat'),'params','fftResultsTd')

%% plot the data 
for c = 1:4
    start = tic;
    fn = sprintf('key%d',c-1);
    dat = [tdProcDat.(fn)];
    sr = 250; 
    [fftOut,ff]   = pwelch(dat,sr,sr/2,0:1:sr/2,sr,'psd');
    fftResultsTd.([fn 'fftOut']) = log10(fftOut); 
    fprintf('chanel %d done in %.2f\n',c,toc(start))
end
fftResultsTd.ff = ff; 
fftResultsTd.timeStart = [tdProcDat.timeStart];
fftResultsTd.timeEnd = [tdProcDat.timeEnd];

save( fullfile(rootdir,'psdResults.mat'),'params','fftResultsTd')

%% get td data + pkg data + acc data - correct place 
% get idx to plot 
% load('/Volumes/Samsung_T5/RCS02/RCS02_all_home_data_processed/data/RCS02R/psdResults.mat');
load('/Volumes/Samsung_T5/RCS02/RCS02_all_home_data_processed/data/RCS02L/psdResults.mat') % left hand 

% read pkg 
% first set of pkg data 
fn = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/v07_3_week/pkg/scores_20190515_124018.csv'; % left hand 
fn = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/v07_3_week/pkg/scores_20190515_124531.csv'; % right hand 
pkgTable1 = readtable(fn); 
fn = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/v08_1_month_initial_programming/pkg_data/scores_20190523_125035.csv'; % left hand 
fn = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/v08_1_month_initial_programming/pkg_data/scores_20190523_124728.csv'; % right hand 
pkgTable2 = readtable(fn); 
pkgTable = [pkgTable1; pkgTable2]; 
figure; 
hsb(1) = subplot(2,1,1); 
plot(pkgTable.DateTime,pkgTable.BK,'LineWidth',1,'Color',[0 0.8 0 0.5]); 
title('bk'); 
hsb(2) = subplot(2,1,2); 
plot(pkgTable.DateTime,pkgTable.DK,'LineWidth',1,'Color',[0 0 0.8 0.5]); 
title('dk'); 
linkaxes(hsb,'x'); 

figure;
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


% confirm that this is a good way to get rid of outliers 
hfig = figure; 
ttls = {'STN 0-2','STN 1-3','M1 8-10','M1 9-11'}; 
for c = 1:4 
    fn = sprintf('key%dfftOut',c-1); 
    hsub = subplot(2,2,c); 
    plot(fftResultsTd.ff,fftResultsTd.(fn)(:,idxkeep),'LineWidth',0.2,'Color',[0 0 0.8 0.2]); 
end

% get the pkg data 
timesPKG = pkgTable.DateTime; 
timesPKG.TimeZone = 'America/Los_Angeles';
idxLoop = find(idxkeep==1); 
cnt = 1; 
dkVals = []; bkVals = []; idxThatHasPKGVals = []; 
for i = 1:length(idxLoop)
    timeGoal = fftResultsTd.timeEnd(idxLoop(i));
    [val(i),idx(i)] = min(abs(timeGoal - timesPKG));
    if val(i) < minutes(3)
        dkVals(cnt) = pkgTable.DK(idx(i));
        bkVals(cnt) = pkgTable.BK(idx(i)); 
        idxThatHasPKGVals(cnt) = idxLoop(i); 
        cnt = cnt + 1; 
    end
end

% make a table with pkg values and td results 
allDataPkgRcsAcc.key0fftOut = fftResultsTd.key0fftOut(:,idxThatHasPKGVals)';
allDataPkgRcsAcc.key1fftOut = fftResultsTd.key1fftOut(:,idxThatHasPKGVals)';
allDataPkgRcsAcc.key2fftOut = fftResultsTd.key2fftOut(:,idxThatHasPKGVals)';
allDataPkgRcsAcc.key3fftOut = fftResultsTd.key3fftOut(:,idxThatHasPKGVals)';
allDataPkgRcsAcc.timeStart  = fftResultsTd.timeStart(idxThatHasPKGVals)';
allDataPkgRcsAcc.timeEnd  = fftResultsTd.timeStart(idxThatHasPKGVals)';
allDataPkgRcsAcc.dkVals = dkVals';
allDataPkgRcsAcc.bkVals = bkVals';
allDatTable = struct2table(allDataPkgRcsAcc); 

% compute correlations 
% pkg values 
dkVals = log10(allDataPkgRcsAcc.dkVals);
idxDk  = allDataPkgRcsAcc.dkVals>10;
bkVals = allDataPkgRcsAcc.bkVals;
idxBk  = allDataPkgRcsAcc.bkVals >= -80 &  allDataPkgRcsAcc.bkVals <= -1;
% power vals 
powerBeta02 = mean(allDataPkgRcsAcc.key0fftOut(:,16:29),2); 
powerBeta13 = mean(allDataPkgRcsAcc.key0fftOut(:,14:30),2); 
powerGama810 = mean(allDataPkgRcsAcc.key2fftOut(:,71:84),2); 
powerGama911 = mean(allDataPkgRcsAcc.key3fftOut(:,70:84),2); 
powerBeta810 = mean(allDataPkgRcsAcc.key2fftOut(:,18:30),2); 
powerBeta911 = mean(allDataPkgRcsAcc.key3fftOut(:,20:29),2); 

% compute correlations 
pkgNames = {'dkVals','bkVals'}; 
idxNames = {'idxDk','idxBk'}; 
pwrNames = {'powerBeta02','powerBeta13','powerGama810','powerGama911','powerBeta810','powerBeta911'};

for k = 1:length(pkgNames)
    hfig = figure; 
    for p = 1:length(pwrNames)
        
        x = eval(pkgNames{k}); 
        idx = eval(idxNames{k}); 
        x = x(idx); 
        y = eval(pwrNames{p}); 
        y = y(idx); 
        [r,pp] = corrcoef(x,y,'Rows','complete');
        fprintf('corr between %s and %s is %.2f\n',...
            pkgNames{k},pwrNames{p},r(1,2)); 
        
        subplot(2,3,p); 
        s1 = scatter(x,y,20,[0 0 0.9],'filled','MarkerFaceAlpha',0.5); 
        xlabel(pkgNames{k});
        ylabel(pwrNames{p});
        ttluse = sprintf('corr between %s and %s is %.2f\n',...
            pkgNames{k},pwrNames{p},r(1,2)); 
        title(ttluse); 
        hline = refline(gca);
        hline.LineWidth = 3;
        hline.Color = [hline.Color 0.5];
        set(gca,'FontSize',16); 
    end
end
%



% get acc rms of data 
% load acc data 
load('/Volumes/Samsung_T5/RCS02/RCS02_all_home_data_processed/data/RCS02L/processedDataAcc.mat'); 
timesAcc = [accProcDat.timeStart]; 
for i = 1:length(accProcDat)
    rmsVals(i) = rms(accProcDat(i).XSamples) + ...
              rms(accProcDat(i).YSamples) + ...
              rms(accProcDat(i).ZSamples); 
end

idxLoop = find(idxkeep==1); 
cnt = 1; 
clear val idx 
for i = 1:length(idxLoop)
    timeGoal = fftResultsTd.timeEnd(idxLoop(i));
    [val(i),idx(i)] = min(abs(timeGoal - timesAcc));
    if val(i) < minutes(3)
        accVals(cnt) = rmsVals(idx(i));
        idxThatHasAccVals(cnt) = idxLoop(i); 
        cnt = cnt + 1; 
    end
end







figure;
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
sgtitle('90 hours of data -30 sec chunks - RCS02L','FontSize',30)
linkaxes(hsub,'x');

% cortex - gamma - 75-79; 
% beta - stn - 19-24 

figure;
powerBeta = mean(fftResultsTd.key0fftOut(19:24,idxkeep)); 
powerGama = mean(fftResultsTd.key2fftOut(75:79,idxkeep)); 
x = fftResultsTd.timeEnd(idxkeep); 

hold on; 
scatter(x,rescale(  powerBeta, 0, 0.45) );
scatter(x,rescale(  powerGama, 0.5, 1) );
legend('Beta','Gamma');
title('beta vs gamma rescaled - time of day'); 

figure; 
hold on; 
scatter(1:length(x),rescale(  powerBeta, 0, 0.45) ,20,[0 0 0.9],'filled','MarkerFaceAlpha',0.5);
scatter(1:length(x),rescale(  powerGama, 0.5, 1) ,20,[0.8 0 0],'filled','MarkerFaceAlpha',0.5);
legend('Beta','Gamma');
title('beta vs gamma rescaled - linear'); 

figure; 
hsb(1) = subplot(2,1,1); 
scatter(timeofday(x),powerBeta,20,[0 0 0.9],'filled','MarkerFaceAlpha',0.5);
title('beta'); 

hsb(2) = subplot(2,1,2); 
scatter(timeofday(x),powerGama,20,[0.8 0 0],'filled','MarkerFaceAlpha',0.5);
title('gamma'); 
linkaxes(hsb,'x'); 



figure; 
powerBeta = mean(fftResultsTd.key1fftOut(19:24,idxkeep)); 
powerGama = mean(fftResultsTd.key3fftOut(75:79,idxkeep)); 

s = scatter(powerBeta,powerGama,10,[0 0 0.9],'filled','MarkerFaceAlpha',0.2); 
xlabel('Beta'); 
ylabel('Gamma');
s.DataTipTemplate.DataTipRows(1).Label = 'Beta';
s.DataTipTemplate.DataTipRows(2).Label = 'Gamma';
row = dataTipTextRow('time',[cellstr(datestr(fftResultsTd.timeStart))]);
s.DataTipTemplate.DataTipRows(end+1) = row;
title('beta (stn) gamma (m1)'); 
datacursormode toggle

% plot against pkg dat

figure; 
subplot(3,1,1);
scatter(pkgTable.DK,pkgTable.BK,10,[0.8 0 0],'filled','MarkerEdgeAlpha',0.2);
xlabel('dk'); 
ylabel('bk'); 
subplot(3,1,2);
histogram(pkgTable.DK);
title('DK'); 
subplot(3,1,3);
histogram(pkgTable.BK);
title('BK'); 

timesPKG = pkgTable.DateTime; 
timesPKG.TimeZone = 'America/Los_Angeles';
idxLoop = find(idxkeep==1); 
cnt = 1; 
dkVals = []; bkVals = []; idxThatHasPKGVals = []; 
for i = 1:length(idxLoop)
    timeGoal = fftResultsTd.timeEnd(idxLoop(i));
    [val(i),idx(i)] = min(abs(timeGoal - timesPKG));
    if val(i) < minutes(3)
        dkVals(cnt) = pkgTable.DK(idx(i));
        bkVals(cnt) = pkgTable.BK(idx(i)); 
        idxThatHasPKGVals(cnt) = idxLoop(i); 
        cnt = cnt + 1; 
    end
end
% power vals 
powerBeta02 = mean(fftResultsTd.key0fftOut(16:29,idxThatHasPKGVals)); 
powerBeta13 = mean(fftResultsTd.key1fftOut(14:30,idxThatHasPKGVals)); 
powerGama810 = mean(fftResultsTd.key2fftOut(71:84,idxThatHasPKGVals)); 
powerGama911 = mean(fftResultsTd.key2fftOut(70:84,idxThatHasPKGVals)); 
powerBeta810 = mean(fftResultsTd.key2fftOut(18:30,idxThatHasPKGVals)); 
powerBeta911 = mean(fftResultsTd.key2fftOut(20:29,idxThatHasPKGVals)); 
% pkg values 
dkVals; 
bkVals; 
% compute correlations 
pkgNames = {'dkVals','bkVals'}; 
pwrNames = {'powerBeta02','powerBeta13','powerGama810','powerGama911','powerBeta810','powerBeta911'};

for k = 1:length(pkgNames)
    hfig = figure; 
    for p = 1:length(pwrNames)
        
        x = eval(pkgNames{k}); 
        y = eval(pwrNames{p}); 
        [r,pp] = corrcoef(x,y,'Rows','complete');
        fprintf('corr between %s and %s is %.2f\n',...
            pkgNames{k},pwrNames{p},r(1,2)); 
        
        subplot(2,3,p); 
        s1 = scatter(x,y,20,[0 0 0.9],'filled','MarkerFaceAlpha',0.5); 
        xlabel(pkgNames{k});
        ylabel(pwrNames{p});
        ttluse = sprintf('corr between %s and %s is %.2f\n',...
            pkgNames{k},pwrNames{p},r(1,2)); 
        title(ttluse); 
        hline = refline(gca);
        hline.LineWidth = 3;
        hline.Color = [hline.Color 0.5];
        set(gca,'FontSize',16); 
    end
end

figure 
subplot(2,2,1); 
plot(fftResultsTd.key0fftOut(:,idxThatHasPKGVals),'LineWidth',0.002,'Color',[0 0 0.8 0.2])
title('stn 0-2');
subplot(2,2,2); 
plot(fftResultsTd.key1fftOut(:,idxThatHasPKGVals),'LineWidth',0.002,'Color',[0 0 0.8 0.2])
title('stn 1-3');
subplot(2,2,3); 
plot(fftResultsTd.key2fftOut(:,idxThatHasPKGVals),'LineWidth',0.002,'Color',[0 0 0.8 0.2])
title('m1 8-10');
subplot(2,2,4); 
plot(fftResultsTd.key3fftOut(:,idxThatHasPKGVals),'LineWidth',0.002,'Color',[0 0 0.8 0.2])
title('m1 9-11');

figure;
subplot(2,1,1); 
s = scatter(dkVals,powerGama,20,[0 0 0.9],'filled','MarkerFaceAlpha',0.5); 
s.DataTipTemplate.DataTipRows(1).Label = 'DK PKG';
s.DataTipTemplate.DataTipRows(2).Label = 'RCS power gamma';
times = fftResultsTd.timeStart(idxThatHasPKGVals);
row = dataTipTextRow('time',[cellstr(datestr(times))]);
s.DataTipTemplate.DataTipRows(end+1) = row;
datacursormode toggle
xlabel('PKG'); 
ylabel('RCs'); 
title('gamma vs dk vals'); 
hline = refline(gca); 
hline.LineWidth = 3; 
hline.Color = [hline.Color 0.5]; 
set(gca,'FontSize',16)

subplot(2,1,2); 

s1 = scatter(bkVals,powerBeta,20,[0 0 0.9],'filled','MarkerFaceAlpha',0.5); 
s1.DataTipTemplate.DataTipRows(1).Label = 'BK PKG';
s1.DataTipTemplate.DataTipRows(2).Label = 'RCS power beta';
times = fftResultsTd.timeStart(idxThatHasPKGVals);
row = dataTipTextRow('time',[cellstr(datestr(times))]);
s1.DataTipTemplate.DataTipRows(end+1) = row;
datacursormode toggle
xlabel('PKG'); 
ylabel('RCs'); 
title('beta vs bk vals');
hline = refline(gca); 
hline.LineWidth = 3; 
hline.Color = [hline.Color 0.5]; 
set(gca,'FontSize',16)

% get acc rms of data 
timesAcc = [accProcDat.timeStart]; 
for i = 1:length(accProcDat)
    rmsVals(i) = rms(accProcDat(i).XSamples) + ...
              rms(accProcDat(i).YSamples) + ...
              rms(accProcDat(i).ZSamples); 
        
end


idxLoop = find(idxkeep==1); 
cnt = 1; 
clear val idx 
for i = 1:length(idxLoop)
    timeGoal = fftResultsTd.timeEnd(idxLoop(i));
    [val(i),idx(i)] = min(abs(timeGoal - timesAcc));
    if val(i) < minutes(3)
        accVals(cnt) = rmsVals(idx(i));
        idxThatHasAccVals(cnt) = idxLoop(i); 
        cnt = cnt + 1; 
    end
end



% power vals 
powerBeta02Acc = mean(fftResultsTd.key0fftOut(16:29,idxThatHasAccVals)); 
powerBeta13Acc = mean(fftResultsTd.key1fftOut(14:30,idxThatHasAccVals)); 
powerGama810Acc = mean(fftResultsTd.key2fftOut(71:84,idxThatHasAccVals)); 
powerGama911Acc = mean(fftResultsTd.key2fftOut(70:84,idxThatHasAccVals)); 
powerBeta810Acc = mean(fftResultsTd.key2fftOut(18:30,idxThatHasAccVals)); 
powerBeta911Acc = mean(fftResultsTd.key2fftOut(20:29,idxThatHasAccVals)); 
% pkg values 
dkVals; 
bkVals; 
% compute correlations 
pkgNames = {'accVals'};
pwrNames = {'powerBeta02Acc','powerBeta13Acc','powerGama810Acc','powerGama911Acc','powerBeta810Acc','powerBeta911Acc'};
hfig = figure; 
for k = 1:length(pkgNames)
    for p = 1:length(pwrNames)
        x = eval(pkgNames{k}); 
        y = eval(pwrNames{p}); 
        [r,pp] = corrcoef(x,y,'Rows','complete');
        fprintf('corr between RCs actgiraphy and %s is %.2f\n',...
             pwrNames{p},r(1,2)); 
         
         subplot(2,3,p);
         s1 = scatter(x,y,20,[0 0 0.9],'filled','MarkerFaceAlpha',0.5);
         xlabel(pkgNames{k});
         ylabel(pwrNames{p});
         ttluse = sprintf('corr between %s and %s is %.2f\n',...
             pkgNames{k},pwrNames{p},r(1,2));
         title(ttluse);
         hline = refline(gca);
         hline.LineWidth = 3;
         hline.Color = [hline.Color 0.5];
         set(gca,'FontSize',16);
    end
end




powerBetaAcc = mean(fftResultsTd.key0fftOut(19:24,idxThatHasAccVals)); 
powerGamaAcc = mean(fftResultsTd.key2fftOut(75:79,idxThatHasAccVals)); 

figure;
subplot(2,1,1); 
scatter(accVals,powerBetaAcc,20,[0 0 0.9],'filled','MarkerFaceAlpha',0.5); 
xlabel('acc rms'); 
ylabel('power beta stn'); 
title('beta (stn) vs internal rc+s actigraphy RMS'); 
hline = refline(gca); 
hline.LineWidth = 3; 
hline.Color = [hline.Color 0.5]; 
set(gca,'FontSize',16)

subplot(2,1,2); 
scatter(accVals,powerGamaAcc,20,[0.8 0 0],'filled','MarkerFaceAlpha',0.5); 
xlabel('acc rms'); 
ylabel('power gamma m1'); 
title('gamma (m1) vs internal rc+s actigraphy RMS'); 
hline = refline(gca); 
hline.LineWidth = 3; 
hline.Color = [hline.Color 0.5];
set(gca,'FontSize',16)


% get correlations between rc+S and beta and gamma power 
[r,p] = corrcoef(powerBeta,bkVals,'Rows','complete');
[r,p] = corrcoef(powerGama,dkVals,'Rows','complete');




figure;
cntplt = 1;
hsb(cntplt) = subplot(2,1,cntplt); cntplt = cntplt +1; 
hp = plot(pkgTable.DateTime,pkgTable.DK);





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
sgtitle('160 hours of data -30 sec chunks - RCS02L','FontSize',30)
linkaxes(hsub,'x');

