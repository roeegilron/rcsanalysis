function temp_analytze_diffs()
%%
load('/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/bencjtop/timing_zeromq/Session1591829273553/DeviceNPC700353H/EventLog.mat');

idxchoose = strcmp(eventTable.EventType,'TimeJSProgram');

et = eventTable(idxchoose,:); 


timejs = cellfun(@(x) str2num(x),et.EventSubType);

diffs_JS = diff(timejs); 

diffs_RCS = milliseconds( diff(et.HostUnixTime));

diffBoth = [diffs_JS, diffs_RCS]; 

diff_diff = diffs_JS - diffs_RCS;
%%
hfig = figure;
hfig.Color = 'w'; 
histogram(diff_diff,'BinWidth',0.5);
xlabel('difference between JS and RCS time (ms)'); 
ylabel('count'); 
title('diff of diffs JS vs RCS'); 
set(gca,'FontSize',16); 
end