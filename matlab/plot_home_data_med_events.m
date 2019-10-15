function plot_home_data_med_events(dirname)
close all; 
% this function relies on psdresults + all events existing in the .
% directory 
load(fullfile(dirname,'allEvents.mat'));
load(fullfile(dirname,'psdResults.mat'));
%% params
params.beta = 19:25; 
params.timebefore = minutes(60); 
params.timeafter  = minutes(60*2); 

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
% hfig = figure; 
% for i = 1:4
%     hsub(i) = subplot(4,1,i); hold on;
% end
cntplt = 1; 
hfig = figure;
for m = 1:size(medEvents,1)
    for c = 2
        
        
%         hsubuse = hsub(c); 
        fldnm = sprintf('key%dfftOut',c-1);
        tmedTaken = t(medEvents.fftIndex(m)); 
        tbeforeIdx  = (t <= tmedTaken) & (t >= (tmedTaken-params.timebefore));
        tafterIdx   = (t >= tmedTaken) & (t <= (tmedTaken+params.timeafter));
        [~,freqIdx]    = intersect(fftResultsTd.ff,params.beta);
        
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
            hsubuse = subplot(5,5,cntplt); hold on; cntplt = cntplt + 1;
            
            % plot
            scatter(hsubuse,timesAll,yAll,10,[0 0 0.8],'filled','MarkerFaceAlpha',0.4,'MarkerEdgeColor','none');
            
            % fit line
            polyFit6 = fit(minutes(timesAll)',yAll','poly9');
            fVals = polyFit6(minutes(timesAll));
            plot(hsubuse,timesAll,fVals,'Color',[0 0 0.8 0.8],'LineWidth',2);
            
            
            xlim([minutes(-60) minutes(120)]);
            
            
            title(hsubuse,ttls{c});
            xlabel(hsubuse,'Time (alligned to meds)');
            ylabel(hsubuse,'Mean Beta Power');
            set(hsubuse,'FontSize',18);
            plot(hsubuse,minutes([0 0]),[0 1],'LineWidth',3,'Color',[0.8 0 0 0.8]);
        end
    end
end
% for i = 1:4
%     plot(hsub(i),minutes([0 0]),[0 1],'LineWidth',3,'Color',[0.8 0 0 0.8]);
% end



 

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

return

% save matlab of figure 
filenamesave = fullfile(dirname,'figures','events_base_on_data.fig'); 
% savefig(hfig,filenamesave); 
close(hfig);



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