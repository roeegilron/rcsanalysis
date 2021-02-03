function MAIN_plot_agregate_log_data_and_watch_data_reports()
%% this function agregated watch and log data with information about algorithm states

%% function to run to get data:

%% log data: 
% 1. MAIN_read_and_save_log_file_data.m 
%           Looks for log files in dropbox, opens and saves them
%           as .txt 
% 2. MAIN_plot_saved_log_data
%           Loops on dropbox folders looking for .mat files created in
%           previous steps, and plots daily plots of current for each
%           agregating across log files 
%           This function also agregated all the data into one .mat files
%           with all adaptive information and patient table that is sasved
%           in dropbox 
%           Noe that to open meta data should use in Matlab 2019a as the
%           json package reader we use breaks in Matlab 2020a. 

%% watch data: 
% 1. /Users/roee/Starr_Lab_Folder/Data_Analysis/apple_watch_data/jupyter-notebook-templates/download_apple_watch_data.ipynb
%           Run on laptop to download all data on per patient basis - saves
%           to Box 
% 2. plot_apple_watch_data_from_csv
%           Plots the apple watch data and saves the data to a Box folder 
%           Note that this needs to run with Matlab2020a or higher bcs of
%           table handeling of NaN or missing values in in 2019a not
%           wokring 

%% oraganization and plotting schema: 

% find individual dates of interest, and within each date, given handle to
% a subplot, plot a statistic of interest 

%% add path , preabmle 
addpath(genpath('/Users/roee/Starr_Lab_Folder/Data_Analysis/Analysis-rcs-data/code'));
warning('off','MATLAB:table:RowsAddedExistingVars');
addpath(genpath(fullfile(pwd,'toolboxes','panel-2.14')));

%% meta params: 
settings.logDataDir     = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/adaptive_log_data/results';
settings.wathchDataDir  = '/Users/roee/Box/RC-S_Studies_Regulatory_and_Data/apple_watch_data/data'; 

%% define patients: 
cnt =1; 
params(cnt).patient    = 'RCS02'; 
params(cnt).dateStart  = datetime('01-Jan-2021 00:00:00','InputFormat','dd-MMM-uuuu HH:mm:ss'); 
params(cnt).dateEnd    = datetime('24-Jan-2021 00:00:00','InputFormat','dd-MMM-uuuu HH:mm:ss'); 
cnt = cnt + 1;

params(cnt).patient    = 'RCS08'; 
params(cnt).dateStart  = datetime('01-Jan-2021 00:00:00','InputFormat','dd-MMM-uuuu HH:mm:ss'); 
params(cnt).dateEnd    = datetime('24-Jan-2021 00:00:00','InputFormat','dd-MMM-uuuu HH:mm:ss'); 
cnt = cnt + 1;



%% load the master database table 
% set destination folders
dropboxFolder = findFilesBVQX('/Users','Starr Lab Dropbox',struct('dirs',1,'depth',2));
if length(dropboxFolder) == 1
    dirname  = fullfile(dropboxFolder{1}, 'RC+S Patient Un-Synced Data');
    rootdir = fullfile(dirname,'database');
    savedir = fullfile(rootdir,'adaptive_log_data','results');
    figdir  = fullfile(rootdir,'adaptive_log_data','figures');
else
    error('can not find dropbox folder, you may be on a pc');
end



load(fullfile(rootdir,'database_from_device_settings.mat'),'masterTableLightOut');
masterTableOut = masterTableLightOut;

%% get applwatch database 
patdb = get_apple_watch_database();

%% get data, and trim data 

% loop on patients 
cntData = 1; 
dataAgergate = table();
for p = 1:length(params) % create a table with each row being a date with log data,
    
%     % get log data info 
%     dataAgergate.date = [];
%     dataAgergate.type = {};
%     dataAgergate.patient = {};
%     dataAgergate.side    = {}; 
%     dataAgergate.data    = []; % struct with either log data / watch data
    
    % look for log data 
    logDir = findFilesBVQX(settings.logDataDir,[params(p).patient '*'],struct('dirs',1));
    logFiles = findFilesBVQX(logDir{1},'*log_data.mat'); 
    
    % get log data 
    for ll = 1:length(logFiles) % loop on sides 
        load(logFiles{ll});
        logdataRaw.masterTableOut      = masterTableOut; 
        logdataRaw.patTable            = patTable;
        logdataRaw.adaptiveLogTableAll = adaptiveLogTableAll;
        logdataRaw.groupChanges        = groupChangesOutUniqueAll;
        
        
        datesLookFor = params(p).dateStart:caldays(1):params(p).dateEnd;
        
        for d = 1:length(datesLookFor)
            dataDay = struct();
            % file save name
            saveDirDay = fullfile(logDir{1},'day_results');
            if ~exist(saveDirDay,'dir')
                mkdir(saveDirDay);
            end
            timeSave = datesLookFor(d);
            timeSave.Format = 'uuuu-MM-dd';
            fnsave = sprintf('%s_%s%s_log_and_watch_data.mat',timeSave,logdataRaw.patTable.patient{1},logdataRaw.patTable.side{1});
            fullfilesave = fullfile(saveDirDay,fnsave);
            fildLoaded = 0;
            if exist(fullfilesave,'file')
                load(fullfilesave,'dataDay')
                fildLoaded = 1; 
            else
                dataDay = get_log_data_day(logdataRaw, datesLookFor(d));
                watchData = get_watch_data_day(patdb,datesLookFor(d),logdataRaw);
            end
            % if data exists for the day, agregate data 
            if ~isempty(fieldnames(dataDay))
                if ~fildLoaded % only appened watch data if file was not loaded 
                dataDay.watchData = watchData; 
                end
                idx = cntData;
                dataAgergate.date(idx)       = dataDay.date;
                dataAgergate.type{idx}       = dataDay.type;
                dataAgergate.patient{idx}    = dataDay.patient;
                dataAgergate.side{idx}       = dataDay.side;
                dataAgergate.data{idx}       = dataDay.data;
                dataAgergate.watchData{idx}  = watchData;
                cntData = cntData + 1;
                % save data
                save(fullfilesave,'dataDay');
            end


        end
    end
end
%% XXXX just look at once side for now 
unqpatients = unique(dataAgergate.patient);
unqsides     = unique(dataAgergate.side);
for pp = 1:length(unqpatients)
    for ss = 1:length(unqsides)
        
        
        idxplot = strcmp(dataAgergate.side,unqsides{ss}) & ... 
                  strcmp(dataAgergate.patient,unqpatients{pp});
        dataPlot = dataAgergate(idxplot,:);
        
        
        %% plot data from both log data and watch data
        hfig = figure;
        hfig.Color = 'w';
        hpanel = panel();
        hpanel.pack('h',{0.15, 0.2, 0.2, 0.2, 0.25});
        for i = 1:5
            hpanel(i).pack('v',size(dataPlot,1));
        end
        % hpanel.select('all');
        % hpanel.identify()
        
        % plot based on types
        for d = 1: size(dataPlot,1)
            % each plot argument takes a handle for subplot, as well as a data
            % structure
            data = dataPlot.data{d};
            watchdata = dataPlot.watchData{d};
            hsb = hpanel(1,d).select();
            plot_log_data_time_barcode(hsb,data);  % plot block of time for adaptive
            % plot_log_data_state_barcode(hsb,data);  % plot state of time for adaptive in 24 hour clock
            hsb = hpanel(2,d).select();
            plot_log_data_meta_data(hsb,data);  % plot meta data for each state (%/time + target current)
            hsb = hpanel(3,d).select();
            plot_state_target_band(hsb,data); % plot target band for the state
            hsb = hpanel(4,d).select();
            plot_log_data_state_barcode(hsb,data)
            hsb = hpanel(5,d).select();
            plot_watch_data_bar(hsb,watchdata)
        end
        
        
        % create some formatting for the some plots
        for d = 1:size(dataPlot,1)
            hsb = hpanel(1,d).select(); % block time
            set(hsb, 'box','off','XTickLabel',[],'YTickLabel',[],'YTick',[])
        end
        hsb = hpanel(1,size(dataPlot,1)).select(); % block time
        datetick(hsb,'x',15,'keeplimits','keepticks');
        hsb.XTickLabelRotation = 45;
        hpanel.de.margin = 2;
        hpanel.marginright = 20;
        
        % get rid and link axes on the % state plots
        hsb = gobjects();
        for d = 1:size(dataPlot,1)
            hsb(d) = hpanel(4,d).select(); % block time
            set(hsb(d), 'box','off','XTickLabel',[],'YTickLabel',[],'YTick',[])
        end
        linkaxes(hsb,'x');
        
        % get rid and link axes on the % state plots
        hsb = gobjects();
        for d = 1:size(dataPlot,1)
            hsb(d) = hpanel(5,d).select(); % block time
            set(hsb(d), 'box','off','XTickLabel',[],'YTickLabel',[],'YTick',[])
        end
        linkaxes(hsb,'x');
        
        
        % plot the figure
        figdirsave = fullfile(figdir,dataPlot.patient{1},'summary_results');
        if ~exist(figdirsave)
            mkdir(figdirsave)
        end
        fnsave = sprintf('%s%s_summary_metric',dataPlot.patient{1},dataPlot.side{1});
        % plot
        prfig.plotwidth           = 16;
        prfig.plotheight          = 9;
        prfig.figdir              = figdirsave;
        prfig.figname             = fnsave;
        prfig.figtype             = '-djpeg';
        plot_hfig(hfig,prfig)
        close(hfig);
        
    end
end
end

% get the watch data 
function watchData = get_watch_data_day(patDb, datesLookFor,logdataRaw)
%%
watchData = struct();
patient = logdataRaw.patTable.patient{1}; 
side    = logdataRaw.patTable.side{1}; 
if strcmp(side,'L')
    sideWatch = 'R';
elseif strcmp(side,'R')
    sideWatch = 'L';
end
[yLook,mLook,dLook] = ymd(datesLookFor);
[y,m,d] = ymd(patDb.time);

idxuse = cellfun(@(x) strcmp(x,lower(patient)),patDb.patient) & ...
         cellfun(@(x) strcmp(x,sideWatch),patDb.side) & ...
         ( (yLook == y)  & (mLook == m) & (dLook == d) );
     
types = {'dyskinesia','rawAcc','tremor'};
if sum(idxuse) > 1
    patDbUse = patDb(idxuse,:);
    for p = 1:size(patDbUse,1)
        switch patDbUse.type{p}
            case 'dyskinesia'
                watchData.dyskMetrics = get_dyskinesia(patDbUse.file{p});
            case 'tremor'
                watchData.tremMetrics = get_tremor(patDbUse.file{p});
            case 'rawAcc'
                watchData.accelMetrics = get_accel(patDbUse.file{p});
        end
    end
end
        

end

% once you have relevant file names, load dyksinesia data and get metrics 
function dyskMetrics = get_dyskinesia(fn)
dyskdata = readtable(fn);
dyskMetrics = struct();
if ~isempty(dyskdata)
    idxkeep = ~isnan(dyskdata.probability);
    dyskdataOnly = dyskdata(idxkeep,:);
    totalOnes = ones(size(dyskdataOnly,1),1);
    
    %% creat summary metrics
    dyskSummary = struct();
    dyskSummary.probability =    sum(dyskdataOnly.probability .* totalOnes)/sum(totalOnes);
    dyskSummary.totalmin = sum(totalOnes);
    dyskMetrics.summary = dyskSummary;
    dyskMetrics.rawData = dyskdataOnly;
end
end

% once you have relevant file names, load tremor data and get metrics 
function tremMetrics = get_tremor(fn)
% to open properly need matlab 2020a
tremdata = readtable(fn);
%% creat summary metrics
tremMetrics = struct();
if ~isempty(tremdata)
    idxkeep = ~isnan(tremdata.mild) & ~(tremdata.unknown==1);
    
    tremDataOnly = tremdata(idxkeep,:);
    totalOnes = ones(size(tremDataOnly,1),1);
    tremSummary.mildPerc =   sum(tremDataOnly.mild .* totalOnes);
    tremSummary.modrPerc =   sum(tremDataOnly.moderate .* totalOnes);
    tremSummary.slightPerc = sum(tremDataOnly.slight .* totalOnes);
    tremSummary.strongPerc = sum(tremDataOnly.strong .* totalOnes);
    tremSummary.nonePerc =   sum(tremDataOnly.none .* totalOnes);
    tremSummary.unknown =    sum(tremDataOnly.unknown .* totalOnes);
    tremSummary.totalmin = sum(totalOnes);
    
    tremMetrics.rawData = tremDataOnly; 
    tremMetrics.tremSummary = tremSummary; 
    totalWithUknowin = tremSummary.totalmin - tremSummary.unknown;
    totalTremorInAllCategories     = tremSummary.mildPerc + ...
                                     tremSummary.modrPerc + ...
                                     tremSummary.slightPerc + ...
                                     tremSummary.strongPerc;
        
        
    tremMetrics.percTremor = totalTremorInAllCategories / totalWithUknowin;
end

end


% once you have relevant file names, load acc data and get metrics 
function accelMetrics = get_accel(fn)
accdata = readtable(fn);
accelMetrics = struct();
% dont save raw actigraphy data, too big 
x = 2;
figure;

sqr = (accdata.x.^2);
cvx = std(sqr)/mean(sqr);

sqr = (accdata.y.^2);
cvy = std(sqr)/mean(sqr);

sqr = (accdata.z.^2);
cvz = std(sqr)/mean(sqr);

cvmean = mean([cvx cvy cvz]);

accelMetrics.cvmean = cvmean; 

end

% plot watch data in simple bar graph 
function plot_watch_data_bar(hsb,data)
cla(hsb)
hold(hsb,'on');
% plot accel  
if isfield(data,'accelMetrics')
    if ~isempty(fieldnames(data.accelMetrics))
        hBar = barh(1,...
            data.accelMetrics.cvmean,'Parent',hsb);
        hBar.FaceColor = [0.8 0 0];
        hBar.FaceAlpha = 0.5;
    end
end

% plot dysk  
if isfield(data,'dyskMetrics')
    if ~isempty(fieldnames(data.dyskMetrics))
        hBar = barh(2,...
            data.dyskMetrics.summary.probability,'Parent',hsb);
        hBar.FaceColor = [0 0.8 0];
        hBar.FaceAlpha = 0.5;
    end
end

% plot tremor  
if isfield(data,'tremMetrics')
    if ~isempty(fieldnames(data.tremMetrics))
        hBar = barh(3,...
            data.tremMetrics.percTremor,'Parent',hsb);
        hBar.FaceColor = [0 0 0.8];
        hBar.FaceAlpha = 0.5;
    end
end

end


% get log data from one day: 
function dataDay = get_log_data_day(logdataRaw, datesLookFor)
% get the data for one day: 
dataDay = struct();
dateStart = datesLookFor;
dateEnd   = datesLookFor + hours(23) + minutes(59);
idxkeep = (logdataRaw.adaptiveLogTableAll.time >= dateStart) & ...
          (logdataRaw.adaptiveLogTableAll.time < dateEnd);
if sum(idxkeep) > 1
    
    dataDay.date = dateStart;
    dataDay.type = 'logdata';
    dataDay.patient = logdataRaw.patTable.patient{1};
    dataDay.side = logdataRaw.patTable.side{1};
    
    % get data payload:
    data.adaptiveTable = logdataRaw.adaptiveLogTableAll(idxkeep,:);
    data.summaryMetric = get_summary_metrics(data.adaptiveTable);
    data.metaData      = get_meta_data(logdataRaw,data.adaptiveTable.time(1));
    
    dataDay.data = data;
    
end

end

% once you have log data from one day, get summary table %/state
function sumTable = get_summary_metrics(adaptiveTableDay)
sumTable = struct();
aPlot = adaptiveTableDay;
idx = 1;
while idx < size(aPlot,1)-1
    stateTable.current(idx) =  aPlot.prog0(idx);
    stateTable.state(idx)  = aPlot.newstate(idx);
    stateTable.numMin(idx)  = minutes(aPlot.time(idx+1) - aPlot.time(idx));
    idx = idx + 1;
end

sumTable = table();
totalMin = sum(stateTable.numMin);
% get unique states and plot % time per state
unqStates = unique(stateTable.state);
for s = 1:length(unqStates)
    idxuse = unqStates(s) == stateTable.state;
    sumTable.unqStates(s) = unqStates(s);
    sumTable.percInState(s) = sum(stateTable.numMin(idxuse))/totalMin;
    sumTable.minInState(s) = sumTable.percInState(s).*totalMin;
    sumTable.avgcurent(s) = mean(stateTable.current(idxuse));
end



end

% once you have log data from one day, get meat data (cur/state, etc.) 
function metaDataOut  = get_meta_data(logdataRaw,dateStart)
metaDataOut = struct();
% find the change to group d before the adaptive session started 

%%
idxkeep = logdataRaw.groupChanges.time <= dateStart & ... 
          strcmp(logdataRaw.groupChanges.group,'D');
groupChanges = logdataRaw.groupChanges(idxkeep,:);
groupChanges = sortrows(groupChanges,{'time'});
targetSessionTime = groupChanges.time(end);
% find the min difference in time between the target sesion time and a
% releavnt session 
targetSessionTime.TimeZone =  logdataRaw.patTable.timeStart.TimeZone;
[val,idx] = min(abs(targetSessionTime - logdataRaw.patTable.timeStart));
patTable = logdataRaw.patTable(idx,:);
[folderPath, ~] = fileparts(patTable.deviceSettingsFn{1});
%% get settings
% DeviceSettings data
disp('Collecting Device Settings data')
DeviceSettings_fileToLoad = [folderPath filesep 'DeviceSettings.json'];
if isfile(DeviceSettings_fileToLoad)
    [timeDomainSettings, powerSettings, fftSettings, metaData] = createDeviceSettingsTable(folderPath);
else
    error('No DeviceSettings.json file')
end
%
% Stimulation settings
disp('Collecting Stimulation Settings from Device Settings file')
if isfile(DeviceSettings_fileToLoad)
    [stimSettingsOut, stimMetaData] = createStimSettingsFromDeviceSettings(folderPath);
else
    warning('No DeviceSettings.json file - could not extract stimulation settings')
end

disp('Collecting Stimulation Settings from Stim Log file')
StimLog_fileToLoad = [folderPath filesep 'StimLog.json'];
if isfile(StimLog_fileToLoad)
    [stimLogSettings] = createStimSettingsTable(folderPath);
else
    warning('No StimLog.json file')
end
%
% Adaptive Settings
disp('Collecting Adaptive Settings from Device Settings file')
if isfile(DeviceSettings_fileToLoad)
    [DetectorSettings,AdaptiveStimSettings,AdaptiveRuns_StimSettings] = createAdaptiveSettingsfromDeviceSettings(folderPath);
else
    error('No DeviceSettings.json file - could not extract detector and adaptive stimulation settings')
end

% get power band used, assume one, and only read LD0 for now 
currentFFTconfig = struct();
currentFFTconfig.size = fftSettings.fftConfig(end).size;
currentTDsampleRate = timeDomainSettings.samplingRate(end);
powerBands_toConvert = powerSettings.powerBands{end};
[powerBands] = getPowerBands(powerBands_toConvert,currentFFTconfig,currentTDsampleRate);
binaryFlipped = fliplr(dec2bin( DetectorSettings.Ld0(end).detectionInputs,8));
for b = 1:length(binaryFlipped)
    if strcmp(binaryFlipped(b) ,'1')
        switch b
            case 1
                chanfn = 'chan1';
            case 2
                chanfn = 'chan1';
            case 3
                chanfn = 'chan2';
            case 4
                chanfn = 'chan2';
            case 5
                chanfn = 'chan3';
            case 6
                chanfn = 'chan3';
            case 7
                chanfn = 'chan4';
            case 8
                chanfn = 'chan4';
        end
        chanfnraw = timeDomainSettings.(chanfn){end};
        idxend = strfind(chanfnraw,'LFP');
       
        strOut{1} = sprintf('[%s] [%0.2d] %s',...
             chanfnraw(1:idxend(1)-1),b,powerBands.powerBandsInHz{b}); % note assumes only 1 setting in power table
    end
end

%%
metaDataOut.AdaptiveStimSettingsRaw = AdaptiveStimSettings(end,:);
states = metaDataOut.AdaptiveStimSettingsRaw.states; 
% assume one program! 
statesNum = 0:1:8;
stateOut = table();
for s = 1:length(statesNum)
    fnuse = sprintf('state%d_AmpInMilliamps',statesNum(s));
    stateOut.number(s) = statesNum(s);
    stateOut.name{s} = num2str(statesNum(s));
    stateCur = states.(fnuse)(1);
    if stateCur == -1 
        stateOut.stateCur{s} = sprintf('HOLD');
    else
    stateOut.stateCur{s} = sprintf('%.2f mA', stateCur  );
    end
    stateOut.stateCurNum(s) = states.(fnuse)(1);
end
metaDataOut.AdaptiveStimSettingsRaw
metaDataOut.adaptiveInput = strOut{1}; 
metaDataOut.stateOut        = stateOut;

end

function patdb = get_apple_watch_database()
% rood
params.rootdir = '/Users/roee/Box/RC-S_Studies_Regulatory_and_Data/apple_watch_data/data';
params.figdir = '/Users/roee/Box/RC-S_Studies_Regulatory_and_Data/apple_watch_data/figures';

% create databaseL
ff = findFilesBVQX(params.rootdir,'rcs*.csv');
patdb = table();
for f = 1:length(ff)
    [pn,fn,ext] = fileparts(ff{f});
    pat = fn(1:5);
    side = fn(7);
    dateData = datetime(fn(11:21),'InputFormat','MMM_dd_yyyy');
    patdb.time(f) =  dateData;
    patdb.patient{f} = pat;
    patdb.side{f} = side;
    patdb.file{f} = ff{f};
    if any(strfind(fn,'accel'))
        type = 'rawAcc';
    end
    if any(strfind(fn,'dyskinesia'))
        type = 'dyskinesia';
    end
    if any(strfind(fn,'tremor'))
        type = 'tremor';
    end
    patdb.type{f} = type;
end
end

% plot block of time for adaptive 
function plot_log_data_time_barcode(hsb,data)
cla(hsb)
hold(hsb,'on');
starttime = data.adaptiveTable.time(1);
endtime = data.adaptiveTable.time(end);

% get limits in 24 hours clock: 
startVec = datevec(starttime);
startVec(4:6) = 0;
xlim(1) = datenum(datetime(startVec));

endVec = datevec(endtime);
endVec(4) = 23;
endVec(5) = 59;
endVec(6) = 0;
xlim(2) = datenum(datetime(endVec));


ticksuse = datenum([datetime(startVec): hours(3) : datetime(endVec),  datetime(endVec)]);


x = datenum([starttime endtime endtime starttime]);
y = [0 0 1 1];
hPatch = patch('XData', x, 'YData',y,'Parent',hsb);

starttime.Format = 'dd-MMM-uuuu';
[~,dayRec] = weekday(starttime);
dataRecPrint = sprintf('%s (%s)',starttime,dayRec);
text(datenum( starttime) ,0.5 ,dataRecPrint,'Parent',hsb,'FontSize',12);


set(hsb,'XLim',xlim);
hsb.XTick = ticksuse;
hPatch.FaceColor = [0.8 0 0 ];
hPatch.FaceAlpha = 0.3;
datetick('x',15,'keeplimits','keepticks');

end

% plot % time for each state 
function plot_log_data_meta_data(hsb,data)  

cla(hsb)
hold(hsb,'on');
colorsPerState = [255,190,11;...
                  251,86,7;... 
                  255,0,110;... 
                  131,56,236;...
                  58,134,255;...
                  7,59,76]./255;
summaryMetric = data.summaryMetric;
numStates = size(summaryMetric,1);
xPoitions = linspace(0.01,1,numStates+1);
yPositios = linspace(0.8,0.2,3);
for n = 1:numStates
    x = [xPoitions(n) xPoitions(n+1) xPoitions(n+1) xPoitions(n)];
    y = [1 1 0 0 ];
    hPatch = patch('XData', x, 'YData',y,'Parent',hsb);
    hPatch.FaceColor = colorsPerState(n,:);
    hPatch.FaceAlpha = 0.4;

    xPos = mean([xPoitions(n) xPoitions(n+1)]);
    text(xPos ,yPositios(1) ,sprintf('S = %d',n-1),'Parent',hsb,'FontSize',7);
    xPos = mean([xPoitions(n) xPoitions(n+1)]);
    text(xPos,yPositios(2) ,data.metaData.stateOut.stateCur{n},'Parent',hsb,'FontSize',8);
    xPos = mean([xPoitions(n) xPoitions(n+1)]);
    text(xPos,yPositios(3) ,sprintf('%%%.2f',data.summaryMetric.percInState(n)),'Parent',hsb,'FontSize',8);
end
hsb.XLim = [xPoitions(1) xPoitions(end)];
hsb.YLim = [-0.1 1.2];
set(hsb, 'box','off','XTickLabel',[],'XTick',[],'YTickLabel',[],'YTick',[])
set(hsb,'XColor','none')
set(hsb,'YColor','none')



end

% plot target band for the state
function plot_state_target_band(hsb,data) 
%%
cla(hsb);
hText = text(0.5 ,0.1 ,data.metaData.adaptiveInput,'Parent',hsb,'FontSize',10,'VerticalAlignment','middle');
set(hsb,'XLim',[0.5 0.6]);
set(hsb,'YLim',[0.1 0.1*1.05]);
set(hsb, 'box','off','XTickLabel',[],'XTick',[],'YTickLabel',[],'YTick',[])
set(hsb,'XColor','none')
set(hsb,'YColor','none')



end

% plot sate of time for adaptive in 24 hour clock 
function plot_log_data_state_barcode(hsb,data) 

cla(hsb)
hold(hsb,'on');
colorsPerState = [255,190,11;...
                  251,86,7;... 
                  255,0,110;... 
                  131,56,236;...
                  58,134,255;...
                  7,59,76]./255;
percPerState = data.summaryMetric.percInState';
for b = 1:length(percPerState)
    hBar(b) = barh(b,...
    data.summaryMetric.percInState(b));
    hBar(b).FaceColor = colorsPerState(b,:);
    hBar(b).FaceAlpha = 0.5;
end
hsb.YTick = 1:length(percPerState);
axis(hsb,'tight');
%%
% xtips1 = b(1).YEndPoints + 0.3;
% ytips1 = b(1).XEndPoints;
% labels1 = string(b(1).YData);
% text(xtips1,ytips1,labels1,'VerticalAlignment','middle')

end