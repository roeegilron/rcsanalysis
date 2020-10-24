function plot_log_data()
%%
rootdir = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/RCS06 Un_Synced Data/SummitData/SummitContinuousBilateralStreaming/RCS06R';
ff = findFilesBVQX(rootdir,'LogData*',struct('dirs',1));
dsOut = table(); 
for f = 1:length(ff)
    [pn,fn] = fileparts(ff{f}); 
    deviceJsonFn = fullfile(pn,'DeviceSettings.json'); 
    dsOut(f,:) = get_meta_data_from_device_settings_file(deviceJsonFn);
end 
for f = 1:length(ff)
    dsOut.LogFolder{f} = ff{f};
end


%% find data from april 28th
idxuse = day(dsOut.timeStart) == 28 & ...
month(dsOut.timeStart) == 4 & ...
year(dsOut.timeStart) == 2020;
dsDate = dsOut(idxuse,:);

%% find logs
hfig = figure; 
for d = 1:size(dsDate,1)
    ftf = findFilesBVQX( dsDate.LogFolder{d},'*LOG.txt');
    adaptiveLogTable = read_adaptive_txt_log(ftf{1});
    %% load adaptive data
    [devdir,~]  = fileparts(dsDate.deviceSettingsFn{d});
    fnAdaptive = fullfile(devdir,'AdaptiveLog.json');
    fnDeviceSettings = dsDate.deviceSettingsFn{d};
%     ds = get_meta_data_from_device_settings_file(fnDeviceSettings);
%     str = getAdaptiveHumanReadaleSettings(ds);
    mintrim = 10;
    
    % load adapative 
    res = readAdaptiveJson(fnAdaptive);
    currentTimeSeries = res.adaptive.CurrentProgramAmplitudesInMilliamps(1,:);
    timestamps = datetime(datevec(res.timing.timestamp./86400 + datenum(2000,3,1,0,0,0))); % medtronic time - LSB is seconds
    uxtimes = datetime(res.timing.PacketGenTime/1000,...
        'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
    yearUse = mode(year(uxtimes));
    idxKeepYear = year(uxtimes)==yearUse;
    
    % inputs
    ld0 = res.adaptive.LD0_output(idxKeepYear);
    ld0_high = res.adaptive.LD0_highThreshold(idxKeepYear);
    ld0_low  = res.adaptive.LD0_lowThreshold(idxKeepYear);
    timesUseDetector = uxtimes(idxKeepYear);
    idxkeepdet = timesUseDetector > (timesUseDetector(1) + minutes(mintrim));
    
    timesUseDetector = timesUseDetector(idxkeepdet);
    ld0 = ld0(idxkeepdet);
    ld0_high = ld0_high(idxkeepdet);
    ld0_low = ld0_low(idxkeepdet);
    
    % get rid of negative diffs (e.g. times for past)
    idxbad = find(seconds(diff(timesUseDetector))<0)+1;
    idxkeep = setxor(1:length(timesUseDetector),idxbad);
    timesUseDetector = timesUseDetector(idxkeep);
    ld0 = ld0(idxkeep);
    ld0_high = ld0_high(idxkeep);
    ld0_low = ld0_low(idxkeep);
    
    timesUseCur = uxtimes(idxKeepYear);
    idxkeepcur = timesUseCur > (timesUseCur(1) + minutes(mintrim));
    timesUseCur = timesUseCur(idxkeepcur);
    
    % trim start of file
    currentTimeSeriesTrimmed = currentTimeSeries(idxkeepcur);
    
    db.currentTimeSeries{d} = currentTimeSeriesTrimmed; 
    db.timesUseDetector{d} = timesUseDetector;
    db.timesUseCur{d} = timesUseCur;
    db.ld0{d} =  ld0;
    db.ld0_high{d}  = ld0_high;
    db.ld0_low{d} = ld0_low; 
    uniqCurrents = unique(currentTimeSeriesTrimmed); 
    if length(uniqCurrents) == 1
        db.adaptive_running(d) = 0; 
    else
        db.adaptive_running(d) = 1; 
    end
    db.adaptiveLogTable{d} = adaptiveLogTable;
end
%% open figure 
close all;
hfig = figure; 
hfig.Color = 'w';
nrows = 3;
ncols = 1; 
cntplt = 1; 
for i = 1:nrows
    hsb(i) = subplot(nrows,ncols,i); 
end
% plot data
% only plot data from

dbuse = db;
for d = 1:length(dbuse.currentTimeSeries)
    % plot the detector
    timesUseDetector = dbuse.timesUseDetector{d};
    ld0 = dbuse.ld0{d};
    ld0_high = dbuse.ld0_high{d};
    ld0_low = dbuse.ld0_low{d};
    if ~isempty(ld0)
        % only remove outliers in the threshold
        outlierIdx = isoutlier(ld0_high);
        ld0 = ld0(~outlierIdx);
        ld0_high = ld0_high(~outlierIdx);
        ld0_low = ld0_low(~outlierIdx);
        timesUseDetector = timesUseDetector(~outlierIdx);
        
        idxplot = 1; % first plot is detecorr 
        hold(hsb(idxplot),'on');
        hplt = plot(hsb(idxplot),timesUseDetector,ld0,'LineWidth',2.5,'Color',[0 0 0.8 ]);
        hplt = plot(hsb(idxplot),timesUseDetector,ld0_high,'LineWidth',2,'Color',[0.8 0 0 ]);
        hplt.LineStyle = '-.';
        hplt.Color = [hplt.Color 0.7];
        hplt = plot(hsb(idxplot),timesUseDetector,ld0_low,'LineWidth',2,'Color',[0.8 0 0]);
        hplt.LineStyle = '-.';
        hplt.Color = [hplt.Color 0.7];
        prctile_99 = prctile(ld0,99);
        prctile_1  = prctile(ld0,1);
        if prctile_1 > ld0_low(1)
            prctile_1 = ld0_low(1) * 0.9;
        end
        if prctile_99 < ld0_high(1)
            prctile_99 = ld0_high(1)*1.1;
        end
        ylim(hsb(idxplot),[prctile_1 prctile_99]);
        ttlus = sprintf('Control signal');
        title(hsb(idxplot),ttlus);
        ylabel(hsb(idxplot),'Control signal (a.u.)');
        set(hsb(idxplot),'FontSize',12);
        
        
        idxplot = 2; % current 
        hold(hsb(idxplot),'on');
        timesUseCur = dbuse.timesUseCur{d};
        cur = dbuse.currentTimeSeries{d};
        % don't  remove outliers for current
        % but remove current above 10 as they are unlikely to be real
        outlierIdx = cur>10;
        cur = cur(~outlierIdx);
        timesUseCur = timesUseCur(~outlierIdx);
        
        
        
        plot(hsb(idxplot),timesUseCur,cur,'LineWidth',3,'Color',[0 0.8 0 0.7]);
%         for i = 1:3
%             states{i} = sprintf('%0.1fmA',dbuse.cur(d,i));
%             
%             if i == 2
%                 if dbuse.cur(d,i) == 25.5
%                     states{i} = 'HOLD';
%                 end
%             end
%         end
%         ttlus = sprintf('Current in mA %s [%s, %s, %s]',unqSides{ss},states{1},states{2},states{3});
%         title(hsb(idxplot) ,ttlus);
        ylabel( hsb(idxplot) ,'Current (mA)');
        set( hsb(idxplot),'FontSize',16);
        ylims = [min([dbuse.currentTimeSeries{:}]) max([dbuse.currentTimeSeries{:}])];
        if ylims(1) == ylims(2)
            ylims(1) = ylims(1) * 0.9;
            ylims(2) = ylims(2) * 1.1;
        end
        set(hsb(idxplot),'YLim',ylims);
        
        % plot the raw states 
        idxplot = 3; 
        minTime = min(timesUseCur);
        maxTime = max(timesUseCur);
        adaptiveLogTable = dbuse.adaptiveLogTable{d};
        adaptiveLogTable.time.TimeZone = minTime.TimeZone;
        adaptiveLogTable = sortrows(adaptiveLogTable,'time');
        states = adaptiveLogTable.newstate;
        timeUse = adaptiveLogTable.time;
       %%
       cla(hsb(idxplot));
       incX = 1;
       incY = 0; 
       hold(hsb(idxplot),'on');
        for t = 2:length(timeUse)-1
            plot(hsb(idxplot),[timeUse(t-1) timeUse(t)],[states(t-1) states(t-1)],...
                'LineWidth',1,'Color',[0 0 0.8]);
            plot(hsb(idxplot),[timeUse(t) timeUse(t)],[states(t-1) states(t)],...
                'LineWidth',1,'Color',[0 0 0.8]);
        end
        hsb(idxplot).YTick = [0 1 2];
        ylabel('State (Log File)');
        ylim([-0.5 2.5]);
        %%
        
        linkaxes(hsb,'x');
    end
end
%%
end