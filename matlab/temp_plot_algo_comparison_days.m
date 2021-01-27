function temp_plot_algo_comparison_days(dirname)
ff = findFilesBVQX(dirname,'*.mat');
outPlot = table();
for f = 1:length(ff)
    load(ff{f});
    % get a table of unique states and unique currents as well as hours 
    outPlot.time(f) = aPlot.time(1); 
    
    stateTable = table();
    
    idx = 1; 
    while idx < size(aPlot,1)-1
        stateTable.current(idx) =  aPlot.prog0(idx);
        stateTable.state(idx)  = aPlot.newstate(idx);
        stateTable.numMin(idx)  = minutes(aPlot.time(idx+1) - aPlot.time(idx));
        idx = idx + 1; 
    end
    
    sumTable = table(); 
    sumTable.totalMin = minutes(sum(stateTable.numMin));
    % get unique states and plot % time per state 
    unqStates = unique(stateTable.state);
    unqStates = unique(stateTable.state);
    for s = 1:length(unqStates)
        idxuse = unqStates(s) == stateTable.state;
        sumTable.unqStates(s) = unqStates(s);
        sumTable.percInState(s) = sum(stateTable.numMin(idxuse))/sum(stateTable.numMin);
    end
    
    outPlot.sumTable{f} = sumTable;
    % get unique curernt and plot time
    
    
end

%%
hfig = figure;
hfig.Color = 'w'; 
for i = 1:4
    hsb = subplot(2,2,i);
    sumTable = outPlot.sumTable{i};
    unqStates = sumTable.unqStates;
    pie(sumTable.percInState);
    legendOut = {};
    for ss = 1:length(sumTable.unqStates)
        legendOut{1,ss} = sprintf('%d',unqStates(ss));
    end
    legend(legendOut,'Location','southoutside','Orientation','horizontal')
    dayuse = outPlot.time;
    [y,m,d] = ymd(outPlot.time(i));
    ttluse = sprintf('%d/%0.2d/%0.2d',y,m,d);
    title(ttluse);
end


end