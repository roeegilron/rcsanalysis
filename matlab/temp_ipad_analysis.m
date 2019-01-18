%% plot iPad on top of Delsys on top of Acccel 
% first try to plot ipad on top of Delsys 

%% load data 
% load rc+s data 
clear all 
close all; 
clc;
rootdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v03-postop/rcs-data/Session1539481694013/DeviceNPC700395H';
filesLoad = {'EventLog','DeviceSettings','RawDataAccel','RawDataTD'};
load(fullfile(rootdir,filesLoad{1}));
load(fullfile(rootdir,filesLoad{2}));
load(fullfile(rootdir,filesLoad{3}));
accelTab = outdatcomplete;
clear outdatcomplete;
load(fullfile(rootdir,filesLoad{4}));
srAcc = unique(srates);
tdTab = outdatcomplete;
clear outdatcomplete;
% load delsys data:
load('/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v03-postop/delsys-data/RCS01-postop_Plot_and_Store_Rep_2.4.csv.mat');
% % load syncd idx 
% load ipad-task.mat
% for l = 1:length(locsecrcs)
%     idxuse(l)  = find(rcsTime > locsecrcs ,1);
% end
% outdat.lfp = tdTab.key1;
% outdat.ecog = tdTab.key3;
% figdir = pwd; 
% 
% plot_ipad_data_rcs_json(idxuse(4:end-1),outdat,500,figdir,timeparams); 





%% find the actual data  
% get delsys data and resample to 64hz and zscore 
fnms = {'DBS_5Hz_ACCX1_IM_','DBS_5Hz_ACCY1_IM_','DBS_5Hz_ACCZ1_IM_'}; 
for p = 1:length(fnms)
    y = dataraw.(fnms{p});
    frac = 64/(2/0.0135);
    % sOut / sIn = p / q 
    % computer sOut/sIn and multiply fraction until you get int 
    y = resample(y,432,1e3); % deslys resampled
    delDat(p,:) = zscore(y - mean(y));
    endn
% get rcs data
fnms = {'XSamples','YSamples','ZSamples'}; 
hold on;
for p = 1:length(fnms)
    y = accelTab.(fnms{p});
    accDat(p,:) = zscore(y - mean(y));
end
% loop on all axis and compute the average lag using xcorr 
cnt = 1; 
for c = 1:size(accDat,1)
    [x,lags] = xcorr(accDat(c,:),delDat(c,:));
    idx(c) = lags(max(x)==x);
    if idx(c) > 0
        idxout(cnt) = idx(c); cnt = cnt + 1; 
        figure
        plot(lags,x);
        figure;
        hold on;
        plot([zeros(idx(c),1); delDat(c,:)']);
        plot(accDat(c,:));
    end
end
idxuse = ceil(mean(idxout));
%% plot delsys and rc+s using seconds and link axes 
hfig = figure; 
% plot acc RC+S 
hsb(1) = subplot(2,1,1); 
hold on;
secs = accelTab.derivedTimes; 
fnms = {'XSamples','YSamples','ZSamples'}; 
hold on;
for p = 1:size(accDat,1)
    hplt(p) = plot(accDat(p,:));
%     hplt(p) = plot(secs,accDat(p,:));
end
legend(fnms);
title('RC+S'); 
% plot acc Delsys 
secsTemp = 0:1:size(delDat,2)-1;
secsDel  = seconds(secsTemp./64);
secsToAddToFirstSample = seconds(idxuse/64); 
secsDate = secsDel + secs(1) + secsToAddToFirstSample; 
secsDate.TimeZone = 'America/Los_Angeles';
hsb(2) = subplot(2,1,2);
hold on; 
hold on;
for p = 1:length(fnms)
%     plot(secsDate,delDat(p,:));
        plot([ zeros(idxuse,1); delDat(p,:)' ]);
end%% 
% link axes 
title('delsys'); 
legend({'x','y','z'});
linkaxes(hsb,'x');

%%





%%

%% plot acc delsys vs accel ecog 
rcspoint = seconds(1261.6388);
delpoint = seconds(980.59275);
rcspoint = seconds(1261.6388 - 980.59275);
delpoint = seconds(0);
hfig = figure; 
% plot acc RC+S 
hsb(1) = subplot(2,1,1); 
hold on;
secs = accelTab.derivedTimes; 
secsuse = (secs-secs(1)) - rcspoint;
secsuse.Format = 's';
fnms = {'XSamples','YSamples','ZSamples'}; 
hold on;
for p = 1:length(fnms)
    y = accelTab.(fnms{p});
    yuse = y - mean(y);
    plot(secsuse,yuse);
end
title('RC+S'); 
% plot acc Delsys 
secsTemp = 1:1:length(dataraw.DBS_5Hz_ACCX1_IM_);
secsDel  = seconds(secsTemp./dataraw.srates.ACC) - delpoint;
secsDate = seconds(secsDel) + datetime('13-Oct-2018 18:53:32.58');
secsDate.TimeZone = 'America/Los_Angeles';
hsb(2) = subplot(2,1,2);
hold on; 
fnms = {'DBS_5Hz_ACCX1_IM_','DBS_5Hz_ACCY1_IM_','DBS_5Hz_ACCZ1_IM_'}; 
hold on;
for p = 1:length(fnms)
    y = dataraw.(fnms{p});
    yuse = y - mean(y); 
    plot(secsDel,yuse);
end%% 
% link axes 
title('delsys'); 
linkaxes(hsb,'x');

%% plot actual data 
hfig = figure; 
% plot acc RC+S 
hsb(1) = subplot(2,1,1); 
hold on;
fnms = {'DBS_5Hz_ACCX1_IM_','DBS_5Hz_ACCY1_IM_','DBS_5Hz_ACCZ1_IM_'}; 
for p = 1:length(fnms)
    y = accelTab.(fnms{p});
    yuse = y - mean(y);
    plot(secsuse,yuse);
end
title('RC+S'); 
% plot acc Delsys 
secsTemp = 1:1:length(dataraw.DBS_5Hz_ACCX1_IM_);
secsDel  = seconds(secsTemp./dataraw.srates.ACC) - delpoint;
secsDate = seconds(secsDel) + datetime('13-Oct-2018 18:53:32.58');
secsDate.TimeZone = 'America/Los_Angeles';
hsb(2) = subplot(2,1,2);
hold on; 
fnms = {'DBS_5Hz_ACCX1_IM_','DBS_5Hz_ACCY1_IM_','DBS_5Hz_ACCZ1_IM_'}; 
hold on;
for p = 1:length(fnms)
    y = dataraw.(fnms{p});
    yuse = y - mean(y); 
    plot(secsDel,yuse);
end%% 
% link axes 
title('delsys'); 
linkaxes(hsb,'x');