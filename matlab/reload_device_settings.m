function reload_device_settings(dirname)

% now only choose folders that are above a certain duration 
load(fullfile(dirname,'database.mat'),'tblout'); 
if iscell(tblout.duration)
    idxnotEmpty = cellfun(@(x) ~isempty(x),tblout.duration); 
else
    idxnotEmpty = tblout.duration > seconds(0); 
end

tbluse = tblout(idxnotEmpty,:);
if iscell(tblout.duration)
    idxRecordingsOver30Seconds = cellfun(@(x) x > seconds(30), tbluse.duration);
else
    idxRecordingsOver30Seconds = tblout.duration > seconds(30); 
end
tbluse = tbluse(idxRecordingsOver30Seconds,:); 
startTimes = [tbluse.startTime{:}]';
idxopen = isbetween(startTimes,'19-Jun-2019','10-Jul-2019');
tbluse = tbluse(idxopen,:); 


ff = findFilesBVQX(dirname,'DeviceSettings.json');
for f = 1:size(tbluse,1)
    [pn,fn,ext] = fileparts(tbluse.tdfile{f});
    ds = findFilesBVQX(pn,'DeviceSettings.json');
    outRec = loadDeviceSettings(ds{1});
end

end