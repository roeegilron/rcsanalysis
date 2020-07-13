%% Evaluation code for PAC
%  Main changes:
%  1. use logical indexing
%  2. transpose some vectors so that largest dimension first (allows faster
%  comptuation
%  3. use index counting + reshape to make parfor more efficient
%%
%% set params (Define the Amplitude- and Phase- Frequencies)
PhaseFreqVector      = 2:2:50;
AmpFreqVector        = 100:5:200;
PhaseFreq_BandWidth  = 4;
AmpFreq_BandWidth    = 10;
useparfor            = 0; % if true, user parfor, requires parallel computing toolbox

%% Load data
load ExtractHGHFOOpenField.mat
lfp         = lfpHFO;
data_length = length(lfp);
srate       = 1000;
dt          = 1/srate;
t           = (1:data_length)*dt;

%% Do filtering and Hilbert transform on CPU
Comodulogram=single(zeros(length(PhaseFreqVector),length(AmpFreqVector)));
AmpFreqTransformed = zeros(length(AmpFreqVector), data_length);
PhaseFreqTransformed = zeros(length(PhaseFreqVector), data_length);

for ii=1:length(AmpFreqVector)
    Af1 = AmpFreqVector(ii);
    Af2 = Af1+AmpFreq_BandWidth;
    AmpFreq=eegfilt(lfp,srate,Af1,Af2); % just filtering
    AmpFreqTransformed(ii, :) = abs(hilbert(AmpFreq)); % getting the amplitude envelope
end

for jj=1:length(PhaseFreqVector)
    Pf1 = PhaseFreqVector(jj);
    Pf2 = Pf1 + PhaseFreq_BandWidth;
    PhaseFreq=eegfilt(lfp,srate,Pf1,Pf2); % this is just filtering
    PhaseFreqTransformed(jj, :) = angle(hilbert(PhaseFreq)); % this is getting the phase time series
end

%% Do comodulation calculation
start   = tic;
% precalcluate vars for comodulation calculation that only need to be calculated once
nbin     = 18;
position = zeros(1,nbin); % this variable will get the beginning (not the center) of each phase bin (in rads)
winsize  = 2*pi/nbin;
for j = 1:nbin
    position(j) = -pi+(j-1)*winsize;
end
winsize = 2*pi/nbin;
lognbin = log(nbin);
% using this indexing scheme allows for more efficient parfor 
pairuse = [];cnt = 1;
for jj=1:length(AmpFreqVector)
    for ii=1:length(PhaseFreqVector)
        puse1(cnt) = ii;
        puse2(cnt) = jj;
        cnt = cnt + 1;
    end
end

% create linearlized Comodulogram
Comodulogram = zeros(size(pairuse,1),1,'single');
if useparfor
    parfor p = 1:size(puse1,2)
        Comodulogram(p) = ModIndex_v3(PhaseFreqTransformed(puse1(p), :), AmpFreqTransformed(puse2(p), :)', position,nbin,winsize,lognbin);
    end
else
    for p = 1:size(puse1,2)
        Comodulogram(p) = ModIndex_v3(PhaseFreqTransformed(puse1(p), :), AmpFreqTransformed(puse2(p), :)', position,nbin,winsize,lognbin);
    end
end
Coreshaped = reshape(Comodulogram,length(PhaseFreqVector),length(AmpFreqVector));


fprintf('comod calc done in %f secs \n',toc(start));

%% plotting 
figure;
contourf(PhaseFreqVector+PhaseFreq_BandWidth/2,AmpFreqVector+AmpFreq_BandWidth/2,Coreshaped',30,'lines','none')
set(gca,'fontsize',14)
ylabel('Amplitude Frequency (Hz)')
xlabel('Phase Frequency (Hz)')
title('version 1');
colorbar
