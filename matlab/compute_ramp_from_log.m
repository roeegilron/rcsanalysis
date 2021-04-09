function compute_ramp_from_log()

load('temp_day_plot.mat','dayPlot')

params.ramp_up_rate = 15; % seconds
params.ramp_down_rate = 5; % seconds

params.stateTable = [0 3;
                     1 25.5;
                     2 2.7;
                     3 2.7;
                     4 2.7;
                     5 2.7];
                 

dayOut = dayPlot(2,:);  % start at 2 for count 
cnt = 1; 
for d = 2:size(dayPlot,1)-1
    % check if you need to ramp up / down 
    currentNow = dayPlot.current(d); 
    targetCurrent = computeTargeCurrent(params.stateTable, dayPlot.state(d));
    % create ideal ramp times 
    [rampTimes,Currents] = computeRampCurve(currentNow,targetCurrent,dayPlot.time(d), params); 
    if isempty(rampTimes) % no ramp needed 
        dayOut(cnt,:) = dayPlot(d,:); 
        cnt = cnt + 1; 
    else % ramp needed
        [rampTimes,Currents] = checkRampCurve(dayPlot.time(d),dayPlot.time(d+1),rampTimes,Currents);
        if isempty(rampTimes)
            dayOut(cnt,:) = dayPlot(d,:);
            cnt = cnt + 1;
        else
            for r = 1:length(rampTimes)
                dayOut(cnt,:) = dayPlot(d,:);
                dayOut.time(cnt) = rampTimes(r);
                dayOut.current(cnt) = Currents(r);
                dayOut.state(cnt) = dayPlot.state(d);
                cnt = cnt+1;
            end
        end
        % check which ramp times fall below time
        % add apropriate rows
    end
    clear rampTimes Currents
end
%%
figure;
stairs(dayOut.time,dayOut.current,'Color',[0.8 0 0 0.5],'LineWidth',2);
hold on;
stairs(dayPlot.time,dayPlot.current,'Color',[0 0 0.8 0.5],'LineWidth',0.05);
ylim([2.5 3.1]);
end

function targetCurrent = computeTargeCurrent(stateTable, currentState)
idxTarget = stateTable(:,1) == currentState;
targetCurrent = stateTable(idxTarget,2);

end

function [rampTimes,currents] = computeRampCurve(currentNow,targetCurrent,time, params); 
if currentNow == targetCurrent 
    rampTimes = [];
    currents = [];
elseif targetCurrent == 25.5
    rampTimes = [];
    currents = [];
else
    if currentNow < targetCurrent
        rampRate = params.ramp_up_rate;
        curJump  = 0.1;
    else
        rampRate = params.ramp_down_rate;
        curJump  = -0.1;
    end
    numberSteps = ceil(abs(targetCurrent-currentNow)/0.1);
    timesRamp = linspace(time, time + seconds(rampRate),    numberSteps + 1);
    currenJumps = currentNow : curJump : targetCurrent;
    rampTimes = timesRamp';
    currents = currenJumps';
end
end

function [rampTimes,Currents] = checkRampCurve(currenTime,nextTime,rampTimes,Currents)
idxkeep = rampTimes < nextTime;
rampTimes = rampTimes(idxkeep); 
Currents = Currents(idxkeep); 
end