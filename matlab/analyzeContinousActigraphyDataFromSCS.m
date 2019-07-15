function analyzeContinousActigraphyDataFromSCS()
params.overlap = 15; % overlap in seconds - time to jump for fft
params.datasize = 30; % time in second to run fft on
params.maxGapFactor   = 2; % max gap factor to allow. So 1/sampleRate * maxGap Factor.
params.maxGap   = 0.2; % max gap to allow in data before throwing it out - seconds
params.tdSR     = 250; % only use 250hz sampling rate
params.accSR    = 32; % only user 64 hz sampling rate
params.rootdir  = '/Volumes/Samsung_T5/RCS02/RCS02_all_home_data_processed/data/RCS02R';


% load acc data
ffAcc = findFilesBVQX(params.rootdir,'RawDataAccel.json'); 

for f = 1:length(ffAcc)
    try
        MAIN(ffAcc{f});
        fprintf('file %d out of %d success\n',f,length(ffAcc));
    catch
        fprintf('file %d out of %d fail\n',f,length(ffAcc));
    end 
end
return 

if ~isempty(td)
        start = tic;
        fileDuration = td.derivedTimes(end) - td.derivedTimes(1);
        if fileDuration > minutes(1)
            
            % load actigraphy
            load(fullfile(datadir,'RawDataAccel.mat'),'outdatcomplete');
            accTable = outdatcomplete;
            clear outdatcomplete;
            
            
            accData = processActigraphyData(accTable,params);
            save(fullfile(datadir,'processedAccData.mat'),'accData','params');
        end
    end


end