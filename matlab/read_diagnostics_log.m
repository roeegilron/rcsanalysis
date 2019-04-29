function read_diagnostics_log(fn)
rawdat = deserializeJSON(fn);
for i = 1:length(rawdat)
    
    fldnms = fieldnames(rawdat{i});
    
    if strcmp(fldnms{2},'LogEntry')
        tmpfnm = fieldnames(rawdat{i}.LogEntry.payload);
        if sum(cellfun(@(x) any(strfind(x,'eventId')),tmpfnm))
            idx(i,1) = 1; 
            idx(i,2) = rawdat{i}.LogEntry.payload.eventId; 
        else
            idx(i,1) = 0;
            idx(i,2) = 0;
        end
    end    
end

eventsKeep = [17 18 24 26];

fprintf('unique event ids:\n\n')
fprintf('%d\n',unique(idx(:,2)))

fprintf('keeping ids:\n\n')
fprintf('%d\n',eventsKeep)

% 17 rlp session start 
% 18 therapy on off 
% 24 ptm session (recharge start) 
% 26 group change 
keepIdx  = zeros(size(idx,1),1); 
for e = 1:length(eventsKeep)
    keepIdx = keepIdx | eventsKeep(e)==idx(:,2);
end

logKeep = rawdat(keepIdx); 

dat = table(); 
for i = 1:length(logKeep)
    fldnms = fieldnames(logKeep{i});
    dat.RecordInfo{i} = logKeep{i}.RecordInfo;
    dat.Type{i}       = fldnms{2};
    dat.eventId(i)    = logKeep{i}.LogEntry.payload.eventId;
    % time
    rawsec         = logKeep{i}.LogEntry.header.entryTimestamp.seconds;
    timestamp = datetime(datevec(rawsec./86400 + datenum(2000,3,1,0,0,0))); % medtronic time - LSB is seconds
    dat.time(i)       = timestamp;
    fnmstmp = fieldnames(logKeep{i}.LogEntry.payload.entryPayload);
    dat.types{i}      =    fnmstmp{2};
    dat.value(i)      = logKeep{i}.LogEntry.payload.entryPayload.(fnmstmp{2});
    switch dat.eventId(i)
        case 17 % rlp session start end 
            if dat.value(i)
                struse = 'RLP session started';
            else
                struse = 'RLP session ended';
            end
        case 18 % therapy on / off 
            if dat.value(i)
                struse = 'stim on';
            else
                struse = 'stim off';
            end
        case 24 % ptm session start / end 
             if dat.value(i)
                struse = 'Recharge (PTM) session started';
            else
                struse = 'Recharge (PTM) session ended';
            end
        case 26 % group change 
            switch dat.value(i)
                case 0
                    grp = 'A';
                case 1 
                    grp = 'B';
                case 2 
                    grp = 'C';
                case 3 
                    grp = 'D';
            end
            struse = sprintf('group %s active',grp); 
    end
    dat.humanStr{i} = struse; 
end

               

end