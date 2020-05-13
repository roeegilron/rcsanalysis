function hfig = plot_continuos_recording_report_from_table(startTimes,duration)
timeDomainFileDur(:,1) = startTimes;
timeDomainFileDur(:,2) = startTimes + duration;

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

% get y values for graph 
 
for d = 1:size(allTimesNew,1)
    monthTemp = month(allTimesNew(d,1));
    dayTemp = day(allTimesNew(d,1));
    idxUse = find(monthTemp == unqMonthsAndDays(:,1) & dayTemp == unqMonthsAndDays(:,2));
    yValue(d) = idxUse; 
    dateTime(idxUse,1) = allTimesNew(d,1);
end
% get labels for y values
ylabelsUse = {}; 
for d = 1:size(unqMonthsAndDays,1)
    dayTemp = day(dateTime(d,1));
    [m,str] = month(datenum(dateTime(d,1)));
    ylabelsUse{d,1} = sprintf('%s %d',str,dayTemp);
end
% plot figure 
hfig = figure; 
hold on; 
hax = subplot(1,1,1); 
plot(timeofday( allTimesNew' ),[yValue' yValue']',...
    'LineWidth',10,...
    'Color',[0.8 0 0 0.7]);
hax.YTick = [1 : 1: max(yValue)];
hax.YTickLabel = ylabelsUse;
hax.YLim = [hax.YLim(1)-1 hax.YLim(2)+1];
set(gca,'FontSize',16); 
ttluse = sprintf('Continous Chronic Recording at Home (%s hours)',sum(timeDomainFileDur(:,2) - timeDomainFileDur(:,1))); 
title(ttluse);
set(gcf,'Color','w'); 


