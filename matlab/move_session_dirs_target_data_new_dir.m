function move_session_dirs_target_data_new_dir()
% manually move session dirs from one target directory to another 
rootdir = '/Volumes/Samsung_T5/RCS05/1Month/dump2/StarrLab/RCS05R'; 
targetdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS05/v05_3week/rcs_data_from_session/RCS05R'; 
targetdate = datetime('Aug 14 2019','InputFormat','MMM dd uuuu'); 

load(fullfile(rootdir,'database.mat')); 

datefolders = tblout.rectime;
targetdate.Format = datefolders.Format;
targetdate.TimeZone = datefolders.TimeZone;
endtime = targetdate + hours(23.9);
idxmove = isbetween(datefolders,targetdate,endtime);
datatomove = tblout(idxmove,:); 

for s = 1:size(datatomove,1)
    [pn,fn] = fileparts(datatomove.tdfile{s});
    [temp,devicedir] = fileparts(pn); 
    [temp,sessiondir] = fileparts(temp); 
    dest = fullfile(targetdir,sessiondir,devicedir);
    mkdir(dest);
    copyfile(pn,dest);
end
end