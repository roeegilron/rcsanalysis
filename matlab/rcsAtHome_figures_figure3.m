function rcsAtHome_figures_figure3()

%% panel A - raw data from one patient
fignum = 3; 
figdirout = '/Users/roee/Starr_Lab_Folder/Writing/papers/2019_LongTerm_RCS_recordings/figures';
% original function:
% plot_chopped_data_comparisons
load('/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/in_clinic/rest_3rd_try/patientRAWDATA_in_clinic.mat');
idxuse = strcmp(datTbl.patient,'RCS02') & ...
    strcmp(datTbl.side,'R') & ...
    strcmp(datTbl.med,'off' );
% use R 0-2 9-11 for on off comparison and raw data
outdatcomplete = datTbl.data{idxuse};
times = outdatcomplete.derivedTimes;
srate = unique( outdatcomplete.samplerate );
% plot STN and M1
hfig = figure;
hfig.Color = 'w';

nrows = 4; 
ncols = 1; 

cntplt = 1; 
hsb(cntplt) = subplot(nrows,ncols,cntplt); cntplt = cntplt + 1; 
hold on;
subtrac = datetime('23-May-2019 10:49:58.180');
subtrac.TimeZone = outdatcomplete.derivedTimes.TimeZone;
secsuse = outdatcomplete.derivedTimes - subtrac;
idxchoose = secsuse > seconds(0) & secsuse <= seconds(20);
secsplot = secsuse(idxchoose);
y = outdatcomplete.key0(idxchoose);
y = y - mean(y);
y = y .* 1e3;
plot(secsplot,y);

title('STN 0-2','FontName','Arial','FontSize',12);
hsb(1).XTick = [];
hsb(1).YTick = [];
hsb(1).Box = 'off';
ylabel('\muV','FontName','Arial','FontSize',12);

hsb(cntplt) = subplot(nrows,ncols,cntplt); cntplt = cntplt + 1; 
hold on;
subtrac = datetime('23-May-2019 10:49:58.180');
subtrac.TimeZone = outdatcomplete.derivedTimes.TimeZone;
secsuse = outdatcomplete.derivedTimes - subtrac;
idxchoose = secsuse > seconds(0) & secsuse <= seconds(20);
secsplot = secsuse(idxchoose);
y = outdatcomplete.key1(idxchoose);
y = y - mean(y);
y = y .* 1e3;
plot(secsplot,y);

title('STN 1-3','FontName','Arial','FontSize',12);
hsb(cntplt-1).XTick = [];
hsb(cntplt-1).YTick = [];
hsb(cntplt-1).Box = 'off';
ylabel('\muV','FontName','Arial','FontSize',12);



hsb(cntplt) = subplot(nrows,ncols,cntplt); cntplt = cntplt + 1; 
hold on;
y = outdatcomplete.key2(idxchoose);
y = y - mean(y);
y = y .* 1e3;
plot(secsplot,y);
title('M1 8-10','FontName','Arial','FontSize',12);
linkaxes(hsb,'x');
linkaxes(hsb,'y');
hsb(cntplt-1).XTick = [];
hsb(cntplt-1).YTick = [];
hsb(cntplt-1).Box = 'off';
ylabel('\muV','FontName','Arial','FontSize',12);




hsb(cntplt) = subplot(nrows,ncols,cntplt); cntplt = cntplt + 1; 
hold on;
y = outdatcomplete.key3(idxchoose);
y = y - mean(y);
y = y .* 1e3;
plot(secsplot,y);
title('M1 9-11','FontName','Arial','FontSize',12);
linkaxes(hsb,'x');
linkaxes(hsb,'y');
hsb(cntplt-1).XTick = [];
hsb(cntplt-1).YTick = [];
hsb(cntplt-1).Box = 'off';
ylabel('\muV','FontName','Arial','FontSize',12);

% plot scale plot
ylims = hsb(2).YLim;
% vertical is 100 microvolts
plot(seconds([8.1 8.1 ]),[(ylims(1)+10) (ylims(1)+10 + 100)],'LineWidth',1,'Color',[0.5 0.5 0.5 0.7])
ylims = hsb(2).YLim;
% horizontal is 0.2 second
plot(seconds([8.1 8.3 ]),[(ylims(1)+10) (ylims(1)+10)],'LineWidth',1,'Color',[0.5 0.5 0.5 0.7])


linkaxes(hsb,'xy');

xlim(seconds([8 10]));

prfig.plotwidth           = 3;
prfig.plotheight          = 4;
prfig.figdir             = figdirout;
prfig.figname             = sprintf('Fig%d_panelA',fignum);
prfig.figtype             = '-dpdf';
plot_hfig(hfig,prfig)
close(hfig);
%%
%% panel B- psd in clinic - on off from one patient
close all; clear all;
addpath(genpath(fullfile(pwd,'toolboxes','shadedErrorBar')))
fignum = 3; 
figdirout = '/Users/roee/Starr_Lab_Folder/Writing/papers/2019_LongTerm_RCS_recordings/figures';
load('/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/in_clinic/rest_3rd_try/patientPSD_in_clinic.mat');
% original function:
% plot_chopped_data_comparisons
colorsUse   = [ 0 0.8 0 0.5; 0.8 0 0 0.5];
medstates = {'on','off'};
electrodes = {'STN 0-2','M1 9-11'};
datTabl = patientPSD_in_clinic;
cntplt = 1;
hfig = figure;
hfig.Color = 'w';
for e = 1:2
    hsb(1) = subplot(2,1,cntplt); cntplt = cntplt +1;
    hold on;
    for m = 1:2
        idxuse = strcmp(datTabl.patient,'RCS02') & ...
            strcmp(datTabl.side,'R') & ...
            strcmp(datTabl.electrode,electrodes{e}) & ...
            strcmp(datTabl.medstate,medstates{m} );
        % plot
        plot(datTabl.ff{idxuse},datTabl.fftOutNorm{idxuse},'LineWidth',4,'Color',colorsUse(m,:));
        
        xlabel('Frequency (Hz)','FontName','Arial','FontSize',11);
        ylabel('Norm. Power','FontName','Arial','FontSize',11);
    end
    xlim([3.5 89.5]);
    ttluse = sprintf('%s',electrodes{e});
    title(ttluse,'FontName','Arial','FontSize',16);
    set(gca,'FontName','Arial','FontSize',16);
    if e == 2
        legend({'defined on','defined off'},'FontName','Arial','FontSize',10);
    end
    
end

prfig.plotwidth           = 4;
prfig.plotheight          = 4;
prfig.figdir             = figdirout;
prfig.figname             = sprintf('Fig%d_panelB',fignum);
prfig.figtype             = '-dpdf';
plot_hfig(hfig,prfig)
close(hfig);

%% psd data at home - average acros patients and montages for STN 
clc; close all; clear all;
addpath(genpath(fullfile(pwd,'toolboxes','shadedErrorBar')))
fignum = 3; 
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
subplot(1,1,1);hold on; 
% med on 
idxkeep = (cellfun(@(x) (x==500),pdb.srate) & ...
           strcmp(pdb.medstate,'on') );
psds = cell2mat(pdb.fftOutNorm(idxkeep));
ff = pdb.ff(idxkeep);
ff = ff{1}; 
% have issue with RCS02 - only recorded data at 250Hz. Need to include him
% seperatly. 
idxnorm = ff >=5 & ff <=90;
psds = psds(:,idxnorm); 
idxkeep = cellfun(@(x) (x==250),pdb.srate)  & ...
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
hsbH.mainLine.LineWidth = 4;
hsbH.patch.FaceAlpha = 0.1;
hsbH.patch.FaceColor = [0 0.8 0]; 
hsbH.edge(1).Color = [1 1 1];
hsbH.edge(2).Color = [1 1 1];

hLine(1) = hsbH.mainLine;

% med off 
idxkeep = cellfun(@(x) (x==500),pdb.srate)  & ...
           strcmp(pdb.medstate,'off');
psds = cell2mat(pdb.fftOutNorm(idxkeep));
ff = pdb.ff(idxkeep);
ff = ff{1}; 
% have issue with RCS02 - only recorded data at 250Hz. Need to include him
% seperatly. 
idxnorm = ff >=5 & ff <=90;
psds = psds(:,idxnorm); 
idxkeep = cellfun(@(x) (x==250),pdb.srate) & ...
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
hsbH.mainLine.LineWidth = 4;
hsbH.patch.FaceAlpha = 0.1;
hsbH.patch.FaceColor = [0.8 0 0]; 
hsbH.edge(1).Color = [1 1 1];
hsbH.edge(2).Color = [1 1 1];
hLine(2) = hsbH.mainLine;

hold on;
set(gca,'XLim',[5 90])
xlabel('Frequency (Hz)');
ylabel('Norm. Freq');
title('STN contacts','FontSize',16);
legend(hLine,{'defined on','defined off'});

prfig.plotwidth           = 4;
prfig.plotheight          = 4;
prfig.figdir             = figdirout;
prfig.figname             = sprintf('Fig%d_panelD2',fignum);
prfig.figtype             = '-dpdf';
plot_hfig(hfig,prfig)
close(hfig);

%% 

%% panel C - psd at home - all raw data 10 minute - across all states 
% note that this is a moving 2 minute 10 minute average - since using the
% PKG as basis for this 
close all; clear all;
fignum = 3; 
figdirout = '/Users/roee/Starr_Lab_Folder/Writing/papers/2019_LongTerm_RCS_recordings/figures';
% original function:
% plot_pkg_data_all_subjects
load('/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/pkg_data/figures/data_paper/mean_normalized_psd_all_psds RCS02 R pkg L 10_min_avgerage.mat');
hfig = figure;
hfig.Color = 'w';
titles = {'STN 0-2','STN 1-3','M1 8-10','M1 9-11'};
labelsCheck = [];
for c = 1
    hsb(c) = subplot(1,1,c);
    cla(hsb(c));
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
    plot(psdResults.ff', dat,'LineWidth',0.1,'Color',[0 0 0.8 0.1]);
    xlim([3 100]);
    xlabel('Time (Hz)','FontName','Arial','FontSize',11);
    ylabel('Norm Power','FontName','Arial','FontSize',11);
    ttluse = sprintf('All raw data %.1f hours', ((size(dat,1).*10)/60)/2);
    title(ttluse,'FontName','Arial','FontSize',11);
    set(gca,'FontName','Arial','FontSize',11);
end
hfig.RendererMode = 'manual';
hfig.Renderer = 'painters';
prfig.plotwidth           = 3.5;
prfig.plotheight          = 3;
prfig.figdir             = figdirout;
prfig.figname             = sprintf('Fig%d_panelC',fignum);
prfig.figtype             = '-dpdf';
plot_hfig(hfig,prfig)
close(hfig);

%%

%% panel D - psd at home - data seperated by state 
% note that this is a moving 2 minute 10 minute average - since using the
% PKG as basis for this 
close all; clear all;
fignum = 3; 
addpath(genpath(fullfile(pwd,'toolboxes','shadedErrorBar')))
figdirout = '/Users/roee/Starr_Lab_Folder/Writing/papers/2019_LongTerm_RCS_recordings/figures';
% original function:
% plot_pkg_data_all_subjects
load('/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/pkg_data/figures/data_paper/pkg_states RCS02 R pkg L _10_min_avgerage.mat');
cntplt = 1; 
titles = {'STN 0-2','STN 1-3','M1 8-10','M1 9-11'};
colors = [0.8 0 0; 0 0.8 0;0 0 0.8; 0.5 0.5 0.5];
colors2 = {'r','g','b','k'};
hfig = figure; 
hfig.Color = 'w';
for c = [1 4]
    hsb(cntplt) = subplot(2,1,cntplt); cntplt = cntplt + 1;
    hold on;
    statesUsing = {};cntstt = 1;
    for s = 1:length(statesUse)
        fn = sprintf('key%dfftOut',c-1);
        labels = strcmp(allstates,statesUse{s});
        labelsCheck(:,s) = labels;
        
        dat = [];
        dat = allDataPkgRcsAcc.(fn);
        idxnormalize = psdResults.ff > 3 &  psdResults.ff <90;
        meandat = abs(mean(dat(:,idxnormalize),2)); % mean within range, by row
        % the absolute is to make sure 1/f curve is not flipped
        % since PSD values are negative
        meanmat = repmat(meandat,1,size(dat,2));
        dat = dat./meanmat;
        
        
        if sum(labels)>=1
            hsbH = shadedErrorBar(psdResults.ff,dat(labels,:),{@mean,@(x) std(x)*2},...
                'lineprops',{colors2{s},'markerfacecolor','r','LineWidth',2});
            statesUsing{cntstt} = statesUse{s};cntstt = cntstt + 1;
            hsbH.mainLine.Color = [colors(s,:) 0.5];
            hsbH.mainLine.LineWidth = 3;
            hsbH.patch.FaceAlpha = 0.1;
        end
        % save the median data
        
        rawdat = allDataPkgRcsAcc.(fn);
        rawdat = rawdat(labels,:);
        legend(statesUsing);
        xlim([3 100]);
        xlabel('Time (Hz)','FontName','Arial','FontSize',11);
        ylabel('Norm Power','FontName','Arial','FontSize',11);
        ttluse = sprintf('%s',titles{c});
        title(ttluse,'FontName','Arial','FontSize',11);
        set(gca,'FontName','Arial','FontSize',11);
    end
end
hfig.RendererMode = 'manual';
hfig.Renderer = 'painters';
prfig.plotwidth           = 4;
prfig.plotheight          = 4;
prfig.figdir             = figdirout;
prfig.figname             = sprintf('Fig%d_panelD',fignum);
prfig.figtype             = '-dpdf';
plot_hfig(hfig,prfig)
close(hfig);


end