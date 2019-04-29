%%
hfig = figure; 
hsub(1) = subplot(2,2,[1 3]);
hsub(2) = subplot(2,2,2);
hsub(3) = subplot(2,2,4);
fs = 40;

hfigOrig  = openfig('/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v06-home-visit-3-week/figures/continous recording.fig');
axToCopy = get(hfigOrig,'Children');
hsubCopied = copyobj(axToCopy, hfig);
hsubCopied.Position = hsub(1).Position; 
close(hfigOrig);
set(hsubCopied,'FontSize',fs);

figname = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v06-home-visit-3-week/figures/med and sleep effect only stn.fig';
hfigOrig  = openfig(figname);
axToCopy = get(hfigOrig,'Children');
hsubCopied = copyobj(axToCopy(2), hfig);
hsubCopied.Position = hsub(2).Position; 

% plot med time during wake 
hold(hsubCopied,'on');
xt = datetime('03-Nov-2018 15:00:00.995','TimeZone','America/Los_Angeles');
xm = [xt xt]; 
ylims  = get(hsubCopied,'YLim'); 
plot(hsubCopied,xm,ylims,'Color',[0 0.8 0 0.7],'LineWidth',3);

legend(hsubCopied,{'Alpha','Beta','Med Time'});
datetick(hsubCopied,'x','HH','keepticks','keeplimits');
set(hsubCopied,'FontSize',fs);



axToCopy = get(hfigOrig,'Children');
hsubCopied = copyobj(axToCopy(4), hfig);
hsubCopied.Position = hsub(3).Position; 
hold(hsubCopied,'on');

% plot med time during sleep
xt = datetime('08-Nov-2018 03:00:00.995','TimeZone','America/Los_Angeles');
xm = [xt xt]; 
ylims  = get(hsubCopied,'YLim'); 
plot(hsubCopied,xm,ylims,'Color',[0 0.8 0 0.7],'LineWidth',3);

xt = datetime('08-Nov-2018 07:00:00.995','TimeZone','America/Los_Angeles');
xm = [xt xt]; 
ylims  = get(hsubCopied,'YLim'); 
% plot(hsubCopied,xm,ylims,'Color',[0 0.8 0 0.7],'LineWidth',3);

% end 



legend(hsubCopied,{'Alpha','Beta','Med Time'});
legend(hsubCopied,{'Alpha','Beta'});
% delete(hsub(3).Position); 
% close(hfigOrig);
set(hsubCopied,'FontSize',fs);
datetick(hsubCopied,'x','HH','keepticks','keeplimits');
xlabel(hsubCopied,'Time (24h)');
delete(hsub);

p.plotwidth           = 450/10;
p.plotheight          = 139/10;
p.figdir              = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v06-home-visit-3-week/figures';
p.figname             = 'stn sleep and med effects continous recordings no meds';
p.figtype             = '-dpdf';
p.closeafterprint     = 0;
hfig.PaperSize = [p.plotwidth p.plotheight];
hfig.Units = 'centimeters';
hfig.PaperPositionMode = 'manual';
plot_hfig(hfig,p);

%% make figure for noise floor 
close all;
hfig = figure; 
hsub(1) = subplot(1,2,1);
hsub(2) = subplot(1,2,2);
fs = 40; 

% copy NO vs rcs figure
figname = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v06-home-visit-3-week/figures/neuroomega vs rc+s.fig';
hfigOrig  = openfig(figname);
axToCopy = get(hfigOrig,'Children');
hsubCopied = copyobj(axToCopy(7), hfig);
hsubCopied.Position = hsub(1).Position; 
close(hfigOrig);
xlim(hsubCopied,[0 200]);
title(hsubCopied,'External amplifier vs RC+S (STN)');
set(hsubCopied,'FontSize',fs);


% copy factor over noise floor
figname = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v06-home-visit-3-week/figures/noise floor factor.fig';
hfigOrig  = openfig(figname);
axToCopy = get(hfigOrig,'Children');
hsubCopied = copyobj(axToCopy(2), hfig);
hsubCopied.Position = hsub(2).Position; 
xlim(hsubCopied,[0 200]);
xlabel(hsubCopied,'Frequency (Hz)');
title(hsubCopied,'RC+S signal above noise floor (STN)');
close(hfigOrig);
set(hsubCopied,'FontSize',fs);


delete(hsub);
 
p.plotwidth           = 260/10;
p.plotheight          = 98/10;
p.figdir              = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v06-home-visit-3-week/figures';
p.figname             = 'factor over noise floor';
p.figtype             = '-dpdf';
p.closeafterprint     = 1;
hfig.PaperSize = [p.plotwidth p.plotheight];
hfig.Units = 'centimeters';
hfig.PaperPositionMode = 'manual';
plot_hfig(hfig,p);

%% make figure of ipad movement related data 
close all;

hfig = figure; 
hsub(1) = subplot(2,2,[1 3]);
hsub(2) = subplot(2,2,2);
hsub(3) = subplot(2,2,4);
fs = 35; 

% copy movement related gamma in M1
figname = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v06-home-visit-3-week/figures/ipad_spectrogram_baseline--2000--500_hold_center_fir1.fig';
hfigOrig  = openfig(figname);
axToCopy = get(hfigOrig,'Children');
hsubCopied = copyobj(axToCopy(2), hfig);
hsubCopied.Position = hsub(1).Position;
title(hsubCopied,'Movement related activity (M1)');
hsubCopied.YLabel.String = 'Frequency (Hz)';
set(hsubCopied,'XLim',[-2000 7000]);
set(hsubCopied,'FontSize',fs)
close(hfigOrig);


% copy movement related gamma in stn and M1 spectrogram 
figname = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v06-home-visit-3-week/figures/spectrogram_movemet_related_raw.fig';
hfigOrig  = openfig(figname);
axToCopy = get(hfigOrig,'Children');

% stn 
hsubCopied = copyobj(axToCopy(3), hfig);
hsubCopied.Position = hsub(2).Position;
title(hsubCopied,'STN - single trial movement related activity');
xlim(hsubCopied,seconds([548.69 594.73]));
xtics = get(hsubCopied,'XTick');
set(hsubCopied,'xticklabels','');
hsubCopied.XLabel.String = '';

set(hsubCopied,'FontSize',fs)


%M1
hsubCopied = copyobj(axToCopy(1), hfig);
hsubCopied.Position = hsub(3).Position;
xlim(hsubCopied,seconds([548.69 594.73]));
title(hsubCopied,'M1 - single trial movement related activity');
set(hsubCopied,'xticklabels',{'2';'7';'12';'17';'22';'27';'32';'37';'42'});
set(hsubCopied,'FontSize',fs)


close(hfigOrig);



delete(hsub);

p.plotwidth           = 450/10;
p.plotheight          = 110/10;
p.figdir              = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v06-home-visit-3-week/figures';
p.figname             = 'single trial m1 activtiy';
p.figtype             = '-dpng';
p.closeafterprint     = 1;
hfig.PaperSize = [p.plotwidth p.plotheight];
hfig.Units = 'centimeters';
hfig.PaperPositionMode = 'manual';
plot_hfig(hfig,p);

%% make figure for adaptive dbs 
close all;

hfig = figure; 
% hfig.Position =[0.691594202898551   0.110000000000000   0.213405797101449   0.815000000000000];
hsub(1) = subplot(2,3,[1 2]);
hsub(2) = subplot(2,3,[4 5]);
hsub(3) = subplot(2,3,[3 6]);
fs = 35; 

% plot detector 
figname = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v19_adaptive_month5_day2/figures/adaptive dbs ipad task.fig';
hfigOrig  = openfig(figname);
axToCopy = get(hfigOrig,'Children');
hsubCopied = copyobj(axToCopy(5), hfig);
hsubCopied.Position = hsub(1).Position;
title(hsubCopied,'Adaptive embedded detector during movement task');
set(hsubCopied,'FontSize',fs)
set(hsubCopied,'xticklabels','');
hsubCopied.XLabel.String = '';


% plot the time domain data 

hsubCopied = copyobj(axToCopy(1), hfig);
hsubCopied.Position = hsub(2).Position;
title(hsubCopied,'M1 spectrogram');
set(hsubCopied,'FontSize',fs)
datetick(hsubCopied,'x','MM:SS','keeplimits','keepticks')
hsubCopied.XLabel.String = 'Time (mm:ss)';


close(hfigOrig);

% plot time spent in each state 
figname = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v19_adaptive_month5_day2/figures/1 hour adaptive DBS streaming in clinic.fig';
hfigOrig  = openfig(figname);
axToCopy = get(hfigOrig,'Children');
hsubCopied = copyobj(axToCopy(7), hfig);
hsubCopied.Position = hsub(3).Position;
title(hsubCopied,'% Time spent in each state');
set(hsubCopied,'FontSize',fs)
close(hfigOrig)
% datetick(hsubCopied,'x','MM:FFF','keepticks','keeplimits');

delete(hsub);

clear p; 
p.plotwidth           = 450/10;
p.plotheight          = 110/10;
p.figdir              = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v19_adaptive_month5_day2/figures/';
p.figname             = 'adapative dbs trials';
p.figtype             = '-dpng';
p.closeafterprint     = 1;
hfig.PaperSize = [p.plotwidth p.plotheight];
hfig.Units = 'centimeters';
hfig.PaperPositionMode = 'manual';
plot_hfig(hfig,p);

%% make figure of stim titration histogram 
close all;

hfig = figure; 
% hfig.Position =[0.691594202898551   0.110000000000000   0.213405797101449   0.815000000000000];
hsub(1) = subplot(1,1,1);
fs = 35; 

% plot detector 
figname = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v17_stim_titration/figures/stim titration histogram.fig';
hfigOrig  = openfig(figname);
axToCopy = get(hfigOrig,'Children');
hsubCopied = copyobj(axToCopy(6), hfig);
hsubCopied.Position = hsub(1).Position;
title(hsubCopied,'M1 Beta during reaching movement task & rest');
set(hsubCopied,'FontSize',fs)
hsubCopied.XLabel.String = 'Beta (a.u.)';


delete(hsub);

clear p; 
p.plotwidth           = 160/10;
p.plotheight          = 101/10;
p.figdir              = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v17_stim_titration/figures/';
p.figname             = 'adapative dbs trials';
p.figtype             = '-dpdf';
p.closeafterprint     = 1;
hfig.PaperSize = [p.plotwidth p.plotheight];
hfig.Units = 'centimeters';
hfig.PaperPositionMode = 'manual';
plot_hfig(hfig,p);

%% make driving figure 


close all;

hfig = figure; 
hsub(1) = subplot(1,2,1);
hsub(2) = subplot(1,2,2);
fs = 35; 
% plot video frame 
vidname = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v10-3-month/vids/MVI_0267.MP4'; 

vread = VideoReader(vidname);
vread.CurrentTime = 5*70; 
vidFrame = readFrame(vread);
image(vidFrame, 'Parent', hsub(1));
axis(hsub(1),'tight');
axis(hsub(1), 'off');
axis(hsub(1),'image');

% plot detector 
figname = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v10-3-month/figures/stopping data driving.fig';
hfigOrig  = openfig(figname);
axToCopy = get(hfigOrig,'Children');
hsubCopied = copyobj(axToCopy(1), hfig);
hsubCopied.Position = hsub(2).Position;
title(hsubCopied,'M1 activity alligned to car stopping');
set(hsubCopied,'FontSize',fs)
axis(hsubCopied, 'tight');
ylim(hsubCopied,[1 100]);

hsubCopied.XLabel.String = 'Time (sec)';
hsubCopied.YLabel.String = 'Frequency (Hz)';


close(hfigOrig);
delete(hsub(2));

clear p; 
p.plotwidth           = 443/10;
p.plotheight          = 133/10;
p.figdir              = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v10-3-month/figures/';
p.figname             = 'car driving figure';
p.figtype             = '-dpng';
p.closeafterprint     = 1;
hfig.PaperSize = [p.plotwidth p.plotheight];
hfig.Units = 'centimeters';
hfig.PaperPositionMode = 'manual';
plot_hfig(hfig,p);



