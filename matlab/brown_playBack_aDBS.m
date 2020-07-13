function [outTDsignal, samplingRate] = get_timeDomain_Segment(fn,ch_num,locs)
%% gets a chunck of time domain signal defined by
%% inputs:
% fn: location of .mat file with the time domain data
% ch_num: data chanel number of 4 possible time domain channels/keys (key0, key1, key2, key3)
% locs: 2-dim array with first and last sample of segment to be extracted
%% outputs:
% outTDsignal: truncated time domain signal 
% samplinghRate: vector of sampling rates within segment

tdData = load('/Users/juananso/Dropbox (Personal)/Work/DATA/benchtop/neuroDAC/playBack_neuralData_GP_aDBS/RawDataTD_GP_Offmeds.mat');

switch ch_num
    case 0, outTDsignal = tdData.outdatcomplete.key0(locs(1):locs(2));
    case 1, outTDsignal = tdData.outdatcomplete.key1(locs(1):locs(2));
    case 2, outTDsignal = tdData.outdatcomplete.key2(locs(1):locs(2));
    case 3, outTDsignal = tdData.outdatcomplete.key3(locs(1):locs(2));
end
        
samplingRate = tdData.outdatcomplete.samplerate(locs(1):locs(2));

end
