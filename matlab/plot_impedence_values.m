function plot_impedence_values()
%% this function moves folders from synced dropbox folders to unsynced folders
clc;
% set destination folders
rootdir_orig = '/Users/roee/Starr Lab Dropbox/';
rootdir_dest = fullfile(rootdir_orig,'RC+S Patient Un-Synced Data');
dirout = fullfile(rootdir_orig,'RC+S Patient Un-Synced Data','database','impedences');
%% loop on the unsycned data folder 
patdir = findFilesBVQX(rootdir_dest,'RCS*Un-Synced Data',struct('dirs',1,'depth',1));
recordingPrograms = {'StarrLab','SummitContinuousBilateralStreaming'};
impdenceTables = struct(); 
cnttbl = 1;
for p = 2:length(patdir) % loop on patients, skip patient 1 that doesn't have anything 
    for rp = 1%:length(recordingPrograms) % patient facing programs doesn't do impedence for now, but getting ready in case this changes
        dirsearch = fullfile(patdir{p},'SummitData',recordingPrograms{rp});
        if isdir(dirsearch)
            patSides = findFilesBVQX(dirsearch,'RCS*',struct('dirs',1,'depth',1));
            for s = 1:length(patSides)
                side = patSides{s}(end);
                [pn,fn] = fileparts(patSides{s});
                patient = fn(1:end-1);
                % find event jsons
                eventFiles = findFilesBVQX(patSides{s},'EventLog.json');
                for e = 1:length(eventFiles)
                    text = fileread(eventFiles{e});
                    if ~isempty(text)
                        if any(strfind(text,'Lead Integrity'))
                            events =loadEventLog(eventFiles{e});
                            idxleadtest = strcmp(events.EventType,'Lead Integrity');
                            leadIntegrityTable = events(idxleadtest,:);
                            impdenceTables(cnttbl).patient  = patient;
                            impdenceTables(cnttbl).side  = side;
                            impdenceTables(cnttbl).impedenceTable= leadIntegrityTable;
                            cnttbl = cnttbl + 1;
                            
                        end
                    end
                end
            end
        end
    end
end

%% loop on the data folders still on patients computers 
patdirs = {'RCS01 LTE','RC02LTE','RCS03','RCS04','RCS05','RCS06','RCS07','RCS08','RCS09'};
recordingPrograms = {'StarrLab','SummitContinuousBilateralStreaming'};
for p = 2:length(patdirs) % loop on patients, skip patient 1 that doesn't have anything 
    for rp = 1%:length(recordingPrograms) % patient facing programs doesn't do impedence for now, but getting ready in case this changes
        dirsearch = fullfile(rootdir_orig,patdirs{p},'SummitData',recordingPrograms{rp});
        if isdir(dirsearch)
            patSides = findFilesBVQX(dirsearch,'RCS*',struct('dirs',1,'depth',1));
            for s = 1:length(patSides)
                side = patSides{s}(end);
                [pn,fn] = fileparts(patSides{s});
                patient = fn(1:end-1);
                % find event jsons
                eventFiles = findFilesBVQX(patSides{s},'EventLog.json');
                for e = 1:length(eventFiles)
                    text = fileread(eventFiles{e});
                    if ~isempty(text)
                        if any(strfind(text,'Lead Integrity'))
                            events =loadEventLog(eventFiles{e});
                            idxleadtest = strcmp(events.EventType,'Lead Integrity');
                            leadIntegrityTable = events(idxleadtest,:);
                            impdenceTables(cnttbl).patient  = patient;
                            impdenceTables(cnttbl).side  = side;
                            impdenceTables(cnttbl).impedenceTable= leadIntegrityTable;
                            cnttbl = cnttbl + 1;
                            
                        end
                    end
                end
            end
        end
    end
end


%% write impedence tables to files 
impdenceTable = struct2table(impdenceTables);

for i = 1:size(impdenceTable,1)
    tblwrite = impdenceTable.impedenceTable{i};
    timeuse = tblwrite.sessionTime(1);
    timeuse.Format = 'yyyy-MM-dd HH_mm';
    fnsavme = sprintf('%s_%s_%s.csv',impdenceTable.patient{i},impdenceTable.side{i},timeuse); 
    flwrite = fullfile(dirout,fnsavme); 
    writetable(tblwrite,flwrite);
end



end