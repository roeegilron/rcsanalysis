function rcsAtHome_figures_figures4()
% original function: 
% plot_jspsych_movement_task_summary_figures.m

close all;

boxdir = '/Users/roee/Box/movement_task_data_at_home/data'; % dektop
boxdir = '/Users/roee/Box/movement_task_data_at_home/data'; % laptop
resdir = '/Users/roee/Box/movement_task_data_at_home/results'; % laptop
figdir = '/Users/roee/Box/movement_task_data_at_home/figures'; % laptop


fnsave = fullfile(resdir,'all_movement_task_contralateral_Brown_share_before_PARRM.mat');

load(fnsave,'masterTableUse'); 

% find out when this was recorded compared to surgery date 
dirSave = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database';
load(fullfile(dirSave, 'deviceIdMasterList.mat'),'masterTable'); 

for m = 1:size(masterTableUse,1)
    idxuse = cellfun(@(x) strcmp(x,masterTableUse.patient{m}),masterTable.patient) & ...
             cellfun(@(x) strcmp(x,masterTableUse.side{m}),masterTable.side);
    surgeryDate = masterTable.implntDate(idxuse);
    timeDiff(m) = masterTableUse.timeStart(m) - surgeryDate;
end
timeDiff.Format = 'dd:hh:mm:ss';
mean(timeDiff) 
min(timeDiff)
max(timeDiff)
% loop on left / right brain 
% loop on stim on/stim off

%% plot 
stimState = [0 1];
stimLabels = {'stim off','stim on'};
chanelsPlotIdx = [1 , 2];
chanelsPlotLabels = {'+8-10','+9-11'};
tuse = 1;
%% set up figure
hfig = figure;
hfig.Color = 'w';
hpanel = panel();
hpanel.pack(5,8);
hpanel.select('all');
hpanel.fontsize = 12;
% hpanel.identify();

for ci = 1:length(chanelsPlotIdx)
    for pp = 1:size(masterTableUse,1)
        tabuse = masterTableUse(pp,:);
        load(tabuse.matFile{1}{1});
        %% plot figure
        % find out which row to put data in 
        switch tabuse.patient{1}
            case 'RCS02'
                rowuse = 1;
            case 'RCS05'
                rowuse = 2;
            case 'RCS06'
                rowuse = 3;
            case 'RCS07'
                rowuse = 4;
            case 'RCS08'
                rowuse = 5;
        end
        % find out which colomn to put data in 
        if tabuse.stimulation_on == 1 
            colString = sprintf('stim on %s %s',tabuse.side{1},chanelsPlotLabels{ci});
            ttlString{1,1} = sprintf('stim on %s',tabuse.side{1});
            ttlString{1,2} = sprintf('%s',chanelsPlotLabels{ci});
        elseif tabuse.stimulation_on == 0  
            colString = sprintf('stim off %s %s',tabuse.side{1},chanelsPlotLabels{ci});
            ttlString{1,1} = sprintf('stim off %s',tabuse.side{1});
            ttlString{1,2} = sprintf('%s',chanelsPlotLabels{ci});
        end
        switch colString
            case 'stim off L +8-10'
                coluse = 1;
            case 'stim off L +9-11'
                coluse = 2;
            case 'stim on L +8-10'
                coluse = 3;
            case 'stim on L +9-11'
                coluse = 4;
            case 'stim off R +8-10'
                coluse = 5;
            case 'stim off R +9-11'
                coluse = 6;
            case 'stim on R +8-10'
                coluse = 7;
            case 'stim on R +9-11'
                coluse = 8;
        end
        hpanel(rowuse,coluse).select();
        hsb = gca();
        cmax= 2;%max(abs(squeeze(zertf(:))));
        cmin=-cmax;
        % zscore 
        tempmat=double(squeeze(timeparams.zertf(:,:,1,chanelsPlotIdx(ci))));
        
        % no zscore 
%         tempmat = double(squeeze(timeparams.ertf(:,:,1,chanelsPlotIdx(ci))));
%         tempmat = tempmat./repmat(mean(tempmat(:,1:1000),2),1,size(tempmat,2));
%         cmax= max(abs(squeeze(tempmat(:))));
%         cmin=-max(abs(squeeze(tempmat(:))));
        
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
        if coluse == 1
            ylab{1,1} = tabuse.patient{1};
            ylab{2,1} = 'Frequency (Hz)';
            ylabel(ylab);
        else
            hsb.YTick = [];
        end
        hold on;
        axis tight
        if tuse == 1
            xxxx = 2;
        else
            hsb.XLim = [-1 1];
        end
        %         colorbar;
        if rowuse == 5 % assumes 5 patietns 
            xlabel('time (s)');
        else
            % get rid of time for evertyhing but bottom braphs
            x= 2;
            hsb.XTick = [];
        end
        if rowuse == 1

            title(ttlString,'FontSize',15);
        end
        if tabuse.stimulation_on == 1 && (coluse == 4 || coluse == 8)
            hsb.YAxisLocation = 'right';
            stimText = sprintf('%2.1f mA',tabuse.stimStatus{1}.amplitude_mA);
            fprintf('%s %s %.2fHz\n',tabuse.patient{1}, tabuse.side{1}, tabuse.stimStatus{1}.rate_Hz)
            ylabel(stimText);
        end
    end
end

% put in alt patient names 
altPatNames = {'RCS01','RCS02','RCS03','RCS04','RCS05'};
for i = 1:5
    hsb = hpanel(i,1).select();
    hsb.YLabel.String{1} = altPatNames{i};
end

hpanel.de.margin = 5;

for i = 1:5
    hpanel(i,4).marginright = 20;
end

hpanel.marginleft = 30;
hpanel.margintop = 15;
hpanel.marginright = 15;



hfig = gcf;
hpanel.fontsize = 10;
fnmsv = sprintf('all_patient_center_key_Up__left_and_right_CONTRA_-zscore_%s_cutting_out_stim',chanelsPlotLabels{ci});

% hfig.Renderer='Painters';
prfig.figdir = figdir;
prfig.figtype = '-djpeg';
prfig.resolution = 600;
prfig.closeafterprint = 0;
prfig.plotwidth           = 16;
prfig.plotheight          = 9;
prfig.figname             = fnmsv;
plot_hfig(hfig,prfig)
% print(hfig,fullfile(figdir,fnmsv),'-dpdf','-r200');

% make vector based figure no images, followd by only images 
% later stitch toegether in illustrator 

%% vector based: 
fnmsv = sprintf('all_patient_center_key_Up__left_and_right_CONTRA_-zscore_%s_cutting_out_stim_ONLY_VECTOR',chanelsPlotLabels{ci});
axs = hfig.Children;
for a = 1:length(axs)
    for c =  1:length(axs(1).Children)
        if strcmp(axs(a).Children(c).Type,'surface')
            axs(a).Children(c).Visible = 'off';
        end
    end
end
prfig.figdir = figdir;
prfig.figtype = '-dpdf';
prfig.resolution = 600;
prfig.closeafterprint = 0;
prfig.plotwidth           = 16;
prfig.plotheight          = 9;
prfig.figname             = fnmsv;
plot_hfig(hfig,prfig)
%%

%% image based: 
fnmsv = sprintf('all_patient_center_key_Up__left_and_right_CONTRA_-zscore_%s_cutting_out_stim_ONLY_IMAGE',chanelsPlotLabels{ci});
axs = hfig.Children;
for a = 1:length(axs)
    for c =  1:length(axs(1).Children)
        if strcmp(axs(a).Children(c).Type,'surface')
            axs(a).Children(c).Visible = 'on';
        end
        
        if strcmp(axs(a).Children(c).Type,'line')
            axs(a).Children(c).Visible = 'off';
        end
    end
    axs(a).Title.Visible = 'off';
    axs(a).YLabel.Visible = 'off';
    axs(a).XLabel.Visible = 'off';
    axs(a).YTick = [];
    axs(a).XTick = [];
end

end