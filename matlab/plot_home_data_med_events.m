function plot_home_data_med_events(dirname)
close all; 
% this function relies on psdresults + all events existing in the .
% directory 
load(fullfile(dirname,'allEvents.mat'));
load(fullfile(dirname,'psdResults.mat'));
%% params
params.beta = 19:25; 
params.timebefore = minutes(60*3); 
params.timeafter  = minutes(60*3); 

% create table with idx of fft results in all events and the time
% difference 
t = [fftResultsTd.timeStart];
medEvents = allEvents.medEvents;

medEvents.fftIndex = zeros(size(medEvents,1),1);
medEvents.fftTimeDiff = duration(0,1:size(medEvents,1),0)';
for e = 1:size(medEvents,1)
    fprintf('%d\t %s\n',e,min(abs(t-medEvents.HostUnixTime(e))))
    [medEvents.fftTimeDiff(e), medEvents.fftIndex(e) ] = min(abs(t-medEvents.HostUnixTime(e)));
end
eventsUseForAnalysis = medEvents(medEvents.fftTimeDiff < minutes(5),:);

peaks  = [19 19 28 28]; % RCS06L
peaks  = [50 20 24 22]; % RCS07R
width  = 2.5;  
[pn,fn] = fileparts(dirname); 

% concatenate off and on events 
colors = [0.8 0 0 0.5; 0 0.8 0 0.5];
[colormapuse] = cbrewer('Accent', size(medEvents,1));
unqdays = unique(day(eventsUseForAnalysis.medTimes));
for u = 1:length(unqdays)
    hfig = figure; 
    ttls   = {'STN 0-1','STN 1-3','M1 8-10','M1 9-11'};
    
    % get med events
    idxdaysmedTimes = day(eventsUseForAnalysis.medTimes) == unqdays(u);
    if sum(idxdaysmedTimes)>=1
        for c = 1:4
            subplot(4,1,c);
            hold on;
            dayIdxs  = day(fftResultsTd.timeStart) == unqdays(u);% find day data
            freqIdx    = (fftResultsTd.ff >= peaks(c)-width) & (fftResultsTd.ff <= peaks(c)+width);
            fldnm = sprintf('key%dfftOut',c-1);
            % data day
            y = mean(fftResultsTd.(fldnm)(freqIdx,dayIdxs),1);
            times = timeofday(fftResultsTd.timeStart(dayIdxs));
            % plot data
            scatter(times,y,10,[0 0 0.8],'filled','MarkerFaceAlpha',0.4,'MarkerEdgeColor','none');
            % plot med times
            medTimesUse = eventsUseForAnalysis.medTimes(idxdaysmedTimes);
            xsmeds = [timeofday(medTimesUse) , timeofday(medTimesUse)];
            ysmeds = repmat(get(gca,'YLim'),size(xsmeds,1),1);
            plot(xsmeds',ysmeds','LineWidth',3,'Color',[0.8 0 0 0.8]);
            
            
            hzuse = sprintf('[%.2f-%.2f(Hz)]',min(fftResultsTd.ff(freqIdx)),max(fftResultsTd.ff(freqIdx)));
            title([ttls{c} ' ' hzuse]);
            set(gca,'FontSize',18);
        end
        monthUse = month(medTimesUse(1),'shortname');
        largetitleuse = sprintf('%s %s-side %s-%d',fn(1:end-1),fn(end),...
            monthUse{1},day(medTimesUse(1)));
        sgtitle(largetitleuse,'FontSize',25);
        
        % plot jpeg of figure
        prfig.plotwidth           = 25;
        prfig.plotheight          = 25*0.6;
        mkdir(fullfile(dirname,'figures'));
        prfig.figdir              = fullfile(dirname,'figures');
        prfig.figtype             = '-djpeg';
        prfig.closeafterprint     = 0;
        prfig.resolution          = 300;
        startstr = 'all_home_data_allinged_to_med_events_by_day';
        figstr = sprintf('%s_%s_%d',startstr,monthUse{1},day(medTimesUse(1)));
        prfig.figname  = figstr;
        plot_hfig(hfig,prfig);
        close(hfig);
    end
end






end

function [txt] = myupdatefcn(~,event_obj)
% Customizes text of data tips
str = event_obj.Target.UserData.type;
tim = event_obj.Target.UserData.dur(1);

pos = get(event_obj,'Position');
txt = {['Freq : ', sprintf('%.2f',pos(1))],...
       ['Power: ', sprintf('%.2f',pos(2))],...
       ['Sub Report: ', str],...
       ['Time Diff: ', sprintf('%s',tim)]};
end

function old_version_plot_data_centered_on_meds_times()
%% params
params.beta = 19:25; 
params.timebefore = minutes(60*3); 
params.timeafter  = minutes(60*3); 

% create table with idx of fft results in all events and the time
% difference 
t = [fftResultsTd.timeStart];
medEvents = allEvents.medEvents;

medEvents.fftIndex = zeros(size(medEvents,1),1);
medEvents.fftTimeDiff = duration(0,1:size(medEvents,1),0)';
for e = 1:size(medEvents,1)
    fprintf('%d\t %s\n',e,min(abs(t-medEvents.HostUnixTime(e))))
    [medEvents.fftTimeDiff(e), medEvents.fftIndex(e) ] = min(abs(t-medEvents.HostUnixTime(e)));
end
eventsUseForAnalysis = medEvents(medEvents.fftTimeDiff < minutes(5),:);



% concatenate off and on events 
colors = [0.8 0 0 0.5; 0 0.8 0 0.5];
[colormapuse] = cbrewer('Accent', size(medEvents,1));

ttls   = {'STN 0-1','STN 1-3','M1 8-10','M1 9-11'};
peaks  = [19 19 28 28]; % RCS06L
width  = 2.5; 
for ii = 1:4
    cuse = ii;
% hfig = figure; 
% for i = 1:4
%     hsub(i) = subplot(4,1,i); hold on;
% end
cntplt = 1; 
hfig = figure;
nrows = ceil(sqrt(size(eventsUseForAnalysis,1)));
ncols = ceil(sqrt(size(eventsUseForAnalysis,1)));
cnt = 1; 
for r = 1:ncols
    for c = 1:nrows
        plotmatrix(r,c) = cnt; 
        cnt = cnt+1; 
    end
end
for m = 1:size(medEvents,1)
    for c = cuse
%         hsubuse = hsub(c); 
        fldnm = sprintf('key%dfftOut',c-1);
        tmedTaken = t(medEvents.fftIndex(m)); 
        tbeforeIdx  = (t <= tmedTaken) & (t >= (tmedTaken-params.timebefore));
        tafterIdx   = (t >= tmedTaken) & (t <= (tmedTaken+params.timeafter));
        freqIdx    = (fftResultsTd.ff >= peaks(c)-width) & (fftResultsTd.ff <= peaks(c)+width);
        
        % data time before 
        y = fftResultsTd.(fldnm)(freqIdx,tbeforeIdx);
        ymean = mean(y,1);
        ymean1 = rescale(ymean,0,1);
        timesTemp = fftResultsTd.timeStart(tbeforeIdx);
        times1     = timesTemp - timesTemp(end);
        
        %data time after
        y = fftResultsTd.(fldnm)(freqIdx,tafterIdx);
        ymean = mean(y,1);
        ymean2 = rescale(ymean,0,1);
        timesTemp = fftResultsTd.timeStart(tafterIdx);
        times2     = timesTemp - timesTemp(1);
        
        timesAll = [ times1, times2];
        yAll = [ ymean1, ymean2];
        if timesAll(end) - timesAll(1) > minutes(10)
            hsubuse = subplot(nrows,ncols,cntplt); hold on; 
            
            % plot
            scatter(hsubuse,timesAll,yAll,10,[0 0 0.8],'filled','MarkerFaceAlpha',0.4,'MarkerEdgeColor','none');
            
            % fit line
            polyFit6 = fit(minutes(timesAll)',yAll','poly9');
            fVals = polyFit6(minutes(timesAll));
            plot(hsubuse,timesAll,fVals,'Color',[0 0 0.8 0.8],'LineWidth',2);
            
            
            xlim([-params.timebefore params.timeafter]);
            
            
%             title(hsubuse,ttls{c});
            if intersect(plotmatrix(end,:),cntplt)
                xlabel(hsubuse,'Time (alligned to meds)');
            end
            if intersect(plotmatrix(:,1),cntplt)
                ylabel(hsubuse,'Mean Beta Power');
            end
            set(hsubuse,'FontSize',18);
            plot(hsubuse,minutes([0 0]),[0 1],'LineWidth',3,'Color',[0.8 0 0 0.8]);
            cntplt = cntplt + 1;
        end
    end
end




 

% plot jpeg of figure
prfig.plotwidth           = 25;
prfig.plotheight          = 25*0.6;
mkdir(fullfile(dirname,'figures')); 
prfig.figdir              = fullfile(dirname,'figures');
prfig.figtype             = '-djpeg';
prfig.closeafterprint     = 0;
prfig.resolution          = 300;
prfig.figname  = 'all_home_data_allinged_to_med_events_beta_sep';
plot_hfig(hfig,prfig); 
end
return

% save matlab of figure 
filenamesave = fullfile(dirname,'figures','events_base_on_data.fig'); 
% savefig(hfig,filenamesave); 
close(hfig);

end