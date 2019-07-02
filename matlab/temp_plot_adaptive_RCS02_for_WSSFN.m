function temp_plot_adaptive_RCS02_for_WSSFN()

%% clear stuff 
clear all; close all; clc; 
%%
%% set up params
params.dir =  '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/v09_adaptive/adaptive_day_2/surfacebook/RCS02R/Session1559769597879/DeviceNPC700404H';
params.outdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/v09_adaptive/adaptive_day_2/surfacebook/RCS02R/Session1559769597879/DeviceNPC700404H';
params.dir    = '/Volumes/Samsung_T5/RCS02/v10_02_month/RCS_DATA/SCBS/RCS02L/Session1561746867608/DeviceNPC700398H';
params.outdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/v09_adaptive/figures';

%% load data 
fnAdaptive = fullfile([params.dir 'AdaptiveLog.json']); 
[outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerTable] =  MAIN_load_rcs_data_from_folder(params.dir);
%% load adaptive 
fnAdaptive = fullfile(params.dir,'AdaptiveLog.json'); 
res = readAdaptiveJson(fnAdaptive);

%% plot detector and time domain
% time start and time end in packet gen time time 
timeStart = datetime('05-Jun-2019 15:05:54.844'); 
timeEnd   = datetime('05-Jun-2019 15:14:35.819'); 
timeStart.TimeZone = 'America/Los_Angeles';
timeEnd.TimeZone = 'America/Los_Angeles';

cur = res.adaptive.CurrentProgramAmplitudesInMilliamps(1,:); 
timestamps = datetime(datevec(res.timing.timestamp./86400 + datenum(2000,3,1,0,0,0))); % medtronic time - LSB is seconds
uxtimes = datetime(res.timing.PacketGenTime/1000,...
    'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
% 
% find idx of event 
% idxevent = ...
%     strcmp(eventTable.EventSubType,'Now on continuous DBS. Induce dyskinesia and see if it self terminates or not.'); 
% timeStart = eventTable.UnixOnsetTime(idxevent); 
% timeEnd   = timeStart+ minutes(22); 
idxuse = uxtimes > timeStart & uxtimes < timeEnd;
timeUse = uxtimes(idxuse); 
% trim factor bcs of packet gentime below 
startTimeDetector = datetime('05-Jun-2019 15:06:51.828');
startTimeDetector.TimeZone = 'America/Los_Angeles';
idxuse = uxtimes > startTimeDetector & uxtimes < timeEnd;
timeUse = uxtimes(idxuse); 
timeUse = timeUse - timeUse(1);
timeUse = minutes(timeUse);
hfig = figure;
% detector 

% trim factor bcs of packet gentime below 

hsub(1) = subplot(3,1,1); 
hold on; 
ld0 = res.adaptive.LD0_output(idxuse); 
ld0_high = res.adaptive.LD0_highThreshold(idxuse); 
ld0_low  = res.adaptive.LD0_lowThreshold(idxuse); 

plot(timeUse,ld0,'LineWidth',3);
hplt = plot(timeUse,ld0_high,'LineWidth',3);
hplt.LineStyle = '-.';
% hplt.Color = [hplt.Color 0.7];
% hplt = plot(timeUse,ld0_low,'LineWidth',3);
hplt.LineStyle = '-.';
hplt.Color = [hplt.Color 0.7];


% ylimsUse(1) = res.adaptive.LD0_lowThreshold(1)*0.2;
% ylimsUse(2) = res.adaptive.LD0_highThreshold(1)*1.8;


% ylimsUse(1) = prctile(ld0,1);
% ylimsUse(2) = prctile(ld0,99);

ylim([min(ld0) max(ld0)]); 
title('Detector'); 
ylabel('Detector (a.u.)'); 
xlabel('Time'); 
legend({'Detector','Threshold'}); 
set(gca,'FontSize',24)

% time domain 
hsub(2) = subplot(3,1,2); 

% get rid of curropt packets with wrong year 
idxkeepyear = year(outdatcomplete.derivedTimes)==2019; 
outdatcomplete = outdatcomplete(idxkeepyear,:); 
% only keep packets aroung packet gen time start and end time before get
% real time 
alltimes = outdatcomplete.derivedTimes; 
idxkeepTimeDomain = alltimes > (timeStart ) & alltimes < (timeEnd ); 
outdatcomplete = outdatcomplete(idxkeepTimeDomain,:); 

idxPackTimes = find(outdatcomplete.PacketGenTime ~=0); 
pactimeUnix = outdatcomplete.PacketGenTime(idxPackTimes); 
pactimeReal = datetime(pactimeUnix/1000,...
    'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');

times = outdatcomplete.derivedTimes;
% take the difference between packet gen tiems and packTime real 
timeDiff = pactimeReal(1) - times(idxPackTimes(1));
timesModified = times + timeDiff; 

idxuseTimeDomain = timesModified > (timeStart ) & timesModified < (timeEnd ); 
% use below to verify with real signal 

tempTime = timesModified(idxuseTimeDomain);
timeUseTimeDomainDuration = tempTime-tempTime(1); 
% plot(timeUseTimeDomainDuration,outdatcomplete.key3(idxuseTimeDomain)); 
% plot spectrogmram 
y = outdatcomplete.key3(idxuseTimeDomain);
srate = unique(outdatcomplete.samplerate);
SNR = -300;
y = y-mean(y); 
% [s,f,t,p] = spectrogram(y,2000,850,128*5,srate,'MinThreshold',SNR ,'yaxis');
spectrogram(y,1000,850,128*5,srate,'MinThreshold',SNR ,'yaxis');
axis tight
shading interp
ylim([5 100]);
colorbar off; 
title('M1'); 
xlabel('');
set(gca,'FontSize',24)

% plot acceleration 
hsub(3) = subplot(3,1,1); 


% get rid of curropt packets with wrong year 
idxkeepyearAcc = year(outdatcompleteAcc.derivedTimes)==2019; 
outdatcompleteAcc = outdatcompleteAcc(idxkeepyearAcc,:); 
% only keep packets aroung packet gen time start and end time before get
% real time 
alltimesAcc = outdatcompleteAcc.derivedTimes; 
idxkeepAcc = alltimesAcc > (timeStart ) & alltimesAcc < (timeEnd ); 
outdatcompleteAcc = outdatcompleteAcc(idxkeepAcc,:); 

idxPackTimesAcc = find(outdatcompleteAcc.PacketGenTime ~=0); 
pactimeUnixAcc = outdatcompleteAcc.PacketGenTime(idxPackTimesAcc); 
pactimeRealAcc = datetime(pactimeUnixAcc/1000,...
    'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');

timesAcc = outdatcompleteAcc.derivedTimes;
% take the difference between packet gen tiems and packTime real 
timeDiffAcc = pactimeRealAcc(1) - timesAcc(idxPackTimesAcc(1));
timesModifiedAcc = timesAcc + timeDiffAcc; 

idxuseAcc = timesModifiedAcc > (timeStart ) & timesModifiedAcc < (timeEnd ); 
 
tuse = timesModifiedAcc;
hsub(3) = subplot(3,1,3); 
x = outdatcompleteAcc.XSamples(idxuseAcc); 
y = outdatcompleteAcc.YSamples(idxuseAcc); 
z = outdatcompleteAcc.ZSamples(idxuseAcc); 

x = x - mean(x);
y = y - mean(y);
z = z - mean(z);

avgMov = mean([abs(x) abs(y) abs(z)],2)'; 
avgMoveSmoothed = movmean(avgMov,[32*2 0]); 
avgMovePercent = avgMoveSmoothed;
% baseline = tuse < 5; 
% baselineVal = mean(avgMoveSmoothed(baseline)); 
% avgMovePercent = (avgMoveSmoothed./baselineVal); 

hold on;
% plot(tuse,x);
% plot(tuse,y);
% plot(tuse,z);
timeUseAcc = tuse(idxuseAcc);
timeUseAccDuration = minutes(timeUseAcc-timeUseAcc(1));
hp = plot(timeUseAccDuration, avgMovePercent); 
hp.LineWidth = 3; 
hp.Color = [0 0 0.8 0.8];
title('Internal accelrometer'); 
set(gca,'FontSize',24)
% link axes 
linkaxes(hsub,'x'); 
xlim([0.5 7]); 

pfig.plotwidth           = (450/10)/2.24;
pfig.plotheight          = (211/10)/2.24;
pfig.figdir              = '/Users/roee/Starr_Lab_Folder/Presenting/Posters/Gilron_WSSFN_2019/figures';
pfig.figname             = 'adaptive_dyskinesia'; 
pfig.figtype             = '-dpdf';
pfig.closeafterprint     = 1;
pfig.resolution          = 600;
plot_hfig(hfig,pfig);

end