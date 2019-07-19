function MAIN_run_process_RCS_data_in_parallel()

% data location:
if ismac 
    rootdir  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/v13_home_data_stim/rcs_data/RCS02R';
    curdir = pwd; 
else isunix
    rootdir  = '/home/starr/ROEE/data/RCS02L/';
    curdir = pwd; 
end
ffiles = findFilesBVQX(rootdir,'RawDataTD.mat');

clc;

for f = 3:length(ffiles)
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