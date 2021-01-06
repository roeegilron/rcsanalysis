function temp_plot_gamma_entrainment_chronic_stim()
%% pac params
plotPac = 1;
addpath(genpath('/Users/roee/Documents/Code/PAC'));



pacparams.PhaseFreqVector      = 5:2:50;
pacparams.AmpFreqVector        = 10:5:150;

pacparams.PhaseFreq_BandWidth  = 4;
pacparams.AmpFreq_BandWidth    = 10;
pacparams.computeSurrogates    = 0;
pacparams.numsurrogate         = 0;
pacparams.alphause             = 0.05;
pacparams.plotdata             = 0;
pacparams.useparfor            = 0; % if true, user parfor, requires parallel computing toolbox
pacparams.plotdata             = 1;
pacparams.regionnames          = {'stn 0-2','mc 10-11'};
%%
fn = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/RCS12 Un-Synced Data/SummitData/SummitContinuousBilateralStreaming/RCS12L/Session1609082805731/DeviceNPC700477H/post_entrain.mat';fn = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/RCS12 Un-Synced Data/SummitData/SummitContinuousBilateralStreaming/RCS12L/Session1609082805731/DeviceNPC700477H/post_entrain.mat';
% fn = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/RCS12 Un-Synced Data/SummitData/SummitContinuousBilateralStreaming/RCS12L/Session1609082805731/DeviceNPC700477H/post_entrain.mat';fn = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/RCS12 Un-Synced Data/SummitData/SummitContinuousBilateralStreaming/RCS12L/Session1609082805731/DeviceNPC700477H/pre_entrain.mat';
load(fn);
data = [outdatachunk.key1 , outdatachunk.key3];
fs = 500; 
results = computePAC(data',fs,pacparams);
%%
fn = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/RCS02 Un-Synced Data/SummitData/SummitContinuousBilateralStreaming/RCS02R/Session1607536010832/DeviceNPC700404H/pre_entrain.mat';
fn = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/RCS02 Un-Synced Data/SummitData/SummitContinuousBilateralStreaming/RCS02R/Session1607536010832/DeviceNPC700404H/post_entrain.mat';
load(fn);
data = [outdatachunk.key1 , outdatachunk.key3];
fs = 500; 
results = computePAC(data',fs,pacparams);


