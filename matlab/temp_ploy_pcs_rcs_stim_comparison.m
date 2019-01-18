function temp_ploy_pcs_rcs_stim_comparison()
%% load rsc
load /Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v05-home-visit-10-day/rc+s_data/Session1541024226000/DeviceNPC700395H/passive-recharge.mat
%% load pc+s 
fn = '/Users/roee/Starr_Lab_Folder/Data_Analysis/Raw_Data/BR_reorg_manual/brpd_09/v08_06_mnt/s_001_tsk-rest/brpd09_2017_04_18_10_07_43__MR_0.txt';
dat = importdata(fn);
ypc = dat(:,1); 
%% plot 
y = outdatachunk.key1; 
srate = 500;
[fftOut,f]   = pwelch(y,srate,srate/2,0:1:200,srate,'psd');
hfig = figure; 
subplot(1,2,1); 
hplt = plot(f,log10(fftOut)); 
hplt.LineWidth = 5;
hplt.Color = [0 0 0.8 0.7];
xlabel('Frequency (Hz)');
ylabel('Power  (log_1_0\muV^2/Hz)');
set(gca,'FontSize',20);
title('RC+S','FontSize',30);


srate = 794;
[fftOut,f]   = pwelch(ypc,srate,srate/2,0:1:200,srate,'psd');
subplot(1,2,2); 
hplt = plot(f,log10(fftOut)); 
hplt.LineWidth = 5;
hplt.Color = [0.8 0 0 0.7];
xlabel('Frequency (Hz)');
ylabel('Power  (log_1_0\muV^2/Hz)');
set(gca,'FontSize',20);
title('PC+S','FontSize',30);


params.figdir  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/presentations/figures';
params.figtype = '-dpdf';
params.resolution = 300;
params.closeafterprint = 1; 
params.figname = 'rcs pcs stim comaprison stn';

plot_hfig(hfig,params)


end