function rcsAtHome_figures_figure_s3()
% load in clinic psds 
dirname = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/in_clinic/rest_3rd_try';
fnmsave = fullfile(dirname,'patientPSD_in_clinic.mat');
load(fnmsave);

% load at home data  
rootdir = '/Users/roee/Box/rcs paper paper on first five bilateral implants/revision for nature biotechnology/figures/Figs3_Rcs07_example_clinic_vs_home';
fnmsv = fullfile(rootdir,'at_home_psds_all_subjects.mat');
load(fnmsv,'patientPSD_at_home');
% function that computed above -
% plot_subject_specific_data_psd_coherence_home_data.m 

% For the RCS07 R example supplement figure, showing gamma oscillation biomarker in chronic but not acute, suggest showing 6 panels:
% STN 1-3 PSD, cortex 8-10 PSD, and coherence between them; and show all 3, both the in clinic PSDs at 2 weeks on/off, 
% and the chronic recording, PKG parsed on immobile/mobile. The gamma oscillations show up well in the chronic but not the acute

%% set up figure    
    close all;
    hfig = figure;
    hfig.Color = 'w';
    hpanel = panel();
    hpanel.pack(3,2); % two rows - one for stim/no stim RCS 02 the second for violin plots 
%     hpanel.select('all');
%     hpanel.identify();
%% plot at home data 


% original function:
% plot_chopped_data_comparisons
colorsUse   = [ 0 0.8 0 0.5; 0.8 0 0 0.5];
medstates = {'on','off'};
electrodes = {'STN 1-3','M1 8-10'};
datTabl = patientPSD_in_clinic;
cntplt = 1;

hsb = gobjects(3,1);
for e = 1:2
    hsb(e,1) = hpanel(cntplt,1).select(); cntplt = cntplt + 1;
    hold on;
    for m = 1:2
        idxuse = strcmp(datTabl.patient,'RCS07') & ...
            strcmp(datTabl.side,'R') & ...
            strcmp(datTabl.electrode,electrodes{e}) & ...
            strcmp(datTabl.medstate,medstates{m} );
        % plot
        plot(datTabl.ff{idxuse},datTabl.fftOut{idxuse},'LineWidth',4,'Color',colorsUse(m,:));
        
    end
    xlim(hsb(e,1),[3.5 89.5]);
    ttluse = sprintf('%s',electrodes{e});
    title(ttluse,'FontName','Arial','FontSize',16);
    set(gca,'FontName','Arial','FontSize',16);
    
    ylabel('Power (log_1_0\muV^2/Hz)');
    
    if e == 1
        legend({'defined on','defined off'},'FontName','Arial','FontSize',10);
    end
    xlim([3 100]);
    hsb(e,1).XTick = [10:10:100];
    grid on;

end
% plot coherence between 
hsb(cntplt,1) = hpanel(cntplt,1).select();
hsb = hsb(cntplt,1);
hold(hsb,'on');
for m = 1:2
    idxCoh    = strcmp(patientCOH_in_clinic.patient,'RCS07') & ...
        strcmp(patientCOH_in_clinic.side,'R') & ...
        strcmp(patientCOH_in_clinic.chan1,'STN 1-3') & ...
        strcmp(patientCOH_in_clinic.chan2,'M1 8-10') & ...
         strcmp(patientCOH_in_clinic.medstate,medstates{m} );
    
    cohPlot = patientCOH_in_clinic(idxCoh,:);
    x = cohPlot.ffCoh{1};
    y = cohPlot.mscoherence{1};
    plot(x,y,...
        'LineWidth',4,'Color',colorsUse(m,:));
end
xlabel('Frequency (Hz)','FontName','Arial','FontSize',11);
ylabel('ms coherence'); 
title('coherence between STN and MC'); 
xlim([3 100]);
grid on;
hsb.XTick = [10:10:100];

%% plot in clinic data
clc;
datTabl = patientPSD_at_home; 
idxuse = strcmp(datTabl.patient,'RCS07') & ...
    strcmp(datTabl.side,'R') & ...
    (strcmp(datTabl.electrode,'STN 1-3') | strcmp(datTabl.electrode,'M1 8-10') |  strcmp(datTabl.electrode,'coh_stn13m10810'));
tablePlot = datTabl(idxuse,:);
plotShaded = 1;
areaStr = {'STN','M1','coh'};
for tt = 1:size(tablePlot,1)
    if any(strfind(tablePlot.electrode{tt},'STN'))
        coluse = 1;
    elseif any(strfind(tablePlot.electrode{tt},'M1'))
        coluse = 2;
    elseif  any(strfind(tablePlot.electrode{tt},'coh'))
        coluse = 3;
    end
    hsb = hpanel(coluse,2).select();
    hold(hsb,'on'); 
    if any(strfind(tablePlot.electrode{tt},'coh'))
        x = tablePlot.ff_coh{tt};
        y = tablePlot.ms_coherence_RawData{tt};
    else
        x = tablePlot.ff{tt};
        y = tablePlot.fftOutRawData{tt};
    end
    if strcmp(tablePlot.medstate{tt},'off')
        colorUse = [0.8 0 0.2];
    elseif strcmp(tablePlot.medstate{tt},'on')
        colorUse = [0 0.8 0.2];
    elseif strcmp(tablePlot.medstate{tt},'sleep')
        colorUse = [0 0 0.2];
    elseif strcmp(tablePlot.medstate{tt},'not sleep')
        colorUse = [0.8 0 0.2];
    end
    if plotShaded
%         hshadedError = shadedErrorBar(x,y,{@median,@(y) std(y)./sqrt(size(y,1))});
        hshadedError = shadedErrorBar(x,y,{@median,@(y) std(y)*0.5});
        
        hshadedError.mainLine.Color = colorUse;
        hshadedError.mainLine.LineWidth = 2;
        hshadedError.patch.FaceColor = colorUse;
        hshadedError.patch.MarkerEdgeColor = [ 1 1 1];
        hshadedError.edge(1).Color = [colorUse 0.1];
        hshadedError.edge(2).Color = [colorUse 0.1];
        hshadedError.patch.FaceAlpha = 0.1;
        hplt(tt) = hshadedError.mainLine;
    else
        hplt = plot(x,y);
        for hh = 1:length(hplt)
            hplt(hh).Color = [colorUse 0.4];
        end
    end
%     ttlsuse = sprintf('%s %s %s',tablePlot.patient{tt}, strrep( tablePlot.electrode{tt},'_', ' '),tablePlot.side{tt});
%     title(ttlsuse);
    xlim([3 100]);
    hsb.XTick = [10:10:100];
    grid on;
    yout{tt} = y;
end
legend(hplt(1:3),{'off - wearable estimate','on - wearible estimate','sleep - weariable estimate'},...
    'FontSize',10);
%%
cnt = 1; 
for i = 1:2 
    for j = 1:2
        hsb = hpanel(i,j).select();
        hsbPsds(cnt) = hsb; 
        cnt = cnt + 1; 
        for ll = 1:length(hsb.XTickLabel)
            hsb.XTickLabel{ll} = '';
        end
    end
end
hsb = hpanel(1,2).select();
hsb.Title.String = 'STN 1-3';
hsb = hpanel(2,2).select();
hsb.Title.String = 'MC 8-10';
hsb = hpanel(3,2).select();
hsb.Title.String = 'STN - MC cohernece';
hsb.YLim(1) = 0;
% link axes psds 
linkaxes(hsbPsds,'xy');

hsbCoherence = [hpanel(3,2).select() hpanel(3,1).select()];
linkaxes(hsbCoherence,'xy');

%%
figdirout = '/Users/roee/Box/rcs paper paper on first five bilateral implants/revision for nature biotechnology/figures/Figs3_Rcs07_example_clinic_vs_home';
hpanel.fontsize = 12;
hpanel.de.margin = 10; 
hpanel.margin = [30 30 30 30];

figname = 'RCS07_example_in_clinic_vs_at_home_data';
prfig.plotwidth           = 10;
prfig.plotheight          = 12;
prfig.figdir             = figdirout;
prfig.figname             = figname;
prfig.figtype             = '-dpdf';
plot_hfig(hfig,prfig)


end