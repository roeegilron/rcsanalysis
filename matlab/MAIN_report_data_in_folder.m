function MAIN_report_data_in_folder(varargin)
if isempty(varargin)
    [dirname] = uigetdir(pwd,'choose a dir with rcs session folders');
else
    dirname  = varargin{1};
end

tblout = getDataBaseRCSdata(dirname);
% print out details about this to a text file in this directory
fid = fopen(fullfile(dirname,'recordingReport.txt'),'w+');

for t = 1:size(tblout,1)
    if ~isempty(tblout.startTime(t))
        % need to check if the table is comprised of cell arrays
        % in some cases empty sessions will force the table into a cell
        % array
        % in other cases if all sessions are valid it will format a a
        % matrix
        if iscell(tblout.duration)
            dur = tblout.duration{t};
            startTime = tblout.startTime{t};
            endTime = tblout.endTime{t};
            sessName = tblout.sessname{t};
        else
            dur = tblout.duration(t);
            startTime = tblout.startTime(t);
            endTime = tblout.endTime(t);
            sessName = tblout.sessname{t};
        end
        fprintf(fid,'%s (Duration)\n\t\t%s\t\t%s\t\t%s\n',...
            dur,startTime,endTime,sessName);
        
        et = tblout.eventData{t};
        if ~isempty(et)
            idxuse = ~cellfun(@(x) any(strfind(x, 'BatteryLevel')),et.EventType);
            if sum(idxuse) >=1
                etuse = et(idxuse,:);
                for e = 1:size(etuse,1)
                    fprintf(fid,'\t\t\t %s\n \t\t\t%s\n',...
                        etuse.EventSubType{e},etuse.EventType{e});
                end
                
            end
        end
    end
end


if iscell(tblout.duration)
    toSum = {tblout.duration(~cellfun(@(x) isempty(x),tblout.duration))};
    totalDuration = sum([toSum{1,1}{:}]);
else
    totalDuration = sum(tblout.duration);
end
fnmsave = fullfile(dirname,'database.mat');
save(fnmsave,'tblout','totalDuration');
return;

idxuse = strcmp(et.EventType,'INSLeftBatteryLevel') & ...
    ~isempty(et.EventSubType) & ...
    ~strcmp(et.EventSubType,'%');
etuse = et(idxuse,:);
percents = cellfun(@(x) str2num( strrep(x,'%','') ),etuse.EventSubType);
times = etuse.UnixOnsetTime;
figure;
plot(times,percents);
title('INS battery decline');
xlabel('Time');
ylabel('INS %');
set(gca,'FontSize',16);

end