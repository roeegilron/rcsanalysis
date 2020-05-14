%% Analysis of floor noise in time and frequency for test bench configurations
close all; clear all; clc

%% Binary arguments
figFullScreen = 1;
<<<<<<< HEAD
plotFFTsettings = 0;
plot2Detectors = 1;
adaptiveOn = 1;
showRawSignal = 0;
focusThreshold = 0;
showStateChanges = 0;
calculatePSD = 1;
lineWidth = 1;
saveFigures = 0;

%% adding path to json toolbox 
addpath([pwd,'/toolboxes/turtle_json/src/'])

%% load data
dirname = uigetdir('/Users/juananso/Dropbox (Personal)/Work/DATA/benchtop/selfTriggering')
=======
showRawSignal = 1;
calculatePSD = 1;
saveFigures = 1;

%% adding path to json toolbox 

%% load data
dirname = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS07/v19_stim_titration_1/rcs_data/StarrLab/RCS07L/Session1586881685668/DeviceNPC700419H';
>>>>>>> df49cb1c5be760ef19ff6568a6c1779a7d9e4b69
[outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerTable] = MAIN_load_rcs_data_from_folder(dirname);
fnAdaptive = fullfile(dirname,'AdaptiveLog.json'); 
fnDeviceSettings = fullfile(dirname,'DeviceSettings.mat');
res = readAdaptiveJson(fnAdaptive); 
<<<<<<< HEAD
if plotFFTsettings
devSettings = readDevSettings(fnDeviceSettings);
end
=======
devSettings = readDevSettings(fnDeviceSettings);
>>>>>>> df49cb1c5be760ef19ff6568a6c1779a7d9e4b69
saveFigDir = fullfile(dirname,'/Figures');
if ~isfolder(saveFigDir)
    mkdir(saveFigDir)
end

%% Extract parameters
sr = outdatcomplete.samplerate(1);
<<<<<<< HEAD
if adaptiveOn
    stimRate = res.adaptive.StimRateInHz;
else
    stimRate = 0;
end

if plotFFTsettings
fftSettings = devSettings.fft;
end
=======
stimRate = res.adaptive.StimRateInHz;
fftSettings = devSettings.fft;
>>>>>>> df49cb1c5be760ef19ff6568a6c1779a7d9e4b69
titleUse = strcat(outRec(1).tdData(1).chanFullStr,' stimRate-',num2str(stimRate(1)),'Hz'); 

%% Get time values
idxTimeCompare = find(outdatcomplete.PacketRxUnixTime~=0,1);
packRxTimeRaw  = outdatcomplete.PacketRxUnixTime(idxTimeCompare); 
packtRxTime    =  datetime(packRxTimeRaw/1000,...
            'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
derivedTime    = outdatcomplete.derivedTimes(idxTimeCompare); 
timeDiff       = derivedTime - packtRxTime;
time_ms = milliseconds(outdatcomplete.derivedTimes-outdatcomplete.derivedTimes(1))/1000;

%% creating main figure and adding settings of signal and FFT 
fig1 = figure;
if figFullScreen
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
    fontSize = 16;
else
    fontSize = 12;
end

<<<<<<< HEAD
if plotFFTsettings
    ax = subplot(511);
    % text(0.1,1,titleUse,'FontSize',fontSize)
    text(0.1,0.75,strcat('FFT properties:'),'FontSize',fontSize);
    text(0.1,0.5,strcat('interval = ', num2str(fftSettings.interval),' ms'),'FontSize',fontSize);
    text(0.1,0.25,strcat('size = ', num2str(fftSettings.size),' points'),'FontSize',fontSize);
    text(0.1,0,strcat('windowLoad = ', num2str(fftSettings.windowLoad),' %'),'FontSize',fontSize);
    set ( ax, 'visible', 'off')
end
=======
ax = subplot(511);
% text(0.1,1,titleUse,'FontSize',fontSize)
text(0.1,0.75,strcat('FFT properties:'),'FontSize',fontSize);
text(0.1,0.5,strcat('interval = ', num2str(fftSettings.interval),' ms'),'FontSize',fontSize);
text(0.1,0.25,strcat('size = ', num2str(fftSettings.size),' points'),'FontSize',fontSize);
text(0.1,0,strcat('windowLoad = ', num2str(fftSettings.windowLoad),' %'),'FontSize',fontSize);
set ( ax, 'visible', 'off')
>>>>>>> df49cb1c5be760ef19ff6568a6c1779a7d9e4b69

%% plot time series
y = (outdatcomplete.key0*1e3); % transform data from millivolts to microvolts
y = y-mean(y);

% create and apply notch fitler, Quality factor q = w0/bw, where w0 is the notch frequency.
wo = 60/(sr/2);  
bw = wo/5;
[b,a] = iirnotch(wo,bw);
y_filt = filtfilt(b,a,y);
wo = 120/(sr/2);  
bw = wo/35; 
[b,a] = iirnotch(wo,bw);
y_filt_2 = filtfilt(b,a,y_filt);
<<<<<<< HEAD
% wo = 180/(sr/2);  
% bw = wo/35; 
% [b,a] = iirnotch(wo,bw);
% y_filt_3 = filtfilt(b,a,y_filt_2);
y_filt_3 = y_filt_2;

if plotFFTsettings
    ax0 = subplot(512);
else
    ax0 = subplot(411);
end

=======
wo = 180/(sr/2);  
bw = wo/35; 
[b,a] = iirnotch(wo,bw);
y_filt_3 = filtfilt(b,a,y_filt_2);

ax0 = subplot(512);
>>>>>>> df49cb1c5be760ef19ff6568a6c1779a7d9e4b69
if showRawSignal
    plot(time_ms,y);
    hold on
end
<<<<<<< HEAD
plot(time_ms,y_filt_3,'k');
=======
plot(time_ms,y_filt_3,'r');
>>>>>>> df49cb1c5be760ef19ff6568a6c1779a7d9e4b69
title(titleUse);
ylabel('Voltage (\muV)')
set(gca,'FontSize',fontSize);
% xlabel('Time (s)')
% legend('time series')
% axis([0 max(x) -200 200])

<<<<<<< HEAD
%% rms floor noise amplitude
samp5secs = sr*5;
rmsSig5secs = rms(y_filt_3(1:samp5secs))

%% Plot spectrogram
fig2 = figure(2);
spectrogram(y_filt_3,128,120,128,sr,'yaxis')

%% plot detectors 
if adaptiveOn
    timestamps = datetime(datevec(res.timing.timestamp./86400 + datenum(2000,3,1,0,0,0))); % medtronic time - LSB is seconds
    uxtimes = datetime(res.timing.PacketGenTime/1000,...
        'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
    yearUse = mode(year(uxtimes)); 
    idxKeepYear = year(uxtimes)==yearUse;

    ld0 = res.adaptive.LD0_output(idxKeepYear);
    ld0_high = res.adaptive.LD0_highThreshold(idxKeepYear);
    ld0_low  = res.adaptive.LD0_lowThreshold(idxKeepYear);
    
    ld1 = res.adaptive.LD1_output(idxKeepYear);
    ld1_high = res.adaptive.LD1_highThreshold(idxKeepYear);
    ld1_low  = res.adaptive.LD1_lowThreshold(idxKeepYear);
    
    timesUseDetector = uxtimes(idxKeepYear); 
    time_ms_LD = milliseconds(timesUseDetector-timesUseDetector(1))/1000;

    figure(1)
    if plotFFTsettings
        ax1 = subplot(513);
    else
        ax1 = subplot(412);
    end
    
    hold on
    
    if plot2Detectors 
        
        [ax,h1,h2] = plotyy(time_ms_LD,ld0,time_ms_LD,ld1);
        set(h1,'Color','m','LineWidth',lineWidth);
        set(h2,'Color','c','LineWidth',lineWidth);
        set(ax,{'ycolor'},{'m';'c'}) 
        
        hold(ax(1),'on')
        hplt0h = plot(ax(1), time_ms_LD,ld0_high,'LineWidth',lineWidth,'LineStyle','-.','Color','m'); %         set(hplt0h,'Marker','o','Linestyle','--','Color','m');
        hplt0l = plot(ax(1), time_ms_LD,ld0_low,'LineWidth',lineWidth,'LineStyle',':','Color','m');
        hL1 = ylabel(ax(1),'Power (LSB)');
        set(hL1,'fontsize',fontSize,'color','m')
        
        hold(ax(2),'on')
        hplt1h = plot(ax(2), time_ms_LD,ld1_low,'LineWidth',lineWidth,'LineStyle','-.','Color','c');
        hplt1l = plot(ax(2), time_ms_LD,ld1_low,'LineWidth',lineWidth,'LineStyle',':','Color','c');        
        hL2 = ylabel(ax(2),'Power (LSB)');
        set(hL2,'fontsize',fontSize,'color','c')
        
        legend([h1;hplt0h;hplt0l;h2;hplt1h;hplt1l],'ld0','ld0 high','ld0 low','ld1','ld1 high','ld1 low')
        
    else
        plot(time_ms_LD,ld0,'LineWidth',lineWidth,'Color','m');
        hplt = plot(time_ms_LD,ld0_high,'LineWidth',lineWidth);
        hplt.LineStyle = '-.';
        hplt.Color = [hplt.Color 1];
        hplt = plot(time_ms_LD,ld0_low,'LineWidth',lineWidth);
        hplt.LineStyle = ':';
        hplt.Color = [hplt.Color 0.5];
        set(gca,'FontSize',fontSize);
        ylabel('Power (LSB)');
        if focusThreshold
            axis([0 time_ms_LD(end) 0 ld0_high(1)+(ld0_high(1)/2)])
        end
%         xlabel('Time (s)')
%         legend('LD0','LD0 th')
    end

    %% plot current
    cur = res.adaptive.CurrentProgramAmplitudesInMilliamps(1,idxKeepYear);
    if plotFFTsettings
        ax2 = subplot(514);
    else
        ax2 = subplot(413);
    end
    plot(time_ms_LD,cur(1:length(timesUseDetector)),'LineWidth',lineWidth,'Color','b');
    set(gca,'FontSize',fontSize); 
    ylabel('Current (mA)')
    % xlabel('Time (s)')

    %% plot state
    state = res.adaptive.CurrentAdaptiveState(1,idxKeepYear);
    if plotFFTsettings
        ax3 = subplot(515);
    else 
        ax3 = subplot(414);
    end
    plot(time_ms_LD,state(1:length(timesUseDetector)),'LineWidth',2,'color',[26,148,49]/255);
    set(gca,'FontSize',fontSize);
    ylabel('State (#)')
    xlabel('Time (s) (all plots)')

    %% plot state change
    stateDiff = diff(state);
    locs = find(stateDiff~=0);
    index = locs+1;
    figure(1)
    hold on
    
    if showStateChanges
        for ii=1:length(index)
            if plotFFTsettings
                subplot(512);
            else
                subplot(411);
            end
            hold on
            plot([time_ms_LD(index(ii)) time_ms_LD(index(ii))],[min(y) max(y)],'k:','LineWidth',1);
            if plotFFTsettings
                subplot(513)
            else
                subplot(412)
            end
            hold on
            plot([time_ms_LD(index(ii)) time_ms_LD(index(ii))],[0 max(ld0)],'k:','LineWidth',1);
            if plotFFTsettings
                subplot(514)
            else
                subplot(413)
            end
            hold on
            plot([time_ms_LD(index(ii)) time_ms_LD(index(ii))],[0 max(cur)],'k:','LineWidth',1);
            if plotFFTsettings
                subplot(515)
            else
                subplot(414)
            end
            hold on
            plot([time_ms_LD(index(ii)) time_ms_LD(index(ii))],[0 max(state)],'k:','LineWidth',1);
        end
    end
       
    %% link axes
    if plot2Detectors
        linkaxes([ax0,ax1,ax(2),ax2,ax3],'x');
    else
        linkaxes([ax0,ax1,ax2,ax3],'x');
    end
    
end % end adaptive on analysis

%% Amplitude spectral density, averaging version with pwelch, as Roee, but after having transformed to micrVolt
figure(2)
if calculatePSD
    [fftOut,ff]   = pwelch(y,sr,sr/2,0:1:sr/2,sr,'psd');
    [fftOut_filt,ff]   = pwelch(y_filt_3,sr,sr/2,0:1:sr/2,sr,'psd');
    fig3 = figure(3);
    plot(ff,log10(fftOut))
    hold on
    plot(ff,log10(fftOut_filt),'k')
=======
%% plot detector 
timestamps = datetime(datevec(res.timing.timestamp./86400 + datenum(2000,3,1,0,0,0))); % medtronic time - LSB is seconds
uxtimes = datetime(res.timing.PacketGenTime/1000,...
    'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
yearUse = mode(year(uxtimes)); 
idxKeepYear = year(uxtimes)==yearUse;

ld0 = res.adaptive.LD0_output(idxKeepYear);
ld0_high = res.adaptive.LD0_highThreshold(idxKeepYear);
ld0_low  = res.adaptive.LD0_lowThreshold(idxKeepYear);
timesUseDetector = uxtimes(idxKeepYear); 
time_ms_LD = milliseconds(timesUseDetector-timesUseDetector(1))/1000;

figure(1)
ax1 = subplot(513);
hold on
plot(time_ms_LD,ld0,'LineWidth',3);
hplt = plot(time_ms_LD,ld0_high,'LineWidth',3);
hplt.LineStyle = '-.';
hplt.Color = [hplt.Color 1];
hplt = plot(time_ms_LD,ld0_low,'LineWidth',3);
hplt.LineStyle = ':';
hplt.Color = [hplt.Color 0.5];
set(gca,'FontSize',fontSize);
ylabel('Power (LSB)');
axis([0 time_ms_LD(end) 0 ld0_high(1)+(ld0_high(1)/2)])
% xlabel('Time (s)')
% legend('LD0','LD0 Threshold high','LD0 Threshold low')

%% plot current
cur = res.adaptive.CurrentProgramAmplitudesInMilliamps(1,:);
ax2 = subplot(514);
plot(time_ms_LD,cur(1:length(timesUseDetector)),'LineWidth',3);
set(gca,'FontSize',fontSize); 
ylabel('Current (mA)')
% xlabel('Time (s)')

%% plot state
state = res.adaptive.CurrentAdaptiveState(1,:);
ax3 = subplot(515);
plot(time_ms_LD,state(1:length(timesUseDetector)),'LineWidth',3);
set(gca,'FontSize',fontSize);
ylabel('State (#)')
xlabel('Time (s) (all plots)')

%% plot state change
stateDiff = diff(state);
index = find(stateDiff~=0);
figure(1)
hold on
for ii=1:length(index)
    subplot(512);
    hold on
    plot([time_ms_LD(index(ii)) time_ms_LD(index(ii))],[min(y) max(y)],'r','LineWidth',1);
    subplot(513)
    hold on
    plot([time_ms_LD(index(ii)) time_ms_LD(index(ii))],[0 max(ld0)],'r','LineWidth',1);
    subplot(514)
    hold on
    plot([time_ms_LD(index(ii)) time_ms_LD(index(ii))],[0 max(cur)],'r','LineWidth',1);
    subplot(515)
    hold on
    plot([time_ms_LD(index(ii)) time_ms_LD(index(ii))],[0 max(state)],'r','LineWidth',1);
end

%% link axes
linkaxes([ax0,ax1,ax2,ax3],'x');

%% Amplitude spectral density, averaging version with pwelch, as Roee, but after having transformed to micrVolt
if calculatePSD
    [fftOut,ff]   = pwelch(y,sr,sr/2,0:1:sr/2,sr,'psd');
    [fftOut_filt,ff]   = pwelch(y_filt_3,sr,sr/2,0:1:sr/2,sr,'psd');
    fig2 = figure;
    plot(ff,log10(fftOut))
    hold on
    plot(ff,log10(fftOut_filt),'r')
>>>>>>> df49cb1c5be760ef19ff6568a6c1779a7d9e4b69
    title(titleUse)
    set(gca,'FontSize',fontSize);
    xlabel('Frequency (Hz)')
    ylabel('Power  (log_1_0\muV^2/Hz)');
    % axis([0 500 -10 max(log10(fftOut))])
    legend('raw signal','notch filtered')
end

%% save figure
if saveFigures
    figureName = 'MainPannel.fig';
    pointFig = fullfile(saveFigDir,figureName);
    saveas(fig1,pointFig)
    figureName = 'MainPannel.png';
    pointFig = fullfile(saveFigDir,figureName);
    saveas(fig1,pointFig)
<<<<<<< HEAD
    
    figureName = 'spectrogram.fig';
    pointFig = fullfile(saveFigDir,figureName);
    saveas(fig2,pointFig)
    figureName = 'spectrogram.png';
    pointFig = fullfile(saveFigDir,figureName);
    saveas(fig2,pointFig)

    figureName = 'PSD.fig';
    pointFig = fullfile(saveFigDir,figureName);
    saveas(fig3,pointFig)
    figureName = 'PSD.png';
    pointFig = fullfile(saveFigDir,figureName);
    saveas(fig3,pointFig)
=======

    figureName = 'PSD.fig';
    pointFig = fullfile(saveFigDir,figureName);
    saveas(fig2,pointFig)
    figureName = 'PSD.png';
    pointFig = fullfile(saveFigDir,figureName);
    saveas(fig2,pointFig)
>>>>>>> df49cb1c5be760ef19ff6568a6c1779a7d9e4b69
end