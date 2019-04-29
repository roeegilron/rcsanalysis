function [outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerTable] =  MAIN_load_rcs_data_from_folder(varargin)
%% function load rcs data from a folder 
if isempty(varargin)
    [dirname] = uigetdir(pwd,'choose a dir with rcs .json data');
else
    dirname  = varargin{1};
end
%% load files 
filesLoad = {'RawDataTD.json','DeviceSettings.json','EventLog.json','RawDataAccel.json','RawDataPower.json'}; 
for j = 1:length(filesLoad)
    ff = findFilesBVQX(dirname,filesLoad{j});
    checkForErrors(ff);
    [fileExists, fn] = checkIfMatExists(ff{1});
    if fileExists
        if strcmp(filesLoad{j},'RawDataAccel.json') % if acc file rename it 
            a = load(fn); 
            outdatcompleteAcc = a.outdatcomplete; 
            sratesAcc = a.srates; 
            unqsratesAcc = a.unqsrates;
        else
            load(fn);
        end
    else
        switch filesLoad{j}
            case 'RawDataTD.json'
                fileload = fullfile(dirname,'RawDataTD.json');
                [outdatcomplete, srates, unqsrates] = MAIN(fileload);
            case 'RawDataAccel.json'
                fileload = fullfile(dirname,'RawDataAccel.json');
                [outdatcompleteAcc, ~, ~] = MAIN(fileload);
            case 'DeviceSettings.json'
                fileload = fullfile(dirname,'DeviceSettings.json');
                outRec = loadDeviceSettings(fileload);
            case 'EventLog.json'
                fileload = fullfile(dirname,'EventLog.json');
                eventTable = loadEventLog(fileload);
                if isempty(eventTable)
                    sessionid = fileload(strfind(fileload,'Session')+7:strfind(fileload,'Session')+19);
                    eventTable = createDummyEventTable(outRec,sessionid);
                end
                [pn,fnm, ext] = fileparts(fileload);
                save(fullfile(pn,[fnm '.mat']),'eventTable');
            case 'RawDataPower.json'
                fileload = fullfile(dirname,'RawDataPower.json');
                powerTable = loadPowerData(fileload);
        end
        
    end
end


end

function checkForErrors(ff)
if isempty(ff)
    error('no time domain json'); 
elseif length(ff) > 2 
    error('more than one time domain files');  
end
end

function [fileExists, fnout] = checkIfMatExists(fn)
[pn,fn,ext] = fileparts(fn);
if exist(fullfile(pn,[fn '.mat']),'file')
    fileExists = 1; 
    fnout = fullfile(pn,[fn '.mat']);
else
    fileExists = 0; 
    fnout = [];
end
end