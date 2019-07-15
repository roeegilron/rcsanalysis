function MAIN_run_process_RCS_data_in_parallel()

% data location:
if ismac 
    rootdir  = '/Volumes/Samsung_T5/RCS02/RCS02_all_home_data_processed/data/RCS02L';
    curdir = pwd; 
else isunix
    rootdir  = '/home/starr/ROEE/data/RCS02L/';
    curdir = pwd; 
end
ffiles = findFilesBVQX(rootdir,'RawDataTD.mat');
ffiles = findFilesBVQX(rootdir,'RawDataAccel.mat');

clc;

for f = 1:length(ffiles)
    try 
        analyzeContinouseDataFromSCS(ffiles{f});
        fprintf('success %d \n',f);
    catch 
        fprintf('failed %d \n',f);
    end
    try
        % find device folder
         %% to run in parllel comment section above and uncomment section below:
%          gotodir = sprintf('cd(''%s'');',curdir);
%          startmatlab = 'matlab -nodisplay -r ';
%          		runprogram  = sprintf('%s analyzeContinouseDataFromSCS(''%s'').m; exit; ',gotodir, ffiles{f});
%          unix([ startmatlab   runprogram ' &'])
    catch
        fprintf('\t\tXXXXX\t error in foler %s\n', folderuse{1});
    end
end