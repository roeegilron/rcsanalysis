function MAIN_run_process_RCS_data_in_parallel()

% data location:
rootdir  = '/Volumes/Samsung_T5/RCS02/RCS02_all_home_data_processed/data/RCS02L';

ffiles = findFilesBVQX(rootdir,'RawDataTD.mat');
clc;

for f = 1:length(ffiles)
    try
        % find device folder
         %% to run in parllel comment section above and uncomment section below:
         startmatlab = 'matlab -nodisplay -r ';
         		runprogram  = sprintf('"run analyzeContinouseDataFromSCS(''%s'').m; exit;" ',ffiles{f});
         unix([startmatlab  runprogram ' &'])
    catch
        fprintf('\t\tXXXXX\t error in foler %s\n', folderuse{1});
    end
end