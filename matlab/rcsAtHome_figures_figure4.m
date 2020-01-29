function rcsAtHome_figures_figure4()
%% single subject data 
% this figure shows the single subject data  
%% 
% panel a - beav data from pkg monitor
% panel b - transition in motor state - psd and coherence in spectrogram form
% panel c - psd at home - all raw data 10 minute - across all states
close all;
plotpanels = 0;
addpath(genpath(fullfile(pwd,'toolboxes','panel-2.14')));
if ~plotpanels
    hfig = figure;
    hfig.Color = 'w';
    hfig.Position = [1000         547        1020         791];
    hpanel = panel();
    hpanel.pack(1,2);
    hpanel(1,1).pack([0.4 0.6]); 
    hpanel(1,1,1).pack({0.45 0.45 0.1});% panel a - behav data from
    hpanel(1,1,2).pack(3,1); % panel c - psd at home 
    hpanel(1,2).pack(4,1); % panel b  psd at home 
%     hpanel.select('all');
%     hpanel.identify();
end
%%

%% panel a - beav data from pkg monitor 
% plot on day example of PKG data per patient 
% data from wearable PKG monitor reports scores for bradykinesia and dyskinesia in 10 minute intervals. Example from 1 day for RCS02
pkgdatdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/pkg_data/processed_data';
figdirout = '/Users/roee/Starr_Lab_Folder/Writing/papers/2019_LongTerm_RCS_recordings/figures/1_draft2/Fig4_state_decoding_single_subject';
resultsdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home';
load(fullfile(pkgdatdir,'pkgDataBaseProcessed.mat'),'pkgDB');

uniqePatients = unique(pkgDB.patient); 
uniqeSides    = unique(pkgDB.side); 

for p = 1 % 1:length(uniqePatients)
    for s = 2% 1:length(uniqeSides)
        idxpat = strcmp(uniqePatients{p},pkgDB.patient) &  strcmp(uniqeSides{s},pkgDB.side); 
        load(pkgDB.savefn{idxpat}); 
        unqdays = unique(pkgTable.Day);
        for d = 5%1:length(unqdays)
            if plotpanels
                hfig = figure;
                hfig.Color = 'w';
            end
            idxuse = pkgTable.Day == unqdays(d); 
            times = pkgTable.Date_Time(idxuse,:); 
            dkvals = pkgTable.DK(idxuse,:);
            dkvals(dkvals==0) = 0.1;
            dkvals = log10(dkvals);
            bkvals = pkgTable.BK(idxuse,:);
            bkvals = abs(bkvals);
            % bk vals 
            if plotpanels
                hsb(1) = subplot(21,1,[1:9]);
            else
                hpanel(1,1,1,1).select();
                hsb(1) = gca;
            end
            hold on; 
            mrksize = 8; 
            alphause = 0.3; 
            scatter(times,bkvals,mrksize,'filled','MarkerFaceColor',[0 0 0],'MarkerFaceAlpha',alphause);
            xlims = get(hsb(1),'XLim');
            hp(2) = plot(xlims,[80 80],'LineWidth',2,'Color',[0.5 0.5 0.5],'LineStyle','-.');
            bkmovemean = movmean(bkvals,[5 5]);
            plot(times,bkmovemean,'LineWidth',1,'Color',[0 0 0 0.5]);
            hsb(1).XTick = []; 
            hsb(1).XTickLabel = '';
%             hsb(1).YTick = []; 
%             hsb(1).YTickLabel = ''; 
            
            title('bradykinesia (BK) score'); 
            ylabel('BK score (a.u.)'); 
            set(gca,'FontSize',12); 
%             hp(1) = plot(xlims,[26 26],'LineWidth',2,'Color','r','LineStyle','-.');
%             hp(2) = plot(xlims,[80 80],'LineWidth',2,'Color','k','LineStyle','-.');

            
            % dk vals             
            if plotpanels
                hsb(2) = subplot(21,1,[1:9]);
            else
                hpanel(1,1,1,2).select();
                hsb(2) = gca;
            end
            
            hold on; 
            scatter(times,dkvals,mrksize,'filled','MarkerFaceColor',[0 0 0],'MarkerFaceAlpha',alphause);
            
            dkmovemean = movmean(dkvals,[5 5]); 
            plot(times,dkmovemean,'LineWidth',1,'Color',[0 0 0 0.5]); 
            xlims = get(gca,'XLim'); 
%             hp(3) = plot(xlims,[log10(7) log10(7)],'LineWidth',2,'Color',[0 0.8 0],'LineStyle','-.');
%             hp(4) = plot(xlims,[log10(16) log10(16)],'LineWidth',2,'Color',[0 0.8 0],'LineStyle','-.');

            title('dyskinesia (DK) score'); 
            ylabel('DK score (a.u.)');
            set(gca,'FontSize',12); 
            
            hsb(2).XTick = [];
            hsb(2).XTickLabel = '';
%             hsb(2).YTick = [];
%             hsb(2).YTickLabel = '';
            
            
            
            
            % plot state 
            if plotpanels
                hsb(3) = subplot(21,1,20:21);
                hold on; 
            else
                hpanel(1,1,1,3).select();
                hsb(3) = gca;
            end
            
            hold on;
            rawstates = pkgTable.states(idxuse); 

            
            switch uniqePatients{p}
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
            otheridx =  ~(sleeidx | onidx | offidx);
            
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
                        
            hbrsleep = bar(times(sleeidx),repmat(-0.2,1,sum(sleeidx)),'stacked');
            hbrsleep.FaceColor = [0 0 0.8];
            hbrsleep.FaceAlpha = 0.6;
            hbrsleep.EdgeColor = 'none';
            hbrsleep.BarWidth = 1;

            
                                    
            hbrother = bar(times(otheridx),repmat(-0.2,1,sum(otheridx)),'stacked');
            hbrother.FaceColor = [0.5 0.5 0.5];
            hbrother.FaceAlpha = 0.6;
            hbrother.EdgeColor = 'none';
            hbrother.BarWidth = 1;

            
            legend([ hbron hbroff hbrsleep hbrother],{'on','off','sleep','other'});
            title('state classification'); 
            
            hsb(3).YTick = [];
            hsb(3).YTickLabel = '';
            if plotpanels
            hsb(3).Position(4) = hsb(3).Position(4)*0.6;
            hsb(2).Position(4) = hsb(2).Position(4)*0.9;
            hsb(1).Position(4) = hsb(1).Position(4)*0.9;
            end
            % set limits 
            linkaxes(hsb,'x');
            
            xlimsVec = datevec(xlims);
            xlimsVec(:,4) = [4;0];
            xlimsNew = datetime(xlimsVec);

            datetick('x','HH:MM');
            set(gca,'XLim',xlimsNew); 
            titluse = sprintf('%s %s day - %d',uniqePatients{p},uniqeSides{s},unqdays(d));
            
            
            if plotpanels
                sgtitle(titluse,'FontSize',12); 
                prfig.plotwidth           = 11;
                prfig.plotheight          = 6;
                prfig.figdir             = figdirout;
                prfig.figname             = sprintf('Fig4_panelA_%s %s day - %d.pdf',uniqePatients{p},uniqeSides{s},unqdays(d));
                plot_hfig(hfig,prfig)
                
                close(hfig);
            end

        end
    end
end
%% 

%% panel b - transition in motor state - psd and coherence in spectrogram form

% Figure 4 ? for the example spectrogram its looking good 
% but would make those lines of discontinuity different/less prominent, maybe narrower and a softer color like gray to be less distracting.
fignum = 4; 
load('/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home/coherence_and_psd RCS02 L pkg R.mat');
figdirout = '/Users/roee/Starr_Lab_Folder/Writing/papers/2019_LongTerm_RCS_recordings/figures/1_draft2/Fig4_state_decoding_single_subject';
usetime = 0; % if usetime is 1 it will plot according to time of day so you can see gaps 
% otherwise it will plot everything in idx units and fill out time after
% the fact 

if plotpanels
    hfig = figure;
    hfig.Color = 'w';
    cntplt = 1;
    numplots = 4;
else
    cntplt = 1;
    numplots = 4;
end


% STN %%%
hsb = [];
ttls = {'STN','M1','coherence stn-m1'};
fieldnamesuse = {'key0fftOut','key2fftOut','stn02m10810'};
hsb = gobjects(3,1);
for c = 1:3
    if plotpanels
        hsb(cntplt) = subplot(numplots,1,cntplt); cntplt = cntplt + 1;
    else
        hpanel(1,2,cntplt,1).select(); % loop on 3rd position; 
        hsb(cntplt) = gca;
        cntplt = cntplt + 1;
    end
    idxuse = 300:500;
    ffts = []; idxnormalize = []; times = []; idxzero =[];
    
    ffts = allDataPkgRcsAcc.(fieldnamesuse{c});
    
    idxnormalize = psdResults.ff > 3 &  psdResults.ff <90;
    if c == 3 
        freqs = cohResults.ff; 
    else
        freqs = psdResults.ff;
    end
    meandat = abs(mean(ffts(:,idxnormalize),2)); % mean within range, by row
    % the absolute is to make sure 1/f curve is not flipped
    % since PSD values are negative
    meanmat = repmat(meandat,1,size(ffts,2));
    ffts = ffts./meanmat;
    
    if ~usetime % if I am not using time, change the idx zeros to only have a gap of 1 value
        % get rid of idxzero in idxuse
        % change idxzero to account for areas to leave a line
        times = allDataPkgRcsAcc.timeStart(idxuse);
        idxzero = diff(times) ~= minutes(2) ;
        idxlines = [diff(idxzero)==1 0]; % locations of lines
        idxGaps = idxuse(logical(idxlines));
        idxuse = idxuse(~idxzero);
    end
    
    % imagesc(ffts(idxuse,:)');
    times = allDataPkgRcsAcc.timeStart(idxuse);
    fftsUse = ffts(idxuse,:);
    dkvals  = allDataPkgRcsAcc.dkVals(idxuse); 
    
    % change to either plot data in times or in idx units
    timesrep = repmat(times,size(fftsUse,2),1)';
    frequse  = repmat(freqs,1,size(fftsUse,1))';
    
    % only plot non gap areas
    idxzero = find(diff(times) ~= minutes(2))+1 ;
    for i = 1:length(idxzero)
        fftsUse(idxzero(i),:) = NaN;
    end
    
    gaps = times(find(diff(times)~=minutes(2)==1) +1 ) -times(find(diff(times)~=minutes(2)==1)  );
        fprintf('total time %s\n',times(end)-times(1));
    fprintf('gap mean %s (range %s-%s)\n',mean(gaps),min(gaps),max(gaps));

    
    % change to either plot data in times or in idx units
    timesrep = repmat(times,size(fftsUse,2),1)';
    if usetime
        timesmat = datenum(timesrep);
        timevec = datenum(times);
    else
        timevec = 1:length(times);
        timesmat = repmat(timevec,size(fftsUse,2),1)';
        
        % don't incldue lines
        loclines = [ (diff(times) ~= minutes(2)) logical(0)];
        timediff = [logical(1) ~(diff(times) ~= minutes(2))];
        loclines = find(loclines(timediff)==1) + 1;
        timevec = 1:sum(timediff);
        fftsUse = fftsUse(timediff,:);
        dkvals  = dkvals(timediff); 
        timesmat = repmat(timevec,size(fftsUse,2),1)';
        frequse  = repmat(freqs,1,size(fftsUse,1))';
    end
    
    h = pcolor(timesmat, frequse,fftsUse);
    hc = colorbar;
    hc.Label.String = 'Norm power (a.u.)';
    hold on;
    set(h, 'EdgeColor', 'none');
    
    set(gca,'YDir','normal')
    ylim([1 100]);
    title(ttls{cntplt-1});
    if usetime
        datetick('x','dd-mm HH:MM');
    else
        ylims = get(gca,'YLim');
        plot([loclines',loclines']',ylims,'LineWidth',1,'Color',[0.5 0.5 0.5 0.5]);
    end
    ylabel('Frequency (Hz)');
    hsb(cntplt-1).XTick = [];
end



% dyskeinsia values
if plotpanels
    hsb(cntplt) = subplot(numplots,1,cntplt); cntplt = cntplt + 1;
else
    hpanel(1,2,cntplt,1).select(); % loop on 3rd position;
    hsb(cntplt) = gca;
end
hold on;
dkvals(dkvals==0) = 0.1;
dkvals = log10(dkvals);
scatter(timevec, dkvals,...
    10,'filled','MarkerFaceColor',[0 0 0],'MarkerFaceAlpha',0.5);

movData = movmean(dkvals,[10 10]);

plot(timevec,movData,'LineWidth',1,...
    'Color',[0 0 0 0.5]); 
title('Dyskinesia'); 

linkaxes(hsb,'x'); 
axis tight;

if usetime
    datetick('x','dd-mm HH:MM');
else
    for i = 1:length(hsb(numplots).XTick)
       labraw = hsb(numplots).XTickLabel(i);
       labuse = datetime(times(str2num(labraw{1})),'Format','h:mm');
       hsb(numplots).XTickLabel{i} = sprintf('%s',labuse);
    end
%     hsb(numplots).XTickLabel{1} = '';
%     hsb(numplots).XTickLabel{end} = '';
    
end
xlabel('Time'); 
ylabel('DK vals (a.u.)');

if plotpanels
    prfig.plotwidth           = 10;
    prfig.plotheight          = 9;
    prfig.figdir             = figdirout;
    prfig.figname             = 'Fig4_panelE_rcs02';
    plot_hfig(hfig,prfig)
end
%%

%% panel c - psd at home - all raw data 10 minute - across all states 
% note that this is a moving 2 minute 10 minute average - since using the
% PKG as basis for this 
fignum = 3; 
addpath(genpath(fullfile(pwd,'toolboxes','shadedErrorBar')))
figdirout = '/Users/roee/Starr_Lab_Folder/Writing/papers/2019_LongTerm_RCS_recordings/figures/1_draft2/Fig4_state_decoding_single_subject';
% original function:
% plot_pkg_data_all_subjects
load('/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home/coherence_and_psd RCS02 R pkg L.mat');
cntplt = 1; 
titles = {'STN 0-2','STN 1-3','M1 8-10','M1 9-11'};
colors = [0.8 0 0; 0 0.8 0;0 0 0.8; 0.5 0.5 0.5];
colors2 = {'r','g','b','k'};
if plotpanels
    hfig = figure;
    hfig.Color = 'w';
end

% assign states rcs 02 
rawstates = allDataPkgRcsAcc.states;
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

fieldnamesuse = {'key0fftOut','key2fftOut','stn02m10810'};
titles = {'STN 0-2','M1 9-11','STN-M1 coherence'}; 
for c = 1:3
    if plotpanels
        hsb(cntplt) = subplot(3,1,cntplt); cntplt = cntplt + 1;
    else
        hpanel(1,1,2,cntplt,1).select(); % loop on 4th position;
        hsb(cntplt) = gca;
        cntplt = cntplt + 1;
    end
    hold on;
    statesUsing = {};cntstt = 1;
    for s = 1:length(statesUse)
        labels = strcmp(allstates,statesUse{s});
        labelsCheck(:,s) = labels;

        fn = fieldnamesuse{c};
        dat = [];
        dat = allDataPkgRcsAcc.(fn);
        if c ~=3
            idxnormalize = psdResults.ff > 3 &  psdResults.ff <90;
            meandat = abs(mean(dat(:,idxnormalize),2)); % mean within range, by row
            % the absolute is to make sure 1/f curve is not flipped
            % since PSD values are negative
            meanmat = repmat(meandat,1,size(dat,2));
            dat = dat./meanmat;
            ff = psdResults.ff;
        else
            ff = cohResults.ff;
        end
        
        if sum(labels)>=1
            hsbH = shadedErrorBar(ff,dat(labels,:),{@mean,@(x) std(x)*1.5},...
                'lineprops',{colors2{s},'markerfacecolor','r','LineWidth',2});
            statesUsing{cntstt} = statesUse{s};cntstt = cntstt + 1;
            hsbH.mainLine.Color = [colors(s,:) 0.5];
            hsbH.mainLine.LineWidth = 2;
            hsbH.edge(1).Color = [1 1 1 0.5];
            hsbH.edge(2).Color = [1 1 1 0.5];
            hsbH.patch.FaceAlpha = 0.1;
        end
        % save the median data
        
        rawdat = allDataPkgRcsAcc.(fn);
        rawdat = rawdat(labels,:);
        legend(statesUsing);
    end
      
        if c == 3 
            ylabel('MS coherence','FontName','Arial','FontSize',11);
            xlabel('Frequecny (Hz)','FontName','Arial','FontSize',11);
        else
            ylabel('Norm Power','FontName','Arial','FontSize',11);
            hsb(cntplt-1).XTick = []; 
            hsb(cntplt-1).XTickLabel = {};
        end
        ttluse = sprintf('%s',titles{c});
        title(ttluse,'FontName','Arial','FontSize',11);
        set(gca,'FontName','Arial','FontSize',11);
        xlim([3 100]);

end

if plotpanels
hfig.RendererMode = 'manual';
hfig.Renderer = 'painters';
prfig.plotwidth           = 6;
prfig.plotheight          = 8;
prfig.figdir             = figdirout;
prfig.figname             = 'Fig4_panelD_all_states_shaded_error_bar_rcs02R';
prfig.figtype             = '-dpdf';
plot_hfig(hfig,prfig)
close(hfig);
end
%%
if ~plotpanels
%%    
hpanel.fontsize = 8;  % global font 
hpanel(1).de.margin = 20;
hpanel(1,2).de.margin = 5;
hpanel(1,1,2).de.margin = 5;
hpanel(1,1,1).de.margin = 5;
hpanel.marginleft =  20;
hpanel.marginright =  20;
hpanel.margintop =  10;
hpanel(1,1).marginbottom =  10;
prfig.plotwidth           = 8;
prfig.plotheight          = 6;
prfig.figdir             = figdirout;
prfig.figname             = 'Fig4_all_with_colorbar';
prfig.figtype             = '-dpdf';
plot_hfig(hfig,prfig)
x = 2;
%%
% close(hfig);
end


return 
%% old previous drafit figure 4 
% panel a - group data for in clinc psd 
% panel b - bar graph of total hours recorded (awake / asleep) 
% panel c - grupe data for at home psd 



%% panel A - group data for in clinc psd 
clc; close all; clear all; 
addpath(genpath(fullfile(pwd,'toolboxes','GEEQBOX')));
fignum = 4; 
figdirout = '/Users/roee/Starr_Lab_Folder/Writing/papers/2019_LongTerm_RCS_recordings/figures';
% original function:
% plot_chopped_data_comparisons
%plot normalized data across patients 
dirname = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/in_clinic/rest_3rd_try';
fnmsave = fullfile(dirname,'patientPSD_in_clinic.mat');
load(fnmsave,'patientPSD_in_clinic');


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
hfig = figure;
hfig.Color = 'w'; 

% loop on area 
areas = {'STN 1-3','M1 8-10'}; 
medstatecheck = {'on','off'};
colorsuse = [0 0.8 0 0.5; 0.8 0 0 0.5]; 
for a = 1%:length(areas)
    subplot(1,2,a); 
    hold on;
    for m = 1:length(medstatecheck) 
        idxkeep = strcmp(pdb.electrode,areas{a}) &  strcmp(pdb.medstate,medstatecheck{m});
        idxkeepout(:,m) = idxkeep;
        fftout  = psdall(idxkeep,:); 
        hsbH = shadedErrorBar(freqschecking,fftout,{@mean,@(x) std(x)*1});
        hsbH.mainLine.Color = colorsuse(m,:);
        hsbH.mainLine.LineWidth = 3;
        hsbH.patch.FaceAlpha = 0.1;
        hsbH.patch.FaceColor = colorsuse(m,1:3); 
        hsbH.edge(1).Color = [1 1 1];
        hsbH.edge(2).Color = [1 1 1];
        hLine(m) = hsbH.mainLine;
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
    xfreqssig(:,1) = freqschecking(b.beg)
    xfreqssig(:,2) = freqschecking(b.end)
    ylims = get(gca,'YLim');
    if ~isempty(xfreqssig)
        plot(xfreqssig,[ylims(2) ylims(2)],'Color',[0.5 0.5 0.5],'LineWidth',2);
    end
    % %%%%%%%%%%%%%%%%%%%%%%%%% do stats
    % %%%%%%%%%%%%%%%%%%%%%%%%% do stats
    % %%%%%%%%%%%%%%%%%%%%%%%%% do stats
    legend(hLine,{'defined on','defined off'});
    xlim([5 90]);
    xlabel('Frequency (Hz)');
    ylabel('Norm. frequency');
    title(areas{a});
    set(gca,'FontSize',16);

end




sgtitle('Defined on/off in clinic (8 STNs, 4 patients)','FontSize',12);

prfig.plotwidth           = 4.4;
prfig.plotheight          = 4.4;
prfig.figdir             = figdirout;
prfig.figname             = sprintf('Fig%d_panelA',fignum);
prfig.figtype             = '-dpdf';
plot_hfig(hfig,prfig)
close(hfig);

%%
%% panel b bar graph of total hours awake / alseep 
clc; close all; clear all; 
fignum = 4; 
figdirout = '/Users/roee/Starr_Lab_Folder/Writing/papers/2019_LongTerm_RCS_recordings/figures';
% origina funciton used: plot_pkg_data_all_subjects
resultsdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home/synced_rcs_pkg_data_saved';
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
hfig = figure;
hsb = subplot(1,1,1); 
hfig.Color = 'w'; 
hbar = bar(recTime);
hsb.XTickLabel = uniquePatients;
hsb.YLabel.String = 'Hours recoreded'; 
hsb.Title.String = 'Hours recoreded at home / patient'; 
legend({'awake','alseep'},'Location','northwest');
prfig.plotwidth           = 5;
prfig.plotheight          = 2.5;
prfig.figdir             = figdirout;
prfig.figname             = sprintf('Fig%d_panelB',fignum);
prfig.figtype             = '-dpdf';
plot_hfig(hfig,prfig)
close(hfig);

%% 
%% panel C - grupe data for at home psd
clc; close all; clear all; 
fignum = 4; 
figdirout = '/Users/roee/Starr_Lab_Folder/Writing/papers/2019_LongTerm_RCS_recordings/figures';
% original function:
% plot_pkg_data_all_subjects

load('/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home/patientPSD_at_home.mat');
hfig = figure;
hfig.Color = 'w'; 
pdb = patientPSD_at_home;



% stn 
subplot(1,2,1);hold on; 
set(gca,'XLim',[5 90])
% med on 
idxkeep = (pdb.srate == 250) & ...
           strcmp(pdb.electrode,'STN 1-3') & ... 
           strcmp(pdb.medstate,'on');
psds = cell2mat(pdb.fftOutNorm(idxkeep));
ff = pdb.ff(idxkeep);
ff = ff{1}; 
% plot(ff,psds,'LineWidth',1,'Color',[0 0.8 0 0.3]);
hsbH = shadedErrorBar(ff,psds,{@mean,@(x) std(x)*1});
hsbH.mainLine.Color = [0 0.8 0 0.5];
hsbH.mainLine.LineWidth = 3;
hsbH.patch.FaceAlpha = 0.1;
hLine(1) = hsbH.mainLine;

% med off 
idxkeep = (pdb.srate == 250) & ...
           strcmp(pdb.electrode,'STN 1-3') & ... 
           strcmp(pdb.medstate,'off');
psds = cell2mat(pdb.fftOutNorm(idxkeep));
ff = pdb.ff(idxkeep);
ff = ff{1}; 
% plot(ff,psds,'LineWidth',1,'Color',[0.8 0 0 0.3]);

hsbH = shadedErrorBar(ff,psds,{@mean,@(x) std(x)*1});
hsbH.mainLine.Color = [0.8 0 0 0.5];
hsbH.mainLine.LineWidth = 3;
hsbH.patch.FaceAlpha = 0.1;
hLine(2) = hsbH.mainLine;

hold on;
xlabel('Frequency (Hz)');
ylabel('Power  (log_1_0\muV^2/Hz)');
title('STN 1-3','FontSize',16);
legend(hLine,{'PKG estimate - on','PKG estimate - off'});

% m1 
subplot(1,2,2);hold on; 
% med on 
idxkeep = (pdb.srate == 250) & ...
           strcmp(pdb.electrode,'M1 8-10') & ... 
           strcmp(pdb.medstate,'on');
psds = cell2mat(pdb.fftOutNorm(idxkeep));
ff = pdb.ff(idxkeep);
ff = ff{1}; 
% plot(ff,psds,'LineWidth',1,'Color',[0 0.8 0 0.3]);

hsbH = shadedErrorBar(ff,psds,{@mean,@(x) std(x)*1});
hsbH.mainLine.Color = [0 0.8 0 0.5];
hsbH.mainLine.LineWidth = 3;
hsbH.patch.FaceAlpha = 0.1;
hLine(1) = hsbH.mainLine;
% med off 
idxkeep = (pdb.srate == 250) & ...
           strcmp(pdb.electrode,'M1 8-10') & ... 
           strcmp(pdb.medstate,'off');
psds = cell2mat(pdb.fftOutNorm(idxkeep));
ff = pdb.ff(idxkeep);
ff = ff{1}; 
% plot(ff,psds,'LineWidth',1,'Color',[0.8 0 0 0.3]);
hsbH = shadedErrorBar(ff,psds,{@mean,@(x) std(x)*1});
hsbH.mainLine.Color = [0.8 0 0 0.5];
hsbH.mainLine.LineWidth = 3;
hsbH.patch.FaceAlpha = 0.1;
hLine(2) = hsbH.mainLine;
legend(hLine,{'PKG estimate - on','PKG estimate - off'});
hold on;
set(gca,'XLim',[5 90])
xlabel('Frequency (Hz)');
ylabel('Power  (log_1_0\muV^2/Hz)');
title('M1 8-10','FontSize',16);
sgtitle('Defined on/off at home (8 STNs, 4 patients)','FontSize',12);


prfig.plotwidth           = 9;
prfig.plotheight          = 3;
prfig.figdir             = figdirout;
prfig.figname             = sprintf('Fig%d_panelC',fignum);
prfig.figtype             = '-dpdf';
plot_hfig(hfig,prfig)
close(hfig);
%%

end