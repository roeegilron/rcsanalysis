function resampleDelsys(data,srIn,srOut)
%y = resample(x,p,q) resamples the input sequence, x, at p/q times the original sample rate. 
% If x is a matrix, then resample treats each column of x as an independent channel. 
% resample applies an antialiasing FIR lowpass filter to x and compensates for the delay introduced by the filter.

% Change the sampling rate of a 1 kHz sinusoid by a factor of 147/160. This factor is used to convert from 48 kHz (DAT rate) to 44.1 kHz (CD sampling rate).

Fs = srIn;                   % Original sampling frequency-48kHz
L = 147;                     % Interpolation/decimation factors
M = 160;
N = 24*L;
h = fir1(N-1,1/M,kaiser(N,7.8562));
h = L*h;                     % Passband gain is L

n = 0:10239;                 % 10240 samples, 0.213 seconds long
x = sin(2*pi*1e3/Fs*n);      % Original signal
y = upfirdn(x,h,L,M);        % 9430 samples, still 0.213 seconds

%Plot the first millisecond of the original signal and overlay the resampled version.
times = seconds( (1:size(data,1) ) ./ (2/0.0135));

timesX = seconds( (1:1:size(x,1) ) ./ 64); 
figure;
plot(times',data); 
hold on; 
plot(timesX', x) ;


stem(n(1:49)/Fs,x(1:49))
hold on 
stem(n(2:45)/(Fs*L/M),y(13:56),'*')
hold off
xlabel('Time (s)')
ylabel('Signal')
legend('Original','Resampled')
