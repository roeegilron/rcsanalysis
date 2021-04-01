function plot_chronic_stim_daily_plots()

%% this function creates daily plot of chronic stimulation 
%% plots: 
%% 1. psds 
%% 2. spectral reprentation 
%% 3. spec. frequency by day / correlated with PKG graphs 
%% 4. confusion matrix of frequencies / rescaled / normalized 

% to recreate data that into this, steps:
% 1. create_sample_data_set_chronic_stim_vs_off_stim
% 2. open_save_spectral_data_new_algo
% 3. plot_chronic_stim_daily_plots (to plot) 

%% load database 
fnuse = '/Volumes/RCS_DATA/chronic_stim_vs_off/database/database_from_device_settings.mat';
load(fnuse);
params.figdir = '/Volumes/RCS_DATA/chronic_stim_vs_off/figures';
params.resdir = '/Volumes/RCS_DATA/chronic_stim_vs_off/results';
close all; 

%% compare stim on / off  

% plot_stim_on_stim_off_comparisons_within_subject(params);
% plot_stim_on_stim_off_comparisons_across_subject(params);
% plot_stim_on_stim_off_comparisons_across_subject_same_freq(params);
% plot_stim_on_stim_off_comparisons_psds(params,masterTableLightOut);
plot_stim_on_stim_off_with_pkg_spectral(params,masterTableLightOut);

return 


%%

%% find specific patients, and for each of these patietns, specific sides and days 
% the output strucutre is such: 
% where each side of 'spectralPatient' is one side 
% and within spectral patietn itself - you have unique days. 

% spectralPatient(s).outSpectral = outSpectral;
% spectralPatient(s).tblSide = tblSide;

unqPatients = unique(masterTableLightOut.patient);
unqPatients = unqPatients(6); % XXXX 
for p = 1:length(unqPatients)
    % find unique days for this patient. 
    idxpat = cellfun(@(x) any(strfind(x,unqPatients{p})),masterTableLightOut.patient);
    dbPat  = masterTableLightOut(idxpat,:);
    tabDates = table();
    [tabDates.y,tabDates.m,tabDates.d] = ymd(dbPat.timeStart);
    unqDates = unique(tabDates,'rows');
    for d = 1:size(unqDates,1) % loop on dates 
        idxDates = (tabDates.y == unqDates.y(d)) &  ... 
                   (tabDates.m == unqDates.m(d)) &  ... 
                   (tabDates.d == unqDates.d(d));
        dbDates = dbPat(idxDates,:);
        unqSides = unique(dbDates.side);
        % init struct 
        spectralPatient = struct();
        for s = 1:length(unqSides) % loop on sides 
            idxside = cellfun(@(x) any(strfind(x,unqSides{s})),dbDates.side);
            dbSide = dbDates(idxside,:);
            % init variables
            cntSide = 1;
            for fs = 1:size(dbSide,1) % look for data in each side, put it the right structure 
                % get the folder to look into: 
                [pn,fn] = fileparts(dbSide.deviceSettingsFn{fs}); 
                fileLoad = fullfile(pn,'combinedDataTable.mat');
                if exist(fileLoad,'file')
                    % find the patient
                    % find the unique days
                    % within each unique days, find data that is opened (combined meta
                    % data) and concatanate this data
                    %         idxuse =  & ...
                    %             cellfun(@(x)
                    %             any(strfind(x,unqPatients{p})),masterTableLightOut.patient);
                    variableInfo = who('-file', fileLoad);
                    if sum(cellfun(@(x) any(strfind(x,'outSpectral')),variableInfo))>0
                        load(fileLoad,'outSpectral');
                        skipPlot = 1;
                        if ~isempty(outSpectral)
                            fnmsSpectral = fieldnames(outSpectral);
                            for ff = 1:length(fnmsSpectral)
                                spectralPatient(s).outSpectral.(fnmsSpectral{ff}){cntSide} = outSpectral.(fnmsSpectral{ff}){1};
                            end
                            spectralPatient(s).tblSide(cntSide,:) = dbSide(fs,:);
                            cntSide = cntSide +1;
                        end
                    end
                end
            end
        end % end loop on sides 
%         plot_daily_spectral_plots_no_blanks(spectralPatient,params);
%         plot_psd_from_day(spectralPatient,params);
%         cross_freq_amp_correlations(spectralPatient,params);
%         cross_freq_amp_correlations_between_structures(spectralPatient,params);
%         cross_freq_amp_correlations_within_structures(spectralPatient,params);
          plot_smoothed_changes_per_day(spectralPatient,params);
%           find_ideal_smoothing_value_changes_per_day(spectralPatient,params);
    end
end




end

function plot_daily_spectral_plots_no_blanks(spectralPatient,params)
addpath(genpath(fullfile(pwd,'toolboxes','panel-2.14')));
%% plot spectral without the blanks
hsb = gobjects();
for sn = 1:size(spectralPatient,2)
    hfig = figure;
    outSpectral = spectralPatient(sn).outSpectral;
    tblSide = spectralPatient(sn).tblSide;
    hfig = figure;
    hfig.Color = 'w';
    
    hpanel = panel();
    hpanel.pack('v',{0.1 0.8 0.1});
    hpanel(2).pack(4,1);
    cnt = 1;
    for i = 1:4
        hsb(i,1) = hpanel(2,i,1).select();
    end
    
    for c = 1:4
        pppOut = [];
        axes(hsb(c,1));
        timesOut = [];
        for ss = 1:length(outSpectral.spectTimes)
            chanfn = sprintf('chan%d',c);
            ppp = outSpectral.(chanfn){ss};
            fff = outSpectral.fff{ss};
            idxFreqUse = fff >= 2 & fff <= 100;
            pppOut = [pppOut, ppp];
            timesOut = [timesOut,outSpectral.spectTimes{ss}];
        end
        idxFreqUse = fff >= 2 & fff <= 100;
        pppUse = pppOut(idxFreqUse,~isnan(pppOut(1,:)));
        timesKeep = timesOut(~isnan(pppOut(1,:)));
        IblurY2 = imgaussfilt(pppUse,[1 15]);
        him = imagesc(log10(IblurY2));
        
        set(gca,'YDir','normal')
        yticks = [4 12 30 50 60 65 70 75 80 100];
        tickLabels = {};
        ticksuse = [];
        for yy = 1:length(yticks)
            [~,idx] = min(abs(yticks(yy)-fff));
            ticksuse(yy) = idx;
            tickLabels{yy} = sprintf('%d',yticks(yy));
        end
        hsb(c,1).YTick = ticksuse;
        hsb(c,1).YTickLabel = tickLabels;
        % get time labels for x tick
        colormap(hsb(c,1),'jet');
        shading interp
        grid('on')
        hsb(c,1).GridAlpha = 0.8;
        hsb(c,1).Layer = 'top';
        axis tight
        title(tblSide.(chanfn){ss});
        ylabel('Frequency (Hz)');
        
    end


    
    linkaxes(hsb,'x');
    xlims = [1 length(timesKeep)];
    hsb(4,1).XTick = floor(linspace(xlims(1), xlims(2),20));
    xticks = hsb(4,1).XTick;
    xticklabels = {};
    for xx = 1:length(xticks)
        timeUseXtick = timesKeep(xticks(xx));
        timeUseXtick.Format = 'HH:mm';
        xticklabels{xx,1} = sprintf('%s',timeUseXtick);
        timeUseXticksOut(xx) = timeUseXtick;
    end
    for i = 1:3
        hsb(i,1).XTick = [];
        ylabel('Frequency (Hz)');
    end
    hsb(4,1).XTickLabel = xticklabels;
    hpanel.fontsize = 10;
    hpanel.margintop = 20;
    hpanel.margin = 20;
    hpanel.de.margin = 5;
    
    % create ttl
    ttlUse = {};
    cntTtl = 1;
    dateUse  = tblSide.timeStart(1);
    dateUse.Format = 'dd-MMM-uuuu';
    % patient and date:
    ttlUse{cntTtl,1} = sprintf('%s %s %s', tblSide.patient{1},tblSide.side{1},dateUse);
    cntTtl = cntTtl + 1;
    % stim settings
    for t = 1:size(tblSide,1)
        dateUse  = tblSide.timeStart(t);
        dateUse.Format = 'HH:mm';
        ttlUse{cntTtl,1} = sprintf('%s:\t %s %.2fmA %.2fHz', dateUse,tblSide.electrodes{t},tblSide.amplitude_mA(t),tblSide.rate_Hz(t));
        cntTtl = cntTtl + 1;
    end
    sgtitle(ttlUse);
    
    % plot time differences spectrogram
    hsb = hpanel(3).select();
    axes(hsb);
    imagesc(log10(minutes(diff(timeUseXticksOut))))
    set(gca, 'box','off','XTickLabel',[],'XTick',[],'YTickLabel',[],'YTick',[])
    set(gca,'XColor','none')
    set(gca,'YColor','none')
    %% print the figure 
    rootdir = params.figdir; 
    patname = spectralPatient(sn).tblSide.patient{1};
    side    = spectralPatient(sn).tblSide.side{1};
    patFigDir = fullfile(rootdir,patname);
    if ~exist(patFigDir,'dir')
        mkdir(patFigDir);
    end
    % figname 
    [yyy,mmm,ddd] = ymd(spectralPatient(sn).tblSide.timeStart(1));
        hpanel.fontsize = 10;
    figname = sprintf('%s_%s_%d_%0.2d_%0.2d_spectral',patname,side,yyy,mmm,ddd);
    prfig.plotwidth           = 16;
    prfig.plotheight          = 16*0.6;
    prfig.figdir              = patFigDir;
    prfig.figtype             = '-djpeg';
    prfig.closeafterprint     = 1;
    prfig.resolution          = 300;
    prfig.figname             = figname;
    plot_hfig(hfig,prfig);
    %%

end

end

function plot_psd_from_day(spectralPatient,params)
for sn = 1:length(spectralPatient)
    
    outSpectral = spectralPatient(sn).outSpectral;
    tblSide = spectralPatient(sn).tblSide;
    hfig = figure;
    hfig.Color = 'w';
    hpanel = panel();
    hpanel.pack('v',{0.1 0.9});
    
    hpanel(2).pack(2,2);
    cnt = 1;
    for i = 1:2
        for j = 1:2
            hsb(cnt,1) = hpanel(2,i,j).select();
            cnt = cnt + 1;
        end
    end
    
    for ss = 1:length(outSpectral.spectTimes)
        
        for c = 1:4
            axes(hsb(c,1));
            chanfn = sprintf('chan%d',c);
            y = outSpectral.(chanfn){ss}.*1e3;
            fff = outSpectral.fff{ss};
            idxFreqUse = fff >= 2 & fff <= 100;
            times = outSpectral.spectTimes{ss};
            curTime = times(1);
            % min number of chunk is number of spectral "jumps"
            % expected in 10 minutes divided by 2
            % e.g. min of 5 min of data
            minChunks = floor((10*60)/seconds(mode(diff(times)))/2);
            avgPsd = [];
            cntpsd = 1;
            while curTime < (times(end)-minutes(20))
                idxuse = curTime <= times & (curTime + minutes(20)) >= times;
                if sum(idxuse) > minChunks
                    avgPsd(cntpsd,:) = nanmean(y(idxFreqUse,idxuse),2);
                    cntpsd = cntpsd + 1;
                end
                curTime = curTime + minutes(5);
            end
            freqsplot = fff(idxFreqUse);
            plot(freqsplot,log10(avgPsd),...
                'LineWidth',0.5,...
                'Color',[0 0 0.8 0.5]);
            title(tblSide.(chanfn){ss});
            hsbuse = gca;
            hsbuse.XTick = [4 12 30 50 60 65 70 75 80 100];
            grid on;
            ylabel(hsbuse,'Power (log_1_0\muV^2/Hz)');
            xlabel(hsbuse,'Frequency (Hz');
        end
    end
    
        % create ttl
    ttlUse = {};
    cntTtl = 1;
    dateUse  = tblSide.timeStart(1);
    dateUse.Format = 'dd-MMM-uuuu';
    % patient and date:
    ttlUse{cntTtl,1} = sprintf('%s %s %s', tblSide.patient{1},tblSide.side{1},dateUse);
    cntTtl = cntTtl + 1;
    % stim settings
    for t = 1:size(tblSide,1)
        dateUse  = tblSide.timeStart(t);
        dateUse.Format = 'HH:mm';
        ttlUse{cntTtl,1} = sprintf('%s:\t %s %.2fmA %.2fHz', dateUse,tblSide.electrodes{t},tblSide.amplitude_mA(t),tblSide.rate_Hz(t));
        cntTtl = cntTtl + 1;
    end
    sgtitle(ttlUse);
    hsb(1,1).XLabel.String = '';
    hsb(2,1).XLabel.String = '';
    
    hpanel.fontsize = 16;
    hpanel.de.margin = 30;
    hpanel.margin = 20;
    hpanel.de.margin = 20;
    
    
    %% print the figure 
    hpanel.fontsize = 12;
    rootdir = params.figdir; 
    patname = spectralPatient(sn).tblSide.patient{1};
    side    = spectralPatient(sn).tblSide.side{1};
    patFigDir = fullfile(rootdir,patname);
    if ~exist(patFigDir,'dir')
        mkdir(patFigDir);
    end
    % figname 
    [yyy,mmm,ddd] = ymd(spectralPatient(sn).tblSide.timeStart(1));
    figname = sprintf('%s_%s_%d_%0.2d_%0.2d_psd',patname,side,yyy,mmm,ddd);
    prfig.plotwidth           = 16;
    prfig.plotheight          = 16*0.6;
    prfig.figdir              = patFigDir;
    prfig.figtype             = '-djpeg';
    prfig.closeafterprint     = 0;
    prfig.resolution          = 300;
    prfig.figname             = figname;
    plot_hfig(hfig,prfig);
    %%

end
end

function cross_freq_amp_correlations(spectralPatient,params)
%% plot
hsb = gobjects();
hfig = figure; 
hfig.Color = 'w';
hpanel = panel();
hpanel.pack('v',{0.05 0.05 0.9});
hpanel(3).pack(4,4);
hpanel(2).pack('h',{0.5 0.5}); % for titles for each side 
hsbOut = gobjects();
cntPanel = 1;

params.smooth = 1; % don't smoooth 

% set panel order: 
for i = 1:4 
    for j = 1:4 
        hsbOut(cntPanel,1) = hpanel(3,i,j).select();
        cntPanel = cntPanel + 1;
    end
end


cntPanel = 1; 
for sn = 1:length(spectralPatient)
    outSpectral = spectralPatient(sn).outSpectral;
    tblSide = spectralPatient(sn).tblSide;

    pppOutAll  = [];
    for c = 1:4
        pppOut = [];
        timesOut = [];
        for ss = 1:length(outSpectral.spectTimes)
            chanfn = sprintf('chan%d',c);
            ppp = outSpectral.(chanfn){ss};
            fff = outSpectral.fff{ss};
            idxFreqUse = fff >= 2 & fff <= 100;
            pppOut = [pppOut, ppp];
            timesOut = [timesOut,outSpectral.spectTimes{ss}];
        end
        idxFreqUse = fff >= 2 & fff <= 100;
        pppOutAll(:,:,c) = pppOut(idxFreqUse,~isnan(pppOut(1,:)));
        timesOutUse = timesOut(~isnan(pppOut(1,:)));
    end
    [yr,mn,dy] = ymd(timesOutUse(1));
    [~,~,allDays] = ymd(timesOutUse); 
    [h,~,~] = hms(timesOutUse);
    idxKeep = (dy == allDays) & (h <= 17 & h>=8);
    timesOutForPlot = timesOutUse(idxKeep);
    
    pairUse = [1 1;
               2 2;
               3 3;
               4 4;
               1 3;
               1 4;
               2 3; 
               2 4];
    allCoors = [];
    cntCol = 1; 
    for pu = 1:size(pairUse,1)
        yMvMean = movmean(pppOutAll(:,idxKeep,pairUse(pu,1))',[params.smooth 0],'omitnan');
        yMvMean = yMvMean(600:end,:);
        %         colmin = min(yMvMean);
        %         colmax = max(yMvMean);
        %         rescaledMvMean1 = rescale(yMvMean,'InputMin',colmin,'InputMax',colmax);
        %         rescaledMvMean1 = rescaledMvMean1;
        rescaledMvMean1 = zscore(yMvMean);
        
        yMvMean = movmean(pppOutAll(:,idxKeep,pairUse(pu,2))',[params.smooth 0],'omitnan');
        yMvMean = yMvMean(600:end,:);
        %         colmin = min(yMvMean);
        %         colmax = max(yMvMean);
        %         rescaledMvMean4 = rescale(yMvMean,'InputMin',colmin,'InputMax',colmax);
        %         rescaledMvMean4 = rescaledMvMean4;
        rescaledMvMean2 = zscore(yMvMean);
        
        
        [corrs pvals] = corr(rescaledMvMean1,rescaledMvMean2,'type','Spearman');
        % [corrs pvals] = corrcoef(rescaledMvMean1,rescaledMvMean4);
        %     pvalsCorr = pvals < 0.05/length(pvals(:));
        corrsDiff = corrs;
        %     corrsDiff(corrs<0.6 & corrs>0 ) = NaN;
        %     corrsDiff(corrs<0 & corrs>-0.3 ) = NaN;
        
        % plotting 
        hsb =    hsbOut(cntPanel,1);
        cntPanel = cntPanel + 1;
        
        axes(hsb);
        b = imagesc(corrsDiff');
        set(b,'AlphaData',~isnan(corrsDiff'))
        allCoors(:,:,pu) = corrs;


        
        set(gca,'YDir','normal')
        cntRow = 1;
        hsb(sn,cntRow) = hsb;
        
        % get xlabel
        chanfn = sprintf('chan%d',pairUse(pu,1));
        chanfnraw = tblSide.(chanfn){1};
        idxcut = strfind(chanfnraw,'lpf');
        strChannel = chanfnraw(1:idxcut-2);
        xlabel(strChannel);
        
        % get ylabel
        chanfn = sprintf('chan%d',pairUse(pu,2));
        chanfnraw = tblSide.(chanfn){1};
        idxcut = strfind(chanfnraw,'lpf');
        strChannel = chanfnraw(1:idxcut-2);
        ylabel(strChannel);
        
        % title 
        ttlUseSubPlot{1,1} = sprintf('%s %s', tblSide.patient{1},tblSide.side{1});
        title(ttlUseSubPlot);
        
        
        ticks = [4 12 30 50 60 65 70 75 80 100];
        
        
        set(gca,'YDir','normal')
        yticks = [4 12 30 50 60 65 70 75 80 100];
        tickLabels = {};
        ticksuse = [];
        for yy = 1:length(yticks)
            [~,idx] = min(abs(yticks(yy)-fff));
            ticksuse(yy) = idx;
            tickLabels{yy} = sprintf('%d',yticks(yy));
        end
        hsb(sn,cntRow).YTick = ticksuse;
        hsb(sn,cntRow).YTickLabel = tickLabels;
        hsb(sn,cntRow).XTick = ticksuse;
        hsb(sn,cntRow).XTickLabel = tickLabels;
        axis tight;
%         axis square;
        grid(hsb(sn,cntRow),'on');
        hsb(sn,cntRow).GridAlpha = 0.8;
        hsb(sn,cntRow).Layer = 'top';
    end
    
            
    % create ttl
    ttlUse = {};
    cntTtl = 1;
    dateUse  = tblSide.timeStart(1);
    dateUse.Format = 'dd-MMM-uuuu';
    % patient and date:
    ttlUse{cntTtl,1} = sprintf('%s %s %s', tblSide.patient{1},tblSide.side{1},dateUse);
    cntTtl = cntTtl + 1;
    % stim settings
    for t = 1:size(tblSide,1)
        dateUse  = tblSide.timeStart(t);
        dateUse.Format = 'HH:mm';
        ttlUse{cntTtl,1} = sprintf('%s:\t %s %.2fmA %.2fHz', dateUse,tblSide.electrodes{t},tblSide.amplitude_mA(t),tblSide.rate_Hz(t));
        cntTtl = cntTtl + 1;
    end
    hsbTitle = hpanel(2,sn).select();
    title(hsbTitle, ttlUse);
    set(hsbTitle, 'box','off','XTickLabel',[],'XTick',[],'YTickLabel',[],'YTick',[])
    

end


for i = 1:size(hsbOut,1)
    caxis(hsbOut(i,1),[min(allCoors(:)) max(allCoors(:))]);
end

hpanel.fontsize = 10;
hpanel(2).marginbottom = 1;

% print figure 
hpanel.fontsize = 8;
rootdir = params.figdir;
patname = spectralPatient(sn).tblSide.patient{1};
side    = spectralPatient(sn).tblSide.side{1};
patFigDir = fullfile(rootdir,patname);
if ~exist(patFigDir,'dir')
    mkdir(patFigDir);
end
% figname
[yyy,mmm,ddd] = ymd(spectralPatient(sn).tblSide.timeStart(1));
figname = sprintf('%s_%s_%d_%0.2d_%0.2d_cross_amp_corr_all_pairs',patname,side,yyy,mmm,ddd);
prfig.plotwidth           = 16;
prfig.plotheight          = 16*0.6;
prfig.figdir              = patFigDir;
prfig.figtype             = '-djpeg';
prfig.closeafterprint     = 1;
prfig.resolution          = 300;
prfig.figname             = figname;
plot_hfig(hfig,prfig);

end

function cross_freq_amp_correlations_between_structures(spectralPatient,params)
%% plot
hsb = gobjects();
hfig = figure; 
hfig.Color = 'w';
hpanel = panel();
hpanel.pack('v',{0.05 0.05 0.9});
hpanel(3).pack(2,4);
hpanel(2).pack('h',{0.5 0.5}); % for titles for each side 
hsbOut = gobjects();
cntPanel = 1;

params.smooth = 1; % don't smoooth 

% set panel order: 
for i = 1:2 
    for j = 1:4 
        hsbOut(cntPanel,1) = hpanel(3,i,j).select();
        cntPanel = cntPanel + 1;
    end
end

tblSaveOut = table(); 
cntbl = 1;
cntPanel = 1; 
for sn = 1:length(spectralPatient)
    outSpectral = spectralPatient(sn).outSpectral;
    tblSide = spectralPatient(sn).tblSide;

    pppOutAll  = [];
    for c = 1:4
        pppOut = [];
        timesOut = [];
        for ss = 1:length(outSpectral.spectTimes)
            chanfn = sprintf('chan%d',c);
            ppp = outSpectral.(chanfn){ss};
            fff = outSpectral.fff{ss};
            idxFreqUse = fff >= 2 & fff <= 100;
            pppOut = [pppOut, ppp];
            timesOut = [timesOut,outSpectral.spectTimes{ss}];
        end
        idxFreqUse = fff >= 2 & fff <= 100;
        pppOutAll(:,:,c) = pppOut(idxFreqUse,~isnan(pppOut(1,:)));
        timesOutUse = timesOut(~isnan(pppOut(1,:)));
    end
    [yr,mn,dy] = ymd(timesOutUse(1));
    [~,~,allDays] = ymd(timesOutUse); 
    [h,~,~] = hms(timesOutUse);
    idxKeep = (dy == allDays) & (h <= 17 & h>=8);
    timesOutForPlot = timesOutUse(idxKeep);
    
    pairUse = [1 3;
               1 4;
               2 3; 
               2 4];
    allCoors = [];
    cntCol = 1; 
    for pu = 1:size(pairUse,1)
        yMvMean = movmean(pppOutAll(:,idxKeep,pairUse(pu,1))',[params.smooth 0],'omitnan');
        yMvMean = yMvMean(600:end,:);
        %         colmin = min(yMvMean);
        %         colmax = max(yMvMean);
        %         rescaledMvMean1 = rescale(yMvMean,'InputMin',colmin,'InputMax',colmax);
        %         rescaledMvMean1 = rescaledMvMean1;
        rescaledMvMean1 = zscore(yMvMean);
        
        yMvMean = movmean(pppOutAll(:,idxKeep,pairUse(pu,2))',[params.smooth 0],'omitnan');
        yMvMean = yMvMean(600:end,:);
        %         colmin = min(yMvMean);
        %         colmax = max(yMvMean);
        %         rescaledMvMean4 = rescale(yMvMean,'InputMin',colmin,'InputMax',colmax);
        %         rescaledMvMean4 = rescaledMvMean4;
        rescaledMvMean2 = zscore(yMvMean);
        
        
        [corrs pvals] = corr(rescaledMvMean1,rescaledMvMean2,'type','Spearman');
        % [corrs pvals] = corrcoef(rescaledMvMean1,rescaledMvMean4);
        %     pvalsCorr = pvals < 0.05/length(pvals(:));
        corrsDiff = corrs;
        %     corrsDiff(corrs<0.6 & corrs>0 ) = NaN;
        %     corrsDiff(corrs<0 & corrs>-0.3 ) = NaN;
        
        % plotting 
        hsb =    hsbOut(cntPanel,1);
        cntPanel = cntPanel + 1;
        
        axes(hsb);
        b = imagesc(corrsDiff');
        set(b,'AlphaData',~isnan(corrsDiff'))
        allCoors(:,:,pu) = corrs;


        
        set(gca,'YDir','normal')
        cntRow = 1;
        hsb(sn,cntRow) = hsb;
        
        % get xlabel
        chanfn = sprintf('chan%d',pairUse(pu,1));
        chanfnraw = tblSide.(chanfn){1};
        idxcut = strfind(chanfnraw,'lpf');
        strChannelX = chanfnraw(1:idxcut-2);
        xlabel(strChannelX);
        
        % get ylabel
        chanfn = sprintf('chan%d',pairUse(pu,2));
        chanfnraw = tblSide.(chanfn){1};
        idxcut = strfind(chanfnraw,'lpf');
        strChannelY = chanfnraw(1:idxcut-2);
        ylabel(strChannelY);
        
        % title 
        ttlUseSubPlot{1,1} = sprintf('%s %s', tblSide.patient{1},tblSide.side{1});
        title(ttlUseSubPlot);
        
        
        
        ticks = [4 12 30 50 60 65 70 75 80 100];
        
        
        set(gca,'YDir','normal')
        yticks = [4 12 30 50 60 65 70 75 80 100];
        tickLabels = {};
        ticksuse = [];
        for yy = 1:length(yticks)
            [~,idx] = min(abs(yticks(yy)-fff));
            ticksuse(yy) = idx;
            tickLabels{yy} = sprintf('%d',yticks(yy));
        end
        hsb(sn,cntRow).YTick = ticksuse;
        hsb(sn,cntRow).YTickLabel = tickLabels;
        hsb(sn,cntRow).XTick = ticksuse;
        hsb(sn,cntRow).XTickLabel = tickLabels;
        axis tight;
%         axis square;
        grid(hsb(sn,cntRow),'on');
        hsb(sn,cntRow).GridAlpha = 0.8;
        hsb(sn,cntRow).Layer = 'top';
        
        
        % save all of this data to a table that will get saved out to the
        % figure directory for now for later comparison across stim levels.
        
        dateUse  = tblSide.timeStart(1);
        dateUse.Format = 'dd-MMM-uuuu';

        
        tblSaveOut.patient{cntbl} = tblSide.patient{1}; 
        tblSaveOut.side{cntbl} = tblSide.side{1};
        tblSaveOut.date(cntbl) = dateUse; 
        tblSaveOut.strChannelY{cntbl} = strChannelY;
        tblSaveOut.strChannelX{cntbl} = strChannelX;
        tblSaveOut.stimOn(cntbl) = sum(tblSide.stimulation_on);    
        
        tblSaveOut.corrsDiff{cntbl} = corrsDiff;
        tblSaveOut.ticksuse{cntbl} = ticksuse;
        tblSaveOut.tickLabels{cntbl} = tickLabels;
        
        tblSaveOut.tblSide{cntbl} = tblSide;
        
        
        % create ttlForRec
        ttlUseRec = {};
        cntTtl = 1;
        dateUse  = tblSide.timeStart(1);
        dateUse.Format = 'dd-MMM-uuuu';
        % patient and date:
        ttlUseRec{cntTtl,1} = sprintf('%s %s %s', tblSide.patient{1},tblSide.side{1},dateUse);
        cntTtl = cntTtl + 1;
        % stim settings
        for t = 1:size(tblSide,1)
            dateUse  = tblSide.timeStart(t);
            dateUse.Format = 'HH:mm';
            ttlUseRec{cntTtl,1} = sprintf('%s:\t %s %.2fmA %.2fHz', dateUse,tblSide.electrodes{t},tblSide.amplitude_mA(t),tblSide.rate_Hz(t));
            cntTtl = cntTtl + 1;
        end
        
        tblSaveOut.ttlUseRec{cntbl} = ttlUseRec;
        
        cntbl = cntbl + 1; 
        
           
        

    
    end
    
            
    

    
    % create ttl
    ttlUse = {};
    cntTtl = 1;
    dateUse  = tblSide.timeStart(1);
    dateUse.Format = 'dd-MMM-uuuu';
    % patient and date:
    ttlUse{cntTtl,1} = sprintf('%s %s %s', tblSide.patient{1},tblSide.side{1},dateUse);
    cntTtl = cntTtl + 1;
    % stim settings
    for t = 1:size(tblSide,1)
        dateUse  = tblSide.timeStart(t);
        dateUse.Format = 'HH:mm';
        ttlUse{cntTtl,1} = sprintf('%s:\t %s %.2fmA %.2fHz', dateUse,tblSide.electrodes{t},tblSide.amplitude_mA(t),tblSide.rate_Hz(t));
        cntTtl = cntTtl + 1;
    end
    hsbTitle = hpanel(2,sn).select();
    title(hsbTitle, ttlUse);
    set(hsbTitle, 'box','off','XTickLabel',[],'XTick',[],'YTickLabel',[],'YTick',[])
    

end

% save table to later plot comparisons of stim on / stim off 
patResDir = fullfile(params.resdir);
fnsave = fullfile(patResDir,sprintf('%s%s_%s.mat',tblSaveOut.patient{1},tblSaveOut.side{1},tblSaveOut.date(1)));
save(fnsave,'tblSaveOut');


for i = 1:size(hsbOut,1)
    caxis(hsbOut(i,1),[min(allCoors(:)) max(allCoors(:))]);
end

hpanel.fontsize = 10;
hpanel(2).marginbottom = 1;

% print figure 
hpanel.fontsize = 8;
rootdir = params.figdir;
patname = spectralPatient(sn).tblSide.patient{1};
side    = spectralPatient(sn).tblSide.side{1};
patFigDir = fullfile(rootdir,patname);
if ~exist(patFigDir,'dir')
    mkdir(patFigDir);
end
% figname
[yyy,mmm,ddd] = ymd(spectralPatient(sn).tblSide.timeStart(1));
figname = sprintf('%s_%s_%d_%0.2d_%0.2d_cross_amp_corr_all_pairs_between',patname,side,yyy,mmm,ddd);
prfig.plotwidth           = 16;
prfig.plotheight          = 16*0.6;
prfig.figdir              = patFigDir;
prfig.figtype             = '-djpeg';
prfig.closeafterprint     = 1;
prfig.resolution          = 300;
prfig.figname             = figname;
plot_hfig(hfig,prfig);

end

function cross_freq_amp_correlations_within_structures(spectralPatient,params)
%% plot
hsb = gobjects();
hfig = figure; 
hfig.Color = 'w';
hpanel = panel();
hpanel.pack('v',{0.05 0.05 0.9});
hpanel(3).pack(2,4);
hpanel(2).pack('h',{0.5 0.5}); % for titles for each side 
hsbOut = gobjects();
cntPanel = 1;

params.smooth = 1; % don't smoooth 

% set panel order: 
for i = 1:2 
    for j = 1:4 
        hsbOut(cntPanel,1) = hpanel(3,i,j).select();
        cntPanel = cntPanel + 1;
    end
end

tblSaveOut = table(); 
cntbl = 1;
cntPanel = 1; 
for sn = 1:length(spectralPatient)
    outSpectral = spectralPatient(sn).outSpectral;
    tblSide = spectralPatient(sn).tblSide;

    pppOutAll  = [];
    for c = 1:4
        pppOut = [];
        timesOut = [];
        for ss = 1:length(outSpectral.spectTimes)
            chanfn = sprintf('chan%d',c);
            ppp = outSpectral.(chanfn){ss};
            fff = outSpectral.fff{ss};
            idxFreqUse = fff >= 2 & fff <= 100;
            pppOut = [pppOut, ppp];
            timesOut = [timesOut,outSpectral.spectTimes{ss}];
        end
        idxFreqUse = fff >= 2 & fff <= 100;
        pppOutAll(:,:,c) = pppOut(idxFreqUse,~isnan(pppOut(1,:)));
        timesOutUse = timesOut(~isnan(pppOut(1,:)));
    end
    [yr,mn,dy] = ymd(timesOutUse(1));
    [~,~,allDays] = ymd(timesOutUse); 
    [h,~,~] = hms(timesOutUse);
    idxKeep = (dy == allDays) & (h <= 17 & h>=8);
    timesOutForPlot = timesOutUse(idxKeep);
    
    pairUse = [1 1;
               2 2;
               3 3; 
               4 4];
    allCoors = [];
    cntCol = 1; 
    for pu = 1:size(pairUse,1)
        yMvMean = movmean(pppOutAll(:,idxKeep,pairUse(pu,1))',[params.smooth 0],'omitnan');
        yMvMean = yMvMean(600:end,:);
        %         colmin = min(yMvMean);
        %         colmax = max(yMvMean);
        %         rescaledMvMean1 = rescale(yMvMean,'InputMin',colmin,'InputMax',colmax);
        %         rescaledMvMean1 = rescaledMvMean1;
        rescaledMvMean1 = zscore(yMvMean);
        
        yMvMean = movmean(pppOutAll(:,idxKeep,pairUse(pu,2))',[params.smooth 0],'omitnan');
        yMvMean = yMvMean(600:end,:);
        %         colmin = min(yMvMean);
        %         colmax = max(yMvMean);
        %         rescaledMvMean4 = rescale(yMvMean,'InputMin',colmin,'InputMax',colmax);
        %         rescaledMvMean4 = rescaledMvMean4;
        rescaledMvMean2 = zscore(yMvMean);
        
        
        [corrs pvals] = corr(rescaledMvMean1,rescaledMvMean2,'type','Spearman');
        % [corrs pvals] = corrcoef(rescaledMvMean1,rescaledMvMean4);
        %     pvalsCorr = pvals < 0.05/length(pvals(:));
        %     corrsDiff(corrs<0.6 & corrs>0 ) = NaN;
        %     corrsDiff(corrs<0 & corrs>-0.3 ) = NaN;
        
        % plotting 
        hsb =    hsbOut(cntPanel,1);
        cntPanel = cntPanel + 1;
        
        %%
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
        %%
        allCoors(:,:,pu) = corrs;


        
        set(gca,'YDir','normal')
        cntRow = 1;
        hsb(sn,cntRow) = hsb;
        
        % get xlabel
        chanfn = sprintf('chan%d',pairUse(pu,1));
        chanfnraw = tblSide.(chanfn){1};
        idxcut = strfind(chanfnraw,'lpf');
        strChannelX = chanfnraw(1:idxcut-2);
        xlabel(strChannelX);
        
        % get ylabel
        chanfn = sprintf('chan%d',pairUse(pu,2));
        chanfnraw = tblSide.(chanfn){1};
        idxcut = strfind(chanfnraw,'lpf');
        strChannelY = chanfnraw(1:idxcut-2);
        ylabel(strChannelY);
        
        % title 
        ttlUseSubPlot{1,1} = sprintf('%s %s', tblSide.patient{1},tblSide.side{1});
        title(ttlUseSubPlot);
        
        
        
        ticks = [4 12 30 50 60 65 70 75 80 100];
        
        
        set(gca,'YDir','normal')
        yticks = [4 12 30 50 60 65 70 75 80 100];
        tickLabels = {};
        ticksuse = [];
        for yy = 1:length(yticks)
            [~,idx] = min(abs(yticks(yy)-fff));
            ticksuse(yy) = idx;
            tickLabels{yy} = sprintf('%d',yticks(yy));
        end
        hsb(sn,cntRow).YTick = ticksuse;
        hsb(sn,cntRow).YTickLabel = tickLabels;
        hsb(sn,cntRow).XTick = ticksuse;
        hsb(sn,cntRow).XTickLabel = tickLabels;
        axis tight;
%         axis square;
        grid(hsb(sn,cntRow),'on');
        hsb(sn,cntRow).GridAlpha = 0.8;
        hsb(sn,cntRow).Layer = 'top';
        
        
        % save all of this data to a table that will get saved out to the
        % figure directory for now for later comparison across stim levels.
        
        dateUse  = tblSide.timeStart(1);
        dateUse.Format = 'dd-MMM-uuuu';

        
        tblSaveOut.patient{cntbl} = tblSide.patient{1}; 
        tblSaveOut.side{cntbl} = tblSide.side{1};
        tblSaveOut.date(cntbl) = dateUse; 
        tblSaveOut.strChannelY{cntbl} = strChannelY;
        tblSaveOut.strChannelX{cntbl} = strChannelX;
        tblSaveOut.stimOn(cntbl) = sum(tblSide.stimulation_on);    
        
        tblSaveOut.corrsDiff{cntbl} = corrsDiff;
        tblSaveOut.ticksuse{cntbl} = ticksuse;
        tblSaveOut.tickLabels{cntbl} = tickLabels;
        
        tblSaveOut.tblSide{cntbl} = tblSide;
        
        
        % create ttlForRec
        ttlUseRec = {};
        cntTtl = 1;
        dateUse  = tblSide.timeStart(1);
        dateUse.Format = 'dd-MMM-uuuu';
        % patient and date:
        ttlUseRec{cntTtl,1} = sprintf('%s %s %s', tblSide.patient{1},tblSide.side{1},dateUse);
        cntTtl = cntTtl + 1;
        % stim settings
        for t = 1:size(tblSide,1)
            dateUse  = tblSide.timeStart(t);
            dateUse.Format = 'HH:mm';
            ttlUseRec{cntTtl,1} = sprintf('%s:\t %s %.2fmA %.2fHz', dateUse,tblSide.electrodes{t},tblSide.amplitude_mA(t),tblSide.rate_Hz(t));
            cntTtl = cntTtl + 1;
        end
        
        tblSaveOut.ttlUseRec{cntbl} = ttlUseRec;
        
        cntbl = cntbl + 1; 
        
           
        

    
    end
    
            
    

    
    % create ttl
    ttlUse = {};
    cntTtl = 1;
    dateUse  = tblSide.timeStart(1);
    dateUse.Format = 'dd-MMM-uuuu';
    % patient and date:
    ttlUse{cntTtl,1} = sprintf('%s %s %s', tblSide.patient{1},tblSide.side{1},dateUse);
    cntTtl = cntTtl + 1;
    % stim settings
    for t = 1:size(tblSide,1)
        dateUse  = tblSide.timeStart(t);
        dateUse.Format = 'HH:mm';
        ttlUse{cntTtl,1} = sprintf('%s:\t %s %.2fmA %.2fHz', dateUse,tblSide.electrodes{t},tblSide.amplitude_mA(t),tblSide.rate_Hz(t));
        cntTtl = cntTtl + 1;
    end
    hsbTitle = hpanel(2,sn).select();
    title(hsbTitle, ttlUse);
    set(hsbTitle, 'box','off','XTickLabel',[],'XTick',[],'YTickLabel',[],'YTick',[])
    

end

% save table to later plot comparisons of stim on / stim off 
patResDir = fullfile(params.resdir);
fnsave = fullfile(patResDir,sprintf('%s%s_within_struc_%s.mat',tblSaveOut.patient{1},tblSaveOut.side{1},tblSaveOut.date(1)));
save(fnsave,'tblSaveOut');


for i = 1:size(hsbOut,1)
    caxis(hsbOut(i,1),[min(allCoors(:)) max(allCoors(:))]);
end

hpanel.fontsize = 10;
hpanel(2).marginbottom = 1;

% print figure 
hpanel.fontsize = 8;
rootdir = params.figdir;
patname = spectralPatient(sn).tblSide.patient{1};
side    = spectralPatient(sn).tblSide.side{1};
patFigDir = fullfile(rootdir,patname);
if ~exist(patFigDir,'dir')
    mkdir(patFigDir);
end
% figname
[yyy,mmm,ddd] = ymd(spectralPatient(sn).tblSide.timeStart(1));
figname = sprintf('%s_%s_%d_%0.2d_%0.2d_cross_amp_corr_all_pairs_within',patname,side,yyy,mmm,ddd);
prfig.plotwidth           = 16;
prfig.plotheight          = 16*0.6;
prfig.figdir              = patFigDir;
prfig.figtype             = '-djpeg';
prfig.closeafterprint     = 1;
prfig.resolution          = 300;
prfig.figname             = figname;
plot_hfig(hfig,prfig);

end

function plot_smoothed_changes_per_day(spectralPatient,prms)
for sn = 1:length(spectralPatient)
    tblSide = spectralPatient(sn).tblSide;
    patAndSide = sprintf('%s%s',spectralPatient(sn).tblSide.patient{1},...
        spectralPatient(sn).tblSide.side{1});
    params = struct();
    switch patAndSide
        case 'RCS02L'
            if ~tblSide.stimulation_on(1)
                params.chan1 = [9 20 51 74 ]; % has some issue of interfernce
                params.chan2 = [8 20 48 76]; % has some issue of interfernce
                params.chan3 = [8 22 76];
                params.chan4 = [9 23 75];
                params.smooth = 0;
                params.bw = 3;
            end
        case 'RCS02R'
            if ~tblSide.stimulation_on(1)
                params.chan1 = [9 20 51 74 ]; % has some issue of interfernce
                params.chan2 = [8 20 48 76]; % has some issue of interfernce
                params.chan3 = [8 22 76];
                params.chan4 = [9 23 75];
                params.smooth = 1600;
                params.bw = 3;
            end

            if tblSide.stimulation_on(1)
                % after stim - jun 25 2020
                params.chan2 = [8 13 33 65];
                params.chan3 = [14 8 17 65];
                params.chan4 = [5 21 65];
                params.smooth = 1600;
                params.bw = 3;
                
            end


        case 'RCS08R'
            params.chan1 = [6, 23, 77];
            params.chan3 = [4 23 77];
            params.chan4 = [11 22 65 77];
            
            
        case 'RCS08L'
            params.chan3 = [11 23 64 ];
            params.chan4 = [11 22 32 65 ];
            
        case 'RCS07R'
            if ~tblSide.stimulation_on(1)
                % before stim - oct 10 2019
                params.chan1 = [5 16 32 54 79 ]; % has some issue of interfernce
                params.chan2 = [5 16 41 79]; % has some issue of interfernce
                params.chan3 = [10 82];
                params.chan4 = [10 17 83];
                params.smooth = 1600;
                params.bw = 3;
            end
            
            if tblSide.stimulation_on(1)
                % after stim - jun 25 2020
                params.chan2 = [8 13 33 65];
                params.chan3 = [14 8 17 65];
                params.chan4 = [5 21 65];
                params.smooth = 1600;
                params.bw = 3;
                
            end
        case 'RCS07L'
            if ~tblSide.stimulation_on(1)
                % before stim - oct 10 2019
                params.chan1 = [18]; % has some issue of interfernce
                params.chan2 = [5 8 19 82]; % has some issue of interfernce
                params.chan3 = [9 20 79 ];
                params.chan4 = [8 22 79];
                params.smooth = 1600;
                params.bw = 3;
            end
            if tblSide.stimulation_on(1)
                % after stim - jun 25 2020
                params.chan2 = [7 16 65]; % has some issue of interfernce
                params.chan3 = [10 19 65 ];
                params.chan4 = [5 65];
                params.smooth = 1600;
                params.bw = 3;
            end
        case 'RCS06R'
            if ~tblSide.stimulation_on(1)
                % before stim - oct 13 2019
                params.chan1 = [18]; % has some issue of interfernce
                params.chan2 = [5 8 19 82]; % has some issue of interfernce
                params.chan3 = [9 20 79 ];
                params.chan4 = [8 22 79];
                params.smooth = 1600;
                params.bw = 3;
            end
            if tblSide.stimulation_on(1)
                % after stim - jun 25 2020
                params.chan2 = [7 16 65]; % has some issue of interfernce
                params.chan3 = [10 19 65 ];
                params.chan4 = [5 65];
                params.smooth = 1600;
                params.bw = 3;
            end
        case 'RCS06L'
            
            
        case 'RCS12L'
            if ~tblSide.stimulation_on(1)
                % before stim - 23 nov 2020
                params.chan1 = [27 67]; % has some issue of interfernce
                params.chan4 = [10 67]; % has some issue of interfernce
                params.smooth = 2e3;
                params.bw = 4;
            end
            if tblSide.stimulation_on(1)
                % after stim - jun 25 2020
                params.chan2 = [7 16 65]; % has some issue of interfernce
                params.chan3 = [10 19 65 ];
                params.chan4 = [5 65];
                params.smooth = 50;
                params.bw = 3;
            end

            
        otherwise
            
    end
    
    outSpectral = spectralPatient(sn).outSpectral;
    tblSide = spectralPatient(sn).tblSide;
    
    
    hsb  = gobjects();
    %%
    hfig = figure;
    hfig.Color = 'w';
    hpanel = panel();
    hpanel.pack('v',{0.1 0.9});
    nrows = length( fieldnames(params))-2;
    hpanel(2).pack(nrows,1);
    for n = 1:nrows
        hsb(n,1) = hpanel(2,n,1).select();
        hold on;
    end
    
    fieldnamesraw = fieldnames(params);
    idxfielnams = cellfun(@(x) any(strfind(x,'chan')),fieldnamesraw);
    fieldnamesuse = fieldnamesraw(idxfielnams);
    
    for fn = 1:length(fieldnamesuse) % loop on channels
        freqCenters = params.(fieldnamesuse{fn});
        lgnds = {};
        hplt = [];
        for fq = 1:length(freqCenters)
            lgnds{fq} = sprintf('%dHz',freqCenters(fq));
            % two loops - the first is to find the min/max for rescaling,
            % the second to plot
            yMvOut = [];
            for ss = 1:length(outSpectral.spectTimes)
                y = outSpectral.(fieldnamesuse{fn}){ss};
                fff = outSpectral.fff{ss};
                bwupper = freqCenters(fq) + params.bw;
                bwlower = freqCenters(fq) - params.bw;
                idxFreqUse = fff >= bwlower & fff <= bwupper;
                yFreqMean = mean(y(idxFreqUse,:),1);
                yMvMean = movmean(yFreqMean,[params.smooth 0],'omitnan');
                times = outSpectral.spectTimes{ss};
                yMvOut = [yMvOut,yMvMean];
                
            end
            minVal = min(yMvMean);
            maxVal = max(yMvMean);
            %             rescale(yMvMean,'InputMin',colmin,'InputMax',colmax)
            
            for ss = 1:length(outSpectral.spectTimes)
                
                axes(hsb(fn,1));
                y = outSpectral.(fieldnamesuse{fn}){ss};
                fff = outSpectral.fff{ss};
                bwupper = freqCenters(fq) + params.bw;
                bwlower = freqCenters(fq) - params.bw;
                idxFreqUse = fff >= bwlower & fff <= bwupper;
                yFreqMean = mean(y(idxFreqUse,:),1);
                yMvMean = movmean(yFreqMean,[params.smooth 0],'omitnan');
                rescaledMvMean = rescale(yMvMean,'InputMin',minVal,'InputMax',maxVal);
                rescaledMvMean =   (yMvMean- nanmean(yMvMean))/nanstd(yMvMean);
%                 rescaledMvMean =   (yFreqMean- nanmean(yFreqMean))/nanstd(yFreqMean);

                times = outSpectral.spectTimes{ss};
                
                if bwupper <= 12
                    colorUse = [0.8 0 0 0.5];
                elseif bwupper >12 & bwupper < 30
                    colorUse = [0 0.8 0 0.5];
                elseif bwupper > 63 & bwupper < 67
                    colorUse = [0 0 0.8 0.5];
                elseif bwupper > 68
                    colorUse = [0 0.5 0.5 0.5];
                else
                    colorUse = [0 0 0 0.5];
                end
                hplt(fq) = plot(times,rescaledMvMean,'Color',colorUse,'LineWidth',3);
%                 set(gca, 'YScale', 'log')

            end
        end
        legend(hplt,lgnds);
        title(tblSide.(fieldnamesuse{fn}){1});
    end
    linkaxes(hsb,'x');
    
    % create ttl
    ttlUse = {};
    cntTtl = 1;
    dateUse  = tblSide.timeStart(1);
    dateUse.Format = 'dd-MMM-uuuu';
    % patient and date:
    ttlUse{cntTtl,1} = sprintf('%s %s %s', tblSide.patient{1},tblSide.side{1},dateUse);
    cntTtl = cntTtl + 1;
    % stim settings
    for t = 1:size(tblSide,1)
        dateUse  = tblSide.timeStart(t);
        dateUse.Format = 'HH:mm';
        ttlUse{cntTtl,1} = sprintf('%s:\t %s %.2fmA %.2fHz', dateUse,tblSide.electrodes{t},tblSide.amplitude_mA(t),tblSide.rate_Hz(t));
        cntTtl = cntTtl + 1;
    end
    sgtitle(ttlUse);
    fprintf('moving window is: %s\n',times(params.smooth)-times(1));
    
    hpanel.fontsize = 16;
    hpanel.margin = 12;
    hpanel.de.margin = 10;
    for i = 1:nrows-1
        hsb(i,1).XTick = [];
    end
    hsb(nrows,1).XTick = hsb(4,1).XLim(1):hours(2):hsb(4,1).XLim(2);
    datetick( hsb(nrows,1),'x','HH:MM','keeplimits','keepticks');
    
    %% print the figure
    hpanel.fontsize = 12;
    rootdir = prms.figdir;
    patname = spectralPatient(sn).tblSide.patient{1};
    side    = spectralPatient(sn).tblSide.side{1};
    patFigDir = fullfile(rootdir,patname);
    if ~exist(patFigDir,'dir')
        mkdir(patFigDir);
    end
    % figname
    [yyy,mmm,ddd] = ymd(spectralPatient(sn).tblSide.timeStart(1));
    figname = sprintf('%s_%s_%d_%0.2d_%0.2d_freq_spec',patname,side,yyy,mmm,ddd);
    prfig.plotwidth           = 16;
    prfig.plotheight          = 16*0.6;
    prfig.figdir              = patFigDir;
    prfig.figtype             = '-djpeg';
    prfig.closeafterprint     = 0;
    prfig.resolution          = 300;
    prfig.figname             = figname;
    plot_hfig(hfig,prfig);
    %%

end
end

function plot_stim_on_stim_off_comparisons_within_subject(params)
ff = findFilesBVQX(params.resdir,'*.mat');
tblOut = table(); 
for f = 1:length(ff)
    load(ff{f});
    if f == 1 
        tblOut = tblSaveOut;
    else
        tblOut = [tblOut; tblSaveOut]; 
    end
    clear tblSaveOut;
end

patients = {'RCS12','RCS08','RCS05','RCS02','RCS07'}; 

% get datesstring 
for d = 1:size(tblOut,1)
    tblOut.dateString{d} = sprintf('%s',tblOut.date(d));
    tblOut.stimOn = tblOut.stimOn > 0;
end

for p = 1%:length(patients)
    switch patients{p} 
        case 'RCS07'
            idxchoose = cellfun(@(x) strcmp(x,patients{p}),tblOut.patient) & ...
                        cellfun(@(x) strcmp(x,'+3-1'),tblOut.strChannelX) & ... 
                        cellfun(@(x) strcmp(x,'+10-8'),tblOut.strChannelY) & ... 
                        (cellfun(@(x) strcmp(x,'10-Oct-2019'),tblOut.dateString) | ...
                        cellfun(@(x) strcmp(x,'25-Jun-2020'),tblOut.dateString) );    
            tblPlot = tblOut(idxchoose,:);
        case 'RCS02'
            idxchoose = cellfun(@(x) strcmp(x,patients{p}),tblOut.patient) & ...
                cellfun(@(x) strcmp(x,'+3-1'),tblOut.strChannelX) & ...
                cellfun(@(x) strcmp(x,'+10-8'),tblOut.strChannelY);
            tblPlot = tblOut(idxchoose,:);
        case 'RCS05'
            idxchoose = cellfun(@(x) strcmp(x,patients{p}),tblOut.patient) & ...
                cellfun(@(x) strcmp(x,'+2-0'),tblOut.strChannelX) & ...
                cellfun(@(x) strcmp(x,'+10-8'),tblOut.strChannelY);
            tblPlot = tblOut(idxchoose,:);
        case 'RCS08'
            idxchoose = cellfun(@(x) strcmp(x,patients{p}),tblOut.patient) & ...
                cellfun(@(x) strcmp(x,'+3-1'),tblOut.strChannelX) & ...
                cellfun(@(x) strcmp(x,'+10-8'),tblOut.strChannelY);
            tblPlot = tblOut(idxchoose,:);
        case 'RCS12'
            idxchoose = cellfun(@(x) strcmp(x,patients{p}),tblOut.patient) & ...
                cellfun(@(x) strcmp(x,'+2-0'),tblOut.strChannelX) & ...
                cellfun(@(x) strcmp(x,'+11-10'),tblOut.strChannelY);
            tblPlot = tblOut(idxchoose,:);

    end
    %% set up panel 
    hsb = gobjects();
    hfig = figure;
    hfig.Color = 'w';
    hpanel = panel();
    hpanel.pack(2,2);
    hsbOut = gobjects();
    cntPanel = 1;
    %%
    % set panel order:
    for i = 1:2
        for j = 1:2
            hsbOut(cntPanel,1) = hpanel(i,j).select();
            cntPanel = cntPanel + 1;
        end
    end 
    %% loop on side and frequcny
    unqSides = unique(tblPlot.side);
    unqStim  = unique(tblPlot.stimOn);
    cntPanel = 1; 
    for s = 1:length(unqSides)
        for u = 1:length(unqStim)
            idxplot = cellfun(@(x) strcmp(x,unqSides{s}),tblPlot.side) & ...
                tblPlot.stimOn == unqStim(u);
            tblSbPlot = tblPlot(idxplot,:);
            % plot the correlation matrix  
            if ~isempty(tblSbPlot)
                hsb = hsbOut(cntPanel,1);
                axes(hsb);
                corrsDiff = tblSbPlot.corrsDiff{1};
%                 allCoors(:,:,cntPanel) = corrsDiff;
                allCoors{cntPanel} = corrsDiff;
                b = imagesc(corrsDiff');
                set(b,'AlphaData',~isnan(corrsDiff'))
                set(gca,'YDir','normal')
                cntRow = 1; sn = 1;
                hsb(sn,cntRow) = hsb;
                % xy labels
                xlabel(tblSbPlot.strChannelX{1});
                ylabel(tblSbPlot.strChannelY{1});
                % titletblSbPlot.ttlUseRec{1}
                ttlRaw = tblSbPlot.ttlUseRec{1};
                title(ttlRaw(1:2,1));
                
                
                
                hsb(sn,cntRow).YTick = tblSbPlot.ticksuse{1};
                hsb(sn,cntRow).YTickLabel = tblSbPlot.tickLabels{1};
                hsb(sn,cntRow).XTick = tblSbPlot.ticksuse{1};
                hsb(sn,cntRow).XTickLabel = tblSbPlot.tickLabels{1};
                axis tight;
                grid(hsb(sn,cntRow),'on');
                hsb(sn,cntRow).GridAlpha = 0.8;
                hsb(sn,cntRow).Layer = 'top';
            end
            cntPanel = cntPanel  +1;
        end
    end
    for i = 1:size(hsbOut,1)
        minVal = min(cellfun(@(x) min(min(x)),allCoors,'UniformOutput',true));
        maxVal = max(cellfun(@(x) max(max(x)),allCoors,'UniformOutput',true));
        caxis(hsbOut(i,1),[minVal maxVal]);
        colorbar(hsbOut(i,1));
    end
    %% adjust margins and plot 
    hpanel.de.margin = 30;
    hpanel.margintop = 20;
    hpanel.marginright = 20;
    % print figure
    hpanel.fontsize = 12;
    rootdir = params.figdir;
    patname = patients{p};
    patFigDir = fullfile(rootdir,patname);
    if ~exist(patFigDir,'dir')
        mkdir(patFigDir);
    end
    % figname
    figname = sprintf('%s_copmare_stim_on_off',patname);
    prfig.plotwidth           = 12*1.2;
    prfig.plotheight          = 12;
    prfig.figdir              = patFigDir;
    prfig.figtype             = '-djpeg';
    prfig.closeafterprint     = 0;
    prfig.resolution          = 300;
    prfig.figname             = figname;
    plot_hfig(hfig,prfig);

    
    %%
end

end

function plot_stim_on_stim_off_comparisons_across_subject(params)
ff = findFilesBVQX(params.resdir,'*.mat');
tblOut = table(); 
for f = 1:length(ff)
    load(ff{f});
    if f == 1 
        tblOut = tblSaveOut;
    else
        tblOut = [tblOut; tblSaveOut]; 
    end
    clear tblSaveOut;
end

patients = {'RCS12','RCS08','RCS05','RCS02','RCS07'}; 

% get datesstring 
for d = 1:size(tblOut,1)
    tblOut.dateString{d} = sprintf('%s',tblOut.date(d));
    tblOut.stimOn = tblOut.stimOn > 0;
end


%% set up panel
hsb = gobjects();
hfig = figure;
hfig.Color = 'w';
hpanel = panel();
hpanel.pack(2,length(patients));
hsbOut = gobjects();
cntPanel = 1;
%%
% set panel order:

for j = 1:length(patients)
    for i = 1:2
        hsbOut(cntPanel,1) = hpanel(i,j).select();
        cntPanel = cntPanel + 1;
    end
end
cntPanel = 1;


for p = 1:length(patients)
    switch patients{p} 
        case 'RCS07'
            idxchoose = cellfun(@(x) strcmp(x,patients{p}),tblOut.patient) & ...
                        cellfun(@(x) strcmp(x,'R'),tblOut.side) & ...
                        cellfun(@(x) strcmp(x,'+3-1'),tblOut.strChannelX) & ... 
                        cellfun(@(x) strcmp(x,'+10-8'),tblOut.strChannelY) & ... 
                        (cellfun(@(x) strcmp(x,'10-Oct-2019'),tblOut.dateString) | ...
                        cellfun(@(x) strcmp(x,'25-Jun-2020'),tblOut.dateString) );    
            tblPlot = tblOut(idxchoose,:);
        case 'RCS02'
            idxchoose = cellfun(@(x) strcmp(x,patients{p}),tblOut.patient) & ...
                cellfun(@(x) strcmp(x,'L'),tblOut.side) & ...
                cellfun(@(x) strcmp(x,'+3-1'),tblOut.strChannelX) & ...
                cellfun(@(x) strcmp(x,'+10-8'),tblOut.strChannelY);
            tblPlot = tblOut(idxchoose,:);
        case 'RCS05'
            idxchoose = cellfun(@(x) strcmp(x,patients{p}),tblOut.patient) & ...
                cellfun(@(x) strcmp(x,'R'),tblOut.side) & ...
                cellfun(@(x) strcmp(x,'+2-0'),tblOut.strChannelX) & ...
                cellfun(@(x) strcmp(x,'+10-8'),tblOut.strChannelY);
            tblPlot = tblOut(idxchoose,:);
        case 'RCS08'
            idxchoose = cellfun(@(x) strcmp(x,patients{p}),tblOut.patient) & ...
                cellfun(@(x) strcmp(x,'R'),tblOut.side) & ...
                cellfun(@(x) strcmp(x,'+3-1'),tblOut.strChannelX) & ...
                cellfun(@(x) strcmp(x,'+10-8'),tblOut.strChannelY);
            tblPlot = tblOut(idxchoose,:);
        case 'RCS12'
            idxchoose = cellfun(@(x) strcmp(x,patients{p}),tblOut.patient) & ...
                cellfun(@(x) strcmp(x,'L'),tblOut.side) & ...
                cellfun(@(x) strcmp(x,'+2-0'),tblOut.strChannelX) & ...
                cellfun(@(x) strcmp(x,'+11-10'),tblOut.strChannelY);
            tblPlot = tblOut(idxchoose,:);

    end
    %% loop on side and frequcny
    unqSides = unique(tblPlot.side);
    unqStim  = unique(tblPlot.stimOn);
    for s = 1:length(unqSides)
        for u = 1:length(unqStim)
            idxplot = cellfun(@(x) strcmp(x,unqSides{s}),tblPlot.side) & ...
                tblPlot.stimOn == unqStim(u);
            tblSbPlot = tblPlot(idxplot,:);
            % plot the correlation matrix  
            if ~isempty(tblSbPlot)
                hsb = hsbOut(cntPanel,1);
                axes(hsb);
                corrsDiff = tblSbPlot.corrsDiff{1};
%                 allCoors(:,:,cntPanel) = corrsDiff;
                allCoors{cntPanel} = corrsDiff;
                b = imagesc(corrsDiff');
                set(b,'AlphaData',~isnan(corrsDiff'))
                set(gca,'YDir','normal')
                cntRow = 1; sn = 1;
                hsb(sn,cntRow) = hsb;
                % xy labels
                xlabel(tblSbPlot.strChannelX{1});
                ylabel(tblSbPlot.strChannelY{1});
                % titletblSbPlot.ttlUseRec{1}
                ttlRaw = tblSbPlot.ttlUseRec{1};
                title(ttlRaw(1:2,1));
                
                
                
                hsb(sn,cntRow).YTick = tblSbPlot.ticksuse{1};
                hsb(sn,cntRow).YTickLabel = tblSbPlot.tickLabels{1};
                hsb(sn,cntRow).XTick = tblSbPlot.ticksuse{1};
                hsb(sn,cntRow).XTickLabel = tblSbPlot.tickLabels{1};
                axis tight;
                grid(hsb(sn,cntRow),'on');
                hsb(sn,cntRow).GridAlpha = 0.8;
                hsb(sn,cntRow).Layer = 'top';
            end
            cntPanel = cntPanel  +1;
        end
    end
    for i = 1:size(hsbOut,1)
        minVal = min(cellfun(@(x) min(min(x)),allCoors(end-1:end),'UniformOutput',true));
        maxVal = max(cellfun(@(x) max(max(x)),allCoors(end-1:end),'UniformOutput',true));
        caxis(hsbOut(i,1),[minVal maxVal]);
        colorbar(hsbOut(i,1));
    end


    
    %%
end

% for i = 1:size(hsbOut,1)
%     minVal = min(cellfun(@(x) min(min(x)),allCoors,'UniformOutput',true));
%     maxVal = max(cellfun(@(x) max(max(x)),allCoors,'UniformOutput',true));
%     caxis(hsbOut(i,1),[minVal maxVal]);
%     colorbar(hsbOut(i,1));
% end

%% adjust margins and plot
hpanel.de.margin = 25;
hpanel.margintop = 20;
hpanel.marginright = 20;
% print figure
hpanel.fontsize = 8;
rootdir = params.figdir;
patFigDir = fullfile(rootdir,'all');

%% figname
figname = 'copmare_stim_on_off_all_sep_colobar';
prfig.plotwidth           = 16;
prfig.plotheight          = 9;
prfig.figdir              = patFigDir;
prfig.figtype             = '-djpeg';
prfig.closeafterprint     = 0;
prfig.resolution          = 300;
prfig.figname             = figname;
plot_hfig(hfig,prfig);


end

function plot_stim_on_stim_off_comparisons_across_subject_same_freq(params)
ff = findFilesBVQX(params.resdir,'*.mat');
tblOut = table(); 
for f = 1:length(ff)
    load(ff{f});
    if f == 1 
        tblOut = tblSaveOut;
    else
        tblOut = [tblOut; tblSaveOut]; 
    end
    clear tblSaveOut;
end

patients = {'RCS12','RCS08','RCS05','RCS02','RCS07'}; 

% get datesstring 
for d = 1:size(tblOut,1)
    tblOut.dateString{d} = sprintf('%s',tblOut.date(d));
    tblOut.stimOn = tblOut.stimOn > 0;
end


%% set up panel
hsb = gobjects();
hfig = figure;
hfig.Color = 'w';
hpanel = panel();
hpanel.pack(2,length(patients));
hsbOut = gobjects();
cntPanel = 1;
%%
% set panel order:

for j = 1:length(patients)
    for i = 1:2
        hsbOut(cntPanel,1) = hpanel(i,j).select();
        cntPanel = cntPanel + 1;
    end
end
cntPanel = 1;


for p = 1:length(patients)
    switch patients{p} 
        case 'RCS07'
            idxchoose = cellfun(@(x) strcmp(x,patients{p}),tblOut.patient) & ...
                        cellfun(@(x) strcmp(x,'R'),tblOut.side) & ...
                        cellfun(@(x) strcmp(x,'+10-8'),tblOut.strChannelX) & ... 
                        cellfun(@(x) strcmp(x,'+10-8'),tblOut.strChannelY) & ... 
                        (cellfun(@(x) strcmp(x,'10-Oct-2019'),tblOut.dateString) | ...
                        cellfun(@(x) strcmp(x,'25-Jun-2020'),tblOut.dateString) );    
            tblPlot = tblOut(idxchoose,:);
        case 'RCS02'
            idxchoose = cellfun(@(x) strcmp(x,patients{p}),tblOut.patient) & ...
                cellfun(@(x) strcmp(x,'L'),tblOut.side) & ...
                cellfun(@(x) strcmp(x,'+10-8'),tblOut.strChannelX) & ...
                cellfun(@(x) strcmp(x,'+10-8'),tblOut.strChannelY);
            tblPlot = tblOut(idxchoose,:);
        case 'RCS05'
            idxchoose = cellfun(@(x) strcmp(x,patients{p}),tblOut.patient) & ...
                cellfun(@(x) strcmp(x,'R'),tblOut.side) & ...
                cellfun(@(x) strcmp(x,'+10-8'),tblOut.strChannelX) & ...
                cellfun(@(x) strcmp(x,'+10-8'),tblOut.strChannelY);
            tblPlot = tblOut(idxchoose,:);
        case 'RCS08'
            idxchoose = cellfun(@(x) strcmp(x,patients{p}),tblOut.patient) & ...
                cellfun(@(x) strcmp(x,'R'),tblOut.side) & ...
                cellfun(@(x) strcmp(x,'+10-8'),tblOut.strChannelX) & ...
                cellfun(@(x) strcmp(x,'+10-8'),tblOut.strChannelY);
            tblPlot = tblOut(idxchoose,:);
        case 'RCS12'
            idxchoose = cellfun(@(x) strcmp(x,patients{p}),tblOut.patient) & ...
                cellfun(@(x) strcmp(x,'L'),tblOut.side) & ...
                cellfun(@(x) strcmp(x,'+11-10'),tblOut.strChannelX) & ...
                cellfun(@(x) strcmp(x,'+11-10'),tblOut.strChannelY);
            tblPlot = tblOut(idxchoose,:);

    end
    %% loop on side and frequcny
    unqSides = unique(tblPlot.side);
    unqStim  = unique(tblPlot.stimOn);
    for s = 1:length(unqSides)
        for u = 1:length(unqStim)
            idxplot = cellfun(@(x) strcmp(x,unqSides{s}),tblPlot.side) & ...
                tblPlot.stimOn == unqStim(u);
            tblSbPlot = tblPlot(idxplot,:);
            % plot the correlation matrix  
            if ~isempty(tblSbPlot)
                hsb = hsbOut(cntPanel,1);
                axes(hsb);
                corrsDiff = tblSbPlot.corrsDiff{1};
%                 allCoors(:,:,cntPanel) = corrsDiff;
                allCoors{cntPanel} = corrsDiff;
                b = imagesc(corrsDiff');
                set(b,'AlphaData',~isnan(corrsDiff'))
                set(gca,'YDir','normal')
                cntRow = 1; sn = 1;
                hsb(sn,cntRow) = hsb;
                % xy labels
                xlabel(tblSbPlot.strChannelX{1});
                ylabel(tblSbPlot.strChannelY{1});
                % titletblSbPlot.ttlUseRec{1}
                ttlRaw = tblSbPlot.ttlUseRec{1};
                title(ttlRaw(1:2,1));
                
                
                
                hsb(sn,cntRow).YTick = tblSbPlot.ticksuse{1};
                hsb(sn,cntRow).YTickLabel = tblSbPlot.tickLabels{1};
                hsb(sn,cntRow).XTick = tblSbPlot.ticksuse{1};
                hsb(sn,cntRow).XTickLabel = tblSbPlot.tickLabels{1};
                axis tight;
                grid(hsb(sn,cntRow),'on');
                hsb(sn,cntRow).GridAlpha = 0.8;
                hsb(sn,cntRow).Layer = 'top';
            end
            cntPanel = cntPanel  +1;
        end
    end
    for i = 1:size(hsbOut,1)
        minVal = min(cellfun(@(x) min(min(x)),allCoors(end-1:end),'UniformOutput',true));
        maxVal = max(cellfun(@(x) max(max(x)),allCoors(end-1:end),'UniformOutput',true));
        caxis(hsbOut(i,1),[minVal maxVal]);
        colorbar(hsbOut(i,1));
    end


    
    %%
end

% for i = 1:size(hsbOut,1)
%     minVal = min(cellfun(@(x) min(min(x)),allCoors,'UniformOutput',true));
%     maxVal = max(cellfun(@(x) max(max(x)),allCoors,'UniformOutput',true));
%     caxis(hsbOut(i,1),[minVal maxVal]);
%     colorbar(hsbOut(i,1));
% end

%% adjust margins and plot
hpanel.de.margin = 25;
hpanel.margintop = 20;
hpanel.marginright = 20;
% print figure
hpanel.fontsize = 8;
rootdir = params.figdir;
patFigDir = fullfile(rootdir,'all');

%% figname
figname = 'copmare_stim_on_off_all_sep_colobar_same_freq_ctx';
prfig.plotwidth           = 16;
prfig.plotheight          = 9;
prfig.figdir              = patFigDir;
prfig.figtype             = '-djpeg';
prfig.closeafterprint     = 0;
prfig.resolution          = 300;
prfig.figname             = figname;
plot_hfig(hfig,prfig);


end


function find_ideal_smoothing_value_changes_per_day(spectralPatient,prms)
for sn = 1:length(spectralPatient)
    tblSide = spectralPatient(sn).tblSide;
    patAndSide = sprintf('%s%s',spectralPatient(sn).tblSide.patient{1},...
        spectralPatient(sn).tblSide.side{1});
    params = struct();
    switch patAndSide
        case 'RCS02L'
            if ~tblSide.stimulation_on(1)
                params.chan1 = [9 20 51 74 ]; % has some issue of interfernce
                params.chan2 = [8 20 48 76]; % has some issue of interfernce
                params.chan3 = [8 22 76];
                params.chan4 = [9 23 75];
                params.smooth = 0;
                params.bw = 3;
            end
        case 'RCS02R'
            if ~tblSide.stimulation_on(1)
                params.chan1 = [9 20 51 74 ]; % has some issue of interfernce
                params.chan2 = [8 20 48 76]; % has some issue of interfernce
                params.chan3 = [8 22 76];
                params.chan4 = [9 23 75];
                params.smooth = 1600;
                params.bw = 3;
            end

            if tblSide.stimulation_on(1)
                % after stim - jun 25 2020
                params.chan2 = [8 13 33 65];
                params.chan3 = [14 8 17 65];
                params.chan4 = [5 21 65];
                params.smooth = 1600;
                params.bw = 3;
                
            end


        case 'RCS08R'
            params.chan1 = [6, 23, 77];
            params.chan3 = [4 23 77];
            params.chan4 = [11 22 65 77];
            
            
        case 'RCS08L'
            params.chan3 = [11 23 64 ];
            params.chan4 = [11 22 32 65 ];
            
        case 'RCS07R'
            if ~tblSide.stimulation_on(1)
                % before stim - oct 10 2019
                params.chan1 = [5 16 32 54 79 ]; % has some issue of interfernce
                params.chan2 = [5 16 41 79]; % has some issue of interfernce
                params.chan3 = [10 82];
                params.chan4 = [10 17 83];
                params.smooth = 1600;
                params.bw = 3;
            end
            
            if tblSide.stimulation_on(1)
                % after stim - jun 25 2020
                params.chan2 = [8 13 33 65];
                params.chan3 = [14 8 17 65];
                params.chan4 = [5 21 65];
                params.smooth = 1600;
                params.bw = 3;
                
            end
        case 'RCS07L'
            if ~tblSide.stimulation_on(1)
                % before stim - oct 10 2019
                params.chan1 = [18]; % has some issue of interfernce
                params.chan2 = [5 8 19 82]; % has some issue of interfernce
                params.chan3 = [9 20 79 ];
                params.chan4 = [8 22 79];
                params.smooth = 1600;
                params.bw = 3;
            end
            if tblSide.stimulation_on(1)
                % after stim - jun 25 2020
                params.chan2 = [7 16 65]; % has some issue of interfernce
                params.chan3 = [10 19 65 ];
                params.chan4 = [5 65];
                params.smooth = 1600;
                params.bw = 3;
            end
        case 'RCS06R'
            if ~tblSide.stimulation_on(1)
                % before stim - oct 13 2019
                params.chan1 = [18]; % has some issue of interfernce
                params.chan2 = [5 8 19 82]; % has some issue of interfernce
                params.chan3 = [9 20 79 ];
                params.chan4 = [8 22 79];
                params.smooth = 1600;
                params.bw = 3;
            end
            if tblSide.stimulation_on(1)
                % after stim - jun 25 2020
                params.chan2 = [7 16 65]; % has some issue of interfernce
                params.chan3 = [10 19 65 ];
                params.chan4 = [5 65];
                params.smooth = 1600;
                params.bw = 3;
            end
        case 'RCS06L'
            
        otherwise
            
    end
    
    outSpectral = spectralPatient(sn).outSpectral;
    tblSide = spectralPatient(sn).tblSide;
    
    
    hsb  = gobjects();
    
    hfig = figure;
    hfig.Color = 'w';
    hpanel = panel();
    hpanel.pack('v',{0.1 0.9});
    nrows = length( fieldnames(params))-2;
    hpanel(2).pack(nrows,1);
    for n = 1:nrows
        hsb(n,1) = hpanel(2,n,1).select();
        hold on;
    end
    
    fieldnamesraw = fieldnames(params);
    idxfielnams = cellfun(@(x) any(strfind(x,'chan')),fieldnamesraw);
    fieldnamesuse = fieldnamesraw(idxfielnams);
    %% loop on channels and get everything into martix form 
    pppOutAll  = [];
    for c = 1:4
        pppOut = [];
        timesOut = [];
        for ss = 1:length(outSpectral.spectTimes)
            chanfn = sprintf('chan%d',c);
            ppp = outSpectral.(chanfn){ss};
            fff = outSpectral.fff{ss};
            idxFreqUse = fff >= 2 & fff <= 100;
            pppOut = [pppOut, ppp];
            timesOut = [timesOut,outSpectral.spectTimes{ss}];
        end
        idxFreqUse = fff >= 2 & fff <= 100;
        pppOutAll(:,:,c) = pppOut(idxFreqUse,~isnan(pppOut(1,:)));
        timesOutUse = timesOut(~isnan(pppOut(1,:)));
    end
    [yr,mn,dy] = ymd(timesOutUse(1));
    [~,~,allDays] = ymd(timesOutUse); 
    [h,~,~] = hms(timesOutUse);
    idxKeep = (dy == allDays) & (h <= 17 & h>=8);
    timesOutForPlot = timesOutUse(idxKeep);
    %% XXXXXX
    %% XXXXXX
    %% XXXXXX
    %% XXXXXX
    params.smooth = 50;
    cnls = [1 4];
    dateVecStart = datevec(timesOutUse(1)); % get the date 
    dateVecEnd = datevec(timesOutUse(1)); % get the date 
    dateVecStart(4) = 14; % start hours 
    dateVecStart(5) = 30; % start minutes 
    dateVecEnd(4) = 16; % end hours 
    dateVecEnd(5) = 30; % end minutes 
    startTime = datetime(dateVecStart,'TimeZone',timesOutUse.TimeZone);
    endTime = datetime(dateVecEnd,'TimeZone',timesOutUse.TimeZone);
    
    idxKeep = timesOutUse > startTime & timesOutUse < endTime;
    
    timesOutForPlot = timesOutUse(idxKeep);
    
    hfig = figure;
    
    hpanel = panel();
    hpanel.pack('h',{0.5 0.5});
    hpanel(1).pack(2,1);
    
    for cc = 1:length(cnls)
        c = cc; 
        hsb(cc,1) = hpanel(1,cc,1).select();
        
        chanfn = sprintf('chan%d',cnls(cc));
        pptOutDay = pppOutAll(:,idxKeep,cnls(c));
        IblurY2 = imgaussfilt(pptOutDay(:,:,1),[1 15]);
            him = imagesc(log10(IblurY2));
        
        pptOutDaySmooth = movmean(pptOutDay',[params.smooth 0],'omitnan');
        pptOutDaySmooth = pptOutDaySmooth';
        
        logVals = log10(pptOutDaySmooth);
        rescaleLog = rescale(pptOutDaySmooth,0 ,1);
        rescaleLog = zscore(pptOutDaySmooth');
        
        him = imagesc(rescaleLog');
        caxis([-2 2]);
        set(gca,'YDir','normal')
        yticks = [4 12 30 50 60 65 70 75 80 100];
        tickLabels = {};
        ticksuse = [];
        for yy = 1:length(yticks)
            [~,idx] = min(abs(yticks(yy)-fff));
            ticksuse(yy) = idx;
            tickLabels{yy} = sprintf('%d',yticks(yy));
        end
        hsb(c,1) = gca;
        hsb(c,1).YTick = ticksuse;
        hsb(c,1).YTickLabel = tickLabels;
        % get time labels for x tick
        colormap(hsb(c,1),'jet');
        shading interp
        grid('on')
        hsb(c,1).GridAlpha = 0.8;
        hsb(c,1).Layer = 'top';
        axis tight
        title(tblSide.(chanfn){ss});
        ylabel('Frequency (Hz)');
        xlims = [1 length(timesOutForPlot)];
        hsb(c,1).XTick = floor(linspace(xlims(1), xlims(2),20));
        xticks = hsb(c,1).XTick;
        
        xticklabels = {};
        for xx = 1:length(xticks)
            timeUseXtick = timesOutForPlot(xticks(xx));
            timeUseXtick.Format = 'HH:mm';
            xticklabels{xx,1} = sprintf('%s',timeUseXtick);
            timeUseXticksOut(xx) = timeUseXtick;
        end
        hsb(c,1).XTickLabel = xticklabels;
        hsb(c,1).XTickLabelRotation = 45;
    end
    
    
    
    
    
    
    
    yMvMean = movmean(pppOutAll(:,idxKeep,cnls(1))',[params.smooth 0],'omitnan');
    rescaledMvMean1 = zscore(yMvMean);
    
    yMvMean = movmean(pppOutAll(:,idxKeep,cnls(2))',[params.smooth 0],'omitnan');
    rescaledMvMean2 = zscore(yMvMean);

    
    %%% XXXX correlation 
    [corrs pvals] = corr(rescaledMvMean1,rescaledMvMean2,'type','Spearman');
    % [corrs pvals] = corrcoef(rescaledMvMean1,rescaledMvMean4);
    %     pvalsCorr = pvals < 0.05/length(pvals(:));
    corrsDiff = corrs;
    %     corrsDiff(corrs<0.6 & corrs>0 ) = NaN;
    %     corrsDiff(corrs<0 & corrs>-0.3 ) = NaN;
    
    % plotting
    hsb =    hpanel(2).select();
    
    axes(hsb);
    b = imagesc(corrsDiff');
    set(b,'AlphaData',~isnan(corrsDiff'))

    
    
    set(gca,'YDir','normal')
    cntRow = 1;
    hsb(sn,cntRow) = hsb;
    
    % get xlabel
    chanfn = sprintf('chan%d',cnls(1));
    chanfnraw = tblSide.(chanfn){1};
    idxcut = strfind(chanfnraw,'lpf');
    strChannelX = chanfnraw(1:idxcut-2);
    xlabel(strChannelX);
    
    % get ylabel
    chanfn = sprintf('chan%d',cnls(2));
    chanfnraw = tblSide.(chanfn){1};
    idxcut = strfind(chanfnraw,'lpf');
    strChannelY = chanfnraw(1:idxcut-2);
    ylabel(strChannelY);
    
    % title
    ttlUseSubPlot{1,1} = sprintf('%s %s', tblSide.patient{1},tblSide.side{1});
    title(ttlUseSubPlot);
    
    
    
    ticks = [4 12 30 50 60 65 70 75 80 100];
    
    
    set(gca,'YDir','normal')
    yticks = [4 12 30 50 60 65 70 75 80 100];
    tickLabels = {};
    ticksuse = [];
    for yy = 1:length(yticks)
        [~,idx] = min(abs(yticks(yy)-fff));
        ticksuse(yy) = idx;
        tickLabels{yy} = sprintf('%d',yticks(yy));
    end
    hsb(sn,cntRow).YTick = ticksuse;
    hsb(sn,cntRow).YTickLabel = tickLabels;
    hsb(sn,cntRow).XTick = ticksuse;
    hsb(sn,cntRow).XTickLabel = tickLabels;
    axis tight;
    %         axis square;
    grid(hsb(sn,cntRow),'on');
    hsb(sn,cntRow).GridAlpha = 0.8;
    hsb(sn,cntRow).Layer = 'top';
    
    
    
    % create ttl
    ttlUse = {};
    cntTtl = 1;
    dateUse  = tblSide.timeStart(1);
    dateUse.Format = 'dd-MMM-uuuu';
    % patient and date:
    ttlUse{cntTtl,1} = sprintf('%s %s %s', tblSide.patient{1},tblSide.side{1},dateUse);
    cntTtl = cntTtl + 1;
    % stim settings
    for t = 1:size(tblSide,1)
        dateUse  = tblSide.timeStart(t);
        dateUse.Format = 'HH:mm';
        ttlUse{cntTtl,1} = sprintf('%s:\t %s %.2fmA %.2fHz', dateUse,tblSide.electrodes{t},tblSide.amplitude_mA(t),tblSide.rate_Hz(t));
        cntTtl = cntTtl + 1;
    end
    hsb(sn,cntRow).Title.String =  ttlUse;
    
    
    
    
    
    
    % print the figure
    hpanel.de.margin = 20;
    hpanel.margintop = 20;
    hpanel.fontsize = 12;
    rootdir = prms.figdir;
    patname = spectralPatient(sn).tblSide.patient{1};
    side    = spectralPatient(sn).tblSide.side{1};
    patFigDir = fullfile(rootdir,patname);
    if ~exist(patFigDir,'dir')
        mkdir(patFigDir);
    end
    % figname
    startTime.Format = 'uuuu-MM-dd__HH-mm';
    endTime.Format = 'HH-mm';
    [yyy,mmm,ddd] = ymd(spectralPatient(sn).tblSide.timeStart(1));
    figname = sprintf('%s_%s_%s__%s__spectral_and_corre_diff_times_not_smoothed_20_no_caxis',patname,side,startTime,endTime);
    prfig.plotwidth           = 16;
    prfig.plotheight          = 16*0.6;
    prfig.figdir              = patFigDir;
    prfig.figtype             = '-djpeg';
    prfig.closeafterprint     = 0;
    prfig.resolution          = 300;
    prfig.figname             = figname;
    plot_hfig(hfig,prfig);
    %%




    %% plot 
    
    for fn = 1:length(fieldnamesuse) % loop on channels
        freqCenters = params.(fieldnamesuse{fn});
        lgnds = {};
        hplt = [];
        for fq = 1:length(freqCenters)
            lgnds{fq} = sprintf('%dHz',freqCenters(fq));
            % two loops - the first is to find the min/max for rescaling,
            % the second to plot
            yMvOut = [];
            for ss = 1:length(outSpectral.spectTimes)
                y = outSpectral.(fieldnamesuse{fn}){ss};
                fff = outSpectral.fff{ss};
                bwupper = freqCenters(fq) + params.bw;
                bwlower = freqCenters(fq) - params.bw;
                idxFreqUse = fff >= bwlower & fff <= bwupper;
                yFreqMean = mean(y(idxFreqUse,:),1);
                yMvMean = movmean(yFreqMean,[params.smooth 0],'omitnan');
                times = outSpectral.spectTimes{ss};
                yMvOut = [yMvOut,yMvMean];
                
            end
            minVal = min(yMvMean);
            maxVal = max(yMvMean);
            %             rescale(yMvMean,'InputMin',colmin,'InputMax',colmax)
            
            for ss = 1:length(outSpectral.spectTimes)
                
                axes(hsb(fn,1));
                y = outSpectral.(fieldnamesuse{fn}){ss};
                fff = outSpectral.fff{ss};
                bwupper = freqCenters(fq) + params.bw;
                bwlower = freqCenters(fq) - params.bw;
                idxFreqUse = fff >= bwlower & fff <= bwupper;
                yFreqMean = mean(y(idxFreqUse,:),1);
                yMvMean = movmean(yFreqMean,[params.smooth 0],'omitnan');
                rescaledMvMean = rescale(yMvMean,'InputMin',minVal,'InputMax',maxVal);
                rescaledMvMean =   (yFreqMean- nanmean(yFreqMean))/nanstd(yFreqMean);

                times = outSpectral.spectTimes{ss};
                
                if bwupper <= 12
                    colorUse = [0.8 0 0 0.5];
                elseif bwupper >12 & bwupper < 30
                    colorUse = [0 0.8 0 0.5];
                elseif bwupper > 63 & bwupper < 67
                    colorUse = [0 0 0.8 0.5];
                elseif bwupper > 68
                    colorUse = [0 0.5 0.5 0.5];
                else
                    colorUse = [0 0 0 0.5];
                end
                hplt(fq) = plot(times,rescaledMvMean,'Color',colorUse,'LineWidth',0.1);
%                 set(gca, 'YScale', 'log')

            end
        end
        legend(hplt,lgnds);
        title(tblSide.(fieldnamesuse{fn}){1});
    end
    linkaxes(hsb,'x');
    
    % create ttl
    ttlUse = {};
    cntTtl = 1;
    dateUse  = tblSide.timeStart(1);
    dateUse.Format = 'dd-MMM-uuuu';
    % patient and date:
    ttlUse{cntTtl,1} = sprintf('%s %s %s', tblSide.patient{1},tblSide.side{1},dateUse);
    cntTtl = cntTtl + 1;
    % stim settings
    for t = 1:size(tblSide,1)
        dateUse  = tblSide.timeStart(t);
        dateUse.Format = 'HH:mm';
        ttlUse{cntTtl,1} = sprintf('%s:\t %s %.2fmA %.2fHz', dateUse,tblSide.electrodes{t},tblSide.amplitude_mA(t),tblSide.rate_Hz(t));
        cntTtl = cntTtl + 1;
    end
    sgtitle(ttlUse);
    fprintf('moving window is: %s\n',times(params.smooth)-times(1));
    
    hpanel.fontsize = 16;
    hpanel.margin = 12;
    hpanel.de.margin = 10;
    for i = 1:3
        hsb(i,1).XTick = [];
    end
    hsb(4,1).XTick = hsb(4,1).XLim(1):hours(2):hsb(4,1).XLim(2);
    datetick( hsb(4,1),'x','HH:MM','keeplimits','keepticks');
    
    %% print the figure
    hpanel.fontsize = 12;
    rootdir = prms.figdir;
    patname = spectralPatient(sn).tblSide.patient{1};
    side    = spectralPatient(sn).tblSide.side{1};
    patFigDir = fullfile(rootdir,patname);
    if ~exist(patFigDir,'dir')
        mkdir(patFigDir);
    end
    % figname
    [yyy,mmm,ddd] = ymd(spectralPatient(sn).tblSide.timeStart(1));
    figname = sprintf('%s_%s_%d_%0.2d_%0.2d_freq_spec',patname,side,yyy,mmm,ddd);
    prfig.plotwidth           = 16;
    prfig.plotheight          = 16*0.6;
    prfig.figdir              = patFigDir;
    prfig.figtype             = '-djpeg';
    prfig.closeafterprint     = 0;
    prfig.resolution          = 300;
    prfig.figname             = figname;
    plot_hfig(hfig,prfig);
    %%

end
end


function plot_stim_on_stim_off_comparisons_psds(params,masterTable)
uniquePat = unique(masterTable.patient);
uniqueSid = unique(masterTable.side);
%%
clc;
for u = 1:length(uniquePat)
    for s = 1:length(uniqueSid)
        idxpat = strcmp(masterTable.patient,uniquePat{u});
        idxsad = strcmp(masterTable.side,uniqueSid{s});
        dbPat = masterTable(idxpat & idxsad,:);
        dbPatPrint = dbPat(:,{'patient','side', 'electrodes','chan1','chan2','stimulation_on'})
        fprintf('\n\n');
    end
end
%%
% set stim pairs / patients 
cnt = 1;
patChannel(cnt,1).Patient = 'RCS02';
patChannel(cnt,1).Side = 'L';
patChannel(cnt,1).stnChan = '+3-1';
patChannel(cnt,1).mcChan  = '+10-8';
cnt = cnt + 1; 

patChannel(cnt,1).Patient = 'RCS07';
patChannel(cnt,1).Side = 'R';
patChannel(cnt,1).stnChan = '+3-1';
patChannel(cnt,1).mcChan  = '+10-8';
cnt = cnt + 1; 

patChannel(cnt,1).Patient = 'RCS08';
patChannel(cnt,1).Side = 'R';
patChannel(cnt,1).stnChan = '+3-1';
patChannel(cnt,1).mcChan  = '+10-8';
cnt = cnt + 1; 

patChannel(cnt,1).Patient = 'RCS05';
patChannel(cnt,1).Side = 'R';
patChannel(cnt,1).stnChan = '+2-0';
patChannel(cnt,1).mcChan  = '+10-8';
cnt = cnt + 1; 

patChannel(cnt,1).Patient = 'RCS12';
patChannel(cnt,1).Side = 'R';
patChannel(cnt,1).stnChan = '+2-0';
patChannel(cnt,1).mcChan  = '+11-0';
cnt = cnt + 1; 
patSelections = struct2table(patChannel);

areas = {'stnChan','mcChan'};
%%
for u = 1:size(patSelections)
        idxpat = strcmp(masterTable.patient,patSelections.Patient{u});
        idxsad = strcmp(masterTable.side,patSelections.Side{u});
        dbPat = masterTable(idxpat & idxsad,:);
        %%
        hfig = figure;
        hfig.Color = 'w';
        hsb = gobjects();
        for a = 1:3
            hsb(a,1) = subplot(1,3,a);
            hold(hsb(a,1),'on');
        end
        for d = 1:size(dbPat,1)
            [pn,~] = fileparts(dbPat.deviceSettingsFn{d});
            rc = rcsPlotter();
            rc.addFolder(pn);
            rc.loadData();
            chansuse = [];
            chancnt = 1; 
            for a = 1:length(areas)
                fnser = patSelections.(areas{a}){u};
                notplot = 1;
                for c = 1:4 
                    fn = sprintf('chan%d',c);
                    if any(strfind(dbPat.(fn){d},fnser))
                        notplot = 0;
                        chansuse(chancnt) = c;
                        chancnt = chancnt + 1;
                        break; 
                    end
                end
                if ~notplot % verify that yo uhave found channel looking for 
                    if isfield(rc.Data,'stimLogSettings')
                        if rc.Data.stimLogSettings.therapyStatus(end) % stim on
                            colorUse = [0 0.8 0 0.2];
                        else
                            colorUse = [0.8 0 0 0.2];
                        end
                        try
                            rc.plotTdChannelPsd(str2num(fn(end)),minutes(2),hsb(a,1),colorUse);
                        end
                    end
                end
            end
            try 
                rc.plotTdChannelCoherence(chansuse,minutes(2),hsb(3,1),colorUse);
            end
            clear rc 
        end
        
        % make some plotting adjusttments 
        for a = 1:3
            xticks = [4 12 30 50 60 65 70 75 80 100];
            hsb(a,1).XTick = xticks;
            axis tight;
            
            grid(hsb(a,1),'on');
            hsb(a,1).GridAlpha = 0.8;
            hsb(a,1).Layer = 'top';
            hsb(a,1).XLim = [1 100];
        end
        figname = sprintf('%s%s_psd_and_coh_on_off_stim',patSelections.Patient{u},patSelections.Side{u});
        prfig.plotwidth           = 16;
        prfig.plotheight          = 9;
        prfig.figdir              = fullfile(params.figdir,'all');
        prfig.figtype             = '-djpeg';
        prfig.closeafterprint     = 0;
        prfig.resolution          = 300;
        prfig.figname             = figname;
        plot_hfig(hfig,prfig);
        %%
end

end

function plot_stim_on_stim_off_with_pkg_spectral(params,masterTableLightOut);
% get pkg data: 
sortedTbl = get_pkg_huge_data_table_two_minutes_data();

allDays = dateshift(sortedTbl.Date_Time,'start','day');
% print pkg days, per patient 

% set stim pairs / patients 
cnt = 1;
patChannel(cnt,1).Patient = 'RCS02';
patChannel(cnt,1).Side = 'L';
patChannel(cnt,1).stnChan = '+3-1';
patChannel(cnt,1).mcChan  = '+10-8';
patChannel(cnt,1).off_stim = datetime('28-May-2019 00:00:00');
patChannel(cnt,1).on_stim = datetime('12-Jun-2020 00:00:00');
patChannel(cnt,1).pkg_side = 'L'; % I know wrong but that is where Ih ave data 
cnt = cnt + 1; 

patChannel(cnt,1).Patient = 'RCS07';
patChannel(cnt,1).Side = 'R';
patChannel(cnt,1).stnChan = '+3-1';
patChannel(cnt,1).mcChan  = '+10-8';
patChannel(cnt,1).off_stim = datetime('10-Oct-2019 00:00:00');
patChannel(cnt,1).on_stim = datetime('25-Jun-2020 00:00:00');
patChannel(cnt,1).pkg_side = 'L';

cnt = cnt + 1; 

patChannel(cnt,1).Patient = 'RCS08';
patChannel(cnt,1).Side = 'R';
patChannel(cnt,1).stnChan = '+3-1';
patChannel(cnt,1).mcChan  = '+10-8';
patChannel(cnt,1).off_stim = datetime('04-Mar-2020 00:00:00');
patChannel(cnt,1).on_stim = datetime('23-Jun-2020 00:00:00');
patChannel(cnt,1).pkg_side = 'L';

cnt = cnt + 1; 

patChannel(cnt,1).Patient = 'RCS05';
patChannel(cnt,1).Side = 'R';
patChannel(cnt,1).stnChan = '+2-0';
patChannel(cnt,1).mcChan  = '+10-8';
patChannel(cnt,1).off_stim = datetime('25-Jul-2019 00:00:00');
patChannel(cnt,1).on_stim = datetime('16-Jun-2020 00:00:00');
patChannel(cnt,1).pkg_side = 'L';

% cnt = cnt + 1; 
% 
% patChannel(cnt,1).Patient = 'RCS12';
% patChannel(cnt,1).Side = 'R';
% patChannel(cnt,1).stnChan = '+2-0';
% patChannel(cnt,1).mcChan  = '+11-0';
% cnt = cnt + 1; 
patSelections = struct2table(patChannel);

masterTable = masterTableLightOut;
for u = 1:size(patSelections)
    idxpat = strcmp(masterTable.patient,patSelections.Patient{u});
    idxsad = strcmp(masterTable.side,patSelections.Side{u});
    
    dbPat = masterTable(idxpat & idxsad,:);
    dbPatPrint = dbPat(:,{'patient','side','timeStart','timeEnd', 'electrodes','chan1','chan2','stimulation_on'})
end

stim_conds = {'on_stim','off_stim'};
areas = {'stnChan','mcChan'};

for u = 1:size(patSelections)
    for sss = 1:length(stim_conds)
    idxpat = strcmp(masterTable.patient,patSelections.Patient{u});
    idxsad = strcmp(masterTable.side,patSelections.Side{u});
    allDaysNeural = dateshift(masterTable.timeStart,'start','day');
    dateNeuralLookFor = patChannel(u,1).(stim_conds{sss});
    dateNeuralLookFor.TimeZone = allDaysNeural.TimeZone;
    idxday = allDaysNeural == dateNeuralLookFor;
    
    dbPat = masterTable(idxpat & idxsad & idxday,:);
    
    %%
    hfig = figure;
    hfig.Color = 'w';
    hsb = gobjects();
    for a = 1:5
        hsb(a,1) = subplot(5,1,a);
        hold(hsb(a,1),'on');
    end
    for d = 1:size(dbPat,1)
        [pn,~] = fileparts(dbPat.deviceSettingsFn{d});
        rc = rcsPlotter();
        rc.addFolder(pn);
        rc.loadData();
        chansuse = [];
        chancnt = 1;
        for a = 1:length(areas)
            fnser = patSelections.(areas{a}){u};
            notplot = 1;
            for c = 1:4
                fn = sprintf('chan%d',c);
                if any(strfind(dbPat.(fn){d},fnser))
                    notplot = 0;
                    chansuse(chancnt) = c;
                    chancnt = chancnt + 1;
                    break;
                end
            end
            if ~notplot % verify that yo uhave found channel looking for
                if isfield(rc.Data,'stimLogSettings')
                    if rc.Data.stimLogSettings.therapyStatus(end) % stim on
                        colorUse = [0 0.8 0 0.2];
                    else
                        colorUse = [0.8 0 0 0.2];
                    end
                    try
                        rc.plotTdChannelSpectral(str2num(fn(end)),hsb(a,1))
                    end
                end
            end
        end
    end
    % fix the timing 
    for a = 1:2
        hax = hsb(a,1);
        timeStart = dateshift(datetime(datevec(hax.XLim(1))) ,'start','hour');
        timeEnd   = dateshift(datetime(datevec(hax.XLim(2))) ,'end','hour');
        if day(timeStart) ~= day(timeEnd)
            dateVecTimeStart = datevec(hax.XLim(1));
            dateVecTimeEnd = datevec(hax.XLim(2));
            dateVecTimeEnd(3) = dateVecTimeStart(3); 
            timeEnd = dateshift(datetime(dateVecTimeEnd) ,'end','day');
            timeEnd.Format = timeStart.Format;
        end
        xticks = datenum(timeStart : minutes(30) : timeEnd);
        hax.XTick = xticks;
        xlim(hax,datenum([timeStart timeEnd]));
%         axis(hax,'tight');
        datetick(hax,'x','HH:MM','keepticks','keeplimits');
    end
    % plot pkg
    % get table day 
    allDays.TimeZone = dateNeuralLookFor.TimeZone;
    idxday = allDays == dateNeuralLookFor;
    idxhand = strcmp(patSelections.pkg_side{u},sortedTbl.side);
    idxpatient = strcmp(patSelections.Patient{u},sortedTbl.patient);
    tblDay = sortedTbl(idxday & idxhand & idxpatient,:);

    % bk vals
    cla(hsb(3,1));
    axes(hsb(3,1));
    times = tblDay.Date_Time;
    dkvals = tblDay.DK;
    dkvals = log10(dkvals);
    bkvals = tblDay.BK;
    bkvals = abs(bkvals);
    trmvals = tblDay.Tremor_Score;
    hold on;
    mrksize = 20;
    alphause = 0.3;
    scatter(datenum(times),bkvals,mrksize,'filled','MarkerFaceColor',[0 0 0],'MarkerFaceAlpha',alphause);
    xlims = get(gca,'XLim');
    hp(2) = plot(xlims,[80 80],'LineWidth',2,'Color',[0.5 0.5 0.5],'LineStyle','-.');
    hp(2) = plot(xlims,[26 26],'LineWidth',2,'Color',[0.5 0.5 0.5],'LineStyle','-.');
    ylims = get(gca,'YLim');
    % plot dose times
    idxdose = ~isnat(tblDay.date_reminder);
    if sum(idxdose) >= 1
        reminderTimes = tblDay.date_reminder(idxdose);
        reminderDose  = tblDay.date_dose(idxdose);
        for rr = 1:length(reminderTimes)
            plot(datenum([reminderTimes(rr) reminderTimes(rr)]),ylims,'LineWidth',2,'Color',[0.5 0.7 0.5],'LineStyle','-.');
            plot(datenum([reminderDose(rr) reminderDose(rr)]),ylims,'LineWidth',2,'Color',[0.5 0.8 0.5],'LineStyle','-.');
        end
    end
    bkmovemean = movmean(bkvals,[5 5]);
    plot(datenum(times),bkmovemean,'LineWidth',4,'Color',[0 0 0 0.5]);
    
    hax = gca;
    ylabel(hax, 'bradykinesia score (a.u.)');
    set(gca,'FontSize',8);
    title(hax,'BK values'); 
    
    plottedDuration = datetime(datevec(hax.XLim(2))) - datetime(datevec(hax.XLim(1)));
    
    timeStart = dateshift(datetime(datevec(hax.XLim(1))) ,'start','hour');
    timeEnd   = dateshift(datetime(datevec(hax.XLim(2))) ,'end','hour');
    xticks = datenum(timeStart : minutes(30) : timeEnd);
    hax.XTick = xticks;
    datetick(hax,'x','HH:MM','keepticks','keeplimits');
    hax.XLim = hsb(2,1).XLim;

    

    
    % dk vals
    cla(hsb(4,1));
    axes(hsb(4,1));
    hax = hsb(4,1); 
    hold(hax,'on');
    scatter(datenum(times),dkvals,mrksize,'filled','MarkerFaceColor',[0 0.8 0],'MarkerFaceAlpha',alphause);
    
    dkmovemean = movmean(dkvals,[5 5]);
    plot(hsb(4,1),datenum(times),dkmovemean,'LineWidth',4,'Color',[0 0.8 0 0.5]);
    xlims = get(hsb(4,1),'XLim');
    
    hp(2) = plot(hsb(4,1),xlims,[log10(7) log10(7) ],'LineWidth',2,'Color',[0.5 0.5 0.5],'LineStyle','-.');
    hp(2) = plot(hsb(4,1),xlims,[log10(16) log10(16)],'LineWidth',2,'Color',[0.5 0.5 0.5],'LineStyle','-.');
    
    ylabel(hax,'dyskinesia score (a.u.)');
    set(hax,'FontSize',8);
    timeStart = dateshift(datetime(datevec(hax.XLim(1))) ,'start','hour');
    timeEnd   = dateshift(datetime(datevec(hax.XLim(2))) ,'end','hour');
    xticks = datenum(timeStart : minutes(30) : timeEnd);
    hax.XTick = xticks;
    datetick(hax,'x','HH:MM','keepticks','keeplimits');
    hax.XLim = hsb(2,1).XLim;
    title(hax,'DK values');

    
    
    % tremor values
    cla(hsb(5,1));
    axes(hsb(5,1));
    hax = hsb(5,1);
    hold(hax,'on');
    
    hold on;
    scatter(datenum(times),trmvals,mrksize,'filled','MarkerFaceColor',[0 0 0.8],'MarkerFaceAlpha',alphause);
    
    dkmovemean = movmean(trmvals,[5 5]);
    plot(datenum(times),dkmovemean,'LineWidth',4,'Color',[0 0 0.8 0.5]);
    
    ylabel(hax,'tremor score (a.u.)');
    timeStart = dateshift(datetime(datevec(hax.XLim(1))) ,'start','hour');
    timeEnd   = dateshift(datetime(datevec(hax.XLim(2))) ,'end','hour');
    xticks = datenum(timeStart : minutes(30) : timeEnd);
    hax.XTick = xticks;
    datetick(hax,'x','HH:MM','keepticks','keeplimits');
    hax.XLim = hsb(2,1).XLim;
    title(hax,'tremor values');


    % make large title 
    dateNeuralLookFor = patChannel(u,1).(stim_conds{sss});
    ttluse{1,1} = sprintf('%s %s %s',patSelections.Patient{u},patSelections.Side{u},dateNeuralLookFor);
    stimSettings = rc.Data.stimLogSettings;
    if rc.Data.stimLogSettings.therapyStatus(end)
        ttluse{2,1} = rc.Data.stimLogSettings.stimParams_prog1{end};
    else
        ttluse{2,1} = 'stim off';
    end
    
    sgtitle(ttluse);
    for a = 1:5
        hax = hsb(a,1); 
        set(hax,'FontSize',10);
    end
    
    linkaxes(hsb,'x');
    figname = sprintf('%s_pkg_data_spectral_data',   ttluse{1,1});
    prfig.plotwidth           = 16*1.8;
    prfig.plotheight          = 9*1.8;
    prfig.figdir              = fullfile(params.figdir,'all');
    prfig.figtype             = '-djpeg';
    prfig.closeafterprint     = 0;
    prfig.resolution          = 300;
    prfig.figname             = figname;
    plot_hfig(hfig,prfig);

    end
    
end
        
                   
            

end

function pkgHugeTable = get_pkg_huge_data_table_two_minutes_data()
%% plot one day example of PKG data / patient
rootdir = '/Users/roee/Box/RC-S_Studies_Regulatory_and_Data/pkg_data';
savedir = fullfile(rootdir,'results','processed_data');
load(fullfile(savedir,'pkgDataBaseProcessed.mat'),'pkgDB');

uniqePatients = unique(pkgDB.patient);
uniqeSides    = unique(pkgDB.side);
close all;
clc;

%% % agregate all pkg data into one big table


pkgHugeTable = table();
for p  = 1:size(pkgDB,1)
    ff = findFilesBVQX( savedir, pkgDB.savefn{p}) ;
    load(ff{1});
    nrows = size(pkgTable,1);
    pkgTable.patient =  repmat(pkgDB.patient(p),nrows,1);
    pkgTable.date_details =  repmat(pkgDB.date_details(p),nrows,1);
    pkgTable.side =  repmat(pkgDB.side(p),nrows,1);
    pkgTable.timerange =  repmat(pkgDB.timerange(p,:),nrows,1);
    % add the dose information to the table
    for d = 1:size(doseTable)
        if ~isnan( doseTable.Dose(d))
            idxday = pkgTable.Day == doseTable.Day(d);
            if sum(idxday) > 1
                dayDates = pkgTable.Date_Time(idxday,:);
                yearUse = year(dayDates(1));
                monthUse = month(dayDates(1));
                dayUse = day(dayDates(1));
                [hourUse,minUse,secUse] = hms(doseTable.Reminder(d));
                dateReminder = datetime( sprintf('%d/%0.2d/%0.2d %0.2d:%0.2d:%0.2d',...
                    yearUse,monthUse,dayUse,hourUse,minUse,secUse),...
                    'Format','yyyy/MM/dd HH:mm:ss');
                
                [hourUse,minUse,secUse] = hms(doseTable.Dose(d));
                dateDose = datetime( sprintf('%d/%0.2d/%0.2d %0.2d:%0.2d:%0.2d',...
                    yearUse,monthUse,dayUse,hourUse,minUse,secUse),...
                    'Format','yyyy/MM/dd HH:mm:ss');
                [value,idx] = min(abs(dateDose-pkgTable.Date_Time));
                pkgTable.date_dose(idx) = dateDose;
                pkgTable.date_reminder(idx) = dateReminder;
            end
        end
    end
    if ~isfield(pkgTable,'date_dose') % in cased dose data doesn't exist for this subject
        pkgTable.date_dose(1) = NaT;
        pkgTable.date_reminder(1) = NaT;
    end
    
    if p == 1
        pkgHugeTable = pkgTable;
        clear pkgTable;
    else
        pkgHugeTable = [pkgHugeTable  ; pkgTable];
        clear pkgTable;
    end
end
% if you get a dyskinesia value that is 0 - and you log that
% you get -inf to fix this - change all dyskinesia values that are 0 to a 1
% so that you get a zero when you log it.
idxzero = pkgHugeTable.DK == 0;
pkgHugeTable.DK(idxzero) = 1;


sortedTbl = sortrows(pkgDB,{'patient','side','pkg_identifier','timerange'});

end

