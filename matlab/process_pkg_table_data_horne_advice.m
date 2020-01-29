function process_pkg_table_data_horne_advice()
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

close all;
%% load the data
figdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/pkg_data/figures';
datdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/pkg_data/processed_data';

cnt = 1;
% RCS06
pkgChoose{cnt,1}  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/pkg_data/UCSF_Scores_Dose_27_Nov_2019/scores_20191008_123107.csv'; % R
patient{cnt,1} = 'RCS06 R hand';
%
pkgChoose{cnt,2}  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/pkg_data/UCSF_Scores_Dose_27_Nov_2019/scores_20191008_122956.csv'; % L hand
patient{cnt,2} = 'RCS06 L hand';

cnt = cnt+1;

% RCS07
pkgChoose{cnt,1}  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/pkg_data/UCSF_Scores_Dose_27_Nov_2019/scores_20190918_144940.csv'; % R
patient{cnt,1} = 'RCS07 R hand';

pkgChoose{cnt,2}  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/pkg_data/UCSF_Scores_Dose_27_Nov_2019/scores_20190918_145105.csv'; % L hand
patient{cnt,2} = 'RCS07 L hand';

cnt = cnt+1;

% RCS05
pkgChoose{cnt,1}  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/pkg_data/UCSF_Scores_Dose_27_Nov_2019/scores_20190805_140217.csv'; % R
patient{cnt,1} = 'RCS05 R hand';
%
pkgChoose{cnt,2}  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/pkg_data/UCSF_Scores_Dose_27_Nov_2019/scores_20190801_150333.csv'; % L hand
patient{cnt,2} = 'RCS05 L hand';

cnt = cnt+1;

%RCS02
pkgChoose{cnt,1}  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/pkg_data/UCSF_Scores_17_July_2019/scores_20190515_124531.csv'; % R hand
patient{cnt,1} = 'RCS02 R hand';
%
pkgChoose{cnt,2}  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/pkg_data/UCSF_Scores_17_July_2019/scores_20190515_124018.csv'; % L hand
patient{cnt,2} = 'RCS02 L hand';

cnt = cnt+1;

%rcs 03 
pkgChoose{cnt,1} = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/pkg_data/UCSF_Scores_17_July_2019/scores_20190620_104140.csv';
patient{cnt,1}   = 'RCS03 R hand';

cnt = cnt+1;

plotscores = 0;
if plotscores
    
    % plot the raw scores for all subjects
    % bradykinesia, dyskiensia, tremor severity
    cnt = 1;
    hfig = figure;
    hfig.Color = 'w';
    cntdys = 1; hdysk = [];
    cntbrd = 1; hbrdy = [];
    cnttrm = 1; htrem = [];
    for p = 1:size(pkgChoose,1)
        
        for ss = 1:2 % loop on sides
            % read pkg
            pkgTable = readtable(pkgChoose{p,ss});
            timesPKG = pkgTable.Date_Time;
            timesPKG.TimeZone = 'America/Los_Angeles';
            
            % get rid of NaN data (it's empty on startup
            pkgTable = pkgTable(~isnan(pkgTable.BK),:);
            
            % get rid of off wrist data
            pkgTable = pkgTable(~pkgTable.Off_Wrist,:);
            
            % brakdykinesia
            hbrdy(cntbrd) =  subplot(4,6,cnt); cnt = cnt + 1; cntbrd = cntbrd + 1;
            hold on;
            histogram(pkgTable.BK,'Normalization','probability',...
                'BinWidth',10);
            titleUse{1,1} = patient{p,ss};
            titleUse{1,2} = sprintf('%s','bradykinesia');
            ylims = get(gca,'YLim');
            hp(1) = plot([-26 -26],ylims,'LineWidth',2,'Color','r','LineStyle','-.');
            hp(2) = plot([-80 -80],ylims,'LineWidth',2,'Color','k','LineStyle','-.');
            %     legend(hp,{'> BK = off','> BK = sleep'});
            title(titleUse)
            set(gca,'FontSize',16);
            
            % tremor
            htrem(cnttrm) =  subplot(4,6,cnt); cnt = cnt + 1; cnttrm = cnttrm + 1;
            hold on;
            
            histogram(pkgTable.Tremor_Score(pkgTable.Tremor_Score~=0),...
                'Normalization','probability',...
                'BinWidth',5);
            titleUse{1,1} = patient{p,ss};
            titleUse{1,2} = sprintf('%s','tremor');
            title(titleUse)
            set(gca,'FontSize',16);
            
            
            % dyskinesia
            hdysk(cntdys) =  subplot(4,6,cnt); cnt = cnt + 1; cntdys = cntdys + 1;
            hold on;
            histogram(log10(pkgTable.DK),'Normalization','probability',...
                'BinWidth',0.3);
            titleUse{1,1} = patient{p,ss};
            titleUse{1,2} = sprintf('%s','dyskinesia');
            ylims = get(gca,'YLim');
            hp(3) = plot([log10(7) log10(7)],ylims,'LineWidth',2,'Color',[0 0.8 0],'LineStyle','-.');
            hp(4) = plot([log10(16) log10(16)],ylims,'LineWidth',2,'Color',[0 0.8 0],'LineStyle','-.');
            %     legend(hp,{'< DK = dyskinetic'});
            
            title(titleUse)
            set(gca,'FontSize',16);
            
            
            
            title(titleUse)
            if cnt == 7
                %         legend(hp,{'> BK = off','> BK = sleep','< DK = dyskinetic'},'Location','northeast');
            end
            set(gca,'FontSize',16);
        end
    end
    linkaxes(hdysk,'x');
    linkaxes(hbrdy,'x');
    linkaxes(htrem,'x');
    
    prfig.plotwidth           = 24;
    prfig.plotheight          = 15;
    prfig.figdir              = figdir;
    prfig.figname             = 'all_raw_scores';
    plot_hfig(hfig,prfig)
    
    
    pkgDB = table();
    cntpt = 1;
    for p = 1:size(pkgChoose,1)
        hfig = figure;
        hfig.Color = 'w';
        for ss = 1:2 % loop on sides
            % read pkg
            pkgTable = readtable(pkgChoose{p,ss});
            timesPKG = pkgTable.Date_Time;
            timesPKG.TimeZone = 'America/Los_Angeles';
            
            % get rid of NaN data (it's empty on startup
            pkgTable = pkgTable(~isnan(pkgTable.BK),:);
            
            % get rid of off wrist data
            pkgTable = pkgTable(~pkgTable.Off_Wrist,:);
            
            
            
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
            subplot(1,2,ss);
            h = histogram(Conditions,'Normalization','probability');
            h.DisplayOrder = 'descend';
            ylabel('% time / condition');
            titleUse{1,1} = patient{p,ss};
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
            stateSvName = sprintf('%s_%s_%s.mat',patient{p,ss},times(1),times(2));
            savefn = fullfile(datdir,stateSvName);
            save(savefn,'pkgTable');
            % pkg database
            pkgDB.patient{cntpt} = patient{p,ss}(1:5);
            pkgDB.side{cntpt} = patient{p,ss}(7);
            pkgDB.timerange(cntpt,:)   = times;
            pkgDB.savefn{cntpt}      = savefn;
            cntpt = cntpt + 1;
        end
        
        prfig.plotwidth           = 15;
        prfig.plotheight          = 10;
        prfig.figdir              = figdir;
        prfig.figname             = sprintf('%s pkg categories' ,patient{p,ss}(1:5));
        plot_hfig(hfig,prfig)
    end
    save(fullfile(datdir,'pkgDataBaseProcessed.mat'),'pkgDB');
end

%% plot correlation between metrics 
load /Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/pkg_data/processed_data/pkgDataBaseProcessed.mat


uniqupatients = unique(pkgDB.patient); 
uniquesides   = unique(pkgDB.side); 
for p = 1:length(uniqupatients) 
    hfig = figure;
    hfig.Color = 'w';
    cnt = 1; 
    for s = 1:length(uniquesides)
        % find and load file 
        x =2 ;
        patient = uniqupatients{p};
        side    = uniquesides{s}; 
        idx = strcmp(pkgDB.patient,patient) & strcmp(pkgDB.side,side);
        load(pkgDB.savefn{idx})
        
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
        subplot(2,3,cnt); cnt = cnt + 1;
        r = corr(dkScores,bkScores); 
        scatter(dkScores,bkScores,10,'filled','MarkerFaceAlpha',0.2)
        xlabel('DK');
        ylabel('BK');
        ttluse = sprintf('%s BK/DK corr (r = %.2f)',side,r);
        title(ttluse);
        
        % plot correlatiob between DK and tremor 
        subplot(2,3,cnt); cnt = cnt + 1;
        dktremor = dkScores(idxtremor); 
        tremscor = tremoscor(idxtremor); 
        r = corr(dktremor,tremscor);
        scatter(dktremor,tremscor,20,'filled','MarkerFaceAlpha',0.2)
        xlabel('DK');
        ylabel('Tremor');
        ttluse = sprintf('%s DK/tremor corr (r = %.2f)',side,r);
        title(ttluse);
        
        % plot correlatiob between BK and tremor 
        subplot(2,3,cnt); cnt = cnt + 1;
        bktremor = bkScores(idxtremor);
        tremscor = tremoscor(idxtremor); 
        r = corr(bktremor,tremscor);
        scatter(bktremor,tremscor,20,'filled','MarkerFaceAlpha',0.2)
        xlabel('BK');
        ylabel('Tremor');
        ttluse = sprintf('%s BK/tremor corr (r = %.2f)',side,r);
        title(ttluse);
        
    end
    perTrem = sum(idxtremor)/length(dkScores); 
    ttluse = sprintf('%s (Tremor - %0.2f)',patient,perTrem);
    sgtitle(ttluse,'FontSize',25); 
    prfig.plotwidth           = 15;
    prfig.plotheight          = 10;
    prfig.figdir              = figdir;
    prfig.figtype             = '-djpeg';
    prfig.figname             = sprintf('%s pkg corelations' ,patient);
    plot_hfig(hfig,prfig)

end



end