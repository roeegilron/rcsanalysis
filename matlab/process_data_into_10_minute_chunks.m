function process_data_into_10_minute_chunks(varargin)
clc;
% set destination folders
rootdir_orig = '/Users/roee/Starr Lab Dropbox/';
rootdir_dest = fullfile(rootdir_orig,'RC+S Patient Un-Synced Data');



if isempty(varargin)
    dropboxFolder = findFilesBVQX('/Users','Starr Lab Dropbox',struct('dirs',1,'depth',2));
    if length(dropboxFolder) == 1
        dirname  = fullfile(dropboxFolder{1}, 'RC+S Patient Un-Synced Data');
    else
        error('can not find dropbox folder, you may be on a pc');
    end
elseif length(varargin) == 1
    dirname = varargin{1};
else
    error('too many input variable , max of one input - string of file folder');
end

rootdir_dest = dirname;



errorfilename = fullfile(rootdir_dest,'database','stim_sense_database_construction_errors.txt');
fid = fopen(errorfilename,'w+');
fprintf(fid,'these folders have errored:\n\n');
% find all patient directories
patdirs = findFilesBVQX(rootdir_dest,'RCS*',struct('dirs',1,'depth',1));
% patdirsGP = patdirs([3 9 10],:);
% patdirsGP = patdirs([2 5 6 7 8],:);
% patdirs = patdirs(end-1:end); % XXXX
for p = 1:length(patdirs)% loop on patient directories
    fprintf('\n\n');
    recordingPrograms = {'SummitContinuousBilateralStreaming'};
    for rp = 1:length(recordingPrograms)
        recprogdir = fullfile(patdirs{p},'SummitData',recordingPrograms{rp});
        if exist(recprogdir,'dir')
            sidesdirs_found = findFilesBVQX(recprogdir,'RCS*',struct('dirs',1,'depth',1));
            for s = 1:length(sidesdirs_found) % loop on device side
                try
                    MAIN_run_process_RCS_data_in_parallel(sidesdirs_found{s});
                catch 
                    % write folder that have errored somewhere.
                    fprintf(fid,'%s\n',sidesdirs_found{s});
                end
            end
        end
        
    end
end
fclose(fid);
end