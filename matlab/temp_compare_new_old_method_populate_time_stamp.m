function temp_compare_new_old_method_populate_time_stamp()
%% start up
close all;
clear all;
clc;
params.rootdirRCs = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v19_adaptive_month5_day2/rcs_data/Session1553628169628/DeviceNPC700395H';
params.rcsTdFn    = fullfile(params.rootdirRCs,'RawDataTD_new_packet_over_method.mat');
params.rcsAccFn   = fullfile(params.rootdirRCs,'RawDataAccel_new_method.mat');
params.rcsEvntFn  = fullfile(params.rootdirRCs,'EventLog.mat');
params.rcsDvcStFn = fullfile(params.rootdirRCs,'DeviceSettings.mat');
params.fnAdaptive = fullfile(params.rootdirRCs,'AdaptiveLog.json'); 


params.delsysFn   = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v19_adaptive_month5_day2/delsys/RCS01_03-26-19_closedloop_behavioraltesting_onmeds_try2_Plot_and_Store_Rep_1.1.csv.mat';
params.vidFn      = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v19_adaptive_month5_day2/vids/MVI_0067.MP4';
params.drivingTm  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v10-3-month/delsys_driving/driving_start_stop_times_off_stim.csv';
params.vidStart = 365.2315; % this is without subtractions
params.delsysStart = seconds(0.3442); % this is where first pressure pulse starts

params.figdir     = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v19_adaptive_month5_day2/figures';

params.vidOut     = fullfile(params.figdir, 'adaptive_example.mp4');
params.framewidth = seconds(15); % in seconds 
params.vidFrame



%% load RCS stuff
load(params.rcsTdFn);
rcsDat = outdatcomplete;
clear outdatcomplete;
load(params.rcsAccFn);
rcsDatAcc = outdatcomplete;
load(params.rcsEvntFn);
load(params.rcsDvcStFn);
res = readAdaptiveJson(params.fnAdaptive); 

% load delsys 
load(params.delsysFn);
% load video 
vidCam = VideoReader(params.vidFn); 
vidCam.CurrentTime = params.vidStart;

%% plot acc verification 
hfig1 = figure;
% below should be commentd out on first run
correctNums = 1;
if correctNums
    params.delsys5Hz = seconds(2220.6258);
    params.rcs5Hz    = rcsDat.derivedTimes(538067);
else
    params.delsys5Hz = seconds(0);
    params.rcs5Hz    = seconds(0);
end


% plot delsys
hsub(1) = subplot(2,1,1);
delsysChannelFieldNames = fieldnames(dataraw); 
idxBestGuess = cellfun(@(x) any(strfind(lower(x),'dbs')), delsysChannelFieldNames) & ...
    cellfun(@(x) any(strfind(lower(x),'5hz')), delsysChannelFieldNames) & ...
    cellfun(@(x) any(strfind(lower(x),'emg')), delsysChannelFieldNames) ;
if sum(idxBestGuess)  == 1
    chanFnUse = delsysChannelFieldNames{idxBestGuess};
else
    idxUse = find(cellfun(@(x) any(strfind(lower(x),'emg')), delsysChannelFieldNames)==1) ;
    chanFnUse = delsysChannelFieldNames{idxUse(1)};
end
y = dataraw.(chanFnUse);
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


%% plot detevto vs delsys 
% below should be commentd out on first run
close all; 
clc;
correctNums = 1;
if correctNums
    params.delsys5Hz = seconds(392.9715);
    params.rcs5Hz    = rcsDatAcc.derivedTimes(11320);
    params.rcs5HzIdxAcc = 11320;
else
    params.delsys5Hz = seconds(0);
    params.rcs5Hz    = seconds(0);
end
% plot delsys acc 
hfig = figure; 
numsubplots = 8; 
ncols = 1; 
nmplt = 1;
hsubSpectral = subplot(numsubplots,ncols,nmplt); nmplt = nmplt + 1; 
hsubDetector = subplot(numsubplots,ncols,nmplt); nmplt = nmplt + 1; 
hsubCurrent = subplot(numsubplots,ncols,nmplt); nmplt = nmplt + 1; 

haxRcsAcc = subplot(numsubplots,ncols,nmplt); nmplt = nmplt + 1; 
haxDelAcc = subplot(numsubplots,ncols,nmplt); nmplt = nmplt + 1; 
haxDelHand = subplot(numsubplots,ncols,nmplt); nmplt = nmplt + 1; 
haxPressue = subplot(numsubplots,ncols,nmplt); nmplt = nmplt + 1; 
haxiPad = subplot(numsubplots,ncols,nmplt); 


% plot rcs acc 
axes(haxRcsAcc); 
hold on; 
xx = rcsDatAcc.XSamples;
yy = rcsDatAcc.YSamples;
zz = rcsDatAcc.ZSamples;
secs =  rcsDatAcc.derivedTimes - params.rcs5Hz; 
secsUseForAdaptive = secs(params.rcs5HzIdxAcc); 
plot(haxRcsAcc,secs,xx-mean(xx),'LineWidth',2);
plot(haxRcsAcc,secs,yy-mean(yy),'LineWidth',2);
plot(haxRcsAcc,secs,zz-mean(zz),'LineWidth',2);
title(haxRcsAcc,'rcs acc'); 
ylimsRcsAcc = get(haxRcsAcc,'YLim'); 


% plot delstys acc 
axes(haxDelAcc); 
hold on; 

delsysChannelFieldNames = fieldnames(dataraw); 
idxBestGuess = cellfun(@(x) any(strfind(lower(x),'dbs')), delsysChannelFieldNames) & ...
    cellfun(@(x) any(strfind(lower(x),'5hz')), delsysChannelFieldNames) & ...
    cellfun(@(x) any(strfind(lower(x),'acc')), delsysChannelFieldNames) ;
if sum(idxBestGuess)  == 3
    chanFnUse = delsysChannelFieldNames(idxBestGuess);
end

for c = 1:length(chanFnUse)
    xx = dataraw.(chanFnUse{c});
    secs = seconds((0:1:length(xx )-1 )./dataraw.srates.ACC)-params.delsys5Hz; 
    plot(haxDelAcc,secs',xx-mean(xx),'LineWidth',2);
end
title('delsys acc'); 
ylimsDelsysAcc = get(haxDelAcc,'YLim'); 

% plot delsys hand 

axes(haxDelHand); 
hold on; 

delsysChannelFieldNames = fieldnames(dataraw); 
idxBestGuess = cellfun(@(x) any(strfind(lower(x),'hand')), delsysChannelFieldNames) & ...
    cellfun(@(x) any(strfind(lower(x),'r_')), delsysChannelFieldNames) &...  
    cellfun(@(x) any(strfind(lower(x),'acc')), delsysChannelFieldNames);
if sum(idxBestGuess)  == 3
    chanFnUse = delsysChannelFieldNames(idxBestGuess);
end

for c = 1:length(chanFnUse)
    xx = dataraw.(chanFnUse{c});
    secs = seconds((0:1:length(xx )-1 )./dataraw.srates.ACC)-params.delsys5Hz; 
    plot(haxDelHand,secs',xx-mean(xx),'LineWidth',2);
end
title('delsys gyro right hand'); 
ylimsDelsysAcc = get(haxDelHand,'YLim'); 


% plot delsys presssure  
axuse = haxPressue;
axes(axuse); 
hold on; 

delsysChannelFieldNames = fieldnames(dataraw); 
idxBestGuess = cellfun(@(x) any(strfind(lower(x),'index')), delsysChannelFieldNames) & ...
    cellfun(@(x) any(strfind(lower(x),'r_')), delsysChannelFieldNames) &...  
    cellfun(@(x) any(strfind(lower(x),'trig')), delsysChannelFieldNames);
if sum(idxBestGuess)  == 1
    chanFnUse = delsysChannelFieldNames(idxBestGuess);
end

for c = 1:length(chanFnUse)
    xx = dataraw.(chanFnUse{c});
    secs = seconds((0:1:length(xx )-1 )./dataraw.srates.trig)-params.delsys5Hz; 
    plot(axuse,secs',xx-mean(xx),'LineWidth',2);
end
title(axuse,'delsys pressure sensor'); 
ylimsDelsysAcc = get(axuse,'YLim'); 

% plot delsys ipad  
axuse = haxPressue;
axes(haxiPad); 
hold on; 

delsysChannelFieldNames = fieldnames(dataraw); 
idxBestGuess = cellfun(@(x) any(strfind(lower(x),'sound')), delsysChannelFieldNames) & ...
    cellfun(@(x) any(strfind(lower(x),'_')), delsysChannelFieldNames) &...  
    cellfun(@(x) any(strfind(lower(x),'trig')), delsysChannelFieldNames);
if sum(idxBestGuess)  == 1
    chanFnUse = delsysChannelFieldNames(idxBestGuess);
end

for c = 1:length(chanFnUse)
    xx = dataraw.(chanFnUse{c});
    secs = seconds((0:1:length(xx )-1 )./dataraw.srates.trig)-params.delsys5Hz; 
    plot(haxiPad,secs',xx-mean(xx),'LineWidth',2);
end
title(haxiPad,'delsys pressure sensor'); 
ylimsDelsysAcc = get(haxiPad,'YLim'); 

% plot spectral 
haxRcsSpect = hsubSpectral;
axes(haxRcsSpect); 
hold on;
y = rcsDat.key3;
y = y -mean(y); 
srate = unique(rcsDat.samplerate); 
[s,f,t,p] = spectrogram(y,srate,ceil(0.875*srate),1:40,srate,'yaxis','psd');
deltaSubtract = abs(rcsDat.derivedTimes(1) - params.rcs5Hz);
secs = seconds(t)-deltaSubtract; 
surf(haxRcsSpect,secs, f, 10*log10(p), 'EdgeColor', 'none');
% sh = surf(t,f,p);
% caxis([-2.5 2.5]); 
view(0, 90)
axis tight
shading interp 
xlabel(haxRcsSpect,'seconds');
ylabel(haxRcsSpect,'Frequency (Hz)');
view(2); 
title(haxRcsSpect,'M1 RCS spectral'); 

%  adaptive ld0 + thresh 
axes(hsubDetector); 
cur = res.adaptive.CurrentProgramAmplitudesInMilliamps(1,:); 
timestamps = datetime(datevec(res.timing.timestamp./86400 + datenum(2000,3,1,0,0,0))); % medtronic time - LSB is seconds
uxtimes = datetime(res.timing.PacketGenTime/1000,...
    'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
% 
idxuse = 2:length(uxtimes); 
curUse = cur(idxuse); 
timeUse = uxtimes(idxuse); 
timeUse = timeUse - timeUse(1); 

% timeUse = timeUse - secsUseForAdaptive;
timeUse = timeUse -deltaSubtract;

hold on; 
ld0 = res.adaptive.LD0_output(idxuse); 
ld0_high = res.adaptive.LD0_highThreshold(idxuse); 
ld0_low  = res.adaptive.LD0_lowThreshold(idxuse); 

plot(hsubDetector,timeUse,ld0,'LineWidth',3);
hplt = plot(hsubDetector,timeUse,ld0_high,'LineWidth',3);
hplt.LineStyle = '-.';
hplt.Color = [hplt.Color 0.7];
hplt = plot(hsubDetector,timeUse,ld0_low,'LineWidth',3);
hplt.LineStyle = '-.';
hplt.Color = [hplt.Color 0.7];


ylimsUse(1) = res.adaptive.LD0_lowThreshold(1)*0.2;
ylimsUse(2) = res.adaptive.LD0_highThreshold(1)*1.8;



ylimsUse(1) = prctile(ld0,1);
ylimsUse(2) = prctile(ld0,99);

ylim(hsubDetector,ylimsUse); 
title(hsubDetector,'Detector'); 
ylabel(hsubDetector,'Detector (a.u.)'); 
xlabel(hsubDetector,'Time'); 
legend(hsubDetector,{'Detector','Low threshold','High threshold'}); 

% current and state 
axes(hsubCurrent); 
hold on; 
title(hsubCurrent,'state and current'); 
state = res.adaptive.CurrentAdaptiveState(idxuse);
hplt1 = plot(hsubCurrent,timeUse,state,'LineWidth',3); 
hplt1.Color = [0.8 0.8 0 0.7]; 
cur = res.adaptive.CurrentProgramAmplitudesInMilliamps(1,idxuse); 
hplt2 = plot(hsubCurrent,timeUse,cur,'LineWidth',3); 
hplt2.Color = [0.8 0.8 0 0.2]; 
ylim([-1 4]);
legend([hplt1 hplt2],{'state','current'}); 


% link axes 
linkaxes([haxDelAcc, haxRcsAcc haxDelHand axuse haxiPad ...
    haxRcsSpect hsubDetector hsubCurrent],...
    'x'); 
set(haxDelAcc,'XLim',seconds([-20 5*60]));

%% plot video 
close all; 
clc;

% set up figure 
hfig = figure; 
numsubplots = 2; 
ncols = 3; 

hsubSpectral = subplot(numsubplots,ncols,[2 3]);
hsubDetector = subplot(numsubplots,ncols,[5 6]);
haxVid = subplot(numsubplots,ncols,[1 4]);



% plot spectral 
haxRcsSpect = hsubSpectral;
axes(haxRcsSpect); 
hold on;
y = rcsDat.key3;
y = y -mean(y); 
srate = unique(rcsDat.samplerate); 
[s,f,t,p] = spectrogram(y,srate,ceil(0.875*srate),1:40,srate,'yaxis','psd');
deltaSubtract = abs(rcsDat.derivedTimes(1) - params.rcs5Hz);
secs = seconds(t)-deltaSubtract; 
surf(haxRcsSpect,secs, f, 10*log10(p), 'EdgeColor', 'none');
% sh = surf(t,f,p);
% caxis([-2.5 2.5]); 
view(0, 90)
axis tight
shading interp 
ylabel(haxRcsSpect,'Frequency (Hz)');
view(2); 
title(haxRcsSpect,'M1 RCS spectral'); 

ylimsSpecrtal = get(haxRcsSpect,'YLim');
hcur(1) = plot(haxRcsSpect,seconds([0 0]),ylimsSpecrtal,...
    'LineWidth',3,...
    'Color',[0.2 0.2 0.2 0.7]);

%  adaptive ld0 + thresh 
axes(hsubDetector); 
cur = res.adaptive.CurrentProgramAmplitudesInMilliamps(1,:); 
timestamps = datetime(datevec(res.timing.timestamp./86400 + datenum(2000,3,1,0,0,0))); % medtronic time - LSB is seconds
uxtimes = datetime(res.timing.PacketGenTime/1000,...
    'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
% 
idxuse = 2:length(uxtimes); 
curUse = cur(idxuse); 
timeUse = uxtimes(idxuse); 
timeUse = timeUse - timeUse(1); 

% timeUse = timeUse - secsUseForAdaptive;
timeUse = timeUse -deltaSubtract;

hold on; 
ld0 = res.adaptive.LD0_output(idxuse); 
ld0_high = res.adaptive.LD0_highThreshold(idxuse); 
ld0_low  = res.adaptive.LD0_lowThreshold(idxuse); 

plot(hsubDetector,timeUse,ld0,'LineWidth',3);
hplt = plot(hsubDetector,timeUse,ld0_high,'LineWidth',3);
hplt.LineStyle = '-.';
hplt.Color = [hplt.Color 0.7];
hplt = plot(hsubDetector,timeUse,ld0_low,'LineWidth',3);
hplt.LineStyle = '-.';
hplt.Color = [hplt.Color 0.7];


ylimsUse(1) = res.adaptive.LD0_lowThreshold(1)*0.2;
ylimsUse(2) = res.adaptive.LD0_highThreshold(1)*1.8;



ylimsUse(1) = prctile(ld0,1);
ylimsUse(2) = prctile(ld0,99);

ylim(hsubDetector,ylimsUse); 
title(hsubDetector,'Detector'); 
ylabel(hsubDetector,'Detector (a.u.)'); 
xlabel(hsubDetector,'Time'); 
legend(hsubDetector,{'Detector','Low threshold','High threshold'}); 

hcur(2) = plot(hsubDetector,seconds([0 0]),ylimsUse,...
    'LineWidth',3,...
    'Color',[0.2 0.2 0.2 0.7]);


% link all axes
linkprop(hcur,'XData');
linkaxes([hsubDetector haxRcsSpect],'x'); 


% plot stuff for video 
% start by plotting video figure 


% set up image of video 
cnt = 1; 
%
% set up video 
v = VideoWriter(params.vidOut,'MPEG-4'); 
hfig.Position =  [1000         306        1255        1032];
v.Quality = 100; 
v.FrameRate = vidCam.FrameRate; 

% video writing from
frameRateCam   = vidCam.FrameRate; 
params.vidFrame   = frameRateCam; % number of seconds to advance for each video frame 

open(v); 
% set up curser position to sync with video beep start 
delta = params.framewidth/2; 

% XXXXX
% note added 53 secounds so action starts sooner 
curPos = seconds(0); 
vidCam.CurrentTime = vidCam.CurrentTime ;
% XXXXX
xlims = [curPos-delta curPos+delta];

atEnd = 0;
while ~atEnd
    % XXXXX
    % xxx to make this managable changeed 
    % xlims(2) > max(secs)
    % to 
    % xlims(2) > seconds(140)
    % XXXXX
    if xlims(2) > seconds(60*2);
        atEnd = 0;
        break; 
    end
    %%%% XXX 
    % plot delsys pressure 
    
    set(haxRcsSpect,   'box','off',...
                   'XTickLabel',[],...
                   'XTick',[]);
               
    set(hsubDetector,   'box','off',...
                   'YTickLabel',[],...
                   'YTick',[],...
                   'XLim',xlims); % set xlim for all graphs

                   
        
    % move curser 
    hcur(1).XData = [curPos curPos];
    
    curPos = curPos + seconds(1/params.vidFrame);
    xlims = xlims + seconds(1/params.vidFrame); 
    
    % plot video 

    x = readFrame(vidCam);
    tx = permute(x,[2 1 3]);
    image(haxVid,tx);
    set(haxVid, 'box','off','XTickLabel',[],'XTick',[],'YTickLabel',[],'YTick',[])
    axis(haxVid,'image');
%     pbaspect(haxVid,[size(x,2) size(x,1) 1])
        
    fullVidFrame = getframe(hfig);
    writeVideo(v,fullVidFrame);

    cnt = cnt + 1; 
end
close(v); 

end