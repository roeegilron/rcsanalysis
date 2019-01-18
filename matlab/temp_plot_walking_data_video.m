figure;
secs = seconds(seconds(accDataRcs.derivedTimes - accDataRcs.derivedTimes(1))); 
size(accDataRcs.YSamples); 
%% 
close all

%% 

%% load delsys 
load('/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v07-home-visit-long-walking-session/delsys/original/Rcs-walking-fulll-test_Plot_and_Store_Rep_2.1.csv.mat');

%% load rc +S 

dataDir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v07-home-visit-long-walking-session/Session1541628128409/DeviceNPC700395H';
% load files 
load(fullfile(dataDir,'RawDataTD.mat'));
rcsDat = outdatcomplete; 
rcsSrate = srates; 
clear outdatcomplete srates; 

load(fullfile(dataDir,'RawDataAccel.mat'));
accDataRcs = outdatcomplete; 
accSrate = srates; 
clear outdatcomplete srates; 

load(fullfile(dataDir,'DeviceSettings.mat'));


%% resample delsys data 
fnmsDelsys = fieldnames(dataraw);
idx = cellfun(@(x) any(regexpi(x,'dbs')), fnmsDelsys) & ...
cellfun(@(x) any(regexpi(x,'acc')), fnmsDelsys);
fnmuse = fnmsDelsys(idx);
for f = 1:length(fnmuse)
xresamp(:,f) = resample(dataraw.(fnmuse{f}),10000,23148);
end
secsDelsys = seconds( (0:1:size(xresamp(:,1),1)-1)./64); 

% change x any direction to be equal to rc+s 
xresamp(:,2) = xresamp(:,2).*(-1);
xresamp(:,3) = xresamp(:,3).*(-1);
delActData = xresamp; 
delsPreProc = processActigraphyData(delActData,64); 
%%

%% preprocess acc data 
accDataOut(:,1) = accDataRcs.XSamples; 
accDataOut(:,2) = accDataRcs.YSamples; 
accDataOut(:,3) = accDataRcs.ZSamples; 
RcsPreProc = processActigraphyData(accDataOut,64); 
secsRcs = seconds( (0:1:size(accDataOut(:,1),1)-1)./64); 
%%

%% plot data regular 
figure; 
% delsys 
subplot(2,1,1); 
hold on; 
plot(secsDelsys,delActData); 
legend({'x','y','z'});
title('delsys'); 

% rc+s 
subplot(2,1,2); 
hold on; 
plot(secsRcs,accDataOut); 
legend({'x','y','z'});
title('rc+s'); 
%% 

%% plot actigraphy spectral plot 
y = accDataOut(:,2); 
figure;
srate = 64; 
[s,f,t,p] = spectrogram(y,64,ceil(0.8750*64),1:30,64,'yaxis','power');
surf(t, f, zscore(p), 'EdgeColor', 'none');
caxis([-0.5 0.5]); 
shading interp; 
view([0 90]);
%%
[fftOut,f]   = pwelch(y,srate,srate/2,0:0.6:srate/2,srate,'psd');
figure; 
plot(f,log10(fftOut));

%% plot rc+s data walking with accelratmory 
figure;
hsb(1) = subplot(2,1,1); 
rcsSecs = seconds(seconds(rcsDat.derivedTimes - rcsDat.derivedTimes(1))); 
idxuse  = rcsSecs > seconds(200) & rcsSecs < seconds(2000); 
secsUse = rcsSecs(idxuse); 
y = rcsDat.key3;
y = y(idxuse); 

srate = 500; 
[s,f,t,p] = spectrogram(y,srate,ceil(0.875*srate),2:50,srate,'yaxis','psd');
% zp = zscore(p); 
pscaled = abs(p)./abs(repmat(mean(p,2),1,size(p,2)));
pcolor(t, f,zscore(p));
% sh = surf(t,f,p);
view(0, 90)
axis tight
shading interp 
caxis([-1 1])
view(2); 

% plot acceleraion
hsb(2) = subplot(2,1,2); 
hold on; 
idxuse  = secsRcs > seconds(200) & secsRcs < seconds(2000); 
secsUsePlot = secsRcs(idxuse); 
secsUsePlot = seconds(secsUsePlot - secsUsePlot(1)); 
plot(secsUsePlot,accDataOut(idxuse,1)');
plot(secsUsePlot,accDataOut(idxuse,2)');
plot(secsUsePlot,accDataOut(idxuse,3)');

linkaxes(hsb,'x');
% caxis([-0.5 0.5]); 
%%
[fftOut,f]   = pwelch(y,srate,srate/2,0:0.5:srate/2,srate,'psd');
figure; 
plot(f,log10(fftOut));



%% plot data synced  
figure; 
% delsys 
delSubFactor = seconds(delsysDataPoint.DataIndex./64);
hsb(1) = subplot(2,1,1); 
hold on; 
plot(secsDelsys-delSubFactor,delActData); 
legend({'x','y','z'});
title('delsys'); 
% rc+s 
rcsSubFactor = seconds(rcsDataPoint.DataIndex./64);
hsb(2) = subplot(2,1,2); 
hold on; 
plot(secsRcs-rcsSubFactor,accDataOut); 
legend({'x','y','z'});
title('rc+s'); 
linkaxes(hsb,'x'); 
%% 

%% plot dat processsed 

figure; 
% delsys 
subplot(2,1,1); 
hold on; 
plot(secsDelsys,delsPreProc); 
title('delsys'); 
% rc+s 
subplot(2,1,2); 
hold on; 
plot(secsRcs,RcsPreProc); 
title('rc+s'); 

%% compute lag 
[acor,lag] = xcorr(RcsPreProc-mean(RcsPreProc,delsPreProc));

[~,I] = max(abs(acor));
lagDiff = lag(I)


figure;
subplot(2,1,1); 
hold on; 
plot(accDataRcs.XSamples); 
plot(accDataRcs.YSamples); 
plot(accDataRcs.ZSamples); 


title('rc+s');

subplot(2,1,2);
hold on; 
xresamp = resample(dataraw.DBS_5Hz_1_ACCX1_IM_,10000,23148);
xsecres = seconds( (0:1:length(xresamp)-1)./64); 


xraw    = dataraw.DBS_5Hz_1_ACCX1_IM_; 
xsec    = seconds( (0:1:length(xraw)-1)./dataraw.srates.ACC); 
figure;
hold on; 
plot(xsecres,xresamp); 
plot(xsec,xraw); 


plot(dataraw.DBS_5Hz_1_ACCX1_IM_); 
plot(dataraw.DBS_5Hz_1_ACCY1_IM_.*(-1)); 
plot(dataraw.DBS_5Hz_1_ACCZ1_IM_.*(-1)); 
legend({'x','y','z'});
title('delsys')

%% load driving vid matlab
vidname = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v07-home-visit-long-walking-session/vids/MVI_0208.MP4'; 
vid = VideoReader(vidname); 

%% plot rc+s data 
figure; 
plot(rcsDat.derivedTimes, rcsDat.key3);

%% plot accelration 
hfig = figure; 
hold on; 
plot(accDataRcs.derivedTimes,accDataRcs.XSamples); 


[unqtms, idxs] =  unique( rcsDat.derivedTimes); 

pspectrum(rcsDat.key3(idxs),rcsDat.derivedTimes(idxs), ...
    'spectrogram', ...
    'FrequencyLimits',[6 80],'TimeResolution',0.5)


%% plot spectral plot 
figure; 
y = rcsDat.key3;

srate = 500; 
[s,f,t,p] = spectrogram(y,srate,ceil(0.875*srate),2:50,srate,'yaxis','psd');
% zp = zscore(p); 
pscaled = abs(p)./abs(repmat(mean(p,2),1,size(p,2)));
pcolor(t, f,zscore(p));
% sh = surf(t,f,p);
view(0, 90)
axis tight
shading interp 
caxis([-1 1])
view(2); 


%% plot video of driving + dummy spectral data 
vidname = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v07-home-visit-long-walking-session/vids/MVI_0205.MP4'; 

y = rcsDat.key3;
secs = (1:size(y,1))./500;
secStart = size(y,1) - 444*500; % time to take back 
secEnd = size(y,1) -344*500;

secStart = size(y,1) - 260000; % time to take back 
secEnd = size(y,1) -250000;

vread = VideoReader(vidname);
vread.CurrentTime = 5*60; 

% Generate a set of frames, get the frame from the figure, and then write each frame to the file.
framesize = 10; % in seconds
startframe = secStart - framesize/2;
endframe = startframe + framesize;

idx = secs   > startframe & secs < (secEnd + framesize/2);


% open figure 
hfig = figure('Visible','on','Position',[336         746        1199         592]);
hfig.Color='w'; %Set background color of figure window


hemp = subplot(1,2,2); hold on;
xposempline = secStart + framesize/2;

srate = 500;
% [s,f,t,p] = spectrogram(y,srate,ceil(0.875*srate),2:50,srate,'yaxis','psd');
% zp = zscore(p);
pscaled = abs(p)./abs(repmat(mean(p,2),1,size(p,2)));
pcolor(hemp,t, f,zscore(p));
% sh = surf(t,f,p);
view(0, 90)
axis tight
shading interp
caxis([-1 1])
view(2);

hVidLineEmp = plot(hemp,[xposempline xposempline], hemp.YLim,'LineWidth',4,'Color',[0.1 0.1 0.1 0.9]);

fnm = sprintf('drivingdemo-%d-%d-secs.mp4',secStart,secEnd);

v = VideoWriter(fnm,'MPEG-4');


hvid = subplot(2,2,1); axis tight; box off; axis off;
inc = 1/v.FrameRate ;
incvid =  1/vread.FrameRate;
open(v);

startframeEm = 0;
endframeEm = startframeEm + framesize;
incEm = inc;

fcnt = 1;

while endframe < secEnd
    try
        start = tic;
        % video
        vidFrame = readFrame(vread);
        image(vidFrame, 'Parent', hvid);axis tight; axis off;
        %    vread.CurrentTime = vread.CurrentTime +  incvid;
        
        % empatica
        xlim(hemp,[startframeEm endframeEm]);
        hVidLineEmp.XData = hVidLineEmp.XData + incEm;
        hVidLineEmp.YData = hemp.YLim;
        %    datetick(hemp,'x','MM:SS:FFF');
        % grab frame
        frame(fcnt) = getframe(hfig);
        writeVideo(v,frame(fcnt));
        
        %    X = screencapture(hfig);
        %
        %    frame(fcnt) = im2frame(X);
        
        % increment time counters
        fcnt = fcnt + 1;
        startframe = startframe + inc;
        endframe = endframe + inc;
        startframeEm = startframeEm + incEm;
        endframeEm = endframeEm + incEm;
        %         fprintf('frame %d end time %.2f written in %f\n',...
        %             fcnt, endframe,toc(start));
        fprintf('vid time = %0.3f, em time = %0.3f\n',...
            vread.CurrentTime,endframeEm-framesize/2);
    catch
        close(v);
    end
    
end

close(v);
close(hfig);
