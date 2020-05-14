function plot_alligned_data_in_folder(dirname)
%% function to plot alligned data in a folder 
fnmload = fullfile(dirname,'all_data_alligned.mat'); 
if ~exist(fnmload,'file')
    load_and_save_alligned_data_in_folder(dirname);
    load(fnmload,'outdatcomplete','outdatcompleteAcc','outRec',...
    'eventTable','powerOut','adaptiveTable','adaptiveStruc','senseStruc','embeddedStartEndTimes','adaptiveInfo');
else
    load(fnmload,'outdatcomplete','outdatcompleteAcc','outRec',...
    'eventTable','powerOut','adaptiveTable','adaptiveStruc','senseStruc','embeddedStartEndTimes','adaptiveInfo');
end
close all;
figdir = fullfile(dirname,'figures'); 
mkdir(figdir); 

%% plot alligned data 
% find difference from unix time 
idxTimeCompare = find(outdatcomplete.PacketRxUnixTime~=0,1);
packRxTimeRaw  = outdatcomplete.PacketRxUnixTime(idxTimeCompare); 
packtRxTime    =  datetime(packRxTimeRaw/1000,...
            'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
derivedTime    = outdatcomplete.derivedTimes(idxTimeCompare); 
timeDiff       = derivedTime - packtRxTime;
deltaUse       = seconds(20); 
startTimes = embeddedStartEndTimes.EmbeddedStart.UnixOnsetTime + timeDiff + deltaUse; 
endTimes = embeddedStartEndTimes.EmbeddedEnd.UnixOnsetTime + timeDiff - deltaUse; 
dur      = endTimes - startTimes;
% only consider adaptive files over 30 seconds 
startTimes = startTimes(dur > seconds(30));
endTimes = endTimes(dur > seconds(30));
 % XXXX 
% startTimes = startTimes(1); 
% endTimes = endTimes(end); 
% XXXX 

nrows = 4; 
ncols = 1; 
for e = 5%2:length(startTimes)
    hfig = figure;
    hfig.Position = [45           1        1636         954];
    hfig.Color = 'w';
    cntplt = 1;
    % plot one figure for each adaptive "session".
    % this should include:
    
    % subplot 1
    % settings
    hsub(cntplt) = subplot(nrows,ncols,cntplt); cntplt = cntplt + 1;
    set(gca,'FontSize',16);
    set(gca, 'box','off','XTickLabel',[],'XTick',[],'YTickLabel',[],'YTick',[])

    a = annotation('textbox', hsub(1).Position, 'String', "hi");
    a.FontSize = 14;
    % params to write 
    % power 
    strline = 1;
    strOut{strline} = 'settings'; 
    strline = strline + 1; 
    
    strOut{strline} =  sprintf('%s %s',startTimes(e),eventTable.sessionid{1});
    strline = strline + 1;
    
    
    strOut{strline} = sprintf('%s\t power band: %s',...
        adaptiveInfo(e).tdChannelInfo,...
        adaptiveInfo(e).bandsUsed);    
    strline = strline + 1; 
    % stim 
    
    strOut{strline} = sprintf('stim rate %.2f\t states: [%.2f mA %.2f mA %.2f mA]',...
        adaptiveInfo(e).stimRate,...
        adaptiveInfo(e).State0AmpInMilliamps,...
        adaptiveInfo(e).State1AmpInMilliamps,...
        adaptiveInfo(e).State2AmpInMilliamps);
    strline = strline + 1; 
    
    % fft settings 
    fftsize = adaptiveInfo(e).Fftsize;
    sr = adaptiveInfo(e).SampleRate;
    
    fftinterval = adaptiveInfo(e).FftInterval;
    fftime = ceil((fftsize/sr).*1000); 
    % xxx 
    percentOverlap = fftime/ (fftime +fftinterval);
    strOut{3} = sprintf('%d ms FFt interval, each FFT represents %d ms of data and %.2f overlap (fft size %d sr %d Hz)',...
        fftinterval, ceil((fftsize/sr).*1000),  fftsize,sr);
    updateRate = adaptiveInfo(e).UpdateRate; 
    
    strOut{strline} = sprintf('%d ffts are averaged - %d ms of data before being input to LD',updateRate,ceil((fftsize/sr).*1000)*updateRate);    
    strline = strline + 1; 
    

    strOut{strline} = sprintf('update rate %d onset %d termination %d state change blank %d (%d ms)',...
        adaptiveInfo(e).UpdateRate,...
        adaptiveInfo(e).OnsetDuration,...
        adaptiveInfo(e).TerminationDuration,...
        adaptiveInfo(e).StateChangeBlankingUponStateChange,...
        adaptiveInfo(e).StateChangeBlankingUponStateChange * adaptiveInfo(e).FftInterval);
    strline = strline + 1; 

    
    strOut{strline} = sprintf('ramp up rate %.2f mA/sec\t ramp down rate %.2f mA/sec\t',...
        adaptiveInfo(e).rampUpRatePerSec,...
        adaptiveInfo(e).rampDownRatePerSec);
    strline = strline + 1;
    
    
    % power vals 
    secsPower = powerOut.powerTable.derivedTimes;
    idxusePower = secsPower >= startTimes(e) & secsPower <= endTimes(e);
    powerVals = powerOut.powerTable.(adaptiveInfo(e).bandsUsedName);
    secsPower = secsPower(idxusePower);
    powerVals = powerVals(idxusePower);

    strOut{strline} = sprintf('B0 - %d B1 - %d (power vals: 0.25 (%d )0.5 (%d) 0.75 (%d)',...
        adaptiveInfo(e).B0,adaptiveInfo(e).B1,...
        prctile(powerVals,25),...
        prctile(powerVals,50),...
        prctile(powerVals,75));
    strline = strline + 1;
    
    % detector 
    secsAdaptive = adaptiveTable.derivedTimes;
    idxuseAdaptive = secsAdaptive >= startTimes(e) & secsAdaptive <= endTimes(e);
    secsAdaptive = secsAdaptive(idxuseAdaptive);
    state = adaptiveTable.CurrentAdaptiveState(idxuseAdaptive);
    detector = adaptiveTable.LD0_output(idxuseAdaptive);

    strOut{strline} = sprintf('B0 - %d B1 - %d (detector vals: 0.25 (%d )0.5 (%d) 0.75 (%d)',...
        adaptiveInfo(e).B0,adaptiveInfo(e).B1,...
        prctile(detector,25),...
        prctile(detector,50),...
        prctile(detector,75));
    strline = strline + 1;
    

    a.String = strOut;
    a.EdgeColor = 'none';
    
    % suplot 2
    hsub(cntplt) = subplot(nrows,ncols,cntplt); cntplt = cntplt + 1;
    hold on;
    % 1. td band passedd power
    % find the right time domain channel
    cused = adaptiveInfo(e).tdChannelUsed;
    tddata = outdatcomplete.(sprintf('key%d',cused-1));
    secs   = outdatcomplete.derivedTimes;
    idxuse = secs >= startTimes(e) & secs <= endTimes(e);
    tddata = tddata(idxuse);
    secs   = secs(idxuse);
    bandsUsed = str2num(strrep(strrep(adaptiveInfo(e).bandsUsed,'Hz',''),'-',' '));
    sr = adaptiveInfo(e).SampleRate;
    tddata = tddata - mean(tddata);
    % only way to get a closer approximation is a real time fft 
    % scott feedback this is the right thing to do in real time 
    % can stream both the raw power domain as well as detector 
    [b,a]        = butter(3,[bandsUsed(1) bandsUsed(end)] / (sr/2),'bandpass'); % user 3rd order butter filter
    y_filt       = filtfilt(b,a,tddata); %filter all
    y_filt_hilbert       = abs(hilbert(y_filt));
    ydatRescaled = rescale(y_filt,0.55,1); % XXXX 
    y_filt_hilbertRescaled = rescale(y_filt_hilbert,0.55+(1-0.55)/2,1);
    plot(secs,ydatRescaled,'LineWidth',0.5,'Color',[0 0 0.8 0.2]);
    plot(secs,y_filt_hilbertRescaled,'LineWidth',3,'Color',[0.8 0 0 0.6]);
    % 2. adaptive power
    secsPower = powerOut.powerTable.derivedTimes;
    idxusePower = secsPower >= startTimes(e) & secsPower <= endTimes(e);
    powerVals = powerOut.powerTable.(adaptiveInfo(e).bandsUsedName);
    secsPower = secsPower(idxusePower);
    powerVals = powerVals(idxusePower);
    powerValsRescaled = rescale(powerVals,0.1,0.5);
    plot(secsPower,powerValsRescaled,'LineWidth',3,'Color',[0 0.8 0 0.6]);
    ylabel('power - td & embedded (a.u.)');
    title('Power - TD & Embedded');
    set(gca,'FontSize',16);
    
    % suplot 3
    hsub(cntplt) = subplot(nrows,ncols,cntplt); cntplt = cntplt + 1;
    hold on;
    secsAdaptive = adaptiveTable.derivedTimes;
    idxuseAdaptive = secsAdaptive >= startTimes(e) & secsAdaptive <= endTimes(e);
    secsAdaptive = secsAdaptive(idxuseAdaptive); 
    state = adaptiveTable.CurrentAdaptiveState(idxuseAdaptive);
    detector = adaptiveTable.LD0_output(idxuseAdaptive);
    highThresh = adaptiveTable.LD0_highThreshold(idxuseAdaptive);
    lowThresh = adaptiveTable.LD0_lowThreshold(idxuseAdaptive);
    current   = adaptiveTable.CurrentProgramAmplitudesInMilliamps(idxuseAdaptive); 
    % 1. detector
    plot(secsAdaptive,detector,'LineWidth',3);
    hplt = plot(secsAdaptive,highThresh,'LineWidth',3);
    hplt.LineStyle = '-.';
    hplt.Color = [hplt.Color 0.7];
    hplt = plot(secsAdaptive,lowThresh,'LineWidth',3);
    hplt.LineStyle = '-.';
    hplt.Color = [hplt.Color 0.7];
    % 2. threshold
    ylims = get(gca,'YLim');
    rescaleVals = [ylims(2)*1.1 (ylims(2) + ceil(ylims(2)-ylims(1))/3)];
    stateRescaled = rescale(state,rescaleVals(1),rescaleVals(2));
    % 3. state - rescaled on the second y axis above current
    plot(secsAdaptive,stateRescaled,'LineWidth',3,'Color',[0 0.8 0 0.6]);
    title('state and detector'); 
    set(gca,'FontSize',16);
    
    % subplot 4
    hsub(cntplt) = subplot(nrows,ncols,cntplt); cntplt = cntplt + 1;
    plot(secsAdaptive,current,'LineWidth',3,'Color',[0.8 0 0 0.6]);
    avgCurrent = mean(current); 
    title(sprintf('Current %.2f (mean)',avgCurrent)); 
    ylabel('Current (mA)'); 
    set(gca,'FontSize',16);
    
    figTitle = sprintf('%s %s run %.2d',adaptiveInfo(e).patient,...
        secsAdaptive(end) - secsAdaptive(1),e);
    sgtitle(figTitle,'FontSize',20); 
    
    figSaveName = sprintf('%.2d_embedded_%s',e,adaptiveInfo(e).patient);
    figsaveFullName = fullfile(figdir,figSaveName);
    % save figure; 
    linkaxes(hsub(2:end),'x');
    savefig(hfig,figsaveFullName); 
    
    % plot the artifact from rapid switching of current 
    
    
    %{
    figure; 
    nrows = 4; 
    ncols = 1; 
    cnplt = 1; 
    % plot raw data (but filter a bit between 5-80 to center data a bit) 
    hsb(cnplt ) = subplot(nrows,ncols,cnplt); cnplt = cnplt + 1; 
    hold on; 
    [b,a]        = butter(5,80 / (sr/2),'low'); % user 3rd order butter filter
    y_filt       = filtfilt(b,a,tddata); %filter all
    % find the peaks and plot the am
    ydatRescaled = rescale(y_filt,0,1); % XXXX 
    plot(secs,ydatRescaled)
    [pks,locs] = findpeaks(ydatRescaled,'MinPeakHeight',0.9);
    scatter(secs(locs),pks,50,'filled','MarkerFaceColor',[0.8 0 0 ],'MarkerFaceAlpha',0.5);
    
     [pks2,locs2] = findpeaks(ydatRescaled.*(-1),'MinPeakHeight',-0.15);
    scatter(secs(locs2),ydatRescaled(locs2),50,'filled','MarkerFaceColor',[0 0.8 0 ],'MarkerFaceAlpha',0.5);
    
    
    [wtmat,fr] = a_wavelet_pow_pha(tddata,sr,1,150);
    for ll = 1:length(locs) 
        statidx = locs - 2000; 
        stopidx = locs + 2000;
        if statidx(ll) > 1 & (stopidx(ll) < length(tddata))
            averageEnd(:,:,ll) = wtmat(:,statidx(ll):stopidx(ll));
            rawEnd(ll,:) = tddata(statidx(ll):stopidx(ll));
        end
    end
    
    for ll = 1:length(locs2)
        statidx = locs2 - 2000;
        stopidx = locs2 + 2000;
        if statidx(ll) > 1 & (stopidx(ll) < length(tddata))
            averageStart(:,:,ll) = wtmat(:,statidx(ll):stopidx(ll));
            rawStart(ll,:) = tddata(statidx(ll):stopidx(ll));
        end
    end
    
    avgStart = mean(averageStart,3);
    avgEnd = mean(averageEnd,3);
    hfig = figure;
    hfig.Color = 'w'; 
    subplot(2,1,1);
    plot(rawStart'); 
    title('raw data allinged to stim sweep start'); 
    xlim([0 4e3]); 
    set(gca,'FontSize',16);
    subplot(2,1,2);
    imagesc(abs(avgStart));
    title('wavelet transform'); 
    xlabel('data points');
    ylabel('Frequencty (Hz)');
    set(gca,'YDir','normal')
    set(gca,'FontSize',16);
    
    hfig = figure;
    hfig.Color = 'w';
    subplot(2,1,1);
    plot(rawEnd');
    title('raw data allinged to stim sweep end');
    xlim([0 4e3]);
    set(gca,'FontSize',16);
    subplot(2,1,2);
    imagesc(abs(avgEnd));
    title('wavelet transform');
    xlabel('data points');
    ylabel('Frequencty (Hz)');
    set(gca,'YDir','normal')
    set(gca,'FontSize',16);
    
    
    % Input must contains at list 2 argument;
    % dx - data massive
    % SampleRate - SampleRate
    % fr1 - Start freq.
    % fr2 - Stopt freq.
    % Optional -
    % dfr - Frequency resolution; = 1  if not define
    % w_strectch -  = 3    if not define

    
    % plot the current 
    hsb(cnplt ) = subplot(nrows,ncols,cnplt); cnplt = cnplt + 1; 
    plot(secsAdaptive,current,'LineWidth',3,'Color',[0.8 0 0 0.6]);
    
    linkaxes(hsb,'x');
    subplot(nrows,ncols,cnplt); cnplt = cnplt + 1; 
    hold on; 
    dat = []; 
    for s = 1:length(locs)
        dat(s,:) = tddata(locs(s)-50:locs(s)+1000);
        [fftOutStim(s,:),f]   = pwelch(dat(s,:),sr,sr/2,2:1:(sr/2 - 50),sr,'psd');
        plot(dat(s,:)); 
    end
    
    % plot artifact ffft and real signal FFT
    subplot(nrows,ncols,cnplt); cnplt = cnplt + 1; 
    hold on;
    sr = 1000;
%     plot(f,log10(mean(fftOutStim,1)),'LineWidth',2);
    plot(f,log10(fftOutStim),'LineWidth',2);
    cleandat = tddata(69770+3*1e3:69770+2.5*1e4);
    [fftOut,f]   = pwelch(cleandat,sr,sr/2,2:1:(sr/2 - 50),sr,'psd');
    plot(f,log10(fftOut),'LineWidth',2);
    legend({'stim going down','clean data - no stim change'}); 
    %%
    %}
end
return;
%% 
%% plot all alligne data 
nrows = 2; 
ncols = 4; 
hfig = figure; 
cntplt = 1;





% plot only certain events 
useEvents = 0;
if useEvents == 1
    % find idx of event
    idxevent = ...
        strcmp(eventTable.EventType,'008 Turn Embedded Therapy ON. Number: 1');
    timeStart = eventTable.UnixOnsetTime(idxevent);
    timeEnd   = timeStart+ minutes(22);
else
    timeStart = outdatcomplete.derivedTimes(1) + minutes(2);
    timeEnd = outdatcomplete.derivedTimes(end) - minutes(2);
end



% plot td data 
% idxuse time domain 
timesTD = outdatcomplete.derivedTimes;
idxuseTD = timesTD > timeStart & timesTD < timeEnd;
for c = 1:4 % loop on channels
    fnm = sprintf('key%d',c-1);
    y = outdatcomplete.(fnm)(idxuseTD);
    y = y - mean(y);
    hsub(cntplt) = subplot(nrows,ncols,cntplt);
    hplt = plot(hsub(cntplt),outdatcomplete.derivedTimes(idxuseTD),y);
    hplt.LineWidth = 2;
    hplt.Color = [0 0 0.8 0.7];
    title( hsub(c),outRec(1).tdData(c).chanFullStr );
    set(hsub(c),'FontSize',12);
    cntplt = cntplt+1;
end

% plot accleratoin
timesAcc = outdatcompleteAcc.derivedTimes;
idxuseAcc = timesAcc > timeStart & timesAcc < timeEnd;

hsub(cntplt) = subplot(nrows,ncols,cntplt); 
hold on;
axsUse = {'X','Y','Z'};
for i = 1:3
    fnm = sprintf('%sSamples',axsUse{i});
    y = outdatcompleteAcc.(fnm)(idxuseAcc);
    y = y - mean(y);
    set(hsub(c+1),'FontSize',18);
    hplt = plot(hsub(c+1),outdatcompleteAcc.derivedTimes(idxuseAcc),y);
    hplt.LineWidth = 2;
    hplt.Color = [hplt.Color 0.7];
end
title(hsub(c+1),'actigraphy');
legend({'x','y','z'});
linkaxes(hsub,'x');
for h = 1:length(hsub)
    hsub(h).YLimMode = 'auto';
end
cntplt = cntplt+1; 

% plot adaptive 
timesAdaptive = adaptiveTable.derivedTimes;
idxuseAdaptive = timesAdaptive > timeStart & timesAdaptive < timeEnd;

hsub(cntplt) = subplot(nrows,ncols,cntplt); 
hold(hsub(cntplt),'on');
ld0 = adaptiveTable.LD0_output(idxuseAdaptive); 
ld0_high = adaptiveTable.LD0_highThreshold(idxuseAdaptive); 
ld0_low  = adaptiveTable.LD0_lowThreshold(idxuseAdaptive); 
timeUse = adaptiveTable.derivedTimes(idxuseAdaptive);
plot(hsub(cntplt),timeUse,ld0,'LineWidth',3);
hplt = plot(hsub(cntplt),timeUse,ld0_high,'LineWidth',3);
hplt.LineStyle = '-.';
hplt.Color = [hplt.Color 0.7];
hplt = plot(hsub(cntplt),timeUse,ld0_low,'LineWidth',3);
hplt.LineStyle = '-.';
hplt.Color = [hplt.Color 0.7];


ylimsUse(1) = adaptiveTable.LD0_lowThreshold(1)*0.2;
ylimsUse(2) = adaptiveTable.LD0_highThreshold(1)*1.8;


ylimsUse(1) = prctile(ld0,1);
ylimsUse(2) = prctile(ld0,99);

ylim(hsub(cntplt),ylimsUse); 
title(hsub(cntplt),'Detector'); 
ylabel(hsub(cntplt),'Detector (a.u.)'); 
xlabel(hsub(cntplt),'Time'); 
legend(hsub(cntplt),{'Detector','Low threshold','High threshold'}); 
set(gca,'FontSize',12)
cntplt = cntplt + 1;

% state and current 
hsub(cntplt) = subplot(nrows,ncols,cntplt); 
hold(hsub(cntplt),'on');
title(hsub(cntplt),'state and current'); 
state = adaptiveTable.CurrentAdaptiveState(idxuseAdaptive);
hplt1 = plot(hsub(cntplt),timeUse,state,'LineWidth',3); 
hplt1.Color = [0.8 0.8 0 0.7]; 
% assuming only one program defined: 
cur = adaptiveTable.CurrentProgramAmplitudesInMilliamps(idxuseAdaptive,1); 
hplt2 = plot(hsub(cntplt),timeUse,cur,'LineWidth',3); 
hplt2.Color = [0.8 0.8 0 0.2]; 
ylim([-1 4]);
legend([hplt1 hplt2],{'state','current'}); 
set(hsub(cntplt),'FontSize',12)
cntplt = cntplt + 1;

% power 
timesPower = powerOut.powerTable.derivedTimes;
idxusePower = timesPower > timeStart & timesPower < timeEnd;

hsub(cntplt) = subplot(nrows,ncols,cntplt); 
powerTable = powerOut.powerTable; 
plot(hsub(cntplt),powerTable.derivedTimes(idxusePower),powerTable.Band1(idxusePower)); 
title(hsub(cntplt),powerOut.bands(1).powerBandInHz{1});


% link all axes 
linkaxes(hsub,'x');


end