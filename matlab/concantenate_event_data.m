function concantenate_event_data(dirname)
% firt resave all the event log evetns
ff = findFilesBVQX(dirname,'EventLog.json');
for f = 1:length(ff)
    try
        eventTable  = loadEventLog(ff{f});
        [pn,fn,ext] = fileparts(ff{f});
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
    if ~isempty(eventTable)
        if f == 1
            eventOut = eventTable;
        else
            eventOut = [eventOut; eventTable];
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

save(fullfile(dirname,'allEvents.mat'),'allEvents'); 

end