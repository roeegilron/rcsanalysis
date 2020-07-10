function plot_effects_of_chronic_stim()
patients = {'RCS05', 'RCS06','RCS02', 'RCS07','RCS04', 'RCS03'}; 
betapeaks = [27 19 20 19 13 25;
            27 19 20 19 13 25];
% betapeaks = [65 65 75 65;...
%              65 65 65 65];


cnlsuse = [0 1 1 1 0 1];
% cnlsuse = [3 3 2 3];
width = 2.5; 
cntpt = 1; 
psdresultsfn{1,cntpt} = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home/RCS05/psdResults_R.mat'; % off stim 
psdresultsfn{2,cntpt} = '/Volumes/RCS_DATA/RCS05/data_dump/SummitContinuousBilateralStreaming/RCS05R/psdResults.mat'; % on stim 
cntpt = cntpt+1; 

psdresultsfn{1,cntpt} = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home/RCS06/psdResults_L.mat'; % off stim 
psdresultsfn{2,cntpt} = '/Volumes/RCS_DATA/RCS06/data_sump/SummitContinuousBilateralStreaming/RCS06L/psdResults.mat'; % on stim 
cntpt = cntpt+1; 


psdresultsfn{1,cntpt} = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home/RCS02/psdResults_L.mat'; % off stim 
psdresultsfn{2,cntpt} = '/Volumes/RCS_DATA/RCS02/SummitContinuousBilateralStreaming/Old Data/RCS02L/psdResults.mat'; % on stim 
cntpt = cntpt+1; 

psdresultsfn{1,cntpt} = '/Volumes/RCS_DATA/RCS07/v16_1_month/data_sump/RCS07L/psdResults.mat'; % off stim 
psdresultsfn{2,cntpt} = '/Volumes/RCS_DATA/RCS07/v17_on_stim/RCS07L/psdResults.mat'; % on stim 
cntpt = cntpt+1; 

psdresultsfn{1,cntpt} = '/Volumes/RCS_DATA/RCS04/sense_stim_settings_RCS04/RCS04L/psdResults_off_stim.mat'; % off stim 
psdresultsfn{2,cntpt} = '/Volumes/RCS_DATA/RCS04/sense_stim_settings_RCS04/RCS04L/psdResults_on_stim.mat'; % on stim 
cntpt = cntpt+1; 

psdresultsfn{1,cntpt} = '/Volumes/RCS_DATA/RCS03/from_bobby_computer/RCS03L/psdResults_off_stim.mat'; % off stim 
psdresultsfn{2,cntpt} = '/Volumes/RCS_DATA/RCS03/from_bobby_computer/RCS03L/psdResults_on_stim.mat'; % on stim 
cntpt = cntpt+1; 



%%
close all;
cnttoplot = 1; 
colorsuse = [0.5 0.5 0.5; 0 0.8 0]; 
stimstate = {'off stim','on stim'}; 


hfig = figure;
hfig.Color = 'w';

nrows = length(patients); 
ncols = 2; 
for p = 2%1:size(psdresultsfn,2)
    for i = 1:2
        load(psdresultsfn{i,p});
        ff = fftResultsTd.ff;

        if strcmp(patients{p},'RCS07')
            if i == 2 
                idxuse = isbetween(fftResultsTd.timeStart,'11-Feb-2020 09:07:46.264','13-Feb-2020 01:05:56.134'); 
                for c = 1:4 
                    fnuse = sprintf('key%dfftOut',c-1);
                    fftResultsTd.(fnuse) = fftResultsTd.(fnuse)(:,idxuse);
                end
                fftResultsTd.timeStart = fftResultsTd.timeStart(idxuse);
                fftResultsTd.timeEnd = fftResultsTd.timeEnd(idxuse); 
            end
            
        end
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
        timesout = fftResultsTd.timeStart(idxhoursuse);
        
        meanVals = mean(fftOut(40:60,:));
        q75_test=quantile(meanVals,0.75);
        q25_test=quantile(meanVals,0.25);
        w=1.5;
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
        fftOut = dat;
        % plot a random sample of the raw data 
        hsb(cnttoplot) = subplot(nrows,ncols,cnttoplot);
        if i == 1 
            idxrand = randperm(size(dat,2),floor(size(dat,2)*0.1));
        else
            idxrand = 1:size(dat,2); 
        end
        datplot = dat(:,idxrand); 
        plot(ff,datplot,'LineWidth',0.5,'Color',[0 0 0.8 0.05]);
        
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
% plot scatter plot of beta 
hfig = figure;
hfig.Color  = 'w';
for i = 1:length(patients)
    subplot(nrows,1,i);
    scatter(times{i,2},meanbetafreq{i,2},10,'filled');
    xlabel('time of day');
    ylabel('beta power'); 
    ttluse = sprintf('%s avg beta power - on stim',patients{i});
    title(ttluse);
    set(gca,'FontSize',16);
end
addpath(genpath(fullfile(pwd,'toolboxes','violin')));

hfig = figure;
hsb = subplot(1,1,1);
hfig.Color = 'w';
hviolin  = violin(toplot);

ylabel('Norm and centered beta power'); 

hsb.XTick = xtics;
hsb.XTickLabel  = xtickalbs;
hsb.XTickLabelRotation = 30;

for h = 1:length(hviolin)
    hviolin(h).FaceColor =  coloruse(h,:);
    hviolin(h).FaceAlpha = 0.3;
end


title('effect of chronic stim across all patients'); 
set(gca,'FontSize',16); 
end