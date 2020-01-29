function sync_pkg_data_rcs_data()
%% load toolboxes
addpath(genpath(fullfile(pwd,'toolboxes','shadedErrorBar')))
%% 
%% join pkg files
pkgfiles{1} = '/Volumes/RCS_DATA/RCS03/raw_data_push_jan_2020/pkg_data/RCS03_pkg-R_03-Jul-2019_09-Jul-2019_scores.mat';
pkgfiles{2} = '/Volumes/RCS_DATA/RCS03/raw_data_push_jan_2020/pkg_data/RCS03_pkg-R_20-Jun-2019_26-Jun-2019_scores.mat';
load(pkgfiles{1},'pkgTable');
pkgTable1 = pkgTable;
clear pkgTable;
load(pkgfiles{2},'pkgTable');
pkgTable2 = pkgTable;
clear pkgTable;
pkgTable = [pkgTable1; pkgTable2];
pkgTable = sortrows(pkgTable,'Date_Time');
%%

%% load rc+s data
rootdir = '/Volumes/RCS_DATA/RCS03/raw_data_push_jan_2020/SCBS/RCS03L/';
load(fullfile(rootdir,'psdResults.mat'));
load(fullfile(rootdir,'coherenceResults_RCS03L.mat'));
savefn = 'RCS03L_pkg_and_rcs_dat_synced_10_min.mat';
%%

%% loop on pkg data to creat one strucutre
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
% close(hfig);
% confirm that this is a good way to get rid of outliers
hfig = figure;
ttls = {'STN 0-2','STN 1-3','M1 8-10','M1 9-11'};
for c = 1:4
    fn = sprintf('key%dfftOut',c-1);
    hsub = subplot(2,2,c);
    %         plot(fftResultsTd.ff,fftResultsTd.(fn)(:,idxkeep),'LineWidth',0.2,'Color',[0 0 0.8 0.2]);
    shadedErrorBar(fftResultsTd.ff,fftResultsTd.(fn)(:,idxkeep)',...
        {@median,@(x) std(x)*1.96},...
        'lineprops',{'r','markerfacecolor','r','LineWidth',2})
end
% close(hfig);
%%
% get the pkg data
timesPKG = pkgTable.Date_Time;
timesPKG.TimeZone = 'America/Los_Angeles';
idxLoop = find(idxkeep==1);

allDataPkgRcsAcc = struct();
for c = 1:4
    fn = sprintf('key%dfftOut',c-1);
    psdResults.(fn) = fftResultsTd.(fn)(:,idxkeep);
end
psdResults.ff = fftResultsTd.ff;
psdResults.timeStart  = fftResultsTd.timeStart(idxkeep);
psdResults.timeEnd  = fftResultsTd.timeEnd(idxkeep);
psdTimes = psdResults.timeStart;
cnt = 1;
for i = 1:size(pkgTable,1) % this is looping on rcs data structure
    minTime = timesPKG(i) - minutes(5);
    maxTime = timesPKG(i) + minutes(5);
    idxMatch = isbetween(psdTimes',minTime,maxTime);
    matchingPsdTimes = psdTimes(idxMatch);
    
    if ~isempty(matchingPsdTimes)
        duration = matchingPsdTimes(end) - matchingPsdTimes(1);
        maxGap   = max(diff(matchingPsdTimes));
        if duration >= minutes(5) & maxGap < minutes(1)
            allDataPkgRcsAcc.key0fftOut(cnt,:) = mean(psdResults.key0fftOut(:,idxMatch)',1);
            allDataPkgRcsAcc.key1fftOut(cnt,:) = mean(psdResults.key1fftOut(:,idxMatch)',1);
            allDataPkgRcsAcc.key2fftOut(cnt,:) = mean(psdResults.key2fftOut(:,idxMatch)',1);
            allDataPkgRcsAcc.key3fftOut(cnt,:) = mean(psdResults.key3fftOut(:,idxMatch)',1);
            allDataPkgRcsAcc.timeStart(cnt)  = matchingPsdTimes(1);
            allDataPkgRcsAcc.timeEnd(cnt)  = matchingPsdTimes(end);
            allDataPkgRcsAcc.NumberPSD(cnt) = sum(idxMatch);
            allDataPkgRcsAcc.duration(cnt) = duration;
            allDataPkgRcsAcc.maxgap(cnt) = maxGap;
            allDataPkgRcsAcc.dkVals(cnt,1) = pkgTable.DK(i);
            allDataPkgRcsAcc.bkVals(cnt,1) = pkgTable.BK(i);
            allDataPkgRcsAcc.tremor(cnt,1) = pkgTable.Tremor(i);
            allDataPkgRcsAcc.tremorScore(cnt,1) = pkgTable.Tremor_Score(i);
            allDataPkgRcsAcc.states{cnt} = pkgTable.states{i};
            allDataPkgRcsAcc.numberPkg2minDataPoints{cnt} = cnt;
            
            cnt = cnt + 1;
        end
    end
end
allDataPkgRcsAcc.ffPSD = psdResults.ff; 

% clean cohernece data 
hfig = figure;
idxWhisker = [];
rawfnmsocherence = fieldnames(coherenceResultsTd);
idxusefncoh = cellfun(@(x) any(strfind(x,'stn')),rawfnmsocherence);
if sum(idxusefncoh)==0
    idxusefncoh = cellfun(@(x) any(strfind(x,'gpi')),rawfnmsocherence);
end

fieldnamesloop = rawfnmsocherence(idxusefncoh);
for c = 1:4
    fn = fieldnamesloop{c};
    hsub = subplot(2,2,c);
    meanVals = mean(coherenceResultsTd.(fn)(40:60,:));
    boxplot(meanVals);
    q75_test=quantile(meanVals,0.75);
    q25_test=quantile(meanVals,0.25);
    w=2.0;
    wUpper(c) = w*(q75_test-q25_test)+q75_test;
    idxWhisker(:,c) = meanVals' < wUpper(c);
    
end
idxkeepcoherence = idxWhisker(:,1) &  idxWhisker(:,2) & idxWhisker(:,3) & idxWhisker(:,4) ;
% close(hfig);
throwout = (1- sum(idxkeepcoherence)/length(idxkeepcoherence))*100;
% confirm that this is a good way to get rid of outliers
hfig = figure;
ttls = {'STN 0-2','STN 1-3','M1 8-10','M1 9-11'};
for c = 1:4
    fn = fieldnamesloop{c};
    hsub = subplot(2,2,c);
    %         plot(fftResultsTd.ff,fftResultsTd.(fn)(:,idxkeep),'LineWidth',0.2,'Color',[0 0 0.8 0.2]);
    shadedErrorBar(coherenceResultsTd.ff,coherenceResultsTd.(fn)(:,idxkeepcoherence)',...
        {@median,@(x) std(x)*1.96},...
        'lineprops',{'r','markerfacecolor','r','LineWidth',2})
end
% close(hfig);

cohResults.ff = coherenceResultsTd.ff;
cohResults.timeStart  = coherenceResultsTd.timeStart(idxkeepcoherence);
cohResults.timeEnd  = coherenceResultsTd.timeEnd(idxkeepcoherence);
cohTimes = cohResults.timeStart;
for c = 1:4
    fn = fieldnamesloop{c};
    cohResults.(fn) = coherenceResultsTd.(fn)(:,idxkeepcoherence);
end

% add coherence data 
for i = 1:size(allDataPkgRcsAcc.timeStart,2) % this is looping on rcs data structure
    minTime = allDataPkgRcsAcc.timeStart(i) - minutes(5);
    maxTime = allDataPkgRcsAcc.timeStart(i) + minutes(5);
    idxMatch = isbetween(cohTimes',minTime,maxTime);
    matchingPsdTimes = cohTimes(idxMatch);
    if ~isempty(matchingPsdTimes)
        duration = matchingPsdTimes(end) - matchingPsdTimes(1);
        maxGap   = max(diff(matchingPsdTimes));
        if duration >= minutes(5) & maxGap < minutes(3)
            for ccc = 1:4
                allDataPkgRcsAcc.(fieldnamesloop{ccc})(i,:)= ...
                    mean(cohResults.(fieldnamesloop{ccc})(:,idxMatch)',1);
            end
            allDataPkgRcsAcc.NumberPSD_coh(i) = sum(idxMatch);
            allDataPkgRcsAcc.duration_coh(i) = duration;
            allDataPkgRcsAcc.maxgap_coh(i) = maxGap;
        end
    end
end
allDataPkgRcsAcc.ffCoh = coherenceResultsTd.ff; 
            
fnmsave = fullfile(rootdir,savefn);
save(fnmsave,'allDataPkgRcsAcc');

%%

%% plot the raw data 
hfig = figure;
nrows = 2; 
ncols = 4; 
rawfnmsocherence = fieldnames(allDataPkgRcsAcc);

rawfnmsocherence = fieldnames(allDataPkgRcsAcc);
idxusetd = cellfun(@(x) any(strfind(x,'key')),rawfnmsocherence);


idxusefncoh = cellfun(@(x) any(strfind(x,'stn')),rawfnmsocherence);
if sum(idxusefncoh)==0
    idxusefncoh = cellfun(@(x) any(strfind(x,'gpi')),rawfnmsocherence);
end
cntplt = 1;
fieldnamesloop = rawfnmsocherence(idxusefncoh | idxusetd);
for f = 1:length(fieldnamesloop)
    subplot(nrows,ncols,cntplt); cntplt = cntplt + 1; 
    datplot = allDataPkgRcsAcc.(fieldnamesloop{f})';
    plot(datplot,'LineWidth',0.1,'Color',[0 0 0.5 0.1]);
    xlim([3,100]);
end
%%
end