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
close all; 

%% 

%% find specific patients, and for each of these patietns, specific sides and days 
% the output strucutre is such: 
% where each side of 'spectralPatient' is one side 
% and within spectral patietn itself - you have unique days. 

% spectralPatient(s).outSpectral = outSpectral;
% spectralPatient(s).tblSide = tblSide;

unqPatients = unique(masterTableLightOut.patient);
% unqPatients = unqPatients(5); % XXXX 
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
          plot_smoothed_changes_per_day(spectralPatient,params);
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
hsb = gobjects();
hfig = figure; 
hfig.Color = 'w';
hpanel = panel();
hpanel.pack('v',{0.1 0.9});
hpanel(2).pack(1,2);
hsb = gobjects();
params.smooth = 1500;
for sn = 1:length(spectralPatient)
    outSpectral = spectralPatient(sn).outSpectral;
    tblSide = spectralPatient(sn).tblSide;
    hsb = hpanel(2,1,sn).select();
    axes(hsb); 

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
    idxKeep = (dy == allDays) & h < 17; 
    timesOutForPlot = timesOutUse(idxKeep);
    
    
    yMvMean = movmean(pppOutAll(:,idxKeep,1)',[params.smooth 0],'omitnan');
    yMvMean = yMvMean(600:end,:);
    colmin = min(yMvMean);
    colmax = max(yMvMean);
    rescaledMvMean1 = rescale(yMvMean,'InputMin',colmin,'InputMax',colmax);
    rescaledMvMean1 = rescaledMvMean1;
    
    yMvMean = movmean(pppOutAll(:,idxKeep,4)',[params.smooth 0],'omitnan');
    yMvMean = yMvMean(600:end,:);
    colmin = min(yMvMean);
    colmax = max(yMvMean);
    rescaledMvMean4 = rescale(yMvMean,'InputMin',colmin,'InputMax',colmax);
    rescaledMvMean4 = rescaledMvMean4;
    
    
    [corrs pvals] = corr(rescaledMvMean1,rescaledMvMean4,'type','Spearman');
    % [corrs pvals] = corrcoef(rescaledMvMean1,rescaledMvMean4);
    % pvalsCorr = pvals < 0.05/length(pvals(:));
    corrsDiff = corrs;
%     corrsDiff(corrs<0.6 & corrs>0 ) = NaN;
%     corrsDiff(corrs<0 & corrs>-0.3 ) = NaN;
    b = imagesc(corrsDiff');
    set(b,'AlphaData',~isnan(corrsDiff'))
    
    colorbar;
    set(gca,'YDir','normal')
    hsb(sn,1) = hsb;
    xlabel('STN freqs');
    ylabel('MC freqs');
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
    hsb(sn,1).YTick = ticksuse;
    hsb(sn,1).YTickLabel = tickLabels;
    hsb(sn,1).XTick = ticksuse;
    hsb(sn,1).XTickLabel = tickLabels;

    
    title('STN - MC amp correlations');
    set(gca,'FontSize',16);
    
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
    title(ttlUse);
    axis tight; 
    colorbar off; 
    grid(hsb(sn,1),'on');
    hsb(sn,1).GridAlpha = 0.8;
    hsb(sn,1).Layer = 'top';

    

end
hpanel.fontsize = 16;

%% print figure 
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
figname = sprintf('%s_%s_%d_%0.2d_%0.2d_cross_amp_corr',patname,side,yyy,mmm,ddd);
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
                params.smooth = 1600;
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
                hplt(fq) = plot(times,rescaledMvMean,'Color',colorUse,'LineWidth',2);
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