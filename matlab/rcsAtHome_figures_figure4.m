function rcsAtHome_figures_figure4()
%% Grouped separation data
% this figure shows the group seperation data 
%% 
% panel a - group data for in clinc psd 
% panel b - bar graph of total hours recorded (awake / asleep) 
% panel c - grupe data for at home psd 

%% panel A - group data for in clinc psd 
clc; close all; clear all; 
fignum = 4; 
figdirout = '/Users/roee/Starr_Lab_Folder/Writing/papers/2019_LongTerm_RCS_recordings/figures';
% original function:
% plot_chopped_data_comparisons
%plot normalized data across patients 
dirname = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/in_clinic/rest_3rd_try';
fnmsave = fullfile(dirname,'patientPSD_in_clinic.mat');
load(fnmsave,'patientPSD_in_clinic');


pdb = patientPSD_in_clinic;
% plot 
hfig = figure;
hfig.Color = 'w'; 

% stn 
subplot(1,2,1);hold on; 
% med on 
idxkeep = (pdb.srate == 500) & ...
           strcmp(pdb.electrode,'STN 1-3') & ... 
           strcmp(pdb.medstate,'on');
psds = cell2mat(pdb.fftOutNorm(idxkeep));
ff = pdb.ff(idxkeep);
ff = ff{1}; 
% have issue with RCS02 - only recorded data at 250Hz. Need to include him
% seperatly. 
idxnorm = ff >=5 & ff <=90;
psds = psds(:,idxnorm); 
idxkeep = (pdb.srate == 250) & ...
           strcmp(pdb.electrode,'STN 1-3') & ... 
           strcmp(pdb.medstate,'on');
psds02 = cell2mat(pdb.fftOutNorm(idxkeep));
ff = pdb.ff(idxkeep);
ff = ff{1}; 
idxnorm = ff >=5 & ff <=90;
psds02 = psds02(:,idxnorm); 
psds = [psds;psds02];
ff = ff(idxnorm);


% plot(ff,psds,'LineWidth',1,'Color',[0 0.8 0 0.3]);
hsbH = shadedErrorBar(ff,psds,{@mean,@(x) std(x)*1});
hsbH.mainLine.Color = [0 0.8 0 0.5];
hsbH.mainLine.LineWidth = 3;
hsbH.patch.FaceAlpha = 0.1;
hLine(1) = hsbH.mainLine;

% med off 
idxkeep = (pdb.srate == 500) & ...
           strcmp(pdb.electrode,'STN 1-3') & ... 
           strcmp(pdb.medstate,'off');
psds = cell2mat(pdb.fftOutNorm(idxkeep));
ff = pdb.ff(idxkeep);
ff = ff{1}; 
% have issue with RCS02 - only recorded data at 250Hz. Need to include him
% seperatly. 
idxnorm = ff >=5 & ff <=90;
psds = psds(:,idxnorm); 
idxkeep = (pdb.srate == 250) & ...
           strcmp(pdb.electrode,'STN 1-3') & ... 
           strcmp(pdb.medstate,'off');
psds02 = cell2mat(pdb.fftOutNorm(idxkeep));
ff = pdb.ff(idxkeep);
ff = ff{1}; 
idxnorm = ff >=5 & ff <=90;
psds02 = psds02(:,idxnorm); 
psds = [psds;psds02];
ff = ff(idxnorm);


% plot(ff,psds,'LineWidth',1,'Color',[0.8 0 0 0.3]);
hsbH = shadedErrorBar(ff,psds,{@mean,@(x) std(x)*1});
hsbH.mainLine.Color = [0.8 0 0 0.5];
hsbH.mainLine.LineWidth = 3;
hsbH.patch.FaceAlpha = 0.1;
hLine(2) = hsbH.mainLine;

hold on;
set(gca,'XLim',[5 90])
xlabel('Frequency (Hz)');
ylabel('Norm. Freq');
title('STN 1-3','FontSize',16);
legend(hLine,{'defined on','defined off'});

% m1 
subplot(1,2,2);hold on; 
% med on 
idxkeep = (pdb.srate == 500) & ...
           strcmp(pdb.electrode,'M1 8-10') & ... 
           strcmp(pdb.medstate,'on');
psds = cell2mat(pdb.fftOutNorm(idxkeep));
ff = pdb.ff(idxkeep);
ff = ff{1}; 
% have issue with RCS02 - only recorded data at 250Hz. Need to include him
% seperatly. 
idxnorm = ff >=5 & ff <=90;
psds = psds(:,idxnorm); 
idxkeep = (pdb.srate == 250) & ...
           strcmp(pdb.electrode,'M1 8-10') & ... 
           strcmp(pdb.medstate,'on');
psds02 = cell2mat(pdb.fftOutNorm(idxkeep));
ff = pdb.ff(idxkeep);
ff = ff{1}; 
idxnorm = ff >=5 & ff <=90;
psds02 = psds02(:,idxnorm); 
psds = [psds;psds02];
ff = ff(idxnorm);


% plot(ff,psds,'LineWidth',1,'Color',[0 0.8 0 0.3]);
hsbH = shadedErrorBar(ff,psds,{@mean,@(x) std(x)*1});
hsbH.mainLine.Color = [0 0.8 0 0.5];
hsbH.mainLine.LineWidth = 3;
hsbH.patch.FaceAlpha = 0.1;
hLine(1) = hsbH.mainLine;

% med off 
idxkeep = (pdb.srate == 500) & ...
           strcmp(pdb.electrode,'M1 8-10') & ... 
           strcmp(pdb.medstate,'off');
psds = cell2mat(pdb.fftOutNorm(idxkeep));
ff = pdb.ff(idxkeep);
ff = ff{1}; 
% have issue with RCS02 - only recorded data at 250Hz. Need to include him
% seperatly. 
idxnorm = ff >=5 & ff <=90;
psds = psds(:,idxnorm); 
idxkeep = (pdb.srate == 250) & ...
           strcmp(pdb.electrode,'M1 8-10') & ... 
           strcmp(pdb.medstate,'off');
psds02 = cell2mat(pdb.fftOutNorm(idxkeep));
ff = pdb.ff(idxkeep);
ff = ff{1}; 
idxnorm = ff >=5 & ff <=90;
psds02 = psds02(:,idxnorm); 
psds = [psds;psds02];
ff = ff(idxnorm);

% plot(ff,psds,'LineWidth',1,'Color',[0.8 0 0 0.3]);
hsbH = shadedErrorBar(ff,psds,{@mean,@(x) std(x)*1});
hsbH.mainLine.Color = [0.8 0 0 0.5];
hsbH.mainLine.LineWidth = 3;
hsbH.patch.FaceAlpha = 0.1;
hLine(2) = hsbH.mainLine;

legend(hLine,{'defined on','defined off'});

hold on;
set(gca,'XLim',[5 90])
xlabel('Frequency (Hz)');
ylabel('Norm. Freq');
title('M1 8-10','FontSize',12);
sgtitle('Defined on/off in clinic (8 STNs, 4 patients)','FontSize',12);

prfig.plotwidth           = 9;
prfig.plotheight          = 3;
prfig.figdir             = figdirout;
prfig.figname             = sprintf('Fig%d_panelA',fignum);
prfig.figtype             = '-dpdf';
plot_hfig(hfig,prfig)
close(hfig);

%%
%% panel b bar graph of total hours awake / alseep 
clc; close all; clear all; 
fignum = 4; 
figdirout = '/Users/roee/Starr_Lab_Folder/Writing/papers/2019_LongTerm_RCS_recordings/figures';
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
hfig = figure;
hsb = subplot(1,1,1); 
hfig.Color = 'w'; 
hbar = bar(recTime);
hsb.XTickLabel = uniquePatients;
hsb.YLabel.String = 'Hours recoreded'; 
hsb.Title.String = 'Hours recoreded at home / patient'; 
legend({'awake','alseep'},'Location','northwest');
prfig.plotwidth           = 5;
prfig.plotheight          = 2.5;
prfig.figdir             = figdirout;
prfig.figname             = sprintf('Fig%d_panelB',fignum);
prfig.figtype             = '-dpdf';
plot_hfig(hfig,prfig)
close(hfig);

%% 
%% panel C - grupe data for at home psd
clc; close all; clear all; 
fignum = 4; 
figdirout = '/Users/roee/Starr_Lab_Folder/Writing/papers/2019_LongTerm_RCS_recordings/figures';
% original function:
% plot_pkg_data_all_subjects

load('/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home/patientPSD_at_home.mat');
hfig = figure;
hfig.Color = 'w'; 
pdb = patientPSD_at_home;

% stn 
subplot(1,2,1);hold on; 
set(gca,'XLim',[5 90])
% med on 
idxkeep = (pdb.srate == 250) & ...
           strcmp(pdb.electrode,'STN 1-3') & ... 
           strcmp(pdb.medstate,'on');
psds = cell2mat(pdb.fftOutNorm(idxkeep));
ff = pdb.ff(idxkeep);
ff = ff{1}; 
% plot(ff,psds,'LineWidth',1,'Color',[0 0.8 0 0.3]);
hsbH = shadedErrorBar(ff,psds,{@mean,@(x) std(x)*1});
hsbH.mainLine.Color = [0 0.8 0 0.5];
hsbH.mainLine.LineWidth = 3;
hsbH.patch.FaceAlpha = 0.1;
hLine(1) = hsbH.mainLine;

% med off 
idxkeep = (pdb.srate == 250) & ...
           strcmp(pdb.electrode,'STN 1-3') & ... 
           strcmp(pdb.medstate,'off');
psds = cell2mat(pdb.fftOutNorm(idxkeep));
ff = pdb.ff(idxkeep);
ff = ff{1}; 
% plot(ff,psds,'LineWidth',1,'Color',[0.8 0 0 0.3]);

hsbH = shadedErrorBar(ff,psds,{@mean,@(x) std(x)*1});
hsbH.mainLine.Color = [0.8 0 0 0.5];
hsbH.mainLine.LineWidth = 3;
hsbH.patch.FaceAlpha = 0.1;
hLine(2) = hsbH.mainLine;

hold on;
xlabel('Frequency (Hz)');
ylabel('Power  (log_1_0\muV^2/Hz)');
title('STN 1-3','FontSize',16);
legend(hLine,{'PKG estimate - on','PKG estimate - off'});

% m1 
subplot(1,2,2);hold on; 
% med on 
idxkeep = (pdb.srate == 250) & ...
           strcmp(pdb.electrode,'M1 8-10') & ... 
           strcmp(pdb.medstate,'on');
psds = cell2mat(pdb.fftOutNorm(idxkeep));
ff = pdb.ff(idxkeep);
ff = ff{1}; 
% plot(ff,psds,'LineWidth',1,'Color',[0 0.8 0 0.3]);

hsbH = shadedErrorBar(ff,psds,{@mean,@(x) std(x)*1});
hsbH.mainLine.Color = [0 0.8 0 0.5];
hsbH.mainLine.LineWidth = 3;
hsbH.patch.FaceAlpha = 0.1;
hLine(1) = hsbH.mainLine;
% med off 
idxkeep = (pdb.srate == 250) & ...
           strcmp(pdb.electrode,'M1 8-10') & ... 
           strcmp(pdb.medstate,'off');
psds = cell2mat(pdb.fftOutNorm(idxkeep));
ff = pdb.ff(idxkeep);
ff = ff{1}; 
% plot(ff,psds,'LineWidth',1,'Color',[0.8 0 0 0.3]);
hsbH = shadedErrorBar(ff,psds,{@mean,@(x) std(x)*1});
hsbH.mainLine.Color = [0.8 0 0 0.5];
hsbH.mainLine.LineWidth = 3;
hsbH.patch.FaceAlpha = 0.1;
hLine(2) = hsbH.mainLine;
legend(hLine,{'PKG estimate - on','PKG estimate - off'});
hold on;
set(gca,'XLim',[5 90])
xlabel('Frequency (Hz)');
ylabel('Power  (log_1_0\muV^2/Hz)');
title('M1 8-10','FontSize',16);
sgtitle('Defined on/off at home (8 STNs, 4 patients)','FontSize',12);


prfig.plotwidth           = 9;
prfig.plotheight          = 3;
prfig.figdir             = figdirout;
prfig.figname             = sprintf('Fig%d_panelC',fignum);
prfig.figtype             = '-dpdf';
plot_hfig(hfig,prfig)
close(hfig);
%%

end