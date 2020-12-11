function plot_adaptive_json_in_directory(dirplot)
%% this file plots an adaptive json file as well as current
close all;

fadapt = findFilesBVQX(dirplot,'AdaptiveLog.json');
aTables = {};
cntTbl = 1; 
for ff = 1:length(fadapt)
    fnAdaptive = fadapt{ff};
    %% get data
    [pn,fn] = fileparts(fnAdaptive);
    fnDeviceSettings = fullfile(pn,'DeviceSettings.json');
    ds = get_meta_data_from_device_settings_file(fnDeviceSettings);
    if ds.duration > minutes(20)
        %     str = getAdaptiveHumanReadaleSettings(ds);
        mintrim = 10;
        
        % load adapative
        res = readAdaptiveJson(fnAdaptive);
        tim = res.timing;
        fnf = fieldnames(tim);
        for fff = 1:length(fnf)
            tim.(fnf{fff})= tim.(fnf{fff})';
        end
        
        ada = res.adaptive;
        fnf = fieldnames(ada);
        for fff = 1:length(fnf)
            ada.(fnf{fff})= ada.(fnf{fff})';
        end
        
        timingTable = struct2table(tim);
        adaptiveTableTemp = struct2table(ada);
        adaptiveTable = [timingTable, adaptiveTableTemp];
        % get sampling rate
        deviceSettingsTable = get_meta_data_from_device_settings_file(fnDeviceSettings);
        fftInterval = deviceSettingsTable.fftTable{1}.interval;
        samplingRate = 1000/fftInterval;
        samplingRateCol = repmat(samplingRate,size(adaptiveTable,1),1);
        adaptiveTable.samplerate = samplingRateCol;
        adaptiveTable.packetsizes  = repmat(1,size(adaptiveTable,1),1);
        
        adaptiveTable = assignTime(adaptiveTable);
        ts = datetime(adaptiveTable.DerivedTime/1000,...
            'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
        
        
        adaptiveTable.DerivedTimesFromAssignTimesHumanReadable = ts;
        aTables{cntTbl} = adaptiveTable;
        cntTbl = cntTbl + 1; 
    end
end




%% plot data

hfig = figure;
hfig.Color = 'w';
for i = 1:3
    hsb(i) = subplot(3,1,i); 
    hold(hsb(i),'on');
end

controlSignal = [];
for a = 1:length(aTables)
    adaptiveTable = aTables{a};
    % only remove outliers in the threshold
    timesUseDetector = adaptiveTable.DerivedTimesFromAssignTimesHumanReadable;
    ld0 = adaptiveTable.LD0_output;
    ld0_high = adaptiveTable.LD0_highThreshold;
    ld0_low = adaptiveTable.LD0_lowThreshold;
    
    
    outlierIdx = isoutlier(ld0_high);
    ld0 = ld0(~outlierIdx);
    ld0_high = ld0_high(~outlierIdx);
    ld0_low = ld0_low(~outlierIdx);
    timesUseDetector = timesUseDetector(~outlierIdx);
    
    idxplot = 1; % first plot is detecorr
    controlSignal = [controlSignal; ld0];
    hold(hsb(idxplot),'on');
    hplt = plot(hsb(idxplot),timesUseDetector,ld0,'LineWidth',2.5,'Color',[0 0 0.8 ]);
    plot(hsb(idxplot),timesUseDetector,movmean( ld0,[1 1200]),'LineWidth',4,'Color',[0 0.8 0 0.2]);
    
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
    set(hsb(idxplot),'FontSize',16);
    
    
    % state
    
    
    idxplot = 2; % current
    hold(hsb(idxplot),'on');
    timesUseCur = adaptiveTable.DerivedTimesFromAssignTimesHumanReadable;
    stateUse = adaptiveTable.CurrentAdaptiveState;
    % don't  remove outliers for current
    % but remove current above 10 as they are unlikely to be real
    outlierIdx = stateUse < 0 | stateUse > 9;
    stateUse = stateUse(~outlierIdx);
    timesUseCur = timesUseCur(~outlierIdx);
    plot(hsb(idxplot),timesUseCur,stateUse,'LineWidth',3,'Color',[0.8 0 0 0.7]);
    ylabel( hsb(idxplot) ,'State');
    ylim(hsb(idxplot),[-0.5 2.5]);
    hsb(idxplot).YTick = [0 1 2];
    title(hsb(idxplot),'State');
    set( hsb(idxplot),'FontSize',16);
    
    
    
    % current
    
    idxplot = 3; % current
    hold(hsb(idxplot),'on');
    timesUseCur = adaptiveTable.DerivedTimesFromAssignTimesHumanReadable;
    cur = adaptiveTable.CurrentProgramAmplitudesInMilliamps;
    cur = cur(:,1); % assumes only one program running ;
    % don't  remove outliers for current
    % but remove current above 10 as they are unlikely to be real
    outlierIdx = cur>10;
    cur = cur(~outlierIdx);
    timesUseCur = timesUseCur(~outlierIdx);
    title('Current');
    set( hsb(idxplot),'FontSize',16);
    
    
    
    plot(hsb(idxplot),timesUseCur,cur,'LineWidth',3,'Color',[0 0.8 0 0.7]);
    plot(hsb(idxplot),timesUseCur,movmean( cur,[1 1200]),'LineWidth',4,'Color',[0 0.0 0.8 0.2]);
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
    title('Current');
    ylabel( hsb(idxplot) ,'Current (mA)');
    set( hsb(idxplot),'FontSize',16);
    

end
% plot percentile lines 
idxplot = 1; 
hsb(idxplot)
xlims = hsb(idxplot).XLim;
prctiles = [10 25 50 75 90];
for p = 1:length(prctiles)
    prcUse = prctile(controlSignal,prctiles(p));
    plot(hsb(idxplot),xlims,[prcUse prcUse],...
        'LineStyle','-.',...
        'Color',[0 0.8 0 0.5],...
        'LineWidth',1);
end
ds.timeStart.Format = 'dd-MMM-uuuu';
lrgTitle = sprintf('%s %s %s',ds.patient{1},ds.side{1},ds.timeStart(1));
sgtitle(lrgTitle)
linkaxes(hsb,'x');

%% write to screen
clc; 
fprintf('LD0 data:\n\n');
ld0 = controlSignal;
fprintf('\tmean:\t%.2f\n',mean(ld0));
fprintf('\tmedian:\t%.2f\n',median(ld0));
fprintf('\n'); 
for i = 5:5:100
    fprintf('\t prctile %0.2d:\t%.2f\n',i,prctile(ld0,i));
end
%% write to file 
txtFile = sprintf('%s_%s_%s_prctilesAdaptiveRun.txt',ds.patient{1},ds.side{1},ds.timeStart(1));

filePrctile = fullfile(dirplot,txtFile); 
fid = fopen(filePrctile,'w+');

fprintf(fid,'LD0 data:\n\n');

fprintf(fid,'\tmean:\t%.2f\n',mean(ld0));
fprintf(fid,'\tmedian:\t%.2f\n',median(ld0));
fprintf(fid,'\n'); 
for i = 5:5:100
    fprintf(fid,'\t prctile %0.2d:\t%.2f\n',i,prctile(ld0,i));
end
fclose(fid);



