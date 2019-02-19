function temp_analyze_driving()
%% load data 
datadir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v10-3-month/rcs_data/patient_comp/driving and randy app/Session1546902587066/DeviceNPC700395H';
[outdatcomplete,outRec,eventTable,outDatAcc] =  MAIN_load_rcs_data_from_folder(datadir);

% clean events 
difs = seconds(diff(eventTable.UnixOnsetTime));
idxx = find(difs < seconds(1)) + 1; % exclude these indices 
idxi = setdiff(1:size(eventTable,1),idxx);
etNew = eventTable(idxi,:); 

%% plot raw data and events 
datUse = outdatcomplete(500*60:end-500*45,:);
hfig = figure; 
for c = 1:4
    hsub(c) = subplot(5,1,c); 
    hold on;
    fnm = sprintf('key%d',c-1);
    y = datUse.(fnm);
    y = y - mean(y);
    ylimsuse = [prctile(y,0.03) prctile(y,0.97) ];
    plot(hsub(c),datUse.derivedTimes,y);
    title(hsub(c),outRec(1).tdData(c).chanFullStr);
    % plot events 
    ylims = get(gca,'YLim'); 
    goidx = cellfun(@(x) strcmp(x,'1'), etNew.EventSubType);
    stopidx = cellfun(@(x) strcmp(x,'2'), etNew.EventSubType);
    hplt = plot([etNew.UnixOnsetTime(goidx), etNew.UnixOnsetTime(goidx)],ylimsuse,...
        'LineWidth',2',...
        'Color',[0 1 0.9]); 
    
    hplt = plot([etNew.UnixOnsetTime(stopidx), etNew.UnixOnsetTime(stopidx)],ylimsuse,...
        'LineWidth',2',...
        'Color',[1 0 0]); 
end
hsub(c+1) = subplot(5,1,c+1);
hold on;
axisUse = {'X','Y','Z'}; 
for i = 1:3
    acc = outDatAcc.([axisUse{i} 'Samples']); 
    acc = acc - mean(acc); 
%     plot(outDatAcc.derivedTimes,acc); 
end
xs = outDatAcc.XSamples - mean(outDatAcc.XSamples); 
ys = outDatAcc.YSamples - mean(outDatAcc.YSamples); 
zs = outDatAcc.ZSamples - mean(outDatAcc.ZSamples); 
% legend({'x','y','z','diffx-z'}); 

diffxz = xs-zs; 
mvmean = movmean(diffxz,[30,0]); 

bp = designfilt('bandpassiir',...
    'FilterOrder',2, ...
    'HalfPowerFrequency1',1,...
    'HalfPowerFrequency2',20, ...
    'SampleRate',64);
dat1 = filtfilt(bp,diffxz);
[envpH, envpL] = envelope(dat1,120,'analytic'); % analytic rms


idxPlot = find(diff(diffxz > 10) == 1) + 1;
plot(outDatAcc.derivedTimes,rescale(diffxz,-1,1),'LineWidth',2); 
plot(outDatAcc.derivedTimes,rescale(mvmean,-1,1),'LineWidth',2); 

legend({'diffx-z','movemena'}); 

linkaxes(hsub,'x'); 

% plot driving based on stop and go cue 

%% plot ipad data based on this alligmment 
timeparams.start_epoch_at_this_time    = -7000;%-8000; % ms relative to event (before), these are set for whole analysis
timeparams.stop_epoch_at_this_time     =  7000; % ms relative to event (after)
timeparams.start_baseline_at_this_time = -2000;%-6500; % ms relative to event (before), recommend using ~500 ms *note in the msns folder there is a modified version where you can set baseline bounds by trial (good for varible times, ex. SSD)
timeparams.stop_baseline_at_this_time  = 0;%5-6000; % ms relative to event
timeparams.extralines                  = 0; % plot extra line
timeparams.extralinesec                = 3000; % extra line location in seconds
timeparams.analysis                    = 'hold_center';
timeparams.filtertype                  = 'fir1' ; % 'ifft-gaussian' or 'fir1'

figdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v10-3-month/figures';
goidx = cellfun(@(x) strcmp(x,'1'), etNew.EventSubType);
stopidx = cellfun(@(x) strcmp(x,'2'), etNew.EventSubType);

beepsInSeconds = seconds( seconds(etNew.UnixOnsetTime( goidx) - outdatcomplete.derivedTimes(1)));
rcsIdxs = ceil(seconds(beepsInSeconds).*unique(unique(outdatcomplete.samplerate))); 
pathadd = '/Users/roee/Starr_Lab_Folder/Data_Analysis/First_Pass_Data_Analysis/code/from_nicki';
addpath(genpath(pathadd));
% rcsdat.lfp = outdatcomplete.key1; 
% rcsdat.ecog = outdatcomplete.key3;
tdDat = outRec(1).tdData;
for c = 1:4  
    cnmIpadData = sprintf('key%d',c-1);
    cnm = sprintf('chan%d',c); 
    rcsIpadDataPlot.(cnm) = outdatcomplete.(cnmIpadData);
    rcsIpadDataPlot.([cnm 'Title']) = tdDat(c).chanFullStr;
end
rcsIpadDataPlot.numChannels = 4; 
plot_ipad_data_rcs_json(rcsIdxs,rcsIpadDataPlot,unique(outdatcomplete.samplerate),figdir,timeparams)
rmpath(genpath(pathadd));
end