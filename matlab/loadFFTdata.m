function loadFFTdata(fn)
rawFFtData = deserializeJSON(fn);
fftstruc = rawFFtData.FftData;
headerStruc = [fftstruc.Header];
headerTable = struct2table(headerStruc); 
headerTable.seconds = [headerTable.timestamp.seconds]';
headerTable = headerTable(:,{'dataSize','dataType','dataTypeSequence','globalSequence','info','seconds','systemTick','user1','user2'});
fftTable = struct2table(fftstruc);
fftTable = fftTable(:,{'Channel','SampleRate','FftSize','FftOutput','Units','PacketGenTime','PacketRxUnixTime'}); 
fftTable = [fftTable,headerTable];

% load the device settings to extract the fft information (re x values for
% band - this is the case where you are streaming partial FFT's 

%%
[pn,fn] = fileparts(fn); 
fndevicesettings = fullfile(pn,'DeviceSettings.json');
DeviceSettings = jsondecode(fixMalformedJson(fileread(fndevicesettings),'DeviceSettings'));
deviceSettingTable = table();
recNum = 1; 
f = 1;
strCnt = 1; 
strmStopCnt = 1; 
senseStopCnt = 1; 
instream = 0;
while f <= length(DeviceSettings)
    fnms = fieldnames(DeviceSettings{f});
    curStr = DeviceSettings{f};
    if isfield(curStr,'SensingConfig')
        if isfield(curStr.SensingConfig,'fftConfig')
            timenum = curStr.RecordInfo.HostUnixTime;
            t = datetime(timenum/1000,'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
            deviceSettingTable.action{recNum} = 'sense config';
            deviceSettingTable.recNum(recNum) = NaN;
            deviceSettingTable.timeStart{recNum} = t;
            deviceSettingTable.HostUnixTime(recNum) = timenum;
            fftConfig = curStr.SensingConfig.fftConfig;
            if isfield(curStr.SensingConfig,'timeDomainChannels')
                sampleRates = [curStr.SensingConfig.timeDomainChannels.sampleRate];
                sampleRates = sampleRates(sampleRates ~= 240); 
                unqsampleRate = unique(sampleRates);
                if length(unqsampleRate) > 1 
                    error('sample rate not read properly');
                else
                    switch unqsampleRate
                        case 0 
                            sampleRate = 250; 
                        case 1 
                            sampleRate = 500; 
                        case 2 
                            sampleRate = 1000; 
                    end
                end
            end
            
            % populate fft config 
            deviceSettingTable.bandFormationConfig(recNum) = fftConfig.bandFormationConfig;
            deviceSettingTable.config(recNum)              = fftConfig.config;
            deviceSettingTable.interval(recNum)            = fftConfig.interval;
            deviceSettingTable.size(recNum)                = fftConfig.size;
            deviceSettingTable.sampleRate(recNum)          = sampleRate;
            deviceSettingTable.streamOffsetBins(recNum)    = fftConfig.streamOffsetBins;
            deviceSettingTable.streamSizeBins(recNum)      = fftConfig.streamSizeBins;
            deviceSettingTable.windowLoad(recNum)          = fftConfig.windowLoad;
            % end populate fft config 
            recNum = recNum + 1;
        end
    end
    % check if streaming started 
    if isfield(curStr,'StreamState')
        if curStr.StreamState.TimeDomainStreamEnabled
            if ~instream % if not instream then streaming is starting 
                timenum = curStr.RecordInfo.HostUnixTime;
                t = datetime(timenum/1000,'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
                actionuse = sprintf('stream start %d',strCnt);
                deviceSettingTable.timeStart{recNum} = t;
                deviceSettingTable.HostUnixTime(recNum) = timenum;
                deviceSettingTable.action{recNum} = actionuse;
                deviceSettingTable.recNum(recNum) = strCnt;
                
                
                % populate fft config
                deviceSettingTable.bandFormationConfig(recNum) = fftConfig.bandFormationConfig;
                deviceSettingTable.config(recNum)              = fftConfig.config;
                deviceSettingTable.interval(recNum)            = fftConfig.interval;
                deviceSettingTable.size(recNum)                = fftConfig.size;
                deviceSettingTable.sampleRate(recNum)          = sampleRate;
                deviceSettingTable.streamOffsetBins(recNum)    = fftConfig.streamOffsetBins;
                deviceSettingTable.streamSizeBins(recNum)      = fftConfig.streamSizeBins;
                deviceSettingTable.windowLoad(recNum)          = fftConfig.windowLoad;
                % end populate fft config
                
                strCnt = strCnt + 1;
                recNum = recNum + 1;
                instream = 1;
            end
        end 
    end
    % check if streaming stopped - 
    % it can either be stopped by turning streaming off 
    % or it can be stopped by turning sensing off 
    % option 1 - stream has been turned off 
    if isfield(curStr,'StreamState')
        if instream % streaming is happening detect it's stop
            if ~curStr.StreamState.TimeDomainStreamEnabled
                timenum = curStr.RecordInfo.HostUnixTime;
                t = datetime(timenum/1000,'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
                actionuse = sprintf('stop stream %d',strmStopCnt);
                deviceSettingTable.action{recNum} = actionuse;
                deviceSettingTable.recNum(recNum) = strmStopCnt;
                deviceSettingTable.timeStart{recNum} = t;
                deviceSettingTable.HostUnixTime(recNum) = timenum;
                
                
                % populate fft config
                deviceSettingTable.bandFormationConfig(recNum) = fftConfig.bandFormationConfig;
                deviceSettingTable.config(recNum)              = fftConfig.config;
                deviceSettingTable.interval(recNum)            = fftConfig.interval;
                deviceSettingTable.size(recNum)                = fftConfig.size;
                deviceSettingTable.sampleRate(recNum)          = sampleRate;
                deviceSettingTable.streamOffsetBins(recNum)    = fftConfig.streamOffsetBins;
                deviceSettingTable.streamSizeBins(recNum)      = fftConfig.streamSizeBins;
                deviceSettingTable.windowLoad(recNum)          = fftConfig.windowLoad;
                % end populate fft config
                
                instream = 0;
                strmStopCnt = strmStopCnt + 1;
                recNum = recNum + 1;
            end
        end
    end
    % option 2 sense has been turned off 
    if isfield(curStr,'SenseState')
        if instream % streaming is happening detect it's stop
            sensestat = dec2bin(curStr.SenseState.state,4);
            % blow is assuming we only care about time domain streaming
            % starting / stopping, see: 
            % enum
            % Medtronic.NeuroStim.Olympus.DataTypes.Sensing.SenseStates : byte 
            % for details re what the binary number means 
            if strcmp(sensestat(4),'0') % time domain off 
                timenum = curStr.RecordInfo.HostUnixTime;
                t = datetime(timenum/1000,'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
                actionuse = sprintf('stop sense %d',senseStopCnt);
                deviceSettingTable.action{recNum} = actionuse;
                % XXX this may be wrong 
                % if I use stop sense this is also wrong in some cases 
                % since stop sense is only used by randy at the end usually
                % 
                deviceSettingTable.recNum(recNum) = strmStopCnt; % I'm using the stream stop count but not incrementing it 
                deviceSettingTable.timeStart{recNum} = t;
                deviceSettingTable.HostUnixTime(recNum) = timenum;
                
                
                % populate fft config
                deviceSettingTable.bandFormationConfig(recNum) = fftConfig.bandFormationConfig;
                deviceSettingTable.config(recNum)              = fftConfig.config;
                deviceSettingTable.interval(recNum)            = fftConfig.interval;
                deviceSettingTable.size(recNum)                = fftConfig.size;
                deviceSettingTable.sampleRate(recNum)          = sampleRate;
                deviceSettingTable.streamOffsetBins(recNum)    = fftConfig.streamOffsetBins;
                deviceSettingTable.streamSizeBins(recNum)      = fftConfig.streamSizeBins;
                deviceSettingTable.windowLoad(recNum)          = fftConfig.windowLoad;
                % end populate fft config
                
                instream = 0;
                senseStopCnt = senseStopCnt + 1;
                recNum = recNum + 1;
            end
        end
    end
    f = f+1;
end

% loop on deviceSettigs and extract the start and stop time for each
% recording in the file.
deviceSettingsOut = table(); 
idxnotnan = ~isnan(deviceSettingTable.recNum);
unqRecs = unique(deviceSettingTable.recNum(idxnotnan)); 
for u = 1:length(unqRecs)
    idxuse = deviceSettingTable.recNum == unqRecs(u);
    dt = deviceSettingTable(idxuse,:);
    if size(dt,1) == 1 % this means that stream didn't stop properly
    else
        deviceSettingsOut.recNum(u) = unqRecs(u);
        deviceSettingsOut.timeStart(u) = dt.timeStart{1};
        deviceSettingsOut.timeStop(u) = dt.timeStart{2};
        deviceSettingsOut.duration(u) = deviceSettingsOut.timeStop(u) - deviceSettingsOut.timeStart(u);
        % populate fft config
        deviceSettingsOut.bandFormationConfig(u) = dt.bandFormationConfig(1);
        deviceSettingsOut.config(u)              = dt.config(1);
        deviceSettingsOut.interval(u)            = dt.interval(1);
        deviceSettingsOut.size(u)                = dt.size(1);
        deviceSettingsOut.sampleRate(u)                = dt.sampleRate(1);
        deviceSettingsOut.streamOffsetBins(u)    = dt.streamOffsetBins(1);
        deviceSettingsOut.streamSizeBins(u)      = dt.streamSizeBins(1);
        deviceSettingsOut.windowLoad(u)          = dt.windowLoad(1);
        % end populate fft config

    end
end

% compute the upper and lower bands
for s = 1:size(deviceSettingsOut,1)
    sampleRate = deviceSettingsOut.sampleRate(s); 
    switch deviceSettingsOut.size(s)
        case 0
            fftSize = 64;
        case 1
            fftSize = 256;
        case 3
            fftSize = 1024;
    end
  
    numBins = fftSize/2;
    binWidth = (sampleRate/2)/numBins;
    i = 0;
    bins = [];
    while i < numBins
        bins(i+1) = i*binWidth;
        i =  i + 1;
    end
    
    
    FFTSize = fftSize; % can be 64  256  1024
    sampleRate = sampleRate; % can be 250,500,1000
    
    numberOfBins = FFTSize/2;
    binWidth = sampleRate/2/numberOfBins;
    
    for i = 0:(numberOfBins-1)
        fftBins(i+1) = i*binWidth;
        %     fprintf('bins numbers %.2f\n',fftBins(i+1));
    end
    
    lower(1) = 0;
    for i = 2:length(fftBins)
        valInHz = fftBins(i)-fftBins(2)/2;
        lower(i) = valInHz;
    end
    
    for i = 1:length(fftBins)
        valInHz = fftBins(i)+fftBins(2)/2;
        upper(i) = valInHz;
    end
    fftInHz(1) = lower(deviceSettingsOut.streamOffsetBins(s)+1);
    fftInHz(2) = upper( (deviceSettingsOut.streamOffsetBins(s)+1) + (deviceSettingsOut.streamSizeBins(s)-1) );
    xvalsHz    = lower(deviceSettingsOut.streamOffsetBins(s)+1 :  ((deviceSettingsOut.streamOffsetBins(s)+1) + (deviceSettingsOut.streamSizeBins(s)-1) ));
    deviceSettingsOut.xValsInHz{s} = xvalsHz;
    
end
end

function outstruc = translateTimeDomainChannelsStruct(tdDat)
%% assume no bridging
outstruc = tdDat;
for f = 1:length(outstruc)
    % lpf 1 (front end)
    switch tdDat(f).lpf1
        case 9
            outstruc(f).lpf1 = '450Hz';
        case 18
            outstruc(f).lpf1 = '100Hz';
        case 36
            outstruc(f).lpf1 = '50Hz';
        otherwise
            outstruc(f).lpf1 = 'unexpected';
    end
    % lpf 1 (bacnk end amplifier)
    switch tdDat(f).lpf2
        case 9
            outstruc(f).lpf2 = '100Hz';
        case 11
            outstruc(f).lpf2 = '160Hz';
        case 12
            outstruc(f).lpf2 = '350Hz';
        case 14
            outstruc(f).lpf2 = '1700Hz';
        otherwise
            outstruc(f).lpf2 = 'unexpected';
    end
    % channels - minus input
    switch tdDat(f).minusInput
        case 0
            outstruc(f).minusInput = 'floating';
        case 1
            outstruc(f).minusInput = '0';
        case 2
            outstruc(f).minusInput = '1';
        case 4
            outstruc(f).minusInput = '2';
        case 8
            outstruc(f).minusInput = '3';
        case 16
            outstruc(f).minusInput = '4';
        case 32
            outstruc(f).minusInput = '5';
        case 64
            outstruc(f).minusInput = '6';
        case 128
            outstruc(f).minusInput = '7';
        otherwise
            outstruc(f).minusInput = 'unexpected';
    end
    if ~strcmp(outstruc(f).minusInput,'floating') & ~strcmp(outstruc(f).minusInput,'unexpected')
        if f > 2 % asssumes there is no bridging 
            outstruc(f).minusInput = num2str( str2num(outstruc(f).minusInput)+8);
        end
    end
    % channels - plus input
      switch tdDat(f).plusInput
        case 0
            outstruc(f).plusInput = 'floating';
        case 1
            outstruc(f).plusInput = '0';
        case 2
            outstruc(f).plusInput = '1';
        case 4
            outstruc(f).plusInput = '2';
        case 8
            outstruc(f).plusInput = '3';
        case 16
            outstruc(f).plusInput = '4';
        case 32
            outstruc(f).plusInput = '5';
        case 64
            outstruc(f).plusInput = '6';
        case 128
            outstruc(f).plusInput = '7';
        otherwise
            outstruc(f).plusInput = 'unexpected';
      end
      if ~strcmp(outstruc(f).plusInput,'floating') & ~strcmp(outstruc(f).plusInput,'unexpected')
          if f > 2 % asssumes there is no bridging
              outstruc(f).plusInput = num2str( str2num(outstruc(f).plusInput)+8);
          end
      end
    % sample rate 
    switch tdDat(f).sampleRate
        case 0
            outstruc(f).sampleRate = '250Hz';
        case 1
            outstruc(f).sampleRate = '500Hz';
        case 2 
            outstruc(f).sampleRate = '1000Hz';
        case 240
            outstruc(f).sampleRate = 'disabled';     
        otherwise
            outstruc(f).plusInput = 'unexpected';
    end
    outstruc(f).chanOut = sprintf('+%s-%s',...
        outstruc(f).plusInput,outstruc(f).minusInput);
    outstruc(f).chanFullStr = sprintf('%s lpf1-%s lpf2-%s sr-%s',...
        outstruc(f).chanOut,...
        outstruc(f).lpf1,outstruc(f).lpf2,outstruc(f).sampleRate);
end
end