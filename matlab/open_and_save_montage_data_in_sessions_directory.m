function open_and_save_montage_data_in_sessions_directory(dirname)
%% this file opens and saves montage data in a session direcotry

if exist( fullfile(dirname,'allEvents.mat'), 'file')
    load(fullfile(dirname,'allEvents.mat'))
else
    concantenate_event_data(dirname);
    load(fullfile(dirname,'allEvents.mat'))
end

%% Find all the montage directories in this folder
eventData = allEvents.eventOut;
montageEvents = eventData(cellfun(@(x) any(strfind(x,': config')),eventData.EventType) , :);
sessionIds    = unique(montageEvents.sessionid);

%% loop on each montage session and save the data in a .mat file
clc;
for s = 1:length(sessionIds)
    
    fsessionDir = findFilesBVQX(dirname,sprintf('*%s*',sessionIds{s}),struct('dirs',1));
    fdeviceDir  = findFilesBVQX(fsessionDir{1},sprintf('Device*',sessionIds{s}),struct('dirs',1));
    deviceSettingsFn = fullfile(fdeviceDir{1},'DeviceSettings.json');
    outRec = loadDeviceSettingsForMontage(deviceSettingsFn);
    fileload = fullfile(fdeviceDir{1},'EventLog.json');
    eventTable = loadEventLog(fileload);
    
    % get and save data
    montageData = extract_montage_data(fdeviceDir{1});
    if ~isempty(montageData)
        savename    = fullfile(fdeviceDir{1},'rawMontageData.mat');
        save(savename,'montageData');
    end
    
    % print out montages for quality control
    fprintf('time %s\n',eventTable.sessionTime(1))
    fprintf('_________\n');
    fprintf('_________\n');
    for i = 1:length(outRec)
        cellfun(@(x) fprintf('%0.2d %s\n',i,x),{outRec(i).tdData.chanFullStr}')
        fprintf('_________\n');
    end
    fprintf('_________\n');
    fprintf('_________\n');
    fprintf('\n');
    fprintf('\n');
end
%%

end

function montageData = extract_montage_data(dirname)
badFile = 0; % default
[outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerTable] =  MAIN_load_rcs_data_from_folder(dirname);
deviceSettingsFn = fullfile(dirname,'DeviceSettings.json');
outRec = loadDeviceSettingsForMontage(deviceSettingsFn);
% figure out add / subtract factor for event times (if pc clock is not same
% as INS time).
idxTimeCompare = find(outdatcomplete.PacketRxUnixTime~=0,1);
packRxTimeRaw  = outdatcomplete.PacketRxUnixTime(idxTimeCompare);
packtRxTime    =  datetime(packRxTimeRaw/1000,...
    'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
derivedTime    = outdatcomplete.derivedTimes(idxTimeCompare);
timeDiff       = derivedTime - packtRxTime;
% add a delta to the event markers
deltaUse = seconds(3);
secs = outdatcomplete.derivedTimes;
app.subTime = secs(1);
% find start events
idxStart = cellfun(@(x) any(strfind(x,'Start')),eventTable.EventType);
idxEnd = cellfun(@(x) any(strfind(x,'Stop')),eventTable.EventType);

% insert event table markers and link them
app.ets = eventTable(idxStart,:);
app.ete = eventTable(idxEnd,:);
app.hpltStart = gobjects(sum(idxStart),4);
app.hpltEnd = gobjects(sum(idxStart),4);
% check if this is a valid montage that completed until the end
if size(app.ets,1) ~= size(app.ete,1)
    badFile = 1;
end

% save the raw data
cntStn = 1;
cntM1 = 1;
idxStnM1 = [1:2; 3:4];
cntUse = [ 1 1 ];
fieldName = {'rawDatSTN','rawDatM1'};
if ~badFile
    for i = 1:sum(idxStart)
        % start
        xval = app.ets.UnixOffsetTime(i) + timeDiff +  deltaUse;
        startTime = xval ;
        % end
        xval = app.ete.UnixOffsetTime(i)+timeDiff - deltaUse;
        endTime = xval;
        secsUse = secs;
        idxuse = secsUse > startTime & secsUse < endTime;
        % get data
        for c = 1:4
            cfnm = sprintf('key%d',c-1);
            yTemp(:,c) = outdatcomplete.(cfnm)(idxuse)';
        end
        
        % take care of STN and M1 seperatly
        for a = 1:size(idxStnM1,2)
            tdDataTemp = outRec(i).tdData(idxStnM1(a,:));
            sr = str2num(strrep(tdDataTemp(1).sampleRate,'Hz',''));
            % check to make sure no disabled channels
            if ~sum(cellfun(@(x) any(strfind(x,'disabled')),{tdDataTemp.chanFullStr}))
                % get unique contacts
                unqChannels = unique({tdDataTemp.chanOut});
                if length(unqChannels) == 2 % don't average
                    for u = 1:length(unqChannels)
                        app.(fieldName{a})(cntUse(a)).rawdata = yTemp(:,idxStnM1(a,u));
                        app.(fieldName{a})(cntUse(a)).sr = sr;
                        app.(fieldName{a})(cntUse(a)).chan = tdDataTemp(u).chanOut;
                        app.(fieldName{a})(cntUse(a)).chanFullStr = tdDataTemp(u).chanFullStr;
                        app.(fieldName{a})(cntUse(a)).recIdx = i;
                        cntUse(a) = cntUse(a) + 1;
                    end
                elseif length(unqChannels) == 1 % average
                    app.(fieldName{a})(cntUse(a)).rawdata = mean(yTemp(:,idxStnM1(a,:)),2);
                    app.(fieldName{a})(cntUse(a)).sr = sr;
                    app.(fieldName{a})(cntUse(a)).chan = tdDataTemp(1).chanOut;
                    app.(fieldName{a})(cntUse(a)).chanFullStr = tdDataTemp(1).chanFullStr;
                    app.(fieldName{a})(cntUse(a)).recIdx = i;
                    cntUse(a) = cntUse(a) + 1;
                end
            end
            clear tdDataTemp
        end
        clear yTemp
        
    end
end

if ~isfield(app,'rawDatSTN')
    badFile = 1;
end
if ~isfield(app,'rawDatM1')
    badFile = 1;
end

if badFile
    montageData = [];
else
    montageData.LFP = app.rawDatSTN;
    montageData.M1  = app.rawDatM1;
    montageData.startTime = secs(1);
    montageData.endTime = secs(end);
    % get patient 
    [pn,fn] = fileparts(dirname);
    [pn,fn] = fileparts(pn);
    [pn,patientraw] = fileparts(pn);
    montageData.patient = patientraw(1:end-1); 
    montageData.side = patientraw(end); 
    % get side 
    
end
end