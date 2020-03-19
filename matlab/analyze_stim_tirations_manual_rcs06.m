function analyze_stim_tirations_manual_rcs06()
%% load events 
rootdir = '/Volumes/RCS_DATA/RCS06/newData/SummitContinuousBilateralStreaming/RCS06L/';
load(fullfile(rootdir,'allEvents.mat')); 
eventout = allEvents.eventOut; 
idxkeep = cellfun(@(x) any(strfind(lower(x),'ptm')),eventout.EventSubType);
eventskeep = eventout(idxkeep,:);


uniqueSessionIDS = unique(eventskeep.sessionid);
patientSettings = struct(); 
for s = 1:size(uniqueSessionIDS,1)
    searchdir =  uniqueSessionIDS{s};
    fdir = findFilesBVQX(rootdir,['*' searchdir '*'],struct('dirs',1,'depth',1));
    fidruse = findFilesBVQX(fdir{1},'*evice*',struct('dirs',1,'depth',1));
    [outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerOut,adaptiveTable] =  MAIN_load_rcs_data_from_folder(fidruse{1}); 
    load(fullfile( fidruse{1},'StimLog.mat'));
    patientSettings(s).group = stimEvents.group(1); 
    patientSettings(s).rate = stimEvents.rate(1); 
    patientSettings(s).amp = stimEvents.AmplitudeInMilliamps(1); 
    patientSettings(s).stimstatus = stimEvents.stimStatus(1); 
    patientSettings(s).duration = outdatcomplete.derivedTimes(end) - outdatcomplete.derivedTimes(1); 
    patientSettings(s).date = outdatcomplete.derivedTimes(1); 
    for c = 1:4
        fnuse = sprintf('chan_%d',c); 
        patientSettings(s).(fnuse) = outRec.tdData(c).chanFullStr;
    end
    idxconditions = strcmp(eventTable.EventType,'conditions');
    patientSettings(s).conditions = [eventTable.EventSubType{idxconditions}];
    
    idxextracomments = strcmp(eventTable.EventType,'extra_comments');
    patientSettings(s).extraComments = [eventTable.EventSubType{idxextracomments}];
    
    idxmedication = strcmp(eventTable.EventType,'medication');
    patientSettings(s).medication = [eventTable.EventSubType{idxmedication}];


    patientSettings(s).dir = fidruse{1}; 
end 
ptSettings = struct2table(patientSettings); 
savefn = fullfile(rootdir,'patientSettingsForEvents.mat');
save(savefn,'ptSettings');

ptSettings = sortrows(ptSettings,'duration');
idxkeep = ptSettings.duration < duration('00:30:06') & ... 
          strcmp(ptSettings.chan_2,'+3-1 lpf1-100Hz lpf2-100Hz sr-250Hz');
ptSettingsAnalyze = ptSettings(idxkeep,:); 
hfig = figure; 
hfig.Color = 'w'; 
hold on; 
for p = 1:size(ptSettingsAnalyze,1)
    diropen = ptSettingsAnalyze.dir{p}; 
    [outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerOut,adaptiveTable] =  MAIN_load_rcs_data_from_folder(diropen); 
    stn = mean([outdatcomplete.key0, outdatcomplete.key1],2);
    stn = stn(250*10:end,1); 
    stn = stn-mean(stn); 
    idxpeaks = abs(stn) > prctile(abs(stn),99.9);
    idxremove = find(idxpeaks==1);
    idxplus = [];
    idxplus(:,1) = idxremove; 
    for i = 1:250
        idxplus(:,i+1) = idxremove+i; 
    end
    idxminus = []; 
    idxminus(:,1) = idxremove; 
    for i = 1:250
        idxminus(:,i+1) = idxremove-i; 
    end
    idxgetridoff = unique([idxplus(:) idxminus(:)]);
    idxkeep = setxor(1:size(stn,1),idxgetridoff);
    idxkeep = idxkeep(idxkeep>=1);
    idxkeep = idxkeep(idxkeep<=size(stn,1));
    stnclean = stn(idxkeep,1); 
    [fftOut,f]   = pwelch(stnclean,250,250/2,0:1:250/2,250,'psd');
    hplt = plot(f,log10(fftOut));
    if any(strfind(ptSettingsAnalyze.conditions{p},'Feeling ''on'' little / no symptoms'))
        cond = 'on';
        colorUse = [0 0.8 0.5];
    else
        cond = 'off';
        colorUse = [0.8 0 0.5];
    end
    legendStr{p} = sprintf('%s %.2f',cond, ptSettingsAnalyze.amp(p));
    hplt.Color = colorUse; 
    switch ptSettingsAnalyze.amp(p)
        case 0 
            hplt.LineWidth = 3;
            hplt.LineStyle = '-.';
        case 0.5
            hplt.LineWidth = 3;
            hplt.Color =  [0 0 0.8 0.5];
        case 0.8
            hplt.LineWidth = 6;
            hplt.Color =  [0 0 0.8 0.5];
        case 0.9
            hplt.LineWidth = 6;
            hplt.Color =  [0 0 0.8 0.5];
    end
    xlabel('Frequency (Hz)');
    ylabel('Power (log_1_0\muV^2/Hz)');
end
legend(legendStr);
sgtitle('RCS 06 L STN','FontSize',20); 
set(gca,'FontSize',20);
exampleRCS06 = ptSettingsAnalyze(:,{'group','rate','amp','stimstatus','date','medication','conditions','extraComments',});
exampleRCS06 = sortrows(exampleRCS06,'date');
writetable(exampleRCS06,'sampleLogRCS06.csv');


%% plot STN by day 
rootdir = '/Volumes/RCS_DATA/RCS06/newData/SummitContinuousBilateralStreaming/RCS06L/';
savefn = fullfile(rootdir,'patientSettingsForEvents.mat');
load(savefn,'ptSettings');


ptSettings = sortrows(ptSettings,'duration');
idxkeep = ptSettings.duration < duration('00:30:06') & ... 
          strcmp(ptSettings.chan_2,'+3-1 lpf1-100Hz lpf2-100Hz sr-250Hz');
ptSettingsAnalyze = ptSettings(idxkeep,:); 

ptSettingsAnalyze_big = ptSettingsAnalyze; 
ptSettingsAnalyze_big = sortrows(ptSettingsAnalyze_big,'date');
unqdays = unique(day(ptSettingsAnalyze_big.date));
hfig = figure;
hfig.Color = 'w';
nrows = length(unqdays); 
ncols = 1; 
for u = 1:length(unqdays)
    idxkeepdays = unqdays(u) == day(ptSettingsAnalyze_big.date); 
    ptSettingsAnalyze = ptSettingsAnalyze_big(idxkeepdays,:); 
    hsb(u) = subplot(nrows,ncols,u); 
    hold on;
    for p = 1:size(ptSettingsAnalyze,1)
        diropen = ptSettingsAnalyze.dir{p};
        [outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerOut,adaptiveTable] =  MAIN_load_rcs_data_from_folder(diropen);
        stn = mean([outdatcomplete.key0, outdatcomplete.key1],2);
        stn = stn(250*10:end,1);
        stn = stn-mean(stn);
        idxpeaks = abs(stn) > prctile(abs(stn),99.9);
        idxremove = find(idxpeaks==1);
        idxplus = [];
        idxplus(:,1) = idxremove;
        for i = 1:250
            idxplus(:,i+1) = idxremove+i;
        end
        idxminus = [];
        idxminus(:,1) = idxremove;
        for i = 1:250
            idxminus(:,i+1) = idxremove-i;
        end
        idxgetridoff = unique([idxplus(:) idxminus(:)]);
        idxkeep = setxor(1:size(stn,1),idxgetridoff);
        idxkeep = idxkeep(idxkeep>=1);
        idxkeep = idxkeep(idxkeep<=size(stn,1));
        stnclean = stn(idxkeep,1);
        [fftOut,f]   = pwelch(stnclean,250,250/2,0:1:250/2,250,'psd');
%         hplt = plot(f,log10(fftOut));
        mean_beta = mean(log10(fftOut(18:23))); 
        stim_level = ptSettingsAnalyze.amp(p);
        date_use = ptSettingsAnalyze.date(p); 
        hsc = scatter(date_use,mean_beta,1e3,'filled');
        ampwrite = sprintf('%0.1f',ptSettingsAnalyze.amp(p));
        text(date_use -  minute(2), mean_beta, ampwrite); 
        if any(strfind(ptSettingsAnalyze.conditions{p},'Feeling ''on'' little / no symptoms'))
            cond = 'on';
            colorUse = [0 0.8 0.5];
        else
            cond = 'off';
            colorUse = [0.8 0 0.5];
        end
        hsc.MarkerFaceColor = colorUse; 
        hsc.MarkerFaceAlpha = 0.6;
    
        legendStr{p} = sprintf('%s %.2f',cond, ptSettingsAnalyze.amp(p));

        switch ptSettingsAnalyze.amp(p)
            case 0
%                 hsc.MarkerEdgeColor = [0 0 0];
%                 hsc.LineWidth = 3;
            case 0.5
                hsc.MarkerEdgeColor = [0 0 0.8];
                hsc.LineWidth = 1;
            case 0.8
                hsc.MarkerEdgeColor = [0 0 0.8];
                hsc.LineWidth = 2;
            case 0.9
                hsc.MarkerEdgeColor = [0 0 0.8];
                hsc.LineWidth = 3;
        end
        xlabel('Frequency (Hz)');
        ylabel('Power (log_1_0\muV^2/Hz)');
        legendStr2{p} = sprintf('%s',cond, ptSettingsAnalyze.extraComments{p});

    end
%     legend(legendStr)
%     legend(legendStr2)
    set(gca,'FontSize',15)
    clear legendStr2
end
sgtitle('average beta level on/off stim');
linkaxes(hsb,'y');

%% plot STN across all days
rootdir = '/Volumes/RCS_DATA/RCS06/newData/SummitContinuousBilateralStreaming/RCS06L/';
savefn = fullfile(rootdir,'patientSettingsForEvents.mat');
load(savefn,'ptSettings');


ptSettings = sortrows(ptSettings,'duration');
idxkeep = ptSettings.duration < duration('00:30:06') & ... 
          strcmp(ptSettings.chan_2,'+3-1 lpf1-100Hz lpf2-100Hz sr-250Hz');
ptSettingsAnalyze = ptSettings(idxkeep,:); 

ptSettingsAnalyze_big = ptSettingsAnalyze; 
ptSettingsAnalyze_big = sortrows(ptSettingsAnalyze_big,'date');
unqdays = unique(day(ptSettingsAnalyze_big.date));
hfig = figure;
hfig.Color = 'w';
nrows = length(unqdays); 
ncols = 1;  
cntdot = 1;
for u = 1:length(unqdays)
    idxkeepdays = unqdays(u) == day(ptSettingsAnalyze_big.date); 
    ptSettingsAnalyze = ptSettingsAnalyze_big(idxkeepdays,:); 
    hold on;
    for p = 1:size(ptSettingsAnalyze,1)
        diropen = ptSettingsAnalyze.dir{p};
        [outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerOut,adaptiveTable] =  MAIN_load_rcs_data_from_folder(diropen);
        stn = mean([outdatcomplete.key0, outdatcomplete.key1],2);
        dur = outdatcomplete.derivedTimes(end) - outdatcomplete.derivedTimes(1); 
        duration_recs(cntdot) = dur; 
        fprintf('duration %s\n',dur);
        
        stn = stn(250*10:end,1);
        stn = stn-mean(stn);
        idxpeaks = abs(stn) > prctile(abs(stn),99.9);
        idxremove = find(idxpeaks==1);
        idxplus = [];
        idxplus(:,1) = idxremove;
        for i = 1:250
            idxplus(:,i+1) = idxremove+i;
        end
        idxminus = [];
        idxminus(:,1) = idxremove;
        for i = 1:250
            idxminus(:,i+1) = idxremove-i;
        end
        idxgetridoff = unique([idxplus(:) idxminus(:)]);
        idxkeep = setxor(1:size(stn,1),idxgetridoff);
        idxkeep = idxkeep(idxkeep>=1);
        idxkeep = idxkeep(idxkeep<=size(stn,1));
        stnclean = stn(idxkeep,1);
        [fftOut,f]   = pwelch(stnclean,250,250/2,0:1:250/2,250,'psd');
%         hplt = plot(f,log10(fftOut));
        mean_beta = mean(log10(fftOut(18:23))); 
        % plot fft power
        mean_beta = mean(powerOut.powerTable.Band4);
        fprintf('[%0.2d]',cntdot )
        fprintf('\t %s', outdatcomplete.derivedTimes(end) - outdatcomplete.derivedTimes(1)); 
        fprintf('\t %s\n', powerOut.bands.powerBandInHz{4});
        fprintf('\t %s\n', mean_beta);
        
        stim_level = ptSettingsAnalyze.amp(p);
        date_use = ptSettingsAnalyze.date(p); 
        hsc = scatter(cntdot,mean_beta,1e3,'filled');
        ampwrite = sprintf('%0.1f',ptSettingsAnalyze.amp(p));
        text(cntdot, mean_beta, ampwrite); 
        text(cntdot, mean_beta*0.9, ptSettingsAnalyze.extraComments{p}); 
        if any(strfind(ptSettingsAnalyze.conditions{p},'Feeling ''on'' little / no symptoms'))
            cond = 'on';
            colorUse = [0 0.8 0.5];
        else
            cond = 'off';
            colorUse = [0.8 0 0.5];
        end
        hsc.MarkerFaceColor = colorUse; 
        hsc.MarkerFaceAlpha = 0.6;
    
        legendStr{p} = sprintf('%s %.2f',cond, ptSettingsAnalyze.amp(p));

        switch ptSettingsAnalyze.amp(p)
            case 0
%                 hsc.MarkerEdgeColor = [0 0 0];
%                 hsc.LineWidth = 3;
            case 0.5
                hsc.MarkerEdgeColor = [0 0 0.8];
                hsc.LineWidth = 1;
            case 0.8
                hsc.MarkerEdgeColor = [0 0 0.8];
                hsc.LineWidth = 2;
            case 0.9
                hsc.MarkerEdgeColor = [0 0 0.8];
                hsc.LineWidth = 3;
        end
        xlabel('Frequency (Hz)');
        ylabel('Power (log_1_0\muV^2/Hz)');
        legendStr2{p} = sprintf('%s',cond, ptSettingsAnalyze.extraComments{p});
        cntdot = cntdot + 1;
    end
%     legend(legendStr)
%     legend(legendStr2)
    set(gca,'FontSize',15)
    clear legendStr2
end
sgtitle('average beta level on/off stim');

%% plot time domain and power correlations 
rootdir = '/Volumes/RCS_DATA/RCS06/newData/SummitContinuousBilateralStreaming/RCS06L/';
savefn = fullfile(rootdir,'patientSettingsForEvents.mat');
load(savefn,'ptSettings');


ptSettings = sortrows(ptSettings,'duration');
idxkeep = ptSettings.duration < duration('00:30:06') & ... 
          strcmp(ptSettings.chan_2,'+3-1 lpf1-100Hz lpf2-100Hz sr-250Hz');
ptSettingsAnalyze = ptSettings(idxkeep,:); 

ptSettingsAnalyze_big = ptSettingsAnalyze; 
ptSettingsAnalyze_big = sortrows(ptSettingsAnalyze_big,'date');
unqdays = unique(day(ptSettingsAnalyze_big.date));
hfig = figure;
hfig.Color = 'w';
nrows = length(unqdays); 
ncols = 1;  
cntdot = 1;
alldata = struct();
for p = 1:size(ptSettingsAnalyze,1)
    diropen = ptSettingsAnalyze.dir{p};
    [outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerOut,adaptiveTable] =  MAIN_load_rcs_data_from_folder(diropen);
    alldata(p).outdatcomplete = outdatcomplete; 
    alldata(p).outRec = outRec; 
    alldata(p).eventTable = eventTable; 
    alldata(p).outdatcompleteAcc = outdatcompleteAcc; 
    alldata(p).powerOut = powerOut;     
end

chanidxs = [0 0 1 1 2 2 3 3]; % time domain channels 
for b = 1:8 % loop on power bands
    subplot(4,2,b); 
    hold on;
    for p = 1:size(ptSettingsAnalyze,1)
        fnband = sprintf('Band%d',b);
        outdatcomplete = alldata(p).outdatcomplete;
        fileDuration = outdatcomplete.derivedTimes(end) - outdatcomplete.derivedTimes(1); 
        powerdat = alldata(p).powerOut.powerTable.(fnband); 
        bandString = alldata(p).powerOut.bands.powerBandInHz{b};
        bandsHz = str2num(strrep(strrep(bandString,'Hz',''),'-', ' '));
        
        % get power in time domain 
        chanidx = chanidxs(b); 
        fntd = sprintf('key%d',chanidx);
        if chanidx < 2
            stn = mean([outdatcomplete.(fntd), outdatcomplete.(fntd)],2);
        else
            stn = outdatcomplete.(fntd); 
        end
                
        stn = stn(250*10:end,1);
        stn = stn-mean(stn);
        idxpeaks = abs(stn) > prctile(abs(stn),99.9);
        idxremove = find(idxpeaks==1);
        idxplus = [];
        idxplus(:,1) = idxremove;
        for i = 1:250
            idxplus(:,i+1) = idxremove+i;
        end
        idxminus = [];
        idxminus(:,1) = idxremove;
        for i = 1:250
            idxminus(:,i+1) = idxremove-i;
        end
        idxgetridoff = unique([idxplus(:) idxminus(:)]);
        idxkeep = setxor(1:size(stn,1),idxgetridoff);
        idxkeep = idxkeep(idxkeep>=1);
        idxkeep = idxkeep(idxkeep<=size(stn,1));
        stnclean = stn(idxkeep,1);
        [fftOut,f]   = pwelch(stnclean,250,250/2,0:1:250/2,250,'psd');
%                 hplt = plot(f,log10(fftOut));
        [val,idx1]  = min(abs(f-bandsHz(1)));
        [val,idx2]  = min(abs(f-bandsHz(2)));
        
        
        mean_beta_td = mean(log10(fftOut(idx1:idx2)));
        % plot fft power
        mean_beta_power = log10(sqrt(mean(powerdat)));
%         mean_beta_power = mean(powerdat);
        fprintf('[%0.2d]',cntdot )
        fprintf('\t %s', outdatcomplete.derivedTimes(end) - outdatcomplete.derivedTimes(1));
        fprintf('\t %s\n', bandString);
        fprintf('\t %s\n', mean_beta);
        
        stim_level = ptSettingsAnalyze.amp(p);
        date_use = ptSettingsAnalyze.date(p);
        hsc = scatter(mean_beta_td,mean_beta_power,2e2,'filled');
        ampwrite = sprintf('%0.1f',ptSettingsAnalyze.amp(p));
%         text(mean_beta_td, mean_beta_power, ampwrite);
        if any(strfind(ptSettingsAnalyze.conditions{p},'Feeling ''on'' little / no symptoms'))
            cond = 'on';
            colorUse = [0 0.8 0.5];
        else
            cond = 'off';
            colorUse = [0.8 0 0.5];
        end
        hsc.MarkerFaceColor = colorUse;
        hsc.MarkerFaceAlpha = 0.6;
                
        switch ptSettingsAnalyze.amp(p)
            case 0
                %                 hsc.MarkerEdgeColor = [0 0 0];
                %                 hsc.LineWidth = 3;
            case 0.5
                hsc.MarkerEdgeColor = [0 0 0.8];
                hsc.LineWidth = 1;
            case 0.8
                hsc.MarkerEdgeColor = [0 0 0.8];
                hsc.LineWidth = 2;
            case 0.9
                hsc.MarkerEdgeColor = [0 0 0.8];
                hsc.LineWidth = 3;
        end
    end
    xlabel('Time domain data');
    ylabel('Power domain data'); 
    title(bandString);
end


x = 2;

%% plot m1 
hfig = figure; 
hfig.Color = 'w'; 
hold on; 
for p = 1:size(ptSettingsAnalyze,1)
    diropen = ptSettingsAnalyze.dir{p}; 
    [outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerOut,adaptiveTable] =  MAIN_load_rcs_data_from_folder(diropen); 
    m1 =outdatcomplete.key3;
    m1 = m1-mean(m1); 
    idxpeaks = abs(m1) > prctile(abs(m1),99.9);
    idxremove = find(idxpeaks==1);
    idxplus = [];
    idxplus(:,1) = idxremove; 
    for i = 1:250
        idxplus(:,i+1) = idxremove+i; 
    end
    idxminus = []; 
    idxminus(:,1) = idxremove; 
    for i = 1:250
        idxminus(:,i+1) = idxremove-i; 
    end
    idxgetridoff = unique([idxplus(:) idxminus(:)]);
    idxkeep = setxor(1:size(m1,1),idxgetridoff);
    idxkeep = idxkeep(idxkeep>=1);
    idxkeep = idxkeep(idxkeep<=size(m1,1));
    stnclean = m1(idxkeep,1); 
    
    
    [fftOut,f]   = pwelch(m1,250,250/2,0:1:250/2,250,'psd');
    hplt = plot(f,log10(fftOut));
    if any(strfind(ptSettingsAnalyze.conditions{p},'Feeling ''on'' little / no symptoms'))
        cond = 'on';
        colorUse = [0 0.8 0.5];
    else
        cond = 'off';
        colorUse = [0.8 0 0.5];
    end
    legendStr{p} = sprintf('%s %.2f',cond, ptSettingsAnalyze.amp(p));
    hplt.Color = colorUse; 
    switch ptSettingsAnalyze.amp(p)
        case 0 
            hplt.LineWidth = 3;
            hplt.LineStyle = '-.';
        case 0.5
            hplt.LineWidth = 3;
            hplt.Color =  [0 0 0.8 0.5];
        case 0.8
            hplt.LineWidth = 6;
            hplt.Color =  [0 0 0.8 0.5];
        case 0.9
            hplt.LineWidth = 6;
            hplt.Color =  [0 0 0.8 0.5];
    end
    xlabel('Frequency (Hz)');
    ylabel('Power (log_1_0\muV^2/Hz)');
end
legend(legendStr);
legend(legendStr);
sgtitle('RCS 06 L M1 9-11','FontSize',20); 
set(gca,'FontSize',20);



