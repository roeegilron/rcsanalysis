function [deviceSettingsOut,stimStatus,stimState]  = loadDeviceSettingsForMontage(fn)

DeviceSettings = jsondecode(fixMalformedJson(fileread(fn),'DeviceSettings'));

% fix issues with device settings sometiems being a cell array and
% sometimes not 
if isstruct(DeviceSettings)
    DeviceSettings = {DeviceSettings};
end

%% print raw device settings strucutre 

for f = 1:length(DeviceSettings)
    curStr = DeviceSettings{f};
    fieldnames1 = fieldnames(curStr); 
    fprintf('[%0.3d]\n',f);
    for f1 = 1:length(fieldnames1)
       fprintf('\t%s\n',fieldnames1{f1});
       curStr2 = curStr.(fieldnames1{f1});
       if isstruct(curStr2)
           fieldnames2 = fieldnames(curStr2);
           for f2 = 1:length(fieldnames2)
               fprintf('\t\t%s\n',fieldnames2{f2});
           end
       end
    end
    fprintf('\n');
end

%%
deviceSettingTable = table();
recNum = 1; 
f = 1;
strCnt = 1; 
strmStopCnt = 1; 
senseStopCnt = 1; 
instream = 0;
while f <= length(DeviceSettings)
    fnms = fieldnames(DeviceSettings{f});
    curStr = DeviceSettings{f};
    if isfield(curStr,'SensingConfig')
        if isfield(curStr.SensingConfig,'timeDomainChannels')
            tdData = translateTimeDomainChannelsStruct(curStr.SensingConfig.timeDomainChannels);
            timenum = curStr.RecordInfo.HostUnixTime;
            t = datetime(timenum/1000,'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS'); 
            outRec(recNum).timeStart = t;
            outRec(recNum).unixtimeStart  = timenum;
            outRec(recNum).tdData = tdData;
            deviceSettingTable.action{recNum} = 'sense config';
            deviceSettingTable.recNum(recNum) = NaN;
            deviceSettingTable.timeStart{recNum} = t;
            for c = 1:4
                fnuse = sprintf('chan%d',c);
                deviceSettingTable.(fnuse){recNum} = tdData(c).chanFullStr;
            end
            deviceSettingTable.tdDataStruc{recNum} = tdData;
            recNum = recNum + 1;
        end
    end
    % check if streaming started 
    if isfield(curStr,'StreamState')
        if curStr.StreamState.TimeDomainStreamEnabled
            if ~instream % if not instream then streaming is starting 
                timenum = curStr.RecordInfo.HostUnixTime;
                t = datetime(timenum/1000,'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
                actionuse = sprintf('stream start %d',strCnt);
                deviceSettingTable.action{recNum} = actionuse;
                deviceSettingTable.recNum(recNum) = strCnt;
                deviceSettingTable.timeStart{recNum} = t;
                for c = 1:4
                    fnuse = sprintf('chan%d',c);
                    deviceSettingTable.(fnuse){recNum} = tdData(c).chanFullStr;
                end
                deviceSettingTable.tdDataStruc{recNum} = tdData;
                strCnt = strCnt + 1;
                recNum = recNum + 1;
                instream = 1;
            end
        end 
    end
    % check if streaming stopped - 
    % it can either be stopped by turning streaming off (MOST LOGICAL1)
    % or it can be stopped by turning sensing off (DO WE EVER TURN SENSE OFF???, ask Randy/Roee)
    % option 1 - stream has been turned off ()
    if isfield(curStr,'StreamState')
        if instream % streaming is happening detect it's stop
            if ~curStr.StreamState.TimeDomainStreamEnabled
                timenum = curStr.RecordInfo.HostUnixTime;
                t = datetime(timenum/1000,'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
                actionuse = sprintf('stop stream %d',strmStopCnt);
                deviceSettingTable.action{recNum} = actionuse;
                deviceSettingTable.recNum(recNum) = strmStopCnt;
                deviceSettingTable.timeStart{recNum} = t;
                for c = 1:4
                    fnuse = sprintf('chan%d',c);
                    deviceSettingTable.(fnuse){recNum} = tdData(c).chanFullStr;
                end
                deviceSettingTable.tdDataStruc{recNum} = tdData;
                instream = 0;
                strmStopCnt = strmStopCnt + 1;
                recNum = recNum + 1;
            end
        end
    end
    % option 2 sense has been turned off
    if isfield(curStr,'SenseState')
        if instream % streaming is happening detect it's stop
            if isfield(curStr.SenseState,'state')
                sensestat = dec2bin(curStr.SenseState.state,4);
                % blow is assuming we only care about time domain streaming
                % starting / stopping, see:
                % enum
                % Medtronic.NeuroStim.Olympus.DataTypes.Sensing.SenseStates : byte
                % for details re what the binary number means
                if strcmp(sensestat(4),'0') % time domain off
                    timenum = curStr.RecordInfo.HostUnixTime;
                    t = datetime(timenum/1000,'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
                    actionuse = sprintf('stop sense %d',senseStopCnt);
                    deviceSettingTable.action{recNum} = actionuse;
                    deviceSettingTable.recNum(recNum) = senseStopCnt;
                    deviceSettingTable.timeStart{recNum} = t;
                    for c = 1:4
                        fnuse = sprintf('chan%d',c);
                        deviceSettingTable.(fnuse){recNum} = tdData(c).chanFullStr;
                    end
                    deviceSettingTable.tdDataStruc{recNum} = tdData;
                    instream = 0;
                    senseStopCnt = senseStopCnt + 1;
                    recNum = recNum + 1;
                end
            end
        end
    end
    f = f+1;
end
% loop on deviceSettigs and extract the start and stop time for each
% recording in the file.
deviceSettingsOut = table(); 
idxnotnan = ~isnan(deviceSettingTable.recNum);
unqRecs = unique(deviceSettingTable.recNum(idxnotnan)); 
for u = 1:length(unqRecs)
    idxuse = deviceSettingTable.recNum == unqRecs(u);
    dt = deviceSettingTable(idxuse,:);
    if size(dt,1) == 1 % this means that stream didn't stop properly
    else
        deviceSettingsOut.recNum(u) = unqRecs(u);
        deviceSettingsOut.timeStart(u) = dt.timeStart{1};
        deviceSettingsOut.timeStop(u) = dt.timeStart{2};
        deviceSettingsOut.duration(u) = deviceSettingsOut.timeStop(u) - deviceSettingsOut.timeStart(u);
        for c = 1:4 % find sample rate
            if ~strcmp(dt.tdDataStruc{1}(c).sampleRate,'disabled')
                deviceSettingsOut.samplingRate(u) = str2num(dt.tdDataStruc{1}(c).sampleRate(1:end-2));
            end
        end
        for c = 1:4
            fnuse = sprintf('chan%d',c);
            deviceSettingsOut.(fnuse){u} = dt.(fnuse){1};
        end
        deviceSettingsOut.TimeDomainDataStruc{u} = dt.tdDataStruc{1};
    end
end


%% load stimulation config
% this code (re stim sweep part) assumes no change in stimulation from initial states
% this code will fail for stim sweeps or if any changes were made to
% stimilation 
% need to fix this to include stim changes and when the occured to color
% data properly according to stim changes and when the took place for in
% clinic testing 

if isstruct(DeviceSettings)
    DeviceSettings = {DeviceSettings};
end
therapyStatus = DeviceSettings{1}.GeneralData.therapyStatusData;
groups = [ 0 1 2 3]; 
groupNames = {'A','B','C','D'}; 
stimState = table(); 
cnt = 1; 
for g = 1:length(groups) 
    fn = sprintf('TherapyConfigGroup%d',groups(g));
    for p = 1:4
        if DeviceSettings{1}.TherapyConfigGroup0.programs(p).isEnabled==0
            stimState.group(cnt) = groupNames{g};
            if (g-1) == therapyStatus.activeGroup
                stimState.activeGroup(cnt) = 1;
                if therapyStatus.therapyStatus
                    stimState.stimulation_on(cnt) = 1;
                else
                    stimState.stimulation_on(cnt) = 0;
                end
            else
                stimState.activeGroup(cnt) = 0;
                stimState.stimulation_on(cnt) = 0;
            end
            
            stimState.program(cnt) = p;
            stimState.pulseWidth_mcrSec(cnt) = DeviceSettings{1}.(fn).programs(p).pulseWidthInMicroseconds;
            stimState.amplitude_mA(cnt) = DeviceSettings{1}.(fn).programs(p).amplitudeInMilliamps;
            stimState.rate_Hz(cnt) = DeviceSettings{1}.(fn).rateInHz;
            elecs = DeviceSettings{1}.(fn).programs(p).electrodes.electrodes;
            elecStr = ''; 
            for e = 1:length(elecs)
                if elecs(e).isOff == 0 % electrode active 
                    if e == 17
                        elecUse = 'c'; 
                    else
                        elecUse = num2str(e-1);
                    end
                    if elecs(e).electrodeType==1 % anode 
                        elecSign = '-';
                    else
                        elecSign = '+';
                    end
                    elecSnippet = [elecSign elecUse ' '];
                    elecStr = [elecStr elecSnippet];
                end
            end

            stimState.electrodes{cnt} = elecStr; 
            cnt = cnt + 1; 
        end
    end
end 
if ~isempty(stimState)
    stimStatus = stimState(logical(stimState.activeGroup),:);
else
    stimStatus = [];
end

%% Adaptive / detection config
% detection settings first are reported in full (e.g. all fields) 
% after this point, only changes are reported. 
% to make analysis easier, each row in output table will contain the full
% settings such that I copy over initial settings. 
% this also assumes that you get a full report of the detection settings on
% first connection. 

% the settings being changed in each adaptive state update will be noted
% in a cell array as well 



%%%
%%%
%%%
% NEW CODE - first load initial settings that then get updates 
%%%
%%%
%%%

f = 1;
previosSettIdx = 0;
currentSettIdx  = 1; 
detectionConfig = table();
adaptiveSettings = table();

fnms = fieldnames(DeviceSettings{f});
curStr = DeviceSettings{f};
det_fiels = {'blankingDurationUponStateChange',...
    'detectionEnable','detectionInputs','fractionalFixedPointValue',...
    'holdoffTime','onsetDuration','terminationDuration','updateRate'};
if isfield(curStr,'DetectionConfig')
    lds_fn = {'Ld0','Ld1'};
    % start time and host unix time
    timenum = curStr.RecordInfo.HostUnixTime;
    t = datetime(timenum/1000,'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS'); 
    detectionConfig.timeStart{f} = t;
    detectionConfig.HostUnixTime = curStr.RecordInfo.HostUnixTime;
    % bias term, etc...
    for ll = 1:length(lds_fn)
        ldTable = table();
        if isfield(curStr.DetectionConfig,lds_fn{ll})
            LD = curStr.DetectionConfig.(lds_fn{ll});
            detectionConfig.([lds_fn{ll} '_' 'biasTerm']) = LD.biasTerm';
            detectionConfig.([lds_fn{ll} '_' 'normalizationMultiplyVector']) = [LD.features.normalizationMultiplyVector];
            detectionConfig.([lds_fn{ll} '_' 'normalizationSubtractVector']) = [LD.features.normalizationSubtractVector];
            detectionConfig.([lds_fn{ll} '_' 'weightVector']) = [LD.features.weightVector];
            for d = 1:length(det_fiels)
                detectionConfig.([lds_fn{ll} '_' det_fiels{d}])  =  LD.(det_fiels{d});
            end
        else % fill in previous settings.
            warning('missing field on first itiration');
        end
    end
end
% adaptive configuraiton
if isfield(curStr,'AdaptiveConfig')
    adaptive_fields = {'adaptiveMode','adaptiveStatus','currentState',...
        'deltaLimitsValid','deltasValid'};
    adaptiveConfig = curStr.AdaptiveConfig;
    
    % time
    
    for a = 1:length(adaptive_fields)
        if isfield(adaptiveConfig,adaptive_fields{a})
            adaptiveSettings.(adaptive_fields{a}) = adaptiveConfig.(adaptive_fields{a});
        else
            warning('missing field on first itiration');
        end
    end
    if isfield(adaptiveConfig,'deltas')
        adaptiveSettings.fall_rate = [adaptiveConfig.deltas.fall];
        adaptiveSettings.rise_rate = [adaptiveConfig.deltas.rise];
    else
        warning('missing field on first itiration');
    end
    adaptiveSettings.HostUnixTime = curStr.RecordInfo.HostUnixTime;
end
if isfield(curStr,'AdaptiveConfig')
    % loop on states
    if isfield(adaptiveConfig,'state0')
        for s = 0:8
            statefn = sprintf('state%d',s);
            stateStruct = adaptiveConfig.(statefn);
            adaptiveSettings.(['state' num2str(s)] ) = s;
            adaptiveSettings.(['rate_hz_state' num2str(s)] ) = stateStruct.rateTargetInHz;
            adaptiveSettings.(['isValid_state' num2str(s)] ) = stateStruct.isValid;
            for p = 0:3
                progfn = sprintf('prog%dAmpInMilliamps',p);
                curr(p+1) = stateStruct.(progfn);
            end
            adaptiveSettings.(['currentMa_state' num2str(s)] )(1,:) = curr;
        end
    else
        % fill in previous settings.
    end
end
   
% loop on rest of code and just report changes and when they happened 
% don't copy things over for now 

% return;

%%%%%%%%%%                          output =
%%%%%%%%%%                          getAdaptiveChanges(DeviceSettings) %%%%
%%%%%%%%%% TODO NEXT
%%%%%%%%%% addubg adaotipeSettings and detectorConfig settings to each
%%%%%%%%%% Change

% f = 2;
% previosSettIdx = 0;
% currentSettIdx  = 1; 
% changesMade = struct();
% 
% cntChangeTemp = 1;
% cntchangeAdap = 1;
% embeddedOn = 0;
% adaptiveChanges = table();
% 
% while f<length(DeviceSettings)
%     fnms = fieldnames(DeviceSettings{f})
%     curStr = DeviceSettings{f}
%     % if adaptive config && embedded
%     if isfield(curStr,'AdaptiveConfig')
%         if isfield(curStr.AdaptiveConfig,'adaptiveMode')
%             if curStr.AdaptiveConfig.adaptiveMode == 2
%                 embeddedOn = 1;
%                 % start time and host unix time
%                 timenum = curStr.RecordInfo.HostUnixTime;
%                 t =  datetime(timenum/1000,'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS'); 
%                 adaptiveChanges.changeNum(cntChangeTemp) = cntchangeAdap;
%                 adaptiveChanges.timeChange(cntChangeTemp) = t;
%                 adaptiveChanges.adaptiveMode(cntChangeTemp) = 1;
%                 cntchangeAdap = cntchangeAdap + 1;
%             else
%                 embeddedOn = 0;
%             end
%         end
%     end
%     if isfield(curStr,'GeneralData') && embeddedOn
%         adaptiveChanges.therapySatus(cntChangeTemp) = curStr.GeneralData.therapyStatusData.therapyStatus;
%         adaptiveChanges.activeGroup(cntChangeTemp) = curStr.GeneralData.therapyStatusData.activeGroup;
%         adaptiveChanges.INStime(cntChangeTemp) = curStr.GeneralData.deviceTime;
%         cntChangeTemp = cntChangeTemp + 1;
%     end
%     f = f + 1;
% end
% 
% adaptiveChangesTemp = table();
% nextRow = 0;
% for j=1:size(adaptiveChanges,1)
%     if ~isnat(adaptiveChanges.timeChange(j))
%         nextRow = nextRow + 1;
%         adaptiveChangesTemp(nextRow,:) = adaptiveChanges(j,:);
%     end
% end
% adaptiveChangesTemp
    
%%%%%%%%%% JUAN HERE 
% 
% loop for device setting structure
% 
%     we need to get time
%     stream is on, even if adaptive has changed
%     
%         strean on, start
%         
%         --- adaptive states (on/off)
%         
%         stream off
%     
%         e.g. adaptive off/stream on
%         etc...
%         
%         we can update adaptive parameter, but not start streaming
%         same but we are not in adaptive group (group D on) / sth in settings to tell us that 'adaptive on' sth like this
%         
%         time should be chnaged from unit to ins time



% while f <= length(DeviceSettings)
%     adaptiveChanges = table();
%     fnms = fieldnames(DeviceSettings{f});
%     curStr = DeviceSettings{f};
%     det_fiels = {'blankingDurationUponStateChange',...
%         'detectionEnable','detectionInputs','fractionalFixedPointValue',...
%         'holdoffTime','onsetDuration','terminationDuration','updateRate'};
%     if isfield(curStr,'DetectionConfig') 
%         lds_fn = {'Ld0','Ld1'};
%         for ll = 1:length(lds_fn)
%             ldTable = table();
%             if isfield(curStr.DetectionConfig,lds_fn{ll})
%             LD = curStr.DetectionConfig.(lds_fn{ll});
%             adaptiveChanges.([lds_fn{ll} '_' 'biasTerm']) = LD.biasTerm';
%             adaptiveChanges.([lds_fn{ll} '_' 'normalizationMultiplyVector']) = [LD.features.normalizationMultiplyVector];
%             adaptiveChanges.([lds_fn{ll} '_' 'normalizationSubtractVector']) = [LD.features.normalizationSubtractVector];
%             adaptiveChanges.([lds_fn{ll} '_' 'weightVector']) = [LD.features.weightVector];
%             for d = 1:length(det_fiels)
%                 adaptiveChanges.([lds_fn{ll} '_' det_fiels{d}])  =  LD.(det_fiels{d});
%             end
%             else % fill in previous settings. 
%                 warning('missing field on first itiration');
%             end
%         end
%         adaptiveChanges.HostUnixTime = curStr.RecordInfo.HostUnixTime;
%     end
%     if isfield(curStr,'AdaptiveConfig')
%         adaptive_fields = {'adaptiveMode','adaptiveStatus','currentState',...
%             'deltaLimitsValid','deltasValid'};
%         adaptiveConfig = curStr.AdaptiveConfig;
%         for a = 1:length(adaptive_fields)
%             if isfield(adaptiveConfig,adaptive_fields{a})
%                 adaptiveChanges.(adaptive_fields{a}) = adaptiveConfig.(adaptive_fields{a});
%             else
%                 warning('missing field on first itiration');
%             end
%         end
%         if isfield(adaptiveConfig,'deltas')
%             adaptiveChanges.fall_rate = [adaptiveConfig.deltas.fall];
%             adaptiveChanges.rise_rate = [adaptiveConfig.deltas.rise];
%         else
%             warning('missing field on first itiration');
%         end
%         adaptiveChanges.HostUnixTime = curStr.RecordInfo.HostUnixTime;
%     end
%     if isfield(curStr,'AdaptiveConfig')
%         % loop on states
%         if isfield(adaptiveConfig,'state0')
%             for s = 0:8
%                 statefn = sprintf('state%d',s);
%                 stateStruct = adaptiveConfig.(statefn);
%                 adaptiveChanges.(['state' num2str(s)] ) = s;
%                 adaptiveChanges.(['rate_hz_state' num2str(s)] ) = stateStruct.rateTargetInHz;
%                 adaptiveChanges.(['isValid_state' num2str(s)] ) = stateStruct.isValid;
%                 for p = 0:3
%                     progfn = sprintf('prog%dAmpInMilliamps',p);
%                     curr(p+1) = stateStruct.(progfn);
%                 end
%                 adaptiveChanges.(['currentMa_state' num2str(s)] )(1,:) = curr;
%             end
%         end
%     end
%     if ~isempty(adaptiveChanges)
%         changesMade(cntchange).adaptiveChanges = adaptiveChanges;
%         cntchange = cntchange + 1;
%     end
%     f = f +1;
% end


%%%%
%%% NEEED TO FIX STATES   - with is field for change detection 
%%% 
%%%
%%%
%%%
% OLD CODE 
%%%
%%%
%%%
%{
% DetectionConfig
% AdaptiveConfig
detectionSettings = struct(); detect_idx = 1; 
adaptiveSettings  = struct(); adaptive_idx = 1; 
stateSettings     = struct(); state_idx = 1; 
f = 2;
previosSettIdx = 0;
currentSettIdx  = 1; 
while f <= length(DeviceSettings)
    fnms = fieldnames(DeviceSettings{f});
    curStr = DeviceSettings{f};
    det_fiels = {'blankingDurationUponStateChange',...
        'detectionEnable','detectionInputs','fractionalFixedPointValue',...
        'holdoffTime','onsetDuration','terminationDuration','updateRate'};
    if isfield(curStr,'DetectionConfig')
        lds_fn = {'Ld0','Ld1'};
        for ll = 1:length(lds_fn)
            ldTable = table();
            if isfield(curStr.DetectionConfig,lds_fn{ll})
            LD = curStr.DetectionConfig.(lds_fn{ll});
            ldTable.([ 'biasTerm']) = LD.biasTerm';
            ldTable.([ 'normalizationMultiplyVector']) = [LD.features.normalizationMultiplyVector];
            ldTable.([ 'normalizationSubtractVector']) = [LD.features.normalizationSubtractVector];
            ldTable.([ 'weightVector']) = [LD.features.weightVector];
            for d = 1:length(det_fiels)
                ldTable.([det_fiels{d}])  =  LD.(det_fiels{d});
            end
                detectionSettings(detect_idx).(lds_fn{ll}) = ldTable;
            else
                % fill in previous settings. 
            end
        end
        detectionSettings(detect_idx).HostUnixTime = curStr.RecordInfo.HostUnixTime;
        detect_idx = detect_idx + 1;

    end
    if isfield(curStr,'AdaptiveConfig')
        adaptive_fields = {'adaptiveMode','adaptiveStatus','currentState',...
            'deltaLimitsValid','deltasValid'};
        adaptiveTable = table();
        adaptiveConfig = curStr.AdaptiveConfig;
        cntmissing = 1; 
        missingFields= {};
        for a = 1:length(adaptive_fields)
            if isfield(adaptiveConfig,adaptive_fields{a})
            adaptiveTable.(adaptive_fields{a}) = adaptiveConfig.(adaptive_fields{a});
            else
                missingFields{cntmissing} = adaptive_fields{a};
                cntmissing = cntmissing + 1; 
                % fill in previous settings. 

            end
        end
        if isfield(adaptiveConfig,'deltas')
            adaptiveTable.fall_rate = [adaptiveConfig.deltas.fall];
            adaptiveTable.rise_rate = [adaptiveConfig.deltas.rise];
        else
            
            missingFields{cntmissing} = 'deltas';
            cntmissing = cntmissing + 1;
            % fill in previous settings.
        end
        adaptiveTable.HostUnixTime = curStr.RecordInfo.HostUnixTime;
        adaptiveSettings(adaptive_idx).adaptiveTable = adaptiveTable;
        adaptive_idx = adaptive_idx + 1;
    end
    if isfield(curStr,'AdaptiveConfig')
        % get state table
        stateTable = table();
        % loop on states
        if isfield(adaptiveConfig,'state0')
            for s = 0:8
                statefn = sprintf('state%d',s);
                stateStruct = adaptiveConfig.(statefn);
                stateTable.state(s+1) = s;
                stateTable.rate_hz(s+1) = stateStruct.rateTargetInHz;
                stateTable.isValid(s+1) = stateStruct.isValid;
                for p = 0:3
                    progfn = sprintf('prog%dAmpInMilliamps',p);
                    curr(p+1) = stateStruct.(progfn);
                end
                stateTable.current_mA(s+1,:) = curr;
            end
            stateSettings(state_idx).stateTable = stateTable;
            state_idx = state_idx + 1;
        else
            % fill in previous settings.
        end
    end
    f = f + 1;
end

%%%
%%%
%%%
% OLD CODE 
%%%
%%%
%%%
%}


end

function outstruc = translateTimeDomainChannelsStruct(tdDat)
%% assume no bridging
outstruc = tdDat;
for f = 1:length(outstruc)
    % lpf 1 (front end)
    switch tdDat(f).lpf1
        case 9
            outstruc(f).lpf1 = '450Hz';
        case 18
            outstruc(f).lpf1 = '100Hz';
        case 36
            outstruc(f).lpf1 = '50Hz';
        otherwise
            outstruc(f).lpf1 = 'unexpected';
    end
    % lpf 2 (bacnk end amplifier)
    switch tdDat(f).lpf2
        case 9
            outstruc(f).lpf2 = '100Hz';
        case 11
            outstruc(f).lpf2 = '160Hz';
        case 12
            outstruc(f).lpf2 = '350Hz';
        case 14
            outstruc(f).lpf2 = '1700Hz';
        otherwise
            outstruc(f).lpf2 = 'unexpected';
    end
    % channels - minus input
    switch tdDat(f).minusInput
        case 0
            outstruc(f).minusInput = 'floating';
        case 1
            outstruc(f).minusInput = '0';
        case 2
            outstruc(f).minusInput = '1';
        case 4
            outstruc(f).minusInput = '2';
        case 8
            outstruc(f).minusInput = '3';
        case 16
            outstruc(f).minusInput = '4';
        case 32
            outstruc(f).minusInput = '5';
        case 64
            outstruc(f).minusInput = '6';
        case 128
            outstruc(f).minusInput = '7';
        otherwise
            outstruc(f).minusInput = 'unexpected';
    end
    if ~strcmp(outstruc(f).minusInput,'floating') & ~strcmp(outstruc(f).minusInput,'unexpected')
        if f > 2 % asssumes there is no bridging 
            outstruc(f).minusInput = num2str( str2num(outstruc(f).minusInput)+8);
        end
    end
    % channels - plus input
      switch tdDat(f).plusInput
        case 0
            outstruc(f).plusInput = 'floating';
        case 1
            outstruc(f).plusInput = '0';
        case 2
            outstruc(f).plusInput = '1';
        case 4
            outstruc(f).plusInput = '2';
        case 8
            outstruc(f).plusInput = '3';
        case 16
            outstruc(f).plusInput = '4';
        case 32
            outstruc(f).plusInput = '5';
        case 64
            outstruc(f).plusInput = '6';
        case 128
            outstruc(f).plusInput = '7';
        otherwise
            outstruc(f).plusInput = 'unexpected';
      end
      if ~strcmp(outstruc(f).plusInput,'floating') & ~strcmp(outstruc(f).plusInput,'unexpected')
          if f > 2 % asssumes there is no bridging
              outstruc(f).plusInput = num2str( str2num(outstruc(f).plusInput)+8);
          end
      end
    % sample rate 
    switch tdDat(f).sampleRate
        case 0
            outstruc(f).sampleRate = '250Hz';
        case 1
            outstruc(f).sampleRate = '500Hz';
        case 2 
            outstruc(f).sampleRate = '1000Hz';
        case 240
            outstruc(f).sampleRate = 'disabled';     
        otherwise
            outstruc(f).plusInput = 'unexpected';
    end
    outstruc(f).chanOut = sprintf('+%s-%s',...
        outstruc(f).plusInput,outstruc(f).minusInput);
    outstruc(f).chanFullStr = sprintf('%s lpf1-%s lpf2-%s sr-%s',...
        outstruc(f).chanOut,...
        outstruc(f).lpf1,outstruc(f).lpf2,outstruc(f).sampleRate);
end
end