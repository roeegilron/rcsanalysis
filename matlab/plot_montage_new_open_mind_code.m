function plot_montage_new_open_mind_code()
%% load folder
rootdir = '/Volumes/RCS_DATA/RCS11/Before_programming_second_time_off_stim/rcsdata';
ff = findFilesBVQX(rootdir,'Device*',struct('dirs',1));
rc =rcsPlotter();
for f = 1:length(ff)
    rc.addFolder(ff{f});
end
rc.loadData();
%%
montageFolder = '/Volumes/RCS_DATA/RCS11/Before_programming_second_time_off_stim/rcsdata/RCS11L/Session1616160809973/DeviceNPC700472H'; 
rc = rcsPlotter();
rc.addFolder(montageFolder); 
rc.loadData();

end