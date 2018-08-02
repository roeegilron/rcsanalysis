function outdat = populateTimeStamp(outdat,srate,filename)
%% function to populate time stamps according to INS with Unix style time 
%% 
start = tic;
[pn,fn] = fileparts(filename);
fid = fopen(fullfile(pn,[fn '-Packet-Loss-Report.txt']),'w+'); 
idxpackets = find(outdat.timestamp~=0); 
timestamps = datetime(datevec(outdat.timestamp(idxpackets)./86400 + datenum(2000,3,1,0,0,0))); % medtronic time - LSB is seconds 
% find abnormal packet gaps and report some states 
idxlarge = find(seconds(diff(timestamps)) > 2^16/1e4);
fprintf(fid,'approximate recording length %s\n',timestamps(end)-timestamps(1));
fprintf(fid,'%d gaps larger than %.3f seconds found\n',sum(seconds(diff(timestamps)) > 2^16/1e4),2^16/1e4)

gapmode =  mode(timestamps( idxlarge+1) - timestamps( idxlarge));
gapmedian = median(timestamps( idxlarge+1) - timestamps( idxlarge));
maxgap = max(timestamps( idxlarge+1) - timestamps( idxlarge));
fprintf(fid,'gap mode %s, gap median %s, max gap %s\n',gapmode,gapmedian,maxgap);

pctlost = 1; 
isi = 1/srate; 
medTimeExpanded = zeros(size(outdat,1),1);
packTimes = zeros(size(timestamps,1));
endTimes  = NaT(size(timestamps,1),1);
endTimes.Format = 'dd-MMM-yyyy HH:mm:ss.SSS';

for p = 1:length(idxpackets)
    if p == 1 
        % for first packet, just assume medtronic time is correct 
        idxpopulate = idxpackets(p):-1:1;
        numpoints = length(idxpopulate);
        timeuse = outdat.timestamp(idxpackets(p));
        tmptime = datetime(datevec(timeuse./86400 + datenum(2000,3,1,0,0,0))); % medtronic time - LSB is seconds
        % cast to microseconds
        datstr = [datestr(tmptime) '.000'];
        endTime = datetime(datstr,'InputFormat','dd-MMM-yyyy HH:mm:ss.SSS'); % include microseconds
        endTime.Format = 'dd-MMM-yyyy HH:mm:ss.SSS';
        packTimes(p) = (numpoints-1)/srate;
        endTimes(p) = endTime; 
    else
        % for all other packets, implement folowing algorithem 
        idxpopulate = idxpackets(p):-1:idxpackets(p-1)+1;
        numpoints = length(idxpopulate);
        if timestamps(p)-timestamps(p-1) > 2^16/1e4 % if gap is larger than 6.55 seconds don't incerment from last packet 
            timeuse = outdat.timestamp(idxpackets(p));
            tmptime = datetime(datevec(timeuse./86400 + datenum(2000,3,1,0,0,0))); % medtronic time - LSB is seconds
            % cast to microseconds
            datstr = [datestr(tmptime) '.000'];
            endTime = datetime(datstr,'InputFormat','dd-MMM-yyyy HH:mm:ss.SSS'); % include microseconds
            endTime.Format = 'dd-MMM-yyyy HH:mm:ss.SSS';
            endTimes(p) = endTime;
        else 
            % if gap is smaller than 6.55 seconds verify packet time with systemTick clock 
            % and increment from last end time 
            difftime = outdat.systemTick(idxpackets(p))-outdat.systemTick(idxpackets(p-1));
            if p == 2 
                packtime = mod(difftime,2^16) / 1e4 + 1/srate;% packet time in seconds 
            else
                packtime = mod(difftime,2^16) / 1e4 ;% packet time in seconds
            end
            packTimes(p) = packtime;
            
            if (packtime - numpoints/srate) <= isi 
                secondsToAdd = seconds(packtime ) ;
                % cast to microseconds
                endTime = endTimes(p-1) + secondsToAdd;
                endTimes(p) = endTime; 
            else 
                % we lost some some time, use systemTick to find out how much data was lost. 
                pctlen(pctlost)  = abs(packtime - numpoints/srate);
                % increment time use by difference between packtime and
                % numpoints / srate 
                pctlost = pctlost + 1; 
                secondsToAdd =  seconds(packtime );
                % cast to microseconds
                endTime = endTimes(p-1) + secondsToAdd;
                endTimes(p) = endTime;             
            end
        end
    end
    % populate each sample with a time stamp 
    timevec = endTime: - seconds(1/srate): (endTime- seconds((numpoints-1)/srate)); 
    medTimeExpanded(idxpopulate) = datenum(timevec); % use Matlab datenum, at end cast back to str 
end
%% add data to packet loss report
fprintf(fid,'\n\n'); 
fprintf(fid,'%d packet loss events under 6.55 seoncds occured \n', length(pctlen));
fprintf(fid,'%.4f seconds average packet loss  \n', mean(pctlen));
fprintf(fid,'%.4f seconds mode packet loss \n', mode(pctlen));
fprintf(fid,'%.4f seconds median packet loss  \n', median(pctlen));
fprintf(fid,'%.4f seconds max packet loss \n', max(pctlen));
fprintf(fid,'%.4f seconds min packet loss \n', min(pctlen));
%% convert derived data to string and add to table 
medTimeStr = datetime(datevec(medTimeExpanded),'TimeZone','America/Chicago');
medTimeStr.Format = 'dd-MMM-yyyy HH:mm:ss.SSS';
ncol = size(outdat,2);
outdat.derivedTimes = medTimeStr;
outdat.Properties.VariableDescriptions{ncol+1} = 'derived time stamps from systemTick and timestamp variables'; 
fprintf('finished deriving time in %.2f\n',toc(start));
%% left over 
% uxtime = [TDdat.TimeDomainData.PacketRxUnixTime];
% each increment of of systemTime by +1 is extra 0.1 mili seconds 

% dtnums = datenum(uxtime./86400./1000 + datenum(1970,1,1))';
% datetime(datevec( dtnums(end)),'TimeZone','America/Chicago'); 

% time - PacketGenTime is time in miliseconds backstamped to where it in UTC since Jan 1 1970. 
% this is when it hit the bluetooth on computer 
% systemTick ? INS clock-driven tick counter, 16bits, LSB is 100microseconds, (highly accurate, high resolution, rolls over)
% timestamp ? INS clock-driven time, LSB is seconds (highly accurate, low resolution, does not roll over)
% PacketGenTime ? API estimate of when the data packet was created on the INS within the PC clock domain. Estimate created by using results of latest latency check (one is done at system initialization, but can re-perform whenever you want) and time sync streaming. Potentially useful for syncing with other sensors or devices by bringing things into the PC clock domain, but is only accurate within 50ms give or take.
% PacketRxUnixTime ? PC clock-driven time when the packet was received via Bluetooth, as accurate as a C# DateTime.now (10-20ms)
% SampleRate ? defined in HTML doc as enum TdSampleRates: 0x00 is 250Hz, 0x01 is 500Hz, 0x02 is 1000Hz, 0xF0 is disabled



%% medtrnic time timestamp
% tsmps = outdat.timestamp(outdat.timestamp~=0);
% mdtnums= datenum(tsmps./86400 + datenum(2000,3,1,0,0,0));
% datetime(datevec( mdtnums(end)),'TimeZone','America/Chicago');
end