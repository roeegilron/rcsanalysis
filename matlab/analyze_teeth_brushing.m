function analyze_teeth_brushing()
addpath(genpath('/Users/roee/Documents/Code/Analysis-rcs-data/code'));
%%
close all;
rootdir = '/Users/roee/Box/RC-S_Studies_Regulatory_and_Data/Patient In-Clinic Data';
figdirout = '/Users/roee/Box/RC-S_Studies_Regulatory_and_Data/Patient In-Clinic Data/figures/brushing_exp';
resdir = '/Users/roee/Box/RC-S_Studies_Regulatory_and_Data/Patient In-Clinic Data/figures/brushing_exp/results';
foundDir1 = findFilesBVQX(rootdir,'*shing',struct('dirs',1,'depth',2));
foundDir2 = findFilesBVQX(rootdir,'*shing',struct('dirs',1,'depth',1));
foundDirs = [foundDir1, foundDir2];
%% if save results, and plot psds
saveAndPlot = 0;
if saveAndPlot
    
    for f = 1:length(foundDirs)
        if exist(fullfile(foundDirs{f},'database','database_from_device_settings.mat'),'file')
            load(fullfile(foundDirs{f},'database','database_from_device_settings.mat'))
        else
            create_database_from_device_settings_files(foundDirs{f});
            load(fullfile(foundDirs{f},'database','database_from_device_settings.mat'))
        end
        if f == 1
            tableTask = masterTableOut;
        else
            tableTask = [tableTask; masterTableOut];
        end
    end
    %% load data chunks
    uniquePatients = unique(tableTask.patient);
    uniqueSides    = unique(tableTask.side);
    eventFind = {'rest','brushing'};
    colorsUse = [0.8 0 0 0.7;
        0 0.8 0 0.7];
    
    brushingData = table();
    cntDat = 1;
    for p = 1:size(uniquePatients,1)
        idxPatient = strcmp(tableTask.patient,uniquePatients{p});
        hfig = figure;
        hfig.Color = 'w';
        for s = 1:size(uniqueSides,1)
            idxSide    = strcmp(tableTask.side,uniqueSides{s});
            tblPatient = tableTask(idxPatient & idxSide,:);
            if ~isempty(tblPatient)
                for n = 1:size(tblPatient,1) % loop on instances
                    [pn,~] = fileparts(tblPatient.deviceSettingsFn{n});
                    [outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerOut,adaptiveTable] =  MAIN_load_rcs_data_from_folder(pn);
                    [combinedDataTable, debugTable, timeDomainSettings,powerSettings,...
                        fftSettings,metaData,stimSettingsOut,stimMetaData,stimLogSettings,...
                        DetectorSettings,AdaptiveStimSettings,AdaptiveRuns_StimSettings] = DEMO_ProcessRCS(pn);
                    ts = datetime(combinedDataTable.DerivedTime/1000,...
                        'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
                    combinedDataTable.DerivedTimeHuman = ts; 
                    eventTable = allign_events_time_domain_time(eventTable,outdatcomplete);
                    fprintf(uniquePatients{p})
                    if s == 1
                        cntplt = 1;
                    else
                        cntplt = 5;
                    end
                    if strcmp(uniquePatients{p},'RCS03')
                        % this patient didn't create the strings required times
                        % requried. create fake times and movify them
                        figure; 
                        idxkeep = ~isnan(combinedDataTable.Accel_XSamples);
                        hold on;
                        plot(combinedDataTable.DerivedTimeHuman(idxkeep), combinedDataTable.Accel_XSamples(idxkeep));
                        plot(combinedDataTable.DerivedTimeHuman(idxkeep), combinedDataTable.Accel_YSamples(idxkeep));
                        plot(combinedDataTable.DerivedTimeHuman(idxkeep), combinedDataTable.Accel_ZSamples(idxkeep));
                        
                        
                        % add rest start 
                        cntEvent = size(eventTable,1);
                        eventTable(cntEvent + 1,:) = eventTable(cntEvent,:);
                        cntEvent = cntEvent + 1; 
                        eventTable.EventSubType{cntEvent} = 'Rest Start';
                        eventTable.UnixOffsetTime(cntEvent) = datetime('21-Dec-2020 21:45:24.000','TimeZone','America/Los_Angeles');                        
                        % add rest end 
                        cntEvent = size(eventTable,1);
                        eventTable(cntEvent + 1,:) = eventTable(cntEvent,:);
                        cntEvent = cntEvent + 1; 
                        eventTable.EventSubType{cntEvent} = 'Rest End';
                        eventTable.UnixOffsetTime(cntEvent) = datetime('21-Dec-2020 21:46:15.000','TimeZone','America/Los_Angeles');                        
                        % add brushing start 
                        cntEvent = size(eventTable,1);
                        eventTable(cntEvent + 1,:) = eventTable(cntEvent,:);
                        cntEvent = cntEvent + 1; 
                        eventTable.EventSubType{cntEvent} = 'Brushing Start';
                        eventTable.UnixOffsetTime(cntEvent) = datetime('21-Dec-2020 21:49:59.000','TimeZone','America/Los_Angeles');                        
                        % add brushing start 
                        cntEvent = size(eventTable,1);
                        eventTable(cntEvent + 1,:) = eventTable(cntEvent,:);
                        cntEvent = cntEvent + 1; 
                        eventTable.EventSubType{cntEvent} = 'Brushing End';
                        eventTable.UnixOffsetTime(cntEvent) = datetime('21-Dec-2020 21:50:55.000','TimeZone','America/Los_Angeles');                        
                        
                    end
                    
                    %% loop on channels, and select a data chunk with no intereference                                            for e = 1:length(eventFind) % loop on events
                    for e = 1:length(eventFind) % loop on events
                        idxEvents = cellfun(@(x) any(strfind(lower(x),eventFind{e})),eventTable.EventSubType);
                        eventsUsed = eventTable(idxEvents,:);
                        % XXX 
                        startTime = eventsUsed.UnixOffsetTime(1) + seconds(3);
                        endTime = eventsUsed.UnixOffsetTime(2)  - seconds(3);
                        % time domain data
                        t = combinedDataTable.DerivedTimeHuman;
                        idxuse = t > startTime & t < endTime;
                        timeUse = t(idxuse);
                        timeUse = timeUse - timeUse(1);
                        
                        
                        % make figure 
                        addpath(genpath(fullfile(pwd,'toolboxes','panel-2.14')));
                        hfig = figure;
                        hpanel = panel();
                        hpanel.pack(5,3);

                        % plot time domain 
                        for c = 1:4 % loop on channels
                            hsb(c,1) = hpanel(c,1).select();
                            hold on;
                            chanfn = sprintf('TD_key%d',c-1);
                            sr = tblPatient.senseSettings{1}.samplingRate;
                            chunkUse = combinedDataTable.(chanfn)(idxuse);
                            y = chunkUse - nanmean(chunkUse);
                            % first make sure that y does'nt have NaN's at
                            % check start:
                            timeUseRaw = timeUse;
                            cntNan = 1;
                            if isnan(y(1))
                                while isnan(y(cntNan))
                                    cntNan = cntNan + 1;
                                end
                            end
                            y = y(cntNan:end); 
                            cntStart = cntNan;
                            timeUse = timeUse(cntNan:end);
                            % check end:
                            cntNan = length(y);
                            if isnan(y(cntNan))
                                while isnan(y(cntNan))
                                    cntNan = cntNan - 1;
                                end
                            end
                            cntEnd = cntNan;
                            y = y(1:cntNan); 
                            timeUse = timeUse(1:cntNan);
                            plot(hsb(c),timeUse,y)
                            % plot spectral 
                            hsb(c,2) = hpanel(c,2).select();
                            yFilled = fillmissing(y,'constant',0);
                            [sss,fff,ttt,ppp] = spectrogram(yFilled,kaiser(128,5),64,512,sr,'yaxis');
                            % put nan's in gaps for spectral 
                            
                            
                            idxGapStart = find(diff(isnan(y))==1) + 1; 
                            idxGapEnd = find(diff(isnan(y))==-1) + 1; 
                            for te = 1:size(idxGapStart,1)
                                timeGap(te,1) = seconds(timeUse(idxGapStart(te))) - 0.5;
                                timeGap(te,2) = seconds(timeUse(idxGapEnd(te))) + 0.5;
                                idxBlank = ttt >= timeGap(te,1) & ttt <= timeGap(te,2);
                                if  strcmp(uniquePatients{p},'RCS03') % a lot of missing data 
                                else
                                    ppp(:,idxBlank) = NaN;
                                end
                            end
                            % compute pwelch, but only on sections larger
                            % than 10 seconds 
                            idxGapStart = [1; idxGapStart];
                            idxGapEnd   = [idxGapEnd; length(timeUse)];
                            idxGaps = [idxGapStart , idxGapEnd];
                            if  strcmp(uniquePatients{p},'RCS03') % a lot of missing data
                                idxGapsKeep = timeUse(idxGaps(:,2) - idxGaps(:,1)) >= seconds(1.5);
                            else
                                idxGapsKeep = timeUse(idxGaps(:,2) - idxGaps(:,1)) >= seconds(10);
                            end
                            durations   = timeUse(idxGaps(:,2) - idxGaps(:,1)); 
                            idxGaps = idxGaps( idxGapsKeep,:);
                            durations   = timeUse(idxGaps(:,2) - idxGaps(:,1)); 
                            for ii = 1:size(idxGaps,1)
                                yGap = y(idxGaps(ii,1) : idxGaps(ii,2));
                                yGap = yGap(~isnan(yGap));
                                [fftOut(ii,:),freqs]   = pwelch(yGap.*1e3,sr,sr/2,2:1:(sr/2 - 50),sr,'psd');
                                
                            end
                            
                            surf(hsb(c,2),seconds(ttt), fff, 10*log10(ppp), 'EdgeColor', 'none');
                            colormap(hsb(c,2),jet)
                            shading(hsb(c,2),'interp');
                            view(hsb(c,2),2);
                            axis(hsb(c,2),'tight');
                            
                            
                            % plot psd data  
                            hsb(c,3) = hpanel(c,3).select();
                            plot(hsb(c,3),freqs,log10(mean(fftOut,1)));
                            xlim(hsb(c,3),[0 100]);
                                                        
                            
                            
                            % save data
                            xAccChunk = combinedDataTable.Accel_XSamples(idxuse);
                            xAcc = xAccChunk - nanmean(xAccChunk);
                            yAccChunk = combinedDataTable.Accel_YSamples(idxuse);
                            yAcc = yAccChunk - nanmean(yAccChunk);
                            zAccChunk = combinedDataTable.Accel_ZSamples(idxuse);
                            zAcc = zAccChunk - nanmean(zAccChunk);
                            % resample actigraphy for saving:
                            [xAccResample,xTimes] = resample(xAcc,seconds(timeUseRaw),sr);
                            [yAccResample,yTimes] = resample(yAcc,seconds(timeUseRaw),sr);
                            [zAccResample,zTimes] = resample(zAcc,seconds(timeUseRaw),sr);
                            
                            
                            brushingData.patient{cntDat} = tblPatient.patient{n};
                            brushingData.side{cntDat} = tblPatient.side{n};
                            brushingData.cond{cntDat} = eventFind{e};
                            ttluseChan = tblPatient.senseSettings{1}.TimeDomainDataStruc{1}(c).chanOut;
                            brushingData.chanSense{cntDat} = ttluseChan;
                            brushingData.chanStim{cntDat} = tblPatient.stimStatus{1}.electrodes{1};
                            brushingData.stimRate(cntDat) = tblPatient.stimStatus{1}.rate_Hz;
                            brushingData.stimCurrent(cntDat) = tblPatient.stimStatus{1}.amplitude_mA;
                            brushingData.rawData{cntDat} = y;
                            brushingData.s{cntDat} = sss; % spectral stuff 
                            brushingData.f{cntDat} = fff; % spectral stuff 
                            brushingData.t{cntDat} = ttt; % spectral stuff 
                            brushingData.p{cntDat} = ppp; % spectral stuff 
                            brushingData.freqs{cntDat} = freqs; % pwelch 
                            brushingData.fftOut{cntDat} = log10(mean(fftOut,1)); % pwelch 
                            brushingData.durationsFFt{cntDat} = durations; % pwelche duratiosn 
                            
                            brushingData.xAcc{cntDat} = xAcc;
                            brushingData.xAccResamp{cntDat} = xAccResample;
                            brushingData.yAcc{cntDat} = yAcc;
                            brushingData.yAccResamp{cntDat} = yAccResample;
                            brushingData.zAcc{cntDat} = zAcc;
                            brushingData.zAccResamp{cntDat} = zAccResample;
                            
                            brushingData.timeAcc{cntDat} = xTimes;
                            brushingData.sampleRateAcc{cntDat} = outdatcompleteAcc.samplerate(1);
                            brushingData.time{cntDat} = timeUse;
                            brushingData.sampleRate(cntDat) = sr;
                            cntDat = cntDat + 1;
                        end
                        
                        
                        % plot data actigraphy 
                        hsb(5,1) = hpanel(5,1).select();
                        hold(hsb(5,1),'on');
                        idxplot = ~isnan(xAcc);
                        plot(hsb(5,1),timeUse(idxplot),xAcc(idxplot))
                        plot(hsb(5,1),timeUse(idxplot),yAcc(idxplot))
                        plot(hsb(5,1),timeUse(idxplot),zAcc(idxplot))
                        
                        hsb(5,2) = hpanel(5,2).select();
                        hold(hsb(5,2),'on');
                        plot(hsb(5,2),timeUse(idxplot),xAcc(idxplot))
                        plot(hsb(5,2),timeUse(idxplot),yAcc(idxplot))
                        plot(hsb(5,2),timeUse(idxplot),zAcc(idxplot))
                        linkaxes(hsb(:,1:2),'x');
                        
                        idxPlot = strcmp(brushingData.patient ,tblPatient.patient{1});
                        dataPlot = brushingData(idxPlot,:);
                        ttlUse{1,1} = dataPlot.patient{1};
                        idxR = strcmp(dataPlot.side,'R');
                        dataSide = dataPlot(idxR,:);
                        if ~isempty(dataSide)
                            ttlUse{2,1} = sprintf('R: %s %.2fHz %2.fmA',dataSide.chanStim{1},dataSide.stimRate(1),dataSide.stimCurrent(1));
                            sideUse = 'R';
                        end
                        idxL = strcmp(dataPlot.side,'L');
                        dataSide = dataPlot(idxL,:);
                        if ~isempty(dataSide)
                            ttlUse{2,1} = sprintf('L: %s %.2fHz %2.fmA',dataSide.chanStim{1},dataSide.stimRate(1),dataSide.stimCurrent(1));
                            sideUse = 'L';
                        end
                        ttlUse{3,1} = sprintf('%s',eventFind{e});
                        sgtitle(ttlUse);
                        
                        prfig.plotwidth           = 12;
                        prfig.plotheight          = 18;
                        prfig.figdir             = figdirout;
                        prfig.figname             = sprintf('%s_%s_%s_raw_dat',tblPatient.patient{1},tblPatient.side{1}, eventFind{e});
                        prfig.figtype             = '-djpeg';
                        plot_hfig(hfig,prfig)
                        close(hfig);
                    end
                    %%
%                     
%                     for c = 1:4 % loop on channels
%                         subplot(4,2,cntplt); cntplt = cntplt + 1;
%                         hold on;
%                         chanfn = sprintf('TD_key%d',c-1);
%                         for e = 1:length(eventFind) % loop on events
%                             sr = tblPatient.senseSettings{1}.samplingRate;
%                             idxEvents = cellfun(@(x) any(strfind(lower(x),eventFind{e})),eventTable.EventSubType);
%                             eventsUsed = eventTable(idxEvents,:);
%                             startTime = eventsUsed.insTimes(1) + seconds(10);
%                             endTime = eventsUsed.insTimes(2);  - seconds(10);
%                             % time doain data 
%                             t = combinedDataTable.DerivedTimeHuman;
%                             idxuse = t > startTime & t < endTime;
%                             timeUse = t(idxuse);
%                             timeUse = timeUse - timeUse(1);
%                             chunkUse = combinedDataTable.(chanfn)(idxuse);
%                             y = chunkUse - nanmean(chunkUse);
%                             %%
%                             figure; 
%                             plot(timeUse,y)
%                             %%
%                             % actigraphy 
%                             timeUseActigraphy = outdatcompleteAcc.derivedTimes; 
%                             idxuse = timeUseActigraphy > startTime & timeUseActigraphy < endTime;
%                             timeUseActigraphy = timeUseActigraphy(idxuse);
%                             timeUseActigraphy = timeUseActigraphy - timeUseActigraphy(1);
%                             xAccChunk = outdatcompleteAcc.XSamples(idxuse);
%                             xAcc = xAccChunk - mean(xAccChunk);
%                             yAccChunk = outdatcompleteAcc.YSamples(idxuse);
%                             yAcc = yAccChunk - mean(yAccChunk);
%                             zAccChunk = outdatcompleteAcc.ZSamples(idxuse);
%                             zAcc = zAccChunk - mean(zAccChunk);
%                             % resample 
%                             [xAccResample,xTimes] = resample(xAcc,seconds(timeUseActigraphy),sr);
%                             [yAccResample,yTimes] = resample(yAcc,seconds(timeUseActigraphy),sr);
%                             [zAccResample,zTimes] = resample(zAcc,seconds(timeUseActigraphy),sr);
%                             if length(xAccResample) > length(timeUse)
%                                 xAccResam = xAccResample(1:length(timeUse));
%                                 yAccResam = yAccResample(1:length(timeUse));
%                                 zAccResam = zAccResample(1:length(timeUse));
%                             else
%                                 y = y(1:length(xAccResample));
%                                 timeUse = timeUse(1:length(xAccResample));
%                             end
%                             
%                             sr = tblPatient.senseSettings{1}.samplingRate;
%                             [fftOut,f]   = pwelch(y.*1e3,sr,sr/2,2:1:(sr/2 - 50),sr,'psd');
%                             hplt = plot(f,log10(fftOut));
%                             hplt.LineWidth = 2;
%                             hplt.Color = colorsUse(e,:);
%                             % save data
%                             brushingData.patient{cntDat} = tblPatient.patient{n};
%                             brushingData.side{cntDat} = tblPatient.side{n};
%                             brushingData.cond{cntDat} = eventFind{e};
%                             ttluseChan = tblPatient.senseSettings{1}.TimeDomainDataStruc{1}(c).chanOut;
%                             brushingData.chanSense{cntDat} = ttluseChan;
%                             brushingData.chanStim{cntDat} = tblPatient.stimStatus{1}.electrodes{1};
%                             brushingData.stimRate(cntDat) = tblPatient.stimStatus{1}.rate_Hz;
%                             brushingData.stimCurrent(cntDat) = tblPatient.stimStatus{1}.amplitude_mA;
%                             brushingData.rawData{cntDat} = y;
%                             brushingData.xAcc{cntDat} = xAcc;
%                             brushingData.xAccResamp{cntDat} = xAccResam;
%                             brushingData.yAcc{cntDat} = yAcc;
%                             brushingData.yAccResamp{cntDat} = yAccResam;
%                             brushingData.zAcc{cntDat} = zAcc;
%                             brushingData.zAccResamp{cntDat} = zAccResam;
%                             
%                             brushingData.timeAcc{cntDat} = timeUseActigraphy;
%                             brushingData.sampleRateAcc{cntDat} = outdatcompleteAcc.samplerate(1);
%                             brushingData.time{cntDat} = timeUse;
%                             brushingData.sampleRate(cntDat) = sr;
%                             cntDat = cntDat + 1;
%                             
%                         end
%                         legend(eventFind);
%                         xlim([0 100]);
%                         xticks(gca,[4 12 30 60 65 70 75 80]);
%                         hsb = gca;
%                         hsb.XTickLabelRotation = 45;
%                         set(hsb,'FontSize',10);
%                         grid on;
%                         ttluseChan = tblPatient.senseSettings{1}.TimeDomainDataStruc{1}(c).chanOut;
%                         ttluse = sprintf('%s %s side',ttluseChan,tblPatient.side{n});
%                         title(ttluse);
%                     end
%                     fprintf('\n\n');
%                     unique(eventTable.EventSubType)
%                     fprintf('\n\n');
                end

                
            end
        end
%         idxPlot = strcmp(brushingData.patient ,tblPatient.patient{1});
%         dataPlot = brushingData(idxPlot,:);
%         ttlUse{1,1} = dataPlot.patient{1};
%         idxR = strcmp(dataPlot.side,'R');
%         dataSide = dataPlot(idxR,:);
%         ttlUse{2,1} = sprintf('R: %s %.2fHz %2.fmA',dataSide.chanStim{1},dataSide.stimRate(1),dataSide.stimCurrent(1));
%         idxL = strcmp(dataPlot.side,'L');
%         dataSide = dataPlot(idxL,:);
%         ttlUse{3,1} = sprintf('L: %s %.2fHz %2.fmA',dataSide.chanStim{1},dataSide.stimRate(1),dataSide.stimCurrent(1));
%         sgtitle(ttlUse);
% 
%         prfig.plotwidth           = 12;
%         prfig.plotheight          = 18;
%         prfig.figdir             = figdirout;
%         prfig.figname             = sprintf('%s_%s_psds',tblPatient.patient{1},dataPlot.side{1},);
%         prfig.figtype             = '-djpeg';
%         plot_hfig(hfig,prfig)
%         close(hfig);
    end
    save(fullfile(resdir,'brushing_data.mat'),'brushingData');
end
%% plot psd 
plotpsd = 0;
if plotpsd
    load(fullfile(resdir,'brushing_data.mat'),'brushingData');
    % plot spectral represetnations of the data
    uniquePatients = unique(brushingData.patient);
    uniqueSides    = unique(brushingData.side);
    eventFind = {'rest','brushing'};
    colorsUse = [0.8 0 0 0.7;
        0 0.8 0 0.7];
    %%
    cntDat = 1;
    
    for p = 1:size(uniquePatients,1)
        idxPatient = strcmp(brushingData.patient,uniquePatients{p});
        dataPlot = brushingData(idxPatient,:);
        uniqueSides = unique(dataPlot.side); 
        addpath(genpath(fullfile(pwd,'toolboxes','panel-2.14')));
        hfig = figure;
        hfig.Color = 'w';
        hpanel = panel();
        hpanel.pack('v',{0.1 0.9});
        hpanel(2).pack(3,2);

        for ss = 1:length(uniqueSides)
            idxSide  = strcmp(dataPlot.side,uniqueSides{ss});
            dataPlotSide = dataPlot(idxSide,:);
            uniqueElectrodes = unique(dataPlotSide.chanSense);
            uniqueConditions = unique(dataPlotSide.cond);
            for ee = 1:length(uniqueElectrodes)
                for cc = 1:length(uniqueConditions)
                    idxPlot = strcmp(uniqueElectrodes{ee},dataPlotSide.chanSense) & ... 
                        strcmp(uniqueConditions{cc},dataPlotSide.cond);
                    dataToPlot = dataPlotSide(idxPlot,:);
                    fftOut = mean(cell2mat(dataToPlot.fftOut),1);
                    hsb = hpanel(2,ee,ss).select();
                    hold(hsb,'on');
                    hplt(cc) = plot(hsb,dataToPlot.freqs{1},fftOut);
                    switch uniqueConditions{cc}
                        case 'brushing'
                            clrUse = [0 0.8 0 0.8];
                        case 'rest'
                            clrUse = [0.8 0.0 0 0.8];
                    end
                    hplt(cc).Color = clrUse;
                    hplt(cc).LineWidth = 3;
                    ttluse = sprintf('%s %s' ,dataToPlot.chanSense{1},dataToPlot.side{1});
                    title(ttluse);
                    xlim(hsb,[0 100])
                    hsb.XTick = [4 12 30 50 60 65 70 75 80 100];
                    set(gca,'FontSize',10);
                    ylabel(hsb,'Power (log_1_0\muV^2/Hz)');
                    xlabel(hsb,'Frequency (Hz');
                end
                legend(uniqueConditions);
                grid on;
            end

            ttlUse{1,1} = dataPlot.patient{1};
            idxR = strcmp(dataPlot.side,'R');
            dataSide = dataPlot(idxR,:);
            ttlUse{2,1} = sprintf('R: %s %.2fHz %2.fmA',dataSide.chanStim{1},dataSide.stimRate(1),dataSide.stimCurrent(1));
            idxL = strcmp(dataPlot.side,'L');
            dataSide = dataPlot(idxL,:);
            ttlUse{3,1} = sprintf('L: %s %.2fHz %2.fmA',dataSide.chanStim{1},dataSide.stimRate(1),dataSide.stimCurrent(1));
            sgtitle(ttlUse);
            
            
        end
        prfig.plotwidth           = 17;
        prfig.plotheight          = 12;
        prfig.figdir             = figdirout;
        prfig.figname             = sprintf('%s_psds',dataPlot.patient{1});
        prfig.figtype             = '-djpeg';
        plot_hfig(hfig,prfig)
        close(hfig);

        %%
    end
end

%%
plotspect = 0;
if plotspect
    load(fullfile(resdir,'brushing_data.mat'),'brushingData');
    % plot spectral represetnations of the data
    uniquePatients = unique(brushingData.patient);
    uniqueSides    = unique(brushingData.side);
    eventFind = {'rest','brushing'};
    colorsUse = [0.8 0 0 0.7;
        0 0.8 0 0.7];
    %%
    cntDat = 1;
    
    for p = 1:size(uniquePatients,1)
        idxPatient = strcmp(brushingData.patient,uniquePatients{p});
        dataPlot = brushingData(idxPatient,:);
        %%
        hfig = figure;
        hfig.Color = 'w';
        for b = 1:size(dataPlot,1)
            hsub(b) = subplot(4,4,b);
            data = dataPlot.rawData{b};
            fs = dataPlot.sampleRate(b);
            ttt = dataPlot.t{b};
            fff = dataPlot.f{b};
            ppp = dataPlot.p{b};
            surf(hsub(b),seconds(ttt), fff, 10*log10(ppp), 'EdgeColor', 'none');
            ylim(hsub(b),[2 100]);
            colormap(hsub(b),jet)
            shading(hsub(b),'interp');
            view(hsub(b),2);
            axis(hsub(b),'tight');
            
            ttluse = sprintf('%s %s %s' ,dataPlot.chanSense{b},dataPlot.side{b},dataPlot.cond{b});
            title(ttluse);
            ylim([0 100])
            hsub(b).YTick = [4 12 30 50 60 65 70 75 80 100];
            set(gca,'FontSize',10);
        end
        ttlUse{1,1} = dataPlot.patient{1};
        idxR = strcmp(dataPlot.side,'R');
        dataSide = dataPlot(idxR,:);
        ttlUse{2,1} = sprintf('R: %s %.2fHz %2.fmA',dataSide.chanStim{1},dataSide.stimRate(1),dataSide.stimCurrent(1));
        idxL = strcmp(dataPlot.side,'L');
        dataSide = dataPlot(idxL,:);
        ttlUse{3,1} = sprintf('L: %s %.2fHz %2.fmA',dataSide.chanStim{1},dataSide.stimRate(1),dataSide.stimCurrent(1));
        sgtitle(ttlUse);
        
        prfig.plotwidth           = 17;
        prfig.plotheight          = 12;
        prfig.figdir             = figdirout;
        prfig.figname             = sprintf('%s_spectorgram',dataPlot.patient{1});
        prfig.figtype             = '-djpeg';
        plot_hfig(hfig,prfig)
        close(hfig);
        %%
    end
end
close all;
%% pac
plotPac = 0;
addpath(genpath('/Users/roee/Documents/Code/PAC'));

if plotPac 
    load(fullfile(resdir,'brushing_data.mat'),'brushingData');
    
    
    %% pac params
    pacparams.PhaseFreqVector      = 5:2:50;
    pacparams.AmpFreqVector        = 10:5:180;
    
    pacparams.PhaseFreq_BandWidth  = 4;
    pacparams.AmpFreq_BandWidth    = 10;
    pacparams.computeSurrogates    = 0;
    pacparams.numsurrogate         = 0;
    pacparams.alphause             = 0.05;
    pacparams.plotdata             = 0;
    pacparams.useparfor            = 0; % if true, user parfor, requires parallel computing toolbox
    

     % plot spectral represetnations of the data
    uniquePatients = unique(brushingData.patient);
    uniqueSides    = unique(brushingData.side);
    eventFind = {'rest','brushing'};
    colorsUse = [0.8 0 0 0.7;
        0 0.8 0 0.7];
    %%
    cntDat = 1;
    
    for p = 1:size(uniquePatients,1)
        idxPatient = strcmp(brushingData.patient,uniquePatients{p});
        dataPlot = brushingData(idxPatient,:);
        %%
        hfig = figure;
        hfig.Color = 'w';
        for b = 1:size(dataPlot,1)
            hsub(b) = subplot(4,4,b);
            data = dataPlot.rawData{b};
            fs = dataPlot.sampleRate(b);
            results = computePAC(data',fs,pacparams);
            %% pac plot
            contourf(results.PhaseFreqVector+results.PhaseFreq_BandWidth/2,...
                results.AmpFreqVector+results.AmpFreq_BandWidth/2,...
                results.Comodulogram',30,'lines','none')
            shading interp
            ttluse = sprintf('%s %s %s' ,dataPlot.chanSense{b},dataPlot.side{b},dataPlot.cond{b});
            title(ttluse);
            set(gca,'FontSize',10);
        end
        ttlUse{1,1} = dataPlot.patient{1};
        idxR = strcmp(dataPlot.side,'R');
        dataSide = dataPlot(idxR,:);
        ttlUse{2,1} = sprintf('R: %s %.2fHz %2.fmA',dataSide.chanStim{1},dataSide.stimRate(1),dataSide.stimCurrent(1));
        idxL = strcmp(dataPlot.side,'L');
        dataSide = dataPlot(idxL,:);
        ttlUse{3,1} = sprintf('L: %s %.2fHz %2.fmA',dataSide.chanStim{1},dataSide.stimRate(1),dataSide.stimCurrent(1));
        sgtitle(ttlUse);

        
        prfig.plotwidth           = 17;
        prfig.plotheight          = 12;
        prfig.figdir             = figdirout;
        prfig.figname             = sprintf('%s_PAC',dataPlot.patient{1});
        prfig.figtype             = '-djpeg';
        plot_hfig(hfig,prfig)
        close(hfig);
        %%
    end
end
close all;
%% coherence
plotCoherence = 0;
chanPairs = {'+10-8','+11-9'};
if plotCoherence 
    eventFind = {'rest','brushing'};
    colorsUse = [0.8 0 0 0.7;
        0 0.8 0 0.7];

    load(fullfile(resdir,'brushing_data.mat'),'brushingData');
    
     % plot spectral represetnations of the data
    uniquePatients = unique(brushingData.patient);
    uniqueSides    = unique(brushingData.side);
    eventFind = {'rest','brushing'};
    colorsUse = [0.8 0 0 0.7;
        0 0.8 0 0.7];
    %%
    cntDat = 1;
    
    for p = 1:size(uniquePatients,1)
        idxPatient = strcmp(brushingData.patient,uniquePatients{p});
        dataPlot = brushingData(idxPatient,:);
        %%
        hfig = figure;
        hfig.Color = 'w';
        uniqueSides = unique(dataPlot.side); 
        for c = 1:4
            hsub(c) = subplot(2,2,c); 
            hold(hsub(c),'on');
        end
        for s = 1:length(uniqueSides)
            idxSide = strcmp(dataPlot.side,uniqueSides{s});
            tblSide = dataPlot(idxSide,:);
            idxPair1 = strcmp(tblSide.chanSense,chanPairs{1});
            idxPair2 = strcmp(tblSide.chanSense,chanPairs{2});
            idxSTN = ~idxPair1 & ~idxPair2;
            tblCompare = tblSide(idxSTN,:);
            for c = 1:length(chanPairs)
                idxPair = strcmp(tblSide.chanSense,chanPairs{c});
                tblPair = tblSide(idxPair,:);
                for e = 1:length(eventFind)
                    idxEvent = strcmp(tblCompare.cond,eventFind{e});
                    tblCompareEvent  = tblCompare(idxEvent,:);
                    idxEvent = strcmp(tblPair.cond,eventFind{e});
                    tblPairEvent = tblPair(idxEvent,:);
                    if s == 1 & c == 1 
                        pltidx = 1;
                    elseif s == 2 & c == 1 
                        pltidx = 2;
                    elseif s == 1 & c == 2 
                        pltidx = 3;
                    elseif s == 2 & c == 2 
                        pltidx = 4;
                    end
                    y1 = tblCompareEvent.rawData{1};
                    y2 = tblPairEvent.rawData{1};
                    Fs = tblPairEvent.sampleRate(1);
                    [Cxy,F] = mscohere(y1',y2',...
                        2^(nextpow2(Fs)),...
                        2^(nextpow2(Fs/2)),...
                        2^(nextpow2(Fs)),...
                        Fs);
                    hplot = plot(hsub(pltidx),F,Cxy);
                    xlabel('Freq (Hz)');
                    ylabel('MS Coherence');
                    hplot.Color = colorsUse(e,:);
                    hplot.LineWidth = 2;
                    xlim(hsub(pltidx),[2 100]);
                    hsub(pltidx).XTick = [4 12 30 50 65 70 75 80];
                    ttluse = sprintf('ms coh %s-%s',tblCompareEvent.chanSense{1},tblPairEvent.chanSense{1});
                    title(hsub(pltidx),ttluse);

                end
            end
        end
       
        for c = 1:4
            legend(hsub(c),eventFind);
        end
        ttlUse{1,1} = dataPlot.patient{1};
        idxR = strcmp(dataPlot.side,'R');
        dataSide = dataPlot(idxR,:);
        ttlUse{2,1} = sprintf('R: %s %.2fHz %2.fmA',dataSide.chanStim{1},dataSide.stimRate(1),dataSide.stimCurrent(1));
        idxL = strcmp(dataPlot.side,'L');
        dataSide = dataPlot(idxL,:);
        ttlUse{3,1} = sprintf('L: %s %.2fHz %2.fmA',dataSide.chanStim{1},dataSide.stimRate(1),dataSide.stimCurrent(1));
        sgtitle(ttlUse);

        prfig.plotwidth           = 17;
        prfig.plotheight          = 12;
        prfig.figdir             = figdirout;
        prfig.figname             = sprintf('%s_coherence',dataPlot.patient{1});
        prfig.figtype             = '-djpeg';
        plot_hfig(hfig,prfig)
        close(hfig);
        %%
    end
end
close all;

%% plot pac with actigraphy changes 
%% pac
plotPacActigraphy = 0;
addpath(genpath('/Users/roee/Documents/Code/PAC'));

if plotPacActigraphy 
    load(fullfile(resdir,'brushing_data.mat'),'brushingData');
    
    
    %% pac params
    pacparams.PhaseFreqVector      = 1:1:10;
    pacparams.AmpFreqVector        = 10:5:100;
    
    pacparams.PhaseFreq_BandWidth  = 2;
    pacparams.AmpFreq_BandWidth    = 10;
    pacparams.computeSurrogates    = 0;
    pacparams.numsurrogate         = 0;
    pacparams.alphause             = 0.05;
    pacparams.plotdata             = 0;
    pacparams.useparfor            = 0; % if true, user parfor, requires parallel computing toolbox
    pacparams.regionnames          = {'acc','lfp'}; 
    pacparams.plotdata             = 0;
   
     % plot spectral represetnations of the data
    uniquePatients = unique(brushingData.patient);
    uniqueSides    = unique(brushingData.side);
    eventFind = {'rest','brushing'};
    colorsUse = [0.8 0 0 0.7;
        0 0.8 0 0.7];
    %%
    cntDat = 1;
    
    for p = 1:size(uniquePatients,1)
        idxPatient = strcmp(brushingData.patient,uniquePatients{p});
        dataPlot = brushingData(idxPatient,:);
        %%
        hfig = figure;
        hfig.Color = 'w';
        for b = 1:size(dataPlot,1)
            hsub(b) = subplot(4,4,b);
            data = dataPlot.rawData{b};
            fs = dataPlot.sampleRate(b);
            % find the contra lateral side 
            sideUse = dataPlot.side(b);
            if strcmp(sideUse{1},'L')
                sideGetAcc = 'L';
            elseif strcmp(sideUse{1},'R')
                sideGetAcc = 'R';
            end
            idxSideAcc = strcmp(dataPlot.side,sideGetAcc);
            dataAccTable = dataPlot(idxSideAcc,:);
            idxCond = strcmp(dataAccTable.cond,dataPlot.cond(b));
            dataAccTableUse = dataAccTable(idxCond,:);
            dataAccRaw = dataAccTableUse.yAccResamp{1};% should all be same 
            if length(dataAccRaw) > length(data)
                dataAccRaw = dataAccRaw(1:length(data));
            else
                data = data(1:length(dataAccRaw));
            end
            dataPac = [];
            dataPac(:,1) = dataAccRaw;
            dataFilled = fillmissing(data,'constant',0);
            dataPac(:,2) = dataFilled;
            results = computePAC(dataPac',fs,pacparams);
            results = results(4); 
            %% pac plot
            contourf(results.PhaseFreqVector+results.PhaseFreq_BandWidth/2,...
                results.AmpFreqVector+results.AmpFreq_BandWidth/2,...
                results.Comodulogram',30,'lines','none')
            shading interp
            ttluse = sprintf('%s %s %s' ,dataPlot.chanSense{b},dataPlot.side{b},dataPlot.cond{b});
            title(ttluse);
            xlabel(sprintf('acc (chest) %s',sideGetAcc));
            ylabel(sprintf('amp (brain) %s',sideUse{1}));
            set(gca,'FontSize',10);
        end
        ttlUse{1,1} = dataPlot.patient{1};
        idxR = strcmp(dataPlot.side,'R');
        dataSide = dataPlot(idxR,:);
        ttlUse{2,1} = sprintf('R: %s %.2fHz %2.fmA',dataSide.chanStim{1},dataSide.stimRate(1),dataSide.stimCurrent(1));
        idxL = strcmp(dataPlot.side,'L');
        dataSide = dataPlot(idxL,:);
        ttlUse{3,1} = sprintf('L: %s %.2fHz %2.fmA',dataSide.chanStim{1},dataSide.stimRate(1),dataSide.stimCurrent(1));
        sgtitle(ttlUse);

        
        prfig.plotwidth           = 17;
        prfig.plotheight          = 12;
        prfig.figdir             = figdirout;
        prfig.figname             = sprintf('%s_PACvsAcc_ipsi',dataPlot.patient{1});
        prfig.figtype             = '-djpeg';
        plot_hfig(hfig,prfig)
        close(hfig);
        %%
    end
end
close all;
%% %% plot allign to peak of actigraphy brushing  
plot_alligned = 1;
if plot_alligned
    load(fullfile(resdir,'brushing_data.mat'),'brushingData');
    % plot spectral represetnations of the data
    uniquePatients = unique(brushingData.patient);
    uniqueSides    = unique(brushingData.side);
    eventFind = {'brushing'};
    colorsUse = [0.8 0 0 0.7;
        0 0.8 0 0.7];
    %%
    cntDat = 1;
    
    for p = 1:size(uniquePatients,1)
        idxPatient = strcmp(brushingData.patient,uniquePatients{p});
        dataPlot = brushingData(idxPatient,:);
        uniqueSides = unique(dataPlot.side); 
        addpath(genpath(fullfile(pwd,'toolboxes','panel-2.14')));
        hfig = figure;
        hfig.Color = 'w';
        hpanel = panel();
        hpanel.pack('v',{0.1 0.9});
        hpanel(2).pack(3,2);

        for ss = 1:length(uniqueSides)
            idxSide  = strcmp(dataPlot.side,uniqueSides{ss});
            dataPlotSide = dataPlot(idxSide,:);
            uniqueElectrodes = unique(dataPlotSide.chanSense);
            uniqueConditions = unique(dataPlotSide.cond);
            %% plot the actigraphy input data
            idxPlot = strcmp('brushing',dataPlotSide.cond);
            dataToPlot = dataPlotSide(idxPlot,:);

            accPlot = dataToPlot.yAccResamp{1};
            timePlotAcc = dataToPlot.time{1};
            idxkeep = ~isnan(accPlot);
            accPlot = accPlot(idxkeep);
            timePlotAcc = timePlotAcc(idxkeep);
            sr = dataToPlot.sampleRate(1);
            [b,a]        = butter(3,[4 6] / (sr/2),'bandpass'); % user 3rd order butter filter
            y_filt       = filtfilt(b,a,accPlot); %filter all
            threshold = prctile(y_filt,75);
            [PKS,LOCS]=  findpeaks(y_filt,sr,'MinPeakProminence',1);
            
            % plot the actigarphy and the hight points
            hfig2 = figure;
            hfig2.Color = 'w'; 
            subplot(2,1,1);
            hold on;
            plot(seconds(timePlotAcc),y_filt);
            scatter(LOCS,PKS,100,'filled')
            tSpect = [];
            tSpect = dataToPlot.t{1};
            spectData = dataToPlot.p{1};
            title('actigraphy filtered 4-6Hz'); 
            
            subplot(2,1,2);
            sr = 64;
            accPlot = dataToPlot.yAcc{1};
            idxkeep = ~isnan(accPlot);
            yFilled = fillmissing(accPlot(idxkeep),'constant',0);
            [s,f,t,p] = spectrogram(yFilled,64,32,[1:1:20],64);
            pcolor(t, f ,log10(p));            
            colormap('jet')
            shading('interp');
            title('actigraphy spectrogram'); 
            
            ttlUse{1,1} = sprintf('%s %s',dataToPlot.patient{1},dataToPlot.side{1});
            ttlUse{2,1} = sprintf('%s %.2fHz %2.fmA',dataToPlot.chanStim{1},dataToPlot.stimRate(1),dataToPlot.stimCurrent(1));
            sgtitle(ttlUse);
            
            
            prfig.plotwidth           = 17;
            prfig.plotheight          = 10;
            prfig.figdir             = figdirout;
            prfig.figname             = sprintf('%s_%s_actigraphy_brushing_raw',dataToPlot.patient{1},dataToPlot.side{1});
            prfig.figtype             = '-djpeg';
            plot_hfig(hfig2,prfig)
            close(hfig2);

            %%

            for ee = 1:length(uniqueElectrodes)
                for cc = 1%:length(uniqueConditions)
                    idxPlot = strcmp(uniqueElectrodes{ee},dataPlotSide.chanSense) & ... 
                        strcmp(uniqueConditions{cc},dataPlotSide.cond);
                    dataToPlot = dataPlotSide(idxPlot,:);
                    rawData = dataToPlot.rawData;
                    timePlot = dataToPlot.timeAcc{1}; 
                    %%
                    accPlot = dataToPlot.yAccResamp{1};
                    timePlotAcc = dataToPlot.time{1};
                    idxkeep = ~isnan(accPlot);
                    accPlot = accPlot(idxkeep);
                    timePlotAcc = timePlotAcc(idxkeep);
                    sr = dataToPlot.sampleRate(1);
                    [b,a]        = butter(3,[4 6] / (sr/2),'bandpass'); % user 3rd order butter filter
                    y_filt       = filtfilt(b,a,accPlot); %filter all
                    threshold = prctile(y_filt,75);
                    [PKS,LOCS]=  findpeaks(y_filt,sr,'MinPeakProminence',1);
                    
                    %% plot the actigarphy and the hight points 
%                     figure;
%                     hold on;
%                     plot(seconds(timePlotAcc),y_filt);
%                     scatter(LOCS,PKS,100,'filled')
%                     tSpect = [];
%                     tSpect = dataToPlot.t{1};
%                     spectData = dataToPlot.p{1};
%                     
                    %%
                    spectAvg = [];
                    cnt = 1; 
                    % idx move 
                    idxMove = 250; 
                    accData = [];
                    yRaw = dataToPlot.rawData{1};
                    sr = dataToPlot.sampleRate;
                    for ll = 10:length(LOCS)-10
                        [val,idx] =  min(abs(seconds(timePlotAcc)  - LOCS(ll)));
%                         spectAvg(cnt,:,:) = spectData(:,idx-idxMove:idx+idxMove);
                        y = yRaw(idx-idxMove:idx+idxMove);
                        srate = sr;
                        %[s,f,t,p] = spectrogram(y',kaiser(256,5),220,512,srate,'yaxis');
                        if sum(isnan(y))>1
                        else
                            [s,f,t,p] = spectrogram(y,64,32,[40:5:80],500);
                            spectAvg(cnt,:,:) =  p;
                            accData(cnt,:) = y_filt(idx-idxMove:idx+idxMove);
                            cnt = cnt + 1;
                        end
                    end
                    spectAvgAvg = squeeze(nanmean(spectAvg,1));
%                     figure;
%                     plot(accData','LineWidth',0.2,'Color',[0 0 0.8 0.02])
                    
                    
                    hsb = hpanel(2,ee,ss).select();
                    axes(hsb);
                    pcolor(t, f ,10*log10(spectAvgAvg));     
                    hold on; 
                    xlabel('Time (s)');
                    ylabel('Frequency (Hz)');
                    yyaxis(gca,'right')
                    plot([(1:size(accData,2))./sr], mean(accData,1)','LineWidth',5,'Color',[0 0 0.8 0.2])
                    ylabel('acc. y axes');
                    colormap('jet');
                    shading('interp');
                    axis('tight');
                    xlim([0.1 0.9]);
                    ttluse = sprintf('%s %s %s' ,dataToPlot.chanSense{1},dataToPlot.side{1},dataToPlot.cond{1});
                    title(ttluse);
                    


                    %% plot spctral repreatnation of actigraphy data 
%                     figure; 
%                     sr = 64; 
%                     accPlot = dataToPlot.yAcc{1};
%                     idxkeep = ~isnan(accPlot);
%                     yFilled = fillmissing(accPlot(idxkeep),'constant',0);
%                     [s,f,t,p] = spectrogram(yFilled,64,32,[1:1:20],64);
%                     pcolor(t, f ,log10(p));     
%                     yyaxis(gca,'right')
%                     plot(seconds(timePlotAcc),y_filt);
%                     
%                     colormap('jet')
%                     shading('interp');

                   
                end
            end

            
            
        end
        ttlUse{1,1} = dataPlot.patient{1};
        idxR = strcmp(dataPlot.side,'R');
        dataSide = dataPlot(idxR,:);
        ttlUse{2,1} = sprintf('R: %s %.2fHz %2.fmA',dataSide.chanStim{1},dataSide.stimRate(1),dataSide.stimCurrent(1));
        idxL = strcmp(dataPlot.side,'L');
        dataSide = dataPlot(idxL,:);
        ttlUse{3,1} = sprintf('L: %s %.2fHz %2.fmA',dataSide.chanStim{1},dataSide.stimRate(1),dataSide.stimCurrent(1));
        sgtitle(ttlUse);
        
        
        prfig.plotwidth           = 17;
        prfig.plotheight          = 12;
        prfig.figdir             = figdirout;
        prfig.figname             = sprintf('%s_alligned_acc_data',dataPlot.patient{1});
        prfig.figtype             = '-djpeg';
        plot_hfig(hfig,prfig)
        close(hfig);

        %%
    end
end

end