function temp_RCS06_plot_violin_plots_adaptive_dbs_vs_open_loop_vs_no_stim()
addpath(genpath(fullfile(pwd,'toolboxes','panel-2.14')));
% data dir 
rootdir = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/processed_data';

ff = findFilesBVQX(rootdir,'RCS06_L_psdAndCoherence*.mat');
dataTable = table();
for f = 1:length(ff)
    load(ff{f},'allDataCoherencePsd','database');
    allDataPkgRcsAcc = allDataCoherencePsd;
    databaseUse = database;
    allDataPkgRcsAcc.database = databaseUse;
    [pn,fn] = fileparts(ff{f});
    descriptor = fn(strfind(fn,'__'):end);
    dataTable.patient{f} = fn(1:5);
    dataTable.side{f} = fn(7);
    dataTable.stim(f) = database.stimulation_on(1);
    dataTable.descriptor{f} = descriptor;
    dataTable.allDataPkgRcsAccq{f} = allDataPkgRcsAcc;
end




width = 3;
uniquePatients = unique(dataTable.patient);
uniqueSides    = unique(dataTable.side);
cnttoplot = 1;
for s = 1:size(dataTable,1)
    dataStrucStim = dataTable.allDataPkgRcsAccq{s};
    switch dataStrucStim.database.electrodes{1}
        case '+2 -c '
            dataStrucStim.database(1,{'chan1','chan2','chan3','chan4'})
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
    switch 'RCS06'
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
    if dataStrucStim.database.stimulation_on(1)
        fnuse = stnFn_stim;
    else
        fnuse = stnFn_noStim;
    end
    ss = 1;
    %  get the data strcture
    dataStruc = dataStrucStim;
    hoursrec = hour(dataStruc.timeStartTd);
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
    ff = dataStruc.ffPsd;

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
    
    
    
    meanbetafreqNorm = mean(fftOutNorm(idxusefreq,:),1);
    meanbetafreq = mean(fftOut(idxusefreq,:),1);
    % save some of the data
    idxNum = s;
    dataTable.ff{idxNum} = ff;
    dataTable.fftOut{idxNum} = fftOut;
    dataTable.fftOutNorm{idxNum} = fftOutNorm;
    dataTable.betapeakuse(idxNum) = betapeakuse;
    dataTable.meanbetafreqNorm{idxNum} = meanbetafreqNorm;
    dataTable.meanbetafreq{idxNum} = meanbetafreq;
    
    
end
dataTable = dataTable([3 2 1],:);



%% loop on patients and plot a plot per patient with both the raw data and the violin plot
%% loop on patients and plot a plot per patient with both the raw data and the violin plot
ss = 1;
addpath(genpath(fullfile(pwd,'toolboxes','panel-2.14')));
addpath(genpath(fullfile(pwd,'toolboxes','plot_reducer')));
addpath(genpath(fullfile(pwd,'toolboxes','Violinplot-Matlab/')));
plotstruc = struct();
for t = 1:size(dataTable,1)
    fnUse = sprintf('v%d',t);
    plotstruc.(fnUse) = dataTable.meanbetafreq{t};
end
hfig = figure;
hfig.Color = 'w';
hsb = subplot(1,1,1); 
hviolin  = violinplot(plotstruc);
xtickLabelsModified = cellfun(@(x) strrep(x,'_',' '), dataTable.descriptor,'UniformOutput',0);
hsb.XTickLabel = xtickLabelsModified;
hsb.XTickLabelRotation = 45; 
ylabel('Average beta power'); 
title('Beta power comparison - stim = off,OL,CL');
set(gca,'FontSize',16); 
%%
%% plot raw data 
hfig = figure;
hfig.Color = 'w';
for t = 1:size(dataTable,1)
    subplot(3,1,t); 
    strucUse = dataTable.allDataPkgRcsAccq{t};
    y = dataTable.fftOut{t};
    if size(y,2) > 1000 
        rng(1); 
        idxChooseFrom = randperm(size(y,2));
        y = y(:,idxChooseFrom(1:1e3));
    end
    x = strucUse.ffPsd;
    plot(x,y,'Color',[0 0 0.8 0.1],'LineWidth',0.02);
    xlim([3 100]); 
    ylabel('Power');
    xlabel('Freq (Hz)'); 
    title(xtickLabelsModified{t});
    set(gca,'FontSize',16); 
end
%%

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

end