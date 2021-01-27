function MAIN_read_and_save_log_file_data()

%% load the database 

% set destination folders
dropboxFolder = findFilesBVQX('/Users','Starr Lab Dropbox',struct('dirs',1,'depth',2));
if length(dropboxFolder) == 1
    dirname  = fullfile(dropboxFolder{1}, 'RC+S Patient Un-Synced Data');
    rootdir = fullfile(dirname,'database');
else
    error('can not find dropbox folder, you may be on a pc');
end

reportdir = fullfile(rootdir,'reports');
figdir = fullfile(rootdir,'figures_per_patient-time-recorded');
if ~exist(reportdir,'dir')
    mkdir(reportdir);
end
if ~exist(figdir,'dir')
    mkdir(figdir);
end



load(fullfile(rootdir,'database_from_device_settings.mat'),'masterTableLightOut');
masterTableOut = masterTableLightOut;

%% only get data from RCS patients and newer than december 2020 
newerThan = datetime('01-Dec-2020 00:00:00','Format','dd-MMM-uuuu HH:mm:ss','TimeZone','America/Los_Angeles');
idxkeep = cellfun(@(x) any(strfind(x,'RCS')),masterTableOut.patient) & ... 
          masterTableOut.timeStart > newerThan;
masterTable = masterTableOut(idxkeep,:);

%% loop on data, and look for folders with log data 
for s = 1:size(masterTable,1)
    [pn,~] = fileparts(masterTable.deviceSettingsFn{s});
    logDirFound = findFilesBVQX(pn,'LogData*',struct('dirs',1));
    if ~isempty(logDirFound)
        start = tic; 
        logDir = logDirFound{1}; 
        logtime = masterTable.timeStart(s);
        logtime.Format = 'dd-MMM-uuuu--HH-mm';
        
        fnuse = sprintf('%s%s_%s.mat',masterTable.patient{s},masterTable.side{s}, logtime);
        fnsave = fullfile(logDir,fnuse);
        
        if ~exist(fnsave,'file')
            
            % two options - if you have a Log file - that is old version so
            % everything together, else you have it seperated into event and
            % app logs
            LogFn = findFilesBVQX(logDir,'*LOG.txt');
            % verfiy that you only have one file, and if you have more that
            % it's not a mirror, log or event file 
            excludeFile = 0;
            for ll = 1:length(LogFn)
                [pnn,fnn] = fileparts(LogFn{ll});
                if any(strfind(fnn,'MirrorLog'))
                    excludeFile = 1;
                end
                if any(strfind(fnn,'AppLog'))
                    excludeFile = 1;
                end
                if any(strfind(fnn,'EventLog'))
                    excludeFile = 1;
                end
            end
            if ~isempty(LogFn) & ~excludeFile
                [adaptiveLogTable, rechargeSessions, groupChanges] = read_adaptive_txt_log(LogFn{1});
            end
            
            % look for event log
            eventLogFn = findFilesBVQX(logDir,'*EventLog.txt');
            % if event log exsits, it will only have recharge session and group
            % chnages, get the adaptive stuff from the app log
            if ~isempty(eventLogFn)
                [~, rechargeSessions, groupChanges] = read_adaptive_txt_log(eventLogFn{1});
            end
            
            % look for - app log
            % if app WITH event log exsits, it will only have recharge session and group
            % chnages, get the adaptive stuff from the app log
            appLogFn = findFilesBVQX(logDir,'*AppLog.txt');
            if ~isempty(appLogFn)
                [adaptiveLogTable, ~, ~] = read_adaptive_txt_log(appLogFn{1});
            end
            
            if exist('adaptiveLogTable','var') 
                if ~isempty(adaptiveLogTable)
                    if exist(fnsave,'file')
                        save(fnsave,'adaptiveLogTable','-append')
                    else
                        save(fnsave,'adaptiveLogTable')
                    end
                end
            end
            
            if exist('rechargeSessions','var')
                if ~isempty(rechargeSessions)
                    if exist(fnsave,'file')
                        save(fnsave,'rechargeSessions','-append')
                    else
                        save(fnsave,'rechargeSessions')
                    end
                end
            end
            
            if exist('groupChanges','var')
                if ~isempty(groupChanges)
                    if exist(fnsave,'file')
                        save(fnsave,'groupChanges','-append')
                    else
                        save(fnsave,'groupChanges')
                    end
                end
            end
            
            clear adaptiveLogTable  rechargeSessions groupChanges
            fprintf('file %d/%d: \t%s\t done in %.2f\n',s,size(masterTable,1),fnuse,toc(start));
        end
    end
end
%%



end