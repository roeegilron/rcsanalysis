function [hfig,trialDataResultsUse,taskData] = behaviouralAnalysis_movementTask_data_jspsyc(taskData)
% input - task data from .csv
% add trial numbers to the task 
cnt = 1; 
trial = 0; 
while cnt <= size(taskData,1)
    if strcmp(taskData.event(cnt),'FixationLoad')
        trial = trial + 1; 
        taskData.trial(cnt) = trial;
    else
        taskData.trial(cnt) = trial;
    end
    cnt = cnt + 1;
    
end
uniqueTrials  = unique(taskData.trial);
uniqueTrials  = uniqueTrials(uniqueTrials ~= 0);
trialDataResults = table();
for u = 1:size(uniqueTrials,1)
    trialData = taskData(taskData.trial == uniqueTrials(u),:);
    trialDataResults.trial(u) = uniqueTrials(u); 
    badtrial = 0; 
    inFixation = NaN; 
    inPrep = NaN; 
    inMove = NaN;
    keyUp = NaN; 
    keyDown = NaN; 
    trialResult = 'good trial';
    t = 1;
    while t  <= size(trialData,1)
        if strcmp(trialData.event{t},'FixationLoad')
            inFixation = 1; 
        end
        if strcmp(trialData.event{t},'FixationFinish')
            inFixation = 0; 
        end
        if any(strfind(trialData.event{t},'PREP start'))
            inPrep = 1;
        end
        if any(strfind(trialData.event{t},'PREP end'))
            inPrep = 0;
            
        end
        if any(strfind(trialData.event{t},'MOVE start'))
            inMove = 1;
            timeGoCue = trialData.time(t);
        end
        if any(strfind(trialData.event{t},'MOVE end'))
            inMove = 0;
            timeMoveEnd = trialData.time(t);
        end
        if any(strfind(trialData.event{t},'KeyUp'))
            timeMoveStart = trialData.time(t);
            keyUp = 1;
            keyDown = 0;
        end
        if any(strfind(trialData.event{t},'KeyDown'))
            keyUp = 0;
            keyDown = 1;
            timeKeyDown = trialData.time(t);
        end
        if ~isnan(inFixation) & ~isnan(keyUp)
            if inFixation & keyUp
                trialResult = 'moved during fixation';
                badtrial = 1;
            end
        end
        if ~isnan(inPrep) & ~isnan(keyUp)
            if inPrep & keyUp
                trialResult = 'moved during preperation';
                badtrial = 1;
            end
        end
        if ~isnan(inPrep) & ~isnan(keyUp)
            if inPrep & keyUp
                trialResult = 'moved during preperation';
                badtrial = 1;
            end
        end
        if ~isnan(inMove) & ~isnan(keyUp)
            if inMove & keyUp
                trialResult = 'started move to target';
            end
        end
        if strcmp(trialResult,'started move to target') & ~badtrial & ~inMove
            trialResult = 'good trial';
        end
        t = t + 1;
    end
   
    trialDataResults.result{u} = trialResult;
    trialDataResults.reactionTime(u) = milliseconds(0);
    trialDataResults.movementTimeToTarget(u) =  milliseconds(0);
    trialDataResults.movementTimeFromTarget(u) = milliseconds(0);

    if strcmp(trialResult,'good trial')
        trialDataResults.reactionTime(u) = milliseconds(milliseconds( timeMoveStart - timeGoCue));
        trialDataResults.movementTimeToTarget(u) = milliseconds(milliseconds( timeMoveEnd - timeMoveStart));
        % find the time back from target until key down 
        if u ~= size(uniqueTrials,1)
            idxLarge = taskData.trial > u;
            largerTable = taskData(idxLarge,:);
            idxtime = find( strcmp(largerTable.event,'KeyDown')==1,1);
            timeMovementEnd = largerTable.time(idxtime);
            trialDataResults.movementTimeFromTarget(u) = milliseconds(milliseconds(timeMovementEnd- timeMoveEnd ));
            trialDataResults.totalTimeToExecute(u) =     trialDataResults.reactionTime(u) + ...
                trialDataResults.movementTimeToTarget(u) + ...
                trialDataResults.movementTimeFromTarget(u);
        end
        
    end
end

%%
idxGood = strcmp(trialDataResults.result,'good trial') & ... 
    trialDataResults.movementTimeFromTarget > seconds(0);
trialDataResultsUse = trialDataResults(idxGood,:);
hfig = figure();
hfig.Color = 'w'; 
hsb = subplot(2,1,1);
hold on;
addpath(genpath(fullfile(pwd,'toolboxes','notBoxPlot')))
hnotBox = notBoxPlot(milliseconds( trialDataResultsUse.reactionTime),1);
    hnotBox.data.MarkerSize = 2;
hnotBox = notBoxPlot(milliseconds( trialDataResultsUse.movementTimeToTarget),2);
    hnotBox.data.MarkerSize = 2;
hnotBox = notBoxPlot(milliseconds( trialDataResultsUse.movementTimeFromTarget),3);
    hnotBox.data.MarkerSize = 2;
hnotBox = notBoxPlot(milliseconds( trialDataResultsUse.totalTimeToExecute),4);
    hnotBox.data.MarkerSize = 2;
ylabel('milliseconds'); 
hsb.XTick = 1:4;
hsb.XTickLabel ={'RT','t to target','t from target','total time'};
hsb.XTickLabelRotation = 45;
hsb.YLim(1) = 0;
title('reaction times');
set(hsb,'FontSize',16);

hsb = subplot(2,1,2);
Conditions = categorical(trialDataResults.result);
h = histogram(Conditions,'Normalization','probability');
title('trial performance');
set(hsb,'FontSize',16);


end