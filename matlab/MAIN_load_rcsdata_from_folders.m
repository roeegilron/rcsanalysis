function MAIN_load_rcsdata_from_folders(varargin)
% this function loads RCS data that exist in any folder. 

%% set params
params.jsononly = 1; % only loads .json data 
%% function load rcs data from a folder 
if isempty(varargin)
    [dirname] = uigetdir(pwd,'choose a dir with rcs session folders');
else
    dirname  = varargin{1};
end

foldernames = findFilesBVQX(dirname,'Device*',struct('dirs',1)); 
for f = 1:length(foldernames)
    try
        start = tic;
        [outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerTable] =  MAIN_load_rcs_data_from_folder(foldernames{f},params);
        fprintf('folder %d/%d done in %.2f secs\n',f,length(foldernames),toc(start));
    catch
        fprintf('\t\tXXXXX\t error in foler %s\n', foldernames{f});
    end
end


end