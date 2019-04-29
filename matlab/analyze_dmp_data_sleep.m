function analyze_dmp_data_sleep()
% to plot time stamps / coverage you have see
% reportFolderTimeStamps()
% to get the data that genrated this see :
% analyzeSleepData

prfig.figdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v06-home-visit-3-week/figures/sleep_analysis_2';
prfig.figtype = '-djpeg';
prfig.plotwidth           = 15;
prfig.plotheight          = 15; 

%% clean data 
close all; 
resdir  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v06-home-visit-3-week/results/sleep_data'; 
load(fullfile(resdir,'sleepChunks2.mat'),'sleepChunks');    
load(fullfile(resdir,'sleepChunks2idxkeep.mat'),'idxkeep');    

sleepChunks = sleepChunks(logical(idxkeep),:);
%%
hfig = figure;
hold on;
hfig.UserData = ones(size(sleepChunks,1),1);
handlesUse = struct(); 
chanNames = {'STN 0-2','STN 1-3','M1 8-10','M1 9-11'}; 
for c = 1:4
    hsub(c) = subplot(2,2,c); 
    hold on; 
    chanN = sprintf('chan%d_fftOut',c); 
    dat = sleepChunks.(chanN);
    handlesUse(c).hplts = plot(sleepChunks.freq',dat','ButtonDownFcn',@updateIdx );
    hsub(c).UserData = handlesUse(c).hplts; 
    for p = 1:length(handlesUse(c).hplts)
        handlesUse(c).hplts(p).UserData = p;
    end
    title(chanNames{c}); 
    ylabel(hsub(c),'Power (log_1_0\muV^2/Hz)');
    xlabel('Frquency (Hz)');
    set(hsub(c),'FontSize',16);
end
prfig.figname = 'all data sleep chunks'; 
% plot_hfig(hfig,prfig)

% comment and use only when finished cliecking to clean data 
% idxkeep = get(gcf,'UserData');
% save(fullfile(resdir,'sleepChunks2idxkeep.mat'),'idxkeep');    

% plot k means for each channel 
% further get rid of channels in which power estimate is zero 

hfig = figure; 
numKmeans = 5; 
chanNames = {'STN 0-2','STN 1-3','M1 8-10','M1 9-11'}; 
for c = 1:4
    hsub(c) = subplot(2,2,c); 
    hold on; 
    chanN = sprintf('chan%d_fftOut',c); 
    dat = sleepChunks.(chanN); 
    idx = kmeans(dat,numKmeans); 
    
    for i = 1:numKmeans
        idxuse = idx==i; 
        mFfft = mean(dat(idxuse,:),1);
        plot(sleepChunks.freq(1,:),mFfft); 
        lgtls{i} = sprintf('PC%d',i);
    end
    legend(lgtls); 
    title(chanNames{c}); 
    ylabel(hsub(c),'Power (log_1_0\muV^2/Hz)');
    xlabel('Frquency (Hz)');
    set(hsub(c),'FontSize',16);
end
prfig.figname = 'sleep PCA'; 
% plot_hfig(hfig,prfig)

%% plot sleep chunk using daytime 
hfig = figure; 
freqPeaksPerChannel = [20 21 16 15]; 
bw = 2; 
for c = 1:4
    
    hsub(c) = subplot(4,1,c);
    freqUse = freqPeaksPerChannel(c)-bw : freqPeaksPerChannel(c)+bw;
    hold on;
    chanN = sprintf('chan%d_fftOut',c);
    idxFres = sleepChunks.freq(1,:) >= freqUse(1) & sleepChunks.freq(1,:) < freqUse(end);
    dat = sleepChunks.(chanN);
    powerVals = mean(dat(:,idxFres),2);
    scatter(sleepChunks.time,powerVals,25,'filled'); 
    ttluse = sprintf('%s freq(%d-%dHz)',chanNames{c},freqUse(1),freqUse(end));
    title(ttluse);
    ylabel(hsub(c),'Power (log_1_0\muV^2/Hz)');
    xlabel('Time');
    set(hsub(c),'FontSize',16);
end
prfig.figname = 'plot sleep data over time'; 
linkaxes(hsub,'x');
% plot_hfig(hfig,prfig)

%% plot sleep on 24 hour clock 
prfig.plotwidth           = 25;
freqranges = [1 4; 4 8; 8 13; 13 20; 20 30; 30 50; 50 90];
freqnames  = {'Delta', 'Theta', 'Alpha','LowBeta','HighBeta','LowGamma','HighGamma'}';
for ff = 1:size(freqranges,1)
    hfig = figure;
    [yy,mm,dd] = ymd(sleepChunks.time(1));
    [h,m,s] = hms(sleepChunks.time);
    t = datetime(repmat(yy,size(h,1),1), ...
        repmat(mm,size(h,1),1), ...
        repmat(dd,size(h,1),1), ...
        h,m,s);
    medHour = [7 11 15 19];
    for Mh = 1:length(medHour)
        medTimes(Mh) = datetime(yy,mm,dd,medHour(Mh),0,0);
    end
    for c = 1:4
        hsub(c) = subplot(4,1,c);
        freqUse = freqPeaksPerChannel(c)-bw : freqPeaksPerChannel(c)+bw;
        freqUse = freqranges(ff,1) : freqranges(ff,2);
        hold on;
        chanN = sprintf('chan%d_fftOut',c);
        idxFres = sleepChunks.freq(1,:) >= freqUse(1) & sleepChunks.freq(1,:) <= freqUse(end);
        dat = sleepChunks.(chanN);
        powerVals = mean(dat(:,idxFres),2);
        hscat = scatter(t,powerVals,25,'filled');
        ttluse = sprintf('%s freq(%d-%dHz)',chanNames{c},freqUse(1),freqUse(end));
        ttluse = [ttluse ' ' freqnames{ff}];
        hpltMeds = plot([medTimes', medTimes']',repmat(get( hsub(c),'YLim'),size(medTimes,2),1)','LineWidth',3,...
            'Color',[0.8 0 0 0.5]);
        title(ttluse);
        legend([hscat hpltMeds(1)],{'Power estimate','Med Times'});
        ylabel(hsub(c),'Power (log_1_0\muV^2/Hz)');
        xlabel('Time');
        
        set(hsub(c),'FontSize',16);
    end
    figtitle = sprintf('%s %s','plot sleep data on 24 hour clock',freqnames{ff});
    prfig.figname = figtitle;
    linkaxes(hsub,'x');
    plot_hfig(hfig,prfig)
end



%% plot only stn sleep vs day light 
prfig.plotwidth           = 25;
freqranges = [8 12; 19 21];
freqnames  = {'Alpha', 'Beta'};
clr = [0.7 0 0 ; 0 0 0.7];
hfig = figure;
subplot(2,1,1); % sleep 
for ff = 1:size(freqranges,1)
    t = sleepChunks.time;
    tstart = datetime('11/08/2019 00:00:00','InputFormat','MM/dd/uuuu HH:mm:ss','TimeZone','America/Los_Angeles');
    tend = datetime('11/10/2019 08:00:00','InputFormat','MM/dd/uuuu HH:mm:ss','TimeZone','America/Los_Angeles');
    freqUse = freqPeaksPerChannel(c)-bw : freqPeaksPerChannel(c)+bw;
    freqUse = freqranges(ff,1) : freqranges(ff,2);
    hold on;
    chanN = sprintf('chan%d_fftOut',1);
    idxFres = sleepChunks.freq(1,:) >= freqUse(1) & sleepChunks.freq(1,:) <= freqUse(end);
    dat = sleepChunks.(chanN);
    powerVals = mean(dat(:,idxFres),2);
    powerVals = powerVals./mean(powerVals); 
    hscat = scatter(t,powerVals,50,'filled',...
        'MarkerFaceColor',clr(ff,:),...
        'MarkerFaceAlpha',0.7);
end
set(gca,'XLim',...
    [datetime('07-Nov-2018 23:17:47.465','TimeZone','America/Los_Angeles')...
     datetime('08-Nov-2018 09:46:43.189','TimeZone','America/Los_Angeles')]);
legend(freqnames);
ylabel('normalized power (a.u.)'); 
datetick('x','HH:MM');
title('Sleep stages - STN');
set(gca,'FontSize',16);

% med effect
subplot(2,1,2); % med effect  
for ff = 1:size(freqranges,1)
    t = sleepChunks.time;
    tstart = datetime('11/08/2019 00:00:00','InputFormat','MM/dd/uuuu HH:mm:ss','TimeZone','America/Los_Angeles');
    tend = datetime('11/10/2019 08:00:00','InputFormat','MM/dd/uuuu HH:mm:ss','TimeZone','America/Los_Angeles');
    freqUse = freqPeaksPerChannel(c)-bw : freqPeaksPerChannel(c)+bw;
    freqUse = freqranges(ff,1) : freqranges(ff,2);
    hold on;
    chanN = sprintf('chan%d_fftOut',1);
    idxFres = sleepChunks.freq(1,:) >= freqUse(1) & sleepChunks.freq(1,:) <= freqUse(end);
    dat = sleepChunks.(chanN);
    powerVals = mean(dat(:,idxFres),2);
    powerVals = powerVals./mean(powerVals); 
    hscat = scatter(t,powerVals,50,'filled',...
        'MarkerFaceColor',clr(ff,:),...
        'MarkerFaceAlpha',0.7);
end

set(gca,'XLim',...
    [datetime('03-Nov-2018 11:39:12.995','TimeZone','America/Los_Angeles')...
     datetime('03-Nov-2018 19:01:22.949','TimeZone','America/Los_Angeles')]);
legend(freqnames);
ylabel('normalized power (a.u.)'); 
datetick('x','HH:MM');
title('Med effect - STN');
set(gca,'FontSize',16);
figtitle = 'med and sleep effects stn';
prfig.figname = figtitle;
plot_hfig(hfig,prfig)
figdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v06-home-visit-3-week/figures';
figname = 'med and sleep effect only stn.fig';
savefig(hfig,fullfile(figdir,figname)); 

%%
for ff = 1:size(freqranges,1)
    hfig = figure;
    [yy,mm,dd] = ymd(sleepChunks.time(1));
    t = sleepChunks.time;
    
    medHour = [7 11 15 19];
    for Mh = 1:length(medHour)
        medTimes(Mh) = datetime(yy,mm,dd,medHour(Mh),0,0);
    end
    for c = 2
        hsub(1) = subplot(1,1,1);
        freqUse = freqPeaksPerChannel(c)-bw : freqPeaksPerChannel(c)+bw;
        freqUse = freqranges(ff,1) : freqranges(ff,2);
        hold on;
        chanN = sprintf('chan%d_fftOut',c);
        idxFres = sleepChunks.freq(1,:) >= freqUse(1) & sleepChunks.freq(1,:) <= freqUse(end);
        dat = sleepChunks.(chanN);
        powerVals = mean(dat(:,idxFres),2);
        hscat = scatter(t,powerVals,25,'filled');
        ttluse = sprintf('%s freq(%d-%dHz)',chanNames{c},freqUse(1),freqUse(end));
        ttluse = [ttluse ' ' freqnames{ff}];
        hpltMeds = plot([medTimes', medTimes']',repmat(get( hsub(c),'YLim'),size(medTimes,2),1)','LineWidth',3,...
            'Color',[0.8 0 0 0.5]);
        title(ttluse);
        legend([hscat hpltMeds(1)],{'Power estimate','Med Times'});
        ylabel(hsub(c),'Power (log_1_0\muV^2/Hz)');
        xlabel('Time');
        
        set(hsub(c),'FontSize',16);
    end
    figtitle = sprintf('%s %s','plot sleep data on 24 hour clock',freqnames{ff});
    prfig.figname = figtitle;
    linkaxes(hsub,'x');
%     plot_hfig(hfig,prfig)
end
%%%% end special figure 









end

function updateIdx(src,event)
    idxlist = get(gcf,'UserData');
    idxlist(src.UserData) = 0; 
    set(gcf,'UserData',idxlist);
    % make this line invisible in all axes 
    axs = get(gcf,'Children');
    for c = 1:length(axs)
        axs(c).UserData(src.UserData).Visible = 'off';
    end
end
