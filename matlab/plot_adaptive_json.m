function plot_adaptive_json(fn); 

figure;
hold on;
rawTime = adaptiveTable.PacketRxUnixTime;
secsAdaptive = datetime(rawTime./1000,'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
idxuseAdaptive = 1:length(secsAdaptive);
secsAdaptive = secsAdaptive(idxuseAdaptive);
state = adaptiveTable.CurrentAdaptiveState(idxuseAdaptive);
detector = adaptiveTable.LD0_output(idxuseAdaptive);
highThresh = adaptiveTable.LD0_highThreshold(idxuseAdaptive);
lowThresh = adaptiveTable.LD0_lowThreshold(idxuseAdaptive);
current   = adaptiveTable.CurrentProgramAmplitudesInMilliamps(idxuseAdaptive);
% 1. detector
plot(secsAdaptive,detector,'LineWidth',3);
hplt = plot(secsAdaptive,highThresh,'LineWidth',3);
hplt.LineStyle = '-.';
hplt.Color = [hplt.Color 0.7];
hplt = plot(secsAdaptive,lowThresh,'LineWidth',3);
hplt.LineStyle = '-.';
hplt.Color = [hplt.Color 0.7];
%% 
% 2. threshold
ylims = get(gca,'YLim');
rescaleVals = [ylims(2)*1.1 (ylims(2) + ceil(ylims(2)-ylims(1))/3)];
stateRescaled = rescale(state,rescaleVals(1),rescaleVals(2));
% 3. state - rescaled on the second y axis above current
plot(secsAdaptive,stateRescaled,'LineWidth',3,'Color',[0 0.8 0 0.6]);
title('state and detector');
set(gca,'FontSize',16);

end