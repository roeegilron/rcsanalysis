function plot_neuroDAC_paper(fn)

%% plots two data sets of processed data side by side
close all; clear all; clc

%%%%%%%%%%%%%% Your data directory %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fin = '/Users/juananso/Dropbox (Personal)/Work/DATA/benchtop/neuroDAC/paper/dataSetsMat/';

%% These are sense settings of this dataSets: '+2-0 lpf1-100Hz lpf2-100Hz sr-500Hz stimRate-129.9Hz';

%%%%%%%%%%%%%% Decide on this %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
focusThresholdA = 0;
focusThresholdB = 1;
lineWidth = 2;

%% load Signal
a = load(fullfile(fin,'artificial.mat'));
b = load(fullfile(fin,'patient.mat'));


%% prepare figure
hF = figure(1);
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
fontSize = 16;

%% Plot artificial signal panel (left or A)
titleA = 'adaptive DBS for artificial beta burst amplitude modulated signal'
ax1 = subplot(521); % time domain
plot(a.signal.timeDomain.t,a.signal.timeDomain.y,'k');
title(titleA);
ylabel('Voltage (\muV)')
set(gca,'FontSize',fontSize);
set(ax1,'ylim',[-75 75])

ax2 = subplot(523); % spectrum (if wished)
hS = pcolor(a.signal.spectrogram.tp,a.signal.spectrogram.fp,10*log10(abs(a.signal.spectrogram.sp)));
shading flat
set(gca,'FontSize',fontSize);
ylabel('frequency (Hz)')

ax3 = subplot(525); % power or detector
hold on
plot(a.signal.PowerDetector.t,a.signal.PowerDetector.y,'LineWidth',lineWidth,'Color','m');
ht1 = plot(a.signal.PowerDetector.t,a.signal.PowerDetector.hth,'LineWidth',lineWidth);
ht1.LineStyle = '-.';
ht1.Color = [ht1.Color 1];
ht2 = plot(a.signal.PowerDetector.t,a.signal.PowerDetector.lth,'LineWidth',lineWidth);
ht2.LineStyle = ':';
ht2.Color = [ht2.Color 1];
set(gca,'FontSize',fontSize);
ylabel('Power (LSB)');
if focusThresholdA
    axis([0 a.signal.PowerDetector.t(end) 0 a.signal.PowerDetector.hth(1)+(a.signal.PowerDetector.hth(1)/2)])
end
legend([ht1;ht2],'ld-th high','ld-th low')

ax4 = subplot(527); % stim current
plot(a.signal.StimCurrent.t,a.signal.StimCurrent.y,'LineWidth',lineWidth,'Color','b');
set(gca,'FontSize',fontSize); 
ylabel('Current (mA)')

ax5 = subplot(529); % stim state
plot(a.signal.state.t,a.signal.state.y,'LineWidth',lineWidth,'color',[26,148,49]/255);
set(gca,'FontSize',fontSize);
ylabel('State (#)')
xlabel('Time (s) (all plots)')

linkaxes([ax1,ax2,ax3,ax4,ax5],'x')
set(ax2,'xlim',[0 30])
set(gca,'xlim',[0 30])

%% Plot neural pallidal signal panel (right or B)
titleB = 'adaptive DBS for neural pallidal beta power feature'
ax6 = subplot(522); % time domain
plot(b.signal.timeDomain.t,b.signal.timeDomain.y,'k');
title(titleB);
ylabel('Voltage (\muV)')
set(gca,'FontSize',fontSize);
% axis tight
set(ax6,'ylim',[-75 75])

ax7 = subplot(524); % spectrum (if wished)
pcolor(b.signal.spectrogram.tp,b.signal.spectrogram.fp,10*log10(abs(b.signal.spectrogram.sp)));
shading flat
set(gca,'FontSize',fontSize);
ylabel('frequency (Hz)')

ax8 = subplot(526); % power or detector
hold on
ax2 = plot(b.signal.PowerDetector.t,b.signal.PowerDetector.y,'LineWidth',lineWidth,'Color','m');
ht1 = plot(b.signal.PowerDetector.t,b.signal.PowerDetector.hth,'LineWidth',lineWidth);
ht1.LineStyle = '-.';
ht1.Color = [ht1.Color 1];
ht2 = plot(b.signal.PowerDetector.t,b.signal.PowerDetector.lth,'LineWidth',lineWidth);
ht2.LineStyle = ':';
ht2.Color = [ht2.Color 1];
set(gca,'FontSize',fontSize);
ylabel('Power (LSB)');
if focusThresholdB
    axis([0 b.signal.PowerDetector.t(end) 0 b.signal.PowerDetector.hth(1)+(b.signal.PowerDetector.hth(1)/2)])
end
legend([ht1;ht2],'ld-th high','ld-th low')

ax9 = subplot(528); % stim current
plot(b.signal.StimCurrent.t,b.signal.StimCurrent.y,'LineWidth',lineWidth,'Color','b');
set(gca,'FontSize',fontSize); 
ylabel('Current (mA)')

ax10 = subplot(5,2,10); % stim state
plot(b.signal.state.t,b.signal.state.y,'LineWidth',lineWidth,'color',[26,148,49]/255);
set(gca,'FontSize',fontSize);
ylabel('State (#)')
xlabel('Time (s) (all plots)')

linkaxes([ax6,ax7,ax8,ax9,ax10],'x')
set(ax7,'xlim',[0 30])
set(gca,'xlim',[0 30])

%% save figure
fileName = fullfile(fin,'outFig.png');
saveas(hF,fileName)

fileName = fullfile(fin,'outFig.fig');
saveas(hF,fileName)

end