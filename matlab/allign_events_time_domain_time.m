function eventTable = allign_events_time_domain_time(eventTable,timeDomain)
% this functions takes an event table that has events in computer time and
% returns derived times in INS time 

%  Each data structure has a PC clock-driven time when the packet was received via Bluetooth, 
% as accurate as a C# DateTime.now (10-20ms).   

% in the eventTable structure this is UnixOnsetTime
% in the timedomain strucutre this is PacketRxUnixTime

% the goal of the code is to find the smallest different between
% UnixOnsetTime and PacketRxUnixTime abd get the INS time domain value for
% this sample. 
idxnonzero = find(timeDomain.PacketRxUnixTime~=0); 
packtRxTimes    =  datetime(timeDomain.PacketRxUnixTime(idxnonzero)/1000,...
    'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
% note that we only get one time sample for each time domain packet. 
% this finds the closest time sample in "packet time". 
derivesTimesWithInsTime = timeDomain.derivedTimes(idxnonzero); 

timeDiffInTimeDomain = [packtRxTimes  derivesTimesWithInsTime];

for e = 1:size(eventTable)
    [timeDiff, idx] = min(abs(eventTable.UnixOffsetTime(e) - packtRxTimes));
    timeDiffVec(e) = timeDiff; 
    timeDiffUse = packtRxTimes(idx) - eventTable.UnixOffsetTime(e) ;
    insTimeUncorrected = derivesTimesWithInsTime(idx);
    insTimes(e)       = insTimeUncorrected - timeDiffUse;
end

eventTable.timeDiffVector = timeDiffVec'; 
eventTable.insTimes = insTimes';
end