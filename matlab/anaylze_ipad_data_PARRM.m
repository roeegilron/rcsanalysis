function anaylze_ipad_data_PARRM()
clear all;
close all;
load('/Users/roee/Box/movement_task_data_at_home/results/masterTableUsePARRM.mat');
load('/Users/roee/Box/movement_task_data_at_home/results/parrm_no_parrm_figures/masterTableUseAllFilters.mat');
figdir = '/Users/roee/Box/movement_task_data_at_home/figures';
resdir = '/Users/roee/Box/movement_task_data_at_home/results'; % laptop

tuse = masterTableUse;
% tuse = masterTableUse(logical(masterTableUse.stimulation_on),:);

%%
close all;
%% plot ipad data based on this alligmment
restoredefaultpath;
pathadd = '/Users/roee/Box/movement_task_data_at_home/code/from_nicki';
addpath(pathadd);
% addpath(genpath('/Users/roee/Box/movement_task_data_at_home/code/eeglab'));

% addpath('/Users/roee/Box/movement_task_data_at_home/code/eeglab');
% for m = 1:size(tuse,1)
%     rcsDataMeta = tuse(m,:);
%     patient = tuse.patient{m};
%     brainSideChoose = tuse.side{m};
%     handUsed = tuse.handUsedForTask{m};
%     handBrainRelation  = 'contra';
%     timeStart = tuse.timeStart(m);
%     timeEnd = tuse.timeEnd(m);
%     fnmsv = sprintf('%s_%s-brain-%s-hand_%s___%s____%d-%0.2d-%0.2d__%0.2d-%0.2d_PARRM',...
%         patient,brainSideChoose,handUsed,...
%         handBrainRelation,...
%         timeparams.analysis,...
%         year(timeStart),...
%         month(timeStart),...
%         day(timeStart),...
%         hour(timeStart),...
%         minute(timeStart));
%     
%     % save data
%     save(fullfile(resdir,[fnmsv '.mat']),'rcsDataMeta','-append');
% end

typesOfAnalysis = {'rcsHampelData','rcsNotchData','rcsMatchData','rcsPARRMData','rcsRawData'};
% typesOfAnalysis = {'rcsPARRMData','rcsHampelData','rcsNotchData','rcsMatchData'};
for ttt = 1:length(typesOfAnalysis)
    for m = 1:size(tuse,1)
        stimRate = tuse.stimStatus{m}.rate_Hz;
        rcsIpadDataPlot = tuse.(typesOfAnalysis{ttt}){m};
        if ~isempty(rcsIpadDataPlot)
            rcsIpadDataPlot.chan1 = rcsIpadDataPlot.chan1';
            rcsIpadDataPlot.(['chan1' 'Title']) = tuse.senseSettings{m}.chan1;
            rcsIpadDataPlot.chan2 = rcsIpadDataPlot.chan2';
            rcsIpadDataPlot.(['chan2' 'Title']) = tuse.senseSettings{m}.chan2;
            rcsIpadDataPlot.numChannels = 2;
        else
            rcsIpadDataPlot = tuse.(typesOfAnalysis{end}){m};
            rcsIpadDataPlot.chan1 = rcsIpadDataPlot.chan1';
            rcsIpadDataPlot.(['chan1' 'Title']) = tuse.senseSettings{m}.chan1;
            rcsIpadDataPlot.chan2 = rcsIpadDataPlot.chan2';
            rcsIpadDataPlot.(['chan2' 'Title']) = tuse.senseSettings{m}.chan2;
            rcsIpadDataPlot.numChannels = 2;
        end
        % make data as small as possible for guassian algos 
        sr = tuse.senseSettings{m}.samplingRate;
        timeparams = tuse.timeparams{m};
        samplesCut = 1000*10; 
        idxStart = timeparams.RCidxUse(1) - samplesCut;
        idxEnd = timeparams.RCidxUse(end) + samplesCut;
        timeparams.RCidxUse = timeparams.RCidxUse - (timeparams.RCidxUse(1) - samplesCut);
        rcsIpadDataPlot.chan1 = rcsIpadDataPlot.chan1(idxStart:idxEnd); 
        rcsIpadDataPlot.chan2 = rcsIpadDataPlot.chan2(idxStart:idxEnd); 

        timeparams.filtertype = 'fir1';
        idxUseRxUnixTime = timeparams.RCidxUse;
        % clean stim outliers
%         if tuse.stimulation_on(m)
%             idxRCOut = cleanDataFromStimulationArtifacts(rcsIpadDataPlot,timeparams.RCidxUse,tuse(m,:),timeparams);
%             timeparams.RCidxUse = idxRCOut;
%         end
        
        
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
        largeTitle{5,1} = sprintf('%s', typesOfAnalysis{ttt});
        sgtitle(largeTitle);
        fnmsv = sprintf('%s_%s-brain-%s-hand_%s___%s____%d-%0.2d-%0.2d__%0.2d-%0.2d_%s',...
            patient,brainSideChoose,handUsed,...
            handBrainRelation,...
            timeparams.analysis,...
            year(timeStart),...
            month(timeStart),...
            day(timeStart),...
            hour(timeStart),...
            minute(timeStart),...
            typesOfAnalysis{ttt});
        
        %% save data
        save(fullfile(resdir,[fnmsv '.mat']),'timeparams','rcsIpadDataPlot');
        
        print(hfig,fullfile(figdir,fnmsv),'-djpeg','-r300');
    end
end
end

function idxRCOut = cleanDataFromStimulationArtifacts(rcsIpadDataPlot,idxRC,rcsDataMeta,timeparams)
stimRate = rcsDataMeta.stimStatus{1}.rate_Hz; 
samplingRate = rcsDataMeta.senseSettings{1}.samplingRate;
bp = designfilt('bandpassiir',...
    'FilterOrder',4, ...
    'HalfPowerFrequency1',ceil(stimRate-2),...
    'HalfPowerFrequency2',ceil(stimRate+2), ...
    'SampleRate',samplingRate);

fieldnamesAll = fieldnames(rcsIpadDataPlot);
fieldNameIdxUse = cellfun(@(x) any(strfind(x,'chan')),fieldnamesAll) & ~cellfun(@(x) any(strfind(x,'Title')),fieldnamesAll);
fieldNamesUse = fieldnamesAll(fieldNameIdxUse);
pointSubtract = (timeparams.start_epoch_at_this_time/1e3) * samplingRate;
pointAdd = (timeparams.stop_epoch_at_this_time/1e3) * samplingRate;
idxremove = [];
for i = 1:length(fieldNamesUse)
    fn = fieldNamesUse{i};
    rawData = rcsIpadDataPlot.(fn); 
    filtData = [];
    for t = 1:length(idxRC)
        idxRange = (idxRC(t)+pointSubtract):1:(idxRC(t)+pointAdd-1);
        taskData = rawData(idxRange,1);
        filtData(t,:) = filtfilt(bp,taskData);
        [envpH, envpL] = envelope(filtData(t,:),samplingRate*30,'analytic'); % analytic rms
        mvmean(t,:) = movmean(abs(envpH),[ceil(range(idxRange)/10),0]);
        secs = [1:1:length(taskData)]./samplingRate;
    end
    
    prc = prctile(mvmean',0.8);
    outliers = isoutlier(prc) & prc > median(prc);
    %%
    figure;
    hold on;
    plot(secs,mvmean(~outliers,:)','Color',[0 0 0.8 0.5]);
    if sum(outliers) >= 1
        plot(secs,mvmean(outliers,:),'Color',[0.8 0 0 0.5],'LineWidth',2);
    end
    %%
    outliersBothChannels(i,:)  = outliers';
    
    clear prc outliers 
    
end
% rreport what was removed 
idxremove = sum(outliersBothChannels,2)>=1; 
fprintf('removed %d/%d trials (%.2f) bcs of stim artifacts \n',sum(idxremove),length(idxremove),sum(idxremove)/size(outliersBothChannels,2));
idxNotWithStimArtifact = ~idxremove; 
idxRCOut = idxRC(idxNotWithStimArtifact);


end