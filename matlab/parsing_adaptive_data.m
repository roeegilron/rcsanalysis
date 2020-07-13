

close all; clear all; clc

%% load data
ff = '/Users/juananso/Dropbox (Personal)/Work/DATA/adaptive/fastaDBS_patientTesting/RCS08R/Session1589320314167/DeviceNPC700421H';
% [outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerTable] = MAIN_load_rcs_data_from_folder(dirname);
fnAdaptive = fullfile(dirname,'AdaptiveLog.json'); 
fnDeviceSettings = fullfile(dirname,'DeviceSettings.mat');
res = readAdaptiveJson(fnAdaptive); 
res.timing
res.adaptive

%%
adaptiveLog = load(strcat(ff,'/adaptiveLog.mat'));
adaptiveTable = adaptiveLog.adaptiveTable;
head(adaptiveTable)



