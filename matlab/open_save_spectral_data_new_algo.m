function open_save_spectral_data_new_algo()
%%
% params.dir = '/Volumes/RCS_DATA/chronic_stim_vs_off';
% create_database_from_device_settings_files(params.dir);
fnuse = '/Volumes/RCS_DATA/chronic_stim_vs_off/database/database_from_device_settings.mat';
load(fnuse);
addpath(genpath('/Users/roee/Documents/Code/Analysis-rcs-data/code'));
addpath(genpath('/Users/roee/Starr_Lab_Folder/Data_Analysis/Analysis-rcs-data/code'));


%%

for sss = 1:size(masterTableLightOut,1)
    
    [pn,fn] = fileparts(masterTableLightOut.deviceSettingsFn{sss});
    % if the data exists - just load it
    if masterTableLightOut.duration(sss) > minutes(20)
        filenameSaveOrLoad = fullfile(pn,'combinedDataTable.mat');
        isFile = exist(filenameSaveOrLoad,'file');
        skipPlot = 0; % skip all the load if you have done computation already
        if isFile
            fileMeta = memmapfile(filenameSaveOrLoad);
            variableInfo = who('-file', filenameSaveOrLoad);
            if sum(cellfun(@(x) any(strfind(x,'outSpectral')),variableInfo))>0
                load(filenameSaveOrLoad,'outSpectral');
                skipPlot = 0;
            end
        end
        
        if ~skipPlot
            ss = 1;
            eventFn = fullfile(pn,'EventLog.json');
            eventTable  = loadEventLog(eventFn);
            if ~isempty(eventTable)
                idxRemove = cellfun(@(x) any(strfind(x,'Application Version')),eventTable.EventType) | ...
                    cellfun(@(x) any(strfind(x,'BatteryLevel')),eventTable.EventType) | ...
                    cellfun(@(x) any(strfind(x,'LeadLocation')),eventTable.EventType);
                eventTableUse = eventTable(~idxRemove,:);
            else
                eventTableUse = table();
            end
            try
                start = tic;
                [unifiedDerivedTimes,...
                    timeDomainData, timeDomainData_onlyTimeVariables, timeDomain_timeVariableNames,...
                    AccelData, AccelData_onlyTimeVariables, Accel_timeVariableNames,...
                    PowerData, PowerData_onlyTimeVariables, Power_timeVariableNames,...
                    FFTData, FFTData_onlyTimeVariables, FFT_timeVariableNames,...
                    AdaptiveData, AdaptiveData_onlyTimeVariables, Adaptive_timeVariableNames,...
                    timeDomainSettings, powerSettings, fftSettings, eventLogTable,...
                    metaData, stimSettingsOut, stimMetaData, stimLogSettings,...
                    DetectorSettings, AdaptiveStimSettings, AdaptiveEmbeddedRuns_StimSettings] = ProcessRCS(pn,1);
                dataStreams = {timeDomainData, AccelData, PowerData, FFTData, AdaptiveData};
                [combinedDataTable] = createCombinedTable(dataStreams,unifiedDerivedTimes,metaData);
                timeToLoad = toc(start);
                masterTableLightOut.timeToLoad(sss) = seconds(timeToLoad);
                
                ts = datetime(combinedDataTable.DerivedTime/1000,...
                    'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
                combinedDataTable.DerivedTimeHuman = ts;
                outSpectral = struct();
                
                timeUse = ts;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                
                
                %% plot time domain
                idxuse = logical(ones(size(combinedDataTable,1),1));
                for c = 1:4 % loop on channels
                    chanfn = sprintf('TD_key%d',c-1);
                    sr = timeDomainSettings.samplingRate(1); % assumes no change in session
                    chunkUse = combinedDataTable.(chanfn)(idxuse);
                    y = chunkUse - nanmean(chunkUse);
                    y = y.*1e3;
                    % first make sure that y does'nt have NaN's at start or
                    % end
                    timeUseRaw = timeUse;
                    
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
                    
                    yFilled = fillmissing(y,'constant',0);
                    [sss,fff,ttt,ppp] = spectrogram(yFilled,kaiser(256,5),64,512,sr,'yaxis');
                    % put nan's in gaps for spectral
                    spectTimes = timeUseNoNans(1) + seconds(ttt);
                    
                    idxGapStart = find(diff(isnan(y))==1) + 1;
                    idxGapEnd = find(diff(isnan(y))==-1) + 1;
                    for te = 1:size(idxGapStart,1)
                        timeGap(te,1) = timeUseNoNans(idxGapStart(te)) - seconds(0.2);
                        timeGap(te,2) = timeUseNoNans(idxGapEnd(te)) + seconds(0.2);
                        idxBlank = spectTimes >= timeGap(te,1) & spectTimes <= timeGap(te,2);
                        ppp(:,idxBlank) = NaN;
                    end
                    fnchan = sprintf('chan%d',c);
                    outSpectral.spectTimes{ss} = spectTimes;
                    outSpectral.fff{ss} = fff;
                    chanfn = sprintf('chan%d',c);
                    outSpectral.(chanfn){ss} = ppp;
                end
                %%
                
                %% plot rms of actigraphy
                accAxes = {'X','Y','Z'};
                accIdxKeep = ~isnan(combinedDataTable.Accel_XSamples);
                accTable = combinedDataTable(accIdxKeep,{'DerivedTimeHuman','Accel_XSamples','Accel_YSamples','Accel_ZSamples'});
                yAvg = [];
                for ac = 1:length(accAxes)
                    fnUse = sprintf('Accel_%sSamples',accAxes{ac});
                    yDat = accTable.(fnUse);
                    uxtimesPower = accTable.DerivedTimeHuman;
                    reshapeFactor = 64*3;
                    yDatReshape = yDat(1:end-(mod(size(yDat,1), reshapeFactor)));
                    timeToReshape= uxtimesPower(1:end-(mod(size(yDat,1), reshapeFactor)));
                    yDatToAverage  = reshape(yDatReshape,reshapeFactor,size(yDatReshape,1)/reshapeFactor);
                    timeToAverage  = reshape(timeToReshape,reshapeFactor,size(yDatReshape,1)/reshapeFactor);
                    
                    yAvg(ac,:) = rms(yDatToAverage - mean(yDatToAverage),1)'; % average rms
                    tUse = timeToAverage(reshapeFactor,:);
                end
                rmsAverage = log10(mean(yAvg));
                accTablePlot = table();
                accTablePlot.tuse = tUse';
                % moving mean - 21 seconds
                mvMean = movmean(rmsAverage,7);
                accTablePlot.rmsAverage = rmsAverage';
                accTablePlot.mvMean = mvMean';
                % moving mean - 21 seconds
                mvMean = movmean(rmsAverage,7);
                outSpectral.accTime{ss} = tUse';
                outSpectral.rmsAverage{ss} = rmsAverage';
                outSpectral.mvMean{ss} = mvMean';
                
                filenameSaveOrLoad = fullfile(pn,'combinedDataTable.mat');
                save(filenameSaveOrLoad,'outSpectral','eventTableUse','-append')
            catch
                failedFiles{sss} = pn;
            end
            
        end
    end
end
mtTime = masterTableLightOut;
save('/Volumes/RCS_DATA/chronic_stim_vs_off/database/database_from_device_settings.mat','mtTime','failedFiles','-append');