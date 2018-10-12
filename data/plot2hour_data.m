function plot2hour_data()
%% load data 
rcsfn = '/Users/roee/Starr_Lab_Folder/Data_Analysis/rcsanalysis/data/RawDataTD_2hour.mat';
delfn = '/Users/roee/Starr_Lab_Folder/Data_Analysis/rcsanalysis/data/delsys_5hz.mat';
load(rcsfn); 
load(delfn); 

%% filter 5hz data and choose zero point. 
rcs5hz = outdatcomplete.key1;
rcs5hz = rcs5hz - mean(rcs5hz);
rcs5hzsecraw = outdatcomplete.derivedTimes; 
bstops = [58 62; 118 122; 178 182]; 
rcs5hzfilt = rcs5hz; 
for bs = 1:size(bstops)
    [b, a] = butter(3,2*[bstops(bs,1) bstops(bs,2)]/1e3,'stop'); 
    rcs5hzfilt = filtfilt(b, a, rcs5hzfilt); %notch out at 60
end
[b, a] = butter(3,2*[3 100]/1e3,'bandpass');
rcs5hzfilt = filtfilt(b, a, rcs5hzfilt); %notch out at 60
idxlast5hz = 12961; 
secsdur = rcs5hzsecraw-rcs5hzsecraw(idxlast5hz); 


%% get delsys data 
idxlast5hzDel = 33856;
del5hz = dataraw.DBS_5Hz_EMG3; 
figure;plot(del5hz);

srate  = 26/0.0135; 
period = 1/srate; 
% create sec vector 
lenrem = size(del5hz,1)- idxlast5hzDel;
remvec = 0:period:(lenrem/srate)';
stavec = -(idxlast5hzDel-1)/srate:period:(0-period);
size(stavec,2) + size(remvec,2);
secsve = seconds([stavec remvec]); 

figure;plot(secsve,del5hz);

%% plot data all 
hfig = figure;
hs1 = subplot(2,1,1);
h1 = plot(secsdur,rcs5hzfilt);
hs2 = subplot(2,1,2);
h2 = plot(secsve,del5hz);
linkaxes([hs1 hs2],'x'); 
xlim([seconds(-0.5) seconds(0.5)]); 

delendidx = 13805107; 
rcendidx = 7149656; 
secend = seconds(7150.45725); 

%% plot data selective with break axis 
% start 
% rcs 
rcsidxstart = secsdur > seconds(-0.5) & secsdur < seconds(0.1); 
rcsStart = rescale(rcs5hzfilt(rcsidxstart),0.6,0.9);
rcsSec   = secsdur(rcsidxstart); 
% delsys 
delidxstart = secsve > seconds(-0.5) & secsve < seconds(0.1); 
delStart = rescale(del5hz(delidxstart),0.1,0.5);
delSec   = secsve(delidxstart); 

% end 
secend = seconds(7150.45725); 
rcsidxend = secsdur > secend-seconds(0.45) & secsdur < secend+seconds(0.2); 
rcsEnd = rescale(rcs5hzfilt(rcsidxend),0.6,0.9);
rcsSecEnd   = secsdur(rcsidxend); 
% delsys 
delidxEnd = secsve > secend-seconds(0.45) & secsve < secend+seconds(0.2); 
delEnd = rescale(del5hz(delidxEnd),0.1,0.5);
delSecEnd   = secsve(delidxEnd); 


%% plot 
hfig = figure; 
hfig.Position = [1000         534        1088         804];
hold on; 
hplt1 = plot(datenum(rcsSec),rcsStart); 
hplt1.Color = [0 0 0.8 0.8]; 
hplt1.LineWidth = 2; 
hplt2 = plot(datenum(delSec),delStart); 
hplt2.Color = [0.8 0 0 0.8]; 
hplt2.LineWidth = 2; 
ylim([0 1]); 
hplt1 = plot(datenum(rcsSecEnd),rcsEnd); 
hplt1.Color = [0 0 0.8 0.8]; 
hplt1.LineWidth = 2; 
hplt2 = plot(datenum(delSecEnd),delEnd); 
hplt2.Color = [0.8 0 0 0.8]; 
hplt2.LineWidth = 2; 
ylim([0 1]); 
xlim([datenum(delSec(1)) datenum(delSecEnd(end))]  )
splitout = [datenum(delSec(end)) datenum(delSecEnd(1))];
% find peaks delsys 
[pks,locsdel,w,p] = findpeaks(delEnd,datenum(delSecEnd),...
    'MinPeakDistance',datenum(seconds(0.15)),...
    'MinPeakProminence',0.2);
scatter(locsdel,pks); 
% find peaks rcs 
[pks,locsrcs,w,p] = findpeaks(rcsEnd(112:end),datenum(rcsSecEnd(112:end)),...
    'MinPeakDistance',datenum(seconds(0.15)),...
    'MinPeakProminence',0.2);
scatter(locsrcs,pks); 

axout = breakxaxis(splitout); 
for i = 1:3
    diffsuse(i) = locsdel(i) - locsrcs(i) ;
end
diffs = mean(diffsuse);
val = abs(milliseconds(diffs));

axout.rightAxes.XTick = sort([locsdel locsrcs']); 
axout.rightAxes.XTickLabelRotation = 45; 
datetick(axout.rightAxes,'x','HH:MM:SS.FFF','keepticks','keeplimits');
set(axout.rightAxes,'FontSize',16);


[pks,locsrcsstart,w,p] = findpeaks(rcsStart,datenum(rcsSec),...
    'MinPeakDistance',datenum(seconds(0.15)),...
    'MinPeakProminence',0.2);
scatter(axout.leftAxes,locsrcsstart,pks); 


axout.leftAxes.XTick = sort([locsrcsstart ]); 
axout.leftAxes.XTickLabelRotation = 45; 
datetick(axout.leftAxes,'x','FFF','keepticks','keeplimits');
set(axout.leftAxes,'FontSize',16);
axout.leftAxes.YTick = [];
axout.leftAxes.YTickLabel = '';
ttl{1,1} = 'Delsys RC+S sync 2 hour recording';
ttl{2,1} = sprintf('avg diff at end = %0.3f msec',val);
title(axout.annotationAxes,ttl);


axout.annotationAxes.YTick =[];
axout.annotationAxes.YTickLabel = '';
axout.annotationAxes.FontSize = 18;
%%


axout.annotationAxes.Clipping = 'off';
axout.leftAxes.Clipping = 'off';
axout.rightAxes.Clipping = 'off';
plotwidth  = 20;
plotheight = 20/1.6;
hfig.PaperPositionMode = 'manual'; 
hfig.PaperOrientation  = 'portrait';
hfig.PaperUnits        = 'inches';
hfig.PaperSize         = [plotwidth plotheight]; 
hfig.PaperPosition     = [0 0 plotwidth plotheight]; 
figname = fullfile(pwd,'ro1fig-bnc2.jpeg'); 
print(hfig,figname,'-djpeg','-r300');
figname = fullfile(pwd,'ro1fig-bnc2.pdf'); 
print(hfig,figname,'-dpdf');

figname = fullfile(pwd,'ro1fig-bnc2.fig'); 
saveas(hfig,figname);

hfig.InnerPosition



end