function temp_plot_rcs02_adpative_and_pkg_synced_report()

%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%
%% plot EMBEDDED
%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%



close all;


diruse = {'/Users/roee/Documents/potential_adaptive/RCS02/RCS02R/Session1591977809833/DeviceNPC700404H';...
    '/Users/roee/Documents/potential_adaptive/RCS02/RCS02R/Session1591997807662/DeviceNPC700404H'};





%% set up figure
hfig = figure;
hfig.Color = 'w';
nrows = 2;
ncols = 1;
for ii = 1:2
    fnAdaptive = fullfile(diruse{ii},'AdaptiveLog.json');
    res = readAdaptiveJson(fnAdaptive);

    hsb(1) = subplot(nrows,ncols,1);
    hold on;
    
    % plower DETECTOR  adaptive + current + power
    cur = res.adaptive.CurrentProgramAmplitudesInMilliamps(1,:);
    timestamps = datetime(datevec(res.timing.timestamp./86400 + datenum(2000,3,1,0,0,0))); % medtronic time - LSB is seconds
    uxtimes = datetime(res.timing.PacketGenTime/1000,...
        'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
    yearUse = mode(year(uxtimes));
    idxKeepYear = year(uxtimes)==yearUse;
    
    mintrim  =2;
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
    
    
    hplt = plot(timesUseDetector,ld0,'LineWidth',2.5,'Color',[0 0 0.8 ]);
    hplt = plot(timesUseDetector,ld0_high,'LineWidth',2,'Color',[0.8 0 0 ]);
    hplt.LineStyle = '-.';
    hplt.Color = [hplt.Color 0.7];
    hplt = plot(timesUseDetector,ld0_low,'LineWidth',2,'Color',[0.8 0 0]);
    hplt.LineStyle = '-.';
    hplt.Color = [hplt.Color 0.7];
    prctile_99 = prctile(ld0,99);
    prctile_1  = prctile(ld0,1);
    ylim([prctile_1 prctile_99]);
    title('Control signal');
    ylabel('Control signal (a.u.)');
    set(gca,'FontSize',16);
    
    
    
    
   
    hsb(2) = subplot(nrows,ncols,2);
    hold on;
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
    
    fprintf('mean current %0.2f\n',mean(cur));
    plot(timesUseDetector,cur,'LineWidth',3,'Color',[0 0.8 0 0.7]);
    title( 'Current in mA');
    ylabel( 'Current (mA)');
    %             xlim([min(timesUseDetector) max(timesUseDetector)]);
    %             ylim([min(cur(idxKeepYear)) max(cur(idxKeepYear))]);
    set(gca,'FontSize',16);
end
linkaxes(hsb,'x')

%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%
%% plot EMBEDDED
%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%







%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%
%% plot PKG
%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%

%% load data 
savedir = '/Users/roee/Box/RC-S_Studies_Regulatory_and_Data/pkg_data/results/processed_data';
load(fullfile(savedir,'pkgDataBaseProcessed.mat'),'pkgDB');

uniqePatients = unique(pkgDB.patient);
uniqeSides    = unique(pkgDB.side);

%% % agregate all pkg data into one big table


pkgHugeTable = table();
for p  = 1:size(pkgDB,1)
    ff = findFilesBVQX( savedir, pkgDB.savefn{p}) ;
    load(ff{1});
    nrows = size(pkgTable,1);
    pkgTable.patient =  repmat(pkgDB.patient(p),nrows,1);
    pkgTable.date_details =  repmat(pkgDB.date_details(p),nrows,1);
    pkgTable.side =  repmat(pkgDB.side(p),nrows,1);
    pkgTable.timerange =  repmat(pkgDB.timerange(p,:),nrows,1);
    % add the dose information to the table
    for d = 1:size(doseTable)
        if ~isnan( doseTable.Dose(d))
            idxday = pkgTable.Day == doseTable.Day(d);
            if sum(idxday) > 1
                dayDates = pkgTable.Date_Time(idxday,:);
                yearUse = year(dayDates(1));
                monthUse = month(dayDates(1));
                dayUse = day(dayDates(1));
                [hourUse,minUse,secUse] = hms(doseTable.Reminder(d));
                dateReminder = datetime( sprintf('%d/%0.2d/%0.2d %0.2d:%0.2d:%0.2d',...
                    yearUse,monthUse,dayUse,hourUse,minUse,secUse),...
                    'Format','yyyy/MM/dd HH:mm:ss');
                
                [hourUse,minUse,secUse] = hms(doseTable.Dose(d));
                dateDose = datetime( sprintf('%d/%0.2d/%0.2d %0.2d:%0.2d:%0.2d',...
                    yearUse,monthUse,dayUse,hourUse,minUse,secUse),...
                    'Format','yyyy/MM/dd HH:mm:ss');
                [value,idx] = min(abs(dateDose-pkgTable.Date_Time));
                pkgTable.date_dose(idx) = dateDose;
                pkgTable.date_reminder(idx) = dateReminder;
            end
        end
    end
    if ~isfield(pkgTable,'date_dose') % in cased dose data doesn't exist for this subject
        pkgTable.date_dose(1) = NaT;
        pkgTable.date_reminder(1) = NaT;
    end
    
    if p == 1
        pkgHugeTable = pkgTable;
        clear pkgTable;
    else
        pkgHugeTable = [pkgHugeTable  ; pkgTable];
        clear pkgTable;
    end
end
% if you get a dyskinesia value that is 0 - and you log that
% you get -inf to fix this - change all dyskinesia values that are 0 to a 1
% so that you get a zero when you log it.
idxzero = pkgHugeTable.DK == 0;
pkgHugeTable.DK(idxzero) = 1;


sortedTbl = sortrows(pkgDB,{'patient','side','pkg_identifier','timerange'});

%% get relevant datasets 

% idx open loop 
%%
OLstartDate = datetime('2020-05-26','TimeZone',pkgHugeTable.timerange.TimeZone);
idxdate = pkgHugeTable.timerange(:,1) == OLstartDate;
sum(idxdate)
%%
idxRC02 = strcmp(pkgHugeTable.patient,'RCS02') ;
pkgRC = pkgHugeTable(idxRC02,:); 
unique(pkgRC.timerange(:,1))
    
idxCL = year(pkgRC.Date_Time(:,1)) == 2020 & ...
        month(pkgRC.Date_Time(:,1)) == 6 & ... 
        day(pkgRC.Date_Time(:,1)) == 12;
rcsCL = pkgRC(idxCL,:);




%% plot states
hsb(3) = subplot(4,1,3);
hold on;
% bk vals
times = rcsCL.Date_Time;
times.TimeZone = timesUseDetector.TimeZone;
dkvals = rcsCL.DK;
dkvals = log10(dkvals);
bkvals = rcsCL.BK;
bkvals = abs(bkvals);
trmvals = rcsCL.Tremor_Score;

mrksize = 20;
alphause = 0.3;
scatter(times,bkvals,mrksize,'filled','MarkerFaceColor',[0 0 0],'MarkerFaceAlpha',alphause);
xlims = get(gca,'XLim');
hp(2) = plot(xlims,[80 80],'LineWidth',2,'Color',[0.5 0.5 0.5],'LineStyle','-.');
hp(2) = plot(xlims,[26 26],'LineWidth',2,'Color',[0.5 0.5 0.5],'LineStyle','-.');
ylims = get(gca,'YLim');
% plot dose times
idxdose = ~isnat(rcsCL.date_reminder);
if sum(idxdose) >= 1
    reminderTimes = rcsCL.date_reminder(idxdose);
    reminderDose  = rcsCL.date_dose(idxdose);
    reminderTimes.TimeZone = timesUseDetector.TimeZone; 
    reminderDose.TimeZone = timesUseDetector.TimeZone;
    for rr = 1:length(reminderTimes)
        plot([reminderTimes(rr) reminderTimes(rr)],ylims,'LineWidth',2,'Color',[0.5 0.7 0.5],'LineStyle','-.');
        plot([reminderDose(rr) reminderDose(rr)],ylims,'LineWidth',2,'Color',[0.5 0.8 0.5],'LineStyle','-.');
    end
end
bkmovemean = movmean(bkvals,[5 5]);
plot(times,bkmovemean,'LineWidth',4,'Color',[0 0 0 0.5]);
ylabel('bradykinesia score (a.u.)');
set(gca,'FontSize',12);
title('PKG BK');

% dk vals
hsb(4) = subplot(4,1,4);
hold on;
scatter(times,dkvals,mrksize,'filled','MarkerFaceColor',[0 0.8 0],'MarkerFaceAlpha',alphause);

dkmovemean = movmean(dkvals,[5 5]);
plot(times,dkmovemean,'LineWidth',4,'Color',[0 0.8 0 0.5]);
xlims = get(gca,'XLim');

hp(2) = plot(xlims,[log10(7) log10(7) ],'LineWidth',2,'Color',[0.5 0.5 0.5],'LineStyle','-.');
hp(2) = plot(xlims,[log10(16) log10(16)],'LineWidth',2,'Color',[0.5 0.5 0.5],'LineStyle','-.');

ylabel('dyskinesia score (a.u.)');
set(gca,'FontSize',12);
title('PKG DK');
%%
linkaxes(hsb,'x');



end