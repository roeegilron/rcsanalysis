function move_and_delete_folders()
%% this function moves folders from synced dropbox folders to unsynced folders
fprintf('the time is:\n%s\n',datetime('now'));
clc;
% set destination folders
rootdir_orig = '/Users/roee/Starr Lab Dropbox/';
rootdir_dest = fullfile(rootdir_orig,'RC+S Patient Un-Synced Data');
patdirs = {'RCS01 LTE','RC02LTE','RCS03','RCS04','RCS05','RCS06','RCS07','RCS08','RCS09','RCS10','RCS11','RCS12','RCS13','RCS14'};


for p = 1:length(patdirs)% loop on patient directories
    recordingPrograms = {'SummitContinuousBilateralStreaming','StarrLab'};
%     recordingPrograms = {'SummitContinuousBilateralStreaming'}; % don't give RUNE labs Starr Lab for now 
    % XXX figure out a difference place to put that - work  on this 
    for rp = 1:length(recordingPrograms)
        % find all data from SCBS
        patdir = fullfile(rootdir_orig,patdirs{p},'SummitData',recordingPrograms{rp});
        sidesdirs_found = findFilesBVQX(patdir,'RCS*',struct('dirs',1,'depth',1));
        fprintf('\n\n');
        for s = 1:length(sidesdirs_found) % loop on device side
            dirfound = sidesdirs_found{s};
            [pn,fn] = fileparts(dirfound);
            sessionsfound = findFilesBVQX(dirfound,'*ession*',struct('dirs',1,'depth',1));
            fprintf('%d sessions found %s\n',length(sessionsfound),fn);
            % find destination:
            patNumRaw = regexp(patdirs{p},'[0-9]+','match'); % for cases when patient number doesn't increase in oreder of loop / running partial loop 
            patnum = sprintf('%0.2d',str2num(patNumRaw{1}));
            destfolder = findFilesBVQX(rootdir_dest,['*' patnum '*'],struct('dirs',1,'depth',1));
            
            if strcmp(patdirs{p},'RCS01 LTE')
                destpath = fullfile(destfolder,'SummitData',recordingPrograms{rp},'RCS01L');
            else
                destpath = fullfile(destfolder,'SummitData',recordingPrograms{rp},fn);
            end
            fprintf('%s\n',destpath{1});
            sessionsfound_dest = findFilesBVQX(destpath,'*ession*',struct('dirs',1,'depth',1));
            fprintf('%d sessions in dest\n',length(sessionsfound_dest));
            % only copy files that were created more than 24 hours ago
            clear times 
            for ff = 1:size(sessionsfound,1)
                [pn,fn,ext] = fileparts(sessionsfound{ff});
                rawTime = str2num(strrep(lower(fn),'session',''));
                times(ff) = datetime(rawTime/1000,'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
                fprintf('[%0.3d] \t %s\n',ff,times(ff));
            end
            if ~isempty(sessionsfound)
                % only move files that have been started at least 12 hours ago
                timeBefore = (datetime(datevec(now))-hours(12));
                timeBefore.TimeZone = 'America/Los_Angeles';
                idxkeep = times < timeBefore;
                sessionsfound = sessionsfound(idxkeep);
            end
            
            for f = 1:length(sessionsfound) % loop on sesion folders
                start = tic;
                jsons = findFilesBVQX(sessionsfound{f},'*.json');
                texts = findFilesBVQX(sessionsfound{f},'*.txt');
                [pn,sessFold] = fileparts(sessionsfound{f});
                if isempty(jsons) & isempty(texts) % folder is empty - can delete
                    rmdir(sessionsfound{f},'s');
                    fprintf('removed folder from orig %d/%d in %f\n',f,length(sessionsfound),toc(start));
                else
                    jsonsmove = findFilesBVQX(sessionsfound{f},'*.json',struct('depth',2));
                    if ~isempty(jsonsmove)
                        [pn,~] = fileparts(jsonsmove{1});
                        [~,devName] = fileparts(pn);
                        fullDest = fullfile(destpath{1},sessFold,devName);
                        mkdir(fullDest);
                        for j = 1:length(jsonsmove)
                            % check if file exists in destination - this
                            % can be from previous copy that has failed. 
                            % delete the file at the destination, and try
                            % copying again: 
                            [~,fileNameToMoveForCheck,extCheck] = fileparts(jsonsmove{j});
                            if exist(fullfile(fullDest,[fileNameToMoveForCheck extCheck]),'file')
                                delete(fullfile(fullDest,[fileNameToMoveForCheck extCheck]));
                            end
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
                                delete(full_filename_orig);
                            end
                        end
                    end
                    % check if any additioanl directories inside
                    jsons = findFilesBVQX(sessionsfound{f},'*.json');
                    texts = findFilesBVQX(sessionsfound{f},'*.txt');
                    additional_files_found =[jsons; texts];
                    % if json are not empty - its likely in a subfolder
                    % these are adaptive or text files
                    % create subfolder in destination and move files over
                    if ~isempty(additional_files_found)
                        for a = 1:length(additional_files_found)
                            [pn,fnn,ext] = fileparts(additional_files_found{a});
                            [pn,internalDirFolder] = fileparts(pn);
                            [~,devName] = fileparts(pn);
                            fullDest = fullfile(destpath{1},sessFold,devName,internalDirFolder);
                            mkdir(fullDest);
                            full_filename_dest = fullfile(fullDest,[fnn ext]);
                            full_filename_orig = additional_files_found{a};
                            copyfile(full_filename_orig,full_filename_dest);
                            destdir = dir(full_filename_dest);
                            origdir = dir(full_filename_orig);
                            % check if files size is same
                            % then remove
                            if destdir.bytes == origdir.bytes
                                delete(full_filename_orig);
                            end
                        end
                    end
                    
                    % check for
                    % ConfigLogFiles - has .json inside
                    % LogDataFromLeftINS has . txt inside
                    
                    % if no files remain, then you can delete inner folders
                    % then outer folders
                    
                    fprintf('copied folder %d/%d in %f\n',f,length(sessionsfound),toc(start));
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
            end
        end
    end
end
end