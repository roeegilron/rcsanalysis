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
        outTable.medState{cnt} = medState;
        if any(strfind(lower(fnLoop{fn}),'right'))
            outTable.side{cnt} = 'right';
        elseif any(strfind(lower(fnLoop{fn}),'left'))
            outTable.side{cnt} = 'left';
        else
            outTable.side{cnt} = 'NA';
        end
        outTable.measure{cnt} = fnLoop{fn};
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
outData = partialScores(:,{'patient','side','medState','measure','score'});
% loop on all partial scores and extract the raw value.

% table_data has the data in the form of a table.
bar(categorical(outData{:, 1}), table_data{1:7, 2:4});
legend(table_data.Properties.VariableNames(2:4));
xlabel('LandUse Types');

end