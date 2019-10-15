function [OutS,t,f] = plot_spectogram_normalized(data,fs,peaks,PlotData,normalize)
% thus function plots a normalized spectorgram by fitting a 6th degree
% polynomial to everything aside froms peaks.
% input: 
% data - matrix of times (column vector) 
% fs - sampling rate 
% peaks - peaks in the data in the format of peaks = [15 30; 67 87]; etc. 
% if PlotData is true data is plotted, if false it is not 

%% chronux 
pathChronux = genpath('/Users/roee/Starr_Lab_Folder/Data_Analysis/delsysread/toolboxes/chronux_2_11');
addpath(pathChronux);
%% set params
% set params for ERSP prodcution 
specparams.tapers       = [3 5]; % precalculated tapers from dpss or in the one of the following
specparams.pad          = 1;% padding factor for the FFT) - optional
specparams.err          = [2 0.05]; % (error calculation [1 p] - Theoretical error bars; [2 p] - Jackknife error bars
specparams.trialave     = 0; % (average over trials/channels when 1, don't average when 0) 
specparams.Fs           = fs; % sampling frequency 
centerFreqs             = make_center_frequencies(2,100,60,4);

specparams.fpass        = centerFreqs; %frequency band to be used in the calculation in the form [fmin fmax])- optional. 
specparams.fpass        = [1 100]; %frequency band to be used in the calculation in the form [fmin fmax])- optional. 
movingwin = [2 2*0.95];% (in the form [window winstep] i.e length of moving window and step size) Note that units here have to be consistent with units of Fs - required

%% compute spectorgram 
data = data - mean(data); % detrend 
[S,t,f,Serr] = mtspecgramc(data,movingwin,specparams);
SLog = 10.*log10(S); 
SLogScaled = rescale(SLog,0,1); % scale between zero to one 

% get the idx of the peaks 
idxPeaks = zeros(size(f,2),1);
for i = 1:size(peaks,1)
    idxPeaks = idxPeaks | (f >= peaks(i,1) & f <= peaks(i,2) )';
end
idxNotPeaks = ~idxPeaks; 
% get avg
MeanVal= mean(SLogScaled(:,idxNotPeaks),1);
% find poly nomial 
polyFit6 = fit(f(idxNotPeaks)',MeanVal','poly6');

% plot the fit
% figure;
% hold on;
% meanPeaks = mean(SLogScaled,1);
% plot(f,meanPeaks);
% plot(f(idxNotPeaks),MeanVal,'o')
% plot(polyFit6,'b');

% fit all freq ranges 
fVals = polyFit6(f);
PolyRep = repmat(fVals,1,size(SLog,1))';
if ~normalize
    PolyRep = repmat(ones(size(fVals,1),1),1,size(SLog,1))';
end

OutS = (SLogScaled./PolyRep)';
if PlotData
    figure;
    pcolor(t,f,(SLogScaled./PolyRep)' ); axis xy; colorbar; title('S/Lower');
    shading interp
end

rmpath(pathChronux);


end