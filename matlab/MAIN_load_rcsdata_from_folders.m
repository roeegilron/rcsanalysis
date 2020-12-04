function MAIN_load_rcsdata_from_folders(varargin)
% this function loads RCS data that exist in any folder. 


%% set params
params.jsononly = 0; % only loads .json data 
%% function load rcs data from a folder 
if isempty(varargin)
    [dirname] = uigetdir(pwd,'choose a dir with rcs session folders');
else
    dirname  = varargin{1};
end
% check if a database folder exists, if not run  the MAIN_repot function:
databasefile = fullfile(dirname,'database','database_from_device_settings.mat');
databasedir  = fullfile(dirname,'database'); 
if ~exist(databasefile,'file')
    % MAIN_report_data_in_folder(dirname); old way of doing this - created
    % a database file 
    create_database_from_device_settings_files(dirname);
    load(databasefile);
else
    load(databasefile);
end

% now only choose folders that are above a certain duration 
tblout = masterTableOut;
if iscell(tblout.duration)
    idxnotEmpty = cellfun(@(x) ~isempty(x),tblout.duration); 
else
    idxnotEmpty = tblout.duration > seconds(0); 
end

tbluse = tblout(idxnotEmpty,:);
if iscell(tbluse.duration)
    idxRecordingsOver30Seconds = cellfun(@(x) x > seconds(30), tbluse.duration);
else
    idxRecordingsOver30Seconds = tbluse.duration > seconds(30); 
end
tbluse = tbluse(idxRecordingsOver30Seconds,:); 
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
% startTimes = [tbluse.startTime{:}]';
% idxopen = isbetween(startTimes,'19-Jun-2019','10-Jul-2019');
% tbluse = tbluse(idxopen,:); 
% % delete all the .mat files and reopen this folder 
% for t = 1:size(tbluse)
%     [pn,fn,ext] = fileparts(tbluse.tdfile{t});
%     ff = findFilesBVQX(pn,'*.mat'); 
%     for f = 1:length(ff)
% %         delete(ff{f});
%     end
% end
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%

% write all error folders to a file: 
errorFile = fullfile(databasedir,'error_folders.txt');
fid = fopen(errorFile,'w+');

for f = 1:size(tbluse,1)
    try
        ff = findFilesBVQX(dirname,tbluse.session{f},struct('dirs',1));
        foldername = findFilesBVQX(ff{1},'Device*',struct('dirs',1)); 
        if isempty(foldername) 
            % known bug: 
            foldername = findFilesBVQX(ff{1},'ConfigLogFiles',struct('dirs',1)); 
        else
            foldername = foldername;
        end

        start = tic;
        
        ftd = findFilesBVQX(foldername{1},'RawDataTD.mat');
        fds = findFilesBVQX(foldername{1},'DeviceSettings.mat');
        if ~isempty(ftd) & ~isempty(fds)
            fprintf('this folder was opened before, skippinn\n'); 
            fprintf('folder %d/%d done in %.2f secs\n',f,size(tbluse,1),toc(start));
        else
            [outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerTable] =  MAIN_load_rcs_data_from_folder(foldername{1},params);
            fprintf('folder %d/%d done in %.2f secs\n',f,size(tbluse,1),toc(start));
        end
        
    catch
        fprintf('\t\tXXXXX\t error in foler %s\n', foldername{1});
        if ~isempty(foldername)
            try
                [pn,fn,ext] = fileparts(foldername{1});
                rawTime = str2num(strrep(fn,'Session',''));
                t = datetime(rawTime/1000,'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
                
                fprintf(fid,'%s %s\n',t,foldername{1})
            catch
                fprintf(fid,'Do Not Know Time %s\n',foldername{1});
            end
        end
    end
end
fclose(fid);


end