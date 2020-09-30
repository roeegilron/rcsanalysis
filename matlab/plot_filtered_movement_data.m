function plot_filtered_movement_data()
load('/Users/roee/Box/movement_task_data_at_home/results/all_movement_task_contralateral_Brown_share_before_PARRM.mat'); 
% load('/Users/roee/Box/movement_task_data_at_home/results/all_movement_task_contralateral_Brown_share_after_PARRM.mat');
resdir = '/Users/roee/Box/movement_task_data_at_home/results'; % laptop
%%
masterTableUse = masterTableUse; 
tuse = masterTableUse(logical(masterTableUse.stimulation_on),:);
%%
close all;
for m = 1:size(tuse,1)
    stimRate = tuse.stimStatus{m}.rate_Hz; 
    hfig = figure; 
    hfig.Color = 'w'; 
    cntplt = 1; 
    clear hsb;
    for i = 1:2
        fn = sprintf('chan%d',i);
        rawDat  = tuse.rcsRawData{m}.(fn); 
        rawDat  = rawDat - mean(rawDat); 
        secs    = (1:1:length(rawDat))./1e3; 
        hsb(cntplt) = subplot(4,1,cntplt);  cntplt = cntplt + 1;
        hold on;
        plot(secs,rawDat); 
        secsplot = tuse.timeparams{m}.RCidxUse./1e3;
        ylims = get(gca,'YLim'); 
        plot([secsplot secsplot] ,ylims); 
        title(fn);
        ylabel('raw data');
        bp = designfilt('bandpassiir',...
            'FilterOrder',2, ...
            'HalfPowerFrequency1',stimRate-2,...
            'HalfPowerFrequency2',stimRate+2, ...
            'SampleRate',1e3); 
        
        % looking at time course of dc shift 
        
        bp = designfilt('bandpassiir',...
            'FilterOrder',2, ...
            'HalfPowerFrequency1',160,...
            'HalfPowerFrequency2',200, ...
            'SampleRate',1e3); 
        % how to change filter ? 
        % DC - is much below the filter for stim artfiact 
        filt = filtfilt(bp,rawDat);
        [envpH, envpL] = envelope(filt,1e3*2,'analytic'); % analytic rms
        hsb(cntplt) = subplot(4,1,cntplt); cntplt = cntplt + 1;
        hold on; 
        plot(secs,filt,'LineWidth',0.5,'Color',[0 0 0.8 0.01]);
        plot(secs,envpH); 
        title('filter and bp on stim freq'); 
        xlabel('secs'); 
        ylabel('filtered data stim');
    end
    sgtitle(sprintf('%s %s',tuse.patient{m},tuse.side{m}));
    linkaxes(hsb,'x');
    fnsave = fullfile(resdir, sprintf('%s%s_before_PARRM.fig',tuse.patient{m},tuse.side{m}));
%     savefig(hfig,fnsave); 
end