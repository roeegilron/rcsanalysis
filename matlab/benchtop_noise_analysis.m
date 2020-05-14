%% Analysis of floor noise in time and frequency for test bench configurations
close all; clear all; clc

%% adding path to json toolbox 
addpath([pwd,'/toolboxes/turtle_json/src/'])

%% load data
dirname = uigetdir('/Users/juananso/Starr Lab Dropbox/juan_testing/newFirmwareDev')
[outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerTable] = MAIN_load_rcs_data_from_folder(dirname);
saveFigDir = fullfile(dirname,'/Figures');
if ~isfolder(saveFigDir)
    mkdir(saveFigDir)
end

%% Extract parameters
sr = outdatcomplete.samplerate(1);

%% plot time series
factor = 1; % this factor is STILL ON RESEARCH %%%%%%%%%%%%%%%%%%
y = (outdatcomplete.key0*1e3)/factor; % transform data from millivolts to microvolts
x = 0:1/sr:length(y)/sr-(1/sr);
DC_mV = mean(y)/1000 % im mV
y = y-mean(y);
rms_uV = rms(y)

titleUse = outRec(1).tdData(1).chanFullStr; 
fig1 = figure;
plot(x,y);
title(titleUse);
set(gca,'FontSize',16);
ylabel('Voltage (microVolt)')
xlabel('Time (s)')
legend(['raw signal, ','offset (mV) = ', num2str(round(DC_mV)),', rms (uV) = ', num2str(round(rms_uV))]) %, ...
% axis([0 max(x) -200 200])
figureName = 'TimeSeries.png';
pointFig = fullfile(saveFigDir,figureName);
saveas(fig1,pointFig)

%% Zoom into 0.5 second of data, 10 cycles a5t 20 Hz
duraSecs = 0.5;
nSamples = sr*duraSecs;
x_start = length(x)/2;  % start in the middle
x_ms = x(x_start:x_start+nSamples);

fig2 = figure;
plot(x_ms,y(length(x)/2:length(x)/2+nSamples))
title(titleUse);
set(gca,'FontSize',16);
ylabel('Voltage (microVolt)')
xlabel('Time (s)')

figureName = 'TimeSeries_Zoomed.png';
pointFig = fullfile(saveFigDir,figureName);
saveas(fig2,pointFig)

%% Amplitude spectral density, averaging version with pwelch, as Roee, but after having transformed to micrVolt
[fftOut,ff]   = pwelch(y,sr,sr/2,0:1:sr/2,sr,'psd');
fig3 = figure;
plot(ff,log10(fftOut))
title(titleUse)
set(gca,'FontSize',16);
xlabel('Frequency (Hz)')
ylabel('Power  (log_1_0\muV^2/Hz)');
% axis([0 500 -10 max(log10(fftOut))])

figureName = 'PSD.png';
pointFig = fullfile(saveFigDir,figureName);
saveas(fig3,pointFig)

% transform it to microV/Hz
fig4 = figure;
plot(ff,(sqrt(fftOut)))
title(titleUse)
set(gca,'FontSize',16);
xlabel('Frequency (Hz)')
ylabel('Amplitude (uV/Hz)')

figureName = 'ASD.png';
pointFig = fullfile(saveFigDir,figureName);
saveas(fig4,pointFig)