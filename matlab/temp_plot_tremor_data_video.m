%% start up 
close all; 
clear all;
clc; 
params.delsysFn   = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v06-home-visit-3-week/delsys/RCS01_recording_8_Plot_and_Store_Rep_2.1.csv.mat'; 
params.vidFn      = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v06-home-visit-3-week/vids/MVI_0200.MP4'; 
params.rcsTdFn    = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v06-home-visit-3-week/rc+s_data/rcs_comp/Session1541438482992/DeviceNPC700395H/RawDataTD.mat';
params.rcsAccFn   = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v06-home-visit-3-week/rc+s_data/rcs_comp/Session1541438482992/DeviceNPC700395H/RawDataAccel.mat';
params.rcsEvntFn  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v06-home-visit-3-week/rc+s_data/rcs_comp/Session1541438482992/DeviceNPC700395H/EventLog.mat';
params.rcsDvcStFn = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v06-home-visit-3-week/rc+s_data/rcs_comp/Session1541438482992/DeviceNPC700395H/DeviceSettings.mat';
% params.drivingTm  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v10-3-month/delsys_driving/driving_start_stop_times_off_stim.csv';
params.vidStart = 119.0189; % this is without subtractions 
params.delsysStart = seconds(95.783); % this is where first pressure pulse starts 

params.framewidth = seconds(10); % in seconds 
params.startFrame = params.delsysStart; 
params.vidOut     = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v06-home-visit-3-week/figures/tremor.mp4';
%% load delsys 
load(params.delsysFn);

%% plot delsys video to find out time 
hfig = figure; 
y1 = dataraw.R_index_finger_EMG11_trig;
y2 = dataraw.L_index_finger_EMG10_trig; 
secs = seconds((0:1:length(y1 )-1 )./dataraw.srates.trig); 
plot(secs,y1); 
hold on;
plot(secs,y2);



%% load RCS stuff 
load(params.rcsTdFn); 
rcsDat = outdatcomplete; 
clear outdatcomplete; 
load(params.rcsAccFn); 
rcsDatAcc = outdatcomplete; 
load(params.rcsEvntFn); 
load(params.rcsDvcStFn); 
hfig1 = figure; 
% below should be commentd out on first run 
correctNums = 1; 
if correctNums 
    params.delsys5Hz = seconds(69.219);
    params.rcs5Hz    = rcsDat.derivedTimes(19859);
else
    params.delsys5Hz = seconds(0);
    params.rcs5Hz    = seconds(0);
end


% plot delsys 
del5HzEmgFn = 'DBS_5_Hz_EMG1_IM_';
hsub(1) = subplot(2,1,1); 
y = dataraw.(del5HzEmgFn);
secs = seconds((0:1:length(y )-1 )./dataraw.srates.EMG)-params.delsys5Hz; 
plot(secs',y,'LineWidth',2);
title('delsys'); 
% plot rcs 
hsub(2) = subplot(2,1,2); 
y = rcsDat.key0;
secs = rcsDat.derivedTimes-params.rcs5Hz; 
plot(secs,y,'LineWidth',2);
title('rcs'); 
linkaxes(hsub,'x');

%% verify allignement with acc 
% plot delsys acc 
hfig = figure; 
haxDelAcc = subplot(2,1,1); 
haxRcsAcc = subplot(2,1,2); 

axes(haxDelAcc); 
hold on; 
xx = dataraw.DBS_5_Hz_ACCX1_IM_;
yy = dataraw.DBS_5_Hz_ACCY1_IM_;
zz = dataraw.DBS_5_Hz_ACCZ1_IM_;
secs = seconds((0:1:length(xx )-1 )./dataraw.srates.ACC)-params.delsys5Hz; 
plot(haxDelAcc,secs',xx-mean(xx),'LineWidth',2);
plot(haxDelAcc,secs',yy-mean(yy),'LineWidth',2);
plot(haxDelAcc,secs',zz-mean(zz),'LineWidth',2);
title('delsys acc'); 
ylimsDelsysAcc = get(haxDelAcc,'YLim'); 

% plot rcs acc 
axes(haxRcsAcc); 
hold on; 
xx = rcsDatAcc.XSamples;
yy = rcsDatAcc.YSamples;
zz = rcsDatAcc.ZSamples;
secs = seconds( seconds ( rcsDatAcc.derivedTimes - params.rcs5Hz) ); 
plot(haxRcsAcc,secs,xx-mean(xx),'LineWidth',2);
plot(haxRcsAcc,secs,yy-mean(yy),'LineWidth',2);
plot(haxRcsAcc,secs,zz-mean(zz),'LineWidth',2);
title('rcs acc'); 
ylimsRcsAcc = get(haxRcsAcc,'YLim'); 

linkaxes([haxDelAcc, haxRcsAcc],'x'); 


%% load video 

vidCam = VideoReader(params.vidFn); 
vidCam.CurrentTime = params.vidStart;

%% set up figure 
hfig = figure; 
hfig.Color = [1 1 1]; 
nrows = 4; 
ncols = 2; 

haxVid         = subplot(nrows,ncols,[1 3]); 
% haxPres = subplot(4,2,[2 4]); 
haxDelAcc      = subplot(nrows,ncols,2);
haxRcsAcc      = subplot(nrows,ncols,4);
haxRcsSpect    = subplot(nrows,ncols,[5 7]);
haxRcsSpectSTN = subplot(nrows,ncols,[6 8]);
% haxRcsM1power  = subplot(nrows,ncols,9);
% haxRcsSTNpower = subplot(nrows,ncols,10);
frameRateCam   = vidCam.FrameRate; 

params.vidFrame   = frameRateCam; % number of seconds to advance for each video frame 
hcursCnt = 1; % curser handle count 

%% plot
axes(haxVid); 
axis off 
box off 

% plot pressure 
% axes(haxPres);
% 
% hold on; 
% y = dataraw.Pressure_TPMEMG10_trig;
% secs = seconds((0:1:length(y )-1 )./dataraw.srates.trig)-params.delsys5Hz; 
% plot(secs',y,'LineWidth',2);
% ylimsPressure = get(haxPres,'YLim'); 
% hcur(1) = plot(haxPres,seconds([0 0]),ylimsPressure,...
%     'LineWidth',2,...
%     'Color',[0.7 0.7 0.7 0.5]); 
% title('delsys pressure'); 

atEnd = 0; 

% plot delsys acc 
axes(haxDelAcc); 
hold on; 
xx = dataraw.DBS_5_Hz_ACCX1_IM_;
yy = dataraw.DBS_5_Hz_ACCY1_IM_;
zz = dataraw.DBS_5_Hz_ACCZ1_IM_;
secs = seconds((0:1:length(xx )-1 )./dataraw.srates.ACC)-params.delsys5Hz; 
plot(haxDelAcc,secs',xx-mean(xx),'LineWidth',2);
plot(haxDelAcc,secs',yy-mean(yy),'LineWidth',2);
plot(haxDelAcc,secs',zz-mean(zz),'LineWidth',2);
title('delsys acc'); 
ylimsDelsysAcc = get(haxDelAcc,'YLim'); 
hcur(hcursCnt) = plot(haxDelAcc,seconds([0 0]),ylimsDelsysAcc,...
    'LineWidth',2,...
    'Color',[0.7 0.7 0.7 0.5]); 
hcursCnt = hcursCnt + 1; 

% plot rcs acc 
axes(haxRcsAcc); 
hold on; 
xx = rcsDatAcc.XSamples;
yy = rcsDatAcc.YSamples;
zz = rcsDatAcc.ZSamples;
secs = seconds( seconds ( rcsDatAcc.derivedTimes - params.rcs5Hz) ); 
plot(haxRcsAcc,secs,xx-mean(xx),'LineWidth',2);
plot(haxRcsAcc,secs,yy-mean(yy),'LineWidth',2);
plot(haxRcsAcc,secs,zz-mean(zz),'LineWidth',2);
title('rcs acc'); 
ylimsRcsAcc = get(haxRcsAcc,'YLim'); 
hcur(hcursCnt) = plot(haxRcsAcc,seconds([0 0]),ylimsRcsAcc,...
    'LineWidth',2,...
    'Color',[0.7 0.7 0.7 0.5]); 
hcursCnt = hcursCnt + 1; 


%% plot rcs spectral plot M1
axes(haxRcsSpect); 
hold on;
y = rcsDat.key3;
y = y -mean(y); 
srate = unique(rcsDat.samplerate); 
[s,f,t,p] = spectrogram(y,srate,ceil(0.875*srate),1:120,srate,'yaxis','psd');
% zp = zscore(p); 
% pscaled = abs(p)./abs(repmat(mean(p,2),1,size(p,2)));
% pcolor(t, f,zscore(p))
deltaSubtract = abs(rcsDat.derivedTimes(1) - params.rcs5Hz);
secs = seconds(t)-deltaSubtract; 
surf(secs, f, 10*log10(p), 'EdgeColor', 'none');
% sh = surf(t,f,p);
% caxis([-2.5 2.5]); 
view(0, 90)
axis tight
shading interp 
xlabel('seconds');
ylabel('Frequency (Hz)');
view(2); 
title('M1 RCS'); 
ylimsSpecrtal = get(haxRcsSpect,'YLim'); 
hcur(hcursCnt) = plot(haxRcsSpect,seconds([0 0]),ylimsSpecrtal,...
    'LineWidth',3,...
    'Color',[0.2 0.2 0.2 0.7]); 
linkprop(hcur,'XData');% don't increment since last curser 



% link all axes 

% plot m1 power 
% figure;
% [fftOut,f]   = pwelch(y(1:1e5),srate,srate/2,0:1:srate/2,srate,'psd'); 
% % filter beta and gamma 
% [b,a]        = butter(3,[14 20] / (srate/2),'bandpass'); % user 3rd order butter filter
% y_filt       = filtfilt(b,a,y); %filter all 
% [up, low] = envelope(y,120,'analytic'); % analytic rms 
% y_mov_mean = movmean(up,[srate/2 0]);
% 
% y_mov_mean(191760:192359)  = NaN; % get rid of the artifact 
% secsPower = seconds((0:1:length(y_mov_mean)-1)./srate); 
% hplt = plot(haxRcsM1power, secsPower,y_mov_mean); 
% 
% hplt = plot( secsPower,y_mov_mean); 
% hplt.LineWidth = 3; 



%% plot rcs spectral plot STN
axes(haxRcsSpectSTN); 
hold on;
y = rcsDat.key1;
y = y -mean(y); 
srate = unique(rcsDat.samplerate); 
[s,f,t,p] = spectrogram(y,srate,ceil(0.875*srate),1:120,srate,'yaxis','psd');
% zp = zscore(p); 
% pscaled = abs(p)./abs(repmat(mean(p,2),1,size(p,2)));
% pcolor(t, f,zscore(p))
deltaSubtract = abs(rcsDat.derivedTimes(1) - params.rcs5Hz);
secs = seconds(t)-deltaSubtract; 
surf(secs, f, 10*log10(p), 'EdgeColor', 'none');
% sh = surf(t,f,p);
% caxis([-2.5 2.5]); 
view(0, 90)
axis tight
shading interp 
xlabel('seconds');
ylabel('Frequency (Hz)');
view(2); 

ylimsSpecrtal = get(haxRcsSpectSTN,'YLim'); 
hcur(5) = plot(haxRcsSpectSTN,seconds([0 0]),ylimsSpecrtal,...
    'LineWidth',3,...
    'Color',[0.2 0.2 0.2 0.7]); 
title('STN RCS'); 
% link all axes 
linkprop(hcur,'XData');




% linkaxes([haxDelAcc, haxPres, haxRcsAcc, haxRcsSpect, haxRcsSpectSTN],'x');
linkaxes([haxDelAcc, haxRcsAcc, haxRcsSpect, haxRcsSpectSTN],'x');




cnt = 1; 
%
% set up video 
v = VideoWriter(params.vidOut,'MPEG-4'); 
hfig.Position =  [1000         306        1255        1032];
v.Quality = 100; 
v.FrameRate = vidCam.FrameRate; 
open(v); 
% set up curser position to sync with video beep start 
delta = params.framewidth/2; 

% XXXXX
% note added 53 secounds so action starts sooner 
curPos = params.delsysStart - params.delsys5Hz + seconds(110); % this syncs it up with RCS
vidCam.CurrentTime = vidCam.CurrentTime + 110;
% XXXXX
xlims = [curPos-delta curPos+delta];

while ~atEnd
    % XXXXX
    % xxx to make this managable changeed 
    % xlims(2) > max(secs)
    % to 
    % xlims(2) > seconds(140)
    % XXXXX
    if xlims(2) > max(secs)
        atEnd = 0;
        break; 
    end
    % plot delsys pressure 
    
    set(haxDelAcc,   'box','off',...
                   'YTickLabel',[],...
                   'YTick',[],...
                   'XTickLabel',[],...
                   'XTick',[],...
                   'YLim',ylimsDelsysAcc);
               
    set(haxRcsAcc,   'box','off',...
                   'YTickLabel',[],...
                   'YTick',[],...
                   'YLim',ylimsRcsAcc,...
                   'XLim',xlims); % set xlim for all graphs

                   
        
    % move curser 
    hcur(1).XData = [curPos curPos];
    
    curPos = curPos + seconds(1/params.vidFrame);
    xlims = xlims + seconds(1/params.vidFrame); 
    
    % plot video 

    x = readFrame(vidCam);

    image(haxVid,x); 
    set(haxVid,  'box','off','XTickLabel',[],'XTick',[],'YTickLabel',[],'YTick',[])
    pbaspect(haxVid,[size(x,2) size(x,1) 1])
        
    fullVidFrame = getframe(hfig);
    writeVideo(v,fullVidFrame);

    cnt = cnt + 1; 
end
close(v); 