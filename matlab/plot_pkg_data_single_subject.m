function plot_pkg_data_single_subject()
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
patient = 'RCS08'; 
patient_psd_file_suffix = 'before_stim'; % the specific psd file trying to plot 
% will have a suffix chosenn during the creation process 


%% data selection - RC+S Data 
dropboxdir = findFilesBVQX('/Users','Starr Lab Dropbox',struct('dirs',1,'depth',2));
DROPBOX_PATH = dropboxdir; 

%% find the RC+S data
% find unsynced data folder on dropbox and then patient needed 
rootfolder = findFilesBVQX(DROPBOX_PATH,'RC+S Patient Un-Synced Data',struct('dirs',1,'depth',1));

%% exmaple selections: 
patdir = findFilesBVQX(rootfolder{1},[patient '*'],struct('dirs',1,'depth',1));
% find the home data folder (SCBS fodler 
scbs_folder = findFilesBVQX(patdir{1},'SummitContinuousBilateralStreaming',struct('dirs',1,'depth',2));
% assumign you want the same settings for L and R side  
pat_side_folders = findFilesBVQX(scbs_folder{1},[patient '*'],struct('dirs',1,'depth',1));


cnt = 1; 
for ss = 1:length(pat_side_folders)
    ff = findFilesBVQX(pat_side_folders{ss},'*pkg_and_rcs_dat_synced_10_min*.mat');
    psdrFiles{ss} = ff{1};
    [~, patraw] = fileparts(pat_side_folders{ss});
    
    patientUse{ss} = patraw(1:end-1); 
    % check that use the right oposite pkg side 
    if strcmp(patraw(end),'L')
        pkgSideUse{ss} = 'R';
    else
        pkgSideUse{ss} = 'L';
    end
    rcsSideUse{ss} = patraw(end);
end
figdircreate = fullfile(patdir{1},'figures');
mkdir(figdircreate);
figdirout = figdircreate;
%%

%% decide what to plot 
plotComparisonRCS_ACC_PKG = 0;
plotStates = 0;
plost_states_base_on_coherence = 1;
plotTremor = 0;
plotBKDKcorr = 0;
plot_roc_curves = 0; 
plot_roc_curves_spec_freq = 0; 
plot_effect_of_normazliation = 0; 
plot_raw_psds_all_rcs_data = 0; 
plot_raw_psds_all_rcs_data_coherence = 0;
plot_AUC_vs_segement_length = 0;

%% loop on patients
cntOut = 1;
patientPSD_at_home = table();
patientROC_at_home = table();
for dd = 1:length(psdrFiles)
    %% load the data 
    load(psdrFiles{dd});
    
    %% plot all raw psd data for one patient 
    if plot_raw_psds_all_rcs_data
        hfig = figure;
        hfig.Position = [1154         266        1317         886];
        hfig.Color = 'w';
        titles = {'STN 0-2','STN 1-3','M1 8-10','M1 9-11'};
        labelsCheck = [];
        combineareas = 1; 
        for c = 1:4
            if combineareas
                if c <= 2 
                    hsb(c) = subplot(1,2,1);
                else
                    hsb(c) = subplot(1,2,2);
                end
            else
                hsb(c) = subplot(2,2,c);
            end
            hold on;
            fn = sprintf('key%dfftOut',c-1);
            dat = allDataPkgRcsAcc.(fn);
            idxnormalize = psdResults.ff > 3 &  psdResults.ff <90;
            meandat = abs(mean(dat(:,idxnormalize),2)); % mean within range, by row
            % the absolute is to make sure 1/f curve is not flipped
            % since PSD values are negative
            meanmat = repmat(meandat,1,size(dat,2));
            dat = dat./meanmat;
            normalizedPSD = dat; 
            frequency = psdResults.ff'; 
            idxsleep = strcmp(allDataPkgRcsAcc.states,'sleep');
            plot(psdResults.ff', dat(~idxsleep,:),'LineWidth',0.1,'Color',[0 0 0.8 0.1]);
            plot(psdResults.ff', dat(idxsleep,:),'LineWidth',0.1,'Color',[0.5 0.5 0.5 0.1]);
            xlim([3 100]);
            xlabel('Time (Hz)');
            ylabel('Power (log_1_0\muV^2/Hz)');
            if combineareas
                if c <=2 
                    title(['mean psd (3-90Hz) 10 minutes interval' ' stn']);
                else
                    title(['mean psd (3-90Hz) 10 minutes interval' ' m1']);
                end
                
            else
                title(['mean psd (3-90Hz) 10 minutes interval' titles{c}]);
            end
            ylims = hsb(c).YLim;
            plot([4 4],ylims,'LineWidth',3,'LineStyle','-.','Color',[0.2 0.2 0.2 0.1]);
            plot([13 13],ylims,'LineWidth',3,'LineStyle','-.','Color',[0.2 0.2 0.2 0.1]);
            plot([30 30],ylims,'LineWidth',3,'LineStyle','-.','Color',[0.2 0.2 0.2 0.1]);
            set(gca,'FontSize',16);
        end
        savenm = fullfile(figdirout,...
            sprintf('%s %s pkg %s 10_min_avgerage.mat','mean_normalized_psd_all_psds',patient{dd},pkgSideUse));
        save(savenm,'psdResults','allDataPkgRcsAcc');
        savefigname = fullfile(figdirout,...
            sprintf('%s %s pkg %s 10_min_avgerage.fig','mean_normalized_psd_all_psds',patient{dd},pkgSideUse));

        sgtitle(sprintf('mean psds %s PKG %s', patient{dd},pkgSideUse),'FontSize',20);
        saveas(hfig,savefigname);
        prfig.plotwidth           = 13;
        prfig.plotheight          = 8;
        prfig.figdir             = figdirout;
        if combineareas
        prfig.figname             = sprintf('%s %s pkg _10_min_avgerage','mean_normalized_psd_all_psds_including_sleep_both_sides_combined',patient{dd},pkgSideUse);
        else
            prfig.figname             = sprintf('%s %s pkg _10_min_avgerage','mean_normalized_psd_all_psds_including_sleep',patient{dd},pkgSideUse);
        end
        plot_hfig(hfig,prfig)

    end
    %% 
    
     %% plot all raw psd data for one patient COHERENCE  
    if plot_raw_psds_all_rcs_data_coherence
        hfig = figure;
        hfig.Position = [1154         266        1317         886];
        hfig.Color = 'w';
        titles = {'STN 0-2','STN 1-3','M1 8-10','M1 9-11'};
        labelsCheck = [];
        fieldnamesAll = fieldnames(allDataPkgRcsAcc);
        idxfieldnames = cellfun(@(x) any(strfind(x,'stn')),fieldnamesAll);
        if sum(idxfieldnames)>1 
            fieldnamesloop = fieldnamesAll(idxfieldnames);
        else
            idxfieldnames = cellfun(@(x) any(strfind(x,'gpi')),fieldnamesAll);
            fieldnamesloop = fieldnamesAll(idxfieldnames);
        end
        
        for c = 1:length(fieldnamesloop)
            hsb(c) = subplot(2,2,c);
            hold on;
            cla(hsb(c));
            fn = fieldnamesloop{c};
            dat = allDataPkgRcsAcc.(fn);
            idxnormalize = cohResults.ff > 3 &  cohResults.ff <90;
            meandat = abs(mean(dat(:,idxnormalize),2)); % mean within range, by row
            % the absolute is to make sure 1/f curve is not flipped
            % since PSD values are negative
            meanmat = repmat(meandat,1,size(dat,2));
            dat = dat./meanmat;
            normalizedPSD = dat; 
            frequency = cohResults.ff'; 
            idxsleep = strcmp(allDataPkgRcsAcc.states,'sleep');
            plot(cohResults.ff', dat(~idxsleep,:),'LineWidth',0.1,'Color',[0 0 0.8 0.1]);
            plot(cohResults.ff', dat(idxsleep,:),'LineWidth',0.1,'Color',[0.5 0.5 0.5 0.1]);
            xlim([3 100]);
            xlabel('Time (Hz)');
            ylabel('Power (log_1_0\muV^2/Hz)');
            pairname = coherenceResultsTd.pairname(c,:);
            ttluse = sprintf('%s %s %s','mean mscochere',pairname{1,1},pairname{1,2});
            title(ttluse);
            ylims = hsb(c).YLim;
            plot([4 4],ylims,'LineWidth',3,'LineStyle','-.','Color',[0.2 0.2 0.2 0.1]);
            plot([13 13],ylims,'LineWidth',3,'LineStyle','-.','Color',[0.2 0.2 0.2 0.1]);
            plot([30 30],ylims,'LineWidth',3,'LineStyle','-.','Color',[0.2 0.2 0.2 0.1]);
            set(gca,'FontSize',16);
        end
        savenm = fullfile(figdirout,...
            sprintf('%s %s pkg %s 10_min_avgerage.mat','coherece_mean_normalized',patient{dd},pkgSideUse));
        save(savenm,'psdResults','allDataPkgRcsAcc');
        savefigname = fullfile(figdirout,...
            sprintf('%s %s pkg %s 10_min_avgerage.fig','coherece_mean_normalized',patient{dd},pkgSideUse));

        sgtitle(sprintf('mean psds %s PKG %s', patient{dd},pkgSideUse),'FontSize',20);
        saveas(hfig,savefigname);
        prfig.plotwidth           = 15;
        prfig.plotheight          = 11;
        prfig.figdir             = figdirout;
        prfig.figname             = sprintf('%s %s pkg _10_min_avgerage','coherece_mean_normalized_sleep',patient{dd},pkgSideUse);
        plot_hfig(hfig,prfig)

    end
    %% 
    
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
    
    %% get and plot various states
    if globalparams.useIndStates
        rawstates = allDataPkgRcsAcc.states;
        switch patient
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
%                 statesUse = {'off','on','sleep'};
                
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
                statesUse = {'off','on','sleep'};
            case 'RCS06'
                onidx = cellfun(@(x) any(strfind(x,'dyskinesia')),rawstates) | ... 
                        cellfun(@(x) any(strfind(x,'on')),rawstates);
                offidx = cellfun(@(x) any(strfind(x,'off')),rawstates) | ...
                         cellfun(@(x) any(strfind(x,'tremor')),rawstates);
                sleeidx = cellfun(@(x) any(strfind(x,'sleep')),rawstates);
                % change jan 6 2020 
                onidx = ...
                    cellfun(@(x) any(strcmp(x,'on')),rawstates);
                tremorScores = allDataPkgRcsAcc.tremorScore; 
                idxwithScores = allDataPkgRcsAcc.tremorScore~=0; 
                tremscore = prctile(tremorScores(idxwithScores),50);
                idxOver50     = allDataPkgRcsAcc.tremorScore >= tremscore;
                
                offidx = idxwithScores & idxOver50;

                
                allstates = rawstates;
                allstates(onidx) = {'on'};
                allstates(offidx) = {'off'};
                allstates(sleeidx) = {'sleep'};
                statesUse = {'off','on'};
%                 statesUse = {'off','on','sleep'};
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
                statesUse = {'off','on','sleep'};
            case 'RCS08'
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
                statesUse = {'off','on','sleep'};
                
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
                    psdResults.ff = allDataPkgRcsAcc.ffPSD;
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
                    hsbH.patch.MarkerFaceColor = colors(s,:);
                    hsbH.patch.FaceColor = colors(s,:);
                    hsbH.patch.EdgeColor = colors(s,:);
                    hsbH.edge(1).Color = [colors(s,:) 0.1];
                    hsbH.edge(2).Color = [colors(s,:) 0.1];
                    hsbH.patch.EdgeAlpha = 0.1;
                    hsbH.patch.FaceAlpha = 0.1;

                end
               % save the median data 
               
               rawdat = allDataPkgRcsAcc.(fn);
               rawdat = rawdat(labels,:);
               fftLogged = mean(rawdat,1);
               patientPSD_at_home.patient{cntOut} = patientUse{dd};
               patientPSD_at_home.side{cntOut} = rcsSideUse{dd};
               patientPSD_at_home.medstate{cntOut} = statesUse{s};
               patientPSD_at_home.electrode{cntOut} = titles{c};
               patientPSD_at_home.ff{cntOut} = psdResults.ff;
               patientPSD_at_home.fftOut{cntOut} = fftLogged;
               patientPSD_at_home.srate(cntOut) = 250;
               idxnorm = psdResults.ff >=5 & psdResults.ff <=90;
               fftLogged(idxnorm) = fftLogged(idxnorm)./abs((mean(fftLogged(idxnorm))));
               patientPSD_at_home.fftOutNorm{cntOut} = fftLogged;
               cntOut = cntOut + 1;
               % 

               
                
            end
            legend(statesUsing);
            xlim([3 100]);
            xlabel('Frequency (Hz)');
            ylabel('Power (log_1_0\muV^2/Hz)');
            title(titles{c});
            set(gca,'FontSize',20);
        end
        fnmsv = fullfile(figdirout,sprintf('%s %s pkg %s _10_min_avgerage.mat','pkg_states',patientUse{dd},pkgSideUse{dd})); 
        save(fnmsv,'allDataPkgRcsAcc','allstates','statesUse','psdResults','titles');
        clear prfig;
        sgtitle(sprintf('state estimate %s %s PKG %s', patientUse{dd},rcsSideUse{dd}, pkgSideUse{dd}),'FontSize',20);
        prfig.plotwidth           = 15;
        prfig.plotheight          = 10;
        prfig.figdir             = figdirout;
        prfig.figname             = sprintf('%s %s pkg _10_min_avgerage','pkg_states',patientUse{dd},pkgSideUse{dd});
        plot_hfig(hfig,prfig)
%         close(hfig);
%         fnmsave = fullfile(resultsdir,'patientPSD_at_home.mat');
%         save(fnmsave,'patientPSD_at_home');

    end
    %%
    
    %% plot states based on coherence 
    if plost_states_base_on_coherence 
        
        rawstates = allDataPkgRcsAcc.states;
        allstates = rawstates;
        switch patientUse{dd}
            case 'RCS02'
                onidx = cellfun(@(x) any(strfind(x,'dyskinesia severe')),rawstates);
                offidx = cellfun(@(x) any(strfind(x,'off')),rawstates) | ...
                    cellfun(@(x) any(strfind(x,'on')),rawstates) | ...
                    cellfun(@(x) any(strfind(x,'tremor')),rawstates);
                sleeidx = cellfun(@(x) any(strfind(x,'sleep')),rawstates);
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
                                allstates(onidx) = {'on'};
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
                                allstates(onidx) = {'on'};
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
                                allstates(onidx) = {'on'};
                allstates(onidx) = {'on'};
                allstates(offidx) = {'off'};
                allstates(sleeidx) = {'sleep'};
                statesUse = {'off','on'};
                
            case 'RCS08'
                onidx = cellfun(@(x) any(strfind(x,'dyskinesia')),rawstates) | ...
                    cellfun(@(x) any(strfind(x,'on')),rawstates);
                offidx = cellfun(@(x) any(strfind(x,'off')),rawstates) | ...
                    cellfun(@(x) any(strfind(x,'tremor')),rawstates);
                sleeidx = cellfun(@(x) any(strfind(x,'sleep')),rawstates);
                allstates(onidx) = {'on'};
                allstates(onidx) = {'on'};
                allstates(offidx) = {'off'};
                allstates(sleeidx) = {'sleep'};
                statesUse = {'off','on'};

        end
        colors = [0.8 0 0; 0 0.8 0;0 0 0.8; 0.5 0.5 0.5];
        colors2 = {'r','g','b','k'};
        hfig = figure;
        hfig.Color = 'w';
        titles = {'STN 0-2','STN 1-3','M1 8-10','M1 9-11'};
        labelsCheck = [];
        
        fieldnamesAll = fieldnames(allDataPkgRcsAcc);
        idxfieldnames = cellfun(@(x) any(strfind(x,'stn')),fieldnamesAll);
        if sum(idxfieldnames)>1
            fieldnamesloop = fieldnamesAll(idxfieldnames);
        else
            idxfieldnames = cellfun(@(x) any(strfind(x,'gpi')),fieldnamesAll);
            fieldnamesloop = fieldnamesAll(idxfieldnames);
        end
        cohResults.ff = allDataPkgRcsAcc.ffCoh;
        
        
        for c = 1:4
            hsb(c) = subplot(2,2,c);
            hold on;
            statesUsing = {};cntstt = 1;
            for s = 1:length(statesUse)
                fn = fieldnamesloop{c};
                labels = strcmp(allstates,statesUse{s});
                labelsCheck(:,s) = labels;
                
                dat = [];
                globalparams.normalizeData = 0;
                if globalparams.normalizeData
                    dat = allDataPkgRcsAccCoh.(fn);
                    idxnormalize = cohResults.ff > 3 &  cohResults.ff <90;
                    meandat = abs(mean(dat(:,idxnormalize),2)); % mean within range, by row
                    % the absolute is to make sure 1/f curve is not flipped
                    % since PSD values are negative 
                    meanmat = repmat(meandat,1,size(dat,2));
                    dat = dat./meanmat;
                else
                    dat = allDataPkgRcsAcc.(fn);
                end

                plotShaded = 1; 
                if sum(labels)>=1
                    if plotShaded
                        hsbH = shadedErrorBar(cohResults.ff,dat(labels,:),{@median,@(x) std(x)*1},...
                            'lineprops',{colors2{s},'markerfacecolor','r','LineWidth',2});
                        statesUsing{cntstt} = statesUse{s};cntstt = cntstt + 1;
                        hsbH.mainLine.Color = [colors(s,:) 0.5];
                        hsbH.mainLine.LineWidth = 3;
                        hsbH.patch.MarkerFaceColor = colors(s,:);
                        hsbH.patch.FaceColor = colors(s,:);
                        hsbH.patch.EdgeColor = colors(s,:);
                        hsbH.edge(1).Color = [colors(s,:) 0.1];
                        hsbH.edge(2).Color = [colors(s,:) 0.1];
                        hsbH.patch.EdgeAlpha = 0.1;
                        hsbH.patch.FaceAlpha = 0.1;
                        hForLeg(s) = hsbH.mainLine;
                    else
                        hpltall = plot(cohResults.ff,dat(labels,:),...
                            'LineWidth',0.1,...
                            'Color',[colors(s,:) 0.2]);
                        hForLeg(s) = hpltall(1);
                    end
                end
               % save the median data 
               
               rawdat = allDataPkgRcsAcc.(fn);
               rawdat = rawdat(labels,:);
               coh = mean(rawdat,1);
               patientCOH_at_home.patient{cntOut} = patientUse{dd};
               patientCOH_at_home.side{cntOut} = rcsSideUse{dd};
               patientCOH_at_home.medstate{cntOut} = statesUse{s};
               patientCOH_at_home.electrode{cntOut} = titles{c};
               patientCOH_at_home.ff{cntOut} = cohResults.ff;
               patientCOH_at_home.coh{cntOut} = coh;
               patientCOH_at_home.srate(cntOut) = 250;

               cntOut = cntOut + 1;
               % 

               
               ylims = hsb(c).YLim;
               plot([4 4],ylims,'LineWidth',3,'LineStyle','-.','Color',[0.2 0.2 0.2 0.1]);
               plot([13 13],ylims,'LineWidth',3,'LineStyle','-.','Color',[0.2 0.2 0.2 0.1]);
               plot([30 30],ylims,'LineWidth',3,'LineStyle','-.','Color',[0.2 0.2 0.2 0.1]);
            end
            legend(hForLeg,statesUsing);
            xlim([3 100]);
            xlabel('Frequency (Hz)');
            ylabel('ms coherence');
            pairname = fn;
            ttluse = sprintf('coh %s',fn);
            title(ttluse);
            
            set(gca,'FontSize',20);
        end

        fnmsv = fullfile(figdirout,sprintf('%s %s pkg %s _10_min_avgerage.mat','coh_states',patientUse{dd},pkgSideUse{dd})); 
        save(fnmsv,'allDataPkgRcsAcc','allstates','statesUse','patientCOH_at_home');
        clear prfig;
        sgtitle(sprintf('state estimate %s PKG %s coherence', patientUse{dd},pkgSideUse{dd}),'FontSize',20);
        prfig.plotwidth           = 15;
        prfig.plotheight          = 10;
        prfig.figdir             = figdirout;
        prfig.figname             = sprintf('%s %s pkg coherence_10_min_avgerage','pkg_states',patientUse{dd},pkgSideUse{dd});
        plot_hfig(hfig,prfig)
        close(hfig);
        fnmsave = fullfile(figdirout,'patientCOH_at_home.mat');
        save(fnmsave,'patientCOH_at_home');
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
            legend(hsb(c),lgdtitls,'Location','southeast');
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
            patientROC_at_home.patient{cntOut} = patient{dd}(1:5);
            patientROC_at_home.side{cntOut} = patient{dd}(end);
            patientROC_at_home.electrode{cntOut} = titles{c};
            patientROC_at_home.AUC{cntOut} = AUClog;
            cntOut = cntOut + 1;
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
        
        patientROC_at_home.patient{cntOut} = patient{dd}(1:5);
        patientROC_at_home.side{cntOut} = patient{dd}(end);
        patientROC_at_home.electrode{cntOut} = 'all areas';
        patientROC_at_home.AUC{cntOut} = AUClog;
        cntOut = cntOut + 1;

        
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
%         plot_hfig(hfig,prfig)
        
        fnmsave = fullfile(resultsdir,'patientROC_at_home.mat');
        save(fnmsave,'patientROC_at_home');

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
                freqs =  [15 65 65 10];
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
            patientROC_at_home.patient{cntOut} = patient{dd}(1:5);
            patientROC_at_home.side{cntOut} = patient{dd}(end);
            patientROC_at_home.electrode{cntOut} = titles{c};
            patientROC_at_home.freqs{cntOut} = ttls{c};
            patientROC_at_home.AUC{cntOut} = AUClog;
            cntOut = cntOut + 1;

        end

        mdl = fitglm(alldat,labels,'Distribution','binomial','Link','logit');
        score_log = mdl.Fitted.Probability; % Probability estimates
        [Xlog,Ylog,Tlog,AUClog] = perfcurve(logical(labels),score_log,'true');
        hplt = plot(Xlog,Ylog);
        hplt.LineWidth = 3;
        %hplt.Color = [0 0.7 0 0.7];
        lgndTtls{c+1}  = sprintf('%s (AUC %.2f)','all areas',AUClog);
        
        legend(lgndTtls,'Location','southeast');
        
        patientROC_at_home.patient{cntOut} = patient{dd}(1:5);
        patientROC_at_home.side{cntOut} = patient{dd}(end);
        patientROC_at_home.electrode{cntOut} = 'all areas';
        patientROC_at_home.freqs{cntOut} = 'all areas';
        patientROC_at_home.AUC{cntOut} = AUClog;
        cntOut = cntOut + 1;
        
        fnmsave = fullfile(resultsdir,'patientROC_at_home_spec_freq.mat');
        save(fnmsave,'patientROC_at_home');
        
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
    
    %% plot effect of segment lenght on AUC accuracy 
    if plot_AUC_vs_segement_length
        createDataSet = 0;
        if createDataSet
            metaData = table();
            resultsdirPatientByMinute = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home/pkg_rcs_by_minute_average_smaller_times';
            minuteGap = ([0.5 1:1:12])./2;
            clear allDataPkgRcsAcc; 
            for mm = 1:length(minuteGap)
                start = tic;
                cnt = 1;
                for i = 1:size(pkgTable,1) % this is looping on rcs data structure
                    minTime = timesPKG(i) - minutes(minuteGap(mm));
                    maxTime = timesPKG(i) + minutes(minuteGap(mm));
                    idxMatch = isbetween(psdTimes',minTime,maxTime);
                    matchingPsdTimes = psdTimes(idxMatch);
                    
                    if ~isempty(matchingPsdTimes)
                        duration = matchingPsdTimes(end) - matchingPsdTimes(1);
                        maxGap   = max(diff(matchingPsdTimes));
                        if duration >= minutes(minuteGap(mm)*0.75) & maxGap < minutes(1)
                            allDataPkgRcsAcc.key0fftOut(cnt,:) = mean(psdResults.key0fftOut(:,idxMatch)',1);
                            allDataPkgRcsAcc.key1fftOut(cnt,:) = mean(psdResults.key1fftOut(:,idxMatch)',1);
                            allDataPkgRcsAcc.key2fftOut(cnt,:) = mean(psdResults.key2fftOut(:,idxMatch)',1);
                            allDataPkgRcsAcc.key3fftOut(cnt,:) = mean(psdResults.key3fftOut(:,idxMatch)',1);
                            allDataPkgRcsAcc.timeStart(cnt)  = matchingPsdTimes(1);
                            allDataPkgRcsAcc.timeEnd(cnt)  = matchingPsdTimes(end);
                            allDataPkgRcsAcc.NumberPSD(cnt) = sum(idxMatch);
                            allDataPkgRcsAcc.duration(cnt) = duration;
                            allDataPkgRcsAcc.ff = psdResults.ff;
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
                savefn = sprintf('%s pkg %s_AveragedOn_min_%.2f.mat',patient{dd},pkgSideUse,minuteGap(mm)*2);
                fnmsave = fullfile(resultsdirPatientByMinute,savefn);

                metaData.patient = patient{dd}(1:5);
                metaData.patientRCSside = patient{dd}(end);
                metaData.patientPKGside = pkgSideUse;
                metaData.filename       = savefn;
                metaData.minuteGap      = minuteGap(mm)*2;
                
                save(fnmsave,'allDataPkgRcsAcc','metaData');
                clear allDataPkgRcsAcc
                fprintf('patient %s min %d done in %.2f seconds\n',patient{dd},minuteGap(mm)*2, toc(start));
            end
        else
            % load the data 
            datadirAUC_spec_latecies = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home/pkg_rcs_by_minute_average_smaller_times'; 
            resultsdir_AUC = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home/pkg_rcs_by_minute_average_smaller_times_results';
            ff = findFilesBVQX(datadirAUC_spec_latecies,'*.mat');
            dataTable = struct(); 
            for f = 1:length(ff)
                metaData = load(ff{f},'metaData'); 
                patData = metaData.metaData;
                dataTable(f).patient = patData.patient;
                dataTable(f).patientRCSside = patData.patientRCSside;
                dataTable(f).patientPKGside = patData.patientPKGside;
                dataTable(f).filename = patData.filename;
                dataTable(f).minuteGap = patData.minuteGap;
            end
            dataTable = struct2table(dataTable); 
            
           
            
            
            
            % loop on patient, side to get AUC for each patient and minute
            % gap 
            uniquePatients = unique(dataTable.patient); 
            %% XXX 
%             uniquePatients = {'RCS07'};
            %% XXX 
            sides = {'L','R'}; 
            for p = 1:length(uniquePatients) % loop on patients 
                for s = 1:2 % loop on side 
                    idpatientAndSide = strcmp(dataTable.patient,uniquePatients{p}) & ... 
                                       strcmp(dataTable.patientRCSside,sides{s}); 
                    patientTable = dataTable(idpatientAndSide,:);  
                    patientTable = sortrows(patientTable,'minuteGap'); 
                    %%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%
                    % xxxxxxxx
                    % xxxxxxxx - hard coded patient table here 
                    % xxxxxxxx -  not done with permutation test 
                    %%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%
                    for m = 11:size(patientTable,1)
                        fn = patientTable.filename{m};
                        try
                            load(fullfile(datadirAUC_spec_latecies,fn));
                        catch
                            fnbuild = sprintf('RCS02 %s pkg %s_AveragedOn_min_%d.mat',...
                                patientTable.patientRCSside{m},patientTable.patientPKGside{m},patientTable.minuteGap(m));
                            load(fullfile(datadirAUC_spec_latecies,fnbuild));
                        end
                        %% get states and frequencies per patient
                        % get specific frequenceis per patiet
                        rawstates = allDataPkgRcsAcc.states';
                        switch patientTable.patient{1}
                            case 'RCS02'
                                % R
                                cnls  =  [0  1  2  3  0  1  2  3  ];
                                freqs =  [19 19 24 25 75 75 76 76];
                                ttls  = {'STN beta','STN beta','M1 beta','M1 beta','STN gamma','STN gamma','M1 gamma','M1 gamma'};
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
                                cnls  =  [0  1  2  3  0  1  2  3  ];
                                freqs =  [27 27 27 27 61 61 61 61];
                                ttls  = {'STN beta','STN beta','M1 beta','M1 beta','STN gamma','STN gamma','M1 gamma','M1 gamma'};
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
                                cnls  =  [0  1  2  3  0  1  2  3  ];
                                freqs =  [19 19 14 26 55 55 61 61];
                                ttls  = {'STN beta','STN beta','M1 beta','M1 beta','STN gamma','STN gamma','M1 gamma','M1 gamma'};
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
                                cnls  =  [0  1  2  3  0  1  2  3  ];
                                freqs =  [19 20 21 24 76 79 80 80];
                                ttls  = {'STN beta','STN beta','M1 beta','M1 beta','STN gamma','STN gamma','M1 gamma','M1 gamma'};
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
                        %% fit the model
                        % get the labels
                        idxuse = strcmp(allstates,'off') | strcmp(allstates,'on');
                        labelsRaw = allstates(idxuse);
                        labels = zeros(size(labelsRaw,1),1);
                        labels(strcmp(labelsRaw,'on')) = 1;
                        %% loop on areas
                        alldat = [];
                        for c = 1:length(cnls)
                            % get channel
                            fn = sprintf('key%dfftOut',cnls(c));
                            % get freq
                            idxfreq = psdResults.ff >= freqs(c)-1 & psdResults.ff <= freqs(c)+1;
                            dat = mean(allDataPkgRcsAcc.(fn)(idxuse,idxfreq),2);
                            datuse = dat;
                            alldat(:,c) = dat;                            
                            %% disc 
                            rng(1); % For reproducibility
                            cvp = cvpartition(logical(labels),'Kfold',5,'stratify',logical(1));
                            doshuffle = 1; 
                            if doshuffle
                                numshuffls = 100;
                            else
                                numshuffls = 1; 
                            end
                            for si =1:numshuffls+1
                                for k = 1:5
                                    idxTrn = training(cvp,k); % Training set indices
                                    idxTest = test(cvp,k);    % Test set indices
                                    tblTrn = array2table(dat(idxTrn,:));
                                    tblTrn.Y = labels(idxTrn);
                                    if doshuffle
                                        if si > 1 % first is real 
                                            rng(si);
                                            labs = labels(idxTrn);
                                            idxshuffle = randperm(length(labs));
                                            labs = labs(idxshuffle);
                                            tblTrn.Y = labs;
                                        end
                                    end
                                    Mdl = fitcdiscr(tblTrn,'Y');
                                    [labeltest,scoretest,costest] = predict(Mdl,dat(idxTest,:));
                                    if doshuffle
                                        [X,Y,T,AUC(k,si),OPTROCPT] = perfcurve(logical(labels(idxTest)),scoretest(:,2),'true');
                                    else
                                        [X,Y,T,AUC(k),OPTROCPT] = perfcurve(logical(labels(idxTest)),scoretest(:,2),'true');
                                    end
                                end
                            end
                            %%
                            headinguse = sprintf('%s %s AUC',ttls{c},titles{cnls(c)+1});
                            if doshuffle
                                realVal = mean(AUC(:,1)); 
                                shufflevals = mean(AUC(:,2:end),1);
                                AUCout(c) = realVal; 
                                sumsmaller = sum(realVal < mean(AUC(:,2:end),1));
                                if sumsmaller == 0 
                                    p = 1/numshuffls; 
                                else
                                    p = sumsmaller/numshuffls; 
                                end
                                AUCpOut(c) = p;
                            else
                                AUCout(c) = mean(AUC);
                            end
                        end
                        %% use all areas
                        for si =1:numshuffls+1
                            for k = 1:5
                                idxTrn = training(cvp,k); % Training set indices
                                idxTest = test(cvp,k);    % Test set indices
                                tblTrn = array2table(alldat(idxTrn,:));
                                tblTrn.Y = labels(idxTrn);
                                if doshuffle
                                    if si > 1 % first is real
                                        rng(si);
                                        labs = labels(idxTrn);
                                        idxshuffle = randperm(length(labs));
                                        labs = labs(idxshuffle);
                                        tblTrn.Y = labs;
                                    end
                                end
                                Mdl = fitcdiscr(tblTrn,'Y');
                                [labeltest,scoretest,costest] = predict(Mdl,dat(idxTest,:));
                                if doshuffle
                                    [X,Y,T,AUC(k,si),OPTROCPT] = perfcurve(logical(labels(idxTest)),scoretest(:,2),'true');
                                else
                                    [X,Y,T,AUC(k),OPTROCPT] = perfcurve(logical(labels(idxTest)),scoretest(:,2),'true');
                                end
                            end
                        end
                        if doshuffle
                            realVal = mean(AUC(:,1));
                            shufflevals = mean(AUC(:,2:end),1);
                            AUCout(c+1) = realVal;
                            sumsmaller = sum(realVal < mean(AUC(:,2:end),1));
                            if sumsmaller == 0
                                p = 1/numshuffls;
                            else
                                p = sumsmaller/numshuffls;
                            end
                            AUCpOut(c+1) = p;
                        else
                            AUCout(c+1) = mean(AUC);
                        end
                        
                        %%
                        patientTable.AUC{m} = AUCout;
                        fnmmuse = sprintf('%s_%s_pkg%s_AUC_by_min_results.mat',patientTable.patient{1},...
                            patientTable.patientRCSside{1},...
                            patientTable.patientPKGside{1});
                        fnmsave = fullfile(resultsdir_AUC,fnmmuse);
                        readme = {'AUC is a matrix with cnls and freqs being the columns used to train a linead disc analysis. the last column is all data combines (all areas'};
                        save(fnmsave,'patientTable','cnls','freqs','titles','readme');
                    end
                    % save this patient data 
                end
            end
        
        end
    end
    %% 
end

return;






%% plot single subject transition 
hfig = figure; 
hfig.Color = 'w'; 
hsb(1) = subplot(3,1,1); 
ffts = allDataPkgRcsAcc.key0fftOut; 
idxuse = 300:500;
idxuse = 1:4e3;

idxnormalize = psdResults.ff > 3 &  psdResults.ff <90;
freqs = psdResults.ff; 
meandat = abs(mean(ffts(:,idxnormalize),2)); % mean within range, by row
% the absolute is to make sure 1/f curve is not flipped
% since PSD values are negative
meanmat = repmat(meandat,1,size(ffts,2));
ffts = ffts./meanmat;


% imagesc(ffts(idxuse,:)'); 
times = allDataPkgRcsAcc.timeStart(idxuse); 
fftsUse = ffts(idxuse,:);
timesrep = repmat(times,size(fftsUse,2),1)';
frequse  = repmat(freqs,1,size(fftsUse,1))';

% only plot non gap areas 
idxzero = find(diff(times) ~= minutes(2)) ; 
for i = 1:length(idxzero)
    fftsUse(idxzero(i),:) = NaN;
end

h = pcolor(datenum(timesrep), frequse,fftsUse); 
set(h, 'EdgeColor', 'none');

set(gca,'YDir','normal') 
ylim([1 100]); 
title('STN'); 
datetick('x','dd-mm HH:MM');

hsb(2) = subplot(3,1,2); 
ffts = allDataPkgRcsAcc.key2fftOut; 
idxnormalize = psdResults.ff > 3 &  psdResults.ff <90;
meandat = abs(mean(ffts(:,idxnormalize),2)); % mean within range, by row
% the absolute is to make sure 1/f curve is not flipped
% since PSD values are negative
meanmat = repmat(meandat,1,size(ffts,2));
ffts = ffts./meanmat;

% imagesc(ffts(idxuse,idxnormalize)');
times = allDataPkgRcsAcc.timeStart(idxuse); 
fftsUse = ffts(idxuse,:);
timesrep = repmat(times,size(fftsUse,2),1)';
frequse  = repmat(freqs,1,size(fftsUse,1))';

% only plot non gap areas 
idxzero = find(diff(times) ~= minutes(2)) ; 
for i = 1:length(idxzero)
    fftsUse(idxzero(i),:) = NaN;
end

h = pcolor(datenum(timesrep), frequse,fftsUse); 
set(h, 'EdgeColor', 'none');



set(gca,'YDir','normal') 
title('M1'); 			
timeuse = allDataPkgRcsAcc.timeStart(idxuse); 
timeuse = datenum(timeuse); 
datetick('x', 'dd-mm HH:MM','keepticks');


hsb(3) = subplot(3,1,3); 
hold on; 
dkvals = allDataPkgRcsAcc.dkVals(idxuse); 
dkvals(dkvals==0) = 0.1;
dkvals = log10(dkvals);

scatter(timeuse, dkvals,...
    50,'filled','MarkerFaceColor',[0 0 0],'MarkerFaceAlpha',0.5);

movData = movmean(dkvals,[10 10]);

plot(timeuse,movData,'LineWidth',2,...
    'Color',[0 0 0 0.5]); 
title('Dyskinesia'); 

linkaxes(hsb,'x'); 
datetick('x', 'dd-mm HH:MM');

prfig.plotwidth           = 15;
prfig.plotheight          = 10;
prfig.figdir             = figdirout;
prfig.figname             = sprintf('%s %s pkg %s','Spectral_data_while_streaming_at_home',patient{dd},pkgSideUse);
plot_hfig(hfig,prfig)

%% plot coherence patient stats
idxuse = 400:550;
idxuse = 1:1e3;
hfig = figure; 
hfig.Color = 'w';
hsb(1) = subplot(21,1,[1:9]); 
ffts = allDataPkgRcsAccCoh.stn13m10810; 
freqs = coherenceResultsTd.ff; 
% imagesc(ffts(idxuse,idxnormalize)');
times = allDataPkgRcsAccCoh.timeStart(idxuse); 
fftsUse = ffts(idxuse,:);
timesrep = repmat(times,size(fftsUse,2),1)';
frequse  = repmat(freqs,1,size(fftsUse,1))';

% only plot non gap areas 
idxzero = find(diff(times) ~= minutes(2)) ; 
for i = 1:length(idxzero)
    fftsUse(idxzero(i),:) = NaN;
end

h = pcolor(datenum(timesrep), frequse,fftsUse); 
set(h, 'EdgeColor', 'none');



set(gca,'YDir','normal') 
ylabel('MS coherence'); 
title('Coherence between stn m1'); 			
set(gca,'FontSize',16);
timeuse = allDataPkgRcsAccCoh.timeStart(idxuse); 
timeuse = datenum(timeuse); 
datetick('x', 'HH:MM');


hsb(2) = subplot(21,1,[10:19]); 
hold on; 
dkvals = allDataPkgRcsAccCoh.dkVals(idxuse); 
dkvals(dkvals==0) = 0.1;
dkvals = log10(dkvals);

scatter(timeuse, dkvals,...
    50,'filled','MarkerFaceColor',[0 0 0],'MarkerFaceAlpha',0.5);

movData = movmean(dkvals,[10 10]);

plot(timeuse,movData,'LineWidth',2,...
    'Color',[0 0 0 0.5]); 
title('Dyskinesia scores - PKG watch'); 
ylabel('Dyskinesia scores'); 
set(gca,'FontSize',16);


% plot state 
hsb(3) = subplot(21,1,20:21);
hold on;
[uq,idxunqtimes] = unique(allDataPkgRcsAccCoh.timeStart);

rawstates = allDataPkgRcsAccCoh.states(idxunqtimes);


switch patient{dd}(1:5)
    case 'RCS02'
        onidx = cellfun(@(x) any(strfind(x,'dyskinesia severe')),rawstates);
        offidx = cellfun(@(x) any(strfind(x,'off')),rawstates) | ...
            cellfun(@(x) any(strfind(x,'on')),rawstates) | ...
            cellfun(@(x) any(strfind(x,'tremor')),rawstates);
        sleeidx = cellfun(@(x) any(strfind(x,'sleep')),rawstates);
    case 'RCS05'
        onidx = cellfun(@(x) any(strfind(x,'dyskinesia')),rawstates) | ...
            cellfun(@(x) any(strfind(x,'on')),rawstates);
        offidx = cellfun(@(x) any(strfind(x,'off')),rawstates) | ...
            cellfun(@(x) any(strfind(x,'tremor')),rawstates);
        sleeidx = cellfun(@(x) any(strfind(x,'sleep')),rawstates);
    case 'RCS06'
        onidx = cellfun(@(x) any(strfind(x,'dyskinesia')),rawstates) | ...
            cellfun(@(x) any(strfind(x,'on')),rawstates);
        offidx = cellfun(@(x) any(strfind(x,'off')),rawstates) | ...
            cellfun(@(x) any(strfind(x,'tremor')),rawstates);
        sleeidx = cellfun(@(x) any(strfind(x,'sleep')),rawstates);
    case 'RCS07'
        onidx = cellfun(@(x) any(strfind(x,'dyskinesia')),rawstates) | ...
            cellfun(@(x) any(strfind(x,'on')),rawstates);
        offidx = cellfun(@(x) any(strfind(x,'off')),rawstates) | ...
            cellfun(@(x) any(strfind(x,'tremor')),rawstates);
        sleeidx = cellfun(@(x) any(strfind(x,'sleep')),rawstates);
    case 'RCS08'
        onidx = cellfun(@(x) any(strfind(x,'dyskinesia')),rawstates) | ...
            cellfun(@(x) any(strfind(x,'on')),rawstates);
        offidx = cellfun(@(x) any(strfind(x,'off')),rawstates) | ...
            cellfun(@(x) any(strfind(x,'tremor')),rawstates);
        sleeidx = cellfun(@(x) any(strfind(x,'sleep')),rawstates);
end
otheridx =  ~(sleeidx | onidx | offidx);
times = allDataPkgRcsAccCoh.timeStart(idxunqtimes);
times = datenum(times); 

hbron = bar(times(onidx),repmat(-0.2,1,sum(onidx)),'stacked');
hbron.FaceColor = [0 0.8 0];
hbron.FaceAlpha = 0.6;
hbron.EdgeColor = 'none';
hbron.BarWidth = 1;

hbroff = bar(times(offidx),repmat(-0.2,1,sum(offidx)),'stacked');
hbroff.FaceColor = [0.8 0 0];
hbroff.FaceAlpha = 0.6;
hbroff.EdgeColor = 'none';
hbroff.BarWidth = 1;

hbrsleep = bar(times(sleeidx),repmat(-0.2,1,sum(sleeidx)),'stacked');
hbrsleep.FaceColor = [0 0 0.8];
hbrsleep.FaceAlpha = 0.6;
hbrsleep.EdgeColor = 'none';
hbrsleep.BarWidth = 1;



hbrother = bar(times(otheridx),repmat(-0.2,1,sum(otheridx)),'stacked');
hbrother.FaceColor = [0.5 0.5 0.5];
hbrother.FaceAlpha = 0.6;
hbrother.EdgeColor = 'none';
hbrother.BarWidth = 1;


legend([ hbron hbroff hbrsleep hbrother],{'on','off','sleep','other'});
title('state classification');

linkaxes(hsb,'x'); 


datetick('x', 'HH:MM');
prfig.plotwidth           = 15;
prfig.plotheight          = 10;
prfig.figdir             = figdirout;
prfig.figname             = sprintf('%s %s pkg %s','coherence _data_while_streaming_at_home',patient{dd},pkgSideUse);
% plot_hfig(hfig,prfig)


%% plot violin plots based on coherence 
addpath(genpath(fullfile(pwd,'toolboxes','violin')));
betafreq = 21; 
gamafreq = 75; 
bw = 1.5; 
freqidx = cohResults.ff >= (betafreq-bw) & cohResults.ff <= (betafreq+bw);
fftsUse = allDataPkgRcsAccCoh.stn13m10810(idxunqtimes,:); 

toplot{1,1} = mean(fftsUse(onidx,freqidx),2);
toplot{1,2} = mean(fftsUse(offidx,freqidx),2);

freqidx = cohResults.ff >= (gamafreq-bw) & cohResults.ff <= (gamafreq+bw);
toplot{1,3} = mean(fftsUse(onidx,freqidx),2);
toplot{1,4} = mean(fftsUse(offidx,freqidx),2);

hfig = figure;
hsb = subplot(1,1,1); 
hfig.Color = 'w'; 

hviolin  = violin(toplot);
hviolin(1).FaceColor = [0 0.8 0];
hviolin(1).FaceAlpha = 0.3;

hviolin(2).FaceColor = [0.8 0 0];
hviolin(2).FaceAlpha = 0.3;

hviolin(3).FaceColor = [0 0.8 0];
hviolin(3).FaceAlpha = 0.3;

hviolin(4).FaceColor = [0.8 0 0];
hviolin(4).FaceAlpha = 0.3;


ylabel('MS coherence'); 

hsb.XTick = [ 1 2 3 4]; 
hsb.XTickLabel  = {'on state - beta', 'off state beta' ,'on state - gamma', 'off state gamma'}; 
hsb.XTickLabelRotation = 45;

title('coherence comparison - RCS02'); 

set(gca,'FontSize',20);

%% 





%% percent data keep 
fprintf('mean data thrown out %.2f range (%.2f - %.2f)\n',mean(throwout),min(throwout),max(throwout));
return;

%% plot ROC box plot PCA 
addpath(fullfile(pwd,'toolboxes','notBoxPlot','code'));
load('/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home/patientROC_at_home.mat'); 
figdirout = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/pkg_data/figures';

toPlot = table(); 
idxuse = strcmp(patientROC_at_home.electrode,'STN 1-3') | ... 
    strcmp(patientROC_at_home.electrode,'M1 8-10') | ... 
    strcmp(patientROC_at_home.electrode,'all areas') ;
patientROC_at_home = patientROC_at_home(idxuse,:); 
xvals = zeros(size(patientROC_at_home,1),1);
xvals( strcmp(patientROC_at_home.electrode,'STN 1-3') ) = 1;
xvals( strcmp(patientROC_at_home.electrode,'M1 8-10') ) = 2;
xvals( strcmp(patientROC_at_home.electrode,'all areas') ) = 3;

AUC = cell2mat(patientROC_at_home.AUC);

hfig = figure;
hfig.Color = 'w';
hsb = subplot(1,1,1); 
nbp = notBoxPlot(AUC,xvals); 
hsb.XTickLabel = {'STN 1-3 (2xPCs)','M1 8-10 (2xPCs)','All areas'};
ylabel('AUC'); 
title('M1 & STN best for decoding (4 patients, 8 ''sides'') [PCA]'); 
ylim([0.4 1.1]);
set(gca,'FontSize',20);
prfig.plotwidth           = 15;
prfig.plotheight          = 10;
prfig.figname             = 'AUC summary figure';
prfig.figdir             = figdirout;
plot_hfig(hfig,prfig)
%% 

%% plot ROC box plot spec freqs 
addpath(fullfile(pwd,'toolboxes','notBoxPlot','code'));
load('/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home/patientROC_at_home_spec_freq.mat'); 
figdirout = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/pkg_data/figures';

toPlot = table(); 
idxuse = strcmp(patientROC_at_home.freqs,'STN beta') | ... 
    strcmp(patientROC_at_home.freqs,'M1 Gamma') | ... 
    strcmp(patientROC_at_home.freqs,'all areas') ;
patientROC_at_home = patientROC_at_home(idxuse,:); 
xvals = zeros(size(patientROC_at_home,1),1);
xvals( strcmp(patientROC_at_home.freqs,'STN beta') ) = 1;
xvals( strcmp(patientROC_at_home.freqs,'M1 Gamma') ) = 2;
xvals( strcmp(patientROC_at_home.freqs,'all areas') ) = 3;

AUC = cell2mat(patientROC_at_home.AUC);

hfig = figure;
hfig.Color = 'w';
hsb = subplot(1,1,1); 
nbp = notBoxPlot(AUC,xvals); 
hsb.XTickLabel = {'STN Beta','M1 Gamma','All areas'};
ylabel('AUC'); 
ylim([0.4 1.1]);
title('M1 & STN best for decoding (4 patients, 8 ''sides'') [peak freqs]'); 
set(gca,'FontSize',20);
prfig.plotwidth           = 15;
prfig.plotheight          = 10;
prfig.figname             = 'AUC summary figure spec freqs';
prfig.figdir             = figdirout;
plot_hfig(hfig,prfig)
%% 

%% plot unsupervised clustering rodtrigez 

close all; clear all; clc; 

% load in clinic data 
dirname = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/in_clinic/rest_3rd_try';
fnmsave = fullfile(dirname,'patientPSD_in_clinic.mat');
load(fnmsave,'patientPSD_in_clinic');


addpath(genpath(fullfile('toolboxes','cluster_dp')));
rootdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home'; 
patientDirs = findFilesBVQX(rootdir,'RCS*',struct('dirs',1,'depth',1));
pruse.minaverage = 10; 
pruse.maxgap = 120; % seconds 
for p = 1:length(patientDirs) % loop on patient 
    patSideFiles = findFilesBVQX(patientDirs{p},'psdResults_*.mat');
    [fnn,patientName] = fileparts(patientDirs{p});
    for s = 1:length(patSideFiles)
        load(patSideFiles{s}); 
        [~,rawside] = fileparts(patSideFiles{s});
        patientSide = rawside(end); 
        % avarege psds on 10 minute increments 
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
            meanVals = mean(psdResults.(fn)(:,80:100),2);
            boxplot(meanVals);
            q75_test=quantile(meanVals,0.75);
            q25_test=quantile(meanVals,0.25);
            w=2.0;
            wUpper(c) = w*(q75_test-q25_test)+q75_test;
            idxWhisker(:,c) = meanVals < wUpper(c);
        end
        idxkeep = idxWhisker(:,1) &  idxWhisker(:,2) & idxWhisker(:,3) & idxWhisker(:,4) ;
        sgtitle(sprintf('confriming outlier algo'),'FontSize',20);
        close(hfig);
        
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
        close(hfig);
        % average and normalize data
        rangekeep = [13 30;
            13 30;
            60 80;
            60 80];
        fftSpecFreqs = []; 
        
        freqranges = [1 4; 4 8; 8 13; 13 20; 20 30; 13 30; 30 50; 50 90];
        freqnames  = {'Delta', 'Theta', 'Alpha','LowBeta','HighBeta','Beta','LowGamma','HighGamma'}';

        usespecfreq = 1; 
        cntfreq = 1; 
        for c = 1:4
            fn = sprintf('key%dfftOut',c-1);
            hsub = subplot(2,2,c);
            if usespecfreq
                for sf = 1:size(freqranges,1)
                    idxfreqs = psdResults.ff >= freqranges(sf,1) & psdResults.ff <= freqranges(sf,2) 
                    % normalize the data
                    dat = psdResults.(fn); 
                    idxnormalize = psdResults.ff > 3 &  psdResults.ff <90;
                    meandat = abs(mean(dat(:,idxnormalize),2)); % mean within range, by row
                    % the absolute is to make sure 1/f curve is not flipped
                    % since PSD values are negative
                    meanmat = repmat(meandat,1,size(dat,2));
                    dat = dat./meanmat;

                    dat = dat(idxkeep,idxfreqs);

                    fftSpecFreqs(:,cntfreq) = mean(dat,2);
                    cntfreq = cntfreq + 1;
                end

            else
                idxfreqs = psdResults.ff >= rangekeep(c,1) & psdResults.ff <= rangekeep(c,2)
                dat = psdResults.(fn)(idxkeep,idxfreqs);
                fftSpecFreqs(:,c) = mean(dat,2);
            end
            %XXXXXXXXXX
            %XXXXXXXXXX
            %XXXXXXXXXX
            %XXXXXXXXXX
            % ALLL
            
            %XXXXXXXXXX
            %XXXXXXXXXX
            %XXXXXXXXXX
            %XXXXXXXXXX
        end
        

        % do clustering
        %XXXXXXXXXX
        %XXXXXXXXXX
        %XXXXXXXXXX
        %XXXXXXXXXX
        % ALLL
        
        %XXXXXXXXXX
        %XXXXXXXXXX
        %XXXXXXXXXX
        %XXXXXXXXXX
        idxfreqs = psdResults.ff >= 1 & psdResults.ff <= 95
        fn = sprintf('key%dfftOut',2);
        dat = psdResults.(fn)(idxkeep,idxfreqs);
        
        
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
        [cl,halo] =  cluster_dp(distanceMat,'results');
        
        % plot clusering 
        clusers = 1:3
        hfig = figure; 
        hfig.Color = 'w';
        
        colorsUse = [0.8 0 0;...
            0 0.8 0;...
            0 0 0.8]
        uniqueCluster = unique(cl); 
        colorsUse = parula(length(uniqueCluster));
        plotShaded = 1; 
        plotRaw = 0; 
        for c = 1:4
            fn = sprintf('key%dfftOut',c-1);
            hsub = subplot(2,2,c);
            hold on; 
            dat = psdResults.(fn);
            % normalize the data
            dat = psdResults.(fn);
            idxnormalize = psdResults.ff > 3 &  psdResults.ff <90;
            meandat = abs(mean(dat(:,idxnormalize),2)); % mean within range, by row
            % the absolute is to make sure 1/f curve is not flipped
            % since PSD values are negative
            meanmat = repmat(meandat,1,size(dat,2));
            dat = dat./meanmat;

            freqs = psdResults.ff; 
            for cu = 1:length(uniqueCluster)
                % cluster 1
                if plotShaded
                    hsb = shadedErrorBar(freqs,dat(cl==cu,:),{@median,@(x) std(x)*1});
                    hsb.mainLine.Color = [colorsUse(cu,:) 0.5];
                    hsb.mainLine.LineWidth = 3;
                    hsb.patch.MarkerFaceColor = colorsUse(cu,:);
                    hsb.patch.FaceColor = colorsUse(cu,:);
                    hsb.patch.FaceAlpha = 0.1;
                end
                if plotRaw
                    plot(freqs,dat(cl==cu,:),...
                        'LineWidth',0.1,...
                        'Color',[colorsUse(cu,:) 0.2]); 
                end
            end
            ylabel('Power (log_1_0\muV^2/Hz)');
            xlabel('Frequency (Hz)');
            xlim([0 100]);
            title(ttls{c}); 
            % plot the template data 
            relidx = strcmp(patientPSD_in_clinic.patient,patientName) & ...
                     strcmp(patientPSD_in_clinic.side,patientSide) & ... 
                     strcmp(patientPSD_in_clinic.electrode,ttls{c}); 
            inClinicTable = patientPSD_in_clinic(relidx,:); 
            colorsForInClinic = [0.8 0 0 0.5; 0 0.8 0 0.6];
            conds = {'off','on'}; 
            for oo = 1:2 
                idxuseonoff = strcmp(inClinicTable.medstate,conds{oo}); 
                ff = inClinicTable.ff{idxuseonoff}; 
                fftOut = inClinicTable.fftOutNorm{idxuseonoff}; 
                plot(ff,fftOut,'LineWidth',4,'Color',colorsForInClinic(oo,:));
            end
            set(gca,'FontSize',16);
        end
        
        ttluse = sprintf('%s %s',patientName,patientSide); 
        sgtitle(ttluse,'FontSize',20);
        figname = sprintf('unsupervised_clustering_10min_including_sleep_can_freqs and_template_data_ raw %s %s',patientName,patientSide); 
        prfig.plotwidth           = 15;
        prfig.plotheight          = 10;
        prfig.figname             = figname;
        prfig.figdir              = patientDirs{p};
        plot_hfig(hfig,prfig)

    end
    
end

%% plot template clustering 
% load home data  and make table of patient and side 
addpath(genpath(fullfile(pwd,'toolboxes','shadedErrorBar')))
close all; clear all; clc;
rootdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/pkg_data/figures/17_states_historical'; 
figdirout = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/pkg_data/figures/template_matching';
ff = findFilesBVQX(rootdir, 'pkg_states*10_min*.mat');
patDatHome = struct(); 
for f = 1:length(ff) 
    [pn,fn] = fileparts(ff{f}); 
    patient = fn(12:16);
    side = fn(18);
    patDatHome(f).patient = patient; 
    patDatHome(f).side = side; 
    patDatHome(f).filename = ff{f}; 
end
patDatHome = struct2table(patDatHome);

% load in clinic data 
dirname = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/in_clinic/rest_3rd_try';
fnmsave = fullfile(dirname,'patientPSD_in_clinic.mat');
load(fnmsave,'patientPSD_in_clinic');

% loop on patients 
colors = [0.8 0 0; 0 0.8 0;0 0 0.8; 0.5 0.5 0.5];
for pp = 1:size(patDatHome)
    load(patDatHome.filename{pp}); 
    idxPsdClinic = strcmp(patientPSD_in_clinic.patient,patDatHome.patient{pp}) & ...
                   strcmp(patientPSD_in_clinic.side,patDatHome.side{pp})
    psdInClinicAllAreas = patientPSD_in_clinic(idxPsdClinic,:); 
    hfig = figure;
    hfig.Color = 'w'; 
    % loop on area 
    for c = 1:length(titles) % loop on channels 
        % get clinic template 
        idxarea = strcmp(psdInClinicAllAreas.electrode,titles{c});
        psdInClinic = psdInClinicAllAreas(idxarea,:);
        % get at home data 
        fieldNameAtHome = sprintf('key%dfftOut',c-1);
        psdHome = allDataPkgRcsAcc.(fieldNameAtHome);
        idxnormalize = psdResults.ff > 3 &  psdResults.ff <90;
        meandat = abs(mean(psdHome(:,idxnormalize),2)); % mean within range, by row
        % the absolute is to make sure 1/f curve is not flipped
        % since PSD values are negative
        meanmat = repmat(meandat,1,size(psdHome,2));
        normalizedPSD = psdHome./meanmat;
        % normalizedPSD = rescale(normalizedPSD,0,1); 

        % loop on states 
        unqStates = unique(psdInClinic.medstate); 
        d = [];
        fftTemplateUse = []; 
        % get templates 
        for m = 1:length(unqStates)
            idxuse = strcmp(psdInClinic.medstate,unqStates{m});
            psdUse = psdInClinic(idxuse,:);
            fftTemplateUse(:,m) = psdUse.fftOut{:};
        end
        % normalize templates from in clinic use 
        fftTemplate = fftTemplateUse';
        idxnormalize = psdInClinic.ff{1} > 3 &  psdInClinic.ff{1} <90;
        meandatinclinic = abs(mean(fftTemplate(:,idxnormalize),2)); % mean within range, by row
        % the absolute is to make sure 1/f curve is not flipped
        % since PSD values are negative
        meanmatinclinic = repmat(meandatinclinic,1,size(fftTemplate,2));
        normalizedFFTtemp = fftTemplate./meanmatinclinic;
        % normalizedFFTtemp = rescale(normalizedFFTtemp,0,1);
        normalizedFFTtemp = normalizedFFTtemp';
        
        freqsInClinic = psdInClinic.ff{1}'; 
        freqsAtHome   = psdResults.ff;
        if length(freqsAtHome) < length(freqsInClinic)
            normalizedFFTtemp = interp1(freqsInClinic,normalizedFFTtemp,freqsAtHome);
        end
        
        

        % plot raw data
        
        % compute distances 
        fftTempOut = []; fftTempOut = []; 
        for m = 1:length(unqStates)
            fftTemRep = repmat(normalizedFFTtemp(:,m)',size(normalizedPSD,1),1);
            d(:,m) = vecnorm(normalizedPSD' - fftTemRep')';
        end
        
        plotRaw = 0;
        plotState = 1; 
        plotDistance = 0; 
        subplot(2,2,c);
        if plotRaw 
            hold on;
            plot(normalizedPSD','LineWidth',0.1,'Color',[0 0 0.8 0.01]);
            plot(normalizedFFTtemp(:,1)','LineWidth',6,'Color',[0.8 0 0 0.4]);
            plot(normalizedFFTtemp(:,2)','LineWidth',6,'Color',[0. 0.8 0 0.4]);
            xlim([0 100]); 
            title(titles{c});
            xlabel('Frequency (Hz)');
            ylabel('Rescaled power (a.u.)');
            set(gca,'FontSize',16);
        end

        if plotState 
            for s = 1:2
                if s == 1
                    labels = d(:,2) > d(:,1);
                else
                    labels = d(:,1) > d(:,2);
                end
                if sum(labels) > 1
                    hsbH = shadedErrorBar(psdResults.ff,normalizedPSD(labels,:),{@mean,@(x) std(x)*1});
                    hsbH.mainLine.Color = [colors(s,:) 0.5];
                    hsbH.mainLine.LineWidth = 3;
                    hsbH.patch.MarkerFaceColor = colors(s,:);
                    hsbH.patch.FaceColor = colors(s,:);
                    hsbH.patch.EdgeColor = colors(s,:);
                    hsbH.edge(1).Color = [colors(s,:) 0.1];
                    hsbH.edge(2).Color = [colors(s,:) 0.1];
                    hsbH.patch.EdgeAlpha = 0.1;
                    hsbH.patch.FaceAlpha = 0.1;
                    hForLeg(s) = hsbH.mainLine;
                end
            end
            xlim([0 100]); 
            title(titles{c});
            xlabel('Frequency (Hz)');
            ylabel('Rescaled power (a.u.)');
            set(gca,'FontSize',16);

        end
        
        if plotDistance
            hold on; 
            hs = scatter(d(:,1),d(:,2),10,'filled','MarkerFaceColor',[0 0 0.8],'MarkerFaceAlpha',0.2);
            axis equal;
            mind = min(d(:));
            maxd = max(d(:));
            x = linspace(mind,maxd,100);
            y = linspace(mind,maxd,100);
            plot(x,y,'LineWidth',2,'Color',[0.5 0.5 0.5 0.3]);
            xlabel('distance to in clinic off');
            ylabel('distance to in clinic on');
            set(gca,'FontSize',16);
        end

        
        
        
        
    end
    
    if plotRaw
        figname = sprintf('templateMatching - raw  %s %s',patDatHome.patient{pp},patDatHome.side{pp});
    end
    if plotState
        figname = sprintf('templateMatching - state  %s %s',patDatHome.patient{pp},patDatHome.side{pp});
    end
    if plotDistance
        figname = sprintf('templateMatching - distnace  %s %s',patDatHome.patient{pp},patDatHome.side{pp});
    end

    ttluse = sprintf('template matching %s %s',patDatHome.patient{pp},patDatHome.side{pp});
    sgtitle(ttluse,'FontSize',20);

    
    prfig.plotwidth           = 15;
    prfig.plotheight          = 10;
    prfig.figname             = figname;
    prfig.figdir              = figdirout
    plot_hfig(hfig,prfig)

end


%% 

%% plot template matching 
addpath(genpath(fullfile('toolboxes','cluster_dp')));
rootdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home'; 
load /Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/in_clinic/rest_3rd_try/patientPSD_in_clinic.mat
patientDirs = findFilesBVQX(rootdir,'RCS*',struct('dirs',1,'depth',1));
pruse.minaverage = 10; 
pruse.maxgap = 120; % seconds 
for p = 1:length(patientDirs) % loop on patient 
    patSideFiles = findFilesBVQX(patientDirs{p},'psdResults_*.mat');
    [fnn,patientName] = fileparts(patientDirs{p});
    for s = 1:length(patSideFiles)
        load(patSideFiles{s}); 
        [~,rawside] = fileparts(patSideFiles{s});
        patientSide = rawside(end); 
        % avarege psds on 10 minute increments 
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
            meanVals = mean(psdResults.(fn)(:,80:100),2);
            boxplot(meanVals);
            q75_test=quantile(meanVals,0.75);
            q25_test=quantile(meanVals,0.25);
            w=2.0;
            wUpper(c) = w*(q75_test-q25_test)+q75_test;
            idxWhisker(:,c) = meanVals < wUpper(c);
        end
        idxkeep = idxWhisker(:,1) &  idxWhisker(:,2) & idxWhisker(:,3) & idxWhisker(:,4) ;
        sgtitle(sprintf('confriming outlier algo'),'FontSize',20);
        close(hfig);
        
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
        close(hfig);
        
        
        % average and normalize data
        rangekeep = [13 30;
            13 30;
            60 80;
            60 80];
        fftSpecFreqs = []; 
        for c = 1:4
            fn = sprintf('key%dfftOut',c-1);
            hsub = subplot(2,2,c);
            idxfreqs = psdResults.ff >= rangekeep(c,1) & psdResults.ff <= rangekeep(c,2)
            dat = psdResults.(fn)(idxkeep,idxfreqs);
            fftSpecFreqs(:,c) = mean(dat,2); 
        end
        

        % do clustering 
                
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
        [cl,halo] =  cluster_dp(distanceMat,'results');
        
        % plot clusering 
        clusers = 1:2
        hfig = figure; 
        hfig.Color = 'w';
        for c = 1:4
            fn = sprintf('key%dfftOut',c-1);
            hsub = subplot(2,2,c);
            dat = psdResults.(fn);
            freqs = psdResults.ff; 
            % cluster 1 
            hsb = shadedErrorBar(freqs,dat(cl==1,:),{@median,@(x) std(x)*1});
            hsb.mainLine.Color = [0.8 0 0 0.5]
            hsb.mainLine.LineWidth = 3;
            hsb.patch.MarkerFaceColor = [0.8 0 0];
            hsb.patch.FaceColor = [0.8 0 0];
            hsb.patch.FaceAlpha = 0.1;
            % cluster 2 
            hsb = shadedErrorBar(freqs,dat(cl==2,:),{@median,@(x) std(x)*1});
            hsb.mainLine.Color = [0 0.8 0 0.5]
            hsb.mainLine.LineWidth = 3;
            hsb.patch.MarkerFaceColor = [0 0.8 0];
            hsb.patch.FaceColor = [0 0.8 0];
            hsb.patch.FaceAlpha = 0.1;
            ylabel('Power (log_1_0\muV^2/Hz)');
            xlabel('Frequency (Hz)');
            xlim([0 100]);
            title(ttls{c}); 
            set(gca,'FontSize',16);
        end
        ttluse = sprintf('%s %s',patientName,patientSide); 
        sgtitle(ttluse,'FontSize',20);
        figname = sprintf('unsupervised_clustering_10min_ %s %s',patientName,patientSide); 
        prfig.plotwidth           = 15;
        prfig.plotheight          = 10;
        prfig.figname             = figname;
        prfig.figdir              = patientDirs{p};
        plot_hfig(hfig,prfig)

    end
    
end

%% plot effect of segment averageing lengh on AUC accuracy 
 % load the data 
 datadirAUC_spec_latecies = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home/pkg_rcs_by_minute_average_smaller_times';
 resultsdir_AUC = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home/pkg_rcs_by_minute_average_smaller_times_results';
 ff = findFilesBVQX(datadirAUC_spec_latecies,'*.mat');
 titles = {'STN 0-2','STN 1-3','M1 8-10','M1 9-11'};
 dataTable = struct();
 for f = 1:length(ff)
     metaData = load(ff{f},'metaData');
     patData = metaData.metaData;
     dataTable(f).patient = patData.patient;
     dataTable(f).patientRCSside = patData.patientRCSside;
     dataTable(f).patientPKGside = patData.patientPKGside;
     dataTable(f).filename = patData.filename;
     dataTable(f).minuteGap = patData.minuteGap;
 end
 dataTable = struct2table(dataTable);
 
 
 
 
 
 % loop on patient, side to get AUC for each patient and minute
 % gap
 uniquePatients = unique(dataTable.patient);
 %
 %             uniquePatients = {'RCS07'};
 %
 sides = {'L','R'};
 for p = 1:length(uniquePatients) % loop on patients
     for s = 1:2 % loop on side
         idpatientAndSide = strcmp(dataTable.patient,uniquePatients{p}) & ...
             strcmp(dataTable.patientRCSside,sides{s});
         patientTable = dataTable(idpatientAndSide,:);
         patientTable = sortrows(patientTable,'minuteGap');
         for m = 1:size(patientTable,1)
             fn = patientTable.filename{m};
             try
                 load(fullfile(datadirAUC_spec_latecies,fn));
             catch
                 fnbuild = sprintf('RCS02 %s pkg %s_AveragedOn_min_%d.mat',...
                     patientTable.patientRCSside{m},patientTable.patientPKGside{m},patientTable.minuteGap(m));
                 load(fullfile(datadirAUC_spec_latecies,fnbuild));
             end
             % get states and frequencies per patient
             % get specific frequenceis per patiet
             rawstates = allDataPkgRcsAcc.states';
             switch patientTable.patient{1}
                 case 'RCS02'
                     % R
                     cnls  =  [0  1  2  3  0  1  2  3  ];
                     freqs =  [19 19 24 25 75 75 76 76];
                     ttls  = {'STN beta','STN beta','M1 beta','M1 beta','STN gamma','STN gamma','M1 gamma','M1 gamma'};
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
                     cnls  =  [0  1  2  3  0  1  2  3  ];
                     freqs =  [27 27 27 27 61 61 61 61];
                     ttls  = {'STN beta','STN beta','M1 beta','M1 beta','STN gamma','STN gamma','M1 gamma','M1 gamma'};
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
                     cnls  =  [0  1  2  3  0  1  2  3  ];
                     freqs =  [19 19 14 26 55 55 61 61];
                     ttls  = {'STN beta','STN beta','M1 beta','M1 beta','STN gamma','STN gamma','M1 gamma','M1 gamma'};
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
                     cnls  =  [0  1  2  3  0  1  2  3  ];
                     freqs =  [19 20 21 24 76 79 80 80];
                     ttls  = {'STN beta','STN beta','M1 beta','M1 beta','STN gamma','STN gamma','M1 gamma','M1 gamma'};
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
             % fit the model
             % get the labels
             idxuse = strcmp(allstates,'off') | strcmp(allstates,'on');
             labelsRaw = allstates(idxuse);
             labels = zeros(size(labelsRaw,1),1);
             labels(strcmp(labelsRaw,'on')) = 1;
             % loop on areas
             alldat = [];
             for c = 1:length(cnls)
                 % get channel
                 fn = sprintf('key%dfftOut',cnls(c));
                 % get freq
                 idxfreq = allDataPkgRcsAcc.ff >= freqs(c)-1 & allDataPkgRcsAcc.ff <= freqs(c)+1;
                 dat = mean(allDataPkgRcsAcc.(fn)(idxuse,idxfreq),2);
                 datuse = dat;
                 alldat(:,c) = dat;
                 %% disc
                 rng(1); % For reproducibility
                 cvp = cvpartition(logical(labels),'Kfold',5,'stratify',logical(1));
                 for k = 1:5
                     idxTrn = training(cvp,k); % Training set indices
                     idxTest = test(cvp,k);    % Test set indices
                     tblTrn = array2table(dat(idxTrn,:));
                     tblTrn.Y = labels(idxTrn);
                     Mdl = fitcdiscr(tblTrn,'Y');
                     [labeltest,scoretest,costest] = predict(Mdl,dat(idxTest,:));
                     [X,Y,T,AUC(k),OPTROCPT] = perfcurve(logical(labels(idxTest)),scoretest(:,2),'true');
                 end
                 %%
                 headinguse = sprintf('%s %s AUC',ttls{c},titles{cnls(c)+1});
                 AUCout(c) = mean(AUC);
             end
             % use all areas
             tblTrn = array2table(alldat(idxTrn,:));
             tblTrn.Y = labels(idxTrn);
             Mdl = fitcdiscr(tblTrn,'Y');
             [labeltest,scoretest,costest] = predict(Mdl,alldat(idxTest,:));
             [X,Y,T,AUC,OPTROCPT] = perfcurve(logical(labels(idxTest)),scoretest(:,2),'true');
             AUCout(c+1) = AUC;
             %
             patientTable.AUC{m} = AUCout;
             fnmmuse = sprintf('%s_%s_pkg%s_AUC_by_min_results.mat',patientTable.patient{1},...
                 patientTable.patientRCSside{1},...
                 patientTable.patientPKGside{1});
             fnmsave = fullfile(resultsdir_AUC,fnmmuse);
             readme = {'AUC is a matrix with cnls and freqs being the columns used to train a linead disc analysis. the last column is all data combines (all areas'};
             save(fnmsave,'patientTable','cnls','freqs','titles','readme');
         end
         % save this patient data
     end
 end
%%

%%




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