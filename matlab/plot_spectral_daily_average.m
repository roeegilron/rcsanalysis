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


load(fullfile(rootdir,'database_from_device_settings.mat'),'masterTableLightOut');

masterTableOut = masterTableLightOut;

idxkeep = cellfun(@(x) any(strfind(x,'RCS')), masterTableOut.patient);
tblall =  masterTableOut(idxkeep,:);

unqpatients = unique(tblall.patient);
plotwhat = input('choose patient and side (1) or plot all(2)? ');
if plotwhat == 1 % choose patients and side
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
            %%
            sgtitle('place holder');
            cntTtl = 1;
            for ss = 1:size(tblSide,1)
                [pn,fn] = fileparts(tblSide.deviceSettingsFn{ss});
                
                %                 [outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerOut,adaptiveTable] =  MAIN_load_rcs_data_from_folder(pn);
                eventFn = fullfile(pn,'EventLog.json');
                eventTable  = loadEventLog(eventFn);
                idxRemove = cellfun(@(x) any(strfind(x,'Application Version')),eventTable.EventType) | ...
                    cellfun(@(x) any(strfind(x,'BatteryLevel')),eventTable.EventType) | ...
                    cellfun(@(x) any(strfind(x,'LeadLocation')),eventTable.EventType);
                eventTableUse = eventTable(~idxRemove,:);
                [combinedDataTable, debugTable, timeDomainSettings,powerSettings,...
                    fftSettings,metaData,stimSettingsOut,stimMetaData,stimLogSettings,...
                    DetectorSettings,AdaptiveStimSettings,AdaptiveRuns_StimSettings] = wrapper_DEMO_ProcessRCS(pn);
                
                
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
                    pcolor(datenum(spectTimes), fff(idxFreqUse) ,log10(ppp(idxFreqUse,:)));
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
                    groupUse = stimLogSettings.activeGroup{1};
                    gropufn = sprintf('Group%s',groupUse);
                    groupstruc = stimLogSettings.(gropufn);
                    % assuming one program
                    tsStim = datetime(stimLogSettings.HostUnixTime/1000,...
                        'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
                    tsStim.Format = 'HH:mm';
                    stimSettingStr = sprintf('%s: %.2fmA %.2fHz',tsStim,...
                        groupstruc.ampInMilliamps(1),groupstruc.RateInHz(1));
                    
                    ttlUse{cntTtl,1} = stimSettingStr;
                    cntTtl = cntTtl + 1;
                end
            end
            sgtitle(ttlUse);
        end
        for c = 1:5
            axes(hsb(c,1));
            datetick('x','HH:MM','keeplimits')
        end
        linkaxes(hsb,'x');
        linkaxes(hsb(1:4),'y');
        ylim(hsb(1,1),[0 100]);
        % plot the list of events
        % plot the stim settinsg
        spectralPatient(s).outSpectral = outSpectral;
        spectralPatient(s).tblSide = tblSide;
        
    end
    
end





%% plot spectral without the blanks
for sn = 1:size(spectralPatient)
    hfig = figure; 
    outSpectral = spectralPatient(sn).outSpectral;
    tblSide = spectralPatient(sn).tblSide;
    hfig = figure;
    hfig.Color = 'w';
    
    hpanel = panel();
    hpanel.pack(4,1);
    cnt = 1;
    for i = 1:4
        hsb(i,1) = hpanel(i,1).select();
    end

    for c = 1:4
        pppOut = [];
        axes(hsb(c,1));
        timesOut = [];
        for ss = 1:size(tblSide,1)
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
        hsb(c,1).YTick = yticks;
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
end
xlims = [1 length(timesKeep)];
hsb(4,1).XTick = floor(linspace(xlims(1), xlims(2),20));
xticks = hsb(4,1).XTick;
xticklabels = {};
for xx = 1:length(xticks)
    timeUseXtick = timesKeep(xticks(xx));
    timeUseXtick.Format = 'HH:mm';
    xticklabels{xx,1} = sprintf('%s',timeUseXtick);
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
    
    for ss = 1:size(tblSide,1)
        
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
    hpanel.fontsize = 16;
    hpanel.de.margin = 30;
    sgtitle(sprintf('%s %s',tblSide.patient{ss}, tblSide.side{ss}));
    hpanel.margin = 20;
    hpanel.de.margin = 20;
end

%%
x = 2;

%% plot in the same figure all relevant frequenciees, rescaled and smoothed.
params.chan1 = [21, 65, 71];
params.chan3 = [10 26 65 70];
params.chan4 = [10 21 65 70];
params.bw = 1;
params.smooth = 10*60;


% params.chan1 = [21, 65, 71];
params.chan3 = [8 74];
params.chan4 = [8 74];
params.bw = 1;
params.smooth = 10*60;


hsb  = [];

hfig = figure;
hfig.Color = 'w';
hpanel = panel();
nrows = length( fieldnames(params))-2;
hpanel.pack(nrows,1);
for n = 1:nrows
    hsb(n,1) = hpanel(n,1).select();
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
        for ss = 1:size(tblSide,1)
            
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
        end
    end
    legend(hplt,lgnds);
    title(tblSide.(fieldnamesuse{fn}){ss});
end
linkaxes(hsb,'x');

hpanel.fontsize = 16;
hpanel.margin = 12;
hpanel.de.margin = 30;

%%

