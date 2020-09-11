function rcsAtHome_figures_figure3_0()
%%
close all; clear all; 
rootdir = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/processed_data';
patientAnalyze = {'RCS02'};
dataTable = table();
cntTbl = 1;
load('/Users/roee/Box/rcs paper paper on first five bilateral implants/revision for nature biotechnology/figures/Fig3_0_hours_recrorded/psd_and_cohernce_databases_2.mat');
hoursRecorded = table();
for f = 1:length(dataBases)
    db = dataBases{f}; 
    db = db(db.duration > minutes(2),:);
    metaData = db(1,{'patient','side','area','diagnosis','stimulation_on'});
    timeAwake = seconds(0);
    timeAsleep = seconds(0);
    timeAwake.Format = 'hh:mm';
    timeAsleep.Format = 'hh:mm';
    
    for d = 1:size(db,1)
        if day(db.timeStart(d)) == day(db.timeEnd(d))
            tempTimeVec{1} = db.timeStart(d): minutes(1) : db.timeEnd(d);
        else
            % day 1 
            time1 = db.timeStart(d); 
            datevecUse = datevec(time1); 
            datevecUse(4) = 23;
            datevecUse(5) = 59;
            datevecUse(6) = 59;
            time2 = datetime(datevecUse);
            time2.TimeZone = time1.TimeZone; 
            tempTimeVec{1} = time1: minutes(1) : time2;
            % day 2: 
            tempTimeVec{2} = (time2 + minutes(1)): minutes(1) : db.timeEnd(d);
        end
        for t = 1:length(tempTimeVec)
            timeVecUse = tempTimeVec{t};
            idxAwake = hour(timeVecUse) > 7 & hour(timeVecUse) < 22;
            idxAsleep = hour(timeVecUse) < 8 | hour(timeVecUse) > 21;
            if sum(idxAwake == idxAsleep) > 5
                fprintf('houston we have a problem\n')
            else
                timeAsleep = timeAsleep + minutes(sum(idxAsleep));
                timeAwake = timeAwake + minutes(sum(idxAwake));
            end
        end
    end
    metaData = db(1,{'patient','side','area','diagnosis','stimulation_on'});
    hoursRecorded.patient{f}         = metaData.patient{1};
    hoursRecorded.side{f}            = metaData.side{1};
    hoursRecorded.area{f}            = metaData.area{1};
    hoursRecorded.diagnosis{f}       = metaData.diagnosis{1};
    hoursRecorded.stimulation_on(f)  = metaData.stimulation_on(1);
    hoursRecorded.asleepHours(f)     = timeAsleep;
    hoursRecorded.awakeHours(f)      = timeAwake;   
end
savename = '/Users/roee/Box/rcs paper paper on first five bilateral implants/revision for nature biotechnology/figures/Fig3_0_hours_recrorded/psd_and_cohernce_databases_hours_recorded.mat';
save(savename,'hoursRecorded');


%%
%% panel a bar graph of total hours awake / alseep 


fignum = 3; 
figdirout = '/Users/roee/Box/rcs paper paper on first five bilateral implants/revision for nature biotechnology/figures/Fig3_0_hours_recrorded';
% get only a subset of the data 
idxkeep = strcmp(hoursRecorded.area,'STN') & ... 
          strcmp(hoursRecorded.diagnosis,'PD'); 
tblUse = hoursRecorded(idxkeep,:);       
    
uniquePatients = unique(tblUse.patient); 
recTime = seconds(0);
stimStimState = [];
for p = 1:length(uniquePatients)  
    for s = 1:2
        idxuse = strcmp(tblUse.patient,uniquePatients{p}) & tblUse.stimulation_on == s-1; 
        tblCompute = tblUse(idxuse,:);
        if s-1 == 0 
            recTime(p,1) = sum(tblCompute.awakeHours);
            recTime(p,2) = sum(tblCompute.asleepHours);
        else
            recTime(p,3) = sum(tblCompute.awakeHours);
        end
    end
end
recTime.Format = 'hh:mm';
% fprintf('wake time mean %.2f max %.2f  %.2f\n',mean(recTime(:,1)),max(recTime(:,1)),min(recTime(:,1)));
% fprintf('sleep time mean %.2f max %.2f  %.2f\n',mean(recTime(:,2)),max(recTime(:,2)),min(recTime(:,2)));

clc; 

fprintf('total hours recorded study (%s)\n',sum(recTime(:)));
recTimeOffStim = recTime(:,1:2);
fprintf('total hours recorded off stim (%s)\n',sum(recTimeOffStim(:)));
recTimeOffStim = recTime(1:4,1:2);
fprintf('total hours recorded off stim subs 1-4 (%s)\n',sum(recTimeOffStim(:)));
recTimeOffStim = recTime(:,2);
fprintf('total hours recorded off stim sleeping (%s)\n',sum(recTimeOffStim(:)));
recTimeOffStim = recTime(:,3);
fprintf('total hours recorded on stim awake (%s)\n',sum(recTimeOffStim(:)));
% total hours contributed by RCS08: 
fprintf('total hours recorded by RCS08 (RCS 05 in paper) (%s)\n',sum(recTime(5,:)));


recTime = hours(recTime);
cntplt = 1;
hfig = figure;
hfig.Color = 'w';
hsb = subplot(1,1,1);
hsb(cntplt) = hsb;

hbar = bar(recTime);
altPatientNames = {'RCS01';'RCS02';'RCS03';'RCS04';'RCS05'};
hsb.XTickLabel = altPatientNames;
hsb.YLabel.String = 'Hours recoreded'; 
hsb.Title.String = 'Hours recorded at home / patient'; 
hleg = legend({'awake (stim off)','alseep (stim off)','awake (chronic stim)' },'Location','northwest');
hleg.Box = 'off'; 

% save fig 
if plotpanels
    savefig(hfig,fullfile(figdirout,sprintf('Fig%d_panelA_hours_recorded_at_home',fignum)));
    prfig.plotwidth           = 5;
    prfig.plotheight          = 2.5;
    prfig.figdir             = figdirout;
    prfig.figname             = sprintf('Fig%d_panelA_hours_recorded_at_home',fignum);
    prfig.figtype             = '-dpdf';
    plot_hfig(hfig,prfig)
    close(hfig);
end

%% previous hours to report in the letter to the editor 
resultsdir = '/Users/roee/Box/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home/synced_rcs_pkg_data_saved';
ff = findFilesBVQX(resultsdir,'RCS*.mat'); 
tbl = table();
for f = 1:length(ff) 
    load(ff{f});
    [pn,fn] = fileparts(ff{f});
    tbl.patient{f} = fn(1:5);
    tbl.rcs_side{f} = fn(7);
    tbl.pkg_side{f} = fn(end);
    idxsleep = strcmp(allDataPkgRcsAcc.states,'sleep');
    idxnotsleep = ~strcmp(allDataPkgRcsAcc.states,'sleep');
    tbl.sleep_hours(f) = (sum(idxsleep)*2)/60; 
    tbl.wake_hours(f) = (sum(idxnotsleep)*2)/60; 
    tbl.numStates(f) = length(allDataPkgRcsAcc.states);
end
numStates = tbl.numStates; 
stderror= std( numStates ) / sqrt( length( numStates ))
fprintf('mean %.2f (%.2f-%.2f) (min,max), %.2f SEM\n',...
    mean(numStates), min(numStates),max(numStates), stderror);

totalHoursLastVersion = sum(tbl.sleep_hours) + sum(tbl.wake_hours);
%% 