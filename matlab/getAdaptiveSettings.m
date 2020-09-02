function out = getAdaptiveSettings(fn)

    DeviceSettings = jsondecode(fixMalformedJson(fileread(fn),'DeviceSettings'));


    f = 1;
    adaptiveSettings = table();
    cntChangeTemp = 1;
    while f<length(DeviceSettings)
        curStr = DeviceSettings{f};
        adaptive_fields = {'adaptiveMode','ad','currentState',...
                                'deltaLimitsValid','deltasValid'};
            if isfield(curStr,'AdaptiveConfig')
                % start time and host unix time
                timenum = curStr.RecordInfo.HostUnixTime;
                t =  datetime(timenum/1000,'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS'); 
                adaptiveSettings.changeNum(cntChangeTemp) = cntChangeTemp;
                adaptiveSettings.timeChange(cntChangeTemp) = t;
                adaptiveConfig = curStr.AdaptiveConfig;
                for a = 1:length(adaptive_fields)
                    if isfield(adaptiveConfig,adaptive_fields{a})
                        adaptiveSettings.(adaptive_fields{a}){cntChangeTemp} = adaptiveConfig.(adaptive_fields{a});
                    else
                        warning('missing field on first itiration');
                    end
                end
                if isfield(adaptiveConfig,'deltas')
                    adaptiveSettings.fall_rate{cntChangeTemp} = [adaptiveConfig.deltas.fall];
                    adaptiveSettings.rise_rate{cntChangeTemp} = [adaptiveConfig.deltas.rise];
                else
                    warning('missing field on first itiration');
                end
                % loop on states
                if isfield(adaptiveConfig,'state0')
                    for s = 0:8
                        statefn = sprintf('state%d',s);
                        try 
                            stateStruct = adaptiveConfig.(statefn);
                            adaptiveSettings.(['state' num2str(s)] ){cntChangeTemp} = s;
                            try
                            adaptiveSettings.(['rate_hz_state' num2str(s)] ){cntChangeTemp} = [stateStruct.rateTargetInHz];
                            catch
                                adaptiveSettings.(['rate_hz_state' num2str(s)] ){cntChangeTemp} = [];
                            end
                            adaptiveSettings.(['isValid_state' num2str(s)] ){cntChangeTemp} = [stateStruct.isValid];
                            for p = 0:3
                                progfn = sprintf('prog%dAmpInMilliamps',p);
                                try
                                    curr(p+1) = stateStruct.(progfn);
                                catch
                                    curr(p+1) = nan;
                                end
                            end
                            if ~isnan(curr)
                                adaptiveSettings.(['currentMa_state' num2str(s)] ){cntChangeTemp} = curr;
                            else
                                adaptiveSettings.(['currentMa_state' num2str(s)] ){cntChangeTemp} = [];
                            end
                        catch
                            % nothing happens
                        end
                    end
                else
                    % fill in previous settings.
                end
                cntChangeTemp = cntChangeTemp + 1;
            end
        f = f +1;
    end
    
    % remove cells which have no element (no changes) from colom 3 on
    adaptiveSettingsCell = table2cell(adaptiveSettings);
    matrixEmptyCells = cellfun(@isempty, adaptiveSettingsCell);  %find them
    sumcols = sum(matrixEmptyCells,2);
    adaptiveSettings(find(sumcols==size(adaptiveSettings,2)-2),:) = []; % -2, to not count the two intial cols which are always filled in
    adaptiveSettings.changeNum = (1:size(adaptiveSettings,1))';
    
    out = adaptiveSettings;
end