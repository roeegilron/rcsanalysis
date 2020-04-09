function plot_effects_of_chronic_stim_RCS04()
patients = {'RCS04'}; 
betapeaks = [13 19 20 19 13 25;
            13 19 20 19 13 25];
% betapeaks = [65 65 75 65;...
%              65 65 65 65];



cnlsuse = [0 1 1 1 0 1];
% cnlsuse = [3 3 2 3];
width = 2.5; 
cntpt = 1; 
psdresultsfn{1,cntpt} = '/Volumes/RCS_DATA/RCS04/sense_stim_settings_RCS04/RCS04L/psdResults_off_stim.mat'; % off stim 
psdresultsfn{2,cntpt} = '/Volumes/RCS_DATA/RCS04/sense_stim_settings_RCS04/RCS04L/psdResults_on_stim.mat'; % on stim 
cntpt = cntpt+1; 



%%
close all;
cnttoplot = 1; 
colorsuse = [0.5 0.5 0.5; 0 0.8 0]; 
stimstate = {'off stim','on stim'}; 

for p = 1:size(psdresultsfn,2)
    for i = 1:2
        load(psdresultsfn{i,p});
        plot_continuos_recording_report_from_table(tbluse);
    end
end

hfig = figure;
hfig.Color = 'w';

nrows = length(patients); 
ncols = 2; 
for p = 1:size(psdresultsfn,2)
    for i = 1:2
        load(psdresultsfn{i,p});
        ff = fftResultsTd.ff;

        if strcmp(patients{p},'RCS04')
            timeAfter = datetime('13-Jul-2019 08:15:52.728');
            timeAfter.TimeZone = fftResultsTd.timeStart.TimeZone;
            idxuse = fftResultsTd.timeStart > timeAfter;
            for c = 1:4
                fnuse = sprintf('key%dfftOut',c-1);
                fftResultsTd.(fnuse) = fftResultsTd.(fnuse)(:,idxuse);
            end
            fftResultsTd.timeStart = fftResultsTd.timeStart(idxuse);
            fftResultsTd.timeEnd = fftResultsTd.timeEnd(idxuse);

        end
        % normalize the data
        fnuse = sprintf('key%dfftOut',cnlsuse(p));
        hoursrec = hour(fftResultsTd.timeStart);
        idxhoursuse = (hoursrec >= 10) & (hoursrec <= 22); 
        fftOut = fftResultsTd.(fnuse)(:,idxhoursuse);
%         fftOut = fftResultsTd.(fnuse);
        timesout = fftResultsTd.timeStart(idxhoursuse);
        
        meanVals = mean(fftOut(40:60,:));
        q75_test=quantile(meanVals,0.75);
        q25_test=quantile(meanVals,0.25);
        w = 1.5;
        wUpper = w*(q75_test-q25_test)+q75_test;
        wLower = q25_test-w*(q75_test-q25_test);
        idxWhisker = (meanVals' < wUpper) & (meanVals' > wLower);
        
        fftOut = fftOut(:,idxWhisker);
        timesout = timesout(idxWhisker);
        
        dat = fftOut;
        idxnormalize = ff > 3 &  ff <90;
        % normalize by individual peaks
        idxnormalize = ff >= (betapeaks(i,p)-width) &  ff <= (betapeaks(i,p)+width);

        meandat = repmat(mean(abs(mean(dat(idxnormalize,:),2))),length(ff),1); % mean within range, by row
        % the absolute is to make sure 1/f curve is not flipped
        % since PSD values are negative
        meanmat = repmat(meandat,1,size(dat,2));
        dat = dat./meanmat;
%         fftOut = dat;
        % plot a random sample of the raw data
        hsb(cnttoplot) = subplot(nrows,ncols,cnttoplot);

        plot(ff,fftOut,'LineWidth',0.5,'Color',[0 0 0.8 0.05]);
        
        xlim([3 90]);
        % use peaks or individual peaks
        idxusefreq = ff >= 13 &  ff <= 30;
        % individual peaks 
        idxusefreq = ff >= (betapeaks(i,p)-width) &  ff <= (betapeaks(i,p)+width);
        
        meanbetafreq{p,i} = mean(fftOut(idxusefreq,:),1);
        times{p,i} = timesout;
        toplot{1,cnttoplot} = mean(fftOut(idxusefreq,:),1);
        xtics(cnttoplot)  = cnttoplot; 
        xticklab = sprintf('%s %s',patients{p},stimstate{i});
        xtickalbs{cnttoplot} = xticklab; 
        coloruse(cnttoplot,:) = colorsuse(i,:);
        cnttoplot = cnttoplot + 1; 
        title(xticklab);
        xlabel('Freq. (Hz)');
        ylabel('Beta power');
        set(gca,'FontSize',16); 
        clear fftResultsTd;
    end
end
linkaxes(hsb,'y');
addpath(genpath(fullfile(pwd,'toolboxes','violin')));

hfig = figure;
hsb = subplot(1,1,1);
hfig.Color = 'w';
hviolin  = violin(toplot);

ylabel('Beta power'); 

hsb.XTick = xtics;
hsb.XTickLabel  = xtickalbs;
hsb.XTickLabelRotation = 30;

for h = 1:length(hviolin)
    hviolin(h).FaceColor =  coloruse(h,:);
    hviolin(h).FaceAlpha = 0.3;
end


title('Beta  - effect of chronic stimulation'); 
set(gca,'FontSize',16); 
end