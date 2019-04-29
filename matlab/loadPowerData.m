function powerTable  = loadPowerData(fn)
powerLog = jsondecode(fixMalformedJson(fileread(fn),'EventLog'));
[pn,fnm,ext ] = fileparts(fn);
if isempty(powerLog) | isempty(powerLog.PowerDomainData)
    fprintf('power data  is empty\n');
    fprintf('creating dummy event table\n');
    powerTable  = [];
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
end

