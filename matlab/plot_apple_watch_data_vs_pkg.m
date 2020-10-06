function plot_apple_watch_data_vs_pkg()
addpath(genpath(fullfile(pwd ,'toolboxes', 'turtle_json','src')));
close all;
%% load data
% closed loop
tremor_prob_by_severity{1,1} = '/Users/roee/Downloads/PKG & Apple Watch/RCS02OL & CL/PKG OL L - 2 min/Tremor_AppleWatch.json';
tremor_prob_by_severity{1,2} = '/Users/roee/Downloads/PKG & Apple Watch/RCS02OL & CL/PKG OL L - 2 min/RCS02_Apple-Watch-Left_dyskinesia_1590508427135_1590550920654.json';

hfig = figure;
hfig.Color = 'w';
nrows = 5;
ncols = 1;
cntplt = 1;
res = json.load(tremor_prob_by_severity{1,1});
timenum = res.result.time;
t = datetime(timenum,'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
measures = {'slight','mild','moderate','strong'};
for m = 1:length(measures)
    msr = res.result.probability.(measures{m});
    idxkeep = ~isnan(msr);
    msr = msr(idxkeep);
    minutesOf = sum(1.*msr);
end
% plot tremor
hsb(cntplt) = subplot(nrows,ncols,cntplt); cntplt =  cntplt + 1;
hold on;
for m = 1:length(measures)
    msr = res.result.probability.(measures{m});
    idxkeep = ~isnan(msr) & msr~=0;
    scatter(t(idxkeep),msr(idxkeep).*m)
end
title('tremor apple watch');

ylabel('tremor prob');

% dyskinesia
hsb(cntplt) =  subplot(nrows,ncols,cntplt); cntplt =  cntplt + 1;
res = json.load(tremor_prob_by_severity{1,2});
timenum = res.result.time;
t_dysk = datetime(timenum,'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
msr = res.result.probability;
idxkeep = ~isnan(msr) & msr~=0;
scatter(t(idxkeep),msr(idxkeep).*m)

title('dyskinesia apple watch');

ylabel('dyskinesia prob');

%% pkg data
pkgfile =  '/Users/roee/Downloads/PKG & Apple Watch/RCS02OL & CL/PKG OL L - 2 min/scores_20200522_122011.csv';
pkgTable = readtable(pkgfile);
pkgTable.Date_Time.TimeZone = 'America/Los_Angeles';
timesPKG = pkgTable.Date_Time;
timesPKG.TimeZone = 'America/Los_Angeles';

% get rid of NaN data (it's empty on startup
pkgTable = pkgTable(~isnan(pkgTable.BK),:);


% check if BK is in a positive scale, if so, flip it
if prctile(pkgTable.BK,50)>0
    % get rid of negative values
    pkgTable = pkgTable(pkgTable.BK>=0,:);
    % flip the sign of all bk vals
    pkgTable.BK = pkgTable.BK.*(-1);
end


% get rid of off wrist data
pkgTable = pkgTable(~pkgTable.Off_Wrist,:);
times = pkgTable.Date_Time;
times.TimeZone = t_dysk.TimeZone;
idxuse =  times > t_dysk(1) &  times < t_dysk(end);

times = pkgTable.Date_Time(idxuse,:);
dkvals = pkgTable.DK(idxuse,:);
dkvals(dkvals==0) = 0.1;
dkvals = log10(dkvals);
bkvals = pkgTable.BK(idxuse,:);
bkvals = abs(bkvals);
% bk vals
hsb(cntplt) =  subplot(nrows,ncols,cntplt); cntplt =  cntplt + 1;
hold on;
mrksize = 20;
alphause = 0.3;
scatter(times,bkvals,mrksize,'filled','MarkerFaceColor',[0 0 0],'MarkerFaceAlpha',alphause);
xlims = get(gca,'XLim');
hp(2) = plot(xlims,[80 80],'LineWidth',2,'Color',[0.5 0.5 0.5],'LineStyle','-.');
bkmovemean = movmean(bkvals,[5 5]);
plot(times,bkmovemean,'LineWidth',4,'Color',[0 0 0 0.5]);
ylabel('bradykinesia score (a.u.)');
set(gca,'FontSize',12);


% dk vals
hsb(cntplt) =  subplot(nrows,ncols,cntplt); cntplt =  cntplt + 1;hold on;
scatter(times,dkvals,mrksize,'filled','MarkerFaceColor',[0 0 0],'MarkerFaceAlpha',alphause);

dkmovemean = movmean(dkvals,[5 5]);
plot(times,dkmovemean,'LineWidth',4,'Color',[0 0 0 0.5]);
xlims = get(gca,'XLim');
plot(xlims,[log10(7) log10(7)],'LineWidth',2,'Color',[0 0.8 0],'LineStyle','-.');
plot(xlims,[log10(16) log10(16)],'LineWidth',2,'Color',[0 0.8 0],'LineStyle','-.');

ylabel('dyskinesia score (a.u.)');
set(gca,'FontSize',12);

% tremor scores 
hsb(cntplt) =  subplot(nrows,ncols,cntplt); cntplt =  cntplt + 1;
hold on;
mrksize = 20;
alphause = 0.3;
trmr = pkgTable.Tremor_Score(idxuse);
scatter(times,trmr,mrksize,'filled','MarkerFaceColor',[0 0 0],'MarkerFaceAlpha',alphause);
xlims = get(gca,'XLim');
ylabel('tremor score (a.u.)');
set(gca,'FontSize',12);

for h = 1:length(hsb)
    set(hsb(h),'FontSize',16);
end

% link a
linkaxes(hsb,'x');

end