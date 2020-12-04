function plot_subject_specific_data_psd_coherence_home_data_raw()
%% load data
rootdir = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/processed_data/';
figdirout = fullfile(rootdir,'figures');
ff = findFilesBVQX(rootdir,'RCS*psdAndCoherence*.mat');
%% plot subject specific - comment out if you dont want specific fsubject 
ff = findFilesBVQX(rootdir,'RCS12_*psdAndCoherence*off.mat');
params.plotpsds = 1;
%% plot all raw data PSD plots
if params.plotpsds
    for fnf = 1:length(ff)
        try
            load(ff{fnf});
            
            %%
            fieldnamesRaw = fieldnames( allDataCoherencePsd );
            idxPlot = cellfun(@(x) any(strfind(x,'key')),fieldnamesRaw) | ...
                cellfun(@(x) any(strfind(x,'gpi')),fieldnamesRaw) | ...
                cellfun(@(x) any(strfind(x,'stn')),fieldnamesRaw) ;
            fieldNamesPlot = fieldnamesRaw(idxPlot);
            %
            %% set up figure
            addpath(genpath(fullfile(pwd,'toolboxes','panel-2.14')));
            addpath(genpath(fullfile(pwd,'toolboxes','plot_reducer')));
            hfig = figure;
            hfig.Color = 'w';
            hpanel = panel();
            hpanel.pack('v',{0.05 0.95});
            hpanel(2).pack(2,4);
            lw = 0.002;
            % hpanel.select('all');
            % hpanel.identify();
            
            % plot psd
            idxPlot = cellfun(@(x) any(strfind(x,'key')),fieldnamesRaw);
            fieldNamesPlot = fieldnamesRaw(idxPlot);
            
            % get only data from 8am -10pm
            t = allDataCoherencePsd.timeStartTd;
            idxTime = hour(t) > 8 & hour(t) < 22;
            xticks = [4 8 12 20 30 60 80];
            for f = 1:length(fieldNamesPlot)
                hsb(f) = hpanel(2,1,f).select();
                hold(hsb(f),'on');
                x = allDataCoherencePsd.ffPsd;
                y = allDataCoherencePsd.(fieldNamesPlot{f})(:,idxTime);
                % only take a subset of y if larger than 1000 lines ot make plotting
                % easier
                if size(y,2) > 1e3
                    rng(1);
                    idxchoose = randperm(size(y,2));
                    idxuse = idxchoose(1:1e3);
                    yUse = y(:,idxuse);
                else
                    yUse = y;
                end
                xlim([3 100]);
                %     reduce_plot(x',yUse,'LineWidth',lw,'Color',[0 0 0.8 0.05]);
                plot(x',yUse,'LineWidth',lw,'Color',[0 0 0.8 0.05]);
                chanFn = sprintf('chan%d',f);
                ttluse = database.(chanFn){1};
                title(ttluse);
                hsb(f).XTick = xticks;
                ylims = hsb(f).YLim;
                for i = 1:length(xticks)
                    xs = [xticks(i) xticks(i)];
                    plot(xs,ylims,'LineWidth',1,'Color',[0.5 0.5 0.5 0.2],'LineStyle','-.');
                end
                if f == 1
                    ylabel('Power (log_1_0\muV^2/Hz)');
                end
            end
            
            % plot coherence
            idxPlot = cellfun(@(x) any(strfind(x,'gpi')),fieldnamesRaw) | ...
                cellfun(@(x) any(strfind(x,'stn')),fieldnamesRaw) ;
            fieldNamesPlot = fieldnamesRaw(idxPlot);
            
            % get only data from 8am -10pm
            t = allDataCoherencePsd.timeStartCoh;
            idxTime = hour(t) > 8 & hour(t) < 22;
            xticks = [4 8 12 20 30 60 80];
            for f = 1:length(fieldNamesPlot)
                hsb(f) = hpanel(2,2,f).select();
                hold(hsb(f),'on');
                x = allDataCoherencePsd.ffCoh;
                y = allDataCoherencePsd.(fieldNamesPlot{f})(:,idxTime);
                % only take a subset of y if larger than 1000 lines ot make plotting
                % easier
                if size(y,2) > 1e3
                    rng(1);
                    idxchoose = randperm(size(y,2));
                    idxuse = idxchoose(1:1e3);
                    yUse = y(:,idxuse);
                else
                    yUse = y;
                end
                xlim([3 100]);
                %     reduce_plot(x',yUse,'LineWidth',lw,'Color',[0 0 0.8 0.05]);
                plot(x',yUse,'LineWidth',lw,'Color',[0.8 0 0 0.05]);
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
            % incldue some meta data in the top title
            % plot the figures
            grandTitle = {};
            grandTitle{1,1} = sprintf('%s %s',database.patient{1},database.side{1});
            if database.stimulation_on(1)
                grandTitle{1,2}  = sprintf('stim on (%s, %.2f mA, %.2f Hz)',database.electrodes{1},database.amplitude_mA(1),database.rate_Hz(1));
                stimStatusFielSave  = sprintf('stim-on_%s_%.2f-mA_%.2f-Hz',database.electrodes{1},database.amplitude_mA(1),database.rate_Hz(1));
            else
                grandTitle{1,2}  = 'stim off';
                stimStatusFielSave = 'stim-off';
            end
            database.duration.Format = 'hh:mm';
            grandTitle{1,3} = sprintf('%s (hh:mm) hours of data',sum(database.duration));
            
            hsb = hpanel(1).select();
            httl = title(grandTitle);
            set(gca, 'box','off','XTickLabel',[],'XTick',[],'YTickLabel',[],'YTick',[])
            set(gca,'XColor','none')
            set(gca,'YColor','none')
            hpanel.fontsize = 14;
            hpanel(1).marginbottom = -10;
            hpanel.de.margin = 30;
            
            hpanel.margintop = 40;
            httl.FontSize = 25;
            
            
            fnSave = sprintf('%s_%s_%s',database.patient{1},database.side{1},stimStatusFielSave);
            
            fac = 0.9;
            prfig.plotwidth           = 16*fac;
            prfig.plotheight          = 10*fac;
            prfig.figdir              = figdirout;
            prfig.figtype             = '-djpeg';
            prfig.figname             = fnSave;
            prfig.resolution          = 150;
            plot_hfig(hfig,prfig)
        end
    end
end

%% plot daily PSD plots for days in which more than 4 hours were recorded 

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