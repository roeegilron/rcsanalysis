%%
% rcs 02 
% res = readAdaptiveJson('/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/v09_adaptive/adaptive_day_2/lte/StarrLab/RCS02R/Session1559757210876/DeviceNPC700404H/AdaptiveLog.json'); 
% rcs 01 
% res = readAdaptiveJson('/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v19_adaptive_month5_day2/rcs_data/Session1553628169628/DeviceNPC700395H/AdaptiveLog.json');
% rcs 05 
res = readAdaptiveJson('/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS05/v08_RCS05 4 Month/adaptive_day_2/rcsdata/RCS05R/Session1578692912450/DeviceNPC700415H/AdaptiveLog.json');
%%

cur = res.adaptive.CurrentProgramAmplitudesInMilliamps(1,:); 
cur = res.adaptive.CurrentProgramAmplitudesInMilliamps';
cur = cur(:,1)';
timestamps = datetime(datevec(res.timing.timestamp./86400 + datenum(2000,3,1,0,0,0))); % medtronic time - LSB is seconds
uxtimes = datetime(res.timing.PacketGenTime/1000,...
    'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
% rcs 02 
idxuse = [3199:3444]; % since there is 6Hz pulse here, have start end time
% rcs 01 
idxuse = [1:21128]; % since there is 6Hz pulse here, have start end time


tss = res.timing.timestamp;
figure; 
curruntInMa = cur(idxuse);
timesUse    = uxtimes(idxuse); 
% subtract the first value in time used 
% so have diff time for each current point '
diffsUse         = seconds(diff(timesUse));
timesUseTruc     = timesUse(20:end-20); 
curruntInMaTrunc = curruntInMa(20:end-20); 

figure;
plot(timesUseTruc,curruntInMaTrunc,'LineWidth',2,'Color','b');
totaltime = timesUseTruc(end) - timesUseTruc(1); 
secTime   = seconds(totaltime); 

%% new way of doing things:
dirname = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS05/v08_RCS05 4 Month/adaptive_day_2/rcsdata/RCS05R/Session1578692912450/DeviceNPC700415H';
fnmload = fullfile(dirname,'all_data_alligned.mat'); 
if ~exist(fnmload,'file')
    load_and_save_alligned_data_in_folder(dirname);
    load(fnmload,'outdatcomplete','outdatcompleteAcc','outRec',...
    'eventTable','powerOut','adaptiveTable','adaptiveStruc','senseStruc','embeddedStartEndTimes','adaptiveInfo');
else
    load(fnmload,'outdatcomplete','outdatcompleteAcc','outRec',...
    'eventTable','powerOut','adaptiveTable','adaptiveStruc','senseStruc','embeddedStartEndTimes','adaptiveInfo');
end
% find difference from unix time 
idxTimeCompare = find(outdatcomplete.PacketRxUnixTime~=0,1);
packRxTimeRaw  = outdatcomplete.PacketRxUnixTime(idxTimeCompare); 
packtRxTime    =  datetime(packRxTimeRaw/1000,...
            'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
derivedTime    = outdatcomplete.derivedTimes(idxTimeCompare); 
timeDiff       = derivedTime - packtRxTime;
deltaUse       = seconds(20); 
startTimes = embeddedStartEndTimes.EmbeddedStart.UnixOnsetTime + timeDiff + deltaUse; 
endTimes = embeddedStartEndTimes.EmbeddedEnd.UnixOnsetTime + timeDiff - deltaUse; 
dur      = endTimes - startTimes;
% only consider adaptive files over 30 seconds 
startTimes = startTimes(dur > seconds(30));
endTimes = endTimes(dur > seconds(30));
e = 8; 
secsAdaptive = adaptiveTable.derivedTimes;
idxuseAdaptive = secsAdaptive >= startTimes(e) & secsAdaptive <= endTimes(e);
secsAdaptive = secsAdaptive(idxuseAdaptive);
state = adaptiveTable.CurrentAdaptiveState(idxuseAdaptive);
detector = adaptiveTable.LD0_output(idxuseAdaptive);
highThresh = adaptiveTable.LD0_highThreshold(idxuseAdaptive);
lowThresh = adaptiveTable.LD0_lowThreshold(idxuseAdaptive);
current   = adaptiveTable.CurrentProgramAmplitudesInMilliamps(idxuseAdaptive);
curruntInMaTrunc = current;
%% 


%% rcs 07 
% have issue with opening up the adaptive file 
% have to do it with medtornic code 
% had to open this with medtronic plotting tools 
load('/Users/roee/Documents/Adaptive Visit 1/RCS Data/RCS07R/Session1582321705380/DeviceNPC700403H/adatpive_adata_opened_medtronic_code.mat');
load('/Users/roee/Documents/Adaptive Visit 1/RCS Data/RCS07R/Session1582321705380/DeviceNPC700403H/EventLog.mat');
load('/Users/roee/Documents/Adaptive Visit 1/RCS Data/RCS07R/Session1582321705380/DeviceNPC700403H/RawDataTD.mat');
idxuse = tvec > 2109; 
tsecs = outdatcomplete.derivedTimes - outdatcomplete.derivedTimes(1);
tsecs = seconds(tsecs); 
idxustd = tsecs > 2109;
timeuse = outdatcomplete.derivedTimes(idxustd);
fprintf('start %s\n',timeuse(1));
fprintf('stop %s\n',timeuse(end));
curruntInMaTrunc = ProgramAmps(1,idxuse);

%%




% rcs 02 
pw = 60; % pulse width
f  = 130.2;% frequency (hz) 
r  = 1913; % impedence 
openloopCur = 2.1; % in mili amps. 

% rcs 01 
pw = 100; % pulse width
f  = 160.3;% frequency (hz) 
r  = 1570; % impedence 
openloopCur = 2.5; % in mili amps.

% rcs 05
pw = 60; % pulse width
f  = 130.2;% frequency (hz) 
r  = 1378; % impedence 
openloopCur = 1.7; % in mili amps.

% rcs 07 
pw = 60; % pulse width
f  = 130.2;% frequency (hz) 
r  = 1730; % taking from 1 month visit can't find anything else 
openloopCur = 2; % in mili amps.

% total TEED per second adaptive 
% previous computation 
% curSquaredNormalizedByTime = sum( (curruntInMaTrunc.^2) ./ diffsUse ); 
% TEED     = curSquaredNormalizedByTime * f * pw * r; 
% curruntInMaOpenLoop = repmat(openloopCur, length(curruntInMaTrunc),1);
% curSquaredNormalizedByTimeOpenLoop = sum( (curruntInMaOpenLoop'.^2) ./ diffsUse ); 
% TEEDopenLoop     = curSquaredNormalizedByTimeOpenLoop * f * pw * r; 

% current 
meanCurrent = mean(curruntInMaTrunc).^2;
TEED     = (meanCurrent * f * pw) / r; 
% total teed if were in opel loop eq. time 
meanCurrent = openloopCur.^2;
TEEDopenLoop     = (meanCurrent * f * pw) / r; 



ratioTEED  = TEED/TEEDopenLoop;

fprintf('closed loop ran for %s\n',totaltime); 
fprintf('TEED closed loop\t = %.15f\n',TEED);
fprintf('TEED open loop\t = %.15f\n',TEEDopenLoop);
fprintf('ratio between closed loop to open loop = %.3f\n',ratioTEED); 