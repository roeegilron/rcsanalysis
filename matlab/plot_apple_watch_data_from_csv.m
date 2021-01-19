function plot_apple_watch_data_from_csv()
warning('off','MATLAB:table:RowsAddedExistingVars');

%% load data 
% rood
params.rootdir = '/Users/roee/Box/RC-S_Studies_Regulatory_and_Data/apple_watch_data';
% create databaseL 
ff = findFilesBVQX(params.rootdir,'rcs*.csv'); 
patdb = table(); 
for f = 1:length(ff) 
    [pn,fn,ext] = fileparts(ff{f});
    pat = fn(1:5);
    dateData = datetime(fn(7:17),'InputFormat','MMM_dd_yyyy');
    patdb.time(f) =  dateData;
    patdb.patient{f} = pat; 
    patdb.file{f} = ff{f};
    if any(strfind(fn,'accel'))
        type = 'rawAcc';
    end
    if any(strfind(fn,'dyskinesia'))
        type = 'dyskinesia';
    end
    if any(strfind(fn,'tremor'))
        type = 'tremor';
    end
    patdb.type{f} = type;
end
%%

for p = 1:size(patdb,1) 
    switch patdb.type{p}
        case 'accel'
            x =2;
        case 'dyskinesia'
            x = 2;
        case 'tremor'
            tremdata = readtable(patdb.file{p});
            fprintf('reading data from files %s \n',patdb.file{p});
            %% creat summary metrics
            tremSummary = struct();
            if ~isempty(tremdata)
                idxkeep = ~isnan(tremdata.mild) & ~(tremdata.unknown==1);
                
                tremDataOnly = tremdata(idxkeep,:);
                totalOnes = ones(size(tremDataOnly,1),1);
                tremSummary.mildPerc =   sum(tremDataOnly.mild .* totalOnes);
                tremSummary.modrPerc =   sum(tremDataOnly.moderate .* totalOnes);
                tremSummary.slightPerc = sum(tremDataOnly.slight .* totalOnes);
                tremSummary.strongPerc = sum(tremDataOnly.strong .* totalOnes);
                tremSummary.nonePerc =   sum(tremDataOnly.none .* totalOnes);
                tremSummary.unknown =   sum(tremDataOnly.unknown .* totalOnes);
                tremSummary.totalmin = sum(totalOnes);
                patdb.tremSummary{p} = tremSummary;
            end
    end
end

%% plot some summary metrics 
unqpatients = unique(patdb.patient);
types = {'tremor','accel','dyskinesia'};
for t = 1%:length(types)
    for p = 1%:length(unqpatients)
        idxpat = cellfun(@(x) any(strfind(x,unqpatients{p})),patdb.patient) & ...
                 cellfun(@(x) any(strfind(x,types{t})),patdb.type);
        patientDb = patdb(idxpat,:);
        
        struct2table([patientDb.tremSummary{:}])
        x = 2;
    end
end

x = 2;




%%
tremor_prob_by_severity{1,1} = '/Users/roee/Downloads/RCS02_Apple-Watch_tremor_severity_1589898990490_1589940720883.json';
tremor_prob_by_severity{1,2} = '/Users/roee/Downloads/RCS02_Apple-Watch_dyskinesia_1589898990490_1589940720883_dysk_closed_loop.json';
% open loop 
tremor_prob_by_severity{2,1} = '/Users/roee/Downloads/RCS02_Apple-Watch_tremor_severity_1590073373144_1590103701967.json'; 
tremor_prob_by_severity{2,2} = '/Users/roee/Downloads/RCS02_Apple-Watch_dyskinesia_1590073082453_1590103217481_open_loop.json';

for i = 1:2
    res = json.load(tremor_prob_by_severity{i,1});
    timenum = res.result.time;
    t = datetime(timenum,'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
    measures = {'slight','mild','moderate','strong'};
    for m = 1:length(measures)
        msr = res.result.probability.(measures{m});
        idxkeep = ~isnan(msr); 
        msr = msr(idxkeep);
        minutesOf = sum(1.*msr);
        outcomesPer_Tremor(m,i) = minutesOf/sum(idxkeep);
        outcomesMin_Tremor(m,i) = minutesOf;
    end
    
    % dyskinesia
    res = json.load(tremor_prob_by_severity{i,2});
    timenum = res.result.time;

    
    msr = res.result.probability;
    idxkeep = ~isnan(msr);
    msr = msr(idxkeep);
    minutesOf = sum(1.*msr);
    outcomesPer_Dyskinsia(1,i) = minutesOf/sum(idxkeep);
    outcomesMin_Dyskinsia(1,i) = minutesOf;
end
%% plot differnces 
close all;
hfig = figure;
plotthis = [outcomesPer_Tremor; outcomesPer_Dyskinsia];
labels = {'tremor slight','tremor mild','tremor moderate','tremor strong', 'dyskinesia'};

hfig.Color = 'w'; 
hbar = bar(plotthis.*100);
legend({'closed loop','open loop'});
ylabel('% tremmor/dyskinesia /day');
hsb = gca;
hsb.XTickLabel = labels;
hsb.XTickLabelRotation = 45;
set(gca,'FontSize',16);
title('Comparison OL/CL Apple Watch');
%%
figure;polarplot(t,slight); 
end