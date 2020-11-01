function temp_plot_montage_data_scott()
%%
fullPathToFile = '/Users/roee/Box/Starr_Lab_Folder/Data_Analysis/RCS_data/results/stim_titrations_2/results/montage_results_all_subjects.mat';
load(fullPathToFile); 
%%

%% get data 
%% load data per patient 

idxuse = strcmp(allDataPerPatient.patient,'RCS06') & ... 
        strcmp(allDataPerPatient.side,'L');
datP = allDataPerPatient(idxuse,:);

%% off meds on stim:
datPlot = datP(2,:); 
datPlot % see settings for this run 
rowuse = 2; 
coluse = 2; 
montageDataRaw = datPlot.montageDataRaw{1};
rawdata = montageDataRaw.data{rowuse}(:,coluse);
t = montageDataRaw.derivedTimes{rowuse};
% trim first 5 seconds
if isduration(t)
    t = seconds(t);
end
idxkeep = t>=5 & t<40;
t = t(idxkeep);
rawdata = rawdata(idxkeep);
sr = montageDataRaw.samplingRate(rowuse);

[fftOut{1},ff{1}]   = pwelch(rawdata,sr,sr/2,0:1:sr/2,sr,'psd');

%% on meds on stim:
datPlot = datP(3,:);
datPlot % see settings for this run  (notice it is a few hours later) 
rowuse = 2; 
coluse = 2; 
montageDataRaw = datPlot.montageDataRaw{1};
rawdata = montageDataRaw.data{rowuse}(:,coluse);
t = montageDataRaw.derivedTimes{rowuse};
% trim first 5 seconds
if isduration(t)
    t = seconds(t);
end
idxkeep = t>=5 & t<40;
t = t(idxkeep);
rawdata = rawdata(idxkeep);
sr = montageDataRaw.samplingRate(rowuse);

[fftOut{2},ff{2}]   = pwelch(rawdata,sr,sr/2,0:1:sr/2,sr,'psd');

%% plot 
close all;
hfig = figure;
hfig.Color = 'w';
hsb = subplot(1,1,1);
hold on;
plot(ff{1},log10(fftOut{1}),...
    'LineWidth',3,'Color',[0.8 0 0 0.5]);


plot(ff{2},log10(fftOut{2}),...
    'LineWidth',3,'Color',[0 0.8 0 0.5]);

legend({'off meds on stim','on meds on stim'});
title('off meds on/off stim'); 
ylabel('Power (log_1_0\muV^2/Hz)');
xlabel('Frequency (Hz)');
set(gca,'FontSize',16);


end