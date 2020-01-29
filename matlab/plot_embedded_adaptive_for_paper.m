function plot_embedded_adaptive_for_paper()
% core function open make_alligned_adaptive_video.m
prfig.plotwidth           = 20;
prfig.plotheight          = 12;
prfig.figdir             = '/Users/roee/Starr_Lab_Folder/Writing/papers/2019_LongTerm_RCS_recordings/figures/raw';
prfig.figname             = 'embedded_adaptive';
prfig.figtype             = '-dpdf';
set(gca,'XLim',[duration('00:01:03') duration('00:01:39'));
plot_hfig(hfig,prfig)
close(hfig);
