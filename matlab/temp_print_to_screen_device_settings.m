function temp_print_to_screen_device_settings(fn)
load(fn);
clc
for i = 1:length(DeviceSettings)
    fnms = fieldnames(DeviceSettings{i}); 
    fprintf('setting: %d\n',i); 
    cellfun(@(x) fprintf('\t%s\n',x),fnms)
    fprintf('%%%%%%%%%%%%%%%%\n\n');
end
x = 2;

stimObj = deserializeJSON('/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v04-home-visit/rcs-data/Session1540414678805/DeviceNPC700395H/StimLog.json');

x = 2;
% visualize dte