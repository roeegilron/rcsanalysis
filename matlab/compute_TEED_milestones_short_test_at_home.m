function compute_TEED_milestones_short_test_at_home()

%% RCS 02 May 14 2020 - R side only 
pw = 60; % pulse width
f  = 130.2;% frequency (hz) 
r  = 1913; % impedence measured june 5 2019 in adaptive session 
    
openloopCur = 2.7; % in mili amps.
curruntInMaTrunc = 2.72;
% states - 

% current 
meanCurrent = mean(curruntInMaTrunc).^2;
TEED     = (meanCurrent * f * pw) / r; 
% total teed if were in opel loop eq. time 
meanCurrent = openloopCur.^2;
TEEDopenLoop     = (meanCurrent * f * pw) / r; 


%% RCS 05 May 5 2020 
pw = 60; % pulse width
f  = 130.2;% frequency (hz) 
r  = 1298; % impedence measured jan 9 2020
    
openloopCur = 1.3; % in mili amps.
curruntInMaTrunc = 1.35;
% states - 

% current 
meanCurrent = mean(curruntInMaTrunc).^2;
TEED     = (meanCurrent * f * pw) / r; 
% total teed if were in opel loop eq. time 
meanCurrent = openloopCur.^2;
TEEDopenLoop     = (meanCurrent * f * pw) / r; 



%% RCS 06 May 6 2020 L side 
pw = 60; % pulse width
f  = 158.7;% frequency (hz) 
r  = 1405; % impedence measured april 17 2020
    
openloopCur = 1.4; % in mili amps.
curruntInMaTrunc = 1.35;
% states - 

% current 
meanCurrent = mean(curruntInMaTrunc).^2;
TEED     = (meanCurrent * f * pw) / r; 
% total teed if were in opel loop eq. time 
meanCurrent = openloopCur.^2;
TEEDopenLoop     = (meanCurrent * f * pw) / r; 


%% RCS 07 May 7 2020 L side 
pw = 60; % pulse width
f  = 130.2;% frequency (hz) 
r  = 1253; % impedence measured May 7 2020
    
openloopCur = 2.1; % in mili amps.
curruntInMaTrunc = 2.08;
% states - 

% current 
meanCurrent = mean(curruntInMaTrunc).^2;
TEED     = (meanCurrent * f * pw) / r; 
% total teed if were in opel loop eq. time 
meanCurrent = openloopCur.^2;
TEEDopenLoop     = (meanCurrent * f * pw) / r; 






ratioTEED  = TEED/TEEDopenLoop;

fprintf('TEED closed loop\t = %.15f\n',TEED);
fprintf('TEED open loop\t = %.15f\n',TEEDopenLoop);



end