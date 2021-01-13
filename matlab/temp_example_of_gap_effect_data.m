%% missing data demo 
fs = 1000;
t = 0:1/fs:2;
x = chirp(t,100,1,200,'quadratic');

spectrogram(x,128,120,128,fs,'yaxis')
title('Quadratic Chirp')




% get rid of 10 samples for every 100 
%% make data
x = chirp(t,20,1,60,'logarithmic');
xx = x;

y = []; 
for i = 500:100:1e3
    xx(i-70+1:i) = NaN;
end
y = xx(~isnan(xx));

%%
hfig = figure; 
hfig.Color = 'w'; 
subplot(1,2,1);
plot(x);
xlim([0 2e3]);
set(gca,'FontSize',16);
title('original data');

subplot(1,2,2);
plot(xx);
xlim([0 2e3]);
set(gca,'FontSize',16);
title('missing data');

%%
hfig = figure;
hfig.Color = 'w';
windowSize = 512; 
overlap = ceil(0.875*windowSize);
NFFT = 256; 
subplot(2,2,1);
sr = 1e3;
yFilled = fillmissing(y,'constant',0);
[sss,fff,ttt,ppp] = spectrogram(x,kaiser(windowSize,5),overlap,NFFT,sr,'yaxis');
pcolor(ttt, fff ,log10(ppp));
% surf(hsb(c,1),spectTimes, fff, 10*log10(ppp), 'EdgeColor', 'none');
colormap(cmap);
title('Chirp - all data')
colormap('jet');
shading interp;
xlabel('time (s)')
ylabel('freq (hz');
set(gca,'FontSize',16);




subplot(2,2,2);
sr = 1e3;
[sss,fff,ttt,ppp] = spectrogram(y,kaiser(windowSize,5),overlap,NFFT,sr,'yaxis');
pcolor(ttt, fff ,log10(ppp));
title('Chirp - missing data un-accounted for')
colormap('jet');
shading interp;
xlabel('time (s)')
ylabel('freq (hz');
set(gca,'FontSize',16);


subplot(2,2,3);
sr = 1e3;
yFilled = fillmissing(xx,'constant',0);
[sss,fff,ttt,ppp] = spectrogram(yFilled,kaiser(windowSize,5),overlap,NFFT,sr,'yaxis');
idxGapStart = find(diff(isnan(xx))==1) + 1;
idxGapEnd = find(diff(isnan(xx))==-1) + 1;
for te = 1:size(idxGapStart,2)
    timeGap(te,1) = t(idxGapStart(te)) - 0.1;
    timeGap(te,2) = t(idxGapEnd(te)) + 0.1;
    idxBlank = ttt >= timeGap(te,1) & ttt <= timeGap(te,2);
    ppp(:,idxBlank) = NaN;
end

pcolor(ttt, fff ,log10(ppp));
title('Chirp - accounted for & blanked')
colormap('jet');
shading interp;
xlabel('time (s)')
ylabel('freq (hz');
set(gca,'FontSize',16);



subplot(2,2,4);
idxkeep = ~isnan(ppp(1,:));

pcolor(ttt(idxkeep), fff ,log10(ppp(:,idxkeep)));
title('Quadratic Chirp - accounted for cut out')
colormap('jet');
shading interp;
xlabel('time (s)')
ylabel('freq (hz');
set(gca,'FontSize',16);




