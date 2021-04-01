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
datadir = '/Users/roee/Box/rcs paper paper on first five bilateral implants/revision for nature biotechnology/figures/Fig5_states_estimates_group_data_and_ AUC/data';
fignum = 5; 
figdirout = '/Users/roee/Starr_Lab_Folder/Writing/papers/2019_LongTerm_RCS_recordings/figures/1_draft2/Fig5_states_estimates_group_data_and_ AUC';
figdirout = '/Users/roee/Starr_Lab_Folder/Writing/papers/2019_LongTerm_RCS_recordings/figures/final_figures/Fig5_states_estimates_group_data_and_ AUC';
figdirout = '/Users/roee/Box/rcs paper paper on first five bilateral implants/revision for nature biotechnology/figures/Fig5_states_estimates_group_data_and_ AUC';

altPatientNames = {'RCS01';'RCS02';'RCS03';'RCS04';'RCS05'};


ff = findFilesBVQX(datadir,'*by_min_results_with_coherence.mat');
for f = 1:length(ff)
    load(ff{f});
    cntSize = size(AUC_results_table,1);
    cnt = cntSize + 1; 
    % STN 
    AUC_results_table.patient{cnt} = AUC_results_table.patient{cntSize};
    AUC_results_table.side{cnt} = AUC_results_table.side{cntSize};
    AUC_results_table.area{cnt} = [labelAgregateAreas{1} ' all'];
    AUC_results_table.AUC(cnt) = AUCout_agregate(1);
    AUC_results_table.AUCp(cnt) = AUCpOut_agregate(1);
    cnt = cnt + 1; 
    % M1 
    AUC_results_table.patient{cnt} = AUC_results_table.patient{cntSize};
    AUC_results_table.side{cnt} = AUC_results_table.side{cntSize};
    AUC_results_table.area{cnt} = [labelAgregateAreas{2} ' all'];
    AUC_results_table.AUC(cnt) = AUCout_agregate(2);
    AUC_results_table.AUCp(cnt) = AUCpOut_agregate(2);
    cnt = cnt + 1;
    % cohernece
    AUC_results_table.patient{cnt} = AUC_results_table.patient{cntSize};
    AUC_results_table.side{cnt} = AUC_results_table.side{cntSize};
    AUC_results_table.area{cnt} = labelAgregateAreas_coherence{1};
    AUC_results_table.AUC(cnt) = AUCout_agregate_coherence(1);
    AUC_results_table.AUCp(cnt) = AUCpOut_agregate_coherence(1);
    cnt = cnt + 1
    
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

idxuse = cellfun(@(x) any(strfind(x,'STN all')),AUCall.area);
aucadd = AUCall.AUC(idxuse); 
patsadd   = AUCall.patient(idxuse);
patients = [patients;patsadd];
pvalsdd  = AUCall.AUCp(idxuse); 
pvals  = [pvals ; pvalsdd];
datbox = [datbox ; aucadd]; 
xvals  = [xvals; ones(size(aucadd,1),1).*idxnum]; 
titlsuse{idxnum,1} = 'STN all';
idxnum = idxnum + 1; 


idxuse = cellfun(@(x) any(strfind(x,'MC all')),AUCall.area);
aucadd = AUCall.AUC(idxuse); 
patsadd   = AUCall.patient(idxuse);
patients = [patients;patsadd];
pvalsdd  = AUCall.AUCp(idxuse); 
pvals  = [pvals ; pvalsdd];
datbox = [datbox ; aucadd]; 
xvals  = [xvals; ones(size(aucadd,1),1).*idxnum]; 
titlsuse{idxnum,1} = 'MC all';
idxnum = idxnum + 1; 


% idxuse = cellfun(@(x) any(strfind(x,'STN-M1 coh beta')),AUCall.area);
% aucadd = AUCall.AUC(idxuse); 
% patsadd   = AUCall.patient(idxuse);
% patients = [patients;patsadd];
% pvalsdd  = AUCall.AUCp(idxuse); 
% pvals  = [pvals ; pvalsdd];
% datbox = [datbox ; aucadd]; 
% xvals  = [xvals; ones(size(aucadd,1),1).*idxnum]; 
% titlsuse{idxnum,1} = 'coherence beta';
% idxnum = idxnum + 1; 
% 
% idxuse = cellfun(@(x) any(strfind(x,'STN-M1 coh gamma')),AUCall.area);
% aucadd = AUCall.AUC(idxuse); 
% patsadd   = AUCall.patient(idxuse);
% patients = [patients;patsadd];
% pvalsdd  = AUCall.AUCp(idxuse); 
% pvals  = [pvals ; pvalsdd];
% datbox = [datbox ; aucadd]; 
% xvals  = [xvals; ones(size(aucadd,1),1).*idxnum]; 
% titlsuse{idxnum,1} = 'coherence gamma';
% idxnum = idxnum + 1; 

idxuse = cellfun(@(x) any(strfind(x,'coherence STN & MC')),AUCall.area);
aucadd = AUCall.AUC(idxuse); 
patsadd   = AUCall.patient(idxuse);
patients = [patients;patsadd];
pvalsdd  = AUCall.AUCp(idxuse); 
pvals  = [pvals ; pvalsdd];
datbox = [datbox ; aucadd]; 
xvals  = [xvals; ones(size(aucadd,1),1).*idxnum]; 
titlsuse{idxnum,1} = 'coherence STN & MC';
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
for t = 1:length(titlsuse)
    fprintf('%s %.2f mean range (%.2f - %.2f)\n',titlsuse{t}, mean(datbox(xvals==t)),min(datbox(xvals==t)),max(datbox(xvals==t)));    
end

% find out how many multiple comarisons were done per subject (including
% ones not shown)
 numtests = sum(strcmp(AUCall.patient,'RCS02'));

for i = 1:length(titlsuse)
    persig = sum(pvals(xvals==i)<0.05)/numtests; 
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

% check how many p-values computed per patient 
unqpat  = unique(patients);
for p = 1:length(unqpat)
        patidx  = strcmp(unqpat{p},patients);
        numPvalTests = sum(patidx); 
end
            
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
    % delete all the not box plot stuff: 
    delete(hdat); 
    delete(nbp(i).sdPtch);
    delete(nbp(i).semPtch);
    delete(nbp(i).mu);
    for p = 1:length(unqpat)
        idxpat = strcmp(unqpat{p},patdat);
        xpat = xdat(idxpat); 
        ypat = ydat(idxpat); 
        ppat = pvalsdat(idxpat); 
        alphaToBeat = 0.05/numPvalTests;
        hsact(p) = scatter(xpat(ppat<alphaToBeat),ypat(ppat<alphaToBeat),markerSizeSig,'filled','o','MarkerFaceColor',colorsSubs(p,:),'MarkerFaceAlpha',0.8);
        scatter(xpat(ppat>=alphaToBeat),ypat(ppat>=alphaToBeat),markerSizeNotSig,'filled','v','MarkerFaceColor',colorsSubs(p,:),'MarkerFaceAlpha',0.8);
    end
end
hLegend = legend(hsact,altPatientNames);
hLegend.Box = 'off';
hsb.XLim = [ 0 10];
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
        hscat(p) = scatter(aucScore,deltaUpdrs,50,colorsSubs(p,:),'filled','MarkerFaceAlpha',0.8);
        
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

hLegend = legend(uniquPatients,'Location','northeast');
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
    prfig.figname             = 'Fig5_v2_AUC_and_updrs_v5';
    prfig.figtype             = '-dpdf';
    plot_hfig(hfig,prfig)
    % close(hfig);
else
    set(hsb,'FontSize',6);
    prfig.plotwidth           = 2.55;
    prfig.plotheight          = 1.96;
    prfig.figdir              = figdirout;
    prfig.figname             = 'Fig5_v2_AUC_and_updrs_v6_only_updrs_corr';
    prfig.figtype             = '-dpdf';
    plot_hfig(hfig,prfig)
    % close(hfig);
    
end
%%
return 
%% plot the weights for feature coefficiants 
close all;
figdirout = '/Users/roee/Box/rcs paper paper on first five bilateral implants/revision for nature biotechnology/figures/Fig5_states_estimates_group_data_and_ AUC';
datadir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home';

altPatientNames = {'RCS01';'RCS02';'RCS03';'RCS04';'RCS05'};


ff = findFilesBVQX(datadir,'*by_min_results_with_coherence.mat');
coeff = [];
patientLabes = {};
for f = 1:length(ff)
    load(ff{f});
    coeff(f,:) = rescale(abs(AUC_results_table_coeffients.coefficents'),0,1);
    if f == 1 
        AUCall = AUC_results_table; 
    else
        AUCall = [AUCall; AUC_results_table];
    end
    patientLabes{f} = sprintf('%s %s',AUC_results_table.patient{1},AUC_results_table.side{1});
end
hfig = figure;
hfig.Color = 'w'; 
imagesc(coeff); 
hsb = gca();
hsb.YTickLabel = patientLabes;
hsb.XTick = 1:length(AUC_results_table_coeffients.coefficentsLabels');
hsb.XTickLabel = AUC_results_table_coeffients.coefficentsLabels';
hsb.XTickLabelRotation = 45;
hclr = colorbar; 
hclr.Label.String = 'Norm. contribution to LDA classifier';
hsb.FontSize = 16; 

title('Contribution of features to LDA discrimination','FontSize',24);
prfig.plotwidth           = 10;
prfig.plotheight          = 7;
prfig.figdir              = figdirout;
prfig.figname             = 'Fig5_v2_AUC_contributions_of_LDA_weights';
prfig.figtype             = '-dpdf';
plot_hfig(hfig,prfig)

%%

%% plot the weights vs AUC performance  
close all;
figdirout = '/Users/roee/Box/rcs paper paper on first five bilateral implants/revision for nature biotechnology/figures/Fig5_states_estimates_group_data_and_ AUC';
datadir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home';

altPatientNames = {'RCS01';'RCS02';'RCS03';'RCS04';'RCS05'};


ff = findFilesBVQX(datadir,'*by_min_results_with_coherence.mat');
coeff = [];
patientLabes = {};
cntplt = 1; 
clear AUC_ag;
for f = 1:length(ff)
    load(ff{f});
    [pn,fn] = fileparts(ff{f});
    patientLabels{f} = [fn(1:5) ' ' fn(7)];
    AUC_ag(f,:) = AUCout_agregate(1:2);
end
hfig = figure; 
hfig.Color = 'w';
hsb = gca;
hbar = bar(AUC_ag);
hsb.XTickLabel = patientLabels;
hsb.XTickLabelRotation = 45;
ylabel('AUC'); 
title('Relative contribution of area'); 
set(hsb,'FontSize',16);
legend(labelAgregateAreas);
ylim([0.5 1]); 
prfig.plotwidth           = 10;
prfig.plotheight          = 7;
prfig.figdir              = figdirout;
prfig.figname             = 'Fig5_v2_relative_contribution_of_areas_stn_vs_mc';
prfig.figtype             = '-dpdf';
plot_hfig(hfig,prfig)

%%


%% plot the agregated STN vs MC vs STN+MC decoders 
close all;
figdirout = '/Users/roee/Box/rcs paper paper on first five bilateral implants/revision for nature biotechnology/figures/Fig5_states_estimates_group_data_and_ AUC';
datadir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home';

altPatientNames = {'RCS01';'RCS02';'RCS03';'RCS04';'RCS05'};


ff = findFilesBVQX(datadir,'*by_min_results_with_coherence.mat');
coeff = [];
patientLabes = {};
hfig = figure;
hfig.Color = 'w'; 
cntplt = 1; 
for f = 1:length(ff)
    load(ff{f});
    coeff(f,:) = rescale(abs(AUC_results_table_coeffients.coefficents'),0,1);
    hsb(f) = subplot(5,2,cntplt); hold on;
    cntplt = cntplt + 1; 
    patientLabes{f} = sprintf('%s %s',AUC_results_table.patient{1},AUC_results_table.side{1});
    scatter(AUC_results_table.AUC(1:16), coeff(f,:),50,'filled','MarkerFaceAlpha',0.5);
    xline = AUC_results_table.AUC(17); 
    ylims = hsb(f).YLim;
    plot([xline xline], ylims,'LineWidth',1,'Color',[0.5 0.5 0.5 0.5],'LineStyle','-.');
    xlabel('AUC'); 
    ylabel('LDA weights'); 
    set(gca,'FontSize',12); 
    title(patientLabes{f}); 
end
linkaxes(hsb,'x');

sgtitle('Correlation between AUC and LDA weights - ind. features','FontSize',16);
prfig.plotwidth           = 7;
prfig.plotheight          = 10;
prfig.figdir              = figdirout;
prfig.figname             = 'Fig5_v2_AUC_contributions_of_LDA_weights_scatter_plots';
prfig.figtype             = '-dpdf';
plot_hfig(hfig,prfig)

%%



return;



end