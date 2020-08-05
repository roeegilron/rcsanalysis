function process_data_into_10_minute_chunks()
clc;
% set destination folders
rootdir_orig = '/Users/roee/Starr Lab Dropbox/';
rootdir_dest = fullfile(rootdir_orig,'RC+S Patient Un-Synced Data');

errorfilename = fullfile(rootdir_dest,'database','stim_sense_database_construction_errors.txt');
fid = fopen(errorfilename,'w+');
fprintf(fid,'these folders have errored:\n\n');
% find all patient directories
patdirs = findFilesBVQX(rootdir_dest,'RCS*',struct('dirs',1,'depth',1));
patdirsGP = patdirs([3 9 10],:);
patdirsGP = patdirs([2 5 6 7 8],:);
for p = 1:length(patdirsGP)% loop on patient directories
    fprintf('\n\n');
    recordingPrograms = {'SummitContinuousBilateralStreaming'};
    for rp = 1:length(recordingPrograms)
        recprogdir = fullfile(patdirsGP{p},'SummitData',recordingPrograms{rp});
        if exist(recprogdir,'dir')
            sidesdirs_found = findFilesBVQX(recprogdir,'RCS*',struct('dirs',1,'depth',1));
            for s = 1:length(sidesdirs_found) % loop on device side
                try
                    MAIN_run_process_RCS_data_in_parallel(sidesdirs_found{s});
                end
            end
        end
        
    end
end

end