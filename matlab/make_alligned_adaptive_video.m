function make_alligned_adaptive_video()
% this function takes a session folder with adaptive and plots it in video
% form 
% must have run: 
% 
% load_and_save_alligned_data_in_folder()
% and 
% plot_alligned_data_in_folder() 
% if more than one adaptive session, you need to know which session you
% want to plot 
% it depends on having the file: 
% all_data_alligned.mat
% in the directory 



%% start up 
close all; 
clear all;
clc; 
params.adaptiveFolder   = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/v14_adaptive_before_sending_home/RCS02R/Session1570736950940/DeviceNPC700404H';
params.window           = seconds(30); % size of window you want 
params.advance          = seconds(0.1); 
params.runToPlot        = 5; % run to plot - see results of plot_alligned_data_in_folder() on this folder 
params.vidFname         = sprintf('all_data_alligned_v3_%0.2d.mp4',params.runToPlot);
params.vidOut           = fullfile(params.adaptiveFolder,params.vidFname); 

%% plot alligned data 
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

nrows = 3; 
ncols = 1; 
for e = params.runToPlot% 1:length(startTimes)
    hfig = figure;
    hfig.Position = [45           1        1636         954];
    hfig.Color = 'w';
    cntplt = 1;
    % plot one figure for each adaptive "session".
    % this should include:
    
    % subplot 1
    % settings
%     hsub(cntplt) = subplot(nrows,ncols,cntplt); cntplt = cntplt + 1;
%     set(gca,'FontSize',16);
%     set(gca, 'box','off','XTickLabel',[],'XTick',[],'YTickLabel',[],'YTick',[])
% 
%     a = annotation('textbox', hsub(1).Position, 'String', "hi");
%     a.FontSize = 14;
%     % params to write 
%     % power 
%     strline = 1;
%     strOut{strline} = 'settings'; 
%     strline = strline + 1; 
%     
%     strOut{strline} = sprintf('%s\t power band: %s',...
%         adaptiveInfo(e).tdChannelInfo,...
%         adaptiveInfo(e).bandsUsed);    
%     strline = strline + 1; 
%     % stim 
%     
%     strOut{strline} = sprintf('stim rate %.2f\t states: [%.2f mA %.2f mA %.2f mA]',...
%         adaptiveInfo(e).stimRate,...
%         adaptiveInfo(e).State0AmpInMilliamps,...
%         adaptiveInfo(e).State1AmpInMilliamps,...
%         adaptiveInfo(e).State2AmpInMilliamps);
%     strline = strline + 1; 
%     
%     % fft settings 
%     fftsize = adaptiveInfo(e).Fftsize;
%     sr = adaptiveInfo(e).SampleRate;
%     
%     strOut{3} = sprintf('each FFT represents %d ms of data (fft size %d sr %d Hz)',...
%         ceil((fftsize/sr).*1000), fftsize,sr);
%     updateRate = adaptiveInfo(e).UpdateRate; 
%     
%     strOut{strline} = sprintf('%d ffts are averaged - %d ms of data before being input to LD',updateRate,ceil((fftsize/sr).*1000)*updateRate);    
%     strline = strline + 1; 
% 
%     strOut{strline} = sprintf('update rate %d onset %d termination %d state change blank %d',...
%         adaptiveInfo(e).UpdateRate,...
%         adaptiveInfo(e).OnsetDuration,...
%         adaptiveInfo(e).TerminationDuration,...
%         adaptiveInfo(e).StateChangeBlankingUponStateChange);
%     strline = strline + 1; 
% 
%     
%     strOut{strline} = sprintf('ramp up rate %.2f mA/sec\t ramp down rate %.2f mA/sec\t',...
%         adaptiveInfo(e).rampUpRatePerSec,...
%         adaptiveInfo(e).rampDownRatePerSec);
%     strline = strline + 1;
% 
% 
%     a.String = strOut;
%     a.EdgeColor = 'none'
    
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
    [b,a]        = butter(3,[bandsUsed(1) bandsUsed(end)] / (sr/2),'bandpass'); % user 3rd order butter filter
    y_filt       = filtfilt(b,a,tddata); %filter all
    y_filt_hilbert       = abs(hilbert(y_filt));
    ydatRescaled = rescale(y_filt,0.55,1);
    y_filt_hilbertRescaled = rescale(y_filt_hilbert,0.55+(1-0.55)/2,1);
    % make all scales duration based: 
    secs = secs - secs(1); 
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
    % make all scales duration based:
    secsAdaptive = secsAdaptive - secsAdaptive(1);
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
    
    % subplot 4
    hsub(cntplt) = subplot(nrows,ncols,cntplt); cntplt = cntplt + 1;
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
    linkaxes(hsub,'x');
    savefig(hfig,figsaveFullName); 
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% XXXXXXXXXXXXX
% XXXXXXXXXXXXX
% XXXXXXXXXXXXX
% XXXXXXXXXXXXX

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set up video 
v = VideoWriter(params.vidOut,'MPEG-4'); 
hfig.Position =  [1000         306        1255        1032];
v.Quality = 100; 
v.FrameRate = v.FrameRate; 
params.advance = seconds(1/v.FrameRate);
open(v); 
% set up curser position to sync with video beep start 
delta = params.window;

xlimsCur = get(gca,'XLim');
curPos = seconds(15);
xlims = [curPos-delta/2 curPos+delta/2];
hsub(1).XLim = xlims;
set(hsub(1),  'box','off','XTickLabel',[],'XTick',[],'YTickLabel',[],'YTick',[])
set(hsub(2),  'box','off','XTickLabel',[],'XTick',[],'YTickLabel',[],'YTick',[])

%%
atEnd = 0;
while ~atEnd
    if xlims(2) >= seconds(120) %% CHANGES from max(secs)
        break; 
    end
    % move curser 
%     hcur(1).XData = [curPos curPos];
    
    
    % plot video 
    
    fullVidFrame = getframe(hfig);
    writeVideo(v,fullVidFrame);
    
    curPos = curPos + params.advance;
    xlims = xlims + params.advance;
    hsub(1).XLim = xlims;
end
close(v); 
close(hfig);
