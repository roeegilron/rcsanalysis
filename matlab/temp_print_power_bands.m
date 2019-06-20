%%
clc; 
for i = 1:length(pbOut)
    fprintf('file # %d\n\n',i);
    fprintf('ftt size = %d\n',pbOut(i).fftSize); 
    fprintf('number of bins = %d\n',pbOut(i).numBins); 
    fprintf('binWidth = %f.2\n',pbOut(i).binWidth); 
    fprintf('sampleRate = %d\n',pbOut(i).sampleRate); 
    fprintf('\n\n'); 
    fprintf('powerChannelsIdxs = %d %d\n',pbOut(i).powerChannelsIdxs); 
    fprintf('\n\n');
    fprintf('powerChannelsIdxs = %s\n',pbOut(i).powerBandInHz{:}); 
    fprintf('\n\n');
end