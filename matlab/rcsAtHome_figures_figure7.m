function rcsAtHome_figures_figure7()
%% stn beta activity is detectable during stim 
% panel a - single subject - on , off and chornic stim 
% panel b plot violin plots of average beta power 
% panel c - plot embedded adaptive data 
close all;
figdirout = '/Users/roee/Box/rcs paper paper on first five bilateral implants/revision for nature biotechnology/figures/Fig7_effect_of_stim_and_adaptive/subject_speciific_plots';
plotpanels = 1;
addpath(genpath(fullfile(pwd,'toolboxes','panel-2.14')));
if ~plotpanels
    hfig = figure;
    hfig.Color = 'w';
    hpanel = panel();
    hpanel.pack({0.4, 0.6});
    hpanel(1).pack(1,3); % panel a + b 
    hpanel(2).pack(3,1); % panel c adaptive 
%     hpanel.select('all');
%     hpanel.identify();

end

%% panel A - single subject - on , off and chornic stim 
dontRun = 1;
if ~dontRun
    dirsave = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/results/long_term_stim_on_stim_off';
    load(fullfile(dirsave,'psd_at_home_stim_on_vs_stim_off.mat'),'psdResultsBoth');
    load('/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/pkg_data/figures/pkg_states RCS02 R pkg L _10_min_avgerage.mat')
    addpath(genpath(fullfile(pwd,'toolboxes','shadedErrorBar')))
    if plotpanels
        hfig = figure();
        hfig.Color = 'w';
    end
    % on stim vs off stim
    % d = 1 -
    stimstate = {'off stim','on chronic stim'};
    statesuse = {'off','on'};
    colorsUse = [0.5 0.5 0.5;
        0   0.8   0];
    titles = {'STN 0-2','STN 1-3','M1 8-10','M1 9-11'};
    cntplt = 1;
    if ~plotpanels
        hSub = gobjects(3,1);
    end
    for c = [2 4]
        if plotpanels
            hSub(cntplt) = subplot(2,2,cntplt); cntplt = cntplt+1;
        else
            hpanel(1,1,cntplt).select(); cntplt = cntplt + 1;
            hSub(cntplt,1) = gca;
        end
        
        
        hold on;
        for d = 1:2
            fn = sprintf('key%dfftOut',c-1);
            if d == 2   % on stim
                psdResults = psdResultsBoth(2);
                fftOut = psdResults.(fn)(psdResults.idxkeep,:);
                ff = psdResults.ff;
            else
                fftOut = allDataPkgRcsAcc.(fn);
                ff = psdResults.ff;
            end
            idxusefreq = ff >= 13 &  ff <= 30;
            
            % normalize the data
            dat = fftOut;
            idxnormalize = psdResults.ff > 3 &  psdResults.ff <90;
            meandat = abs(mean(dat(:,idxnormalize),2)); % mean within range, by row
            % the absolute is to make sure 1/f curve is not flipped
            % since PSD values are negative
            meanmat = repmat(meandat,1,size(dat,2));
            dat = dat./meanmat;
            fftOut = dat;
            
            meanbetafreq{c,d} = mean(fftOut(:,idxusefreq),2);
            
            idxusefreq = ff >= 65 &  ff <= 85;
            meangammafreq{c,d} = mean(fftOut(:,idxusefreq),2);
            
            
            
            hsb = shadedErrorBar(ff,fftOut,{@median,@(x) std(x)*2});
            hsb.mainLine.Color = [colorsUse(d,:) 0.5];
            hsb.mainLine.LineWidth = 2;
            hsb.patch.MarkerFaceColor = colorsUse(d,:);
            hsb.patch.FaceColor = colorsUse(d,:);
            hsb.patch.EdgeColor = colorsUse(d,:);
            hsb.edge(1).Color = [colorsUse(d,:) 0.1];
            hsb.edge(2).Color = [colorsUse(d,:) 0.1];
            hsb.patch.EdgeAlpha = 0.1;
            hsb.patch.FaceAlpha = 0.1;
            xlabel('Frequency (Hz)');
            ylabel('Norm. power (a.u.)');
            title(titles{c});
            set(gca,'FontSize',16);
            hlines(d) = hsb.mainLine;
            xlim([3 100]);
        end
        legend(hlines,stimstate);
        %     totalhours = (length(psdResults.timeStart(psdResults.idxkeep))*10)/60;
        %     fprintf('total hours %d %s\n',totalhours,stimstate{d});
    end
    if plotpanels
        sgtitle('RCS02 L','FontSize',25);
        
        figname = sprintf('on stim vs off stim_ %s %s v2','RCS02','L');
        prfig.plotwidth           = 15;
        prfig.plotheight          = 10;
        prfig.figname             = figname;
        prfig.figdir              = dirsave;
        plot_hfig(hfig,prfig)
    end
end
%% 

%% panel b plot violin plots of average beta power 
rootdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home/'; 
addpath(genpath(fullfile(pwd,'toolboxes','panel-2.14')));
% off stim 
ff = findFilesBVQX(rootdir,'coherence_and_psd*.mat');
dataTable = table();
for f = 1:length(ff)
    load(ff{f});
    [pn,fn] = fileparts(ff{f});
    dataTable.patient{f} = fn(19:23);
    dataTable.side{f} = fn(25);
    dataTable.stim(f) = 0; 
    dataTable.allDataPkgRcsAccq{f} = allDataPkgRcsAcc;
end
% on stim 
stimDir = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/processed_data';
ff  = findFilesBVQX(stimDir,'RC*psd*stim*.mat');
ffc = findFilesBVQX(stimDir,'RC*coh*stim*.mat');
tblcnt = size(dataTable,1) + 1;
clear allDataPkgRcsAcc;
for f = 1:length(ff)
    % load data
    load(ff{f},'fftResultsTd','database');
    load(ffc{f},'coherenceResultsTd','database');
    [pn,fn] = fileparts(ff{f});
    
    % create output structure 
    allDataPkgRcsAcc.key0fftOut         = fftResultsTd.key0fftOut;
    allDataPkgRcsAcc.key1fftOut         = fftResultsTd.key1fftOut;
    allDataPkgRcsAcc.key2fftOut         = fftResultsTd.key2fftOut;
    allDataPkgRcsAcc.key3fftOut         = fftResultsTd.key3fftOut;
    allDataPkgRcsAcc.ffPSD              = fftResultsTd.ff; 
    allDataPkgRcsAcc.timeStart          = fftResultsTd.timeStart;
    allDataPkgRcsAcc.timeEnd            = fftResultsTd.timeEnd;
    allDataPkgRcsAcc.stn02m10810        = coherenceResultsTd.stn02m10810;
    allDataPkgRcsAcc.stn02m10911        = coherenceResultsTd.stn02m10911;
    allDataPkgRcsAcc.stn13m0911         = coherenceResultsTd.stn13m0911;
    allDataPkgRcsAcc.stn13m10810        = coherenceResultsTd.stn13m10810;
    allDataPkgRcsAcc.ffCoh              = coherenceResultsTd.ff;
    allDataPkgRcsAcc.database           = database; 
    
    % save to data table 
    dataTable.patient{tblcnt}           = fn(1:5);
    dataTable.side{tblcnt}              = fn(7);
    dataTable.stim(tblcnt)              = 1;
    dataTable.allDataPkgRcsAccq{tblcnt} = allDataPkgRcsAcc;
    tblcnt = tblcnt + 1;
    clear allDataPkgRcsAcc;
end




width = 3; 
uniquePatients = unique(dataTable.patient);
uniqueSides    = unique(dataTable.side); 
cnttoplot = 1;
for p = 1:length(uniquePatients)
    for s = 1:length(uniqueSides)
        idxuse = strcmp(dataTable.patient, uniquePatients{p}) & ...
            strcmp(dataTable.side, uniqueSides{s}) ;
        patTable = dataTable(idxuse,:);
        idxstim  = find(patTable.stim==1);
        dataStrucStim = patTable.allDataPkgRcsAccq{idxstim};
        switch dataStrucStim.database.electrodes{1}
            case '+2 -c '
                if strcmp(dataStrucStim.database.chan1{1}, '+3-1 lpf1-100Hz lpf2-100Hz sr-250Hz')
                    stnFn_stim   = 'key0fftOut'; 
                    stnFn_noStim = 'key1fftOut'; 
                    cnlsReadFreq = [1 2];
                elseif strcmp(dataStrucStim.database.chan2{1}, '+3-1 lpf1-100Hz lpf2-100Hz sr-250Hz')
                    stnFn_stim   = 'key1fftOut'; 
                    stnFn_noStim = 'key1fftOut'; 
                    cnlsReadFreq = [2 2];
                end
            case '+1 -c '
                if strcmp(dataStrucStim.database.chan1{1}, '+2-0 lpf1-100Hz lpf2-100Hz sr-250Hz')
                    stnFn_stim   = 'key0fftOut';
                    stnFn_noStim = 'key0fftOut';
                    cnlsReadFreq = [1 1];
                elseif strcmp(dataStrucStim.database.chan2{1}, '+3-1 lpf1-100Hz lpf2-100Hz sr-250Hz')
                    stnFn_stim   = 'key1fftOut';
                    stnFn_noStim = 'key0fftOut';
                    cnlsReadFreq = [2 1];
                end
        end
        switch uniquePatients{p}
            case 'RCS02'
                cnls  =  [0  1  2  3  0  1  2  3  ];
                freqs =  [19 19 24 25 75 75 76 76];
                ttls  = {'STN beta','STN beta','M1 beta','M1 beta','STN gamma','STN gamma','M1 gamma','M1 gamma'};
            case 'RCS05'
                cnls  =  [0  1  2  3  0  1  2  3  ];
                freqs =  [27 27 27 27 61 61 61 61];
            case 'RCS06'
                cnls  =  [0  1  2  3  0  1  2  3  ];
                freqs =  [19 19 14 26 55 55 61 61];
                ttls  = {'STN beta','STN beta','M1 beta','M1 beta','STN gamma','STN gamma','M1 gamma','M1 gamma'};
            case 'RCS07'
                cnls  =  [0  1  2  3  0  1  2  3  ];
                freqs =  [19 20 21 24 76 79 80 80];
                ttls  = {'STN beta','STN beta','M1 beta','M1 beta','STN gamma','STN gamma','M1 gamma','M1 gamma'};
            case 'RCS08'
                cnls  =  [0  1  2  3  0  1  2  3  ];
                freqs =  [27 23 26 26 43 84 84 84];
                ttls  = {'STN beta','STN beta','M1 beta','M1 beta','STN gamma','STN gamma','M1 gamma','M1 gamma'};
        end
        stimState = [ 0 1];
        stimLabel = {'stim off','stim on'};
        stmfn     = {'stnFn_noStim','stnFn_stim'};
        colorsuse = [0.5 0.5 0.5; 0 0.8 0]; 

        if  p == 1 & s == 1
            ff = psdResults.ff;
        end
        for ss = 1:2
            %  get the data strcture 
            dataStruc = patTable.allDataPkgRcsAccq{ patTable.stim == stimState(ss) };
            % normalize the data
            fnuse = eval(stmfn{ss});
            hoursrec = hour(dataStruc.timeStart);
            idxhoursuse = (hoursrec >= 8) & (hoursrec <= 22);
            fftOutRaw = dataStruc.(fnuse);
            if size(fftOutRaw,1) > size(fftOutRaw,2)
                fftOut = fftOutRaw(idxhoursuse',:);
                fftOut = fftOut';
            end
            if size(fftOutRaw,1) < size(fftOutRaw,2)
                fftOut = fftOutRaw(:,idxhoursuse);
            end
            
            meanVals = mean(fftOut(40:60,:));
            q75_test=quantile(meanVals,0.75);
            q25_test=quantile(meanVals,0.25);
            w=2.0;
            wUpper = w*(q75_test-q25_test)+q75_test;
            wLower = q25_test-w*(q75_test-q25_test);
            idxWhisker = (meanVals' < wUpper) & (meanVals' > wLower);
            fftOut = fftOut(:,idxWhisker);
            
            dat = fftOut;
            idxnormalize = ff > 3 &  ff <90;
            meandat = repmat(mean(abs(mean(dat(:,idxnormalize),2))),length(ff),1); % mean within range, by row
            % the absolute is to make sure 1/f curve is not flipped
            % since PSD values are negative
            meanmat = repmat(meandat,1,size(dat,2));
            dat = dat./meanmat;
            fftOutNorm = dat;
            
%             xlim([3 100]);
            % use peaks or individual peaks
            idxusefreq = ff >= 13 &  ff <= 30;
            % individual peaks
            betapeakuse = freqs(cnlsReadFreq(ss));
            idxusefreq = ff >= (betapeakuse - width) &  ff <= (betapeakuse + width);
            
            
            
            meanbetafreqNorm{p,s,ss} = mean(fftOutNorm(idxusefreq,:),1);
            meanbetafreq{p,s,ss} = mean(fftOut(idxusefreq,:),1);
            toplot{1,cnttoplot} = mean(fftOutNorm(idxusefreq,:),1)';
            xtics(cnttoplot)  = cnttoplot;
            xticklab = sprintf('%s %s %s',uniquePatients{p},uniqueSides{s},stimLabel{ss});
            xtickalbs{cnttoplot} = xticklab;
            coloruse(cnttoplot,:) = colorsuse(ss,:);
            cnttoplot = cnttoplot + 1;
            % save some of the data 
            idxuse = strcmp(dataTable.patient, uniquePatients{p}) & ...
                     strcmp(dataTable.side, uniqueSides{s}) & ... 
                     dataTable.stim == stimState(ss);
            cnfnm = sprintf('chan%d',str2num((fnuse(4)))+1);
            idxNum = find(idxuse==1);
            dataTable.ff{idxNum} = ff;
            dataTable.fftOut{idxNum} = fftOut;
            dataTable.fftOutNorm{idxNum} = fftOutNorm;
            dataTable.betapeakuse(idxNum) = betapeakuse;
            dataTable.meanbetafreqNorm{idxNum} = meanbetafreqNorm{p,s,ss};
            dataTable.meanbetafreq{idxNum} = meanbetafreq{p,s,ss};

        end
    end
end


%% loop on patients and plot a plot per patient with both the raw data and the violin plot 
addpath(genpath(fullfile(pwd,'toolboxes','panel-2.14')));
addpath(genpath(fullfile(pwd,'toolboxes','plot_reducer')));
addpath(genpath(fullfile(pwd,'toolboxes','Violinplot-Matlab/')));

colorsuse = [0.5 0.5 0.5; 0 0.8 0]; 

for p = 3%1:length(uniquePatients)
    idxuse = strcmp(dataTable.patient, uniquePatients{p});
    patTable = dataTable(idxuse,:);
    % start figure 
    hfig = figure();
    hfig.Color = 'w';
    hpanel = panel();
    hpanel.pack(2,1);
    
    hpanel(1,1).pack(1,4);
    hpanel(2,1).pack(1,2);
%     hpanel.select('all');
%     hpanel.identify();
    for ss = 1:size(patTable,1)
        datPlot = patTable(ss,:);
        if strcmp(datPlot.side,'L') & datPlot.stim
            colUse = 2;
        end
        if strcmp(datPlot.side,'L') & ~datPlot.stim
            colUse = 1;
        end
        if strcmp(datPlot.side,'R') & datPlot.stim
            colUse = 4;
        end
        if strcmp(datPlot.side,'R') & ~datPlot.stim
            colUse = 3;
        end
        if datPlot.stim
            colorsuse = [0.5 0.5 0.5 0.2];
            ttlUse = sprintf('%s %s %s',datPlot.patient{1},datPlot.side{1},'stim on');
        else
            colorsuse =  [0 0.8 0 0.2]; 
            ttlUse = sprintf('%s %s %s',datPlot.patient{1},datPlot.side{1},'stim off');
        end
        hsb(ss) = hpanel(1,1,1,colUse).select();
        reduce_plot(patTable.ff{ss},patTable.fftOut{ss},'Color',colorsuse);
        xlim([3 100]);
        title(ttlUse);
        if colUse == 1
            ylabel('Power (log_1_0\muV^2/Hz)');
        end
        hold(hsb(ss),'on');
    end
    linkaxes(hsb,'y');
    for ss = 1:4
        plot(hsb(ss),[patTable.betapeakuse(ss) patTable.betapeakuse(ss)], hsb(ss).YLim,...
            'LineWidth' , 4,...
            'LineStyle','-.',...
            'Color',[0 0 0.2 0.2]);
    end
    
    
    % plot the violin plots
    ttsPlotsUse = {'stim on/off L','stim on/off R'};
    uniqueSides    = unique(patTable.side);    
    coloruse = [  0 0.8 0;0.5 0.5 0.5]; 

    for s = 1:length(uniqueSides)
        idxside = strcmp(patTable.side,uniqueSides{s});
        patSide = patTable(idxside,:);
        plotstruc = struct();
        for t = 1:size(patSide,1)
            fnUse = sprintf('v%d',t);
            plotstruc.(fnUse) = patSide.meanbetafreq{t};
            if logical(patSide.stim(t))
                xTicks{t} = 'stim on';
            else
                xTicks{t} = 'stim off';
            end
        end
        if strcmp(patSide.side{s},'L')
            colUse = 1;
        end
        if strcmp(patSide.side{s},'R')
            colUse = 2;
        end
        hsb = hpanel(2,1,1,colUse).select();
        hviolin  = violinplot(plotstruc);
        for h = 1:length(hviolin)
            hviolin(h).ViolinPlot.FaceColor =  coloruse(h,:);
            hviolin(h).ScatterPlot.CData    =  coloruse(h,:);
            hviolin(h).ViolinPlot.FaceAlpha =  0.3;
            hviolin(h).ShowData = 0;
        end
        hsb.XTickLabel  = xTicks;
%         hsb.XTickLabelRotation = 30;

        title(ttsPlotsUse{s});
    end
    hpanel.margin = [20 20 15 15];
    hpanel.fontsize = 16;
    figname = sprintf('%s',uniquePatients{p});
    prfig.plotwidth           = 16;
    prfig.plotheight          = 12;
    prfig.figdir             = figdirout;
    prfig.figname             = figname;
    prfig.figtype             = '-djpeg';
    plot_hfig(hfig,prfig)

end
return 
x = 2;
%%


addpath(genpath(fullfile(pwd,'toolboxes','violin')));
addpath(genpath(fullfile(pwd,'toolboxes','Violinplot-Matlab/')));
clear plotstruc;
dataTable = sortrows(dataTable,{'patient','side','stim'})
colorsuse = [0.5 0.5 0.5; 0 0.8 0];
for t = 1:size(dataTable)
    fnUse = sprintf('v%d',t);
%     plotstruc.NotNumeric(t) = sum(~isnumeric(toplot{t}));
%     plotstruc.NaN(t) = sum(isnan(toplot{t}));
%     plotstruc.InF(t) = sum(isinf(toplot{t}));
    plotstruc.(fnUse) = dataTable.meanbetafreq{t};
    if dataTable.stim(t)
        xtickalbs{t} = sprintf('%s %s %s',dataTable.patient{t},dataTable.side{t},'stim on');
        ColorsUse(t,:) = colorsuse(1,:);
    else
        xtickalbs{t} = sprintf('%s %s %s',dataTable.patient{t},dataTable.side{t},'stim off');
        ColorsUse(t,:) = colorsuse(2,:);
    end
end
hfig = figure;
hfig.Color = 'w';
hSub = subplot(1,1,1);
hviolin  = violinplot(plotstruc);

ylabel('Average STN beta power'); 
% hSub.XTick = xtics;
hSub.XTickLabel  = xtickalbs;
hSub.XTickLabelRotation = 30;
for h = 1:length(hviolin)
    hviolin(h).ViolinPlot.FaceColor =  ColorsUse(h,:);
    hviolin(h).ScatterPlot.CData    =  ColorsUse(h,:);
    hviolin(h).ViolinPlot.FaceAlpha =  0.3;
    hviolin(h).ShowData = 0;
end
hpanel.fontsize = 18; 
figname = 'all_patient_chronic_stim';
prfig.plotwidth           = 16;
prfig.plotheight          = 12;
prfig.figdir             = figdirout;
prfig.figname             = figname;
prfig.figtype             = '-djpeg';
title('effect of chronic stim  STN beta');

plot_hfig(hfig,prfig)


%%
return 

patients = {'RCS02','RCS05'}; 
patients = {'RCS01','RCS02'}; % renamed for paper  
betapeaks = [27 19 20];
cnlsuse = [1 0];
width = 2.5; 
cntpt = 1; 

dirsave = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/results/long_term_stim_on_stim_off'; 
load(fullfile(dirsave,'psd_at_home_stim_on_vs_stim_off.mat'),'psdResultsBoth'); 


psdresultsfn{1,cntpt} = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home/RCS02/psdResults_L.mat'; % off stim 
psdresultsfn{2,cntpt} = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/results/long_term_stim_on_stim_off/psdResults_on_stim.mat'; % on stim 
cntpt = cntpt+1; 

psdresultsfn{1,cntpt} = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home/RCS05/psdResults_R.mat'; % off stim 
psdresultsfn{2,cntpt} = '/Volumes/RCS_DATA/RCS05/data_dump/SummitContinuousBilateralStreaming/RCS05R/psdResults.mat'; % on stim 

cntpt = cntpt+1; 

cnttoplot = 1; 
colorsuse = [0.5 0.5 0.5; 0 0.8 0]; 
stimstate = {'off stim','on stim'}; 


if plotpanels
    hfig = figure;
    hsb = subplot(1,1,1);
    hfig.Color = 'w';
else
    hpanel(1,1,cntplt).select(); cntplt = cntplt + 1;
    hSub = gca;
end

nrows = length(patients); 
ncols = 2; 
for p = 1:size(psdresultsfn,2)
    for i = 1:2
        load(psdresultsfn{i,p});
        ff = fftResultsTd.ff;

        % normalize the data
        fnuse = sprintf('key%dfftOut',cnlsuse(p));
        hoursrec = hour(fftResultsTd.timeStart);
        idxhoursuse = (hoursrec >= 8) & (hoursrec <= 22); 
        fftOut = fftResultsTd.(fnuse)(:,idxhoursuse);
        timesout = fftResultsTd.timeStart(idxhoursuse);
        
        meanVals = mean(fftOut(40:60,:));
        q75_test=quantile(meanVals,0.75);
        q25_test=quantile(meanVals,0.25);
        w=2.0;
        wUpper = w*(q75_test-q25_test)+q75_test;
        wLower = q25_test-w*(q75_test-q25_test);
        idxWhisker = (meanVals' < wUpper) & (meanVals' > wLower);
        fftOut = fftOut(:,idxWhisker);
        timesout = timesout(idxWhisker);
        
        dat = fftOut;
        idxnormalize = ff > 3 &  ff <90;
        meandat = repmat(mean(abs(mean(dat(:,idxnormalize),2))),length(ff),1); % mean within range, by row
        % the absolute is to make sure 1/f curve is not flipped
        % since PSD values are negative
        meanmat = repmat(meandat,1,size(dat,2));
        dat = dat./meanmat;
        fftOut = dat;
        
        xlim([3 100]);
        % use peaks or individual peaks
        idxusefreq = ff >= 13 &  ff <= 30;
        % individual peaks 
        idxusefreq = ff >= (betapeaks(p)-width) &  ff <= (betapeaks(p)+width);
        
        meanbetafreq{p,i} = mean(fftOut(idxusefreq,:),1);
        times{p,i} = timesout;
        toplot{1,cnttoplot} = mean(fftOut(idxusefreq,:),1);
        xtics(cnttoplot)  = cnttoplot; 
        xticklab = sprintf('%s %s',patients{p},stimstate{i});
        xtickalbs{cnttoplot} = xticklab; 
        coloruse(cnttoplot,:) = colorsuse(i,:);
        cnttoplot = cnttoplot + 1; 
        ylabel('Norm. power');
        set(gca,'FontSize',16); 
    end
end


hviolin  = violin(toplot);
ylabel('Average norm. beta power'); 
hSub.XTick = xtics;
hSub.XTickLabel  = xtickalbs;
hSub.XTickLabelRotation = 30;
ylim([-1.1 -0.45]);
for h = 1:length(hviolin)
    hviolin(h).FaceColor =  coloruse(h,:);
    hviolin(h).FaceAlpha = 0.3;
end

title('effect of chronic stim');
%% 

%% panel C - plot embedded adaptive data 
params.adaptiveFolder   = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/v14_adaptive_before_sending_home/RCS02R/Session1570736950940/DeviceNPC700404H';
params.window           = seconds(30); % size of window you want 
params.advance          = seconds(0.1); 
params.runToPlot        = 5; % run to plot - see results of plot_alligned_data_in_folder() on this folder 
params.vidFname         = sprintf('all_data_alligned_v3_%0.2d.mp4',params.runToPlot);
params.vidOut           = fullfile(params.adaptiveFolder,params.vidFname); 

% plot alligned data 
dirname = params.adaptiveFolder;
fnmload = fullfile(params.adaptiveFolder,'all_data_alligned.mat'); 
if exist(fnmload,'file')
    load_and_save_alligned_data_in_folder(dirname);
    load(fnmload,'outdatcomplete','outdatcompleteAcc','outRec',...
    'eventTable','powerOut','adaptiveTable','adaptiveStruc','senseStruc','embeddedStartEndTimes','adaptiveInfo');
else
    load(fnmload,'outdatcomplete','outdatcompleteAcc','outRec',...
    'eventTable','powerOut','adaptiveTable','adaptiveStruc','senseStruc','embeddedStartEndTimes','adaptiveInfo');

end
figdir = fullfile(dirname,'figures'); 
mkdir(figdir); 

% plot alligned data 
% find difference from unix time 
idxTimeCompare = find(outdatcomplete.PacketRxUnixTime~=0,1);
packRxTimeRaw  = outdatcomplete.PacketRxUnixTime(idxTimeCompare); 
packtRxTime    =  datetime(packRxTimeRaw/1000,...
            'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
derivedTime    = outdatcomplete.derivedTimes(idxTimeCompare); 
timeDiff       = derivedTime - packtRxTime;
deltaUse       = seconds(20); 
startTimes = embeddedStartEndTimes.EmbeddedStart.UnixOnsetTime + timeDiff + deltaUse; 
endTimes = embeddedStartEndTimes.EmbeddedEnd.UnixOnsetTime + timeDiff - deltaUse; 
dur      = endTimes - startTimes;
% only consider adaptive files over 30 seconds 
startTimes = startTimes(dur > seconds(30));
endTimes = endTimes(dur > seconds(30));
 % XXXX 
% startTimes = startTimes(1); 
% endTimes = endTimes(end); 
% XXXX 

nrows = 3; 
ncols = 1; 
cntplt = 1;
for e = params.runToPlot% 1:length(startTimes)
    
    if plotpanels
        hfig = figure;
        hfig.Position = [45           1        1636         954];
        hfig.Color = 'w';
    end

    % plot one figure for each adaptive "session".
    % this should include:
    
    % splot settings 
    % settings
%     hsub(cntplt) = subplot(nrows,ncols,cntplt); cntplt = cntplt + 1;
%     set(gca,'FontSize',16);
%     set(gca, 'box','off','XTickLabel',[],'XTick',[],'YTickLabel',[],'YTick',[])
% 
%     a = annotation('textbox', hsub(1).Position, 'String', "hi");
%     a.FontSize = 14;


    % power 
    strline = 1;
    strOut{strline} = 'settings'; 
    strline = strline + 1; 
    
    strOut{strline} = sprintf('%s\t power band: %s',...
        adaptiveInfo(e).tdChannelInfo,...
        adaptiveInfo(e).bandsUsed);    
    strline = strline + 1; 
    % stim 
    
    strOut{strline} = sprintf('stim rate %.2f\t states: [%.2f mA %.2f mA %.2f mA]',...
        adaptiveInfo(e).stimRate,...
        adaptiveInfo(e).State0AmpInMilliamps,...
        adaptiveInfo(e).State1AmpInMilliamps,...
        adaptiveInfo(e).State2AmpInMilliamps);
    strline = strline + 1; 
    
    % fft settings 
    fftsize = adaptiveInfo(e).Fftsize;
    sr = adaptiveInfo(e).SampleRate;
    
    strOut{3} = sprintf('each FFT represents %d ms of data (fft size %d sr %d Hz)',...
        ceil((fftsize/sr).*1000), fftsize,sr);
    updateRate = adaptiveInfo(e).UpdateRate; 
    
    strOut{strline} = sprintf('%d ffts are averaged - %d ms of data before being input to LD',updateRate,ceil((fftsize/sr).*1000)*updateRate);    
    strline = strline + 1; 

    strOut{strline} = sprintf('update rate %d onset %d termination %d state change blank %d',...
        adaptiveInfo(e).UpdateRate,...
        adaptiveInfo(e).OnsetDuration,...
        adaptiveInfo(e).TerminationDuration,...
        adaptiveInfo(e).StateChangeBlankingUponStateChange);
    strline = strline + 1; 

    
    strOut{strline} = sprintf('ramp up rate %.2f mA/sec\t ramp down rate %.2f mA/sec\t',...
        adaptiveInfo(e).rampUpRatePerSec,...
        adaptiveInfo(e).rampDownRatePerSec);
    strline = strline + 1;

    % suplot 2
    if plotpanels
        hsub(cntplt) = subplot(nrows,ncols,cntplt); cntplt = cntplt + 1;
    else
        hpanel(2,cntplt,1).select(); cntplt = cntplt + 1;
        hsub(cntplt,1) = gca;
    end
    
    hold on;
    % 1. td band passedd power
    % find the right time domain channel
    cused = adaptiveInfo(e).tdChannelUsed;
    tddata = outdatcomplete.(sprintf('key%d',cused-1));
    secs   = outdatcomplete.derivedTimes;
    idxuse = secs >= startTimes(e) & secs <= endTimes(e);
    tddata = tddata(idxuse);
    secs   = secs(idxuse);
    bandsUsed = str2num(strrep(strrep(adaptiveInfo(e).bandsUsed,'Hz',''),'-',' '));
    sr = adaptiveInfo(e).SampleRate;
    tddata = tddata - mean(tddata);
    [b,a]        = butter(3,[bandsUsed(1) bandsUsed(end)] / (sr/2),'bandpass'); % user 3rd order butter filter
    y_filt       = filtfilt(b,a,tddata); %filter all
    y_filt_hilbert       = abs(hilbert(y_filt));
    ydatRescaled = rescale(y_filt,0.55,1);
    y_filt_hilbertRescaled = rescale(y_filt_hilbert,0.55+(1-0.55)/2,1);
    
    
    up = y_filt_hilbert; 
    thresh = prctile(y_filt_hilbert,75); 
    % find start and end indices of line crossing threshold
    startidx = find(diff(up > thresh) == 1) + 1;
    endidx = find(diff(up > thresh) == -1) + 1;
    endidx = endidx(endidx > startidx(1));
    startidx = startidx(1:length(endidx));
    for b = 1:size(startidx,1)
        bursts.len(b) = secs(endidx(b)) - secs(startidx(b));
        bursts.amp(b) = max(up(startidx(b):endidx(b)));
    end
    % make all scales duration based: 
    secs = secs - secs(1); 
    % subtract a ceratin number of seconds so output graph is centerd on
    % zero 
    secs = secs - seconds(63);
    % 
    plot(secs,ydatRescaled,'LineWidth',0.5,'Color',[0 0 0.8 0.2]);
    plot(secs,y_filt_hilbertRescaled,'LineWidth',3,'Color',[0.8 0 0 0.6]);
    % 2. adaptive power
    secsPower = powerOut.powerTable.derivedTimes;
    idxusePower = secsPower >= startTimes(e) & secsPower <= endTimes(e);
    powerVals = powerOut.powerTable.(adaptiveInfo(e).bandsUsedName);
    secsPower = secsPower(idxusePower);
    powerVals = powerVals(idxusePower);
    powerValsRescaled = rescale(powerVals,0.1,0.5);
    % make all scales duration based: 
    secsPower = secsPower - secsPower(1); 
    % 
%     plot(secsPower,powerValsRescaled,'LineWidth',3,'Color',[0 0.8 0 0.6]);
    ylabel('power - td & embedded (a.u.)');
    ylabel('Beta LFP');
    title('Time Domain Data (filtered in Beta range)');
    set(gca,'FontSize',16);
    set(gca,'XTick',[]);
    
    % suplot 3
    if plotpanels
        hsub(cntplt) = subplot(nrows,ncols,cntplt); cntplt = cntplt + 1;
    else
        hpanel(2,cntplt,1).select(); cntplt = cntplt + 1;
        hsub(cntplt,1) = gca;
    end
    hold on;
    secsAdaptive = adaptiveTable.derivedTimes;
    idxuseAdaptive = secsAdaptive >= startTimes(e) & secsAdaptive <= endTimes(e);
    secsAdaptive = secsAdaptive(idxuseAdaptive); 
    state = adaptiveTable.CurrentAdaptiveState(idxuseAdaptive);
    detector = adaptiveTable.LD0_output(idxuseAdaptive);
    highThresh = adaptiveTable.LD0_highThreshold(idxuseAdaptive);
    lowThresh = adaptiveTable.LD0_lowThreshold(idxuseAdaptive);
    current   = adaptiveTable.CurrentProgramAmplitudesInMilliamps(idxuseAdaptive); 
    % 1. detector
    % make all scales duration based:
    secsAdaptive = secsAdaptive - secsAdaptive(1);
    % subtract a ceratin number of seconds so output graph is centerd on
    % zero 
    secsAdaptive = secsAdaptive - seconds(63);
    %
    plot(secsAdaptive,detector,'LineWidth',3);
    hplt = plot(secsAdaptive,highThresh,'LineWidth',3);
    hplt.LineStyle = '-.';
    hplt.Color = [hplt.Color 0.7];
    hplt = plot(secsAdaptive,lowThresh,'LineWidth',3);
    hplt.LineStyle = '-.';
    hplt.Color = [hplt.Color 0.7];
    % 2. threshold
    ylims = get(gca,'YLim');
    rescaleVals = [ylims(2)*1.1 (ylims(2) + ceil(ylims(2)-ylims(1))/3)];
    stateRescaled = rescale(state,rescaleVals(1),rescaleVals(2));
    % 3. state - rescaled on the second y axis above current
    plot(secsAdaptive,stateRescaled,'LineWidth',3,'Color',[0 0.8 0 0.6]);
    title('state and detector'); 
    set(gca,'FontSize',16);
    set(gca,'XTick',[]);
    
    % subplot 4
    if plotpanels
        hsub(cntplt) = subplot(nrows,ncols,cntplt); cntplt = cntplt + 1;
    else
        hpanel(2,cntplt,1).select(); cntplt = cntplt + 1;
        hsub(cntplt,1) = gca;
    end
    hold on;
    plot(secsAdaptive,current,'LineWidth',3,'Color',[0.8 0 0 0.6]);
    avgCurrent = mean(current); 
    title(sprintf('Current %.2f (mean)',avgCurrent)); 
    title(sprintf('Current',avgCurrent)); 
    ylabel('Current (mA)'); 
    set(gca,'FontSize',16);
    
    figTitle = sprintf('%s %s run %.2d',adaptiveInfo(e).patient,...
        adaptiveInfo(e).duration,e);
%     sgtitle(figTitle,'FontSize',20); 
    
    figSaveName = sprintf('%.2d_embedded_%s',e,adaptiveInfo(e).patient);
    figsaveFullName = fullfile(figdir,figSaveName);
    

    % save figure; 
    xlabel('Time (seconds');
    linkaxes(hsub,'x');
    set(gca,'XLim',[duration('00:00:00') duration('00:00:39')]);
    xtickformat('mm:ss');
end
%% 


%% 

if ~plotpanels
%%    
figdirout = '/Users/roee/Starr_Lab_Folder/Writing/papers/2019_LongTerm_RCS_recordings/figures/final_figures/Fig7_effect_of_stim_and_adaptive';
hpanel.fontsize = 10; 
hLegend = findobj(gcf, 'Type', 'Legend');
hLegend(1).FontSize = 9;
hLegend(1).FontName = 'Helvetica';
hLegend(1).FontWeight = 'normal';

hpanel(1,1).de.margin = 20; 
hpanel(1,1).de.marginbottom = 20; 
hpanel(2).de.margin = 10; 
hpanel(2).margintop = 30;
hpanel.margin = [20 20 20 20];
prfig.plotwidth           = 8;
prfig.plotheight          = 10;
prfig.figdir             = figdirout;
prfig.figname             = 'Fig7_all_v5';
prfig.figtype             = '-dpdf';
plot_hfig(hfig,prfig)

end

return 

%% potentioan panel D - compare burst durations 
% open loop folder - run 3 
clear params y_filt_hilbert
params.adaptiveFolder{1}   = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/v16_adaptive_4_months_beta_thermostat/RCS02L/Session1572281066593/DeviceNPC700398H';
params.adaptiveFolder{2}   = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/v14_adaptive_before_sending_home/RCS02R/Session1570736950940/DeviceNPC700404H';
params.window           = seconds(30); % size of window you want 
params.advance          = seconds(0.1); 
params.runToPlot(1)        = 3; % run to plot - see results of plot_alligned_data_in_folder() on this folder 
params.runToPlot(2)        = 5; % run to plot - see results of plot_alligned_data_in_folder() on this folder 

for aaa = 1:length(params.adaptiveFolder)
    % plot alligned data
    dirname = params.adaptiveFolder{aaa};
    fnmload = fullfile(dirname,'all_data_alligned.mat');
    if exist(fnmload,'file')
        load_and_save_alligned_data_in_folder(dirname);
        load(fnmload,'outdatcomplete','outdatcompleteAcc','outRec',...
            'eventTable','powerOut','adaptiveTable','adaptiveStruc','senseStruc','embeddedStartEndTimes','adaptiveInfo');
    else
        load(fnmload,'outdatcomplete','outdatcompleteAcc','outRec',...
            'eventTable','powerOut','adaptiveTable','adaptiveStruc','senseStruc','embeddedStartEndTimes','adaptiveInfo');
        
    end
    figdir = fullfile(dirname,'figures');
    mkdir(figdir);
    
    % plot alligned data
    % find difference from unix time
    idxTimeCompare = find(outdatcomplete.PacketRxUnixTime~=0,1);
    packRxTimeRaw  = outdatcomplete.PacketRxUnixTime(idxTimeCompare);
    packtRxTime    =  datetime(packRxTimeRaw/1000,...
        'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
    derivedTime    = outdatcomplete.derivedTimes(idxTimeCompare);
    timeDiff       = derivedTime - packtRxTime;
    deltaUse       = seconds(20);
    startTimes = embeddedStartEndTimes.EmbeddedStart.UnixOnsetTime + timeDiff + deltaUse;
    endTimes = embeddedStartEndTimes.EmbeddedEnd.UnixOnsetTime + timeDiff - deltaUse;
    dur      = endTimes - startTimes;
    % only consider adaptive files over 30 seconds
    startTimes = startTimes(dur > seconds(30));
    endTimes = endTimes(dur > seconds(30));
    plotpanels = 1;
    for e = params.runToPlot(aaa)
        
        % suplot 2
        if plotpanels
            %         hsub(cntplt) = subplot(nrows,ncols,cntplt); cntplt = cntplt + 1;
        else
            hpanel(2,cntplt,1).select(); cntplt = cntplt + 1;
            hsub(cntplt,1) = gca;
        end
        
        hold on;
        % 1. td band passedd power
        % find the right time domain channel
        cused = adaptiveInfo(e).tdChannelUsed;
        tddata = outdatcomplete.(sprintf('key%d',cused-1));
        secs   = outdatcomplete.derivedTimes;
        idxuse = secs >= startTimes(e) & secs <= endTimes(e);
        tddata = tddata(idxuse);
        secs   = secs(idxuse);
        bandsUsed = str2num(strrep(strrep(adaptiveInfo(e).bandsUsed,'Hz',''),'-',' '));
        bandsUsed = [17.57 21.48];
        sr = adaptiveInfo(e).SampleRate;
        tddata = tddata - mean(tddata);
        [b,a]        = butter(3,[bandsUsed(1) bandsUsed(end)] / (sr/2),'bandpass'); % user 3rd order butter filter
        y_filt       = filtfilt(b,a,tddata); %filter all
        y_filt_hilbert{aaa}       = abs(hilbert(y_filt));
        secsUse{aaa} = secs; 
        
    end
end
% plot the joint 75% threshold 
hfig = figure;
clear y secsplot1 secsplot2 bursts secsburst
hfig.Color = 'w'; 
subplot(2,1,1); 
hold on;
% open loop 
idxlenopenloop = length(secsUse{1});
secsplot1 = secsUse{1}(1:idxlenopenloop) - secsUse{1}(1);
secsburst(:,1) = secsplot1; 
plot(secsplot1,y_filt_hilbert{1}(1:idxlenopenloop)) 
y(:,1) = y_filt_hilbert{1}(1:idxlenopenloop);

secsplot2 = (secsUse{2}(1:idxlenopenloop) -secsUse{2}(1))  + (secsplot1(end)+ seconds(10));
secsburst(:,2) = (secsUse{2}(1:idxlenopenloop) -secsUse{2}(1)); 
plot(secsplot2,y_filt_hilbert{2}(1:idxlenopenloop));
y(:,2) = y_filt_hilbert{2}(1:idxlenopenloop);
thresh = prctile(y(:),75);
plot([secsplot1(1) secsplot2(end)], [thresh thresh],'LineWidth',3,'LineStyle','-.'); 
legend({'open loop','adaptive','75th percentile'}); 
title('Hilbert - band passed beta')' 
ylabel('beta amtplitude envelope - hilbert'); 
xlabel('time (seconds)');
set(gca,'FontSize',16);

for i = 1:2
    up = y(:,i); 
    secs = secsburst(:,i);
    % find start and end indices of line crossing threshold
    startidx = find(diff(up > thresh) == 1) + 1;
    endidx = find(diff(up > thresh) == -1) + 1;
    endidx = endidx(endidx > startidx(1));
    startidx = startidx(1:length(endidx));
    for b = 1:size(startidx,1)
        bursts(i).len(b) = secs(endidx(b)) - secs(startidx(b));
        bursts(i).amp(b) = max(up(startidx(b):endidx(b)));
    end
end
subplot(2,1,2); 
hold on; 
histogram(seconds(bursts(1).len).*1000,'Normalization','probability','BinWidth',50);
histogram(seconds(bursts(2).len).*1000,'Normalization','probability','BinWidth',50);
legend({'open loop','adaptive'})
ylabel('probability'); 
xlabel('burst length (ms)'); 
set(gca,'FontSize',16);
%%

%% previous panel A - single subject - on , off and chornic stim 
dirsave = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/results/long_term_stim_on_stim_off'; 
load(fullfile(dirsave,'psd_at_home_stim_on_vs_stim_off.mat'),'psdResultsBoth'); 
load('/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/pkg_data/figures/pkg_states RCS02 R pkg L _10_min_avgerage.mat')
addpath(genpath(fullfile(pwd,'toolboxes','shadedErrorBar')))
if plotpanels
    hfig = figure();
    hfig.Color = 'w';
end
% on stim vs off stim 
% d = 1 - 
stimstate = {'off stim - imobile','off stim - mobile','on chronic stim'}; 
statesuse = {'off','on'};
colorsUse = [0.8 0 0;
          0   0.8 0;
          0   0   0.8];
titles = {'STN 0-2','STN 1-3','M1 8-10','M1 9-11'};
cntplt = 1;
if ~plotpanels
    hSub = gobjects(3,1);
end
for c = [2 4]
    if plotpanels
        hSub(cntplt) = subplot(2,2,cntplt); cntplt = cntplt+1;
    else
        hpanel(1,1,cntplt).select(); cntplt = cntplt + 1; 
        hSub(cntplt,1) = gca;
    end
            
    
    hold on; 
    for d = 1:3
        fn = sprintf('key%dfftOut',c-1);
        if d >=3  % on stim 
            psdResults = psdResultsBoth(2);
            fftOut = psdResults.(fn)(psdResults.idxkeep,:);
            ff = psdResults.ff;
        else
            fftOutRaw = allDataPkgRcsAcc.(fn); 
            idxusestate = strcmp(allstates,statesuse{d});
            fftOut = fftOutRaw(idxusestate,:); 
            ff = psdResults.ff;
        end
        idxusefreq = ff >= 13 &  ff <= 30; 
        meanbetafreq{c,d} = mean(fftOut(:,idxusefreq),2);
        
        idxusefreq = ff >= 65 &  ff <= 85;
        meangammafreq{c,d} = mean(fftOut(:,idxusefreq),2);
        
        % normalize the data 
        dat = fftOut;
        idxnormalize = psdResults.ff > 3 &  psdResults.ff <90;
        meandat = abs(mean(dat(:,idxnormalize),2)); % mean within range, by row
        % the absolute is to make sure 1/f curve is not flipped
        % since PSD values are negative
        meanmat = repmat(meandat,1,size(dat,2));
        dat = dat./meanmat;
        fftOut = dat;
        
        
        hsb = shadedErrorBar(ff,fftOut,{@median,@(x) std(x)*2});
        hsb.mainLine.Color = [colorsUse(d,:) 0.5];
        hsb.mainLine.LineWidth = 2;
        hsb.patch.MarkerFaceColor = colorsUse(d,:);
        hsb.patch.FaceColor = colorsUse(d,:);
        hsb.patch.EdgeColor = colorsUse(d,:);
        hsb.edge(1).Color = [colorsUse(d,:) 0.1];
        hsb.edge(2).Color = [colorsUse(d,:) 0.1];
        hsb.patch.EdgeAlpha = 0.1;
        hsb.patch.FaceAlpha = 0.1;
        xlabel('Frequency (Hz)');
        ylabel('Norm. power (a.u.)');
        title(titles{c}); 
        set(gca,'FontSize',16); 
        hlines(d) = hsb.mainLine;
        xlim([0 130]);
    end
    legend(hlines,stimstate); 
%     totalhours = (length(psdResults.timeStart(psdResults.idxkeep))*10)/60;
%     fprintf('total hours %d %s\n',totalhours,stimstate{d});
end
if plotpanels
    sgtitle('RCS02 L','FontSize',25);
    
    figname = sprintf('on stim vs off stim_ %s %s v2','RCS02','L');
    prfig.plotwidth           = 15;
    prfig.plotheight          = 10;
    prfig.figname             = figname;
    prfig.figdir              = dirsave;
    plot_hfig(hfig,prfig)
end
%% 


%% previoous panel b plot violin plots of average beta power 
addpath(genpath(fullfile(pwd,'toolboxes','violin')));
% toplot{1,1} = meanbetafreq{2,1}; % off off stim 
% toplot{1,2} = meanbetafreq{2,2}; % off off stim 
% toplot{1,3} = meanbetafreq{2,3}; % on stim 
% toplot{1,4} = [ meanbetafreq{2,1} ; meanbetafreq{2,2}];

toplot{1,1} = [ meanbetafreq{2,1} ; meanbetafreq{2,2}];
toplot{1,2} = meanbetafreq{2,3}; % on stim 


if plotpanels
    hfig = figure;
    hsb = subplot(1,1,1);
    hfig.Color = 'w';
else
    hpanel(1,1,cntplt).select(); cntplt = cntplt + 1;
    hSub(cntplt,1) = gca;
end
% hviolin  = violin(toplot);
% hviolin(1).FaceColor = [0.8 0 0];
% hviolin(1).FaceAlpha = 0.3;
% 
% hviolin(2).FaceColor = [0 0.8 0];
% hviolin(2).FaceAlpha = 0.3;
% 
% hviolin(3).FaceColor = [0 0 0.8];
% hviolin(3).FaceAlpha = 0.3;
% 
% hviolin(4).FaceColor = [0.5 0.5 0.5];
% hviolin(4).FaceAlpha = 0.3;

hviolin  = violin(toplot);
hviolin(1).FaceColor = [0.5 0.5 0.5];
hviolin(1).FaceAlpha = 0.3;

hviolin(2).FaceColor = [0 0.8 0];
hviolin(2).FaceAlpha = 0.3;


ylabel('Average beta power'); 

hsb = hSub(cntplt,1);

% hsb.XTick = [ 1 2 3 4]; 
% hsb.XTickLabel  = {'off stim imobile', 'off stim mobile','on chornic stim','before stim'}; 
hsb.XTick = [ 1 2 ]; 
hsb.XTickLabel  = {'off stim','on chornic stim'};
hsb.XTickLabelRotation = 30;

title('effect of chronic stim RCS02 L'); 

set(gca,'FontSize',16); 
if plotpanels
    figname = sprintf('on stim vs off stim_ %s %s violin','RCS02','L');
    prfig.plotwidth           = 5;
    prfig.plotheight          = 5;
    prfig.figname             = figname;
    prfig.figdir              = dirsave;
    plot_hfig(hfig,prfig)
end
%% 
