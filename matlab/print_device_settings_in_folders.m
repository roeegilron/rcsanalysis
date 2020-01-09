function print_device_settings_in_folders(dirname)
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
elseif isdatetime( tblout.startTime);
    datTab = tblout;
end
txtfilename = fullfile(dirname,'channels_recorded_from_per_session.txt'); 
fid = fopen(txtfilename,'w+'); 
for s = 1:size(datTab,1) % loop on sessions 
    sesstime = datTab.rectime(s);
    sesstime.Format = 'dd-MMM-yyyy HH:mm';
    fprintf(fid,'[%0.2d]\n',s);
    fprintf(fid,'\t%s\n',sesstime);
    if iscell(datTab.startTime)
        fprintf(fid,'\t%s\n',datTab.endTime{s} - datTab.startTime{s});
    else
        fprintf(fid,'\t%s\n',datTab.endTime(s) - datTab.startTime(s));
    end
    % load device settings 
    try 
    [pn,fn] = fileparts(datTab.tdfile{s});
    fileload = fullfile(pn,'DeviceSettings.mat');
    load(fileload); 
    for i = 1:length(outRec)
        channelsFound = {outRec(i).tdData.chanFullStr}';
        for c = 1:length(channelsFound)
            fprintf(fid,'\t\t%s\n',channelsFound{c});
        end
        fprintf(fid,'\n');
    end
    end
end
fclose(fid);
end