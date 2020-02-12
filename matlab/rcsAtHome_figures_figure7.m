function rcsAtHome_figures_figure7()
%% stn beta activity is detectable during stim 
% panel a - single subject - on , off and chornic stim 
% panel b plot violin plots of average beta power 
% panel c - plot embedded adaptive data 
close all;

plotpanels = 0;
addpath(genpath(fullfile(pwd,'toolboxes','panel-2.14')));
if ~plotpanels
    hfig = figure;
    hfig.Color = 'w';
    hpanel = panel();
    hpanel.pack({0.4, 0.6});
    hpanel(1).pack(1,3); % panel a + b 
    hpanel(2).pack(3,1); % panel c adaptive 
%     hpanel.select('all');
%     hpanel.identify();

end

%% panel A - single subject - on , off and chornic stim 
dirsave = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/results/long_term_stim_on_stim_off'; 
load(fullfile(dirsave,'psd_at_home_stim_on_vs_stim_off.mat'),'psdResultsBoth'); 
load('/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/pkg_data/figures/pkg_states RCS02 R pkg L _10_min_avgerage.mat')
addpath(genpath(fullfile(pwd,'toolboxes','shadedErrorBar')))
if plotpanels
    hfig = figure();
    hfig.Color = 'w';
end
% on stim vs off stim 
% d = 1 - 
stimstate = {'off stim','on chronic stim'}; 
statesuse = {'off','on'};
colorsUse = [0.5 0.5 0.5;
          0   0.8   0];
titles = {'STN 0-2','STN 1-3','M1 8-10','M1 9-11'};
cntplt = 1;
if ~plotpanels
    hSub = gobjects(3,1);
end
for c = [2 4]
    if plotpanels
        hSub(cntplt) = subplot(2,2,cntplt); cntplt = cntplt+1;
    else
        hpanel(1,1,cntplt).select(); cntplt = cntplt + 1; 
        hSub(cntplt,1) = gca;
    end
            
    
    hold on; 
    for d = 1:2
        fn = sprintf('key%dfftOut',c-1);
        if d == 2   % on stim 
            psdResults = psdResultsBoth(2);
            fftOut = psdResults.(fn)(psdResults.idxkeep,:);
            ff = psdResults.ff;
        else
            fftOut = allDataPkgRcsAcc.(fn); 
            ff = psdResults.ff;
        end
        idxusefreq = ff >= 13 &  ff <= 30; 
        
        % normalize the data 
        dat = fftOut;
        idxnormalize = psdResults.ff > 3 &  psdResults.ff <90;
        meandat = abs(mean(dat(:,idxnormalize),2)); % mean within range, by row
        % the absolute is to make sure 1/f curve is not flipped
        % since PSD values are negative
        meanmat = repmat(meandat,1,size(dat,2));
        dat = dat./meanmat;
        fftOut = dat;
        
        meanbetafreq{c,d} = mean(fftOut(:,idxusefreq),2);
        
        idxusefreq = ff >= 65 &  ff <= 85;
        meangammafreq{c,d} = mean(fftOut(:,idxusefreq),2);

        
        
        hsb = shadedErrorBar(ff,fftOut,{@median,@(x) std(x)*2});
        hsb.mainLine.Color = [colorsUse(d,:) 0.5];
        hsb.mainLine.LineWidth = 2;
        hsb.patch.MarkerFaceColor = colorsUse(d,:);
        hsb.patch.FaceColor = colorsUse(d,:);
        hsb.patch.EdgeColor = colorsUse(d,:);
        hsb.edge(1).Color = [colorsUse(d,:) 0.1];
        hsb.edge(2).Color = [colorsUse(d,:) 0.1];
        hsb.patch.EdgeAlpha = 0.1;
        hsb.patch.FaceAlpha = 0.1;
        xlabel('Frequency (Hz)');
        ylabel('Norm. power (a.u.)');
        title(titles{c}); 
        set(gca,'FontSize',16); 
        hlines(d) = hsb.mainLine;
        xlim([3 100]);
    end
    legend(hlines,stimstate); 
%     totalhours = (length(psdResults.timeStart(psdResults.idxkeep))*10)/60;
%     fprintf('total hours %d %s\n',totalhours,stimstate{d});
end
if plotpanels
    sgtitle('RCS02 L','FontSize',25);
    
    figname = sprintf('on stim vs off stim_ %s %s v2','RCS02','L');
    prfig.plotwidth           = 15;
    prfig.plotheight          = 10;
    prfig.figname             = figname;
    prfig.figdir              = dirsave;
    plot_hfig(hfig,prfig)
end
%% 

%% panel b plot violin plots of average beta power 
addpath(genpath(fullfile(pwd,'toolboxes','violin')));
patients = {'RCS02','RCS05'}; 
patients = {'RCS01','RCS02'}; % renamed for paper  
betapeaks = [27 19 20];
cnlsuse = [1 0];
width = 2.5; 
cntpt = 1; 

dirsave = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/results/long_term_stim_on_stim_off'; 
load(fullfile(dirsave,'psd_at_home_stim_on_vs_stim_off.mat'),'psdResultsBoth'); 


psdresultsfn{1,cntpt} = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home/RCS02/psdResults_L.mat'; % off stim 
psdresultsfn{2,cntpt} = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/results/long_term_stim_on_stim_off/psdResults_on_stim.mat'; % on stim 
cntpt = cntpt+1; 

psdresultsfn{1,cntpt} = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home/RCS05/psdResults_R.mat'; % off stim 
psdresultsfn{2,cntpt} = '/Volumes/RCS_DATA/RCS05/data_dump/SummitContinuousBilateralStreaming/RCS05R/psdResults.mat'; % on stim 

cntpt = cntpt+1; 

cnttoplot = 1; 
colorsuse = [0.5 0.5 0.5; 0 0.8 0]; 
stimstate = {'off stim','on stim'}; 


if plotpanels
    hfig = figure;
    hsb = subplot(1,1,1);
    hfig.Color = 'w';
else
    hpanel(1,1,cntplt).select(); cntplt = cntplt + 1;
    hSub = gca;
end

nrows = length(patients); 
ncols = 2; 
for p = 1:size(psdresultsfn,2)
    for i = 1:2
        load(psdresultsfn{i,p});
        ff = fftResultsTd.ff;

        % normalize the data
        fnuse = sprintf('key%dfftOut',cnlsuse(p));
        hoursrec = hour(fftResultsTd.timeStart);
        idxhoursuse = (hoursrec >= 8) & (hoursrec <= 22); 
        fftOut = fftResultsTd.(fnuse)(:,idxhoursuse);
        timesout = fftResultsTd.timeStart(idxhoursuse);
        
        meanVals = mean(fftOut(40:60,:));
        q75_test=quantile(meanVals,0.75);
        q25_test=quantile(meanVals,0.25);
        w=2.0;
        wUpper = w*(q75_test-q25_test)+q75_test;
        wLower = q25_test-w*(q75_test-q25_test);
        idxWhisker = (meanVals' < wUpper) & (meanVals' > wLower);
        fftOut = fftOut(:,idxWhisker);
        timesout = timesout(idxWhisker);
        
        dat = fftOut;
        idxnormalize = ff > 3 &  ff <90;
        meandat = repmat(mean(abs(mean(dat(:,idxnormalize),2))),length(ff),1); % mean within range, by row
        % the absolute is to make sure 1/f curve is not flipped
        % since PSD values are negative
        meanmat = repmat(meandat,1,size(dat,2));
        dat = dat./meanmat;
        fftOut = dat;
        
        xlim([3 100]);
        % use peaks or individual peaks
        idxusefreq = ff >= 13 &  ff <= 30;
        % individual peaks 
        idxusefreq = ff >= (betapeaks(p)-width) &  ff <= (betapeaks(p)+width);
        
        meanbetafreq{p,i} = mean(fftOut(idxusefreq,:),1);
        times{p,i} = timesout;
        toplot{1,cnttoplot} = mean(fftOut(idxusefreq,:),1);
        xtics(cnttoplot)  = cnttoplot; 
        xticklab = sprintf('%s %s',patients{p},stimstate{i});
        xtickalbs{cnttoplot} = xticklab; 
        coloruse(cnttoplot,:) = colorsuse(i,:);
        cnttoplot = cnttoplot + 1; 
        ylabel('Norm. power');
        set(gca,'FontSize',16); 
    end
end


hviolin  = violin(toplot);
ylabel('Average norm. beta power'); 
hSub.XTick = xtics;
hSub.XTickLabel  = xtickalbs;
hSub.XTickLabelRotation = 30;
ylim([-1.1 -0.45]);
for h = 1:length(hviolin)
    hviolin(h).FaceColor =  coloruse(h,:);
    hviolin(h).FaceAlpha = 0.3;
end

title('effect of chronic stim');
%% 

%% panel C - plot embedded adaptive data 
params.adaptiveFolder   = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/v14_adaptive_before_sending_home/RCS02R/Session1570736950940/DeviceNPC700404H';
params.window           = seconds(30); % size of window you want 
params.advance          = seconds(0.1); 
params.runToPlot        = 5; % run to plot - see results of plot_alligned_data_in_folder() on this folder 
params.vidFname         = sprintf('all_data_alligned_v3_%0.2d.mp4',params.runToPlot);
params.vidOut           = fullfile(params.adaptiveFolder,params.vidFname); 

% plot alligned data 
dirname = params.adaptiveFolder;
fnmload = fullfile(params.adaptiveFolder,'all_data_alligned.mat'); 
if exist(fnmload,'file')
    load_and_save_alligned_data_in_folder(dirname);
    load(fnmload,'outdatcomplete','outdatcompleteAcc','outRec',...
    'eventTable','powerOut','adaptiveTable','adaptiveStruc','senseStruc','embeddedStartEndTimes','adaptiveInfo');
else
    load(fnmload,'outdatcomplete','outdatcompleteAcc','outRec',...
    'eventTable','powerOut','adaptiveTable','adaptiveStruc','senseStruc','embeddedStartEndTimes','adaptiveInfo');

end
figdir = fullfile(dirname,'figures'); 
mkdir(figdir); 

% plot alligned data 
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

nrows = 3; 
ncols = 1; 
cntplt = 1;
for e = params.runToPlot% 1:length(startTimes)
    
    if plotpanels
        hfig = figure;
        hfig.Position = [45           1        1636         954];
        hfig.Color = 'w';
    end

    % plot one figure for each adaptive "session".
    % this should include:
    
    % splot settings 
    % settings
%     hsub(cntplt) = subplot(nrows,ncols,cntplt); cntplt = cntplt + 1;
%     set(gca,'FontSize',16);
%     set(gca, 'box','off','XTickLabel',[],'XTick',[],'YTickLabel',[],'YTick',[])
% 
%     a = annotation('textbox', hsub(1).Position, 'String', "hi");
%     a.FontSize = 14;


    % power 
    strline = 1;
    strOut{strline} = 'settings'; 
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
    
    strOut{3} = sprintf('each FFT represents %d ms of data (fft size %d sr %d Hz)',...
        ceil((fftsize/sr).*1000), fftsize,sr);
    updateRate = adaptiveInfo(e).UpdateRate; 
    
    strOut{strline} = sprintf('%d ffts are averaged - %d ms of data before being input to LD',updateRate,ceil((fftsize/sr).*1000)*updateRate);    
    strline = strline + 1; 

    strOut{strline} = sprintf('update rate %d onset %d termination %d state change blank %d',...
        adaptiveInfo(e).UpdateRate,...
        adaptiveInfo(e).OnsetDuration,...
        adaptiveInfo(e).TerminationDuration,...
        adaptiveInfo(e).StateChangeBlankingUponStateChange);
    strline = strline + 1; 

    
    strOut{strline} = sprintf('ramp up rate %.2f mA/sec\t ramp down rate %.2f mA/sec\t',...
        adaptiveInfo(e).rampUpRatePerSec,...
        adaptiveInfo(e).rampDownRatePerSec);
    strline = strline + 1;

    % suplot 2
    if plotpanels
        hsub(cntplt) = subplot(nrows,ncols,cntplt); cntplt = cntplt + 1;
    else
        hpanel(2,cntplt,1).select(); cntplt = cntplt + 1;
        hsub(cntplt,1) = gca;
    end
    
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
    [b,a]        = butter(3,[bandsUsed(1) bandsUsed(end)] / (sr/2),'bandpass'); % user 3rd order butter filter
    y_filt       = filtfilt(b,a,tddata); %filter all
    y_filt_hilbert       = abs(hilbert(y_filt));
    ydatRescaled = rescale(y_filt,0.55,1);
    y_filt_hilbertRescaled = rescale(y_filt_hilbert,0.55+(1-0.55)/2,1);
    
    
    up = y_filt_hilbert; 
    thresh = prctile(y_filt_hilbert,75); 
    % find start and end indices of line crossing threshold
    startidx = find(diff(up > thresh) == 1) + 1;
    endidx = find(diff(up > thresh) == -1) + 1;
    endidx = endidx(endidx > startidx(1));
    startidx = startidx(1:length(endidx));
    for b = 1:size(startidx,1)
        bursts.len(b) = secs(endidx(b)) - secs(startidx(b));
        bursts.amp(b) = max(up(startidx(b):endidx(b)));
    end
    % make all scales duration based: 
    secs = secs - secs(1); 
    % subtract a ceratin number of seconds so output graph is centerd on
    % zero 
    secs = secs - seconds(63);
    % 
    plot(secs,ydatRescaled,'LineWidth',0.5,'Color',[0 0 0.8 0.2]);
    plot(secs,y_filt_hilbertRescaled,'LineWidth',3,'Color',[0.8 0 0 0.6]);
    % 2. adaptive power
    secsPower = powerOut.powerTable.derivedTimes;
    idxusePower = secsPower >= startTimes(e) & secsPower <= endTimes(e);
    powerVals = powerOut.powerTable.(adaptiveInfo(e).bandsUsedName);
    secsPower = secsPower(idxusePower);
    powerVals = powerVals(idxusePower);
    powerValsRescaled = rescale(powerVals,0.1,0.5);
    % make all scales duration based: 
    secsPower = secsPower - secsPower(1); 
    % 
%     plot(secsPower,powerValsRescaled,'LineWidth',3,'Color',[0 0.8 0 0.6]);
    ylabel('power - td & embedded (a.u.)');
    ylabel('Beta LFP');
    title('Time Domain Data (filtered in Beta range)');
    set(gca,'FontSize',16);
    set(gca,'XTick',[]);
    
    % suplot 3
    if plotpanels
        hsub(cntplt) = subplot(nrows,ncols,cntplt); cntplt = cntplt + 1;
    else
        hpanel(2,cntplt,1).select(); cntplt = cntplt + 1;
        hsub(cntplt,1) = gca;
    end
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
    % make all scales duration based:
    secsAdaptive = secsAdaptive - secsAdaptive(1);
    % subtract a ceratin number of seconds so output graph is centerd on
    % zero 
    secsAdaptive = secsAdaptive - seconds(63);
    %
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
    set(gca,'XTick',[]);
    
    % subplot 4
    if plotpanels
        hsub(cntplt) = subplot(nrows,ncols,cntplt); cntplt = cntplt + 1;
    else
        hpanel(2,cntplt,1).select(); cntplt = cntplt + 1;
        hsub(cntplt,1) = gca;
    end
    hold on;
    plot(secsAdaptive,current,'LineWidth',3,'Color',[0.8 0 0 0.6]);
    avgCurrent = mean(current); 
    title(sprintf('Current %.2f (mean)',avgCurrent)); 
    title(sprintf('Current',avgCurrent)); 
    ylabel('Current (mA)'); 
    set(gca,'FontSize',16);
    
    figTitle = sprintf('%s %s run %.2d',adaptiveInfo(e).patient,...
        adaptiveInfo(e).duration,e);
%     sgtitle(figTitle,'FontSize',20); 
    
    figSaveName = sprintf('%.2d_embedded_%s',e,adaptiveInfo(e).patient);
    figsaveFullName = fullfile(figdir,figSaveName);
    

    % save figure; 
    xlabel('Time (seconds');
    linkaxes(hsub,'x');
    set(gca,'XLim',[duration('00:00:00') duration('00:00:39')]);
    xtickformat('mm:ss');
end
%% 


%% 

if ~plotpanels
%%    
figdirout = '/Users/roee/Starr_Lab_Folder/Writing/papers/2019_LongTerm_RCS_recordings/figures/final_figures/Fig7_effect_of_stim_and_adaptive';
hpanel.fontsize = 10; 
hLegend = findobj(gcf, 'Type', 'Legend');
hLegend(1).FontSize = 9;
hLegend(1).FontName = 'Helvetica';
hLegend(1).FontWeight = 'normal';

hpanel(1,1).de.margin = 20; 
hpanel(1,1).de.marginbottom = 20; 
hpanel(2).de.margin = 10; 
hpanel(2).margintop = 30;
hpanel.margin = [20 20 20 20];
prfig.plotwidth           = 8;
prfig.plotheight          = 10;
prfig.figdir             = figdirout;
prfig.figname             = 'Fig7_all_v5';
prfig.figtype             = '-dpdf';
plot_hfig(hfig,prfig)

end

return 

%% potentioan panel D - compare burst durations 
% open loop folder - run 3 
clear params y_filt_hilbert
params.adaptiveFolder{1}   = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/v16_adaptive_4_months_beta_thermostat/RCS02L/Session1572281066593/DeviceNPC700398H';
params.adaptiveFolder{2}   = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/v14_adaptive_before_sending_home/RCS02R/Session1570736950940/DeviceNPC700404H';
params.window           = seconds(30); % size of window you want 
params.advance          = seconds(0.1); 
params.runToPlot(1)        = 3; % run to plot - see results of plot_alligned_data_in_folder() on this folder 
params.runToPlot(2)        = 5; % run to plot - see results of plot_alligned_data_in_folder() on this folder 

for aaa = 1:length(params.adaptiveFolder)
    % plot alligned data
    dirname = params.adaptiveFolder{aaa};
    fnmload = fullfile(dirname,'all_data_alligned.mat');
    if exist(fnmload,'file')
        load_and_save_alligned_data_in_folder(dirname);
        load(fnmload,'outdatcomplete','outdatcompleteAcc','outRec',...
            'eventTable','powerOut','adaptiveTable','adaptiveStruc','senseStruc','embeddedStartEndTimes','adaptiveInfo');
    else
        load(fnmload,'outdatcomplete','outdatcompleteAcc','outRec',...
            'eventTable','powerOut','adaptiveTable','adaptiveStruc','senseStruc','embeddedStartEndTimes','adaptiveInfo');
        
    end
    figdir = fullfile(dirname,'figures');
    mkdir(figdir);
    
    % plot alligned data
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
    plotpanels = 1;
    for e = params.runToPlot(aaa)
        
        % suplot 2
        if plotpanels
            %         hsub(cntplt) = subplot(nrows,ncols,cntplt); cntplt = cntplt + 1;
        else
            hpanel(2,cntplt,1).select(); cntplt = cntplt + 1;
            hsub(cntplt,1) = gca;
        end
        
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
        bandsUsed = [17.57 21.48];
        sr = adaptiveInfo(e).SampleRate;
        tddata = tddata - mean(tddata);
        [b,a]        = butter(3,[bandsUsed(1) bandsUsed(end)] / (sr/2),'bandpass'); % user 3rd order butter filter
        y_filt       = filtfilt(b,a,tddata); %filter all
        y_filt_hilbert{aaa}       = abs(hilbert(y_filt));
        secsUse{aaa} = secs; 
        
    end
end
% plot the joint 75% threshold 
hfig = figure;
clear y secsplot1 secsplot2 bursts secsburst
hfig.Color = 'w'; 
subplot(2,1,1); 
hold on;
% open loop 
idxlenopenloop = length(secsUse{1});
secsplot1 = secsUse{1}(1:idxlenopenloop) - secsUse{1}(1);
secsburst(:,1) = secsplot1; 
plot(secsplot1,y_filt_hilbert{1}(1:idxlenopenloop)) 
y(:,1) = y_filt_hilbert{1}(1:idxlenopenloop);

secsplot2 = (secsUse{2}(1:idxlenopenloop) -secsUse{2}(1))  + (secsplot1(end)+ seconds(10));
secsburst(:,2) = (secsUse{2}(1:idxlenopenloop) -secsUse{2}(1)); 
plot(secsplot2,y_filt_hilbert{2}(1:idxlenopenloop));
y(:,2) = y_filt_hilbert{2}(1:idxlenopenloop);
thresh = prctile(y(:),75);
plot([secsplot1(1) secsplot2(end)], [thresh thresh],'LineWidth',3,'LineStyle','-.'); 
legend({'open loop','adaptive','75th percentile'}); 
title('Hilbert - band passed beta')' 
ylabel('beta amtplitude envelope - hilbert'); 
xlabel('time (seconds)');
set(gca,'FontSize',16);

for i = 1:2
    up = y(:,i); 
    secs = secsburst(:,i);
    % find start and end indices of line crossing threshold
    startidx = find(diff(up > thresh) == 1) + 1;
    endidx = find(diff(up > thresh) == -1) + 1;
    endidx = endidx(endidx > startidx(1));
    startidx = startidx(1:length(endidx));
    for b = 1:size(startidx,1)
        bursts(i).len(b) = secs(endidx(b)) - secs(startidx(b));
        bursts(i).amp(b) = max(up(startidx(b):endidx(b)));
    end
end
subplot(2,1,2); 
hold on; 
histogram(seconds(bursts(1).len).*1000,'Normalization','probability','BinWidth',50);
histogram(seconds(bursts(2).len).*1000,'Normalization','probability','BinWidth',50);
legend({'open loop','adaptive'})
ylabel('probability'); 
xlabel('burst length (ms)'); 
set(gca,'FontSize',16);
%%

%% previous panel A - single subject - on , off and chornic stim 
dirsave = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/results/long_term_stim_on_stim_off'; 
load(fullfile(dirsave,'psd_at_home_stim_on_vs_stim_off.mat'),'psdResultsBoth'); 
load('/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/pkg_data/figures/pkg_states RCS02 R pkg L _10_min_avgerage.mat')
addpath(genpath(fullfile(pwd,'toolboxes','shadedErrorBar')))
if plotpanels
    hfig = figure();
    hfig.Color = 'w';
end
% on stim vs off stim 
% d = 1 - 
stimstate = {'off stim - imobile','off stim - mobile','on chronic stim'}; 
statesuse = {'off','on'};
colorsUse = [0.8 0 0;
          0   0.8 0,
          0   0   0.8];
titles = {'STN 0-2','STN 1-3','M1 8-10','M1 9-11'};
cntplt = 1;
if ~plotpanels
    hSub = gobjects(3,1);
end
for c = [2 4]
    if plotpanels
        hSub(cntplt) = subplot(2,2,cntplt); cntplt = cntplt+1;
    else
        hpanel(1,1,cntplt).select(); cntplt = cntplt + 1; 
        hSub(cntplt,1) = gca;
    end
            
    
    hold on; 
    for d = 1:3
        fn = sprintf('key%dfftOut',c-1);
        if d >=3  % on stim 
            psdResults = psdResultsBoth(2);
            fftOut = psdResults.(fn)(psdResults.idxkeep,:);
            ff = psdResults.ff;
        else
            fftOutRaw = allDataPkgRcsAcc.(fn); 
            idxusestate = strcmp(allstates,statesuse{d});
            fftOut = fftOutRaw(idxusestate,:); 
            ff = psdResults.ff;
        end
        idxusefreq = ff >= 13 &  ff <= 30; 
        meanbetafreq{c,d} = mean(fftOut(:,idxusefreq),2);
        
        idxusefreq = ff >= 65 &  ff <= 85;
        meangammafreq{c,d} = mean(fftOut(:,idxusefreq),2);
        
        % normalize the data 
        dat = fftOut;
        idxnormalize = psdResults.ff > 3 &  psdResults.ff <90;
        meandat = abs(mean(dat(:,idxnormalize),2)); % mean within range, by row
        % the absolute is to make sure 1/f curve is not flipped
        % since PSD values are negative
        meanmat = repmat(meandat,1,size(dat,2));
        dat = dat./meanmat;
        fftOut = dat;
        
        
        hsb = shadedErrorBar(ff,fftOut,{@median,@(x) std(x)*2});
        hsb.mainLine.Color = [colorsUse(d,:) 0.5];
        hsb.mainLine.LineWidth = 2;
        hsb.patch.MarkerFaceColor = colorsUse(d,:);
        hsb.patch.FaceColor = colorsUse(d,:);
        hsb.patch.EdgeColor = colorsUse(d,:);
        hsb.edge(1).Color = [colorsUse(d,:) 0.1];
        hsb.edge(2).Color = [colorsUse(d,:) 0.1];
        hsb.patch.EdgeAlpha = 0.1;
        hsb.patch.FaceAlpha = 0.1;
        xlabel('Frequency (Hz)');
        ylabel('Norm. power (a.u.)');
        title(titles{c}); 
        set(gca,'FontSize',16); 
        hlines(d) = hsb.mainLine;
        xlim([0 130]);
    end
    legend(hlines,stimstate); 
%     totalhours = (length(psdResults.timeStart(psdResults.idxkeep))*10)/60;
%     fprintf('total hours %d %s\n',totalhours,stimstate{d});
end
if plotpanels
    sgtitle('RCS02 L','FontSize',25);
    
    figname = sprintf('on stim vs off stim_ %s %s v2','RCS02','L');
    prfig.plotwidth           = 15;
    prfig.plotheight          = 10;
    prfig.figname             = figname;
    prfig.figdir              = dirsave;
    plot_hfig(hfig,prfig)
end
%% 


%% previoous panel b plot violin plots of average beta power 
addpath(genpath(fullfile(pwd,'toolboxes','violin')));
% toplot{1,1} = meanbetafreq{2,1}; % off off stim 
% toplot{1,2} = meanbetafreq{2,2}; % off off stim 
% toplot{1,3} = meanbetafreq{2,3}; % on stim 
% toplot{1,4} = [ meanbetafreq{2,1} ; meanbetafreq{2,2}];

toplot{1,1} = [ meanbetafreq{2,1} ; meanbetafreq{2,2}];
toplot{1,2} = meanbetafreq{2,3}; % on stim 


if plotpanels
    hfig = figure;
    hsb = subplot(1,1,1);
    hfig.Color = 'w';
else
    hpanel(1,1,cntplt).select(); cntplt = cntplt + 1;
    hSub(cntplt,1) = gca;
end
% hviolin  = violin(toplot);
% hviolin(1).FaceColor = [0.8 0 0];
% hviolin(1).FaceAlpha = 0.3;
% 
% hviolin(2).FaceColor = [0 0.8 0];
% hviolin(2).FaceAlpha = 0.3;
% 
% hviolin(3).FaceColor = [0 0 0.8];
% hviolin(3).FaceAlpha = 0.3;
% 
% hviolin(4).FaceColor = [0.5 0.5 0.5];
% hviolin(4).FaceAlpha = 0.3;

hviolin  = violin(toplot);
hviolin(1).FaceColor = [0.5 0.5 0.5];
hviolin(1).FaceAlpha = 0.3;

hviolin(2).FaceColor = [0 0.8 0];
hviolin(2).FaceAlpha = 0.3;


ylabel('Average beta power'); 

hsb = hSub(cntplt,1);

% hsb.XTick = [ 1 2 3 4]; 
% hsb.XTickLabel  = {'off stim imobile', 'off stim mobile','on chornic stim','before stim'}; 
hsb.XTick = [ 1 2 ]; 
hsb.XTickLabel  = {'off stim','on chornic stim'};
hsb.XTickLabelRotation = 30;

title('effect of chronic stim RCS02 L'); 

set(gca,'FontSize',16); 
if plotpanels
    figname = sprintf('on stim vs off stim_ %s %s violin','RCS02','L');
    prfig.plotwidth           = 5;
    prfig.plotheight          = 5;
    prfig.figname             = figname;
    prfig.figdir              = dirsave;
    plot_hfig(hfig,prfig)
end
%% 
