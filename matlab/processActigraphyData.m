function rescaledData = processActigraphyData(data,sr)
%% average and output 3 axis actigraphy data
% input: matrix of data (rows are sample, columns are 3 channels -  x y z)
% output: filtered, z-scaled positive only 1 d matrix

% what function does to data
% remove mean
% smooth by a 1 second moving window 
% square each channel
% add each squared channel to each other
% normalize between 0 and 1
procActiData = [];
for i = 1:size(data,2)
    dcmean = data(:,i) - mean(data(:,i));
    movMeanDat = movmean(dcmean,[sr-1 0]);
    movMeanDat = movMeanDat.^2; 
    procActiData = [procActiData , movMeanDat];
end
% movMeanDat = movmean(rescaledData,[sr-1 0]);

% rescaledData = rescale(sum(procActiData,2),0,1);

rescaledData = mean(procActiData,2); 
% %  filter 0.5 - 50hz
% [b, acreat ]  =butter(3, [0.1 30] / (sr/2),'bandpass');
% % filter data
% outData  = filtfilt(b,a,rescaledData);

end
