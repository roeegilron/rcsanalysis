function plot_hfig(hfig,varargin)

p = inputParser;
p.CaseSensitive = false;

% double 
validationFcn = @(x) validateattributes(x,{'double'},{'nonempty'});
addParameter(p,'plotwidth',15,validationFcn)

addParameter(p,'plotheight',8,validationFcn)

addParameter(p,'closeafterprint',0,validationFcn)

addParameter(p,'resolution',600,validationFcn)

% strings: 
validationFcn = @(x) validateattributes(x,{'char'},{'nonempty'});
addParameter(p,'figdir',pwd,validationFcn)

addParameter(p,'figname','outfig',validationFcn)

addParameter(p,'figtype','-dpdf',validationFcn)

p.parse(varargin{:});

%Extract values from the inputParser
plotwidth           = p.Results.plotwidth;
plotheight          = p.Results.plotheight;
figdir              = p.Results.figdir;
figname             = p.Results.figname;
figtype             = p.Results.figtype;
closeafterprint     = p.Results.closeafterprint;
resolution          = p.Results.resolution;

hfig.PaperPositionMode = 'manual';
hfig.PaperSize         = [plotwidth plotheight]; 
hfig.PaperPosition     = [ 0 0 plotwidth plotheight]; 

switch figtype
    case '-dpdf'
        fnmsv = sprintf('%s.pdf',figname);
        print(hfig,fullfile(figdir,fnmsv),'-dpdf'); 
    case '-djpeg'
        fnmsv = sprintf('%s.jpeg',figname);
        res = sprintf('-r%d',resolution);
        print(hfig,fullfile(figdir,fnmsv),'-djpeg',res);
    case '-dpng'
        fnmsv = sprintf('%s.png',figname);
        res = sprintf('-r%d',resolution);
        print(hfig,fullfile(figdir,fnmsv),'-dpng',res);
end
if closeafterprint
    close(hfig);
end

end