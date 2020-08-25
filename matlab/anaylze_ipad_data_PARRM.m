function anaylze_ipad_data_PARRM()
clear all;
close all;
load('/Users/roee/Box/movement_task_data_at_home/results/masterTableUsePARRM.mat');
figdir = '/Users/roee/Box/movement_task_data_at_home/figures';
resdir = '/Users/roee/Box/movement_task_data_at_home/results'; % laptop

tuse = masterTableUse;
% tuse = masterTableUse(logical(masterTableUse.stimulation_on),:);

%%
close all;
%% plot ipad data based on this alligmment
pathadd = '/Users/roee/Box/movement_task_data_at_home/code/from_nicki';
addpath(genpath(pathadd));
addpath('/Users/roee/Box/movement_task_data_at_home/code/eeglab');

for m = 1:size(tuse,1)
    stimRate = tuse.stimStatus{m}.rate_Hz;
    rcsIpadDataPlot = tuse.rcsRawData{m};
    if ~isempty(tuse.rcsPARRMData{m})
        rcsIpadDataPlot.chan1 = tuse.rcsPARRMData{m}.chan1';
        rcsIpadDataPlot.chan2 = tuse.rcsPARRMData{m}.chan2';
    end
    sr = tuse.senseSettings{m}.samplingRate;
    timeparams = tuse.timeparams{m};
    timeparams.filtertype = 'fir1';
    idxUseRxUnixTime = timeparams.RCidxUse;
    timeparams = plot_ipad_data_rcs_json(idxUseRxUnixTime,rcsIpadDataPlot,sr,figdir,timeparams,...
        1,2,0,2,250); % nrwos, ncols, save figure, min freq , max freq
    
    %% save figure
    patient = tuse.patient{m};
    brainSideChoose = tuse.side{m};
    handUsed = tuse.handUsedForTask{m};
    handBrainRelation  = 'contra';
    timeStart = tuse.timeStart(m);
    timeEnd = tuse.timeEnd(m);
    if tuse.stimulation_on(m)
        stimState = 'stim on';
    else
        stimState = 'stim off';
    end
    hfig = gcf;
    hfig.PaperSize = [14 6];
    hfig.PaperPosition = [0 0 14 6];
    largeTitle = {};
    largeTitle{1,1} = sprintf('%s %s (brain) %s (hand) (%s)',patient,brainSideChoose,handUsed,handBrainRelation);
    largeTitle{2,1} = sprintf('%s',stimState);
    largeTitle{3,1} = sprintf('%s',strrep('red line - target presented (prep) green line - go cue (move)','_',' '));
    largeTitle{4,1} = sprintf('%s - %s', timeStart,timeEnd);
    sgtitle(largeTitle);
    fnmsv = sprintf('%s_%s-brain-%s-hand_%s___%s____%d-%0.2d-%0.2d__%0.2d-%0.2d_PARRM',...
        patient,brainSideChoose,handUsed,...
        handBrainRelation,...
        timeparams.analysis,...
        year(timeStart),...
        month(timeStart),...
        day(timeStart),...
        hour(timeStart),...
        minute(timeStart));
    
    %% save data
    save(fullfile(resdir,[fnmsv '.mat']),'timeparams','rcsIpadDataPlot');
    
    print(hfig,fullfile(figdir,fnmsv),'-djpeg','-r300');
end
end