function tblout = getDataBaseRCSdata(dirname)
% this function created a database of rcs data

% rows
% rec time
% path to filename
% rawTDdata .mat exist
% plot (boolean)

% depends on:
% turtle json

% add path
ptadd = genpath(fullfile(pwd,'toolboxes','turtle_json'));
addpath(ptadd);

dirsdata = findFilesBVQX(dirname,'Sess*',struct('dirs',1,'depth',1));


% find out if a database file was already created in this folder
% if so, just an update is needed no need to recrate the whole
% database
databasefn = fullfile(dirname,'database.mat');
olddb =[]; % default is that the database does not exist
if exist(databasefn,'file')
    load(databasefn);
    if ismember('patient',tblout.Properties.VariableNames) % make sure this data base adheres to new relative directory standards
        olddb = tblout;
        clear tblout;
        % get all session names
        for s = 1:size(dirsdata)
            [~,sessname] = fileparts(dirsdata{s});
            sessionsexist(s,1) = sum(cellfun(@(x) strcmp(x,sessname),olddb.sessname));
        end
        dirsdata = dirsdata(~sessionsexist);
    end
end

% extract times and .mat status
dbout = [];
cntsave = 1;
for d = 1:length(dirsdata)
    diruse = findFilesBVQX(dirsdata{d},'Device*',struct('dirs',1,'depth',1));
    
    if isempty(diruse) % no data exists inside
    else % data may exist, check for time domain ndata
        tdfile = findFilesBVQX(dirsdata{d},'RawDataTD.json');
        if isempty(tdfile) % time data file doesn't exist
        else
            timeReport = report_start_end_time_td_file_rcs(tdfile{1});
            if ~isempty(timeReport.duration)
                [pn,fn] = fileparts(dirsdata{d});
                [~,patientRaw] = fileparts(pn);
                dbout(cntsave).rectime = getTime(fn);
                dbout(cntsave).sessname = fn;
                
                [tdpath,deviceName] = fileparts(tdfile{1});
                [~,deviceName] = fileparts(tdpath);
                dbout(cntsave).device = deviceName;
                dbout(cntsave).patient = patientRaw(1:end-1);
                dbout(cntsave).side = patientRaw(end);
                
                [~,tdfilename ] = fileparts(tdfile{1});
                dbout(cntsave).tdfile = tdfilename;
                % timeReport = reportime(tdfile{1}); % XXX
                timeReport = report_start_end_time_td_file_rcs(tdfile{1});
                dbout(cntsave).startTime = timeReport.startTime;
                dbout(cntsave).endTime = timeReport.endTime;
                dbout(cntsave).duration = timeReport.duration;
                
                % load event file
                try
                    evFile = findFilesBVQX(dirsdata{d},'EventLog.json');
                    [~,evfilename ] = fileparts(evFile{1});
                    dbout(cntsave).eventFile = evfilename;
                    eventData = loadEventLog(evFile{1});
                    dbout(cntsave).eventData = eventData;
                catch
                end
                
                
                % does mat file exist?
                matfile = findFilesBVQX(dirsdata{d},'*TD*.mat');
                if isempty(matfile) % no matlab data loaded
                    dbout(cntsave).matExist = false;
                    dbout(cntsave).fnm = [];
                else
                    dbout(cntsave).matExist = true;
                end
                dbout(cntsave).plot = false;
                cntsave = cntsave + 1;
            end
        end
    end
end
if ~isempty(dbout)
    newdb = struct2table(dbout,'AsArray',true);
else
    newdb =[]; % the new database is empty - e.g. no new files to add 
end

clear tblout;
if istable(olddb) % an old table existed
    if isempty(newdb) % no new data to add
        tblout = olddb;
    else
        tblout = [newdb; olddb];
    end
else
    tblout = newdb;
end
tblout_sort_cols = tblout(:,{'rectime','duration','patient','side','device','startTime',...
    'endTime','sessname','tdfile','eventFile','eventData','matExist','fnm','plot'});
% get rid of files with no duration
tblout = sortrows(tblout_sort_cols,'rectime');


% reogranize the tblout table  and sort on time
% clean up
rmpath(ptadd);
end

function t = getTime(fn)
%%
tmpcl = regexp(fn,'[0-9]+','match');
timenum = str2num(tmpcl{1});
t = datetime(timenum/1000,'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
%%
end



