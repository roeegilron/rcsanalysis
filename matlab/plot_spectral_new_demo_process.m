function plot_spectral_new_demo_process(pn)
%% load data 
start = tic;
[combinedDataTable, debugTable, timeDomainSettings,powerSettings,...
    fftSettings,metaData,stimSettingsOut,stimMetaData,stimLogSettings,...
    DetectorSettings,AdaptiveStimSettings,AdaptiveRuns_StimSettings] = DEMO_ProcessRCS(pn,2);
timeToLoad = toc(start);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%% load time domain
idxuse = logical(ones(size(combinedDataTable,1),1));
dataOutFilled = [];
for c = 1:4 % loop on channels
    chanfn = sprintf('TD_key%d',c-1);
    sr = timeDomainSettings.samplingRate(1); % assumes no change in session
    chunkUse = combinedDataTable.(chanfn)(idxuse);
    y = chunkUse - nanmean(chunkUse);
    y = y.*1e3;
    % first make sure that y does'nt have NaN's at start or
    % end which makes finding gaps easier 
    timeUseRaw = combinedDataTable.localTime;
    % check start:
    
    cntNan = 1;
    if isnan(y(1))
        while isnan(y(cntNan))
            cntNan = cntNan + 1;
        end
    end
    y = y(cntNan:end);
    cntStart = cntNan;
    timeUseRaw = timeUseRaw(cntNan:end);
    % check end:
    cntNan = length(y);
    if isnan(y(cntNan))
        while isnan(y(cntNan))
            cntNan = cntNan - 1;
        end
    end
    cntEnd = cntNan;
    y = y(1:cntEnd);
    timeUseNoNans = timeUseRaw(1:cntEnd);
    % fill the NaN's with zeros 
    yFilled = fillmissing(y,'constant',0);
    dataOutFilled(:,c) = yFilled;
end
%% compute spectrogram 
% set params. 
params.windowSize     = 1024;  % spect window size 
params.windowOverlap  = ceil(1024*0.875);   % spect window overalp (points) 
params.paddingGap     = seconds(1); % padding to add to window spec
params.windowUse       = 'kaiser'; % blackmanharris \ kaiser \ hann

outSpectral = struct();
for i = 1:4 
    % blank should be bigger than window on each side 
    windowInSec = seconds(256/sr);
    switch params.windowUse
        case 'kaiser'
            windowUse = kaiser(params.windowSize,2);
        case 'blackmanharris'
            windowUse = blackmanharris(params.windowSize); 
        case 'hann'
            L = params.windowSize; 
            windowUse = 0.5*(1-cos(2*pi*(0:L-1)/(L-1)));
%             hann(params.windowSize); 
    end
    
    [sss,fff,ttt,ppp] = spectrogram(dataOutFilled(:,i),...
                                    windowUse,...
                                    params.windowOverlap,...
                                    256,sr,'yaxis');
    % put nan's in gaps for spectral
    spectTimes = timeUseNoNans(1) + seconds(ttt);
    
    idxGapStart = find(diff(isnan(y))==1) + 1;
    idxGapEnd = find(diff(isnan(y))==-1) + 1;
    for te = 1:size(idxGapStart,1)
        timeGap(te,1) = timeUseNoNans(idxGapStart(te)) - (windowInSec + params.paddingGap);
        timeGap(te,2) = timeUseNoNans(idxGapEnd(te))   + (windowInSec + params.paddingGap);
        idxBlank = spectTimes >= timeGap(te,1) & spectTimes <= timeGap(te,2);
        ppp(:,idxBlank) = NaN;
    end
    if i == 1
        fnchan = sprintf('chan%d',i);
        outSpectral.spectTimes = spectTimes;
        outSpectral.fff = fff;
    end
    chanfn = sprintf('chan%d',i);
    outSpectral.(chanfn) = ppp';
    outSpectral.fff = fff;
end
%%
% plot spectrogram with different values of NaN
% plotting params 
params.removeGaps     = 0; % if 1 remove gaps, otherwise, keep gaps 
params.guassianFit    = 1; % fit a guassian to image for smoothing 
params.zScore         = 0; % zscore each frequecny 
params.smooth         = 50;    % smoothing (in points in "spect" domain") 
params.cnls           = [1 2 ]; 
params.plotTD         = 1; % plot time domain
params.limitTo100Hz   = 1; 

if params.plotTD == 1 
    nrows = length(params.cnls)*2; 
else
    nrows = length(params.cnls);  
end
close all; 
hfig = figure;
hfig.Color = 'w'; 
hpanel = panel();
hpanel.pack(nrows,1); 

cntplt = 1; 
for cc = 1:length(params.cnls)
    c = cntplt; 
    
    timesOutSpectral = outSpectral.spectTimes;

        
    % plot time domain
    if params.plotTD
        hsb(cntplt,1) = hpanel(cntplt,1).select();
        y = dataOutFilled(:,params.cnls(cc));
        x = timeUseNoNans;
        plot(linspace(1,length(timesOutSpectral),length(x)) ,y,'Parent',hsb(cntplt,1));
        
        
        
        xlims = [1 length(timesOutSpectral)];
        hsb(c,1).XTick = floor(linspace(xlims(1), xlims(2),20));
        xticks = hsb(c,1).XTick;
        
        xticklabels = {};
        for xx = 1:length(xticks)
            timeUseXtick = timeUseNoNans(xticks(xx));
            timeUseXtick.Format = 'HH:mm';
            xticklabels{xx,1} = sprintf('%s',timeUseXtick);
            timeUseXticksOut(xx) = timeUseXtick;
        end
        hsb(c,1).XTickLabel = xticklabels;
        hsb(c,1).XTickLabelRotation = 45;
        title(hsb(c,1), timeDomainSettings.(cnhafn));
        cntplt = cntplt + 1;
    end
    
    c = cntplt; 
    % plot spdctral 
    hsb(cntplt,1) = hpanel(cntplt,1).select();
    cntplt = cntplt + 1;
    timesOutForPlot = outSpectral.spectTimes;
    
    cnhafn = sprintf('chan%d',params.cnls(cc));
    pptOutDay = outSpectral.(cnhafn);
    
    if params.limitTo100Hz
        x = 2;
        idxlimit = fff > 0 & fff <= 100;
        fff = fff(idxlimit); 
        pptOutDay = pptOutDay(:,idxlimit);
    end
    
    if params.removeGaps
        idxnan = isnan(pptOutDay(:,1));
        pptOutDay = pptOutDay(~idxnan,:); 
        timesOutForPlot = timesOutForPlot(~idxnan);
    end
    if params.guassianFit% previous way of doing this - with just gaussing bluring
        IblurY2 = imgaussfilt(pptOutDay,[1 15]);
        him = imagesc(log10(IblurY2'));
    end
    % smooth data - with trailingedge 
%     pptOutDaySmooth = movmean(pptOutDay,[params.smooth 0],'omitnan');
%     pptOutDaySmooth = pptOutDaySmooth';
    
    if params.zScore
        % implement zscore to be robost to nan's: 
        P = pptOutDay; 
        P = movmean(P,[params.smooth 0],'omitnan');
        P = movmean(P,[params.smooth 0]);
        
        meanMatrix = repmat(nanmean(P,1),size(P,1),1);
        stdMatrx   = repmat(nanstd(P,1),size(P,1),1);
        zScoreData = (P - meanMatrix) ./ stdMatrx;
        
        % identify gaps before smoothing 
        imAlpha=ones(size(P'));
        imAlpha(isnan(P'))=0;

%         zScoreData = movmean(zScoreData,[params.smooth 0],'omitnan');
        
        
        imagesc(zScoreData','AlphaData',imAlpha);
        
        caxis([-2 2]);
    end
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
    title(hsb(c,1), timeDomainSettings.(cnhafn));
end

linkaxes(hsb,'x');




end