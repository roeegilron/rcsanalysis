function plot_montage_data_1000Hz()
[app.outdatcomplete,app.outRec,eventTable,app.outdatcompleteAcc,app.powerTable] =  MAIN_load_rcs_data_from_folder(app.dataDir);
outdatcomplete = app.outdatcomplete;
outRec = app.outRec;

outdatcomplete.derivedTimes(1)
[fnn,pnn] = fileparts(app.dataDir);
[fnn,sessionName] = fileparts(fnn);
figTitle = sprintf('%s %s',outdatcomplete.derivedTimes(1),sessionName);
app.UIFigure.Name = figTitle;

deviceSettingsFn = fullfile(app.dataDir,'DeviceSettings.json');
outRec = loadDeviceSettingsForMontage(deviceSettingsFn);
% figure out add / subtract factor for event times (if pc clock is not same
% as INS time).
idxTimeCompare = find(outdatcomplete.PacketRxUnixTime~=0,1);
packRxTimeRaw  = outdatcomplete.PacketRxUnixTime(idxTimeCompare);
packtRxTime    =  datetime(packRxTimeRaw/1000,...
    'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
derivedTime    = outdatcomplete.derivedTimes(idxTimeCompare);
timeDiff       = derivedTime - packtRxTime;


secs = outdatcomplete.derivedTimes;
app.subTime = secs(1);
% find start events
idxStart = cellfun(@(x) any(strfind(x,'Start')),eventTable.EventType);
idxEnd = cellfun(@(x) any(strfind(x,'Stop')),eventTable.EventType);

% insert event table markers and link them
app.ets = eventTable(idxStart,:);
app.ete = eventTable(idxEnd,:);
app.hpltStart = gobjects(sum(idxStart),4);
app.hpltEnd = gobjects(sum(idxStart),4);
% plot the lines for event markers
deltaUse = seconds(5);
for i = 1:sum(idxStart)
    for c = 1:4
        hsub = get(app.hsub(c));
        ylims = hsub.YLim;
        % start
        xval = app.ets.UnixOffsetTime(i) + timeDiff +  deltaUse;
        startTime = xval ;% XXX
        hplt = plot([xval xval],ylims,'Parent',app.hsub(c),'Color',[0 0.8 0 0.7],'LineWidth',3);
        app.hpltStart(i,c) = hplt;
        hplt.ButtonDownFcn = @app.LineDown;
        % end
        xval = app.ete.UnixOffsetTime(i)+timeDiff - deltaUse;
        endTime = xval;
        hplt = plot([xval xval],ylims,'Parent',app.hsub(c),'Color',[0.8 0 0 0.7],'LineWidth',3);
        app.hpltEnd(i,c) = hplt;
        hplt.ButtonDownFcn = @app.LineDown;
    end
end

% save the raw data
cntStn = 1;
cntM1 = 1;
for i = 1:sum(idxStart)
    % if you have disabled channels assume for now that channels need to be averaged
    if sum(cellfun(@(x) any(strfind(x,'disabled')),{outRec(i).tdData.chanFullStr}))
        % start
        xval = app.ets.UnixOffsetTime(i) + timeDiff +  deltaUse;
        startTime = xval ;% XXX
        % end
        xval = app.ete.UnixOffsetTime(i)+timeDiff - deltaUse;
        endTime = xval;
        % get raw data from non disableed channels
        idxNotDisabeled = find(~cellfun(@(x) any(strfind(x,'disabled')),{outRec(i).tdData.chanFullStr})==1);
        y = [];
        for c = 1:length(idxNotDisabeled)
            cfnm = sprintf('key%d',idxNotDisabeled(c)-1);
            y(:,c) = outdatcomplete.(cfnm)';
        end
        secsUse = secs;
        idxuse = secsUse > startTime & secsUse < endTime;
        % get sample rate
        sr = str2num(strrep(outRec(i).tdData(idxNotDisabeled(1)).sampleRate,'Hz',''));
        c = idxNotDisabeled(1);
        if min(idxNotDisabeled)<=2 % its stn
            % save raw data in order to plot psds
            app.rawDatSTN(cntStn).rawdata = mean(y(idxuse,:),2);
            app.rawDatSTN(cntStn).sr = sr;
            app.rawDatSTN(cntStn).chan = sprintf('+%s-%s',outRec(i).tdData(c).plusInput,outRec(i).tdData(c).minusInput);
            app.rawDatSTN(cntStn).chanFullStr = outRec(i).tdData(idxNotDisabeled(1)).chanFullStr;
            cntStn = cntStn + 1;
        else % its m1
            % save raw data in order to plot psds
            app.rawDatM1(cntM1).rawdata = y(idxuse);
            app.rawDatM1(cntM1).sr = sr;
            app.rawDatM1(cntM1).chan = sprintf('+%s-%s',outRec(i).tdData(c).plusInput,outRec(i).tdData(c).minusInput);
            app.rawDatM1(cntM1).chanFullStr = outRec(i).tdData(idxNotDisabeled(1)).chanFullStr;
            cntM1 = cntM1 + 1;
        end
        % if you have no disabled channels - so every td channel is
        % recording
    else % no disabled channels
        for c = 1:4
            % start
            xval = app.ets.UnixOffsetTime(i) + timeDiff +  deltaUse;
            startTime = xval ;% XXX
            % end
            xval = app.ete.UnixOffsetTime(i)+timeDiff - deltaUse;
            endTime = xval;
            % get raw data
            cfnm = sprintf('key%d',c-1);
            y = outdatcomplete.(cfnm);
            secsUse = secs;
            idxuse = secsUse > startTime & secsUse < endTime;
            % get sample rate
            sr = str2num(strrep(outRec(i).tdData(c).sampleRate,'Hz',''));
            if c <=2
                % save raw data in order to plot psds
                app.rawDatSTN(cntStn).rawdata = y(idxuse);
                app.rawDatSTN(cntStn).sr = sr;
                app.rawDatSTN(cntStn).chan = sprintf('+%s-%s',outRec(i).tdData(c).plusInput,outRec(i).tdData(c).minusInput);
                app.rawDatSTN(cntStn).chanFullStr = outRec(i).tdData(c).chanFullStr;
                cntStn = cntStn + 1;
            else
                % save raw data in order to plot psds
                app.rawDatM1(cntM1).rawdata = y(idxuse);
                app.rawDatM1(cntM1).sr = sr;
                app.rawDatM1(cntM1).chan = sprintf('+%s-%s',outRec(i).tdData(c).plusInput,outRec(i).tdData(c).minusInput);
                app.rawDatM1(cntM1).chanFullStr = outRec(i).tdData(c).chanFullStr;
                cntM1 = cntM1 + 1;
            end
        end
    end
end

end