function timesOut = getTimesFromPowerOrAdaptive(timestamps,systemTicks,rxUnixTimes)

idxpackets = find(timestamps~=0); 
timestamps = datetime(datevec(timestamps(idxpackets)./86400 + datenum(2000,3,1,0,0,0))); % medtronic time - LSB is seconds 


endTimes  = NaT(size(timestamps,1), 1) - NaT(1);
endTimes.Format = 'hh:mm:ss.SSS'; % add microseconds 
% 1 figure out different isis 
% isis = 1./srates;

% 1.5 start with gaps that are smaller than 6.553 seconds 
% if gap is smaller than 6.55 seconds verify packet time with systemTick clock
% and increment from last end time
idxsmaller = [0 ; diff(timestamps) <= seconds(2^16/1e4)]; % add zero at start since using diff
% find out what value to give based on
% packet count
idxInNums = find(idxsmaller==1);
preIdxInNums = idxInNums-1;
difftime = systemTicks(idxpackets(idxInNums))-systemTicks(idxpackets(preIdxInNums));
packtime = mod(difftime,2^16) / 1e4 ;% packet time in seconds
secondsToAdd = seconds(packtime ) ;
endTimes(idxInNums) = secondsToAdd;   
 
% 2. find gaps larger than 6.553 seconds and populate- this has to come
% after all the easy stuff 
idxlarger = [0 ; diff(timestamps) > seconds(2^16/1e4)];
% find out what value to give based on
% packet count
idxInNums = find(idxlarger==1); 
preIdxInNums = idxInNums-1; 
gapLenInSeconds = timestamps(idxInNums)-timestamps(preIdxInNums);
numberOfSixSecChunks = seconds(gapLenInSeconds)/(2^16/1e4);
systemTickPreviousPacket = systemTicks(idxpackets(preIdxInNums));
systemTickCurrentPacket = systemTicks(idxpackets(idxInNums));
exactGapTime = seconds(floor(numberOfSixSecChunks)*floor(2^16/1e4) - ...
    systemTickPreviousPacket/1e4 + ...
    systemTickCurrentPacket/1e4);
endTimes(idxInNums) = exactGapTime;

% get rid of the first packet;  
endTimes = endTimes(2:end); 
% set starting point based on computer time 
firstTimeIdx = find(rxUnixTimes~=0,1);
timeOfLastSampleInFirstPacket = datetime(rxUnixTimes(firstTimeIdx)/1000,...
    'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
startTime = timeOfLastSampleInFirstPacket - endTimes(1); 
timesOut = startTime + cumsum(endTimes); 
end
