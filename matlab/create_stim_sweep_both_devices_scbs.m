function create_stim_sweep_both_devices_scbs()
clc;
%% params to set 
patient         = 'RCS07'; % patient plotting stim sweep for 
groupUse        = 'C';    % group to use 

% RIGHT: 
maxAmp_R        = 2.0; % max amp for the stim sweep on the R side 
openLoopR       = 1.8; % open loop level for the stim sweep on the R side (often lower) 
% LEFT 
maxAmp_L        = 2.0; % max amp for the stim sweep on the L side 
openLoopL       = 1.8; % open loop level for the stim sweep on the L side (often lower) 

stimfreq        = 130.2; % assume same stim frequnecy through out stim titration; 
pulsewidth      = 60; % assume same stim frequnecy through out stim titration; 
timesInBetween  = 30; % time in seconds to go back to zero in between each stim level 
timRunInSeconds = 45; % time to run each "primary" sweep 

evMarkerDelay   = 5; % event marker dealy in seconds 
%% create the psuedo random sequence
varNames = {'maxAmp_R','maxAmp_L'};
for sss = 1:2
    minamp = 0;
    inclectionpoint = 1.0;
    maxamp = eval(varNames{sss});
    if maxamp < inclectionpoint
        inclectionpoint = maxamp;
    end
    inc1    = 0.3;
    inc2    = 0.2;
    
    series = [minamp:inc1:inclectionpoint  inclectionpoint+inc2:inc2: maxamp];
    if series(end) ~= maxamp
        series = [series maxamp];
    end
    
    % create 5e3 random sequences and compute the absolute difference
    for i = 1:5e3
        rng(i);
        meanseries(i) = mean(abs(diff(series(randperm(length(series))))));
    end
    [maxdiffm idx] = max(meanseries);
    
    rng(idx);
    seriesuse = series(randperm(length(series)));
    mean(abs(diff(seriesuse)));
    
    switch  sss 
        case 1  % R side 
            ampsUseR = seriesuse; 
            fprintf('R: %0.2f\n',seriesuse);
        case 2  % L side 
            ampsUseL = seriesuse; 
            fprintf('L: %0.2f\n',seriesuse);
    end
end

%% prepare the stim sweep table 
% prepare the stim sweep table that will be written down to .json 
% verify that one side is in "open loop" while the other is undergoing stim
% sweep and vice versa 
stimSweep = table();
cnt = 1; 
% LEFT SIDE STIM SEEP RIGHT OPEN LOOP 
for i = 1:length(ampsUseL)  
    % left side
    stimSweep.rate_Left(cnt) = stimfreq;
    stimSweep.Program_Left(cnt) = 0;
    stimSweep.AmpInmA_Left(cnt) = ampsUseL(i);
    stimSweep.Pw_Left(cnt) = pulsewidth;
    % right side
    stimSweep.rate_Right(cnt) = stimfreq;
    stimSweep.Program_Right(cnt) = 0;
    stimSweep.AmpInmA_Right(cnt) = openLoopR;
    stimSweep.Pw_Right(cnt) = pulsewidth;
    
    stimSweep.TimeToRun(cnt) = timRunInSeconds;
    cnt = cnt  +1;
    % add a 12 second washout period (to allow for the 5 second delay not to
    % "run into each other"
    % left side
    stimSweep.rate_Left(cnt) = stimfreq;
    stimSweep.Program_Left(cnt) = 0;
    stimSweep.AmpInmA_Left(cnt) = 0;
    stimSweep.Pw_Left(cnt) = pulsewidth;
    % right side
    stimSweep.rate_Right(cnt) = stimfreq;
    stimSweep.Program_Right(cnt) = 0;
    stimSweep.AmpInmA_Right(cnt) = openLoopR;
    stimSweep.Pw_Right(cnt) = pulsewidth;
    stimSweep.TimeToRun(cnt) = timesInBetween;
    cnt = cnt  +1;
end

% RIGHT SIDE STIM SEEP RIGHT OPEN LOOP 
for i = 1:length(ampsUseR)  
    % left side
    stimSweep.rate_Left(cnt) = stimfreq;
    stimSweep.Program_Left(cnt) = 0;
    stimSweep.AmpInmA_Left(cnt) = openLoopL;
    stimSweep.Pw_Left(cnt) = pulsewidth;
    % right side
    stimSweep.rate_Right(cnt) = stimfreq;
    stimSweep.Program_Right(cnt) = 0;
    stimSweep.AmpInmA_Right(cnt) = ampsUseR(i);
    stimSweep.Pw_Right(cnt) = pulsewidth;
    
    stimSweep.TimeToRun(cnt) = timRunInSeconds;
    cnt = cnt  +1;
    % add a 12 second washout period (to allow for the 5 second delay not to
    % "run into each other"
    % left side
    stimSweep.rate_Left(cnt) = stimfreq;
    stimSweep.Program_Left(cnt) = 0;
    stimSweep.AmpInmA_Left(cnt) = openLoopL;
    stimSweep.Pw_Left(cnt) = pulsewidth;
    % right side
    stimSweep.rate_Right(cnt) = stimfreq;
    stimSweep.Program_Right(cnt) = 0;
    stimSweep.AmpInmA_Right(cnt) = 0;
    stimSweep.Pw_Right(cnt) = pulsewidth;
    stimSweep.TimeToRun(cnt) = timesInBetween; 
    cnt = cnt  +1;
end
%% print  these results to a .json file 
outputfile = sprintf('stim_sweep_config_%s.json',patient);
fid = fopen(outputfile,'w+'); 

fprintf(fid,'{\n'); 
fprintf(fid,'\t"comment": "Each index is one run. So the first index of each matrix contains the parameters for the first run and the second is the second run and so on. AmpInMa - is the amplitude in milliamps DBS will go to,  RateInHz is the frequency in Hz stimulate will be delivered at, PulseWidthInMicroSeconds is the pulse width for stimulation, TimeToRunInSeconds is the time to run each stimulation frequency, and EvenMarkerTimeInSeconds is the duration after stimulation command has given that even marker is written. This is done to account for stimulation ramp up time that is set by RLP and to allow for easy data analysis. CurrentIndex is the index to run next",\n');

% LEFT INS 
fprintf(fid,'\t"LeftINSOrUnilateral": {\n'); 
fprintf(fid,'\t\t"GroupToRunStimSweep": "%s",\n',groupUse);

% rate 
fprintf(fid,'\t\t"RateInHz":\t\t\t\t\t[');
for i = 1:size(stimSweep,1) 
    fprintf(fid,'%.2f', stimSweep.rate_Left(i));
    if i ~= size(stimSweep,1)
        fprintf(fid,',\t');
    else
        fprintf(fid,'],\n');
    end
end
% Program 
fprintf(fid,'\t\t"Program":\t\t\t\t\t[');
for i = 1:size(stimSweep,1) 
    fprintf(fid,'%d', stimSweep.Program_Left(i));
    if i ~= size(stimSweep,1)
        fprintf(fid,',\t');
    else
        fprintf(fid,'],\n');
    end
end
% Amp In Ma 
fprintf(fid,'\t\t"AmpInmA":\t\t\t\t\t[');
for i = 1:size(stimSweep,1) 
    fprintf(fid,'%.2f', stimSweep.AmpInmA_Left(i));
    if i ~= size(stimSweep,1)
        fprintf(fid,',\t');
    else
        fprintf(fid,'],\n');
    end
end
% pulse width  
fprintf(fid,'\t\t"PulseWidthInMicroSeconds":\t\t\t\t\t[');
for i = 1:size(stimSweep,1) 
    fprintf(fid,'%d', stimSweep.Pw_Left(i));
    if i ~= size(stimSweep,1)
        fprintf(fid,',\t');
    else
        fprintf(fid,']\n');
    end
end
fprintf(fid,'\t},\n'); 



% RIGHT INS 
fprintf(fid,'\t"RightINS": {\n'); 
fprintf(fid,'\t\t"GroupToRunStimSweep": "%s",\n',groupUse);

% rate 
fprintf(fid,'\t\t"RateInHz":\t\t\t\t\t[');
for i = 1:size(stimSweep,1) 
    fprintf(fid,'%.2f', stimSweep.rate_Right(i));
    if i ~= size(stimSweep,1)
        fprintf(fid,',\t');
    else
        fprintf(fid,'],\n');
    end
end
% Program 
fprintf(fid,'\t\t"Program":\t\t\t\t\t[');
for i = 1:size(stimSweep,1) 
    fprintf(fid,'%d', stimSweep.Program_Right(i));
    if i ~= size(stimSweep,1)
        fprintf(fid,',\t');
    else
        fprintf(fid,'],\n');
    end
end
% Amp In Ma 
fprintf(fid,'\t\t"AmpInmA":\t\t\t\t\t[');
for i = 1:size(stimSweep,1) 
    fprintf(fid,'%.2f', stimSweep.AmpInmA_Right(i));
    if i ~= size(stimSweep,1)
        fprintf(fid,',\t');
    else
        fprintf(fid,'],\n');
    end
end
% pulse width 
fprintf(fid,'\t\t"PulseWidthInMicroSeconds":\t\t\t\t\t[');
for i = 1:size(stimSweep,1) 
    fprintf(fid,'%d', stimSweep.Pw_Right(i));
    if i ~= size(stimSweep,1)
        fprintf(fid,',\t');
    else
        fprintf(fid,']\n');
    end
end
fprintf(fid,'\t},\n'); 

% TIME TO RUN IN SECONDS 
fprintf(fid,'\t"TimeToRunInSeconds":\t\t\t\t\t[');
for i = 1:size(stimSweep,1) 
    fprintf(fid,'%d', stimSweep.TimeToRun(i));
    if i ~= size(stimSweep,1)
        fprintf(fid,',\t');
    else
        fprintf(fid,'],\n');
    end
end

fprintf(fid,'\t"EventMarkerDelayTimeInSeconds":\t\t\t\t\t%d,\n',evMarkerDelay);
fprintf(fid,'\t"CurrentIndex":\t\t\t\t\t%d\n',0); % always start at zero 
fprintf(fid,'}\n');

% report total stim sweep time 
% total stim sweep time: 
clc;
sweepDuration = seconds(sum(stimSweep.TimeToRun));
sweepDuration.Format = 'mm:ss';
fprintf('stim sweep will run for %s\n',sweepDuration); 
fprintf('it has %d steps\n',size(stimSweep,1)); 
%%
%{
{
	"comment": "Each index is one run. So the first index of each matrix contains the parameters for the first run and the second is the second run and so on. AmpInMa - is the amplitude in milliamps DBS will go to,  RateInHz is the frequency in Hz stimulate will be delivered at, PulseWidthInMicroSeconds is the pulse width for stimulation, TimeToRunInSeconds is the time to run each stimulation frequency, and EvenMarkerTimeInSeconds is the duration after stimulation command has given that even marker is written. This is done to account for stimulation ramp up time that is set by RLP and to allow for easy data analysis. CurrentIndex is the index to run next",
	"LeftINSOrUnilateral": {
		"GroupToRunStimSweep": "C",
		"RateInHz":					[130.2,	130.2,	130.2,	130.2,	130.2,	130.2,	130.2,	130.2],
		"Program":					[0,		0,		0,		0,		0,		0,		0,		0],
		"AmpInmA": 					[1.2,	0.3,	1.5,	0.6,	1.8,	0,		2.1,	0.9],
		"PulseWidthInMicroSeconds": [60,	60,		60,		60,		60,		60,		60,		60],
	},
	"RightINS": {
		"GroupToRunStimSweep": "C",
		"RateInHz":					[130.2,	130.2,	130.2,	130.2,	130.2,	130.2,	130.2,	130.2],
		"Program":					[0,		0,		0,		0,		0,		0,		0,		0],
		"AmpInmA": 					[1.6,	1.6,	1.6,	1.6,	1.6,	1.6,	1.6,	1.6],
		"PulseWidthInMicroSeconds": [60,	60,		60,		60,		60,		60,		60,		60],
	},
	"TimeToRunInSeconds": 			[40, 	40, 	40,		40,		40,		40,		40,		40],
	"EventMarkerDelayTimeInSeconds": 5,
	"CurrentIndex": 0
}
%}
%%
%}

end