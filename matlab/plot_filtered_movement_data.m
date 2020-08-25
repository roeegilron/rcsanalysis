function plot_filtered_movement_data()
load('/Users/roee/Box/movement_task_data_at_home/results/all_movement_task_contralateral_Brown_share.mat'); 
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
        subplot(4,1,cntplt);  cntplt = cntplt + 1;
        hsb(cntplt) = plot(secs,rawDat); 
        ylabel('raw data');
        bp = designfilt('bandpassiir',...
            'FilterOrder',2, ...
            'HalfPowerFrequency1',stimRate-2,...
            'HalfPowerFrequency2',stimRate+2, ...
            'SampleRate',1e3);
        filt = filtfilt(bp,rawDat);
        [envpH, envpL] = envelope(filt,1e3*2,'analytic'); % analytic rms
        hsb(cntplt) = subplot(4,1,cntplt); cntplt = cntplt + 1;
        hold on; 
        plot(secs,filt,'LineWidth',0.5,'Color',[0 0 0.8 0.01]);
        plot(secs,envpH); 
        xlabel('secs'); 
        ylabel('filtered data stim');
    end
    sgtitle(sprintf('%s %s',tuse.patient{m},tuse.side{m}));
    linkaxes(hsb,'x');
end