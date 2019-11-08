function timeReport = report_start_end_time_td_file_rcs(tdfile)
%% this file just tried to open a TD file 
%% and report the start and end time as quickly as possible 
%% it uses "fread" functions in order to do this really quickly 

% this approach tries to read only a portion of the file at a time: 
tic 
fid = fopen(tdfile); 
fseek(fid, 0, 'bof');
text = fread(fid, 500,'uint8=>char')';
fileIsEmpty = 0; % assume that file is not empty until proven otherwise 
% check that this file is not empty 
if length(text)<200 %  this is an empty time domain file 
    fileIsEmpty = 1; 
end
if ~fileIsEmpty
    rawtime = regexp(text,'(?<="timestamp":{"seconds":)[0-9]+','match');
    timeStart = datetime(datevec(str2double(rawtime{1})./86400 + ...
        datenum(2000,3,1,0,0,0))); % medtronic time - LSB is seconds
    
    % now go to end of the file
    fseek(fid, -10000, 'eof');
    filesize = ftell(fid);
    text = fread(fid, 8000,'uint8=>char')';
    rawtime = regexp(text,'(?<="timestamp":{"seconds":)[0-9]+','match');
    
    timeEnd = datetime(datevec(str2double(rawtime{end})./86400 + ...
        datenum(2000,3,1,0,0,0))); % medtronic time - LSB is seconds
    
    fclose(fid);
    
    timeReport.startTime = timeStart;
    timeReport.endTime = timeEnd;
    timeReport.duration = timeEnd-timeStart;
else
    timeReport.startTime = [];
    timeReport.endTime = [];
    timeReport.duration = [];
end



% this works - but it reads everytthing 

% tic 
% text = fileread(tdfile); 
% rawtime = regexp(text,'(?<="timestamp":{"seconds":)[0-9]+','match'); 
% 
% timeStart = datetime(datevec(str2double(rawtime{1})./86400 + ...
%             datenum(2000,3,1,0,0,0))); % medtronic time - LSB is seconds
% 
% timeEnd = datetime(datevec(str2double(rawtime{end})./86400 + ...
%             datenum(2000,3,1,0,0,0))); % medtronic time - LSB is seconds
% toc



end