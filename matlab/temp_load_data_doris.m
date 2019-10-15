function temp_load_data_doris()
%% clsoe stuff
clear all
close all 
%% delsts data 
load('/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/v04_10_day/delsys/RCS02_5-15-19_coming_on_meds_test_Plot_and_Store_Rep_1.1.csv.mat'); 
%% load rcs 
dirname = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/v04_10_day/rcs_data/on_meds/RCS02L/Session1557944591887/DeviceNPC700398H';
[outdatcompleteL,outRec,eventTable,outdatcompleteAccL,powerTable] =  MAIN_load_rcs_data_from_folder(dirname);
dirname = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/v04_10_day/rcs_data/on_meds/RCS02R/Session1557944606217/DeviceNPC700404H';
[outdatcompleteR,outRec,eventTable,outdatcompleteAccR,powerTable] =  MAIN_load_rcs_data_from_folder(dirname);

%% plot delsys and rcs 

x = dataraw.DBS_5HZ_L_green2_ACCX2_IM_;
y = dataraw.DBS_5HZ_L_green2_ACCY2_IM_;
z = dataraw.DBS_5HZ_L_green2_ACCZ2_IM_;
secsDelsys = seconds((0:1:length(x )-1 )./dataraw.srates.ACC);
figure;
subplot(3,1,1); 
hold on;
plot(secsDelsys,x-mean(x),'LineWidth',1,'Color',[0.8 0 0 0.3]);
plot(secsDelsys,y-mean(y),'LineWidth',1,'Color',[0 0.8 0 0.3]);
plot(secsDelsys,z-mean(z),'LineWidth',1,'Color',[0 0 0.8 0.3]);
title('delsys'); 
% plot RCS L
x = outdatcompleteAccL.XSamples;
y = outdatcompleteAccL.YSamples;
z = outdatcompleteAccL.ZSamples; 
secsRCSL = outdatcompleteAccL.derivedTimes;
secsRCSL = secsRCSL - secsRCSL(1); 
secsRCSL = seconds(seconds(secsRCSL)); 
subplot(3,1,2); 
hold on;
plot(secsRCSL,x-mean(x),'LineWidth',1,'Color',[0.8 0 0 0.3]);
plot(secsRCSL,y-mean(y),'LineWidth',1,'Color',[0 0.8 0 0.3]);
plot(secsRCSL,z-mean(z),'LineWidth',1,'Color',[0 0 0.8 0.3]);
title('rcsL'); 


% plot RCS R
x = outdatcompleteAccR.XSamples;
y = outdatcompleteAccR.YSamples;
z = outdatcompleteAccR.ZSamples; 
secsRCSR = outdatcompleteAccR.derivedTimes;
secsRCSR = secsRCSR - secsRCSR(1); 
secsRCSR = seconds(seconds(secsRCSR)); 
subplot(3,1,3); 
hold on;
plot(secsRCSR,x-mean(x),'LineWidth',1,'Color',[0.8 0 0 0.3]);
plot(secsRCSR,y-mean(y),'LineWidth',1,'Color',[0 0.8 0 0.3]);
plot(secsRCSR,z-mean(z),'LineWidth',1,'Color',[0 0 0.8 0.3]);
title('rcsR'); 

%% save data chunk
rcsLeft = 67919; 
rcsRight         = 67469;
delsys_dp.DataIndex = 290470;
delIdx = secsDelsys(delsys_dp.DataIndex); 

secsBefore = seconds(10); 
secsAfter  = seconds(130);

% save delsys chunk 
secsFrom = secsDelsys(290470) - secsBefore; 
secsTo   = secsDelsys(290470) + secsAfter; 
idx = secsDelsys >= secsFrom & secsDelsys <= secsTo; 
fn = fieldnames(dataraw); 
idxUse = cellfun(@(x) any(strfind(x,'ACC')),fn); 
idxAcc = find(idxUse==1); 
for i = 1:length(idxAcc)
    delsysChunk.(fn{idxAcc(i)}) = dataraw.(fn{idxAcc(i)})(idx);
end
delsysChunk.srates = dataraw.srates; 
% save RC+S data chunk left acc  
secsFrom = secsRCSL(rcsLeft) - secsBefore; 
secsTo   = secsRCSL(rcsLeft) + secsAfter; 
idx = secsRCSL >= secsFrom & secsRCSL <= secsTo; 
rcsAccLeft = outdatcompleteAccL(idx,:);
% save RC+S data chunk left time domain
secsTD = outdatcompleteL.derivedTimes - outdatcompleteL.derivedTimes(1); 
idx = secsTD >= secsFrom & secsTD <= secsTo; 
rcsDataChunkLeft = outdatcompleteL(idx,:); 

% save RC+S data chunk right acc  
secsFrom = secsRCSR(rcsRight) - secsBefore; 
secsTo   = secsRCSR(rcsRight) + secsAfter; 
idx = secsRCSR >= secsFrom & secsRCSR <= secsTo; 
rcsAccRight = outdatcompleteAccR(idx,:);
% save RC+S data chunk right time domain
secsTD = outdatcompleteR.derivedTimes - outdatcompleteR.derivedTimes(1); 
idx = secsTD >= secsFrom & secsTD <= secsTo; 
rcsDataChunkRight = outdatcompleteR(idx,:); 
%% save results
outdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/v04_10_day/results';
fn     = 'walking_bilateral.mat';
fnsv   = fullfile(outdir,fn); 
save(fnsv,'outdatcompleteAccL','outdatcompleteAccR','outdatcompleteL','outdatcompleteR','outRec','delsysChunk'); 
%% plot data 
clear all; 
close all; 



