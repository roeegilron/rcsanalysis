function findAndSaveTimeDiffBetweenUnixAndInsTimes(dirname)
% firt resave all the event log evetns
ff = findFilesBVQX(dirname,'RawDataTD.mat');
for f = 1:length(ff)
    try
        load(ff{f});
        [pn,fn,ext] = fileparts(ff{f});
        idxTimeCompare = find(outdatcomplete.PacketRxUnixTime~=0,1);
        packRxTimeRaw  = outdatcomplete.PacketRxUnixTime(idxTimeCompare);
        packtRxTime    =  datetime(packRxTimeRaw/1000,...
            'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
        derivedTime    = outdatcomplete.derivedTimes(idxTimeCompare);
        timeDiff       = derivedTime - packtRxTime;
        save(fullfile(pn,[fn '.mat']),'timeDiff','-append');
        fprintf('time diff is %s \t finished reloading event %d/%d\n',timeDiff,f,length(ff));
    catch
        fprintf('failed loading file in event %d/%d\n',f,length(ff));
    end
    
end