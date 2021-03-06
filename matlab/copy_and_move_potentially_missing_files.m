function copy_and_move_potentially_missing_files()
% hunt for RC+S sessions that exists elsewhere
% stick them on dropbox if they are not already there

sourceDir = '/Users/roee/Documents/Data_Analysis/RCS_data';
runDataBaseFunction = input('run databse function again? (1 == yes 0 == no ');
if runDataBaseFunction
    create_database_from_device_settings_files(sourceDir);
    load(fullfile(sourceDir,'database', 'database_from_device_settings.mat'));
    sourceDB = masterTableLightOut;
    clear masterTableLightOut;
else
    load(fullfile(sourceDir,'database', 'database_from_device_settings.mat'),'masterTableLightOut');
    sourceDB = masterTableLightOut;
    clear masterTableLightOut;
end

targetDir = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data';
if runDataBaseFunction
    create_database_from_device_settings_files(targetDir);
    targetDB = masterTableLightOut;
    clear masterTableLightOut;
else
    load(fullfile(targetDir,'database', 'database_from_device_settings.mat'),'masterTableLightOut');
    targetDB = masterTableLightOut;
    clear masterTableLightOut;
end

%% report missing files found in patient report 
missingFilesDB = table();
for s = 1:size(sourceDB,1)
     x = 2;
     if ~isempty(sourceDB.patient(s))
         sourceDB.
     end
end
x  = 2;
%% 

%%
idxuse = strcmp(masterTableOut.patient,'RCS02');
masterTableOut =  masterTableOut(idxuse,:);
cntNotFound = 1;
for s = 1:size(masterTableOut,1)
    if ~isempty(masterTableOut.deviceId{s})
        sessiondir = masterTableOut.session{s};
        patient    = masterTableOut.patient{s};
        side    = masterTableOut.side{s};
        programUsed = 'NA';
        if any(strfind(masterTableOut.deviceSettingsFn{s},'SummitContinuousBilateralStreaming'))
            programUsed = 'SummitContinuousBilateralStreaming';
        end
        if any(strfind(masterTableOut.deviceSettingsFn{s},'StarrLab'))
            programUsed = 'StarrLab';
        end
        if any(strfind(patient,'RCS'))
            idxUse = strcmp(tblPat.patient,patient) & strcmp(tblPat.side,side);
            patDir = tblPat.path(idxUse);
            [ParentDirPatients,fn] = fileparts(patDir{1});
            patSideDires = findFilesBVQX(ParentDirPatients,['*' sessiondir(3:end) '*'],struct('dirs',1));
            if isempty(patSideDires)
                fprintf('[%0.3d]\t %s %s not found %s \n',cntNotFound,patient, side, sessiondir);
                cntNotFound = cntNotFound + 1;
                [sourceDir,~] = fileparts(masterTableOut.deviceSettingsFn{s});
                if any(strfind(sourceDir,'StarrLab'))
                    targetPath = patDir{1};
                elseif any(strfind(sourceDir,'SummitContinuousBilateralStreaming'))
                    targetPath = patDir{2};
                else
                    targetPath = patDir{1};
                end
                targetDir = findFilesBVQX(targetPath,[patient side],struct('dirs',1,'depth',1));
                copy_and_move(sourceDir,targetDir{1});
            end
        end
        
    end
end

end


function copy_and_move(sourceDir, targetDir)
start = tic;
jsons = findFilesBVQX(sourceDir,'*.json','maxdepth',1);
texts = findFilesBVQX(sourceDir,'*.txt','depth',1);
[pn,devName] = fileparts(sourceDir);
[~,sessFold] = fileparts(pn);
jsonsmove = jsons;
if ~isempty(jsonsmove)
    [pn,~] = fileparts(jsonsmove{1});
    [~,devName] = fileparts(pn);
    fullDest = fullfile(targetDir,sessFold,devName);
    mkdir(fullDest);
    for j = 1:length(jsonsmove)
        copyfile(jsonsmove{j},fullDest);
        fs(j) = dir(jsonsmove{j});
        [~,filenamemove,ext] = fileparts(jsonsmove{j});
        full_filename_dest = fullfile(fullDest,[filenamemove ext]);
        full_filename_orig = jsonsmove{j};
        destdir = dir(full_filename_dest);
        origdir = dir(full_filename_orig);
        % check if files size is same
        % then remove
        if destdir.bytes == origdir.bytes
%             delete(full_filename_orig);
        end
    end
end

% check for
% ConfigLogFiles - has .json inside
% LogDataFromLeftINS has . txt inside

% if no files remain, then you can delete inner folders
% then outer folders

fprintf('copied folder in %f\n',toc(start));
% verify that data exist in destination folder and it's the
% same size as origin
%             totalsize_orig = sum([fs.bytes]);
%             fs_dest = dir(fullfile(fullDest,'*.json'));
%             totalsize_dest = sum([fs_dest.bytes]);
%             if totalsize_dest == totalsize_orig % the files have been copied ok
%                 [dirtoremove,~] = fileparts(fullDest);
%                 rmdir(dirtoremove,'s');
%                 fprintf('removed folder from orig %d/%d in %f\n',f,length(sessionsfound),toc(start));
%             end

end