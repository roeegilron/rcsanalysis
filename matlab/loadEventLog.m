function eventLog  = loadEventLog(fn)
eventLog = jsondecode(fixMalformedJson(fileread(fn),'EventLog'));
[pn,fnm,ext ] = fileparts(fn);
save(fullfile(pn,[fnm '.mat']),'eventLog');

