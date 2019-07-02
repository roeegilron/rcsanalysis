function [outtable, srates] = unravelDataACC(TDdat)
%% Function to unravel TimeDomainData
% input: a structure time domain data that is read from TimeDomainRaw.json 
% file that is spit out by RC+S Summit interface. 
% To transform *.json file into structure use deserializeJSON.m 
% in this folder 
%% unravel data 



%% deduce sampling rate 
srates = getSampleRateAcc([TDdat.AccelData.SampleRate]');

%% pre allocate memory 
% find out how many channels of data you have 
nchan = 3; % you always get 3 channels 
% find out how many rows you need to allocate 
tmp = [TDdat.AccelData.Header];
datasizes = [tmp.dataSize]';
% xxxxxxxxx
packetsizes = (datasizes/8); % divide by 8 for now, this may need to be fixed 
% xxxxxxxxx
nrows = sum(packetsizes);
outdat = zeros(nrows, nchan+2); % pre allocate memory 

%% loop on pacets to create out data with INS time and system tick 
% loop on packets and populate packets fields 
start = tic; 
curidx = 0; 
for p = 1:size(datasizes,1)
    rowidx = curidx+1:1:(packetsizes(p)+curidx);
    curidx = curidx + packetsizes(p); 
    packetidx = curidx;  % the time is always associated with the last sample in the packet 
    outdat(rowidx,1) = TDdat.AccelData(p).XSamples;
    varnames{1} = 'XSamples';
    outdat(rowidx,2) = TDdat.AccelData(p).YSamples;
    varnames{2} = 'YSamples';
    outdat(rowidx,3) = TDdat.AccelData(p).ZSamples;
    varnames{3} = 'ZSamples';
    outdat(packetidx,nchan+1) = TDdat.AccelData(p).Header.systemTick; 
    varnames{nchan+1} = 'systemTick'; 
    outdat(packetidx,nchan+2) = TDdat.AccelData(p).Header.timestamp.seconds; 
    varnames{nchan+2} = 'timestamp'; 
    outdat(packetidx,nchan+3) = TDdat.AccelData(p).PacketGenTime;
    varnames{nchan+3} = 'PacketGenTime'; 
    outdat(packetidx,nchan+4) = TDdat.AccelData(p).PacketRxUnixTime;
    varnames{nchan+4} = 'PacketRxUnixTime'; 
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

end
