function plot_amp_amp_corrs_all_patients()
%%
close all;
rootdir = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/processed_data/';
ff = findFilesBVQX(rootdir,'*psdNewOpenMindAlgo__stim-off.mat');
figdirsave = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/figures_amp_amp_correlations';

PLOT_AMP_AMP_EACH_SIDE_SEP = 1;
PLOT_AMP_AMP_CORR_ACROSS_SIDES = 0;
%%
if PLOT_AMP_AMP_EACH_SIDE_SEP
    for fff = 3% 1:length(ff)
        fnload = ff{fff};
        load(fnload,'psdDataOut','dataOut','psdTimesOut','database');
        
        % only select daylight times and do some artifact removal
        %%
        close all;
        idxWhisker = []; wUpper = []; wLower = [];
        for c = 1:4
            dat = dataOut(:,:,1)';
            meanVals = log10(mean(dat(:,40:60),2));
            q75_test=quantile(meanVals,0.75);
            q25_test=quantile(meanVals,0.25);
            w=2.0;
            wUpper(c) = w*(q75_test-q25_test)+q75_test;
            wLower(c) = -w*(q75_test-q25_test)-q75_test;
                        
%             wUpper(c,1) = mean(meanVals)+2*std(meanVals);
%             wLower(c,1) = mean(meanVals)-2*std(meanVals);
            idxWhisker(:,c) = meanVals < wUpper(c) & meanVals > wLower(c);
        end
        idxkeep = idxWhisker(:,1) &  idxWhisker(:,2) & idxWhisker(:,3) & idxWhisker(:,4) ;
        
        % get implant date
        masterDataId  = get_device_id_return_meta_data(database.deviceSettingsFn{1});
        % only get wake times:
        idxtimekeep = hour(psdTimesOut) >= 8 &  hour(psdTimesOut) <= 22 & psdTimesOut > masterDataId.implntDate;
        
        % set up panel
        addpath(genpath(fullfile(pwd,'toolboxes','panel-2.14')));
        hsb = gobjects();
        hfig = figure;
        hfig.Color = 'w';
        hpanel = panel();
        hpanel.pack(3,4);
        hsbAll = gobjects();
        cntPanel = 1;
        % set panel order:
        for i = 1:3
            for j = 1:4
                hsbAll(cntPanel,1) = hpanel(i,j).select();
                cntPanel = cntPanel + 1;
            end
        end
        
        % verify
        dur = size(dat,1)*psdDataOut(1).psdDuration;
        dur.Format = 'hh:mm';
        
        for c = 1:4
            dat = dataOut(:,:,c)';
            cla(hsbAll(c,1));
            datplot = log10(dat(idxkeep & idxtimekeep,: )');
            if size(datplot,2) > 1200
                numRanLines = 1200;
            else
                numRanLines = size(datplot,2);
            end
            idxplot = randperm(size(datplot,2),numRanLines);
            plot(hsbAll(c,1),datplot(:,idxplot),'LineWidth',0.1,'Color',[0.8 0 0 0.1]);
            ticks = [4 12 30 50 60 65 70 75 80 100];
            hsbAll(c,1).XTick = ticks;
            hsbAll(c,1).XLim = [1 100];
            ylabel(hsbAll(c,1),'Power (log_1_0\muV^2/Hz)');
            xlabel(hsbAll(c,1),'Frequency (Hz)');
            grid(hsbAll(c,1),'on');
            hsbAll(c,1).GridAlpha = 0.8;
            hsbAll(c,1).Layer = 'top';
            fnuse = sprintf('chan%d_tdSettings',c);
            titleUse = psdDataOut(1).(fnuse);
            title(hsbAll(c,1),titleUse);
        end
        %%
        
        pairsuse = [1 3; 1 4; 2 3; 2 4; 1 1; 2 2; 3 3; 4 4];
        
        
        
        for pp = 1:size(pairsuse,1)
            
            hsb = hsbAll(pp+4,1);
            cla(hsb);
            fnuse = sprintf('chan%d_tdSettings',pairsuse(pp,1));
            xlab = psdDataOut(1).(fnuse)(1:5);
            fnuse = sprintf('chan%d_tdSettings',pairsuse(pp,2));
            ylab = psdDataOut(1).(fnuse)(1:5);
            
            dat = dataOut(:,:,pairsuse(pp,1))';
            rescaledMvMean1 = zscore(log10(dat(idxkeep & idxtimekeep,:)));
            %     rescaledMvMean1 = dat(idxkeep & idxtimekeep,:);
            
            dat = dataOut(:,:,pairsuse(pp,2))';
            rescaledMvMean2 = zscore(log10(dat(idxkeep & idxtimekeep,:)));
            %     rescaledMvMean1 = dat(idxkeep & idxtimekeep,:);
            
            
            [corrs pvals] = corr(rescaledMvMean1,rescaledMvMean2,'type','Spearman');
            % [corrs pvals] = corrcoef(rescaledMvMean1,rescaledMvMean4);
            %     pvalsCorr = pvals < 0.05/length(pvals(:));
            corrsDiff = corrs;
            %     corrsDiff(corrs<0.6 & corrs>0 ) = NaN;
            %     corrsDiff(corrs<0 & corrs>-0.3 ) = NaN;
            
            % plotting
            if pairsuse(pp,1) ~= pairsuse(pp,2)
                betweenAreas = 1;
            else
                betweenAreas = 0;
            end
            
            if betweenAreas
                axes(hsb);
                b = imagesc(corrsDiff');
                % set(b,'AlphaData',~isnan(corrsDiff'))
                cmin = -0.6;
                cmax = 0.7;
                caxis(hsb, [cmin cmax]);
                colorbar;
            else
                corrsDiff = corrs;
                axes(hsb);
                nrows = size(corrsDiff,1);
                % get rid of diagnoal - turn to NaN since uato correlated
                shifts = [-2 : 1 : 2];
                n = size(corrsDiff,1);
                for ns = 1:length(shifts)
                    A = bsxfun(@eq,[1:n].',1-shifts(ns):n-shifts(ns));
                    corrsDiff(A) = NaN;
                end
                corrsDiff(nrows+1:nrows+1:end) = NaN;
                b = imagesc(corrsDiff');
                set(b,'AlphaData',~isnan(corrsDiff'))% change alpha on diagonal
                cmin = -1;
                cmax = 1;
                caxis(hsb,[cmin cmax]);
                colorbar;
                
            end
            
            set(hsb,'YDir','normal')
            
            % get xlabel
            xlabel(xlab);
            
            % get ylabel
            ylabel(ylab);
            
            
            
            ticks = [4 12 30 50 60 65 70 75 80 100];
            
            
            set(gca,'YDir','normal')
            yticks = [4 12 30 50 60 65 70 75 80 100];
            tickLabels = {};
            ticksuse = [];
            fff = psdDataOut.freqs;
            for yy = 1:length(yticks)
                [~,idx] = min(abs(yticks(yy)-fff));
                ticksuse(yy) = idx;
                tickLabels{yy} = sprintf('%d',yticks(yy));
            end
            hsb.YTick = ticksuse;
            hsb.YTickLabel = tickLabels;
            hsb.XTick = ticksuse;
            hsb.XTickLabel = tickLabels;
            axis tight;
            %         axis square;
            grid(hsb,'on');
            hsb.GridAlpha = 0.8;
            hsb.Layer = 'top';
            
            ttluse  = sprintf('%s %s %s',database.patient{1},database.side{1},dur);
            title(ttluse);
        end
        % save figures;
        fnsave  = sprintf('%s_%s_amp_amp_correlations',database.patient{1},database.side{1});
        
        hpanel.margin = 20;
        hpanel.fontsize = 7;
        % plot
        prfig.plotwidth           = 16;
        prfig.plotheight          = 9;
        prfig.figdir              = figdirsave;
        prfig.figname             = fnsave;
        prfig.figtype             = '-djpeg';
        prfig.closeafterprint     = 0;
        plot_hfig(hfig,prfig)
        %     close(hfig);
        clear('psdDataOut','dataOut','psdTimesOut','database');
        
        
    end
end

%% between L and R correlations
if  PLOT_AMP_AMP_CORR_ACROSS_SIDES
    patients = {'RCS02','RCS05','RCS06','RCS07','RCS08','RCS11','RCS12'};
    
    for pp = 1:length(patients)
        fnleft = findFilesBVQX(rootdir,[patients{pp} '*_L_*stim-off.mat']);
        fnload = fnleft{1};
        load(fnload,'psdTimesOut','dataOut','psdDataOut','database');
        psdTimes_L = psdTimesOut;
        dataOut_L  = dataOut;
        clear psdTimesOut dataOut
        fnright = findFilesBVQX(rootdir,[patients{pp} '*_R_*stim-off.mat']);
        fnload = fnright{1};
        load(fnload,'psdTimesOut','dataOut','psdDataOut','database');
        psdTimes_R = psdTimesOut;
        dataOut_R  = dataOut;
        clear psdTimesOut dataOut
        
        
        
        % get rid of the outliers, then find the times that workd
        idxWhisker = [];
        for c = 1:4
            dat = dataOut_L(:,:,1)';
            meanVals = mean(dat(:,40:60),2);
            q75_test=quantile(meanVals,0.75);
            q25_test=quantile(meanVals,0.25);
            w=2.0;
            wUpper(c) = w*(q75_test-q25_test)+q75_test;
            idxWhisker(:,c) = meanVals < wUpper(c);
        end
        idxkeep = idxWhisker(:,1) &  idxWhisker(:,2) & idxWhisker(:,3) & idxWhisker(:,4) ;
        idxtimekeep = hour(psdTimes_L) >= 8 &  hour(psdTimes_L) <= 22;
        psdTimes_L = psdTimes_L(idxkeep & idxtimekeep);
        dataOut_L = dataOut_L(:,idxkeep & idxtimekeep,:);
        
        idxWhisker = [];
        for c = 1:4
            dat = dataOut_R(:,:,1)';
            meanVals = mean(dat(:,40:60),2);
            q75_test=quantile(meanVals,0.75);
            q25_test=quantile(meanVals,0.25);
            w=2.0;
            wUpper(c) = w*(q75_test-q25_test)+q75_test;
            idxWhisker(:,c) = meanVals < wUpper(c);
        end
        idxkeep = idxWhisker(:,1) &  idxWhisker(:,2) & idxWhisker(:,3) & idxWhisker(:,4) ;
        idxtimekeep = hour(psdTimes_R) >= 8 &  hour(psdTimes_R) <= 22;
        psdTimes_R = psdTimes_R(idxkeep & idxtimekeep);
        dataOut_R = dataOut_R(:,idxkeep & idxtimekeep,:);
        
        
        
        
        
        
        idx = [];
        val = minutes(0);
        for i = 1:length(psdTimes_L)
            [val(i),idx(i) ] = min(abs(psdTimes_L(i) - psdTimes_R)); % idx are on the R side
        end
        idxkeepR = idx(val < minutes(2));
        idxkeepL = val < minutes(2);
        
        dataOut_R = dataOut_R(:,idxkeepR,:);
        dataOut_L = dataOut_L(:,idxkeepL,:);
        
        
        %%
        
        hsb = gobjects();
        hfig = figure;
        hfig.Color = 'w';
        hpanel = panel();
        hpanel.pack(2,4);
        hsbAll = gobjects();
        cntPanel = 1;
        % set panel order:
        for i = 1:2
            for j = 1:4
                hsbAll(cntPanel,1) = hpanel(i,j).select();
                cntPanel = cntPanel + 1;
            end
        end
        %%
        
        
        pairsuse = [1 1; 2 2; 3 3; 4 4; 1 4; 1 3;2 4; 2 3];
        
        
        
        for pp = 1:size(pairsuse,1)
            
            hsb = hsbAll(pp,1);
            cla(hsb);
            fnuse = sprintf('chan%d_tdSettings',pairsuse(pp,1));
            xlab = psdDataOut(1).(fnuse)(1:5);
            xlab = sprintf('R %s',xlab);
            fnuse = sprintf('chan%d_tdSettings',pairsuse(pp,2));
            ylab = psdDataOut(1).(fnuse)(1:5);
            ylab = sprintf('L %s',ylab);
            
            dat = dataOut_R(:,:,pairsuse(pp,1))';
            rescaledMvMean1 = zscore(log10(dat(:,:)));
            %     rescaledMvMean1 = dat(idxkeep & idxtimekeep,:);
            
            dat = dataOut_L(:,:,pairsuse(pp,2))';
            rescaledMvMean2 = zscore(log10(dat(:,:)));
            %     rescaledMvMean1 = dat(idxkeep & idxtimekeep,:);
            
            dur = size(dat,1)*psdDataOut(1).psdDuration;
            dur.Format = 'hh:mm';
            
            [corrs pvals] = corr(rescaledMvMean1,rescaledMvMean2,'type','Spearman');
            % [corrs pvals] = corrcoef(rescaledMvMean1,rescaledMvMean4);
            %     pvalsCorr = pvals < 0.05/length(pvals(:));
            corrsDiff = corrs;
            %     corrsDiff(corrs<0.6 & corrs>0 ) = NaN;
            %     corrsDiff(corrs<0 & corrs>-0.3 ) = NaN;
            
            % plotting
            if pairsuse(pp,1) ~= pairsuse(pp,2)
                betweenAreas = 1;
            else
                betweenAreas = 0;
            end
            
            betweenAreas = 1;
            if betweenAreas
                axes(hsb);
                b = imagesc(corrsDiff');
                % set(b,'AlphaData',~isnan(corrsDiff'))
                cmin = -1;
                cmax = 1;
                caxis(hsb, [cmin cmax]);
                colorbar;
            else
                corrsDiff = corrs;
                axes(hsb);
                nrows = size(corrsDiff,1);
                % get rid of diagnoal - turn to NaN since uato correlated
                shifts = [-2 : 1 : 2];
                n = size(corrsDiff,1);
                for ns = 1:length(shifts)
                    A = bsxfun(@eq,[1:n].',1-shifts(ns):n-shifts(ns));
                    corrsDiff(A) = NaN;
                end
                corrsDiff(nrows+1:nrows+1:end) = NaN;
                b = imagesc(corrsDiff');
                set(b,'AlphaData',~isnan(corrsDiff'))% change alpha on diagonal
                cmin = -1;
                cmax = 1;
                caxis(hsb,[cmin cmax]);
                colorbar;
                
            end
            
            set(hsb,'YDir','normal')
            
            % get xlabel
            xlabel(xlab);
            
            % get ylabel
            ylabel(ylab);
            
            
            
            ticks = [4 12 30 50 60 65 70 75 80 100];
            
            
            set(gca,'YDir','normal')
            yticks = [4 12 30 50 60 65 70 75 80 100];
            tickLabels = {};
            ticksuse = [];
            fff = psdDataOut.freqs;
            for yy = 1:length(yticks)
                [~,idx] = min(abs(yticks(yy)-fff));
                ticksuse(yy) = idx;
                tickLabels{yy} = sprintf('%d',yticks(yy));
            end
            hsb.YTick = ticksuse;
            hsb.YTickLabel = tickLabels;
            hsb.XTick = ticksuse;
            hsb.XTickLabel = tickLabels;
            axis tight;
            %         axis square;
            grid(hsb,'on');
            hsb.GridAlpha = 0.8;
            hsb.Layer = 'top';
            
            ttluse  = sprintf('%s %s %s',database.patient{1},database.side{1},dur);
            title(ttluse);
            
        end
        % save figures;
        fnsave  = sprintf('%s_L-R_betwewen_sides_amp_amp_correlations',database.patient{1});
        
        hpanel.margin = 20;
        hpanel.fontsize = 7;
        % plot
        prfig.plotwidth           = 16;
        prfig.plotheight          = 7;
        prfig.figdir              = figdirsave;
        prfig.figname             = fnsave;
        prfig.figtype             = '-djpeg';
        prfig.closeafterprint     = 0;
        plot_hfig(hfig,prfig)
        
        
    end
    
end


end