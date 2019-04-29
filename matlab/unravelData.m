function [outtable, srates] = unravelData(TDdat)
%% Function to unravel TimeDomainData
% input: a structure time domain data that is read from TimeDomainRaw.json 
% file that is spit out by RC+S Summit interface. 
% To transform *.json file into structure use deserializeJSON.m 
% in this folder 
%% unravel data 



%% deduce sampling rate 
srates = getSampleRate([TDdat.TimeDomainData.SampleRate]');

%% pre allocate memory 
% find out how many channels of data you have 
nchan = size(TDdat.TimeDomainData(1).ChannelSamples,2);
% find out how many rows you need to allocate , you may not 
% have consistent nubmer of channels through the recording 
% get the number of channels for each packet 
tdtmp = TDdat.TimeDomainData;
for p = 1:size(tdtmp,2)
    nchans(p,1) = size(tdtmp(p).ChannelSamples,2);
end
maxnchans = max(nchans);
tmp = [TDdat.TimeDomainData.Header];
datasizes = [tmp.dataSize]';
packetsizes = (datasizes./nchans)./2; % divide by 2 bcs data Size is number of bits in packet. 
nrows = sum(packetsizes);
outdat = zeros(nrows, max(nchans)+3); % pre allocate memory 

%% loop on pacets to create out data with INS time and system tick 
% loop on packets and populate packets fields 
start = tic; 
curidx = 0; 
%% to simplify things, always have 4 channels, even if only 2 active 
maxnchans = 4;
varnames = {'key0','key1','key2','key3'}; 
for p = 1:size(datasizes,1)
    rowidx = curidx+1:1:(packetsizes(p)+curidx);
    curidx = curidx + packetsizes(p); 
    packetidx = curidx;  % the time is always associated with the last sample in the packet 
    samples = TDdat.TimeDomainData(p).ChannelSamples;
    nchan =  nchans(p,1);
    for c = 1:size(samples,2)
        idxuse = samples(c).Key+1;% bcs keys (channels) are zero indexed 
        outdat(rowidx,idxuse) = samples(c).Value;
    end
    outdat(packetidx,maxnchans+1) = TDdat.TimeDomainData(p).Header.systemTick; 
    varnames{maxnchans+1} = 'systemTick'; 
    outdat(packetidx,maxnchans+2) = TDdat.TimeDomainData(p).Header.timestamp.seconds; 
    varnames{maxnchans+2} = 'timestamp'; 
    outdat(packetidx,maxnchans+3) = srates(p); 
    varnames{maxnchans+3} = 'samplerate'; 
    
    
    outdat(packetidx,maxnchans+4) = TDdat.TimeDomainData(p).PacketGenTime;
    varnames{maxnchans+4} = 'PacketGenTime'; 
    
    outdat(packetidx,maxnchans+5) =  TDdat.TimeDomainData(p).PacketRxUnixTime; 
    varnames{maxnchans+5} = 'PacketRxUnixTime'; 
end


%%
fprintf('finished unpacking into matrix in %.2f seconds\n',toc(start));
outtable = array2table(outdat);
clear outdat; 
outtable.Properties.VariableNames = varnames; 
outtable.Properties.VariableDescriptions{nchan+1} = ...
    'systemTick ? INS clock-driven tick counter, 16bits, LSB is 100microseconds, (highly accurate, high resolution, rolls over)';
outtable.Properties.VariableDescriptions{nchan+2} = ...
    'timestamp ? INS clock-driven time, LSB is seconds (highly accurate, low resolution, does not roll over)';

outtable.Properties.VariableDescriptions{nchan+3} = ...
    'sample rate for each packet, used in cases in which the sample rate is not conssistent through out session';

outtable.Properties.VariableDescriptions{nchan+4} = ...
    'API estimate of when the data packet was created on the INS within the PC clock domain. Estimate created by using results of latest latency check (one is done at system initialization, but can re-perform whenever you want) and time sync streaming. Potentially useful for syncing with other sensors or devices by bringing things into the PC clock domain, but is only accurate within 50ms give or take.';

outtable.Properties.VariableDescriptions{nchan+5} = ...
    'PC clock-driven time when the packet was received via Bluetooth, as accurate as a C# DateTime.now (10-20ms)';


end
