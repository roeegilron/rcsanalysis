function plot_actigraphy_dyskinsia_check()
%% load data 
fn1 = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/v03_postop_day_2/RCS02L/Session1557435294506/DeviceNPC700398H/';
fn2 = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/v03_postop_day_2/RCS02R/Session1557435300217/DeviceNPC700404H'; 
%% plot raw data 
hfig = figure; 
hsub(1) = subplot(2,1,1); % LEFT 
hsub(2) = subplot(2,1,2); % RIGHT 
hold(hsub(1),'on');
hold(hsub(2),'on');
% load L 
[outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerTable] =  MAIN_load_rcs_data_from_folder(fn1); 
x = outdatcompleteAcc.XSamples; 
y = outdatcompleteAcc.YSamples; 
z = outdatcompleteAcc.ZSamples; 
secs = outdatcompleteAcc.derivedTimes; 
plot(hsub(1),secs,x-mean(x));
plot(hsub(1),secs,y-mean(y));
plot(hsub(1),secs,z-mean(z));
title(hsub(1),'Left actigraphy'); 

% load R 
[outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerTable] =  MAIN_load_rcs_data_from_folder(fn1); 
x = outdatcompleteAcc.XSamples; 
y = outdatcompleteAcc.YSamples; 
z = outdatcompleteAcc.ZSamples; 
secs = outdatcompleteAcc.derivedTimes; 
plot(hsub(2),secs,x-mean(x));
plot(hsub(2),secs,y-mean(y));
plot(hsub(2),secs,z-mean(z));
title(hsub(2),'Right actigraphy'); 
linkaxes(hsub,'x'); 
%% plot squared data 

hfig = figure; 
hsub(1) = subplot(2,1,1); % LEFT 
hsub(2) = subplot(2,1,2); % RIGHT 
hold(hsub(1),'on');
hold(hsub(2),'on');
% load L 
[outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerTable] =  MAIN_load_rcs_data_from_folder(fn1); 
x = outdatcompleteAcc.XSamples; 
y = outdatcompleteAcc.YSamples; 
z = outdatcompleteAcc.ZSamples; 
datplot = (x-mean(x)).^2 + (y-mean(y)).^2 + (z-mean(z)).^2;
datplot = movmean(datplot,[0 64*5]);
secs = outdatcompleteAcc.derivedTimes; 
plot(hsub(1),secs,datplot);
title(hsub(1),'Left actigraphy'); 

% load R 
[outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerTable] =  MAIN_load_rcs_data_from_folder(fn1); 
x = outdatcompleteAcc.XSamples; 
y = outdatcompleteAcc.YSamples; 
z = outdatcompleteAcc.ZSamples; 
secs = outdatcompleteAcc.derivedTimes; 
datplot = (x-mean(x)).^2 + (y-mean(y)).^2 + (z-mean(z)).^2;
datplot = movmean(datplot,[0 64*60]);
secs = outdatcompleteAcc.derivedTimes; 
plot(hsub(2),secs,datplot);
title(hsub(2),'Right actigraphy'); 
linkaxes(hsub,'x'); 
end