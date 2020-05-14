function selection = select_files(folder,pref,mid,suf,ext,type,fpath)
%
% SELECTION = SELECT_FILES(FOLDER,PREF,MID,SUF,EXT,TYPE,PATH)
% 
% Select files/folders.
% 
% 
%INPUT
%-----
% - FOLDER: directory to look the files/folders in
% - PREF  : files/folders prefix
% - MID   : middle part of the files/folders
% - SUF   : files/folders suffix
% - EXT   : files extension
% - TYPE  : 'files' or 'folders'
% - FPATH : 'path' (SELECTION will have the full path) or 'nopath' (only
%   files/folders names)
% 
%TIPS
%----
% - PREF, MID, SUF and EXT can be empty strings
% - EXT is ignored if TYPE = 'folders'
% - SELECT_FILES is case-insensitive
% 
% 
%OUTPUT
%------
% - SELECTION: cell array containing the file/folder names
% 
% 
%EXAMPLE
%-------
% selection = select_files('C:\MyDocs','my_','program','','m','files','path');
% 
% 
% See also SELECT_FILES_REC
% Guilherme C. Beltramini (guicoco@gmail.com)
% 2012-Feb-03, 10:41 am
% Get files/folders with chosen pattern
%--------------------------------------------------------------------------
curr_dir = pwd;
cd(folder)
switch lower(type)
    
    % Folders
    case 'folders'
        tmp = dir(sprintf('%s*%s*%s',pref,mid,suf));
        
        % Exclude '.' and '..'
        if size(tmp,1)>0
            if strcmp(tmp(1).name,'.')
                tmp(1) = [];
            end
            if strcmp(tmp(1).name,'..')
                tmp(1) = [];
            end
        end
        
    % Files
    case 'files'
        if isempty(ext)
            tmp = dir(sprintf('%s*%s*%s',pref,mid,suf));
        else
            ext = strrep(ext,'.','');
            tmp = dir(sprintf('%s*%s*%s.%s',pref,mid,suf,ext));
        end
        
        
    otherwise
        error('Unknown option for TYPE (choose ''files'' or ''folders'')')
end
cd(curr_dir)
if isempty(tmp)
    selection = {''};
    return
end
% Find the directories in the selection
%--------------------------------------------------------------------------
N           = size(tmp,1);
direct      = cell(N,1);
[direct{:}] = deal(tmp.isdir);
direct      = cell2mat(direct);
% Get chosen type
%--------------------------------------------------------------------------
switch lower(type)
    case 'files'
        tmp = tmp(~direct);
    case 'folders'
        tmp = tmp(direct);
end
% Path
%--------------------------------------------------------------------------
N         = size(tmp,1);
selection = cell(N,1);
switch lower(fpath)
    
    % Full path
    %----------
    case 'path'
        for f=1:N
            selection{f} = fullfile(folder,tmp(f).name);
        end
    
    % Only file name
    %---------------
    case 'nopath'
        [selection{:}] = deal(tmp.name);
        
    otherwise
        error('Unknown option for PATH')
end