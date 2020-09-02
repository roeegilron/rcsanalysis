function plot_embedded_adaptive_data_benchtop(varargin)
%plot_embedded_adaptive_data_with_spectrogram(fn), plots embedded adaptive
%   data of the session folder passed as argument, including spectrogram of time domain signal.
%   It assumes one channel If the lenght of the time domain signal is largern
%   than 1 hour, it creates a figure plot for each chunck of 1 hour, which is then saved in a destination directory.

%% init directories

% RAWDATA_FOLDER_PATH = '/Users/juananso/Dropbox (Personal)/Work/DATA/adaptive/fastDBS_patientTesting/RCS08R/Session1589320314167/DeviceNPC700421H'; % long session with lots of changes
RAWDATA_FOLDER_PATH = '/Users/juananso/Dropbox (Personal)/Work/DATA/adaptive/realisticSettings/Session1585158666205/DeviceNPC700239H';  % short session with few other no changes

if ~isempty(varargin) && isfolder(varargin)
    datadir = varargin{1};
else
    datadir = RAWDATA_FOLDER_PATH;
end

savefigdir = fullfile(datadir,'Figures');
if ~isfolder(savefigdir)
    mkdir(savefigdir)
end

%% init variables


%% load data
fprintf('loading all data...\n')
[outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerOut,adaptiveTable] =  MAIN_load_rcs_data_from_folder(datadir);
head(outdatcomplete)
metadata = get_meta_data_from_device_settings_file(fullfile(datadir,'DeviceSettings.json'));
[deviceSettings, stimStatus,stimState,fftTable,powerTable] = loadDeviceSettingsForMontage(fullfile(datadir,'DeviceSettings.json'));
head(metadata)
adaptivechanges = getAdaptiveChanges(fullfile(datadir,'DeviceSettings.json'));
detectorChanges = getDetectorSettings(fullfile(datadir,'DeviceSettings.json'))
adaptiveSettings = getAdaptiveSettings(fullfile(datadir,'DeviceSettings.json'))
plot(adaptivechanges.timeChange,ones(1,size(adaptivechanges,1)),'om','MarkerSize',10)
hold on
plot(detectorChanges.timeChange,ones(1,size(detectorChanges,1)),'xb','MarkerSize',10)

%% preprocess data

%% plot time domain data

%% plot spectrogram data

%% plot detector

%% plot stimulation amplitude

%% plot state

%% save figure

end