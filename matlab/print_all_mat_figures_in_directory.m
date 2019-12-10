function print_all_mat_figures_in_directory(dirname)

figsFound = findFilesBVQX(dirname,'*.fig');
for f = 1:length(figsFound)
    open(figsFound{f}); 
    hfig = gcf(); 
    [pn,fn,ext] = fileparts(figsFound{f});
    hfig.Color = 'w'; 
    idxaxes = isgraphics(hfig.Children,'axes');
    gaxes = hfig.Children(idxaxes);
    for a = 1:length(gaxes)
        gaxes(a).Title.String = strrep(    gaxes(a).Title.String ,'_', ' ');
        set(gaxes,'FontSize',16); 
        islines = isgraphics( gaxes(a).Children,'Line');
        hlines = gaxes(a).Children(islines);
        for h = 1:length(hlines)
            hlines(h).LineWidth = 2;
        end
    end
    prfig.plotwidth           = 15*1.6;
    prfig.plotheight          = 10*1.6;
    prfig.figdir              = dirname;
    prfig.figname             = fn;
    plot_hfig(hfig,prfig)
    close(hfig);
end

end