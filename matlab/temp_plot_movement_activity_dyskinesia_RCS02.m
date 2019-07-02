function temp_plot_movement_activity_dyskinesia_RCS02()
%% load data 
diruse = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/v03_postop_day_2/RCS02L/Session1557435294506/DeviceNPC700398H';
[outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerTable] = ...
    MAIN_load_rcs_data_from_folder(diruse); 
timeStart = '09-May-2019 14:05:03.001'; 
timeEnd   = '09-May-2019 14:24:59.998'; 

%% plot time domain data 
hfig = figure; 
allTimes = outdatcomplete.derivedTimes; 
idxuseTimeDomain  = allTimes > timeStart & allTimes < timeEnd;

outdatcomplete = outdatcomplete(idxuseTimeDomain,:); 
tuse = outdatcomplete.derivedTimes;
srate = unique( outdatcomplete.samplerate );

t = tuse - tuse(1); 
windowsize = 1024;
% plot stn 
hsub(1) = subplot(3,1,1); 

y = outdatcomplete.key1; 
y = y-mean(y); 
SNR = -90;

[s,f,t,p] = spectrogram(y,2000,850,128*5,srate,'MinThreshold',SNR ,'yaxis');
spectrogram(y,2000,850,128*5,srate,'MinThreshold',SNR ,'yaxis');

axis tight
shading interp
ylim([1 100]);
% colorbar off; 
title('STN'); 
xlabel('');
set(gca,'FontSize',16);
% plot m1
hsub(2) = subplot(3,1,2); 

y = outdatcomplete.key3; 
y = y-mean(y); 
[s,f,t,p] = spectrogram(y,2000,850,128*5,srate,'MinThreshold',SNR ,'yaxis');
spectrogram(y,2000,850,128*5,srate,'MinThreshold',SNR ,'yaxis');
axis tight
shading interp
ylim([1 100]);
% colorbar off; 
title('M1'); 
xlabel('');
set(gca,'FontSize',16);
%plot acclelaton 
allTimes = outdatcompleteAcc.derivedTimes; 
idxuseTimeDomain  = allTimes > timeStart & allTimes < timeEnd;

outdatcompleteAcc = outdatcompleteAcc(idxuseTimeDomain,:); 
tuse = outdatcompleteAcc.derivedTimes;
srate = unique( outdatcompleteAcc.samplerate );
tuse = outdatcompleteAcc.derivedTimes; 
tuse = tuse - tuse(1); 
tuse = minutes(tuse); 
hsub(3) = subplot(3,1,3); 
x = outdatcompleteAcc.XSamples; 
y = outdatcompleteAcc.YSamples; 
z = outdatcompleteAcc.ZSamples; 

x = x - mean(x);
y = y - mean(y);
z = z - mean(z);

avgMov = mean([abs(x) abs(y) abs(z)],2)'; 
avgMoveSmoothed = movmean(avgMov,[32*2 0]); 
baseline = tuse < 5; 
baselineVal = mean(avgMoveSmoothed(baseline)); 
avgMovePercent = (avgMoveSmoothed./baselineVal); 

hold on;
% plot(tuse,x);
% plot(tuse,y);
% plot(tuse,z);

hp = plot(tuse, avgMovePercent); 
hp.LineWidth = 3; 
hp.Color = [0 0 0.8 0.8];
title('Internal accelrometer'); 

linkaxes(hsub,'x'); 
xlim([0 19]);
ylabel('Movement level (factor over baseline)') ;
xlabel('Time (minutes)'); 
set(gca,'FontSize',16);

set(hsub(1),'XTickLabel','')
set(hsub(2),'XTickLabel','')

%%
params.plotwidth           = (354/10)/2.24;
params.plotheight          = (277/10)/2.24;
params.figdir              = '/Users/roee/Starr_Lab_Folder/Presenting/Posters/Gilron_WSSFN_2019/figures';
params.figname             = 'brittle_fluctuational_dyskinesia'; 
params.figtype             = '-djpeg';
params.closeafterprint     = 1;
params.resolution          = 600;
plot_hfig(hfig,params);
end