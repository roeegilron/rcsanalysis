
close all; clear all; clc

f = [0.5 0.5 20 20 50 100 150 200 250]

rmsIn = 707.1067812;
rmsOut = [843 843 2051 2065 1677 1085 662 415 44];

houtIn = rmsOut./rmsIn;
plot(f,10*log10(houtIn/max(houtIn)),'-o')
xlabel('Frequency (Hz)')
ylabel('10 x log_{10}(V_{o}/V_{in})')
set(gca,'FontSize',16);
hold on
houtIn_interp = interp(houtIn,10);
ff_interp = interp(f,10);
plot(ff_interp,10*log10(houtIn_interp/max(houtIn_interp)),'+')
axis([0 250 -20 0])
legend('meas rms(Vout/Vin)','interp(data,10)')