function plot_ipad_data()
%% This function is an ugly non automatic function to ploy ipad data
%% It shamelessly copies bits of code from all kind of places to form a 
%% clunkly solution that will hopefully be improved soon 
close all 
clear all 

%% Step 1: convert .hpf files 
%  A. this is done using hte delsys convert utility 
%  B. then you use this function to convert the .csv output from (A) to a .csv file using the process flag 
%     convertDelsysToMat('full path to fn.csv','process') (function found in delsysread folder) 
%  C. Make sure using plotting functions that 5Hz artifact is visible in
%     both functions 
%% 

%% Step 2: get idx for 5Hz artifact and save this to another file. 
% delsysFn 
fprintf('get delsys file name\n'); 
[fn,pn ] = uigetfile('*.mat','get delsys file name');
delsysFn = fullfile(pn,fn); 
load(delsysFn)
% rcs data folder 
fprintf('get rc+s folder name\n'); 
dataDir = uigetdir('get rc+s folder name'); 
% load files 
load(fullfile(dataDir,'RawDataTD.mat'));
rcsDat = outdatcomplete; 
rcsSrate = srates; 
clear outdatcomplete srates; 

load(fullfile(dataDir,'RawDataAccel.mat'));
accDataRcs = outdatcomplete; 
accSrate = srates; 
clear outdatcomplete srates; 

load(fullfile(dataDir,'DeviceSettings.mat'));
% fig dir 
fprintf('get fig dir folder name\n'); 
figdir = uigetdir('get fig dir folder name'); 
% ipad file 
fprintf('get ipad file json\n')
[fn,pn ] = uigetfile('*.json');
ipadFn = fullfile(pn,fn); 

%save params for easy reload 
params.delsysFn = delsysFn; 
params.dataDir = dataDir;
params.figdir = figdir; 
params.ipadFn = ipadFn; 
fnparams = fullfile(dataDir,'params-ipad-1.mat'); 
save(fnparams,'params');

%% load with params
load(fnparams,'params'); 
load(params.delsysFn)
% load files 
load(fullfile(params.dataDir,'RawDataTD.mat'));
rcsDat = outdatcomplete; 
rcsSrate = srates; 
clear outdatcomplete srates; 
load(fullfile(params.dataDir,'RawDataAccel.mat'));
accDataRcs = outdatcomplete; 
accSrate = srates; 
clear outdatcomplete srates; 
load(fullfile(params.dataDir,'DeviceSettings.mat'));
% figdir 
figdir = params.figdir;
ipadFn = params.ipadFn;
delsysFn = params.delsysFn;
dataDir = params.dataDir;

%%




%% alling and assign 
if exist(fullfile(dataDir,'ipad_allign_info.mat'),'file')
    load(fullfile(dataDir,'ipad_allign_info.mat'),'alligninfo','delsysForBeep');
else
    dbs5hzfieldname = 'DBS_5HZ_L_green2_EMG2_IM_';
    delsysForBeep.sound = dataraw.(dbs5hzfieldname);
    delsysForBeep.soundsrate = dataraw.srates.EMG;
    rcsraw.lfp = rcsDat.key0;
    rcsraw.ecog = rcsDat.key2;
    rcsraw.sr = unique(rcsSrate); % will be issue if more than one sampling rate
    rcsraw.sr = rcsraw.sr(1); 
    alligninfo = threshold_beep_finder(delsysForBeep,rcsraw);
    save(fullfile(dataDir,'ipad_allign_info.mat'),'alligninfo','delsysForBeep');
end
%% check how good allignemt is using acc data from delsys / rc+s as well as emg data 
hfig = figure; 
nmplt = 1; 
timeSubRCS = rcsDat.derivedTimes(alligninfo.ecogsync(1)); 
% plot rc+s 5hz 
hs(nmplt) = subplot(4,1,nmplt); nmplt = nmplt + 1; 
secUseRcs = seconds(seconds(rcsDat.derivedTimes - timeSubRCS))';
plot(secUseRcs,rcsDat.key0'); 
title('rc+s 5hz artifact - time domain'); 
% plot delsys 5hz emg 
hs(nmplt) = subplot(4,1,nmplt); nmplt = nmplt + 1; 
lenuse = size(dataraw.(dbs5hzfieldname),1) - 1; % since time starts at zero 
timeVecDelsys = seconds( (0:1:lenuse) ./ dataraw.srates.EMG); 
timeSubDelsys = timeVecDelsys(alligninfo.eegsync(1));
secUseDelsys = timeVecDelsys - timeSubDelsys; 
plot(secUseDelsys,dataraw.(dbs5hzfieldname));
title('delsys 5hz artifact - emg'); 
% plot rc+s acc 
hs(nmplt) = subplot(4,1,nmplt); nmplt = nmplt + 1; 
hold on; 
secUseRcsAcc = seconds(seconds(accDataRcs.derivedTimes - timeSubRCS)); 

plot(secUseRcsAcc,accDataRcs.XSamples - mean(accDataRcs.XSamples)); 
plot(secUseRcsAcc,accDataRcs.YSamples - mean(accDataRcs.YSamples)); 
plot(secUseRcsAcc,accDataRcs.ZSamples - mean(accDataRcs.ZSamples)); 
legend({'X','Y','Z'}); 
title('rc+s actigraphy'); 

% plot delsys 5hz acc  
hs(nmplt) = subplot(4,1,nmplt); nmplt = nmplt + 1; 
hold on; 
lenuse = size(dataraw.DBS_5HZ_L_green2_ACCX2_IM_,1) - 1; % since time starts at zero
timeVecDelsysAcc = seconds( (0:1:lenuse) ./ dataraw.srates.ACC);
secUseDelsys = timeVecDelsysAcc - timeSubDelsys;
plot(secUseDelsys,dataraw.DBS_5HZ_L_green2_ACCX2_IM_ - mean(dataraw.DBS_5HZ_L_green2_ACCX2_IM_));
plot(secUseDelsys,dataraw.DBS_5HZ_L_green2_ACCY2_IM_ - mean(dataraw.DBS_5HZ_L_green2_ACCY2_IM_));
plot(secUseDelsys,dataraw.DBS_5HZ_L_green2_ACCZ2_IM_ - mean(dataraw.DBS_5HZ_L_green2_ACCZ2_IM_));
legend({'X','Y','Z'}); 

title('delsys actigraphy'); 
linkaxes(hs,'x');
%%




%% check how good allignemt is using acc data from delsys / rc+s as well as emg data 
%% now plot using Delsys Hand actigraphy + rc+s Spectral plot 
hfig = figure; 
nmplt = 1; 
timeSubRCS = rcsDat.derivedTimes(alligninfo.ecogsync(1)); 
% plot rc+s 5hz 
hs(nmplt) = subplot(4,1,nmplt); nmplt = nmplt + 1; 
secUseRcs = seconds(seconds(rcsDat.derivedTimes - timeSubRCS))';
plot(secUseRcs,rcsDat.key0'); 
title('rc+s 5hz artifact - time domain'); 
% plot delsys 5hz emg 
fnmsDelsys = fieldnames(dataraw);
dbs5hzfieldname = fnmsDelsys{...
cellfun(@(x) any(regexpi(x,'dbs')), fnmsDelsys) & ...
cellfun(@(x) any(regexpi(x,'emg')), fnmsDelsys)};

hs(nmplt) = subplot(4,1,nmplt); nmplt = nmplt + 1; 
lenuse = size(dataraw.(dbs5hzfieldname),1) - 1; % since time starts at zero 
timeVecDelsys = seconds( (0:1:lenuse) ./ dataraw.srates.EMG); 
timeSubDelsys = timeVecDelsys(alligninfo.eegsync(1));
secUseDelsys = timeVecDelsys - timeSubDelsys; 
plot(secUseDelsys,dataraw.(dbs5hzfieldname));
title('delsys 5hz artifact - emg'); 
% plot rc+s acc 
hs(nmplt) = subplot(4,1,nmplt); nmplt = nmplt + 1; 
hold on; 
secUseRcsAcc = seconds(seconds(accDataRcs.derivedTimes - timeSubRCS)); 

plot(secUseRcsAcc',accDataRcs.XSamples - mean(accDataRcs.XSamples)); 
plot(secUseRcsAcc,accDataRcs.YSamples - mean(accDataRcs.YSamples)); 
plot(secUseRcsAcc,accDataRcs.ZSamples - mean(accDataRcs.ZSamples));
accDataRcsTemp = [accDataRcs.XSamples, accDataRcs.YSamples, accDataRcs.ZSamples];
procAccDataRcs = processActigraphyData(accDataRcsTemp, unique(accSrate));
legend({'X','Y','Z'}); 
title('rc+s actigraphy'); 
linkaxes(hs,'x');

% plot delsys 5hz emg 
hs(nmplt) = subplot(4,1,nmplt); nmplt = nmplt + 1; 
hold on; 
% find the correct fieldnames 
fnmsDelsys = fieldnames(dataraw);
fnmsAccDelsys = fnmsDelsys(...
cellfun(@(x) any(regexpi(x,'dbs')), fnmsDelsys) & ...
cellfun(@(x) any(regexpi(x,'acc')), fnmsDelsys));
for ff = 1:length(fnmsAccDelsys)
    lenuse = size(dataraw.(fnmsAccDelsys{ff}),1) - 1; % since time starts at zero
    timeVecDelsysAcc = seconds( (0:1:lenuse) ./ dataraw.srates.ACC);
    secUseDelsys = timeVecDelsysAcc - timeSubDelsys;
    plot(secUseDelsys,dataraw.(fnmsAccDelsys{ff}) - mean(dataraw.(fnmsAccDelsys{ff})));
    sizesDelsys(ff,1) = lenuse; 
end
% process delsys data 
if length( unique(sizesDelsys) ) > 1 
        accDataDelsys = [dataraw.(fnmsAccDelsys{1})(1:min(sizesDelsys)),...
        dataraw.(fnmsAccDelsys{1})(1:min(sizesDelsys)),...
        dataraw.(fnmsAccDelsys{1})(1:min(sizesDelsys))];

else
    accDataDelsys = [dataraw.(fnmsAccDelsys{1}),...
        dataraw.(fnmsAccDelsys{2}),...
        dataraw.(fnmsAccDelsys{3})];
end
procAccDataDelsys = processActigraphyData(accDataDelsys, dataraw.srates.ACC);

legend({'X','Y','Z'}); 

title('delsys actigraphy'); 
linkaxes(hs,'x');
%%





%% find beep indices in delsys time,convert to RC+S time and chop delsys + rc+s data to be equal 
timeDat = readIpadJson(ipadFn);
delsysForEvent.srate = dataraw.srates.trig;
fnmsDelsys = fieldnames(dataraw);
fnmsSoundDelsys = fnmsDelsys(...
cellfun(@(x) any(regexpi(x,'sound')), fnmsDelsys) ); 

delsysForEvent.Erg1 = dataraw.(fnmsSoundDelsys{1});
soundSecsDelsys = seconds(peakFinder(delsysForEvent)); % use peak finder to find sound in Delsys time. 
soundSecsDelsysRcsSync = soundSecsDelsys - timeSubDelsys; % subtract "sync time" from delsys. 
secsCut = [soundSecsDelsysRcsSync(1) - seconds(20)  soundSecsDelsysRcsSync(end) + seconds(20)];
% get data chunks from rc+s td data, acc and delsys 
% rcs
idxRcsTimeDomain = secUseRcs > secsCut(1) & secUseRcs < secsCut(2); % secsUseRcs already had time in seconds 
rcsIpadData = rcsDat(idxRcsTimeDomain,:); % turn this into duration in seconds 
dervTimes = rcsIpadData.derivedTimes; 
dervTimes = seconds(seconds(dervTimes - dervTimes(1) ));
rcsIpadData.derivedTimes = dervTimes; 
clear dervTimes
% rcs acc 
idxRcsTimeDomainAcc = secUseRcsAcc > secsCut(1) & secUseRcsAcc < secsCut(2); % secsUseRcs already had time in seconds 
rcsIpadAccData = accDataRcs(idxRcsTimeDomainAcc,:); % turn this into duration in seconds 
dervTimes = rcsIpadAccData.derivedTimes; 
dervTimes = seconds(seconds(dervTimes - dervTimes(1) ));
rcsIpadAccData.derivedTimes = dervTimes; 
% delsys 
fnms = fieldnames( dataraw ); 
delsysIpad = struct(); 
delsysIpad.srates = dataraw.srates; 
% cut delsys data structure to be all equal across different sample rates 
for f = 1:length(fnms)-1 % last value in structure is sample rates 
    if any(strfind(fnms{f},'trig'))
        srate = dataraw.srates.trig;
        fn = 'trig';
    elseif any(strfind(fnms{f},'EMG'))
        srate = dataraw.srates.EMG;
        fn = 'EMG';
    elseif any(strfind(fnms{f},'ACC'))
        srate = dataraw.srates.ACC;
        fn = 'ACC';
    elseif any(strfind(fnms{f},'Gyro'))
        srate = dataraw.srates.Gyro;
        fn = 'Gyro';
    elseif any(strfind(fnms{f},'Mag'))
        srate = dataraw.srates.Mag;
        fn = 'Mag';
    end
   secsRaw = seconds((0:1:size(dataraw.(fnms{f}),1)-1 ) ./srate) -  timeSubDelsys; 
   
   idxDelsys = secsRaw > secsCut(1) & secsRaw < secsCut(2); 
   delsysIpad.(fnms{f}) = dataraw.(fnms{f})(idxDelsys); 
   secsOut.(fn) = seconds((0:1:size(delsysIpad.(fnms{f}),1)-1)./srate); 
   clear secsRaw;
end


% run peak finder again to make sure it gives us updated second time for
% data chunk this is a quality control step 

delsysForEvent.srate = delsysIpad.srates.trig;
delsysForEvent.Erg1 = dataraw.(fnmsSoundDelsys{1});
soundSecsDelsys = seconds(peakFinder(delsysForEvent)); % use peak finder to find sound in Delsys time. 
% get events table in json time 
eventsTable = transformJsonDatToEEGidx(timeDat, dataraw.srates.trig ,seconds(soundSecsDelsys)); 

save(fullfile(dataDir,'ipadDataOffMeds.mat'),...
    'eventsTable','delsysForEvent',...
    'rcsIpadAccData','rcsIpadData',...
    'rcsSrate','accSrate','outRec',...
    'dataDir','figdir',...
    'delsysIpad');

%% plot verificaiton figure 
hfig = figure;
nmplt = 1;
nmrows = 4;
% plot delsys + sound 
hsub(nmplt) = subplot(nmrows,1,nmplt); nmplt = nmplt + 1; 
hold on; 
fnms = {'R_Hand_ACCX2_IM_','R_Hand_ACCY2_IM_','R_Hand_ACCZ2_IM_'}; 
for ff = 1:length(fnms)
    dat = delsysIpad.(fnms{ff}); 
    hplt = plot(secsOut.ACC, dat - mean(dat)); 
    hplt.LineWidth = 2; 
end
title('delsys right hand + sound'); 
ylims = hsub(nmplt-1).YLim; 
plot([soundSecsDelsys; soundSecsDelsys],repmat(ylims,size(soundSecsDelsys,2),1)',...
    'Color',[0.5 0.5 0.5 0.7],'LineWidth',2)
legend({'x','y','z','beep'}); 
set(gca,'FontSize',16); 
% plot delsys acc 
hsub(nmplt) = subplot(nmrows,1,nmplt); nmplt = nmplt + 1; 
hold on; 
fnms = {'DBS_5_Hz_ACCX1_IM_','DBS_5_Hz_ACCY1_IM_','DBS_5_Hz_ACCZ1_IM_'}; 
for ff = 1:length(fnms)
    dat = delsysIpad.(fnms{ff}); 
    hplt = plot(secsOut.ACC, dat - mean(dat)); 
    hplt.LineWidth = 1; 
end
title('delsys 5Hz DBS (over IPG)'); 
set(gca,'FontSize',16); 
% plot rc+s acc 
hsub(nmplt) = subplot(nmrows,1,nmplt); nmplt = nmplt + 1; 
hold on; 

fnms = {'XSamples','YSamples','ZSamples'}; 
for ff = 1:length(fnms)
    dat = rcsIpadAccData.(fnms{ff}); 
    hplt = plot(rcsIpadAccData.derivedTimes, dat - mean(dat)); 
    hplt.LineWidth = 1; 
end
title('rc+s actigraphy (should match delsys)'); 
set(gca,'FontSize',16); 
% plot rc+s spectrogram 
hsub(nmplt) = subplot(nmrows,1,nmplt); nmplt = nmplt + 1; 
rcsDatChunk = rcsIpadData.key3;
y = rcsDatChunk - mean(rcsDatChunk);
srate = unique(rcsSrate);
[s,f,t,p] = spectrogram(y,srate,ceil(0.6*srate),1:120,srate,...
    'yaxis','power');
surf(seconds(t), f, 10*log10(p), 'EdgeColor', 'none');
shading('interp');
view(2);
axis('tight');
xlabel('seconds');
ylabel('Frequency (Hz)');
title('rc+s M1 spectral plots'); 
set(gca,'FontSize',16); 


linkaxes(hsub,'x');




%% plot ipad data based on this alligmment 
timeparams.start_epoch_at_this_time    = -3000;%-8000; % ms relative to event (before), these are set for whole analysis
timeparams.stop_epoch_at_this_time     =  7000; % ms relative to event (after)
timeparams.start_baseline_at_this_time = -1000;%-6500; % ms relative to event (before), recommend using ~500 ms *note in the msns folder there is a modified version where you can set baseline bounds by trial (good for varible times, ex. SSD)
timeparams.stop_baseline_at_this_time  = -500;%5-6000; % ms relative to event
timeparams.extralines                  = 1; % plot extra line
timeparams.extralinesec                = 3000; % extra line location in seconds
timeparams.analysis                    = 'hold_center';
timeparams.filtertype                  = 'fir1' ; % 'ifft-gaussian' or 'fir1'

idxuse = cellfun(@(x) strcmp(x,'prep_ON'),eventsTable.label);
beepsInSeconds = seconds(eventsTable.eegtimestamp(idxuse));
rcsIdxs = ceil(seconds(beepsInSeconds).*unique(unique(rcsIpadData.samplerate))); 
pathadd = '/Users/roee/Starr_Lab_Folder/Data_Analysis/First_Pass_Data_Analysis/code/from_nicki';
addpath(genpath(pathadd));
rcsdat.lfp = rcsIpadData.key1; 
rcsdat.ecog = rcsIpadData.key3;
tdDat = outRec(1).tdData;
for c = 1:4  
    cnmIpadData = sprintf('key%d',c-1);
    cnm = sprintf('chan%d',c); 
    rcsIpadDataPlot.(cnm) = rcsIpadData.(cnmIpadData);
    rcsIpadDataPlot.([cnm 'Title']) = tdDat(c).chanFullStr;
end
rcsIpadDataPlot.numChannels = 4; 
plot_ipad_data_rcs_json(rcsIdxs,rcsIpadDataPlot,unique(rcsSrate),figdir,timeparams)
rmpath(genpath(pathadd));


%% 

%% plot ipad data in frequency domain 

params.labelfind = {'rest_ON','prep_ON','touch1_OFF'} ; % labels to start on 
colorsuse        = {'r','g','b'};
params.colorsuse = colorsuse; 
params.timebefr  = ceil([0 0 0].* unique(rcsSrate)); % start time 
params.timeaftr  = ceil([2 1 4].*unique(rcsSrate)); % end time 
areasuse = {'lfp','ecog'};
windowsize = 256;
params.windowsize = windowsize;
params.leglines = {'hold', 'prep','move'};
areasuse = {'key0','key1','key2','key3'}; 

clear fftOut res fftuse leglines
hfig = figure; 
for a = 1:length(areasuse)
    hsub(a) = subplot(2,2,a);
    title(outRec.tdData(a).chanFullStr);
    hold on;
    for ll = 1:length(params.labelfind)
        idx = cellfun(@(x) strcmp(x,params.labelfind{ll}),eventsTable.label);
        beepsInSeconds = seconds(eventsTable.eegtimestamp(idx));
        rcsIdxs = ceil(seconds(beepsInSeconds).*unique(unique(rcsIpadData.samplerate)));
        rcsIdxs = rcsIdxs(~isnan(rcsIdxs));
        rcsIdxs = rcsIdxs(~isnan(rcsIdxs));
        rcsIdxs = rcsIdxs(1:end-2); 
        for i = 1:length(rcsIdxs)
            sampleidx = [rcsIdxs(i) + params.timebefr(ll) : 1 : rcsIdxs(i) + params.timeaftr(ll)];
            dat = rcsIpadData.(areasuse{a})(sampleidx);
            if sum(dat) ~= 0
                [fftOut,f]   = pwelch(dat,windowsize,ceil(windowsize*0.875),6:2:200,unique(rcsSrate),'psd');
                fftuse(i,:)  = log10(fftOut);
            end
        end
        if sum(dat) ~= 0
            res.(areasuse{a}).(params.labelfind{ll}) = fftuse;
            hsb = shadedErrorBar(f,fftuse,{@mean,@(x) std(x)./sqrt(size(x,1))} );
            hsb.mainLine.Color = colorsuse{ll};
            hsb.mainLine.LineWidth = 3;
            hsb.patch.FaceColor = colorsuse{ll};
            leglines(ll) = hsb.mainLine;
            legend(leglines,{'hold', 'prep','move'});

        else
            res.(areasuse{a}).(params.labelfind{ll}) = [];
        end
        hold on;
        clear fftOut;
    end
    ylabel('Power  (log_1_0\muV^2/Hz)');
    xlabel('Frequency (Hz)');
    axis tight;
    set(gca,'FontSize',16);
end
linkaxes(hsub,'x');

clear params

params.figname = 'rcs plot json movement related'; 
params.figdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/presentations/figures';
params.figtype = '-djpeg';
plot_hfig(hfig,params)






end