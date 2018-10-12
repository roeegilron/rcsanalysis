function noise_floor_temp(rawfn) 
%% load data 
% rawfn = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS_test/noise-floor-test-2/RCS-tests-Oct9-2018/test31/Session1539112319744/DeviceNPC700395H/RawDataTD.mat';
[pn,fn] = fileparts(rawfn); 
outdir = pn;
load(rawfn);
%% plot raw data 
hfig = figure;
y = outdatcomplete.key0;
x = outdatcomplete.derivedTimes; 

subplot(2,1,1);
hplt = plot(x,y);
hplt.LineWidth = 3; 
hplt.Color = [0 0 0.8 0.7];
title('Raw data channel 0 (0+0-)');
ylabel('mV'); 
set(gca,'FontSize',16);

subplot(2,1,2);
y = outdatcomplete.key2;
x = outdatcomplete.derivedTimes; 

hplt = plot(x,y);
hplt.LineWidth = 3; 
hplt.Color = [0 0 0.8 0.7];
title('Raw data channel 0 (8+8-)');
ylabel('mV'); 
set(gca,'FontSize',16);

% print 
hfig.PaperPositionMode = 'manual';
hfig.PaperSize         = [15 8]; 
hfig.PaperPosition     = [ 0 0 15 8]; 
fnmuse = fullfile(outdir,'rawdatatimedomain.jpeg'); 
print(hfig,fnmuse,'-r300','-djpeg')


%% plot raw data zooomed 
szes = size(outdatcomplete,1);
idxhalf = ceil(szes/2);
timecut  = outdatcomplete.derivedTimes(idxhalf);

timecut  = outdatcomplete.derivedTimes(idxhalf);
idxuse = outdatcomplete.derivedTimes > timecut; 

hfig = figure;
y = outdatcomplete.key0(idxuse);
x = outdatcomplete.derivedTimes(idxuse); 

subplot(2,1,1);
hplt = plot(x,y);
hplt.LineWidth = 3; 
hplt.Color = [0 0 0.8 0.7];
title('Raw data channel 0 (0+0-)');
ylabel('mV'); 
set(gca,'FontSize',16);

subplot(2,1,2);
y = outdatcomplete.key2(idxuse);
x = outdatcomplete.derivedTimes(idxuse); 

hplt = plot(x,y);
hplt.LineWidth = 3; 
hplt.Color = [0 0 0.8 0.7];
title('Raw data channel 0 (8+8-)');
ylabel('mV'); 
set(gca,'FontSize',16);

% print 
hfig.PaperPositionMode = 'manual';
hfig.PaperSize         = [15 8]; 
hfig.PaperPosition     = [ 0 0 15 8]; 
fnmuse = fullfile(outdir,'rawdatatimedomainzoomed.jpeg'); 
print(hfig,fnmuse,'-r300','-djpeg')


%% plot psd 
szes = size(outdatcomplete,1);
idxhalf = ceil(szes/2);
timecut  = outdatcomplete.derivedTimes(idxhalf);
idxuse = outdatcomplete.derivedTimes > timecut; 
x = outdatcomplete.key0(idxuse); 
x =  x - mean(x); 
[fftOut,f]   = pwelch(x,1e3,1e3/2,0:1:250,1e3,'psd');
clear x 
hfig = figure;
subplot(2,1,1);
hplt = plot(f,log10(fftOut));
hplt.LineWidth = 3; 
hplt.Color = [0 0 0.8 0.7];
title('Noise Floor Channel 0');
xlabel('Frequency (Hz)');
ylabel('Power  (log_1_0\muV^2/Hz)'); 
set(gca,'FontSize',16);
res(1).fftOut = fftOut; 
res(1).f = f; ;

subplot(2,1,2);
x = outdatcomplete.key2(idxuse); 
x =  x - mean(x); 
[fftOut,f]   = pwelch(x,1e3,1e3/2,0:1:250,1e3,'psd');
clear x 
hplt = plot(f,log10(fftOut));
hplt.LineWidth = 3; 
hplt.Color = [0 0 0.8 0.7];
title('Noise Floor Channel 1');
xlabel('Frequency (Hz)');
ylabel('Power  (log_1_0\muV^2/Hz)'); 
set(gca,'FontSize',16);
% print 
hfig.PaperPositionMode = 'manual';
hfig.PaperSize         = [15 8]; 
hfig.PaperPosition     = [ 0 0 15 8]; 
fnmuse = fullfile(outdir,'noisefloorpsd.jpeg'); 
print(hfig,fnmuse,'-r300','-djpeg')
res(2).fftOut = fftOut; 
res(2).f =f;
save(fullfile(outdir,'results.mat'),'res');
end
