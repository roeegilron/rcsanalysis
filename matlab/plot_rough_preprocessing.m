%% signal preprocessing
% aim is to characterize minimum signal quality before going forward with
% next steps of analysis

close all; clear all; clc

%% load data base table
dataTable = load('/Users/juananso/Starr Lab Dropbox/RC+S Patient Un-Synced Data/RCS03 Un-Synced Data/SummitData/SummitContinuousBilateralStreaming/RCS03L/output_data_around_med_times_table.mat')

%% inpot variables
figFullScreen = 1;
ii = 10

%% access data
medTime = dataTable.output.MedTime(ii)
sr = dataTable.output.sampleRate(ii);
time = dataTable.output(ii,:).derivedTimes{:,1};
signal.key0 = dataTable.output(ii,:).key0{:,1};
signal.key1 = dataTable.output(ii,:).key1{:,1};
signal.key2 = dataTable.output(ii,:).key2{:,1};
signal.key3 = dataTable.output(ii,:).key3{:,1};

%% creating main figure settings
fig1 = figure;
if figFullScreen
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
    fontSize = 16;
else
    fontSize = 12;
end

%% first glance into time domain signal before any processing
ax1 = subplot(421)
plot(time,signal.key0)

ax3 = subplot(423)
plot(time,signal.key1)

ax5 = subplot(425)
plot(time,signal.key2)

ax7 = subplot(427)
plot(time,signal.key3)

linkaxes([ax1,ax3,ax5,ax7],'x');

%% adding spectrogram
ax2 = subplot(422);
[fftOut,ff]   = pwelch(signal.key0-mean(signal.key0),sr,sr/2,0:1:sr/2,sr,'psd');
plot(ff,log10(fftOut))
set(gca,'FontSize',fontSize);
ylabel('frequency (Hz)')

ax4 = subplot(424);
[fftOut,ff]   = pwelch(signal.key1-mean(signal.key1),sr,sr/2,0:1:sr/2,sr,'psd');
plot(ff,log10(fftOut))
set(gca,'FontSize',fontSize);
ylabel('frequency (Hz)')

ax6 = subplot(426);
[fftOut,ff]   = pwelch(signal.key2-mean(signal.key2),sr,sr/2,0:1:sr/2,sr,'psd');
plot(ff,log10(fftOut))
set(gca,'FontSize',fontSize);
ylabel('frequency (Hz)')

ax8 = subplot(428);
[fftOut,ff]   = pwelch(signal.key3-mean(signal.key3),sr,sr/2,0:1:sr/2,sr,'psd');
plot(ff,log10(fftOut))
set(gca,'FontSize',fontSize);
ylabel('frequency (Hz)')

linkaxes([ax2,ax4,ax6,ax8],'x')

%% add spectrogram


