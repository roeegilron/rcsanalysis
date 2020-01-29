function plot_pkg_behav_example()
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