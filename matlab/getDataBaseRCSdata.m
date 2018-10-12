function tblout = getDataBaseRCSdata(dirname)
% this function created a database of rcs data 

% rows 
% rec time 
% path to filename 
% rawTDdata .mat exist 
% plot (boolean) 

dirsdata = findFilesBVQX(dirname,'Sess*',struct('dirs',1,'depth',1));
% extract times and .mat status 
dbout = []; 
for d = 1:length(dirsdata)
    diruse = findFilesBVQX(dirsdata{d},'Device*',struct('dirs',1,'depth',1));
    if isempty(diruse) % no data exists insdie  
        
        dbout(d).rectime = []; 
        dbout(d).matExist  = 0; 
        dbout(d).plot    = false; 
        dbout(d).fnm     = []; 
        dbout(d).tdfile  = []; 
        [pn,fn] = fileparts(dirsdata{d}); 
        dbout(d).sessname = fn;
    else % data exists 
        [pn,fn] = fileparts(dirsdata{d}); 
        dbout(d).rectime = getTime(fn); 
        dbout(d).sessname = fn;
        tdfile = findFilesBVQX(dirsdata{d},'RawDataTD.json');
        dbout(d).tdfile = tdfile{1}; 
        % does mat file exist? 
        matfile = findFilesBVQX(dirsdata{d},'*TD*.mat');
        if isempty(matfile) % no matlab data loaded
            dbout(d).matExist = false;
            dbout(d).fnm = [];  
        else
            dbout(d).matExist = true; 
            dbout(d).fnm = matfile{1}; 
        end
        dbout(d).plot = false; 
    end
end
tblout = struct2table(dbout); 
end

function t = getTime(fn)
%% 
tmpcl = regexp(fn,'[0-9]+','match');
timenum = str2num(tmpcl{1});
t = datetime(timenum/1000,'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
%%
end



