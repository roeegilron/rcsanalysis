function meta = get_device_id_return_meta_data(fn)
%% this function takes a device settings.json file 
%% and returns device ID and other meta data about the recording 
warning('off','MATLAB:table:RowsAddedExistingVars');
dirSave = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database';
load(fullfile(dirSave, 'deviceIdMasterList.mat'),'masterTable'); 

tic 
fid = fopen(fn); 
fseek(fid, 0, 'bof');
text = fread(fid, 500,'uint8=>char')';
fileIsEmpty = 0; % assume that file is not empty until proven otherwise 
% check that this file is not empty 
if length(text)<200 %  this is an empty time domain file 
    fileIsEmpty = 1; 
end
meta = table();
if ~fileIsEmpty
    
    % get device ID: 
    deviceIdRaw = regexp(text,'(?<=,"DeviceId":")[a-zA-Z_0-9]+','match');
    deviceID{1} = deviceIdRaw{1};
    
    meta = get_patient_side_from_device_id(deviceID{1},masterTable);
    
    % get start time
    rawtime = regexp(text,'(?<=,"HostUnixTime":)[0-9]+','match');
    timenum = str2num(rawtime{1});
    meta.timeStart(1) = datetime(timenum/1000,'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
    
    
    % now go to end of the file
    fseek(fid, -10000, 'eof');
    filesize = ftell(fid);
    text = fread(fid, 10000,'uint8=>char')';
    rawtime = regexp(text,'(?<=,"HostUnixTime":)[0-9]+','match');
    if ~isempty(rawtime) % can use text based methods (no json structure needed to get time end 
        timenum = str2num(rawtime{1});
        meta.timeEnd(1) = datetime(timenum/1000,'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
    else % need to try and open json file 
        DeviceSettings = jsondecode(fixMalformedJson(fileread(fn),'DeviceSettings'));
        % fix issues with device settings sometiems being a cell array and
        % sometimes not
        
        if isstruct(DeviceSettings)
            DeviceSettings = {DeviceSettings};
            timenum = DeviceSettings{end}.RecordInfo.HostUnixTime;
            meta.timeEnd(1) = datetime(timenum/1000,'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');

        end
    end

    meta.duration(1) = meta.timeEnd - meta.timeStart;

else
    
    meta.deviceID{1} = '';
    meta.timeStart(1) = NaT; 
    meta.timeEnd(1) = NaT; 
    meta.duration(1) = seconds(0); 
    
end
 
fclose(fid);


end

function metaResults = get_patient_side_from_device_id(deviceId,masterTable)
idxuse = cellfun(@(x) any(strfind(x,lower(deviceId))), masterTable.deviceId);
if sum(idxuse) > 1 
    error('more than one match found in master table')
else
    metaResults = masterTable(idxuse,:);
end
end

