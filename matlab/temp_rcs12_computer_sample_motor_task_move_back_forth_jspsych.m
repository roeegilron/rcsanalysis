function temp_rcs12_computer_sample_motor_task_move_back_forth_jspsych()
close all;

pn = '/Users/roee/Box/RC-S_Studies_Regulatory_and_Data/Patient In-Clinic Data/RCS12/movement_task_multiple_reach/rcs_data/RCS12_L/Session1610149048176/DeviceNPC700477H';

expData = readtable('/Users/roee/Box/RC-S_Studies_Regulatory_and_Data/Patient In-Clinic Data/RCS12/movement_task_multiple_reach/task_as_run/task_1610150512115_ver1.csv');
% expData2 = readtable('/Users/roee/Box/RC-S_Studies_Regulatory_and_Data/Patient In-Clinic Data/RCS12/movement_task_multiple_reach/task_as_run/task_1610150058957_ver1.csv');


t = datetime(expData.Var3/1000,'ConvertFrom','posixTime',...
    'TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');

expData.Properties.VariableNames{1} = 'block';
expData.Properties.VariableNames{2} = 'trial';
expData.Properties.VariableNames{3} = 'unixTime';
expData.Properties.VariableNames{4} = 'event';
expData.Time = t; 




%% 

%%


hfig = figure;
hfig.Color = 'w';
hpanel = panel();
hpanel.pack('v',{0.1 0.9});
hpanel(2).pack('h',{0.1 0.9});
hpanel(2,2).pack(5,1);



eventFn = fullfile(pn,'EventLog.json');
eventTable  = loadEventLog(eventFn);
idxRemove = cellfun(@(x) any(strfind(x,'Application Version')),eventTable.EventType) | ...
    cellfun(@(x) any(strfind(x,'BatteryLevel')),eventTable.EventType) | ...
    cellfun(@(x) any(strfind(x,'LeadLocation')),eventTable.EventType);
eventTableUse = eventTable(~idxRemove,:);
[combinedDataTable, debugTable, timeDomainSettings,powerSettings,...
    fftSettings,metaData,stimSettingsOut,stimMetaData,stimLogSettings,...
    DetectorSettings,AdaptiveStimSettings,AdaptiveRuns_StimSettings] = DEMO_ProcessRCS(pn,3);



timeUse = combinedDataTable.localTime;
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
    pcolor(datenum(spectTimes), fff(idxFreqUse) ,log10(ppp(idxFreqUse,:)));
    colormap('jet')
    shading('interp');
    
    idxplot = cellfun(@(x) any(strfind(x,'KeyDown')),expData.event);
    eventPlot = expData(idxplot,:);
    
    ylims = get(gca,'YLim');
    for e = 1:size(eventPlot,1)
        xvals = datenum(eventPlot.Time(e));
        
        plot([xvals xvals],ylims,'LineWidth',2,'Color',[0.8 0 0 ]);
    end
    
    idxplot = cellfun(@(x) any(strfind(x,'KeyUp')),expData.event);
    eventPlot = expData(idxplot,:);
    
    ylims = get(gca,'YLim');
    for e = 1:size(eventPlot,1)
        xvals = datenum(eventPlot.Time(e));
        
        plot([xvals xvals],ylims,'LineWidth',2,'Color',[0 0.8 0 ]);
    end
    
    
    
    
    axis(hsb(c,1),'tight');
    fnchan = sprintf('chan%d',c);
    title(hsb(c,1),timeDomainSettings.(fnchan){1});
    outSpectral.spectTimes{1} = spectTimes;
    outSpectral.fff{1} = fff;
    chanfn = sprintf('chan%d',c);
    outSpectral.(chanfn){1} = ppp;
end


timeToPrint = spectTimes(1);
timeToPrint.Format = 'dd-MMM-yyyy';
cntTtl = 1;
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

linkaxes(hsb(1:3),'x');
%% plot event related data: 
% get data 
hfig = figure; 
rawData = [];
rawData(:,1) = mean([combinedDataTable.TD_key0, combinedDataTable.TD_key1],2);
rawData(:,2) = combinedDataTable.TD_key2;
rawData(:,3) = combinedDataTable.TD_key3;

filtData = [];

missData = isnan(combinedDataTable.TD_key0);

sr = unique(combinedDataTable.TD_samplerate(~isnan(combinedDataTable.TD_samplerate)));

% stn 
[b,a]        = butter(3,[19 21] / (sr/2),'bandpass'); % user 3rd order butter filter
yFilled = fillmissing(rawData(:,1),'constant',0);
yFilled = yFilled - mean(yFilled);
y_filt       = filtfilt(b,a,yFilled); %filter all
hsb(1,1) = subplot(3,1,1); hold on;
plot(combinedDataTable.localTime, y_filt,'Color',[0 0 0.8 0.2]);
y_filt_hilbert       = abs(hilbert(y_filt));
filtData(:,1) = y_filt_hilbert;
plot(combinedDataTable.localTime,y_filt_hilbert,'LineWidth',3,'Color',[0.8 0 0 0.6]);
title('stn beta');

% mc gammma 
[b,a]        = butter(3,[64 66] / (sr/2),'bandpass'); % user 3rd order butter filter
yFilled = fillmissing(rawData(:,2),'constant',0);
yFilled = yFilled - mean(yFilled);
y_filt       = filtfilt(b,a,yFilled); %filter all
hsb(2,1) = subplot(3,1,2); hold on;
plot(combinedDataTable.localTime, y_filt,'Color',[0 0 0.8 0.2]);
y_filt_hilbert       = abs(hilbert(y_filt));
filtData(:,2) = y_filt_hilbert;
plot(combinedDataTable.localTime,y_filt_hilbert,'LineWidth',3,'Color',[0.8 0 0 0.6]);

title('MC 8-9 gamma');

% mc gamma 2 
[b,a]        = butter(3,[64 66] / (sr/2),'bandpass'); % user 3rd order butter filter
yFilled = fillmissing(rawData(:,3),'constant',0);
y_filt       = filtfilt(b,a,yFilled); %filter all
yFilled = yFilled - mean(yFilled);
hsb(3,1) = subplot(3,1,3); hold on;
plot(combinedDataTable.localTime, y_filt,'Color',[0 0 0.8 0.2]);
y_filt_hilbert       = abs(hilbert(y_filt));
filtData(:,3) = y_filt_hilbert;
plot(combinedDataTable.localTime,y_filt_hilbert,'LineWidth',3,'Color',[0.8 0 0 0.6]);
title('MC 10-11 gamma');

for i = 1:3
    axes(hsb(i,1));
    idxplot = cellfun(@(x) any(strfind(x,'KeyDown')),expData.event);
    eventPlot = expData(idxplot,:);
    
    ylims = get(gca,'YLim');
    for e = 1:size(eventPlot,1)
        xvals = eventPlot.Time(e);
        
        plot([xvals xvals],ylims,'LineWidth',2,'Color',[0.8 0 0 ]);
    end
    
    idxplot = cellfun(@(x) any(strfind(x,'KeyUp')),expData.event);
    eventPlot = expData(idxplot,:);
    
    ylims = get(gca,'YLim');
    for e = 1:size(eventPlot,1)
        xvals = eventPlot.Time(e);
        
        plot([xvals xvals],ylims,'LineWidth',2,'Color',[0 0.8 0 ]);
    end
    
    idxplot = cellfun(@(x) any(strfind(x,'MOVE start')),expData.event);
    eventPlot = expData(idxplot,:);
    
    ylims = get(gca,'YLim');
    for e = 1:size(eventPlot,1)
        xvals = eventPlot.Time(e);
        
        plot([xvals xvals],ylims,'LineWidth',2,'Color',[0 0.8 0 ],'LineStyle','-.');
    end
    
    
    idxplot = cellfun(@(x) any(strfind(x,'MOVE end')),expData.event);
    eventPlot = expData(idxplot,:);
    
    ylims = get(gca,'YLim');
    for e = 1:size(eventPlot,1)
        xvals = eventPlot.Time(e);
        
        plot([xvals xvals],ylims,'LineWidth',2,'Color',[0.8 0 0 ],'LineStyle','-.');
    end
    
end

% linkaxes(hsb,'x');
%%

% plot event related data that is organized by time it took to move: 

% plot average event related data 

%% bet some behvioural data 
trialTimes = table(); 
cnt = 1;
% some behaviorual analysis 
unqBlocks = unique(expData.block);
for u = 1:length(unqBlocks)
    idxBlock = expData.block == unqBlocks(u);
    datBlock = expData(idxBlock,:);
    idxstart = find(cellfun(@(x) any(strfind(x,'KeyUp')),datBlock.event),1,'last')+2;
    datMoves = datBlock(idxstart:end,:);
    unqtrials = unique(datMoves.trial); 
    for t = 1:length(unqtrials)
        idxtrial = datMoves.trial == unqtrials(t);
        datTrial = datMoves(idxtrial,:);
        moveTime = datTrial.Time(2) - datTrial.Time(1);
        trialTimes.moveTime(cnt) = seconds(moveTime); 
        trialTimes.type{cnt} = datTrial.event{1}; 
        trialTimes.moveStart(cnt) = datTrial.Time(1);
        trialTimes.moveEnd(cnt) = datTrial.Time(2);
        cnt = cnt + 1; 
    end
end
hfig= figure;
hfig.Color = 'w';
histogram(trialTimes.moveTime,'BinWidth',0.05);
title('movement time'); 
xlabel('time')
ylabel('count');

%% plot psd's based on different phases of movement 
%% bet some behvioural data 
trialTimes = table(); 
cnt = 1;
rawTimes = combinedDataTable.localTime;
missData = isnan(combinedDataTable.TD_key0);

cntFix = 1;
cntPrep = 1;
cntFirstMove = 1; 
cntLeft = 1;
cntTop = 1;
cntBot =1;
fftPrep = [];
fftFix = [];
ffitFirstMove = [];
cntRight =1;
fftRightMoves = []; 
fftLeftMoves = []; 
fftTopMoves = []; 
fftBottomMoves = []; 
% get fixation psds 
unqBlocks = unique(expData.block);
for u = 1:length(unqBlocks)
    idxBlock = expData.block == unqBlocks(u);
    datBlock = expData(idxBlock,:);
    idxstart = find(cellfun(@(x) any(strfind(x,'KeyUp')),datBlock.event),1);
    if length(idxstart) == 1  % only one keyup event! 
        
        % fft for fixation 
        idxfix = find(cellfun(@(x) any(strfind(x,'FixationFinish')),datBlock.event),1);
        timeEnd = datBlock.Time(idxfix);
        timeStart = timeEnd - seconds(3); 
        tidx = (rawTimes > timeStart) & (rawTimes <= timeEnd);
        sizes = sum(tidx);
        if sum(missData(tidx)) == 0 % check no missing data
                [fftFix(cntFix,:,:),f]   = pwelch(rawData(tidx,:).*1e3,sr,sr/2,2:1:(sr/2 - 50),sr,'psd');
                cntFix = cntFix + 1;
        end
        
        
        % fft for prep 
        idxfix = find(cellfun(@(x) any(strfind(x,'PREP end')),datBlock.event),1);
        timeEnd = datBlock.Time(idxfix);
        timeStart = timeEnd - seconds(3); 
        tidx = (rawTimes > timeStart) & (rawTimes <= timeEnd);
        sizes = sum(tidx);
        if sum(missData(tidx)) == 0 % check no missing data
                [fftPrep(cntPrep,:,:),f]   = pwelch(rawData(tidx,:).*1e3,sr,sr/2,2:1:(sr/2 - 50),sr,'psd');
                cntPrep = cntPrep + 1;
        end
        
        % fft for first movement  
        idxfix = find(cellfun(@(x) any(strfind(x,'KeyUp')),datBlock.event),1);
        timeStart = datBlock.Time(idxfix);
        idxfix = find(cellfun(@(x) any(strfind(x,'MOVE end')),datBlock.event),1,'first');
        timeEnd = datBlock.Time(idxfix);
        tidx = (rawTimes > timeStart) & (rawTimes <= timeEnd);
        sizes = sum(tidx);
        if sum(missData(tidx)) == 0 % check no missing data
                [ffitFirstMove(cntFirstMove,:,:),f]   = pwelch(rawData(tidx,:).*1e3,sr/2,sr/4,2:1:(sr/2 - 50),sr,'psd');
                cntFirstMove = cntFirstMove + 1;
        end
        
        % fft for subsequent movements right 
        idxstart = find(cellfun(@(x) any(strfind(x,'KeyUp')),datBlock.event),1,'last')+2;
        datMoves = datBlock(idxstart:end,:);

        idxStart = find(cellfun(@(x) any(strfind(x,'right target MOVE start')),datMoves.event));
        idxEnd = find(cellfun(@(x) any(strfind(x,'right target MOVE end')),datMoves.event));
        for ii = 1:length(idxStart)
            timeStart = datMoves.Time(idxStart(ii));
            timeEnd = datMoves.Time(idxEnd(ii));
            tidx = (rawTimes > timeStart) & (rawTimes <= timeEnd);
            sizes = sum(tidx);
            if sum(missData(tidx)) == 0 % check no missing data
                [fftRightMoves(cntRight,:,:),f]   = pwelch(rawData(tidx,:).*1e3,sr/2,sr/4,2:1:(sr/2 - 50),sr,'psd');
                cntRight = cntRight + 1;
            end
        end
        
        % fft for subsequent movements left
        idxstart = find(cellfun(@(x) any(strfind(x,'KeyUp')),datBlock.event),1,'last')+2;
        datMoves = datBlock(idxstart:end,:);
        
        idxStart = find(cellfun(@(x) any(strfind(x,'left target MOVE start')),datMoves.event));
        idxEnd = find(cellfun(@(x) any(strfind(x,'left target MOVE end')),datMoves.event));
        for ii = 1:length(idxStart)
            timeStart = datMoves.Time(idxStart(ii));
            timeEnd = datMoves.Time(idxEnd(ii));
            tidx = (rawTimes > timeStart) & (rawTimes <= timeEnd);
            sizes = sum(tidx);
            if sum(missData(tidx)) == 0 % check no missing data
                [fftLeftMoves(cntLeft,:,:),f]   = pwelch(rawData(tidx,:).*1e3,sr/2,sr/4,2:1:(sr/2 - 50),sr,'psd');
                cntLeft = cntLeft + 1;
            end
        end
        
        % fft for subsequent movements top
        idxstart = find(cellfun(@(x) any(strfind(x,'KeyUp')),datBlock.event),1,'last')+2;
        datMoves = datBlock(idxstart:end,:);
        
        idxStart = find(cellfun(@(x) any(strfind(x,'top target MOVE start')),datMoves.event));
        idxEnd = find(cellfun(@(x) any(strfind(x,'top target MOVE end')),datMoves.event));
        for ii = 1:length(idxStart)
            timeStart = datMoves.Time(idxStart(ii));
            timeEnd = datMoves.Time(idxEnd(ii));
            tidx = (rawTimes > timeStart) & (rawTimes <= timeEnd);
            sizes = sum(tidx);
            if sum(missData(tidx)) == 0 % check no missing data
                [fftTopMoves(cntTop,:,:),f]   = pwelch(rawData(tidx,:).*1e3,sr/2,sr/4,2:1:(sr/2 - 50),sr,'psd');
                cntTop = cntTop + 1;
            end
        end
        
          % fft for subsequent movements bittpm
        idxstart = find(cellfun(@(x) any(strfind(x,'KeyUp')),datBlock.event),1,'last')+2;
        datMoves = datBlock(idxstart:end,:);
        
        idxStart = find(cellfun(@(x) any(strfind(x,'bottom target MOVE start')),datMoves.event));
        idxEnd = find(cellfun(@(x) any(strfind(x,'bottom target MOVE end')),datMoves.event));
        for ii = 1:length(idxStart)
            timeStart = datMoves.Time(idxStart(ii));
            timeEnd = datMoves.Time(idxEnd(ii));
            tidx = (rawTimes > timeStart) & (rawTimes <= timeEnd);
            sizes = sum(tidx);
            if sum(missData(tidx)) == 0 % check no missing data
                [fftBottomMoves(cntBot,:,:),f]   = pwelch(rawData(tidx,:).*1e3,sr/2,sr/4,2:1:(sr/2 - 50),sr,'psd');
                cntBot = cntBot + 1;
            end
        end
        
    end
end

%% make figure 
hfig = figure; 
hfig.Color = 'w'; 
cntplt = 1; 
nrows = 3;
ncols = 1; 
hsb = [];
% stn
hsb(1,1) = subplot(nrows,ncols,cntplt); cntplt = cntplt+1; hold on;
plot(f,log10(mean(fftFix(:,:,1),1)),'LineWidth',2,'Color',[0.8 0 0 0.5]);
plot(f,log10(mean(fftPrep(:,:,1),1)),'LineWidth',2,'Color',[0 0.8 0 0.5]);
plot(f,log10(mean(ffitFirstMove(:,:,1),1)),'LineWidth',2,'Color',[0 0 0.8 0.5]);
plot(f,log10(mean(fftRightMoves(:,:,1),1)),'LineWidth',2,'Color',[0 0.8 0.8 0.5],'LineStyle','-.');
plot(f,log10(mean(fftLeftMoves(:,:,1),1)),'LineWidth',2,'Color',[0 0.8 0.8 0.5],'LineStyle','-.');
plot(f,log10(mean(fftTopMoves(:,:,1),1)),'LineWidth',2,'Color',[0 0.8 0.8 0.5],'LineStyle','-.');
plot(f,log10(mean(fftBottomMoves(:,:,1),1)),'LineWidth',2,'Color',[0 0.8 0.8 0.5],'LineStyle','-.');
legend({'fix','prep','move','q move'});
title('stn 0-2');
% mc 
hsb(2,1) = subplot(nrows,ncols,cntplt); cntplt = cntplt+1; hold on;
plot(f,log10(mean(fftFix(:,:,2),1)),'LineWidth',2,'Color',[0.8 0 0 0.5]);
plot(f,log10(mean(fftPrep(:,:,2),1)),'LineWidth',2,'Color',[0 0.8 0 0.5]);
plot(f,log10(mean(ffitFirstMove(:,:,2),1)),'LineWidth',2,'Color',[0 0 0.8 0.5]);
plot(f,log10(mean(fftRightMoves(:,:,2),1)),'LineWidth',2,'Color',[0 0.8 0.8 0.5],'LineStyle','-.');
plot(f,log10(mean(fftLeftMoves(:,:,2),1)),'LineWidth',2,'Color',[0 0.8 0.8 0.5],'LineStyle','-.');
plot(f,log10(mean(fftTopMoves(:,:,2),1)),'LineWidth',2,'Color',[0 0.8 0.8 0.5],'LineStyle','-.');
plot(f,log10(mean(fftBottomMoves(:,:,2),1)),'LineWidth',2,'Color',[0 0.8 0.8 0.5],'LineStyle','-.');


title('mc 8-9');
% mc 
hsb(3,1) = subplot(nrows,ncols,cntplt); cntplt = cntplt+1; hold on;
plot(f,log10(mean(fftFix(:,:,3),1)),'LineWidth',2,'Color',[0.8 0 0 0.5]);
plot(f,log10(mean(fftPrep(:,:,3),1)),'LineWidth',2,'Color',[0 0.8 0 0.5]);
plot(f,log10(mean(ffitFirstMove(:,:,3),1)),'LineWidth',2,'Color',[0 0 0.8 0.5]);
plot(f,log10(mean(fftRightMoves(:,:,3),1)),'LineWidth',2,'Color',[0 0.8 0.8 0.5],'LineStyle','-.');
plot(f,log10(mean(fftLeftMoves(:,:,3),1)),'LineWidth',2,'Color',[0 0.8 0.8 0.5],'LineStyle','-.');
plot(f,log10(mean(fftTopMoves(:,:,3),1)),'LineWidth',2,'Color',[0 0.8 0.8 0.5],'LineStyle','-.');
plot(f,log10(mean(fftBottomMoves(:,:,3),1)),'LineWidth',2,'Color',[0 0.8 0.8 0.5],'LineStyle','-.');

title('mc 10-11');

linkaxes(hsb,'x');
xlim([0 100]);

%%

unqBlocks = unique(expData.block);
for u = 1:length(unqBlocks)
    idxBlock = expData.block == unqBlocks(u);
    datBlock = expData(idxBlock,:);
    idxstart = find(cellfun(@(x) any(strfind(x,'KeyUp')),datBlock.event),1,'last')+2;
    datMoves = datBlock(idxstart:end,:);
    unqtrials = unique(datMoves.trial); 
    for t = 1:length(unqtrials)
        idxtrial = datMoves.trial == unqtrials(t);
        datTrial = datMoves(idxtrial,:);
        moveTime = datTrial.Time(2) - datTrial.Time(1);
        trialTimes.moveTime(cnt) = seconds(moveTime); 
        trialTimes.type{cnt} = datTrial.event{1}; 
        trialTimes.moveStart(cnt) = datTrial.Time(1);
        trialTimes.moveEnd(cnt) = datTrial.Time(2);
        cnt = cnt + 1; 
    end
end
figure;histogram(trialTimes.moveTime);



%% plot event related data based on time 
trialTimesSorted = sortrows(trialTimes,{'moveTime'});
rawTimes = combinedDataTable.localTime;
datOut = [];
cntOut = 1; 
movetime = [];
for t = 1:size(trialTimesSorted,1)
    % get 0.2 seconds before 
    % and 2 seconds after 
    % mark with a line the time in which movement happened 
    secBefore = seconds(0.2);
    secAfter  = seconds(2);
    tStart = trialTimesSorted.moveStart(t); 
    tStart = tStart -secBefore;
    tEnd = trialTimesSorted.moveStart(t); 
    tEnd = tEnd + secAfter;
    movetime(t) = seconds((trialTimesSorted.moveEnd(t) - trialTimesSorted.moveStart(t)) + secBefore);
    tidx = (rawTimes > tStart) & (rawTimes <= tEnd);
    sizes(t) = sum(tidx);
    if sum(missData(tidx)) == 0 % check no missing data 
        datOut(cntOut,:,:) = filtData(tidx,:);
        cntOut = cntOut  + 1;
    end
end

figure; 
subplot(3,1,1); 
imagesc(datOut(:,:,1));
title('stn beta');
for e = 1:size(movetime)
    xidx = ceil(movetime(t)*sr); 
end

subplot(3,1,2); 
imagesc(datOut(:,:,2));
title('mc 8-9 gamma');

subplot(3,1,3); 
imagesc(datOut(:,:,3));
title('mc 10-11 gamma');

%%
hfig = figure;
plot(mean(datOut(1:50,:,1))','Color',[0.8 0 0 0.5],'LineWidth',2)
hold on;
plot(mean(datOut(110:160,:,1))','Color',[0 0.8 0 0.5],'LineWidth',2)
hold on;
plot(mean(datOut(end-50:end,:,1))','Color',[0 0 0.8 0.5],'LineWidth',2)
ylims = get(gca,'YLim');

xvals = ceil(mean(movetime(1:50))*sr);
plot([xvals xvals],ylims,'Color',[0.8 0 0 0.5],'LineWidth',2);

xvals = ceil(mean(movetime(110:160))*sr);
plot([xvals xvals],ylims,'Color',[0 0.8 0 0.5],'LineWidth',2);


xvals = ceil(mean(movetime(end-50:end))*sr);
plot([xvals xvals],ylims,'Color',[0 0 0.8 0.5],'LineWidth',2);

timeStart = ceil(seconds(secBefore) * sr);
plot([timeStart timeStart],ylims,'Color',[0 0 0 0.5],'LineWidth',2,'LineStyle','-.');

title('STN 0-2 beta');
legend({'fast','med','slow'});
hfig.Color = 'w';



%%


%%
idxplot = cellfun(@(x) any(strfind(x,'KeyDown')),expData.event);
eventPlot = expData(idxplot,:);

ylims = get(gca,'YLim');
for e = 1:size(eventPlot,1)
    xvals = datenum(eventPlot.Time(e));
    
    plot([xvals xvals],ylims,'LineWidth',2,'Color',[0.8 0 0 ]);
end


%% plot rms of actigraphy
accAxes = {'X','Y','Z'};
accIdxKeep = ~isnan(combinedDataTable.Accel_XSamples);
accTable = combinedDataTable(accIdxKeep,{'localTime','Accel_XSamples','Accel_YSamples','Accel_ZSamples'});
yAvg = [];
for ac = 1:length(accAxes)
    fnUse = sprintf('Accel_%sSamples',accAxes{ac});
    yDat = accTable.(fnUse);
    uxtimesPower = accTable.localTime;
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
outSpectral.accTime{1} = tUse';
outSpectral.rmsAverage{1} = rmsAverage';
outSpectral.mvMean{1} = mvMean';

for c = 1:5
    axes(hsb(c,1));
    datetick('x','HH:MM','keeplimits')
end
linkaxes(hsb,'x');
linkaxes(hsb(1:4),'y');
ylim(hsb(1,1),[0 100]);
% plot the list of events
% plot the stim settinsg


sgtitle(ttlUse);

%% plot task specific events 

return
%% plot psd

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



ss = 1;
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
    minChunks = floor((10*5)/seconds(mode(diff(times)))/2);
    avgPsd = [];
    cntpsd = 1;
    while curTime < (times(end)-minutes(2))
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
    fnchan = sprintf('chan%d',c);
    title(hsb(c,1),timeDomainSettings.(fnchan){1});

    hsbuse = gca;
    hsbuse.XTick = [4 12 30 50 60 65 70 75 80 100];
    grid on;
    ylabel(hsbuse,'Power (log_1_0\muV^2/Hz)');
    xlabel(hsbuse,'Frequency (Hz');
end

hpanel.fontsize = 16;
hpanel.de.margin = 30;
sgtitle(sprintf('%s %s',tblSide.patient{ss}, tblSide.side{ss}));
hpanel.margin = 20;
hpanel.de.margin = 20;



