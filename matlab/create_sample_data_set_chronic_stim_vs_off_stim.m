function create_sample_data_set_chronic_stim_vs_off_stim()
%% set params for each patient
params.rootdest = '/Volumes/RCS_DATA/chronic_stim_vs_off';

%% load the master databse
% set destination folders
dropboxFolder = findFilesBVQX('/Users','Starr Lab Dropbox',struct('dirs',1,'depth',2));
if length(dropboxFolder) == 1
    dirname  = fullfile(dropboxFolder{1}, 'RC+S Patient Un-Synced Data');
    rootdir = fullfile(dirname,'database');
else
    error('can not find dropbox folder, you may be on a pc');
end

% set box folder with current analysis code


load(fullfile(rootdir,'database_from_device_settings.mat'),'masterTableLightOut');

masterTableOut = masterTableLightOut;

idxkeep = cellfun(@(x) any(strfind(x,'RCS')), masterTableOut.patient);
tblall =  masterTableOut(idxkeep,:);

%% get a list of patients and dates
cnt = 1;
patientDates = table;

% rcs02
patientDates.patient{cnt} = 'RCS02';
patientDates.date(cnt)    = datetime('28 May 2019','Format','dd MMM yyyy');
cnt = cnt +1;
patientDates.patient{cnt} = 'RCS02';
patientDates.date(cnt)    = datetime('12 Jun 2020','Format','dd MMM yyyy');
cnt = cnt + 1;
% may 28 2019
% jun 12 2020

% rcs05
patientDates.patient{cnt} = 'RCS05';
patientDates.date(cnt)    = datetime('25 Jul 2019','Format','dd MMM yyyy');
cnt = cnt + 1;
patientDates.patient{cnt} = 'RCS05';
patientDates.date(cnt)    = datetime('16 Jun 2020','Format','dd MMM yyyy');
cnt = cnt + 1;
% july 25 2019
% jun 16 2020

% rcs06
patientDates.patient{cnt} = 'RCS06';
patientDates.date(cnt)    = datetime('13 Oct 2019','Format','dd MMM yyyy');
cnt = cnt + 1;
patientDates.patient{cnt} = 'RCS06';
patientDates.date(cnt)    = datetime('25 Jun 2020','Format','dd MMM yyyy');
cnt = cnt + 1;

% oct 13 2019
% jun 25 2020

% rcs07
patientDates.patient{cnt} = 'RCS07';
patientDates.date(cnt)    = datetime('10 Oct 2019','Format','dd MMM yyyy');
cnt = cnt + 1;
patientDates.patient{cnt} = 'RCS07';
patientDates.date(cnt)    = datetime('25 Jun 2020','Format','dd MMM yyyy');
cnt = cnt + 1;
patientDates.patient{cnt} = 'RCS07';
patientDates.date(cnt)    = datetime('8 Jan 2021','Format','dd MMM yyyy');
cnt = cnt + 1;
patientDates.patient{cnt} = 'RCS07';
patientDates.date(cnt)    = datetime('9 Jan 2021','Format','dd MMM yyyy');
cnt = cnt + 1;
patientDates.patient{cnt} = 'RCS07';
patientDates.date(cnt)    = datetime('10 Jan 2021','Format','dd MMM yyyy');
cnt = cnt + 1;
patientDates.patient{cnt} = 'RCS07';
patientDates.date(cnt)    = datetime('11 Jan 2021','Format','dd MMM yyyy');
cnt = cnt + 1;

% before stim - oct 10 2019
% after stim - jun 25 2020
% with diary:
% jan 8
% jan 9
% jan 10
% jan 11



% rcs08
patientDates.patient{cnt} = 'RCS08';
patientDates.date(cnt)    = datetime('4 Mar 2020','Format','dd MMM yyyy');
cnt = cnt + 1;
patientDates.patient{cnt} = 'RCS08';
patientDates.date(cnt)    = datetime('23 Jun 2020','Format','dd MMM yyyy');
cnt = cnt + 1;
% march 4 2020
% jun 23 2020


% rcs12
patientDates.patient{cnt} = 'RCS12';
patientDates.date(cnt)    = datetime('23 Nov 2020','Format','dd MMM yyyy');
cnt = cnt + 1;
patientDates.patient{cnt} = 'RCS12';
patientDates.date(cnt)    = datetime('3 Jan 2021','Format','dd MMM yyyy');
cnt = cnt + 1;
% nov 23 2020
% jan 3rd 2021

% rcs 13
patientDates.patient{cnt} = 'RCS13';
patientDates.date(cnt)    = datetime('12 Jan 2021','Format','dd MMM yyyy');
cnt = cnt + 1;

%% run through this list and move all the files from dropbox to destination
for p = 7:size(patientDates,1)  % XXX 
    patientFind = patientDates.patient{p};
    [yFind,mFind,dFind] = ymd(patientDates.date(p));
    [yAll,mAll,dAll   ] = ymd(tblall.timeStart);
    idxSessions = (yFind == yAll) & (mFind == mAll) & (dFind == dAll) & ...
        cellfun(@(x) any(strfind(x,patientFind)),tblall.patient);
    tblMove = tblall(idxSessions,:);
    uniqueSides = unique(tblMove.side);
    for u = 1:length(uniqueSides)
        % create an array of sessions found that includes patient,
        idxSides = cellfun(@(x) any(strfind(x,uniqueSides{u})),tblMove.side);
        tblSide = tblMove(idxSides,:);
        
        
        
        patdir = sprintf('%s%s',tblSide.patient{1},tblSide.side{1});
        destpath{1} = fullfile(params.rootdest,patdir);
        if ~exist(destpath{1},'dir')
            mkdir(destpath{1});
        end
        sessionsfound = {};
        for ss = 1:size(tblSide,1)
            [pn,fn] = fileparts(tblSide.deviceSettingsFn{ss});
            [pnn,fn] = fileparts(pn);
            sessionsfound{ss,1} = pnn;
        end
        
        
        
        for f = 1:length(sessionsfound) % loop on sesion folders
            start = tic;
            jsons = findFilesBVQX(sessionsfound{f},'*.json');
            texts = findFilesBVQX(sessionsfound{f},'*.txt');
            [pn,sessFold] = fileparts(sessionsfound{f});
            if isempty(jsons) & isempty(texts) % folder is empty - can delete
                %                 rmdir(sessionsfound{f},'s');
                fprintf('removed folder from orig %d/%d in %f\n',f,length(sessionsfound),toc(start));
            else
                jsonsmove = findFilesBVQX(sessionsfound{f},'*.json',struct('depth',2));
                if ~isempty(jsonsmove)
                    [pn,~] = fileparts(jsonsmove{1});
                    [~,devName] = fileparts(pn);
                    fullDest = fullfile(destpath{1},sessFold,devName);
                    if ~exist(fullDest,'dir')
                        mkdir(fullDest);
                    end
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
                    end
                end
                % check if any additioanl directories inside
                
                jsons = findFilesBVQX(sessionsfound{f},'*.json',struct('depth',3));
                try
                    texts = findFilesBVQX(sessionsfound{f},'*.txt',struct('depth',3));
                catch 
                    texts = {};
                end
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
                    end
                end
                
                % check for
                % ConfigLogFiles - has .json inside
                % LogDataFromLeftINS has . txt inside
                
                % if no files remain, then you can delete inner folders
                % then outer folders
                
                fprintf('copied folder %d/%d in %f\n',f,length(sessionsfound),toc(start));
            end
        end
    end
end