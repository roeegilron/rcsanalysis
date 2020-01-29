function process_pkg_table_data_horne_advice_single_file(pkgfile,patient,pkgside)
% pkgOffMeds  = bksabs > 32 & bksabs < 80;
% pkgOnMeds   = bksabs <= 20 & bksabs > 0;
%{
    We use BKS>26<40 (BKS=26 =UPDRS III~30)as a marker of
    ?OFF? and >32<40 as (BKS=32 =UPDRS III~45)marker of very OFF
    We use DKS>7 as a marker of dyskinesia and > 16 as significant dyskinesia
    Generally when BKS>26, DKS will be low.
    We don?t usually use the terminology of OFF/On/dyskinesia use in diaries
    because they are categorical states compared to a continuous variable.
    If I can ask you the same question for UPDRS and AIMS score
    what cut-off would you like to use to indicate those
    same states and then I can give you approximate numbers for the BKS DKS.
    We have good evidence thatTreatable bradykinesia
    (i.e. presumable OFF according to a clinician) is when the
     BKS>26 (or <-26 as per the csv files)
    Good control (i.e. neither OFF nor ON) is when BKS <26 AND DKS<7
    Dyskinesia is when DKS>7 and BKS <26.
    However you should not use single epochs alone.
    We tend to use the 4/7 or 3/5 rule ?
    that is use take the first 7 epochs of BKS (or DKS),
    then the middle epoch will be ?OFF? if 4/7 of the epochs >26.
    Slide along one and apply the rule again etc.
    Mal Horne
    malcolm.horne@florey.edu.au
    Wed 7/24/2019 7:12 PM email
    subjet: More data for UCSF

    DKS ? and note the 75th percentile of controls" - what is the number for this?
    RE BKS ? see bands of activity ? suggest you make more correlation for BKS in range 18-40
    As said before, above 80 = sleep and between 40-80 = inactivity (i.e. on couch)
    Tue 7/9/2019 5:10 PM
    subject:
    sessions with detailed data
%}
%% plot all the raw data in histogram form 
plotscores = 1;
if plotscores
    [pn,fn,ext] = fileparts(pkgfile); 
    figdir = pn; 
    % plot the raw scores 
    % bradykinesia, dyskiensia, tremor severity
    cntplt = 1;
    hfig = figure;
    hfig.Color = 'w';
    cntdys = 1; hdysk = [];
    cntbrd = 1; hbrdy = [];
    cnttrm = 1; htrem = [];
    ss = 1;
    % read pkg
    pkgTable = readtable(pkgfile);
    timesPKG = pkgTable.Date_Time;
    timesPKG.TimeZone = 'America/Los_Angeles';
    
    % get rid of NaN data (it's empty on startup
    pkgTable = pkgTable(~isnan(pkgTable.BK),:);

    
    % check if BK is in a positive scale, if so, flip it 
    if prctile(pkgTable.BK,50)>0
        % get rid of negative values 
        pkgTable = pkgTable(pkgTable.BK>=0,:);
        % flip the sign of all bk vals 
        pkgTable.BK = pkgTable.BK.*(-1);
    end
    
    
    % get rid of off wrist data
    pkgTable = pkgTable(~pkgTable.Off_Wrist,:);
    
    % brakdykinesia
    hbrdy(cntbrd) =  subplot(2,2,cntplt); cntplt = cntplt + 1; cntbrd = cntbrd + 1;
    hold on;
    histogram(pkgTable.BK,'Normalization','probability',...
        'BinWidth',10);
    titleUse{1,1} = patient;
    titleUse{1,2} = sprintf('%s','bradykinesia');
    ylims = get(gca,'YLim');
    hp(1) = plot([-26 -26],ylims,'LineWidth',2,'Color','r','LineStyle','-.');
    hp(2) = plot([-80 -80],ylims,'LineWidth',2,'Color','k','LineStyle','-.');
    %     legend(hp,{'> BK = off','> BK = sleep'});
    title(titleUse)
    set(gca,'FontSize',16);
    
    % tremor
    htrem(cnttrm) =  subplot(2,2,cntplt); cntplt = cntplt + 1; cnttrm = cnttrm + 1;
    hold on;
    histogram(pkgTable.Tremor_Score(pkgTable.Tremor_Score~=0),...
        'Normalization','probability',...
        'BinWidth',5);
    titleUse{1,1} = patient;
    titleUse{1,2} = sprintf('%s','tremor');
    title(titleUse)
    set(gca,'FontSize',16);
    
    
    % dyskinesia
    hdysk(cntdys) =  subplot(2,2,cntplt); cntplt = cntplt + 1; cntdys = cntdys + 1;
    hold on;
    histogram(log10(pkgTable.DK),'Normalization','probability',...
        'BinWidth',0.3);
    titleUse{1,1} = patient;
    titleUse{1,2} = sprintf('%s','dyskinesia');
    ylims = get(gca,'YLim');
    hp(3) = plot([log10(7) log10(7)],ylims,'LineWidth',2,'Color',[0 0.8 0],'LineStyle','-.');
    hp(4) = plot([log10(16) log10(16)],ylims,'LineWidth',2,'Color',[0 0.8 0],'LineStyle','-.');
    %     legend(hp,{'< DK = dyskinetic'});
    title(titleUse)
    set(gca,'FontSize',16);
    title(titleUse)

    
    
    % use 3/5 rule to look at 10 minute epochs
    for i = 3:(size(pkgTable,1)-2)
        bkvals = pkgTable.BK(i-2:i+2);
        dkvals = pkgTable.DK(i-2:i+2);
        tremor = pkgTable.Tremor(i-2:i+2);
        % off - bks under 26 and over 80 (sleep)
        cnt = 1;
        state = {};
        if sum(bkvals <= -26 & bkvals >= -80) >=3 % off
            state{cnt} = 'off'; cnt = cnt +1;
        end
        %     Good control (i.e. neither OFF nor ON) is when BKS <26 AND DKS<7
        if sum(bkvals >= -26 & dkvals <= 16) >=3 % on
            state{cnt} = 'on'; cnt = cnt +1;
        end
        % dyskinesia mild
        if sum(bkvals >= -26 & (dkvals >= 7 & dkvals < 16)) >=3 % on
            state{cnt} = 'dyskinesia mild'; cnt = cnt +1;
        end
        % dyskinesia severe
        if sum(bkvals >= -26 & dkvals >= 16) >=3 % on
            state{cnt} = 'dyskinesia severe'; cnt = cnt +1;
        end
        %    tremor
        if sum(tremor) >=3 % tremor
            state{cnt} = 'tremor'; cnt = cnt +1;
        end
        %   sleep
        if  sum(bkvals < -80) >=3 % off
            state{cnt} = 'sleep'; cnt = cnt +1;
        end
        tremorScore = mean(tremor);
        if length(state)==2
            x = 2;
        end
        stateLens(i) = length(state);
        if isempty(state)
            states{i,1} = 'uncategorized';
        else
            stateout = '';
            for s = 1:length(state)
                if s == 1
                    stateout = [stateout state{s}];
                else
                    stateout = [stateout ' ' state{s}];
                end
            end
            states{i,1} = stateout;
        end
    end
    
    Conditions = categorical(states(3:end),...
        unique(states(3:end)));
    
    % states
    hstate(cntplt) =  subplot(2,2,cntplt); cntplt = cntplt + 1; cntbrd = cntbrd + 1;
    h = histogram(Conditions,'Normalization','probability');
    h.DisplayOrder = 'descend';
    ylabel('% time / condition');
    titleUse{1,1} = patient;
    titleUse{1,2} = sprintf('%s - %s (%s)',pkgTable.Date_Time(1),pkgTable.Date_Time(end),...
        pkgTable.Date_Time(end)-pkgTable.Date_Time(1));
    title(titleUse)
    set(gca,'FontSize',16);
    % save table
    states = states(3:end);
    idxsave = 3:(size(pkgTable,1)-2);
    pkgTable = pkgTable(idxsave,:);
    pkgTable.states = states;
    clear states;
    
    times = [pkgTable.Date_Time(1) pkgTable.Date_Time(end)];
    times.Format = 'uuuu-MM-dd HH-mm-ss';
    
    
    filesavefn = sprintf('%s_pkg-%s_%s_%s_scores',patient,pkgside,...
        datetime(pkgTable.Date_Time(1),'Format','dd-MMM-uuuu'),...
        datetime(pkgTable.Date_Time(end),'Format','dd-MMM-uuuu') );
    
    savefn = fullfile(figdir,filesavefn);
    save(savefn,'pkgTable');
    
    set(gca,'FontSize',16);
    prfig.plotwidth           = 15;
    prfig.plotheight          = 15;
    prfig.figdir              = figdir;
    figsavename = sprintf('%s_pkg-%s_%s_%s_scores',patient,pkgside,...
        datetime(pkgTable.Date_Time(1),'Format','dd-MMM-uuuu'),...
        datetime(pkgTable.Date_Time(end),'Format','dd-MMM-uuuu') );
    prfig.figname             = figsavename;
    plot_hfig(hfig,prfig)
    
end
close(hfig);

%% plot correlation between metrics 

hfig = figure;
hfig.Color = 'w';
cnt = 1;
idxsleep = pkgTable.BK<=-80;
pkgTable = pkgTable(~idxsleep,:);

% process data a bit - idx for tremor etc.
idxtremor = logical(pkgTable.Tremor);
tremoscor = pkgTable.Tremor_Score;
dkScores = pkgTable.DK;
% make zero scores slighgly bigger than zeros
dkScores(dkScores==0) = min(dkScores(dkScores~=0));
dkScores  = log10(dkScores);
bkScores  = pkgTable.BK;
% plot correlation between DK and BK
subplot(1,3,cnt); cnt = cnt + 1;
r = corr(dkScores,bkScores);
scatter(dkScores,bkScores,10,'filled','MarkerFaceAlpha',0.2)
xlabel('DK');
ylabel('BK');
ttluse = sprintf('%s %s BK/DK corr (r = %.2f)',patient,pkgside,r);
title(ttluse);

% plot correlatiob between DK and tremor
subplot(1,3,cnt); cnt = cnt + 1;
dktremor = dkScores(idxtremor);
tremscor = tremoscor(idxtremor);
r = corr(dktremor,tremscor);
scatter(dktremor,tremscor,20,'filled','MarkerFaceAlpha',0.2)
xlabel('DK');
ylabel('Tremor');
ttluse = sprintf('%s %s DK/tremor corr (r = %.2f)',patient,pkgside,r);
title(ttluse);

% plot correlatiob between BK and tremor
subplot(1,3,cnt); cnt = cnt + 1;
bktremor = bkScores(idxtremor);
tremscor = tremoscor(idxtremor);
r = corr(bktremor,tremscor);
scatter(bktremor,tremscor,20,'filled','MarkerFaceAlpha',0.2)
xlabel('BK');
ylabel('Tremor');
ttluse = sprintf('%s %s BK/tremor corr (r = %.2f)',patient,pkgside,r);
title(ttluse);

perTrem = sum(idxtremor)/length(dkScores);
ttluse = sprintf('%s (Tremor - %0.2f)',patient,perTrem);
sgtitle(ttluse,'FontSize',25);

figsavename = sprintf('%s_pkg-%s_%s_%s_correlations',patient,pkgside,...
    datetime(pkgTable.Date_Time(1),'Format','dd-MMM-uuuu'),...
    datetime(pkgTable.Date_Time(end),'Format','dd-MMM-uuuu') );

prfig.plotwidth           = 11;
prfig.plotheight          = 8;
prfig.figdir              = figdir;
prfig.figtype             = '-dpdf';
prfig.figname             = figsavename;
plot_hfig(hfig,prfig)
close(hfig);

return 


%% XXXXXXXXXXXXXXXXXXXX
%% XXXXXXXXXXXXXXXXXXXX
%% XXXXXXXXXXXXXXXXXXXX
%% XXXXXXXXXXXXXXXXXXXX
%% XXXXXXXXXXXXXXXXXXXX
%% XXXXXXXXXXXXXXXXXXXX
%% TO DO 
%% TO DO 
%% TO DO 
%% TO DO 
%% TO DO 
%% TO DO 
%% TO DO 
%% TO DO 
%% TO DO 
%% TO DO 
%% TO DO 
%% TO DO 
% in the future add this to plot all the days based on states 
%% XXXXXXXXXXXXXXXXXXXX
%% XXXXXXXXXXXXXXXXXXXX
%% XXXXXXXXXXXXXXXXXXXX
%% XXXXXXXXXXXXXXXXXXXX
%% XXXXXXXXXXXXXXXXXXXX
%% XXXXXXXXXXXXXXXXXXXX

%% plot one day example of PKG data / patient 
pkgdatdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/pkg_data/processed_data';
figdirout = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/pkg_data/figures/pkg_behav_measures/one_day_final';
resultsdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home';
load(fullfile(pkgdatdir,'pkgDataBaseProcessed.mat'),'pkgDB');

uniqePatients = unique(pkgDB.patient); 
uniqeSides    = unique(pkgDB.side); 
close all;
%% get some general states about PKG 
clc;
BKall = [];
DKall = []; 
for p = 1 :length(uniqePatients)
    for s = 1:length(uniqeSides)
        idxpat = strcmp(uniqePatients{p},pkgDB.patient) &  strcmp(uniqeSides{s},pkgDB.side); 
        load(pkgDB.savefn{idxpat}); 
        BKall = [BKall ; pkgTable.BK];
        DKall = [DKall ; pkgTable.DK];
    end
end
BKall = abs(BKall); 
fprintf('mean BK %.2f range (%.2f - %.2f)\n',mean(BKall),min(BKall),max(BKall) ); 
fprintf('mean DK %.2f range (%.2f - %.2f)\n',mean(DKall),min(DKall),max(DKall) ); 

fprintf('\n\n'); 
fprintf('BK %.2f %.2f %.2f (25,50,75 - percentiles)\n',prctile(BKall,25),prctile(BKall,50),prctile(BKall,75));
fprintf('DK %.2f %.2f %.2f (25,50,75 - percentiles)\n',prctile(DKall,25),prctile(DKall,50),prctile(DKall,75));


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



end