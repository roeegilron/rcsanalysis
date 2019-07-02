function [powerTable, pbOut]  = loadPowerData(fn)
powerLog = jsondecode(fixMalformedJson(fileread(fn),'EventLog'));
powerTable = table();
pbOut = struct();
[pn,fnm,ext ] = fileparts(fn);
if isempty(powerLog) | isempty(powerLog.PowerDomainData)
    fprintf('power data  is empty\n');
    fprintf('creating dummy event table\n');
    powerTable  = [];
    powerBandInHz = [];
else
    % struct fields
    % header - this is all timing data
    Header = [powerLog.PowerDomainData.Header];
    fnms = {'dataSize','dataType','dataTypeSequence',...
        'globalSequence','info','systemTick'};
    timing = struct();
    for f = 1:length(fnms)
        timing.(fnms{f}) = [Header.(fnms{f})]';
    end
    timestamps = [Header.timestamp];
    timing.timestamp =  struct2array(timestamps)';
    
    % power data (with out bands)
    powerDat = [powerLog.PowerDomainData];
    fnms = {'PacketGenTime','PacketRxUnixTime',...
        'ExternalValuesMask','FftSize','IsPowerChannelOverrange','SampleRate','ValidDataMask'};
    powTempStruc = struct();
    for f = 1:length(fnms)
        powTempStruc.(fnms{f}) = [powerDat.(fnms{f})]';
    end
    % power bands
    bands = [powerDat.Bands]';
    for b = 1:size(bands,2)
        bndfnm = sprintf('Band%d',b);
        powTempStruc.(bndfnm) = bands(:,b);
    end
    
    timeTab = struct2table(timing);
    powrTab = struct2table(powTempStruc);
    powerTable = [powrTab, timeTab];
    % load device settings file as well to find out power bins in Hz
    % this depends on running
    % loadDeviceSettings.m
    % and also depeends on having
    % DeviceSettings.json in the same folder
    % as the power data
    [rootdir,filename] = fileparts(fn);
    load(fullfile(rootdir,'DeviceSettings.mat'));
    pbOut = struct();
    for oo = 1:size(outRec,2)
            sampleRate = str2double(strrep( outRec(oo).tdData(1).sampleRate,'Hz',''));
            switch outRec(oo).fftConfig.size
                case 0
                    fftSize = 64;
                case 1
                    fftSize = 256;
                case 3
                    fftSize = 1024;
            end
            powerChannelsIdxs = [];
            idxCnt = 1;
            for c = 1:4
                for b = 0:1
                    fieldStart = sprintf('band%dStart',b);
                    fieldStop = sprintf('band%dStop',b);
                    powerChannelsIdxs(idxCnt,1) = outRec(oo).powerChannels(c).(fieldStart);
                    powerChannelsIdxs(idxCnt,2) = outRec(oo).powerChannels(c).(fieldStop);
                    idxCnt = idxCnt+1;
                end
            end
        
        % power data
        % notes to compute bins
        numBins = fftSize/2;
        binWidth = (sampleRate/2)/numBins;
        i = 0;
        bins = [];
        while i < numBins
            bins(i+1) = i*binWidth;
            i =  i + 1;
        end
        
        powerChannelsIdxs = powerChannelsIdxs + 1; % since Matlab is 0 indexed and C# is 1 indexed.
        powerBandInHz = {};
        for pc = 1:size(powerChannelsIdxs,1)
            powerBandInHz{pc,1} = sprintf('%.2fHz-%.2fHz',...
                bins(powerChannelsIdxs(pc,1)),bins(powerChannelsIdxs(pc,2)));
        end
        pbOut(oo).powerBandInHz = powerBandInHz; 
        pbOut(oo).powerChannelsIdxs = powerChannelsIdxs;
        pbOut(oo).fftSize = fftSize;
        pbOut(oo).bins = bins;
        pbOut(oo).numBins = numBins;
        pbOut(oo).binWidth = binWidth;
        pbOut(oo).sampleRate = sampleRate;
    end
end



