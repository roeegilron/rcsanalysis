function print_report_from_device_settings_database_file_per_patient()
%% this repots some stats from the database for all patients

%% load the database
dropboxdir = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database';
reportsDir = fullfile(dropboxdir,'reports');
databaseFile = fullfile(dropboxdir,'database_from_device_settings.mat');
load(databaseFile);
%%
% clean up database a bit
% only keep elements of database from which you can "read" patient:
idxkeep = cellfun(@(x) ischar(x),masterTableOut.patient);
masterTableOut = masterTableOut(idxkeep,:);
% only keep RC+S patients, not benchtop devices etc.
idxkeep = cellfun(@(x) any(strfind(x,'RCS')),masterTableOut.patient);
masterTableOut = masterTableOut(idxkeep,:);
for ss = 1:size(masterTableOut,1)
    if istable(masterTableOut.senseSettings{ss})
        masterTableOut.chan1{ss} = masterTableOut.senseSettings{ss}.chan1{1};
        masterTableOut.chan2{ss} = masterTableOut.senseSettings{ss}.chan2{1};
        masterTableOut.chan3{ss} = masterTableOut.senseSettings{ss}.chan3{1};
        masterTableOut.chan4{ss} = masterTableOut.senseSettings{ss}.chan4{1};
    else
        masterTableOut.chan1{ss} = 'NA';
        masterTableOut.chan2{ss} = 'NA';
        masterTableOut.chan3{ss} = 'NA';
        masterTableOut.chan4{ss} = 'NA';
    end
    if istable(masterTableOut.stimStatus{ss})
        masterTableOut.stimulation_on(ss) = masterTableOut.stimStatus{ss}.stimulation_on;
        masterTableOut.electrodes{ss} = masterTableOut.stimStatus{ss}.electrodes{1};
        masterTableOut.amplitude_mA(ss) = masterTableOut.stimStatus{ss}.amplitude_mA(1);
        masterTableOut.rate_Hz(ss) = masterTableOut.stimStatus{ss}.rate_Hz(1);
    else
        masterTableOut.stimulation_on(ss) = NaN;
        masterTableOut.electrodes{ss} = 'NA';
        masterTableOut.amplitude_mA(ss) = NaN;
        masterTableOut.rate_Hz(ss) = NaN;
    end
end
save(databaseFile,'masterTableOut','-append');

%%
uniqPatients = unique(masterTableOut.patient);
for p = 1:length(uniqPatients)
    idxpatient = strcmp(masterTableOut.patient,uniqPatients{p});
    patTable = masterTableOut(idxpatient,:);
    uniqSides = unique(patTable.side);
    for s = 1:length(uniqSides)
        % get uniq sides 
        
        idxside = strcmp(patTable.side,uniqSides{s});
        dbUse = patTable(idxside,:);
        idxkeep = cellfun(@(x) istable(x),dbUse.stimStatus) & logical(dbUse.recordedWithScbs);
        dbUse = dbUse(idxkeep,:);
        dbUse.duration.Format = 'hh:mm:ss';
        for ss = 1:size(dbUse,1)
            dbUse.chan1{ss} = dbUse.senseSettings{ss}.chan1{1};
            dbUse.chan2{ss} = dbUse.senseSettings{ss}.chan2{1};
            dbUse.chan3{ss} = dbUse.senseSettings{ss}.chan3{1};
            dbUse.chan4{ss} = dbUse.senseSettings{ss}.chan4{1};
            dbUse.stimulation_on(ss) = dbUse.stimStatus{ss}.stimulation_on;
            dbUse.electrodes{ss} = dbUse.stimStatus{ss}.electrodes{1};
            dbUse.amplitude_mA(ss) = dbUse.stimStatus{ss}.amplitude_mA(1);
            dbUse.rate_Hz(ss) = dbUse.stimStatus{ss}.rate_Hz(1);
        end
        
        fnSave = sprintf('%s_s_sense_stim_report.txt',uniqPatients{p},uniqSides{s});
        fid = fopen(fullfile(reportsDir,fnSave),'w+');
        
        fprintf(fid, 'sensing and stimulation settings report of database size and settings\n\n\n');
        
        fprintf(fid, 'information in brackets contains amount of data in that condition in the format:\n');
        fprintf(fid, '[HH:MM:SS]\n\n\n');
        
        fprintf(fid,'\t *note that this only accounts for SCBS data for now\n\n')
        
        fprintf(fid, '%%%%%%%%\n');
        fprintf(fid, '%%%%%%%%\n');
        fprintf(fid, '%%%%%%%%\n');
        fprintf(fid, '%%%%%%%%\n\n');
        fprintf(fid, 'OFF STIM\n\n');
        fprintf(fid, '%%%%%%%%\n\n');
        
        % sense settings:
        idxkeep = ~dbUse.stimulation_on;
        tbluse = dbUse(idxkeep,:);
        fprintf(fid, '[%s] hours of data OFF stim\n\n', sum(tbluse.duration));
        fprintf(fid,'\tunique settings per channel:\n');
        fprintf(fid,'\t *note that hour count/ channel can contain partial overlaps across channels\n\n')
        for c = 1:4
            
            fprintf(fid,'\tchan %d:\n',c);
            cfn = sprintf('chan%d',c);
            unqsettings = unique(tbluse.(cfn));
            for u = 1:length(unqsettings)
                idxchan = strcmp(tbluse.(cfn), unqsettings{u});
                fprintf(fid,'\t\t[%s]\t%s\n',sum(tbluse.duration(idxchan)),unqsettings{u});
                
            end
        end
        
        
        fprintf(fid, '%%%%%%%%\n');
        fprintf(fid, '%%%%%%%%\n');
        fprintf(fid, '%%%%%%%%\n');
        fprintf(fid, '%%%%%%%%\n\n');
        fprintf(fid, 'ON STIM\n\n');
        fprintf(fid, '%%%%%%%%\n\n');
        
        % sense settings:
        idxkeep = logical(dbUse.stimulation_on);
        tbluse = dbUse(idxkeep,:);
        fprintf(fid, '[%s] hours of data ON stim\n\n', sum(tbluse.duration));
        fprintf(fid,'\tunique settings per channel:\n');
        fprintf(fid,'\t *note that hour count/ channel can contain partial overlaps across channels\n\n')
        for c = 1:4
            
            fprintf(fid,'\tchan %d:\n',c);
            cfn = sprintf('chan%d',c);
            unqsettings = unique(tbluse.(cfn));
            for u = 1:length(unqsettings)
                idxchan = strcmp(tbluse.(cfn), unqsettings{u});
                fprintf(fid,'\t\t[%s]\t%s\n',sum(tbluse.duration(idxchan)),unqsettings{u});
                
            end
        end
        
        % stim settings
        fprintf(fid, '%%%%%%%%\n');
        fprintf(fid, '%%%%%%%%\n');
        fprintf(fid,'\nSTIM SETTINGS:\n');
        fprintf(fid, '%%%%%%%%\n\n');
        stim_electrodes = unique(tbluse.electrodes);
        
        for e = 1:length(stim_electrodes)
            idxelec = strcmp(tbluse.electrodes, stim_electrodes{e});
            fprintf(fid,'[%s] %s\n',sum(tbluse.duration(idxelec)), stim_electrodes{e});
            stim_electrodes = unique(tbluse.electrodes);
            unqFreqs = unique(tbluse.rate_Hz(idxelec));
            for ff = 1:length(unqFreqs)
                idxfreq = tbluse.rate_Hz == unqFreqs(ff);
                fprintf(fid,'\t stim freq: %.2f(Hz)\n',unqFreqs(ff));
                unqCurrents = unique(tbluse.amplitude_mA(idxelec & idxfreq));
                for uc = 1:length(unqCurrents)
                    idxcur = tbluse.amplitude_mA == unqCurrents(uc);
                    idxcur_use = idxelec & idxcur & idxfreq;
                    fprintf(fid,'\t\t\t [%s] %.2f mA\n',sum(tbluse.duration(idxcur_use)),unqCurrents(uc));
                end
            end
        end
        warning('on','MATLAB:table:RowsAddedExistingVars');
        
        
        fclose(fid);
    end
end