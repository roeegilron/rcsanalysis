function plot_adaptive_log(fn)

adaptiveLogTable = read_adaptive_txt_log(fn);
%%
allDays =  day(adaptiveLogTable.time);
allMonths = month(adaptiveLogTable.time);
unqDays  = unique(day(adaptiveLogTable.time));
unqMonth = unique(month(adaptiveLogTable.time));

for m = 1:length(unqMonth)
    for d = 1:length(unqDays)
        idxuse = allMonths == unqMonth(m) & allDays == unqDays(d); 
        aPlot = adaptiveLogTable(idxuse,:); 
        if ~isempty(aPlot)
            aPlot = sortrows(aPlot,'time');
            dayPlot = table(); 
            dCnt = 1; 
            for i = 1:size(aPlot,1)
                if i == 1 
                   dayPlot.time(dCnt) = aPlot.time(i); 
                   dayPlot.current(dCnt) = aPlot.prog0(i); 
                   dCnt = dCnt + 1; 
                else 
                   if aPlot.prog0(i) == aPlot.prog0(i-1)
                       dayPlot.time(dCnt) = aPlot.time(i);
                       dayPlot.current(dCnt) = aPlot.prog0(i);
                       dCnt = dCnt + 1;
                   else
                       dayPlot.time(dCnt) = aPlot.time(i);
                       dayPlot.current(dCnt) = aPlot.prog0(i-1);
                       dCnt = dCnt + 1;
                       dayPlot.time(dCnt) = aPlot.time(i);
                       dayPlot.current(dCnt) = aPlot.prog0(i);
                       dCnt = dCnt + 1;
                   end
                end
            end
            
            %% plot 
            % compute weighted average for the day 
            numSecsPerCurrent = seconds(diff(dayPlot.time));
            currentsUse = dayPlot.current(2:end); 
            currentsWeighted = {};
            for a = 1:length(currentsUse)
                currentsWeighted{a} = repmat(currentsUse(a),1,numSecsPerCurrent(a));
            end
            weightedMean  = mean([currentsWeighted{:}]);
            nonWeightedMean = mean(dayPlot.current);
            fprintf('w mean = %.2f non weighted mean = %.2f\n',weightedMean,nonWeightedMean);
            
            % plot 
            hfig = figure;
            hfig.Color = 'w';
            hPlt = plot(dayPlot.time,dayPlot.current,'LineWidth',2,'Color',[0 0 0.8 0.5]);
            hsb = gca;
            ylims = hsb.YLim;
            hsb.YLim(1) = hsb.YLim(1)*0.9;
            hsb.YLim(2) = hsb.YLim(2)*1.1;
            ttluse = sprintf('%d/%d/%d (%.2fmA = avg current)',month(dayPlot.time(1)),day(dayPlot.time(1)),year(dayPlot.time(1)),weightedMean);
            title(ttluse);
            ttlsave = sprintf('%d_%d_%d',month(dayPlot.time(1)),day(dayPlot.time(1)),year(dayPlot.time(1)));
            
            [pn,~] = fileparts(fn);
            prfig.plotwidth           = 8;
            prfig.plotheight          = 6;
            prfig.figdir             = pn;
            prfig.figname             = ttlsave;
            prfig.figtype             = '-djpeg';
            plot_hfig(hfig,prfig)
            close(hfig);

            %%
        end
    end
end
return 

%%
figure;
plot(adaptiveLogTable.time, adaptiveLogTable.prog0)
end