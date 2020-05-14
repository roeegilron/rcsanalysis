function numlines = countlines(name,option)
% 
% numlines = countlines(name,option)
% 
% Count the number of lines in the files.
% 
% 
%INPUT
%-----
% - NAME  : folder name where the files are or cell array with the file
%   names (OPTION='dir' and 'file', respectively)
% - OPTION: 'dir' (NAME is a folder) or 'file' (NAME is a file or set of
%   files)
% 
% 
%OUTPUT
%------
% - NUMLINES: Nx2 cell array, where N is the number of files, with the file
%   name in the first column and the number of lines in the second column
% 
% 
% See also SELECT_FILES
% The part of the code that counts the lines came from Walter Roberson:
% www.mathworks.com/matlabcentral/newsreader/view_thread/235126
% Guilherme Coco Beltramini (guicoco@gmail.com)
% 2013-Jan-17, 05:26 pm
% Input
switch option
    case 'dir'
        name = select_files(name,'','','','','files','path');
        if size(name,1)==1 && strcmp(name{1},'') % no file
            numlines = {'',[]};
            return
        end
    case 'file'
        if ischar(name)
            name = {name};
        elseif ~iscellstr(name)
            error('Invalid input for NAME')
        else
            name = name(:);
        end
    otherwise
        error('Unknown OPTION')
end
% Count the number of lines for all files
numfiles = size(name,1);
numlines = cell(numfiles,2);
for ff=1:numfiles
    numlines{ff,2} = str2double( perl('countlines.pl', name{ff}) );
end
numlines(:,1) = name;