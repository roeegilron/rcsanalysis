function res = findIdxOfContinousData(y,dateArray,params)
 
%% convert date array to duration array 
rawOrigIdx = 1:length(dateArray); % idx to use for later 
durationsArray = dateArray - dateArray(1); % convert date time array into duration array
durationsDiff  = diff(durationsArray); % get the differences of duration array to find large gaps 
durationsOver  = durationsDiff > params.maxgap; % find instnaces in which large gaps exist 
diffDurationsOver = diff(durationsOver); % find strat and ending epocks of large gaps 

% find starts 
idxStart = find(diffDurationsOver == -1) + 1;
idxEnd = find(diffDurationsOver == 1) + 1;
% deal with no gap at start 
if diffDurationsOver(1) == 0 
    idxStart = [1; idxStart]; 
end

% deal with no gap at end 
if diffDurationsOver(end) == 0 
    idxEnd = [idxEnd; length(durationsArray)]; 
end

%% verify no mistakes and plot 
durationValues = durationsArray(idxEnd)-durationsArray(idxStart);
sortedDurationValues = sort(durationValues);
idxKeep = durationValues > params.minchunksize;
durationValues(idxKeep);
if params.plot
    % print histogram of values 
    figure;
    histogram(durationValues);
    
    % print figure of data + start and end times
    figure;
    plot(dateArray,y);
    hold on;
    ylims = get(gca,'YLim');
    plot([dateArray(idxStart) dateArray(idxStart)],ylims,'Color',[0 0.8 0 0.5],'LineWidth',3);
    plot([dateArray(idxEnd) dateArray(idxEnd)],ylims,'Color',[0.8 0 0 0.5],'LineWidth',3);
end

%% get results 
res.startIdx = idxStart(idxKeep);
res.endIdx  = idxEnd(idxKeep);
res.durations = durationValues; 
res.maxDuration = max(durationValues); 
res.medianDuration = median(durationValues); 
res.meanDuration = mean(durationValues); 


end