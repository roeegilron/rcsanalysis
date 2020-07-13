function MAIN()
%% This is a caller routine to evaluate the user of the parfor on our server 
% the purpose is to test parfor performance with a large number of
% surrogates on our server. 
load('ExtractHGHFOOpenField.mat'); 
% set paramaters: 
params.PhaseFreqVector      = 2:2:50;
params.AmpFreqVector        = 100:5:200;
params.PhaseFreqVector      = 2:10:50;
params.AmpFreqVector        = 100:20:200;

params.PhaseFreq_BandWidth  = 4;
params.AmpFreq_BandWidth    = 10;
params.computeSurrogates    = 1;
params.numsurrogate         = 5;
params.alphause             = 0.05;
params.plotdata             = 1;
params.useparfor            = 0; % if true, user parfor, requires parallel computing toolbox

computePAC(lfpHFO,1000,params);
end