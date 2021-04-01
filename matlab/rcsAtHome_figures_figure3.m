function rcsAtHome_figures_figure3()
close all;
%%
plotpanels = 0;
addpath(genpath(fullfile(pwd,'toolboxes','panel-2.14')));
if ~plotpanels
    %%
    close all;
    for i = 1
        hfig = figure;
        hfig.Color = 'w';
        hpanel = panel();
        hpanel.pack('h',{0.25 0.75/2 0.75/2});
        hpanel(1).pack('v',{0.5 0.5});
        hpanel(1,1).pack(4,1);
        hpanel(2).pack(3,1); % panel a raw stn and m1 data
        hpanel(3).pack(3,1); % panel a raw stn and m1 data
        if i == 1
%             hpanel.select('all');
%             hpanel.identify();
        end
    end
    %%
    

end
%%

%% panel A - raw data from one patient
fignum = 3; 
figdirout = '/Users/roee/Starr_Lab_Folder/Writing/papers/2019_LongTerm_RCS_recordings/figures/1_draft2/Fig3_data_examples_in_clinic';
% original function:
% plot_chopped_data_comparisons
load('/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/in_clinic/rest_3rd_try/patientRAWDATA_in_clinic.mat')

idxuse = strcmp(datTbl.patient,'RCS07') & ...
    strcmp(datTbl.side,'R') & ...
    strcmp(datTbl.med,'off' );
% use R 0-2 9-11 for on off comparison and raw data
outdatcomplete = datTbl.data{idxuse};
times = outdatcomplete.derivedTimes;
srate = unique( outdatcomplete.samplerate );
% plot STN and M1
if plotpanels
    hfig = figure;
    hfig.Color = 'w';
end

nrows = 4; 
ncols = 1; 
cntplt = 1;
subtrac = outdatcomplete.derivedTimes(1); 
secsuse = outdatcomplete.derivedTimes - (subtrac + seconds(15));
idxchoose = secsuse > seconds(0) & secsuse <= seconds(2);
secsplot = secsuse(idxchoose);

hsb = gobjects(4,1);
titles = {'STN 0-2','STN 1-3','motor cortex 8-10','motor cortex 9-11'};
for c = 1:4
    if ~plotpanels
        hsb(c) = hpanel(1,1,cntplt,1).select(); cntplt = cntplt + 1;
    else
        hsb(c) = subplot(nrows,ncols,c);
    end
    hold on;
    fn = sprintf('key%d',c-1);
    y = outdatcomplete.(fn)(idxchoose);
    y = y-mean(y);
    y = y.*1e3;
    plot(secsplot,y,'LineWidth',1.5,'Color',[0 0 0.8 0.7]);
    hsb(c).XTick = [];
    hsb(c).YTick = [];
    hsb(c).XAxis.Visible = 'off';
    hsb(c).YAxis.Visible = 'off';
    hsb(c).Box = 'off';
    title(titles{c});
end
linkaxes(hsb,'xy');
    
% plot scale plot
ylims = hsb(4).YLim;
% vertical is 200 microvolts
plot(seconds([0.2 0.2 ]),[(ylims(1)+10) (ylims(1)+10 + 200)],'LineWidth',2,'Color',[0.5 0.5 0.5 0.7])
ylims = hsb(4).YLim;
% horizontal is 0.3 second
plot(seconds([0.2 0.5 ]),[(ylims(1)+10) (ylims(1)+10)],'LineWidth',2,'Color',[0.5 0.5 0.5 0.7])

if plotpanels
    prfig.plotwidth           = 3;
    prfig.plotheight          = 4;
    prfig.figdir             = figdirout;
    prfig.figname             = sprintf('Fig%d_panelA',fignum);
    prfig.figtype             = '-dpdf';
    plot_hfig(hfig,prfig)
    close(hfig);
end
%%
%% panel B- psd in clinic - on off from one patient
plotIndividLines = 1; % don't plot shaded error bards 

if plotpanels
    close all; clear all;
end
addpath(genpath(fullfile(pwd,'toolboxes','shadedErrorBar')))
fignum = 3; 
figdirout = '/Users/roee/Starr_Lab_Folder/Writing/papers/2019_LongTerm_RCS_recordings/figures';
load('/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/in_clinic/rest_3rd_try/patientPSD_in_clinic.mat');
% load(fnmsave,'patientPSD_in_clinic','patientCOH_in_clinic');

% original function:
% plot_chopped_data_comparisons
colorsUse   = [ [27 158  119]./255  , 0.5; [217 95 2]./255 0.75];
medstates = {'on','off'};
electrodes = {'STN 0-2','M1 9-11'};
datTabl = patientPSD_in_clinic;
cntplt = 1;
if plotpanels
    hfig = figure;
    hfig.Color = 'w';
end
hsb = gobjects(3,1);
for e = 1:2
    if ~plotpanels
        hsb(e,1) = hpanel(2,cntplt,1).select(); cntplt = cntplt + 1;
    else
        hsb(1) = subplot(2,1,cntplt); cntplt = cntplt +1;
    end
    hold on;
    for m = 1:2
        idxuse = strcmp(datTabl.patient,'RCS02') & ...
            strcmp(datTabl.side,'R') & ...
            strcmp(datTabl.electrode,electrodes{e}) & ...
            strcmp(datTabl.medstate,medstates{m} );
        % plot
        plot(datTabl.ff{idxuse},datTabl.fftOutNorm{idxuse},'LineWidth',1.5,'Color',colorsUse(m,:));
        
    end
    xlim(hsb(e,1),[3.5 89.5]);
    ttluse = sprintf('%s',electrodes{e});
    title(ttluse,'FontName','Arial','FontSize',16);
    set(gca,'FontName','Arial','FontSize',16);
    
    ylabel('Norm. Power','FontName','Arial','FontSize',11);
    
    if e == 1
        hLeg = legend({'defined on','defined off'},'FontName','Arial','FontSize',7);
        hLeg.Box = 'off';
    end
    hsb(e,1).XTick = [];
    % change scale of psd labels from 0-1 (it's a hack, but easier this
    % way).
    ylimits =    hsb(e,1).YLim;
    newTicks = linspace(ylimits(1),ylimits(2),5);
    
    hsb(e,1).YTick = newTicks;
    newYLabels = rescale(newTicks,0,1);
    for y = 1:length(newYLabels)
        newLabels{y,1} = sprintf('%.2f',newYLabels(y));
    end
    hsb(e,1).YTickLabel = newLabels;
    set(gca,'xlimmode','manual','ylimmode','manual')

end
% plot coherence between 
hsb(cntplt,1) = hpanel(2,cntplt,1).select();
hsb = hsb(cntplt,1);
hold(hsb,'on');
for m = 1:2
    idxCoh    = strcmp(patientCOH_in_clinic.patient,'RCS02') & ...
        strcmp(patientCOH_in_clinic.side,'R') & ...
        strcmp(patientCOH_in_clinic.chan1,'STN 0-2') & ...
        strcmp(patientCOH_in_clinic.chan2,'M1 9-11') & ...
         strcmp(patientCOH_in_clinic.medstate,medstates{m} );
    
    cohPlot = patientCOH_in_clinic(idxCoh,:);
    x = cohPlot.ffCoh{1};
    y = cohPlot.mscoherence{1};
    plot(x,y,...
        'LineWidth',1.5,'Color',colorsUse(m,:));
end
xlabel('Frequency (Hz)','FontName','Arial','FontSize',11);
ylabel('ms coherence'); 
title('coherence between STN and MC'); 
xlim(hsb,[3.5 89.5]);

        

if plotpanels
    prfig.plotwidth           = 4;
    prfig.plotheight          = 4;
    prfig.figdir             = figdirout;
    prfig.figname             = sprintf('Fig%d_panelB',fignum);
    prfig.figtype             = '-dpdf';
    plot_hfig(hfig,prfig)
    close(hfig);
end
%% psd data at in clinic - average acros patients and montages for STN 
if plotpanels
    clc; close all; 
end
addpath(genpath(fullfile(pwd,'toolboxes','GEEQBOX')));
fignum = 4; 
figdirout = '/Users/roee/Starr_Lab_Folder/Writing/papers/2019_LongTerm_RCS_recordings/figures';
% original function:
% plot_chopped_data_comparisons
%plot normalized data across patients 
dirname = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/in_clinic/rest_3rd_try';
fnmsave = fullfile(dirname,'patientPSD_in_clinic.mat');
load(fnmsave);


pdb = patientPSD_in_clinic;
% normalized the psds 
psdall = []; 
ff = []; 
for i = 1:size(pdb)
    ff = pdb.ff{i};
    idxnorm = ff >=5 & ff <=90;
    psdall(i,:) = pdb.fftOutNorm{i}(:,idxnorm);
end
freqschecking = ff(idxnorm); 
% plot
if plotpanels
    hfig = figure;
    hfig.Color = 'w';
end

% loop on area and do STATS PSDS for all patients 
areas = {'STN 1-3','M1 8-10'}; 
areas = {'STN','M1'}; 
titlesUse = {'STN contacts','M1 contacts'};

medstatecheck = {'on','off'};
colorsuse = [0 0.8 0 0.5; 0.8 0 0 0.5]; 
colorsuse = [0 0.8 0 0.5; 0.8 0 0 0.5]; 
colorsuse   = [ [27 158  119]./255  , 0.75; [217 95 2]./255 0.75];

for a = 1:length(areas)
    if ~plotpanels
        hsb(e,2) = hpanel(3,a,1).select(); cntplt = cntplt + 1;
    else
        subplot(1,1,a);
    end

    hold on;
    for m = 1:length(medstatecheck) 
        idxkeep = cellfun(@(x) any(strfind(x,areas{a})), pdb.electrode) &  ...
                  strcmp(pdb.medstate,medstatecheck{m});
        idxkeepout(:,m) = idxkeep;
        fftout  = psdall(idxkeep,:); 
        
        x = freqschecking; 
        y = fftout; 
        
        if plotIndividLines
            hplt = plot(x,y,'LineWidth',0.2,'Color',[colorsuse(m,1:3) 0.5]);
            hLine(m) = hplt(1);
        else
            % stadnard error or mean
            %         hsbH = shadedErrorBar(x,y,{@median,@(y) std(y)./sqrt(size(y,1))});
            % 1 std
            hsbH = shadedErrorBar(freqschecking,fftout,{@mean,@(x) std(x)*1});
            
            hsbH.mainLine.Color = colorsuse(m,:);
            hsbH.mainLine.LineWidth = 0.5;
            hsbH.patch.FaceAlpha = 0.5;
            hsbH.patch.FaceColor = colorsuse(m,1:3);
            hsbH.edge(1).Color = [1 1 1];
            hsbH.edge(2).Color = [1 1 1];
            hsbH.edge(1).Visible = 'off';
            hsbH.edge(2).Visible = 'off';
            hLine(m) = hsbH.mainLine;
        end
    end

    
    % %%%%%%%%%%%%%%%%%%%%%%%%% do stats
    % %%%%%%%%%%%%%%%%%%%%%%%%% do stats
    % %%%%%%%%%%%%%%%%%%%%%%%%% do stats
    idxstats = (idxkeepout(:,1) | idxkeepout(:,2));
    pdbSTN = pdb(idxstats,:);
    
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
            X = [medstate, side, const];
            varnames ={'med state','side','const'};
            [betahat, alphahat, results] = gee(id, meanfreqs, medstate, X, 'n', 'equi', varnames);
            pvals(sf) = results.model{3,5};
        end
        siglog = logical(pvals<= (0.05./size(freqranges,1)));
        freqnames(siglog);
    end
    
    % do states for each frequency
    psdcheck = psdall(idxstats,:);
    for f = 1:size(freqschecking,2)
        meanfreq = [] ;
        meanfreq = psdcheck(:,f);
        const = ones(size(meanfreq,1),1);
        X = [medstate, side, const];
        varnames ={'med state','side','const'};
        [betahat, alphahat, results] = gee(id, meanfreq, medstate, X, 'n', 'equi', varnames);
        pvals(f) = results.model{3,5};
    end
    siglog = logical(pvals <= (0.05./length(freqschecking))  );
    freqssig = freqschecking(siglog);
    cntsig = 1; 
    xfreqssig = [];
    D = diff([0,siglog,0]);
    b.beg = find(D == 1);
    b.end = find(D == -1) - 1;
    xfreqssig(:,1) = freqschecking(b.beg);
    xfreqssig(:,2) = freqschecking(b.end);
    ylims = get(gca,'YLim');
    if ~isempty(xfreqssig)
        plot(xfreqssig,[ylims(2) ylims(2)],'Color',[0.5 0.5 0.5],'LineWidth',2);
    else
        fprintf('nothing sign mc');
    end
    % %%%%%%%%%%%%%%%%%%%%%%%%% do stats
    % %%%%%%%%%%%%%%%%%%%%%%%%% do stats
    % %%%%%%%%%%%%%%%%%%%%%%%%% do stats
    if a == 1 
        hLegend = legend(hLine,{'defined on','defined off'},'FontSize',7);
        hLegend.Box = 'off';
    end
    xlim([5 90]);
%     xlabel('Frequency (Hz)');
    
    % change scale of psd labels from 0-1 (it's a hack, but easier this
    % way).
    ylimits =    hsb(e,2).YLim;
    newTicks = linspace(ylimits(1),ylimits(2),5);
    
    hsb(e,2).YTick = newTicks;
    newYLabels = rescale(newTicks,0,1);
    for y = 1:length(newYLabels)
        newLabels{y,1} = sprintf('%.2f',newYLabels(y));
    end
    hsb(e,2).YTickLabel = newLabels;
    set(gca,'xlimmode','manual','ylimmode','manual')
    
    ylabel('Norm. power');
    hsb = gca;
    hsb.XTick = [];
    title(titlesUse{a});
    set(gca,'FontSize',16);
end





% loop on area and do STATS COHERNCE  for all patients 
areas = {'STN 1-3','M1 8-10'}; 
areas = {'STN','M1'}; 
titlesUse = {'STN contacts','M1 contacts'};

medstatecheck = {'on','off'};
pdb = patientCOH_in_clinic;
psdall = []; 
ff = []; 
for i = 1:size(pdb)
    ff = pdb.ffCoh{i};
    idxnorm = ff >=5 & ff <=90;
    psdall(i,:) = pdb.mscoherence{i}(idxnorm)';
end


hsb(3,2) = hpanel(3,3,1).select(); cntplt = cntplt + 1;
hold on;
for m = 1:length(medstatecheck)
    idxkeep = strcmp(pdb.medstate,medstatecheck{m});
    idxkeepout(:,m) = idxkeep;
    fftout  = psdall(idxkeep,:);
    
    x = ff(idxnorm);
    y = fftout;
    
    if plotIndividLines
        hplt = plot(x,y,'LineWidth',0.2,'Color',[colorsuse(m,1:3) 0.5]);
        hLine(m) = hplt(1);
    else
        % stadnard error or mean
        %     hsbH = shadedErrorBar(x',y,{@median,@(y) std(y)./sqrt(size(y,1))});
        % 1 std
        hsbH = shadedErrorBar(x',y,{@mean,@(x) std(x)*1});
        
        
        hsbH.mainLine.Color = colorsuse(m,:);
        hsbH.mainLine.LineWidth = 0.5;
        hsbH.patch.FaceAlpha = 0.5;
        hsbH.patch.FaceColor = colorsuse(m,1:3);
        hsbH.edge(1).Color = [1 1 1];
        hsbH.edge(2).Color = [1 1 1];
        hsbH.edge(1).Visible = 'off';
        hsbH.edge(2).Visible = 'off';
        hLine(m) = hsbH.mainLine;
    end
end


% %%%%%%%%%%%%%%%%%%%%%%%%% do stats
% %%%%%%%%%%%%%%%%%%%%%%%%% do stats
% %%%%%%%%%%%%%%%%%%%%%%%%% do stats
idxstats = (idxkeepout(:,1) | idxkeepout(:,2));
pdbSTN = pdb(idxstats,:);

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

medstate = zeros(size(pdbSTN,1),1);
medstate( strcmp(pdbSTN.medstate,'on') ) = 1;
medstate( strcmp(pdbSTN.medstate,'off') ) = 2;

side = zeros(size(pdbSTN,1),1);
side( strcmp(pdbSTN.side,'L') ) = 1;
side( strcmp(pdbSTN.side,'R') ) = 2;



% do stats for each frequency
psdcheck = psdall(idxstats,:);
for f = 1:size(freqschecking,2)
    meanfreq = [] ;
    meanfreq = psdcheck(:,f);
    const = ones(size(meanfreq,1),1);
    X = [medstate, side, const];
    varnames ={'med state','side','const'};
    [betahat, alphahat, results] = gee(id, meanfreq, medstate, X, 'n', 'equi', varnames);
    pvals(f) = results.model{3,5};
end
siglog = logical(pvals <= (0.05./length(freqschecking))  );
freqssig = freqschecking(siglog);
cntsig = 1;
xfreqssig = [];
D = diff([0,siglog,0]);
b.beg = find(D == 1);
b.end = find(D == -1) - 1;
xfreqssig(:,1) = freqschecking(b.beg);
xfreqssig(:,2) = freqschecking(b.end);
ylims = get(gca,'YLim');
if ~isempty(xfreqssig)
    plot(xfreqssig,[ylims(2) ylims(2)],'Color',[0.5 0.5 0.5],'LineWidth',2);
end
% %%%%%%%%%%%%%%%%%%%%%%%%% do stats
% %%%%%%%%%%%%%%%%%%%%%%%%% do stats
% %%%%%%%%%%%%%%%%%%%%%%%%% do stats
% legend(hLine,{'defined on','defined off'});
xlim([5 90]);



xlabel('Frequency (Hz)');
ylabel('ms coherence');
title(titlesUse{a});
set(gca,'FontSize',16);

hsb(3,2).YLim(1) = 0;

% % change scale of psd labels from 0-1 (it's a hack, but easier this
% % way).
% e = 3;
% ylimits =    hsb(e,2).YLim;
% newTicks = linspace(ylimits(1),ylimits(2),5);
% 
% hsb(e,2).YTick = newTicks;
% newYLabels = rescale(newTicks,0,1);
% for y = 1:length(newYLabels)
%     newLabels{y,1} = sprintf('%.2f',newYLabels(y));
% end
% hsb(e,2).YTickLabel = newLabels;
set(gca,'xlimmode','manual','ylimmode','manual')



if plotpanels
    sgtitle('Defined on/off in clinic (8 STNs, 5 patients)','FontSize',12);
    
    prfig.plotwidth           = 4.4;
    prfig.plotheight          = 4.4;
    prfig.figdir             = figdirout;
    prfig.figname             = sprintf('Fig%d_panelA',fignum);
    prfig.figtype             = '-dpdf';
    plot_hfig(hfig,prfig)
    close(hfig);
end
%% 

%% panel B - movement related activity 
hfigmove = openfig('/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS07/v16_3week/figures/ipad_spectrogram_baseline--1000--500_hold_center_fir1.fig'); 
ax = hfigmove.Children(5);
hsurf = ax.Children(3); 
x = hsurf.XData;
x = x./1000;
y = hsurf.YData;
z = hsurf.ZData; 
cmap = hsurf.CData;
ylims = ax.YLim;
close(hfigmove);

hsb = gobjects(1,1); 
if ~plotpanels
    hsb = hpanel(1,2).select(); 
else
    hfig = figure;
    subplot(1,1,a);
end


hold on; 
cmax = 2; 
cmin = -cmax;
hp = pcolor(x,y,cmap);
shading interp;
caxis([cmin cmax]);
hcolor = colorbar; 
hcolor.Label.String = 'Z-score'; 
xlabel('time (s)');
ylabel('Frequency (Hz)'); 
hline = plot([3 3], [ylims(1) ylims(2)],'LineWidth',3,'Color',[0 0 0 0.8]);
axis tight 
xlim([0 7]); 
ttlsuse{1,1} = 'Movement related cortical activity'; 
ttlsuse{1,2} = 'motor cortex 8-10'; 
title(ttlsuse); 

% fix some title and font sizes - indiv subjects 
hsb = hpanel(2,1,1).select();
hsb.FontSize = 12; 
hsb.Title.String = 'STN 0-2';
hsb.Title.FontSize = 14;

hsb = hpanel(2,2,1).select();
hsb.FontSize = 12; 
hsb.Title.String = 'motor cortex 9-11';
hsb.Title.FontSize = 14;

hsb = hpanel(2,3,1).select();
hsb.Title.String = 'STN-motor cortex coherence';
hsb.FontSize = 12; 
hsb.Title.FontSize = 14;

% fix some title and font sizes - group data 
hsb = hpanel(2,1,1).select();
hsb.FontSize = 12; 
hsb.Title.String = 'STN';
hsb.Title.FontSize = 14;

hsb = hpanel(2,2,1).select();
hsb.FontSize = 12; 
hsb.Title.String = 'motor cortex';
hsb.Title.FontSize = 14;

hsb = hpanel(2,3,1).select();
hsb.Title.String = 'STN-motor cortex coherence';
hsb.FontSize = 12; 
hsb.Title.FontSize = 14;



% to plot vecot uncomment this 
delete(hp);
% to plot jpeg on comment this: 
delete(hline); 
    hsb = hpanel(1,2).select(); 
hsb.Box = 'off';
hsb.XTick = [];
hsb.XLabel.String = '';
hsb.YLabel.String = '';
hsb.YTick = [] ;
hsb.XAxis.Visible = 'off';
hsb.YAxis.Visible = 'off';


%% 
if ~plotpanels
    %% plot all 
    figdirout = '/Users/roee/Box/rcs paper paper on first five bilateral implants/revision for nature biotechnology/figures/Fig3_data_examples_in_clinic';
    hpanel.fontsize = 6;
    hpanel.de.fontsize = 6;
    hpanel.de.margin = 7;
    hpanel(1).marginright = 40;
    hpanel(2).marginright = 15;
    

    
    
    prfig.plotwidth           = 7.08;
    prfig.plotheight          = 4.42;
    prfig.figdir             = figdirout;
    prfig.figname             = 'Fig3_all_nomovement_just_stn_vector_v8_not_vector_IND';
    prfig.figtype             = '-dpdf';
    plot_hfig(hfig,prfig)
    %%
end
return 















%% previous stuff 
%% panel C - psd at home - all raw data 10 minute - across all states 
% note that this is a moving 2 minute 10 minute average - since using the
% PKG as basis for this 
close all; clear all;
fignum = 3; 
figdirout = '/Users/roee/Starr_Lab_Folder/Writing/papers/2019_LongTerm_RCS_recordings/figures';
% original function:
% plot_pkg_data_all_subjects
load('/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/pkg_data/figures/data_paper/mean_normalized_psd_all_psds RCS02 R pkg L 10_min_avgerage.mat');
hfig = figure;
hfig.Color = 'w';
titles = {'STN 0-2','STN 1-3','M1 8-10','M1 9-11'};
labelsCheck = [];
for c = 1
    hsb(c) = subplot(1,1,c);
    cla(hsb(c));
    fn = sprintf('key%dfftOut',c-1);
    dat = allDataPkgRcsAcc.(fn);
    idxnormalize = psdResults.ff > 3 &  psdResults.ff <90;
    meandat = abs(mean(dat(:,idxnormalize),2)); % mean within range, by row
    % the absolute is to make sure 1/f curve is not flipped
    % since PSD values are negative
    meanmat = repmat(meandat,1,size(dat,2));
    dat = dat./meanmat;
    normalizedPSD = dat;
    frequency = psdResults.ff';
    plot(psdResults.ff', dat,'LineWidth',0.1,'Color',[0 0 0.8 0.1]);
    xlim([3 100]);
    xlabel('Time (Hz)','FontName','Arial','FontSize',11);
    ylabel('Norm Power','FontName','Arial','FontSize',11);
    ttluse = sprintf('All raw data %.1f hours', ((size(dat,1).*10)/60)/2);
    title(ttluse,'FontName','Arial','FontSize',11);
    set(gca,'FontName','Arial','FontSize',11);
end
hfig.RendererMode = 'manual';
hfig.Renderer = 'painters';
prfig.plotwidth           = 3.5;
prfig.plotheight          = 3;
prfig.figdir             = figdirout;
prfig.figname             = sprintf('Fig%d_panelC',fignum);
prfig.figtype             = '-dpdf';
plot_hfig(hfig,prfig)
close(hfig);

%%

%% panel D - psd at home - data seperated by state 
% note that this is a moving 2 minute 10 minute average - since using the
% PKG as basis for this 
close all; clear all;
fignum = 3; 
addpath(genpath(fullfile(pwd,'toolboxes','shadedErrorBar')))
figdirout = '/Users/roee/Starr_Lab_Folder/Writing/papers/2019_LongTerm_RCS_recordings/figures';
% original function:
% plot_pkg_data_all_subjects
load('/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/pkg_data/figures/data_paper/pkg_states RCS02 R pkg L _10_min_avgerage.mat');
cntplt = 1; 
titles = {'STN 0-2','STN 1-3','M1 8-10','M1 9-11'};
colors = [0.8 0 0; 0 0.8 0;0 0 0.8; 0.5 0.5 0.5];
colors2 = {'r','g','b','k'};
hfig = figure; 
hfig.Color = 'w';
for c = [1 4]
    hsb(cntplt) = subplot(2,1,cntplt); cntplt = cntplt + 1;
    hold on;
    statesUsing = {};cntstt = 1;
    for s = 1:length(statesUse)
        fn = sprintf('key%dfftOut',c-1);
        labels = strcmp(allstates,statesUse{s});
        labelsCheck(:,s) = labels;
        
        dat = [];
        dat = allDataPkgRcsAcc.(fn);
        idxnormalize = psdResults.ff > 3 &  psdResults.ff <90;
        meandat = abs(mean(dat(:,idxnormalize),2)); % mean within range, by row
        % the absolute is to make sure 1/f curve is not flipped
        % since PSD values are negative
        meanmat = repmat(meandat,1,size(dat,2));
        dat = dat./meanmat;
        
        
        if sum(labels)>=1
            hsbH = shadedErrorBar(psdResults.ff,dat(labels,:),{@mean,@(x) std(x)*2},...
                'lineprops',{colors2{s},'markerfacecolor','r','LineWidth',2});
            statesUsing{cntstt} = statesUse{s};cntstt = cntstt + 1;
            hsbH.mainLine.Color = [colors(s,:) 0.5];
            hsbH.mainLine.LineWidth = 1.5;
            hsbH.patch.FaceAlpha = 0.1;
        end
        % save the median data
        
        rawdat = allDataPkgRcsAcc.(fn);
        rawdat = rawdat(labels,:);
        
        hLegend = legend(statesUsing);
        xlim([3 100]);
        xlabel('Time (Hz)','FontName','Arial','FontSize',11);
        ylabel('Norm Power','FontName','Arial','FontSize',11);
        ttluse = sprintf('%s',titles{c});
        title(ttluse,'FontName','Arial','FontSize',11);
        set(gca,'FontName','Arial','FontSize',11);
    end
end
hfig.RendererMode = 'manual';
hfig.Renderer = 'painters';
prfig.plotwidth           = 4;
prfig.plotheight          = 4;
prfig.figdir             = figdirout;
prfig.figname             = sprintf('Fig%d_panelD',fignum);
prfig.figtype             = '-dpdf';
plot_hfig(hfig,prfig)
close(hfig);


end