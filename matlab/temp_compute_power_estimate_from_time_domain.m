function temp_compute_power_estimate_from_time_domain()

dropboxFolder = findFilesBVQX('/Users','Starr Lab Dropbox',struct('dirs',1,'depth',2));
if length(dropboxFolder) == 1
    dirname  = fullfile(dropboxFolder{1}, 'RC+S Patient Un-Synced Data');
else
    error('can not find dropbox folder, you may be on a pc');
end




%% get folder for RCS08 example
foldername = fullfile(dropboxFolder, 'RC+S Patient Un-Synced Data/RCS08 Un-Synced Data/SummitData/SummitContinuousBilateralStreaming/RCS08L/Session1603917619728/DeviceNPC700444H');
fnsave = fullfile(foldername{1},'data_for_juan_compute_power_from_time_domain.mat');
if exist(fnsave,'file')
    load(fnsave);
else
    
    
    foldername = fullfile(dropboxFolder, 'RC+S Patient Un-Synced Data/RCS08 Un-Synced Data/SummitData/SummitContinuousBilateralStreaming/RCS08L/Session1603917619728/DeviceNPC700444H');
    
    
    pn = foldername{1};
    
    fnDeviceSettings = fullfile(pn,'DeviceSettings.json');
    
    
    
    ds = get_meta_data_from_device_settings_file(fnDeviceSettings);
    
    %     str = getAdaptiveHumanReadaleSettings(ds);
    
    str = getAdaptiveHumanReadaleSettings(ds,1);
    
    [combinedDataTable, debugTable, timeDomainSettings,powerSettings,...
        fftSettings,metaData,stimSettingsOut,stimMetaData,stimLogSettings,...
        DetectorSettings,AdaptiveStimSettings,AdaptiveRuns_StimSettings] = wrapper_DEMO_ProcessRCS(pn);
    
    ts = datetime(combinedDataTable.DerivedTime/1000,...
        'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
    combinedDataTable.DerivedTimeHuman = ts;
    
    fnAdaptive = fullfile(pn,'AdaptiveLog.json');
    
    res = readAdaptiveJson(fnAdaptive);
    tim = res.timing;
    fnf = fieldnames(tim);
    for fff = 1:length(fnf)
        tim.(fnf{fff})= tim.(fnf{fff})';
    end
    
    ada = res.adaptive;
    fnf = fieldnames(ada);
    for fff = 1:length(fnf)
        ada.(fnf{fff})= ada.(fnf{fff})';
    end
    
    timingTable = struct2table(tim);
    adaptiveTableTemp = struct2table(ada);
    adaptiveTable = [timingTable, adaptiveTableTemp];
    % get sampling rate
    deviceSettingsTable = get_meta_data_from_device_settings_file(fnDeviceSettings);
    fftInterval = deviceSettingsTable.fftTable{1}.interval;
    samplingRate = 1000/fftInterval;
    samplingRateCol = repmat(samplingRate,size(adaptiveTable,1),1);
    adaptiveTable.samplerate = samplingRateCol;
    adaptiveTable.packetsizes  = repmat(1,size(adaptiveTable,1),1);
    
    adaptiveTable = assignTime(adaptiveTable);
    ts = datetime(adaptiveTable.DerivedTime/1000,...
        'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
    
    
    adaptiveTable.DerivedTimesFromAssignTimesHumanReadable = ts;
end




%% plot the raw data

% plot all the fft settings 
hfig = figure;
hfig.Position = [776   539   375   742];
hfig.Color = 'w';
nrows = 1;
ncols = 1;
cntplt = 1;
hsub(cntplt) = subplot(nrows,ncols,cntplt); cntplt = cntplt + 1;

a = annotation('textbox', hsub(1).Position, 'String', "hi");
a.FontSize = 14;

set(gca,'FontSize',16);
set(gca, 'box','off','XTickLabel',[],'XTick',[],'YTickLabel',[],'YTick',[])
set(gca,'XColor','none')
set(gca,'YColor','none')


a.String = str;
a.EdgeColor = 'none';
%%

% plot the raw data 
hfig = figure;
hfig.Color = 'w';

nrows = 3; % raw time domain, raw power, adaptive out
ncols = 1;
cntplt = 1;
% plot raw time domain data
hsb = subplot(nrows,ncols,cntplt); cntplt = cntplt +1;
plot(combinedDataTable.DerivedTimeHuman,combinedDataTable.TD_key0);
title('raw time domain');

% plot raw power
hsb = subplot(nrows,ncols,cntplt); cntplt = cntplt +1;
idxnan = isnan(combinedDataTable.Power_Band1);
plot(combinedDataTable.DerivedTimeHuman(~idxnan),combinedDataTable.Power_Band1(~idxnan));
title('raw power');

% plot feature input
hsb = subplot(nrows,ncols,cntplt); cntplt = cntplt +1;
idxnan = isnan(adaptiveTable.Ld0DetectionStatus);
plot(adaptiveTable.DerivedTimesFromAssignTimesHumanReadable(~idxnan),adaptiveTable.Ld0DetectionStatus(~idxnan));
title('raw adaptive (avg power)');
fnsave = fullfile(foldername{1},'data_for_juan_compute_power_from_time_domain.mat');
if ~exist(fnsave,'file')
    save(fnsave);
end

