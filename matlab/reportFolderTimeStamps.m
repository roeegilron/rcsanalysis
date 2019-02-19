function reportFolderTimeStamps()
%% this function converts folder time stamps to human readable
%% and report this to screen 
dirname = uigetdir(); 
fdirs = findFilesBVQX(dirname,'Sess*',struct('depth',1,'dirs',1));
for f = 1:size(fdirs,1)
    [pn,fn,ext] = fileparts(fdirs{f}); 
    rawTime = str2num(strrep(fn,'Session','')); 
    t = datetime(rawTime/1000,'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
    tout(f).time = t; 
    tout(f).fn = fn; 
    tout(f).pn = pn; 
end
foldDat = struct2table(tout); 
foldDat
return; 
%%
fn = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v13_programming_session4/rcs_data/Session1549329326222/DeviceNPC700395H/EventLog.json';
el = json.load(fn);
for i = 1:length(el)
    eout(i) = el{i}.Event
end
eTab = struct2table(efout); 
idx = cellfun(@(x) strcmp(x,'TdPacketReceived'),eTab.EventType) | ... 
      cellfun(@(x) strcmp(x,'BatteryLevel'),eTab.EventType); 
eTabNoTd = eTab(~idx,:); 