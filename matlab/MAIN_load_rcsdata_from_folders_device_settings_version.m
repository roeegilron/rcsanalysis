function MAIN_load_rcsdata_from_folders_device_settings_version(dirname)
% this function loads RCS data that exist in any folder. 


%% set params
params.jsononly = 0; % only loads .json data 
%% function load rcs data from a folder 

% check if a database folder exists, if not run  the MAIN_repot function:
if ~exist(fullfile(dirname,'database_from_device_settings.mat'),'file')
    create_database_from_device_settings_files(dirname);
end

% now only choose folders that are above a certain duration 
load(fullfile(dirname,'database_from_device_settings.mat')); 
tblout = masterTableOut;

idxnotEmpty = tblout.duration > seconds(0);


tbluse = tblout(idxnotEmpty,:);

idxRecordingsOver30Seconds = tbluse.duration > seconds(30);

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

for f = 1:size(tbluse,1)
    try
        ff = findFilesBVQX(dirname,tbluse.session{f},struct('dirs',1));
        foldername = findFilesBVQX(ff{1},'Device*',struct('dirs',1)); 

        start = tic;
        ftd = findFilesBVQX(foldername{1},'RawDataTD.mat');
        if ~isempty(ftd)
            fprintf('this folder was opened before, skippinn\n'); 
            fprintf('folder %d/%d done in %.2f secs\n',f,size(tbluse,1),toc(start));
        else
            [outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerTable] =  MAIN_load_rcs_data_from_folder(foldername{1},params);
            fprintf('folder %d/%d done in %.2f secs\n',f,size(tbluse,1),toc(start));
        end
        
    catch
        fprintf('\t\tXXXXX\t error in foler %s\n', foldername{1});
    end
end


end