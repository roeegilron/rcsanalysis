function srate = getSampleRate(srates)
%% input: matrix of sample rates of each packet from TimeDomainData.Json 
%% output: sample rate in Hz 


if length(unique(srates)) > 1 
    error('you have non uniform sample rates in your data'); 
else
    sratenum = unique(srates); 
    switch sratenum 
        case 0 
            srate = 250; % sample rate in Hz. 
        case 1 
            srate = 500; 
        case 2 
            srate = 1e3; 
    end
end
clear temp*; 
