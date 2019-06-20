%%
% rcs 02 
res = readAdaptiveJson('/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/v09_adaptive/adaptive_day_2/lte/StarrLab/RCS02R/Session1559757210876/DeviceNPC700404H/AdaptiveLog.json'); 
% rcs 01 
res = readAdaptiveJson('/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v19_adaptive_month5_day2/rcs_data/Session1553628169628/DeviceNPC700395H/AdaptiveLog.json');
%%

cur = res.adaptive.CurrentProgramAmplitudesInMilliamps(1,:); 
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
timesUseTruc     = timesUse(2:end); 
curruntInMaTrunc = curruntInMa(2:end); 

plot(timesUseTruc,curruntInMaTrunc);
totaltime = timesUseTruc(end) - timesUseTruc(1); 
secTime   = seconds(totaltime); 

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