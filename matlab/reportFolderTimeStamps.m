function reportFolderTimeStamps()
%% this function converts folder time stamps to human readable
%% and report this to screen

dirname = uigetdir();
fdirs = findFilesBVQX(dirname,'Sess*',struct('depth',1,'dirs',1));
% report fast 
fid = fopen(fullfile(dirname,'folderTimes.txt'),'w+'); 
for f = 1:size(fdirs,1)
    [pn,fn,ext] = fileparts(fdirs{f});
    rawTime = str2num(strrep(lower(fn),'session',''));
    t = datetime(rawTime/1000,'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
    fprintf(fid,'%s %s\n',t,fn);
end
fclose(fid)
return; 
for f = 1:size(fdirs,1)
    [pn,fn,ext] = fileparts(fdirs{f});
    rawTime = str2num(strrep(fn,'Session',''));
    t = datetime(rawTime/1000,'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
    foldDirr = fullfile(pn,fn);
    ftdf = findFilesBVQX(foldDirr,'RawDataTD.json');
    data = deserializeJSON(ftdf{1});
    if ~isempty(data)
        fldnms = fieldnames(data);
        if ~isempty(fldnms)
            if ~isempty(data.TimeDomainData)
                starTime = data.TimeDomainData(1).Header.timestamp.seconds;
                endTime = data.TimeDomainData(end).Header.timestamp.seconds;
                
                startTimeDt = datetime(datevec(starTime./86400 + datenum(2000,3,1,0,0,0))); % medtronic time - LSB is seconds
                endTimeDt = datetime(datevec(endTime./86400 + datenum(2000,3,1,0,0,0))); % medtronic time - LSB is seconds
                fprintf('file length is %s\n',endTimeDt- startTimeDt);
                dur = endTimeDt- startTimeDt;
            else
                dur = duration([0 0 0]);
            end
        else
            dur = duration([0 0 0]);
        end
    else
        dur = duration([0 0 0]);
    end
    tout(f).time = t;
    tout(f).fn = fn;
    tout(f).pn = pn;
    tout(f).duration = endTimeDt- startTimeDt;
    
end
foldDat = struct2table(tout);
%% plot coverage by day 
hfig = figure; 
hax = subplot(1,1,1); 
hold on; 
daysRec =   day(foldDat.time);
unqday = unique(  daysRec ); 
[yy,mm,dd] = ymd(foldDat.time(1));
for d = 1:length(unqday) 
    idxday = find(daysRec == unqday(d));
    [h,m,s] = hms(foldDat.time(idxday));
    startTimes = datetime(repmat(yy,size(h,1),1), ...
                          repmat(mm,size(h,1),1), ...
                          repmat(dd,size(h,1),1), ...
                          h,m,s);
    endTimes = startTimes + foldDat.duration(idxday);
    plot([startTimes endTimes],[d d],...
        'LineWidth',10,...
        'Color',[0.8 0 0 0.7]);
    ylabels{d} = sprintf('Nov %d',unqday(d));
        
end
ylim([0 length(unqday)+1]);

hax.YTickLabel = [{' '} ;ylabels';  {' '}];
datetick('x','HH:MM');
set(gca,'XLim',...
    [datetime('03-Nov-2018 00:00:12.995') ...
     datetime('04-Nov-2018 00:01:22.949')]);

 
title('Continous Chronic Recording at Home');
figdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v06-home-visit-3-week/figures';
figname = 'continous recording.fig';
savefig(hfig,fullfile(figdir,figname)); 

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