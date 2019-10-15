function temp_rcs02_dyskinesia_start_make_video()
% make video of RCS02 dyskinesia start 


%% start up 
close all; 
clear all;
clc; 
params.delsysFn   = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/v03_postop_day_2/delsys/RCS02_5-9-19_onmeds_rest_Plot_and_Store_Rep_1.0.csv.mat';
params.vidFn      = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/v03_postop_day_2/vids/MVI_0229.MP4';
params.rcsFolder  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/v03_postop_day_2/RCS02L/Session1557435294506/DeviceNPC700398H';
% load rcs folder times: 
params.rcsTdFn    = fullfile(params.rcsFolder,'RawDataTD.mat');
params.rcsAccFn   = fullfile(params.rcsFolder,'RawDataAccel.mat');
params.rcsEvntFn  = fullfile(params.rcsFolder,'EventLog.mat');
params.rcsDvcStFn = fullfile(params.rcsFolder,'DeviceSettings.mat');
params.delAllignF = fullfile(params.rcsFolder,'delsysAllignInformation.mat'); 
% load delsys allign file 
delparams = load(params.delAllignF,'params');

% note that I added a few seconds to beep time bcs of packet loss 
params.vidStart = 19.216 + 6; % this is without subtractions 
params.delsysStart = seconds(1.7351); % this is where first pressure pulse starts 

params.framewidth = seconds(20); % in seconds 
params.startFrame = params.delsysStart; 
params.vidOut     = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/v03_postop_day_2/figures/dyskinesia_start_manually_adjusted.mp4';
%% load delsys 
load(params.delsysFn);

%% plot delsys video to find out time 
% hfig = figure; 
% y1 = dataraw.TouchL_EMG11_trig;
% y2 = dataraw.TouchR_EMG9_trig; 
% secs = seconds((0:1:length(y1 )-1 )./dataraw.srates.trig); 
% plot(secs,y1); 
% hold on;
% plot(secs,y2);



%% load RCS stuff 
load(params.rcsTdFn); 
rcsDat = outdatcomplete; 
clear outdatcomplete; 
load(params.rcsAccFn); 
rcsDatAcc = outdatcomplete; 
load(params.rcsEvntFn); 
load(params.rcsDvcStFn); 
% below should be commentd out on first run 
delparams = load(params.delAllignF,'params');
correctNums = 1; 
if correctNums 
    params.delsys5Hz = seconds(delparams.params.delsysAllignPoints(2));
    params.rcs5Hz    = seconds(delparams.params.rcsAllignPoints(2));
else
    params.delsys5Hz = seconds(0);
    params.rcs5Hz    = seconds(0);
end


% plot delsys 
hfig1 = figure; 
del5HzEmgFn = 'DBS5HzL_EMG1_IM_';
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
xx = dataraw.DBS5HzL_ACCX1_IM_;
yy = dataraw.DBS5HzL_ACCY1_IM_;
zz = dataraw.DBS5HzL_ACCZ1_IM_;
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
haxRcsSpect    = subplot(nrows,ncols,[3 4 7 8 11 12]);
haxRcsSpectSTN = subplot(nrows,ncols,[15 16 19 20 23 24]);
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


%% plot rcs spectral plot M1
axes(haxRcsSpect); 
cla(haxRcsSpect);
hold on;
y = rcsDat.key3;
y = y -mean(y);
srate = unique(rcsDat.samplerate); 
idxPeaks = [15 30; 67 87]; 
[OutS,t,f] = plot_spectogram_normalized(y,srate,idxPeaks,0,1); 
secs = seconds(t)-params.rcs5Hz;
surf(haxRcsSpect,secs, f, OutS, 'EdgeColor', 'none');
view(2); 
caxis(haxRcsSpect,[0.7 1.45]);
axis tight
shading interp 
% xlabel('seconds');
ylabel('Frequency (Hz)');
view(2); 
title('M1 (Cortical paddle)'); 
% plot curser 
ylimsSpecrtal = get(haxRcsSpect,'YLim'); 
zlimsSpectral = get(haxRcsSpect,'ZLim');
hcur(hcursCnt) = plot3(haxRcsSpect,seconds([0 0]),ylimsSpecrtal,[zlimsSpectral(2) zlimsSpectral(2)],...
    'LineWidth',3,...
    'Color',[0.2 0.2 0.2 0.7]); 
hcursCnt = hcursCnt + 1;
set(haxRcsSpect,'FontSize',16); 

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
axes(haxRcsSpectSTN); 
hold on;
y = rcsDat.key1;
y = y -mean(y); 
srate = unique(rcsDat.samplerate); 
idxPeaks = [15 30; 67 87]; 
[OutS,t,f] = plot_spectogram_normalized(y,srate,idxPeaks,0,1); 
secs = seconds(t)-params.rcs5Hz;
surf(haxRcsSpectSTN,secs, f, OutS, 'EdgeColor', 'none');
view(2); 
caxis(haxRcsSpectSTN,[0.7 1.85]);
ylabel('Frequency (Hz)');
axis tight
shading interp 
% plot curser 
ylimsSpecrtal = get(haxRcsSpectSTN,'YLim'); 
zlimsSpectral = get(haxRcsSpectSTN,'ZLim');
hcur(hcursCnt) = plot3(haxRcsSpectSTN,seconds([0 0]),ylimsSpecrtal,[zlimsSpectral(2) zlimsSpectral(2)],...
    'LineWidth',3,...
    'Color',[0.2 0.2 0.2 0.7]); 
title('STN (DBS lead)'); 
xlabel(haxRcsSpectSTN,'Time (Seconds)'); 

% link all axes 
set(haxRcsSpectSTN,'FontSize',16); 
linkprop(hcur,'XData'); % don't increment since last




% linkaxes([haxDelAcc, haxPres, haxRcsAcc, haxRcsSpect, haxRcsSpectSTN],'x');
% linkaxes([haxDelAcc, haxRcsAcc, haxRcsSpect, haxRcsSpectSTN],'x');
linkaxes([ haxRcsSpect, haxRcsSpectSTN],'x');



%%
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
curPos = params.delsysStart - params.delsys5Hz + seconds(840-15); % this syncs it up with RCS
vidCam.CurrentTime = vidCam.CurrentTime + (840-15);
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
    if xlims(2) > seconds(824+25) %% CHANGES from max(secs)
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

    set(haxRcsSpect,   'box','off',...
                   'XTickLabel',[],...
                   'XTick',[],...
                   'XLim',xlims); % set xlim for all graphs


                   
        
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