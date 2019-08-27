function write_stim_sweep(fn)
% Writes a stim sweep configuration file to be used by adaptiveDBS program 
% Input: .CSV file formatted (see sample data in this repo for exmaple) 
% Output: .JSON file read by adaptive DBS progrma that will execute this
% stim sweep
%% 
stimraw = readtable(fn);
[pn,fnn,ext] = fileparts(fn);
outputfile = fullfile(pn,[fnn '.json']);
fid = fopen(outputfile,'w+'); 

fprintf(fid,'{\n'); 
fprintf(fid,'"comment": "Each index is one run. So the first index of each matrix contains the parameters for the first run and the second is the second run and so on. AmpInMa - is the amplitude in milliamps DBS will go to,  RateInHz is the frequency in Hz stimulate will be delivered at, PulseWidthInMicroSeconds is the pulse width for stimulation, GroupABCD is the group which will deliver stimulation, TimeToRunInSeconds is the time to run each stimulation frequency, and EvenMarkerTimeInSeconds is the duration after stimulation command has given that even marker is written. This is done to account for stimulation ramp up time that is set by RLP and to allow for easy data analysis.",\n');
% amptlidues 
fprintf(fid,'"AmpInmA":\t\t\t[');
for i = 1:size(stimraw.amp,1)
    if i == size(stimraw.amp,1)
        fprintf(fid,'%0.2f',stimraw.amp(i));
    else
        fprintf(fid,'%0.2f,\t',stimraw.amp(i));
    end
end
fprintf(fid,'],\n');

% rate 
fprintf(fid,'"RateInHz":\t\t\t[');
for i = 1:size(stimraw.rate,1)
    if i == size(stimraw.rate,1)
        fprintf(fid,'%0.2f',stimraw.rate(i));
    else
        fprintf(fid,'%0.2f,\t',stimraw.rate(i));
    end
end
fprintf(fid,'],\n');

% pulse width 
fprintf(fid,'"PulseWidthInMicroSeconds":\t\t\t[');
for i = 1:size(stimraw.pulsewidth,1)
    if i == size(stimraw.pulsewidth,1)
        fprintf(fid,'%d',stimraw.pulsewidth(i));
    else
        fprintf(fid,'%d,\t',stimraw.pulsewidth(i));
    end
end
fprintf(fid,'],\n');

% time to run  
fprintf(fid,'"TimeToRunInSeconds":\t\t\t[');
for i = 1:size(stimraw.timerun,1)
    if i == size(stimraw.timerun,1)
        fprintf(fid,'%d',stimraw.timerun(i));
    else
        fprintf(fid,'%0d,\t',stimraw.timerun(i));
    end
end
fprintf(fid,'],\n');

% group  
fprintf(fid,'"GroupABCD":\t\t\t[');
for i = 1:size(stimraw.group,1)
    if i == size(stimraw.group,1)
        fprintf(fid,'"%s"',stimraw.group{i});
    else
        fprintf(fid,'"%s",\t',stimraw.group{i});
    end
end
fprintf(fid,'],\n');

fprintf(fid,'"EventMarkerDelayTimeInSeconds": %d,\n',5);

fprintf(fid,'}\n'); 
fclose(fid); 