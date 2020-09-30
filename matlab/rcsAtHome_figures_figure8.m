function rcsAtHome_figures_figure8()
%% plot stim vs no stim effects 
close all;
%% setup
plotpanels = 0;
if ~plotpanels
    %% 
    hfig = figure;
    hfig.Color = 'w';
    hpanel = panel();
    hpanel.pack(2,1); % two rows - one for stim/no stim RCS 02 the second for violin plots 
    hpanel(1,1).pack('h',2,1); % panel a - stim vs no stim
%     hpanel.select('all');
%     hpanel.identify();
    %%
end

%% panel A new way of doing data - single subject on off chronic stim 
rootdir = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/processed_data';
patientAnalyze = {'RCS02'};
dataTable = table();
cntTbl = 1;
ff = findFilesBVQX(rootdir,['RCS02' '*psdAndCoherence*stim*.mat']);
for f = 1:length(ff)
    load(ff{f},'allDataCoherencePsd','database');
    allDataPkgRcsAcc = allDataCoherencePsd;
    databaseUse = database;
    allDataPkgRcsAcc.database = databaseUse;
    [pn,fn] = fileparts(ff{f});
    descriptor = fn(strfind(fn,'__'):end);
    dataTable.patient{cntTbl} = fn(1:5);
    dataTable.side{cntTbl} = fn(7);
    dataTable.stim(cntTbl) = database.stimulation_on(1);
    dataTable.descriptor{cntTbl} = descriptor;
    dataTable.allDataPkgRcsAccq{cntTbl} = allDataPkgRcsAcc;
    cntTbl = cntTbl + 1;
end
% plot shaded error bars 
dataTable = sortrows(dataTable,{'stim'});
areasUse = {'key0fftOut','key3fftOut'};
areaTitles = {'STN','M1'};
coloruse = [  0 0.8 0;0.5 0.5 0.5];

for a = 1:length(areasUse)
    hsb(a) = hpanel(1,1,a,1).select();
    hold(hsb(a),'on');
    for t = 1:size(dataTable,1)
        dataStruc = dataTable.allDataPkgRcsAccq{t};
        y = dataStruc.(areasUse{a});
        x = dataStruc.ffPsd;
        hsbH = shadedErrorBar(x,y',{@mean,@(y) std(y)*0.5});
%         hsbH = shadedErrorBar(x',y',{@median,@(yy) std(yy)./sqrt(size(yy,1))});
        hsbH.mainLine.Color = [coloruse(t,:) 0.5];
        hsbH.mainLine.LineWidth = 3;
        hsbH.patch.FaceColor = coloruse(t,:);
        hsbH.edge(1).Color = [1 1 1 0.5];
        hsbH.edge(2).Color = [1 1 1 0.5];
        hsbH.patch.FaceAlpha = 0.3;    
        xlim([3 100]);
        title(areaTitles{a});
        ylabel('Power (log_1_0\muV^2/Hz)');
        xlabel('Frequency (Hz)');
        hLeg(t) = hsbH.patch;
        yStats{t} = y; 
        xStats{t} = x; 
    end
    legend(hLeg,{'stim off','stim on'}); 
    % compute p value in beta range
    freqsNums  = [12 30];
    x = xStats{1}; 
    idxfreqs = x >= freqsNums(1,1) & x <freqsNums(1,2);
    youtFreqsBins{1} = yStats{1}(idxfreqs,:);
    
    % compute the peaks
    yPeaks = [youtFreqsBins{1}];
    % find peaks 
    dataFindPeaks = mean(yPeaks',1);
    pks = []; locs = [];
    [pks,locs] = findpeaks(dataFindPeaks,'MinPeakDistance',length(dataFindPeaks)-2,'MinPeakProminence',range(dataFindPeaks)*0.2);
    betaFreqs = x(idxfreqs);
    if ~isempty(locs)
        peakFreq = betaFreqs(locs);
        idxfreqsPeak = x <= (peakFreq+1.5) & x >= (peakFreq-1.5);
        [pval,h ] = ranksum(mean(yStats{1}(idxfreqsPeak,:)',2),...
            mean(yStats{2}(idxfreqsPeak,:)',2));
        fprintf('pvalue is %.6f\n',pval);
    end
    %

end

savename = '/Users/roee/Box/rcs paper paper on first five bilateral implants/revision for nature biotechnology/figures/Fig3_0_hours_recrorded/psd_and_cohernce_databases_hours_recorded.mat';
load(savename,'hoursRecorded');
idxkeep = strcmp(hoursRecorded.area,'STN') & ... 
          strcmp(hoursRecorded.diagnosis,'PD') & ... 
          strcmp(hoursRecorded.patient,'RCS02'); 
tblUse = hoursRecorded(idxkeep,:);       

 sum(tblUse.awakeHours);
 
 idxkeep = strcmp(hoursRecorded.area,'STN') & ... 
          strcmp(hoursRecorded.diagnosis,'PD') & ... 
          strcmp(hoursRecorded.patient,'RCS02') | strcmp(hoursRecorded.patient,'RCS06') | strcmp(hoursRecorded.patient,'RCS07');
tblUse = hoursRecorded(idxkeep,:);     
 sum(tblUse.awakeHours);


%% 

%% panel B - beta band violin plots 
figdirout = '/Users/roee/Box/rcs paper paper on first five bilateral implants/revision for nature biotechnology/figures/Fig8_effect_chronic_stim';
fnsmsv = fullfile(figdirout,'chronic_stim_vs_baseline_openloop_RCS02_RCS06_RCS07_light.mat'); 
funcUsed = 'plot_violin_plots_open_loop_stim_vs_no_stim.m';
load(fnsmsv,'dataTableLight','funcUsed');
dataTbl = dataTableLight;
idxuse1 = strcmp(dataTbl.patient,'RCS02') & strcmp(dataTbl.side,'L');
idxuse2 = strcmp(dataTbl.patient,'RCS06') & strcmp(dataTbl.side,'L');
idxuse3 = strcmp(dataTbl.patient,'RCS07') & strcmp(dataTbl.side,'R');
idxuse  = idxuse1 | idxuse2 | idxuse3; 
dataTbl = dataTbl(idxuse,:);
dataTbl = sortrows(dataTbl,{'patient','stim'});
dataTbl = [dataTbl(1:2,:) ; dataTbl(5:6,:) ; dataTbl(3:4,:)];
% 

%% plot the violin plots
hsb = hpanel(2,1).select();

addpath(genpath(fullfile(pwd,'toolboxes','Violinplot-Matlab/')));
coloruse = [  0 0.8 0;0.5 0.5 0.5];
plotstruc = struct();
colorsUse = [];
for s = 1:size(dataTbl,1)
    fnUse = sprintf('v%d',s);
    plotstruc.(fnUse) = dataTbl.meanbetafreq{s};
    if dataTbl.stim(s) == 0 
        colorsUse(s,:) = coloruse(1,:);
    elseif dataTbl.stim(s) == 1 
        colorsUse(s,:) = coloruse(2,:);
    end
end

hviolin  = violinplot(plotstruc);
for h = 1:length(hviolin)
    hviolin(h).ViolinPlot.FaceColor =  colorsUse(h,:);
    hviolin(h).ScatterPlot.CData    =  colorsUse(h,:);
    hviolin(h).ViolinPlot.FaceAlpha =  0.3;
    hviolin(h).ShowData = 0;
end
hsb.XTick = 1.5:2:5.5;
hsb.XTickLabel = {'RCS01', 'RCS04','RCS03'};
ylabel('Power (log_1_0\muV^2/Hz)');


%% plot hfig 

hpanel.margin = [30 30 30 30];
% change some labels 
hsb = hpanel(1,1,2,1).select();
hsb.Title.String  = 'MC';

hpanel.fontsize = 16;
figname = 'all_patients_psd_chornic_stim';
prfig.plotwidth           = 16;
prfig.plotheight          = 12;
prfig.figdir             = figdirout;
prfig.figname             = figname;
prfig.figtype             = '-dpdf';
plot_hfig(hfig,prfig)
%%

end