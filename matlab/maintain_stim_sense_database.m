function maintain_stim_sense_database()
clc;
% set destination folders
rootdir_orig = '/Users/roee/Starr Lab Dropbox/';
rootdir_dest = fullfile(rootdir_orig,'RC+S Patient Un-Synced Data');

errorfilename = fullfile(rootdir_dest,'stim_sense_database_construction_errors.txt');
fid = fopen(errorfilename,'w+');
fprintf(fid,'these folders have errored:\n\n');
% find all patient directories
patdirs = findFilesBVQX(rootdir_dest,'RCS*',struct('dirs',1,'depth',1));
for p = 2:length(patdirs)% loop on patient directories
    fprintf('\n\n');
    recordingPrograms = {'SummitContinuousBilateralStreaming','StarrLab'};
    for rp = 1:length(recordingPrograms)
        recprogdir = fullfile(patdirs{p},'SummitData',recordingPrograms{rp});
        if exist(recprogdir,'dir')
            sidesdirs_found = findFilesBVQX(recprogdir,'RCS*',struct('dirs',1,'depth',1));
            for s = 1:length(sidesdirs_found) % loop on device side
                try
                    print_stim_and_sense_settings_in_folders(sidesdirs_found{s},1);
                catch
                    fprintf(fid,'%s\n',sidesdirs_found{s});
                end
            end
        end
    end
end
fclose(fid); 
end