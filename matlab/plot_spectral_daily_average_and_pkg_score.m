% function plot_spectral_daily_average_and_pkg_score(varargin)
% this function looks into 1 patient side at a time
% it asks the user to select the day based on RCS existing database
% for that day it will create a spectrogram of neural data (discontinuous)
% and it will pair a PKG physical score (tremor, bradykinesia or diyskinesia)

% dependencies
% https://github.com/openmind-consortium/Analysis-rcs-data

%% additional libraires and toolboxes
addpath(fullfile(pwd,'toolboxes','panel-2.14'));
addpath('/Users/juananso/Dropbox (Personal)/Work/Git_Repo/UCSF-rcs-data-analysis/code')

%% data selection PKG data day
% find Box directory
boxDir = findFilesBVQX('/Users','Box',struct('dirs',1,'depth',2));
pkgDB_location = fullfile(boxDir{1},'RC-S_Studies_Regulatory_and_Data','pkg_data','results','processed_data');
load(fullfile(pkgDB_location,'pkgDataBaseProcessed.mat'),'pkgDB');

% select day
timeBefore = datetime('2019-06-19');
timeAfer =   datetime('2019-06-27');
actualDate = datetime('2019-06-21');
patidx = 'RCS03';

% select side seperatly
sideRCS = {'L'}; % these sides refer to RC+S 
sidePKG = {'R'}; % you need contralateral sides for PKG 
for sd = 1:length(sideRCS)
    
    %% create one big pkg table 
    % get subject and side 
    idxpkgdb = strcmp(pkgDB.patient,patidx) & ... 
                strcmp(pkgDB.side,sidePKG{sd}); 
    posPKGs  = pkgDB(idxpkgdb,:);
    % filter on dates 
    idxdatespos = posPKGs.timerange(:,1) >= timeBefore & ... 
              posPKGs.timerange(:,2) <= timeAfer;
          
    pkgDBuse = posPKGs(idxdatespos,:);
    
    pkgBigTable = table();
    for pk = 1:size(pkgDBuse)
        ff = findFilesBVQX(pkgDB_location,pkgDBuse.savefn{pk});
        load(ff{1},'pkgTable');
        if pk == 1 
            pkgBigTable = pkgTable; 
        else
            pkgBigTable = [pkgBigTable ; pkgTable];
        end
        clear pkgTable; 
    end
    pkgTable = sortrows(pkgBigTable,'Date_Time');
    idxDay = find(pkgTable.Date_Time <= actualDate+1 & pkgTable.Date_Time >= actualDate);
    pkgTableDay = pkgTable(idxDay(1:end-1),:);
end

%% 
% set destination folders
dropboxFolder = findFilesBVQX('/Users','Starr Lab Dropbox',struct('dirs',1,'depth',2));
if length(dropboxFolder) == 1
    dirname  = fullfile(dropboxFolder{1}, 'RC+S Patient Un-Synced Data');
    rootdir = fullfile(dirname,'database');
else
    error('can not find dropbox folder, you may be on a pc');
end

% localize dataset from overall database
load(fullfile(rootdir,'database_from_device_settings.mat'),'masterTableLightOut');
masterTableOut = masterTableLightOut;
idxkeep = cellfun(@(x) any(strfind(x,'RCS')), masterTableOut.patient);
tblall =  masterTableOut(idxkeep,:);
idxPatient = strcmp(tblall.patient ,patidx);
tblPatient = tblall(idxPatient,:);
idxSide = strcmp(tblPatient.side,sideRCS);
tblSide = tblPatient(idxSide,:);
tblSide = sortrows(tblSide,'timeStart');
timeStart = tblSide.timeStart;
actualDate = datetime(actualDate,'TimeZone','local');
idxDay = find(tblSide.timeStart >= actualDate & tblSide.timeStart < actualDate + 1);
tblDay = tblSide(idxDay,:);

idxLonger = tblDay.duration > minutes(20);

if sum(idxLonger) == 0
    warning('no session is longer than 20 minutes, exiting for this day\n');
    fprintf('no session is longer than 20 minutes, exiting for this day\n');
    return;
end

tblPatient = tblDay(idxLonger,:)


%%
outSpectral = table();

[pn,fn] = fileparts(tblPatient.deviceSettingsFn{1});
idxdatapn = pn(findstr(pn,'Starr Lab Dropbox'):end);
pn = findFilesBVQX('/Users',idxdatapn,struct('dirs',1,'depth',2));
pn = pn{1}; % convert struct to string array
% plot_spectral_new_demo_process(pn);

[combinedDataTable, debugTable, timeDomainSettings,powerSettings,...
    fftSettings,metaData,stimSettingsOut,stimMetaData,stimLogSettings,...
    DetectorSettings,AdaptiveStimSettings,AdaptiveRuns_StimSettings] = DEMO_ProcessRCS(pn,2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% load time domain
idxuse = logical(ones(size(combinedDataTable,1),1));
dataOutFilled = [];
for c = 1:4 % loop on channels
    chanfn = sprintf('TD_key%d',c-1);
    sr = timeDomainSettings.samplingRate(1); % assumes no change in session
    chunkUse = combinedDataTable.(chanfn)(idxuse);
    y = chunkUse - nanmean(chunkUse);
    y = y.*1e3;
    % first make sure that y does'nt have NaN's at start or
    % end which makes finding gaps easier 
    timeUseRaw = combinedDataTable.localTime;
    % check start:
    cntNan = 1;
    if isnan(y(1))
        while isnan(y(cntNan))
            cntNan = cntNan + 1;
        end
    end
    y = y(cntNan:end);
    cntStart = cntNan;
    timeUseRaw = timeUseRaw(cntNan:end);
    % check end:
    cntNan = length(y);
    if isnan(y(cntNan))
        while isnan(y(cntNan))
            cntNan = cntNan - 1;
        end
    end
    cntEnd = cntNan;
    y = y(1:cntEnd);
    timeUseNoNans = timeUseRaw(1:cntEnd);
    % fill the NaN's with zeros 
    yFilled = fillmissing(y,'constant',0);
    dataOutFilled(:,c) = yFilled;
end
%% compute spectrogram 
% set params. 
params.windowSize     = 256;  % spect window size 
params.windowOverlap  = ceil(256*0.875);   % spect window overalp (points) 
params.paddingGap     = seconds(1); % padding to add to window spec
params.windowUse       = 'hann'; % blackmanharris \ kaiser \ hann
outSpectral = struct();
for i = 1:4 
    % blank should be bigger than window on each side 
    windowInSec = seconds(256/sr);
    switch params.windowUse
        case 'kaiser'
            windowUse = kaiser(params.windowSize,2);
        case 'blackmanharris'
            windowUse = blackmanharris(params.windowSize); 
        case 'hann'
            L = params.windowSize; 
            windowUse = 0.5*(1-cos(2*pi*(0:L-1)/(L-1)));
%             hann(params.windowSize); 
    end
    [sss,fff,ttt,ppp] = spectrogram(dataOutFilled(:,i),...
                                    windowUse,...
                                    params.windowOverlap,...
                                    256,sr,'yaxis');
    % put nan's in gaps for spectral
    spectTimes = timeUseNoNans(1) + seconds(ttt);
    idxGapStart = find(diff(isnan(y))==1) + 1;
    idxGapEnd = find(diff(isnan(y))==-1) + 1;
    for te = 1:size(idxGapStart,1)
        timeGap(te,1) = timeUseNoNans(idxGapStart(te)) - (windowInSec + params.paddingGap);
        timeGap(te,2) = timeUseNoNans(idxGapEnd(te))   + (windowInSec + params.paddingGap);
        idxBlank = spectTimes >= timeGap(te,1) & spectTimes <= timeGap(te,2);
        ppp(:,idxBlank) = NaN;
    end
    if i == 1
        fnchan = sprintf('chan%d',i);
        outSpectral.spectTimes = spectTimes;
        outSpectral.fff = fff;
    end
    chanfn = sprintf('chan%d',i);
    outSpectral.(chanfn) = ppp';
end
%%
% plot spectrogram with different values of NaN
% plotting params 
params.removeGaps     = 0; % if 1 remove gaps, otherwise, keep gaps 
params.guassianFit    = 1; % fit a guassian to image for smoothing 
params.zScore         = 1; % zscore each frequecny 
params.smooth         = 2e2;    % smoothing (in points in "spect" domain") 
params.cnls           = [1 2 3 4]; 
params.plotTD         = 0; % plot time domai n
if params.plotTD == 1 
    nrows = (length(params.cnls)*2)+1; 
else
    nrows = length(params.cnls)+1;  
end
close all; 
hfig = figure;
hfig.Color = 'w'; 
hpanel = panel();
hpanel.pack(nrows,1); 
cntplt = 1; 
for cc = 1:length(params.cnls)
    c = cntplt; 
    timesOutSpectral = outSpectral.spectTimes;
    % plot time domain
    if params.plotTD
        hsb(cntplt,1) = hpanel(cntplt,1).select();
        y = dataOutFilled(:,params.cnls(cc));
        x = timeUseNoNans;
        plot(linspace(1,length(timeUseNoNans),length(x)) ,y,'Parent',hsb(cntplt,1));
        xlims = [1 length(timeUseNoNans)];
        hsb(c,1).XTick = floor(linspace(xlims(1), xlims(2),20));
        xticks = hsb(c,1).XTick;
        xticklabels = {};
        for xx = 1:length(xticks)
            timeUseXtick = timeUseNoNans(xticks(xx));
            timeUseXtick.Format = 'HH:mm';
            xticklabels{xx,1} = sprintf('%s',timeUseXtick);
            timeUseXticksOut(xx) = timeUseXtick;
        end
        axis tight
        ylim([-100 100])
        ylabel('TD (uVolt)')
        hsb(c,1).XTickLabel = xticklabels;
        hsb(c,1).XTickLabelRotation = 45;
        title(hsb(c,1), timeDomainSettings.(cnhafn));
        cntplt = cntplt + 1;
    end
    c = cntplt; 
    % plot spdctral 
    hsb(cntplt,1) = hpanel(cntplt,1).select();
    cntplt = cntplt + 1;
    timesOutForPlot = outSpectral.spectTimes;
    cnhafn = sprintf('chan%d',params.cnls(cc));
    pptOutDay = outSpectral.(cnhafn);
    if params.removeGaps
        idxnan = isnan(pptOutDay(:,1));
        pptOutDay = pptOutDay(~idxnan,:); 
        timesOutForPlot = timesOutForPlot(~idxnan);
    end
    if params.guassianFit% previous way of doing this - with just gaussing bluring
        IblurY2 = imgaussfilt(pptOutDay,[1 15]);
        him = imagesc(log10(IblurY2'));
    end
    % smooth data - with trailingedge 
%     pptOutDaySmooth = movmean(pptOutDay,[params.smooth 0],'omitnan');
%     pptOutDaySmooth = pptOutDaySmooth';
    if params.zScore
        % implement zscore to be robost to nan's: 
        P = pptOutDay; 
        P = movmean(P,[params.smooth 0],'omitnan');
        meanMatrix = repmat(nanmean(P,1),size(P,1),1);
        stdMatrx   = repmat(nanstd(P,1),size(P,1),1);
        zScoreData = (P - meanMatrix) ./ stdMatrx;
        % identify gaps before smoothing 
        imAlpha=ones(size(P'));
        imAlpha(isnan(P'))=0;
%         zScoreData = movmean(zScoreData,[params.smooth 0],'omitnan');
        imagesc(zScoreData','AlphaData',imAlpha);
        caxis([-2 2]);
    end
    set(gca,'YDir','normal')
    yticks = [4 12 30 50 60 65 70 75 80 100];
    tickLabels = {};
    ticksuse = [];
    for yy = 1:length(yticks)
        [~,idx] = min(abs(yticks(yy)-fff));
        ticksuse(yy) = idx;
        tickLabels{yy} = sprintf('%d',yticks(yy));
    end
    hsb(c,1) = gca;
    hsb(c,1).YTick = ticksuse;
    hsb(c,1).YTickLabel = tickLabels;
    % get time labels for x tick
    colormap(hsb(c,1),'jet');
    shading interp
    grid('on')
    hsb(c,1).GridAlpha = 0.8;
    hsb(c,1).Layer = 'top';
    axis tight
    ylabel('Frequency (Hz)');
    xlims = [1 length(timesOutForPlot)];
    hsb(c,1).XTick = floor(linspace(xlims(1), xlims(2),20));
    xticks = hsb(c,1).XTick;
    xticklabels = {};
    for xx = 1:length(xticks)
        timeUseXtick = timesOutForPlot(xticks(xx));
        timeUseXtick.Format = 'HH:mm';
        xticklabels{xx,1} = sprintf('%s',timeUseXtick);
        timeUseXticksOut(xx) = timeUseXtick;
    end
    hsb(c,1).XTickLabel = xticklabels;
    hsb(c,1).XTickLabelRotation = 45;
    title(hsb(c,1), timeDomainSettings.(cnhafn));
end
% linkaxes(hsb,'x');

%% Intersecting PKG points with neural data
data_format = 'dd-mmm-yyyy HH:MM:SS';
%% Convert to datestr
pkgTimes = datetime(pkgTableDay.Date_Time,'TimeZone','local');
date_str_U = datestr(pkgTimes);
date_str_C = datestr(timesOutForPlot);
%% convert to datenum
date_num_U = datenum(date_str_U,data_format);
date_num_C = datenum(date_str_C,data_format);
% C = A(ia) and C = B(ib).
[C,ia,ib] = intersect(date_num_U,date_num_C);
% to get the dates back:
pkgTimes2 = datetime(date_num_U(ia),'ConvertFrom','datenum');
pkgTimes2 = datetime(pkgTimes2,'TimeZone','local');


c = 5;
hsb(c,1) = hpanel(c,1).select();
[C,ia,ib] = intersect(pkgTimes,pkgTimes2);
axis tight
pkgTimesXnums = linspace(1,length(pkgTimes2),length(pkgTimes2));

% tremor
plot(pkgTimesXnums,smooth(pkgTableDay.Tremor_Score(ia)/max(pkgTableDay.Tremor_Score(ia))),'LineWidth',2,'color','b')
hold on
% plot(pkgTimesXnums,pkgTableDay.Tremor(ia),'LineWidth',2,'color','k')
hold on
% BK
plot(pkgTimesXnums,smooth(abs(pkgTableDay.BK(ia))/max(abs(pkgTableDay.BK(ia)))),'LineWidth',2,'color','r')

xlims2 = [1 length(pkgTimes2)];
hsb(c,1).XTick = floor(linspace(xlims2(1), xlims2(2),20));
xticks = hsb(c,1).XTick;
xticklabels = {};
for xx = 1:length(xticks)
    timeUseXtick = pkgTimes2(xticks(xx));
    timeUseXtick.Format = 'HH:mm';
    xticklabels{xx,1} = sprintf('%s',timeUseXtick);
    timeUseXticksOut(xx) = timeUseXtick;
end
hsb(c,1).XTickLabel = xticklabels;
hsb(c,1).XTickLabelRotation = 45;
ylabel('PKG scores (normalized untis 0,1)');
legend(hsb(c,1),'tremor score','BK')
% linkaxes(hsb,'x');