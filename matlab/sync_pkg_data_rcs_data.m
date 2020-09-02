function sync_pkg_data_rcs_data()
% relies on these function to run:

% for RC+S:
% MAIN_create_subsets_of_home_data_for_analysis - to get the RC+S data -
% need access to dropbox on your comptuer (selective sync)
%
% for PKG:
% code is on Box - this is how this is created. see:
% '/Users/roee/Box/RC-S_Studies_Regulatory_and_Data/pkg_data/code';
% you also need selective sync installed and to sync this folder
% you must have ran this code:
% 'process_pkg_two_minute_data.m'
% which created the PKG database
% and extracts all the PKG data

%% houskeeping
close all;
clc;

addpath(genpath(fullfile(pwd,'toolboxes','shadedErrorBar')));
%% load the data

globalparams.use10minute = 1; % use 10 minute averaging
globalparams.useIndStates = 1; % use a different state mix for each patient to define on/off
globalparams.normalizeData = 1; % normalize the data along psd rows (normalize each row)




%% data selection PKG data
% '/Users/roee/Box/RC-S_Studies_Regulatory_and_Data/pkg_data/code';
% find Box directory
boxDir = findFilesBVQX('/Users','Box',struct('dirs',1,'depth',2));
pkgDB_location = fullfile(boxDir{1},'RC-S_Studies_Regulatory_and_Data','pkg_data','results','processed_data');
load(fullfile(pkgDB_location,'pkgDataBaseProcessed.mat'),'pkgDB');
pkgDB
%%

%% print the database and choose the date range you want to look for overlapping RC+S data within:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% SET PARAMS
%%%% SET PARAMS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%


timeBefore = datetime('2020-03-03'); % only using second data sprint of PKG 
timeBefore = datetime('2020-02-01'); % using both data sprints 
timeAfer =   datetime('2020-03-14');
patient = 'RCS08';
patient_psd_file_suffix = 'before_stim'; % the specific psd file trying to plot

timeBefore = datetime('2019-06-19'); % only using second data sprint of PKG 
timeAfer =   datetime('2019-07-10');
patient = 'RCS03';
patient_psd_file_suffix = 'before_stim'; % the specific psd file trying to plot

% will have a suffix chosenn during the creation process

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% SET PARAMS
%%%% SET PARAMS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% data selection - RC+S Data
dropboxdir = findFilesBVQX('/Users','Starr Lab Dropbox',struct('dirs',1,'depth',2));
DROPBOX_PATH = dropboxdir;

%% load toolboxes
addpath(genpath(fullfile(pwd,'toolboxes','shadedErrorBar')))

%% loop on both sides seperatly:
sides = {'L','R'}; % these sides refer to RC+S 
sidesPKG = {'R','L'}; % you need contralateral sides for PKG 
for sd = 1:length(sides)
    
    
    %% create one big pkg table 
    % get subject and side 
    idxpkgdb = strcmp(pkgDB.patient,patient) & ... 
                strcmp(pkgDB.side,sidesPKG{sd}); 
    posPKGs  = pkgDB(idxpkgdb,:);
    % filter on dates 
    idxdatespos = posPKGs.timerange(:,1) >= timeBefore & ... 
              posPKGs.timerange(:,2) <= timeAfer;
          
    pkgDBuse = posPKGs(idxdatespos,:);
    
    pkgBigTable = table();
    for pk = 1:size(pkgDBuse)
        ff = findFilesBVQX(pkgDB_location,pkgDBuse.savefn{pk});
        load(ff{1},'pkgTable');
        if pk == 1 
            pkgBigTable = pkgTable; 
        else
            pkgBigTable = [pkgBigTable ; pkgTable];
        end
        clear pkgTable; 
    end
    pkgTable = sortrows(pkgBigTable,'Date_Time');
    %%
    
    %% load rc+s data
    rootfolder = findFilesBVQX(DROPBOX_PATH,'RC+S Patient Un-Synced Data',struct('dirs',1,'depth',1));
    patdir = findFilesBVQX(rootfolder{1},[patient '*'],struct('dirs',1,'depth',1));
    % find the home data folder (SCBS fodler
    scbs_folder = findFilesBVQX(patdir{1},'SummitContinuousBilateralStreaming',struct('dirs',1,'depth',2));
    % assumign you want the same settings for L and R side
    pat_side_folders = findFilesBVQX(scbs_folder{1},[patient sides{sd}],struct('dirs',1,'depth',1));
    % find the actual psd file lookign for 
    ff = findFilesBVQX(pat_side_folders,['psdResults' '*' patient_psd_file_suffix '*'],struct('depth',1));
    load(ff{1});
    % find the coherence files 
    ff = findFilesBVQX(pat_side_folders,['coherenceResults' '*' patient_psd_file_suffix '*'],struct('depth',1));
    load(ff{1}); 
    % create rootdir 
    rootdir = pat_side_folders{1};
    
    savefn = sprintf('%s%s_pkg-%s_and_rcs_dat_synced_10_min.mat',patient,sides{sd},sidesPKG{sd});
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
    hfig.Color = 'w'; 
    nrows = 2;
    ncols = 4;
    rawfnmsocherence = fieldnames(allDataPkgRcsAcc);
    
    rawfnmsocherence = fieldnames(allDataPkgRcsAcc);
    idxusetd = cellfun(@(x) any(strfind(x,'key')),rawfnmsocherence);
    
    
    idxusefncoh = cellfun(@(x) any(strfind(x,'stn')),rawfnmsocherence);
    
    if sum(idxusefncoh)==0
        idxusefncoh = cellfun(@(x) any(strfind(x,'gpi')),rawfnmsocherence);    
    end
    
    fieldnamesloop = rawfnmsocherence(idxusefncoh | idxusetd);
    if sum(idxusefncoh)==0 % gpi case 
        error('need to fill this out for GPi'); 
    else % stn case 
        titlsUse = {'STN 0-2','STN 1-3','M1 8-10','M1 9-11','STN 0-2 m1 8-10','STN 0-2 m1 9-11','STN 1-3 m1 8-10','STN 1-3 m1 9-11'};
    end
    
    cntplt = 1;
    for f = 1:length(fieldnamesloop)
        subplot(nrows,ncols,cntplt); cntplt = cntplt + 1;
        datplot = allDataPkgRcsAcc.(fieldnamesloop{f})';
        plot(datplot,'LineWidth',0.1,'Color',[0 0 0.5 0.1]);
        title(titlsUse{f}); 
        xlim([3,100]);
        xlabel('Frequency (Hz)'); 
        if f >=4 
            ylabel('MS coherence');
        else
            ylabel('Power (log_1_0\muV^2/Hz)');
        end
    end
    
    lrgTitle{1} = sprintf('%s %s',patient,sides{sd});
    lrgTitle{2} = sprintf('%s - %s',timeBefore,timeAfer); 
    sgtitle(lrgTitle,'FontSize',18);
    
    figdirout = fullfile(rootdir,'figures');
    mkdir(figdirout);
    savefn = sprintf('%s%s_praw_rcs_dat_synced_with_pkg_10_min__%s',patient,sides{sd},lrgTitle{2});
    savefnFig = [savefn '.fig'];
    savefig(hfig,fullfile(figdirout,savefnFig));
    
    prfig.plotwidth           = 13;
    prfig.plotheight          = 8;
    prfig.figdir              = figdirout;
    prfig.figname            = savefn; 
    prfig.figtype             = '-djpeg';
    

    plot_hfig(hfig,prfig);

    %%
    
end




end