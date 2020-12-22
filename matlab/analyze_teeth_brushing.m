function analyze_teeth_brushing()
addpath(genpath('/Users/roee/Documents/Code/Analysis-rcs-data/code'));
%%
close all;
rootdir = '/Users/roee/Box/RC-S_Studies_Regulatory_and_Data/Patient In-Clinic Data';
figdirout = '/Users/roee/Box/RC-S_Studies_Regulatory_and_Data/Patient In-Clinic Data/figures/brushing_exp';
resdir = '/Users/roee/Box/RC-S_Studies_Regulatory_and_Data/Patient In-Clinic Data/figures/brushing_exp/results';
foundDir1 = findFilesBVQX(rootdir,'*shing',struct('dirs',1,'depth',2));
foundDir2 = findFilesBVQX(rootdir,'*shing',struct('dirs',1,'depth',3));
foundDirs = [foundDir2, foundDir1];
%% if save results, and plot psds
saveAndPlot = 1;
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
    % XXX
    for p = 2:size(uniquePatients,1)
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
                        plot(combinedDataTable.DerivedTimeHuman(idxkeep), combinedDataTable.Accel_XSamples(idxkeep));
                        
                        % add rest 
                        cntEvent = size(eventTable,1);
                        eventTable(cntEvent + 1,:) = eventTable(cntEvent,:);
                        cntEvent = cntEvent + 1; 
                        eventTable.EventSubType{cntEvent} = 'rest Start';
                        eventTable.UnixOffsetTime(cntEvent) = datetime('21-Dec-2020 21:44:22.329','TimeZone','America/Los_Angeles');                        
                    end
                    

                    
                    %% loop on channels, and select a data chunk with no intereference                                            for e = 1:length(eventFind) % loop on events
                    for e = 1:length(eventFind) % loop on events
                        idxEvents = cellfun(@(x) any(strfind(lower(x),eventFind{e})),eventTable.EventSubType);
                        eventsUsed = eventTable(idxEvents,:);
                        % XXX 
                        startTime = eventsUsed.insTimes(1) + seconds(10);
                        endTime = eventsUsed.insTimes(2)  - seconds(10);
                        % time doain data
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
                                ppp(:,idxBlank) = NaN;
                            end
                            % compute pwelch, but only on sections larger
                            % than 10 seconds 
                            idxGapStart = [1; idxGapStart];
                            idxGapEnd   = [idxGapEnd; length(timeUse)];
                            idxGaps = [idxGapStart , idxGapEnd];
                            idxGapsKeep = timeUse(idxGaps(:,2) - idxGaps(:,1)) >= seconds(10);
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
                            [xAccResample,xTimes] = resample(xAcc,seconds(timeUse),sr);
                            [yAccResample,yTimes] = resample(yAcc,seconds(timeUse),sr);
                            [zAccResample,zTimes] = resample(zAcc,seconds(timeUse),sr);
                            
                            
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
                        end
                        idxL = strcmp(dataPlot.side,'L');
                        dataSide = dataPlot(idxL,:);
                        if ~isempty(dataSide)
                            ttlUse{2,1} = sprintf('L: %s %.2fHz %2.fmA',dataSide.chanStim{1},dataSide.stimRate(1),dataSide.stimCurrent(1));
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
            spectrogram(data,kaiser(256,5),220,512,fs,'yaxis')
            ylim(hsub(b),[2 100]);
            axis(hsub(b),'tight');
            
            colormap(jet)
            colorbar off;
            shading(gca,'interp')
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
plotPacActigraphy = 1;
addpath(genpath('/Users/roee/Documents/Code/PAC'));

if plotPacActigraphy 
    load(fullfile(resdir,'brushing_data.mat'),'brushingData');
    
    
    %% pac params
    pacparams.PhaseFreqVector      = 1:1:10;
    pacparams.AmpFreqVector        = 10:5:180;
    
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
            dataPac(:,2) = data;
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
%% 

end