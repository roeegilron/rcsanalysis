function plot_spectral_daily_average()
addpath(genpath(fullfile(pwd,'toolboxes','panel-2.14')));
close all; clc; clear all;
addpath(genpath('/Users/roee/Documents/Code/Analysis-rcs-data/code'));


% set destination folders
dropboxFolder = findFilesBVQX('/Users','Starr Lab Dropbox',struct('dirs',1,'depth',2));
if length(dropboxFolder) == 1
    dirname  = fullfile(dropboxFolder{1}, 'RC+S Patient Un-Synced Data');
    rootdir = fullfile(dirname,'database');
else
    error('can not find dropbox folder, you may be on a pc');
end

% set box folder with current analysis code


load(fullfile(rootdir,'database_from_device_settings.mat'),'masterTableLightOut');

masterTableOut = masterTableLightOut;

idxkeep = cellfun(@(x) any(strfind(x,'RCS')), masterTableOut.patient);
tblall =  masterTableOut(idxkeep,:);

unqpatients = unique(tblall.patient);
plotwhat = input('choose patient and side (1) or plot all(2)? ');
if plotwhat == 1 % choose patients and sidet
    fprintf('choose patient by idx\n');
    unqpatients = unique(tblall.patient);
    for uu = 1:length(unqpatients)
        fprintf('[%0.2d] %s\n',uu,unqpatients{uu})
    end
    patidx = input('patientidx ?');
end
idxPatient = strcmp(tblall.patient , unqpatients(patidx));
tblPatient = tblall(idxPatient,:);



% choose year
[y,m,d] = ymd(tblPatient.timeStart);
uniqueYears = unique(y);
for yy = 1:length(uniqueYears)
    fprintf('[%0.2d] %d\n',yy,uniqueYears(yy))
end
yearidx = input('year idx ?');
tblPatient = tblPatient(y == uniqueYears(yearidx),:);

% choose month
[y,m,d] = ymd(tblPatient.timeStart);
uniqueMonths = unique(m);
for mm = 1:length(uniqueMonths)
    fprintf('[%0.2d] %d\n',mm,uniqueMonths(mm))
end
monthidx = input('month idx?');
tblPatient = tblPatient(m == uniqueMonths(monthidx),:);

% choose day
[y,m,d] = ymd(tblPatient.timeStart);
uniqueDays = unique(d);
for dd = 1:length(uniqueDays)
    fprintf('[%0.2d] %d\n',dd,uniqueDays(dd))
end
dayidx = input('day idx?');
tblPatient = tblPatient(d == uniqueDays(dayidx),:);
tblPatient.duration.Format = 'hh:mm:ss';

idxLonger = tblPatient.duration > minutes(20);

if sum(idxLonger) == 0
    warning('no session is longer than 20 minutes, exiting for this day\n');
    fprintf('no session is longer than 20 minutes, exiting for this day\n');
    return;
end
tblPatient = tblPatient(idxLonger,:);



plotSpectral = 1; % with the blanks
% loop on sides
uniqueSides = unique(tblPatient.side);

spectralPatient = struct();
if plotSpectral == 1 % plot all power bands
    for s = 1:length(uniqueSides)
        idxSide = strcmp(tblPatient.side,uniqueSides{s});
        tblSide = tblPatient(idxSide,:);
        outSpectral = table();
        if ~isempty(tblSide)
            %% plot
            hfig = figure;
            hfig.Color = 'w';
            hpanel = panel();
            hpanel.pack('v',{0.1 0.9});
            hpanel(2).pack('h',{0.1 0.9});
            hpanel(2,2).pack(5,1);
            %             hpanel.select('all');
            %             hpanel.identify();
            %
            sgtitle('place holder');
            cntTtl = 1;
            for ss = 1:size(tblSide,1)
                if tblSide.timeDomainStreaming(ss)
                    [pn,fn] = fileparts(tblSide.deviceSettingsFn{ss});
                    % if the data exists - just load it
                    filenameSaveOrLoad = fullfile(pn,'combinedDataTable.mat');
                    isFile = exist(filenameSaveOrLoad,'file');
                    skipPlot = 0; % skip all the load if you have done computation already
                    if isFile
                        fileMeta = memmapfile(filenameSaveOrLoad);
                        variableInfo = who('-file', filenameSaveOrLoad);
                        if sum(cellfun(@(x) any(strfind(x,'outSpectral')),variableInfo))>0
                            load(filenameSaveOrLoad,'outSpectral');
                            skipPlot = 1;
                        end
                    end
                    
                    if ~skipPlot
                        
                        
                        
                        %                  [outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerOut,adaptiveTable] =  MAIN_load_rcs_data_from_folder(pn);
                        eventFn = fullfile(pn,'EventLog.json');
                        eventTable  = loadEventLog(eventFn);
                        idxRemove = cellfun(@(x) any(strfind(x,'Application Version')),eventTable.EventType) | ...
                            cellfun(@(x) any(strfind(x,'BatteryLevel')),eventTable.EventType) | ...
                            cellfun(@(x) any(strfind(x,'LeadLocation')),eventTable.EventType);
                        eventTableUse = eventTable(~idxRemove,:);
                        [combinedDataTable, debugTable, timeDomainSettings,powerSettings,...
                            fftSettings,metaData,stimSettingsOut,stimMetaData,stimLogSettings,...
                            DetectorSettings,AdaptiveStimSettings,AdaptiveRuns_StimSettings] = DEMO_ProcessRCS(pn,2);
                        
                        
                        ts = datetime(combinedDataTable.DerivedTime/1000,...
                            'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
                        combinedDataTable.DerivedTimeHuman = ts;
                        
                        
                        timeUse = ts;
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        
                        
                        
                        %% plot time domain
                        idxuse = logical(ones(size(combinedDataTable,1),1));
                        for c = 1:4 % loop on channels
                            hsb(c,1) = hpanel(2,2,c,1).select();
                            hold on;
                            chanfn = sprintf('TD_key%d',c-1);
                            sr = timeDomainSettings.samplingRate(1); % assumes no change in session
                            chunkUse = combinedDataTable.(chanfn)(idxuse);
                            y = chunkUse - nanmean(chunkUse);
                            y = y.*1e3;
                            % first make sure that y does'nt have NaN's at start or
                            % end
                            timeUseRaw = timeUse;
                            
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
                            
                            yFilled = fillmissing(y,'constant',0);
                            [sss,fff,ttt,ppp] = spectrogram(yFilled,kaiser(256,5),64,512,sr,'yaxis');
                            % put nan's in gaps for spectral
                            spectTimes = timeUseNoNans(1) + seconds(ttt);
                            
                            idxGapStart = find(diff(isnan(y))==1) + 1;
                            idxGapEnd = find(diff(isnan(y))==-1) + 1;
                            for te = 1:size(idxGapStart,1)
                                timeGap(te,1) = timeUseNoNans(idxGapStart(te)) - seconds(0.2);
                                timeGap(te,2) = timeUseNoNans(idxGapEnd(te)) + seconds(0.2);
                                idxBlank = spectTimes >= timeGap(te,1) & spectTimes <= timeGap(te,2);
                                ppp(:,idxBlank) = NaN;
                            end
                            
                            spectTimesPcolor = seconds(spectTimes - spectTimes(1));
                            axes(hsb(c,1));
                            
                            %%
                            
                            %%
                            % use pcolor
                            idxFreqUse = fff >= 2 & fff <= 100;
                            %                     pcolor(datenum(spectTimes), fff(idxFreqUse) ,log10(ppp(idxFreqUse,:)));
                            colormap('jet')
                            shading('interp');
                            
                            
                            
                            
                            axis(hsb(c,1),'tight');
                            fnchan = sprintf('chan%d',c);
                            title(hsb(c,1),timeDomainSettings.(fnchan){1});
                            outSpectral.spectTimes{ss} = spectTimes;
                            outSpectral.fff{ss} = fff;
                            chanfn = sprintf('chan%d',c);
                            outSpectral.(chanfn){ss} = ppp;
                        end
                        %%
                        %% plot coherence
                        yOut = [];
                        idxuse = logical(ones(size(combinedDataTable,1),1));
                        for c = 1:4
                            timeUseRaw = timeUse;
                            chanfn = sprintf('TD_key%d',c-1);
                            sr = timeDomainSettings.samplingRate(1); % assumes no change in session
                            chunkUse = combinedDataTable.(chanfn)(idxuse);
                            y = chunkUse - nanmean(chunkUse);
                            y = y.*1e3;
                            
                            
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
                            
                            yFilled = fillmissing(y,'constant',0);
                            yOut(:,c) = yFilled;
                        end
                        %%
                        %% plot some coherence data.
                        
                        %%
                        
                        
                        % actually quite hard to do...
                        %{
                figure;
                idxuse = 8016:8016+1e5;
                idxuse = 1:1+1e5;
                wcoherence(yOut(idxuse,1),yOut(idxuse,4),sr,'numscales',25);
                
                                
                yTall = tall([yOut(idxuse,1),yOut(idxuse,4)]);
                fcn = @(x) median(x,1,'omitnan');
                tA = matlab.tall.movingWindow(fcn,5000,yTall);
                tOut = gather(tA);
                
                [wcoh,tm,P,coi] = wcoherence(yOut(1:1e4,1),yOut(1:1e4,4),sr,...
                    'numscales',16);
                figure;
                helperPlotCoherence(wcoh,tm,seconds(P),seconds(coi),'Time (secs)','Periods (Seconds)');
                % and maybe other problems with actually doing this...
                https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0146443
                        %}
                        
                        
                        %% plot rms of actigraphy
                        accAxes = {'X','Y','Z'};
                        accIdxKeep = ~isnan(combinedDataTable.Accel_XSamples);
                        accTable = combinedDataTable(accIdxKeep,{'DerivedTimeHuman','Accel_XSamples','Accel_YSamples','Accel_ZSamples'});
                        yAvg = [];
                        for ac = 1:length(accAxes)
                            fnUse = sprintf('Accel_%sSamples',accAxes{ac});
                            yDat = accTable.(fnUse);
                            uxtimesPower = accTable.DerivedTimeHuman;
                            reshapeFactor = 64*3;
                            yDatReshape = yDat(1:end-(mod(size(yDat,1), reshapeFactor)));
                            timeToReshape= uxtimesPower(1:end-(mod(size(yDat,1), reshapeFactor)));
                            yDatToAverage  = reshape(yDatReshape,reshapeFactor,size(yDatReshape,1)/reshapeFactor);
                            timeToAverage  = reshape(timeToReshape,reshapeFactor,size(yDatReshape,1)/reshapeFactor);
                            
                            yAvg(ac,:) = rms(yDatToAverage - mean(yDatToAverage),1)'; % average rms
                            tUse = timeToAverage(reshapeFactor,:);
                        end
                        rmsAverage = log10(mean(yAvg));
                        accTablePlot = table();
                        accTablePlot.tuse = tUse';
                        % moving mean - 21 seconds
                        mvMean = movmean(rmsAverage,7);
                        accTablePlot.rmsAverage = rmsAverage';
                        accTablePlot.mvMean = mvMean';
                        
                        % plot
                        hsb(5,1) = hpanel(2,2,5,1).select();
                        axes(hsb(5,1));
                        hplt = plot(datenum(tUse),rmsAverage);
                        hplt.LineWidth = 1;
                        hplt.Color = [0.7 0.7 0 0.1];
                        % moving mean - 21 seconds
                        mvMean = movmean(rmsAverage,7);
                        hplt = plot(datenum(tUse),mvMean);
                        hplt.LineWidth = 2;
                        hplt.Color = [0.5 0.5 0 0.5];
                        title('actigraphy');
                        ylabel('RMS of acc (log10(g))');
                        outSpectral.accTime{ss} = tUse';
                        outSpectral.rmsAverage{ss} = rmsAverage';
                        outSpectral.mvMean{ss} = mvMean';
                        
                        
                        %%
                        
                        timeToPrint = spectTimes(1);
                        timeToPrint.Format = 'dd-MMM-yyyy';
                        
                        ttlUse = {};
                        if cntTtl == 1
                            ttlUse{cntTtl,1} = sprintf('%s %s', metaData.subjectID,timeToPrint); cntTtl = cntTtl + 1;
                        end
                        cntTtl = cntTtl + 1;
                        % print stim settings
                        for st = 1:size(stimLogSettings,1)
                            groupUse = stimLogSettings.activeGroup{st};
                            gropufn = sprintf('Group%s',groupUse);
                            groupstruc = stimLogSettings.(gropufn)(st);
                            % assuming one program
                            tsStim = datetime(stimLogSettings.HostUnixTime(st)/1000,...
                                'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
                            tsStim.Format = 'HH:mm';
                            stimSettingStr = sprintf('%s: %.2fmA %.2fHz',tsStim,...
                                groupstruc.ampInMilliamps(1),groupstruc.RateInHz(1));
                            
                            ttlUse{cntTtl,1} = stimSettingStr;
                            cntTtl = cntTtl + 1;
                        end
                        %
                        filenameSaveOrLoad = fullfile(pn,'combinedDataTable.mat');
                        save(filenameSaveOrLoad,'outSpectral', 'debugTable', 'timeDomainSettings','powerSettings',...
                            'fftSettings','metaData','stimSettingsOut','stimMetaData','stimLogSettings',...
                            'DetectorSettings','AdaptiveStimSettings','AdaptiveRuns_StimSettings','eventTableUse');
                        sgtitle(ttlUse);
                    end
                end
            end
        end
        if ~skipPlot
            for c = 1:5
                axes(hsb(c,1));
                datetick('x','HH:MM','keeplimits')
            end
            linkaxes(hsb,'x');
            linkaxes(hsb(1:4),'y');
            ylim(hsb(1,1),[0 100]);
            % plot the list of events
            % plot the stim settinsg
        end
        spectralPatient(s).outSpectral = outSpectral;
        spectralPatient(s).tblSide = tblSide;
        
    end
    
end


%% get all event data for the day 
eventTabOut = table();
for t = 1:size(tblSide,1)
    [pn,~] = fileparts(tblSide.deviceSettingsFn{t});
    eventFn = fullfile(pn,'EventLog.json');
    eventTable  = loadEventLog(eventFn);
    idxRemove = cellfun(@(x) any(strfind(x,'Application Version')),eventTable.EventType) | ...
        cellfun(@(x) any(strfind(x,'BatteryLevel')),eventTable.EventType) | ...
        cellfun(@(x) any(strfind(x,'LeadLocation')),eventTable.EventType);
    eventTableUse = eventTable(~idxRemove,:);
    eventTabOut = [eventTabOut; eventTableUse];
    
    
end
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
        for ss = 1:size(outSpectral,1)
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
    hpanel.fontsize = 16;
    hpanel.margintop = 20;
    hpanel.margin = 20;
    hpanel.de.margin = 10;
    
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
end



%% look at cross frequency correlations
hsb = gobjects();
hfig = figure; 
hfig.Color = 'w';
hpanel = panel();
hpanel.pack('v',{0.1 0.9});
hpanel(2).pack(1,2);
hsb = gobjects();
params.smooth = 1500;
for sn = 1:size(spectralPatient,2)
    outSpectral = spectralPatient(sn).outSpectral;
    tblSide = spectralPatient(sn).tblSide;
    hsb = hpanel(2,1,sn).select();
    axes(hsb); 

    pppOutAll  = [];
    for c = 1:4
        pppOut = [];
        timesOut = [];
        for ss = 1:size(outSpectral,1)
            chanfn = sprintf('chan%d',c);
            ppp = outSpectral.(chanfn){ss};
            fff = outSpectral.fff{ss};
            idxFreqUse = fff >= 2 & fff <= 100;
            pppOut = [pppOut, ppp];
            timesOut = [timesOut,outSpectral.spectTimes{ss}];
        end
        idxFreqUse = fff >= 2 & fff <= 100;
        pppOutAll(:,:,c) = pppOut(idxFreqUse,~isnan(pppOut(1,:)));
    end
    
    yMvMean = movmean(pppOutAll(:,:,1)',[params.smooth 0],'omitnan');
    yMvMean = yMvMean(600:end,:);
    colmin = min(yMvMean);
    colmax = max(yMvMean);
    rescaledMvMean1 = rescale(yMvMean,'InputMin',colmin,'InputMax',colmax);
    rescaledMvMean1 = rescaledMvMean1;
    
    yMvMean = movmean(pppOutAll(:,:,4)',[params.smooth 0],'omitnan');
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
%%












%% plot psds  for each side
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
    
    for ss = 1:size(outSpectral,1)
        
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
            while curTime < (times(end)-minutes(10))
                idxuse = curTime <= times & (curTime + minutes(10)) >= times;
                if sum(idxuse) > minChunks
                    avgPsd(cntpsd,:) = nanmean(y(idxFreqUse,idxuse),2);
                    cntpsd = cntpsd + 1;
                end
                curTime = curTime + minutes(10);
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

    
    hpanel.fontsize = 16;
    hpanel.de.margin = 30;
    hpanel.margin = 20;
    hpanel.de.margin = 20;
end

%%
x = 2;

%% plot in the same figure all relevant frequenciees, rescaled and smoothed.
for sn = 1:length(spectralPatient)
    tblSide = spectralPatient(sn).tblSide;
    patAndSide = sprintf('%s%s',spectralPatient(sn).tblSide.patient{1},...
                 spectralPatient(sn).tblSide.side{1});
    params = struct();
    switch patAndSide
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
    
    
    hsb  = [];
    
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
            for ss = 1:size(outSpectral,1)
                chanfn = sprintf('chan%d',c);
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
            
            for ss = 1:size(outSpectral,1)
                
                axes(hsb(fn,1));
                chanfn = sprintf('chan%d',c);
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
    hpanel.de.margin = 30;
end
%%




%% plot frequncy "barcodes" 
params = [];
for sn = 1:length(spectralPatient)
    
    outSpectral = spectralPatient(sn).outSpectral;
    
    params.chan1 = [14 25];
    params.chan3 = [11 23 65 ];
    params.chan4 = [11 23 65 ];
    params.bw = 1;
    params.smooth = 10*60;
    
    
    % params.chan1 = [21, 65, 71];
    % params.chan3 = [8 74];
    % params.chan4 = [8 74];
    params.bw = 1;
    params.smooth = 10*60;
    
    
    hsb  = [];
    
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
            for ss = 1:size(outSpectral,1)
                
                axes(hsb(fn,1));
                chanfn = sprintf('chan%d',c);
                y = outSpectral.(fieldnamesuse{fn}){ss};
                fff = outSpectral.fff{ss};
                bwupper = freqCenters(fq) + params.bw;
                bwlower = freqCenters(fq) - params.bw;
                idxFreqUse = fff >= bwlower & fff <= bwupper;
                yFreqMean = mean(y(idxFreqUse,:),1);
                yMvMean = movmean(yFreqMean,[10*60 0],'omitnan');
                rescaledMvMean = rescale(yMvMean,0 ,1);
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
                hplt(fq) = imagesc(rescaledMvMean);
                
            end
        end
%         legend(hplt,lgnds);
        title(tblSide.(fieldnamesuse{fn}){ss});
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

    
    hpanel.fontsize = 16;
    hpanel.margin = 12;
    hpanel.de.margin = 30;
end
%%

