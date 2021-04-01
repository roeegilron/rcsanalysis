function rcsAtHome_figures_figures1()
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
rootdir = '/Users/roee/Box/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home/coherence_and_psd';
addpath(genpath(fullfile(pwd,'toolboxes','panel-2.14')));


hfig = figure;
hfig.Color = 'w';
hfig.Position = [1000         194        1387        1144];
hpanel = panel();
hpanel.pack(5,3); 
hsb = gobjects(5,3);

ff = findFilesBVQX(rootdir,'coherence_and_psd*RCS*.mat');
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
            psdResults.ff = allDataPkgRcsAcc.ffPSD;
        end
        idxnormalize = psdResults.ff > 3 &  psdResults.ff <90;
        meandat = abs(mean(dat(:,idxnormalize),2)); % mean within range, by row
        % the absolute is to make sure 1/f curve is not flipped
        % since PSD values are negative
        meanmat = repmat(meandat,1,size(dat,2));
        dat = dat./meanmat;
        r = ceil(size(dat,1) .* rand(720,1));
        r = 1:5:size(dat,1);
        normalizedPSD = dat(r,:);
        frequency = psdResults.ff';
        idxsleep = strcmp(allDataPkgRcsAcc.states,'sleep');
        % idxsleep = allDataPkgRcsAcc.bkVals <= -110;
        lw = linewidths(p);
        reduce_plot(psdResults.ff', normalizedPSD,'LineWidth',lw,'Color',[0 0 0.8 0.05]);% was 0.7 for rcs02 and 0.5 alpha
%         plot(psdResults.ff', normalizedPSD(1,:),'LineWidth',lw,'Color',[0 0 0.8 0.05]);% was 0.7 for rcs02 and 0.5 alpha
        
        xlim([3 100]);
        if p == length(uniquePatients)
            xlabel('Frequency (Hz)');
        else
            hsb(p,msr-1).XTick = [];
        end
        if (msr-1) == 1
            ylab = {}; 
            ylab{1,1} = sprintf('%s',patientsNameToUse{p});
            ylab{1,2} = sprintf('%s','Norm. power (a.u.)');
            ylabel(ylab);
        end
        ylims = hsb(p,(msr-1)).YLim;
        ttluse = {};
%         ttluse{1,1} = sprintf('%s',patientsNameToUse{p});
        ttluse{1,1} = sprintf('%s',areatitls{a});
        title(ttluse);
        %         plot([4 4],ylims,'LineWidth',3,'LineStyle','-.','Color',[0.2 0.2 0.2 0.1]);
%         plot([13 13],ylims,'LineWidth',2,'LineStyle','-.','Color',[0.2 0.2 0.2 0.1]);
%         plot([30 30],ylims,'LineWidth',2,'LineStyle','-.','Color',[0.2 0.2 0.2 0.1]);
        set(gca,'FontSize',10);

    end

    % plot coherence
    hsb(p,msr) = hpanel(p,msr).select(); msr = msr + 1;
    hold on;
    r = ceil(size(coh_dat,1) .* rand(720,1));
    r = 1:5:size(coh_dat,1);
    if strcmp(uniquePatients{p},'RCS08')
        cohResults.ff = allDataPkgRcsAcc.ffCoh;
    end
    reduce_plot(cohResults.ff', coh_dat(r,:),'LineWidth',lw,'Color',[0 0 0.8 0.05]);
%     reduce_plot(cohResults.ff', coh_dat(1,:),'LineWidth',lw,'Color',[0 0 0.8 0.05]);
    if p == length(uniquePatients)
        xlabel('Frequency (Hz)');
    else
        hsb(p,msr-1).XTick = [];
    end 
    ylabel('MS coherence');
    ttluse = {};
%     ttluse{1,1} = sprintf('%s',patientsNameToUse{p});
    ttluse{1,1} = 'stn-motor cortex coherence';
    title(ttluse);
    xlim([0 100]);
    set(gca,'FontSize',10);
    clear allDataPkgRcsAcc m1_data coh_dat stndata psdResults cohResults
end
hpanel.de.margin = 10;
plotVector = 0; 
for i = 1:5 
    for j = 1:3
        hsb = hpanel(i,j).select(); 
        if j == 3 
             hpanel(i,j).marginright = 20;
             
        else
            
            hpanel(i,j).marginright = 20;
        end
        hpanel(i,j).marginbottom = 7;
       
    end
end
numTicks = 5;
for i = 1:5
    for j = 1:3
        hsb = hpanel(i,j).select();
        if plotVector
            delete(get(hsb,'Children'))
        end
        ylims = hsb.YLim;
        plot(hsb,[13 13],ylims,'LineWidth',2,'LineStyle','-.','Color',[0.2 0.2 0.2 0.1]);
        plot(hsb,[30 30],ylims,'LineWidth',2,'LineStyle','-.','Color',[0.2 0.2 0.2 0.1]);

        yticksuse = linspace(ylims(1),ylims(2),numTicks);
        ticklabels = {'0.00','0.25','0.50','0.75','1.00'};
        hsb.YTick = yticksuse;
        hsb.YTickLabel = ticklabels;
        hsb.YLim = [yticksuse(1) yticksuse(end)];
    end
end

%% make a vector based and image based plot, the merge them. 
%% start with vector based 

%% HIDE ALL LINES aside from 13-30 lines - VECTOR ONLY 
axs = hfig.Children; 
for a = 1:length(axs)
    idxturnoff = cellfun(@(x) size(x,2), {axs(a).Children.XData})' ==  2;
    axxOff = axs(a).Children(idxturnoff);
    for ll = 1:length(axxOff)
            axxOff(ll).Visible = 'on';
    end
    
    idxturnoff = cellfun(@(x) size(x,2), {axs(a).Children.XData})' >  3;
    axxOff = axs(a).Children(idxturnoff);
    for ll = 1:length(axxOff)
            axxOff(ll).Visible = 'off';
    end
end

hpanel.fontsize = 10; 
hpanel.margintop = 15;
hpanel.margin = [30 15 15 15];
prfig.figdir             = figdirout;
prfig.figtype             = '-dpdf';
prfig.plotwidth           = 7.0;
prfig.plotheight          = 8.5;

prfig.figname             = sprintf('FigS1_raw_psd_data_p4_v6_VECTOR_ONLY');

plot_hfig(hfig,prfig)

%%
%% HIDE ALL eveything else - just pring a jpeg to put under vector image 

for a = 1:length(axs)
    idxturnoff = cellfun(@(x) size(x,2), {axs(a).Children.XData})' ==  2;
    axxOff = axs(a).Children(idxturnoff);
    for ll = 1:length(axxOff)
            axxOff(ll).Visible = 'off';
    end
    
    idxturnoff = cellfun(@(x) size(x,2), {axs(a).Children.XData})' >  3;
    axxOff = axs(a).Children(idxturnoff);
    for ll = 1:length(axxOff)
            axxOff(ll).Visible = 'on';
    end
    axs(a).XLabel.Visible = 'off';
    axs(a).YLabel.Visible = 'off';
    axs(a).Title.Visible = 'off';
    axs(a).XTick = [];
    axs(a).YTick = [];
    axs(a).Box = 'off';
    axs(a).XColor = [1 1 1];
    axs(a).YColor = [1 1 1];
end
%%
hpanel.fontsize = 10; 
hpanel.margintop = 15;
hpanel.margin = [30 15 15 15];
prfig.figdir              = figdirout;
prfig.resolution          = 600;
prfig.figtype             = '-djpeg';
prfig.plotwidth           = 7.0;
prfig.plotheight          = 8.5;

prfig.figname             = sprintf('FigS1_raw_psd_data_p4_v6_JPEG_ONLY');

plot_hfig(hfig,prfig)
%% 




if plotVector
    prfig.figdir             = figdirout;
    prfig.figtype             = '-dpdf';
    prfig.figname             = sprintf('FigS1_raw_psd_data_p4_v5_vector');
else
    prfig.figdir             = figdirout;
    prfig.figtype             = '-djpeg';
    prfig.figname             = sprintf('FigS1_raw_psd_data_p4_v5');
end
plot_hfig(hfig,prfig)
%%