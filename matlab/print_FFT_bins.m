function print_FFT_bins()
clc;
%% params to change 
FFTSize = 256; % can be 64  256  1024
sampleRate = 1000; % can be 250,500,1000
%% 
numberOfBins = FFTSize/2; 
binWidth = sampleRate/2/numberOfBins; 

for i = 0:(numberOfBins-1)
    fftBins(i+1) = i*binWidth;
%     fprintf('bins numbers %.2f\n',fftBins(i+1)); 
end

lower(1) = 0; 
for i = 2:length(fftBins)   
    valInHz = fftBins(i)-fftBins(2)/2;
    lower(i) = valInHz;
%     fprintf('lower value in hz %.2f\n',lower(i)); 
end

for i = 1:length(fftBins)
    valInHz = fftBins(i)+fftBins(2)/2;
    upper(i) = valInHz;
%     fprintf('upper value in hz %.2f\n',lower(i)); 
end

for i = 1:length(upper)
    fprintf('lower =\t %2.2f (Hz)\t upper=\t %.2f(Hz)\n',lower(i),upper(i)); 
end

end