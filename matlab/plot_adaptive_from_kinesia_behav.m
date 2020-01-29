function plot_adaptive_from_kinesia_behav()
%%
close all;clear all;clc;
figdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS05/v08_RCS05 4 Month/adaptive_day_2';
adTb = readtable('/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS05/v08_RCS05 4 Month/adaptive_day_2/adaptive_right_stn_left_side_kinesia.csv');
adTb = readtable('/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS05/v08_RCS05 4 Month/adaptive_day_2/adaptive_left_stn_right_side_kinesia.csv');

vars = adTb.Properties.VariableNames';

mesuresTab = adTb(:,vars(4:end));
mesuresTab = mesuresTab(~isnan(mesuresTab.FreezingOfGait),:);
varsuse = mesuresTab.Properties.VariableNames';
order = adTb(:,{'order'});
order = order(~isnan(mesuresTab.FreezingOfGait),:);
orderuse = zeros(size(order,1),1);
orderuse(strcmp(order.order,'B')) = 1; 
orderuse(strcmp(order.order,'A')) = 2; 
%%
hfig = figure; 
hfig.Color = 'w';
for i = 1:size(varsuse,1)
    hsb = subplot(3,4,i); 
    fn = varsuse{i}; 
    hbx = notBoxPlot(mesuresTab.(fn),orderuse);
    hsb.XTickLabel{1} = 'OL';
    hsb.XTickLabel{2} = 'CL';
    hbx(1).semPtch.FaceColor = [0 0.8 0];
    hbx(1).semPtch.FaceAlpha = 0.4;
    hbx(2).semPtch.FaceColor = [0.8 0 0];
    hbx(2).semPtch.FaceAlpha = 0.4;
    title(fn);
    set(gca,'FontSize',12);
end
sgtitle('L STN adaptive','FontSize',20); 

prfig.plotwidth           = 18;
prfig.plotheight          = 10;
prfig.figdir             = figdir;
prfig.figname             = 'L STN';
plot_hfig(hfig,prfig)
close(hfig);

end