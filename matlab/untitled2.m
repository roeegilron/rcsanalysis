function plot_adaptive_vs_log_file_state()
load('/Users/roee/Documents/potential_adaptive/RCS06/RCS06R/Session1587409185592/DeviceNPC700425H/AdaptiveLog.mat')
figure; 
subplot(3,1,1); 
cur =  adaptiveTable.CurrentProgramAmplitudesInMilliamps(:,1); 
t   =  adaptiveTable.PacketRxUnixTime; 
plot(t,cur);
subplot(3,1,3); 

subplot(3,1,3); 
plot(adaptiveLogTable.time,adaptiveLogTable.newstate);


end