function srate = getSampleRateAcc(srates)
%% input: matrix of sample rates of each packet from TimeDomainData.Json 
%% output: sample rate in Hz 


if length(unique(srates)) > 1 
    error('you have non uniform sample rates in your data'); 
else
    sratenum = unique(srates); 
    switch sratenum 
        case 0 
            srate = 64; % sample rate in Hz. 
            % XX to do add other sampling rates 
    end
end
clear temp*; 
