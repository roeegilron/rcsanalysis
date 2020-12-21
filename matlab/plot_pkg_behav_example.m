function plot_pkg_behav_example()
%% plot one day example of PKG data / patient
[rootdir, ~] = fileparts(pwd);
savedir = fullfile(rootdir,'results','processed_data');
load(fullfile(savedir,'pkgDataBaseProcessed.mat'),'pkgDB');

uniqePatients = unique(pkgDB.patient);
uniqeSides    = unique(pkgDB.side);
close all;
clc;

%% get some general states about PKG
clc;
BKall = [];
DKall = [];
TRall = [];
for p  = 1:size(pkgDB,1)
    ff = findFilesBVQX( savedir, pkgDB.savefn{p}) ;
    load(ff{1});
    BKall = [BKall ; pkgTable.BK];
    DKall = [DKall ; pkgTable.DK];
    TRall = [TRall ; pkgTable.Tremor_Score];
end


BKall = abs(BKall);
fprintf('mean BK %.2f range (%.2f - %.2f)\n',mean(BKall),min(BKall),max(BKall) );
fprintf('mean DK %.2f range (%.2f - %.2f)\n',mean(DKall),min(DKall),max(DKall) );
fprintf('mean TR %.2f range (%.2f - %.2f)\n',mean(TRall),min(TRall),max(TRall) );

fprintf('\n\n');
fprintf('BK %.2f %.2f %.2f (25,50,75 - percentiles)\n',prctile(BKall,25),prctile(BKall,50),prctile(BKall,75));
fprintf('DK %.2f %.2f %.2f (25,50,75 - percentiles)\n',prctile(DKall,25),prctile(DKall,50),prctile(DKall,75));
fprintf('TR %.2f %.2f %.2f (25,50,75 - percentiles)\n',prctile(TRall,25),prctile(TRall,50),prctile(TRall,75));


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

%% plot histograms on a per subject basis
plotHistogram = 1;
if plotHistogram
    unqPatients = unique(pkgHugeTable.patient);
    for p = 1:length(unqPatients) % loop on unique patients
        idxpatient = strcmp(pkgHugeTable.patient,unqPatients{p});
        patTable = pkgHugeTable(idxpatient,:);
        % loop on side
        uniqueSides = unique(patTable.side);
        for ss = 1:length(uniqueSides) % loop on side
            idxside = strcmp(patTable.side,uniqueSides{ss});
            patSideTable = patTable(idxside,:);
            % get min max values for easy comparison
            tremorMinMax = [min(patSideTable.Tremor_Score) max(patSideTable.Tremor_Score)];
            bradyMinMax = [min(patSideTable.BK) max(patSideTable.BK)];
            dyskMinMax = [min(log10(patSideTable.DK)) max(log10(patSideTable.DK))];
            % loop on conditions
            uniqueConditions = unique(patSideTable.date_details);
            for u = 1:length(uniqueConditions)
                idxunique = strcmp(patSideTable.date_details,uniqueConditions{u});
                tblPlot = patSideTable(idxunique,:);
                
                
                % plot histogram
                
                clear hp
                hfig = figure('Color','w','Visible','off');
                cnt = 1;
                
                % get rid of NaN data (it's empty on startup
                tblPlot = tblPlot(~isnan(tblPlot.BK),:);
                
                % get rid of off wrist data
                tblPlot = tblPlot(~tblPlot.Off_Wrist,:);
                
                unqCond = strrep(uniqueConditions{u},'_',' ');
                
                % brakdykinesia
                hbrdy =  subplot(1,3,cnt); cnt = cnt + 1;
                axis(hbrdy);
                hold on;
                histogram(tblPlot.BK,'Normalization','probability',...
                    'BinWidth',10);
                titleUse{1,1} = sprintf('%s %s',unqPatients{p},uniqueSides{ss});
                
                titleUse{1,2} = sprintf('%s %s','bradykinesia',unqCond);
                ylims = get(gca,'YLim');
                hp(1) = plot([-26 -26],ylims,'LineWidth',2,'Color','r','LineStyle','-.');
                hp(2) = plot([-80 -80],ylims,'LineWidth',2,'Color','k','LineStyle','-.');
                legend(hp,{'> BK = off','> BK = sleep'});
                title(titleUse)
                set(gca,'FontSize',16);
                xlim(hbrdy,bradyMinMax);
                clear hp
                
                % tremor
                htrem =  subplot(1,3,cnt); cnt = cnt + 1;
                axis(htrem);
                hold on;
                
                histogram(tblPlot.Tremor_Score(tblPlot.Tremor_Score~=0),...
                    'Normalization','probability',...
                    'BinWidth',5);
                titleUse{1,1} = sprintf('%s %s',unqPatients{p},unqCond);
                titleUse{1,2} = sprintf('%s %s','tremor',uniqueConditions{u});
                title(titleUse)
                set(gca,'FontSize',16);
                xlim(htrem,tremorMinMax);
                
                
                % dyskinesia
                hdysk =  subplot(1,3,cnt); cnt = cnt + 1;
                axis(hdysk);
                hold on;
                histogram(log10(tblPlot.DK),'Normalization','probability',...
                    'BinWidth',0.3);
                titleUse{1,1} = sprintf('%s %s',unqPatients{p},uniqueSides{ss});
                titleUse{1,2} = sprintf('%s %s','dyskinesia',unqCond);
                ylims = get(gca,'YLim');
                hp(1) = plot([log10(7) log10(7)],ylims,'LineWidth',2,'Color',[0 0.8 0],'LineStyle','-.');
                hp(2) = plot([log10(16) log10(16)],ylims,'LineWidth',2,'Color',[0 0.8 0],'LineStyle','-.');
                
                legend(hp(1),{'< DK = dyskinetic'});
                title(titleUse)
                set(gca,'FontSize',16);
                xlim(hdysk,dyskMinMax);
                clear hp
                
                
                title(titleUse)
                
                prfig.plotwidth           = 19;
                prfig.plotheight          = 8;
                
                [rootdir, ~] = fileparts(pwd);
                rootfigdir = fullfile(rootdir,'figures');
                % make file fig dir
                subdir = fullfile(rootfigdir,unqPatients{p});
                mkdir(subdir);
                measureDir = fullfile(subdir,'histogram');
                mkdir(measureDir);
                
                prfig.figdir              = measureDir;
                
                figNameSave = sprintf('%s_%s-side_%s_%s',unqPatients{p},uniqueSides{ss},'histogram',uniqueConditions{u});
                prfig.figname             = figNameSave;
                plot_hfig(hfig,prfig)
                fprintf('printed figure %s\n',figNameSave);
                %%
                
            end
        end
    end
end
%%
idxuse = strcmp(pkgHugeTable.patient,'RCS05') & ...
    strcmp(pkgHugeTable.side,'L') & ... 
    strcmp(pkgHugeTable.reportID,'141631');
exTbl = pkgHugeTable(idxuse,:);

unique(exTbl.timerange(:,1))

% look at unique pkg valuesa 
% Unique values
C = exTbl.Date_Time(:,1);
[~,idxu,idxc] = unique(C,'rows');
% count unique values (use histc in <=R2014b)
[count, ~, idxcount] = histcounts(idxc,numel(idxu));
% Where is greater than one occurence
idxkeep = count(idxcount)>1;
% Extract from C
C(idxkeep,:);


%%

%% plot states on a per subject basis
% issue with RCS03 lumping data from two hands together 
unqPatients = unique(pkgHugeTable.patient);
for p = 1:length(unqPatients) % loop on unique patients
    idxpatient = strcmp(pkgHugeTable.patient,unqPatients{p});
    patTable = pkgHugeTable(idxpatient,:);
    % loop on side
    uniqueSides = unique(patTable.side);
    for ss = 1:length(uniqueSides) % loop on side
        idxside = strcmp(patTable.side,uniqueSides{ss});
        patSideTable = patTable(idxside,:);
        % get min max values for easy comparison
        tremorMinMax = [min(patSideTable.Tremor_Score) max(patSideTable.Tremor_Score)];
        bradyMinMax = [min(patSideTable.BK) max(patSideTable.BK)];
        dyskMinMax = [min(log10(patSideTable.DK)) max(log10(patSideTable.DK))];
        % loop on conditions
        uniqueConditions = unique(patSideTable.date_details);
        for u = 1:length(uniqueConditions) % loop on broad categories - before / after stim 
            idxunique = strcmp(patSideTable.date_details,uniqueConditions{u});
            tblConds = patSideTable(idxunique,:);
            unqPKGs = unique(tblConds.timerange(:,1)); 
           
            for upkg = 1:length(unqPKGs) % loop on uniqe pkg runs  
                idxTest = tblConds.timerange(:,1) == unqPKGs(upkg); 
                tblAllDays = tblConds(idxTest,:);
                % get unique days 
                uniqueDays = unique(tblAllDays.Day);
                for uqday = 1:length(uniqueDays) % loop on unique days
                    idxDay = tblAllDays.Day == uniqueDays(uqday);
                    tblDay = tblAllDays(idxDay,:);

                    %% plot states
                    close all;
                    hfig = figure('Visible','off');
                    hfig.Color = 'w';
                    
                    % bk vals
                    hsb(1) = subplot(32,1,[1:10]);
                    times = tblDay.Date_Time;
                    dkvals = tblDay.DK;
                    dkvals = log10(dkvals);
                    bkvals = tblDay.BK;
                    bkvals = abs(bkvals);
                    trmvals = tblDay.Tremor_Score;
                    hold on;
                    mrksize = 20;
                    alphause = 0.3;
                    scatter(times,bkvals,mrksize,'filled','MarkerFaceColor',[0 0 0],'MarkerFaceAlpha',alphause);
                    xlims = get(gca,'XLim');
                    hp(2) = plot(xlims,[80 80],'LineWidth',2,'Color',[0.5 0.5 0.5],'LineStyle','-.');
                    hp(2) = plot(xlims,[26 26],'LineWidth',2,'Color',[0.5 0.5 0.5],'LineStyle','-.');
                    ylims = get(gca,'YLim'); 
                    % plot dose times 
                    idxdose = ~isnat(tblDay.date_reminder); 
                    if sum(idxdose) >= 1 
                        reminderTimes = tblDay.date_reminder(idxdose);
                        reminderDose  = tblDay.date_dose(idxdose); 
                        for rr = 1:length(reminderTimes)
                            plot([reminderTimes(rr) reminderTimes(rr)],ylims,'LineWidth',2,'Color',[0.5 0.7 0.5],'LineStyle','-.');
                            plot([reminderDose(rr) reminderDose(rr)],ylims,'LineWidth',2,'Color',[0.5 0.8 0.5],'LineStyle','-.');
                        end
                    end
                    bkmovemean = movmean(bkvals,[5 5]);
                    plot(times,bkmovemean,'LineWidth',4,'Color',[0 0 0 0.5]);
                    hsb(1).XTick = [];
                    hsb(1).XTickLabel = '';
                    ylabel('bradykinesia score (a.u.)');
                    set(gca,'FontSize',12);
                    
                    
                    % dk vals
                    hsb(2) = subplot(32,1,[11:20]);
                    hold on;
                    scatter(times,dkvals,mrksize,'filled','MarkerFaceColor',[0 0.8 0],'MarkerFaceAlpha',alphause);
                    
                    dkmovemean = movmean(dkvals,[5 5]);
                    plot(times,dkmovemean,'LineWidth',4,'Color',[0 0.8 0 0.5]);
                    xlims = get(gca,'XLim');
                    
                    hp(2) = plot(xlims,[log10(7) log10(7) ],'LineWidth',2,'Color',[0.5 0.5 0.5],'LineStyle','-.');
                    hp(2) = plot(xlims,[log10(16) log10(16)],'LineWidth',2,'Color',[0.5 0.5 0.5],'LineStyle','-.');
                    
                    ylabel('dyskinesia score (a.u.)');
                    set(gca,'FontSize',12);
                    
                    hsb(2).XTick = [];
                    hsb(2).XTickLabel = '';
                    
                    % tremor values
                    hsb(3) = subplot(32,1,[21:30]);
                    hold on;
                    scatter(times,trmvals,mrksize,'filled','MarkerFaceColor',[0 0 0.8],'MarkerFaceAlpha',alphause);
                    
                    dkmovemean = movmean(trmvals,[5 5]);
                    plot(times,dkmovemean,'LineWidth',4,'Color',[0 0 0.8 0.5]);
                    xlims = get(gca,'XLim');
                    ylabel('tremor score (a.u.)');
                    set(gca,'FontSize',12);
                    
                    
                    

                    titleUse{1,1} = sprintf('%s %s',unqPatients{p},uniqueSides{ss});
                    titleUse{1,2} = sprintf('%s',uniqueConditions{u});
                    
                    %% state classifcation
                    hsb(4) = subplot(32,1,31:32);
                    hold(hsb(4),'on');
                    

                    rawstates = tblDay.states;
                    switch uniqePatients{p}
                        case 'RCS01'
                            onidx = cellfun(@(x) any(strfind(x,'dyskinesia')),rawstates) | ...
                                cellfun(@(x) any(strfind(x,'on')),rawstates);
                            offidx = cellfun(@(x) any(strfind(x,'off')),rawstates) | ...
                                cellfun(@(x) any(strfind(x,'tremor')),rawstates);
                            sleeidx = cellfun(@(x) any(strfind(x,'sleep')),rawstates);
                        case 'RCS02'
                            onidx = cellfun(@(x) any(strfind(x,'dyskinesia severe')),rawstates);
                            offidx = cellfun(@(x) any(strfind(x,'off')),rawstates) | ...
                                cellfun(@(x) any(strfind(x,'on')),rawstates) | ...
                                cellfun(@(x) any(strfind(x,'tremor')),rawstates);
                            sleeidx = cellfun(@(x) any(strfind(x,'sleep')),rawstates);
                        case 'RCS03'
                            onidx = cellfun(@(x) any(strfind(x,'dyskinesia')),rawstates) | ...
                                cellfun(@(x) any(strfind(x,'on')),rawstates);
                            offidx = cellfun(@(x) any(strfind(x,'off')),rawstates) | ...
                                cellfun(@(x) any(strfind(x,'tremor')),rawstates);
                            sleeidx = cellfun(@(x) any(strfind(x,'sleep')),rawstates);
                        case 'RCS05'
                            onidx = cellfun(@(x) any(strfind(x,'dyskinesia')),rawstates) | ...
                                cellfun(@(x) any(strfind(x,'on')),rawstates);
                            offidx = cellfun(@(x) any(strfind(x,'off')),rawstates) | ...
                                cellfun(@(x) any(strfind(x,'tremor')),rawstates);
                            sleeidx = cellfun(@(x) any(strfind(x,'sleep')),rawstates);
                        case 'RCS06'
                            onidx = cellfun(@(x) any(strfind(x,'dyskinesia')),rawstates) | ...
                                cellfun(@(x) any(strfind(x,'on')),rawstates);
                            offidx = cellfun(@(x) any(strfind(x,'off')),rawstates) | ...
                                cellfun(@(x) any(strfind(x,'tremor')),rawstates);
                            sleeidx = cellfun(@(x) any(strfind(x,'sleep')),rawstates);
                        case 'RCS07'
                            onidx = cellfun(@(x) any(strfind(x,'dyskinesia')),rawstates) | ...
                                cellfun(@(x) any(strfind(x,'on')),rawstates);
                            offidx = cellfun(@(x) any(strfind(x,'off')),rawstates) | ...
                                cellfun(@(x) any(strfind(x,'tremor')),rawstates);
                            sleeidx = cellfun(@(x) any(strfind(x,'sleep')),rawstates);
                        case 'RCS08'
                            onidx = cellfun(@(x) any(strfind(x,'dyskinesia')),rawstates) | ...
                                cellfun(@(x) any(strfind(x,'on')),rawstates);
                            offidx = cellfun(@(x) any(strfind(x,'off')),rawstates) | ...
                                cellfun(@(x) any(strfind(x,'tremor')),rawstates);
                            sleeidx = cellfun(@(x) any(strfind(x,'sleep')),rawstates);
                        case 'RCS09'
                            onidx = cellfun(@(x) any(strfind(x,'dyskinesia')),rawstates) | ...
                                cellfun(@(x) any(strfind(x,'on')),rawstates);
                            offidx = cellfun(@(x) any(strfind(x,'off')),rawstates) | ...
                                cellfun(@(x) any(strfind(x,'tremor')),rawstates);
                            sleeidx = cellfun(@(x) any(strfind(x,'sleep')),rawstates);
                        case 'RCS10'
                            onidx = cellfun(@(x) any(strfind(x,'dyskinesia')),rawstates) | ...
                                cellfun(@(x) any(strfind(x,'on')),rawstates);
                            offidx = cellfun(@(x) any(strfind(x,'off')),rawstates) | ...
                                cellfun(@(x) any(strfind(x,'tremor')),rawstates);
                            sleeidx = cellfun(@(x) any(strfind(x,'sleep')),rawstates);
                    end
                    

                    clear rawstates;
                    otheridx =  ~(sleeidx | onidx | offidx);
                    
                    hbron = bar(times(onidx),repmat(-0.2,1,sum(onidx)),'stacked');
                    hbron.FaceColor = [0 0.8 0];
                    hbron.FaceAlpha = 0.6;
                    hbron.EdgeColor = 'none';
                    hbron.BarWidth = 1;
                    
                    hbroff = bar(times(offidx),repmat(-0.2,1,sum(offidx)),'stacked');
                    hbroff.FaceColor = [0.8 0 0];
                    hbroff.FaceAlpha = 0.6;
                    hbroff.EdgeColor = 'none';
                    hbroff.BarWidth = 1;
                    
                    hbrsleep = bar(times(sleeidx),repmat(-0.2,1,sum(sleeidx)),'stacked');
                    hbrsleep.FaceColor = [0 0 0.8];
                    hbrsleep.FaceAlpha = 0.6;
                    hbrsleep.EdgeColor = 'none';
                    hbrsleep.BarWidth = 1;
                    
                    
                    
                    hbrother = bar(times(otheridx),repmat(-0.2,1,sum(otheridx)),'stacked');
                    hbrother.FaceColor = [0.5 0.5 0.5];
                    hbrother.FaceAlpha = 0.6;
                    hbrother.EdgeColor = 'none';
                    hbrother.BarWidth = 1;
                    
                    
                    legend([ hbron hbroff hbrsleep hbrother],{'on','off','sleep','other'},'Location','west');
                    title('state classification');
                    
                    linkaxes(hsb,'x');
                    datetick('x','HH:MM');
                    % set 24 hour xlimits
                    [h,m,s] = hms(times(1));
                    minutes_subtract = minutes(h*60 + m + s/60);
                    x_start = times(1) - minutes_subtract;
                    x_end   = times(1) + (hours(24) - minutes_subtract);
                    xlim([x_start x_end]);
                    %%
                    
                    sgtitle(titleUse);

                    %%
                    % plot
                    
                    
                    prfig.plotwidth           = 19;
                    prfig.plotheight          = 8;
                    
                    % get / make the correct figure directory 
                    [rootdir, ~] = fileparts(pwd);
                    rootfigdir = fullfile(rootdir,'figures');
                    
                    subdir = fullfile(rootfigdir,unqPatients{p}); % make file fig dir
                    mkdir(subdir);
                    measureDir = fullfile(subdir,'states_per_day');
                    mkdir(measureDir);
                    
                    % date details 
                    deatlisDir = fullfile(measureDir,uniqueConditions{u});
                    mkdir(deatlisDir);
                    
                    % run details 
                    dir_date = sprintf('%s %s',tblDay.timerange(1,1), tblDay.timerange(1,2));
                    dateDir = fullfile(deatlisDir,dir_date);
                    mkdir(dateDir);
                    
                    
                    
                    prfig.figdir  = dateDir;
                    [Y,M,D] = ymd(tblDay.Date_Time(1));
                    figNameSave = sprintf('%s_%s-side_%s_%s__%0.4d-%0.2d-%0.2d',unqPatients{p},uniqueSides{ss},'day_graphs',uniqueConditions{u},Y,M,D);

                    prfig.figname             = figNameSave;
                    plot_hfig(hfig,prfig)
                    fprintf('printed figure %s\n',figNameSave);
                    close(hfig);
                    %%
                end
            end
            
        end
    end
end


%%%%%%
%%%%%%
%%%%%%
%%
%%%%%
%%%%%%
%%%%%%
%%



return;







%% plot in three graphs with state trend line
for p = 1 % 1:length(uniqePatients)
    for s = 2% 1:length(uniqeSides)
        idxpat = strcmp(uniqePatients{p},pkgDB.patient) &  strcmp(uniqeSides{s},pkgDB.side);
        load(pkgDB.savefn{idxpat});
        unqdays = unique(pkgTable.Day);
        for d = 5%1:length(unqdays)
            hfig = figure;
            hfig.Color = 'w';
            idxuse = pkgTable.Day == unqdays(d);
            times = pkgTable.Date_Time(idxuse,:);
            dkvals = pkgTable.DK(idxuse,:);
            dkvals(dkvals==0) = 0.1;
            dkvals = log10(dkvals);
            bkvals = pkgTable.BK(idxuse,:);
            bkvals = abs(bkvals);
            % bk vals
            hsb(1) = subplot(21,1,[1:9]);
            hold on;
            mrksize = 20;
            alphause = 0.3;
            scatter(times,bkvals,mrksize,'filled','MarkerFaceColor',[0 0 0],'MarkerFaceAlpha',alphause);
            xlims = get(gca,'XLim');
            hp(2) = plot(xlims,[80 80],'LineWidth',2,'Color',[0.5 0.5 0.5],'LineStyle','-.');
            bkmovemean = movmean(bkvals,[5 5]);
            plot(times,bkmovemean,'LineWidth',4,'Color',[0 0 0 0.5]);
            hsb(1).XTick = [];
            hsb(1).XTickLabel = '';
            %             hsb(1).YTick = [];
            %             hsb(1).YTickLabel = '';
            
            %             title('bradykinesia score');
            ylabel('bradykinesia score (a.u.)');
            set(gca,'FontSize',12);
            %             hp(1) = plot(xlims,[26 26],'LineWidth',2,'Color','r','LineStyle','-.');
            %             hp(2) = plot(xlims,[80 80],'LineWidth',2,'Color','k','LineStyle','-.');
            
            
            % dk vals
            hsb(2) = subplot(21,1,[10:19]);
            hold on;
            scatter(times,dkvals,mrksize,'filled','MarkerFaceColor',[0 0 0],'MarkerFaceAlpha',alphause);
            
            dkmovemean = movmean(dkvals,[5 5]);
            plot(times,dkmovemean,'LineWidth',4,'Color',[0 0 0 0.5]);
            xlims = get(gca,'XLim');
            %             hp(3) = plot(xlims,[log10(7) log10(7)],'LineWidth',2,'Color',[0 0.8 0],'LineStyle','-.');
            %             hp(4) = plot(xlims,[log10(16) log10(16)],'LineWidth',2,'Color',[0 0.8 0],'LineStyle','-.');
            
            %             title('dyskinesia score');
            ylabel('dyskinesia score (a.u.)');
            set(gca,'FontSize',12);
            
            hsb(2).XTick = [];
            hsb(2).XTickLabel = '';
            %             hsb(2).YTick = [];
            %             hsb(2).YTickLabel = '';
            
            
            
            
            % plot state
            hsb(3) = subplot(21,1,20:21);
            hold on;
            rawstates = pkgTable.states(idxuse);
            
            
            switch uniqePatients{p}
                case 'RCS02'
                    onidx = cellfun(@(x) any(strfind(x,'dyskinesia severe')),rawstates);
                    offidx = cellfun(@(x) any(strfind(x,'off')),rawstates) | ...
                        cellfun(@(x) any(strfind(x,'on')),rawstates) | ...
                        cellfun(@(x) any(strfind(x,'tremor')),rawstates);
                    sleeidx = cellfun(@(x) any(strfind(x,'sleep')),rawstates);
                case 'RCS05'
                    onidx = cellfun(@(x) any(strfind(x,'dyskinesia')),rawstates) | ...
                        cellfun(@(x) any(strfind(x,'on')),rawstates);
                    offidx = cellfun(@(x) any(strfind(x,'off')),rawstates) | ...
                        cellfun(@(x) any(strfind(x,'tremor')),rawstates);
                    sleeidx = cellfun(@(x) any(strfind(x,'sleep')),rawstates);
                case 'RCS06'
                    onidx = cellfun(@(x) any(strfind(x,'dyskinesia')),rawstates) | ...
                        cellfun(@(x) any(strfind(x,'on')),rawstates);
                    offidx = cellfun(@(x) any(strfind(x,'off')),rawstates) | ...
                        cellfun(@(x) any(strfind(x,'tremor')),rawstates);
                    sleeidx = cellfun(@(x) any(strfind(x,'sleep')),rawstates);
                case 'RCS07'
                    onidx = cellfun(@(x) any(strfind(x,'dyskinesia')),rawstates) | ...
                        cellfun(@(x) any(strfind(x,'on')),rawstates);
                    offidx = cellfun(@(x) any(strfind(x,'off')),rawstates) | ...
                        cellfun(@(x) any(strfind(x,'tremor')),rawstates);
                    sleeidx = cellfun(@(x) any(strfind(x,'sleep')),rawstates);
            end
            otheridx =  ~(sleeidx | onidx | offidx);
            
            hbron = bar(times(onidx),repmat(-0.2,1,sum(onidx)),'stacked');
            hbron.FaceColor = [0 0.8 0];
            hbron.FaceAlpha = 0.6;
            hbron.EdgeColor = 'none';
            hbron.BarWidth = 1;
            
            hbroff = bar(times(offidx),repmat(-0.2,1,sum(offidx)),'stacked');
            hbroff.FaceColor = [0.8 0 0];
            hbroff.FaceAlpha = 0.6;
            hbroff.EdgeColor = 'none';
            hbroff.BarWidth = 1;
            
            hbrsleep = bar(times(sleeidx),repmat(-0.2,1,sum(sleeidx)),'stacked');
            hbrsleep.FaceColor = [0 0 0.8];
            hbrsleep.FaceAlpha = 0.6;
            hbrsleep.EdgeColor = 'none';
            hbrsleep.BarWidth = 1;
            
            
            
            hbrother = bar(times(otheridx),repmat(-0.2,1,sum(otheridx)),'stacked');
            hbrother.FaceColor = [0.5 0.5 0.5];
            hbrother.FaceAlpha = 0.6;
            hbrother.EdgeColor = 'none';
            hbrother.BarWidth = 1;
            
            
            legend([ hbron hbroff hbrsleep hbrother],{'on','off','sleep','other'});
            title('state classification');
            
            hsb(3).YTick = [];
            hsb(3).YTickLabel = '';
            hsb(3).Position(4) = hsb(3).Position(4)*0.6;
            
            hsb(2).Position(4) = hsb(2).Position(4)*0.9;
            hsb(1).Position(4) = hsb(1).Position(4)*0.9;
            % set limits
            linkaxes(hsb,'x');
            
            xlimsVec = datevec(xlims);
            xlimsVec(:,4) = [4;0];
            xlimsNew = datetime(xlimsVec);
            
            datetick('x','HH:MM');
            set(gca,'XLim',xlimsNew);
            titluse = sprintf('%s %s day - %d',uniqePatients{p},uniqeSides{s},unqdays(d));
            sgtitle(titluse,'FontSize',12);
            
            prfig.plotwidth           = 8.5;
            prfig.plotheight          = 3.9;
            prfig.figdir             = figdirout;
            prfig.figname             = sprintf('%s %s day - %d.pdf',uniqePatients{p},uniqeSides{s},unqdays(d));
            plot_hfig(hfig,prfig)
            
            close(hfig);
            
        end
    end
end


return

%% plot in one bar graph
for p = 1:length(uniqePatients)
    for s = 1:length(uniqeSides)
        idxpat = strcmp(uniqePatients{p},pkgDB.patient) &  strcmp(uniqeSides{s},pkgDB.side);
        load(pkgDB.savefn{idxpat});
        unqdays = unique(pkgTable.Day);
        for d = 1:length(unqdays)
            idxuse = pkgTable.Day == unqdays(d);
            times = pkgTable.Date_Time(idxuse,:);
            dkvals = pkgTable.DK(idxuse,:);
            dkvals(dkvals==0) = 0.1;
            dkvals = log10(dkvals );
            bkvals = pkgTable.BK(idxuse,:);
            rawstates = pkgTable.states(idxuse);
            
            switch uniqePatients{p}
                case 'RCS02'
                    onidx = cellfun(@(x) any(strfind(x,'dyskinesia severe')),rawstates);
                    offidx = cellfun(@(x) any(strfind(x,'off')),rawstates) | ...
                        cellfun(@(x) any(strfind(x,'on')),rawstates) | ...
                        cellfun(@(x) any(strfind(x,'tremor')),rawstates);
                    sleeidx = cellfun(@(x) any(strfind(x,'sleep')),rawstates);
                case 'RCS05'
                    onidx = cellfun(@(x) any(strfind(x,'dyskinesia')),rawstates) | ...
                        cellfun(@(x) any(strfind(x,'on')),rawstates);
                    offidx = cellfun(@(x) any(strfind(x,'off')),rawstates) | ...
                        cellfun(@(x) any(strfind(x,'tremor')),rawstates);
                    sleeidx = cellfun(@(x) any(strfind(x,'sleep')),rawstates);
                case 'RCS06'
                    onidx = cellfun(@(x) any(strfind(x,'dyskinesia')),rawstates) | ...
                        cellfun(@(x) any(strfind(x,'on')),rawstates);
                    offidx = cellfun(@(x) any(strfind(x,'off')),rawstates) | ...
                        cellfun(@(x) any(strfind(x,'tremor')),rawstates);
                    sleeidx = cellfun(@(x) any(strfind(x,'sleep')),rawstates);
                case 'RCS07'
                    onidx = cellfun(@(x) any(strfind(x,'dyskinesia')),rawstates) | ...
                        cellfun(@(x) any(strfind(x,'on')),rawstates);
                    offidx = cellfun(@(x) any(strfind(x,'off')),rawstates) | ...
                        cellfun(@(x) any(strfind(x,'tremor')),rawstates);
                    sleeidx = cellfun(@(x) any(strfind(x,'sleep')),rawstates);
            end
            otheridx =  ~(sleeidx | onidx | offidx);
            hfig = figure;
            hfig.Color = 'w';
            
            hold on;
            bkvalsRescale = rescale(abs(bkvals),0,1);
            dkvalsRescale = rescale(dkvals,0,1);
            
            %plot bkvals
            hsubuse(1) = subplot(1,1,1);
            hold on;
            hbr = bar(times,[bkvalsRescale, dkvalsRescale],'stacked');
            hbr(1).FaceColor = [0.5 0.5 0.5];
            hbr(1).FaceAlpha = 0.6;
            hbr(2).FaceColor = [0.9100 0.4100 0.1700];
            hbr(2).FaceAlpha = 0.6;
            
            hbron = bar(times(onidx),repmat(-0.2,1,sum(onidx)),'stacked');
            hbron.FaceColor = [0 0.8 0];
            hbron.FaceAlpha = 0.6;
            hbron.EdgeColor = 'none';
            
            hbroff = bar(times(offidx),repmat(-0.2,1,sum(offidx)),'stacked');
            hbroff.FaceColor = [0.8 0 0];
            hbroff.FaceAlpha = 0.6;
            hbroff.EdgeColor = 'none';
            
            
            hbrsleep = bar(times(sleeidx),repmat(-0.2,1,sum(sleeidx)),'stacked');
            hbrsleep.FaceColor = [0 0 0.8];
            hbrsleep.FaceAlpha = 0.6;
            hbrsleep.EdgeColor = 'none';
            
            
            hbrother = bar(times(otheridx),repmat(-0.2,1,sum(otheridx)),'stacked');
            hbrother.FaceColor = [0.5 0.5 0.5];
            hbrother.FaceAlpha = 0.6;
            hbrother.EdgeColor = 'none';
            
            legend([hbr hbron hbroff hbrsleep hbrother],{'bk','dk','on','off','sleep','other'});
            
            xlims = get(gca,'XLim');
            ylabel('a.u. - rescaled');
            
            set(gca,'FontSize',16);
            
            xlimsVec = datevec(xlims);
            xlimsVec(2,:) = xlimsVec(1,:);
            xlimsVec(:,4) = [8;20];
            xlimsNew = datetime(xlimsVec);
            
            
            linkaxes(hsubuse,'x');
            %             set(gca,'XLim',xlimsNew);
            titluse = sprintf('%s %s day - %d',uniqePatients{p},uniqeSides{s},unqdays(d));
            sgtitle(titluse,'FontSize',20);
            
            prfig.plotwidth           = 18;
            prfig.plotheight          = 10;
            prfig.figdir             = figdirout;
            prfig.figname             = sprintf('%s %s day - %d.pdf',uniqePatients{p},uniqeSides{s},unqdays(d));
            plot_hfig(hfig,prfig);
            close(hfig);
        end
    end
end

%% plot in one graphs
for p = 1:length(uniqePatients)
    for s = 1:length(uniqeSides)
        idxpat = strcmp(uniqePatients{p},pkgDB.patient) &  strcmp(uniqeSides{s},pkgDB.side);
        load(pkgDB.savefn{idxpat});
        unqdays = unique(pkgTable.Day);
        for d = 1:length(unqdays)
            hfig = figure;
            hfig.Color = 'w';
            idxuse = pkgTable.Day == unqdays(d);
            times = pkgTable.Date_Time(idxuse,:);
            dkvals = pkgTable.DK(idxuse,:);
            dkvals(dkvals==0) = 0.1;
            dkvals = log10(dkvals );
            bkvals = pkgTable.BK(idxuse,:);
            rawstates = pkgTable.states(idxuse);
            
            switch uniqePatients{p}
                case 'RCS02'
                    onidx = cellfun(@(x) any(strfind(x,'dyskinesia severe')),rawstates);
                    offidx = cellfun(@(x) any(strfind(x,'off')),rawstates) | ...
                        cellfun(@(x) any(strfind(x,'on')),rawstates) | ...
                        cellfun(@(x) any(strfind(x,'tremor')),rawstates);
                    sleeidx = cellfun(@(x) any(strfind(x,'sleep')),rawstates);
                case 'RCS05'
                    onidx = cellfun(@(x) any(strfind(x,'dyskinesia')),rawstates) | ...
                        cellfun(@(x) any(strfind(x,'on')),rawstates);
                    offidx = cellfun(@(x) any(strfind(x,'off')),rawstates) | ...
                        cellfun(@(x) any(strfind(x,'tremor')),rawstates);
                    sleeidx = cellfun(@(x) any(strfind(x,'sleep')),rawstates);
                case 'RCS06'
                    onidx = cellfun(@(x) any(strfind(x,'dyskinesia')),rawstates) | ...
                        cellfun(@(x) any(strfind(x,'on')),rawstates);
                    offidx = cellfun(@(x) any(strfind(x,'off')),rawstates) | ...
                        cellfun(@(x) any(strfind(x,'tremor')),rawstates);
                    sleeidx = cellfun(@(x) any(strfind(x,'sleep')),rawstates);
                case 'RCS07'
                    onidx = cellfun(@(x) any(strfind(x,'dyskinesia')),rawstates) | ...
                        cellfun(@(x) any(strfind(x,'on')),rawstates);
                    offidx = cellfun(@(x) any(strfind(x,'off')),rawstates) | ...
                        cellfun(@(x) any(strfind(x,'tremor')),rawstates);
                    sleeidx = cellfun(@(x) any(strfind(x,'sleep')),rawstates);
            end
            otheridx =  ~(sleeidx | onidx | offidx);
            subplot(1,1,1);
            hold on;
            bkvalsRescale = rescale(abs(bkvals),0.51,1);
            dkvalsRescale = rescale(dkvals,0.1,0.49);
            mrksz = 40;
            %plot bkvals
            hscb(1) = scatter(times(onidx),bkvalsRescale(onidx),mrksz,'filled',...
                'MarkerFaceColor',[0 0.9 0],'MarkerEdgeAlpha',0.5);
            hscb(2) = scatter(times(offidx),bkvalsRescale(offidx),mrksz,'filled',...
                'MarkerFaceColor',[0.8 0 0],'MarkerEdgeAlpha',0.5);
            hscb(3) = scatter(times(sleeidx),bkvalsRescale(sleeidx),mrksz,'filled',...
                'MarkerFaceColor',[0 0 0.8],'MarkerEdgeAlpha',0.5);
            hscb(4) = scatter(times(otheridx),bkvalsRescale(otheridx),mrksz,'filled',...
                'MarkerFaceColor',[0.5 0.5 0.5],'MarkerEdgeAlpha',0.5);
            
            xlims = get(gca,'XLim');
            
            inmin = min(abs(bkvals));
            inmax = max(abs(bkvals));
            B = rescale(26,0.51,1,'InputMin',inmin,'InputMax',inmax);
            hp(1) = plot(xlims,[B B],'LineWidth',2,'Color','r','LineStyle','-.');
            B = rescale(80,0.51,1,'InputMin',inmin,'InputMax',inmax);
            hp(2) = plot(xlims,[B B],'LineWidth',2,'Color','k','LineStyle','-.');
            
            
            mrksz = 90;
            %plot dkvals
            hsc(1) = scatter(times(onidx),dkvalsRescale(onidx),mrksz,'square', 'filled',...
                'MarkerFaceColor',[0 0.9 0],'MarkerEdgeAlpha',0.5);
            hsc(2) = scatter(times(offidx),dkvalsRescale(offidx),mrksz,'square', 'filled',...
                'MarkerFaceColor',[0.8 0 0],'MarkerEdgeAlpha',0.5);
            hsc(3) = scatter(times(sleeidx),dkvalsRescale(sleeidx),mrksz,'square', 'filled',...
                'MarkerFaceColor',[0 0 0.8],'MarkerEdgeAlpha',0.5);
            hsc(4) = scatter(times(otheridx),dkvalsRescale(otheridx),mrksz,'square', 'filled',...
                'MarkerFaceColor',[0.5 0.5 0.5],'MarkerEdgeAlpha',0.5);
            
            inmin = min(dkvals);
            inmax = max(dkvals);
            B = rescale(log10(7),0.1,0.49,'InputMin',inmin,'InputMax',inmax);
            hp(1) = plot(xlims,[B B],'LineWidth',2,'Color','g','LineStyle','-.');
            B = rescale(log10(16),0.1,0.49,'InputMin',inmin,'InputMax',inmax);
            hp(2) = plot(xlims,[B B],'LineWidth',2,'Color','g','LineStyle','-.');
            
            
            
            legend(hscb,{'on','off','sleep','other'});
            set(gca,'FontSize',16);
            ylabel('a.u. - rescaled DK and BK');
            
            xlimsVec = datevec(xlims);
            xlimsVec(2,:) = xlimsVec(1,:);
            xlimsVec(:,4) = [8;20];
            xlimsNew = datetime(xlimsVec);
            
            
            
            set(gca,'XLim',xlimsNew);
            titluse = sprintf('%s %s day - %d',uniqePatients{p},uniqeSides{s},unqdays(d));
            sgtitle(titluse,'FontSize',20);
            
            prfig.plotwidth           = 18;
            prfig.plotheight          = 10;
            prfig.figdir             = figdirout;
            prfig.figname             = sprintf('%s %s day - %d.pdf',uniqePatients{p},uniqeSides{s},unqdays(d));
            plot_hfig(hfig,prfig)
            close(hfig);
            
        end
    end
end

return

%% plot in two graphs
for p = 4%1:length(uniqePatients)
    for s = 1%:length(uniqeSides)
        idxpat = strcmp(uniqePatients{p},pkgDB.patient) &  strcmp(uniqeSides{s},pkgDB.side);
        load(pkgDB.savefn{idxpat});
        unqdays = unique(pkgTable.Day);
        for d = 4%1:length(unqdays)
            hfig = figure;
            hfig.Color = 'w';
            idxuse = pkgTable.Day == unqdays(d);
            times = pkgTable.Date_Time(idxuse,:);
            dkvals = pkgTable.DK(idxuse,:);
            %             dkvals(dkvals==0) = 0.1;
            %             dkvals = log10(dkvals);
            bkvals = pkgTable.BK(idxuse,:);
            % bk vals
            hsb(1) = subplot(2,1,1);
            hold on;
            scatter(times,abs(bkvals),20,'filled','MarkerFaceColor',[0.8 0 0],'MarkerEdgeAlpha',0.5);
            title('BK');
            ylabel('BK vals');
            set(gca,'FontSize',16);
            xlims = get(gca,'XLim');
            hp(1) = plot(xlims,[26 26],'LineWidth',2,'Color','r','LineStyle','-.');
            hp(2) = plot(xlims,[80 80],'LineWidth',2,'Color','k','LineStyle','-.');
            
            
            % dk vals
            hsb(2) = subplot(2,1,2);
            hold on;
            scatter(times,dkvals,20,'filled','MarkerFaceColor',[0 0.8 0],'MarkerEdgeAlpha',0.5);
            xlims = get(gca,'XLim');
            hp(3) = plot(xlims,[log10(7) log10(7)],'LineWidth',2,'Color',[0 0.8 0],'LineStyle','-.');
            hp(4) = plot(xlims,[log10(16) log10(16)],'LineWidth',2,'Color',[0 0.8 0],'LineStyle','-.');
            
            title('DK');
            ylabel('DK vals');
            set(gca,'FontSize',16);
            
            linkaxes(hsb,'x');
            
            xlimsVec = datevec(xlims);
            xlimsVec(2,:) = xlimsVec(1,:);
            xlimsVec(:,4) = [8;20];
            xlimsNew = datetime(xlimsVec);
            
            
            
            set(gca,'XLim',xlimsNew);
            titluse = sprintf('%s %s day - %d',uniqePatients{p},uniqeSides{s},unqdays(d));
            sgtitle(titluse,'FontSize',20);
            
            prfig.plotwidth           = 15;
            prfig.plotheight          = 10;
            prfig.figdir             = figdirout;
            prfig.figname             = sprintf('%s %s day - %d.pdf',uniqePatients{p},uniqeSides{s},unqdays(d));
            plot_hfig(hfig,prfig)
            close(hfig);
            
        end
    end
end





end