function analyzeContinouseDataFromSCS(TDDATAFILE)
params.overlap = 15; % overlap in seconds - time to jump for fft - make equal to datasize if no overlap wanted 
params.datasize = 30; % time in second to run fft on
params.maxGapFactor   = 2.5; % max gap factor to allow. So 1/sampleRate * maxGap Factor.
params.maxGap   = 0.2; % max gap to allow in data before throwing it out - seconds
params.tdSR     = 250; % only use 250hz sampling rate
params.accSR    = 64; % only user 64 hz sampling rate
% % data location:
% rootdir  = '/Volumes/Samsung_T5/RCS02/RCS02_all_home_data_processed/data/RCS02L';
% 
% ffiles = findFilesBVQX(rootdir,'RawDataTD.mat');
% tdfile  = findFilesBVQX(rootdir,'DeviceSettings.mat');
% acfile  = findFilesBVQX(rootdir,'RawDataAccel.mat');
% 
% tdProcDat = struct();
% accProcDat = struct();
% clc;

%% check issue with years 

% check for problems with year times  and copy those direcotries over to
% share with medtronic
skipthis =1;
if ~skipthis
    destFolder = '/Volumes/Samsung_T5/RCS02/RCS02_all_home_data_processed/data/RCS02L/1_problem_sessions';
    fid = fopen(fullfile(destFolder,'problemFolders.txt'),'w+');
    for f = 1:length(ffiles)
        [datadir,fn,ext] = fileparts(ffiles{f});
        [ppn,~,~] = fileparts(datadir);
        [~,sessionFn,~] = fileparts(ppn);
        % load td data
        load(ffiles{f},'outdatcomplete');
        td = outdatcomplete;
        clear outdatcomplete;
        if ~isempty(td)
            fileDuration = td.derivedTimes(end) - td.derivedTimes(1);
            if fileDuration > minutes(1)
                % load actigraphy
                fnacc = fullfile(datadir,'RawDataAccel.mat');
                if exist(fnacc,'file')
                    load(fullfile(datadir,'RawDataAccel.mat'),'outdatcomplete');
                    accTable = outdatcomplete;
                    clear outdatcomplete;
                    fprintf('file %d, %s %.2f not 2019 year \n',...
                        f, sessionFn,...
                        sum(year(accTable.derivedTimes) ~= 2019) / size(td,1) )
                    if sum(year(accTable.derivedTimes) ~= 2019) > 0
                        x = 2;
                        filesToCopy = findFilesBVQX(ppn,'*.json');
                        folderUse = fullfile(destFolder,sessionFn);
                        mkdir(folderUse);
                        cellfun(@(x) copyfile(x,folderUse), filesToCopy);
                        fprintf(fid,'session %s duration %s %% not 2019 year %.2f\n',...
                            sessionFn,fileDuration,sum(year(accTable.derivedTimes) ~= 2019) / size(td,1) );
                    end
                end
            end
        end
    end
    fclose(fid);
end
%%
% fid = fopen(fullfile(rootdir,'fileProcessigLog.txt'),'w+');

% for f = 1:length(ffiles)
    % load all the data
    [datadir,fn,ext] = fileparts(TDDATAFILE);
    % load td data
    load(TDDATAFILE,'outdatcomplete');
    td = outdatcomplete;
    clear outdatcomplete;
    if ~isempty(td)
        start = tic;
        fileDuration = td.derivedTimes(end) - td.derivedTimes(1);
        if fileDuration > minutes(1)
            % load device settings
            load(fullfile(datadir,'DeviceSettings.mat'),'outRec');
            
            % load power data
            [powerTable, pbOut] = loadPowerData(fullfile(datadir,'RawDataPower.json'));
            
            % load actigraphy
            load(fullfile(datadir,'RawDataAccel.mat'),'outdatcomplete');
            accTable = outdatcomplete;
            clear outdatcomplete;
            
            % load events
            load(fullfile(datadir,'EventLog.mat'),'eventTable');
            
            % process and analyze time domain data
            processedData = processTimeDomainData_TEMP_VECTOR(td,params);
            save(fullfile(datadir,'processedTDdata.mat'),'processedData','params'); 
            

            
%             if isempty(fieldnames(tdProcDat))
%                 tdProcDat = processedData;
%             else
%                 if ~isempty(processedData)
%                     tdProcDat = [tdProcDat processedData];
%                 end
%             end
            
            % process and analyze acc data
%             accData = processActigraphyData(accTable,params);
%             save(fullfile(datadir,'processedAccData.mat'),'accData','params'); 
%             if isempty(fieldnames(accProcDat))
%                 accProcDat = accData;
%             else
%                 if ~isempty(accData)
%                     accProcDat = [accProcDat accData];
%                 end
%             end
            
            % process and analyze actigraphy data
            %             processedData = processTimeDomainData(td,params);
        end
%         fprintf(fid,'file %d out of %d file length is %.2f minutes - doee in %.2f seconds\n',...
%             f,length(ffiles),minutes(fileDuration),toc(start));
%         fprintf('file %d out of %d file length is %.2f minutes - doee in %.2f seconds\n',...
%             f,length(ffiles),minutes(fileDuration),toc(start));
    end
    
% end
% save( fullfile(rootdir,'processedData.mat'),'params','tdProcDat','accProcDat','-v7.3')
% fclose(fid);
end

function processedData = processTimeDomainData(td,params)
% for each channel, find out if:
% a. max gap condition is met
% b. overlap step size is set
% c. max gap factor is set
% d. compute fft
% e. always skip the first params.datasize seconds
timeStart = td.derivedTimes(1)+seconds(params.datasize);
timeEnd = td.derivedTimes(1) + seconds(params.datasize)*2;
cnt = 1;
processedData = [];
% if all the data isn't from the same year - reject this session
%
%
if sum(year(td.derivedTimes) ~= 2019) > 0
  return;
end
while timeEnd < td.derivedTimes(end)
    idxuse = td.derivedTimes >= timeStart & td.derivedTimes <= timeEnd;
    times = td.derivedTimes(idxuse);
    sratesIdx = td.samplerate~=0;
    srates = unique(td.samplerate(sratesIdx));
    reject = 0;
    % check if sapmpling rates are the same
    if length(srates)>1
        reject = 1;
    else
        sr = srates;
    end
    % check if sampling rate matches
    if ~(sr == params.tdSR)
        reject = 1;
    end
    % check times and max gap
    if prctile(seconds(diff(times)),99) > (1/sr)* params.maxGapFactor
        % check if 99% of data has gaps that are a max of 2x sr diffs
        reject = 1;
    end
    % check max inter gap interval
    if max(seconds(diff(times))) > params.maxGap
        reject = 1;
    end
    % check if your segment is at least of length data size
    if isempty(times)
        reject = 1;
    else
        if ~ (seconds(times(end)-times(1)) > params.datasize-1) % at least larger than data size - 1 seconds
            reject = 1;
        end
    end
    % check if segment has enough data point (may be a little shy bcs of
    % packet loss 
    if ~(length(times)  > ((params.datasize-1)*sr))
            reject = 1;
    end
    
    if ~reject
        processedData(cnt).timeStart = timeStart;
        processedData(cnt).timeEnd = timeEnd;
        for c = 1:4
            fn = sprintf('key%d',c-1);
            x = td.(fn)(idxuse);
            x = x - mean(x);
            % trim x by 1 second to insure can save everything to matrix
            % form
            datapoints = (params.datasize-1)*sr;
            
            %             [fftOut,ff]   = pwelch(x,sr,sr/2,0:1:sr/2,sr,'psd');
            processedData(cnt).(fn) = x(1:datapoints);
            
        end
        cnt = cnt+1;
    end
    timeStart = timeStart + seconds(params.overlap);
    timeEnd = timeStart + seconds(params.datasize);
end

end

function  processedData = processActigraphyData(accTable,params)
% for each channel, find out if:
% a. max gap condition is met
% b. overlap step size is set
% c. max gap factor is set
% d. compute fft
% e. always skip the first params.datasize seconds
timeStart = accTable.derivedTimes(1)+seconds(params.datasize);
timeEnd = accTable.derivedTimes(1) + seconds(params.datasize)*2;
actChannels = {'X','Y','Z'};
cnt = 1;
processedData = [];
% if all the data isn't from the same year - reject this session
%
%
if sum(year(accTable.derivedTimes) ~= 2019) > 0
  return;
end

while timeEnd < accTable.derivedTimes(end)
    idxuse = accTable.derivedTimes >= timeStart & accTable.derivedTimes <= timeEnd;
    times = accTable.derivedTimes(idxuse);
    srates = unique(accTable.samplerate(idxuse));
    reject = 0;
    % check if sapmpling rates are the same
    if length(srates)>1
        reject = 1;
    else
        sr = srates;
    end
    % check if sampling rate matches
    if ~(sr == params.accSR)
        reject = 1;
    end
    % check times and max gap
    if prctile(seconds(diff(times)),99) > (1/sr)* params.maxGapFactor
        % check if 99% of data has gaps that are a max of 2x sr diffs
        reject = 1;
    end
    % check max inter sample gap
    if max(seconds(diff(times))) > params.maxGap
        reject = 1;
    end
    % check if your segment is at least of length data size
    if isempty(times)
        reject = 1;
    else
        if ~ (seconds(times(end)-times(1)) > params.datasize-1) % at least larger than data size - 1 seconds
            reject = 1;
        end
    end
    % check if segment has enough data point (may be a little shy bcs of
    % packet loss
    if ~(length(times)  > ((params.datasize-1)*sr))
        reject = 1;
    end

    
    if ~reject
        processedData(cnt).timeStart = timeStart;
        processedData(cnt).timeEnd = timeEnd;
        for c = 1:3
            fn = sprintf('%sSamples',actChannels{c});
            x = accTable.(fn)(idxuse);
            x = x - mean(x);
            datapoints = (params.datasize-1)*sr;
            %             [fftOut,ff]   = pwelch(x,sr,sr/2,0:1:sr/2,sr,'psd');
            %             processedData(cnt).(fn).ff = ff;
            %             processedData(cnt).(fn).fftOut = log10(fftOut);
            processedData(cnt).(fn) = x(1:datapoints);
        end
        cnt = cnt+1;
    end
    timeStart = timeStart + seconds(params.overlap);
    timeEnd = timeStart + seconds(params.datasize);
end

end

function processedData = processTimeDomainData_TEMP_VECTOR(td,params)
% reshape data (no overlap) - this will be faster 
% since using vectorization to check for issues with bad files etc. 
fprintf('reshaping data in vector format\n'); 
start = tic; 

% check for uniform sample rates
samplerate = unique(td.samplerate); 
if length( unique(td.samplerate) ) == 1
    reject = 0; 
end

% check if sampling rate matches

if ~reject
    datapoints = (params.datasize-1) * samplerate;
    totalNumPoints = size(td.key0,1); 
    leaveout = mod(totalNumPoints,datapoints);
    idxuseTotalData   = leaveout+1:1:totalNumPoints;
    % reshape times 
    times = td.derivedTimes(idxuseTotalData);
    totalPointsTrimmed = size(times,1);
    
    reshapedTimes = reshape(times,datapoints,totalPointsTrimmed/datapoints)';
    % check times and max gap
    secDiffs = seconds(diff(reshapedTimes,1,2));
    idxmaxgapFactor = max(secDiffs,[],2) <= (1/samplerate)* params.maxGapFactor;
    % chek for max gap 
    idxmaxgap =idxuse<= params.maxGap;
    idxuse = idxmaxgapFactor & idxmaxgap;
end
timeStart = reshapedTimes(:,1);
timeEnd = reshapedTimes(:,end);

RawprocessedData.timeStart = timeStart(idxuse);
RawprocessedData.timeEnd = timeEnd(idxuse);
for c = 1:4
    fn = sprintf('key%d',c-1);
    x = td.(fn)(idxuseTotalData);
    reshapedData = reshape(x,datapoints,totalPointsTrimmed/datapoints)';
    reshapedData = reshapedData - mean(reshapedData,2);
    reshapedData = reshapedData(idxuse,:);
    RawprocessedData.(fn) = reshapedData; 
end

processedData = struct();
for p = 1:length(RawprocessedData.timeStart)
    processedData(p).timeStart = RawprocessedData.timeStart(p); 
    processedData(p).timeEnd   = RawprocessedData.timeEnd(p); 
    processedData(p).key0      = RawprocessedData.key0(p,:); 
    processedData(p).key1      = RawprocessedData.key1(p,:); 
    processedData(p).key2      = RawprocessedData.key2(p,:); 
    processedData(p).key3      = RawprocessedData.key3(p,:); 
end
dur = processedData(end).timeStart - processedData(1).timeStart;
fprintf('data duration %s reshaped in %.2f seconds\n',dur,toc(start));
    
% processedData.alltimes = reshapedTimes(idxuse,:);


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



