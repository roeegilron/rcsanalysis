function load_and_save_alligned_data_in_folder(dirname)

[outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerOut,adaptiveTable] =  MAIN_load_rcs_data_from_folder(dirname);

% get rid of extra comments field 
eventTable = eventTable(~strcmp(eventTable.EventType,'extra_comments'),:);
eventTable = eventTable(~strcmp(eventTable.EventType,'conditions'),:);
% get times for power data 
timestamps   = powerOut.powerTable.timestamp;
systemTicks  = powerOut.powerTable.systemTick;
rxUnixTimes  = powerOut.powerTable.PacketRxUnixTime;

timesOut = getTimesFromPowerOrAdaptive(timestamps,systemTicks,rxUnixTimes);
powerOut.powerTable = powerOut.powerTable(2:end,:); % get rid of first idx 
powerOut.powerTable.derivedTimes = timesOut;



% get times for adaptive data  
timestamps   = adaptiveTable.timestamp;
systemTicks  = adaptiveTable.systemTick;
rxUnixTimes  = adaptiveTable.PacketRxUnixTime;

timesOut = getTimesFromPowerOrAdaptive(timestamps,systemTicks,rxUnixTimes);
adaptiveTable = adaptiveTable(2:end,:); % get rid of first idx 
adaptiveTable.derivedTimes = timesOut;

% load config files 
ff = findFilesBVQX(dirname,'*adaptive.json');

if ~isempty(ff) 
    for f = 1:length(ff) 
        adaptiveStruc(f) = deserializeJSON(ff{f});
        % find sense file and load that 
        [pn,fn] = fileparts(ff{f});
        senseFile = findFilesBVQX(dirname,[fn(1:3) '*' '_sense.json']);
        senseStruc(f) = deserializeJSON(senseFile{1});
    end
end

fid = fopen(fullfile(pn,'adaptive_log.txt'),'w+');
% print start time 
t = eventTable.sessionTime(1);
t.Format = 'dd-MMM-yyyy HH:mm';
fprintf(fid,'%s start time\n',t); 

[pn,fn] = fileparts(dirname);
[pn,session] = fileparts(pn);
[pn,patient] = fileparts(pn);
fprintf(fid,'%s\n',patient);
fprintf(fid,'%s\n',session);
fprintf(fid,'\n'); 

fprintf('embedded files run:\n\n'); 
idxEmbedded = find( (cellfun(@(x) any(strfind(x,'Embedded')),eventTable.EventType) & ...
                     cellfun(@(x) any(strfind(x,'Number:')),eventTable.EventType))...
                    ==1); % start idx 
idxEmbeddedEnd = zeros(length(idxEmbedded),1);
cnt = 1;
for i = 1:length(idxEmbedded)
    adaptiveInfo(i).sessionStarTime = t;
    adaptiveInfo(i).patient = patient; 
    adaptiveInfo(i).session = session; 
    fprintf(fid,'[%0.3d]\t',i);
    % find when either next embedded start or a change to another group
    % happened (8 is next embedded, 1 = stim on, 2 = stim off or 3 is
    % change to another group - so anything under or equal to 3)
    eventTemp = eventTable(idxEmbedded(i)+1:end,:);
    embeddedEnd = 0; 
    idxStart = idxEmbedded(i);
    
    breakWhile = 0;
    while ~embeddedEnd
        if idxStart == size(eventTable,1) % at end
            idxEmbeddedEnd(cnt) = idxStart;
            breakWhile = 1;
        end
        if breakWhile ==1
            break;
        end
       idxStart = idxStart + 1; 
       eventStr = eventTable.EventType(idxStart);
       if isempty(eventStr{1})
           code = 0;
       else
           code = str2num(eventStr{1}(1:3));
       end
       if code <=3 || code ==8
           embeddedEnd = 1; 
           idxEmbeddedEnd(cnt) = idxStart; 
       else
           % do nothing 
       end
       
    end
    startTime = eventTable.UnixOnsetTime(idxEmbedded(i));
    endTime = eventTable.UnixOnsetTime(idxEmbeddedEnd(i));
    adaptiveInfo(i).startTime = startTime;
    adaptiveInfo(i).endTime = endTime;
    adaptiveInfo(i).duration = endTime - startTime; 
    fprintf(fid,'%s duration (%s - %s)\n',...
        endTime - startTime,startTime,endTime)
    cnt = cnt +1; 
end
fprintf(fid,'\n'); 
embeddedStartEndTimes.EmbeddedStart = eventTable(idxEmbedded,:);
embeddedStartEndTimes.EmbeddedEnd = eventTable(idxEmbeddedEnd,:);

% print summary of adpative elements tried 
for i = 1:length(adaptiveStruc)
    fnms = fieldnames(adaptiveStruc(i).Detection.LD0.Inputs);
    for f = 1:length(fnms)
        cout(f) = adaptiveStruc(i).Detection.LD0.Inputs.(fnms{f});
        senseStruc(i).Sense.PowerBands(cout).ChannelPowerBand
    end
    fprintf(fid,'%0.3d - adaptive inputs:\n\n');
    fprintf(fid,'____________________________\n');
    fprintf(fid,'____________________________\n');
    
    
    bandsUsed = powerOut.bands(i).powerBandInHz{cout};
    tdchannelused = str2num(fnms{cout}(3))+1; % get time domain channel used 
    tdChanelUsed = outRec(i).tdData(tdchannelused).chanFullStr; 
    adaptiveInfo(i).tdChannelUsed = tdchannelused;
    adaptiveInfo(i).tdChannelInfo = outRec(i).tdData(tdchannelused).chanFullStr;
    adaptiveInfo(i).bandsUsed = bandsUsed;
    adaptiveInfo(i).bandsUsedIdx = find(cout==1);
    adaptiveInfo(i).bandsUsedName = sprintf('Band%d',find(cout==1));
    fprintf(fid,'band used:\n'); 
    fprintf(fid,'%s\n',tdChanelUsed);
    fprintf(fid,'%s\n',bandsUsed);
    fprintf(fid,'\n');
    fprintf(fid,'adaptive and fft settings:\n'); 
    fprintf(fid,'\n');
    fieldsReport = {'B0','B1','UpdateRate','OnsetDuration','TerminationDuration','StateChangeBlankingUponStateChange'};
    fieldnamesUse   = {'threshold 1','threshold 2','update rate','onset duration','termination duration','state change blanking'};
    for f = 1:length(fieldsReport)
        val = adaptiveStruc(i).Detection.LD0.(fieldsReport{f});
        fprintf(fid,'%s\t\t\t\t%d\t\n',fieldnamesUse{f},val);
        adaptiveInfo(i).(fieldsReport{f}) = val;
    end  
    fprintf(fid,'\n');
    % program 0 settings 
    fprintf(fid,'program 0 settings:\n'); 
    fprintf(fid,'\n'); 
    prog0 = adaptiveStruc(i).Adaptive.Program0;
    fprintf(fid,'rate:\t %.2fHz\n',prog0.RateTargetInHz);
    adaptiveInfo(i).stimRate = prog0.RateTargetInHz;
    fprintf(fid,'State 0 target:\t %.1f mA\n',prog0.State0AmpInMilliamps);
    adaptiveInfo(i).State0AmpInMilliamps = prog0.State0AmpInMilliamps;
    fprintf(fid,'State 1 target:\t %.1f mA\n',prog0.State1AmpInMilliamps);
    adaptiveInfo(i).State1AmpInMilliamps = prog0.State1AmpInMilliamps;
    fprintf(fid,'State 2 target:\t %.1f mA\n',prog0.State2AmpInMilliamps);
    adaptiveInfo(i).State2AmpInMilliamps = prog0.State2AmpInMilliamps;
    rampRatePerSec = (prog0.RiseTimes*10)/655360;
    fprintf(fid,'rise ramp rate:\t %.2f mA / second\n',rampRatePerSec);
    adaptiveInfo(i).rampUpRatePerSec = rampRatePerSec;
    rampRatePerSec = (prog0.FallTimes*10)/655360;
    fprintf(fid,'fall ramp rate:\t %.2f mA / second\n',rampRatePerSec);
    adaptiveInfo(i).rampDownRatePerSec = rampRatePerSec;
    % sense settings 
    fprintf(fid,'\n'); 
    fprintf(fid,'FFT settings:\n'); 
    fprintf(fid,'\n'); 
    fprintf(fid,'FFT interval:\t %d ms\n',senseStruc(i).Sense.FFT.FftInterval);
    adaptiveInfo(i).FftInterval = senseStruc(i).Sense.FFT.FftInterval;
    fprintf(fid,'FFT size:\t %d points\n',senseStruc(i).Sense.FFT.FftSize);
    adaptiveInfo(i).Fftsize = senseStruc(i).Sense.FFT.FftSize;
    
    fftsize = senseStruc(i).Sense.FFT.FftSize; 
    fftinteval = senseStruc(i).Sense.FFT.FftInterval;
    updateRate = adaptiveStruc(i).Detection.LD0.UpdateRate;
    adaptiveInfo(i).UpdateRate = updateRate;
    sr = senseStruc(i).Sense.TDSampleRate; 
    adaptiveInfo(i).SampleRate = sr;
    fprintf(fid,'each FFT represents %d ms of data (fft size %d sr %d Hz)\n',...
        ceil((fftsize/sr).*1000), fftsize,sr);
    fprintf(fid,'%d ffts are averaged - %d ms of data before being input to LD\n',updateRate,ceil((fftsize/sr).*1000)*updateRate);    

    if fftinteval >=  (ceil((fftsize/sr).*1000)*updateRate)
        fprintf(fid,'%% overlap is %.2f%%\n',...
            0);
    else
        fprintf(fid,'%% overlap is %.2f%%\n',...
            1-(fftinteval / (ceil((fftsize/sr).*1000)*updateRate))  );
    end
    
end
% this assuems just one LD (LD0) 
% this alos assumes just one power channel 

fnmsave = fullfile(dirname,'all_data_alligned.mat'); 
save(fnmsave,'outdatcomplete','outdatcompleteAcc','outRec',...
    'eventTable','powerOut','adaptiveTable','adaptiveStruc','senseStruc','embeddedStartEndTimes','adaptiveInfo');


end

function timesOut = getTimesFromPowerOrAdaptive(timestamps,systemTicks,rxUnixTimes)

idxpackets = find(timestamps~=0); 
timestamps = datetime(datevec(timestamps(idxpackets)./86400 + datenum(2000,3,1,0,0,0))); % medtronic time - LSB is seconds 


endTimes  = NaT(size(timestamps,1), 1) - NaT(1);
endTimes.Format = 'hh:mm:ss.SSS'; % add microseconds 
% 1 figure out different isis 
% isis = 1./srates;

% 1.5 start with gaps that are smaller than 6.553 seconds 
% if gap is smaller than 6.55 seconds verify packet time with systemTick clock
% and increment from last end time
idxsmaller = [0 ; diff(timestamps) <= seconds(2^16/1e4)]; % add zero at start since using diff
% find out what value to give based on
% packet count
idxInNums = find(idxsmaller==1);
preIdxInNums = idxInNums-1;
difftime = systemTicks(idxpackets(idxInNums))-systemTicks(idxpackets(preIdxInNums));
packtime = mod(difftime,2^16) / 1e4 ;% packet time in seconds
secondsToAdd = seconds(packtime ) ;
endTimes(idxInNums) = secondsToAdd;   
 
% 2. find gaps larger than 6.553 seconds and populate- this has to come
% after all the easy stuff 
idxlarger = [0 ; diff(timestamps) > seconds(2^16/1e4)];
% find out what value to give based on
% packet count
idxInNums = find(idxlarger==1); 
preIdxInNums = idxInNums-1; 
gapLenInSeconds = timestamps(idxInNums)-timestamps(preIdxInNums);
numberOfSixSecChunks = seconds(gapLenInSeconds)/(2^16/1e4);
systemTickPreviousPacket = systemTicks(idxpackets(preIdxInNums));
systemTickCurrentPacket = systemTicks(idxpackets(idxInNums));
exactGapTime = seconds(floor(numberOfSixSecChunks)*floor(2^16/1e4) - ...
    systemTickPreviousPacket/1e4 + ...
    systemTickCurrentPacket/1e4);
endTimes(idxInNums) = exactGapTime;

% get rid of the first packet;  
endTimes = endTimes(2:end); 
% set starting point based on computer time 
firstTimeIdx = find(rxUnixTimes~=0,1);
timeOfLastSampleInFirstPacket = datetime(rxUnixTimes(firstTimeIdx)/1000,...
    'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
startTime = timeOfLastSampleInFirstPacket - endTimes(1); 
timesOut = startTime + cumsum(endTimes); 
end