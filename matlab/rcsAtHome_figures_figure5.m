function rcsAtHome_figures_figure5()
%% Grouped separation data
% this figure shows the group seperation data 
%% 
% panel a bar graph of total hours awake / alseep
% panel b - PSD and coherence at home - average state estimate across subjects (median average)
% panel c - AUC for all subjects 

addpath(genpath(fullfile(pwd,'toolboxes','panel-2.14')));
%%
hfig = figure; 
p = panel();
p.pack(1,2); 
p(1,1).pack(2,1);
p(1,2).pack(3,1); 
p.select('all');
p.fontsize = 30;
p.identify();
plotpanels = 0;
% p(1,1).repack(0.3);
%%

close all;

if ~plotpanels
    hfig = figure;
    hfig.Color = 'w';
    hpanel = panel();
    hpanel.pack(1,2);
    hpanel(1,1).pack(2,1);
    hpanel(1,2).pack(3,1);
end
% plot panel a in the first column, 3 subplots 
% plot panel b and c in the seceond column 2 subplots 
%% panel a bar graph of total hours awake / alseep 
fignum = 5; 
figdirout = '/Users/roee/Starr_Lab_Folder/Writing/papers/2019_LongTerm_RCS_recordings/figures/1_draft2/Fig5_states_estimates_group_data_and_ AUC';
% origina funciton used: plot_pkg_data_all_subjects
resultsdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home/synced_rcs_pkg_data_saved';
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
    hfig = figure;
    hfig.Color = 'w'; 
    hsb = subplot(1,1,1);
    hsb(cntplt) = subplot; 
else
    hpanel(1,1,1,1).select();
    hsb = gca();
end

hbar = bar(recTime);
altPatientNames = {'RCS01';'RCS02';'RCS03';'RCS04'};
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
%% 

%% panel b - PSD and coherence at home - average state estimate across subjects (median average) 
addpath(genpath(fullfile('toolboxes','GEEQBOX')));
addpath(genpath(fullfile(pwd,'toolboxes','shadedErrorBar')))
fignum = 5; 
figdirout = '/Users/roee/Starr_Lab_Folder/Writing/papers/2019_LongTerm_RCS_recordings/figures/1_draft2/Fig5_states_estimates_group_data_and_ AUC';
% original function:
% plot_pkg_data_all_subjects

load('/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home/patientPSD_at_home.mat');
load('/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home/patientCOH_at_home.mat');
if plotpanels
    hfig = figure;
    hfig.Color = 'w';
end
pdb = patientPSD_at_home;


% %%%%%%%%%%%%%%%%%%%%%%%%% do stats 
% %%%%%%%%%%%%%%%%%%%%%%%%% do stats 
% %%%%%%%%%%%%%%%%%%%%%%%%% do stats 
areas = {'STN','M1'};
for a = 1:length(areas)
    idxstn = cellfun(@(x) any(strfind(x,areas{a})),pdb.electrode);
    pdbSTN = pdb(idxstn,:);
    
    % groups:
    
    % id = subject id
    % percent  = beta level averaged between 13-30
    % month - categorical med on/off
    % X - matrix of conditions incdluing (numerical):
    %  1. med state (on/off)
    %  2. side (L/R)
    %  3. montage (0-2 / 1-3)
    uniquePatients = unique(pdbSTN.patient);
    id = zeros(size(pdbSTN,1),1);
    for p = 1:length(uniquePatients)
        for i = 1:size(pdbSTN,1)
            id( strcmp(pdbSTN.patient,uniquePatients{p}) ) = p;
        end
    end
    montage = zeros(size(pdbSTN,1),1);
    unqeMontage = unique(pdbSTN.electrode);
    montage( strcmp(pdbSTN.electrode,unqeMontage{1}) ) = 1;
    montage( strcmp(pdbSTN.electrode,unqeMontage{2}) ) = 2;
    
    medstate = zeros(size(pdbSTN,1),1);
    medstate( strcmp(pdbSTN.medstate,'on') ) = 1;
    medstate( strcmp(pdbSTN.medstate,'off') ) = 2;
    
    side = zeros(size(pdbSTN,1),1);
    side( strcmp(pdbSTN.side,'L') ) = 1;
    side( strcmp(pdbSTN.side,'R') ) = 2;
    
    usefreqranges = 0;
    if usefreqranges
        freqranges = [1 4;     4 8;     8 13;    13 20;   20 30;       30 50;     50 90];
        freqnames  = {'Delta', 'Theta', 'Alpha','LowBeta','HighBeta','LowGamma','HighGamma'}';
        
        ff = pdbSTN.ff{1};
        fftnorm = cell2mat(pdbSTN.fftOutNorm);
        pvals = [];
        for sf = 1:size(freqranges,1)
            idxfreqs = ff >= freqranges(sf,1) & ff <= freqranges(sf,2);
            meanfreqs = mean(fftnorm(:,idxfreqs),2);
            const = ones(size(meanfreqs,1),1);
            X = [medstate, montage, side, const];
            varnames ={'med state','montage','side','const'};
            [betahat, alphahat, results] = gee(id, meanfreqs, medstate, X, 'n', 'equi', varnames);
            pvals(sf) = results.model{3,5};
        end
        siglog = logical(pvals<=0.05./size(freqranges,1));
        freqnames(siglog);
    end
    
    % do states for each frequency
    for f = 1:length(pdbSTN.fftOutNorm{1})
        meanfreq = [] ;
        for i = 1:size(pdbSTN,1)
            meanfreq(i,1) = pdbSTN.fftOutNorm{i}(f);
        end
        const = ones(size(meanfreq,1),1);
        X = [medstate, montage, side, const];
        varnames ={'med state','montage','side','const'};
        [betahat, alphahat, results] = gee(id, meanfreq, medstate, X, 'n', 'equi', varnames);
        pvals(f) = results.model{3,5};
    end
    siglog = logical(pvals<=0.05./length(pdbSTN.fftOutNorm{1}));
    ff = pdbSTN.ff{i};
    ff(siglog);
    siglogout(:,a) = siglog;
end
% %%%%%%%%%%%%%%%%%%%%%%%%% do stats 
% %%%%%%%%%%%%%%%%%%%%%%%%% do stats 
% %%%%%%%%%%%%%%%%%%%%%%%%% do stats 

areas = {'STN','M1'}; 
medstate = {'on','off'}; 
colorsUse = [0 0.8 0; 0.8 0 0];

nrows = 3; 
ncols = 1; 
cntplt = 1; 
for a = 1:length(areas)
    if plotpanels
        hsb(cntplt) = subplot(nrows,ncols,cntplt);hold on;
        cntplt = cntplt + 1;
    else
        hpanel(1,2,cntplt,1).select();
        hold on;
        cntplt = cntplt + 1;
        hsb = gca();
    end
    for m = 1:length(medstate)
        set(gca,'XLim',[5.1 89])
        
        idxkeep = (pdb.srate == 250) & ...
            cellfun(@(x) any(strfind(x,areas{a})),pdb.electrode) & ...
            strcmp(pdb.medstate,medstate{m});
        psds = cell2mat(pdb.fftOutNorm(idxkeep));
        ff = pdb.ff(idxkeep);
        ff = ff{1};
        % plot(ff,psds,'LineWidth',1,'Color',[0 0.8 0 0.3]);
        hsbH = shadedErrorBar(ff,psds,{@mean,@(x) std(x)*1});
        hsbH.mainLine.Color = colorsUse(m,:); 
        hsbH.mainLine.LineWidth = 1;
        hsbH.edge(1).Color = [1 1 1]; 
        hsbH.edge(2).Color = [1 1 1]; 
        hsbH.patch.FaceAlpha = 0.1;
        hsbH.patch.FaceColor = colorsUse(m,:); 
        hLine(m) = hsbH.mainLine;
    end
    % plot significance 
    ylims = get(gca,'YLim');
    freqsig = ff(siglogout(:,a));
    
    xfreqssig = [];
    D = diff([0,siglogout(:,a)',0]);
    b.beg = find(D == 1);
    b.end = find(D == -1) - 1;
    xfreqssig(:,1) = ff(b.beg);
    xfreqssig(:,2) = ff(b.end);
    if ~isempty(xfreqssig)
        plot(xfreqssig,[ylims(2) ylims(2)],'Color',[0.5 0.5 0.5],'LineWidth',2);
    end

    ylabel('Norm. power  (a.u.)');
    title(areas{a},'FontSize',16);
    set(gca,'FontSize',12); 
    set(gca,'XTick',[]);
    if a == 1 
    legend(hLine,{'PKG estimate - on','PKG estimate - off'});
    end
end

% plot coherence 
pdb = patientCOH_at_home;
if plotpanels
    hsb(cntplt) = subplot(nrows,ncols,cntplt);hold on;
    cntplt = cntplt + 1;
else
    hpanel(1,2,cntplt,1).select();
    hold on;
    cntplt = cntplt + 1;
    hsb = gca();
end
for m = 1:length(medstate)
    idxkeep = (pdb.srate == 250) & ...
        strcmp(pdb.medstate,medstate{m});
    cohs = cell2mat(pdb.coh(idxkeep)');
    ff = pdb.ff(idxkeep);
    ff = ff{1}; 
    errs = []; 
    meancoh = mean(cohs); 
    errs(:,1) = mean(cohs) + std(cohs);
    errs(:,2) = mean(cohs) - std(cohs);
    errs(errs(:,2)<0,2) = meancoh(errs(:,2)<0);
    errs = errs';
%     hsbH = shadedErrorBar(ff,cohs,{@mean,@(x) std(x)*1});
    hsbH = shadedErrorBar(ff,mean(cohs),errs); 
    hsbH.mainLine.Color = colorsUse(m,:);
    hsbH.mainLine.LineWidth = 1;
    hsbH.edge(1).Color = [1 1 1];
    hsbH.edge(2).Color = [1 1 1];
    hsbH.patch.FaceAlpha = 0.1;
    hsbH.patch.FaceColor = colorsUse(m,:);
    hLine(m) = hsbH.mainLine;
    xlabel('Frequency (Hz)');
    ylabel('MS Coherence');
    set(gca,'FontSize',12);
    set(gca,'XLim',[5.1 89])
end
% %%%%%%%%%%%%%%%%%%%%%%%%% do stats 
% %%%%%%%%%%%%%%%%%%%%%%%%% do stats 
% %%%%%%%%%%%%%%%%%%%%%%%%% do stats 
pdbSTN = pdb;

% groups:

% id = subject id
% percent  = beta level averaged between 13-30
% month - categorical med on/off
% X - matrix of conditions incdluing (numerical):
%  1. med state (on/off)
%  2. side (L/R)
%  3. montage (0-2 / 1-3)
uniquePatients = unique(pdbSTN.patient);
id = zeros(size(pdbSTN.patient,2),1);
for p = 1:length(uniquePatients)
    for i = 1:size(pdbSTN.patient,2)
        id( strcmp(pdbSTN.patient',uniquePatients{p}) ) = p;
    end
end
montage = zeros(size(pdbSTN.patient,2),1);
unqeMontage = unique(pdbSTN.electrode);
montage( strcmp(pdbSTN.electrode,unqeMontage{1}) ) = 1;
montage( strcmp(pdbSTN.electrode,unqeMontage{2}) ) = 2;
montage( strcmp(pdbSTN.electrode,unqeMontage{3}) ) = 3;
montage( strcmp(pdbSTN.electrode,unqeMontage{4}) ) = 4;

medstate = zeros(size(pdbSTN.patient,2),1);
medstate( strcmp(pdbSTN.medstate,'on') ) = 1;
medstate( strcmp(pdbSTN.medstate,'off') ) = 2;

side = zeros(size(pdbSTN.patient,2),1);
side( strcmp(pdbSTN.side,'L') ) = 1;
side( strcmp(pdbSTN.side,'R') ) = 2;

% do states for each frequency
for f = 1:length(pdbSTN.ff{1})
    meanfreq = [] ;
    for i = 1:size(pdbSTN.patient,2)
        meanfreq(i,1) = pdbSTN.coh{i}(f);
    end
    const = ones(size(meanfreq,1),1);
    X = [medstate, montage, side, const];
    varnames ={'med state','montage','side','const'};
    [betahat, alphahat, results] = gee(id, meanfreq, medstate, X, 'n', 'equi', varnames);
    pvals(f) = results.model{3,5};
end
siglog = logical(pvals<=0.05./length(pdbSTN.ff{1}));
ff = pdbSTN.ff{i};
ff(siglog);
xfreqssig = [];
D = diff([0,siglogout(:,a)',0]);
b.beg = find(D == 1);
b.end = find(D == -1) - 1;
xfreqssig(:,1) = ff(b.beg);
xfreqssig(:,2) = ff(b.end);
idxeql = xfreqssig(:,1)==xfreqssig(:,2); % add 1 to equal idx so shows up in line plot 
xfreqssig(idxeql,2) = xfreqssig(idxeql,2) + 1; 
ylims = get(gca,'YLim');
if ~isempty(xfreqssig)
    plot(xfreqssig',[ylims(2) ylims(2)],'Color',[0.5 0.5 0.5],'LineWidth',2);
end

% %%%%%%%%%%%%%%%%%%%%%%%%% do stats 
% %%%%%%%%%%%%%%%%%%%%%%%%% do stats 
% %%%%%%%%%%%%%%%%%%%%%%%%% do stats 
if plotpanels
    hsb(cntplt-1).YLim(1) = 0;
else
    hsb.YLim(1) = 0;
end
% legend(hLine,{'PKG estimate - on','PKG estimate - off'});
title('STN-M1 coherence'); 

if plotpanels
    % save fig
    savefig(hfig,fullfile(figdirout,sprintf('Fig%d_panelB_psd_coh_group',fignum)));
    
    prfig.plotwidth           = 6;
    prfig.plotheight          = 9;
    prfig.figdir             = figdirout;
    prfig.figname             = sprintf('Fig%d_panelB_psd_coh_group',fignum);
    prfig.figtype             = '-dpdf';
    plot_hfig(hfig,prfig)
    close(hfig);
end
%% 

%% panel c - AUC for all subjects 
% original function to compute the data: 
% AUC_analysis_including_coherence_and_psd_pkg_data()
addpath(genpath(fullfile(pwd,'toolboxes','notBoxPlot')))
datadir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home/';
fignum = 5; 
figdirout = '/Users/roee/Starr_Lab_Folder/Writing/papers/2019_LongTerm_RCS_recordings/figures/1_draft2/Fig5_states_estimates_group_data_and_ AUC';
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
    hpanel(1,1,2,1).select();
    hold on;
    hsb = gca();
end
hold on; 
nbp = notBoxPlot(datbox,xvals); 
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
colorsSubs = [255 181 62; ...
             0 0 87;...
             177 63 0;...
             0 102 8]./255;
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
        scatter(xpat(ppat<0.05),ypat(ppat<0.05),20,'filled','o','MarkerFaceColor',colorsSubs(p,:));
        scatter(xpat(ppat>=0.05),ypat(ppat>=0.05),20,'filled','s','MarkerFaceColor',colorsSubs(p,:));
    end
end
if plotpanels
    % save fig as
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
if ~plotpanels
%%    
hpanel.fontsize = 12; 

hpanel(1).de.margin = 30; 
hpanel.marginbottom = 40;
hpanel(1,2).de.margin = 10;
hpanel(1,2).de.marginbottom = 2;
hpanel(1,1).de.margin = 20;
hpanel.margin = [20 20 10 10];
prfig.plotwidth           = 10;
prfig.plotheight          = 7;
prfig.figdir             = figdirout;
prfig.figname             = 'Fig5_all_final';
prfig.figtype             = '-dpdf';
plot_hfig(hfig,prfig)
%%
% close(hfig);
end
return;

%% panel s1 - all raw PSD data showcasing sleep - for all patients 
close all force;clear all;clc;
fignum = 4; % NA - it's a supplementary figure 
addpath(genpath(fullfile(pwd,'toolboxes','plot_reducer')));
load('/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home/coherence_and_psd RCS02 L pkg R.mat');
load('/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home/coherence_and_psd RCS06 R pkg L.mat');
figdirout = '/Users/roee/Starr_Lab_Folder/Writing/papers/2019_LongTerm_RCS_recordings/figures/1_draft2/Figs1_raw_data_across_subs';
titles = {'STN 0-2','STN 1-3','M1 8-10','M1 9-11'};
labelsCheck = [];
combineareas = 1;
rootdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home/'; 
addpath(genpath(fullfile(pwd,'toolboxes','panel-2.14')));


hfig = figure;
hfig.Color = 'w';
hfig.Position = [1000         194        1387        1144];
hpanel = panel();
hpanel.pack(4,3); 
hsb = gobjects(4,3);

ff = findFilesBVQX(rootdir,'coherence_and_psd*.mat');
cntplt = 1; 
nrows  = 4;
ncols =  3; 
datuse = {};

linewidths = [0.2 0.6 0.03 0.03];
areatitls = {'STN','motor cortex'};
for f = 1:length(ff)
    [pn,fn,ext] = fileparts(ff{f}); 
    patients{f} = fn(19:23);     
end
uniquePatients = unique(patients); 
patientsNameToUse = {'RCS01','RCS02','RCS03','RCS04'};
for p = 1:length(uniquePatients)
    fpts = ff(strcmp(uniquePatients{p},patients));
    stndata = [];
    m1_data = [];
    coh_dat = [];
    msr = 1; 
    for fp = 1:length(fpts)
        load(fpts{fp});
        if p == 4 & fp == 1 
            stndata = [stndata; allDataPkgRcsAcc.key1fftOut];
        else
            stndata = [stndata; allDataPkgRcsAcc.key0fftOut ; allDataPkgRcsAcc.key1fftOut];
        end
        m1_data = [m1_data; allDataPkgRcsAcc.key2fftOut ; allDataPkgRcsAcc.key3fftOut];
        if p == 4 & fp == 1 
            coh_dat = [
                allDataPkgRcsAcc.stn13m0911;
                allDataPkgRcsAcc.stn13m10810];
        else
            coh_dat = [coh_dat; allDataPkgRcsAcc.stn02m10810;
                allDataPkgRcsAcc.stn02m10911;
                allDataPkgRcsAcc.stn13m0911;
                allDataPkgRcsAcc.stn13m10810];
        end
    end
    areas = {'STN','M1'};
    dat = [];
    for a = 1:2
        hsb(p,msr) = hpanel(p,msr).select(); msr = msr + 1; 
        hold on;
        if a == 1 
            dat = stndata;
        else
            dat = m1_data;
        end
        
        idxnormalize = psdResults.ff > 3 &  psdResults.ff <90;
        meandat = abs(mean(dat(:,idxnormalize),2)); % mean within range, by row
        % the absolute is to make sure 1/f curve is not flipped
        % since PSD values are negative
        meanmat = repmat(meandat,1,size(dat,2));
        dat = dat./meanmat;
        r = ceil(size(dat,1) .* rand(720,1))
        r = 1:5:size(dat,1);
        normalizedPSD = dat(r,:);
        frequency = psdResults.ff';
        idxsleep = strcmp(allDataPkgRcsAcc.states,'sleep');
        % idxsleep = allDataPkgRcsAcc.bkVals <= -110;
        lw = linewidths(p);
                reduce_plot(psdResults.ff', normalizedPSD,'LineWidth',lw,'Color',[0 0 0.8 0.05]);% was 0.7 for rcs02 and 0.5 alpha
        xlim([3 100]);
        if p == 4
            xlabel('Frequency (Hz)');
        else
            hsb(p,msr-1).XTick = [];
        end
        if (msr-1) == 1
            ylabel('Norm. power (a.u.)');
        end
        ylims = hsb(p,msr-1).YLim;
        ttluse = {};
        ttluse{1,1} = sprintf('%s',patientsNameToUse{p});
        ttluse{1,2} = sprintf('%s',areatitls{a});
        title(ttluse);
        %         plot([4 4],ylims,'LineWidth',3,'LineStyle','-.','Color',[0.2 0.2 0.2 0.1]);
        plot([13 13],ylims,'LineWidth',2,'LineStyle','-.','Color',[0.2 0.2 0.2 0.1]);
        plot([30 30],ylims,'LineWidth',2,'LineStyle','-.','Color',[0.2 0.2 0.2 0.1]);
        set(gca,'FontSize',10);

    end

    % plot coherence
    hsb(p,msr) = hpanel(p,msr).select(); msr = msr + 1;
    hold on;
    r = ceil(size(coh_dat,1) .* rand(720,1))
    r = 1:5:size(coh_dat,1);
    reduce_plot(cohResults.ff', coh_dat(r,:),'LineWidth',lw,'Color',[0 0 0.8 0.05]);
    ylims = hsb(p,msr-1).YLim;
%     plot([4 4],ylims,'LineWidth',3,'LineStyle','-.','Color',[0.2 0.2 0.2 0.1]);
    plot([13 13],ylims,'LineWidth',2,'LineStyle','-.','Color',[0.2 0.2 0.2 0.1]);
    plot([30 30],ylims,'LineWidth',2,'LineStyle','-.','Color',[0.2 0.2 0.2 0.1]);
    if p == 4 
        xlabel('Frequency (Hz)');
    else
        hsb(p,msr-1).XTick = [];
    end 
    ylabel('MS coherence');
    ttluse = {};
    ttluse{1,1} = sprintf('%s',patientsNameToUse{p});
    ttluse{1,2} = 'stn-motor cortex coherence';
    title(ttluse);
    xlim([0 100]);
    set(gca,'FontSize',10);
    clear allDataPkgRcsAcc m1_data coh_dat stndata psdResults cohResults
end

hpanel.fontsize = 12; 
hpanel.margintop = 15;
hapenl.de.margin = 10; 
axs = hfig.Children; 
for a = 1:length(axs)
    axs(a).Children(1).YData = axs(a).YLim; 
    axs(a).Children(2).YData = axs(a).YLim; 
end

prfig.plotwidth           = 8;
prfig.plotheight          = 8;
prfig.figdir             = figdirout;
prfig.figtype             = '-djpeg';
prfig.figname             = sprintf('FigS1_raw_psd_data_p4_v4');
plot_hfig(hfig,prfig)
%%

foundfigs = findFilesBVQX( figdirout,'*.fig');
hfig = openfig(foundfigs{1});
hfignew = figure; 
hfignew.Color = 'w'; 
hsb = subplot(6,2,p.p(1,:));
posuse = hsb.Position; 
% delete(hsb); 
copyobj(hfig.Children, hfignew);
hfignew.Children(2).Position = posuse; 



end