function flas_log = read_flas_logs_rcs()
filename = '/Users/roee/Downloads/RCS02 Embedded log files/RIGHT Event Log.txt';
% filename = '/Users/roee/Downloads/RCS06 Embedded Logs 6/Right Event Logs.txt';
[pn,fn,ext] = fileparts(filename);
%%
fid=fopen(filename);
inblock = 0;

% search flags: 
RechargeSesson = 0; 
TherapyStatus = 0; 
ActiveDeviceChanged = 0; 

eventsFound = table();
eventcnt = 1;

%     {'ActiveDeviceChanged'         }
%     {'AdaptiveTherapyStatusChanged'}
%     {'ClockChanged'                }
%     {'CpSession'                   }
%     {'NonSessionRecharge'          }
%     {'RechargeSesson'              }
%     {'TherapyStatus'               }
% 
    
while ~feof(fid)
    tline = fgetl(fid); 
    % insert desired processing here; just display the data here for example
    % check if in block 
    
%     fprintf('%s\n',tline);
    
    if any(strfind(tline,'LogEntry.Header'))
        inblock = 1; 
    end
    if inblock & isempty(tline)
        inblock = 0;
    end
    
    % get time of event 
    if inblock & any(strfind(tline,'DateTime'))
        stridx = strfind(tline,'DateTime = ');
        time_event = datetime(tline(41:end));
    end
    
    % find event ID's 
    if inblock & any(strfind(tline,'CommonLogPayload`1.EventId'))
        idxequal = strfind(tline,'(');
        eventType = tline(idxequal+1:end-1);
        eventsFound.type{eventcnt} = eventType;
        eventsFound.time(eventcnt) = time_event;
        eventcnt = eventcnt + 1;
       if any(strfind(tline,'RechargeSesson'))
       end
       if any(strfind(tline,'TherapyStatus'))
       end
       if any(strfind(tline,'ActiveDeviceChanged'))
           ActiveDeviceChanged = 1; 
       end
    end
    
    % get specific device flags 
    if ActiveDeviceChanged 
        if any(strfind(tline,'TherapyActiveGroupChangedEventLogEntry.NewGroup'))
            ActiveDeviceChanged = 0;
            eventsFound.type{eventcnt} = 'ActiveDeviceChanged'; 
            eventsFound.time(eventcnt) = time_event; 
            eventsFound.value(eventcnt) = str2num(tline(end-1)); 
            eventcnt = eventcnt + 1;
        end
    end
    
end
filewrite = fullfile(pn,[fn '.csv']);
writetable(eventsFound,filewrite)
fclose(fid);
end
