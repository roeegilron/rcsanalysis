%% only run once
fn = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v02-surgery/Session1539380967366/DeviceNPC700395H/RawDataTD.json';
TDdat = deserializeJSON(fn);


%% pre allocate memory 
% find out how many channels of data you have 
nchan = size(TDdat.TimeDomainData(1).ChannelSamples,2);
% find out how many rows you need to allocate 
tmp = [TDdat.TimeDomainData.Header];
datasizes = [tmp.dataSize]';
packetsizes = (datasizes./nchan)./2; % divide by 2 bcs data Size is number of bits in packet. 
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
    samples = TDdat.TimeDomainData(p).ChannelSamples;
    for c = 1:nchan
        outdat(rowidx,c) = samples(c).Value;
        if p == 1 % only need to get var names once 
            varnames{c} = sprintf('key%d',samples(c).Key);
        end
    end
    outdat(packetidx,nchan+1) = TDdat.TimeDomainData(p).Header.systemTick; 
    varnames{nchan+1} = 'systemTick'; 
    outdat(packetidx,nchan+2) = TDdat.TimeDomainData(p).Header.timestamp.seconds; 
    varnames{nchan+2} = 'timestamp'; 
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

%% plot spectral plot 



