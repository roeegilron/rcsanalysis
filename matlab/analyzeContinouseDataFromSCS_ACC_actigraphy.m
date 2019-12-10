function analyzeContinouseDataFromSCS_ACC_actigraphy(ACCDATAFILE)
params.overlap = 15; % overlap in seconds - time to jump for fft - make equal to datasize if no overlap wanted 
params.datasize = 30; % time in second to run fft on
params.maxGapFactor   = 2.5; % max gap factor to allow. So 1/sampleRate * maxGap Factor.
params.maxGap   = 0.2; % max gap to allow in data before throwing it out - seconds
params.tdSR     = 250; % only use 250hz sampling rate
params.accSR    = 64; % only user 64 hz sampling rate


%%
    [datadir,fn,ext] = fileparts(ACCDATAFILE);
    % load acc data
    load(ACCDATAFILE,'outdatcomplete');
    accTable = outdatcomplete;
    clear outdatcomplete;
    if ~isempty(accTable)
        start = tic;
        fileDuration = accTable.derivedTimes(end) - accTable.derivedTimes(1);
        if fileDuration > minutes(1)
            % load actigraphy
            load(fullfile(datadir,'RawDataAccel.mat'),'outdatcomplete');
            accTable = outdatcomplete;
            clear outdatcomplete;
            
            accData = processActigraphyData_TEMP_VECTOR(accTable,params);
            save(fullfile(datadir,'processedAccData.mat'),'accData','params'); 
        end
    end
    
end


function processedData = processActigraphyData_TEMP_VECTOR(accTable,params)
% reshape data (no overlap) - this will be faster 
% since using vectorization to check for issues with bad files etc. 
fprintf('reshaping data in vector format\n'); 
start = tic; 

% check for uniform sample rates
samplerate = unique(accTable.samplerate); 
if length( unique(accTable.samplerate) ) == 1
    reject = 0; 
end

% check if sampling rate matches

if ~reject
    datapoints = (params.datasize-1) * samplerate;
    totalNumPoints = size(accTable.XSamples,1); 
    leaveout = mod(totalNumPoints,datapoints);
    idxuseTotalData   = leaveout+1:1:totalNumPoints;
    % reshape times 
    times = accTable.derivedTimes(idxuseTotalData);
    totalPointsTrimmed = size(times,1);
    
    reshapedTimes = reshape(times,datapoints,totalPointsTrimmed/datapoints)';
    % check times and max gap
    secDiffs = seconds(diff(reshapedTimes,1,2));
    idxmaxgapFactor = max(secDiffs,[],2) <= (1/samplerate)* params.maxGapFactor;
    % chek for max gap 
    idxmaxgap = max(secDiffs,[],2) <= params.maxGap;
    idxuse = idxmaxgapFactor & idxmaxgap;
end
timeStart = reshapedTimes(:,1);
timeEnd = reshapedTimes(:,end);

RawprocessedData.timeStart = timeStart(idxuse);
RawprocessedData.timeEnd = timeEnd(idxuse);
axesUse = {'X','Y','Z'};
for c = 1:3
    fn = sprintf('%sSamples',axesUse{c});
    x = accTable.(fn)(idxuseTotalData);
    reshapedData = reshape(x,datapoints,totalPointsTrimmed/datapoints)';
    reshapedData = reshapedData - mean(reshapedData,2);
    reshapedData = reshapedData(idxuse,:);
    RawprocessedData.(fn) = reshapedData; 
end

processedData = struct();
for p = 1:length(RawprocessedData.timeStart)
    processedData(p).timeStart = RawprocessedData.timeStart(p); 
    processedData(p).timeEnd   = RawprocessedData.timeEnd(p); 
    processedData(p).XSamples      = RawprocessedData.XSamples(p,:); 
    processedData(p).YSamples      = RawprocessedData.YSamples(p,:); 
    processedData(p).ZSamples      = RawprocessedData.ZSamples(p,:); 
end
dur = processedData(end).timeStart - processedData(1).timeStart;
fprintf('data duration %s reshaped in %.2f seconds\n',dur,toc(start));
    
% processedData.alltimes = reshapedTimes(idxuse,:);


end



