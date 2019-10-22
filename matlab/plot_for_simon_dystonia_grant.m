function plot_for_simon_dystonia_grant()
close all;

fn = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS04/RCS04_StarrLab/RCS04L/Session1562869314738/DeviceNPC700418H';

[outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerOut,adaptiveTable] =  MAIN_load_rcs_data_from_folder(fn);
figdir = fullfile(fn,'figures'); 
mkdir(figdir); 

deviceSettingsFn = fullfile(fn,'DeviceSettings.json');
outRec = loadDeviceSettingsForMontage(deviceSettingsFn);
% figure out add / subtract factor for event times (if pc clock is not same
% as INS time).
idxTimeCompare = find(outdatcomplete.PacketRxUnixTime~=0,1);
packRxTimeRaw  = outdatcomplete.PacketRxUnixTime(idxTimeCompare);
packtRxTime    =  datetime(packRxTimeRaw/1000,...
    'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
derivedTime    = outdatcomplete.derivedTimes(idxTimeCompare);
timeDiff       = derivedTime - packtRxTime;
% add a delta to the event markers
deltaUse = seconds(3);
secs = outdatcomplete.derivedTimes;
app.subTime = secs(1);
% find start events
idxStart = cellfun(@(x) any(strfind(x,'Start')),eventTable.EventType);
idxEnd = cellfun(@(x) any(strfind(x,'Stop')),eventTable.EventType);

% insert event table markers and link them
app.ets = eventTable(idxStart,:);
app.ete = eventTable(idxEnd,:);

xval = app.ets.UnixOffsetTime(2) + timeDiff +  deltaUse;
startTime = xval ;
% end
xval = app.ete.UnixOffsetTime(2)+timeDiff - deltaUse;
endTime = xval;
secsUse = secs;
idxuse = secsUse > startTime & secsUse < endTime;

% channels 
{outRec(2).tdData.chanFullStr}'

figure;
stn = outdatcomplete.key0(idxuse);
m1  = outdatcomplete.key3(idxuse); 
hsub(1) = subplot(2,1,1); 
plot(secsUse(idxuse),stn); 
title(outRec(2).tdData(1).chanFullStr);

hsub(2) = subplot(2,1,2); 
plot(secsUse(idxuse),m1); 
title(outRec(2).tdData(4).chanFullStr);

linkaxes(hsub,'x'); 
savefig(fullfile(figdir,'raw data.fig'));
sgtitle('raw data'); 


% plot figure graph 
hfig = figure; 
hsub(1) = subplot(4,2,1); % stn 
hsub(2) = subplot(4,2,2); % m1 
hsub(3) = subplot(4,2,[3 4]); % spectrogram stn 
hsub(4) = subplot(4,2,[5 6]); % spectrogram m1 
hsub(5) = subplot(4,2,[7 8]); % cohernece stn m1 

% plot stn 
hfig = figure; 
y = stn; 
srate = 500; 
% axes(hsub(1));
[fftOut,f]   = pwelch(y,srate,srate/2,0:1:srate/2,srate,'psd');
hp = plot(f,log10(fftOut));
hp.LineWidth = 3;
hp.Color     = [0.8 0 0 0.5];
xlim([0 80]);
title('stn');
xlabel('Frequency (Hz)');
ylabel('Power  (log_1_0\muV^2/Hz)');
savefig(hfig, fullfile(figdir,'stn psd.fig'));

% plot stn 
hfig = figure; 
y = m1; 
srate = 500; 
% axes(hsub(2));
[fftOut,f]   = pwelch(y,srate,srate/2,0:1:srate/2,srate,'psd');
hp = plot(f,log10(fftOut));
hp.LineWidth = 3;
hp.Color     = [0 0 0.8 0.5];
xlim([0 80]);
title('m1');
xlabel('Frequency (Hz)');
ylabel('Power  (log_1_0\muV^2/Hz)');
savefig(hfig, fullfile(figdir,'m1 psd.fig'));

% plot stn spectral 
hfig = figure; 
data = stn';
fs = 500; 
% axes(hsub(3));
peaks = [4 6]; 
PlotData = 0; 
normalize = 1; 
[OutS,t,f] = plot_spectogram_normalized(data,fs,peaks,PlotData,normalize);
pcolor(t,f,OutS ); 
axis xy; 
% colorbar; 
title('stn');
axis tight; 
ylim([0 15]);
shading interp
savefig(hfig, fullfile(figdir,'stn spect.fig'));

% plot m1 spectral 
hfig = figure; 
data = m1';
fs = 500; 
% axes(hsub(4));
peaks = [4 6]; 
PlotData = 0; 
normalize = 1; 
[OutS,t,f] = plot_spectogram_normalized(data,fs,peaks,PlotData,normalize);
pcolor(t,f,OutS ); 
axis xy; 
% colorbar; 
title('m1');
axis tight; 
ylim([0 15]);
shading interp
savefig(hfig, fullfile(figdir,'m1 spect.fig'));


% plot simon coherence 
hfig = figure; 
% axes(hsub(5)); 
Fs = 500;
[Cxy,F] = mscohere(stn,m1,...
    2^(nextpow2(Fs)),...
    2^(nextpow2(Fs/2)),...
    2^(nextpow2(Fs)),...
    Fs);
idxplot = F > 0 & F < 100; 
hplot = plot(F(idxplot),Cxy(idxplot));
xlabel('Freq (Hz)');
ylabel('coherence'); 
savefig(hfig, fullfile(figdir,'coherence.fig'));



end