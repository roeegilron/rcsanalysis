function temp_plot_rcs02_effect_increasing_averaging()
%%


%% load data 
foldername = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/RCS02 Un-Synced Data/SummitData/SummitContinuousBilateralStreaming/RCS02R/Session1607536010832/DeviceNPC700404H/';
%%
[outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerOut,adaptiveTable] =  MAIN_load_rcs_data_from_folder(foldername);
%% load data with demo process 
clear all;
addpath(genpath('/Users/roee/Documents/Code/Analysis-rcs-data/code'));


[combinedDataTable, debugTable, timeDomainSettings,powerSettings,...
    fftSettings,metaData,stimSettingsOut,stimMetaData,stimLogSettings,...
    DetectorSettings,AdaptiveStimSettings,AdaptiveRuns_StimSettings] = DEMO_ProcessRCS(foldername);
ts = datetime(combinedDataTable.DerivedTime/1000,...
'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
%% plit 
close all;
hfig = figure;
hfig.Color = 'w'; 
idxuse = ~isnan(combinedDataTable.Power_Band7);
tsUse = ts(idxuse);
pwerBand = combinedDataTable.Power_Band7(idxuse); 
addpath(genpath(fullfile(pwd,'toolboxes','panel-2.14')));
hpanel = panel();
hpanel.pack('v',{0.1 0.9});
hpanel(2).pack(3,2);
% limits use: 
limseUse = datetime({'09-Dec-2020 10:00:23.797'   ,'09-Dec-2020 15:30:08.411'});
limseUse.TimeZone = tsUse.TimeZone; 

cnt = 1; 
hsb(cnt) = hpanel(2,1,1).select(); cnt = cnt + 1; 
axes(hsb(cnt-1)); 
plot(tsUse,pwerBand); 
xlim(limseUse);
ylim([0 1e4]);
title('raw signal = 0.5 second interval'); 

% 30 sec different average 
hsb(cnt) = hpanel(2,2,1).select(); cnt = cnt + 1; 
axes(hsb(cnt-1)); 
pwerBandMov = movmean(pwerBand,[60 1]);
plot(tsUse,pwerBandMov); 
xlim(limseUse);
title('30 sec moving average'); 

% 10 min average 
hsb(cnt) = hpanel(2,3,1).select(); cnt = cnt + 1; 
axes(hsb(cnt-1)); 
pwerBandMov = movmean(pwerBand,[1200 1]);
plot(tsUse,pwerBandMov); 
xlim(limseUse);
title('20 min moving average'); 


% non moving average 
hsb(cnt) = hpanel(2,1,2).select(); cnt = cnt + 1; 
axes(hsb(cnt-1)); 
plot(tsUse,pwerBand); 
xlim(limseUse);
ylim([0 1e4]);
title('raw signal = 0.5 second interval'); 

% compute non moving averages 
reshapeUse = 60;
modIdx = mod(length(pwerBand),reshapeUse);
powerToReshape = pwerBand(1:end-modIdx);
tsReshaped = tsUse(1:end-modIdx);
% reshape the power 
powerReshape = reshape(powerToReshape,[reshapeUse, length(powerToReshape)/reshapeUse]);
% computer the average 
for s = 1:size(powerReshape,2)
    avgVal = mean(powerReshape(:,s));
    powerReshape(:,s) = repmat(avgVal,[1 reshapeUse])';
end
powerAvgd = reshape(powerReshape,[1 length(powerToReshape)])';
hsb(cnt) = hpanel(2,2,2).select(); cnt = cnt + 1; 
axes(hsb(cnt-1)); 
plot(tsReshaped,powerAvgd); 
xlim(limseUse);
title('30 sec non moving average'); 


% compute non moving averages 2 
reshapeUse = 1200;
modIdx = mod(length(pwerBand),reshapeUse);
powerToReshape = pwerBand(1:end-modIdx);
tsReshaped = tsUse(1:end-modIdx);
% reshape the power 
powerReshape = reshape(powerToReshape,[reshapeUse, length(powerToReshape)/reshapeUse]);
% computer the average 
for s = 1:size(powerReshape,2)
    avgVal = mean(powerReshape(:,s));
    powerReshape(:,s) = repmat(avgVal,[1 reshapeUse])';
end
powerAvgd = reshape(powerReshape,[1 length(powerToReshape)])';
hsb(cnt) = hpanel(2,3,2).select(); cnt = cnt + 1; 
axes(hsb(cnt-1)); 
plot(tsReshaped,powerAvgd); 
xlim(limseUse);
title('20 min non moving average'); 
sgtitle('moving vs non moving averages','FontSize',24);

%%
hpanel.fontsize = 10;
figdir = '/Users/roee/Box/RC-S_Studies_Regulatory_and_Data/Patient In-Clinic Data/figures/moving_average_adbs';
prfig.plotwidth           = 10;
prfig.plotheight          = 9;
prfig.figdir              = figdir;
prfig.figtype             = '-djpeg';
prfig.closeafterprint     = 0;
prfig.resolution          = 300;
prfig.figname             = 'moving_average_rcs02';
plot_hfig(hfig,prfig);


%% PAC 


end