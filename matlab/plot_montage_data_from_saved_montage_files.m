function plot_montage_data_from_saved_montage_files(dirname)
% you need to run this function first:
% open_and_save_montage_data_in_sessions_directory

ff = findFilesBVQX(dirname,'rawMontageData.mat');
figdir = fullfile(dirname,'figures');
mkdir(figdir);

for f = 1:length(ff)
    load(ff{f});
    plot_pac_montage_data_within(montageData,figdir,ff{f});
end
end

function plot_pac_montage_data_within(montageData,figdir,origfile)
close all;
addpath(genpath(fullfile('..','..','PAC')));
timeStart = datetime(montageData.startTime,'Format','dd-MMM-yyyy_HH-mm');
fnsave = sprintf('%s_%s_%s',montageData.patient,montageData.side,timeStart);
timeStart = datetime(montageData.startTime,'Format','dd-MMM-yyyy HH:mm');
titleName = sprintf('%s %s %s',montageData.patient,montageData.side,timeStart);

pacparams.PhaseFreqVector      = 5:2:50;
pacparams.AmpFreqVector        = 10:5:400;

pacparams.PhaseFreq_BandWidth  = 4;
pacparams.AmpFreq_BandWidth    = 10;
pacparams.computeSurrogates    = 0;
pacparams.numsurrogate         = 0;
pacparams.alphause             = 0.05;
pacparams.plotdata             = 0;
pacparams.useparfor            = 0; % if true, user parfor, requires parallel computing toolbox
pacparams.regionnames          = {'STN','M1'};


cntplt = 1;
if length(montageData.M1) == 8
    % 12 PAC plots 
    ncols  = 3; 
    nrows  = 4; 
elseif length(montageData.M1) == 6
    ncols  = 3; 
    nrows  = 4; 
elseif length(montageData.M1) == 7
    % 14 PAC plots 
    ncols  = 4; 
    nrows  = 4; 
else
    ncols  = 4; 
    nrows  = 4; 
end
needToSavePacResults = 1; 
listOfVariables = who('-file', origfile);
if ismember('pac_results', listOfVariables) 
    load(origfile,'pac_results');
    needToSavePacResults = 0;
end
load(origfile,'pac_results')



fldnms = {'LFP','M1'}; 
hfig = figure;
for a = 1:2 % loop on area
    for n = 1:length(montageData.(fldnms{a}))
        subplot(nrows,ncols,cntplt); cntplt = cntplt + 1;
        dat = montageData.(fldnms{a})(n);
        if dat.sr == 250 
            pacparams.AmpFreqVector        = 10:5:80;
        elseif dat.sr == 500
            pacparams.AmpFreqVector        = 10:5:200;
        elseif dat.sr == 1000
            pacparams.AmpFreqVector        = 10:5:420;
        end
        if needToSavePacResults
            res = computePAC(dat.rawdata',dat.sr,pacparams);
            pac_results(n).(fldnms{a}) = res;
        else
            res = pac_results(n).(fldnms{a});
        end
        % pac plot
        areasAmp = sprintf('%s %s',dat.chan,fldnms{a});
        areasPhase = sprintf('%s %s',dat.chan,fldnms{a});
        contourf(res.PhaseFreqVector+res.PhaseFreq_BandWidth/2,...
            res.AmpFreqVector+res.AmpFreq_BandWidth/2,...
            res.Comodulogram',30,'lines','none')
        shading interp
        ttly = sprintf('Amplitude Frequency %s (Hz)',areasAmp);
        ylabel(ttly)
        ttlx = sprintf('Phase Frequency %s (Hz)',areasPhase);
        xlabel(ttlx)
        ttlstr = sprintf('%s %dHz',areasPhase,dat.sr);
        title(ttlstr);
        set(gca,'FontSize',18);
    end
end
save(origfile,'pac_results','-append');
sgtitle(titleName,'FontSize',30);
hfig.Color = 'w';

prfig.plotwidth           = 30;
prfig.plotheight          = 30;
prfig.figdir              = figdir;
prfig.figtype             = '-djpeg';
prfig.closeafterprint     = 0;
prfig.resolution          = 300;
prfig.figname             = fnsave;
plot_hfig(hfig,prfig);
close all;

end