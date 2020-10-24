function [senseSettings,stimState,stimStatus,fftTable,powerTable,adaptiveSettings,senseSettingsMultiple,stimStateChanges]  = loadDeviceSettingsFromFirstInitialStructure(DeviceSettings)
warning('off','MATLAB:table:RowsAddedExistingVars');

timenum = DeviceSettings{1}.RecordInfo.HostUnixTime;
time = datetime(timenum/1000,'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');


SensingConfig =  DeviceSettings{1}.SensingConfig; 
%% td sense settings 
tdDataStruc = translateTimeDomainChannelsStruct(SensingConfig.timeDomainChannels)';
senseSettings = table();
senseSettings.time = time; 
senseSettings.duration = seconds(0); 
for c = 1:4 % find sample rate
    if ~strcmp(tdDataStruc(c).sampleRate,'disabled')
        senseSettings.samplingRate = str2num(tdDataStruc(c).sampleRate(1:end-2));
    end
end
for c = 1:4
    fnuse = sprintf('chan%d',c);
    senseSettings.(fnuse){1} = tdDataStruc(c).chanFullStr;
end
senseSettings.TimeDomainDataStruc{1} = tdDataStruc;
senseSettings.TelmMode{1} =  DeviceSettings{1}.TelemetryModuleInfo.TelmMode;
senseSettings.TelmRatio(1) =  DeviceSettings{1}.TelemetryModuleInfo.TelmRatio;
% load all the sense settings in the whole file 

try
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
        % it can either be stopped by turning streaming off
        % or it can be stopped by turning sensing off
        % option 1 - stream has been turned off
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
        if size(dt,1) == 1 % this means that stream didn't stop properly / or that we jsut have one recrodings
            deviceSettingsOut.recNum(u) = unqRecs(u);
            deviceSettingsOut.timeStart(u) = dt.timeStart{1};
            % assume time stop is end of file
            timenum = DeviceSettings{end}.RecordInfo.HostUnixTime;
            timeEnd = datetime(timenum/1000,'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
            
            deviceSettingsOut.timeStop(u) = timeEnd;
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
    if size(deviceSettingsOut,1) >=1
        % get settings that were "maxed out" throughout
        [~,idx] = max(deviceSettingsOut.duration);
        deviceSettingsOut = deviceSettingsOut(idx,:);
        senseSettings.time = deviceSettingsOut.timeStart;
        senseSettings.duration = deviceSettingsOut.duration;
        senseSettings.samplingRate = deviceSettingsOut.samplingRate;
        senseSettings.chan1 = deviceSettingsOut.chan1;
        senseSettings.chan2 = deviceSettingsOut.chan2;
        senseSettings.chan3 = deviceSettingsOut.chan3;
        senseSettings.chan4 = deviceSettingsOut.chan4;
        senseSettings.TimeDomainDataStruc  = deviceSettingsOut.TimeDomainDataStruc;
    end
    senseSettingsMultiple = deviceSettingTable;
catch
    senseSettingsMultiple = table();
end
%% load power channel + fft config 

%  first part of code checks if there were any sense config evnets in the
%  file. 
% if not, you have to load these from the default "first" structure in the
% code. 
% the next part of the code tries to take acount of any changes in the
% sensing or power channel config through out the device settings file. 
% for example, if power has changed or the fft has changes to when
% switching to adapative stimulation using either research facing or the
% patient facing application. 
% get the fft
SensingConfigStruc = SensingConfig;
% XXX
% note that this is awful code - me being lazy
% instead of creating a new subfunciton copying code over
% just trying to get this to work quickly
% but this should be fixed as now any bugs have to be worked out in two
% places
% XXX
% since using the first data payload - just compute the first time
% point
fftTable = table();
fftTable.time = time; 
fftTable.duration = seconds(0); 

% get the sample rate from the first payload
sampleRate = senseSettings.samplingRate;
% load fft default config

fftConfig = SensingConfigStruc.fftConfig;
fftcnt = 1;
powerTable = table();
powerTable.time = time; 
powerTable.duration = seconds(0); 
pwrcnt = 1;
switch fftConfig.size
    case 0
        fftTable.fftSize(fftcnt) = 64;
    case 1
        fftTable.fftSize(fftcnt)  = 256;
    case 3
        fftTable.fftSize(fftcnt)  = 1024;
end
fftTable.bandFormationConfig(fftcnt) = fftConfig.bandFormationConfig;
fftTable.config(fftcnt) = fftConfig.config;
fftTable.interval(fftcnt) = fftConfig.interval;
fftTable.size(fftcnt) = fftConfig.size;
fftTable.streamOffsetBins(fftcnt) = fftConfig.streamOffsetBins;
fftTable.streamSizeBins(fftcnt) = fftConfig.streamSizeBins;
fftTable.windowLoad(fftcnt) = fftConfig.windowLoad;

%% get the power
fftSize = fftTable.fftSize;

powerChannels = SensingConfigStruc.powerChannels;
powerChannelsIdxs = [];
idxCnt = 1;
for c = 1:4
    for b = 0:1
        fieldStart = sprintf('band%dStart',b);
        fieldStop = sprintf('band%dStop',b);
        powerChannelsIdxs(idxCnt,1) = powerChannels(c).(fieldStart);
        powerChannelsIdxs(idxCnt,2) = powerChannels(c).(fieldStop);
        idxCnt = idxCnt+1;
    end
end


%% get the bins to compute the power channels
fftSize = fftTable.fftSize(fftcnt);
numBins = fftSize/2;
binWidth = (sampleRate/2)/numBins;
i = 0;
bins = [];
while i < numBins
    bins(i+1) = i*binWidth;
    i =  i + 1;
end
FFTSize = fftSize; % can be 64  256  1024
sampleRate = sampleRate; % can be 250,500,1000

numberOfBins = FFTSize/2;
binWidth = sampleRate/2/numberOfBins;

for i = 0:(numberOfBins-1)
    fftBins(i+1) = i*binWidth;
    %     fprintf('bins numbers %.2f\n',fftBins(i+1));
end

lower(1) = 0;
for i = 2:length(fftBins)
    valInHz = fftBins(i)-fftBins(2)/2;
    lower(i) = valInHz;
end

for i = 1:length(fftBins)
    valInHz = fftBins(i)+fftBins(2)/2;
    upper(i) = valInHz; 
end
powerChannelsIdxs = powerChannelsIdxs + 1; % since C# is 0 indexed and Matlab is 1 indexed.
powerBandInHz = {};
for pc = 1:size(powerChannelsIdxs,1)
    powerBandInHz{pc,1} = sprintf('%.2fHz-%.2fHz',...
        lower(powerChannelsIdxs(pc,1)),upper(powerChannelsIdxs(pc,2)));
    fnUse = sprintf('band%dHz',pc);
    powerTable.(fnUse)(pwrcnt,1) = lower(powerChannelsIdxs(pc,1));
    powerTable.(fnUse)(pwrcnt,2) = upper(powerChannelsIdxs(pc,2));
end
powerTable.powerBandInHz{pwrcnt} = powerBandInHz;



%% load stimulation config
% this code (re stim sweep part) assumes no change in stimulation from initial states
% this code will fail for stim sweeps or if any changes were made to
% stimilation 
% need to fix this to include stim changes and when the occured to color
% data properly according to stim changes and when the took place for in
% clinic testing 


cnt = 1;
stimState = table();

% need to find the valid group
initialStructure = DeviceSettings{1};
fieldNamesGroupsRaw = fieldnames(initialStructure);
idxTherapyGroups = cellfun(@(x) any(strfind(x,'TherapyConfigGroup')), fieldNamesGroupsRaw);
fieldNamesTherapyGroups = fieldNamesGroupsRaw(idxTherapyGroups,:);
therapyStatus = initialStructure.GeneralData.therapyStatusData;
groupNumberActive = therapyStatus.activeGroup;

for tg = 1:length( fieldNamesTherapyGroups )
    groupNumber = tg-1; 
    switch groupNumber
        case 0
            groupName = 'A';
        case 1
            groupName = 'B';
        case 2
            groupName = 'C';
        case 3
            groupName = 'D';
    end
    therapyGroup = initialStructure.(fieldNamesTherapyGroups{tg});
    for p = 1:4
            stimState.group(cnt) = groupName;
           
            if groupNumber == therapyStatus.activeGroup
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
            if therapyGroup.programs(p).isEnabled==0 % 0 means enabled
                stimState.programEnabeled(cnt) = 1;
            else
                stimState.programEnabeled(cnt) = 0;
            end
             stimState.group(cnt) = groupName;
            stimState.pulseWidth_mcrSec(cnt) = therapyGroup.programs(p).pulseWidthInMicroseconds;
            stimState.amplitude_mA(cnt) = therapyGroup.programs(p).amplitudeInMilliamps;
            stimState.rate_Hz(cnt) = therapyGroup.rateInHz;
            elecs = therapyGroup.programs(p).electrodes.electrodes;
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
            
            % active / passive recharge
            activeRechargeRatio = therapyGroup.programs(p).miscSettings.activeRechargeRatio;
            if activeRechargeRatio == 10
                stimState.active_recharge(cnt) = 1;
            elseif activeRechargeRatio == 0
                stimState.active_recharge(cnt) = 0;
            else
                stimState.active_recharge(cnt) = NaN; % unexpected value
            end
            cnt = cnt + 1;
        
    end
end
stimStatus = table();

idxValidGroupAndProgram = stimState.activeGroup & stimState.programEnabeled;
if sum(idxValidGroupAndProgram) == 0 % no valid programs 
    % report the first program as "valid" even thought it isn'tl 
    stimStatus = stimState(1,:); 
else
    stimStatus = stimState(idxValidGroupAndProgram,:);
    
end
for sss = 1:size(stimStatus,1)
    stimStatus.time(sss) = time;
    stimStatus.duration(sss) = seconds(0);
end
stimStatus = stimStatus(:,{'time','duration','group','stimulation_on','activeGroup','program','programEnabeled',...
    'electrodes','amplitude_mA','rate_Hz','pulseWidth_mcrSec',...
    'active_recharge'});

% loop on programs to find different stim states 
% print all device settings to see if I am missing somethings 
clc;
% for ds = 2:length(DeviceSettings)
%     fns = fieldnames(DeviceSettings{ds});
%     fprintf('%0.2d:\n',ds); 
%     for f = 1:length(fns)
%     fprintf('%s\n',fns{f});
%     end
%     fprintf('\n\n');
% end
stimStateChanges = stimStatus;

for ds = 2:length(DeviceSettings)
    curFieldNames = fieldnames(DeviceSettings{ds});
    idxTherapyGroups = cellfun(@(x) any(strfind(x,'TherapyConfigGroup')), curFieldNames);
    groupNumber = tg-1;

    if sum(idxTherapyGroups)>0 % check if therapy is being configured 
        therapyGroup = curFieldNames{idxTherapyGroups};
        groupNumber = str2num(therapyGroup(end));
        switch groupNumber
            case 0
                groupName = 'A';
            case 1
                groupName = 'B';
            case 2
                groupName = 'C';
            case 3
                groupName = 'D';
        end
        therapySettings = DeviceSettings{ds}.(curFieldNames{idxTherapyGroups});
        % only check for things that you can change within session: 
        % amp, rate, pulsewidth
        % note that this code may break if multiple programs are enabled. 
        enabledProgram = find([therapySettings.programs.isEnabled] == 0 ,1);
        idxBeingChanged = strcmp({groupName},stimState.group) & ...
            stimState.program == enabledProgram;
        if sum(idxBeingChanged) > 0
            stimState(idxBeingChanged,:);
            % update with changes from this current payload
            curLen = size(stimStateChanges,1);
            preIdx = curLen; %  previous index
            curIdx = curLen + 1; %  current index
            stimStateChanges(curIdx,:) = stimStateChanges(preIdx,:);
            % update timing info
            RecordInfo = DeviceSettings{ds}.RecordInfo;
            timenum = RecordInfo.HostUnixTime;
            Curtime = datetime(timenum/1000,'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
            
            stimStateChanges.time(curIdx)  = Curtime;
            stimStateChanges.duration(curIdx)  = stimStateChanges.time(curIdx) - stimStateChanges.time(preIdx);
            stimStateChanges.group(curIdx) = groupName;
            stimStateChanges.program(curIdx) = enabledProgram;
            stimStateChanges.amplitude_mA(curIdx) = therapySettings.programs(enabledProgram).amplitudeInMilliamps;
            stimStateChanges.rate_Hz(curIdx) = therapySettings.rateInHz;
            stimStateChanges.pulseWidth_mcrSec(curIdx) = therapySettings.programs(enabledProgram).pulseWidthInMicroseconds;
        end
    end
    
    curFieldNames = fieldnames(DeviceSettings{ds});
    idxGeneralData = cellfun(@(x) any(strfind(x,'GeneralData')), curFieldNames);
    if sum(idxGeneralData)>0 % check if general data is being configured
        generalDataSettings = DeviceSettings{ds}.(curFieldNames{idxGeneralData});
        therapyStatus = generalDataSettings.therapyStatusData;
        curLen = size(stimStateChanges,1);
        preIdx = curLen; %  previous index
        curIdx = curLen + 1; %  current index
        stimStateChanges(curIdx,:) = stimStateChanges(preIdx,:);
        % update timing info
        RecordInfo = DeviceSettings{ds}.RecordInfo;
        timenum = RecordInfo.HostUnixTime;
        Curtime = datetime(timenum/1000,'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
        stimStateChanges.time(curIdx)  = Curtime;
        stimStateChanges.duration(curIdx)  = stimStateChanges.time(curIdx) - stimStateChanges.time(preIdx);
        groupNumber = therapyStatus.activeGroup; 
        switch groupNumber
            case 0
                groupName = 'A';
            case 1
                groupName = 'B';
            case 2
                groupName = 'C';
            case 3
                groupName = 'D';
        end
        stimStateChanges.group(curIdx) = groupName; 
        stimStateChanges.stimulation_on(curIdx) = therapyStatus.therapyStatus;

    end

    
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
adaptiveSettings = table();
adaptiveSettings.time = time; 
adaptiveSettings.duration = seconds(0); 


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
            adaptiveSettings.([lds_fn{ll} '_' 'biasTerm']) = LD.biasTerm';
            adaptiveSettings.([lds_fn{ll} '_' 'normalizationMultiplyVector']) = [LD.features.normalizationMultiplyVector];
            adaptiveSettings.([lds_fn{ll} '_' 'normalizationSubtractVector']) = [LD.features.normalizationSubtractVector];
            adaptiveSettings.([lds_fn{ll} '_' 'weightVector']) = [LD.features.weightVector];
            for d = 1:length(det_fiels)
                adaptiveSettings.([lds_fn{ll} '_' det_fiels{d}])  =  LD.(det_fiels{d});
            end
        else % fill in previous settings.
            warning('missing field on first itiration');
        end
    end
    adaptiveSettings.HostUnixTime = curStr.RecordInfo.HostUnixTime;
end
if isfield(curStr,'AdaptiveConfig')
    adaptive_fields = {'adaptiveMode','adaptiveStatus','currentState',...
        'deltaLimitsValid','deltasValid'};
    adaptiveConfig = curStr.AdaptiveConfig;
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
warning('on','MATLAB:table:RowsAddedExistingVars');


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
    % lpf 1 (bacnk end amplifier)
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