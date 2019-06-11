function MAIN_run_open_RCS_data_in_parallel()
roodir = '/Users/roee/Downloads/temp';
roodir = '/home/starr/ROEE/data/SummitContinuousBilateralStreaming/RCS02L';
foldernames = findFilesBVQX(roodir,'Device*',struct('dirs',1)); 

for f = 1:length(foldernames)
    try
        % find device folder
         %% to run in parllel comment section above and uncomment section below:
         startmatlab = 'matlab -nodisplay -r ';
         		runprogram  = sprintf('"run MAIN_load_rcs_data_from_folder(''%s'').m; exit;" ',foldernames{f});
         unix([startmatlab  runprogram ' &'])
    catch
        fprintf('\t\tXXXXX\t error in foler %s\n', folderuse{1});
    end
end