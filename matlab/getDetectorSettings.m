function out = getDetectorSettings(fn)

    DeviceSettings = jsondecode(fixMalformedJson(fileread(fn),'DeviceSettings'));


    f = 1;
    detectorSettings = table();
    cntChangeTemp = 1;
    while f<length(DeviceSettings)
        curStr = DeviceSettings{f};
        det_fiels = {'blankingDurationUponStateChange',...
        'detectionEnable','detectionInputs','fractionalFixedPointValue',...
        'holdoffTime','onsetDuration','terminationDuration','updateRate'};
        if isfield(curStr,'DetectionConfig')
            % start time and host unix time
            timenum = curStr.RecordInfo.HostUnixTime;
            t =  datetime(timenum/1000,'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS'); 
            detectorSettings.changeNum(cntChangeTemp) = cntChangeTemp;
            detectorSettings.timeChange(cntChangeTemp) = t;
            lds_fn = {'Ld0','Ld1'};
            for ll = 1:length(lds_fn)
%                 ldTable = table();
                if isfield(curStr.DetectionConfig,lds_fn{ll})
                    LD = curStr.DetectionConfig.(lds_fn{ll});
                    detectorSettings.([lds_fn{ll} '_' 'biasTerm']){cntChangeTemp} = LD.biasTerm';
                    detectorSettings.([lds_fn{ll} '_' 'normalizationMultiplyVector']){cntChangeTemp} = [LD.features.normalizationMultiplyVector];
                    detectorSettings.([lds_fn{ll} '_' 'normalizationSubtractVector']){cntChangeTemp} = [LD.features.normalizationSubtractVector];
                    detectorSettings.([lds_fn{ll} '_' 'weightVector']){cntChangeTemp} = [LD.features.weightVector];
                    for d = 1:length(det_fiels)
                        detectorSettings.([lds_fn{ll} '_' det_fiels{d}]){cntChangeTemp} =  LD.(det_fiels{d});
                    end
                else % fill in previous settings.
                    warning('missing field on first itiration');
                end
            end    
            
        cntChangeTemp = cntChangeTemp + 1;
        end
%         if isfield(curStr,'AdaptiveConfig')
%             adaptive_fields = {'adaptiveMode','adaptiveStatus','currentState',...
%                 'deltaLimitsValid','deltasValid'};
%             adaptiveConfig = curStr.AdaptiveConfig;
%             for a = 1:length(adaptive_fields)
%                 if isfield(adaptiveConfig,adaptive_fields{a})
%                     detectorSettings.(adaptive_fields{a}){cntChangeTemp} = adaptiveConfig.(adaptive_fields{a});
%                 else
%                     warning('missing field on first itiration');
%                 end
%             end
%             if isfield(adaptiveConfig,'deltas')
%                 detectorSettings.fall_rate{cntChangeTemp} = [adaptiveConfig.deltas.fall];
%                 detectorSettings.rise_rate{cntChangeTemp} = [adaptiveConfig.deltas.rise];
%             else
%                 warning('missing field on first itiration');
%             end
% %             detectorSettings.HostUnixTime = curStr.RecordInfo.HostUnixTime;
%         end
%         if isfield(curStr,'AdaptiveConfig')
%             % loop on states
%             if isfield(adaptiveConfig,'state0')
%                 for s = 0:8
%                     statefn = sprintf('state%d',s);
%                     stateStruct = adaptiveConfig.(statefn);
%                     detectorSettings.(['state' num2str(s)] ) = s;
%                     detectorSettings.(['rate_hz_state' num2str(s)] ) = stateStruct.rateTargetInHz;
%                     detectorSettings.(['isValid_state' num2str(s)] ) = stateStruct.isValid;
%                     for p = 0:3
%                         progfn = sprintf('prog%dAmpInMilliamps',p);
%                         curr(p+1) = stateStruct.(progfn);
%                     end
%                     detectorSettings.(['currentMa_state' num2str(s)] )(1,:) = curr;
%                 end
%             else
%                 % fill in previous settings.
%             end
%         end
        f = f +1;
    end
    out = detectorSettings;
end