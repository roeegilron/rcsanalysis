function stimTable = loadStimSettings(fn)
stimRaw = jsondecode(fixMalformedJson(fileread(fn),'StimSettings'));

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
    
    % loop on grops 
    groupNames = {'GroupA_','GroupB_','GroupC_','GroupD_'};
    progNames = {'prog0_','prog1_','prog2_','prog3_'};
    for g = 1:4
        fldnm = sprintf('TherapyConfigGroup%d',g-1); 
        
        thrpConfigGroup = stimRaw{s}.(fldnm); 
        fnuse = sprintf('%s_%s',groupNames{g},'ratePeriod'); 
        stimSettings(s).(fnuse) = thrpConfigGroup.ratePeriod;
        fnuse = sprintf('%s_%s',groupNames{g},'RateInHz'); 
        stimSettings(s).(fnuse) = thrpConfigGroup.RateInHz;
        % loop on program 
        for p = 1:4
            progfn = sprintf('program%d',p-1);
            prog = thrpConfigGroup.(progfn); 
            progfnms = {'amplitude','AmplitudeInMilliamps','pulseWidth','PulseWidthInMicroseconds'};
            for pp = 1:length(progfnms)
                fnmout = sprintf('%s%s%s',groupNames{g},progNames{p},progfnms{pp});
                stimSettings(s).(fnmout) = prog.(progfnms{pp});
            end
        end
    end
end
% broken here 
cntStim = 1; 
for s = 2:length(stimRaw)
    fnmsraw = fieldnames(stimRaw{s});
    if ismember('TherapyConfigGroup0',fnmsraw) 
        if isfield(stimRaw{s,1}.TherapyConfigGroup0,'RateInHz')
        % stim info
        stimChanges(cntStim).('RateInHz') = stimRaw{s,1}.TherapyConfigGroup0.RateInHz;
        fnms = {'AmplitudeInMilliamps','PulseWidthInMicroseconds'};
        prog0info = stimRaw{s,1}.TherapyConfigGroup0.program0;
        for f = 1:length(fnms)
            stimChanges(cntStim).(fnms{f}) = [prog0info.(fnms{f})];
        end
        % rec info
        fnms = {'ApiVer','DeviceId',...
            'HostUnixTime','SessionId'};
        recInfo = stimRaw{s,1}.RecordInfo;
        for f = 1:length(fnms)
            stimChanges(cntStim).(fnms{f}) = [recInfo.(fnms{f})];
        end
        cntStim = cntStim + 1;
        end
    end
end
stimTable = struct2table(stimChanges);
end