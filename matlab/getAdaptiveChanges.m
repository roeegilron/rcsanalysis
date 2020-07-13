function out = getAdaptiveChanges(deviceSettings)

    f = 1;
    cntChangeTemp = 1;
    cntchangeAdap = 1;
    embeddedOn = 0;
    adaptiveChanges = table();

    while f<length(deviceSettings)
        curStr = deviceSettings{f};
        % if adaptive config && embedded
        if isfield(curStr,'AdaptiveConfig')
            if isfield(curStr.AdaptiveConfig,'adaptiveMode')
                if curStr.AdaptiveConfig.adaptiveMode == 2
                    embeddedOn = 1;
                    % start time and host unix time
                    timenum = curStr.RecordInfo.HostUnixTime;
                    t =  datetime(timenum/1000,'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS'); 
                    adaptiveChanges.changeNum(cntChangeTemp) = cntchangeAdap;
                    adaptiveChanges.timeChange(cntChangeTemp) = t;
                    adaptiveChanges.adaptiveMode(cntChangeTemp) = 1;
                    cntchangeAdap = cntchangeAdap + 1;
                else
                    embeddedOn = 0;
                end
            end
        end
        if isfield(curStr,'GeneralData') && embeddedOn
            adaptiveChanges.therapySatus(cntChangeTemp) = curStr.GeneralData.therapyStatusData.therapyStatus;
            adaptiveChanges.activeGroup(cntChangeTemp) = curStr.GeneralData.therapyStatusData.activeGroup;
            adaptiveChanges.INStime(cntChangeTemp) = curStr.GeneralData.deviceTime;
            cntChangeTemp = cntChangeTemp + 1;
        end
        f = f + 1;
    end

    adaptiveChangesTemp = table();
    nextRow = 0;
    for j=1:size(adaptiveChanges,1)
        if ~isnat(adaptiveChanges.timeChange(j))
            nextRow = nextRow + 1;
            adaptiveChangesTemp(nextRow,:) = adaptiveChanges(j,:);
        end
    end
    
    out = adaptiveChangesTemp;

end