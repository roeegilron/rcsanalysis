function temp_plot_rcs12_skiing_amp_amp_correlations()
%% find all data 
addpath('/Users/roee/Starr_Lab_Folder/Data_Analysis/Analysis-rcs-data/code');
pn = '/Volumes/RCS_DATA/RCS12/Skiingday/SummitData/SummitContinuousBilateralStreaming';
create_database_from_device_settings_files(pn)
load(fullfile(pn,'database/database_from_device_settings.mat'));
%%
rc = rcsPlotter;
for s = 1:size(masterTableLightOut,1)
    [pn,fn] = fileparts(masterTableLightOut.deviceSettingsFn{s}); 
    rc.addFolder(pn);
end
rc.loadData();
%%
rc.saveTdChannelSpectral();
%% loop on data left 
dbUse = masterTableLightOut;
unqSides = unique(dbUse.side);
for s = 1:length(unqSides)
    idxUse = strcmp(unqSides{s},dbUse.side);
    dbSide = dbUse(idxUse,:);
    outData(s).rc = rcsPlotter();
    for ss = 1:size(dbSide,1)
        [pn,fn] = fileparts(dbSide.deviceSettingsFn{ss});
        outData(s).rc.addFolder(pn);
    end
    outData(s).rc.loadData();
end
%% 

%% plot adaptive
hfig = figure('Color','w');
nrows = 9;
cntplt = 1;
hsb = gobjects();
for c = 1:4
    for i = 1:length(outData)
        hsb(cntplt,1) = subplot(nrows,1,cntplt); cntplt = cntplt + 1;
        outData(i).rc.plotTdChannelSpectral(c,hsb(cntplt-1,1));
        hsb(cntplt-1,1).Title.String = [unqSides{i} ' ' hsb(cntplt-1,1).Title.String ];
    end
end

hsb(cntplt,1) = subplot(nrows,1,cntplt); cntplt = cntplt + 1;
for i = 1:length(outData)
    outData(i).rc.plotActigraphyChannel('X',hsb(cntplt-1,1));
    hsb(cntplt-1,1).Title.String = [unqSides{i} ' ' hsb(cntplt-1,1).Title.String ];
end
linkaxes(hsb,'x')

%%

for i = 1:size(hsb,1)-1
    hax = hsb(i,1);
    timeStart = dateshift(datetime(datevec(hax.XLim(1))) ,'start','hour');
    timeEnd   = dateshift(datetime(datevec(hax.XLim(2))) ,'end','hour');
    xticks = datenum(timeStart : minutes(15) : timeEnd);
    hax.XTick = xticks;
    datetick(hax,'x','HH:MM','keepticks','keeplimits');
    grid(hax,'on');
    hax.GridAlpha = 0.4;
    hax.Layer = 'top';
end

hax = hsb(end,1);
timeStart = dateshift(datetime(datevec(hax.XLim(1))) ,'start','hour');
timeEnd   = dateshift(datetime(datevec(hax.XLim(2))) ,'end','hour');
xticks = datenum(timeStart : minutes(15) : timeEnd);
hax.XTick = xticks;
datetick(hax,'x','HH:MM','keepticks','keeplimits');
grid(hax,'on');
hax.GridAlpha = 0.4;
hax.Layer = 'top';

% look at amp-amp correlatoin in on-meds conditions 
startTime = datetime('10-Dec-2020 12:11:26.819');
stopTime  = datetime('10-Dec-2020 12:26:01.243');

hax.XLim = datenum([startTime, stopTime]);

%% plot amp-amp stim on
load('/Volumes/RCS_DATA/RCS12/Skiingday/SummitData/SummitContinuousBilateralStreaming/RCS12L/Session1607629024823/DeviceNPC700477H/AllDataSpectral.mat')
load('/Volumes/RCS_DATA/RCS12/Skiingday/SummitData/SummitContinuousBilateralStreaming/RCS12R/Session1607629033703/DeviceNPC700476H/AllDataSpectral.mat')
%% set up panel
startTime = datetime('10-Dec-2020 12:11:26.819');
stopTime  = datetime('10-Dec-2020 12:26:01.243');
startTime.TimeZone =  spectralData.spectTimes.TimeZone;
stopTime.TimeZone =  spectralData.spectTimes.TimeZone;

idxkeep = (spectralData.spectTimes' > startTime & spectralData.spectTimes' < stopTime ) & ...
            ~isnan(spectralData.data(:,1,1));
addpath(genpath(fullfile(pwd,'toolboxes','panel-2.14')));
%%
hsb = gobjects();
hfig = figure;
hfig.Color = 'w';
hpanel = panel();
hpanel.pack(3,4);
hsbAll = gobjects();
cntPanel = 1;
% set panel order:
for i = 1:3
    for j = 1:4
        hsbAll(cntPanel,1) = hpanel(i,j).select();
        cntPanel = cntPanel + 1;
    end
end

% verify
for c = 1:4
    dat = spectralData.data(:,:,c)';
    cla(hsbAll(c,1));
    datplot = log10(dat(:,idxkeep));
    if size(datplot,2) > 1200
        numRanLines = 1200;
    else
        numRanLines = size(datplot,2);
    end
    idxplot = randperm(size(datplot,2),numRanLines);
    plot(hsbAll(c,1),datplot(:,idxplot),'LineWidth',0.1,'Color',[0.8 0 0 0.1]);
    ticks = [4 12 30 50 60 65 70 75 80 100];
    hsbAll(c,1).XTick = ticks;
    hsbAll(c,1).XLim = [1 100];
    ylabel(hsbAll(c,1),'Power (log_1_0\muV^2/Hz)');
    xlabel(hsbAll(c,1),'Frequency (Hz)');
    grid(hsbAll(c,1),'on');
    hsbAll(c,1).GridAlpha = 0.8;
    hsbAll(c,1).Layer = 'top';
    fnuse = sprintf('chan%d_tdSettings',c);
    titleUse = spectralData(1).(fnuse);
    title(hsbAll(c,1),titleUse);
end


pairsuse = [1 3; 1 4; 2 3; 2 4; 1 1; 2 2; 3 3; 4 4];



for pp = 1:size(pairsuse,1)
    
    hsb = hsbAll(pp+4,1);
    cla(hsb);
    fnuse = sprintf('chan%d_tdSettings',pairsuse(pp,1));
    xlab = spectralData(1).(fnuse)(1:5);
    fnuse = sprintf('chan%d_tdSettings',pairsuse(pp,2));
    ylab = spectralData(1).(fnuse)(1:5);
    
        
    
    dat = spectralData.data(idxkeep,:,pairsuse(pp,1));
    rescaledMvMean1 = zscore(log10(dat(:,:)));
    %     rescaledMvMean1 = dat(idxkeep & idxtimekeep,:);
    
    dat = spectralData.data(idxkeep,:,pairsuse(pp,2));
    rescaledMvMean2 = zscore(log10(dat(:,:)));
    %     rescaledMvMean1 = dat(idxkeep & idxtimekeep,:);
    
    
    [corrs pvals] = corr(rescaledMvMean1,rescaledMvMean2,'type','Spearman');
    % [corrs pvals] = corrcoef(rescaledMvMean1,rescaledMvMean4);
    %     pvalsCorr = pvals < 0.05/length(pvals(:));
    corrsDiff = corrs;
    %     corrsDiff(corrs<0.6 & corrs>0 ) = NaN;
    %     corrsDiff(corrs<0 & corrs>-0.3 ) = NaN;
    
    % plotting
    if pairsuse(pp,1) ~= pairsuse(pp,2)
        betweenAreas = 1;
    else
        betweenAreas = 0;
    end
    
    if betweenAreas
        axes(hsb);
        b = imagesc(corrsDiff');
        % set(b,'AlphaData',~isnan(corrsDiff'))
        cmin = -0.4;
        cmax = 0.4;
        caxis(hsb, [cmin cmax]);
        colorbar;
    else
        corrsDiff = corrs;
        axes(hsb);
        nrows = size(corrsDiff,1);
        % get rid of diagnoal - turn to NaN since uato correlated
        shifts = [-2 : 1 : 2];
        n = size(corrsDiff,1);
        for ns = 1:length(shifts)
            A = bsxfun(@eq,[1:n].',1-shifts(ns):n-shifts(ns));
            corrsDiff(A) = NaN;
        end
        corrsDiff(nrows+1:nrows+1:end) = NaN;
        b = imagesc(corrsDiff');
        set(b,'AlphaData',~isnan(corrsDiff'))% change alpha on diagonal
        cmin = -0.4;
        cmax = 0.4;
        caxis(hsb,[cmin cmax]);
        colorbar;
        
    end
    
    set(hsb,'YDir','normal')
    
    % get xlabel
    xlabel(xlab);
    
    % get ylabel
    ylabel(ylab);
    
    
    
    ticks = [4 12 30 50 60 65 70 75 80 100];
    
    
    set(gca,'YDir','normal')
    yticks = [4 12 30 50 60 65 70 75 80 100];
    tickLabels = {};
    ticksuse = [];
    fff = spectralData.freqs;
    for yy = 1:length(yticks)
        [~,idx] = min(abs(yticks(yy)-fff));
        ticksuse(yy) = idx;
        tickLabels{yy} = sprintf('%d',yticks(yy));
    end
    hsb.YTick = ticksuse;
    hsb.YTickLabel = tickLabels;
    hsb.XTick = ticksuse;
    hsb.XTickLabel = tickLabels;
    set(hsb,'XLim',[1 idx]);
    set(hsb,'YLim',[1 idx]);
%     axis tight;
    grid(hsb,'on');
    hsb.GridAlpha = 0.8;
    hsb.Layer = 'top';
    
%     ttluse  = sprintf('%s %s %s',database.patient{1},database.side{1},dur);
%     title(ttluse);
end

%%
% save figures;
fnsave  = sprintf('%s_%s_amp_amp_correlations_skiing_meds_on','RCS12','R');
figdirsave = '/Volumes/RCS_DATA/RCS12/Skiingday/figures';

hpanel.margin = 20;
hpanel.fontsize = 7;
% plot
prfig.plotwidth           = 16;
prfig.plotheight          = 9;
prfig.figdir              = figdirsave;
prfig.figname             = fnsave;
prfig.figtype             = '-djpeg';
prfig.closeafterprint     = 0;
plot_hfig(hfig,prfig)
%     close(hfig);
clear('psdDataOut','dataOut','psdTimesOut','database');


end