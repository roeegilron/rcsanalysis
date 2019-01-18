function eventTable = createDummyEventTable(outRec,sessionid )
timenum = str2num(sessionid);
t = datetime(timenum/1000,'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
outTab(1).sessionTime = t;
outTab(1).sessionid = {sessionid}; 
outTab(1).EventSubType = '1';
outTab(1).EventType = 'Sent';
outTab(1).UnixOnsetTime = outRec(1).timeStart;
outTab(1).UnixOffsetTime =  outRec(1).timeEnd;


eventTable = struct2table(outTab);

end