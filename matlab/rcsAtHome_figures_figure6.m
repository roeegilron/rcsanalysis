function rcsAtHome_figures_figure6()
% Quality of data seperation using unsupervised methods
% panel a - unsuperivsed clustering using rodrigez Science 2014 method  (RCS02 and RCS07)
% panel b - unsupervised clustering using a template method (RCS02 and RCS07)
% panel c - bar code comparisons - state estimate, rodgrigez, template matching

plotpanels = 1;
addpath(genpath(fullfile(pwd,'toolboxes','panel-2.14')));
if ~plotpanels
    hfig = figure;
    hfig.Color = 'w';
    hfig.Position = [1355         264         877        1041];
    hpanel = panel();
    hpanel.pack({0.6 0.4}); % top and bottom 
    hpanel(1).pack(1,2); % divide top into two 
    hpanel(1,1,1).pack(2,2);
    hpanel(1,1,2).pack(2,2);
    hpanel(2).pack(6,1); % all the bard codes 
%     hpanel.select('all');
%     hpanel.identify();
end
includesleep = 0;
plotthis = 1;
if plotthis
%% panel a - unsuperivsed clustering using rodrigez Science 2014 method  (RCS02 and RCS07)
figdirout = '/Users/roee/Starr_Lab_Folder/Writing/papers/2019_LongTerm_RCS_recordings/figures/1_draft2/Fig6_unsupervised_methods';

resultsdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home';
resultsdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home';
resultsdir = '/Users/roee/Box/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home/coherence_and_psd/';

ff = findFilesBVQX(resultsdir,'coherence_and_psd *.mat');
addpath(genpath('/Users/roee/Starr_Lab_Folder/Data_Analysis/rcsanalysis/matlab/toolboxes/cluster_dp'));

computecluster = 0; % if computer cluster - compute and plot clusters 
% otherwise just load the cluster and plot it based on a predtermined key. 
% using specific subjects and areas 
if computecluster 
for f = [2 8] %1:length(ff) % loop on patient
    [pn,fn] = fileparts(ff{f}); 
    load(ff{f}); 
    patientstr = fn(19:23); 
    patientsid = fn(25);
    
    
    freqranges = [1 4;     4 8;     8 13;    13 20;   20 30;     13 30;  30 50;     50 90];
    freqnames  = {'Delta', 'Theta', 'Alpha','LowBeta','HighBeta','Beta','LowGamma','HighGamma'}';
    
    usespecfreq = 1;
    fftSpecFreqsAll = [] ;
    includesleep = 0; 
    if ~includesleep
        idxnotsleep = ~strcmp(allDataPkgRcsAcc.states,'sleep');
    end
    for c = 1:4
        fftSpecFreqs = [];
        fn = sprintf('key%dfftOut',c-1);
        for sf = 1:size(freqranges,1)
            idxfreqs = psdResults.ff >= freqranges(sf,1) & psdResults.ff <= freqranges(sf,2);
            if ~includesleep
                dat = allDataPkgRcsAcc.(fn)(idxnotsleep,:);
            else
                dat = allDataPkgRcsAcc.(fn);
            end
            idxnormalize = psdResults.ff > 3 &  psdResults.ff <90;
            meandat = abs(mean(dat(:,idxnormalize),2)); % mean within range, by row
            % the absolute is to make sure 1/f curve is not flipped
            % since PSD values are negative
            meanmat = repmat(meandat,1,size(dat,2));
            dat = dat./meanmat;
            
            
            fftSpecFreqs(:,sf) = mean(dat(:,idxfreqs) ,2);
            
        end
        [cl_spec(:,c),halo_spec(:,c)] = do_clustering(fftSpecFreqs);
        fftSpecFreqsAll = [fftSpecFreqsAll, fftSpecFreqs];
    end
    [cl,halo] = do_clustering(fftSpecFreqsAll);
    % plotting 
    hfig = figure; 
    hfig.Color = 'w'; 
    plotShaded = 0;
    plotRaw = 1;
    for c = 1:4
        fn = sprintf('key%dfftOut',c-1);
        hsub = subplot(2,2,c);
        hold on;
        if ~includesleep
            dat = allDataPkgRcsAcc.(fn)(idxnotsleep,:);
        else
            dat = allDataPkgRcsAcc.(fn);
        end
        idxnormalize = psdResults.ff > 3 &  psdResults.ff <90;
        meandat = abs(mean(dat(:,idxnormalize),2)); % mean within range, by row
        % the absolute is to make sure 1/f curve is not flipped
        % since PSD values are negative
        meanmat = repmat(meandat,1,size(dat,2));
        dat = dat./meanmat;
        
        uniqueCluster = unique(cl);
        colorsUse = parula(length(uniqueCluster));

        
        freqs = psdResults.ff;
        ttls = {'STN 0-2','STN 1-3','M1 8-10','M1 9-11'};
        for cu = 1:length(uniqueCluster)
            % cluster 1
            if plotShaded
                hsb = shadedErrorBar(freqs,dat(cl==cu,:),{@median,@(x) std(x)*1});
                hsb.mainLine.Color = [colorsUse(cu,:) 0.5];
                hsb.mainLine.LineWidth = 3;
                hsb.patch.MarkerFaceColor = colorsUse(cu,:);
                hsb.patch.FaceColor = colorsUse(cu,:);
                hsb.patch.FaceAlpha = 0.1;
            end
            if plotRaw
                plot(freqs,dat(cl==cu,:),...
                    'LineWidth',0.1,...
                    'Color',[colorsUse(cu,:) 0.1]);
            end
        end
        ylabel('Power (log_1_0\muV^2/Hz)');
        xlabel('Frequency (Hz)');
        xlim([0 100]);
        ttluse = {};
        ttluse{1,1} = sprintf('%s',patDatHome.patient{pp});
        ttluse{2,1} = sprintf('%s',ttlsforpaper{c});

        title(ttluse);
    end
    
    ttluse = sprintf('%s %s',patientstr,patientsid);
    sgtitle(ttluse,'FontSize',20);
    fnsave = sprintf('unsupervised_clustering_results_10min_not_including_sleep_%s_%s.mat',patientstr,patientsid); 
    fnsave = fullfile(resultsdir,fnsave); 
    save(fnsave,'cl','halo','cl_spec','halo_spec');
    
    figname = sprintf('unsupervised_clustering_10min_not_including_sleep_can_freqs and_template_data_ raw %s %s',patientstr,patientsid);
    prfig.plotwidth           = 15;
    prfig.plotheight          = 10;
    prfig.figname             = figname;
    prfig.figdir              = resultsdir;
    plot_hfig(hfig,prfig)
    
    clear fftSpecFreqs cl halo cl_spec halo_spec
end
else
    patientplot = {'RCS02','RCS07'};
    patientsNameToPlot = {'RCS01','RCS04'};
    patientside = {'R','R'};
    pkgside     = {'L','L'};
    ttls = {'STN 0-2','STN 1-3','M1 8-10','M1 9-11'};
    ttlsforpaper = {'STN 0-2','STN 1-3','motor cortex 8-10','motor cortex 9-11'};

    nrows = 2;
    ncols = 2;
    plotShaded = 0;
    plotRaw = 1;

    if plotpanels
        % plotting
        hfig = figure;
        hfig.Color = 'w';
    end
    
    cntplt = 1; 
    if ~plotpanels
        hsubs = gobjects(4,1);
        hsubs(1) = hpanel(1,1,1,1,1).select();
        hsubs(3) = hpanel(1,1,1,1,2).select();
        hsubs(2) = hpanel(1,1,1,2,1).select();
        hsubs(4) = hpanel(1,1,1,2,2).select();
    end
    for p = 1:length(patientplot)
        fnload = sprintf('coherence_and_psd %s %s pkg %s.mat',patientplot{p},patientside{p},pkgside{p});
        load(fullfile(resultsdir,fnload));
        fnload = sprintf('unsupervised_clustering_results_10min_including_sleep_%s_%s.mat',patientplot{p},patientside{p});
        fnload = sprintf('unsupervised_clustering_results_10min_not_including_sleep_%s_%s.mat',patientplot{p},patientside{p});
        load(fullfile(resultsdir,fnload));
        for c = [2 4]
            fn = sprintf('key%dfftOut',c-1);
            if plotpanels
                hsub = subplot(nrows,ncols,cntplt); cntplt = cntplt + 1;
            else
                axes(hsubs(cntplt)); cntplt = cntplt + 1;
            end
            hold on;
            idxnotsleeep = ~strcmp(allDataPkgRcsAcc.states,'sleep');
            includesleep = 0;
            if ~includesleep
                dat = allDataPkgRcsAcc.(fn)(idxnotsleeep,:);
            else
                dat = allDataPkgRcsAcc.(fn);
            end
            
            
            idxnormalize = psdResults.ff > 3 &  psdResults.ff <90;
            meandat = abs(mean(dat(:,idxnormalize),2)); % mean within range, by row
            % the absolute is to make sure 1/f curve is not flipped
            % since PSD values are negative
            meanmat = repmat(meandat,1,size(dat,2));
            dat = dat./meanmat;
            
            uniqueCluster = unique(cl);
            colorsUse = parula(length(uniqueCluster));
            switch patientplot{p}
                case 'RCS02'
                    colorsUse = [1.000000000000000   0.792156862745098                   0; ...
                                  0.443137254901961                   0   0.623529411764706 ];
                case 'RCS07'
                    colorsUse = [1.000000000000000   0.792156862745098                   0; ...
                                  0.443137254901961                   0   0.623529411764706 ;...
                                 0 0.8 0];
                    
            end
            
            
            freqs = psdResults.ff;
            for cu = 1:length(uniqueCluster)
                % cluster 1
                if plotShaded
                    hsb = shadedErrorBar(freqs,dat(cl==cu,:),{@median,@(x) std(x)*1});
                    hsb.mainLine.Color = [colorsUse(cu,:) 0.5];
                    hsb.mainLine.LineWidth = 3;
                    hsb.patch.MarkerFaceColor = colorsUse(cu,:);
                    hsb.patch.FaceColor = colorsUse(cu,:);
                    hsb.patch.FaceAlpha = 0.1;
                    hsb.edge(1).Color = [ 1 1 1 ];
                    hsb.edge(2).Color = [ 1  1 1 ];
                end
                if plotRaw
                    plot(freqs,dat(cl==cu,:),...
                        'LineWidth',0.1,...
                        'Color',[colorsUse(cu,:) 0.1]);
                end
            end
            
            
            xlim([0 100]);
            ttluse = {};
            ttluse{1,1} = sprintf('%s',patientsNameToPlot{p});
            ttluse{2,1} = sprintf('%s',ttlsforpaper{c});
            
            title(ttluse);
            
           
        end
    end
    
    
    hsubs(1).XTick = []; 
    hsubs(1).YLabel.String = 'Norm. power (a.u.)';
    
    hsubs(2).YLabel.String = 'Norm. power (a.u.)';
    hsubs(2).XLabel.String = 'Frequency (Hz)';
    
    hsubs(3).XTick = []; 
    hsubs(3).YTick = []; 
     
    hsubs(4).YTick = []; 
    hsubs(4).XLabel.String = 'Frequency (Hz)';
    
    
    
    if plotpanels
        prfig.plotwidth           = 15;
        prfig.plotheight          = 10;
        prfig.figname             = 'Fig6_panelA_unsupervised_clustering_no_sleep';
        prfig.figdir              = figdirout;
        plot_hfig(hfig,prfig)
    end
end
%%
end 


plotthis = 0;
if plotthis
%% panel b - unsupervised clustering using a template method (RCS02 and RCS07)
% load home data  and make table of patient and side 
addpath(genpath(fullfile(pwd,'toolboxes','shadedErrorBar')))
rootdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/pkg_data/figures/17_states_historical';
rootdir = '/Users/roee/Box/rcs paper paper on first five bilateral implants/revision for nature biotechnology/figures/Fig6_unsupervised_methods/data/17_states_historical';
figdirout = '/Users/roee/Starr_Lab_Folder/Writing/papers/2019_LongTerm_RCS_recordings/figures/1_draft2/Fig6_unsupervised_methods';
figdirout = '/Users/roee/Box/rcs paper paper on first five bilateral implants/revision for nature biotechnology/figures/Fig6_unsupervised_methods';

resultsdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home';
resultsdir = '/Users/roee/Box/rcs paper paper on first five bilateral implants/revision for nature biotechnology/figures/Fig5_states_estimates_group_data_and_ AUC/data';
ff = findFilesBVQX(rootdir, 'pkg_states*10_min*.mat');
patDatHome = struct();
for f = 1:length(ff)
    [pn,fn] = fileparts(ff{f});
    patient = fn(12:16);
    side = fn(18);
    patDatHome(f).patient = patient;
    patDatHome(f).side = side;
    patDatHome(f).filename = ff{f};
end
patDatHome = struct2table(patDatHome);

% load in clinic data
dirname = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/in_clinic/rest_3rd_try';
dirname = '/Users/roee/Box/rcs paper paper on first five bilateral implants/revision for nature biotechnology/figures/Fig6_unsupervised_methods/data/rest_3rd_try';
fnmsave = fullfile(dirname,'patientPSD_in_clinic.mat');
load(fnmsave,'patientPSD_in_clinic');

% loop on patients
patDatHome = patDatHome([2 8],:);
nrows = 2; 
ncols = 2; 
cntplt = 1;
includesleep = 0;

colors = [0.8 0 0; 0 0.8 0;0 0 0.8; 0.5 0.5 0.5];
if plotpanels
    hfig = figure;
    hfig.Color = 'w';
end

patientplot = {'RCS02','RCS07'};
patientNamesToPlot = {'RCS01','RCS04'};
patientside = {'R','R'};
pkgside     = {'L','L'};

titles = {'STN 0-2','STN 1-3','M1 8-10','M1 9-11'};
ttlsforpaper = {'STN 0-2','STN 1-3','motor cortex 8-10','motor cortex 9-11'};

if ~plotpanels
    hsubsb = gobjects(4,1);
    hsubsb(1) = hpanel(1,1,2,1,1).select();
    hsubsb(3) = hpanel(1,1,2,1,2).select();
    hsubsb(2) = hpanel(1,1,2,2,1).select();
    hsubsb(4) = hpanel(1,1,2,2,2).select();
end

for pp = 1:size(patDatHome)
%     load(patDatHome.filename{pp});
    
    fnload = sprintf('coherence_and_psd %s %s pkg %s.mat',patientplot{pp},patientside{pp},pkgside{pp});
    load(fullfile(resultsdir,fnload));

    idxPsdClinic = strcmp(patientPSD_in_clinic.patient,patDatHome.patient{pp}) & ...
        strcmp(patientPSD_in_clinic.side,patDatHome.side{pp});
    psdInClinicAllAreas = patientPSD_in_clinic(idxPsdClinic,:);
    lablesout = [] ;
    % loop on area
    for c = [2 4]
        % get clinic template
        idxarea = strcmp(psdInClinicAllAreas.electrode,titles{c});
        psdInClinic = psdInClinicAllAreas(idxarea,:);
        % get at home data
        fieldNameAtHome = sprintf('key%dfftOut',c-1);
        if includesleep
            psdHome = allDataPkgRcsAcc.(fieldNameAtHome);
        else
            idxnotsleep = ~strcmp(allDataPkgRcsAcc.states,'sleep');
            psdHome = allDataPkgRcsAcc.(fieldNameAtHome)(idxnotsleep,:);
        end
        idxnormalize = psdResults.ff > 3 &  psdResults.ff <90;
        meandat = abs(mean(psdHome(:,idxnormalize),2)); % mean within range, by row
        % the absolute is to make sure 1/f curve is not flipped
        % since PSD values are negative
        meanmat = repmat(meandat,1,size(psdHome,2));
        normalizedPSD = psdHome./meanmat;
        % normalizedPSD = rescale(normalizedPSD,0,1);
        
        % loop on states
        unqStates = unique(psdInClinic.medstate);
        d = [];
        fftTemplateUse = [];
        % get templates
        for m = 1:length(unqStates)
            idxuse = strcmp(psdInClinic.medstate,unqStates{m});
            psdUse = psdInClinic(idxuse,:);
            fftTemplateUse(:,m) = psdUse.fftOut{:};
        end
        % normalize templates from in clinic use
        fftTemplate = fftTemplateUse';
        idxnormalize = psdInClinic.ff{1} > 3 &  psdInClinic.ff{1} <90;
        meandatinclinic = abs(mean(fftTemplate(:,idxnormalize),2)); % mean within range, by row
        % the absolute is to make sure 1/f curve is not flipped
        % since PSD values are negative
        meanmatinclinic = repmat(meandatinclinic,1,size(fftTemplate,2));
        normalizedFFTtemp = fftTemplate./meanmatinclinic;
        % normalizedFFTtemp = rescale(normalizedFFTtemp,0,1);
        normalizedFFTtemp = normalizedFFTtemp';
        
        freqsInClinic = psdInClinic.ff{1}';
        freqsAtHome   = psdResults.ff;
        if length(freqsAtHome) < length(freqsInClinic)
            normalizedFFTtemp = interp1(freqsInClinic,normalizedFFTtemp,freqsAtHome);
        end
        
        
        
        % plot raw data
        
        % compute distances
        fftTempOut = []; fftTempOut = [];
        for m = 1:length(unqStates)
            fftTemRep = repmat(normalizedFFTtemp(:,m)',size(normalizedPSD,1),1);
            d(:,m) = vecnorm(normalizedPSD' - fftTemRep')';
        end
        
        plotRaw = 1;
        plotState = 0;
        plotDistance = 0;
        if plotpanels
            subplot(nrows,ncols,cntplt); cntplt = cntplt + 1;
        else
            axes(hsubsb(cntplt)); cntplt = cntplt + 1;
        end
        colors(1,:) = [0   0.815686274509804   0.803921568627451];
        colors(2,:) = [1.000000000000000   0.341176470588235                   0];
        if plotRaw
            for s = 1:2
                hold on;
                if s == 1
                    labels = d(:,2) > d(:,1);
                else
                    labels = d(:,1) >= d(:,2);
                end
                if s == 2 & cntplt == 5
                    LineWidth = 0.05;
                    Alpha = 0.02;
                elseif s == 1 & cntplt == 5
                    LineWidth = 1;
                    Alpha = 0.2;
                else
                    LineWidth = 0.05;
                    Alpha = 0.02;

                end
                plot(psdResults.ff,normalizedPSD(labels,:),...
                    'LineWidth',LineWidth,...
                    'Color',[colors(s,:) Alpha]);
            end
            plot(normalizedFFTtemp(:,1)','LineWidth',1,'Color',[0 0 0 0.8],'LineStyle','-.');
            plot(normalizedFFTtemp(:,2)','LineWidth',1,'Color',[0 0 0 0.8],'LineStyle','-');
            xlim([0 100]);
            ttluse = {};
            ttluse{1,1} = sprintf('%s',patientNamesToPlot{pp});
            ttluse{2,1} = sprintf('%s',ttlsforpaper{c});
            title(ttluse);
            xlabel('Frequency (Hz)');
            ylabel('Normalized power (a.u.)');
            set(gca,'FontSize',16);
        end
        
        if plotState
            for s = 1:2
                hold on;
                if s == 1
                    labels = d(:,2) > d(:,1);
                else
                    labels = d(:,1) > d(:,2);
                end
                if sum(labels) > 1
                    hsbH = shadedErrorBar(psdResults.ff,normalizedPSD(labels,:),{@mean,@(x) std(x)*1});
                    hsbH.mainLine.Color = [colors(s,:) 0.5];
                    hsbH.mainLine.LineWidth = 3;
                    hsbH.patch.MarkerFaceColor = colors(s,:);
                    hsbH.patch.FaceColor = colors(s,:);
                    hsbH.patch.EdgeColor = colors(s,:);
                    hsbH.edge(1).Color = [colors(s,:) 0.1];
                    hsbH.edge(2).Color = [colors(s,:) 0.1];
                    hsbH.patch.EdgeAlpha = 0.1;
                    hsbH.patch.FaceAlpha = 0.1;
                    hForLeg(s) = hsbH.mainLine;
                end
            end
            xlim([0 100]);
            ttluse = {};
            ttluse{1,1} = sprintf('%s',patientNamesToPlot{pp});
            ttluse{2,1} = sprintf('%s',ttlsforpaper{c});
            title(ttluse);
            xlabel('Frequency (Hz)');
            ylabel('Normalized power (a.u.)');
            
        end
        
        if plotDistance
            hold on;
            hs = scatter(d(:,1),d(:,2),10,'filled','MarkerFaceColor',[0 0 0.8],'MarkerFaceAlpha',0.2);
            axis equal;
            mind = min(d(:));
            maxd = max(d(:));
            x = linspace(mind,maxd,100);
            y = linspace(mind,maxd,100);
            plot(x,y,'LineWidth',2,'Color',[0.5 0.5 0.5 0.3]);
            xlabel('distance to in clinic off');
            ylabel('distance to in clinic on');
        end 
        lablesout(:,c) = labels;
    end
    % save labels 
    if includesleep
        fnsave = sprintf('template_clustering_results_10min_including_sleep_%s %s .mat',patientplot{pp},patientside{pp});
    else
        fnsave = sprintf('template_clustering_results_10min_not_including_sleep_%s %s .mat',patientplot{pp},patientside{pp});
    end
    fnsave = fullfile(resultsdir,fnsave);
%     save(fnsave,'labels','colors','lablesout');
end

hsubsb(1).XTick = [];
hsubsb(1).XLabel.String = '';
hsubsb(1).YLabel.String = 'Norm. power (a.u.)';

hsubsb(2).YLabel.String = 'Norm. power (a.u.)';
hsubsb(2).XLabel.String = 'Frequency (Hz)';

hsubsb(3).XTick = [];
hsubsb(3).XLabel.String = '';
hsubsb(3).YLabel.String = '';
hsubsb(3).YTick = [];

hsubsb(4).YTick = [];
hsubsb(4).YLabel.String = '';
hsubsb(4).XLabel.String = 'Frequency (Hz)';

if plotRaw
    figname = 'Fig6_panelB_template_matching_raw_data';
end
if plotState
    figname = 'Fig6_panelB_template_matching_shaded_errorbars';
end
if plotDistance
    figname = sprintf('templateMatching - distnace  %s %s',patDatHome.patient{pp},patDatHome.side{pp});
end
if plotpanels
    prfig.plotwidth           = 15;
    prfig.plotheight          = 10;
    prfig.figname             = figname;
    prfig.figdir              = figdirout;
    plot_hfig(hfig,prfig)
end
%%
end

plotthis = 0;
if plotthis
%% panel c - plot bar codes of patient state, template, clustering 
figdirout = '/Users/roee/Starr_Lab_Folder/Writing/papers/2019_LongTerm_RCS_recordings/figures/1_draft2/Fig6_unsupervised_methods';
figdirout = '/Users/roee/Box/rcs paper paper on first five bilateral implants/revision for nature biotechnology/figures/Fig6_unsupervised_methods';
resultsdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home';
patientplot = {'RCS02','RCS07'};
patientside = {'R','R'};
pkgside     = {'L','L'};
ttls = {'STN 0-2','STN 1-3','M1 8-10','M1 9-11'};
if plotpanels
    hfig = figure;
    hfig.Color = 'w';
end
nrows = 6; 
ncols = 1; 
cntplt = 1; 
hsub = gobjects(6,1);
trimtofit = 1; % trim data to be equal between patients 
plotlegends = 0;

for p = 1:length(patientplot)
    fnload = sprintf('coherence_and_psd %s %s pkg %s.mat',patientplot{p},patientside{p},pkgside{p});
    load(fullfile(resultsdir,fnload));
    fnload = sprintf('unsupervised_clustering_results_10min_not_including_sleep_%s_%s',patientplot{p},patientside{p});
    load(fullfile(resultsdir,fnload));
    fnload = sprintf('template_clustering_results_10min_not_including_sleep_%s %s .mat',patientplot{p},patientside{p});
    load(fullfile(resultsdir,fnload));
    
    % raw states
    if plotpanels
        hsub(cntplt) = subplot(nrows,ncols,cntplt); cntplt = cntplt + 1;
    else
        hsub(cntplt) = hpanel(2,cntplt,1).select(); cntplt = cntplt + 1;
    end
    hold on;
    if includesleep
        rawstates = allDataPkgRcsAcc.states;
    else
        rawstates = allDataPkgRcsAcc.states; 
        rawstates = rawstates(~strcmp(rawstates,'sleep'));
    end
    switch patientplot{p}
        case 'RCS02'
            onidx = cellfun(@(x) any(strfind(x,'dyskinesia severe')),rawstates);
            offidx = cellfun(@(x) any(strfind(x,'off')),rawstates) | ...
                cellfun(@(x) any(strfind(x,'on')),rawstates) | ...
                cellfun(@(x) any(strfind(x,'tremor')),rawstates);
            sleeidx = cellfun(@(x) any(strfind(x,'sleep')),rawstates);
        case 'RCS05'
            onidx = cellfun(@(x) any(strfind(x,'dyskinesia')),rawstates) | ...
                cellfun(@(x) any(strfind(x,'on')),rawstates);
            offidx = cellfun(@(x) any(strfind(x,'off')),rawstates) | ...
                cellfun(@(x) any(strfind(x,'tremor')),rawstates);
            sleeidx = cellfun(@(x) any(strfind(x,'sleep')),rawstates);
        case 'RCS06'
            onidx = cellfun(@(x) any(strfind(x,'dyskinesia')),rawstates) | ...
                cellfun(@(x) any(strfind(x,'on')),rawstates);
            offidx = cellfun(@(x) any(strfind(x,'off')),rawstates) | ...
                cellfun(@(x) any(strfind(x,'tremor')),rawstates);
            sleeidx = cellfun(@(x) any(strfind(x,'sleep')),rawstates);
        case 'RCS07'
            onidx = cellfun(@(x) any(strfind(x,'dyskinesia')),rawstates) | ...
                cellfun(@(x) any(strfind(x,'on')),rawstates);
            offidx = cellfun(@(x) any(strfind(x,'off')),rawstates) | ...
                cellfun(@(x) any(strfind(x,'tremor')),rawstates);
            sleeidx = cellfun(@(x) any(strfind(x,'sleep')),rawstates);
    end
    if includesleep
        otheridx =  ~(sleeidx | onidx | offidx);
    else
        otheridx =  ~(  onidx | offidx);
    end
    
    if trimtofit
        times = 1:720; 
        onidx = onidx(1:720); 
        offidx = offidx(1:720); 
        otheridx = otheridx(1:720); 
    else
        times = 1:length(rawstates);
    end
    
    hbron = bar(times(onidx),repmat(-0.2,1,sum(onidx)),'stacked');
    hbron.FaceColor = [0 0.8 0];
    hbron.FaceAlpha = 0.6;
    hbron.EdgeColor = 'none';
    hbron.BarWidth = 1;
    
    hbroff = bar(times(offidx),repmat(-0.2,1,sum(offidx)),'stacked');
    hbroff.FaceColor = [0.8 0 0];
    hbroff.FaceAlpha = 0.6;
    hbroff.EdgeColor = 'none';
    hbroff.BarWidth = 1;
    
    if includesleep
        hbrsleep = bar(times(sleeidx),repmat(-0.2,1,sum(sleeidx)),'stacked');
        hbrsleep.FaceColor = [0 0 0.8];
        hbrsleep.FaceAlpha = 0.6;
        hbrsleep.EdgeColor = 'none';
        hbrsleep.BarWidth = 1;
    end
    
    hbrother = bar(times(otheridx),repmat(-0.2,1,sum(otheridx)),'stacked');
    hbrother.FaceColor = [0.5 0.5 0.5];
    hbrother.FaceAlpha = 0.6;
    hbrother.EdgeColor = 'none';
    hbrother.BarWidth = 1;
    
    if includesleep
        if plotlegends
            legend([ hbron hbroff hbrsleep hbrother],{'on','off','sleep','other'});
        end
    else
        if plotlegends
            legend([ hbron hbroff hbrother],{'on','off','other'},'Location','northeast');
        end
    end
    ttluse = sprintf('%s state classification by wearable monitor',patientplot{p});
    ttluse = sprintf('state classification by wearable monitor');
    title(ttluse);
    hsub(cntplt-1).YTick = [];
    hsub(cntplt-1).YTickLabel = '';
    hsub(cntplt-1).XTick = [];
    hsub(cntplt-1).XTickLabel = '';

    
    % unsupervised clustering

    if plotpanels
        hsub(cntplt) = subplot(nrows,ncols,cntplt); cntplt = cntplt + 1;
    else
        hsub(cntplt) = hpanel(2,cntplt,1).select(); cntplt = cntplt + 1;
    end

    switch patientplot{p}
        case 'RCS02'
            colorsUse = [1.000000000000000   0.792156862745098                   0; ...
                0.443137254901961                   0   0.623529411764706 ];

        case 'RCS07'
            colorsUse = [  0.443137254901961                   0   0.623529411764706; ...
                1.000000000000000   0.792156862745098                   0];
    end

    hold on;
    uc = unique(cl);
    if trimtofit
        cl = cl(1:720);
    end
    hbrother = gobjects(2,1); 
    for u = 1:length(uc)
        hbrother(u,1) = bar(times(uc(u)==cl),repmat(-0.2,1,sum(uc(u)==cl)),'stacked');
        hbrother(u,1).FaceColor = colorsUse(u,:);
        hbrother(u,1).FaceAlpha = 0.6;
        hbrother(u,1).EdgeColor = 'none';
        hbrother(u,1).BarWidth = 1;
    end
    if plotlegends
        legend([ hbrother],{'cluster 1', 'cluster 2'},'Location','northeast');
    end
    ttluse = sprintf('%s density based clustering',patientplot{p});
    ttluse = sprintf('density based clustering');
    title(ttluse);
    hsub(cntplt-1).YTick = [];
    hsub(cntplt-1).YTickLabel = '';
    hsub(cntplt-1).XTick = [];
    hsub(cntplt-1).XTickLabel = '';


    % template

    if plotpanels
        hsub(cntplt) = subplot(nrows,ncols,cntplt); cntplt = cntplt + 1;
    else
        hsub(cntplt) = hpanel(2,cntplt,1).select(); cntplt = cntplt + 1;
    end
    hold on;
    val = [0 1];
    labels = lablesout(:,2); % use stn 
    if trimtofit
        labels = labels(1:720);
    end
    
    colors(1,:) = [0   0.815686274509804   0.803921568627451];
    colors(2,:) = [1.000000000000000   0.341176470588235                   0];

    hbrother = gobjects(2,1); 
    for s = 1:2
        hbrother(s,1) = bar(times(labels==val(s)),repmat(-0.2,1,sum( labels==val(s) )),'stacked');
        hbrother(s,1).FaceColor = colors(s,:);
        hbrother(s,1).FaceAlpha = 0.6;
        hbrother(s,1).EdgeColor = 'none';
        hbrother(s,1).BarWidth = 1;
    end
    if plotlegends
        legend([ hbrother],{'cluster 1', 'cluster 2'},'Location','northeast');
    end
    ttluse = sprintf('%s template based clustering',patientplot{p});
    ttluse = sprintf('template based clustering');
    title(ttluse);
    if (cntplt-1) == 6
        hsub(cntplt-1).XTick = [90:90:720];
        hsub(cntplt-1).XTickLabel = {'3', '6' ,'9' ,'12' ,'15' ,'18', '21' ,'24'};
        xlabel('hours'); 
    else
        hsub(cntplt-1).XTick = [];
        hsub(cntplt-1).XTickLabel = '';
    end
    hsub(cntplt-1).YTick = [];
    hsub(cntplt-1).YTickLabel = '';
    
    % compute concordance 
    
    % state labels 
    statelabels = zeros(size(onidx,1),1);
    statelabels(onidx) = 1;
    statelabels(offidx) = 2;
    exclude = statelabels == 0; 
    statecheck = statelabels(~exclude); 
    % unsupervised 
    unsuperisedlabels = cl(~exclude); 
    val = sum(statecheck == unsuperisedlabels)/ length(statecheck);
    fprintf('unsupervised %.2f %.2f\n',val, 1-val);
    % tempalte 
    templatelab = zeros(size(labels,1),1);
    templatelab(labels==0) = 1; 
    templatelab(labels==1) = 2; 
    templatelabuse = templatelab(~exclude);
    val = sum(statecheck == templatelabuse')/ length(templatelabuse);
    fprintf('template %.2f %.2f\n',val, 1-val);

    
    
end
if plotpanels
    prfig.plotwidth           = 15;
    prfig.plotheight          = 6;
    prfig.figname             = 'Fig6_panelC_compare_classification_methods_barcodes';
    prfig.figdir              = figdirout;
    plot_hfig(hfig,prfig)
end
%% 
end
%% plot all 
hpanel.fontsize = 10; 
hpanel.de.margin = 10;
hpanel(1).margin = 20;
hpanel(2).de.margin = 6;
hpanel.margin = [20 20 20 20];
prfig.plotwidth           = 8;
prfig.plotheight          = 8;
prfig.figdir             = figdirout;
prfig.figname             = 'Fig6_all_panelA';
prfig.figtype             = '-djpeg';
plot_hfig(hfig,prfig)
%%
return 

end


function [cl,halo] = do_clustering(datcluster)
% do clustering
% get distance matrix
D = pdist(datcluster,'euclidean');
distmat = squareform(D);
distMatrices = squareform(distmat,'tovector');
% get row indices
rows = repmat(1:size(distmat,1),size(distmat,2),1)';
idx = logical(eye(size(rows)));
rows(idx) = 0;
rowsColmn = squareform(rows,'tovector');
% get column idices
colmns = repmat(1:size(distmat,1),size(distmat,2),1);
idx = logical(eye(size(colmns)));
colmns(idx) = 0;
colsColmn = squareform(colmns,'tovector');
% save data for rodriges
distanceMat = [];
distanceMat(:,1) = rowsColmn;
distanceMat(:,2) = colsColmn;
distanceMat(:,3) = distMatrices;
% do cluster
[cl,halo] =  cluster_dp(distanceMat,'results');
end



%{
% previous figure 5 plots:
%% panel A - AUC with all areas
fignum = 5;
figdirout = '/Users/roee/Starr_Lab_Folder/Writing/papers/2019_LongTerm_RCS_recordings/figures';
% original function:
% plot_pkg_data_all_subjects

rootdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home/pkg_rcs_by_minute_average_results';
rootdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home/pkg_rcs_by_minute_average_smaller_times_results';
ff = findFilesBVQX(rootdir,'*.mat');
addpath(fullfile(pwd,'toolboxes','notBoxPlot','code'));
cnt = 1;
for f = 1:length(ff)
    load(ff{f},'freqs','patientTable','titles','cnls','readme');
    unqgaps =  unique(patientTable.minuteGap);
    freqsuse = freqs;
    clear freqs
    
    for u = 1:length(unqgaps)
        idxuse = patientTable.minuteGap==unqgaps(u);
        pdb = patientTable(idxuse,:);
        AUC = cell2mat(pdb.AUC);
        for c = 1:length(cnls)
            patientROC_at_home(cnt).patient = patientTable.patient(idxuse);
            patientROC_at_home(cnt).patientRCSside = patientTable.patientRCSside (idxuse);
            patientROC_at_home(cnt).patientPKGside = patientTable.patientPKGside(idxuse);
            patientROC_at_home(cnt).freq = freqsuse(c);
            patientROC_at_home(cnt).channel = titles(cnls(c)+1);
            patientROC_at_home(cnt).minuteGap = unqgaps(u);
            channeraw = patientROC_at_home(cnt).channel;
            if c <= 4
                freqstr = 'beta';
            else
                freqstr = 'gamma';
            end
            
            if any(strfind(channeraw{1},'STN'))
                areause = 'STN';
            else
                areause = 'M1';
            end
            patientROC_at_home(cnt).channelabel = [areause ' ' freqstr];
            patientROC_at_home(cnt).AUC = AUC(c);
            cnt = cnt + 1;
        end
        patientROC_at_home(cnt).patient = patientTable.patient(idxuse);
        patientROC_at_home(cnt).patientRCSside = patientTable.patientRCSside (idxuse);
        patientROC_at_home(cnt).patientPKGside = patientTable.patientPKGside(idxuse);
        patientROC_at_home(cnt).freq = NaN;
        patientROC_at_home(cnt).channel = 'all areas';
        patientROC_at_home(cnt).minuteGap = unqgaps(u);
        patientROC_at_home(cnt).channelabel = 'all areas';
        patientROC_at_home(cnt).AUC = AUC(c+1);
        cnt = cnt + 1;
    end
end
patientROC_at_home =  struct2table(patientROC_at_home);

idx10mingap  = patientROC_at_home.minuteGap==10;
patientROC_at_home_10min = patientROC_at_home(idx10mingap,:);
idxuse = strcmp(patientROC_at_home_10min.channelabel,'STN beta') | ...
    strcmp(patientROC_at_home_10min.channelabel,'M1 gamma') | ...
    strcmp(patientROC_at_home_10min.channelabel,'all areas') ;
patientROC_at_home_10min = patientROC_at_home_10min(idxuse,:);
xvals = zeros(size(patientROC_at_home_10min,1),1);
xvals( strcmp(patientROC_at_home_10min.channelabel,'STN beta') ) = 1;
xvals( strcmp(patientROC_at_home_10min.channelabel,'M1 gamma') ) = 2;
xvals( strcmp(patientROC_at_home_10min.channelabel,'all areas') ) = 3;


hfig = figure;
hfig.Color = 'w';
hsb = subplot(1,1,1);
nbp = notBoxPlot([patientROC_at_home_10min.AUC],xvals);
hsb.XTickLabel = {'STN Beta','M1 Gamma','All areas'};
ylabel('AUC');
ylim([0.4 1.1]);
title('M1 & STN best for decoding (4 patients, 8 ''sides'') [peak freqs]');
set(gca,'FontSize',12);

prfig.plotwidth           = 6;
prfig.plotheight          = 4;
prfig.figdir             = figdirout;
prfig.figname             = sprintf('Fig%d_panelA',fignum);
prfig.figtype             = '-dpdf';
plot_hfig(hfig,prfig)
close(hfig);
%%
%%

%% panel b - bar graph of segment lenght vs AUC
% plot segement lenght vs AUC
uniquepatient = unique(patientROC_at_home.patient);
for f = 1:length(ff)
    load(ff{f},'freqs','patientTable','titles','cnls','readme');
    AUC = cell2mat(patientTable.AUC);
    outdat(f).stnbeta = AUC(:,1:2);
    outdat(f).m1gama = AUC(:,7:8);
    outdat(f).allareas = AUC(:,9);
    outdat(f).mingaps = patientTable.minuteGap;
    outdat(f).patient = patientTable.patient{1};
    outdat(f).patientside = patientTable.patientRCSside{1};
end
patROCbymin = struct2table(outdat);
uniquepatient = unique(patROCbymin.patient);
hfig = figure;
hfig.Color = 'w';
for p = 1:length(uniquepatient)
    subplot(2,2,p);
    hold on;
    idxpat = cellfun(@(x) strcmp(x, uniquepatient{p}),   patROCbymin.patient );
    patdata = patROCbymin(idxpat,:);
    hplt = [];
    for i = 1:size(patdata,1)
        hplt(1,:) = plot(patdata.mingaps{i},patdata.stnbeta{i},'LineWidth',1,'Color',[0 0 0.8 0.5]);
        hplt(2,:) = plot(patdata.mingaps{i},patdata.m1gama{i},'LineWidth',1,'Color',[0.8 0 0 0.5]);
        hplt(3,:) = plot(patdata.mingaps{i},patdata.allareas{i},'LineWidth',2,'Color',[0 0.8 0 0.5]);
    end
    xlabel('average factor (minutes)');
    ylabel('AUC');
    title(uniquepatient{p});
    legend([hplt(1,1),hplt(2,1),hplt(3,1)],{'stn beta','m1 gamma','all areas'});
    set(gca,'FontSize',16);
end

prfig.plotwidth           = 12;
prfig.plotheight          = 8;
prfig.figdir             = figdirout;
prfig.figname             = sprintf('Fig%d_panelB_v2',fignum);
prfig.figtype             = '-dpdf';
plot_hfig(hfig,prfig)
close(hfig);
%%

%% panel c - unsupervised clustering with one patient, includign sleep

%%
%}