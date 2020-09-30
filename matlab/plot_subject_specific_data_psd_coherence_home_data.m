function plot_subject_specific_data_psd_coherence_home_data()
addpath(genpath(fullfile('toolboxes','GEEQBOX')));
addpath(genpath(fullfile(pwd,'toolboxes','shadedErrorBar')))
fignum = 5; 
figdirout = '/Users/roee/Starr_Lab_Folder/Writing/papers/2019_LongTerm_RCS_recordings/figures/1_draft2/Fig5_states_estimates_group_data_and_ AUC';
figdirout = '/Users/roee/Starr_Lab_Folder/Writing/papers/2019_LongTerm_RCS_recordings/figures/final_figures/Fig5_states_estimates_group_data_and_ AUC';
figdirout = '/Users/roee/Box/rcs paper paper on first five bilateral implants/revision for nature biotechnology/figures/Fig5_states_estimates_group_data_and_ AUC';
figdirout = '/Users/roee/Box/rcs paper paper on first five bilateral implants/revision for nature biotechnology/figures/Fig5_states_estimates_group_data_and_ AUC';

plotpanels = 1;
% original function:
% plot_pkg_data_all_subjects

load('/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home/patientPSD_at_home.mat');
load('/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home/patientCOH_at_home.mat');
if plotpanels
    hfig = figure;
    hfig.Color = 'w';
end
pdb = patientPSD_at_home;
datadir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home';


sides = {'L','R'};
uniquePatients = {'RCS02','RCS06','RCS05','RCS07','RCS08'};
cntOut = 1;
tremorAnalysis = 0; 
sleepAnalysis = 1; 
strUse = 'sleep_vs_off_vs_on';
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
                allstates = rawstates; % make syre all states is "raw slate". 
                for aaa = 1:length(allstates)
                    allstates{aaa} = 'NA';
                end
                if tremorAnalysis
                    offidx = allDataPkgRcsAcc.tremorScore>10;
                    statesUse = {'off','on','sleep'};
                    allstates(offidx) = {'off'};
                    allstates(onidx) = {'on'};
                    allstates(sleeidx) = {'sleep'};
                    statesUse = {'off','on','sleep'};
                    
%                     idxNotSleep = ~strcmp(allstates,'sleep');
%                     allstates(idxNotSleep) = {'not sleep'};
                    statesUse = {'not sleep','sleep'};
                    statesUse = {'off','on','sleep'};

                    strUse = 'tremor_analysis';
                    strUse = 'sleep_vs_off_vs_on';
                elseif sleepAnalysis                    
                    statesUse = {'off','on','sleep'};
                    allstates(offidx) = {'off'};
                    allstates(onidx) = {'on'};
                    allstates(sleeidx) = {'sleep'};
                    strUse = 'sleep_vs_off_vs_on';
                else
                    allstates(onidx) = {'on'};
                    allstates(offidx) = {'off'};
                    allstates(sleeidx) = {'sleep'};
                    statesUse = {'off','on'};
                end
            case 'RCS05'
                cnls  =  [0  1  2  3  0  1  2  3  ];
                freqs =  [27 27 27 27 61 61 61 61];
                ttls  = {'STN beta','STN beta','M1 beta','M1 beta','STN gamma','STN gamma','M1 gamma','M1 gamma'};
                onidx = cellfun(@(x) any(strfind(x,'dyskinesia')),rawstates) | ...
                    cellfun(@(x) any(strfind(x,'on')),rawstates);
                offidx = cellfun(@(x) any(strfind(x,'off')),rawstates) | ...
                    cellfun(@(x) any(strfind(x,'tremor')),rawstates);
                sleeidx = cellfun(@(x) any(strfind(x,'sleep')),rawstates);
                allstates = rawstates; % make syre all states is "raw slate". 
                for aaa = 1:length(allstates)
                    allstates{aaa} = 'NA';
                end
                if tremorAnalysis
                    offidx = allDataPkgRcsAcc.tremorScore>10;
                    statesUse = {'off','sleep'};
                    allstates(offidx) = {'off'};
                    allstates(sleeidx) = {'sleep'};
                    
                    idxNotSleep = ~strcmp(allstates,'sleep');
                    allstates(idxNotSleep) = {'not sleep'};
                    statesUse = {'not sleep','sleep'};

                    strUse = 'tremor_analysis';
                    strUse = 'sleep_vs_not';
                elseif sleepAnalysis
                    statesUse = {'off','on','sleep'};
                    allstates(offidx) = {'off'};
                    allstates(onidx) = {'on'};
                    allstates(sleeidx) = {'sleep'};
                    strUse = 'sleep_vs_off_vs_on';
                else
                    allstates(onidx) = {'on'};
                    allstates(offidx) = {'off'};
                    allstates(sleeidx) = {'sleep'};
                    statesUse = {'off','on'};
                    
                end
                
            case 'RCS06'
                cnls  =  [0  1  2  3  0  1  2  3  ];
                freqs =  [19 19 14 26 55 55 61 61];
                ttls  = {'STN beta','STN beta','M1 beta','M1 beta','STN gamma','STN gamma','M1 gamma','M1 gamma'};
                onidx = cellfun(@(x) any(strfind(x,'on')),rawstates);
                offidx = cellfun(@(x) any(strfind(x,'off')),rawstates) | ...
                    cellfun(@(x) any(strfind(x,'dyskinesia')),rawstates) | ...
                    cellfun(@(x) any(strfind(x,'tremor')),rawstates);
                sleeidx = cellfun(@(x) any(strfind(x,'sleep')),rawstates);
                allstates = rawstates; % make syre all states is "raw slate". 
                for aaa = 1:length(allstates)
                    allstates{aaa} = 'NA';
                end
                if tremorAnalysis
                    offidx = allDataPkgRcsAcc.tremorScore>10;
                    statesUse = {'off','sleep'};
                    allstates(offidx) = {'off'};
                    allstates(sleeidx) = {'sleep'};
                    
                    idxNotSleep = ~strcmp(allstates,'sleep');
                    allstates(idxNotSleep) = {'not sleep'};
                    statesUse = {'not sleep','sleep'};

                    strUse = 'tremor_analysis';
                    strUse = 'sleep_vs_not';
                elseif sleepAnalysis
                    statesUse = {'off','on','sleep'};
                    allstates(offidx) = {'off'};
                    allstates(onidx) = {'on'};
                    allstates(sleeidx) = {'sleep'};
                    strUse = 'sleep_vs_off_vs_on';
                else
                    allstates(onidx) = {'on'};
                    allstates(offidx) = {'off'};
                    allstates(sleeidx) = {'sleep'};
                    statesUse = {'off','on'};
                end
                
            case 'RCS07'
                cnls  =  [0  1  2  3  0  1  2  3  ];
                freqs =  [19 20 21 24 76 79 80 80];
                ttls  = {'STN beta','STN beta','M1 beta','M1 beta','STN gamma','STN gamma','M1 gamma','M1 gamma'};
                onidx = cellfun(@(x) any(strfind(x,'dyskinesia')),rawstates) | ...
                    cellfun(@(x) any(strfind(x,'on')),rawstates);
                offidx = cellfun(@(x) any(strfind(x,'off')),rawstates) | ...
                    cellfun(@(x) any(strfind(x,'tremor')),rawstates);
                sleeidx = cellfun(@(x) any(strfind(x,'sleep')),rawstates);
                allstates = rawstates; % make syre all states is "raw slate". 
                for aaa = 1:length(allstates)
                    allstates{aaa} = 'NA';
                end
                if tremorAnalysis
                    offidx = allDataPkgRcsAcc.tremorScore>10;
                    statesUse = {'off','sleep'};
                    allstates(offidx) = {'off'};
                    allstates(sleeidx) = {'sleep'};
                    
                    idxNotSleep = ~strcmp(allstates,'sleep');
                    allstates(idxNotSleep) = {'not sleep'};
                    statesUse = {'not sleep','sleep'};

                    strUse = 'tremor_analysis';
                    strUse = 'sleep_vs_not';
                elseif sleepAnalysis
                    statesUse = {'off','on','sleep'};
                    allstates(offidx) = {'off'};
                    allstates(onidx) = {'on'};
                    allstates(sleeidx) = {'sleep'};
                    strUse = 'sleep_vs_off_vs_on';
                else
                    allstates(onidx) = {'on'};
                    allstates(offidx) = {'off'};
                    allstates(sleeidx) = {'sleep'};
                    statesUse = {'off','on'};
                end
                
            case 'RCS08'
                cnls  =  [0  1  2  3  0  1  2  3  ];
                freqs =  [27 23 26 26 43 84 84 84];
                ttls  = {'STN beta','STN beta','M1 beta','M1 beta','STN gamma','STN gamma','M1 gamma','M1 gamma'};
                onidx = cellfun(@(x) any(strfind(x,'dyskinesia')),rawstates) | ...
                    cellfun(@(x) any(strfind(x,'on')),rawstates);
                offidx = cellfun(@(x) any(strfind(x,'off')),rawstates) | ...
                    cellfun(@(x) any(strfind(x,'tremor')),rawstates);
                sleeidx = cellfun(@(x) any(strfind(x,'sleep')),rawstates);
                allstates = rawstates; % make syre all states is "raw slate". 
                for aaa = 1:length(allstates)
                    allstates{aaa} = 'NA';
                end
                if tremorAnalysis
                    offidx = allDataPkgRcsAcc.tremorScore>10;
                    statesUse = {'off','sleep'};
                    allstates(offidx) = {'off'};
                    allstates(sleeidx) = {'sleep'};
                    
                    idxNotSleep = ~strcmp(allstates,'sleep');
                    allstates(idxNotSleep) = {'not sleep'};
                    statesUse = {'not sleep','sleep'};

                    strUse = 'tremor_analysis';
                    strUse = 'sleep_vs_not';
                elseif sleepAnalysis
                    statesUse = {'off','on','sleep'};
                    allstates(offidx) = {'off'};
                    allstates(onidx) = {'on'};
                    allstates(sleeidx) = {'sleep'};
                    strUse = 'sleep_vs_off_vs_on';
                else
                    allstates(onidx) = {'on'};
                    allstates(offidx) = {'off'};
                    allstates(sleeidx) = {'sleep'};
                    statesUse = {'off','on'};
                end
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
                patientPSD_at_home.fftOutRawData{cntOut} = rawdat;
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
                patientPSD_at_home.ms_coherence_RawData{cntOut} = rawdat;
                patientPSD_at_home.cnls{cntOut} = cnls;
                patientPSD_at_home.freqs{cntOut} = freqs;
                patientPSD_at_home.ttls{cntOut} = ttls;

                cntOut = cntOut + 1;
            end
        end
    end
end
rootdir = '/Users/roee/Box/rcs paper paper on first five bilateral implants/revision for nature biotechnology/figures/Figs3_Rcs07_example_clinic_vs_home';
fnmsv = fullfile(rootdir,'at_home_psds_all_subjects.mat');
save(fnmsv,'patientPSD_at_home');
%% psds 
rootdir = '/Users/roee/Box/rcs paper paper on first five bilateral implants/revision for nature biotechnology/figures/Figs3_Rcs07_example_clinic_vs_home';
fnmsv = fullfile(rootdir,'at_home_psds_all_subjects.mat');
load(fnmsv,'patientPSD_at_home');

close all; 
addpath(genpath(fullfile(pwd,'toolboxes','panel-2.14')));
pdb = patientPSD_at_home ;
freqUse = {'beta','gamma'};
window  = 10; % hz from each side 
areas = {'STN','M1'};
medstates = {'off','on','sleep'};
cntbl = 1; 
unqPatients = unique(patientPSD_at_home.patient); 
areaStr = {'STN','M1','coh'};
plotShaded = 1;
cntPvalRes = 1; 
tblPvalResults = table();
for pp = 1:length(unqPatients)
    idxPatient = strcmp(patientPSD_at_home.patient,unqPatients{pp});
    patientTable = patientPSD_at_home(idxPatient,:);
    % only use some of the states 
    % XXX 
    idxUseStates = strcmp(patientTable.medstate,'off') | strcmp(patientTable.medstate,'on') | strcmp(patientTable.medstate,'sleep');
    strUse = 'off_vs_on_vs_sleep_sig';
    % XXX 
    patientTable = patientTable(idxUseStates,:);
    freqsCheckSignificance = 3:100; 
    numberMultipleComparisons = length(freqsCheckSignificance) * size(patientTable,1);
    effectivePValue = 0.05/numberMultipleComparisons; % this is Bonforoni correction - may neeed to do FDR... 
    hfig = figure;
    hfig.Color = 'w';
    p = panel();
    p.pack(4,4);
    hsbs = gobjects(4,4);
        
    for a = 1:length(areaStr) 
        idxArea = cellfun(@(x) any(strfind(x,areaStr{a})),patientTable.electrode);
        cntPltColumn = 1; 
        tableArea = patientTable(idxArea,:);
        uniqueElectrodes = unique(tableArea.electrode);
        uniqueSides      = unique(tableArea.side);
        aUse = a;
        for e = 1:length(uniqueElectrodes)
            for s = 1:length(uniqueSides)
                idxSides = strcmp(tableArea.electrode,uniqueElectrodes{e}) & ... 
                    strcmp(tableArea.side,uniqueSides{s}); 
                tablePlot = tableArea(idxSides,:);
                if cntPltColumn == 5 & a == 3
                    cntPltColumn = 1;
                    aUse = a +1;
                end
                hsb = p(aUse,cntPltColumn).select();
                hsbs(aUse,cntPltColumn) = hsb;
                hold(hsb,'on');

                cntPltColumn = cntPltColumn + 1;
                
                    
                
                for tt = 1:size(tablePlot,1)
                    if strcmp(areaStr{a},'coh')
                        x = tablePlot.ff_coh{tt};
                        y = tablePlot.ms_coherence_RawData{tt};
                    else
                        x = tablePlot.ff{tt};
                        y = tablePlot.fftOutRawData{tt};
                    end
                    if strcmp(tablePlot.medstate{tt},'off')
                        colorUse = [0.8 0 0.2];
                    elseif strcmp(tablePlot.medstate{tt},'on')
                        colorUse = [0 0.8 0.2];
                    elseif strcmp(tablePlot.medstate{tt},'sleep')
                        colorUse = [0 0 0.2];
                    elseif strcmp(tablePlot.medstate{tt},'not sleep')
                        colorUse = [0.8 0 0.2];
                        
                    end
                    if plotShaded
                        hshadedError = shadedErrorBar(x,y,{@median,@(y) std(y)./sqrt(size(y,1))});
                        
                        hshadedError.mainLine.Color = colorUse;
                        hshadedError.mainLine.LineWidth = 2;
                        hshadedError.patch.FaceColor = colorUse;
                        hshadedError.patch.MarkerEdgeColor = [ 1 1 1];
                        hshadedError.edge(1).Color = [colorUse 0.1];
                        hshadedError.edge(2).Color = [colorUse 0.1];
                        hshadedError.patch.FaceAlpha = 0;
                        hplt(tt) = hshadedError.mainLine;
                    else
                        hplt = plot(x,y);
                        for hh = 1:length(hplt)
                            hplt(hh).Color = [colorUse 0.4];
                        end
                    end
                    ttlsuse = sprintf('%s %s %s',tablePlot.patient{tt}, strrep( tablePlot.electrode{tt},'_', ' '),tablePlot.side{tt});
                    if any(strfind(tablePlot.electrode{tt},'coh'))
                        if any(strfind(tablePlot.electrode{tt},'stn02')) & any(strfind(tablePlot.electrode{tt},'m10810'))
                            tablePlot.electrode{tt} = 'COH STN 0-2 <-> MC 8-10';
                        end
                        if any(strfind(tablePlot.electrode{tt},'stn02')) & any(strfind(tablePlot.electrode{tt},'m10911'))
                            tablePlot.electrode{tt} = 'COH STN 0-2 <-> MC 9-11';
                        end
                        if any(strfind(tablePlot.electrode{tt},'stn13')) & any(strfind(tablePlot.electrode{tt},'m10810'))
                            tablePlot.electrode{tt} = 'COH STN 1-3 <-> MC 8-10';
                        end
                        if any(strfind(tablePlot.electrode{tt},'stn13')) & any(strfind(tablePlot.electrode{tt},'0911'))
                            tablePlot.electrode{tt} = 'COH STN 1-3 <-> MC 9-11';
                        end
                        ttlsuse = sprintf('%s %s', strrep( tablePlot.electrode{tt},'_', ' '),tablePlot.side{tt});

                    elseif any(strfind(tablePlot.electrode{tt},'M1'))
                        tablePlot.electrode{tt}(2) = 'C';
                        ttlsuse = sprintf('%s %s', strrep( tablePlot.electrode{tt},'_', ' '),tablePlot.side{tt});
                    else
                        
                        ttlsuse = sprintf('%s %s', strrep( tablePlot.electrode{tt},'_', ' '),tablePlot.side{tt});
                    end
                    title(ttlsuse);
                    xlim([3 100]);
                    grid on; 
                    hsb.XTick = [12 30 60 90 ];
                    yout{tt} = y; 
                end
                % get rid of some tick values
                if (cntPltColumn-1) ~= 1
                    for ll = 1:length(hsb.XTickLabel)
                        hsb.YTickLabel{ll} = '';
                    end
                elseif aUse <=2
                    ylabel('Power (log_1_0\muV^2/Hz)');
                else
                    ylabel('ms coherence');
                end
                if aUse ~= 4
                    for ll = 1:length(hsb.XTickLabel)
                        hsb.XTickLabel{ll} = '';
                    end
                else
                    xlabel('Frequency (Hz)');
                end
                

                % plot significance if comparing all frequecney bands using
                % rank sum tests 
                [h,pvals ] = ttest2(yout{1},yout{2});
                [h,pvals ] = ranksum(yout{1}(:,1),yout{2}(:,1));
                pvals = [];
                for ppp = 1:length(x)
                    [pvals(ppp),h ] = ranksum(yout{1}(:,ppp),yout{2}(:,ppp));
                end
                sigValues = pvals <= effectivePValue;
                
                Xsig = x(sigValues);
                ylims = hsb.YLim;
%                 scatter(Xsig,repmat(ylims(2),length(Xsig),1),'filled','MarkerFaceColor',[0.5 0.5 0.5],'MarkerFaceAlpha',0.5);
                % 
                freqsCheck = {'alpha','beta','gamma'}; 
                freqsNums  = [6 15; 12 30; 70 90];
                NumberMultipleComparisons = size(patientTable,1)/2 * length(freqsCheck);
                for fq = 1:length(freqsCheck)
                    tblPvalResults.patient{cntPvalRes}    = tablePlot.patient{1};
                    tblPvalResults.side{cntPvalRes} = tablePlot.side{1};
                    tblPvalResults.electrode{cntPvalRes} = tablePlot.electrode{1};
                    tblPvalResults.freqName{cntPvalRes}  = freqsCheck{fq};

                    
                    idxfreqs = x >= freqsNums(fq,1) & x <freqsNums(fq,2);
                    [pval,h ] = ranksum(mean(yout{1}(:,idxfreqs),2),...
                                              mean(yout{2}(:,idxfreqs),2));
                    [h,pvalTtest] = ttest2(mean(yout{1}(:,idxfreqs),2),...
                                              mean(yout{2}(:,idxfreqs),2));
                    youtFreqsBins{1} = yout{1}(:,idxfreqs);
                    youtFreqsBins{2} = yout{2}(:,idxfreqs);
                    
                    % compute the peaks
                    y = [youtFreqsBins{1} ; youtFreqsBins{2}];
                    % plot the max 10%
                    maxYs = max(y,[],2);
                    [~,idxplot] = maxk(maxYs,ceil(0.1*size(y,1)) );
                    yPlot = y(idxplot,:);
                    
                    dataFindPeaks = mean(yPlot',2);
                    pks = []; locs = [];
                    [pks,locs] = findpeaks(dataFindPeaks,'MinPeakDistance',length(dataFindPeaks)-2,'MinPeakProminence',range(dataFindPeaks)*0.2);
                    % does it have a peak?
                    pval = 0.5;% default values 
                    pvalTtest = 0.5; % defaults values 
                    if ~isempty(pks)
                        tblPvalResults.peakExists(cntPvalRes)  = 1;
                        % redo test in freq specific manner 
                        freqsUseForPeaksAlgo = x(idxfreqs);
                        peakFreq             = freqsUseForPeaksAlgo(locs);
                        idxfreqsPeak = x <= (peakFreq+1.5) & x >= (peakFreq-1.5);
                        [pval,h ] = ranksum(mean(yout{1}(:,idxfreqsPeak),2),...
                            mean(yout{2}(:,idxfreqsPeak),2));
                        [h,pvalTtest] = ttest2(mean(yout{1}(:,idxfreqsPeak),2),...
                            mean(yout{2}(:,idxfreqsPeak),2));
                    else
                        tblPvalResults.peakExists(cntPvalRes)  = 0;
                    end
                    
                    tblPvalResults.rawData{cntPvalRes}  = youtFreqsBins;
                    tblPvalResults.freqRange(cntPvalRes,:)  = freqsNums(fq,:);
                    tblPvalResults.frqNumbersHz{cntPvalRes}  = x(idxfreqs);
                    tblPvalResults.rawPval_ManWitney(cntPvalRes)  = pval;
                    tblPvalResults.sigCorrected_ManWitney(cntPvalRes)  = pval <= (0.001/NumberMultipleComparisons);
                    tblPvalResults.rawPval_Ttest(cntPvalRes)  = pvalTtest;
                    tblPvalResults.sigCorrected_Ttest(cntPvalRes)  = pvalTtest <= (0.001/NumberMultipleComparisons);
                    tblPvalResults.p_value_001(cntPvalRes)  = 0.001/NumberMultipleComparisons;
                    tblPvalResults.p_value_05(cntPvalRes)  = 0.05/NumberMultipleComparisons;
                    if tblPvalResults.peakExists(cntPvalRes) &  tblPvalResults.sigCorrected_ManWitney(cntPvalRes)
                        scatter(tblPvalResults.frqNumbersHz{cntPvalRes}(locs),ylims(2),50,'filled','MarkerFaceColor',[0.5 0.5 0.5],'MarkerFaceAlpha',0.5)
                    end
                    
                    cntPvalRes = cntPvalRes + 1;
                end
            end
        end
    end
    % fix sig scatters 
    for iii = 1:4 
        for jjj = 1:4
            hscatters = findobj(hsbs(iii,jjj).Children,'Type','scatter');
            ylimval = hsbs(iii,jjj).YLim(2);
            for h = 1:length(hscatters)
                hscatters(h).YData = ylimval; 
            end
        end
    end
    
    figdirout = '/Users/roee/Box/rcs paper paper on first five bilateral implants/revision for nature biotechnology/figures/Figs4_single_subject_example';
    prfig.plotwidth           = 7.2;
    prfig.plotheight          = 7.2;
    prfig.figdir             = figdirout;
    prfig.figname             = sprintf('%s_%s_individ_psd_states_with_sig_man_witney',tablePlot.patient{tt},strUse);
    prfig.figtype             = '-dpdf';
    linkaxes(hsbs(1:2,:),'y');
    linkaxes(hsbs(3:4,:),'y');
    p.de.margin = 6;
    p.fontsize = 8;
    plot_hfig(hfig,prfig)
    close(hfig);
end
%% plot significance in particaular frequencey ranges 
hfig = figure; 
hfig.Color = 'w'; 
hsb = subplot(1,1,1); 
hold(hsb,'on'); 
areas = {'STN','M1','coh'};
cnt = 1; 
unqPatients = unique(tblPvalResults.patient); 
imagePlot = [];
for f = 1:length(freqsCheck)
    for a = 1:length(areas)
        for p = 1:length(unqPatients)
            unqIdxs = strcmp(freqsCheck{f},tblPvalResults.freqName) & ...
                strcmp(unqPatients{p},tblPvalResults.patient) & ...
                cellfun(@(x) any(strfind(x,areas{a})),tblPvalResults.electrode);
            tblUse = tblPvalResults(unqIdxs,:);
            if sum(tblUse.sigCorrected_Ttest & tblUse.peakExists)>=1
                clrUse = [0 0.8 0.2];
            else
                clrUse = [0.8 0 0.2];
            end
            x = p;
            y = cnt;
            scatter(x,cnt,60,'filled','MarkerFaceColor', clrUse);
            yLabels{cnt} =  sprintf('%s %s',areas{a},freqsCheck{f});
            idxPvals = tblUse.sigCorrected_Ttest & tblUse.peakExists;
            maxP     = max( -log10(tblUse.rawPval_ManWitney(idxPvals)));
%             maxP     = max( -log10(tblUse.rawPval_Ttest));
            if isempty(maxP)
                maxP = NaN;
            end
            imagePlot(x,cnt) = maxP;
        end
        cnt = cnt + 1;
    end
end

hsb.YTick     = 1:length(yLabels);
hsb.YTickLabel = yLabels;
hsb.XTick = 1:length(unqPatients);
hsb.XLim = [0 6];
hsb.YLim = [0 10];
hsb.XTickLabel = unqPatients;
title('significane in bands');
set(gca,'FontSize',16); 
fnmsv = fullfile(figdirout,'pValues_per_frequency.mat');
save(fnmsv,'tblPvalResults');
%% plot an image with empty colors 
close all;
hfig = figure; 
hfig.Color = 'w'; 
hsb = subplot(1,1,1); 


Data_Array = flipud(imagePlot);
imAlpha=ones(size(Data_Array));
imAlpha(isnan(Data_Array))=0;
imAlpha(isnan(Data_Array))=0;
imagesc(Data_Array,'AlphaData',imAlpha);
set(gca,'color',[1 1 1]);


hsb.YTick = 1:length(uniquePatients);
hsb.YTickLabel = fliplr(uniquePatients);
hsb.XTick = 1:length(yLabels);
hsb.XTickLabel = yLabels;
% hsb.XTickLabelRotation = 45;

hcolor = colorbar;
hcolor.Label.String = '-log10(p-value)';
title('max p-value / area / subject');
set(gca,'FontSize',16);
axis tight;

%%

%% make manhttan plots 
hfig = figure;
hfig.Color = 'w';
unocrrectedPval_5 = -log10(0.05);
correctedPval_5 = -log10(0.05/NumberMultipleComparisons);
correctedPval_1 = -log10(0.001/NumberMultipleComparisons);
unqPatients = unique(tblPvalResults.patient); 
for p = 1:length(unqPatients)
    hsb = subplot(length(unqPatients)+1,1,p); 
    hold(hsb,'on'); 
    unqIdxs = strcmp(unqPatients{p},tblPvalResults.patient);
    tblUse = tblPvalResults(unqIdxs,:);
    tblUse = sortrows(tblUse,{'freqName'});
    for t = 1:size(tblUse)
        switch tblUse.freqName{t}
            case 'alpha'
                clrUse = [0 0.8 0.2];
            case 'beta'
                clrUse = [0.8 0 0.2];
            case 'gamma'
                clrUse = [0 0.8 0.8];
        end
        pvalUse = -log10(tblUse.rawPval_ManWitney(t));
        if tblUse.peakExists(t)==0 %|| pvalUse <= correctedPval_1 
            clrUse = [1 1 1];
        end
        scatter(t,pvalUse,60,'filled','MarkerFaceColor', clrUse);
        xTickLabels{t} = strrep( sprintf('%s %s',tblUse.electrode{t},tblUse.freqName{t}),'_',' ');
    end
    if p == length(unqPatients)
        hsb.XTick = 1:length(xTickLabels);
        hsb.XTickLabel = xTickLabels;
        hsb.XTickLabelRotation = 60;
    end
    ylabel(unqPatients{p}); 
    xlims = hsb.XLim;
    plot(xlims,[correctedPval_5 correctedPval_5],'LineWidth',2,'LineStyle','-.','Color',[0.5 0.5 0.5 0.2]);
    plot(xlims,[correctedPval_1 correctedPval_1],'LineWidth',2,'LineStyle','-.','Color',[0.5 0.5 0.5 0.2]);
    plot(xlims,[unocrrectedPval_5 unocrrectedPval_5],'LineWidth',2,'LineStyle','-.','Color',[0.8 0.0 0.0 0.2]);
    set(gca,'FontSize',16); 
    hsbAx(p) = hsb; 
end
sgtitle('Manhattan plots of p-values','FontSize',24);
linkaxes(hsbAx,'x');


%%

%% determin if peaks exist in specific frequncey ranges 
close all; 
correctedPval_5 = -log10(0.05/NumberMultipleComparisons);
correctedPval_1 = -log10(0.001/NumberMultipleComparisons);
unqPatients = unique(tblPvalResults.patient);
for p = 1:length(unqPatients)
    unqIdxs = strcmp(unqPatients{p},tblPvalResults.patient);
    tblUse = tblPvalResults(unqIdxs,:);
    tblUse = sortrows(tblUse,{'freqName'});
    hfig = figure;
    hfig.Color = 'w';
    for t = 1:size(tblUse)
        hsb(t) = subplot(8,6,t);
        hold(hsb(t),'on'); 
        titleTable{t} = strrep( sprintf('%s %s',tblUse.electrode{t},tblUse.freqName{t}),'_',' ');
        y = [tblUse.rawData{t}{1} ; tblUse.rawData{t}{2}];
        % plot the max 10% 
        maxYs = max(y,[],2);
        [~,idxplot] = maxk(maxYs,ceil(0.1*size(y,1)) );
        yPlot = y(idxplot,:);
        xPlot = tblUse.frqNumbersHz{t};
        plot(xPlot,mean(yPlot',2),'LineWidth',1,'Color',[0 0 0.8 0.5]);
        dataFindPeaks = mean(yPlot',2);

        [pks,locs] = findpeaks(dataFindPeaks,'MinPeakDistance',length(dataFindPeaks)-2,'MinPeakProminence',range(dataFindPeaks)*0.2);
        if ~isempty(pks)
            scatter(xPlot(locs),pks,40,'filled','MarkerFaceColor',[0.0 0.8 0.2],'MarkerFaceAlpha',0.5);
        end
        
        title(titleTable{t});
        % does it have a peak? 
        meanY = mean(yPlot',2);
        edgesSmaller = (meanY(1) < max(meanY(2:end-1)))  &  (meanY(end) < max(meanY(2:end-1)));
        peakExists = (mean([meanY(1) meanY(end)]) * 1.5)  <  max(meanY(2:end-1));
        if ~isempty(pks)
            hsb(t).Color = [0.8 0.0 0.2 0.5];
        end
        
    end
    sgtitle(uniquePatients{p},'FontSize');
    set(gcf, 'InvertHardcopy', 'off')
    prfig.plotwidth           = 14;
    prfig.plotheight          = 9;
    prfig.figdir             = figdirout;
    prfig.figname             = sprintf('%s_individ_peaks',uniquePatients{p});
    prfig.figtype             = '-dpdf';
    plot_hfig(hfig,prfig)

end
%% 
return









%%
outputTable = table();
for f = 1:length(freqUse)
    for a = 1:length(areas)
        idxstn = cellfun(@(x) any(strfind(x,areas{a})),pdb.electrode);
        pdbArea = pdb(idxstn,:);
        for m = 1:length(medstates)
            cntArea = 1; % since combining motnages
            dataPeaksNorm = [];
            dataPeaks = [];
            idxMed = strcmp(pdbArea.medstate,medstates{m});
            pdbMed = pdbArea(idxMed,:);
            uniqContacts = unique(pdbMed.electrode);
            for u = 1:length(uniqContacts)
                idxContact = strcmp(pdbMed.electrode,uniqContacts{u});
                pdbContact = pdbMed(idxContact,:);
                for s = 1:size(pdbContact)
                    switch uniqContacts{u}
                        case 'STN 0-2'
                            cnl = 0;
                        case 'STN 1-3'
                            cnl = 1;
                        case 'M1 8-10'
                            cnl = 2;
                        case 'M1 9-11'
                            cnl = 3;
                    end
                    cnls = pdbContact.cnls{s};
                    ttls = pdbContact.ttls{s};
                    freqs = pdbContact.freqs{s};
                    idxchannel = cnls == cnl;
                    idxfreq    = cellfun(@(x) any(strfind(x,freqUse{f})),ttls);
                    freqUseHz   = freqs(idxchannel & idxfreq);
                    allFreqsUse(cntArea) = freqUseHz;
                    psdDataNorm = pdbContact.fftOutNorm{s};
                    psdData     = pdbContact.fftOut{s};
                    freqs   = pdbContact.ff{s};
                    idxdata = freqs >= (freqUseHz-window) & freqs <= (freqUseHz+window);
                    dataPeaksNorm(cntArea,:) = psdDataNorm(idxdata); 
                    dataPeaks(cntArea,:) = psdData(idxdata); 
                    cntArea = cntArea + 1;
                    
                end
            end
            % save the data in a table; 
            outputTable.medstate{cntbl} = medstates{m};
            outputTable.area{cntbl} = areas{a};
            outputTable.freqUse{cntbl} = freqUse{f};
            outputTable.psdDataNorm{cntbl} = dataPeaksNorm;
            outputTable.psdData{cntbl} = dataPeaks;
            outputTable.allFreqsUse(cntbl,:) = allFreqsUse;
            cntbl = cntbl + 1;
        end
    end
end

% cohenrece  
pdb = patientPSD_at_home ;
freqUse = {'beta','gamma'};
window  = 10; % hz from each side 
medstates = {'off','on'};
for f = 1:length(freqUse)
        idxstn = cellfun(@(x) any(strfind(x,'coh')),pdb.electrode);
        pdbArea = pdb(idxstn,:);
        for m = 1:length(medstates)
            cntArea = 1; % since combining motnages
            idxMed = strcmp(pdbArea.medstate,medstates{m});
            pdbMed = pdbArea(idxMed,:);
            uniqContacts = unique(pdbMed.electrode);
            dataMsCoherence = [];
            for u = 1:length(uniqContacts)
                idxContact = strcmp(pdbMed.electrode,uniqContacts{u});
                pdbContact = pdbMed(idxContact,:);
                for s = 1:size(pdbContact)
                    switch uniqContacts{u}
                        case 'coh_stn02m10810'
                            cnl = 0;
                        case 'coh_stn02m10911'
                            cnl = 2;
                        case 'coh_stn13m0911'
                            cnl = 1;
                        case 'coh_stn13m10810'
                            cnl = 3;
                    end
                    cnls = pdbContact.cnls{s};
                    ttls = pdbContact.ttls{s};
                    freqs = pdbContact.freqs{s};
                    idxchannel = cnls == cnl;
                    idxfreq    = cellfun(@(x) any(strfind(x,freqUse{f})),ttls);
                    freqUseHz   = freqs(idxchannel & idxfreq);
                    allFreqsUse(cntArea) = freqUseHz;
                    mscoherence = pdbContact.ms_coherence{s};
                    freqs   = pdbContact.ff_coh{s};
                    idxdata = freqs >= (freqUseHz-window) & freqs <= (freqUseHz+window);
                    if sum(idxdata) == 20 
                        idxdata = freqs >= (freqUseHz-window) & freqs <= (freqUseHz+window+1);
                    end
                    dataMsCoherence(cntArea,:) = mscoherence(idxdata); 
                    cntArea = cntArea + 1;
                    
                end
            end
            % save the data in a table; 
            outputTable.medstate{cntbl} = medstates{m};
            outputTable.area{cntbl} = 'M1-stn-cohernece';
            outputTable.freqUse{cntbl} = freqUse{f};
            outputTable.dataMsCoherence{cntbl} = dataMsCoherence;
            outputTable.allFreqsUseCoherence(cntbl,:) = allFreqsUse;
            cntbl = cntbl + 1;
        end
    
end
%% plot 
plotShaded = 0;
hfig = figure; 
hfig.Color = 'w'; 
p = panel();
p.pack(3,2); 
freqUse = {'beta','gamma'};
areas = {'STN','M1'};
medstates = {'off','on'};
for f = 1:length(freqUse)
    for a = 1:length(areas)
        hsb = p(a,f).select(); 
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

% plot coherence 
freqUse = {'beta','gamma'};
areas = {'STN','M1'};
medstates = {'off','on'};
for f = 1:length(freqUse)
    hsb = p(3,f).select();
    hold(hsb,'on');
    for m = 1:length(medstates)
        idxFreq = strcmp(outputTable.freqUse ,freqUse{f});
        idxAreas= strcmp(outputTable.area ,'M1-stn-cohernece');
        idxMed  = strcmp(outputTable.medstate ,medstates{m});
        idxUse = idxFreq & idxAreas & idxMed;
        tbPlt = outputTable(idxUse,:);
        data = tbPlt.dataMsCoherence{1};
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
            titleUse = sprintf('%s %s','M1-stn coherence',freqUse{f});
            title(titleUse);
            ylabel('ms coherence');
            xlabel('centered frequency (Hz)');
            hplt(m) = hshadedError.mainLine;
        else
            hplt = plot(x,y);
            for hh = 1:length(hplt)
                hplt(hh).Color = [colorUse 0.4];
            end
            hplt(m) = hplt(hh);
        end
    end
    legend(hplt,{'off - PKG estimate','on - PKG estimate'});
end

p.marginbottom = 30;
p.marginright = 30 ;
p.marginleft = 30;
p.margintop = 30;
% p.de.margin = 15;
p.fontsize = 15;
%%

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
        hpanel(1,2,cntplt,1).select();
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
        hsbH = shadedErrorBar(ff,psds,{@mean,@(x) std(x)*1});
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
    hpanel(1,2,cntplt,1).select();
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
    errs(:,1) = mean(cohs) + std(cohs);
    errs(:,2) = mean(cohs) - std(cohs);
    errs(errs(:,2)<0,2) = meancoh(errs(:,2)<0);
    errs = errs';
%     hsbH = shadedErrorBar(ff,cohs,{@mean,@(x) std(x)*1});
    hsbH = shadedErrorBar(ff,mean(cohs),errs); 
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
    
    prfig.plotwidth           = 6;
    prfig.plotheight          = 9;
    prfig.figdir             = figdirout;
    prfig.figname             = sprintf('Fig%d_panelB_psd_coh_group',fignum);
    prfig.figtype             = '-dpdf';
    plot_hfig(hfig,prfig)
    close(hfig);
end