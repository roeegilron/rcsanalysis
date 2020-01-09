function save_suraface_vector_format(figname) 
% this function takes as input a saved matlab figure 
%  it will search for all surface objects and plot the figure twice 
% as pdf - once with all the lines and title 
% and once with just the pictures so that they can be easily be overlayed
% in illustrator. 
close all;
[pn,fn,ext] = fileparts(figname);
% plot everything in vector 
open(figname); 
hfig = gcf; 
hfig.Color = 'w';
idxax = isgraphics(hfig.Children,'Axes'); 
haxes = hfig.Children(idxax); 
for i = 1:length(haxes)
    idxsurf = isgraphics(haxes(i).Children,'surface');
    hsurf = haxes(i).Children(idxsurf); 
    delete(hsurf); 
end
prfig.plotwidth           = 15;
prfig.plotheight          = 10;
prfig.figname             = [fn '_vector'];
prfig.figdir             = pn;
prfig.figtype           = '-dpdf'; 
plot_hfig(hfig,prfig)
close(hfig); 
% plot just the images  
open(figname); 
hfig = gcf; 
hfig.Color = 'w';
idxax = isgraphics(hfig.Children,'Axes');  
haxes = hfig.Children(idxax); 
for i = 1:length(haxes)
    haxes(i).XTick = [];
    haxes(i).YTick = [];
    haxes(i).YLabel.String = '';
    haxes(i).XLabel.String = '';
    haxes(i).Title.String = '';
    idxsurf = isgraphics(haxes(i).Children,'surface');
    hnotsurf = haxes(i).Children(~idxsurf);
    delete(hnotsurf);
end
prfig.plotwidth           = 15;
prfig.plotheight          = 10;
prfig.figname             = [fn '_bitmap'];
prfig.figdir             = pn;
prfig.figtype           = '-djpeg'; 
prfig.resolution           = 300;
plot_hfig(hfig,prfig)
close(hfig); 
%%
 