% Programmed by Adriano Tort, CBD, BU, 2008
% Modified by Roee Gilron 2017 roeegilron@gmail.com 
% Main changs are logicla indexing + pre computing some variables 

% Phase-amplitude cross-frequency coupling measure:
%
% [MI,MeanAmp]=ModIndex_v2(Phase, Amp, position)
%
% Inputs:
% Phase = phase time series
% Amp = amplitude time series
% position = phase bins (left boundary)
%
% Outputs:
% MI = modulation index (see Tort et al PNAS 2008, 2009 and J Neurophysiol 2010)
% MeanAmp = amplitude distribution over phase bins (non-normalized)
 
function  MI =ModIndex_v3(Phase, Amp, position, nbin,winsize ,lognbin)

 
% now we compute the mean amplitude in each phase:

MeanAmp=zeros(1,nbin); 
for j=1:nbin
    MeanAmp(j) = mean(Amp( Phase <  position(j)+winsize & Phase >=  position(j) ),1);
end

% so note that the center of each bin (for plotting purposes) is
% position+winsize/2
 
% at this point you might want to plot the result to see if there's any
% amplitude modulation
 
% bar(10:20:720,[MeanAmp,MeanAmp])
% xlim([0 720])

% and next you quantify the amount of amp modulation by means of a
% normalized entropy index:

%% note Roee Gilron: 
% done to only compute this once, when run many many times no need to
% compute twice 
madivsum = MeanAmp/sum(MeanAmp); 
%% 
MI = (lognbin - (-sum ( (    madivsum ).*log((  madivsum )) )  ))/lognbin;

end
