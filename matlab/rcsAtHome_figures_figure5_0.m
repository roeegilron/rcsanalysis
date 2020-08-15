function rcsAtHome_figures_figure5_0()
%% Grouped separation data
% this figure shows the group seperation data 
%% 
% panel a bar graph of total hours awake / alseep
% panel b - PSD and coherence at home - average state estimate across subjects (median average)
% panel c - AUC for all subjects -

addpath(genpath(fullfile(pwd,'toolboxes','panel-2.14')));
%%
    hfig = figure;
    hfig.Color = 'w';
    hpanel = panel();
    hpanel.pack('v',{2/8 4/8 2/8});
    hpanel.select('all');
    hpanel.identify();
% p(1,1).repack(0.3);
%%

close all;
plotpanels = 0;
if ~plotpanels
    %%
    hfig = figure;
    hfig.Color = 'w';
    hpanel = panel();
    hpanel.pack('v',{2/8 3/8 3/8});
%     hpanel.select('all');
%     hpanel.identify();
    %%
end
% plot panel a in the first column, 3 subplots 
% plot panel b and c in the seceond column 2 subplots 
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
    hpanel(1).select();
    hsb = gca();
    hold(hsb,'on');
end

hbar = bar(recTime);
altPatientNames = {'RCS01';'RCS02';'RCS03';'RCS04';'RCS05'};

hsb.XTick = 1:5;
hsb.XTickLabel = altPatientNames;
% hsb.XTickLabelRotation = 45;
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
%% panel b image plot of p-values in which show significance seperating on/off 
% original figure that made this is at: 
% plot_subject_specific_data_psd_coherence_home_data.m
figdirout = '/Users/roee/Box/rcs paper paper on first five bilateral implants/revision for nature biotechnology/figures/Fig5_states_estimates_group_data_and_ AUC';
fnmsv = fullfile(figdirout,'pValues_per_frequency.mat');
load(fnmsv,'tblPvalResults');
uniquePatients = unique(tblPvalResults.patient);

hold(hsb,'on'); 
areas = {'STN','M1','coh'};
cnt = 1; 
unqPatients = unique(tblPvalResults.patient); 
imagePlot = [];
freqsCheck = {'alpha','beta','gamma'};
freqsNums  = [6 15; 12 30; 70 90];

for f = 1:length(freqsCheck)
    for a = 1:length(areas)
        for p = 1:length(unqPatients)
            unqIdxs = strcmp(freqsCheck{f},tblPvalResults.freqName) & ...
                strcmp(unqPatients{p},tblPvalResults.patient) & ...
                cellfun(@(x) any(strfind(x,areas{a})),tblPvalResults.electrode);
            tblUse = tblPvalResults(unqIdxs,:);
            if sum(tblUse.sigCorrected_Ttest & tblUse.peakExists)>=1
                clrUse = [0 0.8 0.2];
            else
                clrUse = [0.8 0 0.2];
            end
            x = p;
            y = cnt;
            yLabels{cnt} =  sprintf('%s %s',areas{a},freqsCheck{f});
            yLabelsUseImage{cnt} =  sprintf('%s',areas{a});
            idxPvals = tblUse.sigCorrected_ManWitney & tblUse.peakExists;
            maxP     = max( -log10(tblUse.rawPval_ManWitney(idxPvals)));
%             maxP     = max( -log10(tblUse.rawPval_Ttest));
            if isempty(maxP)
                maxP = NaN;
            end
            imagePlot(x,cnt) = maxP;
        end
        cnt = cnt + 1;
    end
end
%
% plot an image with empty colors 

hsb = hpanel(2).select();
Data_Array = imagePlot;
imAlpha=ones(size(Data_Array));
imAlpha(isnan(Data_Array))=0;
imAlpha(isnan(Data_Array))=0;
imagesc(Data_Array,'AlphaData',imAlpha);
set(gca,'color',[1 1 1]);


hsb.YTick = 1:length(uniquePatients);
hsb.YTickLabel = uniquePatients;
hsb.XTick = 1:length(yLabelsUseImage);
hsb.XTickLabel = yLabelsUseImage;
% hsb.XTickLabelRotation = 45;

hcolor = colorbar;
hcolor.Label.String = '-log10(p-value)';
title('max p-value / area / subject');
set(gca,'FontSize',16);
axis tight;

%% plot simulated oscilatory phenomoena 
x = linspace(1,100,1e3); 
y = ones(1,1000);
% y(1:10) = y(1:10)./(x(1:10).^4); 
% y(11:end) = y(11:end)./(x(11:end).^2); 
y(1:end) = y(1:end)./(x(1:end).^4); 
baselinePSD = log10(y);

%% start with no oscilationrs 
% hline = plot(x,baselinePSD);
% hline.LineWidth = 4; 
% hline.Color    = [0.9 0 0 0.6]; 
xlabel('Frequency (Hz'); 
ylabel('Power  (log_1_0\muV^2/Hz)');
title('Oscillatory activity correlates with specific motor signs'); 
set(gca,'FontSize',20);

ylim = get(gca,'YLim');
ydat = [ylim(2) ylim(2) ylim(1) ylim(1)];

%% Panel C - add each oscilation in turn (each seperatly
% add oscilation 
hpanel(3).select();
freqs = [... 
         7 13;...
         15 30;...
         75 85]; 
height = [0.8 1.5 2 3]; 
numsecondsPerOscilation = 0.1;

handles.freqranges = freqs;
cuse = parula(size(handles.freqranges,1));
patchTitle = {'Tremor','Levodopa med state, movement','Dyskinesia'};
tempPSD = baselinePSD;
for f = 1:size(freqs,1)
    hold on;
    if f == 1
    end
    heights = 2.85;
    for i = 1:length(heights)
        if i ==1 
            % plot the patch first
            freq = handles.freqranges(f,:);
            xdat = [freq(1) freq(2) freq(2) freq(1)];
            handles.hPatches(f) = patch('XData',xdat,'YData',[1 1 -8 -8],'YLimInclude','off');
            handles.hPatches(f).Parent = gca;
            handles.hPatches(f).FaceColor = cuse(f,:);
            handles.hPatches(f).FaceAlpha = 0.3;
            handles.hPatches(f).EdgeColor = 'none';
            handles.hPatches(f).Visible = 'on';

        end
        idxuse = x > freqs(f,1) & x < freqs(f,2);
        win = blackmanharris(sum(idxuse==1));
        win = win.* heights(i);
%         tempPSD = baselinePSD;
       
        tempPSD(idxuse) = tempPSD(idxuse)+win';
        drawnow;
        if f == size(freqs,1)
            hline = plot(x,tempPSD);
            hline.LineWidth = 4;
            hline.Color    = [0.9 0 0 0.6];
            xlabel('Frequency (Hz');
            ylabel('Power  (log_1_0\muV^2/Hz)');
            title('Oscillatory activity correlates with specific motor signs');
            set(gca,'FontSize',20);
        end

%         writeVideo(v,fullVidFrame);
    end
end
legend(handles.hPatches,patchTitle);

%% print the figure 
hpanel.fontsize = 12;
hpanel.de.margin = 20;
hpanel(2).marginbottom = 40;
hpanel.marginbottom = 30;
hpanel.marginright = 30;
hpanel.margintop = 15;
hpanel.marginleft = 30;
%%
prfig.plotwidth           = 7;
prfig.plotheight          = 10;
prfig.figdir              = figdirout;
prfig.figname             = 'Fig5_v0_pvals_images';
prfig.figtype             = '-dpdf';
plot_hfig(hfig,prfig)

%% 

end