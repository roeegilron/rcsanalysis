function results = computePAC(data,sr,varargin)
%% Compute Phase Amplitude coupling
%  Written by Roee Gilron roeegilron@gmail.com
%  Code based on Adriano Tort code described in this paper:
%  https://www.ncbi.nlm.nih.gov/pmc/articles/PMC2941206/
%
%  Inputs:
%
%  Required:
%
%  data - 1. matrix of size 1 x time points if computing PAC within one area
%         2. matrix of size 2 x time points if computing PAC between two
%         regions
%  sr   - sampling rate of data
%
%  optional arguments ('name', value) format:
%
%  1. PhaseFreqVector - matrix of phase frequencies.
%     example: computePAC(data,sr,'PhaseFreqVector',2:4:50)
%     default: 2:2:50
%  2. AmpFreqVector - matrix of amp frequencies.
%     example: computePAC(data,sr,'PhaseFreqVector',2:2:50,'AmpFreqVector',2:2:100)
%     default: 5:2:100
%  3. PhaseFreq_BandWidth - bandwith in which to compuate phase freq
%     example: computePAC(data,sr,'PhaseFreqVector',2:2:50,'PhaseFreq_BandWidth',4)
%     default: 4
%  4. AmpFreq_BandWidth - bandwith in which to compuate amp freq
%     example: computePAC(data,sr,'PhaseFreqVector',2:2:50,'AmpFreq_BandWidth',8)
%     default: 10
%  5. useparfor - use parfor to compute PAC (faster, but requires parallel
%     computing toolbox
%     example: computePAC(data,sr,'useparfor',1,'AmpFreq_BandWidth',8)
%     default: 0
%  6. computeSurrogates - compute surrogates for statistical purposes
%     example: computePAC(data,sr,'useparfor',0,'computeSurrogates',1)
%     default: 0
%  7. numsurrogate - number of surrogates (non-parametric shuffels) to compute for statistical purposes
%     example: computePAC(data,sr,'computeSurrogates',1,'numsurrogate',100)
%     default: 100
%  7. alphause - alpha use for for statistical purposes
%     default: 0.05
%  8. filteruse - charachter, type of filter to use for bp filtering 
%     example: computePAC(data,sr,'PhaseFreqVector',2:2:50,'filteruse','gaussian')
%     default: 'fir1' options: 'filterls','fir1', 'gaussian';
%  9. regionnames - charachter, regions names to be computed (only relevant if computing
%     between two regions
%     example: computePAC(data,sr,'PhaseFreqVector',2:2:50,'regionnames',{'GPi','Motor Cortex'})
%     default: {'a1','a2'};
% 10. plotdata - if true (1 -default) plot data, if false, don't plot
%     example: computePAC(data,sr,'PhaseFreqVector',2:2:50,'plotdata',0)
%     default: 1 (plot data)
%

%  Also accpets structure format, example:
%  params.PhaseFreqVector = 2:2:50;
%  params.AmpFreqVector   = 5:1:100;
%  params.useparfor   = 1;
%  computePAC(data,sr,params);
%
%  Outputs:
%  structure -  results which contain input fields as well as:
%  1. Comodulogram
%
%
%  plot of PAC in either 1 / 4 subplots:
%  if data is 1 x time points - compute PAC within
%
%  if data is 2 x time points, compute 4 subplots:
%  1 plot PAC within area 1
%  2 plot PAC within area 2
%  3 plot PAC between area 1 (phase) and area 2 (amp)
%  4 plot PAC between area 1 (amp) and area 2 (phase)


%% Define function inputs, data, sr requires default values
% Parse input arguments
p = inputParser;
p.CaseSensitive = false;

validationFcn = @(x) validateattributes(x,{'double'},{'nonempty'});

addParameter(p,'PhaseFreqVector',2:2:50,validationFcn)
addParameter(p,'AmpFreqVector',5:2:100,validationFcn)
addParameter(p,'PhaseFreq_BandWidth',4,validationFcn)
addParameter(p,'AmpFreq_BandWidth',10,validationFcn)
addParameter(p,'useparfor',0,validationFcn)
addParameter(p,'computeSurrogates',0,validationFcn)
addParameter(p,'numsurrogate',100,validationFcn)
addParameter(p,'alphause',0.05,validationFcn)
addParameter(p,'plotdata',1,validationFcn)

validationFcn = @(x) validateattributes(x,{'cell'},{'nonempty'});
addParameter(p,'regionnames',{'a1','a2'},validationFcn)
validationFcn = @(x) validateattributes(x,{'char'},{'nonempty'});
addParameter(p,'filteruse','fir1',validationFcn)

p.parse(varargin{:});

%Extract values from the inputParser
PhaseFreqVector      = p.Results.PhaseFreqVector;
AmpFreqVector        = p.Results.AmpFreqVector;
PhaseFreq_BandWidth  = p.Results.PhaseFreq_BandWidth;
AmpFreq_BandWidth    = p.Results.AmpFreq_BandWidth;
useparfor            = p.Results.useparfor; % if true, user parfor, requires parallel computing toolbox
regionames           = p.Results.regionnames;
computesurr          = p.Results.computeSurrogates;
numsurrogate         = p.Results.numsurrogate;
alphause             = p.Results.alphause;
plotdata             = p.Results.plotdata;
filteruse            = p.Results.filteruse;

%% Load data
lfp           = data;
data_length   = length(lfp);
data_size     = size(data,1);
srate         = sr;
dt            = 1/srate;
t             = (1:data_length)*dt;

if plotdata
    hfig          = figure('Visible','off');
    %     hfig.Position = [1000         666        1132         672];
end

if useparfor 
    if isunix & ~ismac
        % requires parpool toolbox 
        pool = parpool('roee',20); % this is specific to our servers; 
    end
end

if data_size == 1
    numplots = 1;
else
    numplots = 4;
end
for aa = 1:numplots
    if numplots == 1
        datAmp = lfp;
        datPha = lfp;
        ttlAmp = '';
        ttlPha = '';
    elseif numplots == 4
        switch aa
            case 1
                datAmp = lfp(1,:);
                datPha = lfp(1,:);
                ttlAmp = sprintf('%s',regionames{1});
                ttlPha = sprintf('%s',regionames{1});
            case 2
                datAmp = lfp(2,:);
                datPha = lfp(2,:);
                ttlAmp = sprintf('%s',regionames{2});
                ttlPha = sprintf('%s',regionames{2});
            case 3
                datAmp = lfp(1,:);
                datPha = lfp(2,:);
                ttlAmp = sprintf('%s',regionames{1});
                ttlPha = sprintf('%s',regionames{2});
            case 4
                datAmp = lfp(2,:);
                datPha = lfp(1,:);
                ttlAmp = sprintf('%s',regionames{2});
                ttlPha = sprintf('%s',regionames{1});
        end
    end
    
    %% Do filtering and Hilbert transform on CPU
    Comodulogram=single(zeros(length(PhaseFreqVector),length(AmpFreqVector)));
    AmpFreqTransformed = zeros(length(AmpFreqVector), data_length);
    PhaseFreqTransformed = zeros(length(PhaseFreqVector), data_length);
    
    for ii=1:length(AmpFreqVector)
        Af1 = AmpFreqVector(ii);
        Af2 = Af1+AmpFreq_BandWidth;
        AmpFreq = bp_filter(datAmp,srate,Af1,Af2,filteruse); % just filtering
        AmpFreqTransformed(ii, :) = abs(hilbert(AmpFreq)); % getting the amplitude envelope
    end
    
    for jj=1:length(PhaseFreqVector)
        Pf1 = PhaseFreqVector(jj);
        Pf2 = Pf1 + PhaseFreq_BandWidth;
        PhaseFreq = bp_filter(datPha,srate,Pf1,Pf2,filteruse); % this is just filtering
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
    pairuse = [];
    cnt = 1;
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
            Comodulogram(1,p) = ModIndex_v3(PhaseFreqTransformed(puse1(p), :), AmpFreqTransformed(puse2(p), :)', position,nbin,winsize,lognbin);
        end
    else
        for p = 1:size(puse1,2)
            Comodulogram(1,p) = ModIndex_v3(PhaseFreqTransformed(puse1(p), :), AmpFreqTransformed(puse2(p), :)', position,nbin,winsize,lognbin);
        end
    end
    
    Com_reshaped = reshape(Comodulogram,length(PhaseFreqVector),length(AmpFreqVector));
    
    %% initialize variables for surrogate
    if computesurr
        % choose # of points at least sr from start and end of recording 
        rng(1); % to get same answer each time - be careful! 
        skip = randperm(size(AmpFreqTransformed,2)-sr*2,numsurrogate)+sr; 
        % get skip idxs (to avoid doing this for each shuffle 
        for s = 1:numsurrogate
            idxsurr(s,:) = [skip(s):size(AmpFreqTransformed,2) 1:skip(s)-1];
        end
        % run surrogates (statistics) if desired
        for s=1:numsurrogate
            if useparfor 
                parfor p = 1:size(puse1,2)
                    Comodulogram_surr(s,p) = ModIndex_v3(PhaseFreqTransformed(puse1(p),:),  AmpFreqTransformed(puse2(p), idxsurr(s,:))', position,nbin,winsize,lognbin);
                end
            else
                for p = 1:size(puse1,2)
                    Comodulogram_surr(s,p) = ModIndex_v3(PhaseFreqTransformed(puse1(p),:),  AmpFreqTransformed(puse2(p), idxsurr(s,:))', position,nbin,winsize,lognbin);
                end
            end
        end
        % compute z score 
        MI_surr = Comodulogram_surr;
        [surrogate_mean,surrogate_std] = normfit(MI_surr); % fit gaussian to surrogate data, uses normfit.m from MATLAB Statistics toolbox
        zComodulogram = (abs(Comodulogram) - surrogate_mean )./ surrogate_std;
        
        % compute p values 
        compMatrix = repmat(Comodulogram,numsurrogate,1);
        pvals = 1 - sum(abs(compMatrix) >= abs(MI_surr),1)./numsurrogate; % two sided p-value
        % set any Pval that is zero the effective max pval
        pvals(pvals==0) = 1/numsurrogate;
        [pvalssig,critp] = fdr_bh(pvals,alphause);
        % give value of zero to pvalues that are not significant 
        Comodulogram_surr = Comodulogram;
        Comodulogram_surr(~pvalssig) = 0;

     
        % reshape outputs 
        pvals_reshape= reshape(pvals,length(PhaseFreqVector),length(AmpFreqVector));
        Com_surr_reshaped= reshape(Comodulogram_surr,length(PhaseFreqVector),length(AmpFreqVector));
        zCom_reshaped = reshape(zComodulogram,length(PhaseFreqVector),length(AmpFreqVector));
    else
        Com_surr_reshaped = [];
        zCom_reshaped = [];
        pvals_reshape = []; 
        MI_surr = []; 
    end
    %%
    fprintf('comod calc done in %f secs \n',toc(start));
    % save data:
    results(aa).zComodulogram       = zCom_reshaped; % this will by empty if you didn't run surrogates 
    results(aa).Comodulogram_surr   = Com_surr_reshaped;% this will by empty if you didn't run surrogates 
    results(aa).pvals               = pvals_reshape;% this will by empty if you didn't run surrogates 
    results(aa).MI_surr             = MI_surr;% this will by empty if you didn't run surrogates 
    results(aa).Comodulogram        = Com_reshaped;
    results(aa).PhaseArea           = ttlPha;
    results(aa).ttlAmp              = ttlAmp;
    results(aa).AmpFreqVector       = AmpFreqVector;
    results(aa).PhaseFreqVector     = PhaseFreqVector;
    results(aa).PhaseFreq_BandWidth = PhaseFreq_BandWidth;
    results(aa).AmpFreq_BandWidth   = AmpFreq_BandWidth;
    results(aa).computesurr         = computesurr;
    results(aa).numsurrogate        = numsurrogate;
    results(aa).alphause            = alphause;
    results(aa).time_to_compute     = toc(start); % just for logging / compute time purposes
    results(aa).regionames          = regionames;
    
    %% plotting
    if plotdata
        if numplots ~=1
            subplot(2,2,aa)
            if aa <= 2
                ttlgrp = 'PAC within';
            else
                ttlgrp = 'PAC between';
            end
        else
            ttlgrp = 'PAC within';
        end
        
        
        contourf(PhaseFreqVector+PhaseFreq_BandWidth/2,AmpFreqVector+AmpFreq_BandWidth/2,Com_reshaped',30,'lines','none')
        set(gca,'fontsize',14)
        ttly = sprintf('Amplitude Frequency %s (Hz)',ttlAmp);
        ylabel(ttly)
        ttlx = sprintf('Phase Frequency %s (Hz)',ttlPha);
        xlabel(ttlx)
        title(ttlgrp);
        %colorbar
    end
end
if plotdata
    hfig.Visible = 'on';
end

if useparfor
    if exist('pool','var')
        delete(pool);
    end
end

end