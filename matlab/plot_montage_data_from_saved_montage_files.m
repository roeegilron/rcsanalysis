function plot_montage_data_from_saved_montage_files(dirname)
% you need to run this function first:
% open_and_save_montage_data_in_sessions_directory
addpath('/Users/juananso/Dropbox (Personal)/Work/Git_Repo/rcsanalysis/toolboxes/PAC-master');
ff = findFilesBVQX(dirname,'rawMontageData.mat');
figdir = fullfile(dirname,'figures');
mkdir(figdir);

for f = 1:length(ff)
    load(ff{f});
    if exist('montagDataRawManualIdxs','var')
        montageDataRaw = montagDataRawManualIdxs;
    end
    plot_data_per_recording(montageDataRaw,figdir,ff{f});
%     plot_pac_montage_data_within(montageData,figdir,ff{f});
    [pn,fn] = fileparts(ff{f});
    
%     plot_montage_data(pn);
%     rcsDataChopper(pn); 
end
end

function plot_data_per_recording(montageData,figdir,origfile)
addpath(genpath(fullfile(pwd,'toolboxes','panel-2.14')));
for i = 1:size(montageData,1)
    hfig = figure('Visible','on');
    hfig.Color = 'w';
    hfig.Position = [1000         547        1020         791];
    hpanel = panel();
    hpanel.pack(4,5);
    % raw data
    x = montageData.derivedTimes{i};
    if isduration(x)
        idxuse = x > seconds(3) & x < (x(end)-seconds(3));
    else
        idxuse = (x > 3) & x < (x(end)-3);
    end
    x = x(idxuse); 
    x = x - x(1); 
    sr = montageData.samplingRate(i);
    ydat = montageData.data{i};
    ydat = ydat(idxuse,:);
    for c = 1:4
        hsb = hpanel(c,1).select();
        axes(hsb);
        y = ydat(:,c)*1000; % form millivolts to microVolts
        y = y - mean(y); 
        plot(x,y);
        xlabel('Time');
        ylabel('uV');
        if isduration(x)
            xtickformat('mm:ss');
        end
        chanchar = montageData.TimeDomainDataStruc{i}(c).chanOut;
        ttlstr = sprintf('raw %s',chanchar);
        title(ttlstr);
    end
    % spectrogram
     for c = 1:4
        hsb = hpanel(c,2).select();
        axes(hsb);
        y = ydat(:,c);
        y = y - mean(y); 
        if sum(y) ~= 0
            srate = sr;
            overlapFac = 0.875;
            spectrogram(y,srate,ceil(overlapFac*srate),1:ceil(srate/2-20),srate,'yaxis','psd');
            shading interp
            axis tight;
            colorbar off;
            chanchar = montageData.TimeDomainDataStruc{i}(c).chanOut;
            ttlstr = sprintf('Spect %s',chanchar);
            title(ttlstr);
        end
     end
     % psd 
     for c = 1:4
        hsb = hpanel(c,3).select();
        axes(hsb);
        hold on;
        y = ydat(:,c);
        y = y - mean(y);
        if sum(y) ~= 0
            [fftOut,f]   = pwelch(y,sr,sr/2,2:1:(sr/2 - 50),sr,'psd');
            plotFreqPatches(hsb);
            plot(f,log10(fftOut),'LineWidth',2);
            xlabel('Freq (Hz)');
            ylabel('Power (log_1_0\muV^2/Hz)');
            chanchar = montageData.TimeDomainDataStruc{i}(c).chanOut;
            ttlstr = sprintf('PSD %s',chanchar);
            title(ttlstr);

        end
     end
    % pac
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

    addpath(genpath(fullfile('..','..','PAC')));
    if sr == 250
        pacparams.AmpFreqVector        = 10:5:80;
    elseif sr == 500
        pacparams.AmpFreqVector        = 10:5:200;
    elseif sr == 1000
        pacparams.AmpFreqVector        = 10:5:420;
    end
    for c = 1:4
        hsb = hpanel(c,4).select();
        axes(hsb);
        hold on;
        y = ydat(:,c);
        y = y - mean(y);
        if sum(y) ~= 0
            res = computePAC(y',sr,pacparams);
            chanchar = montageData.TimeDomainDataStruc{i}(c).chanOut;
            areasAmp = sprintf('%s',chanchar);
            areasPhase = sprintf('%s',chanchar);
            
            contourf(res.PhaseFreqVector+res.PhaseFreq_BandWidth/2,...
                res.AmpFreqVector+res.AmpFreq_BandWidth/2,...
                res.Comodulogram',30,'lines','none')
            shading interp
            ttly = sprintf('Amplitude Frequency %s (Hz)',areasAmp);
            ylabel(ttly)
            ttlx = sprintf('Phase Frequency %s (Hz)',areasPhase);
            xlabel(ttlx)
            ttlstr = sprintf('PAC %s',chanchar);
            title(ttlstr);
            set(gca,'FontSize',10);
        end
    end
    % coherence 
    % pairs: 
    if sr == 1000 
        reps = 2;
    else
        reps = 1; 
    end 
    for r = 1:reps
        if sr == 1000
            copairs = [1 3; 1 3];
        else
            copairs = [1 3; 1 4; 2 3; 2 4];
        end
        for c = 1:size(copairs,1)
            if sr == 1000
                hsb = hpanel(r,5).select();
            else
                hsb = hpanel(c,5).select();
            end
            axes(hsb);
            hold on;
            y1 = ydat(:,copairs(c,1));
            y2 = ydat(:,copairs(c,2));
            if (sum(y1) ~= 0) & (sum(y2) ~= 0)
                pair1 = montageData.TimeDomainDataStruc{i}(copairs(c,1)).chanOut;
                pair2 = montageData.TimeDomainDataStruc{i}(copairs(c,2)).chanOut;
                ttlstr = sprintf('%s - %s coh',pair1, pair2);
                Fs = sr;
                [Cxy,F] = mscohere(y1',y2',...
                    2^(nextpow2(Fs)),...
                    2^(nextpow2(Fs/2)),...
                    2^(nextpow2(Fs)),...
                    Fs);
                if r == 2
                    idxplot = F > 100 & F < 400;
                else
                    idxplot = F > 2 & F < 100;
                end
                hplot = plot(F(idxplot),Cxy(idxplot),'LineWidth',2);
                xlabel('Freq (Hz)');
                ylabel('MS Coherence');
                title(ttlstr);
            end
        end
    end
    timeStart = datetime(montageData.startTime(i),'Format','HH:mm');
    fntitle = sprintf('%0.2d %s %s %s',i,montageData.patient{i},montageData.side{i},timeStart);
%     sgtitle(fntitle)
    
    hpanel.margin = [20 20 20 20];
    hpanel.fontsize = 13;
    hpanel.de.margin = 20;
    % print the figure 
    timeStart = datetime(montageData.startTime(i),'Format','dd-MMM-yyyy_HH-mm');
    fnsave = sprintf('%s_%s_%s_%0.2d',montageData.patient{i},montageData.side{i},timeStart,i);
    prfig.plotwidth           = 20;
    prfig.plotheight          = 15;
    prfig.figdir              = figdir;
    prfig.figtype             = '-djpeg';
    prfig.closeafterprint     = 0;
    prfig.resolution          = 100;
    prfig.figname             = fnsave;
    plot_hfig(hfig,prfig);
    close all;
end





end

function plot_pac_montage_data_within(montageData,figdir,origfile)
close all;
addpath(genpath(fullfile('..','..','PAC')));
timeStart = datetime(montageData.startTime(1),'Format','dd-MMM-yyyy_HH-mm');
fnsave = sprintf('%s_%s_%s',montageData.patient,montageData.side,timeStart);
timeStart = datetime(montageData.startTime(1),'Format','dd-MMM-yyyy HH:mm');
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
    ncols  = 5;
    nrows  = 4;
elseif length(montageData.M1) == 6
    ncols  = 3;
    nrows  = 4;
elseif length(montageData.M1) == 7
    % 14 PAC plots
    ncols  = 4;
    nrows  = 4;
elseif length(montageData.M1) == 12
    % 14 PAC plots
    ncols  = 6;
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



function plot_coherence_montage_data(montageData,figdir,origfile)
results = [];
% set up subplots
app.hfig = figure;
hsub(1) = subplot(2,3,1,'Parent',app.hfig);
hsub(2) = subplot(2,3,4,'Parent',app.hfig);
hsub(3) = subplot(2,3,2,'Parent',app.hfig);
hsub(4) = subplot(2,3,5,'Parent',app.hfig);
hsub(5) = subplot(2,3,3,'Parent',app.hfig);
hsub(6) = subplot(2,3,6,'Parent',app.hfig);
app.hsubCoherence = gobjects(6,1);
for i = 1:6
    app.hsubCoherence(i) = hsub(i);
end

cnPairs = [1 2;... % stn stn
    3 4;... % m1 m1
    1 3;... % m1 m1
    1 4;...
    2 3;...
    2 4];
idxMontage = find(strcmp(app.hCoherenceMontageSelecor.Value,app.hCoherenceMontageSelecor.Items)==1);

outdatcomplete = app.(sprintf('outDataChunks%d',idxMontage));
outRec = app.outRec(idxMontage);
times = outdatcomplete.derivedTimes;
srate = unique( outdatcomplete.samplerate );
nmplt = 1;
i = 1;
for c = 1:size(cnPairs,1)
    axes(hsub(c));
    hold on;
    % first channel
    cIdx1 = cnPairs(c,1);
    fnm = sprintf('key%d',cIdx1-1);
    y1 = outdatcomplete.(fnm);
    y1 = y1 - mean(y1);
    
    cIdx2 = cnPairs(c,2);
    fnm = sprintf('key%d',cIdx2-1);
    y2 = outdatcomplete.(fnm);
    y2 = y2 - mean(y2);
    
    %% plot cohenece
    Fs = unique(outdatcomplete.samplerate);
    [Cxy,F] = mscohere(y1',y2',...
        2^(nextpow2(Fs)),...
        2^(nextpow2(Fs/2)),...
        2^(nextpow2(Fs)),...
        Fs);
    idxplot = F > 0 & F < 100;
    hplot = plot(F(idxplot),Cxy(idxplot),'Parent',hsub(c));
    xlabel(hsub(c),'Freq (Hz)');
    ylabel(hsub(c),'MS Coherence');
    
    xlim([0 100]);
    ttlGraph = sprintf('C between %s and %s',...
        outRec(1).tdData(cIdx1).chanOut,...
        outRec(1).tdData(cIdx2).chanOut);
    set(hsub(c),'FontSize',10);
    
    title(hsub(c),ttlGraph,'FontSize',10);
    clear y1 y2 cIdx1 cIdx2;
    ylims(c,:) = hsub(c).YLim;
    nmplt = nmplt + 1;
end
ylimsUse = [min(ylims(:,1)) max(ylims(:,2))];
for c = 1:6
    set(hsub(c),'Ylim',ylimsUse);
end

end