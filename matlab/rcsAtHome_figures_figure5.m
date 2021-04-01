function rcsAtHome_figures_figure5()
%% Grouped separation data
% this figure shows the group seperation data 
%% 
% panel a bar graph of total hours awake / alseep
% panel b - PSD and coherence at home - average state estimate across subjects (median average)
% panel c - AUC for all subjects -

addpath(genpath(fullfile(pwd,'toolboxes','panel-2.14')));
%%
    hfig = figure;
    hfig.Color = 'w';
    hpanel = panel();
    hpanel.pack(1,2);
    hpanel(1,2).pack('v',{1/3 1/3 1/3});
    hpanel(1,1).pack('v',{1/3 2/3}); 
    hpanel.select('all');
    hpanel.identify();
% p(1,1).repack(0.3);
%%

close all;
plotpanels = 0;
if ~plotpanels
    %%
    hfig = figure;
    hfig.Color = 'w';
    hpanel = panel();
    hpanel.pack(1,2);
    hpanel(1,2).pack('v',{1/3 1/3 1/3});
    hpanel(1,1).pack('v',{1/3 2/3}); 
%     hpanel.select('all');
%     hpanel.identify();
    %%
end
% plot panel a in the first column, 3 subplots 
% plot panel b and c in the seceond column 2 subplots 
%% panel a bar graph of total hours awake / alseep 
fignum = 5; 
figdirout = '/Users/roee/Starr_Lab_Folder/Writing/papers/2019_LongTerm_RCS_recordings/figures/final_figures/Fig5_states_estimates_group_data_and_ AUC';
figdirout = '/Users/roee/Box/rcs paper paper on first five bilateral implants/revision for nature biotechnology/figures/Fig5_states_estimates_group_data_and_ AUC';
% origina funciton used: plot_pkg_data_all_subjects
resultsdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home/synced_rcs_pkg_data_saved';
resultsdir = '/Users/roee/Box/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home/synced_rcs_pkg_data_saved';
resultsdir = '/Users/roee/Box/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home/synced_rcs_pkg_data_saved';
ff = findFilesBVQX(resultsdir,'RCS*.mat'); 
tbl = table();
for f = 1:length(ff) 
    load(ff{f});
    [pn,fn] = fileparts(ff{f});
    tbl.patient{f} = fn(1:5);
    tbl.rcs_side{f} = fn(7);
    tbl.pkg_side{f} = fn(end);
    idxsleep = strcmp(allDataPkgRcsAcc.states,'sleep');
    idxnotsleep = ~strcmp(allDataPkgRcsAcc.states,'sleep');
    tbl.sleep_hours(f) = (sum(idxsleep)*2)/60; 
    tbl.wake_hours(f) = (sum(idxnotsleep)*2)/60; 
end
uniquePatients = unique(tbl.patient); 
recTime = [];
for p = 1:length(uniquePatients)
    idxuse = strcmp(tbl.patient,uniquePatients{p});
    recTime(p,1) = sum(tbl.wake_hours(idxuse));
    recTime(p,2) = sum(tbl.sleep_hours(idxuse));
end
fprintf('wake time mean %.2f max %.2f  %.2f\n',mean(recTime(:,1)),max(recTime(:,1)),min(recTime(:,1)));
fprintf('sleep time mean %.2f max %.2f  %.2f\n',mean(recTime(:,2)),max(recTime(:,2)),min(recTime(:,2)));
if plotpanels
    cntplt = 1;
    hfig = figure;
    hfig.Color = 'w'; 
    hsb = subplot(1,1,1);
    hsb(cntplt) = hsb; 
else
    hpanel(1,1,1).select();
    hsb = gca();
    hold(hsb,'on');
end

hbar = bar(recTime);
altPatientNames = {'RCS01';'RCS02';'RCS03';'RCS04';'RCS05'};
hsb.XTickLabel = altPatientNames;
hsb.YLabel.String = 'Hours recoreded'; 
hsb.Title.String = 'Hours recorded at home / patient'; 
hleg = legend({'awake','alseep'},'Location','northwest');
hleg.Box = 'off'; 
% save fig 
if plotpanels
    savefig(hfig,fullfile(figdirout,sprintf('Fig%d_panelA_hours_recorded_at_home',fignum)));
    prfig.plotwidth           = 2.16;
    prfig.plotheight          = 4.37;
    prfig.figdir             = figdirout;
    prfig.figname             = sprintf('Fig%d_panelA_hours_recorded_at_home',fignum);
    prfig.figtype             = '-dpdf';
    plot_hfig(hfig,prfig)
    close(hfig);
end
%% 

%% panel b - PSD and coherence at home - average state estimate across subjects (median average) 
addpath(genpath(fullfile('toolboxes','GEEQBOX')));
addpath(genpath(fullfile(pwd,'toolboxes','shadedErrorBar')))
fignum = 5; 
figdirout = '/Users/roee/Starr_Lab_Folder/Writing/papers/2019_LongTerm_RCS_recordings/figures/1_draft2/Fig5_states_estimates_group_data_and_ AUC';
figdirout = '/Users/roee/Starr_Lab_Folder/Writing/papers/2019_LongTerm_RCS_recordings/figures/final_figures/Fig5_states_estimates_group_data_and_ AUC';
figdirout = '/Users/roee/Box/rcs paper paper on first five bilateral implants/revision for nature biotechnology/figures/Fig5_states_estimates_group_data_and_ AUC';

% original function:
% plot_pkg_data_all_subjects

load('/Users/roee/Box/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home/coherence_and_psd/patientPSD_at_home.mat');
load('/Users/roee/Box/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home/coherence_and_psd/patientCOH_at_home.mat');
if plotpanels
    hfig = figure;
    hfig.Color = 'w';
end
pdb = patientPSD_at_home;
datadir = '/Users/roee/Box/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home/coherence_and_psd/';


sides = {'L','R'};
uniquePatients = {'RCS02','RCS06','RCS05','RCS07','RCS08'};
cntOut = 1;
for p = 1:length(uniquePatients) % loop on patients
    for s = 1:2 % loop on side
        
        filenamesearch = sprintf('coherence_and_psd %s %s *.mat',uniquePatients{p},sides{s});
        ff = findFilesBVQX(datadir,filenamesearch);
        load(ff{1});
        rawstates = allDataPkgRcsAcc.states';
        switch uniquePatients{p}
            case 'RCS02'
                % R
                cnls  =  [0  1  2  3  0  1  2  3  ];
                freqs =  [19 19 24 25 75 75 76 76];
                ttls  = {'STN beta','STN beta','M1 beta','M1 beta','STN gamma','STN gamma','M1 gamma','M1 gamma'};
                onidx = cellfun(@(x) any(strfind(x,'dyskinesia severe')),rawstates);
                offidx = cellfun(@(x) any(strfind(x,'off')),rawstates) | ...
                    cellfun(@(x) any(strfind(x,'on')),rawstates) | ...
                    cellfun(@(x) any(strfind(x,'tremor')),rawstates);
                sleeidx = cellfun(@(x) any(strfind(x,'sleep')),rawstates);
                allstates = rawstates;
                allstates(onidx) = {'on'};
                allstates(offidx) = {'off'};
                allstates(sleeidx) = {'sleep'};
                statesUse = {'off','on'};
            case 'RCS05'
                cnls  =  [0  1  2  3  0  1  2  3  ];
                freqs =  [27 27 27 27 61 61 61 61];
                ttls  = {'STN beta','STN beta','M1 beta','M1 beta','STN gamma','STN gamma','M1 gamma','M1 gamma'};
                onidx = cellfun(@(x) any(strfind(x,'dyskinesia')),rawstates) | ...
                    cellfun(@(x) any(strfind(x,'on')),rawstates);
                offidx = cellfun(@(x) any(strfind(x,'off')),rawstates) | ...
                    cellfun(@(x) any(strfind(x,'tremor')),rawstates);
                sleeidx = cellfun(@(x) any(strfind(x,'sleep')),rawstates);
                allstates = rawstates;
                allstates(onidx) = {'on'};
                allstates(offidx) = {'off'};
                allstates(sleeidx) = {'sleep'};
                statesUse = {'off','on'};
                
            case 'RCS06'
                cnls  =  [0  1  2  3  0  1  2  3  ];
                freqs =  [19 19 14 26 55 55 61 61];
                ttls  = {'STN beta','STN beta','M1 beta','M1 beta','STN gamma','STN gamma','M1 gamma','M1 gamma'};
                onidx = cellfun(@(x) any(strfind(x,'dyskinesia')),rawstates) | ...
                    cellfun(@(x) any(strfind(x,'on')),rawstates);
                offidx = cellfun(@(x) any(strfind(x,'off')),rawstates) | ...
                    cellfun(@(x) any(strfind(x,'tremor')),rawstates);
                sleeidx = cellfun(@(x) any(strfind(x,'sleep')),rawstates);
                allstates = rawstates;
                allstates(onidx) = {'on'};
                allstates(offidx) = {'off'};
                allstates(sleeidx) = {'sleep'};
                statesUse = {'off','on'};
                
            case 'RCS07'
                cnls  =  [0  1  2  3  0  1  2  3  ];
                freqs =  [19 20 21 24 76 79 80 80];
                ttls  = {'STN beta','STN beta','M1 beta','M1 beta','STN gamma','STN gamma','M1 gamma','M1 gamma'};
                onidx = cellfun(@(x) any(strfind(x,'dyskinesia')),rawstates) | ...
                    cellfun(@(x) any(strfind(x,'on')),rawstates);
                offidx = cellfun(@(x) any(strfind(x,'off')),rawstates) | ...
                    cellfun(@(x) any(strfind(x,'tremor')),rawstates);
                sleeidx = cellfun(@(x) any(strfind(x,'sleep')),rawstates);
                allstates = rawstates;
                allstates(onidx) = {'on'};
                allstates(offidx) = {'off'};
                allstates(sleeidx) = {'sleep'};
                statesUse = {'off','on'};
                
            case 'RCS08'
                cnls  =  [0  1  2  3  0  1  2  3  ];
                freqs =  [27 23 26 26 43 84 84 84];
                ttls  = {'STN beta','STN beta','M1 beta','M1 beta','STN gamma','STN gamma','M1 gamma','M1 gamma'};
                onidx = cellfun(@(x) any(strfind(x,'dyskinesia')),rawstates) | ...
                    cellfun(@(x) any(strfind(x,'on')),rawstates);
                offidx = cellfun(@(x) any(strfind(x,'off')),rawstates) | ...
                    cellfun(@(x) any(strfind(x,'tremor')),rawstates);
                sleeidx = cellfun(@(x) any(strfind(x,'sleep')),rawstates);
                allstates = rawstates;
                allstates(onidx) = {'on'};
                allstates(offidx) = {'off'};
                allstates(sleeidx) = {'sleep'};
                statesUse = {'off','on'};
        end

        % psd 
        titles = {'STN 0-2','STN 1-3','M1 8-10','M1 9-11'};
        labelsCheck = [];
        for c = 1:4
            statesUsing = {};cntstt = 1;
            for ss = 1:length(statesUse)
                fn = sprintf('key%dfftOut',c-1);
                labels = strcmp(allstates,statesUse{ss});
                labelsCheck(:,ss) = labels;

                % save the mean data
                
                rawdat = allDataPkgRcsAcc.(fn);
                rawdat = rawdat(labels,:);
                fftLogged = mean(rawdat,1);
                patientPSD_at_home.patient{cntOut} = uniquePatients{p};
                patientPSD_at_home.side{cntOut} = sides{s};
                patientPSD_at_home.cnls{cntOut} = cnls;
                patientPSD_at_home.freqs{cntOut} = freqs;
                patientPSD_at_home.ttls{cntOut} = ttls;
                
                patientPSD_at_home.medstate{cntOut} = statesUse{ss};
                patientPSD_at_home.electrode{cntOut} = titles{c};
                patientPSD_at_home.ff{cntOut} = psdResults.ff;
                patientPSD_at_home.fftOut{cntOut} = fftLogged;
                patientPSD_at_home.srate(cntOut) = 250;
                idxnorm = psdResults.ff >=5 & psdResults.ff <=90;
                fftLogged(idxnorm) = fftLogged(idxnorm)./abs((mean(fftLogged(idxnorm))));
                patientPSD_at_home.fftOutNorm{cntOut} = fftLogged;

                cntOut = cntOut + 1;
            end
        end
        % coherence 
        fieldNamesCoherence = {'stn02m10810','stn02m10911','stn13m10810','stn13m0911'};
        titles_coh = {'coh_stn02m10810','coh_stn02m10911','coh_stn13m10810','coh_stn13m0911'};
        labelsCheck = [];
        for c = 1:4
            statesUsing = {};cntstt = 1;
            for ss = 1:length(statesUse)
                fn = sprintf('%s',fieldNamesCoherence{c});
                labels = strcmp(allstates,statesUse{ss});
                labelsCheck(:,ss) = labels;

                % save the mean data
                
                rawdat = allDataPkgRcsAcc.(fn);
                rawdat = rawdat(labels,:);
                ms_coherence = mean(rawdat,1);
                patientPSD_at_home.patient{cntOut} = uniquePatients{p};
                patientPSD_at_home.side{cntOut} = sides{s};
                patientPSD_at_home.medstate{cntOut} = statesUse{ss};
                patientPSD_at_home.electrode{cntOut} = titles_coh{c};
                patientPSD_at_home.ff_coh{cntOut} = patientCOH_at_home.ff{1};
                patientPSD_at_home.ms_coherence{cntOut} = ms_coherence;
                cntOut = cntOut + 1;
            end
        end
    end
end
pdb = patientPSD_at_home ;


% %%%%%%%%%%%%%%%%%%%%%%%%% do stats 
% %%%%%%%%%%%%%%%%%%%%%%%%% do stats 
% %%%%%%%%%%%%%%%%%%%%%%%%% do stats 
areas = {'STN','M1'};
for a = 1:length(areas)
    idxstn = cellfun(@(x) any(strfind(x,areas{a})),pdb.electrode);
    pdbSTN = pdb(idxstn,:);
    
    % groups:
    
    % id = subject id
    % percent  = beta level averaged between 13-30
    % month - categorical med on/off
    % X - matrix of conditions incdluing (numerical):
    %  1. med state (on/off)
    %  2. side (L/R)
    %  3. montage (0-2 / 1-3)
    uniquePatients = unique(pdbSTN.patient);
    id = zeros(size(pdbSTN,1),1);
    for p = 1:length(uniquePatients)
        for i = 1:size(pdbSTN,1)
            id( strcmp(pdbSTN.patient,uniquePatients{p}) ) = p;
        end
    end
    montage = zeros(size(pdbSTN,1),1);
    unqeMontage = unique(pdbSTN.electrode);
    montage( strcmp(pdbSTN.electrode,unqeMontage{1}) ) = 1;
    montage( strcmp(pdbSTN.electrode,unqeMontage{2}) ) = 2;
    
    medstate = zeros(size(pdbSTN,1),1);
    medstate( strcmp(pdbSTN.medstate,'on') ) = 1;
    medstate( strcmp(pdbSTN.medstate,'off') ) = 2;
    
    side = zeros(size(pdbSTN,1),1);
    side( strcmp(pdbSTN.side,'L') ) = 1;
    side( strcmp(pdbSTN.side,'R') ) = 2;
    
    usefreqranges = 0;
    if usefreqranges
        freqranges = [1 4;     4 8;     8 13;    13 20;   20 30;       30 50;     50 90];
        freqnames  = {'Delta', 'Theta', 'Alpha','LowBeta','HighBeta','LowGamma','HighGamma'}';
        
        ff = pdbSTN.ff{1};
        fftnorm = cell2mat(pdbSTN.fftOutNorm);
        pvals = [];
        for sf = 1:size(freqranges,1)
            idxfreqs = ff >= freqranges(sf,1) & ff <= freqranges(sf,2);
            meanfreqs = mean(fftnorm(:,idxfreqs),2);
            const = ones(size(meanfreqs,1),1);
            X = [medstate, montage, side, const];
            varnames ={'med state','montage','side','const'};
            [betahat, alphahat, results] = gee(id, meanfreqs, medstate, X, 'n', 'equi', varnames);
            pvals(sf) = results.model{3,5};
        end
        siglog = logical(pvals<=0.05./size(freqranges,1));
        freqnames(siglog);
    end
    
    % do states for each frequency
    pvals = [];
    for f = 1:length(pdbSTN.fftOutNorm{1})
        meanfreq = [] ;
        for i = 1:size(pdbSTN,1)
            meanfreq(i,1) = pdbSTN.fftOutNorm{i}(f);
        end
        const = ones(size(meanfreq,1),1);
        X = [medstate, montage, side, const];
        varnames ={'med state','montage','side','const'};
        [betahat, alphahat, results] = gee(id, meanfreq, medstate, X, 'n', 'equi', varnames);
        pvals(f) = results.model{3,5};
    end
    siglog = logical(pvals<=0.05./length(pdbSTN.fftOutNorm{1}));
    ff = pdbSTN.ff{i};
    ff(siglog);
    siglogout(:,a) = siglog;
end
% %%%%%%%%%%%%%%%%%%%%%%%%% do stats 
% %%%%%%%%%%%%%%%%%%%%%%%%% do stats 
% %%%%%%%%%%%%%%%%%%%%%%%%% do stats 

areas = {'STN','M1'}; 
medstate = {'on','off'}; 
colorsUse = [0 0.8 0; 0.8 0 0];

nrows = 3; 
ncols = 1; 
cntplt = 1; 
for a = 1:length(areas)
    if plotpanels
        hsb(cntplt) = subplot(nrows,ncols,cntplt);hold on;
        cntplt = cntplt + 1;
    else
        hpanel(1,2,cntplt).select();
        hold on;
        cntplt = cntplt + 1;
        hsb = gca();
    end
    for m = 1:length(medstate)
        set(gca,'XLim',[5.1 89])
        
        idxkeep = (pdb.srate == 250) & ...
            cellfun(@(x) any(strfind(x,areas{a})),pdb.electrode) & ...
            strcmp(pdb.medstate,medstate{m});
        psds = cell2mat(pdb.fftOutNorm(idxkeep));
        ff = pdb.ff(idxkeep);
        ff = ff{1};
        % plot(ff,psds,'LineWidth',1,'Color',[0 0.8 0 0.3]);
%         hsbH = shadedErrorBar(ff,psds,{@mean,@(x) std(x)*1});
        y = psds;
        x = ff;
        hsbH = shadedErrorBar(x,y,{@median,@(yy) std(yy)./sqrt(size(yy,1))});
        hsbH.mainLine.Color = colorsUse(m,:); 
        hsbH.mainLine.LineWidth = 1;
        hsbH.edge(1).Color = [1 1 1]; 
        hsbH.edge(2).Color = [1 1 1]; 
        hsbH.patch.FaceAlpha = 0.1;
        hsbH.patch.FaceColor = colorsUse(m,:); 
        hLine(m) = hsbH.mainLine;
    end
    % plot significance 
    ylims = get(gca,'YLim');
    freqsig = ff(siglogout(:,a));
    
    xfreqssig = [];
    D = diff([0,siglogout(:,a)',0]);
    b.beg = find(D == 1);
    b.end = find(D == -1) - 1;
    xfreqssig(:,1) = ff(b.beg);
    xfreqssig(:,2) = ff(b.end);
    if ~isempty(xfreqssig)
        plot(xfreqssig,[ylims(2) ylims(2)],'Color',[0.5 0.5 0.5],'LineWidth',2);
    end

    ylabel('Norm. power  (a.u.)');
    title(areas{a},'FontSize',16);
    set(gca,'FontSize',12); 
    set(gca,'XTick',[]);
    if a == 1 
    legend(hLine,{'PKG estimate - on','PKG estimate - off'});
    end
end

% plot coherence 
pdbRaw = pdb;
if plotpanels
    hsb(cntplt) = subplot(nrows,ncols,cntplt);hold on;
    cntplt = cntplt + 1;
else
    hpanel(1,1,cntplt).select();
    hold on;
    cntplt = cntplt + 1;
    hsb = gca();
end
for m = 1:length(medstate)
    idxkeep = cellfun(@(x) any(strfind(x,'coh')),pdbRaw.electrode) & ...
              strcmp(medstate{m},pdbRaw.medstate);
    pdb = pdbRaw(idxkeep,:);

        
    cohs = cell2mat(pdb.ms_coherence);
    ff = pdb.ff_coh(1);
    ff = ff{1}; 
    errs = []; 
    meancoh = mean(cohs);   
    % using standard deviation 
%     errs(:,1) = mean(cohs) + std(cohs);
%     errs(:,2) = mean(cohs) - std(cohs);
    % using standard error 
    errs(:,1) = mean(cohs) + (std(cohs)./sqrt(size(cohs,1)));
    errs(:,2) = mean(cohs) - (std(cohs)./sqrt(size(cohs,1)));
    
    errs = errs';

    yy = cohs;
    hsbH = shadedErrorBar(ff,cohs,{@median,@(yy) std(yy)./sqrt(size(yy,1))});
    hsbH.mainLine.Color = colorsUse(m,:);
    hsbH.mainLine.LineWidth = 1;
    hsbH.edge(1).Color = [1 1 1];
    hsbH.edge(2).Color = [1 1 1];
    hsbH.patch.FaceAlpha = 0.1;
    hsbH.patch.FaceColor = colorsUse(m,:);
    hLine(m) = hsbH.mainLine;
    xlabel('Frequency (Hz)');
    ylabel('MS Coherence');
    set(gca,'FontSize',12);
    set(gca,'XLim',[5.1 89])
end
% %%%%%%%%%%%%%%%%%%%%%%%%% do stats 
% %%%%%%%%%%%%%%%%%%%%%%%%% do stats 
% %%%%%%%%%%%%%%%%%%%%%%%%% do stats 
pdbSTN = pdb;

% groups:

% id = subject id
% percent  = beta level averaged between 13-30
% month - categorical med on/off
% X - matrix of conditions incdluing (numerical):
%  1. med state (on/off)
%  2. side (L/R)
%  3. montage (0-2 / 1-3)
uniquePatients = unique(pdbSTN.patient);
id = zeros(size(pdbSTN.patient,2),1);
for p = 1:length(uniquePatients)
    for i = 1:size(pdbSTN.patient,2)
        id( strcmp(pdbSTN.patient',uniquePatients{p}) ) = p;
    end
end
montage = zeros(size(pdbSTN.patient,2),1);
unqeMontage = unique(pdbSTN.electrode);
montage( strcmp(pdbSTN.electrode,unqeMontage{1}) ) = 1;
montage( strcmp(pdbSTN.electrode,unqeMontage{2}) ) = 2;
montage( strcmp(pdbSTN.electrode,unqeMontage{3}) ) = 3;
montage( strcmp(pdbSTN.electrode,unqeMontage{4}) ) = 4;

medstate = zeros(size(pdbSTN.patient,2),1);
medstate( strcmp(pdbSTN.medstate,'on') ) = 1;
medstate( strcmp(pdbSTN.medstate,'off') ) = 2;

side = zeros(size(pdbSTN.patient,2),1);
side( strcmp(pdbSTN.side,'L') ) = 1;
side( strcmp(pdbSTN.side,'R') ) = 2;

% do states for each frequency
pvals = [];
for f = 1:length(pdbSTN.ff_coh{1})
    meanfreq = [] ;
    for i = 1:size(pdbSTN.patient,1)
        meanfreq(i,1) = pdbSTN.ms_coherence{i}(f);
    end
    const = ones(size(meanfreq,1),1);
    X = [medstate', montage', side', const];
    varnames ={'med state','montage','side','const'};
    [betahat, alphahat, results] = gee(id, meanfreq, medstate, X, 'n', 'equi', varnames);
    pvals(f) = results.model{3,5};
end
siglog = logical(pvals<=  (0.05./ length(pdbSTN.ff_coh{1})) );
ff = pdbSTN.ff_coh{i};
ff(siglog);
xfreqssig = [];
D = diff([0,siglogout(:,a)',0]);
b.beg = find(D == 1);
b.end = find(D == -1) - 1;
xfreqssig(:,1) = ff(b.beg);
xfreqssig(:,2) = ff(b.end);
idxeql = xfreqssig(:,1)==xfreqssig(:,2); % add 1 to equal idx so shows up in line plot 
xfreqssig(idxeql,2) = xfreqssig(idxeql,2) + 1; 
ylims = get(gca,'YLim');
if ~isempty(xfreqssig)
    plot(xfreqssig',[ylims(2) ylims(2)],'Color',[0.5 0.5 0.5],'LineWidth',2);
end

% %%%%%%%%%%%%%%%%%%%%%%%%% do stats 
% %%%%%%%%%%%%%%%%%%%%%%%%% do stats 
% %%%%%%%%%%%%%%%%%%%%%%%%% do stats 
if plotpanels
    hsb(cntplt-1).YLim(1) = 0;
else
    hsb.YLim(1) = 0;
end
% legend(hLine,{'PKG estimate - on','PKG estimate - off'});
title('STN-M1 coherence'); 

if plotpanels
    % save fig
    savefig(hfig,fullfile(figdirout,sprintf('Fig%d_panelB_psd_coh_group',fignum)));
    for i=1:length(hfig.Children)
        if strcmp(hfig.Children(i).Type,'axes')
            hfig.Children(i).FontSize = 6;
        end
    end
    
    prfig.plotwidth           = 2.16;
    prfig.plotheight          = 4.37;
    prfig.figdir             = figdirout;
    prfig.figname             = sprintf('Fig%d_panelB_psd_coh_group',fignum);
    prfig.figtype             = '-dpdf';
    plot_hfig(hfig,prfig)
    close(hfig);
end
%% 

%% plot C - stn beta centered psd 
datadir = '/Users/roee/Box/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home/coherence_and_psd';
fnsave = fullfile(datadir,'coherence_and_psd_summary_all_patients.mat');
load(fnsave,'outputTable');

plotShaded = 1;
hsb = hpanel(1,1,2).select();
freqUse = {'beta','gamma'};
freqUse = {'beta'};
areas = {'STN','M1'};
areas = {'STN'};
medstates = {'off','on'};
for f = 1:length(freqUse)
    for a = 1:length(areas)
        hold(hsb,'on');
        for m = 1:length(medstates)
            idxFreq = strcmp(outputTable.freqUse ,freqUse{f});
            idxAreas= strcmp(outputTable.area ,areas{a});
            idxMed  = strcmp(outputTable.medstate ,medstates{m});
            idxUse = idxFreq & idxAreas & idxMed; 
            tbPlt = outputTable(idxUse,:);
            data = tbPlt.psdData{1}; 
            freqLen = size(data,2);
            xrow = 1-ceil(freqLen/2):1:floor(freqLen/2);
            x = xrow; 
            y = data; 
            if strcmp(medstates{m},'off')
                colorUse = [0.8 0 0.2];
            elseif strcmp(medstates{m},'on')
                colorUse = [0 0.8 0.2];
            end
            if plotShaded
                hshadedError = shadedErrorBar(x,y,{@median,@(y) std(y)./sqrt(size(y,1))});
        
                hshadedError.mainLine.Color = colorUse;
                hshadedError.mainLine.LineWidth = 2;
                hshadedError.patch.FaceColor = colorUse;
                hshadedError.patch.MarkerEdgeColor = [ 1 1 1];
                hshadedError.edge(1).Color = [colorUse 0.1];
                hshadedError.edge(2).Color = [colorUse 0.1];
                hshadedError.patch.FaceAlpha = 0.1;
                hplt(m) = hshadedError.mainLine;
            else
                hplt = plot(x,y);
                for hh = 1:length(hplt)
                    hplt(hh).Color = [colorUse 0.4];
                end
                hplt(m) = hplt(hh);
            end
            titleUse = sprintf('%s %s',areas{a},freqUse{f});
            title(titleUse); 
            ylabel('Power (log_1_0\muV^2/Hz)');
            xlabel('centered frequency (Hz)'); 
%             plot(xrow,data);
        end
        legend(hplt,{'off - PKG estimate','on - PKG estimate'});
    end
end
%% plot panel
figdirout = '/Users/roee/Box/rcs paper paper on first five bilateral implants/revision for nature biotechnology/figures/Fig5_states_estimates_group_data_and_ AUC';

hpanel.fontsize = 10;
hpanel.de.margin = 20;
hpanel.marginbottom = 15;
hpanel.marginright = 15;
hpanel.margintop = 15;
hpanel.marginleft = 15;
prfig.plotwidth           = 8;
prfig.plotheight          = 7;
prfig.figdir              = figdirout;
prfig.figname             = 'Fig5_v1_pkg_and_hours_recorded_partial';
prfig.figtype             = '-dpdf';
plot_hfig(hfig,prfig)
%%

return;



%% panel s1 - all raw PSD data showcasing sleep - for all patients 
close all force;clear all;clc;
fignum = 4; % NA - it's a supplementary figure 
addpath(genpath(fullfile(pwd,'toolboxes','plot_reducer')));
figdirout = '/Users/roee/Starr_Lab_Folder/Writing/papers/2019_LongTerm_RCS_recordings/figures/1_draft2/Figs1_raw_data_across_subs';
figdirout = '/Users/roee/Box/rcs paper paper on first five bilateral implants/revision for nature biotechnology/figures/Figs1_raw_data_across_subs';
titles = {'STN 0-2','STN 1-3','M1 8-10','M1 9-11'};
labelsCheck = [];
combineareas = 1;
rootdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home/'; 
addpath(genpath(fullfile(pwd,'toolboxes','panel-2.14')));


hfig = figure;
hfig.Color = 'w';
hfig.Position = [1000         194        1387        1144];
hpanel = panel();
hpanel.pack(5,3); 
hsb = gobjects(5,3);

ff = findFilesBVQX(rootdir,'coherence_and_psd*.mat');
cntplt = 1; 
nrows  = 4;
ncols =  3; 
datuse = {};

linewidths = [0.2 0.6 0.03 0.03 0.2];
areatitls = {'STN','motor cortex'};
for f = 1:length(ff)
    [pn,fn,ext] = fileparts(ff{f}); 
    patients{f} = fn(19:23);     
end
uniquePatients = unique(patients); 
patientsNameToUse = {'RCS01','RCS02','RCS03','RCS04','RCS05'};
for p = 1:length(uniquePatients)
    fpts = ff(strcmp(uniquePatients{p},patients));
    stndata = [];
    m1_data = [];
    coh_dat = [];
    msr = 1; 
    for fp = 1:length(fpts)
        load(fpts{fp});
        if p == 4 & fp == 1 
            stndata = [stndata; allDataPkgRcsAcc.key1fftOut];
        else
            stndata = [stndata; allDataPkgRcsAcc.key0fftOut ; allDataPkgRcsAcc.key1fftOut];
        end
        m1_data = [m1_data; allDataPkgRcsAcc.key2fftOut ; allDataPkgRcsAcc.key3fftOut];
        if p == 4 & fp == 1 
            coh_dat = [
                allDataPkgRcsAcc.stn13m0911;
                allDataPkgRcsAcc.stn13m10810];
        else
            coh_dat = [coh_dat; allDataPkgRcsAcc.stn02m10810;
                allDataPkgRcsAcc.stn02m10911;
                allDataPkgRcsAcc.stn13m0911;
                allDataPkgRcsAcc.stn13m10810];
        end
    end
    areas = {'STN','M1'};
    dat = [];
    for a = 1:2
        hsb(p,msr) = hpanel(p,msr).select(); msr = msr + 1; 
        hold on;
        if a == 1 
            dat = stndata;
        else
            dat = m1_data;
        end
        if strcmp(uniquePatients{p},'RCS08')
            idxnormalize = allDataPkgRcsAcc.ffPSD > 3 &  allDataPkgRcsAcc.ffPSD <90;
            frequency = allDataPkgRcsAcc.ffPSD';
        else
            idxnormalize = psdResults.ff > 3 &  psdResults.ff <90;
            frequency = psdResults.ff';
        end
        meandat = abs(mean(dat(:,idxnormalize),2)); % mean within range, by row
        % the absolute is to make sure 1/f curve is not flipped
        % since PSD values are negative
        meanmat = repmat(meandat,1,size(dat,2));
        dat = dat./meanmat;
        r = ceil(size(dat,1) .* rand(720,1))
        r = 1:5:size(dat,1);
        normalizedPSD = dat(r,:);
        idxsleep = strcmp(allDataPkgRcsAcc.states,'sleep');
        % idxsleep = allDataPkgRcsAcc.bkVals <= -110;
        lw = linewidths(p);
                reduce_plot(frequency', normalizedPSD,'LineWidth',lw,'Color',[0 0 0.8 0.05]);% was 0.7 for rcs02 and 0.5 alpha
        xlim([3 100]);
        if p == 4
            xlabel('Frequency (Hz)');
        else
            hsb(p,msr-1).XTick = [];
        end
        if (msr-1) == 1
            ylabel('Norm. power (a.u.)');
        end
        ylims = hsb(p,msr-1).YLim;
        ttluse = {};
        ttluse{1,1} = sprintf('%s',patientsNameToUse{p});
        ttluse{1,2} = sprintf('%s',areatitls{a});
        title(ttluse);
        %         plot([4 4],ylims,'LineWidth',3,'LineStyle','-.','Color',[0.2 0.2 0.2 0.1]);
        plot([13 13],ylims,'LineWidth',2,'LineStyle','-.','Color',[0.2 0.2 0.2 0.1]);
        plot([30 30],ylims,'LineWidth',2,'LineStyle','-.','Color',[0.2 0.2 0.2 0.1]);
        set(gca,'FontSize',10);

    end

    % plot coherence
    hsb(p,msr) = hpanel(p,msr).select(); msr = msr + 1;
    hold on;
    r = ceil(size(coh_dat,1) .* rand(720,1))
    r = 1:5:size(coh_dat,1);
    if strcmp(uniquePatients{p},'RCS08')
        freqsCoh = allDataPkgRcsAcc.ffCoh;
    else
        freqsCoh = cohResults.ff'
    end
    reduce_plot(freqsCoh, coh_dat(r,:),'LineWidth',lw,'Color',[0 0 0.8 0.05]);
    ylims = hsb(p,msr-1).YLim;
%     plot([4 4],ylims,'LineWidth',3,'LineStyle','-.','Color',[0.2 0.2 0.2 0.1]);
    plot([13 13],ylims,'LineWidth',2,'LineStyle','-.','Color',[0.2 0.2 0.2 0.1]);
    plot([30 30],ylims,'LineWidth',2,'LineStyle','-.','Color',[0.2 0.2 0.2 0.1]);
    if p == 4 
        xlabel('Frequency (Hz)');
    else
        hsb(p,msr-1).XTick = [];
    end 
    ylabel('MS coherence');
    ttluse = {};
    ttluse{1,1} = sprintf('%s',patientsNameToUse{p});
    ttluse{1,2} = 'stn-motor cortex coherence';
    title(ttluse);
    xlim([0 100]);
    set(gca,'FontSize',10);
    clear allDataPkgRcsAcc m1_data coh_dat stndata psdResults cohResults
end

hpanel.fontsize = 12; 
hpanel.margintop = 15;
hpanel.de.margin = 10; 
axs = hfig.Children; 
for a = 1:length(axs)
    axs(a).Children(1).YData = axs(a).YLim; 
    axs(a).Children(2).YData = axs(a).YLim; 
end

prfig.plotwidth           = 8;
prfig.plotheight          = 8;
prfig.figdir             = figdirout;
prfig.figtype             = '-djpeg';
prfig.figname             = sprintf('FigS1_raw_psd_data_p4_v4');
plot_hfig(hfig,prfig)
%%

foundfigs = findFilesBVQX( figdirout,'*.fig');
hfig = openfig(foundfigs{1});
hfignew = figure; 
hfignew.Color = 'w'; 
hsb = subplot(6,2,p.p(1,:));
posuse = hsb.Position; 
% delete(hsb); 
copyobj(hfig.Children, hfignew);
hfignew.Children(2).Position = posuse; 



end