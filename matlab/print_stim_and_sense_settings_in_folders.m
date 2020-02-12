function print_stim_and_sense_settings_in_folders(dirname)
% this will print the channels recorded from in each file 
databasefile = fullfile(dirname,'database.mat'); 
if exist(databasefile,'file') 
    load(databasefile);
else
    MAIN_report_data_in_folder(dirname); 
end
if iscell(tblout.startTime)
    idxkeep = cellfun(@(x) ~isempty(x),tblout.startTime);
    datTab = tblout(idxkeep,:);
    datTab.duration = cellfun(@(x) x(1),datTab.duration);
elseif isdatetime( tblout.startTime)
    datTab = tblout;
end

fid = fopen(fullfile(dirname,'stimAndDeviceSettingsLog.txt'),'w+');
for s = 1:size(datTab,1) 
    [pn,fn,ext] = fileparts(datTab.tdfile{s});
    jsonfn = fullfile(pn,'DeviceSettings.json');
    loadDeviceSettings(jsonfn);
    load(fullfile(pn,'DeviceSettings.mat'));
    if length(outRec) == 1
        jsonfn = fullfile(pn,'StimLog.json');
        loadStimSettings(jsonfn);
        load(fullfile(pn,'StimLog.mat'));
        try 
        fprintf(fid,'%s - %s\n',datTab.startTime{s}, datTab.endTime{s});
        fprintf(fid,'\t - duration %s \t%s\n',datTab.duration(s),datTab.sessname{s});
        catch
            fprintf(fid,'%s - %s\n',datTab.startTime(s), datTab.endTime(s));
            fprintf(fid,'\t - duration %s \t%s\n',datTab.duration(s),datTab.sessname{s});
        end
        stimTable = stimState(logical(stimState.activeGroup),:);
        fprintf(fid,'\t - stim:\t group %s - stim state %d stim amp %.2f rate %.2f\n',...
            stimTable.group,stimTable.stimulation_on,stimTable.amplitude_mA, stimTable.rate_Hz);
        fprintf(fid,'\n');
        fprintf(fid,'\t\t\t\t\t\t\t\t\t%s\n',outRec.tdData.chanFullStr);
        fprintf(fid,'\n\n\');
    end
end
