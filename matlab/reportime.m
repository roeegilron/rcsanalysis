function timeReport = reportime(varargin)
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
    [pn,fn] = fileparts(filename);
end

jsonobj = deserializeJSON(filename);

if isfield(jsonobj,'AccelData')
    %% print time accel domain
    idxuse = strfind(pn,'Session');
    fprintf('file %s:\n',pn(idxuse:end));
    starTime = jsonobj.AccelData(1).Header.timestamp.seconds;
    startTimeDt = datetime(datevec(starTime./86400 + datenum(2000,3,1,0,0,0))); % medtronic time - LSB is seconds
    fprintf('file started at %s\n', startTimeDt);
    endTime  = jsonobj.AccelData(end).Header.timestamp.seconds;
    endTimeDt = datetime(datevec(endTime./86400 + datenum(2000,3,1,0,0,0))); % medtronic time - LSB is seconds
    fprintf('file started at %s\n', endTimeDt);
    fprintf('file length is %s\n',endTimeDt- startTimeDt);
else
    
    %% print time time domain
    idxuse = strfind(pn,'Session');
    fprintf('file %s:\n',pn(idxuse:end));
    if isempty(jsonobj) % this is for the case in which json is malformed 
        fprintf('turtle json can not read this file \n');
        startTimeDt = []; 
        endTimeDt = []; 

    elseif isempty(fieldnames(jsonobj)) 
        fprintf('no time time domain dat ain this file\n');
        startTimeDt = []; 
        endTimeDt = []; 
    elseif isempty(jsonobj.TimeDomainData)
        fprintf('no time time domain dat ain this file\n');
        startTimeDt = [];
        endTimeDt = [];
    else
        starTime = jsonobj.TimeDomainData(1).Header.timestamp.seconds;
        startTimeDt = datetime(datevec(starTime./86400 + datenum(2000,3,1,0,0,0))); % medtronic time - LSB is seconds
        fprintf('file started at %s\n', startTimeDt);
        endTime  = jsonobj.TimeDomainData(end).Header.timestamp.seconds;
        endTimeDt = datetime(datevec(endTime./86400 + datenum(2000,3,1,0,0,0))); % medtronic time - LSB is seconds
        fprintf('file started at %s\n', endTimeDt);
        fprintf('file length is %s\n',endTimeDt- startTimeDt);
    end
end
if isempty(startTimeDt)
    timeReport.startTime = [];
    timeReport.endTime = [];
    timeReport.duration = [];
    
else
    timeReport.startTime = startTimeDt;
    timeReport.endTime = endTimeDt;
    timeReport.duration = endTimeDt- startTimeDt;
end

end

