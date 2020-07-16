function plot_jspsych_movement_task_summary_figures()
close all;

boxdir = '/Users/roee/Box/movement_task_data_at_home/data'; % dektop
boxdir = '/Users/roee/Box/movement_task_data_at_home/data'; % laptop
resdir = '/Users/roee/Box/movement_task_data_at_home/results'; % laptop
figdir = '/Users/roee/Box/movement_task_data_at_home/figures'; % laptop


addpath(genpath(fullfile(pwd,'toolboxes','panel-2.14')));
addpath(genpath(fullfile(pwd,'toolboxes','shadedErrorBar')))
%% make database
plot_spects = 1;
if plot_spects
    task_search = {'center_prep','center_move'};
    for tuse = 1:length ( task_search)
        
        ff = findFilesBVQX(resdir,['RCS*' task_search{tuse} '*.mat']);
        metaData = table();
        for f = 1:length(ff)
            load(ff{f},'rcsDataMeta');
            rcsDataMeta.file{1} = ff{f};
            if f == 1
                metaData = rcsDataMeta(1,:);
            else
                metaData = [metaData; rcsDataMeta(1,:)];
            end
        end
        idxchoose = strcmp(metaData.side,'L');
        metaData = metaData(idxchoose,:);
        
        %% set up figure
        hfig = figure;
        hfig.Color = 'w';
        hpanel = panel();
        hpanel.pack(5,2);
        hpanel.select('all');
        hpanel.fontsize = 12;
        % hpanel.identify();
        
        %%
        
        
        %% loop on stim states
        stimState = [0 1];
        stimLabels = {'stim off','stim on'};
        chanelsPlotIdx = [1 , 2];
        chanelsPlotLabels = {'8-10','9-11'};
        for ci = 1:length(chanelsPlotIdx)
            for ss = 1:2
                tabuse = metaData(metaData.stimulation_on == stimState(ss),:);
                stimLabels{ss}
                for pp = 1:size(tabuse,1)
                    load(tabuse.file{pp});
                    %% plot figure
                    hpanel(pp,ss).select();
                    hsb = gca();
                    cmax= 2;%max(abs(squeeze(zertf(:))));
                    cmin=-cmax;
                    tempmat=double(squeeze(timeparams.zertf(:,:,1,chanelsPlotIdx(ci))));
                    pcolor(timeparams.epoch_time./1000,timeparams.center_frequencies,tempmat);
                    shading interp;
                    caxis([cmin cmax]);
                    hold on;
                    %         title(ttluse, 'FontWeight', 'bold','FontSize',16);
                    hold(hsb,'on');
                    YLim = get(gca,'YLim');
                    plot([0 0 ],YLim,...
                        'LineWidth',4,...
                        'LineStyle','-.',...
                        'Color',[0.8 0.1 0.1 0.7]);
                    
                    if timeparams.extralines
                        plot([timeparams.extralinesec./1000 timeparams.extralinesec./1000],[YLim ],...
                            'LineWidth',4,...
                            'LineStyle','-.',...
                            'Color',[0 0.39 0 0.7]);
                    end
                    if ss == 1
                        ylab{1,1} = rcsDataMeta.patient{1};
                        ylab{2,1} = 'Frequency (Hz)';
                        ylabel(ylab);
                    else
                        hsb.YTick = [];
                    end
                    hold on;
                    axis tight
                    if tuse == 1
                        
                    else
                        hsb.XLim = [-1 1];
                    end
                    %         colorbar;
                    if pp == size(tabuse,1)
                        xlabel('time (s)');
                    else
                        % get rid of time for evertyhing but bottom braphs
                        x= 2;
                        hsb.XTick = [];
                    end
                    if pp == 1
                        title(stimLabels{ss},'FontSize',15);
                    end
                    if ss == 2 
                        hsb.YAxisLocation = 'right';
                        stimText = sprintf('%2.1f mA',rcsDataMeta.amplitude_mA);
                        ylabel(stimText);
                    end
                end
            end
            %%
            hpanel.marginleft = 30;
            hpanel.margintop = 15;
            hpanel.marginright = 15;
            hpanel.de.margin = 7;
            
            
            hfig = gcf;
            hfig.PaperSize = [6 9];
            hfig.PaperPosition = [0 0 6 9];
            fnmsv = sprintf('all_patient_center_move_%s_%s',chanelsPlotLabels{ci},task_search{tuse});
            print(hfig,fullfile(figdir,fnmsv),'-djpeg','-r300');
        end
    end
end




%%%%%
%%%%%
%%%%%

%% make database
task_search = {'center_prep'};
for tuse = 1:length ( task_search)
    
    ff = findFilesBVQX(resdir,['RCS*' task_search{tuse} '*.mat']);
    metaData = table();
    for f = 1:length(ff)
        load(ff{f},'rcsDataMeta');
        rcsDataMeta.file{1} = ff{f};
        if f == 1
            metaData = rcsDataMeta(1,:);
        else
            metaData = [metaData; rcsDataMeta(1,:)];
        end
    end
    idxchoose = strcmp(metaData.side,'L');
    metaData = metaData(idxchoose,:);
    

    
    %% loop on stim states
    stimState = [0 1];
    stimLabels = {'stim off','stim on'};
    chanelsPlotIdx = [1 , 2];
    chanelsPlotLabels = {'8-10','9-11'};
    for ci = 1:length(chanelsPlotIdx)
        %% set up figure
        hfig = figure;
        hfig.Color = 'w';
        hpanel = panel();
        hpanel.pack(5,2);
        hpanel.select('all');
        hpanel.fontsize = 12;
        % hpanel.identify();

        for ss = 1:2
            tabuse = metaData(metaData.stimulation_on == stimState(ss),:);
            stimLabels{ss}
            for pp = 1:size(tabuse,1)
                load(tabuse.file{pp});
                %% plot figure
                hpanel(pp,ss).select();
                hsb = gca();
                hold(hsb,'on');
                cmax= 2;%max(abs(squeeze(zertf(:))));
                cmin=-cmax;
                
                
                cfn = sprintf('chan%d',chanelsPlotIdx(ci));
                dat = rcsIpadDataPlot.(cfn);
                
                sr = 1e3; 
                for ii = 1:length(timeparams.RCidxUse)
                    % fixation 
                    idxRaw = timeparams.RCidxUse(ii)-1000:1:timeparams.RCidxUse(ii);
                    datuse = dat(idxRaw); 
                    [fftOutFix(ii,:),ff]   = pwelch(datuse,sr,sr/2,0:1:sr/2,sr,'psd');
                    % preperation 
                    idxRaw = timeparams.RCidxUse(ii)+2000:1:timeparams.RCidxUse(ii)+3000;
                    datuse = dat(idxRaw);
                    [fftOutPrep(ii,:),ff]   = pwelch(datuse,sr,sr/2,0:1:sr/2,sr,'psd');
                    
                    idxRaw = timeparams.RCidxUse(ii)+3300:1:timeparams.RCidxUse(ii)+4300;
                    datuse = dat(idxRaw);
                    [fftOutMove(ii,:),ff]   = pwelch(datuse,sr,sr/2,0:1:sr/2,sr,'psd');
                end
                

                shadedErrorBar(ff,log10(fftOutFix),...
                    {@median,@(yy) std(yy)./sqrt(size(yy,1))},'lineprops',{'r','markerfacecolor','r','LineWidth',2});
                
                shadedErrorBar(ff,log10(fftOutPrep),...
                    {@median,@(yy) std(yy)./sqrt(size(yy,1))},'lineprops',{'b','markerfacecolor','b','LineWidth',2});
                
                
                shadedErrorBar(ff,log10(fftOutMove),...
                    {@median,@(yy) std(yy)./sqrt(size(yy,1))},'lineprops',{'g','markerfacecolor','g','LineWidth',2});


                if ss == 1
                    ylab{1,1} = rcsDataMeta.patient{1};
                    ylab{2,1} = 'Power (log_1_0\muV^2/Hz)';
                    ylabel(ylab);
                else
                    hsb.YTick = [];
                end
                hold on;
                axis tight
                if tuse == 1
                    
                else
                end
                %         colorbar;
                if pp == size(tabuse,1)
                    xlabel('Frequency (Hz)');
                else
                    % get rid of time for evertyhing but bottom braphs
                    x= 2;
                    hsb.XTick = [];
                end
                if pp == 1
                    title(stimLabels{ss},'FontSize',15);
                end
                xlim(hsb,[0 200]);
            end
        end
        %%
        hpanel.marginleft = 30;
        hpanel.margintop = 15;
        hpanel.de.margin = 7;
        
        
        hfig = gcf;
        hfig.PaperSize = [6 9];
        hfig.PaperPosition = [0 0 6 9];
        fnmsv = sprintf('all_patient_psds_%s_%s',chanelsPlotLabels{ci},task_search{tuse});
        print(hfig,fullfile(figdir,fnmsv),'-djpeg','-r300');
    end
end

end