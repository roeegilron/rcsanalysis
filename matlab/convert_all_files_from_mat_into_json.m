function convert_all_files_from_mat_into_json()
clc;
warning('off','MATLAB:table:RowsAddedExistingVars');
startTic = tic;


% set destination folders
dropboxFolder = findFilesBVQX('/Users','Starr Lab Dropbox',struct('dirs',1,'depth',2));
if length(dropboxFolder) == 1
    dirname  = fullfile(dropboxFolder{1}, 'RC+S Patient Un-Synced Data');
    rootdir_orig = '/Users/roee/Starr Lab Dropbox/';
    rootdir_dest = fullfile(rootdir_orig,'RC+S Patient Un-Synced Data');

else
    error('can not find dropbox folder, you may be on a pc');
end


errorfilename = fullfile(rootdir_dest,'database','convert_from_json_to_mat_errors.txt');
fid = fopen(errorfilename,'w+');
fprintf(fid,'these folders have errored:\n\n');
% find all patient directories
patdirs = findFilesBVQX(rootdir_dest,'RCS*',struct('dirs',1,'depth',1));
for p = 1:length(patdirs)% loop on patient directories
    fprintf('\n\n');
    recordingPrograms = {'SummitContinuousBilateralStreaming','StarrLab'};
    for rp = 1:length(recordingPrograms)
        recprogdir = fullfile(patdirs{p},'SummitData',recordingPrograms{rp});
        if exist(recprogdir,'dir')
            sidesdirs_found = findFilesBVQX(recprogdir,'RCS*',struct('dirs',1,'depth',1));
            for s = 1:length(sidesdirs_found) % loop on device side
                try
                    MAIN_load_rcsdata_from_folders(sidesdirs_found{s});
                catch
                    fprintf(fid,'%s\n',sidesdirs_found{s});
                end
            end
        end
    end
end
fclose(fid); 
timeTook = seconds(toc(startTic));
timeTook.Format = 'hh:mm:ss';
fprintf('finished all data base in %s\n',timeTook);
fprintf('finished job and time is:\n%s\n',datetime('now'))

end

