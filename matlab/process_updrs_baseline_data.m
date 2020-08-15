function process_updrs_baseline_data()
dirname = '/Users/roee/Box/rcs paper paper on first five bilateral implants/revision for nature biotechnology/figures/Fig5_states_estimates_group_data_and_ AUC/baseline_updrs';
ff = findFilesBVQX(dirname,'*.csv');
outTable = table();
cnt = 1;
for f = 1:length(ff)
    rawTab = readtable(ff{f});
    if any(strfind(ff{f},'off_meds'))
        medState = 'off meds';
    elseif any(strfind(ff{f},'on_meds'))
        medState = 'on meds';
    end
    varsExist = fieldnames(rawTab); 
    fnLoop = varsExist(2:end-3); 
    for fn = 1:length(fnLoop)
        outTable.patient{cnt} = rawTab.RecordId{1};
        ;
        outTable.medState{cnt} = medState;
        if any(strfind(lower(fnLoop{fn}),'right'))
            outTable.side{cnt} = 'right';
        elseif any(strfind(lower(fnLoop{fn}),'left'))
            outTable.side{cnt} = 'left';
        else
            outTable.side{cnt} = 'NA';
        end
        outTable.measure{cnt} = fnLoop{fn};
        if strcmp(fnLoop{fn}(1),'x')
            x =2 ;
            rawVal = regexp(fnLoop{fn},'[0-9]+_[0-9]+','match');
            rawVal = strrep( rawVal{1} ,'_','.');
            measureNumber = str2num(rawVal);
            outTable.measure_number(cnt) = measureNumber;
        end
        rawVal = rawTab.(fnLoop{fn});
        if iscell(rawVal)
            outTable.RawValue{cnt} = rawVal{1};
        elseif isnan(rawVal)
            outTable.RawValue{cnt} = NaN;
        else
            outTable.RawValue{cnt} = rawVal;
        end
        cnt = cnt + 1;
    end    
end
% get table of only left/rigtt 
idxLeftRight = strcmp(outTable.side,'right') | strcmp(outTable.side,'left');
partialScores = outTable(idxLeftRight,:);

for p = 1:size(partialScores,1)
    x = partialScores.RawValue{p};
    if ischar(x)
        score = str2num(x(regexp(x,'[0-9]+')));
    elseif isnumeric(x)
        score = x; 
    else
        x = NaN;
    end
    partialScores.score(p) = score;
end
outData = partialScores(:,{'patient','side','medState','measure','score','measure_number'});
% loop on all partial scores and extract the raw value.

% get summary table 
uniquePatient = unique(outData.patient);
uniqueSides   = unique(outData.side); 
medStates     = unique(outData.medState);
resultsTable = table();
cnt = 1; 
for p = 1:length(uniquePatient)
    for s = 1:length(uniqueSides)
        idxUse = strcmp(outData.patient,uniquePatient{p}) & ... 
                 strcmp(outData.side,uniqueSides{s});
        updrsTableSide = outData(idxUse,:); 
        for m = 1:length(medStates)
            idxMed = strcmp(updrsTableSide.medState,medStates{m});
            sumTable = updrsTableSide(idxMed,:);
            resultsTable.patient{cnt} = uniquePatient{p};
            resultsTable.side{cnt} = uniqueSides{s};
            resultsTable.state{cnt} = medStates{m};
            % get rid of all tremore related scores 
            idxNoTremor = sumTable.measure_number > 3.2;
            resultsTable.score(cnt) = sum(sumTable.score(idxNoTremor));
            cnt = cnt + 1; 
        end
    end
end
%%
close all;
deltaTable = table();
hfig = figure;
hfig.Color = 'w'; 
cnt = 1; 
for p = 1:length(uniquePatient)
    hsub(p) = subplot(2,3,p); 
    idxUse = strcmp(resultsTable.patient,uniquePatient{p});
    patScores = resultsTable(idxUse,:);
    hbar = bar(patScores.score,'FaceColor','flat');
    hbar.CData(1,:) = [0.8 0 0];
    hbar.CData(3,:) = [0.8 0 0];
    hbar.CData(2,:) = [0 0.8 0];
    hbar.CData(4,:) = [0 0.8 0];
    hbar.FaceAlpha = 0.2;
    title(uniquePatient{p});
    hsub(p).XTick = [1.5 3.5];
    hsub(p).XTick = [1.5 3.5];
    hsub(p).XTickLabel = {'left','right'};
    for s = 1:length(uniqueSides)
        idxSide =  strcmp(patScores.side,uniqueSides{s});
        sideTable = patScores(idxSide,:);
        deltaTable.patient{cnt} = uniquePatient{p};
        deltaTable.side{cnt} = uniqueSides{s};
        deltaTable.delta(cnt) = sideTable.score(1) - sideTable.score(2); 
        cnt = cnt+ 1;
    end
end
linkaxes(hsub,'y');
savename = fullfile(dirname,'updrs_results.mat');
readme = 'process_updrs_baseline_data.m computed this and result .csv are on Box in the paper folder'; 
save(savename,'resultsTable','deltaTable','outData','outTable');
%% plot UPDRs vs AUC results 
dirname = '/Users/roee/Box/rcs paper paper on first five bilateral implants/revision for nature biotechnology/figures/Fig5_states_estimates_group_data_and_ AUC/baseline_updrs';
savename = fullfile(dirname,'updrs_results.mat');
load(savename,'resultsTable','deltaTable','outData','outTable');

figdirout = '/Users/roee/Starr_Lab_Folder/Writing/papers/2019_LongTerm_RCS_recordings/figures/final_figures/Fig5_states_estimates_group_data_and_ AUC';
figdirout = '/Users/roee/Box/rcs paper paper on first five bilateral implants/revision for nature biotechnology/figures/Fig5_states_estimates_group_data_and_ AUC';

datadir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home/';

ff = findFilesBVQX(datadir,'*by_min_results_with_coherence.mat');
for f = 1:length(ff)
    load(ff{f});
    
    if f == 1 
        AUCall = AUC_results_table; 
    else
        AUCall = [AUCall; AUC_results_table];
    end
end
idxLeft = strcmp(AUCall.side,'L');
idxAll = strcmp(AUCall.area,'all areas');
aucResults = AUCall(idxAll,:);
uniquPatients = unique(AUCall.patient);
sidesAUC = {'L','R'};
sidesDelta = {'left','right'}; 
colorsSubs = [255 181 62; ...
             0 0 87;...
             177 63 0;...
             0 102 8;...
             204 255 102]./255;
% plot compared to all areas AUC 
hfig = figure;
hfig.Color = 'w';
hsb = subplot(1,1,1); 
hold on;
for p = 1:length(uniquPatients)
    idxPatient = strcmp(aucResults.patient,uniquPatients{p});
    patientAUC = aucResults(idxPatient,:);
    for s = 1:length(sidesAUC)
        idxSideAuc = strcmp(patientAUC.side,sidesAUC{s});
        aucScore = patientAUC.AUC(idxSideAuc);
        idxDelta = strcmp(deltaTable.patient,uniquPatients{p}) & ... 
            strcmp(deltaTable.side,sidesDelta{s});
        deltaUpdrs = deltaTable.delta(idxDelta);
        hscat(p) = scatter(aucScore,deltaUpdrs,100,colorsSubs(p,:),'filled','MarkerFaceAlpha',0.5);
    end
end
legend(uniquPatients,'Location','northeastoutside');
xlabel('AUC'); 
ylabel('Delta UPDRS off-on');
title('AUC = Baseline UPDRS difference correlation');
title('AUC/UPDRS correlation');
set(gca,'FontSize',10);
prfig.plotwidth           = 4;
prfig.plotheight          = 4;
prfig.figdir             = figdirout;
prfig.figtype             = '-dpdf';
prfig.figname             = sprintf('AUC_vs_updrs');
plot_hfig(hfig,prfig)

%% plot compared to anything BUT all areas 
hfig = figure;
hfig.Color = 'w';
hsb = subplot(1,1,1); 
aucResults = AUCall(~idxAll,:);
hold on;
for p = 1:length(uniquPatients)
    idxPatient = strcmp(aucResults.patient,uniquPatients{p});
    patientAUC = aucResults(idxPatient,:);
    for s = 1:length(sidesAUC)
        idxSideAuc = strcmp(patientAUC.side,sidesAUC{s});
        aucScore = patientAUC.AUC(idxSideAuc);
        idxDelta = strcmp(deltaTable.patient,uniquPatients{p}) & ... 
            strcmp(deltaTable.side,sidesDelta{s});
        deltaUpdrs = deltaTable.delta(idxDelta);
        hscat(p) = scatter(mean(aucScore),deltaUpdrs,100,colorsSubs(p,:),'filled');
    end
end
legend(uniquPatients,'Location','northeastoutside');
xlabel('AUC'); 
ylabel('Delta UPDRS off-on');
title('AUC mean= Baseline UPDRS difference correlation'); 
set(gca,'FontSize',16);

%%
end