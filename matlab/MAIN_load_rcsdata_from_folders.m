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

% first load the data in the folder 
% MAIN_report_data_in_folder(dirname); 
% now only choose folders that are above a certain duration 
load(fullfile(dirname,'database.mat'),'tblout'); 
if iscell(tblout.duration)
    idxnotEmpty = cellfun(@(x) ~isempty(x),tblout.duration); 
else
    idxnotEmpty = tblout.duration > seconds(0); 
end

tbluse = tblout(idxnotEmpty,:);
if iscell(tblout.duration)
    idxRecordingsOver30Seconds = cellfun(@(x) x > seconds(30), tbluse.duration);
else
    idxRecordingsOver30Seconds = tblout.duration > seconds(30); 
end
tbluse = tbluse(idxRecordingsOver30Seconds,:); 

for f = 1:size(tbluse,1)
    try
        ff = findFilesBVQX(dirname,tbluse.sessname{f},struct('dirs',1));
        foldername = findFilesBVQX(ff{1},'Device*',struct('dirs',1)); 

        start = tic;
        [outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerTable] =  MAIN_load_rcs_data_from_folder(foldername{1},params);
        fprintf('folder %d/%d done in %.2f secs\n',f,size(tbluse,1),toc(start));
    catch
        fprintf('\t\tXXXXX\t error in foler %s\n', foldername{1});
    end
end


end