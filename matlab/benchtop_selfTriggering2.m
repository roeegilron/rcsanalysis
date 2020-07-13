%% Analysis of floor noise in time and frequency for test bench configurations
close all; clear all; clc

%% Binary arguments
saveSignalneuroDACPaper = 0;
figFullScreen = 0;
plotFFTsettings = 0;
plotSpectrogram = 0;
plot2Detectors = 0;
adaptiveOn = 0;
showRawSignal = 0;
focusThreshold = 0;
showStateChanges = 0;
calculatePSD = 0;
plotOriginalPlayBack = 0;
lineWidth = 1;
saveFigures = 0;

%% load data
dirname = uigetdir('/Users/juananso/Dropbox (Personal)/Work/DATA/benchtop/selfTriggering')
[outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerTable] = MAIN_load_rcs_data_from_folder(dirname);
fnAdaptive = fullfile(dirname,'AdaptiveLog.json'); 
fnDeviceSettings = fullfile(dirname,'DeviceSettings.mat');
res = readAdaptiveJson(fnAdaptive); 
if plotFFTsettings
devSettings = readDevSettings(fnDeviceSettings);
end
saveFigDir = fullfile(dirname,'/Figures');
if ~isfolder(saveFigDir)
    mkdir(saveFigDir)
end

%% Extract parameters
sr = outdatcomplete.samplerate(1);
if adaptiveOn
    stimRate = res.adaptive.StimRateInHz;
else
    stimRate = 0;
end

if plotFFTsettings
    fftSettings = devSettings.fft;
end
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

if plotFFTsettings
    ax = subplot(511);
    % text(0.1,1,titleUse,'FontSize',fontSize)
    text(0.1,0.75,strcat('FFT properties:'),'FontSize',fontSize);
    text(0.1,0.5,strcat('interval = ', num2str(fftSettings.interval),' ms'),'FontSize',fontSize);
    text(0.1,0.25,strcat('size = ', num2str(fftSettings.size),' points'),'FontSize',fontSize);
    text(0.1,0,strcat('windowLoad = ', num2str(fftSettings.windowLoad),' %'),'FontSize',fontSize);
    set ( ax, 'visible', 'off')
end

%% plot time series
y = (outdatcomplete.key0*1e3); % transform data from millivolts to microvolts
y = y-mean(y);

% create and apply notch fitler, Quality factor q = w0/bw, where w0 is the notch frequency.
% wo = 60/(sr/2);  
% bw = wo/5;
% [b,a] = iirnotch(wo,bw);
% y_filt = filtfilt(b,a,y);
% wo = 120/(sr/2);  
% bw = wo/35; 
% [b,a] = iirnotch(wo,bw);
% y_filt_2 = filtfilt(b,a,y_filt);
% wo = 180/(sr/2);  
% bw = wo/35; 
% [b,a] = iirnotch(wo,bw);
% y_filt_3 = filtfilt(b,a,y_filt_2);
y_filt_3 = y;

if plotFFTsettings
    ax0 = subplot(512);
elseif plotSpectrogram
    ax0 = subplot(511);
else
    ax0 = subplot(411);
end

if showRawSignal
    plot(time_ms,y);
    hold on
end
plot(time_ms,y_filt_3,'k');
title(titleUse);
ylabel('Voltage (\muV)')
set(gca,'FontSize',fontSize);

if saveSignalneuroDACPaper
    signal.timeDomain.t = time_ms;
    signal.timeDomain.y = y_filt_3;
end
    
offset=10*sr;
reSampFac = 1;
if plotOriginalPlayBack
    % look for max value, corresponds (control this :S because!!!!! it could be is not always the case) with clipping at start aDBS
    [val,neurT0]=max(y_filt_3);
    % take last sample of array as end segment
    neurTend = length(y_filt_3)*reSampFac;
    % in original data we are interested in starting from first sample
    locs = [1,neurTend];
    [td,sr2]=get_timedomain_segment('/Users/juananso/Dropbox (Personal)/Work/DATA/benchtop/neuroDAC/playBack_neuralData_GP_aDBS/RawDataTD_GP_Offmeds.mat',0,locs);
    % remove DC
    td = td-mean(td);
    t_neurSeg = linspace(time_ms(neurT0),time_ms(end),length(td));
    hold on; plot(t_neurSeg,td*1e3,'r');
end

% xlabel('Time (s)')
% legend('time series')
% axis([0 max(x) -200 200])

%% rms floor noise amplitude
samp5secs = sr*1;
rmsSig5secs = rms(y_filt_3(1:samp5secs))

%% Plot spectrogram
fig2 = figure(2);
pspectrum(y_filt_3,sr,'spectrogram','Leakage',1,'OverlapPercent',80, ...
    'MinThreshold',-1,'FrequencyLimits',[10, 100],'TimeResolution', 500e-3);

if plotSpectrogram
    % figure(4)
    figure(1)
    ax1 = subplot(512);
    [sp,fp,tp] = pspectrum(y_filt_3,sr,'spectrogram','Leakage',1,'OverlapPercent',80, ...
    'MinThreshold',-1,'FrequencyLimits',[1, 50],'TimeResolution', 500e-3);
    pcolor(tp,fp,10*log10(abs(sp)));
    shading flat
    set(gca,'FontSize',fontSize);
    ylabel('frequency (Hz)')
end

if saveSignalneuroDACPaper
    signal.spectrogram.sp = sp;
    signal.spectrogram.fp = fp;
    signal.spectrogram.tp = tp;
end

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
    elseif plotSpectrogram
        ax2 = subplot(513);
    else
        ax1 = subplot(412);
    end
    
    hold on
    
    if plot2Detectors 
        
        [ax,h1,h2] = plotyy(time_ms_LD,ld0,time_ms_LD,ld1);
        set(h1,'Color','b','LineWidth',lineWidth);
        set(h2,'Color','r','LineWidth',lineWidth);
        set(ax,{'ycolor'},{'b';'r'}) 
        
        hold(ax(1),'on')
        hplt0h = plot(ax(1), time_ms_LD,ld0_high,'LineWidth',lineWidth,'LineStyle','-.','Color','b'); %         set(hplt0h,'Marker','o','Linestyle','--','Color','m');
        hplt0l = plot(ax(1), time_ms_LD,ld0_low,'LineWidth',lineWidth,'LineStyle',':','Color','b');
        hL1 = ylabel(ax(1),'Power (LSB)');
        set(hL1,'fontsize',fontSize,'color','b')
        
        hold(ax(2),'on')
        hplt1h = plot(ax(2), time_ms_LD,ld1_low,'LineWidth',lineWidth,'LineStyle','-.','Color','r');
        hplt1l = plot(ax(2), time_ms_LD,ld1_low,'LineWidth',lineWidth,'LineStyle',':','Color','r');        
        hL2 = ylabel(ax(2),'Power (LSB)');
        set(hL2,'fontsize',fontSize,'color','r')
        
        legend([h1;hplt0h;hplt0l;h2;hplt1h;hplt1l],'ld0','ld0 high','ld0 low','ld1','ld1 high','ld1 low')
        
    else
        plot(time_ms_LD,ld0,'LineWidth',lineWidth,'Color','b');
        hplt1 = plot(time_ms_LD,ld0_high,'LineWidth',lineWidth);
        hplt1.LineStyle = '-.';
        hplt1.Color = [hplt1.Color 1];
        hplt2 = plot(time_ms_LD,ld0_low,'LineWidth',lineWidth);
        hplt2.LineStyle = ':';
        hplt2.Color = [hplt1.Color 1];
        set(gca,'FontSize',fontSize);
        ylabel('Power (LSB)');
        if focusThreshold
            axis([0 time_ms_LD(end) 0 ld0_high(1)+(ld0_high(1)/2)])
        end
        legend([hplt1;hplt2],'ld0 high','ld0 low')
%         xlabel('Time (s)')
%         legend('LD0','LD0 th')
    end
    
    if saveSignalneuroDACPaper
        signal.PowerDetector.t = time_ms_LD;
        signal.PowerDetector.y = ld0;
        signal.PowerDetector.hth = ld0_high;
        signal.PowerDetector.lth = ld0_low;
    end
    
    %% plot current
    cur = res.adaptive.CurrentProgramAmplitudesInMilliamps(1,idxKeepYear);
    if plotFFTsettings
        ax2 = subplot(514);
    elseif plotSpectrogram
        ax3 = subplot(514);
    else
        ax2 = subplot(413);
    end
    plot(time_ms_LD,cur(1:length(timesUseDetector)),'LineWidth',lineWidth,'Color','b');
    set(gca,'FontSize',fontSize); 
    ylabel('Current (mA)')
    % xlabel('Time (s)')
    
    if saveSignalneuroDACPaper
        signal.StimCurrent.t = time_ms_LD;
        signal.StimCurrent.y = cur;
    end

    %% plot state
    state = res.adaptive.CurrentAdaptiveState(1,idxKeepYear);
    if plotFFTsettings
        ax3 = subplot(515);
    elseif plotSpectrogram
        ax4 = subplot(515);
    else
        ax3 = subplot(414);
    end
    plot(time_ms_LD,state(1:length(timesUseDetector)),'LineWidth',2,'color',[26,148,49]/255);
    set(gca,'FontSize',fontSize);
    ylabel('State (#)')
    xlabel('Time (s) (all plots)')
    
    if saveSignalneuroDACPaper
        signal.state.t = time_ms_LD;
        signal.state.y = state;
    end

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
            elseif plotSpectrogram
                subplot(511);
            else
                subplot(411);
            end
            hold on
            plot([time_ms_LD(index(ii)) time_ms_LD(index(ii))],[min(y) max(y)],'k:','LineWidth',1);
            if plotFFTsettings
                subplot(513)
            elseif plotSpectrogram
                subplot(513);
            else
                subplot(412)
            end
            hold on
            plot([time_ms_LD(index(ii)) time_ms_LD(index(ii))],[0 max(ld0)],'k:','LineWidth',1);
            if plotFFTsettings
                subplot(514)
            elseif plotSpectrogram
                subplot(513);
            else
                subplot(413)
            end
            hold on
            plot([time_ms_LD(index(ii)) time_ms_LD(index(ii))],[0 max(cur)],'k:','LineWidth',1);
            if plotFFTsettings
                subplot(515)
            elseif plotSpectrogram
                subplot(515);
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
    elseif plotSpectrogram
        linkaxes([ax0,ax1,ax2,ax3,ax4],'x');
    else
        linkaxes([ax0,ax1,ax2,ax3],'x');
    end
%     axis tight
    
end % end adaptive on analysis

%% Amplitude spectral density, averaging version with pwelch, as Roee, but after having transformed to micrVolt
if calculatePSD
    [fftOut,ff]   = pwelch(y,sr,sr/2,0:1:sr/2,sr,'psd');
    [fftOut_filt,ff]   = pwelch(y_filt_3,sr,sr/2,0:1:sr/2,sr,'psd');
    fig3 = figure(3);
    plot(ff,log10(fftOut))
    hold on
    plot(ff,log10(fftOut_filt),'k')
    title(titleUse)
    set(gca,'FontSize',fontSize);
    xlabel('Frequency (Hz)')
    ylabel('Power  (log_1_0\muV^2/Hz)');
    % axis([0 500 -10 max(log10(fftOut))])
    legend('raw signal','notch filtered')
end

%%  analyze 2 detector curves
if plot2Detectors   
    ld0_norm = (ld0-min(ld0))/(max(ld0)-min(ld0));
    ld1_norm = (ld1-min(ld1))/(max(ld1)-min(ld1));
    ld_sub = abs(ld0_norm-ld1_norm_shift1);
   
    figure
    hold on
    plot(time_ms_LD,ld0_norm,'color','b','linewidth',1)
    plot(time_ms_LD,ld1_norm_shift1,'r','linewidth',1)    
    plot(time_ms_LD,ld_sub,'k','linewidth',1)    
    ylabel('Power (LSB)');
    legend('ld0 norm','ld1 norm','abs(ld0-ld1)')
    
    idx = find(time_ms_LD > 12 & time_ms_LD<13);
    figure
    subplot(311)
    hold all
    plot(time_ms_LD(idx),ld0_norm(idx),'color','b','linewidth',1,'DisplayName','ld0 norm')    
    legend('-DynamicLegend');
    if exist('ld1_fact')
        clear ld1_fact
        clear err
        clear ld0_sub
        clear b
        clear err_mean
        clear err_min
        clear err_max
    end
    
    % for 1 positive coeff
    coeffs = linspace(0.1,5,20);
    for ii=1:length(coeffs)
        a=coeffs(ii)
        ld1_fact(ii,:) = a.*ld1_norm_shift1(idx);
        ax1 = subplot(311);
        hold all
        plot(time_ms_LD(idx),ld1_fact(ii,:),'DisplayName',['a x LD1 norm (a = ',num2str(coeffs(ii)),')']);
        legend('-DynamicLegend');
        ylabel('Power normalized (au)');
        err(ii,:) = abs(ld0_norm(idx)-ld1_fact(ii,:));
        ax2 = subplot(312);       
        hold all;
        plot(time_ms_LD(idx),err(ii,:),'DisplayName',['a = ',num2str(coeffs(ii))]);
        ylabel('ld0 norm - a * ld1norm (au)')
        legend('-DynamicLegend');
    end
      
    err = [mean(err'); max(err'); min(err')]
    [err_val,aix_minerr] = min(err(1,:));
    ld0_sub = abs(ld0_norm(idx)-ld1_fact(aix_minerr,:));
    mean(mean(err))
    mean(std(err))
    
    ax3= subplot(313);
    hold on
    plot(time_ms_LD(idx),ld0_norm(idx),'b','linewidth',1)  
    plot(time_ms_LD(idx),ld1_norm_shift1(idx),'r','linewidth',1)  
    plot(time_ms_LD(idx),ld1_fact(aix_minerr,:),'-.k','linewidth',1) 
    plot(time_ms_LD(idx),ld0_sub,'g','linewidth',2)  
    legend('ld0 norm','ld1 norm',['a x ld1 (a=',num2str(coeffs(aix_minerr)),')'],'ld0 out')
    ylabel('Power norm (0,1)')
    xlabel('time (ms)')
    linkaxes([ax1,ax2,ax3],'x')
    
    
    % for 1 positive coeff and 1 negative coeff
%     if exist('ld1_fact')
%         clear ld1_fact
%         clear err
%         clear ld0_sub
%         clear b
%         clear err_mean
%         clear err_min
%         clear err_max
%     end
%     coeffs = linspace(0.25,5,20);
%     for ii=1:length(coeffs)
%         a=coeffs(ii);
%         for jj=1:length(coeffs)
%             b = coeffs(jj);
%             ld1_fact(jj,:,ii) = a.*ld1_norm(idx)-b;
%             ax1 = subplot(311);
%             hold all
%             plot(time_ms_LD(idx),ld1_fact(jj,:,ii),'DisplayName',['a x LD1 norm (a = ',num2str(coeffs(jj)),')']);
%             legend('-DynamicLegend');
%             ylabel('Power normalized (au)');
%             err(jj,:,ii) = abs(ld0_norm(idx)-ld1_fact(jj,:,ii));
%             ax2 = subplot(312);       
%             hold all;
%             plot(time_ms_LD(idx),err(jj,:,ii),'DisplayName',['a = ',num2str(coeffs(ii)),' b = ',num2str(coeffs(jj))]);
%             ylabel('ld0 norm - a * ld1norm (au)')
%             legend('-DynamicLegend');
%         end
%     end
%       
% 
%     [errmin_3d,cix_3d] = min(err);
%     
%     [errmin_2d,bidx_2d] = min(errmin_3d);
%     
%     [errmin_1d,aidx_1d] = min(errmin_2d);
%     
%     bidx_1d = bidx_2d(aidx_1d);
%     
%     ld0_sub = abs(ld0_norm(idx)-ld1_fact(bidx_1d,:,aidx_1d));
% %     
%     ax3= subplot(313)
%     hold on
%     plot(time_ms_LD(idx),ld0_norm(idx),'b','linewidth',1)  
%     plot(time_ms_LD(idx),ld1_norm(idx),'r','linewidth',1)  
%     plot(time_ms_LD(idx),ld1_fact(bidx_1d,:,aidx_1d),'-.k','linewidth',1) 
%     plot(time_ms_LD(idx),ld0_sub,'g','linewidth',2)  
%     legend('ld0 norm','ld1 norm',['a x ld1 (a=',num2str(coeffs(aidx_1d)),', b=',num2str(coeffs(bidx_1d)),')'],'ld0 out')
%     ylabel('Power norm (0,1)')
%     xlabel('time (ms)')
%     linkaxes([ax1,ax2,ax3],'x')
    
end

%% save figure
if saveFigures
    figureName = 'MainPannel.fig';
    pointFig = fullfile(saveFigDir,figureName);
    saveas(fig1,pointFig)
    figureName = 'MainPannel.png';
    pointFig = fullfile(saveFigDir,figureName);
    saveas(fig1,pointFig)
    
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
end

%% save .mat file for neuroDAC paper
if saveSignalneuroDACPaper
    fileName = 'mainPannel.mat';
    pointMat = fullfile(saveFigDir,fileName);
    save(pointMat,'signal')
end
