function plot_embedded_adaptive_data_multiple_folders_SSCM()

%% clear stuff
clear all; close all; clc;
%% get folder list
rootdir = '/Volumes/RCS_DATA/adaptive_at_home_testing';
patfolders = findFilesBVQX(rootdir,'RCS*',struct('depth',1,'dirs',1));
%%
fprintf('patients found:\n')
for p = 1:length(patfolders)
    [pn,fn] = fileparts(patfolders{p});
    patientnum(p) = str2num(fn(end-1:end));
    fprintf('[%0.2d]\n', patientnum(p));
    % find sides
    sidefolders = findFilesBVQX(patfolders{p},'RCS*',struct('depth',1,'dirs',1));
    for s = 1:length(sidefolders)
        MAIN_report_data_in_folder(sidefolders{s});
    end
end
%% concantenat all folders and plot report
tblfn = findFilesBVQX(rootdir,'database.mat');
for t = 1:length(tblfn)
    load(tblfn{t},'tblout')
    if t == 1
        tblall = tblout;
    else
        tblall = [tblall; tblout];
    end
    clear tblout;
end

%% decide if you want to print all adaptive data or just print one side / one patients
unqpatients = unique(tblall.patient);
plotwhat = input('choose patient and side (1) or plot all(2)? ');
if plotwhat == 1 % choose patients and side
    fprintf('choose patient by idx\n');
    unqpatients = unique(tblall.patient);
    for uu = 1:length(unqpatients)
        fprintf('[%0.2d] %s\n',uu,unqpatients{uu})
    end
    patidx = input('patientidx ?');
    patientsUse = unqpatients(patidx);
    sideix = input('choose side (L (1)  R  (2)) ?');
    if sideix == 1
        sidesUse{1} = 'L';
    else
        sidesUse{1} = 'R';
    end
elseif plotwhat == 2 % plot all
    patientsUse = unqpatients;
    sidesUse = {'L','R'};
end

mintrim = 10;
min_duration_day = hours(1);

allcur = [];
%%
for ppp = 1:length(patientsUse)
    for sss = 1:length(sidesUse)
        % find patient and side to plot
        patient = patientsUse{ppp};
        side    = sidesUse{sss};
        idxuse = strcmp(tblall.patient,patient) & strcmp(tblall.side,side);
        tbluse = tblall(idxuse,:);
        
        % find the unique days in each recording
        timeDomainFileDur(:,1) = tbluse.startTime;
        timeDomainFileDur(:,2) = tbluse.startTime + duration;
        idxNotSameDay = day(timeDomainFileDur(:,1)) ~= day(timeDomainFileDur(:,2));
        allTimesSameDay = timeDomainFileDur(~idxNotSameDay,:);
        allTimesDiffDay = timeDomainFileDur(idxNotSameDay,:);
        % for idx that is not the same day, split it
        newTimesDay1 = [allTimesDiffDay(:,1) (allTimesDiffDay(:,1) - timeofday(allTimesDiffDay(:,1)) + day(1)) - minutes(1)];
        newTimesDay2 = [((allTimesDiffDay(:,2) - timeofday(allTimesDiffDay(:,2))) + minutes(2)  ) allTimesDiffDay(:,2) ];
        % concatenate all times
        allTimesNew  = sortrows([allTimesSameDay ; newTimesDay1 ; newTimesDay2],1);
        daysUse      = day(allTimesNew);
        montsUse     = month(allTimesNew);
        unqMonthsAndDays = sortrows(unique([montsUse(:,1) daysUse(:,1) ],'rows'),[1 2],'ascend');
        
        % choose index to plot
        if plotwhat == 1 % plot specific day
            
            fprintf('choose unique montn and day index to plot:\n');
            for u = 1:size(unqMonthsAndDays,1)
                fprintf('[%0.2d] %0.2d / %0.2d\n',u,unqMonthsAndDays(u,1),unqMonthsAndDays(u,2))
            end
            idxchoose = input('choose idx: ');
            
            idxday = (day(tbluse.rectime) ==  unqMonthsAndDays(idxchoose,2)) & (month(tbluse.rectime) ==  unqMonthsAndDays(idxchoose,1));
            tblPlot = tbluse(idxday,:);
            numberUnique = 1;
        else
            numberUnique = length(unqMonthsAndDays);
        end
        
        
        for uuu = 1:numberUnique
            if plotwhat == 2 % plot all days
                idxday = (day(tbluse.rectime) ==  unqMonthsAndDays(uuu,2)) & (month(tbluse.rectime) ==  unqMonthsAndDays(uuu,1));
                tblPlot = tbluse(idxday,:);
            end
            % check if this day length is longer than min length defined
            
            
            %% set up figure
            hfig = figure;
            hfig.Color = 'w';
            nrows = 2;
            for i = 1:nrows
                hsb(i) = subplot(nrows,1,i);
                hold(hsb(i),'on');
            end
            % sgtitle(hfig,titleuse,'FontSize',24);
            % order plot - default
            % (1) detector
            % (2) power
            % (3) acc
            % (4) current
            orderplot = [1 2];
            for t = 1:size(tblPlot,1)
                try
                    %% set up params
                    idxorder  = 1;
                    [pn,fn,ext] = fileparts(tblPlot.tdfile{t});
                    diruse = fullfile(rootdir,tblPlot.patient{t},[tblPlot.patient{t} tblPlot.side{t}], tblPlot.sessname{t},tblPlot.device{t});
                    params.dir    = diruse;
                    %% load data
                    % load acc
                    if exist(fullfile(params.dir,'RawDataAccel.mat'),'file')
                        load(fullfile(params.dir,'RawDataAccel.mat'));
                        outdatcompleteAcc = outdatcomplete;
                        clear outdatcomplete;
                    else
                        fileload = fullfile(params.dir,'RawDataAccel.json');
                        [pn,fn,ext] = fileparts(fileload);
                        if exist(fullfile(pn,[fn '.mat']),'file')
                            load(fullfile(pn,[fn '.mat']));
                            outdatcompleteAcc = outdatcomplete;
                            clear outdatcomplete;
                        else
                            [outdatcompleteAcc, ~, ~] = MAIN(fileload);
                        end
                    end
                    % load device settings
                    fileLoadDeviceSettings = fullfile(params.dir,'DeviceSettings.json');
                    deviceSettingsStruc = loadDeviceSettings(fileLoadDeviceSettings);
                    % load power
                    fileloadPower = fullfile(params.dir,'RawDataPower.json');
                    [pn,fn,ext] = fileparts(fileloadPower);
                    clear powerTable;
                    if exist(fullfile(pn,[fn '.mat']),'file')
                        load(fullfile(pn,[fn '.mat']));
                    else
                        [powerTable, pbOut]  = loadPowerData(fileloadPower);
                    end
                    
                    %% load adaptive
                    fnAdaptive = fullfile(params.dir,'AdaptiveLog.json');
                    res = readAdaptiveJson(fnAdaptive);
                    
                    %% plower DETECTOR  adaptive + current + power
                    axes(hsb(orderplot(idxorder)));
                    cur = res.adaptive.CurrentProgramAmplitudesInMilliamps(1,:);
                    timestamps = datetime(datevec(res.timing.timestamp./86400 + datenum(2000,3,1,0,0,0))); % medtronic time - LSB is seconds
                    uxtimes = datetime(res.timing.PacketGenTime/1000,...
                        'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
                    yearUse = mode(year(uxtimes));
                    idxKeepYear = year(uxtimes)==yearUse;
                    
                    
                    % inputs
                    ld0 = res.adaptive.LD0_output(idxKeepYear);
                    ld0_high = res.adaptive.LD0_highThreshold(idxKeepYear);
                    ld0_low  = res.adaptive.LD0_lowThreshold(idxKeepYear);
                    timesUseDetector = uxtimes(idxKeepYear);
                    idxkeepdet = timesUseDetector > (timesUseDetector(1) + minutes(mintrim));
                    
                    timesUseDetector = timesUseDetector(idxkeepdet);
                    ld0 = ld0(idxkeepdet);
                    ld0_high = ld0_high(idxkeepdet);
                    ld0_low = ld0_low(idxkeepdet);
                    
                    % get rid of negative diffs (e.g. times for past)
                    idxbad = find(seconds(diff(timesUseDetector))<0)+1;
                    idxkeep = setxor(1:length(timesUseDetector),idxbad);
                    timesUseDetector = timesUseDetector(idxkeep);
                    ld0 = ld0(idxkeep);
                    ld0_high = ld0_high(idxkeep);
                    ld0_low = ld0_low(idxkeep);
                    
                    
                    hplt = plot(hsb(orderplot(idxorder)),timesUseDetector,ld0,'LineWidth',2.5,'Color',[0 0 0.8 ]);
                    hplt = plot(hsb(orderplot(idxorder)),timesUseDetector,ld0_high,'LineWidth',2,'Color',[0.8 0 0 ]);
                    hplt.LineStyle = '-.';
                    hplt.Color = [hplt.Color 0.7];
                    hplt = plot(hsb(orderplot(idxorder)),timesUseDetector,ld0_low,'LineWidth',2,'Color',[0.8 0 0]);
                    hplt.LineStyle = '-.';
                    hplt.Color = [hplt.Color 0.7];
                    prctile_99 = prctile(ld0,99);
                    prctile_1  = prctile(ld0,1);
                    ylim([prctile_1 prctile_99]);
                    title(hsb(orderplot(idxorder)),'Control signal');
                    ylabel('Control signal (a.u.)');
                    set(hsb(orderplot(idxorder)),'FontSize',16);
                    idxorder = idxorder + 1;
                    %% plot power
%                     axes(hsb(orderplot(idxorder)));
                    uxtimesPower = datetime(powerTable.PacketRxUnixTime/1000,...
                        'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
                    
                    yearUsePower = mode(year(uxtimesPower));
                    idxKeepYearPower = year(uxtimesPower)==yearUsePower;
                    uxtimesPowerUse = uxtimesPower(idxKeepYearPower);
                    %%%%%%%%%%%%%
                    %%%%%%%%%%%%%
                    %%XXXXXX POWER BAND USED
                    %%XXXXXX
                    %%XXXXXX
                    %%XXXXXX
                    
                    powerBand = powerTable.Band1(idxKeepYearPower);
                    
                    %%XXXXXX
                    %%XXXXXX
                    %%XXXXXX
                    %%XXXXXX
                    %%%%%%%%%%%%%
                    %%%%%%%%%%%%%

                    
                    idxkeeppower = uxtimesPowerUse > (uxtimesPowerUse(1) + minutes(mintrim));
                    uxtimesPowerUse = uxtimesPowerUse(idxkeeppower);
                    powerBand = powerBand(idxkeeppower);
                    
%                     hplt = plot(hsb(orderplot(idxorder)),uxtimesPowerUse,powerBand,'LineWidth',1.5);
%                     hplt.Color = [0.8 0 0 0.5];
%                     prctile_99 = prctile(powerBand,99.5);
%                     prctile_1  = prctile(powerBand,1);
%                     ylim([prctile_1 prctile_99]);
%                     ylabel('Power (a.u.)');
%                     title(hsb(orderplot(idxorder)),'power');
%                     set(hsb(orderplot(idxorder)),'FontSize',16);
%                     idxorder = idxorder + 1;
                    %% plot acc
%                     axes( hsb(orderplot(idxorder)) );
%                     insTimes = outdatcompleteAcc.derivedTimes;
%                     idxwithPacGenTime = find(outdatcompleteAcc.PacketGenTime~=0);
%                     pacGenTime  = datetime(outdatcompleteAcc.PacketGenTime(idxwithPacGenTime(10))/1000,...
%                         'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
%                     insTimesAtThatPoint = insTimes(idxwithPacGenTime(10));
%                     diff_found = insTimesAtThatPoint - pacGenTime;
%                     insTimesCorrected = insTimes - diff_found;
%                     yearUsePower = mode(year(insTimesCorrected));
%                     idxKeepYearPower = year(insTimesCorrected)==yearUsePower;
%                     insTimesToUse = insTimesCorrected(idxKeepYearPower);
%                     
%                     x = outdatcompleteAcc.XSamples(idxKeepYearPower);
%                     y = outdatcompleteAcc.YSamples(idxKeepYearPower);
%                     z = outdatcompleteAcc.ZSamples(idxKeepYearPower);
%                     
%                     x = x - mean(x);
%                     y = y - mean(y);
%                     z = z - mean(z);
%                     
%                     avgMov = mean([abs(x) abs(y) abs(z)],2)';
%                     
%                     avgMoveSmoothed = movmean(avgMov,[64*30 0]);
%                     avgMovePercent = avgMoveSmoothed;
%                     
%                     % trim start of file
%                     idxkeepacc = insTimesToUse > (insTimesToUse(1) + minutes(mintrim));
%                     insTimesToUse = insTimesToUse(idxkeepacc);
%                     avgMovePercent = avgMovePercent(idxkeepacc);
%                     
%                     
%                     hp = plot(hsb(orderplot(idxorder)) ,insTimesToUse, avgMovePercent);
%                     hp.LineWidth = 3;
%                     hp.Color = [0 0 0.8 0.8];
%                     title(hsb(orderplot(idxorder)) ,'Internal accelrometer');
%                     set(hsb(orderplot(idxorder)) ,'FontSize',16);
%                     ylabel(hsb(orderplot(idxorder)) ,'smoothed acc (a.u.)');
%                     idxorder = idxorder + 1;
                    %% plot current
                    axes( hsb(orderplot(idxorder) ));
                    cur = res.adaptive.CurrentProgramAmplitudesInMilliamps(1,:);
                    cur = cur(idxKeepYear);
                    timesUseDetector = uxtimes(idxKeepYear);
                    idxkeepdet = timesUseDetector > (timesUseDetector(1) + minutes(mintrim));
                    timesUseDetector = timesUseDetector(idxkeepdet);
                    
                    % trim start of file
                    cur = cur(idxkeepdet);
                    
                    % get rid of negative diffs (e.g. times for past)
                    idxbad = find(seconds(diff(timesUseDetector))<0)+1;
                    idxkeep = setxor(1:length(timesUseDetector),idxbad);
                    timesUseDetector = timesUseDetector(idxkeep);
                    cur = cur(idxkeep);
                    allcur = [allcur , cur];
                    fprintf('mean current %0.2f\n',mean(cur));
                    plot(timesUseDetector,cur,'LineWidth',3,'Color',[0 0.8 0 0.7],'Parent', hsb(orderplot(idxorder)) );
                    title( hsb(orderplot(idxorder)) ,'Current in mA');
                    ylabel( hsb(orderplot(idxorder)) ,'Current (mA)');
                    %             xlim([min(timesUseDetector) max(timesUseDetector)]);
                    %             ylim([min(cur(idxKeepYear)) max(cur(idxKeepYear))]);
                    set( hsb(orderplot(idxorder)) ,'FontSize',16);
                    
                catch
                    x=2;
                end
                
            end
            largetitle = sprintf('%s %s %s',patient,side,datetime(tblPlot.rectime(1),'Format','dd-MMM-yyyy'));
%             sgtitle(largetitle,'FontSize',24);
            linkaxes(hsb,'x');
            xlims = get(gca,'XLim');
            meancur = mean(allcur);
            if strcmp(patient,'RCS02') 
%                 hplt = plot([xlims(1)+hours(1) xlims(2)],[meancur meancur]);
%                 hplt.LineWidth = 3; 
%                 hplt.LineStyle = '-.';
%                 hplt.Color = [0 0 0.8 0.5];
                

                hplt = plot([xlims(1)+hours(1) xlims(2)],[2.7 2.7]);
                hplt.LineWidth = 3;
                hplt.LineStyle = '-.';
                hplt.Color = [0.8 0 0 0.5];

                axes( hsb(1));
                title('Cortical gamma control signal');
                ylabel('Cortical gamma power (a.u.)');
                
            end
            
            if strcmp(patient,'RCS06')
                axes(hsb(1));
                
                set(gca,'XLim',datetime(['20-Apr-2020 09:00:14' ;  '20-Apr-2020 18:24:11'],'TimeZone','America/Los_Angeles'));
                set(gca,'YLim',[  -0.218273729606444   1.415456954720268].*1e3);
                
                axes(hsb(2));
%                 xlims = get(gca,'XLim');
%                 axes(hsb(2));
%                 hplt = plot([xlims(1)+hours(1) xlims(2)],[meancur meancur]);
%                 hplt.LineWidth = 3;
%                 hplt.LineStyle = '-.';
%                 hplt.Color = [0 0 0.8 0.5];
                
                
                hplt = plot([xlims(1)+hours(1) xlims(2)],[0.9 0.9]);
                hplt.LineWidth = 3;
                hplt.LineStyle = '-.';
                hplt.Color = [0.8 0 0 0.5];
                
                axes( hsb(1));
                title('STN beta control signal');
                ylabel('STN beta power (a.u.)');
                
            end

            
            %% print figure
            % params to print the figures
            yearrec = year(tblPlot.rectime(1));
            montrec = month(tblPlot.rectime(1));
            dayrec  = day(tblPlot.rectime(1));
            fig_title = sprintf('%s_%s_%d_%0.2d-%0.2d_BAND__ZOOM_1',patient,side,yearrec,montrec,dayrec);
            prfig.plotwidth           = 20;
            prfig.plotheight          = 9;
            prfig.figdir              = fullfile(rootdir,'figures');
            prfig.figtype             = '-djpeg';
            prfig.closeafterprint     = 0;
            prfig.resolution          = 300;
            prfig.figname             = fig_title;
            plot_hfig(hfig,prfig);
            
        end
    end
end

return;



end