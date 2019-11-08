function loadStimSettings(fn)
stimRaw = jsondecode(fixMalformedJson(fileread(fn),'StimSettings'));

initialStimSettings = table(); 
for s = 1 % this needs way more work ...
    % rec info 
    fnms = {'ApiVer','DeviceId',...
        'HostUnixTime','SessionId'};
    recInfo = stimRaw{s}.RecordInfo;
    for f = 1:length(fnms)
        stimSettings(s).(fnms{f}) = [recInfo.(fnms{f})];
    end
    % therapy status 
    fnms = {'activeGroup','therapyStatus'};
    therStatus = stimRaw{s}.therapyStatusData;
    for f = 1:length(fnms)
        stimSettings(s).(fnms{f}) = [therStatus.(fnms{f})];
    end
    activeGroups = zeros(4,1); 
    activeGroups(stimSettings(s).activeGroup+1) = 1; % since zero indxed 
    therapyStas  = zeros(4,1); 
    therapyStas(stimSettings(s).activeGroup+1) = stimSettings.therapyStatus; 
    
    % loop on grops 
    groupNames = {'GroupA_','GroupB_','GroupC_','GroupD_'};
    groupNamesInitialSettings = {'A','B','C','D'}; 
    progNames = {'prog0_','prog1_','prog2_','prog3_'};
    for g = 1:4
        fldnm = sprintf('TherapyConfigGroup%d',g-1); 
        
        thrpConfigGroup = stimRaw{s}.(fldnm); 
        fnuse = sprintf('%s_%s',groupNames{g},'ratePeriod'); 
        stimSettings(s).(fnuse) = thrpConfigGroup.ratePeriod;
        fnuse = sprintf('%s_%s',groupNames{g},'RateInHz'); 
        stimSettings(s).(fnuse) = thrpConfigGroup.RateInHz;
        initialStimSettings.group{g} = groupNamesInitialSettings{g}; 
        initialStimSettings.rate(g) = thrpConfigGroup.RateInHz;
        % loop on program 
        for p = 1:4
            progfn = sprintf('program%d',p-1);
            prog = thrpConfigGroup.(progfn); 
            progfnms = {'AmplitudeInMilliamps','PulseWidthInMicroseconds'};
            for pp = 1:length(progfnms)
                fnmout = sprintf('%s%s%s',groupNames{g},progNames{p},progfnms{pp});
                stimSettings(s).(fnmout) = prog.(progfnms{pp});
                if p == 1 
                    initialStimSettings.(progfnms{pp})(g) = prog.(progfnms{pp});
                end
            end
        end
    end
end
initialStimSettings.activeGroup = activeGroups;
initialStimSettings.therapyStatus = therapyStas;

% initialize a table of stim events: 
stimEvents = table(); 
firstSettings = initialStimSettings( initialStimSettings.activeGroup==1,:);
% put the first records in from the initial stim settings structure 
stimEvents.group = firstSettings.group;
stimEvents.rate = firstSettings.rate;
stimEvents.AmplitudeInMilliamps = firstSettings.AmplitudeInMilliamps;
stimEvents.PulseWidthInMicroseconds = firstSettings.PulseWidthInMicroseconds;
if firstSettings.therapyStatus
    stimEvents.stimStatus = {'stim on'};
else
    stimEvents.stimStatus = {'stim off'};
end
stimEvents.EventType = {'config'};


t = datetime(stimRaw{1}.RecordInfo.HostUnixTime/1000,...
    'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');

stimEvents.HostUnixTime = stimRaw{1}.RecordInfo.HostUnixTime;
stimEvents.HostUnixTimeHuman = t; 

stimEvents(2,:) = stimEvents(1,:); 
stimEvents.EventType{2} = 'therapy status'; 
 
meta.DeviceId = stimRaw{1}.RecordInfo.DeviceId;
meta.SessionId = stimRaw{1}.RecordInfo.SessionId;
meta.ApiVer = stimRaw{1}.RecordInfo.ApiVer;

% what type of data do you have? 
types = {}; 
cnt = 1; 

stimRaw = stimRaw(2:end); % get rid of first initial report 
groupNamesUse = {'A','B','C','D'};
stimEventsIdx = size(stimEvents,1) + 1; 
for s = 1:length(stimRaw)
    fieldNamesOut{s} = fieldnames(stimRaw{s});
    stimRawTemp = stimRaw{s}; 
    HostUnixTime = stimRawTemp.RecordInfo.HostUnixTime;
    t = datetime(stimRawTemp.RecordInfo.HostUnixTime/1000,...
        'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');

    % find out if you have a config or status event 
    if any(strfind(fieldNamesOut{s}{2},'TherapyConfig'))
        groupTemp = groupNamesUse{str2num(fieldNamesOut{s}{2}(end))+1};
        stimEvents.group(stimEventsIdx) = {groupTemp};        
        prog = stimRawTemp.(fieldNamesOut{s}{2});
        if isfield(prog,'RateInHz')
            stimEvents.rate(stimEventsIdx) = prog.RateInHz;
        else
            stimEvents.rate(stimEventsIdx) = NaN;
        end
        if isfield(prog,'program0')
            if isfield(prog.program0,'AmplitudeInMilliamps')
                stimEvents.AmplitudeInMilliamps(stimEventsIdx) = prog.program0.AmplitudeInMilliamps;
            else
                stimEvents.AmplitudeInMilliamps(stimEventsIdx) = NaN;
            end
        end
        if isfield(prog,'program0')
            if isfield(prog.program0,'PulseWidthInMicroseconds')
                stimEvents.PulseWidthInMicroseconds(stimEventsIdx) = prog.program0.PulseWidthInMicroseconds;
            else
                stimEvents.PulseWidthInMicroseconds(stimEventsIdx) = NaN;
            end
        end
        stimEvents.stimStatus(stimEventsIdx) = stimEvents.stimStatus(stimEventsIdx-1);
        stimEvents.EventType(stimEventsIdx) = {'config'};
        stimEvents.HostUnixTime(stimEventsIdx) = HostUnixTime;
        stimEvents.HostUnixTimeHuman(stimEventsIdx) = t;
        
        
        stimEventsIdx = stimEventsIdx + 1;
    elseif any(strfind(fieldNamesOut{s}{2},'therapyStatusData'))
        fieldChanged = fieldnames(stimRawTemp.therapyStatusData);
        fieldChanged = fieldChanged{1};
        switch fieldChanged
            case 'therapyStatus' 
                % pre populate with previous event:
                stimEvents(stimEventsIdx,:) = stimEvents(stimEventsIdx-1,:);
                stimEvents.EventType(stimEventsIdx) = {'therapy status'};

                if stimRawTemp.therapyStatusData.therapyStatus
                    stimEvents.stimStatus(stimEventsIdx) = {'stim on'};
                else
                    stimEvents.stimStatus(stimEventsIdx) = {'stim off'};
                end
                stimEvents.HostUnixTime(stimEventsIdx) = HostUnixTime;
                stimEvents.HostUnixTimeHuman(stimEventsIdx) = t;
            case 'activeGroup'
                stimEventsTemp = stimEvents(1:end-1,:); 
                group = groupNamesUse{stimRawTemp.therapyStatusData.activeGroup+1}; % sinze zero idx'd
                stimEvents.group(stimEventsIdx) = {group}; 
                stimEvents.EventType(stimEventsIdx) = {'group change'};
                stimEvents.HostUnixTime(stimEventsIdx) = HostUnixTime;
                stimEvents.HostUnixTimeHuman(stimEventsIdx) = t;
                stimEvents.stimStatus(stimEventsIdx) = stimEvents.stimStatus(stimEventsIdx-1); 
                % look for a previous config of that group, if that doesn't
                % exist, use what you have in initial settings 
                idxConfig = find(cellfun(@(x) strcmp(x,group),stimEventsTemp.group)==1,1,'last');
                if isempty(idxConfig) % hasn't been configued in this session, used initial settings 
                    stimSettings = initialStimSettings(strcmp(initialStimSettings.group,group),:);
                    stimEvents.rate(stimEventsIdx) = stimSettings.rate;
                    stimEvents.AmplitudeInMilliamps(stimEventsIdx) = stimSettings.AmplitudeInMilliamps;
                    stimEvents.PulseWidthInMicroseconds(stimEventsIdx) = stimSettings.PulseWidthInMicroseconds;
                else
                    stimEvents.rate(stimEventsIdx) = stimEvents.rate(idxConfig); 
                    stimEvents.AmplitudeInMilliamps(stimEventsIdx) = stimEvents.AmplitudeInMilliamps(idxConfig); 
                    stimEvents.PulseWidthInMicroseconds(stimEventsIdx) = stimEvents.PulseWidthInMicroseconds(idxConfig); 
                end
        end
        stimEventsIdx = stimEventsIdx + 1;
    end

end
[pn,fnn, ext] = fileparts(fn);
savefn = fullfile(pn,[fnn '.mat']); 
save(savefn,'stimEvents','initialStimSettings','meta');
end