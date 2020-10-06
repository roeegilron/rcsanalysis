function plot_stim_titration_rcs02_2d_detector()
%% load data 
fname = '/Users/roee/Starr Lab Dropbox/RC02LTE/SummitData/StarrLab/RCS02L/Session1601400230611/DeviceNPC700398H';
% fname = '/Users/roee/Starr Lab Dropbox/RCS05/SummitData/StarrLab/RCS05L/Session1601652329022/DeviceNPC700414H';
[outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerOut,adaptiveTable] =  MAIN_load_rcs_data_from_folder(fname);
allDeviceSettingsOut = findFilesBVQX(fname,'DeviceSettings.json');
dSettings = get_meta_data_from_device_settings_file(allDeviceSettingsOut{1});
%%
idxStartStop = cellfun(@(x) any(strfind(x,'mA')),eventTable.EventSubType);
eventTableUse = eventTable(idxStartStop,:); 
idxStart = cellfun(@(x) any(strfind(lower(x),'start')),eventTableUse.EventSubType);
idxEnd = cellfun(@(x) any(strfind(lower(x),'end')),eventTableUse.EventSubType);
eStart = eventTableUse(idxStart,:);
eEnd = eventTableUse(idxEnd,:);
for e = 1:size(eStart,1)
    times(e,1) = datetime(eStart.UnixOffsetTime(e));
    times(e,2) = datetime(eEnd.UnixOffsetTime(e));
end
stimLevels = cellfun(@(x) str2num(x),cellfun(@(x) regexp(x,'[0-9]+.[0-9]','match'),eStart.EventSubType));
stimLevelsStr = cellfun(@(x) regexp(x,'[0-9]+.[0-9]','match'),eStart.EventSubType);
%% plot 
hfig = figure;
hfig.Color = 'w'; 
timenum = powerOut.powerTable.PacketRxUnixTime; 
 t = datetime(timenum/1000,'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
 times.TimeZone = t.TimeZone; 
 pt = powerOut.powerTable; 
 hold on;
for e = 1:size(times,1)
    idxuse = t > times(e,1) & t < times(e,2);
    y = pt.Band1(idxuse);
    x = pt.Band2(idxuse);
    fprintf('%d\n',length(x));
    scatter(mean(x),mean(y),500,'filled','MarkerFaceAlpha',0.2);
    xlabel(['power STN - ' powerOut.bands(1).powerBandInHz{2}]);
    ylabel(['power STN - ' powerOut.bands(1).powerBandInHz{1}]);
    text(mean(x),mean(y),stimLevelsStr{e});
end
set(gca,'FontSize',16);
legend(stimLevelsStr);
title('2D power bands - STN Beta vs Stim power');
end