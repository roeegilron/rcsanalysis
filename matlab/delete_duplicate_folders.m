function delete_duplicate_folders()
%%
clc;
rootdir = 'D:\Starr Lab Dropbox\RC+S Patient Un-Synced Data\';

ff = findFilesBVQX(rootdir,'*(1)*',struct('dirs',1));
fprintf('proposing to delete:\n')
for f = 1:length(ff) 
    [pn,fn] = fileparts(ff{f});
    fprintf('%s\n',fn);
end
deleteok = input('ok to delete? 1 = yes 2 == no ');
if deleteok == 1
    for f = 1:length(ff)
        [pn,fn] = fileparts(ff{f});
        rmdir(ff{f},'s');
        fprintf('%s removed\n',fn);
    end
end
end