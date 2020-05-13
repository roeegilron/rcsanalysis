function [montageData, montageDataRaw] = extract_montage_data(dirname)
badFile = 0; % default
[outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerTable] =  MAIN_load_rcs_data_from_folder(dirname);
deviceSettingsFn = fullfile(dirname,'DeviceSettings.json');
deviceSettings = loadDeviceSettingsForMontage(deviceSettingsFn);
% get rid of any montage files that are less than 20 seconcds 
idxkeep = deviceSettings.duration > seconds(20);
deviceSettings = deviceSettings(idxkeep,:); 

% this section takes an event table that has events in computer time and
% returns derived times in INS time 

%  Each data structure has a PC clock-driven time when the packet was received via Bluetooth, 
% as accurate as a C# DateTime.now (10-20ms).   

% in the eventTable structure this is UnixOnsetTime
% in the timedomain strucutre this is PacketRxUnixTime

% the goal of the code is to find the smallest different between
% UnixOnsetTime and PacketRxUnixTime abd get the INS time domain value for
% this sample. 
idxnonzero = find(outdatcomplete.PacketRxUnixTime~=0); 
% PacketGenTime
% PacketRxUnixTime
packtRxTimes    =  datetime(outdatcomplete.PacketGenTime(idxnonzero)/1000,...
    'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
% note that we only get one time sample for each time domain packet. 
% this finds the closest time sample in "packet time". 
derivesTimesWithInsTime = outdatcomplete.derivedTimes(idxnonzero); 



% get patient
[pn,fn] = fileparts(dirname);
[pn,fn] = fileparts(pn);
[pn,patientraw] = fileparts(pn);
patient = patientraw(1:end-1);
side = patientraw(end);


% convert the packet rx unix time to ins times 
for e = 1:size(deviceSettings,1)
    % start time  - is before end time in some cases fix this 
    [timeDiff, idx] = min(abs(deviceSettings.timeStart(e) - packtRxTimes));
    timeDiffVec(e) = timeDiff;
    timeDiffUse = packtRxTimes(idx) - deviceSettings.timeStart(e) ;
    insTimeUncorrected = derivesTimesWithInsTime(idx);
    deviceSettings.timeStart(e)       = insTimeUncorrected - timeDiffUse;
    % stop time 
    [timeDiff, idx] = min(abs(deviceSettings.timeStop(e) - packtRxTimes));
    timeDiffVec(e) = timeDiff;
    timeDiffUse = packtRxTimes(idx) - deviceSettings.timeStop(e) ;
    insTimeUncorrected = derivesTimesWithInsTime(idx);
    deviceSettings.timeStop(e)       = insTimeUncorrected - timeDiffUse;
end

montageDataRaw = deviceSettings(:,{'duration','samplingRate','chan1','chan2','chan3','chan4','TimeDomainDataStruc'});
for i = 1:size(deviceSettings,1)
    secsUse = outdatcomplete.derivedTimes;
    idxuse = secsUse > deviceSettings.timeStart(i) & secsUse < deviceSettings.timeStop(i);
    % get data
    for c = 1:4
        cfnm = sprintf('key%d',c-1);
        yTemp(:,c) = outdatcomplete.(cfnm)(idxuse)';
    end
    montageDataRaw.data{i} = yTemp;
    secssave = secsUse(idxuse);
    montageDataRaw.derivedTimes{i} = secssave - secssave(1); 
    montageDataRaw.derivedTimesRaw{i} = secssave;
    
    montageDataRaw.startTime(i) = deviceSettings.timeStart(i);
    montageDataRaw.patient{i} = patient;
    montageDataRaw.side{i} = side; 
    
    clear yTemp;
end


% save the raw data
cntStn = 1;
cntM1 = 1;
idxStnM1 = [1:2; 3:4];
cntUse = [ 1 1 ];
fieldName = {'rawDatSTN','rawDatM1'};
for i = 1:size(deviceSettings,1)
    secsUse = outdatcomplete.derivedTimes;
    idxuse = secsUse > deviceSettings.timeStart(i) & secsUse < deviceSettings.timeStop(i);
    % get data
    for c = 1:4
        cfnm = sprintf('key%d',c-1);
        yTemp(:,c) = outdatcomplete.(cfnm)(idxuse)';
    end
    
    % take care of STN and M1 seperatly
    for a = 1:size(idxStnM1,2)
        tdDataTemp = deviceSettings.TimeDomainDataStruc{i}(idxStnM1(a,:));
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
    montageData.startTime = deviceSettings.timeStart;
    montageData.endTime = deviceSettings.timeStop;
    montageData.durations = deviceSettings.duration;
    % get patient 
    [pn,fn] = fileparts(dirname);
    [pn,fn] = fileparts(pn);
    [pn,patientraw] = fileparts(pn);
    montageData.patient = patientraw(1:end-1); 
    montageData.side = patientraw(end); 
    % get side 
end
end