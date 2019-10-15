function temp_rcs02_dyskinesia_adaptive_make_video()
% make video of RCS02 dyskinesia start 


%% start up 
close all; 
clear all;
clc; 
params.delsysFn   = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/v09_adaptive/Delsys/RCS02_6_5_Adaptive_DBS_dsykinesia_test_Plot_and_Store_Rep_1.5.csv.mat';
params.vidFn      = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/v09_adaptive/vids/MVI_0301.MP4'; % 25:50 start of dyskinesia 
params.rcsFolder  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/v09_adaptive/adaptive_day_2/surfacebook/RCS02R/Session1559769597879/DeviceNPC700404H'; % right side 
params.rcsFolder  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/v09_adaptive/adaptive_day_2/lte/StarrLab/RCS02L/Session1559769144423/DeviceNPC700398H'; % left side is what show in dyskinesa vide 
% load rcs folder times: 
params.rcsTdFn    = fullfile(params.rcsFolder,'RawDataTD.mat');
params.rcsAccFn   = fullfile(params.rcsFolder,'RawDataAccel.mat');
params.rcsEvntFn  = fullfile(params.rcsFolder,'EventLog.mat');
params.rcsDvcStFn = fullfile(params.rcsFolder,'DeviceSettings.mat');
% params.delAllignF = fullfile(params.rcsFolder,'delsysAllignInformation.mat'); 
% load delsys allign file 
% delparams = load(params.delAllignF,'params');

% note that I added a few seconds to beep time bcs of packet loss 
params.vidStart = 365.8655 + 32; % this is without subtractions 
params.delsysStart = seconds(1316.49); % this is where first pressure pulse starts 

params.framewidth = seconds(20); % in seconds 
params.startFrame = params.delsysStart; 
params.vidOut     = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/v09_adaptive/figures/adaptive_dbs_rcs02_dyskinesia.mp4';
%% load delsys 
load(params.delsysFn);

%% plot delsys video to find out time 
% hfig = figure; 
% y1 = dataraw.R_index_green9_EMG11_trig;
% y2 = dataraw.Sound_green10_EMG10_trig; 
% secs = seconds((0:1:length(y1 )-1 )./dataraw.srates.trig); 
% plot(secs,y1); 
% hold on;
% plot(secs,y2);
% 


%% load RCS stuff 
load(params.rcsTdFn); 
rcsDat = outdatcomplete; 
clear outdatcomplete; 
load(params.rcsAccFn); 
rcsDatAcc = outdatcomplete; 
load(params.rcsEvntFn); 
load(params.rcsDvcStFn); 
fnAdaptive = fullfile(params.rcsFolder,'AdaptiveLog.json'); 
res = readAdaptiveJson(fnAdaptive);
% load power 
fileloadPower = fullfile(params.rcsFolder,'RawDataPower.json');
[pn,fn,ext] = fileparts(fileloadPower); 
if exist(fullfile(pn,[fn '.mat']),'file')
    load(fullfile(pn,[fn '.mat']));
else
    [powerTable, pbOut]  = loadPowerData(fileloadPower);
end


% below should be commentd out on first run 
% delparams = load(params.delAllignF,'params');
correctNums = 1; 
if correctNums 
    params.delsys5Hz = seconds(574.472);
    params.rcs5Hz    = seconds(522.61);
else
    params.delsys5Hz = seconds(0);
    params.rcs5Hz    = seconds(0);
end


% plot delsys 
hfig1 = figure; 
del5HzEmgFn = 'DBS_5HZ_L_green2_ACCX2_IM_';
hsub(1) = subplot(2,1,1); 
y = dataraw.(del5HzEmgFn);
secs = seconds((0:1:length(y )-1 )./dataraw.srates.EMG)-params.delsys5Hz; 
plot(secs',y,'LineWidth',2);
title('delsys'); 
% plot rcs 
hsub(2) = subplot(2,1,2); 
y = rcsDat.key0;
secs = rcsDat.derivedTimes - rcsDat.derivedTimes(1) -params.rcs5Hz; 
plot(secs,y,'LineWidth',2);
title('rcs'); 
linkaxes(hsub,'x');
close(hfig1);

%% verify allignement with acc 
% plot delsys acc 
hfig = figure; 
haxDelAcc = subplot(2,1,1); 
haxRcsAcc = subplot(2,1,2); 

axes(haxDelAcc); 
hold on; 
xx = dataraw.DBS_5HZ_L_green2_ACCX2_IM_;
yy = dataraw.DBS_5HZ_L_green2_ACCY2_IM_;
zz = dataraw.DBS_5HZ_L_green2_ACCZ2_IM_;
secsDel = seconds((0:1:length(xx )-1 )./dataraw.srates.ACC)-params.delsys5Hz; 
plot(haxDelAcc,secsDel',xx-mean(xx),'LineWidth',2);
plot(haxDelAcc,secsDel',yy-mean(yy),'LineWidth',2);
plot(haxDelAcc,secsDel',zz-mean(zz),'LineWidth',2);
title('delsys acc'); 
ylimsDelsysAcc = get(haxDelAcc,'YLim'); 

% plot rcs acc 
axes(haxRcsAcc); 
hold on; 
xx = rcsDatAcc.XSamples;
yy = rcsDatAcc.YSamples;
zz = rcsDatAcc.ZSamples;
secs = (rcsDatAcc.derivedTimes - rcsDatAcc.derivedTimes(1)) - params.rcs5Hz; 
secs.Format = 's';
plot(haxRcsAcc,secs,xx-mean(xx),'LineWidth',2);
plot(haxRcsAcc,secs,yy-mean(yy),'LineWidth',2);
plot(haxRcsAcc,secs,zz-mean(zz),'LineWidth',2);
title('rcs acc'); 
ylimsRcsAcc = get(haxRcsAcc,'YLim'); 
linkaxes([haxDelAcc, haxRcsAcc],'x'); 
close(hfig);

%% load video 

vidCam = VideoReader(params.vidFn); 
vidCam.CurrentTime = params.vidStart;

%% set up figure 
close all;
clear hcur
hfig = figure; 
hfig.Color = [1 1 1]; 
nrows = 6; 
ncols = 4; 

haxVid         = subplot(nrows,ncols,[1 2 5 6 9 10 13 14 17 18 21 22]); 
% haxPres = subplot(4,2,[2 4]); 
% haxDelAcc      = subplot(nrows,ncols,[3 4]);
% haxRcsAcc      = subplot(nrows,ncols,[7 8]);
haxDetector    = subplot(nrows,ncols,[3 4 7 8 11 12]);
haxCurent = subplot(nrows,ncols,[15 16 19 20 23 24]);
% haxRcsM1power  = subplot(nrows,ncols,9);
% haxRcsSTNpower = subplot(nrows,ncols,10);
frameRateCam   = vidCam.FrameRate; 

params.vidFrame   = frameRateCam; % number of seconds to advance for each video frame 
hcursCnt = 1; % curser handle count 
axes(haxVid); 
axis off 
box off 
atEnd = 0; 
%% plot


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



% % plot delsys acc 
% axes(haxDelAcc); 
% hold on; 
% xx = dataraw.DBS5HzL_ACCX1_IM_;
% yy = dataraw.DBS5HzL_ACCY1_IM_;
% zz = dataraw.DBS5HzL_ACCZ1_IM_;
% secs = seconds((0:1:length(xx )-1 )./dataraw.srates.ACC)-params.delsys5Hz; 
% plot(haxDelAcc,secs',xx-mean(xx),'LineWidth',2);
% plot(haxDelAcc,secs',yy-mean(yy),'LineWidth',2);
% plot(haxDelAcc,secs',zz-mean(zz),'LineWidth',2);
% title('delsys acc'); 
% ylimsDelsysAcc = get(haxDelAcc,'YLim'); 
% hcur(hcursCnt) = plot(haxDelAcc,seconds([0 0]),ylimsDelsysAcc,...
%     'LineWidth',2,...
%     'Color',[0.7 0.7 0.7 0.5]); 
% hcursCnt = hcursCnt + 1; 
% 
% % plot rcs acc 
% axes(haxRcsAcc); 
% hold on; 
% xx = rcsDatAcc.XSamples;
% yy = rcsDatAcc.YSamples;
% zz = rcsDatAcc.ZSamples;
% secs = rcsDatAcc.derivedTimes - rcsDatAcc.derivedTimes(1) - params.rcs5Hz; 
% plot(haxRcsAcc,secs,xx-mean(xx),'LineWidth',2);
% plot(haxRcsAcc,secs,yy-mean(yy),'LineWidth',2);
% plot(haxRcsAcc,secs,zz-mean(zz),'LineWidth',2);
% title('rcs acc'); 
% ylimsRcsAcc = get(haxRcsAcc,'YLim'); 
% hcur(hcursCnt) = plot(haxRcsAcc,seconds([0 0]),ylimsRcsAcc,...
%     'LineWidth',2,...
%     'Color',[0.7 0.7 0.7 0.5]); 
% hcursCnt = hcursCnt + 1; 
%% plot detector 
% plot detector 
cla(haxDetector); 
axis(haxDetector);

hold(haxDetector,'on');
cur = res.adaptive.CurrentProgramAmplitudesInMilliamps(1,:); 
timestamps = datetime(datevec(res.timing.timestamp./86400 + datenum(2000,3,1,0,0,0))); % medtronic time - LSB is seconds
uxtimes = datetime(res.timing.PacketGenTime/1000,...
    'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
yearUse = mode(year(uxtimes)); 
idxKeepYear = year(uxtimes)==yearUse;


ld0 = res.adaptive.LD0_output(idxKeepYear);
ld0_high = res.adaptive.LD0_highThreshold(idxKeepYear);
ld0_low  = res.adaptive.LD0_lowThreshold(idxKeepYear);
timesUseDetector = uxtimes(idxKeepYear); 

timesUseDetector = timesUseDetector - timesUseDetector(1) - params.rcs5Hz;
hplt = plot(haxDetector,timesUseDetector,ld0,'LineWidth',3);
hplt = plot(haxDetector,timesUseDetector,ld0_high,'LineWidth',3);
hplt.LineStyle = '-.';
hplt.Color = [hplt.Color 0.7];

% plot power 
uxtimesPower = datetime(res.timing.PacketGenTime/1000,...
    'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');

yearUsePower = mode(year(uxtimesPower)); 
idxKeepYearPower = year(uxtimesPower)==yearUsePower; 
uxtimesPowerUse = uxtimesPower(idxKeepYearPower);
powerBand = powerTable.Band7(idxKeepYearPower);
secsUse = uxtimesPowerUse - uxtimesPowerUse(1) - params.rcs5Hz;

% hplt = plot(haxDetector,secsUse,powerBand,'LineWidth',3);
% hplt.Color = [0.8 0 0 0.7];


% plot current time line 
ylimsSpecrtal = get(haxDetector,'YLim'); 
hcur(hcursCnt) = plot(haxDetector,seconds([0 0]),ylimsSpecrtal,...
    'LineWidth',3,...
    'Color',[0.2 0.2 0.2 0.7]); 
hcursCnt = hcursCnt + 1;
legend(haxDetector,{'Power (M1 gamma)','Threshold'}); 
ylabel(haxDetector,'Detector power (a.u.)');
title(haxDetector,'Embedded aDBS'); 
haxDetector.XTick = [];
set(haxDetector,'FontSize',16); 


%% plot current 
cla(haxCurent); 
axis(haxCurent);

hold(haxCurent,'on');
current = res.adaptive.CurrentProgramAmplitudesInMilliamps(1,idxKeepYear);
hp = plot(haxCurent,timesUseDetector, current); 
hp.LineWidth = 2; 
hp.Color = [0 0.8 0.8 0.8];
title('current'); 
% plot current time line 
ylimsSpecrtal = get(haxCurent,'YLim'); 
hcur(hcursCnt) = plot(haxCurent,seconds([0 0]),ylimsSpecrtal,...
    'LineWidth',3,...
    'Color',[0.2 0.2 0.2 0.7]); 
hcursCnt = hcursCnt; % last one 
title(haxCurent,'Current'); 
ylabel(haxCurent,'Current (mA)');
set(haxCurent,'FontSize',16); 
linkprop(hcur,'XData'); % don't increment since last
linkaxes([ haxCurent, haxDetector],'x');


%% plot rcs spectral plot M1
% axes(haxRcsSpect); 
% cla(haxRcsSpect);
% hold on;
% y = rcsDat.key3;
% y = y -mean(y);
% srate = unique(rcsDat.samplerate); 
% idxPeaks = [15 30; 67 87]; 
% [OutS,t,f] = plot_spectogram_normalized(y,srate,idxPeaks,0,1); 
% secs = seconds(t)-params.rcs5Hz;
% surf(haxRcsSpect,secs, f, OutS, 'EdgeColor', 'none');
% view(2); 
% caxis(haxRcsSpect,[0.7 1.45]);
% axis tight
% shading interp 
% % xlabel('seconds');
% ylabel('Frequency (Hz)');
% view(2); 
% title('M1 (Cortical paddle)'); 
% % plot curser 
% ylimsSpecrtal = get(haxRcsSpect,'YLim'); 
% zlimsSpectral = get(haxRcsSpect,'ZLim');
% hcur(hcursCnt) = plot3(haxRcsSpect,seconds([0 0]),ylimsSpecrtal,[zlimsSpectral(2) zlimsSpectral(2)],...
%     'LineWidth',3,...
%     'Color',[0.2 0.2 0.2 0.7]); 
% hcursCnt = hcursCnt + 1;
% set(haxRcsSpect,'FontSize',16); 

% linkprop(hcur,'XData');% don't increment since last curser 




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
% axes(haxRcsSpectSTN); 
% hold on;
% y = rcsDat.key1;
% y = y -mean(y); 
% srate = unique(rcsDat.samplerate); 
% idxPeaks = [15 30; 67 87]; 
% [OutS,t,f] = plot_spectogram_normalized(y,srate,idxPeaks,0,1); 
% secs = seconds(t)-params.rcs5Hz;
% surf(haxRcsSpectSTN,secs, f, OutS, 'EdgeColor', 'none');
% view(2); 
% caxis(haxRcsSpectSTN,[0.7 1.85]);
% ylabel('Frequency (Hz)');
% axis tight
% shading interp 
% % plot curser 
% ylimsSpecrtal = get(haxRcsSpectSTN,'YLim'); 
% zlimsSpectral = get(haxRcsSpectSTN,'ZLim');
% hcur(hcursCnt) = plot3(haxRcsSpectSTN,seconds([0 0]),ylimsSpecrtal,[zlimsSpectral(2) zlimsSpectral(2)],...
%     'LineWidth',3,...
%     'Color',[0.2 0.2 0.2 0.7]); 
% title('STN (DBS lead)'); 
% xlabel(haxRcsSpectSTN,'Time (Seconds)'); 
% 
% % link all axes 
% set(haxRcsSpectSTN,'FontSize',16); 
% linkprop(hcur,'XData'); % don't increment since last
% 
% 
% 
% 
% % linkaxes([haxDelAcc, haxPres, haxRcsAcc, haxRcsSpect, haxRcsSpectSTN],'x');
% % linkaxes([haxDelAcc, haxRcsAcc, haxRcsSpect, haxRcsSpectSTN],'x');
% linkaxes([ haxRcsSpect, haxRcsSpectSTN],'x');



%%
% 31:21 is where action starts 
% 12:21 is wehre video starts 
% plot just detecto from 23:43 to 36:45
% just video have start t- 1 minute from action 
% just video have action at t + 4 minutes from action start
% have end at 
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
curPos = params.delsysStart - params.delsys5Hz + seconds(1140-60); % this syncs it up with RCS
vidCam.CurrentTime = vidCam.CurrentTime + (1140-60);
% XXXXX
xlims = [curPos-delta curPos+delta];
%%
while ~atEnd
    % XXXXX
    % xxx to make this managable changeed 
    % xlims(2) > max(secs)
    % to 
    % xlims(2) > seconds(140)
    % XXXXX
    if xlims(2) > seconds(1832+60*4) %% CHANGES from max(secs)
        atEnd = 0;
        break; 
    end
    % plot delsys pressure 
    
%     set(haxDelAcc,   'box','off',...
%                    'YTickLabel',[],...
%                    'YTick',[],...
%                    'XTickLabel',[],...
%                    'XTick',[],...
%                    'YLim',ylimsDelsysAcc);
               
%     set(haxRcsAcc,   'box','off',...
%                    'YTickLabel',[],...
%                    'YTick',[],...
%                    'YLim',ylimsRcsAcc,...
%                    'XLim',xlims); % set xlim for all graphs

    set(haxDetector,   'box','off',...
                   'XTickLabel',[],...
                   'XTick',[],...
                   'XLim',xlims); % set xlim for all graphs
               
               set(haxCurent,   'box','off');


                   
        
    % move curser 
    hcur(1).XData = [curPos curPos];
    
    curPos = curPos + seconds(1/params.vidFrame);
    xlims = xlims + seconds(1/params.vidFrame); 
    
    % plot video 
    
    x = readFrame(vidCam);
    x = flipdim(flipdim(imrotate(x,270),2),2); % flip the image

    image(haxVid,x); 
    set(haxVid,  'box','off','XTickLabel',[],'XTick',[],'YTickLabel',[],'YTick',[])
    pbaspect(haxVid,[size(x,2) size(x,1) 1])
        
    fullVidFrame = getframe(hfig);
    writeVideo(v,fullVidFrame);

    cnt = cnt + 1; 
end
close(v); 
close(hfig);