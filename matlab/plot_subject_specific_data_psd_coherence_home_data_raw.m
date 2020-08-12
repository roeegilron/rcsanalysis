function plot_subject_specific_data_psd_coherence_home_data_raw()
%% load data
rootdir = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/processed_data/';
figdirout = fullfile(rootdir,'figures');
ff = findFilesBVQX(rootdir,'RCS*psdAndCoherence*.mat');

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
        
        prfig.plotwidth           = 18;
        prfig.plotheight          = 12;
        prfig.figdir              = figdirout;
        prfig.figtype             = '-djpeg';
        prfig.figname             = fnSave;
        plot_hfig(hfig,prfig)
    end
end

end