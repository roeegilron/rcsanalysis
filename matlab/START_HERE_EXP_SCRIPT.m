function START_HERE_EXP_SCRIPT()
%% This scripts is meant to explain how to plot and under stand the strucutre of RC+S data 


%% view raw RC+S 
% This is the "gateway code" I use in ordre to view RC+S data. 
% When data comes out of the RC+S this is what it looks like: 

%% RC+S raw data example 

% For my scripts it is important to keep everythign in the structure in which RC+S data comes off device. 
% Though it is not useful as is, the session number contains time. 
% All scripts below rely on this structure. I have not changed this yet
% and the main reason is that a lot of the files are very large and have to
% be "chopped down" as you will see below. 

% First, I will take you through the process of viewing and looking at data
% using GUI's and then will go through individual functions. 

% To look at the data please run RC+S session viewer 
rcsSessionViewer()


%% rcs session viewer example 

% The directoy you are loading is the parent directory to all of the
% 'session folders'. 
% clicking on a link will open another function 
rcsDataChopper()
% this funciton gets the full path to a directory to visualize the data 
% it can save a "chunk of the data" 
% zoom in, show PSD and spectrograms. 
% here is how to run this funciton in standalong mode: 
% note also that it has to be formatted of strufture 
% this is to allow this function to "grow" with additional parameters 
dirname = fullfile('..','data','sample_data','data_folder','RCS04L','Session1562087867615','DeviceNPC700418H');
params.dir = dirname; 
rcsDataChopper(params); 

% try to save to "chunks" of the data with different names and save this
% under results 

%% Digging deaper into file types 
% below I will list file types and their assocaited readers so that you can
% look at the raw data. 
[outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerTable] = ...
    MAIN_load_rcs_data_from_folder(dirname);

% each of the files above corresponds to one type of .json file that you
% get in the raw output. 
% most of these files are in table() format. 

% you can dig into the readers of each files by looking at above function 
% for now let's just see how to plot this .

% this will show you what table looks like. 
head(outdatcomplete)
% the channels come out as "key0", "key1". etc. 
% lets plot one time domain channel and also find out 
% where the meta data describign what it is. 
y = outdatcomplete.key0; % actual data 
x = outdatcomplete.derivedTimes; % times 
% this structure (below describes meta data associated with what channel we
% recorded from). 
% explore the structure to get a better idea of the type of data you can
% get 
titleUse = outRec(1).tdData(1).chanFullStr; 
figure; 
hp = plot(x,y); 
hp.LineWidth = 2; 
hp.Color = [0 0 0.8 0.5];
title(titleUse);
set(gca,'FontSize',16); 
% you can use the 'diff()' function to find large gaps in the data 
% you can also see a package loss report here: 
% RawDataAccel-Packet-Loss-Report.txt
% in the main diretory that you are using 

% events (e.g. when stuff happened) shows up in eventTabel
head(eventTable); 

% acc data shows up here:
head(outdatcompleteAcc) 
% try plotting this. 
% note that each channel (x,y,z) need to be rectified. 

% power data is a more advances use case for aDBS and will be covered in
% other trainings. 
head(powerTable); 
% to explore the structure, but not that this particular example file
% doesn't have power data so it will be empty. 
% upon request can give some power data to explore 

%% Other functions to know of / about 
% this will rapidly plot all the data in a direcotry
dirname = fullfile('..','data','sample_data','data_folder','RCS04L','Session1562088293641','DeviceNPC700418H');
plot_raw_rcs_data(dirname);

%% plot motnage data 
% this is where I put the montage data 
dirnameMontage = fullfile('..','data','sample_data','montage_sweep','Session1563323122046','DeviceNPC700414H');
% this function doesn't take arguments - and just plots the data 
plot_montage_data(); 

%% write stim sweep 
% This allows you to write a stim sweep file. 
stimSweepSampleFile = fullfile('..','data','sample_config_files','stim_sweep','stimsweep.csv'); 
write_stim_sweep(stimSweepSampleFile)

%% plot stim sweep data 
% this plots stim sweep data created using a stim sweep file 
[pnn,fn] = fileparts(pwd);
datadir = fullfile(pnn,'data','sample_data','stim_sweep','DeviceNPC700415H');
figdir = fullfile(pnn,'data','figures'); 
plot_stim_sweep_manual(datadir,figdir)

%% here is how we allign delsys data with RC+S data 
[pn,fn] = fileparts(pwd);
rcsFolder = fullfile(pn,'data','rcs_data','Session1541438482992','DeviceNPC700398H');
rcsFolder = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/data_viz_training/data/rcs_data/Session1541438482992/DeviceNPC700395H';
delsysFn = fullfile(pn,'data','delsys','RCS01_recording_8_Plot_and_Store_Rep_2.1.csv.mat');
allignRCS_Delsys_Data(rcsFolder,delsysFn)

%% here is a function to overlay PSD
plot_psd

end