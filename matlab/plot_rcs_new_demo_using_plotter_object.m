function plot_rcs_new_demo_using_plotter_object()

%% init 
dirname = '/Volumes/RCS_DATA/manual_adaptive/RCS02/SummitContinuousBilateralStreaming/RCS02L';
dirname = '/Volumes/RCS_DATA/manual_adaptive/RCS02/real_run/RCS02L';
dirname = '/Volumes/RCS_DATA/manual_adaptive/RCS05/2021_02_11_dual_lds/RCS05L';
dirname = '/Volumes/RCS_DATA/manual_adaptive/RCS07/2021_02_11_manual_adbs/RCS07R';
dirname = '/Volumes/RCS_DATA/manual_adaptive/RCS02/day2_real_run/SummitContinuousBilateralStreaming/RCS02R';
dirname = '/Users/roee/Downloads/RSC04';
dirame = '/Users/roee/Downloads/vinith';
dirname = '/Volumes/RCS_DATA/manual_adaptive/RCS02/day2_real_run/SummitContinuousBilateralStreaming/RCS02R';
% dirname = '/Users/roee/Starr Lab Dropbox/RCS12/SummitData/SummitContinuousBilateralStreaming/RCS12L';
% dirname = '/Volumes/RCS_DATA/RCS12/adaptive_dau/Session1612984183968/DeviceNPC700477H';
%% create database 
create_database_from_device_settings_files(dirname); 
load(fullfile(dirname,'database','database_from_device_settings.mat'));

%% init 
rc = rcsPlotter();
%%

%% add folders 
for s = 1:size(masterTableLightOut,1)
    [pn,fn] = fileparts(masterTableLightOut.deviceSettingsFn{s});
    rc.addFolder(pn);
end

%% load data 

rc.loadData();

%% plot some data 
% init 
close all;
addpath(genpath(fullfile(pwd,'toolboxes','panel-2.14')));
hfig = figure; 
hfig.Color = 'w'; 
hpanel = panel();
nrows = 4; 
hpanel.pack(nrows,1); 
for n = 1:nrows
    hsb(n,1) = hpanel(n,1).select();
end


rc.plotAdaptiveLd(0,hsb(1,1));


cla(hpanel(2,1).select());
hsb1 = hpanel(2,1).select();
rc.plotPowerRaw(1,hpanel(2,1).select(),300);
eventData = rc.reportEventData;
datesAdd = datenum(eventData.localTime);
xticks = hsb1.XTick;
ticksuse = unique([xticks, datesAdd']);
hsb1.XTick = ticksuse;
hsb1.XTickLabelRotation = 45;

cla(hpanel(3,1).select());
rc.plotPowerRaw(7,hpanel(3,1).select(),300);
rc.plotAdaptiveCurrent(0,hpanel(4,1).select());

linkaxes(hsb,'x')

hpanel.fontsize = 15;
hpanel.margin = 15; 
hpanel.marginleft = 20;
hpanel.margintop = 20;
linkaxes(hsb,'x')




%% pflot some data 
hfig = figure; 
hfig.Color = 'w'; 
hpanel = panel();
nrows = 2; 
hpanel.pack(nrows,1); 
for n = 1:nrows
    hsb(n,1) = hpanel(n,1).select();
end

rc.plotAdaptiveLd(0,hpanel(1,1).select());
title(hpanel(1,1).select(),'Detector');
rc.plotAdaptiveCurrent(0,hpanel(2,1).select());
title(hpanel(2,1).select(),'Current');

hpanel.fontsize = 20;
hpanel.margin = 15; 
hpanel.marginleft = 20;
hpanel.margintop = 20;
linkaxes(hsb,'x')



%% hfig = figure; 
hfig = figure;
hfig.Color = 'w'; 
for n = 1:nrows
    hsb(n,1) = subplot(nrows,1,n); 
end

rc.plotAdaptiveLd(0,hsb(1,1))
title(hsb(1,1),'Detector');

rc.plotTdChannel(1,hsb(2,1))

rc.plotPowerRaw(1,hsb(3,1))

linkaxes(hsb,'x')



%%
dataWitney = rc.Data(end).combinedDataTable;

%%
writetable(dtAdaptiveSparse ,'dataWitney.csv');



%% plot aDBS 
hfig = figure; 
hfig.Color = 'w'; 
hpanel = panel();
nrows = 3; 
hpanel.pack(nrows,1); 
for n = 1:nrows
    hsb(n,1) = hpanel(n,1).select();
end

rc.plotAdaptiveLd(0,hpanel(1,1).select());
title(hpanel(1,1).select(),'Detector LD0');

rc.plotPowerRaw(3,hpanel(2,1).select());

rc.plotTdChannel(1,hpanel(3,1).select());

hpanel.fontsize = 20;
hpanel.margin = 15; 
hpanel.marginleft = 20;
hpanel.margintop = 20;
linkaxes(hsb,'x')




%%
hfig = figure; 
hfig.Color = 'w'; 
hpanel = panel();
nrows = 4; 
hpanel.pack(nrows,1); 
for n = 1:nrows
    hsb(n,1) = hpanel(n,1).select();
end

rc.plotAdaptiveLd(0,hpanel(1,1).select());
title(hpanel(1,1).select(),'Detector LD0');

rc.plotAdaptiveLd(1,hpanel(2,1).select());
title(hpanel(2,1).select(),'Detector LD1');


rc.plotAdaptiveCurrent(0,hpanel(3,1).select());
title(hpanel(3,1).select(),'Current');

rc.plotAdaptiveState(hpanel(4,1).select());
title(hpanel(4,1).select(),'State');

hpanel.fontsize = 20;
hpanel.margin = 15; 
hpanel.marginleft = 20;
hpanel.margintop = 20;
linkaxes(hsb,'x')




%% RCS07 manual aDBS 
%% init 
dirname = '/Volumes/RCS_DATA/chronic_stim_vs_off/RCS07R';
%% create database 
create_database_from_device_settings_files(dirname); 
load(fullfile(dirname,'database','database_from_device_settings.mat'));
masterTableLightOut = masterTableLightOut(22:end,:);
%% init 
rc = rcsPlotter();
%%

%% add folders 

for s = 1:size(masterTableLightOut,1)
    [pn,fn] = fileparts(masterTableLightOut.deviceSettingsFn{s});
    rc.addFolder(pn);
end

%% load data 
rc.loadData();

%%
close all;
addpath(genpath(fullfile(pwd,'toolboxes','panel-2.14')));
hfig = figure; 
hfig.Color = 'w'; 
hpanel = panel();
nrows = 6; 
hpanel.pack(nrows,1); 
for n = 1:nrows
    hsb(n,1) = hpanel(n,1).select();
end

rc.plotPowerRaw(5,hpanel(1,1).select(),60);
rc.plotPowerRaw(7,hpanel(2,1).select(),60);
rc.plotPowerRaw(8,hpanel(3,1).select(),60);

rc.plotAdaptiveLd(0,hpanel(4,1).select());
rc.plotAdaptiveLd(1,hpanel(5,1).select());
rc.plotAdaptiveCurrent(0,hpanel(6,1).select());


linkaxes(hsb,'x')






%% RCS05 manual aDBS 
%% init 
dirname = '/Volumes/RCS_DATA/manual_adaptive/RCS05/RCS05L';
%% create database 
create_database_from_device_settings_files(dirname); 
load(fullfile(dirname,'database','database_from_device_settings.mat'));
%% init 
rc = rcsPlotter();
%%

%% add folders 

for s = 1:size(masterTableLightOut,1)
    [pn,fn] = fileparts(masterTableLightOut.deviceSettingsFn{s});
    rc.addFolder(pn);
end

%% load data 
rc.loadData();

%%
close all;
addpath(genpath(fullfile(pwd,'toolboxes','panel-2.14')));
hfig = figure; 
hfig.Color = 'w'; 
hpanel = panel();
nrows = 6; 
hpanel.pack(nrows,1); 
for n = 1:nrows
    hsb(n,1) = hpanel(n,1).select();
end

rc.plotPowerRaw(6,hpanel(1,1).select(),120);
rc.plotPowerRaw(7,hpanel(2,1).select(),120);
rc.plotPowerRaw(8,hpanel(3,1).select(),120);

rc.plotAdaptiveLd(0,hpanel(4,1).select());
rc.plotAdaptiveLd(1,hpanel(5,1).select());
rc.plotAdaptiveCurrent(0,hpanel(6,1).select());


linkaxes(hsb,'x')


rcraw = rc;
%% plot some data rcs 12
% init 
rc = rc12; 
close all;
addpath(genpath(fullfile(pwd,'toolboxes','panel-2.14')));
hfig = figure; 
hfig.Color = 'w'; 
hpanel = panel();
nrows = 5; 
hpanel.pack(nrows,1); 
for n = 1:nrows
    hsb(n,1) = hpanel(n,1).select();
end


rc.plotAdaptiveLd(0,hsb(1,1));


cla(hpanel(2,1).select());
% hsb = hpanel(2,1).select();
rc.plotPowerRaw(1,hpanel(2,1).select(),10);
% eventData = rc.reportEventData;
% datesAdd = datenum(eventData.localTime);
% xticks = hsb.XTick;
% ticksuse = unique([xticks, datesAdd']);
% hsb.XTick = ticksuse;
% hsb.XTickLabelRotation = 45;

cla(hpanel(3,1).select());
rc.plotPowerRaw(6,hpanel(3,1).select(),10);

rc.plotAdaptiveCurrent(0,hpanel(4,1).select());

rc.plotAdaptiveState(hsb(5,1));

linkaxes(hsb,'x')

hpanel.fontsize = 20;
hpanel.margin = 15; 
hpanel.marginleft = 30;
hpanel.margintop = 20;
linkaxes(hsb,'x')



%% for simon 
dirname = '/Users/roee/Downloads/vinith';
% init 
rc = rcsPlotter();
rc.addFolder('/Users/roee/Downloads/vinith/Session1612562723976/DeviceNPC700418H');
rc.loadData();

% create figure
hfig = figure('Color','w');
hsb = gobjects();
nplots = 4;
for i = 1:nplots; hsb(i,1) = subplot(nplots,1,i); end;

% plot data 
rc.plotTdChannelBandpass(4,[4 8], hsb(1,1)); 
rc.plotAdaptiveLd(0,hsb(2,1));
rc.plotAdaptiveCurrent(0,hsb(3,1));
rc.plotActigraphyChannel('X',hsb(4,1));
% link axes since time domain and acc have differnt
% sample rates:
linkaxes(hsb,'x');

% zoom into one minute graph and makes some nicer x ticks 
xzoom = datetime({'05-Feb-2021 15:25:11','05-Feb-2021 15:26:14'});
xlim(hsb(1,1),datenum(xzoom));
xticks = xzoom(1) : seconds(10) : xzoom(2);
xticklabels = sprintf('%s\n',xticks - xticks(1));
hsb(1,1).XTick = datenum(xticks);
hsb(1,1).XTickLabel = xticklabels;

% add some titles and labels 
title(hsb(3,1),'current');

%%

%% plot RCS02 second day 
dirname = '/Volumes/RCS_DATA/manual_adaptive/RCS02/day2_real_run/SummitContinuousBilateralStreaming/RCS02R';
% create database 
create_database_from_device_settings_files(dirname); 
load(fullfile(dirname,'database','database_from_device_settings.mat'));
% init 
rc = rcsPlotter();
%%

% add folders 

for s = 1:size(masterTableLightOut,1)
    [pn,fn] = fileparts(masterTableLightOut.deviceSettingsFn{s});
    rc.addFolder(pn);
end

% load data 
rc.loadData();

%%
close all;
addpath(genpath(fullfile(pwd,'toolboxes','panel-2.14')));
hfig = figure; 
hfig.Color = 'w'; 
hpanel = panel();
nrows = 4; 
hpanel.pack(nrows,1); 
for n = 1:nrows
    hsb(n,1) = hpanel(n,1).select();
end
cntplt = 1; 

hsbPlot = hpanel(cntplt,1).select();cntplt = cntplt + 1; 
rc.plotAdaptiveLd(0,hsbPlot)

hsbPlot = hpanel(cntplt,1).select();cntplt = cntplt + 1; 
rc.plotAdaptiveLd(1,hsbPlot)

hsbPlot = hpanel(cntplt,1).select();cntplt = cntplt + 1; 
rc.plotAdaptiveCurrent(0,hsbPlot);

hsbPlot = hpanel(cntplt,1).select();cntplt = cntplt + 1; 
rc.plotActigraphyChannel('X',hsbPlot);

% link axes 
linkaxes(hsb,'x')

hpanel.fontsize = 16;
hpanel.fontsize = 20;
hpanel.margin = 15; 
hpanel.marginleft = 20;
hpanel.margintop = 20;




end