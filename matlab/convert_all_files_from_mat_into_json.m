function convert_all_files_from_mat_into_json()
clc;
% set destination folders
rootdir_orig = '/Users/juananso/Starr Lab Dropbox/';
rootdir_dest = fullfile(rootdir_orig,'RC+S Patient Un-Synced Data');

errorfilename = fullfile(rootdir_dest,'database','convert_from_json_to_mat_errors.txt');
fid = fopen(errorfilename,'w+');
fprintf(fid,'these folders have errored:\n\n');
% find all patient directories
patdirs = findFilesBVQX(rootdir_dest,'RCS09*',struct('dirs',1,'depth',1));
for p = 1:length(patdirs)% loop on patient directories
    fprintf('\n\n');
    recordingPrograms = {'SummitContinuousBilateralStreaming'}%,'StarrLab'};
    for rp = 1:length(recordingPrograms)
        recprogdir = fullfile(patdirs{p},'SummitData',recordingPrograms{rp});
        if exist(recprogdir,'dir')
            sidesdirs_found = findFilesBVQX(recprogdir,'RCS09R*',struct('dirs',1,'depth',1));
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
end

