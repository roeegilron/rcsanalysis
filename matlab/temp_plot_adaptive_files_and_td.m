function temp_plot_adaptive_files_and_td()
%% clear stuff 
clear all; close all; clc; 
%%
%% set up params
params.dir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v19_adaptive_month5_day2/rcs_data/Session1553574501259/DeviceNPC700395H'; 
params.dir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v19_adaptive_month5_day2/rcs_data/Session1553618614674/DeviceNPC700395H'; 
params.dir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v19_adaptive_month5_day2/rcs_data/Session1553628169628/DeviceNPC700395H'; 
params.dir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v19_adaptive_month5_day2/rcs_data/Session1553628169628/DeviceNPC700395H'; 
params.dir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/v09_adaptive/adaptive_day_2/lte/StarrLab/RCS02L/Session1559769144423/DeviceNPC700398H/';
params.dir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/v09_adaptive/adaptive_day_2/surfacebook/RCS02R/Session1559769597879/DeviceNPC700404H';
params.outdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/v09_adaptive/adaptive_day_2/surfacebook/RCS02R/Session1559769597879/DeviceNPC700404H';
params.outdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/v09_adaptive/figures';

%% load data 
fnAdaptive = fullfile([params.dir 'AdaptiveLog.json']); 
[outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerTable] =  MAIN_load_rcs_data_from_folder(params.dir);
%%
fnAdaptive = fullfile(params.dir,'AdaptiveLog.json'); 
res = readAdaptiveJson(fnAdaptive); 
%% 
%% histogram of current 
hfig = figure;
cur = res.adaptive.CurrentProgramAmplitudesInMilliamps(1,:);
idxuse = cur >= 0 & cur <= 3; 
histogram(cur(idxuse),'Normalization','probability'); 
ylabel('% spent at each current level'); 
title('1 hour in clinic adaptive'); 
xlabel('current (Ma)'); 
set(gca,'FontSize',16); 

hfig.PaperPositionMode = 'manual';
hfig.PaperSize         = [15 15]; 
hfig.PaperPosition     = [ 0 0 15 15]; 
fnmuse = fullfile(params.outdir,'histogram of current during 1 hour in clinic'); 
print(hfig,fnmuse,'-r300','-djpeg')
%% find start and end times for each state 
% get rid of first time stamp since migbt be wrong; 
adaptiveState = res.adaptive.CurrentAdaptiveState; 
uxtimes = datetime(res.timing.PacketGenTime/1000,...
    'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
uxtimes = uxtimes(2:end); 
adaptiveState = adaptiveState(2:end); 
unqStates     = unique(adaptiveState);
% XXXXXXXXXXX
unqStates     = [0  1 2]; 
% XXXXXXXXXXX
% 
for u = 1:length(unqStates)
    idxStates = adaptiveState == unqStates(u); 
    % find starts 
    startIdxs = find(diff(idxStates) == 1) + 1; 
    if adaptiveState(1) == unqStates(u)
        startIdxs = [1 startIdxs]; 
    end
    % find end idxs 
    endIdxs = find(diff(idxStates) == -1) + 1; 
    if adaptiveState(end) == unqStates(u)
        endIdxs = [endIdxs length(adaptiveState)]; 
    end
    durationsPerState{u} = uxtimes(endIdxs) - uxtimes(startIdxs);
    timesPerState{u,1}   = uxtimes(startIdxs); % start times 
    timesPerState{u,2}   = uxtimes(endIdxs); % end times 
    clear endIdxs startIdxs
end
%% plot state / time 
hfig = figure; 
%state plot by color
hold on;
clrs = [237,248,177;...
        127,205,187;...
        44,127,184]./255;
for u = 1:3
    x = [timesPerState{u,1}; timesPerState{u,2}; timesPerState{u,2}; timesPerState{u,1}];
    x = seconds(x-uxtimes(1));
    len = size(timesPerState{u,1},2);
    y = repmat([1 1 0 0]',1,len);
    p = patch('XData',x,'YData',y,'YLimInclude','off','FaceColor',clrs(u,:));
end
% imagesc(repmat(adaptiveState));
%% plot some figures 

hfig = figure; 
hsubTime = subplot(6,6,[1:3 7:9]); 
hsubPie  = subplot(6,6,[4:6 10:12]); 
hbarDur  = subplot(6,6,[13:24]); 
hState(1) = subplot(6,6,[25 26 31 32]);
hState(2) = subplot(6,6,[27 28 33 34]);
hState(3) = subplot(6,6,[29 30 35 36]);



% bar graph of time in each state 
axes(hsubTime);
durPerState = cellfun(@(x) sum(x),durationsPerState); 
hbar = bar(hsubTime,durPerState); 
ylabel('Time/State'); 
lbls = {'state 0 (3.5ma) ','state 1 (2.5ma) ', 'state 2 (2ma) '};
set(gca,'XTickLabel',lbls)
title('Time spent in each state'); 

% pie chart of relative time in each state 
axes(hsubPie);
hPie = pie(hsubPie,durPerState./(sum(durPerState)),[1 1 1 ]); 
pText = findobj(hPie,'Type','text');
percentValues = get(pText,'String'); 
combinedtxt = strcat(lbls,percentValues'); 
for p = 1:length(pText)
    pText(p).String = combinedtxt{p}; 
    pText(p).FontSize = 16; 
end
set(gca,'FontSize',16); 
title('Time spent in each state (%)'); 

% histogram of times within each state - by bin 
axes(hbarDur); 
cutoffs = [ seconds(0), seconds(10), minutes(1), minutes(5), minutes(10); ... 
           seconds(10), minutes(1),  minutes(5), minutes(10), minutes(15)];
for u = 1:3
    for c = 1:length(cutoffs)
    idxuse = durationsPerState{u} >= cutoffs(1,c) & durationsPerState{u} < cutoffs(2,c);
    percPerTime(c,u) = sum(durationsPerState{u}(idxuse))/sum(durationsPerState{u});
    end
end
hbar = bar(hbarDur,percPerTime); 
ylabel('Probability (% within state/bin)'); 
title('State duration histogram'); 
legend(lbls); 
set(gca,'XTickLabel',{'0-10 sec','10sec-1min','1min-5min','5min-10min','10min-15min'}); 

% histogram of times within each state 
curs = [3.5 2.5 2];
for u = 1:3
    axes(hState(u));
    histogram(hState(u),durationsPerState{u},'Normalization','probability','BinWidth',seconds(10));
    title(sprintf('Histogram of duration in state %d (%.1fma)',u-1,curs(u)));
    ylabel('Probability');
    xlabel('Time');
end
linkaxes(hState,'y');
ttluse = '1 hour adaptive DBS streaming in clinic';
suptitle(ttluse); 

% print 
hfig.PaperPositionMode = 'manual';
hfig.PaperSize         = [20 18]; 
hfig.PaperPosition     = [ 0 0 20 18]; 
fnmuse = fullfile(params.outdir,ttluse); 
print(hfig,fnmuse,'-r300','-djpeg')
savefig(fnmuse); 

%% plot detector and time domain
cur = res.adaptive.CurrentProgramAmplitudesInMilliamps(1,:); 
timestamps = datetime(datevec(res.timing.timestamp./86400 + datenum(2000,3,1,0,0,0))); % medtronic time - LSB is seconds
uxtimes = datetime(res.timing.PacketGenTime/1000,...
    'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
% 
% find idx of event 
idxevent = ...
    strcmp(eventTable.EventSubType,'Now on continuous DBS. Induce dyskinesia and see if it self terminates or not.'); 
timeStart = eventTable.UnixOnsetTime(idxevent); 
timeEnd   = timeStart+ minutes(22); 
idxuse = uxtimes > timeStart & uxtimes < timeEnd;

curUse = cur(idxuse); 
timeUse = uxtimes(idxuse); 

figure;
% detector 
hsub(1) = subplot(3,1,1); 
hold on; 
ld0 = res.adaptive.LD0_output(idxuse); 
ld0_high = res.adaptive.LD0_highThreshold(idxuse); 
ld0_low  = res.adaptive.LD0_lowThreshold(idxuse); 

plot(timeUse,ld0,'LineWidth',3);
hplt = plot(timeUse,ld0_high,'LineWidth',3);
hplt.LineStyle = '-.';
hplt.Color = [hplt.Color 0.7];
hplt = plot(timeUse,ld0_low,'LineWidth',3);
hplt.LineStyle = '-.';
hplt.Color = [hplt.Color 0.7];


ylimsUse(1) = res.adaptive.LD0_lowThreshold(1)*0.2;
ylimsUse(2) = res.adaptive.LD0_highThreshold(1)*1.8;


ylimsUse(1) = prctile(ld0,1);
ylimsUse(2) = prctile(ld0,99);

ylim(ylimsUse); 
title('Detector'); 
ylabel('Detector (a.u.)'); 
xlabel('Time'); 
legend({'Detector','Low threshold','High threshold'}); 
set(gca,'FontSize',24)
% state and current 
hsub(2) =  subplot(3,1,2); 
hold on; 
title('state and current'); 
state = res.adaptive.Ld0DetectionStatus(idxuse)./100;
state = res.adaptive.CurrentAdaptiveState(idxuse);
hplt1 = plot(timeUse,state,'LineWidth',3); 
hplt1.Color = [0.8 0.8 0 0.7]; 
cur = res.adaptive.CurrentProgramAmplitudesInMilliamps(1,idxuse); 
hplt2 = plot(timeUse,cur,'LineWidth',3); 
hplt2.Color = [0.8 0.8 0 0.2]; 
ylim([-1 4]);
legend([hplt1 hplt2],{'state','current'}); 
set(gca,'FontSize',24)


% spetral rep of data 
hsub(3) = subplot(3,1,3); 
win = barthannwin(500); 
nfft = 500; 
overlap = 480; 
% find out what times to use 
allTimes = outdatcomplete.derivedTimes; 
idxuseTimeDomain  = allTimes > timeStart & allTimes < timeEnd;

outDatChunk = outdatcomplete(idxuseTimeDomain,:); 
y = outDatChunk.key3; 


idxpacketGenTime = find(outDatChunk.PacketGenTime~=0);
packetGenTime = outDatChunk.PacketGenTime( idxpacketGenTime(1) ); 
packTimeFormated = datetime(packetGenTime/1000,...
    'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
insTime = outDatChunk.derivedTimes(idxpacketGenTime(1)); 

c = 3; 

srate = 250;
[s,f,t,p] = spectrogram(y,srate,ceil(0.8750*srate),1:120,srate,...
    'yaxis','power');
tsecs = seconds(t);
tdates = timeUse(1) + tsecs; 
hsurf = surf(hsub(c),tdates, f, 10*log10(p), 'EdgeColor', 'none');

shading(hsub(c),'interp');
view(hsub(c),2);
axis(hsub(c),'tight');
xlabel(hsub(c),'seconds');
ylabel(hsub(c),'Frequency (Hz)');
set(gca,'FontSize',24)

% find ipad events and use xlim for that 
linkaxes(hsub,'x'); 

idxIpad = cellfun(@(x) any(strfind(lower(x),'ipad')),eventTable.EventType);
xlimsuse = eventTable.UnixOffsetTime(idxIpad);
% set(hsub(1),'XLim',xlimsuse);
%%
% zoom into spcecici range 
xlimsuse = [datetime('26-Mar-2019 12:31:52.542')   datetime('26-Mar-2019 12:33:15.119')]; 
xlimsuse.TimeZone = 'America/Los_Angeles';
xlim(hsub(1),xlimsuse); 
% save the figure 
fnmuse = fullfile(params.outdir,'adaptive dbs ipad task');
savefig(fnmuse);
%% time spent in each state 
%% hitogram of lenght of time spent in each state 