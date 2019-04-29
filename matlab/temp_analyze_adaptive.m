%% start up
close all;
clear all;
clc;

params.delsysFn   = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v18_adaptive_month5/delsys/RCS01_03-25-19_closedloop_onmeds_onstim_Plot_and_Store_Rep_1.0.csv.mat';
params.vidFn      = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v10-3-month/vids/MVI_0266.MP4';
params.rcsTdFn    = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v18_adaptive_month5/all_rcs_data/Session1553549911973/DeviceNPC700395H/RawDataTD.mat';
params.rcsAccFn   = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v18_adaptive_month5/all_rcs_data/Session1553549911973/DeviceNPC700395H/RawDataAccel.mat';
params.rcsEvntFn  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v18_adaptive_month5/all_rcs_data/Session1553549911973/DeviceNPC700395H/EventLog.mat';
params.rcsDvcStFn = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v18_adaptive_month5/all_rcs_data/Session1553549911973/DeviceNPC700395H/DeviceSettings.mat';
params.drivingTm  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v10-3-month/delsys_driving/driving_start_stop_times_off_stim.csv';

diruse            = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v18_adaptive_month5/all_rcs_data/Session1553549911973/DeviceNPC700395H/';
fnAdaptive = fullfile(diruse,'AdaptiveLog.json'); 
[outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerTable] =  MAIN_load_rcs_data_from_folder(diruse);
res = readAdaptiveJson(fnAdaptive); 

% for plotting video 
params.vidStart = 2.636; % this is without subtractions
params.delsysStart = seconds(76.811); % this is where first pressure pulse starts

params.framewidth = seconds(10); % in seconds
params.startFrame = params.delsysStart;
%% load delsys
load(params.delsysFn);

%% load RCS stuff
load(params.rcsTdFn);
rcsDat = outdatcomplete;
clear outdatcomplete;
load(params.rcsAccFn);
rcsDatAcc = outdatcomplete;
load(params.rcsEvntFn);
load(params.rcsDvcStFn);
hfig1 = figure;
% below should be commentd out on first run
correctNums = 1;
if correctNums
    params.delsys5Hz = seconds(125.6769);
    params.rcs5Hz    = rcsDat.derivedTimes(78603);
else
    params.delsys5Hz = seconds(0);
    params.rcs5Hz    = seconds(0);
end


% plot delsys
hsub(1) = subplot(2,1,1);
y = dataraw.DBS_5HZ_green1_EMG1_IM_;
secs = seconds((0:1:length(y )-1 )./dataraw.srates.EMG)-params.delsys5Hz;
plot(secs',y,'LineWidth',2);
title('delsys');
% plot rcs
hsub(2) = subplot(2,1,2);
y = rcsDat.key0;
secs = rcsDat.derivedTimes-params.rcs5Hz;
plot(secs,y,'LineWidth',2);
title('rcs');
linkaxes(hsub,'x');

%% verify allignement with acc 
% plot delsys acc 
hfig = figure; 
haxDelAcc = subplot(2,1,1); 
haxRcsAcc = subplot(2,1,2); 

axes(haxDelAcc); 
hold on; 
xx = dataraw.DBS_5HZ_green1_ACCX1_IM_;
yy = dataraw.DBS_5HZ_green1_ACCY1_IM_;
zz = dataraw.DBS_5HZ_green1_ACCZ1_IM_;
secs = seconds((0:1:length(xx )-1 )./dataraw.srates.ACC)-params.delsys5Hz; 
plot(haxDelAcc,secs',xx-mean(xx),'LineWidth',2);
plot(haxDelAcc,secs',yy-mean(yy),'LineWidth',2);
plot(haxDelAcc,secs',zz-mean(zz),'LineWidth',2);
title('delsys acc'); 
ylimsDelsysAcc = get(haxDelAcc,'YLim'); 

% plot rcs acc 
axes(haxRcsAcc); 
hold on; 
xx = rcsDatAcc.XSamples;
yy = rcsDatAcc.YSamples;
zz = rcsDatAcc.ZSamples;
secs = seconds( seconds ( rcsDatAcc.derivedTimes - params.rcs5Hz) ); 
plot(haxRcsAcc,secs,xx-mean(xx),'LineWidth',2);
plot(haxRcsAcc,secs,yy-mean(yy),'LineWidth',2);
plot(haxRcsAcc,secs,zz-mean(zz),'LineWidth',2);
title('rcs acc'); 
ylimsRcsAcc = get(haxRcsAcc,'YLim'); 

linkaxes([haxDelAcc, haxRcsAcc],'x'); 

%% plot adaptive first past 
hfig = figure; 
nmplt = 1;
ncols = 1;
nrows = 5;  
hsub(nmplt) = subplot(nrows,ncols,nmplt); nmplt = nmplt + 1; % 1 delsys acc 
hsub(nmplt) = subplot(nrows,ncols,nmplt); nmplt = nmplt + 1; % 2 rcs acc 
hsub(nmplt) = subplot(nrows,ncols,nmplt); nmplt = nmplt + 1; % 3 rcs spectrum
hsub(nmplt) = subplot(nrows,ncols,nmplt); nmplt = nmplt + 1; % 4 adaptive ld0 + thresh + state
hsub(nmplt) = subplot(nrows,ncols,nmplt); nmplt = nmplt + 1; % 5 gyro r hand 

% 1 delsys acc 
haxDelAcc = hsub(1); 
axes(haxDelAcc); 
hold on; 
xx = dataraw.DBS_5HZ_green1_ACCX1_IM_;
yy = dataraw.DBS_5HZ_green1_ACCY1_IM_;
zz = dataraw.DBS_5HZ_green1_ACCZ1_IM_;
secs = seconds((0:1:length(xx )-1 )./dataraw.srates.ACC)-params.delsys5Hz; 
plot(haxDelAcc,secs',xx-mean(xx),'LineWidth',2);
plot(haxDelAcc,secs',yy-mean(yy),'LineWidth',2);
plot(haxDelAcc,secs',zz-mean(zz),'LineWidth',2);
title('delsys acc'); 
ylimsDelsysAcc = get(haxDelAcc,'YLim'); 

% 2 rcs acc 
haxRcsAcc = hsub(2); 
axes(haxRcsAcc); 
hold on; 
xx = rcsDatAcc.XSamples;
yy = rcsDatAcc.YSamples;
zz = rcsDatAcc.ZSamples;
secs = seconds( seconds ( rcsDatAcc.derivedTimes - params.rcs5Hz) ); 
plot(haxRcsAcc,secs,xx-mean(xx),'LineWidth',2);
plot(haxRcsAcc,secs,yy-mean(yy),'LineWidth',2);
plot(haxRcsAcc,secs,zz-mean(zz),'LineWidth',2);
title('rcs acc'); 
ylimsRcsAcc = get(haxRcsAcc,'YLim'); 

% 3 rcs spectrum
haxRcsSpect = hsub(3); 
axes(haxRcsSpect); 
hold on;
y = rcsDat.key2;
y = y -mean(y); 
srate = unique(rcsDat.samplerate); 
[s,f,t,p] = spectrogram(y,srate,ceil(0.875*srate),1:120,srate,'yaxis','psd');
% zp = zscore(p); 
% pscaled = abs(p)./abs(repmat(mean(p,2),1,size(p,2)));
% pcolor(t, f,zscore(p))
deltaSubtract = abs(rcsDat.derivedTimes(1) - params.rcs5Hz);
secs = seconds(t)-deltaSubtract; 
surf(secs, f, 10*log10(p), 'EdgeColor', 'none');
% sh = surf(t,f,p);
% caxis([-2.5 2.5]); 
view(0, 90)
axis tight
shading interp 
xlabel('seconds');
ylabel('Frequency (Hz)');
view(2); 
title('M1 RCS'); 

% 4 adaptive ld0 + thresh 

haxAdaptive = hsub(4); 
axes(haxAdaptive); 
hold on; 
uxtimes = datetime(res.timing.PacketRxUnixTime/1000,...
    'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
uxtimes = uxtimes - params.rcs5Hz; 
adaptive = res.adaptive; 
fnmsPlot = {'LD0_highThreshold','LD0_lowThreshold'};
nrows = length(fnmsPlot); 
for f = 1:length(fnmsPlot)
    hplt = plot(haxAdaptive,uxtimes',adaptive.(fnmsPlot{f}));
    for h = 1:length(hplt)
        hplt.LineWidth = 3;
        hplt.LineStyle = '-.';
%         hplt(h).Color = [0 0 0.8 0.7];
    end
%     ttluse = strrep(fnmsPlot{f},'_',' ');
%     title(ttluse); 
end

fnmsPlot = {'CurrentAdaptiveState','CurrentProgramAmplitudesInMilliamps','LD0_output','Ld0DetectionStatus'};
fnmsPlot = {'LD0_output','Ld0DetectionStatus'};
nrows = length(fnmsPlot); 
for f = 1:length(fnmsPlot)
    if strcmp(fnmsPlot{f},'Ld0DetectionStatus')
        y = adaptive.(fnmsPlot{f})./100;
    else
        y = adaptive.(fnmsPlot{f});
    end
    if size(y,1) == 4
        y = y(1,:);
    end
    hplt = plot(uxtimes,y);
    for h = 1:length(hplt)
        hplt.LineWidth = 3;
%         hplt(h).Color = [0 0 0.8 0.7];
    end
%     ttluse = strrep(fnmsPlot{f},'_',' ');
%     title(ttluse); 
end


% 5 gyro r hand 
haxDelAcc = hsub(5); 
axes(haxDelAcc); 
hold on; 
xx = dataraw.R_hand_green2_GyroX2_IM_;
yy = dataraw.R_hand_green2_GyroY2_IM_;
zz = dataraw.R_hand_green2_GyroZ2_IM_;
secs = seconds((0:1:length(xx )-1 )./dataraw.srates.ACC)-params.delsys5Hz; 
plot(haxDelAcc,secs',xx-mean(xx),'LineWidth',2);
plot(haxDelAcc,secs',yy-mean(yy),'LineWidth',2);
plot(haxDelAcc,secs',zz-mean(zz),'LineWidth',2);
title('right hand gyro'); 
ylimsDelsysAcc = get(haxDelAcc,'YLim'); 


linkaxes(hsub,'x'); 

return 


%% load event times
rcsStartStopTimes = readtable(params.drivingTm); % these are times after 5Hz was subtracted

%% plot spectral chunks of data
% chanls rec from
params.time_before = seconds(10);
params.time_after  = seconds(10);

prfig.plotwidth           = 10;
prfig.plotheight          = 18; 
prfig.figdir              = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v10-3-month/figures';
prfig.figtype             = '-djpeg';
prfig.closeafterprint     = 1; 
prfig.resolution          = 300; 

searchStrings{1} = 'DBS_5Hz_1_ACC';
searchStrings{2} = 'R_hand_2_Gyro';
ttls             = {'delsys acc dbs','delsys gyro r hand'};


% get delsys data
st = dataraw;
for s = 1 :length(searchStrings)
    fldnms   = fieldnames(st);
    searchSt = searchStrings{s};
    idxuse = find(cellfun(@(x) any(strfind(x,searchSt)),fldnms)==1);
    % get data
    for i = 1:length(idxuse)
        tmp = st.(fldnms{idxuse(i)});
        xx(s,i,:) = tmp - mean(tmp);
        secsDelsys(s,i,:) = seconds((0:1:length(xx )-1 )./dataraw.srates.ACC)-params.delsys5Hz;
    end
end

for c = 1:4
    fnmuse = sprintf('key%d',c-1);
    ttluse = sprintf('stopping %s',outRec.tdData(c).chanFullStr);
    prfig.figname = sprintf('starting_high_gamma60-200%d',c);
    
    y = rcsDat.(fnmuse);
    y = y -mean(y);
    % get spectrla data
    srate = unique(rcsDat.samplerate);
    [s,f,t,p] = spectrogram(y,srate,ceil(0.875*srate),1:200,srate,'yaxis','psd');
    % zp = zscore(p);
    % pscaled = abs(p)./abs(repmat(mean(p,2),1,size(p,2)));
    % pcolor(t, f,zscore(p))
    deltaSubtract = abs(rcsDat.derivedTimes(1) - params.rcs5Hz);
    secs = seconds(t)-deltaSubtract;
    % plot delsys data
    
    

    % plot
    
    hfig = figure;
    
    nrows = size(rcsStartStopTimes,1);
    pavg = [];
    for s = 1:size(rcsStartStopTimes,1)
        % plot rc+s data
        hsub(s) = subplot(nrows,1,s);
        hold on;
        stop_time = seconds(rcsStartStopTimes.rcs_acc_stop(s));
        idxUse = secs > (stop_time - params.time_before) & secs < (stop_time + params.time_after);
        % save datsa for averaging - since it is spectral data, compute
        % points 
        interPointDur = mean(diff(secs));
        datPoints = ceil(params.time_before/interPointDur); 
        [~, indexPoint] = min(abs(secs-stop_time));
        res.(fnmuse)(:,:,s) = 10*log10(p(:,indexPoint - datPoints : indexPoint + datPoints )); 

        % plot 
        surf(secs(idxUse), f, 10*log10(p(:,idxUse)), 'EdgeColor', 'none');
        ylims = get(hsub(s),'YLim');
        plot([stop_time stop_time],ylims,'LineWidth',2,'Color',[0.2 0.2 0.2 0.5]);
        view(0, 90)
        axis tight
        shading interp
        % plot delsys data overlayd
        yyaxis right
        secsDel = squeeze(secsDelsys(2,1,:)) ; % 5 hz acc
        idxUse = secsDel > (stop_time - params.time_before) & secsDel < (stop_time + params.time_after);
        plot(secsDel(idxUse),squeeze(xx(1,:, idxUse)) ,'LineWidth',2,'Color',[0.2 0.2 0.2 0.15]);
    end
    suptitle(ttluse);
    % save figure
%     plot_hfig(hfig,prfig); 
end

%% plot averages 
prfig.figname = sprintf('starting_high_gamme_avg60-200_test');
prfig.plotwidth           = 15;
prfig.plotheight          = 15; 
badTrials                 = 10; 
hfig = figure;
for c = 1:4
    fnmuse = sprintf('key%d',c-1);
    subplot(2,2,c); 
    hold on; 
    ttluse = sprintf('stopping avg %s',outRec.tdData(c).chanFullStr);
    idxkeep = setxor(1:size(res.(fnmuse),3),badTrials); % keep everythign but bad trials 
    pToAvg = res.(fnmuse)(:,:,idxkeep);
    pavg = mean(pToAvg,3);
    pavgRescale = rescale(pavg,0,1); 
    % z score the results and subtract mean 
    idxmiddle = ceil(size(pavg,2)/2);
    idxmiddle = ceil(idxmiddle/2); 
    meanVec   = mean(pavgRescale(:,1:idxmiddle),2);
    divVec    = repmat(meanVec,1,size(pavg,2));
    zscoreMat = pavgRescale./divVec;
    % XX 
%     surf(1:size(pavg,2), f, pavgRescale, 'EdgeColor', 'none');
    surf(1:size(pavg,2), f, zscoreMat, 'EdgeColor', 'none');
    % XX 
    ylims = get(gca,'YLim');
    idxLine = ceil(size(pavg,2)/2);
    plot([idxLine idxLine],ylims,'LineWidth',2,'Color',[0.2 0.2 0.2 0.5]);
    view(0, 90)
    title(ttluse); 
    axis tight
    shading interp
    
end
% plot_hfig(hfig,prfig);



