function move_session_dirs_target_data_new_dir()
% manually move session dirs from one target directory to another 
rootdir = '/Volumes/RCS_DATA/RCS07/all_data/RCS07R'; 
targetdir = '/Volumes/RCS_DATA/RCS07/all_data/data_from_3_week_visit/RCS07R'; 
targetdate = datetime('Oct 07 2019','InputFormat','MMM dd uuuu'); 

load('/Volumes/RCS_DATA/RCS07/all_data/RCS07R/database.mat'); 

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