function rcsAtHome_figures_figure5()
% Quality of data seperation 
% this figure shows the group seperation data 
%% panel A - AUC with all areas 
fignum = 5; 
figdirout = '/Users/roee/Starr_Lab_Folder/Writing/papers/2019_LongTerm_RCS_recordings/figures';
% original function:
% plot_pkg_data_all_subjects

rootdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home/pkg_rcs_by_minute_average_results'; 
rootdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home/pkg_rcs_by_minute_average_smaller_times_results';
ff = findFilesBVQX(rootdir,'*.mat'); 
addpath(fullfile(pwd,'toolboxes','notBoxPlot','code'));
cnt = 1; 
for f = 1:length(ff) 
    load(ff{f},'freqs','patientTable','titles','cnls','readme');
    unqgaps =  unique(patientTable.minuteGap);
    freqsuse = freqs;
    clear freqs

    for u = 1:length(unqgaps)
        idxuse = patientTable.minuteGap==unqgaps(u);
        pdb = patientTable(idxuse,:);
        AUC = cell2mat(pdb.AUC);
        for c = 1:length(cnls)
            patientROC_at_home(cnt).patient = patientTable.patient(idxuse);
            patientROC_at_home(cnt).patientRCSside = patientTable.patientRCSside (idxuse);
            patientROC_at_home(cnt).patientPKGside = patientTable.patientPKGside(idxuse);
            patientROC_at_home(cnt).freq = freqsuse(c);
            patientROC_at_home(cnt).channel = titles(cnls(c)+1);
            patientROC_at_home(cnt).minuteGap = unqgaps(u); 
            channeraw = patientROC_at_home(cnt).channel;
            if c <= 4
                freqstr = 'beta';
            else
                freqstr = 'gamma';
            end
            
            if any(strfind(channeraw{1},'STN'))
                areause = 'STN';
            else
                areause = 'M1';
            end
            patientROC_at_home(cnt).channelabel = [areause ' ' freqstr];
            patientROC_at_home(cnt).AUC = AUC(c);
            cnt = cnt + 1;
        end
        patientROC_at_home(cnt).patient = patientTable.patient(idxuse);
        patientROC_at_home(cnt).patientRCSside = patientTable.patientRCSside (idxuse);
        patientROC_at_home(cnt).patientPKGside = patientTable.patientPKGside(idxuse);
        patientROC_at_home(cnt).freq = NaN;
        patientROC_at_home(cnt).channel = 'all areas';
        patientROC_at_home(cnt).minuteGap = unqgaps(u); 
        patientROC_at_home(cnt).channelabel = 'all areas';
        patientROC_at_home(cnt).AUC = AUC(c+1);
        cnt = cnt + 1;
    end
end
patientROC_at_home =  struct2table(patientROC_at_home);

idx10mingap  = patientROC_at_home.minuteGap==10;
patientROC_at_home_10min = patientROC_at_home(idx10mingap,:); 
idxuse = strcmp(patientROC_at_home_10min.channelabel,'STN beta') | ... 
    strcmp(patientROC_at_home_10min.channelabel,'M1 gamma') | ... 
    strcmp(patientROC_at_home_10min.channelabel,'all areas') ;
patientROC_at_home_10min = patientROC_at_home_10min(idxuse,:); 
xvals = zeros(size(patientROC_at_home_10min,1),1);
xvals( strcmp(patientROC_at_home_10min.channelabel,'STN beta') ) = 1;
xvals( strcmp(patientROC_at_home_10min.channelabel,'M1 gamma') ) = 2;
xvals( strcmp(patientROC_at_home_10min.channelabel,'all areas') ) = 3;


hfig = figure;
hfig.Color = 'w';
hsb = subplot(1,1,1); 
nbp = notBoxPlot([patientROC_at_home_10min.AUC],xvals); 
hsb.XTickLabel = {'STN Beta','M1 Gamma','All areas'};
ylabel('AUC'); 
ylim([0.4 1.1]);
title('M1 & STN best for decoding (4 patients, 8 ''sides'') [peak freqs]'); 
set(gca,'FontSize',12);

prfig.plotwidth           = 6;
prfig.plotheight          = 4;
prfig.figdir             = figdirout;
prfig.figname             = sprintf('Fig%d_panelA',fignum);
prfig.figtype             = '-dpdf';
plot_hfig(hfig,prfig)
close(hfig);
%%
%%

%% panel b - bar graph of segment lenght vs AUC 
% plot segement lenght vs AUC 
uniquepatient = unique(patientROC_at_home.patient); 
for f = 1:length(ff) 
    load(ff{f},'freqs','patientTable','titles','cnls','readme');
    AUC = cell2mat(patientTable.AUC);
    outdat(f).stnbeta = AUC(:,1:2); 
    outdat(f).m1gama = AUC(:,7:8); 
    outdat(f).allareas = AUC(:,9); 
    outdat(f).mingaps = patientTable.minuteGap;
    outdat(f).patient = patientTable.patient{1}; 
    outdat(f).patientside = patientTable.patientRCSside{1}; 
end
patROCbymin = struct2table(outdat);
uniquepatient = unique(patROCbymin.patient); 
hfig = figure; 
hfig.Color = 'w'; 
for p = 1:length(uniquepatient)
    subplot(2,2,p); 
    hold on; 
    idxpat = cellfun(@(x) strcmp(x, uniquepatient{p}),   patROCbymin.patient );
    patdata = patROCbymin(idxpat,:);
    hplt = [];
    for i = 1:size(patdata,1)
        hplt(1,:) = plot(patdata.mingaps{i},patdata.stnbeta{i},'LineWidth',1,'Color',[0 0 0.8 0.5]);
        hplt(2,:) = plot(patdata.mingaps{i},patdata.m1gama{i},'LineWidth',1,'Color',[0.8 0 0 0.5]);
        hplt(3,:) = plot(patdata.mingaps{i},patdata.allareas{i},'LineWidth',2,'Color',[0 0.8 0 0.5]);
    end
    xlabel('average factor (minutes)');
    ylabel('AUC'); 
    title(uniquepatient{p}); 
    legend([hplt(1,1),hplt(2,1),hplt(3,1)],{'stn beta','m1 gamma','all areas'}); 
    set(gca,'FontSize',16); 
end

prfig.plotwidth           = 12;
prfig.plotheight          = 8;
prfig.figdir             = figdirout;
prfig.figname             = sprintf('Fig%d_panelB_v2',fignum);
prfig.figtype             = '-dpdf';
plot_hfig(hfig,prfig)
close(hfig);
%%

%% panel c - unsupervised clustering with one patient, includign sleep 

%%
