%% Script name: rcs_software_model

% 1) Aim 1: play around with LDs and power bands to figure ways of removing/supressing stim artifact from sensing
% 2) Aim 2: devlop a software where we can study performanc of aDBS using embedded properties and beyond, based on time domain signal
% Data in: domain LFP, Power bands, LDs, stim current, states
% Data out: best fitting linear model that has best performanc suppresing stim artifact
% 

% LD settings variables
% - UpdateRate
% - OsetDuration
% - TerminationDuration
% - BlankingDuraitonUponStateChange
% - NormalizationSubtractVector
% - NormalizationMultiplyVector
% - WeightVector
% - BiasTerm
% - FractionalFixedPointValue


close all; clear all; clc

fontSize = 14;

%%% Example with perfect sinewave 20 Hz
toUv = 1e3;
Fs = 500;
f = 20;
A = 5;  % mv
T = 10;
[t1, y1, fs] = getSinewave(Fs,f,0,T);
[t2, y2, fs] = getSinewave(Fs,f,A,T);

t = [t1,t1(end)+t2];
y = toUv.*[y1,y2];

figure(1)
ax1 = subplot(211);
plot(t,y,'+-');
ylabel('Voltage (\muV)')
set(gca,'FontSize',fontSize);

%% Compute fft of the signal with hann window

% Compute the Fourier transform of the signal.
L = length(y);
Y = fft(y);

%Compute the two-sided spectrum P2. Then compute the single-sided spectrum P1 based on P2 and the even-valued signal length L.
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

%Define the frequency domain f and plot the single-sided amplitude spectrum P1. The amplitudes are not exactly at 0.7 and 1, as expected, because of the added noise. On average, longer signals produce better frequency approximations.
f = Fs*(0:(L/2))/L;
figure(2)
subplot(211)
plot(f,P1) 
title('Single-Sided Amplitude Spectrum of X(t)')
xlabel('f (Hz)')
ylabel('|P1(f)|')

[fftOut,ff]   = pwelch(y,Fs,Fs/2,0:1:Fs/2,Fs,'psd');
subplot(212)
plot(ff,fftOut,'r') 

%% Compute power of signal based on fft (output is FeaturePower)
fftRate = 50e-3;
updateRatePnts = fftRate*Fs;
fftpnts = 256;
f = Fs*(0:(fftpnts/2))/fftpnts;
freqBand=[15 25];
locs = find(f > freqBand(1) & f < freqBand(2));
countPwr = 0;
power = [];

% running window fft of time domain and equivalent power
for ii=1:length(y)-fftpnts
    % compute the Fourier transform of the signal.
    newfft(ii,:) = getFFT(y,fftpnts,ii);
    
    % plot first 10 iterations to get a sense of variation
    if ii>length(y)-fftpnts-10
        if ii==length(y)-fftpnts-9
        figure
        hold on
        title('Single-Sided Amplitude Spectrum of X(t)')
        xlabel('f (Hz)')
        ylabel('|P1(f)|')
        set(gca,'FontSize',fontSize);
        end
        plot(f,newfft(ii,:),'o') 
    end
   
    % after a multiple of update rate update power as avg of power points
    if mod(ii,updateRatePnts) == 0
        countPwr = countPwr + 1;
        power = [power;mean(newfft(ii+1-updateRatePnts:ii,locs).^2)];
    end

end

% plot power signal
figure(1)
ax2 = subplot(212);
t_power = 0:updateRatePnts/Fs:2*T;
addZeros = abs(size(power,1)-length(t_power));
power = [zeros(addZeros,size(power,2));power];
plot(t_power(1:size(power,1)),power(:,3),'o-')
ylabel('Power (\muV\^2)')
xlabel('time(s)')
set(gca,'FontSize',fontSize);
linkaxes([ax1,ax2],'x');


%% Compare this power to the power of a signal from RCS


%% From POWER bands to LD Power Output with 1 LD
% powerBands: matrix with time domain power signal, each column one power band 
% here an example code
FeaturePower1 = powerBands(:,1);
FeaturePower2 = powerBands(:,2);
featureLength = 2;

FractionalFixedPointValue = 8;  % 0 default value; should be 1, 2, 4, or 8 (Dave's suggestsion is to use 8) if we want to use weighting with two or more power bands
WeightVector = [1 1 0 0];   % here we indicate the power band/s we using
NormalizationMultiplyVector = [1 1 0 0];    % 0 default; should be 1 or different than 0 if we want to scale/normalize several features in 1 LDPowerOutput
NormalizationSubtractVector = [x y 0 0];    % 0 default; this x, y, values are the variables we are looking for to substract artifact from physiological power

for i = 1 : featureLength
    for j = 1 : length(FeaturePower1) 
        W(i) = (WeightVector(i)) / 2^FractionalFixedPointValue;
        M(i) 	= (NormalizationMultiplyVector(i)) / 2^FractionalFixedPointValue;
        ScaledFeaturePower(j,i) = W(i) * M(i) * (FeaturePower(j,i)-NormalizationSubtractVector(i));
    end
end

LDPowerOutput = sum (ScaledFeaturePower);

%% LDPowerOutput
% compared to Lower and Upper threshold terms to determine if the output is, low?, in-range?, or high? when using dual thresholds
% With a single Threshold, the output states compare against only the LowerThreshold and are, low? or ?high?.
LowerThreshold = (BiasTerm[1]) / 2^FractionalFixedPointValue 
UpperThreshold = (BiasTerm[2]) / 2^FractionalFixedPointValue 

%%%%%%%%%%%%%%%%%%%%%%%%% code CORRECTED DAVE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% powerBands: matrix with time domain power signal, each column one power band
% here an example code
FeaturePower1 = powerBands(:,1);
FeaturePower2 = powerBands(:,2);
featureLength = 2;
UpdateRate    = 4;            % example for number of power points to average (can be 1 [no averaging])
FractionalFixedPointValue = 8;  % 0 default value; should be 1, 2, 4, or 8 (Dave's suggestsion is to use 8) if we want to use weighting with two or more power bands
WeightVector = [X Y 0 0];   % here we indicate the power band/s we using
NormalizationMultiplyVector = [1 1 0 0];    % 0 default; should be 1 or different than 0 if we want to scale/normalize several features in 1 LDPowerOutput
NormalizationSubtractVector = [0 0 0 0];    % 0 default; this x, y, values are the variables we are looking for to substract artifact from physiological power
 
% Compute power sum for previous ?updateRate? number of power points including current
for i = 1 : featureLength
    for j = 1 : UpdateRate
        FeaturePower_sum(i) = powerBands(length-j:,i);
    end
end
 
% compute the LDOutput
LDPowerOutput = 0;
for i = 1 : featureLength
    FeaturePower_avg(i)   = FeaturePower_sum(i) / UpdateRate;           % Compute average power for feature          
    W(i)                  = (WeightVector(i)) / 2^FractionalFixedPointValue;
    M(i)                  = (NormalizationMultiplyVector(i)) / 2^FractionalFixedPointValue;
    ScaledFeaturePower(i) = W(i) * M(i) * (FeaturePower_avg(i)-NormalizationSubtractVector(i));
    LDPowerOutput         = LDPowerOutput + ScaledFeaturePower(i);
end
 
% Compute the immediate detection state
ThresholdNum = 2;          % be 1(single) or 2 (dual)
Threshhold   = [1 1]       % threshold values from configuration
 
Detect       = [0 0];      % Immediate [not final] detection state
for t = 1 : ThresholdNum
if LDPowerOutput >= Threshold(t)
    Detect(t) = 1;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%% UP TO HERE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [t, y, fs] = getSinewave(fs,f,A,T)
ts=1/fs;
t=0:ts:T;
y=A*sin(2*pi*f*t);
% sound(y,fs);
end
