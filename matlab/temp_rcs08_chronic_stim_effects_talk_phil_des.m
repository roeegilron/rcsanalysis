function temp_rcs08_chronic_stim_effects_talk_phil_des()

close all;
%%%%
%%%%
%%%%




%% load data
rootdir = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/processed_data/';
figdirout = fullfile(rootdir,'figures');
ff = findFilesBVQX(rootdir,'RCS08_R_*psdAndCoherence*.mat');

%% plot set up figure - raw data 
addpath(genpath(fullfile(pwd,'toolboxes','panel-2.14')));
hfig = figure;
hfig.Color = 'w';
hpanel = panel();
hpanel.pack(2,2);
clrsuse  = [0 0.8 0;
    0.8 0 0];
alphause = 0.05;
for ii = 1:2
    clear allDataCoherencePsd
    % load the rigth data set
    load(ff{ii})
    colorUse = [clrsuse(ii,:) alphause];
    
    
    fieldnamesRaw = fieldnames( allDataCoherencePsd );
    % plot coherence
    idxPlot = cellfun(@(x) any(strfind(x,'gpi')),fieldnamesRaw) | ...
        cellfun(@(x) any(strfind(x,'stn')),fieldnamesRaw) ;
    fieldNamesPlot = fieldnamesRaw(idxPlot);
    fieldNamesPlot = fieldNamesPlot(1:2);% XXXX modifcation ugly
    
    % get only data from 8am -10pm
    t = allDataCoherencePsd.timeStartCoh;
    idxTime = hour(t) > 8 & hour(t) < 22;
    xticks = [4 8 12 20 30 60 80];
    for f = 1:length(fieldNamesPlot)
        hsb(f) = hpanel(ii,f).select();
        hold(hsb(f),'on');
        x = allDataCoherencePsd.ffCoh;
        y = allDataCoherencePsd.(fieldNamesPlot{f})(:,idxTime);
        % only take a subset of y if larger than 1000 lines ot make plotting
        % easier
        if size(y,2) < 1500 % xxxxx UGLY HACK 2
            yUse = y;
        else
            yUse = y(:,end-1200:end);
        end
        xlim([3 100]);
        lw = 0.002; % line width
        plot(hsb(f),x',yUse,'LineWidth',lw,'Color',colorUse);
        idxContact1 = allDataCoherencePsd.paircontact(f,1) + 1;
        idxContact2 = allDataCoherencePsd.paircontact(f,2) + 1;
        chanFn1 = sprintf('chan%d',idxContact1);
        chanFn2 = sprintf('chan%d',idxContact2);
        ttluse = {};
        ttluse{1,1} = 'cohernece between:';
        ttluse{1,2} = database.(chanFn1){1};
        ttluse{1,3} = database.(chanFn2){1};
        title(ttluse);
        hsb(f).XTick = xticks;
        ylims = hsb(f).YLim;
        for i = 1:length(xticks)
            xs = [xticks(i) xticks(i)];
            plot(xs,ylims,'LineWidth',1,'Color',[0.5 0.5 0.5 0.2],'LineStyle','-.');
        end
        if f == 1
            ylabel('MS coherence');
        end
    end
end
hsb = hpanel(1,1).select();
title(hsb,'STN 1-3 MC 8-10 (stim on)');
xlabel(hsb,'');

hsb = hpanel(2,1).select();
title(hsb,'STN 1-3 MC 8-10 (stim off)');
xlabel(hsb,'Frequency (Hz');

hsb = hpanel(1,2).select();
title(hsb,'STN 1-3 MC 9-11 (stim on)');
xlabel(hsb,'');

hsb = hpanel(2,2).select();
title(hsb,'STN 1-3 MC 9-11 (stim off)');
xlabel(hsb,'Frequency (Hz');

hpanel.fontsize = 16;
mrgn = 25;
hpanel.margin = [ mrgn mrgn mrgn mrgn];
hpanel.de.margin = 20; 

hsbb(1) = hpanel(1,1).select();
hsbb(2) = hpanel(2,1).select();
hsbb(3) = hpanel(1,2).select();
hsbb(4) = hpanel(2,2).select();

linkaxes(hsbb,'y');

fac = 0.8;
fnSave = 'rcs08_stim_coherence_ctx';
prfig.plotwidth           = 18*fac;
prfig.plotheight          = 10*fac;
prfig.figdir              = '/Users/roee/Downloads';
prfig.figtype             = '-dpdf';
prfig.figname             = fnSave;
prfig.resolution          = 300;
plot_hfig(hfig,prfig)
%%




%% plot set up figure - shaded error bars  
addpath(genpath(fullfile(pwd,'toolboxes','panel-2.14')));
addpath(genpath(fullfile(pwd,'toolboxes','shadedErrorBar')));

hfig = figure;
hfig.Color = 'w';
hpanel = panel();
hpanel.pack('h',{0.5 0.5});
clrsuse  = [0 0.8 0;
    0.8 0 0];
alphause = 0.7;
for ii = 1:2
    clear allDataCoherencePsd
    % load the rigth data set
    load(ff{ii})
    colorUse = [clrsuse(ii,:) alphause];
    
    
    fieldnamesRaw = fieldnames( allDataCoherencePsd );
    % plot coherence
    idxPlot = cellfun(@(x) any(strfind(x,'gpi')),fieldnamesRaw) | ...
        cellfun(@(x) any(strfind(x,'stn')),fieldnamesRaw) ;
    fieldNamesPlot = fieldnamesRaw(idxPlot);
    fieldNamesPlot = fieldNamesPlot(3:4);% XXXX modifcation ugly
    
    % get only data from 8am -10pm
    t = allDataCoherencePsd.timeStartCoh;
    idxTime = hour(t) > 8 & hour(t) < 22;
    xticks = [4 8 12 20 30 60 80];
    for f = 1:length(fieldNamesPlot)
        hsb(f) = hpanel(f).select();
        hold(hsb(f),'on');
        x = allDataCoherencePsd.ffCoh;
        y = allDataCoherencePsd.(fieldNamesPlot{f})(:,idxTime);
        % only take a subset of y if larger than 1000 lines ot make plotting
        % easier
        if size(y,2) < 1500 % xxxxx UGLY HACK 2
            yUse = y;
        else
            yUse = y(:,end-1200:end);
        end
        xlim([3 100]);
        lw = 3; % line width
        hplt(ii,f) = plot(hsb(f),x',mean(yUse,2),'LineWidth',lw,'Color',colorUse);
        axes(hsb(f));
%         shadedErrorBar(x,yUse',{@median,@(x) std(x)*1.96});
        
        idxContact1 = allDataCoherencePsd.paircontact(f,1) + 1;
        idxContact2 = allDataCoherencePsd.paircontact(f,2) + 1;
        chanFn1 = sprintf('chan%d',idxContact1);
        chanFn2 = sprintf('chan%d',idxContact2);
        ttluse = {};
        ttluse{1,1} = 'cohernece between:';
        ttluse{1,2} = database.(chanFn1){1};
        ttluse{1,3} = database.(chanFn2){1};
        title(ttluse);
        hsb(f).XTick = xticks;
        ylims = hsb(f).YLim;
        for i = 1:length(xticks)
            xs = [xticks(i) xticks(i)];
            plot(xs,ylims,'LineWidth',1,'Color',[0.5 0.5 0.5 0.2],'LineStyle','-.');
        end
        if f == 1
            ylabel('MS coherence');
        end
    end
end
   
hsb = hpanel(1).select();
title(hsb,'STN 1-3 MC 8-10');
xlabel(hsb,'Frequency (Hz');

hsb = hpanel(2).select();
title(hsb,'STN 1-3 MC 9-11');
xlabel(hsb,'Frequency (Hz');

hpanel.fontsize = 16;
mrgn = 25;
hpanel.margin = [ mrgn mrgn mrgn mrgn];
hpanel.de.margin = 20; 
axes(hsb);
legend(hsb,hplt(1:2),{'stim on','stim off'});
fac = 0.8;
fnSave = 'rcs08_stim_coherence_ctx_avg';
prfig.plotwidth           = 20*fac;
prfig.plotheight          = 10*fac;
prfig.figdir              = '/Users/roee/Downloads';
prfig.figtype             = '-dpdf';
prfig.figname             = fnSave;
prfig.resolution          = 300;
plot_hfig(hfig,prfig)
%%





%% plot set up figure - raw data  psds 
addpath(genpath(fullfile(pwd,'toolboxes','panel-2.14')));
hfig = figure;
hfig.Color = 'w';
hpanel = panel();
hpanel.pack(2,2);
clrsuse  = [0 0.8 0;
    0.8 0 0];
alphause = 0.05;
for ii = 1:2
    clear allDataCoherencePsd
    % load the rigth data set
    load(ff{ii})
    colorUse = [clrsuse(ii,:) alphause];
    
    
    fieldnamesRaw = fieldnames( allDataCoherencePsd );
    % plot coherence
    idxPlot = cellfun(@(x) any(strfind(x,'key')),fieldnamesRaw);
    fieldNamesPlot = fieldnamesRaw(idxPlot);
%     fieldNamesPlot = fieldNamesPlot(1:2);% XXXX modifcation ugly
    
    % get only data from 8am -10pm
    t = allDataCoherencePsd.timeStartCoh;
    idxTime = hour(t) > 8 & hour(t) < 22;
    xticks = [4 8 12 20 30 60 80];
    hsb = gobjects(length(fieldNamesPlot),1);
    cntplt = 1;
    for iii = 1:2
        for jjj = 1:2
            hsb(cntplt) = hpanel(iii,jjj).select();
            cntplt = cntplt + 1;
        end
    end
    for f = 1:length(fieldNamesPlot)
%         hsb(f) = hpanel(ii,f).select();
        hold(hsb(f),'on');
        x = allDataCoherencePsd.ffPsd;
        y = allDataCoherencePsd.(fieldNamesPlot{f})(:,idxTime);
        % only take a subset of y if larger than 1000 lines ot make plotting
        % easier
        if size(y,2) < 1500 % xxxxx UGLY HACK 2
            yUse = y;
        else
            yUse = y(:,end-1200:end);
        end
        xlim([3 100]);
        lw = 0.002; % line width
        plot(hsb(f),x',yUse,'LineWidth',lw,'Color',colorUse);
%         lw = 3; 
%         plot(hsb(f),x',mean(yUse,2),'LineWidth',lw,'Color',[colorUse(1:3) 0.8]);
        idxContact1 = allDataCoherencePsd.paircontact(f,1) + 1;
        idxContact2 = allDataCoherencePsd.paircontact(f,2) + 1;
        chanFn1 = sprintf('chan%d',idxContact1);
        chanFn2 = sprintf('chan%d',idxContact2);
        ttluse = {};
        ttluse{1,1} = 'cohernece between:';
        ttluse{1,2} = database.(chanFn1){1};
        ttluse{1,3} = database.(chanFn2){1};
        title(ttluse);
        hsb(f).XTick = xticks;
        ylims = hsb(f).YLim;
    end
end
for f = 1:4
    for i = 1:length(xticks)
        xs = [xticks(i) xticks(i)];
        ylims = hsb(f).YLim;
        plot(hsb(f),xs,ylims,'LineWidth',1,'Color',[0.5 0.5 0.5 0.2],'LineStyle','-.');
        xlim(hsb(f),[0 95]);
        if f == 1 || f == 3
            ylabel(hsb(f),'Power (log_1_0\muV^2/Hz)');
        else
            ylabel(hsb(f),'');
        end

        if f == 3 || f == 4
            xlabel(hsb(f),'Frequency (Hz');
        else
            xlabel(hsb(f),'');
        end
    end
end
title(hsb(1),'STN 0-2');

title(hsb(2),'STN 1-3');

title(hsb(3),'MC 8-10');

title(hsb(4),'MC 9-11');


hpanel.fontsize = 16;
mrgn = 25;
hpanel.margin = [ mrgn mrgn mrgn mrgn];
hpanel.de.margin = 20; 

hsbb(1) = hpanel(1,1).select();
hsbb(2) = hpanel(2,1).select();
hsbb(3) = hpanel(1,2).select();
hsbb(4) = hpanel(2,2).select();


fac = 0.8;
fnSave = 'rcs08_stim_on_off_psds_just_raw';
prfig.plotwidth           = 18*fac;
prfig.plotheight          = 10*fac;
prfig.figdir              = '/Users/roee/Downloads';
prfig.figtype             = '-dpdf';
prfig.figname             = fnSave;
prfig.resolution          = 300;
plot_hfig(hfig,prfig)
%%















return 


%% find peaks, plot all violin plots for specific patients and sidespatientsUse(cntpt) = 2;
close all;
cntpt = 1;

patientsUse(cntpt) = 2;
sidesUse{cntpt} = 'L';
chansUse{cntpt} = '+3-1';
cntpt = cntpt + 1;

patientsUse(cntpt) = 5;
sidesUse{cntpt} = 'L';
chansUse{cntpt} = '+2-0';
cntpt = cntpt + 1;

patientsUse(cntpt) = 5;
sidesUse{cntpt} = 'R';
chansUse{cntpt} = '+2-0';
cntpt = cntpt + 1;

patientsUse(cntpt) = 6;
sidesUse{cntpt} = 'L';
chansUse{cntpt} = '+3-1';
cntpt = cntpt + 1;

patientsUse(cntpt) = 7;
sidesUse{cntpt} = 'L';
chansUse{cntpt} = '+3-1';
cntpt = cntpt + 1;

patientsUse(cntpt) = 7;
sidesUse{cntpt} = 'R';
chansUse{cntpt} = '+3-1';
cntpt = cntpt + 1;

patientsUse(cntpt) = 8;
sidesUse{cntpt} = 'R';
chansUse{cntpt} = '+3-1';
cntpt = cntpt + 1;

patientsUse(cntpt) = 3;
sidesUse{cntpt} = 'L';
chansUse{cntpt} = '+3-2';
cntpt = cntpt + 1;


patientsUse(cntpt) = 3;
sidesUse{cntpt} = 'R';
chansUse{cntpt} = '+3-2';
cntpt = cntpt + 1;

% add path
addpath(genpath(fullfile(pwd,'toolboxes','violin')))
colorsuse = [0.5 0.5 0.5; 0 0.8 0];
% bands used
freqranges = [1 4; 4 8; 8 13; 13 20; 20 30;13 30; 30 50; 50 90];
freqnames  = {'Delta', 'Theta', 'Alpha','LowBeta','HighBeta','All beta','LowGamma','HighGamma'}';

for frr = 1:size(freqranges,1)
    cntpos = 1;
    for pp = 1:length(patientsUse)
        fnSearch = sprintf('RCS%0.2d_%s_psdAndCoherence*stim*.mat',patientsUse(pp),sidesUse{pp});
        ff = findFilesBVQX(rootdir,fnSearch);
        for f = 1:length(ff)
            load(ff{f});
            % find correct channel to compare;
            for c = 1:4
                chanfn = sprintf('chan%d',c);
                if length(unique(database.(chanfn))) ==1
                    chanComp = unique(database.(chanfn));
                    if any(strfind(chanComp{1} ,chansUse{pp}))
                        keyfn = sprintf('key%dfftOut',c-1);
                        break;
                    end
                end
            end
            bandsUsed = freqranges(frr,:);
            % get psd data
            t = allDataCoherencePsd.timeStartTd;
            idxTime = hour(t) > 8 & hour(t) < 22;
            x = allDataCoherencePsd.ffPsd;
            y = allDataCoherencePsd.(keyfn)(:,idxTime);
            idxuse = x > bandsUsed(1) & x <  bandsUsed(2);
            violinDataSTN{cntpos} = mean(y(idxuse,:),1);
            % get m1 data
            y = allDataCoherencePsd.key2fftOut(:,idxTime);
            idxuse = x > bandsUsed(1) & x <  bandsUsed(2);
            violinDataM1{cntpos,1} = mean(y(idxuse,:),1);
            
            y = allDataCoherencePsd.key3fftOut(:,idxTime);
            violinDataM1{cntpos,2} = mean(y(idxuse,:),1);
            ysize = size(allDataCoherencePsd.key3fftOut,2);
            
            % get cohernce data
            fieldnamesRaw = fieldnames( allDataCoherencePsd );
            idxPlot = cellfun(@(x) any(strfind(x,'gpi')),fieldnamesRaw) | ...
                cellfun(@(x) any(strfind(x,'stn')),fieldnamesRaw) ;
            fieldNamesPlot = fieldnamesRaw(idxPlot);
            searchStr = fliplr(strrep(strrep(chansUse{pp},'+',''),'-',''));
            idxCohFieldNames = cellfun(@(x) any(strfind(x,searchStr)),fieldNamesPlot);
            cohFieldNames = fieldNamesPlot(idxCohFieldNames);
            for cf = 1:length(cohFieldNames)
                x = allDataCoherencePsd.ffCoh;
                y = allDataCoherencePsd.(cohFieldNames{cf})(:,idxTime);
                idxuse = x > bandsUsed(1) & x <  bandsUsed(2);
                violinDataCoh{cntpos,cf} = mean(y(idxuse,:),1);
            end
            
            if database.stimulation_on(1)
                violinColor{cntpos} = colorsuse(1,:);
                stimState = sprintf('stim on');
            else
                violinColor{cntpos} = colorsuse(2,:);
                stimState = sprintf('stim off');
            end
            % get patient name and stim state
            patName = sprintf('%s %s %s ',database.patient{1},database.side{1},database.diagnosis{1});
            xTickLabels{cntpos} = [patName stimState];
            cntpos = cntpos + 1;
            clear database;
            %             fprintf('%d\t%s\t%s\n',ysize,patName,stimState);
            fprintf('%d\n',ysize);
            
        end
    end
    % plot violin plots
    close all;
    hfig = figure;
    hfig.Color = 'w';
    nrows = 5;
    ncols = 1;
    cntplt = 1;
    clear hViolin
    % plot stn
    hsb(cntplt) = subplot(nrows,ncols,cntplt);
    hold on;
    % plot violin stn
    hViolin(:,cntplt) = violin(violinDataSTN);
    cntplt = cntplt + 1;
    title(['STN ' freqnames{frr}]);
    ylabel('Power dB');
    
    % plot violin m1 1
    hsb(cntplt) = subplot(nrows,ncols,cntplt);
    hViolin(:,cntplt) = violin(violinDataM1(:,1)');
    cntplt = cntplt + 1;
    title(['MC ' freqnames{frr} ' 1'] );
    ylabel('Power dB');
    
    % plot violin m1 2
    hsb(cntplt) = subplot(nrows,ncols,cntplt);
    hViolin(:,cntplt) = violin(violinDataM1(:,2)');
    cntplt = cntplt + 1;
    title(['MC ' freqnames{frr} ' 2'] );
    hy = ylabel('Power dB');
    
    % plot violin coh 1
    hsb(cntplt) = subplot(nrows,ncols,cntplt);
    hViolin(:,cntplt) = violin(violinDataCoh(:,1)');
    cntplt = cntplt + 1;
    title(['Coh ' freqnames{frr} ' 1'] );
    ylabel('ms coherence');
    
    
    % plot violin coh 2
    hsb(cntplt) = subplot(nrows,ncols,cntplt);
    hViolin(:,cntplt) = violin(violinDataCoh(:,2)');
    cntplt = cntplt + 1;
    title(['Coh ' freqnames{frr} ' 2'] );
    ylabel('ms coherence');
    
    for p = 1:size(hViolin,2)
        for h = 1:length(violinColor)
            hViolin(h,p).FaceColor = violinColor{h};
            hViolin(h,p).FaceAlpha = 0.5;
        end
    end
    for h = 1:length(hsb)
        hsb(h).XTick = [];
        hsb(h).FontSize = 16;
        %     hsb(h).YLabel.Rotation = 0;
    end
    hsub = hsb(cntplt-1);
    hsub.XTick = 1:length(hViolin);
    hsub.XTickLabel = xTickLabels;
    hsub.XTickLabelRotation = 45;
    
    fnSave = sprintf('violin plots freq - %s',freqnames{frr});
    
    largeTitle = sprintf('violin plots %s (%d-%dHz)',freqnames{frr},bandsUsed(1),bandsUsed(2));
    sgtitle(largeTitle,'FontSize',20);
    fac = 0.9;
    prfig.plotwidth           = 10*fac;
    prfig.plotheight          = 16*fac;
    prfig.figdir              = figdirout;
    prfig.figtype             = '-djpeg';
    prfig.figname             = fnSave;
    prfig.resolution          = 150;
    plot_hfig(hfig,prfig)
    clear violinData*
    linkaxes(hsb,'x');
end
%%
x = 2;



%%%%
%%%%
%%%%
end