function plot_pkg_data_all_subjects()
%% houskeeping
close all;
clc;

addpath(genpath(fullfile(pwd,'toolboxes','shadedErrorBar')));


%% load the data
pkgdatdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/pkg_data/processed_data';
figdirout = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/pkg_data/figures';
resultsdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home';

load(fullfile(pkgdatdir,'pkgDataBaseProcessed.mat'),'pkgDB');

globalparams.use10minute = 1; % use 10 minute averaging 
globalparams.useIndStates = 1; % use a different state mix for each patient to define on/off 
globalparams.normalizeData = 1; % normalize the data along psd rows (normalize each row) 

cnt = 1;
% RCS06
dataFiles{cnt}  = '/Volumes/RCS_DATA/RCS06/v10_3_week_before_stimon/data_dump/SummitContinuousBilateralStreaming/RCS06L/processedData.mat';
psdrFiles{cnt}  = '/Volumes/RCS_DATA/RCS06/v10_3_week_before_stimon/data_dump/SummitContinuousBilateralStreaming/RCS06L/psdResults.mat';
dateChoose{cnt} = datetime('Oct 30 2019','Format','MMM dd yyyy');
peaks(cnt,:)  = [18 22];
channel(cnt) = 1;
patient{cnt} = 'RCS06 L';
side{cnt} = 'L';
cnt = cnt+1;

dataFiles{cnt}  = '/Volumes/RCS_DATA/RCS06/v10_3_week_before_stimon/data_dump/SummitContinuousBilateralStreaming/RCS06R/processedData.mat';
psdrFiles{cnt}  = '/Volumes/RCS_DATA/RCS06/v10_3_week_before_stimon/data_dump/SummitContinuousBilateralStreaming/RCS06R/psdResults.mat';
dateChoose{cnt} = datetime('Oct 30 2019','Format','MMM dd yyyy');
peaks(cnt,:)  = [18 22];
channel(cnt) = 1;
patient{cnt} = 'RCS06 R';
side{cnt} = 'R';
cnt = cnt+1;

% RCS07
dataFiles{cnt}  = '/Volumes/Samsung_T5/RCaS07/v14_data_dump/SummitContinuousBilateralStreaming/RCS07L/processedData.mat';
psdrFiles{cnt}  = '/Volumes/Samsung_T5/RCS07/v14_data_dump/SummitContinuousBilateralStreaming/RCS07L/psdResults.mat';
dateChoose{cnt} = datetime('Sep 20 2019','Format','MMM dd yyyy');
peaks(cnt,:)  = [17 21];
channel(cnt) = 1;
patient{cnt} = 'RCS07 L';
side{cnt} = 'L';
cnt = cnt+1;

dataFiles{cnt}  = '/Volumes/Samsung_T5/RCS07/v14_data_dump/SummitContinuousBilateralStreaming/RCS07R/processedData.mat';
psdrFiles{cnt}  = '/Volumes/Samsung_T5/RCS07/v14_data_dump/SummitContinuousBilateralStreaming/RCS07R/psdResults.mat';
dateChoose{cnt} = datetime('Sep 20 2019','Format','MMM dd yyyy');
peaks(cnt,:)  = [17 21];
channel(cnt) = 1;
patient{cnt} = 'RCS07 R';
side{cnt} = 'R';
cnt = cnt+1;

% RCS05
dataFiles{cnt}  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS05/v05_3week/data_dump/SummitContinuousBilateralStreaming/RCS05L/processedData.mat';
psdrFiles{cnt}  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS05/v05_3week/data_dump/SummitContinuousBilateralStreaming/RCS05L/psdResults.mat';
dateChoose{cnt} = datetime('Jul 26 2019','Format','MMM dd yyyy');
peaks(cnt,:)  = [17 21];
channel(cnt) = 0;
patient{cnt} = 'RCS05 L';
side{cnt} = 'L';
cnt = cnt+1;

dataFiles{cnt}  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS05/v05_3week/data_dump/SummitContinuousBilateralStreaming/RCS05R/processedData.mat';
psdrFiles{cnt}  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS05/v05_3week/data_dump/SummitContinuousBilateralStreaming/RCS05R/psdResults.mat';
dateChoose{cnt} = datetime('Jul 26 2019','Format','MMM dd yyyy');
peaks(cnt,:)  = [17 21];
channel(cnt) = 0;
patient{cnt} = 'RCS05 R';
side{cnt} = 'R';
cnt = cnt+1;

%RCS02
dataFiles{cnt}  = '/Volumes/Samsung_T5/RCS02/RCS02_all_home_data_processed/data/RCS02L/processedData.mat';
psdrFiles{cnt}  = '/Volumes/Samsung_T5/RCS02/RCS02_all_home_data_processed/data/RCS02L/psdResults.mat';
dateChoose{cnt} = datetime('May 21 2019','Format','MMM dd yyyy');
peaks(cnt,:)  = [17 20];
channel(cnt) = 0;
patient{cnt} = 'RCS02 L';
side{cnt} = 'L';
cnt = cnt+1;

dataFiles{cnt}  = '/Volumes/Samsung_T5/RCS02/RCS02_all_home_data_processed/data/RCS02R/processedData.mat';
psdrFiles{cnt}  = '/Volumes/Samsung_T5/RCS02/RCS02_all_home_data_processed/data/RCS02R/psdResults.mat';
dateChoose{cnt} = datetime('May 21 2019','Format','MMM dd yyyy');
peaks(cnt,:)  = [17 20];
channel(cnt) = 0;
patient{cnt} = 'RCS02 R';
side{cnt} = 'R';
cnt = cnt+1;

plotComparisonRCS_ACC_PKG = 0;
plotStates = 0;
plotTremor = 0;
plotBKDKcorr = 0;
plot_roc_curves = 0; 
plot_roc_curves_spec_freq = 0; 
plot_effect_of_normazliation = 1; 

%% loop on patients
for dd = 1:length(psdrFiles)
     
    %% get td data + pkg data + acc data - correct place
    fdir = findFilesBVQX(resultsdir,patient{dd}(1:5),struct('dirs',1,'depth',1));
    fnmload = ['psdResults_' side{dd}];
    fileload = fullfile(fdir{1},fnmload);
    load(fileload);
    % load(psdrFiles{dd});
    
    % load the processed PKGs
    if strcmp(side{dd},'L')
        pkgSideUse = 'R';
    elseif  strcmp(side{dd},'R')
        pkgSideUse = 'L';
    end
    correctIdx = strcmp(pkgDB.patient,patient{dd}(1:5)) & ...
        strcmp(pkgDB.side,pkgSideUse);
    pkgfn = pkgDB.savefn{correctIdx};
    load(pkgfn,'pkgTable');
    
    %% plot comparison between PKG scores and RSC actigraphy
    if plotComparisonRCS_ACC_PKG
        % transform states to numbers
        unqStates = unique(pkgTable.states);
        stateNums = zeros(size(pkgTable,1),1);
        for u = 1:length(unqStates)
            stateNums(strcmp(pkgTable.states,unqStates{u})) = u;
        end
        pkgTable.stateNums = stateNums;
        % concatenate all times PKG
        daysUsePKG      = day(pkgTable.Date_Time);
        montsUsePKG     = month(pkgTable.Date_Time);
        unqMonthsAndDaysPKG = sortrows(unique([montsUsePKG(:,1) daysUsePKG(:,1) ],'rows'),[1 2],'ascend');
        
        
        % verify timeing of pkg files
        [pn,fn] = fileparts(dataFiles{dd});
        loadAccFile = fullfile(pn,'processedDataAcc.mat');
        load(loadAccFile);
        timesStart = [accProcDat.timeStart]';
        % reshape the files
        numPoints = size(accProcDat(1).XSamples);
        accTable = struct2table(accProcDat);
        
        %xs = [accTable.XSamples];
        %xs = xs - mean(xs,1);
        for a = 1:size(accProcDat,2)
            start = tic;
            dat = [];
            dat(:,1) = accProcDat(a).XSamples;
            dat(:,2) = accProcDat(a).YSamples;
            dat(:,3) = accProcDat(a).ZSamples;
            datOut = processActigraphyData(dat,64);
            accMean  = mean(datOut);
            accVari  = mean(var(dat));
            accResults(a).('accMean') = accMean;
            accResults(a).('accVari') = accVari;
            accResults(a).('timeStart') = accProcDat(a).timeStart;
            accResults(a).('timeEnd') = accProcDat(a).timeEnd;
        end
        % concatenate all times
        daysUse      = day(timesStart);
        montsUse     = month(timesStart);
        unqMonthsAndDays = sortrows(unique([montsUse(:,1) daysUse(:,1) ],'rows'),[1 2],'ascend');
        for dy = 1:size(unqMonthsAndDaysPKG,1)
            % rcs data
            idxuseRCS = (month(timesStart) == unqMonthsAndDaysPKG(dy,1) ) & ...
                (day(timesStart) ==   unqMonthsAndDaysPKG(dy,2) );
            meansRCs = [accResults(idxuseRCS).accMean];
            variRCs = [accResults(idxuseRCS).accVari];
            timeRCS = [accResults(idxuseRCS).timeStart];
            
            % pkg time
            idxusePKG = (month(pkgTable.Date_Time) == unqMonthsAndDaysPKG(dy,1) ) & ...
                (day(pkgTable.Date_Time) ==   unqMonthsAndDaysPKG(dy,2) );
            dk = pkgTable.DK(idxusePKG);
            bk = pkgTable.BK(idxusePKG);
            timesPKG = pkgTable.Date_Time(idxusePKG);
            stateNums = pkgTable.stateNums(idxusePKG);
            uniqueStates = unique(pkgTable.states);
            
            
            
            
            if sum(idxuseRCS)~=0
                timesPKG.TimeZone = timeRCS.TimeZone;
                hfig = figure;
                hfig.Color = 'w';
                nrows = 5;
                cntplt = 1;
                % dk
                hsub(cntplt) = subplot(nrows,1,cntplt); hold on;
                scatter(timesPKG,log10(dk),10,'b','filled');
                hp(3) = plot(hsub(cntplt).XLim, [log10(7) log10(7)],'LineWidth',2,'Color',[0 0.8 0],'LineStyle','-.');
                hp(3) = plot(hsub(cntplt).XLim, [log10(16) log10(16)],'LineWidth',2,'Color',[0 0.8 0],'LineStyle','-.');
                cntplt = cntplt + 1;
                title('log10 dk');
                % bk
                hsub(cntplt) = subplot(nrows,1,cntplt); hold on;
                scatter(timesPKG,bk,10,'b','filled');
                hp(1) = plot(hsub(cntplt).XLim,[-26 -26],'LineWidth',2,'Color','r','LineStyle','-.');
                hp(2) = plot(hsub(cntplt).XLim,[-80 -80],'LineWidth',2,'Color','k','LineStyle','-.');
                cntplt = cntplt + 1;
                title('bk');
                
                % states
                hsub(cntplt) = subplot(nrows,1,cntplt);
                scatter(timesPKG,stateNums,10,'b','filled');
                hsub(cntplt).YTick = [1:length(uniqueStates)];
                hsub(cntplt).YTickLabel = uniqueStates;
                cntplt = cntplt + 1;
                title('states');
                
                
                hsub(cntplt) = subplot(nrows,1,cntplt); cntplt = cntplt + 1;
                scatter(timeRCS,log10(meansRCs),10,'r','filled');
                title('log10 rcs means');
                
                hsub(cntplt) = subplot(nrows,1,cntplt); cntplt = cntplt + 1;
                scatter(timeRCS,log10(variRCs),10,'r','filled');
                title('log10 rcs variRCs');
                ttlTime = timeRCS(1);
                ttlTime.Format = 'dd-MMM-yyyy';
                sgtitle(sprintf('%s %s PKG - %s',ttlTime,patient{dd},pkgDB.side{correctIdx}));
                linkaxes(hsub,'x');
                
                sgtitle(sprintf('state estimate %s %s', patient{dd},ttlTime),'FontSize',20);
                prfig.plotwidth           = 15;
                prfig.plotheight          = 10;
                mkdir(fullfile(figdirout,'rcscomps'));
                prfig.figdir             = fullfile(figdirout,'rcscomps');
                prfig.figname             = sprintf('%s %0.2d %s %s',patient{dd},dd,'rcs_acc_and_pkg_states',ttlTime);
                plot_hfig(hfig,prfig)
                close(hfig);
                
            end
        end
    end
    %%
    
    %% get and plot the RCS dat and PKG data and put it in one structure
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
    sgtitle(sprintf('confriming outlier algo %s',patient{dd}),'FontSize',20);
    close(hfig);
    
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
    sgtitle(sprintf('confriming outlier algo psd %s',patient{dd}),'FontSize',20);
    close(hfig);
    
    if globalparams.use10minute
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
                    
                    cnt = cnt + 1;
                end
            end
        end
    else
        % get the pkg data
        timesPKG = pkgTable.Date_Time;
        timesPKG.TimeZone = 'America/Los_Angeles';
        idxLoop = find(idxkeep==1);
        cnt = 1;
        dkVals = []; bkVals = []; idxThatHasPKGVals = [];
        tremrr = []; tremrScore = []; states = {};
        for i = 1:length(idxLoop)
            timeGoal = fftResultsTd.timeEnd(idxLoop(i));
            [val(i),idx(i)] = min(abs(timeGoal - timesPKG));
            if val(i) < minutes(1)
                dkVals(cnt) = pkgTable.DK(idx(i));
                bkVals(cnt) = pkgTable.BK(idx(i));
                tremrr(cnt) = pkgTable.Tremor(idx(i));
                tremrScore(cnt) = pkgTable.Tremor_Score(idx(i));
                states{cnt} = pkgTable.states{idx(i)};
                idxThatHasPKGVals(cnt) = idxLoop(i);
                cnt = cnt + 1;
            end
        end
        
        % make a table with pkg values and td results
        allDataPkgRcsAcc = struct();
        allDataPkgRcsAcc.key0fftOut = fftResultsTd.key0fftOut(:,idxThatHasPKGVals)';
        allDataPkgRcsAcc.key1fftOut = fftResultsTd.key1fftOut(:,idxThatHasPKGVals)';
        allDataPkgRcsAcc.key2fftOut = fftResultsTd.key2fftOut(:,idxThatHasPKGVals)';
        allDataPkgRcsAcc.key3fftOut = fftResultsTd.key3fftOut(:,idxThatHasPKGVals)';
        allDataPkgRcsAcc.timeStart  = fftResultsTd.timeStart(idxThatHasPKGVals)';
        allDataPkgRcsAcc.timeEnd  = fftResultsTd.timeEnd(idxThatHasPKGVals)';
        allDataPkgRcsAcc.dkVals = dkVals';
        allDataPkgRcsAcc.bkVals = bkVals';
        allDataPkgRcsAcc.tremor = tremrr';
        allDataPkgRcsAcc.tremorScore = tremrScore';
        allDataPkgRcsAcc.states = states';
        allDatTable = struct2table(allDataPkgRcsAcc);
    end
    
    %% plot effect of normazliation 
    if plot_effect_of_normazliation
        hfig = figure;
        hfig.Position = [301          82         620        1197];
        hfig.Color = 'w';
        titles = {'STN 0-2','STN 1-3','M1 8-10','M1 9-11'};
        labelsCheck = [];
        for c = 1:4
            hsb(c) = subplot(4,1,c);
            fn = sprintf('key%dfftOut',c-1);
            idxnotsleep = ~strcmp(allDataPkgRcsAcc.states,'sleep');
            
            dat = [];
            dat = allDataPkgRcsAcc.(fn)(idxnotsleep,:);
            idxnormalize = psdResults.ff > 3 &  psdResults.ff <90;
            meandat = abs(mean(dat(:,idxnormalize),2)); % mean within range, by row
            scatter(allDataPkgRcsAcc.timeStart(idxnotsleep), meandat,10,'filled');
            xlabel('Time (Hz)');
            ylabel('Power (log_1_0\muV^2/Hz)');
            title(['mean psd (3-90Hz) ' titles{c}]);
            set(gca,'FontSize',20);
        end
        sgtitle(sprintf('mean psds %s PKG %s', patient{dd},pkgSideUse),'FontSize',20);
        prfig.plotwidth           = 9;
        prfig.plotheight          = 20;
        prfig.figdir             = figdirout;
        prfig.figname             = sprintf('%s %s pkg _10_min_avgerage','mean_normalized_psd',patient{dd},pkgSideUse);
        plot_hfig(hfig,prfig)

    end
    %%
    
    %% get the various states
    if globalparams.useIndStates
        rawstates = allDataPkgRcsAcc.states;
        switch patient{dd}(1:5)
            case 'RCS02'
                onidx = cellfun(@(x) any(strfind(x,'dyskinesia severe')),rawstates);
                offidx = cellfun(@(x) any(strfind(x,'off')),rawstates) | ...
                         cellfun(@(x) any(strfind(x,'on')),rawstates) | ...
                         cellfun(@(x) any(strfind(x,'tremor')),rawstates);
                sleeidx = cellfun(@(x) any(strfind(x,'sleep')),rawstates);
                allstates = rawstates;
                allstates(onidx) = {'on'};
                allstates(offidx) = {'off'};
                allstates(sleeidx) = {'sleep'};
                statesUse = {'off','on'};
                
            case 'RCS05'
                onidx = cellfun(@(x) any(strfind(x,'dyskinesia')),rawstates) | ... 
                        cellfun(@(x) any(strfind(x,'on')),rawstates);
                offidx = cellfun(@(x) any(strfind(x,'off')),rawstates) | ...
                         cellfun(@(x) any(strfind(x,'tremor')),rawstates);
                sleeidx = cellfun(@(x) any(strfind(x,'sleep')),rawstates);
                allstates = rawstates;
                allstates(onidx) = {'on'};
                allstates(offidx) = {'off'};
                allstates(sleeidx) = {'sleep'};
                statesUse = {'off','on'};
            case 'RCS06'
                onidx = cellfun(@(x) any(strfind(x,'dyskinesia')),rawstates) | ... 
                        cellfun(@(x) any(strfind(x,'on')),rawstates);
                offidx = cellfun(@(x) any(strfind(x,'off')),rawstates) | ...
                         cellfun(@(x) any(strfind(x,'tremor')),rawstates);
                sleeidx = cellfun(@(x) any(strfind(x,'sleep')),rawstates);
                allstates = rawstates;
                allstates(onidx) = {'on'};
                allstates(offidx) = {'off'};
                allstates(sleeidx) = {'sleep'};
                statesUse = {'off','on'};
            case 'RCS07'
                onidx = cellfun(@(x) any(strfind(x,'dyskinesia')),rawstates) | ... 
                        cellfun(@(x) any(strfind(x,'on')),rawstates);
                offidx = cellfun(@(x) any(strfind(x,'off')),rawstates) | ...
                         cellfun(@(x) any(strfind(x,'tremor')),rawstates);
                sleeidx = cellfun(@(x) any(strfind(x,'sleep')),rawstates);
                allstates = rawstates;
                allstates(onidx) = {'on'};
                allstates(offidx) = {'off'};
                allstates(sleeidx) = {'sleep'};
                statesUse = {'off','on'};
        end
    else
        allstates = allDataPkgRcsAcc.states; 
        statesUse = {'off','on','dyskinesia severe'};
    end
    
    if plotStates

        colors = [0.8 0 0; 0 0.8 0;0 0 0.8; 0.5 0.5 0.5];
        colors2 = {'r','g','b','k'};
        hfig = figure;
        hfig.Color = 'w';
        titles = {'STN 0-2','STN 1-3','M1 8-10','M1 9-11'};
        labelsCheck = [];
        for c = 1:4
            hsb(c) = subplot(2,2,c);
            hold on;
            statesUsing = {};cntstt = 1;
            for s = 1:length(statesUse)
                fn = sprintf('key%dfftOut',c-1);
                labels = strcmp(allstates,statesUse{s});
                labelsCheck(:,s) = labels;
                
                dat = [];
                if globalparams.normalizeData
                    dat = allDataPkgRcsAcc.(fn);
                    idxnormalize = psdResults.ff > 3 &  psdResults.ff <90;
                    meandat = abs(mean(dat(:,idxnormalize),2)); % mean within range, by row
                    % the absolute is to make sure 1/f curve is not flipped
                    % since PSD values are negative 
                    meanmat = repmat(meandat,1,size(dat,2));
                    dat = dat./meanmat;
                else
                    dat = allDataPkgRcsAcc.(fn);
                end

                
                if sum(labels)>=1
                    hsbH = shadedErrorBar(psdResults.ff,dat(labels,:),{@mean,@(x) std(x)*1},...
                        'lineprops',{colors2{s},'markerfacecolor','r','LineWidth',2});
                    statesUsing{cntstt} = statesUse{s};cntstt = cntstt + 1;
                    hsbH.mainLine.Color = [colors(s,:) 0.5];
                    hsbH.mainLine.LineWidth = 3;
                    hsbH.patch.FaceAlpha = 0.1;
                end
                
            end
            legend(statesUsing);
            xlim([3 100]);
            xlabel('Frequency (Hz)');
            ylabel('Power (log_1_0\muV^2/Hz)');
            title(titles{c});
            set(gca,'FontSize',20);
        end
        
        clear prfig;
        sgtitle(sprintf('state estimate %s PKG %s', patient{dd},pkgSideUse),'FontSize',20);
        prfig.plotwidth           = 15;
        prfig.plotheight          = 10;
        prfig.figdir             = figdirout;
        prfig.figname             = sprintf('%s %s pkg _10_min_avgerage','pkg_states',patient{dd},pkgSideUse);
        plot_hfig(hfig,prfig)
%         close(hfig);
    end
    %%
    
    %% compute correlation with tremor
    if plotTremor
        allDataPkgRcsAcc.tremor = tremrr';
        allDataPkgRcsAcc.tremorScore = tremrScore';
        hfig = figure;
        hfig.Color = 'w';
        idxtremor = logical(allDataPkgRcsAcc.tremor);
        tremscores = allDataPkgRcsAcc.tremorScore(idxtremor);
        
        for c = 1:4
            hsb(c) = subplot(2,2,c,'Parent',hfig);
            hold on;
            statesUsing = {};cntstt = 1;
            fn = sprintf('key%dfftOut',c-1);
            dat = allDataPkgRcsAcc.(fn)(idxtremor,:);
            correlations = corr(tremscores,dat,'type','Spearman');
            plot(fftResultsTd.ff,correlations,'LineWidth',2,'Color','b');
            for ccc = 1:20
                rng(ccc);
                tremscoresRandom = tremscores(    randperm(length(tremscores)) );
                correlationsRandom = corr(tremscoresRandom,dat,'type','Spearman');
                plot(fftResultsTd.ff,correlationsRandom,'LineWidth',0.5,'Color',[0 0 0 0.5],'LineStyle','-.');
            end
            lgdtitls{1} = sprintf('tremor scores (%d)',length(tremscores));
            lgdtitls{2} = sprintf('randomized tremor scores (%d)',length(tremscores));
            legend(lgdtitls);
            xlim([3 100]);
            hsb(c).XTick = 5:10:100;
            xlabel('Frequency (Hz)');
            ylabel('Corr. with PKG trem. score');
            title(titles{c});
            set(gca,'FontSize',20);
            
            % plot correlation scores
            %         hfigCorr = figure;
            %         steps = [5:5:100]+1;
            %         hfigCorr.Color = 'w';
            %         cntpltt = 1;
            %         for s = steps
            %             subplot(4,5,cntpltt,'Parent',hfigCorr); cntpltt = cntpltt + 1;
            %             scatter(tremscores,dat(:,s),5,'filled','MarkerFaceAlpha',0.3)
            %             for ss = 1:2
            %                 [rval pval] = corr(tremscores,dat(:,s));
            %             end
            %             ttluse = sprintf('%d(Hz) r %0.2f (>40)',fftResultsTd.ff(s), rval);
            %             title(ttluse);
            %             set(gca,'FontSize',12);
            %         end
            %         ttluse = sprintf('%s %s pkg %s %s','scores tremor elaborated',patient{dd},pkgSideUse,titles{c});
            %         sgtitle(ttluse,'FontSize',16);
            %         prfig.plotwidth           = 15*1.6;
            %         prfig.plotheight          = 10*1.6;
            %         prfig.figdir             = figdirout;
            %         prfig.figtype            = '-djpeg';
            %         prfig.figname             = sprintf('%s %s pkg %s %s','scores_tremor_elaborated',patient{dd},pkgSideUse,titles{c});
            %         plot_hfig(hfigCorr,prfig)
            %         close(hfigCorr)
            % end plot correlation scores
        end
        linkaxes(hsb,'y');
        clear prfig;
        sgtitle(sprintf('tremor estimate %s PKG %s', patient{dd},pkgSideUse),'FontSize',20);
        prfig.plotwidth           = 15*1.6;
        prfig.plotheight          = 10*1.6;
        prfig.figdir             = figdirout;
        prfig.figname             = sprintf('%s %s pkg %s','tremor_estimate',patient{dd},pkgSideUse);
        plot_hfig(hfig,prfig)
        close(hfig);
    end
    %%
    
    %% compute correlation with BK and DK
    titles = {'STN 0-2','STN 1-3','M1 8-10','M1 9-11'};
    if plotBKDKcorr
        hfig = figure;
        hfig.Color = 'w';
        % sleep is anything below 80
        idxnotsleep = ~strcmp(allstates','sleep');
        idxover40 = allDataPkgRcsAcc.bkVals >= -40;
        bkvals = abs(allDataPkgRcsAcc.bkVals(idxnotsleep));
        dkScores  = allDataPkgRcsAcc.dkVals(idxnotsleep);
        dkScores(dkScores==0) = min(dkScores(dkScores~=0));
        dkvals = log10(dkScores);
        
        idxtremor = logical(allDataPkgRcsAcc.tremor);
        tremvalues = allDataPkgRcsAcc.tremorScore(idxtremor); 
        
        for c = 1:4
            hold on;
            fn = sprintf('key%dfftOut',c-1);
            dat = allDataPkgRcsAcc.(fn)(idxnotsleep,:);
            idxnormalize = psdResults.ff > 3 &  psdResults.ff <90;
            meandat = abs(mean(dat(:,idxnormalize),2)); % mean within range, by row
            % the absolute is to make sure 1/f curve is not flipped
            % since PSD values are negative             
            meanmat = repmat(meandat,1,size(dat,2));
            dat = dat./meanmat;
            
            % get tremor data 
            datTremor = allDataPkgRcsAcc.(fn)(idxtremor,:);
            meandatTrem = abs(mean(datTremor(:,idxnormalize),2)); % mean within range, by row
            meanmatTrem = repmat(meandatTrem,1,size(datTremor,2));
            datTremor = datTremor./meanmatTrem;
            

            %% plot the data to check correlation
%                     valsuse{1} = bkvals;
%                     valsuse{2} = dkvals;
%                     valtitls{1} = 'BK vals';
%                     valtitls{2} = 'DK vals';
%                     for vv = 1:2
%                         hfigCorr = figure;
%                         steps = 3:5:100;
%                         hfigCorr.Color = 'w';
%                         cntpltt = 1;
%                         for s = steps
%                             hsbtemp = subplot(4,5,cntpltt); cntpltt = cntpltt + 1;
%                             scatter(hsbtemp,valsuse{vv},dat(:,s),5,'filled','MarkerFaceAlpha',0.2)
%                             for ss = 1:2
%                                 [rval pval] = corr(valsuse{vv},dat(:,s));
%                             end
%                             ttluse = sprintf('%d(Hz) r %0.2f',fftResultsTd.ff(s), rval);
%                             title(hsbtemp,ttluse);
%                             set(hsbtemp,'FontSize',12);
%                         end
%                         ttluse = sprintf('%s pkg %s %s %s',patient{dd},pkgSideUse,valtitls{vv},titles{c});
%                         sgtitle(hfigCorr,  ttluse,'FontSize',16);
%                         prfig.plotwidth           = 15*1.6;
%                         prfig.plotheight          = 10*1.6;
%                         prfig.figdir             = figdirout;
%                         prfig.figtype            = '-djpeg';
%                         prfig.figname             = sprintf('%s %s pkg %s %s %s','issue_with_Heteroscedasticity',patient{dd},pkgSideUse,valtitls{vv},titles{c});
%                         plot_hfig(hfigCorr,prfig)
%                     end
            %%
            hsb(c) = subplot(2,2,c,'Parent',hfig);
            hold on;
            correlations = corr(bkvals,dat,'type','Spearman');
            plot(hsb(c),psdResults.ff,correlations,'LineWidth',2,'Color','b');
            
            correlations = corr(dkvals,dat,'type','Spearman');
            plot(fftResultsTd.ff,correlations,'LineWidth',2,'Color','r');
            
            correlations = corr(tremvalues,datTremor,'type','Spearman');
            plot(fftResultsTd.ff,correlations,'LineWidth',2,'Color','k');
            for ccc = 1:20
                rng(ccc);
                bkvalsRan = bkvals(    randperm(length(bkvals)) );
                correlationsRandom = corr(bkvalsRan,dat,'type','Spearman');
                plot(hsb(c),fftResultsTd.ff,correlationsRandom,'LineWidth',0.5,'Color',[0 0 0 0.5],'LineStyle','-.');
            end
            lgdtitls{1} = sprintf('BK vals (%d)',length(bkvals));
            lgdtitls{2} = sprintf('DK vals (%d)',length(bkvals));
            lgdtitls{3} = sprintf('Tr vals (%d)',length(tremvalues));
            lgdtitls{4} = sprintf('randomized scores (%d)',length(bkvals));
%             legend(hsb(c),lgdtitls);
            xlim(hsb(c),[3 100]);
            hsb(c).XTick = 5:10:100;
            xlabel(hsb(c),'Frequency (Hz)');
            ylabel(hsb(c),'Corr. with PKG scores');
            title(hsb(c),titles{c});
            set(hsb(c),'FontSize',20);
        end
        linkaxes(hsb,'y');
        clear prfig;
        sgtitle(sprintf('BK and DK %s PKG %s %s', patient{dd},pkgSideUse,'normalized psds'),'FontSize',20);
        prfig.plotwidth           = 15*1.6;
        prfig.plotheight          = 10*1.6;
        prfig.figdir             = figdirout;
        prfig.figname             = sprintf('%s %s pkg %s','bk_and_dk_estimate',patient{dd},pkgSideUse);
        plot_hfig(hfig,prfig)
    end
    %%
    
    %% plot ROC curves PCA
    if plot_roc_curves
        %     % compute roc
        titles = {'STN 0-2','STN 1-3','M1 8-10','M1 9-11'};
        tblheadings = {'stn_0_2','stn1_3','m1_8_10','m1_9_11'};
        allstates(sleeidx) = {'sleep'};

        statesUse = {'off','on'};
        idxuse = strcmp(allstates,'off') | strcmp(allstates,'on');
        labelsRaw = allstates(idxuse)';
        labels = zeros(size(labelsRaw,1),1);
        labels(strcmp(labelsRaw,'on')) = 1;
        
        tbl = table();
        for c = 1:4
            fn = sprintf('key%dfftOut',c-1);
            dat = allDataPkgRcsAcc.(fn)(idxuse,:);
            [coeff,score,latent,~,explained] = pca(dat','NumComponents',2);
            tbl.(tblheadings{c}) = coeff;
            expvar(c,:) = explained(1:2);
        end
        
        hfig = figure;
        hfig.Color = 'w';
        hsb = subplot(1,1,1);
        hold on;
        lgndTtls = {};
        fprintf('\n');
        fprintf('%s %s pkg %s\n','ROC_curves',patient{dd},pkgSideUse);
        for c = 1:4
            % each area sep
            fn = sprintf('key%dfftOut',c-1);
            dat = allDataPkgRcsAcc.(fn)(idxuse,:);
            datuse = tbl.(tblheadings{c});
            datuse = allDataPkgRcsAcc.(fn)(idxuse,76);
            mdl = fitglm(datuse,labels,'Distribution','binomial','Link','logit');
            score_log = mdl.Fitted.Probability; % Probability estimates
            [Xlog,Ylog,Tlog,AUClog] = perfcurve(logical(labels),score_log,'true');
            hplt = plot(Xlog,Ylog);
            hplt.LineWidth = 3;
            %hplt.Color = [0 0.7 0 0.7];
            lgndTtls{c}  = sprintf('%s (AUC %.2f)',titles{c},AUClog);
            fprintf('%s (AUC %.2f)\t PC1 - %.2f explained PC2 %.2f explained\n',titles{c},AUClog,...
                expvar(c,1),expvar(c,2));
        end
        % all areas
        dat = [];
        for c = 1:4
            dat = [dat, tbl.(tblheadings{c})];
        end
        
        mdl = fitglm(dat,labels,'Distribution','binomial','Link','logit');
        score_log = mdl.Fitted.Probability; % Probability estimates
        [Xlog,Ylog,Tlog,AUClog] = perfcurve(logical(labels),score_log,'true');
        hplt = plot(Xlog,Ylog);
        hplt.LineWidth = 3;
        %hplt.Color = [0 0.7 0 0.7];
        lgndTtls{c+1}  = sprintf('%s (AUC %.2f)','all areas',AUClog);
        
        legend(lgndTtls,'Location','southeast');
        
        
        xlabel('False positive rate')
        ylabel('True positive rate')
        legend(lgndTtls);
        ttlsuse{1} = sprintf('%s pkg %s',patient{dd},pkgSideUse);
        ttlsuse{2} = 'ROC curves - on/off PKG';
        peron = sum(labels)/length(labels);
        peroff = sum(~labels)/length(labels);
        observatiosn = length(labels);
        ttlsuse{3} = sprintf('%.2f%% off %.2f%% on (%d obs)',peroff,peron,observatiosn);
        
        title(ttlsuse);
        set(gca,'FontSize',20);
        
        prfig.plotwidth           = 15*1.6;
        prfig.plotheight          = 10*1.6;
        prfig.figdir             = figdirout;
        prfig.figname             = sprintf('%s %s pkg %s','ROC_curves',patient{dd},pkgSideUse);
        plot_hfig(hfig,prfig)
        
        
        % svm
        %     SVMModel2 = fitcsvm(dat,labels,...
        %         'Standardize',true);
        %     SVMModel2 = fitPosterior(SVMModel2);
        %     [~,scores2] = resubPredict(SVMModel2);
        %     [Xlog,Ylog,Tlog,AUClog] = perfcurve(logical(labels),scores2(:,2),'true');
        
    end
    %%
    
    %% plot ROC curves specific frequency 
    if plot_roc_curves_spec_freq
        % get specific frequenceis per patiet
        switch patient{dd}(1:5)
            case 'RCS02'
                cnls  =  [1  1  3  3];
                freqs =  [20 75 25 75];
                ttls  = {'STN beta','STN Gamma','M1 Beta','M1 Gamma'};
                onidx = cellfun(@(x) any(strfind(x,'dyskinesia severe')),rawstates);
                offidx = cellfun(@(x) any(strfind(x,'off')),rawstates) | ...
                    cellfun(@(x) any(strfind(x,'on')),rawstates) | ...
                    cellfun(@(x) any(strfind(x,'tremor')),rawstates);
                sleeidx = cellfun(@(x) any(strfind(x,'sleep')),rawstates);
                allstates = rawstates;
                allstates(onidx) = {'on'};
                allstates(offidx) = {'off'};
                allstates(sleeidx) = {'sleep'};
                statesUse = {'off','on'};
            case 'RCS05'
                cnls  =  [1  1  3  3];
                freqs =  [28 80 28 80];
                ttls  = {'STN beta','STN Gamma','M1 Beta','M1 Gamma'};
                onidx = cellfun(@(x) any(strfind(x,'dyskinesia')),rawstates) | ... 
                        cellfun(@(x) any(strfind(x,'on')),rawstates);
                offidx = cellfun(@(x) any(strfind(x,'off')),rawstates) | ...
                         cellfun(@(x) any(strfind(x,'tremor')),rawstates);
                sleeidx = cellfun(@(x) any(strfind(x,'sleep')),rawstates);
                allstates = rawstates;
                allstates(onidx) = {'on'};
                allstates(offidx) = {'off'};
                allstates(sleeidx) = {'sleep'};
                statesUse = {'off','on'};

            case 'RCS06'
                cnls  =  [0  1  2  2];
                freqs =  [25 65 65 10];
                ttls  = {'STN beta','STN Gamma','M1 Gamma','M1 alpha'};
                onidx = cellfun(@(x) any(strfind(x,'dyskinesia')),rawstates) | ...
                    cellfun(@(x) any(strfind(x,'on')),rawstates);
                offidx = cellfun(@(x) any(strfind(x,'off')),rawstates) | ...
                    cellfun(@(x) any(strfind(x,'tremor')),rawstates);
                sleeidx = cellfun(@(x) any(strfind(x,'sleep')),rawstates);
                allstates = rawstates;
                allstates(onidx) = {'on'};
                allstates(offidx) = {'off'};
                allstates(sleeidx) = {'sleep'};
                statesUse = {'off','on'};

            case 'RCS07'
                cnls  =  [1  1  3  3];
                freqs =  [19 80 18 80];
                ttls  = {'STN beta','STN Gamma','M1 Beta','M1 Gamma'};
                onidx = cellfun(@(x) any(strfind(x,'dyskinesia')),rawstates) | ... 
                        cellfun(@(x) any(strfind(x,'on')),rawstates);
                offidx = cellfun(@(x) any(strfind(x,'off')),rawstates) | ...
                         cellfun(@(x) any(strfind(x,'tremor')),rawstates);
                sleeidx = cellfun(@(x) any(strfind(x,'sleep')),rawstates);
                allstates = rawstates;
                allstates(onidx) = {'on'};
                allstates(offidx) = {'off'};
                allstates(sleeidx) = {'sleep'};
                statesUse = {'off','on'};

        end
        
        %% compute roc
        titles = {'STN 0-2','STN 1-3','M1 8-10','M1 9-11'};
        tblheadings = {'stn_0_2','stn1_3','m1_8_10','m1_9_11'};

        idxuse = strcmp(allstates,'off') | strcmp(allstates,'on');
        labelsRaw = allstates(idxuse)';
        labels = zeros(size(labelsRaw,1),1);
        labels(strcmp(labelsRaw,'on')) = 1;
        
        tbl = table();
        for c = 1:length(cnls)
            fn = sprintf('key%dfftOut',c-1);
            dat = allDataPkgRcsAcc.(fn)(idxuse,:);
            [coeff,score,latent,~,explained] = pca(dat','NumComponents',1);
            tbl.(tblheadings{c}) = coeff;
            expvar(c,:) = explained(1:2);
        end
        
        hfig = figure;
        hfig.Color = 'w';
        hsb = subplot(1,1,1);
        hold on;
        lgndTtls = {};
        fprintf('\n');
        fprintf('%s %s pkg %s\n','ROC_curves_specific',patient{dd},pkgSideUse);
        alldat = [];
        for c = 1:length(cnls)
            % get channel 
            fn = sprintf('key%dfftOut',cnls(c));
            % get freq 
            idxfreq = psdResults.ff == freqs(c);
            dat = allDataPkgRcsAcc.(fn)(idxuse,idxfreq);
            datuse = dat;
            alldat(:,c) = dat; 
            mdl = fitglm(datuse,labels,'Distribution','binomial','Link','logit');
            score_log = mdl.Fitted.Probability; % Probability estimates
            [Xlog,Ylog,Tlog,AUClog] = perfcurve(logical(labels),score_log,'true');
            hplt = plot(Xlog,Ylog);
            hplt.LineWidth = 3;
            %hplt.Color = [0 0.7 0 0.7];
            lgndTtls{c}  = sprintf('%s (AUC %.2f)',ttls{c},AUClog);
            fprintf('%s (AUC %.2f)\t PC1 - %.2f explained PC2 %.2f explained\n',titles{c},AUClog,...
                expvar(c,1),expvar(c,2));
        end

        
        mdl = fitglm(alldat,labels,'Distribution','binomial','Link','logit');
        score_log = mdl.Fitted.Probability; % Probability estimates
        [Xlog,Ylog,Tlog,AUClog] = perfcurve(logical(labels),score_log,'true');
        hplt = plot(Xlog,Ylog);
        hplt.LineWidth = 3;
        %hplt.Color = [0 0.7 0 0.7];
        lgndTtls{c+1}  = sprintf('%s (AUC %.2f)','all areas',AUClog);
        
        legend(lgndTtls,'Location','southeast');
        
        
        xlabel('False positive rate')
        ylabel('True positive rate')
        legend(lgndTtls);
        ttlsuse{1} = sprintf('%s pkg %s',patient{dd},pkgSideUse);
        ttlsuse{2} = 'ROC curves - on/off PKG';
        peron = sum(labels)/length(labels);
        peroff = sum(~labels)/length(labels);
        observatiosn = length(labels);
        totalNonSleepObservatons = length(allstates) -  sum(strcmp(allstates,'sleep'));
        percentNonSleepObservationsAnalyzed = observatiosn/ totalNonSleepObservatons;
        ttlsuse{3} = sprintf('%.2f%% off %.2f%% on (%d obs) (%.2f%% analyzed)',peroff,peron,observatiosn,percentNonSleepObservationsAnalyzed);
        
        title(ttlsuse);
        set(gca,'FontSize',20);
        
        prfig.plotwidth           = 15*1.6;
        prfig.plotheight          = 10*1.6;
        prfig.figdir             = figdirout;
        prfig.figname             = sprintf('%s %s pkg %s','ROC_curves_spec_freqs',patient{dd},pkgSideUse);
        plot_hfig(hfig,prfig)
        
        
        % svm
        %     SVMModel2 = fitcsvm(dat,labels,...
        %         'Standardize',true);
        %     SVMModel2 = fitPosterior(SVMModel2);
        %     [~,scores2] = resubPredict(SVMModel2);
        %     [Xlog,Ylog,Tlog,AUClog] = perfcurve(logical(labels),scores2(:,2),'true');
        
    end
    %%
end

end

function previousVersionHardCutOff_AllPatients()
%% loop on patients
for dd = 2%length(psdrFiles)
    
    %% get td data + pkg data + acc data - correct place
    load(psdrFiles{dd});
    
    % read pkg
    pkgTable = readtable(pkgChoose{dd});
    
    hfig = figure;
    hfig.Color = 'w';
    hsb(1) = subplot(2,1,1);
    plot(pkgTable.Date_Time,pkgTable.BK,'LineWidth',1,'Color',[0 0.8 0 0.5]);
    title('bk');
    hsb(2) = subplot(2,1,2);
    plot(pkgTable.Date_Time,log10(pkgTable.DK),'LineWidth',1,'Color',[0 0 0.8 0.5]);
    title('dk');
    linkaxes(hsb,'x');
    sgtitle(sprintf('%s',patient{dd}));
    %plot bk vs DK
    hfig = figure;
    hfig.Color = 'w';
    scatter(log10(pkgTable.DK),pkgTable.BK,10,'filled','MarkerFaceColor',[0.8 0 0],'MarkerEdgeAlpha',0.5);
    sgtitle(sprintf('Log DK vs BK vals %s',patient{dd}),'FontSize',20);
    xlabel('log DK vals');
    ylabel('BK vals');
    grid on
    axis normal
    set(gcf,'Color','w');
    set(gca,'FontSize',20);
    
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
    sgtitle(sprintf('confriming outlier algo %s',patient{dd}),'FontSize',20);
    
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
    sgtitle(sprintf('confriming outlier algo psd %s',patient{dd}),'FontSize',20);
    
    
    % get the pkg data
    timesPKG = pkgTable.Date_Time;
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
    allDataPkgRcsAcc = struct();
    allDataPkgRcsAcc.key0fftOut = fftResultsTd.key0fftOut(:,idxThatHasPKGVals)';
    allDataPkgRcsAcc.key1fftOut = fftResultsTd.key1fftOut(:,idxThatHasPKGVals)';
    allDataPkgRcsAcc.key2fftOut = fftResultsTd.key2fftOut(:,idxThatHasPKGVals)';
    allDataPkgRcsAcc.key3fftOut = fftResultsTd.key3fftOut(:,idxThatHasPKGVals)';
    allDataPkgRcsAcc.timeStart  = fftResultsTd.timeStart(idxThatHasPKGVals)';
    allDataPkgRcsAcc.timeEnd  = fftResultsTd.timeEnd(idxThatHasPKGVals)';
    allDataPkgRcsAcc.dkVals = dkVals';
    allDataPkgRcsAcc.bkVals = bkVals';
    allDatTable = struct2table(allDataPkgRcsAcc);
    
    % plot histogrma correlate with pkg
    %     betaIdxUse  = 23:25;
    %     gamaIdxUse  = 74:76;
    %     powerBeta13  = mean(allDataPkgRcsAcc.key1fftOut(:,betaIdxUse),2);
    %     powerGama810 = mean(allDataPkgRcsAcc.key3fftOut(:,gamaIdxUse),2);
    %     powerGamma = mean(allDataPkgRcsAcc.key3fftOut(:,betaIdxUse),2);
    measureUse = {'clas. using BK','clas. using DK'};
    for m = 1:2
        if m == 1
            pkgOffMeds  = allDataPkgRcsAcc.bkVals > -120 & allDataPkgRcsAcc.bkVals < -60;
            pkgOnMeds   = allDataPkgRcsAcc.bkVals > -60 & allDataPkgRcsAcc.bkVals < -10;
        else
            pkgOffMeds  = allDataPkgRcsAcc.dkVals > 0 & allDataPkgRcsAcc.dkVals < 30;
            pkgOnMeds   = allDataPkgRcsAcc.dkVals >= 30 & allDataPkgRcsAcc.dkVals < 300;
        end
        
        bksabs = abs(allDataPkgRcsAcc.bkVals);
        % pkgOffMeds  = bksabs > 32 & bksabs < 80;
        % pkgOnMeds   = bksabs <= 20 & bksabs > 0;
        %{
    We use BKS>26<40 (BKS=26 =UPDRS III~30)as a marker of
    ?OFF? and >32<40 as (BKS=32 =UPDRS III~45)marker of very OFF
    We use DKS>7 as a marker of dyskinesia and > 16 as significant dyskinesia
    Generally when BKS>26, DKS will be low.
    We don?t usually use the terminology of OFF/On/dyskinesia use in diaries
    because they are categorical states compared to a continuous variable.
    If I can ask you the same question for UPDRS and AIMS score
    what cut-off would you like to use to indicate those
    same states and then I can give you approximate numbers for the BKS DKS.
    We have good evidence thatTreatable bradykinesia
    (i.e. presumable OFF according to a clinician) is when the
     BKS>26 (or <-26 as per the csv files)
    Good control (i.e. neither OFF nor ON) is when BKS <26 AND DKS<7
    Dyskinesia is when DKS>7 and BKS <26.
    However you should not use single epochs alone.
    We tend to use the 4/7 or 3/5 rule ?
    that is use take the first 7 epochs of BKS (or DKS),
    then the middle epoch will be ?OFF? if 4/7 of the epochs >26.
    Slide along one and apply the rule again etc.
    Mal Horne
    Wed 7/24/2019 7:12 PM email
        %}
        prfig.figdir = figdir{dd};
        prfig.figtype = '-djpeg';
        prfig.resolution = 600;
        prfig.closeafterprint = 0;
        
        % for DBS think tank lecture:
        ffTemp = fftResultsTd.ff;
        idxAllDat = pkgOffMeds | pkgOnMeds;
        dat       = allDataPkgRcsAcc.key1fftOut(idxAllDat,:);
        % figure;
        % plot(ffTemp,dat,'Color',[0 0 0.8 0.01],'LineWidth',0.01);
        
        
        hfig = figure;
        hsb(1) = subplot(1,2,1);
        hold on;
        % plot(ffTemp,dat,'Color',[0 0 0.8 0.01],'LineWidth',0.01);
        % shadedErrorBar(fftResultsTd.ff,dat,{@mean,@(x) std(x)*1.96},'lineprops',{'k','markerfacecolor','r','LineWidth',2});
        shadedErrorBar(fftResultsTd.ff,allDataPkgRcsAcc.key1fftOut(pkgOffMeds,:),{@median,@(x) std(x)*1.5},'lineprops',{'r','markerfacecolor','r','LineWidth',2});
        shadedErrorBar(fftResultsTd.ff,allDataPkgRcsAcc.key1fftOut(pkgOnMeds,:),{@median,@(x) std(x)*1.5},'lineprops',{'b','markerfacecolor','b','LineWidth',2});
        % legend({'immobile - wearable estimate'});
        legend({'immobile - wearable estimate','mobile - wearable estimate'});
        xlim([3 100]);
        xlabel('Frequency (Hz)');
        ylabel('Power (log_1_0\muV^2/Hz)');
        title('STN');
        set(gca,'FontSize',20);
        
        
        hsb(2) = subplot(1,2,2);
        hold on;
        shadedErrorBar(fftResultsTd.ff,allDataPkgRcsAcc.key3fftOut(pkgOffMeds,:),{@median,@(x) std(x)*1.5},'lineprops',{'r','markerfacecolor','k','LineWidth',2});
        shadedErrorBar(fftResultsTd.ff,allDataPkgRcsAcc.key3fftOut(pkgOnMeds,:),{@median,@(x) std(x)*1.5},'lineprops',{'b','markerfacecolor','b','LineWidth',2});
        ylims = get(hsb(2),'YLim');
        
        % legend({'immobile - wearable estimate'});
        legend({'immobile - wearable estimate','mobile - wearable estimate'});
        %     patch(hsb(2),[15 36 36 15],[ylims(1) ylims(1) ylims(2) ylims(2)],[1 1 0],'FaceAlpha',0.3,'EdgeColor',[1 1 1])
        %     set(gca,'children',flipud(get(gca,'children')))
        
        set(gca,'YLim',[-8 -3.5]);
        xlim([3 100]);
        xlabel('Frequency (Hz)');
        ylabel('Power (log_1_0\muV^2/Hz)');
        title('M1');
        set(gca,'FontSize',20);
        set(gcf,'Color','w');
        
        sgtitle(sprintf('%s mobile vs immobile pkg estimate %s',measureUse{m}, patient{dd}),'FontSize',20);
        prfig.plotwidth           = 15;
        prfig.plotheight          = 10;
        prfig.figname             = sprintf('%s %s','pkg_plot_mobile_vs_imobile',measureUse{m});;
        plot_hfig(hfig,prfig)
    end
    
    
    
    
    %
    %     figure;
    %     subplot(2,2,1);
    %     hold on;
    %     histogram(powerBeta13(pkgOffMeds),'Normalization','probability','BinWidth',0.1);
    %     histogram(powerBeta13(pkgOnMeds),'Normalization','probability','BinWidth',0.1);
    %     legend({'off (PKG estimate)','on (PKG estimate)'});
    %     ylabel('Probability (%)');
    %     xlabel('Beta power');
    %     ttluse = sprintf('Beta (%d-%dHz) on/off(PKG) - STN',betaIdxUse(1),betaIdxUse(end));
    %     title(ttluse);
    %     set(gcf,'Color','w')
    %     set(gca,'FontSize',20)
    %
    %     subplot(2,2,2);
    %     hold on;
    %     histogram(powerGama810(pkgOffMeds),'Normalization','probability','BinWidth',0.1);
    %     histogram(powerGama810(pkgOnMeds),'Normalization','probability','BinWidth',0.1);
    %     legend({'off (PKG estimate)','on (PKG estimate)'});
    %     xlabel('Gamma power');
    %     ylabel('Probability (%)');
    %     ttluse = sprintf('Gama (%d-%dHz) on/off(PKG) - M1',gamaIdxUse(1),gamaIdxUse(end));
    %     title(ttluse);
    %     set(gcf,'Color','w')
    %     set(gca,'FontSize',20)
    %
    %     subplot(2,2,3);
    %     hold on;
    %     scatter(powerGama810(pkgOffMeds), powerBeta13(pkgOffMeds),4,'filled','MarkerFaceColor',[0.8 0 0],'MarkerFaceAlpha',0.5)
    %     scatter(powerGama810(pkgOnMeds), powerBeta13(pkgOnMeds),4,'filled','MarkerFaceColor',[0 0 0.8],'MarkerFaceAlpha',0.5)
    %     legend({'off (PKG estimate)','on (PKG estimate)'});
    %     title ('Beta (STN) vs Gamma (M1) power');
    %     xlabel('Power Gamma M1');
    %     ylabel('Power Beta STN');
    %     set(gcf,'Color','w')
    %     set(gca,'FontSize',20)
    %
    %
    %
    %     % compute roc
    %     subplot(2,2,4);
    %     hold on;
    %
    %     tbl = table();
    %     tbl.powerBeta = powerBeta13;
    %     tbl.powerGamma = powerGama810;
    %
    %     labels     = zeros(size(powerBeta13,1),1);
    %     labels(pkgOnMeds) = 1;
    %     labels(pkgOffMeds) = 2;
    %
    %     idxkeepROC = labels~=0;
    %     labels = labels(idxkeepROC);
    %     labels(labels==1) = 0;
    %     labels(labels==2) = 1;
    %     dat    = [tbl.powerBeta(idxkeepROC),tbl.powerGamma(idxkeepROC)];
    %
    %     % beta
    %     [X,Y,T,AUC,OPTROCPT] = perfcurve(logical(labels),dat(:,1),1);
    %     hplt = plot(X,Y);
    %     hplt.LineWidth = 3;
    %     hplt.Color = [0 0 0.8 0.7];
    %     lgndTtls{1}  = sprintf('%s (AUC %.2f)','stn beta',AUC);
    %     % gama
    %     [X,Y,T,AUC,OPTROCPT] = perfcurve(logical(labels),dat(:,2),0);
    %     hplt = plot(X,Y);
    %     hplt.LineWidth = 3;
    %     hplt.Color = [0.8 0 0 0.7];
    %     lgndTtls{2}  = sprintf('%s (AUC %.2f)','m1 gamma',AUC);
    %     % both
    %     mdl = fitglm(dat,labels,'Distribution','binomial','Link','logit');
    %     score_log = mdl.Fitted.Probability; % Probability estimates
    %     [Xlog,Ylog,Tlog,AUClog] = perfcurve(logical(labels),score_log,'true');
    %     hplt = plot(Xlog,Ylog);
    %     hplt.LineWidth = 3;
    %     hplt.Color = [0 0.7 0 0.7];
    %     lgndTtls{3}  = sprintf('%s (AUC %.2f)','Beta + Gama',AUClog);
    %     % svm
    %     SVMModel2 = fitcsvm(dat,labels,...
    %         'Standardize',true);
    %     SVMModel2 = fitPosterior(SVMModel2);
    %     [~,scores2] = resubPredict(SVMModel2);
    %     [Xlog,Ylog,Tlog,AUClog] = perfcurve(logical(labels),scores2(:,2),'true');
    %
    %
    %
    %     xlabel('False positive rate')
    %     ylabel('True positive rate')
    %     legend(lgndTtls);
    %     title('ROC curves - beta, gamma, both');
    %     set(gca,'FontSize',20);
    
end

end