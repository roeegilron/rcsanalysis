load /Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v06-home-visit-3-week/rc+s_data/rcs_comp/Session1541438482992/DeviceNPC700395H/ipadDataOffMeds.mat

hfig = figure;
y = rcsIpadData.key3;
srate = 500;
hsb(1) = subplot(2,1,1); 
y = y -mean(y); 
secs = (0:1:length(y)-1)./srate; 
secs = secs - 20; 

plot(secs,y.*1e3); 
ylim([-0.35 .35].*1e3);
ylabel('\muV'); 
title('Raw RC+S M1 LFP data during movement task'); 
set(gca,'FontSize',20); 


hsb(2) = subplot(2,1,2); 
[s,f,t,p] = spectrogram(y,srate,ceil(0.875*srate),2:50,srate,'yaxis','psd');
t = t - 20; 
surf(t, f, 10*log10(p), 'EdgeColor', 'none');
axis tight
shading interp
shading('interp');
view(2);
axis('tight');
xlabel('seconds');
ylabel('Frequency (Hz)');
set(gca,'FontSize',20); 
title('Spectral representation'); 
params.figname = 'rcs plot spectrak plot u24'; 
params.figdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/presentations/figures';
params.figtype = '-djpeg';
fac = 1.8;
params.plotwidth           = 4.70*fac;
params.plotheight          = 3.01*fac;
linkaxes(hsb,'x'); 
xlim([0 60]); 
plot_hfig(hfig,params)
