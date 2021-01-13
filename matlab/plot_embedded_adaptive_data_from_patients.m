function plot_embedded_adaptive_data_from_patients()
%% add assing time
addpath(genpath('/Users/roee/Documents/Code/Analysis-rcs-data'))
%%
close all; clear all; clc;
% set destination folders
dropboxFolder = findFilesBVQX('/Users','Starr Lab Dropbox',struct('dirs',1,'depth',2));
if length(dropboxFolder) == 1
    dirname  = fullfile(dropboxFolder{1}, 'RC+S Patient Un-Synced Data');
    rootdir = fullfile(dirname,'database');
else
    error('can not find dropbox folder, you may be on a pc');
end


load(fullfile(rootdir,'database_from_device_settings.mat'),'masterTableLightOut');

masterTableOut = masterTableLightOut;

idxkeep = cellfun(@(x) any(strfind(x,'RCS')), masterTableOut.patient);
tblall =  masterTableOut(idxkeep,:);

unqpatients = unique(tblall.patient);
plotwhat = input('choose patient and side (1) or plot all(2)? ');
if plotwhat == 1 % choose patients and side
    fprintf('choose patient by idx\n');
    unqpatients = unique(tblall.patient);
    for uu = 1:length(unqpatients)
        fprintf('[%0.2d] %s\n',uu,unqpatients{uu})
    end
    patidx = input('patientidx ?');
end
idxPatient = strcmp(tblall.patient , unqpatients(patidx));
tblPatient = tblall(idxPatient,:);



% choose year
[y,m,d] = ymd(tblPatient.timeStart);
uniqueYears = unique(y);
for yy = 1:length(uniqueYears)
    fprintf('[%0.2d] %d\n',yy,uniqueYears(yy))
end
yearidx = input('year idx ?');
tblPatient = tblPatient(y == uniqueYears(yearidx),:);

% choose month
[y,m,d] = ymd(tblPatient.timeStart);
uniqueMonths = unique(m);
for mm = 1:length(uniqueMonths)
    fprintf('[%0.2d] %d\n',mm,uniqueMonths(mm))
end
monthidx = input('month idx?');
tblPatient = tblPatient(m == uniqueMonths(monthidx),:);

% choose day
[y,m,d] = ymd(tblPatient.timeStart);
uniqueDays = unique(d);
for dd = 1:length(uniqueDays)
    fprintf('[%0.2d] %d\n',dd,uniqueDays(dd))
end
dayidx = input('day idx?');
tblPatient = tblPatient(d == uniqueDays(dayidx),:);
tblPatient.duration.Format = 'hh:mm:ss';

idxLonger = tblPatient.duration > minutes(20);
tblPatient = tblPatient(idxLonger,:);
% loop on sides

uniqueSides = unique(tblPatient.side);

for s = 1:length(uniqueSides)
    idxSide = strcmp(tblPatient.side,uniqueSides{s});
    tblSide = tblPatient(idxSide,:);
    if ~isempty(tblSide)
        %% get data
        aTables = {};
        cntTbl  = 1;
        for su = 1:size(tblSide,1)
            ds = tblSide(su,:);
            if ds.duration > minutes(20)
                mintrim = 10;
                [pn,fn] = fileparts(ds.deviceSettingsFn{1});
                fnAdaptive = fullfile(pn,'AdaptiveLog.json');
                % load adapative
                res = readAdaptiveJson(fnAdaptive);
                if ~isempty(res)
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
                    deviceSettingsTable = get_meta_data_from_device_settings_file(ds.deviceSettingsFn{1});
                    fftInterval = deviceSettingsTable.fftTable{1}.interval;
                    samplingRate = 1000/fftInterval;
                    samplingRateCol = repmat(samplingRate,size(adaptiveTable,1),1);
                    adaptiveTable.samplerate = samplingRateCol;
                    adaptiveTable.packetsizes  = repmat(1,size(adaptiveTable,1),1);
                    
                    adaptiveTable = assignTime(adaptiveTable);
                    ts = datetime(adaptiveTable.DerivedTime/1000,...
                        'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
                    
                    
                    adaptiveTable.DerivedTimesFromAssignTimesHumanReadable = ts;
                    % save out to a cell array of tables for the day
                    aTables{cntTbl} = adaptiveTable;
                    
                    % get actigraphy
                    
                    
                    
                    
                    
                    
                    
                    Accel_fileToLoad = fullfile(pn,'RawDataAccel.json');
                    if isfile(Accel_fileToLoad)
                        jsonobj_Accel = deserializeJSON(Accel_fileToLoad);
                        if ~isempty(jsonobj_Accel.AccelData)
                            disp('Loading Accelerometer Data')
                            [outtable_Accel, srates_Accel] = createAccelTable(jsonobj_Accel);
                            disp('Creating derivedTimes for accelerometer:')
                            AccelData = assignTime(outtable_Accel);
                        else
                            AccelData = [];
                        end
                    else
                        AccelData = [];
                    end
                    ts = datetime(AccelData.DerivedTime/1000,...
                        'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
                    AccelData.DerivedTimesFromAssignTimesHumanReadable = ts;
                    % computer RMS
                    x = AccelData.XSamples - mean(AccelData.XSamples);
                    y = AccelData.XSamples - mean(AccelData.YSamples);
                    z = AccelData.XSamples - mean(AccelData.ZSamples);
                    %     plot(ts,x,'LineWidth',1,'Color',[0.8 0 0 0.6]);
                    %     plot(ts,y,'LineWidth',1,'Color',[0.0 0.8 0 0.6]);
                    %     plot(ts,z,'LineWidth',1,'Color',[0.0 0 0.8 0.6]);
                    % reshape actigraphy over 3 seconds window (64*3)
                    accAxes = {'x','y','z'};
                    yAvg = [];
                    for ac = 1:length(accAxes)
                        yDat = eval(accAxes{ac});
                        uxtimesPower = ts;
                        reshapeFactor = 64*3;
                        yDatReshape = yDat(1:end-(mod(size(yDat,1), reshapeFactor)));
                        timeToReshape= uxtimesPower(1:end-(mod(size(yDat,1), reshapeFactor)));
                        yDatToAverage  = reshape(yDatReshape,reshapeFactor,size(yDatReshape,1)/reshapeFactor);
                        timeToAverage  = reshape(timeToReshape,reshapeFactor,size(yDatReshape,1)/reshapeFactor);
                        
                        yAvg(ac,:) = rms(yDatToAverage - mean(yDatToAverage),1)'; % average rms
                        tUse = timeToAverage(reshapeFactor,:);
                    end
                    rmsAverage = log10(mean(yAvg));
                    accTable = table();
                    accTable.tuse = tUse;
                    % moving mean - 21 seconds
                    mvMean = movmean(rmsAverage,7);
                    accTable.rmsAverage = rmsAverage;
                    accTable.mvMean = mvMean;
                    
                    accTables{cntTbl} = accTable;
                    
                    
                    cntTbl = cntTbl + 1;
                end
            end
        end
        
        
        %% plot data
        
        hfig = figure;
        hfig.Color = 'w';
        nrows = 5;
        for i = 1:nrows
            hsb(i) = subplot(nrows,1,i);
            hold(hsb(i),'on');
        end
        
        controlSignal = [];
        controlSignal_LD1 = [];
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
            
            idxplot = 1; % first plot is detecorr LD1
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
            
            
            idxplot = 2; % second plot is detecorr LD2
            
            ld1 = adaptiveTable.LD1_output;
            ld1_high = adaptiveTable.LD1_highThreshold;
            ld1_low = adaptiveTable.LD1_lowThreshold;
            
            
            outlierIdx = isoutlier(ld1_high);
            ld1 = ld1(~outlierIdx);
            ld1_high = ld1_high(~outlierIdx);
            ld1_low = ld1_low(~outlierIdx);
            timesUseDetector = adaptiveTable.DerivedTimesFromAssignTimesHumanReadable;
            timesUseDetector = timesUseDetector(~outlierIdx);
            
            
            controlSignal_LD1 = [controlSignal_LD1; ld1];
            hold(hsb(idxplot),'on');
            hplt = plot(hsb(idxplot),timesUseDetector,ld1,'LineWidth',2.5,'Color',[0 0 0.8 ]);
            plot(hsb(idxplot),timesUseDetector,movmean( ld1,[1 1200]),'LineWidth',4,'Color',[0 0.8 0 0.2]);
            
            hplt = plot(hsb(idxplot),timesUseDetector,ld1_high,'LineWidth',2,'Color',[0.8 0 0 ]);
            hplt.LineStyle = '-.';
            hplt.Color = [hplt.Color 0.7];
            hplt = plot(hsb(idxplot),timesUseDetector,ld1_low,'LineWidth',2,'Color',[0.8 0 0]);
            hplt.LineStyle = '-.';
            hplt.Color = [hplt.Color 0.7];
            prctile_99 = prctile(ld0,99);
            prctile_1  = prctile(ld0,1);
            if prctile_1 > ld1_low(1)
                prctile_1 = ld1_low(1) * 0.9;
            end
            if prctile_99 < ld1_high(1)
                prctile_99 = ld1_high(1)*1.1;
            end
            ylim(hsb(idxplot),[prctile_1 prctile_99]);
            ttlus = sprintf('Control signal');
            title(hsb(idxplot),ttlus);
            ylabel(hsb(idxplot),'Control signal (a.u.)');
            set(hsb(idxplot),'FontSize',16);
            
            
            % state
            
            
            idxplot = 3; % current
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
            
            idxplot = 4; % current
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
            
            
            
            % plot actigraphy
            idxplot = 5; % current
            hold(hsb(idxplot),'on');
            accTable = accTables{a};
            tUse = accTable.tuse;
            rmsAverage = accTable.rmsAverage;
            mvMean = accTable.mvMean;
            hplt = plot(tUse,rmsAverage);
            hplt.LineWidth = 1;
            hplt.Color = [0.7 0.7 0 0.1];
            % moving mean - 21 seconds
            mvMean = movmean(rmsAverage,7);
            hplt = plot(tUse,mvMean);
            hplt.LineWidth = 2;
            hplt.Color = [0.5 0.5 0 0.5];
            legend({'rms, 20 sec mov. avg.'});
            title('acc');
            ylabel('RMS of acc (log10(g))');
            set(gca,'FontSize',16)
            
            
        end
        linkaxes(hsb,'x');
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
        
        dirplot = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/figures_adaptive/RCS02';
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
        
    end
end

end