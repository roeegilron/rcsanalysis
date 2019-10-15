function MAIN_run_process_RCS_data_in_parallel(dirname)

% data location:
if ismac 
    rootdir  = dirname;
    curdir = pwd; 
else isunix
    rootdir  = '/home/starr/ROEE/data/RCS02L/';
    curdir = pwd; 
end
ffiles = findFilesBVQX(rootdir,'RawDataTD.mat');

clc;

for f = 1:length(ffiles)
    try 
        % first check to see if this foler has been analyzed already 
        [pnn,fnn] = fileparts(ffiles{f});
        if exist(fullfile(pnn,'processedTDdata.mat'),'file')
            fprintf('file %d already exists, skipping \n',f);
        else
            analyzeContinouseDataFromSCS(ffiles{f});
            fprintf('success %d \n',f);
        end
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