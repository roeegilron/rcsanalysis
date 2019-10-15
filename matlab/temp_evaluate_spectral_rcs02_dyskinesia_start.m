function temp_evaluate_spectral_rcs02_dyskinesia_start()
%% load data 
clear all
close all 

pathChronux = genpath('/Users/roee/Downloads/chronux_2_11');
addpath(pathChronux);

params.rcsFolder  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/v03_postop_day_2/RCS02L/Session1557435294506/DeviceNPC700398H';

prfig.figdir  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/v03_postop_day_2/figures';
prfig.figtype = '-djpeg';
prfig.resolution = 600;
prfig.closeafterprint = 0; 


% load rcs folder times: 
params.rcsTdFn    = fullfile(params.rcsFolder,'RawDataTD.mat');
params.rcsAccFn   = fullfile(params.rcsFolder,'RawDataAccel.mat');
params.rcsEvntFn  = fullfile(params.rcsFolder,'EventLog.mat');
params.rcsDvcStFn = fullfile(params.rcsFolder,'DeviceSettings.mat');
params.delAllignF = fullfile(params.rcsFolder,'delsysAllignInformation.mat'); 

load(params.rcsTdFn); 
rcsDat = outdatcomplete; 
hfig = figure; 
haxRcsSpectM1 = subplot(2,1,1);
haxRcsSpectSTN = subplot(2,1,2);
%% plot rcs spectral plot m1
axes(haxRcsSpectM1); 
hold on;
y = rcsDat.key3;
y = y -mean(y); 
srate = unique(rcsDat.samplerate); 
idxPeaks = [15 30; 67 87]; 
[OutS,t,f] = plot_spectogram_normalized(y,srate,idxPeaks,0,0); 
secs = minutes(minutes(seconds(t)));
surf(haxRcsSpectM1,secs, f, OutS, 'EdgeColor', 'none');
view(2); 
% caxis(haxRcsSpectM1,[0.7 1.85]);
xlabel(haxRcsSpectM1,'');
set(haxRcsSpectM1,'XTick',[]);
ylabel('Frequency (Hz)');
title('M1'); 
axis tight
shading interp 
hcol = colorbar;
ylabel(hcol, '% over 1/f')
set(gca,'FontSize',20);



%% plot rcs spectral plot STN
axes(haxRcsSpectSTN); 
hold on;
y = rcsDat.key1;
y = y -mean(y); 
srate = unique(rcsDat.samplerate); 
idxPeaks = [15 30; 67 87]; 
[OutS,t,f] = plot_spectogram_normalized(y,srate,idxPeaks,0,0); 
secs = minutes(minutes(seconds(t)));
surf(haxRcsSpectSTN,secs, f, OutS, 'EdgeColor', 'none');
view(2); 

% caxis(haxRcsSpectSTN,[0.7 1.95]);

axis tight
shading interp 
xlabel('Minutes');
ylabel('Frequency (Hz)');
title('STN'); 
hcol = colorbar;
ylabel(hcol, '% over 1/f')
set(gca,'FontSize',20);


linkaxes([haxRcsSpectM1 haxRcsSpectSTN],'x'); 
set(gcf,'Color','w');



prfig.plotwidth           = 15;
prfig.plotheight          = 10;
prfig.figname             = 'transition to dyskinesia not normalized';
plot_hfig(hfig,prfig)





% 
% %load data 
% params.rcsFolder  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/v03_postop_day_2/RCS02L/Session1557435294506/DeviceNPC700398H';
% % load rcs folder times: 
% params.rcsTdFn    = fullfile(params.rcsFolder,'RawDataTD.mat');
% params.rcsAccFn   = fullfile(params.rcsFolder,'RawDataAccel.mat');
% params.rcsEvntFn  = fullfile(params.rcsFolder,'EventLog.mat');
% params.rcsDvcStFn = fullfile(params.rcsFolder,'DeviceSettings.mat');
% params.delAllignF = fullfile(params.rcsFolder,'delsysAllignInformation.mat');
% load(params.rcsTdFn);
% 
% %% run analysis 
% figure;
% idxuse = 385395:795173;
% y = outdatcomplete.key3(idxuse);
% m1 = y -mean(y); 
% 
% hplt(1) = subplot(2,1,1);
% plot(m1);
% title('m1'); 
% 
% y = outdatcomplete.key1(idxuse);
% stn = y -mean(y); 
% hplt(2) = subplot(2,1,2);
% plot(stn);
% title('stn'); 
% linkaxes(hplt,'x');
% 
% %% plot spectral 
% data = m1';
% plot_spectogram_normalized(data,500,idxPeaks);
% % set params for ERSP prodcution 
% specparams.tapers       = [3 5]; % precalculated tapers from dpss or in the one of the following
% specparams.pad          = 1;% padding factor for the FFT) - optional
% specparams.err          = [2 0.05]; % (error calculation [1 p] - Theoretical error bars; [2 p] - Jackknife error bars
% specparams.trialave     = 0; % (average over trials/channels when 1, don't average when 0) 
% specparams.Fs           = unique(outdatcomplete.samplerate); % sampling frequency 
% centerFreqs             = make_center_frequencies(2,100,60,4);
% 
% specparams.fpass        = centerFreqs; %frequency band to be used in the calculation in the form [fmin fmax])- optional. 
% specparams.fpass        = [1 100]; %frequency band to be used in the calculation in the form [fmin fmax])- optional. 
% movingwin = [2 2*0.95];% (in the form [window winstep] i.e length of moving window and step size) Note that units here have to be consistent with units of Fs - required
% [S,t,f,Serr] = mtspecgramc(data,movingwin,specparams);
% 
% 
% %%
% figure;   
% SerrLog = 10.*log10(Serr); 
% SLogLor = squeeze(SerrLog(1,:,:));
% SLogUpr = squeeze(SerrLog(2,:,:));
% SLog = 10.*log10(S); 
% % scale between zero to one 
% SLogScaled = rescale(SLog,0,1);
% % idx of peaks 
% idxPeaks = [15 30; 67 87]; 
% idxPeaks = f >= idxPeaks(1,1) & f <= idxPeaks(1,2) | ...
%            f >= idxPeaks(2,1) & f <= idxPeaks(2,2) ;
% idxNotPeaks = ~idxPeaks; 
% % get avg
% MeanVal= mean(SLogScaled(:,idxNotPeaks),1);
% % find poly nomial 
% figure;
% hold on;
% polyFit6 = fit(f(idxNotPeaks)',MeanVal','poly6');
% plot(MeanVal,f(idxNotPeaks),'o')
% plot(poly,'b');
% % fit all freq ranges 
% fVals = polyFit6(f);
% PolyRep = repmat(fVals,1,size(SLog,1))';
% 
% figure;
% pcolor(t,f,(SLogScaled./PolyRep)' ); axis xy; colorbar; title('S/Lower');
% shading interp
% 
% %%
% 
%    subplot(411); imagesc(t,f,SLogLor'); axis xy; colorbar; title('Lower confidence');
%    subplot(412); imagesc(t,f,SLog'); axis xy; colorbar; title('Real Data');
%    subplot(413); imagesc(t,f,SLogUpr'); axis xy; colorbar; title('Upper confidence');
%    subplot(414); imagesc(t,f,(SNorm)' ); axis xy; colorbar; title('S/Lower');
% 
%  plot_matrix(S,t,f,'l',Serr)
% xlabel([]); % plot spectrogram
% caxis([-150 -30]); colorbar;
% 
% caxis([-5 6]);
% colorbar;
% hplot = imagesc(t,f,10*log10(S'));
% axis xy; % flip axis so frequncies go from top to bottom 
% 


%% remove path and cleanup 
rmpath(pathChronux); 



