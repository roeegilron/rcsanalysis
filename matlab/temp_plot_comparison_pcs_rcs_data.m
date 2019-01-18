function temp_plot_comparison_pcs_rcs_data()
%% load pc +s data 
pcsfn = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorg_manual/brpd_05/v04_03_wek/s_010_tsk-ipad/BRRAW_brpd05_2014_11_24_12_17_48__MR_2.mat';
load(pcsfn); 
secsBR = seconds((0:length(brraw.ecog)-1 )./794); 

%% load rc+ data 
rcsfn = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v06-home-visit-3-week/rc+s_data/rcs_comp/Session1541438482992/DeviceNPC700395H/RawDataTD.mat';
rcsDevice = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v06-home-visit-3-week/rc+s_data/rcs_comp/Session1541438482992/DeviceNPC700395H/DeviceSettings.mat';
load(rcsfn); 
load(rcsDevice); 

%% plot 
hfig = figure; 
secsUse = secsBR - seconds(115); 
% plot stn 
hsb(1) = subplot(2,2,1); 
hplt = plot(secsUse,brraw.lfp.*1000); 
hplt.Color = [0.8 0 0 0.7];
hplt.LineWidth = 1; 
title('PC+S STN'); 
ylabel('\muV'); 
xlabel('seconds'); 
set(gca,'FontSize',16)
% plot m1 
hsb(2) = subplot(2,2,2); 
hplt = plot(secsUse,brraw.ecog.*1000); 
hplt.Color = [0.8 0 0 0.7];
hplt.LineWidth = 1; 
title('PC+S M1'); 
ylabel('\muV'); 
xlabel('seconds'); 
set(gca,'FontSize',16)

linkaxes(hsb,'xy'); 
xlim(seconds([0 20]));
ylim([-150 150]);

% plot rc+s 
subTime = datetime('05-Nov-2018 09:33:47.375','TimeZone',outdatcomplete.derivedTimes.TimeZone); 

secsUseRcs = seconds(seconds(outdatcomplete.derivedTimes - subTime)); 
% plot stn 
hsbRcs(1) = subplot(2,2,3); 
y = outdatcomplete.key1;
y = y - mean(y); 
y = y.*1e3; 
hplt = plot(secsUseRcs,y); 
hplt.Color = [0 0 0.8 0.7];
hplt.LineWidth = 1; 
title('RC+S STN'); 
ylabel('\muV'); 
xlabel('seconds'); 
set(gca,'FontSize',16)
% plot m1 
hsbRcs(2) = subplot(2,2,4); 
y = outdatcomplete.key3;
y = y - mean(y); 
y = y.*1e3; 
hplt = plot(secsUseRcs,y); 
hplt.Color = [0 0 0.8 0.7];
hplt.LineWidth = 1; 
title('RC+S M1'); 
ylabel('\muV'); 
xlabel('seconds'); 
set(gca,'FontSize',16)
linkaxes(hsbRcs,'x'); 
xlim(seconds([0 20]));
linkaxes(hsbRcs,'y'); 
linkaxes([hsbRcs hsb],'y'); 
%%

params.figname = 'pcs vs rcs raw signal'; 
params.figdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/presentations/figures';
params.figtype = '-djpeg';
plot_hfig(hfig,params)


%% plot spectral data 
frerange = 6:1:60;
overlapFac = 0.875; 
hfig = figure; 
secsUse = secsBR - seconds(115); 
% plot stn 
srate = 794; 
hsb(1) = subplot(2,2,1); 
idxuse = secsUse > seconds(0) & secsUse < seconds(20); 
y = brraw.lfp(idxuse); 
y = y - mean(y); 
y = y.*1e3; 
spectrogram(y,srate,ceil(overlapFac*srate),frerange,srate,'yaxis','psd');
shading interp 
title('PC+S STN'); 
ylabel('Frequency (Hz)'); 
xlabel('Seconds'); 
set(gca,'FontSize',16)
% plot m1 
hsb(2) = subplot(2,2,2); 
idxuse = secsUse > seconds(0) & secsUse < seconds(20); 
y = brraw.ecog(idxuse); 
y = y - mean(y); 
y = y.*1e3; 
spectrogram(y,srate,ceil(overlapFac*srate),frerange,srate,'yaxis','psd');
shading interp 
title('PC+S M1'); 
ylabel('Frequency (Hz)'); 
xlabel('Seconds'); 
set(gca,'FontSize',16)


% plot rc+s 
subTime = datetime('05-Nov-2018 09:33:47.375','TimeZone',outdatcomplete.derivedTimes.TimeZone); 

secsUseRcs = seconds(seconds(outdatcomplete.derivedTimes - subTime)); 
% plot stn 
srate = unique(srates); 
hsbRcs(1) = subplot(2,2,3); 
idxuse = secsUseRcs > seconds(0) & secsUseRcs < seconds(20); 
y = outdatcomplete.key1(idxuse);
y = y - mean(y); 
y = y.*1e3; 
spectrogram(y,srate,ceil(overlapFac*srate),frerange,srate,'yaxis','psd');
shading interp 
title('RC+S STN'); 
ylabel('Frequency (Hz)'); 
xlabel('Seconds'); 
set(gca,'FontSize',16)
% plot m1 
hsbRcs(2) = subplot(2,2,4); 
y = outdatcomplete.key3(idxuse);
y = y - mean(y); 
y = y.*1e3; 
spectrogram(y,srate,ceil(overlapFac*srate),frerange,srate,'yaxis','psd');
shading interp 
title('RC+S STN'); 
ylabel('Frequency (Hz)'); 
xlabel('Seconds'); 
title('RC+S M1'); 
set(gca,'FontSize',16)

clear params
params.figname = 'pcs vs rcs raw signal spectral'; 
params.figdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/presentations/figures';
params.figtype = '-djpeg';
plot_hfig(hfig,params)


end