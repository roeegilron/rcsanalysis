function temp_analyze_movement_stim_titration()
%% load data
clc
% close all;
% clear all; 
fn = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v17_stim_titration/RCS01-home-computer-selected/Session1551900100610/DeviceNPC700395H';
[outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerTable] =  MAIN_load_rcs_data_from_folder(fn);


%% plot power data
% time - PacketGenTime is time in miliseconds backstamped to where it in UTC since Jan 1 1970. 
% this is when it hit the bluetooth on computer 
% systemTick ? INS clock-driven tick counter, 16bits, LSB is 100microseconds, (highly accurate, high resolution, rolls over)
% timestamp ? INS clock-driven time, LSB is seconds (highly accurate, low resolution, does not roll over)
% PacketGenTime ? API estimate of when the data packet was created on the INS within the PC clock domain. Estimate created by using results of latest latency check (one is done at system initialization, but can re-perform whenever you want) and time sync streaming. Potentially useful for syncing with other sensors or devices by bringing things into the PC clock domain, but is only accurate within 50ms give or take.
% PacketRxUnixTime ? PC clock-driven time when the packet was received via Bluetooth, as accurate as a C# DateTime.now (10-20ms)
% SampleRate ? defined in HTML doc as enum TdSampleRates: 0x00 is 250Hz, 0x01 is 500Hz, 0x02 is 1000Hz, 0xF0 is disabled

uxtimes = datetime(powerTable.PacketRxUnixTime/1000,...
    'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');

bandsUse = [1 2 5 6 7 8] ;
freBands = {'16.97 - 23.8Hz',...
    '7.93 - 13.79Hz',...
    '6.71 - 13.79z',...
    '16.97 - 24.05Hz',...
    '4.52 - 6.96Hz',...
    '16.97 - 21.61Hz'};
nmplts   = length(bandsUse)
hfig = figure;
for b = 1:length(bandsUse);
    hsub(b) = subplot(nmplts,1,b);
    bandsfn = sprintf('Band%d',bandsUse(b));
    hplt = plot(uxtimes,powerTable.(bandsfn),'LineWidth',2,'Color',[0 0 0.8 0.8]);
    ylims = get(gca,'YLim'); 
    hold on; 
    t = eventTable.UnixOffsetTime;
    plot([t t],ylims); 
    title(freBands{b});
    set(hsub(b),'FontSize',16);
end
linkaxes(hsub,'x');

%% compare each power range with histgogram 
idxRest = []; 
possidx = strcmp(eventTable.EventSubType,'1') | ... 
    strcmp(eventTable.EventSubType,'2'); 
eventTab = eventTable(possidx,:);
eventNum = str2num(cell2mat(eventTab.EventSubType));
e = 1;
while e < size(eventTab,1)-1
    if eventNum(e) == 1 & eventNum(e+1) == 2 
        timeStart = eventTab.UnixOnsetTime(e);
        timeEnd = eventTab.UnixOnsetTime(e+1);
        idxUse = find(uxtimes > timeStart & uxtimes < timeEnd);
        idxRest = [idxRest, idxUse'];
        e = e+1; 
    else
        e = e+1; 
    end
end


idxMove = []; 
possidx = strcmp(eventTable.EventSubType,'3') | ... 
    strcmp(eventTable.EventSubType,'4'); 
eventTab = eventTable(possidx,:);
eventNum = str2num(cell2mat(eventTab.EventSubType));
e = 1;
while e < size(eventTab,1)-1
    if eventNum(e) == 3 & eventNum(e+1) == 4 
        timeStart = eventTab.UnixOnsetTime(e);
        timeEnd = eventTab.UnixOnsetTime(e+1);
        idxUse = find(uxtimes > timeStart & uxtimes < timeEnd);
        idxMove = [idxMove, idxUse'];
        e = e+1; 
    else
        e = e+1; 
    end
end


bandsUse = [1 2 5 6 7 8] ;
freBands = {'STN 0-3 16.97 - 23.8Hz',...
    'STN 7.93 - 13.79Hz',...
    'M1 8-10 6.71 - 13.79z',...
    'M1 8-10 16.97 - 24.05Hz',...
    'M1 9-11 4.52 - 6.96Hz',...
    'M1 9-11 16.97 - 21.61Hz'};
nmplts   = length(bandsUse);
hfig = figure;
for b = 1:length(bandsUse);
    hsub(b) = subplot(3,2,b);
    bandsfn = sprintf('Band%d',bandsUse(b));
    y = powerTable.(bandsfn);
    h = histogram(y(idxRest)); 
    h.Normalization = 'probability';
    h.BinWidth = 10e3;
    hold on; 
    h = histogram(y(idxMove)); 
    h.Normalization = 'probability';
    h.BinWidth = 10e3;
    legend('rest','move');
    ylabel('probability'); 
    title(freBands{b});
    set(gca,'FontSize',16);
end
linkaxes(hsub,'x');
figdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v17_stim_titration/figures';
fnmuse = fullfile(figdir,'stim titration histogram');
savefig(fnmuse);
%% plot ROC curve for rest / move 
bandsUse = [1 2 5 6 7 8] ;
freBands = {'STN 0-3 16.97 - 23.8Hz',...
    'STN 7.93 - 13.79Hz',...
    'M1 8-10 6.71 - 13.79z',...
    'M1 8-10 16.97 - 24.05Hz',...
    'M1 9-11 4.52 - 6.96Hz',...
    'M1 9-11 16.97 - 21.61Hz'};
nmplts   = length(bandsUse);
hfig = figure;
hDataCursor = datacursormode(hfig);
set(hDataCursor,'UpdateFcn',@dataCursUpdateFunction,'Enable','on');


for b = 1:length(bandsUse);
    hsub(b) = subplot(3,2,b);
    bandsfn = sprintf('Band%d',bandsUse(b));
    
    y = powerTable.(bandsfn);
    % rest scores 
    scoresRest = y(idxRest); 
    labelsRest = repmat({'rest'},length(idxRest),1);
    % move scores 
    scoresMove = y(idxMove);
    labelsMove = repmat({'move'},length(idxMove),1);
    % concatneate 
    scores = [scoresRest ; scoresMove]; 
    labels = [labelsRest ; labelsMove]; 
    % compute roc 
    [X,Y,T,AUC,OPTROCPT] = perfcurve(labels,scores,'rest');
    idxOpt = find( X == OPTROCPT(1) & Y == OPTROCPT(2),1);
    % plot roc 
    userDat.X = X; 
    userDat.Y = Y; 
    userDat.T = T; 
    userDat.AUC = AUC; 
    userDat.OPTROCPT = OPTROCPT; 
    userDat.idxOpt = idxOpt; 
    userDat.freqBand = freBands{b}; 
    
    hsub(b).UserData = userDat;
    setappdata(hsub(b),'AssetData',userDat);

    hplt = plot(hsub(b),X,Y,'UserData',userDat);
    hplt.LineWidth = 3; 
    hplt.Color = [0 0 0.8 0.7];
    xlabel('False positive rate')
    ylabel('True positive rate')
    ttlUse = sprintf('%s (AUC %.2f)',freBands{b},AUC);
    title(ttlUse);
    set(gca,'FontSize',16);
end
%
return 


%% load data from different files and compare 
rootdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v17_stim_titration/RCS01-home-computer-selected';
srcStr  = {'919','255','047'};
stimRts = {'2.0ma','3.0ma','3.5ma'}; 
codesUse = {'1' '2'}; 
conds    = 'rest'; 
hfig = figure; 
for i = 1:4; 
    hsub(i) = subplot(2,2,i); 
    hold on; 
end
for s = 1:length(srcStr)
    sesDir = findFilesBVQX(rootdir,['Sess*' srcStr{s}],struct('dirs',1,'depth',1)); 
    DevDir = findFilesBVQX(sesDir{1},['Device*' ],struct('dirs',1,'depth',1)); 
    [outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerTable] =  MAIN_load_rcs_data_from_folder(DevDir{1});
    % exceptions 
    
    if ~1 
    else
        codeAfterExp = codesUse{1};
    end
    
    idxStart = find(cellfun(@(x) strcmp(x,codeAfterExp),eventTable.EventSubType),1);
    timeStart = eventTable.UnixOffsetTime(idxStart(1));
    
    % exeptions 
    if s == 3 
        codeAfterExp = codesUse{1};
    else
        codeAfterExp = codesUse{2};
    end
    
    idxStop = find(cellfun(@(x) strcmp(x,codeAfterExp),eventTable.EventSubType),1);
    timeStop = eventTable.UnixOffsetTime(idxStop(1));
    
    times = outdatcomplete.derivedTimes; 
    idxuse = times > timeStart  & times < timeStop;
    fprintf('event start %s events stop %s file range %s %s\n',...
        timeStart,timeStop,outdatcomplete.derivedTimes(1),outdatcomplete.derivedTimes(end));
    timesuse = outdatcomplete.derivedTimes(idxuse);
    if sum(idxuse> 500) % make sure there is data to plot
        for c = 1:4
            fnm = sprintf('key%d',c-1);
            y = outdatcomplete.(fnm)(idxuse);
            y = y - mean(y);
            srate = str2num(strrep(outRec(1).tdData(c).sampleRate,'Hz',''));
            [fftOut,f]   = pwelch(y,srate,srate/2,0:1:srate/2,srate,'psd');
            hplt = plot(hsub(c),f,log10(fftOut),'Parent',hsub(c));
            hplt.LineWidth = 2;
            xlabel(hsub(c),'Frequency (Hz)');
            ylabel(hsub(c),'Power (log_1_0\muV^2/Hz)');
        end
    end
    
end


end

function txt = dataCursUpdateFunction(~,event_obj)
% Customizes text of data tips
hAxes = get(get(event_obj,'Target'),'Parent');
assetData = getappdata(hAxes,'AssetData');
pos = get(event_obj,'Position');
idxUse = find(event_obj.Target.UserData.X == pos(1) & event_obj.Target.UserData.Y == pos(2),1);
ud = event_obj.Target.UserData;

txt = {sprintf('FP = %.2f',ud.X(idxUse) ) ,...
       sprintf('TP = %.2f',ud.Y(idxUse) ) ,...
       sprintf('Threshold = %.2f',ud.T(idxUse) ),...
       sprintf('AUC = %.2f, opt Thresh = %f',ud.AUC,ud.T(ud.idxOpt) ) };
end