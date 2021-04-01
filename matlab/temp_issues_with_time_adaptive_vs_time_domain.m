%% 
clear all;
close all;
load('/Volumes/RCS_DATA/RCS05/fast_adbs_session2/RCS05R/Session1615413255464/DeviceNPC700415H/AllDataTables.mat');
Adaptive_fileToLoad = '/Volumes/RCS_DATA/RCS05/fast_adbs_session2/RCS05R/Session1615413255464/DeviceNPC700415H/AdaptiveLog.json';
jsonobj_Adaptive = deserializeJSON(Adaptive_fileToLoad);

outtable_Adaptive = createAdaptiveTable(jsonobj_Adaptive);

idxkeepadaptive = outtable_Adaptive.PacketGenTime > 0;

timeFormat = sprintf('%+03.0f:00',-8);



inputDataTable = outtable_Adaptive;
% Pull out info for each packet
indicesOfTimestamps = find(~isnan(inputDataTable.timestamp));
dataTable_original = inputDataTable(indicesOfTimestamps,:);

%
% Identify packets for rejection

disp('Identifying and removing bad packets')
% Remove any packets with timestamp that are more than 24 hours from median timestamp
medianTimestamp = median(dataTable_original.timestamp);
numSecs = 24*60*60;
badDatePackets = union(find(dataTable_original.timestamp > medianTimestamp + numSecs),find(dataTable_original.timestamp < medianTimestamp - numSecs));

% Negative PacketGenTime
packetIndices_NegGenTime = find(dataTable_original.PacketGenTime <= 0);

% Consecutive packets with identical dataTypeSequence and systemTick;
% identify the second packet for removal; identify the first
% instance of these duplicates below
duplicate_firstIndex = intersect(find(diff(dataTable_original.dataTypeSequence) == 0),...
    find(diff(dataTable_original.systemTick) == 0));

% Identify packetGenTimes that go backwards in time by more than 500ms; may overlap with negative PacketGenTime
packetGenTime_diffs = diff(dataTable_original.PacketGenTime);
diffIndices = find(packetGenTime_diffs < -500 );

% Need to remove [diffIndices + 1], but may also need to remove subsequent
% packets. Automatically remove the next packet [diffIndices + 2], as this is easier than
% trying to confirm there is enough time to assign to samples without
% causing overlap.
% Remove at most 6 adjacent packets (to prevent large un-needed
% packet rejection driven by positive outliers)
numPackets = size(dataTable_original,1);
indices_backInTime = [];
for iIndex = 1:length(diffIndices)
    counter = 3; % Automatically removing two packets, start looking at the third
    
    % Check if next packet indices exists in the recording
    if (diffIndices(iIndex) + 1) <= numPackets
        indices_backInTime = [indices_backInTime (diffIndices(iIndex) + 1)];
    end
    if (diffIndices(iIndex) + 2) <= numPackets
        indices_backInTime = [indices_backInTime (diffIndices(iIndex) + 2)];
    end
    
    % If there are more packets after this, check if they need to also be
    % removed
    while (counter <= 6) &&  (diffIndices(iIndex) + counter) <= numPackets &&...
            dataTable_original.PacketGenTime(diffIndices(iIndex) + counter)...
            < dataTable_original.PacketGenTime(diffIndices(iIndex))
        
        indices_backInTime = [indices_backInTime (diffIndices(iIndex) + counter)];
        counter = counter + 1;
    end
end

% Collect all packets to remove
packetsToRemove = unique([badDatePackets; packetIndices_NegGenTime;...
    duplicate_firstIndex + 1; indices_backInTime']);

% Remove packets identified above for rejection
packetsToKeep = setdiff(1:size(dataTable_original,1),packetsToRemove);
dataTable = dataTable_original(packetsToKeep,:);

clear dataTable_original
outtable_Adaptive = dataTable;

%%
close all; 
hfig = figure;
hfig.Color = 'w';
cntplt = 1;
nrows = 2;
hsb = gobjects();


% time domai n
hsb(cntplt,1) = subplot(nrows,1,cntplt); cntplt = cntplt + 1;
hplt = plot(datenum(timeDomainData.localTime),timeDomainData.key0); 
xTime = timeDomainData.localTime;
row = dataTipTextRow('local time',xTime);
hplt.DataTipTemplate.DataTipRows(end+1) = row;

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


packetGenTimeHuman =  datetime(outtable_Adaptive.PacketGenTime./1000,...
    'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');



hsb(cntplt,1) = subplot(nrows,1,cntplt); cntplt = cntplt + 1;
cur = outtable_Adaptive.CurrentProgramAmplitudesInMilliamps(:,1);
hplt = plot(datenum(packetGenTimeHuman),cur,'Color',[0 0.8 0 0.7]); 
xTime = packetGenTimeHuman;
row = dataTipTextRow('local time',xTime);
hplt.DataTipTemplate.DataTipRows(end+1) = row;

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

linkaxes(hsb,'x');
