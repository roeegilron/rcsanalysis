function plot_continuos_recording_report_across_patients()
cnt = 1;
clc; 
close all;
% RCS02
procsDatas{cnt} = '/Volumes/Samsung_T5/RCS02/RCS02_all_home_data_processed/data/RCS02R/processedData.mat'; cnt = cnt +1; 
% RCS05
procsDatas{cnt} = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS05/v05_3week/data_dump/SummitContinuousBilateralStreaming/RCS05L/processedData.mat'; cnt = cnt +1; 
% RCS07
procsDatas{cnt} = '/Volumes/Samsung_T5/RCS07/v14_data_dump/SummitContinuousBilateralStreaming/RCS07L/processedData.mat'; cnt = cnt +1; 

subs = {'RCS02','RCS05','RCS07'};
rootdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/presentations/figures';
%% plot recording duration to see how much data was recoded per day
% split up recordings that are not in the samy day
% params to print the figures
prfig.plotwidth           = 17;
prfig.plotheight          = 12;
prfig.figdir              = rootdir;
prfig.figtype             = '-djpeg';
prfig.closeafterprint     = 0;
prfig.resolution          = 300;

hfig = figure; 
for p = 1:length(procsDatas)
    load(procsDatas{p},'timeDomainFileDur');
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
    
    for xx = 1:size(allTimesNew,1)
        timeDiff = allTimesNew(xx,2) - allTimesNew(xx,1);
        fprintf('%s %0.2d\t%s dur\t %s\t-%s\n',subs{p},xx,timeDiff,allTimesNew(xx,1),allTimesNew(xx,2));
    end
    
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
    hold on;
    hax = subplot(2,2,p);
    plot(timeofday( allTimesNew' ),[yValue' yValue']',...
        'LineWidth',10,...
        'Color',[0.8 0 0 0.7]);
    hax.YTick = [1 : 1: max(yValue)];
    hax.YTickLabel = ylabelsUse;
    hax.YLim = [hax.YLim(1)-1 hax.YLim(2)+1];
    set(gca,'FontSize',14);
    hoursRecorded = sum(allTimesNew(:,2) - allTimesNew(:,1));
    hoursRecorded.Format = 'hh:mm';
    ttluse = sprintf('%s Continous Chronic Recording at Home (%s hours)',subs{p},hoursRecorded);
    title(ttluse);
end
set(gcf,'Color','w');
prfig.figname  = 'continous recording report across subjects';
plot_hfig(hfig,prfig);
close(hfig);
