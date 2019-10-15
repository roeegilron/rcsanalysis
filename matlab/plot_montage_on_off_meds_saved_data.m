function plot_montage_on_off_meds_saved_data(data,figdir)


params.side = {'L','R'};
params.numSides = 2;
% params to print the figures
prfig.plotwidth           = 25;
prfig.plotheight          = 25*0.6;
prfig.figdir              = figdir;
prfig.figtype             = '-djpeg';
prfig.closeafterprint     = 0;
prfig.resolution          = 300;


%% plot med on med off;
runthis = 1;
if runthis
    close all;
    chanNames = {'LFP','M1'};
    medstate = {'off med','on med'};
    colorsUse = [0.8 0 0 0.8; 0 0.8 0 0.8];
    for s = 1:params.numSides
        for c = 1:length(chanNames)
            hfig  = figure; hold on;
            for i = 1:7
                subplot(4,2,i); hold on;
                for m = 1:2 % loop on med state - first is off meds
                    load(data{m,s})
                    rawdat = montageData.(chanNames{c})(i).rawdata;
                    sr     = montageData.(chanNames{c})(i).sr;
                    [fftOut,ff]   = pwelch(rawdat,sr,sr/2,0:1:sr/2,sr,'psd');
                    plot(ff,log10(fftOut),'LineWidth',4,...
                        'Color',colorsUse(m,:));
                end
                if sr == 500
                    xlim([3 150]);
                elseif sr == 1000
                    xlim([3 400]);
                end
                electrodeUse     = montageData.(chanNames{c})(i).chan;
                titleUse = sprintf('%s %s %s',params.side{s},chanNames{c},electrodeUse);
                title(titleUse);
                legend(medstate);
                set(gca,'FontSize',18);
                set(gcf,'Color','w');
            end
            prfig.figname             = sprintf('%s_%s',params.side{s},chanNames{c});
            plot_hfig(hfig,prfig);
        end
    end
end
%% get data for plotting coherence comparison for the 1000hz contacts
close all;
chanNames = {'LFP','M1'};
medstate = {'off med','on med'};
colorsUse = [0.8 0 0 0.8; 0 0.8 0 0.8];
hfig  = figure; hold on;
cntplt = 1;
y = {};
for s = 1:params.numSides
    for m = 1:2 % loop on med state - first is off meds
        load(data{m,s});
        for i = 7
            for c = 1:length(chanNames)
                load(data{m,s});
                rawdat   = montageData.(chanNames{c})(i).rawdata;
                sr       = montageData.(chanNames{c})(i).sr;
                y{s,m,c}     = rawdat';
            end
        end
    end
end

% do some analysis on 1000hz data
%% coherence
runthis = 1;
if runthis
    sides = {'left side','right side'}; 
    colorsUse = [0.8 0 0 0.5; 0 0.8 0 0.5];
    dat = {};
    cntplt = 1;
    hfig = figure;
    for s = 1:params.numSides
        hsub(s) = subplot(1,2,cntplt);
        cntplt = cntplt +1;
        hold on;
        for m = 1:2 % loop on med state - first is off meds
            dat = squeeze( y(s,m,:));
            minLen = min([ length(dat{1}) length(dat{2})]);
            Fs = sr;
            [Cxy,F] = mscohere(dat{1}(1:minLen),dat{2}(1:minLen),...
                2^(nextpow2(Fs)),...
                2^(nextpow2(Fs/2)),...
                2^(nextpow2(Fs)),...
                Fs);
            xlim([3 400]);
            hplot = plot(hsub(s),F,Cxy,'LineWidth',4,...
                'Color',colorsUse(m,:));
            xlabel('Freq (Hz)');
            ylabel('MS Coherence');
            set(gca,'FontSize',18);
        end
        title(sprintf('%s',sides{s}),'FontSize',20);
        legend({'off - home','on - home'});
    end
    
    sgtitle('Coherence between STN-M1 1000Hz','FontSize',25);
    prfig.figname             = sprintf('coherence-1000hz');
    hfig.Color = 'w';
    plot_hfig(hfig,prfig);
    close all;
end
%% psd
runthis = 1;
if runthis
    xlims = [1 120;
        120 400];
    xtitls = {'lowPower','highPower'};
    medstate = {'off med +1-3','on med +1-3'; 'off med +9-11','on med +9-11'};
    for xx = 1:length(xlims)
        cntplt = 1;
        hfig = figure;
        areas = {'STN','M1'};
        for s = 1:params.numSides
            hold on;
            for c = 1:2 % loop on channels STN/M1
                hsub(s) = subplot(2,2,cntplt); hold on;
                cntplt = cntplt +1;
                for m = 1:2 % loop on med state - first is off meds
                    dat = squeeze( y(s,m,c));
                    sr = 1e3;
                    [fftOut,ff]   = pwelch(dat{1},sr,sr/2,0:1:sr/2,sr,'psd');
                    plot(ff,log10(fftOut),'LineWidth',4,...
                        'Color',colorsUse(m,:));
                    ylabel('Power  (log_1_0\muV^2/Hz)');
                    xlabel('Frequency (Hz)');
                    
                    
                end
                legend(medstate{c,:});
                set(gca,'FontSize',18);
                xlim(xlims(xx,:));
                ttluse = sprintf('%s ',params.side{s},areas{c});
                title(ttluse,'FontSize',20);
            end
        end
        prfig.figname             = sprintf('psd-%s-1000hz',xtitls{xx});
        suprtitle = sprintf('PSD %s 1000Hz',xtitls{xx});
        sgtitle(suprtitle);
        hfig.Color = 'w';
        plot_hfig(hfig,prfig);
    end
end
%% pac
%% pac params
runthis = 1;
if runthis
    
    close all;
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
    
    meds = {'off - home','on - home'};
    sides = {'left brain','right brain'};
    for s = 1:params.numSides
        hfig = figure;
        for i = 1:6
            hsub(i) = subplot(2,3,i);
        end
        hold on;
        for m = 1:2 % loop on med state - first is off meds
            dat = {};
            dat = squeeze( y(s,m,:));
            minLen = min([ length(dat{1}) length(dat{2})]);
            Fs = sr;
            yUse = [];
            yUse(:,1) = dat{1}(1:minLen);
            yUse(:,2) = dat{2}(1:minLen);
            results = computePAC(yUse',1e3,pacparams);
            % pac plot
            if m == 1
                addFac = 0;
            else
                addFac = 3;
            end
            areasAmp = {'STN','M1','M1'};
            areasPhase = {'STN','M1','STN'};
            for ii = 1:3
                res = results(ii);
                contourf(hsub(ii+addFac),res.PhaseFreqVector+res.PhaseFreq_BandWidth/2,...
                    res.AmpFreqVector+res.AmpFreq_BandWidth/2,...
                    res.Comodulogram',30,'lines','none')
                shading interp
                ttly = sprintf('Amplitude Frequency %s (Hz)',areasAmp{ii});
                ylabel(hsub(ii+addFac),ttly)
                ttlx = sprintf('Phase Frequency %s (Hz)',areasPhase{ii});
                xlabel(hsub(ii+addFac),ttlx)
                ttlstr = sprintf('%s',meds{m});
                title(hsub(ii+addFac),ttlstr);
                set(hsub(ii+addFac),'FontSize',18);
            end
            %  1 plot PAC within area 1
            %  2 plot PAC within area 2
            %  3 plot PAC between area 1 (phase) and area 2 (amp)
            %  4 plot PAC between area 1 (amp) and area 2 (phase)
            
        end
        suprtitle = sprintf('PAC on/off home estimate %s',sides{s});
        sgtitle(suprtitle,'FontSize',30);
        prfig.figname             = sprintf('PAC-1000hz %s',sides{s});
        hfig.Color = 'w';
        plot_hfig(hfig,prfig);
        close all;
    end
end



end