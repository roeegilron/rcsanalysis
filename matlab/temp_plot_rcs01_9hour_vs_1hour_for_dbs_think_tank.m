function temp_plot_rcs01_9hour_vs_1hour_for_dbs_think_tank()
% temporary function 
close all;
clear all;

prfig.figdir  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v19_adaptive_month5_day2/figures';
prfig.figtype = '-djpeg';
prfig.resolution = 600;
prfig.closeafterprint = 0; 

% load 1 hour 
load /Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v19_adaptive_month5_day2/results/durationPerState1Hour3_RCS01.mat
durPerStateRaw{1} = durationsPerState{1}; 
durPerStateRaw{2} = [durationsPerState{2} durationsPerState{3}];; 
durPerState = cellfun(@(x) sum(x),durPerStateRaw); 

hfig = figure; 
hsubPie = subplot(1,2,1); 
axes(hsubPie);
lbls = {'state 1 - ','state 2 - '};

hPie = pie(hsubPie,durPerState./(sum(durPerState)),[1 1  ]); 
pText = findobj(hPie,'Type','text');
percentValues = get(pText,'String'); 
combinedtxt = strcat(lbls,percentValues'); 
for p = 1:length(pText)
    pText(p).String = combinedtxt{p}; 
    pText(p).FontSize = 16; 
end
set(gca,'FontSize',20); 
title('1 hour in clinic (% time/state)'); 


% load 2 hour 
clear durPerStateRaw durPerState
load /Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v19_adaptive_month5_day2/results/durationPerState9Hour_RCS01.mat
durPerStateRaw{1} = durationsPerState{1}; 
durPerStateRaw{2} = [durationsPerState{2} durationsPerState{3}]; 
durPerState = cellfun(@(x) sum(x),durPerStateRaw); 

hsubPie = subplot(1,2,2); 
axes(hsubPie);
lbls = {'state 1 - ','state 2 - '};

hPie = pie(hsubPie,durPerState./(sum(durPerState)),[1 1  ]); 
pText = findobj(hPie,'Type','text');
percentValues = get(pText,'String'); 
combinedtxt = strcat(lbls,percentValues'); 
for p = 1:length(pText)
    pText(p).String = combinedtxt{p}; 
    pText(p).FontSize = 16; 
end
set(gca,'FontSize',20); 
title('9 hour at home (% time/state)'); 

sgtitle('Adaptive thresholds set in clinic change at home','FontSize',25); 
hfig.Color = [1 1 1];

prfig.plotwidth           = 15;
prfig.plotheight          = 10;
prfig.figname             = '1 hour vs 9 hours';
plot_hfig(hfig,prfig)

end