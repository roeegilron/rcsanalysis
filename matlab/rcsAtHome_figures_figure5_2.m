function rcsAtHome_figures_figure5_2()
%% Grouped separation data
% this figure shows the group seperation data 
%% 
% panel a bar graph of total hours awake / alseep
% panel b - PSD and coherence at home - average state estimate across subjects (median average)
% panel c - AUC for all subjects -

addpath(genpath(fullfile(pwd,'toolboxes','panel-2.14')));
addpath(genpath(fullfile(pwd,'toolboxes','notBoxPlot')))

%%
hfig = figure; 
p = panel();
p.pack(1,2); 
p.select('all');
p.fontsize = 30;
p.identify();
plotpanels = 0; % plot the big figure;
% p(1,1).repack(0.3);
%%

close all;
plotpanels = 0;
if ~plotpanels
    %%
    hfig = figure;
    hfig.Color = 'w';
    hpanel = panel();
    hpanel.pack('h',{0.6 0.3});
%     hpanel.select('all');
%     hpanel.identify();
    %%
end
% plot panel a in the first column, 3 subplots 
% plot panel b and c in the seceond column 2 subplots 



%% panel c - AUC for all subjects 
% original function to compute the data: 
% AUC_analysis_including_coherence_and_psd_pkg_data()
addpath(genpath(fullfile(pwd,'toolboxes','notBoxPlot')))

datadir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home/';
datadir = '/Users/roee/Box/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home/AUC_results';
fignum = 5; 
figdirout = '/Users/roee/Starr_Lab_Folder/Writing/papers/2019_LongTerm_RCS_recordings/figures/1_draft2/Fig5_states_estimates_group_data_and_ AUC';
figdirout = '/Users/roee/Starr_Lab_Folder/Writing/papers/2019_LongTerm_RCS_recordings/figures/final_figures/Fig5_states_estimates_group_data_and_ AUC';
figdirout = '/Users/roee/Box/rcs paper paper on first five bilateral implants/revision for nature biotechnology/figures/Fig5_states_estimates_group_data_and_ AUC';

altPatientNames = {'RCS01';'RCS02';'RCS03';'RCS04';'RCS05'};


ff = findFilesBVQX(datadir,'*by_min_results_with_coherence.mat');
for f = 1:length(ff)
    load(ff{f});
    if f == 1 
        AUCall = AUC_results_table; 
    else
        AUCall = [AUCall; AUC_results_table];
    end
end
datbox = []; 
xvals  = []; 
pvals  = []; 
patients   = {}; 
idxnum = 1; 
titlsuse = {}; 

idxuse = cellfun(@(x) any(strfind(x,'STN beta')),AUCall.area);
aucadd = AUCall.AUC(idxuse); 
patsadd   = AUCall.patient(idxuse);
patients = [patients;patsadd];
pvalsdd  = AUCall.AUCp(idxuse); 
pvals  = [pvals ; pvalsdd];
datbox = [datbox ; aucadd]; 
xvals  = [xvals; ones(size(aucadd,1),1).*idxnum]; 
titlsuse{idxnum,1} = 'STN beta';
idxnum = idxnum + 1; 

idxuse = cellfun(@(x) any(strfind(x,'M1 gamma')),AUCall.area);
aucadd = AUCall.AUC(idxuse); 
patsadd   = AUCall.patient(idxuse);
patients = [patients;patsadd];
pvalsdd  = AUCall.AUCp(idxuse); 
pvals  = [pvals ; pvalsdd];
datbox = [datbox ; aucadd]; 
xvals  = [xvals; ones(size(aucadd,1),1).*idxnum]; 
titlsuse{idxnum,1} = 'motor cortex gamma';
idxnum = idxnum + 1; 


idxuse = cellfun(@(x) any(strfind(x,'STN-M1 coh beta')),AUCall.area);
aucadd = AUCall.AUC(idxuse); 
patsadd   = AUCall.patient(idxuse);
patients = [patients;patsadd];
pvalsdd  = AUCall.AUCp(idxuse); 
pvals  = [pvals ; pvalsdd];
datbox = [datbox ; aucadd]; 
xvals  = [xvals; ones(size(aucadd,1),1).*idxnum]; 
titlsuse{idxnum,1} = 'coherence beta';
idxnum = idxnum + 1; 

idxuse = cellfun(@(x) any(strfind(x,'STN-M1 coh gamma')),AUCall.area);
aucadd = AUCall.AUC(idxuse); 
patsadd   = AUCall.patient(idxuse);
patients = [patients;patsadd];
pvalsdd  = AUCall.AUCp(idxuse); 
pvals  = [pvals ; pvalsdd];
datbox = [datbox ; aucadd]; 
xvals  = [xvals; ones(size(aucadd,1),1).*idxnum]; 
titlsuse{idxnum,1} = 'coherence gamma';
idxnum = idxnum + 1; 

idxuse = cellfun(@(x) any(strfind(x,'all areas')),AUCall.area);
aucadd = AUCall.AUC(idxuse); 
patsadd   = AUCall.patient(idxuse);
patients = [patients;patsadd];
pvalsdd  = AUCall.AUCp(idxuse); 
pvals  = [pvals ; pvalsdd];
datbox = [datbox ; aucadd]; 
xvals  = [xvals; ones(size(aucadd,1),1).*idxnum]; 
titlsuse{idxnum,1} = 'all features';
idxnum = idxnum + 1; 
% XXXXXXX 
% XXXXXXX
% plot some stats: 
fprintf('STN beta %.2f mean range (%.2f - %.2f)\n',mean(datbox(xvals==1)),min(datbox(xvals==1)),max(datbox(xvals==1)));
fprintf('M1 gamma %.2f mean range (%.2f - %.2f)\n',mean(datbox(xvals==2)),min(datbox(xvals==2)),max(datbox(xvals==2)));
fprintf('M1-STN coh beta  %.2f mean range (%.2f - %.2f)\n',mean(datbox(xvals==3)),min(datbox(xvals==3)),max(datbox(xvals==3)));
fprintf('M1-STN coh gamma  %.2f mean range (%.2f - %.2f)\n',mean(datbox(xvals==4)),min(datbox(xvals==4)),max(datbox(xvals==4)));
fprintf('all areas  %.2f mean range (%.2f - %.2f)\n',mean(datbox(xvals==5)),min(datbox(xvals==5)),max(datbox(xvals==5)));


for i = 1:5
    persig = sum(pvals(xvals==i)<0.05)/sum(xvals==i); 
    fprintf('%s %.2f\n',titlsuse{i},persig); 
end
if plotpanels
    hfig = figure;
    hfig.Color = 'w';
    hsb = subplot(1,1,1);
else
    hpanel(1).select();
    hold on;
    hsb = gca();
end
hold on; 
nbp = notBoxPlot(datbox,xvals,'jitter',0.6); 
hold on;
hsb.XTickLabel = titlsuse;
hsb.XTickLabelRotation = 30;
ylabel('AUC'); 
ylim([0.4 1.1]);
title('Decoding accuracy (AUC) per region and patient'); 
set(gca,'FontSize',12);

% color each subject with a different color 
% segregate markers based on significance (marker style) 
xvalsUse = unique(xvals);
            
colorsSubs = [ ...
    143,75,191 ; ...
    108,157,83; ...
    178,75,112; ...
    109,128,176; ...
    187,111,61]./255;
markerSizeSig = 50;
markerSizeNotSig = 20;
for i = 1:length(xvalsUse)
    nbp(i).sdPtch.FaceAlpha = 0.0;
    nbp(i).sdPtch.FaceColor = [0.1 0.1 0.1];
    nbp(i).semPtch.FaceAlpha = 0.0;
    nbp(i).semPtch.FaceColor = [0.0 0.0 0.8];
end
for i = 1:length(xvalsUse)
    hdat = nbp(i).data;
    xdat = hdat.XData;
    ydat = hdat.YData;
    patdat  = patients(xvals==i);
    pvalsdat = pvals(xvals==i);
    unqpat = unique(patdat);
    delete(hdat); 
    for p = 1:length(unqpat)
        idxpat = strcmp(unqpat{p},patdat);
        xpat = xdat(idxpat); 
        ypat = ydat(idxpat); 
        ppat = pvalsdat(idxpat); 
        hsact(p) = scatter(xpat(ppat<0.05),ypat(ppat<0.05),markerSizeSig,'filled','o','MarkerFaceColor',colorsSubs(p,:),'MarkerFaceAlpha',0.8);
        scatter(xpat(ppat>=0.05),ypat(ppat>=0.05),markerSizeNotSig,'filled','v','MarkerFaceColor',colorsSubs(p,:),'MarkerFaceAlpha',0.8);
    end
end
hLegend = legend(hsact,altPatientNames);
hLegend.Box = 'off';
hsb.XLim = [ 0 7.5];
if plotpanels
    % save fig as
    set(gca,'FontSize',16);
    savefig(hfig,fullfile(figdirout,'Fig5_panelC_AUC_all_subs_with_coherence'));
    
    prfig.plotwidth           = 10;
    prfig.plotheight          = 7;
    prfig.figdir             = figdirout;
    prfig.figname             = 'Fig5_panelC_AUC_all_subs_with_coherence';
    prfig.figtype             = '-dpdf';
    plot_hfig(hfig,prfig)
    close(hfig);
end
%%
%% plot UPDRs vs AUC results 
dirname = '/Users/roee/Box/rcs paper paper on first five bilateral implants/revision for nature biotechnology/figures/Fig5_states_estimates_group_data_and_ AUC/baseline_updrs';
savename = fullfile(dirname,'updrs_results.mat');
load(savename,'resultsTable','deltaTable','outData','outTable');

figdirout = '/Users/roee/Starr_Lab_Folder/Writing/papers/2019_LongTerm_RCS_recordings/figures/final_figures/Fig5_states_estimates_group_data_and_ AUC';
figdirout = '/Users/roee/Box/rcs paper paper on first five bilateral implants/revision for nature biotechnology/figures/Fig5_states_estimates_group_data_and_ AUC';

datadir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home/';
datadir = '/Users/roee/Box/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home/AUC_results';
ff = findFilesBVQX(datadir,'*by_min_results_with_coherence.mat');
for f = 1:length(ff)
    load(ff{f});
    
    if f == 1 
        AUCall = AUC_results_table; 
    else
        AUCall = [AUCall; AUC_results_table];
    end
end
idxLeft = strcmp(AUCall.side,'L');
idxAll = strcmp(AUCall.area,'all areas');
aucResults = AUCall(idxAll,:);
uniquPatients = unique(AUCall.patient);
sidesAUC = {'L','R'};
sidesDelta = {'left','right'}; 

colorsSubs = [ ...
    143,75,191 ; ...
    108,157,83; ...
    178,75,112; ...
    109,128,176; ...
    187,111,61]./255;% plot compared to all areas AUC 
if plotpanels
    hfig = figure;
    hfig.Color = 'w';
    hsb = subplot(1,1,1);
else
    hpanel(2).select();
    hold on;
    hsb = gca();
end

hold on;
scores = [];
updrs  = []; 
cnt = 1; 
for p = 1:length(uniquPatients)
    idxPatient = strcmp(aucResults.patient,uniquPatients{p});
    patientAUC = aucResults(idxPatient,:);
    for s = 1:length(sidesAUC)
        idxSideAuc = strcmp(patientAUC.side,sidesAUC{s});
        aucScore = patientAUC.AUC(idxSideAuc);
        
        idxDelta = strcmp(deltaTable.patient,uniquPatients{p}) & ... 
            strcmp(deltaTable.side,sidesDelta{s});
        deltaUpdrs = deltaTable.delta(idxDelta);
        hscat(p) = scatter(aucScore,deltaUpdrs,200,colorsSubs(p,:),'filled','MarkerFaceAlpha',0.8);
        
        scores(cnt) = aucScore;
        updrs(cnt)  = deltaUpdrs;
        cnt = cnt + 1; 
    end
end
coefficients = polyfit(scores, updrs, 1);
mdl = fitlm(scores,updrs);
xFit = linspace(min(scores), max(scores), 1000);
yFit = polyval(coefficients , xFit);
hold on;
plot(xFit, yFit, 'Color',[0.5 0.5 0.5 0.2],'LineStyle','-.', 'LineWidth', 3);

hLegend = legend(uniquPatients,'Location','northeastoutside');
hLegend.Box = 'off';
xlabel('AUC'); 
ylabel('Delta UPDRS off-on');
ttluse = sprintf('AUC/UPDRS correlation (r^2 = %.2f)',mdl.Rsquared.Adjusted);
title(ttluse);
set(gca,'FontSize',10);
xlim([0.7 1.1]);
ylim([0 20]);


%%
if ~plotpanels
    
    hpanel.fontsize = 12;
    hpanel.de.margin = 20;
    hpanel.marginbottom = 45;
    hpanel.marginright = 30;
    hpanel.margintop = 30;
    hpanel.marginleft = 30;
    prfig.plotwidth           = 10;
    prfig.plotheight          = 7;
    prfig.figdir              = figdirout;
    prfig.figname             = 'Fig5_v2_AUC_and_updrs_v3';
    prfig.figtype             = '-dpdf';
    plot_hfig(hfig,prfig)
    % close(hfig);
end
%%
return;



end