function temp_life_time_usage_rcs
%% rc+ s 
% do this manually 
% using this code: 
% plot_continuos_recording_report_across_patients
% note that this does not work on RCS01 
%{
rootdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01';
ff = findFilesBVQX(rootdir,'RawDataAccel.json');
for f = 1:length(ff)
    try 
    jsonobj = deserializeJSON(ff{f});
    if ~isempty(fieldnames(jsonobj))
        if ~isempty(jsonobj.AccelData)
            secs(f) = jsonobj.AccelData(end).Header.timestamp.seconds - ...
                jsonobj.AccelData(1).Header.timestamp.seconds ;
        end
    end
    catch 
        fprintf('[%d] file %s failed\n',f,ff{f})
    end
end
hoursRCs = hours(seconds(sum(secs)));
%}

%% pc +s 
outdir = fullfile('..','figures','json_file_reports'); 
params.outdir = outdir; 
fn = '/Users/roee/Starr_Lab_Folder/Data_Analysis/First_Pass_Data_Analysis/results/mat_file_with_all_session_jsons/all_session_celldb.mat';
load(fn,'outdb','sessiondb','symptomcat');
ntb = varfun(@sum,sessiondb,'InputVariables','recordingduraton','GroupingVariables','patientcode'); 
rechours = hours(hours(seconds(ntb.sum_recordingduraton)));

%% plot pcs +s 
hfig = figure;
hbar = bar(1:length(rechours),rechours);
hbar.FaceColor = [0.8 0 0 ]; 
hbar.FaceAlpha = 0.7;
set(gca,'XTickLabel',strrep(ntb.patientcode,'_',' ')); 
xlabel('Patients');
ylabel('Hours'); 
title('Sum of Recording Hours Per Subject'); 
set(findall(hfig,'-property','FontSize'),'FontSize',16)
params = []; 

params.figname = 'pcs rec hours'; 
params.figdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/presentations/figures';
params.figtype = '-djpeg';
plot_hfig(hfig,params)

%% plot rc+s and pc+s 
% order - rcs01 rcs02 rcs05 rcs07 
hoursRCs = [25 162*2 147*2 199*2];
hfig = figure;
hbar = bar(1:length(rechours),rechours);
hbar.FaceColor = [0.8 0 0 ]; 
hbar.FaceAlpha = 0.7;
hold on; 
hbar = bar((1:length(hoursRCs)) + length(rechours),hours(hoursRCs));
hbar.FaceColor = [0 0 0.8 ]; 
hbar.FaceAlpha = 0.7;

set(gca,'XTick',[]);
% set(gca,'XTickLabel',[strrep(ntb.patientcode,'_',' ');'RCS01']); 
set(gca,'XTick',[]);
xlabel('Patients');
ylabel('Total Hours'); 
title('Sum of Recording Hours Per Subject'); 
set(findall(hfig,'-property','FontSize'),'FontSize',16)
params = []; 

params.figname = 'pcs vs rcs rec hours updated'; 
params.figdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/presentations/figures';
params.figtype = '-djpeg';
title('Many more hours of data recorded with RC+S','FontSize',25);
set(gca,'FontSize',20);
hfig.Color = 'w'; 
legend('PC+S','RC+S','Location','northeastoutside');
plot_hfig(hfig,params)




end