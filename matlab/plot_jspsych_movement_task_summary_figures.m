function plot_jspsych_movement_task_summary_figures()
close all;

boxdir = '/Users/roee/Box/movement_task_data_at_home/data'; % dektop
boxdir = '/Users/roee/Box/movement_task_data_at_home/data'; % laptop
resdir = '/Users/roee/Box/movement_task_data_at_home/results'; % laptop
figdir = '/Users/roee/Box/movement_task_data_at_home/figures'; % laptop


addpath(genpath(fullfile(pwd,'toolboxes','panel-2.14')));
addpath(genpath(fullfile(pwd,'toolboxes','shadedErrorBar')))
%% make database to find if active recharge was used a

load(fullfile(resdir,'task_file_database.mat'),'masterTableUse','taskDataLocs');
for m =1:size(masterTableUse,1)
    masterTableUse.chan4{m} = masterTableUse.senseSettings{m}.chan4{1};
    masterTableUse.active_recharge(m) = masterTableUse.stimStatus{m}.active_recharge(1);
    masterTableUse.stimulation_on(m) = masterTableUse.stimStatus{m}.stimulation_on(1);
end 
masterTableUse = sortrows(masterTableUse,{'patient','unixTimeStart'});
masterTableUse(:,{'patient','side', 'unixTimeStart','chan4','active_recharge','stimulation_on','handUsedForTask'})
% only choose data in which:
idxchoose = cellfun(@(x) any(strfind(x,'1000Hz')), masterTableUse.chan4) & ... 
            ((masterTableUse.stimulation_on & masterTableUse.active_recharge) | (~masterTableUse.stimulation_on));
masterTableUse = masterTableUse(idxchoose,:);
% find matched for master table use (contra lateral only) 
ff = findFilesBVQX(resdir,['*ipsi*prep' '*.mat']);
metaData = table();
potentialResultsFiles = table();
for f = 1:length(ff)
    load(ff{f},'rcsDataMeta');
    potentialResultsFiles.matFile{f} = ff{f}; 
    potentialResultsFiles.deviceSettingsFile{f} = rcsDataMeta.allDeviceSettingsOut{1};
end
for m = 1:size(masterTableUse,1)
    ds = masterTableUse.allDeviceSettingsOut{m};
    idxMatExist = cellfun(@(x) strcmp(x,ds),potentialResultsFiles.deviceSettingsFile);
    if sum(idxMatExist==1)
        masterTableUse.matFile{m} = potentialResultsFiles.matFile(idxMatExist);
    end
end
idxWithResults = cellfun(@(x) ~isempty(x), masterTableUse.matFile);
masterTableUse = masterTableUse(idxWithResults,:);
masterTableUse = sortrows(masterTableUse,{'patient','unixTimeStart'});
masterTableUse(:,{'patient','side', 'unixTimeStart','chan4','active_recharge','stimulation_on','handUsedForTask'})
% loop on left / right brain 
% loop on stim on/stim off

%% plot 
stimState = [0 1];
stimLabels = {'stim off','stim on'};
chanelsPlotIdx = [1 , 2];
chanelsPlotLabels = {'8-10','9-11'};
tuse = 1;
for ci = 1:length(chanelsPlotIdx)
    %% set up figure
    hfig = figure;
    hfig.Color = 'w';
    hpanel = panel();
    hpanel.pack(5,4);
    hpanel.select('all');
    hpanel.fontsize = 12;
    % hpanel.identify();
    

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
            colString = sprintf('stim on %s',tabuse.side{1});
        elseif tabuse.stimulation_on == 0  
            colString = sprintf('stim off %s',tabuse.side{1});
        end
        switch colString
            case 'stim off L'
                coluse = 1;
            case 'stim on L'
                coluse = 2;
            case 'stim off R'
                coluse = 3;
            case 'stim on R'
                coluse = 4;
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
            title(colString,'FontSize',15);
        end
        if tabuse.stimulation_on == 1
            hsb.YAxisLocation = 'right';
            stimText = sprintf('%2.1f mA',tabuse.stimStatus{1}.amplitude_mA);
            fprintf('%s %s %.2fHz\n',tabuse.patient{1}, tabuse.side{1}, tabuse.stimStatus{1}.rate_Hz)
            ylabel(stimText);
        end
    end
    %%
    hpanel.marginleft = 30;
    hpanel.margintop = 15;
    hpanel.marginright = 15;
    hpanel.de.margin = 7;
    
    
    hfig = gcf;
    hfig.PaperSize = [9 9];
    hfig.PaperPosition = [0 0 9 9];
    fnmsv = sprintf('all_patient_center_move__left_and_right_CONTRA_NO-zscore_%s_%s',chanelsPlotLabels{ci});
    print(hfig,fullfile(figdir,fnmsv),'-djpeg','-r300');
end



return 
















end