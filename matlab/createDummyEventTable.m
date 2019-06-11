function eventTable = createDummyEventTable(outRec,sessionid )
timenum = str2num(sessionid);
t = datetime(timenum/1000,'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
outTab(1).sessionTime = t;
outTab(1).sessionid = {sessionid}; 
outTab(1).EventSubType = '1';
outTab(1).EventType = 'Sent';
if isempty(outRec)
     outTab(1).UnixOnsetTime = t;
     outTab(1).UnixOffsetTime =  t;
else
    outTab(1).UnixOnsetTime = outRec(1).timeStart;
    outTab(1).UnixOffsetTime =  outRec(1).timeStart;
end

eventTable = struct2table(outTab);

end