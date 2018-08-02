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
[outtable, srate] = unravelData(jsonobj);
outdatcomplete = populateTimeStamp(outtable,srate,filename); 
[pn,fn,ext] = fileparts(filename); 
writetable(outdatcomplete,fullfile(pn,[fn '.csv']));
end

