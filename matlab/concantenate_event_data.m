function concantenate_event_data(dirname)
% find resave all the event log evetns
ff = findFilesBVQX(dirname,'EventLog.json');
for f = 1:length(ff)
    try
        eventTable  = loadEventLog(ff{f});
        [pn,fn,ext] = fileparts(ff{f});
        loadStimSettings(fullfile(pn,'StimLog.json'));
        save(fullfile(pn,[fn '.mat']),'eventTable');
        fprintf('finished reloading event %d/%d\n',f,length(ff));
    catch
        fprintf('failed loading file in event %d/%d\n',f,length(ff));
    end
    
end

ff = findFilesBVQX(dirname,'EventLog.mat');
eventOut = table();

for f = 1:length(ff)
    load(ff{f});
    [pn,fn,ext] = fileparts(ff{f});
    
    try
        timeReport = report_start_end_time_td_file_rcs(fullfile(pn,'RawDataTD.json'));
    catch
        timeReport.duration = [];
    end
    if ~isempty(timeReport.duration)
        %         stimEvents  = stimEvents(end,{'group','rate','AmplitudeInMilliamps','PulseWidthInMicroseconds','stimStatus'});
        %         stimEvents.sesionID = eventTable.sessionid(1);
        %         stimEvents.sessionTime = eventTable.sessionTime(1);
        %         stimEvents.startTime = timeReport.startTime;
        %         stimEvents.endTime = timeReport.endTime;
        %         stimEvents.duration = timeReport.duration;
        if ~isempty(eventTable)
            if f == 1
                eventOut = eventTable;
                %                 stimEventsAll = stimEvents;
            else
                eventOut = [eventOut; eventTable];
                %                 stimEventsAll(f,:) = stimEvents;
            end
        end
    end
    
end



idxKeep = ~(strcmp(eventOut.EventType,'CTMLeftBatteryLevel') | ...
    strcmp(eventOut.EventType,'CTMRightBatteryLevel') | ...
    strcmp(eventOut.EventType,'INSRightBatteryLevel') | ...
    strcmp(eventOut.EventType,'INSLeftBatteryLevel'));
idxInfo = (cellfun(@(x) any(strfind(x,'PatientID')),eventOut.EventType(:)) | ...
    cellfun(@(x) any(strfind(x,'LeadLocation')),eventOut.EventType(:)) | ...
    cellfun(@(x) any(strfind(x,'ImplantedLeads')),eventOut.EventType(:)) | ...
    cellfun(@(x) any(strfind(x,'InsImplantLocation')),eventOut.EventType(:)));

% keep the info re subject leads etc.
allEvents.subInfo = eventOut(idxInfo,:);


% for rest of analyis get rid of that
idxKeep = idxKeep & ~idxInfo;
eventOut = eventOut(idxKeep,:);

% cond events
condEventIdx = strcmp(eventOut.EventType,'conditions');
condEvents = eventOut(condEventIdx,:);
% seperate all conditions into all posisble conditions
allConds = {};
for s = 1:size(condEvents,1)
    condRaw = condEvents.EventSubType{s};
    newstr = split(condRaw,',');
    allConds = [allConds; newstr];
end
% clean up some spaced
cnt = 1;
condsPossUnique = {};
for s = 1:size(allConds,1)
    if ~strcmp(allConds{s},' ')
        if strcmp(allConds{s}(1),' ')
            condsPossUnique{cnt,1} = allConds{s}(2:end);
            cnt = cnt + 1;
        else
            condsPossUnique{cnt,1} = allConds{s};
            cnt = cnt + 1;
        end
    end
    
end
uniqueconds = unique(condsPossUnique);
uniquecondsVar = uniqueconds;
uniquecondsVar = cellfun(@(x) strrep(x,' ',''),uniquecondsVar,'UniformOutput',false);
uniquecondsVar = cellfun(@(x) strrep(x,'(',''),uniquecondsVar,'UniformOutput',false);
uniquecondsVar = cellfun(@(x) strrep(x,')',''),uniquecondsVar,'UniformOutput',false);
uniquecondsVar = cellfun(@(x) strrep(x,'/',''),uniquecondsVar,'UniformOutput',false);
uniquecondsVar = cellfun(@(x) strrep(x,'''',''),uniquecondsVar,'UniformOutput',false);
% loop on session id to create unique profile of stim / symptom per session
condsAndStim = table();
if exist('stimEventsAll','var')
    for s = 1:size(stimEventsAll,1)
        condsAndStim.sessionTime(s) = stimEventsAll.sessionTime(s);
        condsAndStim.sesionID(s) = stimEventsAll.sesionID(s);
        condsAndStim.group(s) = stimEventsAll.group(s);
        condsAndStim.rate(s) = stimEventsAll.rate(s);
        condsAndStim.AmplitudeInMilliamps(s) = stimEventsAll.AmplitudeInMilliamps(s);
        condsAndStim.stimStatus(s) = stimEventsAll.stimStatus(s);
        condsAndStim.startTime(s) = stimEventsAll.startTime(s);
        condsAndStim.endTime(s) = stimEventsAll.endTime(s);
        condsAndStim.duration(s) = stimEventsAll.duration(s);
        % get conds in this session
        idxuse = strcmp(condEvents.sessionid,stimEventsAll.sesionID{s});
        allconds = '';
        allCondsRaw = condEvents.EventSubType(idxuse);
        condsAndStim.rawConds{s} = allCondsRaw;
        for c = 1:size(allCondsRaw,1)
            allconds = [allconds allCondsRaw{c}];
        end
        
        for u = 1:length(uniqueconds)
            if any(strfind(allconds,uniqueconds{u}))
                condsAndStim.(uniquecondsVar{u})(s) = 1;
            else
                condsAndStim.(uniquecondsVar{u})(s) = 0;
            end
        end
    end
end


% med events
medEventIdx = strcmp(eventOut.EventType,'medication');
medEvents   = eventOut(medEventIdx,:);
medEvents   = medEvents(cellfun(@(x) strcmp(x(end),'M'),medEvents.EventSubType),:); % only keep med events with times
xtemp = cellfun(@(x) x(end-21:end),medEvents.EventSubType,'UniformOutput',false);
xtemp = cellfun(@(x) strrep(x,'-',''),xtemp,'UniformOutput',false);
dates = cellfun(@(x) datetime(x,'InputFormat','MM_dd_yyyy hh:mm:SS aa'),xtemp);
medEvents.medTimes = dates;

% on events
onEventIdx = cellfun(@(x) any(strfind(x,'Feeling ''on'' ')),eventOut.EventType(:));
onEvents   = eventOut(onEventIdx,:);

% on events with dyskinesia
onEventIdxWithDykinesia = cellfun(@(x) any(strfind(x,'Feeling ''on'' ')),eventOut.EventType(:)) & ...
    cellfun(@(x) any(strfind(x,'Dyskinesia')),eventOut.EventType(:));
onEventsWithDykinesia   = eventOut(onEventIdxWithDykinesia,:);
% on events without dyskinesia
onEventIdxWithOutDykinesia = cellfun(@(x) strcmp(x,'Feeling ''on'' little / no symptoms, '),eventOut.EventType(:));
onEventsWithOutDykinesia   = eventOut(onEventIdxWithOutDykinesia,:);

% off events
offEventIdx = ~cellfun(@(x) any(strfind(x,'Feeling ''on'' ')),eventOut.EventType(:)) & ...
    (strcmp(eventOut.EventType,'') | ...
    ~strcmp(eventOut.EventType,'medication') );
offEvents   = eventOut(offEventIdx,:);

% off events with including all off's but without dyskinesia

% export data
allEvents.eventOut                 = eventOut;
allEvents.medEvents                = medEvents;
allEvents.onEvents                 = onEvents;
allEvents.offEvents                = offEvents;
allEvents.onEventsWithDykinesia    = onEventsWithDykinesia;
allEvents.onEventsWithOutDykinesia = onEventsWithOutDykinesia;
allEvents.condsAndStim             = condsAndStim;

save(fullfile(dirname,'allEvents.mat'),'allEvents');

end