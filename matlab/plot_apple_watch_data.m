function plot_apple_watch_data()
%% load data 
% closed loop 
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