function plot_stim_titrations_from_auto_montage_RCS02()

%% plot stim titration run on SCBS
% plot time domain verification 
rootdir = '/Users/roee/Box/Starr_Lab_Folder/Data_Analysis/RCS_data/results/stim_titrations_2/';
resdir  = '/Users/roee/Box/Starr_Lab_Folder/Data_Analysis/RCS_data/results/stim_titrations_2/results';
dataChoppedStimTitration = table();
cntData = 1; 
useThis = 1;
if useThis
    figdir = '/Users/roee/Box/Starr_Lab_Folder/Data_Analysis/RCS_data/results/stim_titrations_2/figures';
    ff = findFilesBVQX(rootdir,'DeviceSettings.json');
    
    
    cntFnd = 0;
    for f = 1:length(ff)
        [pn,~] = fileparts(ff{f});
        [outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerOut,adaptiveTable] =  ...
            MAIN_load_rcs_data_from_folder(pn);
        ds = get_meta_data_from_device_settings_file(ff{f});
        %%
        
        if iscell(eventTable.EventType)
            idxStartStop = cellfun(@(x) any(strfind(x,'StimSweep')),eventTable.EventType);
            eventTableUse = eventTable(idxStartStop,:);
            idxStart = cellfun(@(x) any(strfind(lower(x),'start')),eventTableUse.EventType);
            idxEnd = cellfun(@(x) any(strfind(lower(x),'stop')),eventTableUse.EventType);
            eStart = eventTableUse(idxStart,:);
            eEnd = eventTableUse(idxEnd,:);
            durations = eEnd.HostUnixTime - eStart.HostUnixTime;
            idxuse = durations > seconds(25);
            eStart = eStart(idxuse,:);
            eEnd = eEnd(idxuse,:);

        else
            idxStartStop = zeros(size(eventTable,1),1);
            eStart = [];
        end
        
        if ~isempty(eStart)
            
        %%
        
        % this section takes an event table that has events in computer time and
        % returns derived times in INS time
        
        %  Each data structure has a PC clock-driven time when the packet was received via Bluetooth,
        % as accurate as a C# DateTime.now (10-20ms).
        
        % in the eventTable structure this is UnixOnsetTime
        % in the timedomain strucutre this is PacketRxUnixTime
        
        % the goal of the code is to find the smallest different between
        % UnixOnsetTime and PacketRxUnixTime abd get the INS time domain value for
        % this sample.
        idxnonzero = find(outdatcomplete.PacketRxUnixTime~=0);
        % PacketGenTime
        % PacketRxUnixTime
        packtRxTimes    =  datetime(outdatcomplete.PacketGenTime(idxnonzero)/1000,...
            'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
        % note that we only get one time sample for each time domain packet.
        % this finds the closest time sample in "packet time".
        derivesTimesWithInsTime = outdatcomplete.derivedTimes(idxnonzero);
        
        
        
        % convert the packet rx unix time to ins times
        for e = 1:size(eStart,1)
            % start time  - is before end time in some cases fix this
            [timeDiff, idx] = min(abs(eStart.HostUnixTime(e) - packtRxTimes));
            timeDiffVec(e) = timeDiff;
            timeDiffUse = packtRxTimes(idx) - eStart.HostUnixTime(e) ;
            insTimeUncorrected = derivesTimesWithInsTime(idx);
            eStart.derivedTimesInsTime(e)       = insTimeUncorrected - timeDiffUse;
            % emd time  - is before end time in some cases fix this
            [timeDiff, idx] = min(abs(eEnd.HostUnixTime(e) - packtRxTimes));
            timeDiffVec(e) = timeDiff;
            timeDiffUse = packtRxTimes(idx) - eEnd.HostUnixTime(e) ;
            insTimeUncorrected = derivesTimesWithInsTime(idx);
            eEnd.derivedTimesInsTime(e)       = insTimeUncorrected - timeDiffUse;
            
        end
        %%
            %%
            hfig = figure;
            hfig.Color = 'w';
            for c = 1:4
                hsb(c) = subplot(4,1,c);
                hold on;
                t = outdatcomplete.derivedTimes;
                fnuse = sprintf('key%d',c-1);
                y = outdatcomplete.(fnuse);
                for e = 1:size(eStart,1)
                    ylims = hsb(c).YLim; 
                    xuse = t > eStart.derivedTimesInsTime(e) & t < eEnd.derivedTimesInsTime(e);
                    tplot = t(xuse); 
                    timeStartDataSection = tplot(1);
                    tplot = tplot - tplot(1); 
                    yplot = y(xuse); 
                    plot(tplot,yplot,'LineWidth',0.05,'Color',[0 0 0.8 0.02]);
                    
                    % output chopped data for later processing  
                    dataChoppedStimTitration.sesssion{cntData} = ds.session{1};
                    dataChoppedStimTitration.timeStartSession(cntData) = ds.timeStart; 
                    dataChoppedStimTitration.timeStartDataSection(cntData) = timeStartDataSection; 
                    dataChoppedStimTitration.patient{cntData} = ds.patient{1}; 
                    dataChoppedStimTitration.side{cntData} = ds.side{1}; 
                    dataChoppedStimTitration.duration(cntData) = tplot(end) - tplot(1); 
                    % get stim level
                    strExtract = eStart.EventSubType{e};
                    [StrMatch] = strExtract(29:50);
                    strRaw = split(StrMatch,',');
                    dataChoppedStimTitration.stimLevel(cntData) = str2num(strRaw{1});
                    % stim electrode 
                    stimChanges = ds.stimStateChanges{1};
                    stimChanges = stimChanges(end,:);
                    electrodes = ds.stimStateChanges{1}.electrodes{1};
                    dataChoppedStimTitration.stimElectrode{cntData} = electrodes;
                    dataChoppedStimTitration.group{cntData} = stimChanges.group;
                    dataChoppedStimTitration.activeRecharge{cntData} = stimChanges.active_recharge;
                    dataChoppedStimTitration.stimRate{cntData} = stimChanges.rate_Hz;
                    
                    % sense electrode 
                    dataChoppedStimTitration.senseElectrode{cntData} = ds.senseSettingsMultiple{1}.tdDataStruc{1}(c).chanOut;
                    dataChoppedStimTitration.timeDomainTime{cntData} = tplot; 
                    dataChoppedStimTitration.timeDomainData{cntData} = yplot;
                    % get power data 
                    timestamps = outdatcomplete.timestamp(xuse);
                    systemticks = outdatcomplete.systemTick(xuse);
                    startIdx = find(timestamps,1,'first');
                    endIdx = find(systemticks,1,'last');
                    
                    timestampStart = timestamps(startIdx);
                    systemTickStart = systemticks(startIdx);
                    timestampEnd = timestamps(endIdx);
                    systemTickEnd = systemticks(endIdx);
                    
                    pt = powerOut.powerTable;
                    % start 
                    idxsame = pt.timestamp == timestampStart;
                    [val,idxStart2] = min(abs(pt.systemTick(idxsame) - systemTickStart));
                    idxspots = find(idxsame==1);
                    idxuseStart = idxspots(idxStart2);
                    % end 
                    idxsame = pt.timestamp == timestampEnd;
                    [val,idxStart2] = min(abs(pt.systemTick(idxsame) - systemTickEnd));
                    idxspots = find(idxsame==1);
                    idxuseEnd = idxspots(idxStart2);
                    % get times for power 
                    timenum = powerOut.powerTable.PacketRxUnixTime;
                    derivedTimesPower = datetime(timenum/1000,'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
                    derivedTimesPowerChunk = derivedTimesPower(idxuseStart:idxuseEnd); 
                    derivedTimesPowerChunk = derivedTimesPowerChunk - derivedTimesPowerChunk(1); 

                    dataChoppedStimTitration.powerDomainTime{cntData} = derivedTimesPowerChunk; 
                    switch c 
                        case 1 
                            powerbands = [ 1 2];
                        case 2 
                            powerbands = [ 3 4];
                        case 3 
                            powerbands = [ 5 6];
                        case 4 
                            powerbands = [ 7 8];
                    end
                    bandsinHz = powerOut.bands(2).powerBandInHz;
                    for bb = 1:2
                        fnuse = sprintf('Band%d',powerbands(bb));
                        powerBand = pt.(fnuse)(idxuseStart:idxuseEnd); 
                        fnout = sprintf('power%d',bb);
                        dataChoppedStimTitration.(fnout){cntData} = powerBand;
                        % get the actual values 
                        pbndsVals = str2num(strrep(strrep(bandsinHz{powerbands(bb)},'Hz',''),'-',' '));
                        fnout = sprintf('power%d_Vals',bb); 
                        dataChoppedStimTitration.(fnout){cntData} = pbndsVals;
                    end
                    dataChoppedStimTitration.fftSize(cntData) = ds.fftTable{1}.fftSize;
                    ss= ds.senseSettingsMultiple{1};
                    sampleRate = str2num(strrep(ss(end,:).tdDataStruc{1}(1).sampleRate,'Hz',''));
                    dataChoppedStimTitration.fftInterval(cntData) = ds.fftTable{1}.interval;
                    dataChoppedStimTitration.sampleRate(cntData) = sampleRate;
                    windowUse = ds.fftTable{1}.windowLoad;
                    switch windowUse
                        case 2
                            hanningWindow = 100;
                        case 22
                            hanningWindow = 50;
                        case 42
                            hanningWindow = 25;
                    end
                    dataChoppedStimTitration.hanningWindow(cntData) = hanningWindow;
                    
                    cntData = cntData + 1;                    
                end
            end
            linkaxes(hsb,'x'); 
            %%
        end
        fprintf('finishes session %d/%d\n',f,length(ff));
    end
end
% compute power domain data from each time domain data segment 
for d = 1:size(dataChoppedStimTitration,1)
    timeDomainData = dataChoppedStimTitration.timeDomainData{d};
    % rectify: 
    timeDomainData = timeDomainData - mean(timeDomainData); 
    sampleRate = dataChoppedStimTitration.sampleRate(d); 
    fftInterval = dataChoppedStimTitration.fftInterval(d); 
    fftSize = dataChoppedStimTitration.fftSize(d);
    hanningWindow = dataChoppedStimTitration.hanningWindow(d);
    timePerFft = fftSize/sampleRate;
    gapBetween = timePerFft*1e3 - fftInterval;
    if gapBetween > 0
     numberOfSamplesOverlap = ceil((gapBetween/1e3) * sampleRate);
    else
        numberOfSamplesOverlap = 0;
    end
    
    FFTSize = fftSize; % can be 64  256  1024
    sampleRate = sampleRate; % can be 250,500,1000
    
    numberOfBins = FFTSize/2;
    binWidth = sampleRate/2/numberOfBins;
    
    for i = 0:(numberOfBins-1)
        fftBins(i+1) = i*binWidth;
        %     fprintf('bins numbers %.2f\n',fftBins(i+1));
    end
    
    lowerVals(1) = 0;
    for i = 2:length(fftBins)
        valInHz = fftBins(i)-fftBins(2)/2;
        lowerVals(i) = valInHz;
    end
    
    for i = 1:length(fftBins)
        valInHz = fftBins(i)+fftBins(2)/2;
        upperVals(i) = valInHz;
    end
    

    [pxx,f] = pwelch(timeDomainData,fftSize,numberOfSamplesOverlap,upperVals, sampleRate);
    dataChoppedStimTitration.tdFreqs{d} = f;
    dataChoppedStimTitration.tdPower{d} = pxx;
    fprintf('finishes session psd %d/%d\n',d,size(dataChoppedStimTitration,1));
end
fileSave = fullfile(resdir,'resultsStimTitrationsAllSubjects.mat'); 
save(fileSave,'dataChoppedStimTitration');


return;

%% load data and plot per patient data - embedded power vs stim levels 
close all; clc;
addpath(genpath(fullfile(pwd,'toolboxes','panel-2.14')));
resdir  = '/Users/roee/Box/Starr_Lab_Folder/Data_Analysis/RCS_data/results/stim_titrations_2/results';
figdir = '/Users/roee/Box/Starr_Lab_Folder/Data_Analysis/RCS_data/results/stim_titrations_2/figures';
fileSave = fullfile(resdir,'resultsStimTitrationsAllSubjects.mat'); 
load(fileSave,'dataChoppedStimTitration');
uniqePatients = unique(dataChoppedStimTitration.patient); 
uniqueSides = unique(dataChoppedStimTitration.side); 

for p = 1:size(uniqePatients,1) % loop on patients 
    for s = 1:size(uniqueSides,1) % loop on sides 
        hfig = figure;
        hfig.Color = 'w';
        hpanel = panel();
        hpanel.pack(4,2);

        idxPatAnDSise = strcmp(dataChoppedStimTitration.patient,uniqePatients{p}) & ... 
            strcmp(dataChoppedStimTitration.side,uniqueSides{s});
        dbPat = dataChoppedStimTitration(idxPatAnDSise,:); 
        unqTimes = unique(dbPat.timeStartSession);
        if length(unqTimes) > 2 
            error('found more than two sessions'); 
        end
        for t = 1:length(unqTimes) % loop on session time - earlier is off meds 
            idxPlot = dbPat.timeStartSession == unqTimes(t);
            dbPlot = dbPat(idxPlot,:); 
            unqTitrations = unique(dbPlot.timeStartDataSection);
            for u = 1:length(unqTitrations)
                idxSection = unqTitrations(u) == dbPlot.timeStartDataSection;
                dbSection = dbPlot(idxSection,:);
                cntplt = 1;
                for r = 1:size(dbSection,1) % loop on all 4 channels 
                    for pv = 1:2 % loop on 2 power bands within channel 
                        hsb = hpanel(r,pv).select();
                        axes(hsb);
                        hold(hsb,'on'); 
                        fnuse = sprintf('power%d',pv); 
                        powerVals = dbSection.(fnuse){r};
                        meanPowerval = mean(powerVals); 
                        stimLevel = dbSection.stimLevel(r);
                        fnPowerVals = sprintf('power%d_Vals',pv);
                        embedderPower = dbSection.(fnPowerVals){r};
                        % plot value 
                        switch t 
                            case 1 % off meds 
                                clrUse = [0.8 0 0];
                            case 2 
                                clrUse = [0 0.8 0];
                        end
                        hsc = scatter(stimLevel,meanPowerval,100,'filled',...
                            'MarkerFaceColor',clrUse,...
                            'MarkerFaceAlpha',0.4);
                        xlabel('Stim Level (mA)');
                        ylabel('Embedded power'); 
                        ttlstr = sprintf('%s %.2f(Hz)-%.2f(Hz)',...
                            dbSection.senseElectrode{r},...
                            embedderPower(1),embedderPower(2));
                        title(ttlstr); 
                    end
                end
            end
        end
        %%
        hpanel.fontsize = 10;  % global font
        hpanel.de.margin = 15;
        hpanel.marginleft =  20;
        hpanel.marginright =  20;
        hpanel.margintop =  10;
        hpanel.marginbottom =  10;
        hfig.PaperPositionMode = 'manual';
        prfig.plotwidth           = 12;
        prfig.plotheight          = 9;
        prfig.figdir             = figdir;
        figname = sprintf('%s_%s_all_embedded_power',uniqePatients{p},uniqueSides{s});
        prfig.figname             = figname;
        prfig.figtype             = '-dpdf';
        plot_hfig(hfig,prfig)
        %%
    end
end

%% load data and plot per patient data - embedded power vs computed power 

close all; clc;
addpath(genpath(fullfile(pwd,'toolboxes','panel-2.14')));
resdir  = '/Users/roee/Box/Starr_Lab_Folder/Data_Analysis/RCS_data/results/stim_titrations_2/results';
figdir = '/Users/roee/Box/Starr_Lab_Folder/Data_Analysis/RCS_data/results/stim_titrations_2/figures';
fileSave = fullfile(resdir,'resultsStimTitrationsAllSubjects.mat'); 
load(fileSave,'dataChoppedStimTitration');
uniqePatients = unique(dataChoppedStimTitration.patient); 
uniqueSides = unique(dataChoppedStimTitration.side); 

for p = 1:size(uniqePatients,1) % loop on patients 
    for s = 1:size(uniqueSides,1) % loop on sides 
        hfig = figure;
        hfig.Color = 'w';
        hpanel = panel();
        hpanel.pack(4,2);

        idxPatAnDSise = strcmp(dataChoppedStimTitration.patient,uniqePatients{p}) & ... 
            strcmp(dataChoppedStimTitration.side,uniqueSides{s});
        dbPat = dataChoppedStimTitration(idxPatAnDSise,:); 
        unqTimes = unique(dbPat.timeStartSession);
        if length(unqTimes) > 2 
            error('found more than two sessions'); 
        end
        for t = 1:length(unqTimes) % loop on session time - earlier is off meds 
            idxPlot = dbPat.timeStartSession == unqTimes(t);
            dbPlot = dbPat(idxPlot,:); 
            unqTitrations = unique(dbPlot.timeStartDataSection);
            for u = 1:length(unqTitrations)
                idxSection = unqTitrations(u) == dbPlot.timeStartDataSection;
                dbSection = dbPlot(idxSection,:);
                cntplt = 1;
                for r = 1:size(dbSection,1) % loop on all 4 channels 
                    for pv = 1:2 % loop on 2 power bands within channel 
                        hsb = hpanel(r,pv).select();
                        axes(hsb);
                        hold(hsb,'on'); 
                        fnuse = sprintf('power%d',pv); 
                        powerVals = dbSection.(fnuse){r};
                        meanPowerval = mean(powerVals); 
                        stimLevel = dbSection.stimLevel(r);
                        fnPowerVals = sprintf('power%d_Vals',pv);
                        embedderPower = dbSection.(fnPowerVals){r};
                        % plot value 
                        switch t 
                            case 1 % off meds 
                                clrUse = [0.8 0 0];
                            case 2 
                                clrUse = [0 0.8 0];
                        end
                        tdFrqs = dbSection.tdFreqs{r};
                        tdPwer = dbSection.tdPower{r};
                        idxusefreq = tdFrqs >= embedderPower(1) & tdFrqs <= embedderPower(2);
                        meanPower = mean(tdPwer(idxusefreq));
                        
                        hsc = scatter(meanPower,meanPowerval,100,'filled',...
                            'MarkerFaceColor',clrUse,...
                            'MarkerFaceAlpha',0.4);
                        xlabel('Power computed');
                        ylabel('Embedded power'); 
                        ttlstr = sprintf('%s %.2f(Hz)-%.2f(Hz)',...
                            dbSection.senseElectrode{r},...
                            embedderPower(1),embedderPower(2));
                        title(ttlstr); 
                    end
                end
            end
        end
        %%
        hpanel.fontsize = 10;  % global font
        hpanel.de.margin = 15;
        hpanel.marginleft =  20;
        hpanel.marginright =  20;
        hpanel.margintop =  10;
        hpanel.marginbottom =  10;
        hfig.PaperPositionMode = 'manual';
        prfig.plotwidth           = 12;
        prfig.plotheight          = 9;
        prfig.figdir             = figdir;
        figname = sprintf('%s_%s_all_embedded_vs_computed_power',uniqePatients{p},uniqueSides{s});
        prfig.figname             = figname;
        prfig.figtype             = '-dpdf';
        plot_hfig(hfig,prfig)
        
    end
end
%%

%% load data and plot per patient data - time domain plots  

close all; clc;
addpath(genpath(fullfile(pwd,'toolboxes','panel-2.14')));
resdir  = '/Users/roee/Box/Starr_Lab_Folder/Data_Analysis/RCS_data/results/stim_titrations_2/results';
figdir = '/Users/roee/Box/Starr_Lab_Folder/Data_Analysis/RCS_data/results/stim_titrations_2/figures';
fileSave = fullfile(resdir,'resultsStimTitrationsAllSubjects.mat'); 
load(fileSave,'dataChoppedStimTitration');
uniqePatients = unique(dataChoppedStimTitration.patient); 
uniqueSides = unique(dataChoppedStimTitration.side); 

for p = 1:size(uniqePatients,1) % loop on patients 
    for s = 1:size(uniqueSides,1) % loop on sides 
        hfig = figure;
        hfig.Color = 'w';
        hpanel = panel();
        hpanel.pack(4,2);

        idxPatAnDSise = strcmp(dataChoppedStimTitration.patient,uniqePatients{p}) & ... 
            strcmp(dataChoppedStimTitration.side,uniqueSides{s});
        dbPat = dataChoppedStimTitration(idxPatAnDSise,:); 
        unqTimes = unique(dbPat.timeStartSession);
        if length(unqTimes) > 2 
            error('found more than two sessions'); 
        end
        for t = 1:length(unqTimes) % loop on session time - earlier is off meds 
            idxPlot = dbPat.timeStartSession == unqTimes(t);
            dbPlot = dbPat(idxPlot,:); 
            unqTitrations = unique(dbPlot.timeStartDataSection);
            for u = 1:length(unqTitrations)
                idxSection = unqTitrations(u) == dbPlot.timeStartDataSection;
                dbSection = dbPlot(idxSection,:);
                cntplt = 1;
                for r = 1:size(dbSection,1) % loop on all 4 channels 
                    for pv = 1:2 % loop on 2 power bands within channel 
                        hsb = hpanel(r,pv).select();
                        axes(hsb);
                        hold(hsb,'on'); 
                        fnuse = sprintf('power%d',pv); 
                        powerVals = dbSection.(fnuse){r};
                        meanPowerval = mean(powerVals); 
                        stimLevel = dbSection.stimLevel(r);
                        fnPowerVals = sprintf('power%d_Vals',pv);
                        embedderPower = dbSection.(fnPowerVals){r};
                        % plot value 
                        switch t 
                            case 1 % off meds 
                                clrUse = [0.8 0 0];
                            case 2 
                                clrUse = [0 0.8 0];
                        end
                        tdFrqs = dbSection.tdFreqs{r};
                        tdPwer = dbSection.tdPower{r};
                        idxusefreq = tdFrqs >= embedderPower(1) & tdFrqs <= embedderPower(2);
                        meanPower = mean(tdPwer(idxusefreq));
                        
                        hsc = scatter(meanPower,meanPowerval,100,'filled',...
                            'MarkerFaceColor',clrUse,...
                            'MarkerFaceAlpha',0.4);
                        xlabel('Power computed');
                        ylabel('Embedded power'); 
                        ttlstr = sprintf('%s %.2f(Hz)-%.2f(Hz)',...
                            dbSection.senseElectrode{r},...
                            embedderPower(1),embedderPower(2));
                        title(ttlstr); 
                    end
                end
            end
        end
        %%
        hpanel.fontsize = 10;  % global font
        hpanel.de.margin = 15;
        hpanel.marginleft =  20;
        hpanel.marginright =  20;
        hpanel.margintop =  10;
        hpanel.marginbottom =  10;
        hfig.PaperPositionMode = 'manual';
        prfig.plotwidth           = 12;
        prfig.plotheight          = 9;
        prfig.figdir             = figdir;
        figname = sprintf('%s_%s_all_embedded_vs_computed_power',uniqePatients{p},uniqueSides{s});
        prfig.figname             = figname;
        prfig.figtype             = '-dpdf';
        plot_hfig(hfig,prfig)
        
    end
end
%%


useThis = 1;
if useThis
    figdir = '/Users/roee/Box/Starr_Lab_Folder/Data_Analysis/RCS_data/results/stim_titrations_2/figures';
    ff = findFilesBVQX(rootdir,'DeviceSettings.json');
    
    hfig = figure;
    hfig.Color = 'w';
    
    cntFnd = 0;
    for f = 1:length(ff)
        [pn,~] = fileparts(ff{f});
        [outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerOut,adaptiveTable] =  ...
            MAIN_load_rcs_data_from_folder(pn);
        ds = get_meta_data_from_device_settings_file(ff{f});
        %%
        
        idxStartStop = cellfun(@(x) any(strfind(x,'StimSweep')),eventTable.EventType);
        eventTableUse = eventTable(idxStartStop,:);
        idxStart = cellfun(@(x) any(strfind(lower(x),'start')),eventTableUse.EventType);
        idxEnd = cellfun(@(x) any(strfind(lower(x),'stop')),eventTableUse.EventType);
        eStart = eventTableUse(idxStart,:);
        eEnd = eventTableUse(idxEnd,:);
        durations = eEnd.HostUnixTime - eStart.HostUnixTime;
        idxuse = durations > seconds(25);
        eStart = eStart(idxuse,:);
        eEnd = eEnd(idxuse,:);

        for e = 1:size(eStart,1)
            times(e,1) = datetime(eStart.UnixOffsetTime(e));
            times(e,2) = datetime(eEnd.UnixOffsetTime(e));
            strExtract = eStart.EventSubType{e};
            [StrMatch] = strExtract(29:50);
            strRaw = split(StrMatch,',');
            [st, ~] = regexp(strExtract,'mA.');
            stimLevels(e) = str2num(strRaw{1});
        end
        if ~isempty(eStart)
            cntFnd = cntFnd + 1;
            idxGroup = cellfun(@(x) any(strfind(lower(x),'003')),eventTable.EventType);
            strGroup = eventTable.EventType(idxGroup);
            if ~isempty(strGroup)
                groupUse = strGroup{1}(end);
            else
                groupUse = 'C';
            end
            stimStateChanges = ds.stimStateChanges{1};
            stimStateChangesSort = stimStateChanges(stimStateChanges.duration > seconds(40),:);
            % what settings were used?
            arState = arStateUse{cntFnd};
            groupUse = groupUseList{cntFnd};
            
            
            %% plot
            timenum = powerOut.powerTable.PacketRxUnixTime;
            t = datetime(timenum/1000,'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
            times.TimeZone = t.TimeZone;
            pt = powerOut.powerTable;
            for bb = 1:8
                subplot(4,2,bb);
                hold on;
                for e = 1:size(times,1)
                    idxuse = t > times(e,1) & t < times(e,2);
                    fnb = sprintf('Band%d',bb);
                    y = pt.(fnb)(idxuse);
                    x = stimLevels(e);
                    fprintf('%d\n',length(x));
                    hsc = scatter(x,mean(y),100,'filled',...
                        'MarkerFaceColor',clrUse{cntFnd},...
                        'MarkerFaceAlpha',0.4,...
                        'MarkerEdgeColor',edgUse{cntFnd});
                    xlabel('Stim amp (mA)');
                    ylabel(['Power:' powerOut.bands(2).powerBandInHz{bb}]);% % XXXX
                    if bb == 1 & e == 1
                        hscLeg(cntFnd) = hsc;
                    end
                    if e == 1
                        hscLegTest(cntFnd,bb) = hsc;
                    end
                    switch bb
                        case 1
                            senseSettings = ds.senseSettings{1}.chan1;
                        case 2
                            senseSettings = ds.senseSettings{1}.chan1;
                        case 3
                            senseSettings = ds.senseSettings{1}.chan2;
                        case 4
                            senseSettings = ds.senseSettings{1}.chan2;
                        case 5
                            senseSettings = ds.senseSettings{1}.chan3;
                        case 6
                            senseSettings = ds.senseSettings{1}.chan3;
                        case 7
                            senseSettings = ds.senseSettings{1}.chan4;
                        case 8
                            senseSettings = ds.senseSettings{1}.chan4;
                    end
                    ttlStr{1,1} = senseSettings{1};
                    ttlStr{1,2} = powerOut.bands(2).powerBandInHz{bb};
                    title(ttlStr);
                end
                set(gca,'FontSize',10);
            end
            titleStr{1,1} = sprintf('Group %s',groupUse);
            titleStr{2,1} = sprintf('Stim elec: %s %.2f',ds.stimStatus{1}.electrodes{1},ds.stimStatus{1}.rate_Hz);
            titleStr{3,1} = sprintf('active recharge %s',arState);
            sgtitle(titleStr,'FontSize',10);
            
        end
    end
    hsb = hfig.Children(end);
    legend(hscLeg,condsLeg);
    %
    % bb = 1;
    % for i = 1:4
    %     for j = 1:2
    %         axes(subplot(i,j,bb));
    %         legend(hscLegTest(:,bb)',condsLeg');
    %         bb = bb + 1;
    %     end
    % end
    prfig.plotwidth           = 8.5*1.8;
    prfig.plotheight          = 11*1.6;
    prfig.figdir             = figdir;
    prfig.figname             = sprintf('%s_COMPARE_ALL_CONDS',patinetAndSide);
    plot_hfig(hfig,prfig)
end

end