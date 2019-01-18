function temp_plot100hz
%% load data 
load /Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v04-home-visit/rcs-data/Session1540414678805/DeviceNPC700395H/1000hzSNRtest-clean.mat
load /Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v04-home-visit/rcs-data/Session1540414678805/DeviceNPC700395H/1000hzSNRtest.mat

srate = 1e3; 
figure; 
hs(1) = subplot(1,2,1); 
y = outdatachunk.key0;
y = y - mean(y);
win = srate*3; 
noverlap = ceil(win*0.90); 
[fftOut,f]   = pwelch(y,win,noverlap,0:1:srate/2,srate,'psd');
hold on;
hplt = plot(f,log10(fftOut));
hplt.Color = [0.8 0 0 0.7]; 
hplt.LineWidth = 2; 
y = outdatachunk.key1;
y = y - mean(y);
[fftOut,f]   = pwelch(y,win,noverlap,0:1:srate/2,srate,'psd');
hplt = plot(f,log10(fftOut));
hplt.Color = [0 0 0.8 0.7]; 
hplt.LineWidth = 2; 
legend({'chan 1','chan2'}); 
title('not averaged'); 

hs(2) = subplot(1,2,2); 
y = mean([outdatachunk.key0,outdatachunk.key1],2);
[fftOut,f]   = pwelch(y,win,noverlap,0:1:srate/2,srate,'psd');
hplt = plot(f,log10(fftOut));
hplt.Color = [0 0.8 0 0.7]; 
hplt.LineWidth = 2; 
title('averaged'); 
linkaxes(hs,'x');
%% plot pac 
hfig = figure;
addpath(genpath('/Users/roee/Starr_Lab_Folder/Data_Analysis/PAC'));

pacparams.PhaseFreqVector      = 5:2:50;
pacparams.AmpFreqVector        = 10:5:420;

pacparams.PhaseFreq_BandWidth  = 4;
pacparams.AmpFreq_BandWidth    = 10;
pacparams.computeSurrogates    = 0;
pacparams.numsurrogate         = 0;
pacparams.alphause             = 0.05;
pacparams.plotdata             = 0;
pacparams.useparfor            = 0; % if true, user parfor, requires parallel computing toolbox

% pac plot
y = mean([outdatachunk.key0,outdatachunk.key1],2);

results = computePAC(y',srate,pacparams);
contourf(results.PhaseFreqVector+results.PhaseFreq_BandWidth/2,...
    results.AmpFreqVector+results.AmpFreq_BandWidth/2,...
    results.Comodulogram',30,'lines','none')
shading interp
set(gca,'fontsize',14)
ttly = sprintf('Amplitude Frequency %s (Hz)','1-3');
ylabel(ttly)
ttlx = sprintf('Phase Frequency %s (Hz)','1-3');
xlabel(ttlx)
title('1000 hz pac');
