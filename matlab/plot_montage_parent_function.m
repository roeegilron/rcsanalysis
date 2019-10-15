function plot_montage_parent_function()


%% RCS 07 

% left side

% off meds
data{1,1} = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS07/v15_athome_off_on_montage/off_meds/RCS07L/Session1569436511438/DeviceNPC700419H/rawMontageData.mat';
% on meds
data{2,1} = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS07/v15_athome_off_on_montage/on_meds_without_dykinesia/RCS07L/Session1569347506366/DeviceNPC700419H/rawMontageData.mat';

% right side

% off meds
data{1,2} = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS07/v15_athome_off_on_montage/off_meds/RCS07R/Session1569436056338/DeviceNPC700403H/rawMontageData.mat';
% on meds
data{2,2} = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS07/v15_athome_off_on_montage/on_meds_without_dykinesia/RCS07R/Session1569346542818/DeviceNPC700403H/rawMontageData.mat';

figdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS07/v15_athome_off_on_montage/figures';
plot_montage_on_off_meds_saved_data(data,figdir);



%% RCS 05

% left side

% off meds
data{1,1} = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS05/v05_3week/rcs_data/StarrLab/RCS05L/Session1565801585915/DeviceNPC700414H/rawMontageData.mat';
% on meds
data{2,1} = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS05/v05_3week/rcs_data/StarrLab/RCS05L/Session1565810644386/DeviceNPC700414H/rawMontageData.mat';

% right side

% off meds
data{1,2} = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS05/v05_3week/rcs_data/StarrLab/RCS05R/Session1565801178469/DeviceNPC700415H/rawMontageData.mat';
% on meds
data{2,2} = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS05/v05_3week/rcs_data/StarrLab/RCS05R/Session1565810961752/DeviceNPC700415H/rawMontageData.mat';

figdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS05/v05_3week/figures';
plot_montage_on_off_meds_saved_data(data,figdir);



%% RCS 06

% left side

% off meds
data{1,1} = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS06/v00_OR_day/RCSdata/StarrLab/RCS06L/Session1569971901227/DeviceNPC700424H/rawMontageData.mat';
% on meds
data{2,1} = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS06/v00_OR_day/RCSdata/StarrLab/RCS06L/Session1569979258863/DeviceNPC700424H/rawMontageData.mat';

% right side

% off meds
data{1,2} = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS06/v00_OR_day/RCSdata/StarrLab/RCS06R/Session1569973527727/DeviceNPC700425H/rawMontageData.mat';
% on meds
data{2,2} = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS06/v00_OR_day/RCSdata/StarrLab/RCS06R/Session1569979644476/DeviceNPC700425H/rawMontageData.mat';

figdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS06/v00_OR_day/figures';



%% RCS 06 10 day visit 
addpath(genpath(fullfile('..','..','PAC')));
% left side

% off meds
data{1,1} = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS06/v10_day/rcs_data/RCS_data/SCBS/RCS06L/Session1570548340725/DeviceNPC700424H/rawMontageData.mat';
% on meds
data{2,1} = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS06/v10_day/rcs_data/RCS_data/SCBS/RCS06L/Session1570562094151/DeviceNPC700424H/rawMontageData.mat';

% right side

% off meds
data{1,2} = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS06/v10_day/rcs_data/RCS_data/SCBS/RCS06R/Session1570548248261/DeviceNPC700425H/rawMontageData.mat';
% on meds
data{2,2} = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS06/v10_day/rcs_data/RCS_data/SCBS/RCS06R/Session1570561801299/DeviceNPC700425H/rawMontageData.mat';

figdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS06/v10_day/figures';

%%



%%  plot

plot_montage_on_off_meds_saved_data(data,figdir);