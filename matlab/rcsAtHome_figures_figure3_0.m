function rcsAtHome_figures_figure3_0()
%%
rootdir = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/processed_data';
patientAnalyze = {'RCS02'};
dataTable = table();
cntTbl = 1;
ff = findFilesBVQX(rootdir,['*psdAndCoherence*stim*.mat']);
for f = 1:length(ff)
    load(ff{f},'database');
    metaData = database(:,{'patient','side','area','diagnosis'});
    timeAwake = seconds(0);
    timeAsleep = seconds(0);
    
    for d = 1:size(database)
        if day(database.timeStart) == day(database.timeEnd)
            x = 2;
        else
        end
        
    end
    
end
%%
%% panel a bar graph of total hours awake / alseep 
fignum = 5; 
figdirout = '/Users/roee/Starr_Lab_Folder/Writing/papers/2019_LongTerm_RCS_recordings/figures/final_figures/Fig5_states_estimates_group_data_and_ AUC';
figdirout = '/Users/roee/Box/rcs paper paper on first five bilateral implants/revision for nature biotechnology/figures/Fig5_states_estimates_group_data_and_ AUC';
% origina funciton used: plot_pkg_data_all_subjects
resultsdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home/synced_rcs_pkg_data_saved';
resultsdir = '/Users/roee/Box/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home/synced_rcs_pkg_data_saved';
resultsdir = '/Users/roee/Box/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home/synced_rcs_pkg_data_saved';
ff = findFilesBVQX(resultsdir,'RCS*.mat'); 
tbl = table();
for f = 1:length(ff) 
    load(ff{f});
    [pn,fn] = fileparts(ff{f});
    tbl.patient{f} = fn(1:5);
    tbl.rcs_side{f} = fn(7);
    tbl.pkg_side{f} = fn(end);
    idxsleep = strcmp(allDataPkgRcsAcc.states,'sleep');
    idxnotsleep = ~strcmp(allDataPkgRcsAcc.states,'sleep');
    tbl.sleep_hours(f) = (sum(idxsleep)*2)/60; 
    tbl.wake_hours(f) = (sum(idxnotsleep)*2)/60; 
end
uniquePatients = unique(tbl.patient); 
recTime = [];
for p = 1:length(uniquePatients)
    idxuse = strcmp(tbl.patient,uniquePatients{p});
    recTime(p,1) = sum(tbl.wake_hours(idxuse));
    recTime(p,2) = sum(tbl.sleep_hours(idxuse));
end
fprintf('wake time mean %.2f max %.2f  %.2f\n',mean(recTime(:,1)),max(recTime(:,1)),min(recTime(:,1)));
fprintf('sleep time mean %.2f max %.2f  %.2f\n',mean(recTime(:,2)),max(recTime(:,2)),min(recTime(:,2)));
if plotpanels
    cntplt = 1;
    hfig = figure;
    hfig.Color = 'w'; 
    hsb = subplot(1,1,1);
    hsb(cntplt) = hsb; 
else
    hpanel(1,1,1).select();
    hsb = gca();
    hold(hsb,'on');
end

hbar = bar(recTime);
altPatientNames = {'RCS01';'RCS02';'RCS03';'RCS04';'RCS05'};
hsb.XTickLabel = altPatientNames;
hsb.YLabel.String = 'Hours recoreded'; 
hsb.Title.String = 'Hours recorded at home / patient'; 
hleg = legend({'awake','alseep'},'Location','northwest');
hleg.Box = 'off'; 
% save fig 
if plotpanels
    savefig(hfig,fullfile(figdirout,sprintf('Fig%d_panelA_hours_recorded_at_home',fignum)));
    prfig.plotwidth           = 5;
    prfig.plotheight          = 2.5;
    prfig.figdir             = figdirout;
    prfig.figname             = sprintf('Fig%d_panelA_hours_recorded_at_home',fignum);
    prfig.figtype             = '-dpdf';
    plot_hfig(hfig,prfig)
    close(hfig);
end