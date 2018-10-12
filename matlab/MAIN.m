function MAIN(varargin)
%% This function reads TimeDomain *.json from RC+S
%% The main reason for this function is to convert this *.json file to a 
%% an easier to analyze *.csv file, and in particular to deal with packet loss issues. 

%% Depedencies: 
% https://github.com/JimHokanson/turtle_json
% in the a folder called "toolboxes" in the directory where MAIN is. 
if isempty(varargin)
    [fn,pn] = uigetfile('*.json');
    filename = fullfile(pn,fn);
else
    filename  = varargin{1};
end

jsonobj = deserializeJSON(filename);
if ~isempty(strfind(filename,'RawDataTD'))
[outtable, srate] = unravelData(jsonobj);
end

if ~isempty(strfind(filename,'RawDataAccel'))
[outtable, srate] = unravelDataACC(jsonobj);
end
outdatcomplete = populateTimeStamp(outtable,srate,filename); 
[pn,fn,ext] = fileparts(filename); 
% writetable(outdatcomplete,fullfile(pn,[fn '.csv']));
save(fullfile(pn,[fn '.mat']),'outdatcomplete');
end

