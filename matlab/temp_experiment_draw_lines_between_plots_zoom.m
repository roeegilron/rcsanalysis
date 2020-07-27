function temp_experiment_draw_lines_between_plots_zoom()
%% close all 
close all;
clc;
hfig = figure;

globalFontSize = 20;
hfig.Color = 'w';
hpanel = panel();
hpanel.pack('v',{50 50});
idxRCS06 = 1; % top panel 
idxRCS02 = 2; % bottom panel 

hpanel(idxRCS06).pack('v',{50 50});
hpanel(idxRCS02).pack('v',{[0 0 1 1 ]}); %parent back ground plot 
hpanel(idxRCS02).pack('v',{25 25 25 25 }); % the middle plot is to accomodate zoom lines  
% hpanel(idxRCS02).pack('v',{[0.6 0.6 0.3 0.3]}); % the middle plot is to accomodate zoom lines  
marginMid = 10;
hpanel(2,2).margin = [ 15 15 marginMid marginMid ];
hpanel(2,3).margin = [ 15 15 marginMid marginMid ];
hpanel(2,4).margin = [ 15 15 marginMid marginMid ];
hpanel(2,5).margin = [ 15 15 marginMid marginMid ];


hpanel.select('all');
hsb(1) = hpanel(2,1).select();
plot([0 0],[20 20]);
set(hsb ,'Layer', 'Top')



