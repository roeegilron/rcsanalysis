%% plot adapvie rcs02
ff = findFilesBVQX('/Volumes/RCS_DATA/RCS02/sleep','Device*',struct('dirs',1));
ff = findFilesBVQX('/Volumes/RCS_DATA/RCS05/fast_adbs/RCS05R','Device*',struct('dirs',1));
for f = 1:length(ff)
    rc =rcsPlotter();
    rc.addFolder(ff{f});
    rc.loadData();
    rc.eraseData();
    clear rc;
end

%% create_master table
%% rcs 02

create_database_from_device_settings_files('/Volumes/RCS_DATA/RCS02/log_data/SummitContinuousBilateralStreaming')
load('/Volumes/RCS_DATA/RCS02/log_data/SummitContinuousBilateralStreaming/database/database_from_device_settings.mat');
%% rcs 07
pn = '/Volumes/RCS_DATA/manual_adaptive/RCS07/2021_02_11_manual_adbs';
pn = '/Volumes/RCS_DATA/RCS02/sleep';
create_database_from_device_settings_files(pn)
load(fullfile(pn,'database/database_from_device_settings.mat'));
%% load adatabase :
allDays = dateshift(masterTableOut.timeStart,'start','day');
uniqueDays = unique(allDays);

for u = 1
    idxuxe = allDays == uniqueDays(u);
    dbUse  = masterTableLightOut(idxuxe,:);
    unqSides = unique(dbUse.side);
    outData = struct();
    hfig = figure;
    for s = 1:length(unqSides)
        idxUse = strcmp(unqSides{s},dbUse.side);
        dbSide = dbUse(idxUse,:);
        outData(s).rc = rcsPlotter();
        for ss = 1:size(dbSide,1)
            [pn,fn] = fileparts(dbSide.deviceSettingsFn{ss});
            outData(s).rc.addFolder(pn);
        end
        outData(s).rc.loadData();
    end
    %% plot adaptive
    hfig = figure('Color','w');
    nrows = 12;
    cntplt = 1;
    hsb = gobjects();
    % plot adattive each side
    for i = 1:length(outData)
        hsb(cntplt,1) = subplot(nrows,1,cntplt); cntplt = cntplt + 1;
        outData(i).rc.plotTdChannelSpectral(2,hsb(cntplt-1,1));
        hsb(cntplt-1,1).Title.String = [unqSides{i} ' ' hsb(cntplt-1,1).Title.String ];
    end
    for i = 1:length(outData)
        hsb(cntplt,1) = subplot(nrows,1,cntplt); cntplt = cntplt + 1;
        outData(i).rc.plotTdChannelSpectral(4,hsb(cntplt-1,1));
        hsb(cntplt-1,1).Title.String = [unqSides{i} ' ' hsb(cntplt-1,1).Title.String ];
    end
    
    for i = 1:length(outData)
        hsb(cntplt,1) = subplot(nrows,1,cntplt); cntplt = cntplt + 1;
        outData(i).rc.plotAdaptiveLd(0,hsb(cntplt-1,1));
        hsb(cntplt-1,1).Title.String = [unqSides{i} ' ' hsb(cntplt-1,1).Title.String ];
        outData(i).rc.utilitySetYLim(hsb(cntplt-1,1))
    end
    for i = 1:length(outData)
        hsb(cntplt,1) = subplot(nrows,1,cntplt); cntplt = cntplt + 1;
        outData(i).rc.plotAdaptiveLd(1,hsb(cntplt-1,1));
        hsb(cntplt-1,1).Title.String = [unqSides{i} ' ' hsb(cntplt-1,1).Title.String ];
        outData(i).rc.utilitySetYLim(hsb(cntplt-1,1))
    end
    for i = 1:length(outData)
        hsb(cntplt,1) = subplot(nrows,1,cntplt); cntplt = cntplt + 1;
        outData(i).rc.plotAdaptiveCurrent(0,hsb(cntplt-1));
        hsb(cntplt-1,1).Title.String = [unqSides{i} ' current' ];
    end
    hsb(cntplt,1) = subplot(nrows,1,cntplt); cntplt = cntplt + 1;
    for i = 1:length(outData)
        outData(i).rc.plotActigraphyChannel('X',hsb(cntplt-1,1));
        hsb(cntplt-1,1).Title.String = [unqSides{i} ' ' hsb(cntplt-1,1).Title.String ];
    end
    linkaxes(hsb,'x')
    sgtitle(sprintf('%s',uniqueDays(u)),'FontSize',16);
end


%% only plot current, state 8,11 12 (3 4 5)
close all;
allDays = dateshift(masterTableOut.timeStart,'start','day');
uniqueDays = unique(allDays);

for u = [5]
    idxuxe = allDays == uniqueDays(u);
    dbUse  = masterTableLightOut(idxuxe,:);
    unqSides = unique(dbUse.side);
    outData = struct();
    hfig = figure;
    for s = 1:length(unqSides)
        idxUse = strcmp(unqSides{s},dbUse.side);
        dbSide = dbUse(idxUse,:);
        outData(s).rc = rcsPlotter();
        for ss = 1:size(dbSide,1)
            [pn,fn] = fileparts(dbSide.deviceSettingsFn{ss});
            outData(s).rc.addFolder(pn);
        end
        outData(s).rc.loadData();
    end
    % plot adaptive
    hfig = figure('Color','w');
    nrows = 10;
    cntplt = 1;
    hsb = gobjects();
    
    for i = 1:length(outData)
        hsb(cntplt,1) = subplot(nrows,1,cntplt); cntplt = cntplt + 1;
        outData(i).rc.plotAdaptiveLd(0,hsb(cntplt-1,1));
        hsb(cntplt-1,1).Title.String = [unqSides{i} ' ' hsb(cntplt-1,1).Title.String ];
        outData(i).rc.utilitySetYLim(hsb(cntplt-1,1))
        set(hsb(cntplt-1),'FontSize',12)
        set(hsb(cntplt-1,1),'YLim',[0 3.5e3])
    end
    %     for i = 1:length(outData)
    %         hsb(cntplt,1) = subplot(nrows,1,cntplt); cntplt = cntplt + 1;
    %         outData(i).rc.plotPowerRaw(1,hsb(cntplt-1,1),60);
    %         hsb(cntplt-1,1).Title.String = [unqSides{i} ' ' hsb(cntplt-1,1).Title.String ];
    %         set(hsb(cntplt-1),'FontSize',12)
    %     end
    %
    %     for i = 1:length(outData)
    %         hsb(cntplt,1) = subplot(nrows,1,cntplt); cntplt = cntplt + 1;
    %         outData(i).rc.plotPowerRaw(8,hsb(cntplt-1,1),60);
    %         hsb(cntplt-1,1).Title.String = [unqSides{i} ' ' hsb(cntplt-1,1).Title.String ];
    %         set(hsb(cntplt-1),'FontSize',12)
    %     end
    for i = 1:length(outData)
        hsb(cntplt,1) = subplot(nrows,1,cntplt); cntplt = cntplt + 1;
        outData(i).rc.plotAdaptiveLd(1,hsb(cntplt-1,1));
        hsb(cntplt-1,1).Title.String = [unqSides{i} ' ' hsb(cntplt-1,1).Title.String ];
        outData(i).rc.utilitySetYLim(hsb(cntplt-1,1))
        set(hsb(cntplt-1,1),'YLim',[0 4e5])
    end
    for i = 1:length(outData)
        hsb(cntplt,1) = subplot(nrows,1,cntplt); cntplt = cntplt + 1;
        outData(i).rc.plotAdaptiveCurrent(0,hsb(cntplt-1));
        hsb(cntplt-1,1).Title.String = [unqSides{i} ' current' ];
        set(hsb(cntplt-1,1),'YLim',[2 3.5]);
        set(hsb(cntplt-1),'FontSize',12)
    end
    
    for i = 1:length(outData)
        hsb(cntplt,1) = subplot(nrows,1,cntplt); cntplt = cntplt + 1;
        outData(i).rc.plotAdaptiveState(hsb(cntplt-1));
        hsb(cntplt-1,1).Title.String = [unqSides{i} ' current' ];
        set(hsb(cntplt-1,1),'YLim',[0 10]);
        set(hsb(cntplt-1),'FontSize',12)
    end
    hsb(cntplt,1) = subplot(nrows,1,cntplt); cntplt = cntplt + 1;
    for i = 1:length(outData)
        outData(i).rc.plotActigraphyChannel('X',hsb(cntplt-1,1));
        hsb(cntplt-1,1).Title.String = [unqSides{i} ' ' hsb(cntplt-1,1).Title.String ];
        set(hsb(cntplt-1),'FontSize',12)
    end
    
    %     hsb(cntplt,1) = subplot(nrows,1,cntplt); cntplt = cntplt + 1;
    
    
    linkaxes(hsb,'x')
    %     sgtitle(sprintf('%s',uniqueDays(u)),'FontSize',16);
    %
    %     xzoom = datetime({'16-Feb-2021 00:00:00','17-Feb-2021 08:00:00'});
    %     xlim(hsb(end,1),datenum(xzoom));
    %     xticks = xzoom(1) : minutes(15) : xzoom(2);
    %     xticks.Format = 'HH:mm';
    %     xticklabels = sprintf('%s\n',xticks );
    %     hsb(end,1).XTick = datenum(xticks);
    %     hsb(end,1).XTickLabel = xticklabels;
    %
end

%% zoom into one minute graph and makes some nicer x ticks
xzoom = datetime({'11-Feb-2021 09:30:00','11-Feb-2021 16:45:00'});
xlim(hsb(end,1),datenum(xzoom));
xticks = xzoom(1) : minutes(15) : xzoom(2);
xticks.Format = 'HH:mm';
xticklabels = sprintf('%s\n',xticks );
hsb(end,1).XTick = datenum(xticks);
hsb(end,1).XTickLabel = xticklabels;

%% XXXXXX
%% XXXXXX
%% XXXXXX
%% XXXXXX

%% import sleep

data = importdata('/Users/roee/Downloads/2_17_2021.txt');

c =  categorical(data.textdata(2:end,1));
dates = cellfun(@(x) datetime(strrep(strrep(strrep(strrep(x,'Time',''),' ',''),'[',''),']','')),data.textdata(2:end,2));
datevecDates = datevec(dates);
datevecDates(:,3) = 17;
datenumDates = datenum(datevecDates);


%%
figure;
plot(datetime(datevec(datenumDates)),c)

%%
hfig = figure;
hsb = subplot(2,1,1);
rc2.plotTdChannelSpectral(1,hsb);
hsb = subplot(2,1,2);
rc2.plotTdChannelBandpass(1,[12 30],hsb);


%% XXXXXX
%% XXXXXX
%% XXXXXX
%% XXXXXX

%% XXXXXX
%% XXXXXX
%% XXXXXX
%% XXXXXX

%% load LD's for day, not actual data
outData = struct();
AdaptiveDataOut = table();
AccelTableOut = table();
eventOutAll = table();
allDays = dateshift(masterTableOut.timeStart,'start','day');
uniqueDays = unique(allDays);

for u = 1:length(uniqueDays)
    idxuxe = allDays == uniqueDays(u);
    dbUse  = masterTableLightOut(idxuxe,:);
    unqSides = unique(dbUse.side);
    for s = 1:length(unqSides)
        idxUse = strcmp(unqSides{s},dbUse.side);
        dbSide = dbUse(idxUse,:);
        for ss = 1:size(dbSide,1)
            [pn,fn] = fileparts(dbSide.deviceSettingsFn{ss});
            %% load data
            try
                [~,...
                    ~, ~, ~,...
                    AccelData, ~, ~,...
                    PowerData, PowerData_onlyTimeVariables, Power_timeVariableNames,...
                    FFTData, FFTData_onlyTimeVariables, FFT_timeVariableNames,...
                    AdaptiveData, AdaptiveData_onlyTimeVariables, Adaptive_timeVariableNames,...
                    timeDomainSettings, powerSettings, fftSettings, eventLogTable,...
                    metaData, stimSettingsOut, stimMetaData, stimLogSettings,...
                    DetectorSettings, AdaptiveStimSettings, AdaptiveEmbeddedRuns_StimSettings] = ProcessRCS(pn,3);
                sideAdd = repmat(unqSides{s},size(AdaptiveData,1),1);
                AdaptiveData = addvars(AdaptiveData,sideAdd,'Before','localTime');
                AdaptiveDataOut = [AdaptiveDataOut; AdaptiveData];
                AccelTableOut   = [AccelTableOut; AccelData];
                
                if ss == 1
                    eventOut = eventLogTable;
                    
                    idxKeep = ~(strcmp(eventOut.EventType,'CTMLeftBatteryLevel') | ...
                        strcmp(eventOut.EventType,'CTMRightBatteryLevel') | ...
                        strcmp(eventOut.EventType,'INSRightBatteryLevel') | ...
                        strcmp(eventOut.EventType,'INSLeftBatteryLevel'));
                    idxInfo = (cellfun(@(x) any(strfind(x,'PatientID')),eventOut.EventType(:)) | ...
                        cellfun(@(x) any(strfind(x,'LeadLocation')),eventOut.EventType(:)) | ...
                        cellfun(@(x) any(strfind(x,'ImplantedLeads')),eventOut.EventType(:)) | ...
                        cellfun(@(x) any(strfind(x,'Log Data Success')),eventOut.EventType(:)) | ...
                        cellfun(@(x) any(strfind(x,'Mirror Event Log Success')),eventOut.EventType(:)) | ...
                        cellfun(@(x) any(strfind(x,'Application Version')),eventOut.EventType(:)) | ...
                        cellfun(@(x) any(strfind(x,'InsImplantLocation')),eventOut.EventType(:)));
                    
                    % for rest of analyis get rid of that
                    idxKeep = idxKeep & ~idxInfo;
                    eventOut = eventOut(idxKeep,:);
                    if ~isempty(eventOut)
                        packtRxTimes    =  datetime(eventOut.UnixOnsetTime/1000,...
                            'ConvertFrom','posixTime','Format','dd-MMM-yyyy HH:mm:ss.SSS');
                        localTime = packtRxTimes + hours( metaData.UTCoffset);
                        eventOut.localTime = localTime;
                        
                        eventOut = eventOut(:,{'localTime','EventType','EventSubType'});
                    end
                    if isempty(eventOutAll)
                        eventOutAll = eventOut;
                    else
                        eventOutAll = [eventOutAll; eventOut];
                    end
                end
                
            end
        end
    end
end

%% loop on adaptive data and side and make histogram plots
allDays = dateshift(AdaptiveDataOut.localTime,'start','day');
uniqueDaysAdaptive = unique(allDays);
tblOut = table();
cntdat = 1;
for u = 1:length(uniqueDaysAdaptive)
    idxuxe = allDays == uniqueDaysAdaptive(u);
    adUse  = AdaptiveDataOut(idxuxe,:);
    unqSides = unique(adUse.sideAdd);
    for s = 1:length(unqSides)
        idxUse = adUse.sideAdd == unqSides(s);
        adSide = adUse(idxUse,:);
        if day(uniqueDaysAdaptive(u)) > 12 % sleep
            tblOut.side{cntdat} = unqSides(s);
            tblOut.status{cntdat} = 'sleep';
            tblOut.LD0{cntdat} = adSide.Ld0_output;
            tblOut.LD1{cntdat} = adSide.Ld1_output;
        else
            tblOut.side{cntdat} = unqSides(s);
            tblOut.status{cntdat} = 'wake';
            tblOut.LD0{cntdat} = adSide.Ld0_output;
            tblOut.LD1{cntdat} = adSide.Ld1_output;
        end
        cntdat = cntdat + 1;
    end
end

%% plot histograms
hfig = figure;
hfig.Color = 'w';
lds = {'LD0','LD1'};
labels = {'MC gamma (62-80Hz)','MC theta-alpha (3-12Hz)'};
unqSides = unique(adUse.sideAdd);
conds = {'wake','sleep'};
cntplt = 1;
for s = 1:length(unqSides)
    for ll = 1:length(lds)
        hsb = subplot(2,2,cntplt); cntplt = cntplt + 1;
        hold(hsb,'on');
        for c = 1:length(conds)
            idxuse = strcmp(tblOut.side,unqSides(s)) & ...
                strcmp(tblOut.status,conds{c});
            tblUseHistogram = tblOut(idxuse,:);
            fnuse = lds{ll};
            dat = tblUseHistogram.(fnuse);
            dat = cell2mat(dat);
            if ll == 2
                binWidth = 1e4;
            else
                binWidth = 5e2;
            end
            [~,edges] = histcounts(log10(dat));
            histogram(dat,10.^edges,'Normalization','probability');
            set(gca, 'xscale','log')
            xlabel('detector values (log scale)');
            ylabel('prob.');
            set(gca,'FontSize',16);
        end
        legend(conds);
        ttlsue = sprintf('%s %s %s',lds{ll},unqSides(s),labels{ll});
        title(ttlsue);
    end
end


%% plot 3D histograms
hfig = figure;
hfig.Color = 'w';
lds = {'LD0','LD1'};
labels = {'MC gamma (62-80Hz)','MC theta-alpha (3-12Hz)'};
unqSides = unique(adUse.sideAdd);
conds = {'wake','sleep'};
cntplt = 1;
for s = 1:length(unqSides)
    hsb = subplot(1,2,cntplt); cntplt = cntplt + 1;
    hold(hsb,'on');
    for c = 1:length(conds)
        idxuse = strcmp(tblOut.side,unqSides(s)) & ...
            strcmp(tblOut.status,conds{c});
        tblUseHistogram = tblOut(idxuse,:);
        dat1 = cell2mat(tblUseHistogram.LD0); % gamma ;
        dat2 = cell2mat(tblUseHistogram.LD1); % theta ;
        
        hsc(c) = scatter(dat1,dat2,10,'filled','MarkerFaceAlpha',0.7);
        %             set(gca, 'xscale','log')
        %             set(gca, 'yscale','log')
        xlabel('gamma')
        ylabel('theta');
        set(gca,'FontSize',16);
    end
    legend(conds);
    title(unqSides(s));
end

%% plot all data


for s = 1:length(unqSides)
    dbUse  = AdaptiveDataOut;
    unqSides = unique(dbUse.sideAdd);
    idxUse = unqSides(s) == dbUse.sideAdd;
    dbSide = dbUse(idxUse,:);
    
    
    allDays = dateshift(dbSide.localTime,'start','day');
    uniqueDays = unique(allDays);
    
    hfig = figure;
    hfig.Color = 'w';
    nrows = length(uniqueDays);
    hsb = gobjects();
    for u = 1:length(uniqueDays)
        idxuxe = allDays == uniqueDays(u);
        dbUse  = AdaptiveDataOut(idxuxe,:);
        hsb(u,1) = subplot(nrows,1,u);
        plot(dbUse.localTime,dbUse.Ld1_output);
        title(sprintf('%s %s', unqSides(s), uniqueDays(u)));
    end
    linkaxes(hsb,'y');
end

%% plot all data
% insert another states on transition to make graph nicer
rootdir = '/Volumes/RCS_DATA/RCS02/log_data/SummitContinuousBilateralStreaming';
ff = findFilesBVQX(rootdir,'RCS02R*.mat');
adaptiveLogTableOut = table();
for f = 1:length(ff)
    load(ff{f});
    [pn,~] = fileparts(ff{f});
    [pn,~] = fileparts(pn);
    
    % find time to adjust table with
    % find packet gen time that is not zero, use the 100th index to
    [outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerOut,adaptiveTable] =  MAIN_load_rcs_data_from_folder(pn);
    
    % make sure not bad packet:
    idxnotzero = find(outdatcomplete.PacketGenTime ~=0);
    packetGenTime = outdatcomplete.PacketGenTime(idxnotzero(100));
    timestamp = outdatcomplete.timestamp(idxnotzero(100));
    timeStampHuman = datetime(datevec(timestamp./86400 + datenum(2000,3,1,0,0,0)),...
        'TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS'); % medtronic time - LSB is seconds
    packetGenTimeHuman =  datetime(packetGenTime/1000,...
        'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
    gapInTime = packetGenTimeHuman - timeStampHuman;
    adaptiveLogTable.time = adaptiveLogTable.time + gapInTime;
    adaptiveLogTableOut = [adaptiveLogTableOut; adaptiveLogTable];
end

%%
load('/Volumes/RCS_DATA/RCS02/log_data/SummitContinuousBilateralStreaming/RCS02L/Session1614470651254/DeviceNPC700398H/LogDataFromLeftUnilateralINS/RCS02L_27-Feb-2021--16-04.mat');
dr = dreamDataReader();
dr.addFolder('/Volumes/RCS_DATA/RCS02/log_data/dreem_data');
dr.loadData()
%%
adaptiveLogTable = table();
eventsCat = categorical();
adaptiveLogTable = adaptiveLogTableOut;
adaptiveLogTableSorted = sortrows(adaptiveLogTable,{'time'},'ascend');
time = adaptiveLogTableSorted.time;
events = adaptiveLogTableSorted.newstate;
gammaEvents = {};
thetaEvents = {};
for e = 1:length(events)
    switch events(e)
        case {0,3,6}
            gammaEvents{e,1} = 'low gamma';
        case {1,4,7}
            gammaEvents{e,1} = 'med gamma';
        case {2,5,8}
            gammaEvents{e,1} = 'high gamma';
    end
    
    switch events(e)
        case {0,1,2}
            thetaEvents{e,1} = 'low theta';
        case {3,4,5}
            thetaEvents{e,1} = 'med theta';
        case {6,7,8}
            thetaEvents{e,1} = 'high theta';
    end
    
end
eventsCat(:,1) = categorical(gammaEvents);
eventsCat(:,2) = categorical(thetaEvents);
current = adaptiveLogTableSorted.prog0;

%%
hfig = figure;
hfig.Color = 'w';
hsbUse = gobjects();



for i = 1:2
    cnt = 1;
    eventsUse = categorical();
    timeUse = [];
    currentUse = [];
    
    hsbUse(i,1) = subplot(4,1,i);
    timeUse(cnt) = datenum(datevec(time(1)));
    eventsUse(cnt) = eventsCat(1,i);
    
    events = eventsCat(:,i);
    cnt = cnt + 1;
    for e = 1:length(events)
        if e > 1
            if events(e) ~= events(e-1)
                timeUse(cnt) = datenum(datevec(time(e)));
                eventsUse(cnt) = events(e-1);
                cnt = cnt + 1;
            end
        end
        timeUse(cnt) = datenum(datevec(time(e)));
        eventsUse(cnt) = events(e);
        cnt = cnt + 1;
    end
    
    hplt = plot(  hsbUse(i,1),timeUse,...
        eventsUse,'LineWidth',2,'Color',[0.8 0 0 0.6]);
    
    timeStart = dateshift(datetime(datevec(timeUse(1))) - hours(1),'start','hour');
    timeEnd   = dateshift(datetime(datevec(timeUse(end))) + hours(1),'start','hour');
    xticks = datenum(timeStart : minutes(15) : timeEnd);
    
    hsbUse(i,1).XTick = xticks;
    datetick('x',21,'keepticks','keeplimits');
    hsbUse(i,1).XTickLabelRotation = 45;
end


cnt = 1;
eventsUse = categorical();
timeUse = [];
currentUse = [];

hsbUse(3,1) = subplot(4,1,3);
timeUse(cnt) = datenum(datevec(time(1)));
current = adaptiveLogTableSorted.prog0;
currentUse(cnt) = current(1);

cnt = cnt + 1;
for e = 1:length(current)
    if e > 1
        if current(e) ~= current(e-1)
            timeUse(cnt) = datenum(datevec(time(e)));
            currentUse(cnt) = current(e-1);
            cnt = cnt + 1;
        end
    end
    timeUse(cnt) = datenum(datevec(time(e)));
    currentUse(cnt) = current(e);
    cnt = cnt + 1;
end
hplt = plot(  hsbUse(3,1),timeUse,...
    currentUse,'LineWidth',2,'Color',[0 0.8 0 0.6]);
datetick('x',15,'keepticks','keeplimits');
hsbUse(i,1).XTickLabelRotation = 45;



hsbUse(4,1) = subplot(4,1,4);
dreemDataTable = dr.Data(2).dataDreem;
dr.plotData(dreemDataTable,hsbUse(4,1))




linkaxes(hsbUse,'x');



%% plot data from fast adaptive

ff = findFilesBVQX('/Volumes/RCS_DATA/RCS05/fast_adbs_session2/RCS05R','Device*',struct('dirs',1));
% 2 = self triggering 
% 7 = open loop 1000ms 
% 15 = adaptive 
% 22 = second protocl - 20 min 
close all;
run0 = 6; % opne lop 
run1 = [10 : 15];
run2 = [23];
for f = run2 %1:length(ff)
    %%
    rc = rcsPlotter();
    % rc.addFolder('/Volumes/RCS_DATA/RCS05/fast_adbs/RCS05R/Session1614985978346/DeviceNPC700415H');
    % rc.addFolder('/Volumes/RCS_DATA/RCS05/fast_adbs/RCS05R/Session1614981259124/DeviceNPC700415H');
    rc.addFolder(ff{f})
    rc.loadData();
    
    
    hfig = figure;
    hfig.Color = 'w';
    cntplt = 1;
    nrows = 5;
    hsb = gobjects();
    
    hsb(cntplt,1) = subplot(nrows,1,cntplt); cntplt = cntplt + 1;
    rc.plotTdChannel(1, hsb(cntplt-1,1) );
    hax = hsb(cntplt-1,1);
    hax = hsb(cntplt-1,1);
    timeStart = dateshift(datetime(datevec(hax.XLim(1))) ,'start','minute');
    timeEnd   = dateshift(datetime(datevec(hax.XLim(2))) ,'end','minute');
    xticks = datenum(timeStart : seconds(0.5) : timeEnd);
    hax.XTick = xticks;
    datetick('x','MM:SS.FFF','keepticks','keeplimits');
    grid(hax,'on');
    hax.GridAlpha = 0.4;
    hax.Layer = 'top';
    
    
    
    hsb(cntplt,1) = subplot(nrows,1,cntplt); cntplt = cntplt + 1;
    rc.plotTdChannelBandpass(1,[23.44 29.30], hsb(cntplt-1,1) );
    hax = hsb(cntplt-1,1);
    timeStart = dateshift(datetime(datevec(hax.XLim(1))) ,'start','minute');
    timeEnd   = dateshift(datetime(datevec(hax.XLim(2))) ,'end','minute');
    xticks = datenum(timeStart : seconds(0.5) : timeEnd);
    hax.XTick = xticks;
    datetick('x','MM:SS.FFF','keepticks','keeplimits');
    grid(hax,'on');
    hax.GridAlpha = 0.4;
    hax.Layer = 'top';
    
    
    
    hsb(cntplt,1) = subplot(nrows,1,cntplt); cntplt = cntplt + 1;
    rc.plotTdChannelBandpass(1,[82.03 91.8], hsb(cntplt-1,1) );
    hax = hsb(cntplt-1,1);
    timeStart = dateshift(datetime(datevec(hax.XLim(1))) ,'start','minute');
    timeEnd   = dateshift(datetime(datevec(hax.XLim(2))) ,'end','minute');
    xticks = datenum(timeStart : seconds(0.5) : timeEnd);
    hax.XTick = xticks;
    datetick('x','MM:SS.FFF','keepticks','keeplimits');
    grid(hax,'on');
    hax.GridAlpha = 0.4;
    hax.Layer = 'top';
    
    
    
    
    hsb(cntplt,1) = subplot(nrows,1,cntplt); cntplt = cntplt + 1;
    rc.plotAdaptiveLd(0,hsb(cntplt-1,1));
    hax = hsb(cntplt-1,1);
    timeStart = dateshift(datetime(datevec(hax.XLim(1))) ,'start','minute');
    timeEnd   = dateshift(datetime(datevec(hax.XLim(2))) ,'end','minute');
    xticks = datenum(timeStart : seconds(0.5) : timeEnd);
    hax.XTick = xticks;
    datetick('x','MM:SS.FFF','keepticks','keeplimits');
    grid(hax,'on');
    hax.GridAlpha = 0.4;
    hax.Layer = 'top';
    
    
    
    hsb(cntplt,1) = subplot(nrows,1,cntplt); cntplt = cntplt + 1;
    rc.plotAdaptiveCurrent(0,hsb(cntplt-1,1));
    title(hsb(cntplt-1,1),'current');
    hax = hsb(cntplt-1,1);
    timeStart = dateshift(datetime(datevec(hax.XLim(1))) ,'start','minute');
    timeEnd   = dateshift(datetime(datevec(hax.XLim(2))) ,'end','minute');
    xticks = datenum(timeStart : seconds(0.5) : timeEnd);
    hax.XTick = xticks;
    datetick('x','MM:SS.FFF','keepticks','keeplimits');
    grid(hax,'on');
    hax.GridAlpha = 0.4;
    hax.Layer = 'top';
    
    
    
    linkaxes(hsb,'x');
    
    
    rc.reportEventData;
    %%
end




%% load folder
ff = findFilesBVQX('/Volumes/RCS_DATA/RCS05/fast_adbs_session2/RCS05R','Device*',struct('dirs',1));
ff = findFilesBVQX('/Volumes/RCS_DATA/RCS02/new_settings_slow_gamms/SummitContinuousBilateralStreaming','Device*',struct('dirs',1));
rc =rcsPlotter();
for f = 1:length(ff)
    rc.addFolder(ff{f});
end
rc.loadData();



%% RCS02 new 8-9 data 
clear all; clc; close all;
dropboxdir = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database';
reportsDir = fullfile(dropboxdir,'reports');
databaseFile = fullfile(dropboxdir,'database_from_device_settings.mat');
load(databaseFile);
idxkeep  = cellfun(@(x) istable(x),masterTableOut.stimStatus) & logical(masterTableOut.recordedWithScbs);
dbUse    = masterTableOut(idxkeep,:);
dbUse.duration.Format = 'hh:mm:ss';



idxpat       = strcmp(dbUse.patient,'RCS02');
% idxside      = strcmp(dbUse.side,'L');
allDays = dateshift(dbUse.timeStart,'start','day');
dateRange = datetime({'18-Mar-2021' , '20-Mar-2021'},'TimeZone',allDays.TimeZone);
idxday = allDays >= dateRange(1)  & allDays <= dateRange(2) ;
idxconcat = idxpat  & idxday;
patDBtoConcat = dbUse(idxconcat,:);


%%
masterTableLightOut = patDBtoConcat;

sidesUses = {'L','R'}; 
outData = struct(); 
outData(1).rc = rcsPlotter();
outData(2).rc = rcsPlotter();
for s = 1: length(sidesUses)
    idxuse = strcmp(sidesUses{s},masterTableLightOut.side); 
    
    patDBtoConcat = masterTableLightOut(idxuse,:);
    for ss = 1:size(patDBtoConcat,1)
        [pn,fn] = fileparts( patDBtoConcat.deviceSettingsFn{ss});
        outData(s).rc.addFolder(pn);
    end
end
outData(1).rc.loadData();
outData(2).rc.loadData();
%%
close all;
hfig = figure;
hfig.Color = 'w';
cntplt = 1;
nrows = 7;
hsb = gobjects();
% 
% % stn
% for s = 1: length(sidesUses)
%     hsb(cntplt,1) = subplot(nrows,1,cntplt); cntplt = cntplt + 1;
%     hax =  hsb(cntplt-1,1);
%     outData(s).rc.plotTdChannelSpectral(1, hax);
%     substr = outData(s).rc.Data(1).metaData.subjectID;
%     hax.Title.String = [substr ' ' hax.Title.String];
% 
% end
% 
% % mc
% for s = 1: length(sidesUses)
%     hsb(cntplt,1) = subplot(nrows,1,cntplt); cntplt = cntplt + 1;
%     hax =  hsb(cntplt-1,1);
%     outData(s).rc.plotTdChannelSpectral(3, hax);
%     substr = outData(s).rc.Data(1).metaData.subjectID;
%     hax.Title.String = [substr ' ' hax.Title.String];
% end


% ld 0 

for s = 1: length(sidesUses)
    hsb(cntplt,1) = subplot(nrows,1,cntplt); cntplt = cntplt + 1;
    hax =  hsb(cntplt-1,1);
    outData(s).rc.plotAdaptiveLd(0, hax);
    substr = outData(s).rc.Data(1).metaData.subjectID;
    ythres = [100 150 200 250];
    for i = 1:length(ythres)
        plot(hax.XLim,[ythres(i) ythres(i)],'Color',[0 0.8 0 0.5],'LineWidth',1,'LineStyle','-.');
    end
    set(hax,'YLim',[0 400])
    hax.Title.String{1} = [substr ' ' hax.Title.String{1}];
end

% ld 1
for s = 1: length(sidesUses)
    hsb(cntplt,1) = subplot(nrows,1,cntplt); cntplt = cntplt + 1;
    hax =  hsb(cntplt-1,1);
    outData(s).rc.plotAdaptiveLd(1, hax);
    ythres = [20e3 30e3 40e3 50e3];
    for i = 1:length(ythres)
        plot(hax.XLim,[ythres(i) ythres(i)],'Color',[0 0.8 0 0.5],'LineWidth',1,'LineStyle','-.');
    end

    substr = outData(s).rc.Data(1).metaData.subjectID;
    hax.Title.String{1} = [substr ' ' hax.Title.String{1}];
end

% plot current 
for s = 1: length(sidesUses)
    hsb(cntplt,1) = subplot(nrows,1,cntplt); cntplt = cntplt + 1;
    hax =  hsb(cntplt-1,1);
    outData(s).rc.plotAdaptiveCurrent(0, hax);
    
    hax.YLim = [1 4];
    substr = outData(s).rc.Data(1).metaData.subjectID;
    hax.Title.String{1} = [substr ];
end

% acc 
hsb(cntplt,1) = subplot(nrows,1,cntplt); cntplt = cntplt + 1;
hax =  hsb(cntplt-1,1);
outData(1).rc.plotActigraphyChannel('X', hax);
outData(2).rc.plotActigraphyChannel('X', hax);
substr = outData(1).rc.Data(1).metaData.subjectID;
hax.Title.String = [ 'L + R ' hax.Title.String];

linkaxes(hsb,'x');



