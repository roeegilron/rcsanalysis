function plot_home_data_based_on_events(dirname)
close all; 
% this function relies on psdresults + all events existing in the .
% directory 
load(fullfile(dirname,'allEvents.mat'));
load(fullfile(dirname,'psdResults.mat'));

% create table with idx of fft results in all events and the time
% difference 
t = [fftResultsTd.timeStart];
% concatenate off and on events 

% add a field to on and off events re their lable 
allEvents.offEvents.label = repmat({'off'},size(allEvents.offEvents,1),1);
allEvents.onEvents.label = repmat({'on'},size(allEvents.onEvents,1),1);
eventsUse = [allEvents.offEvents ; allEvents.onEvents];
eventsUse.fftIndex = zeros(size(eventsUse,1),1);
eventsUse.fftTimeDiff = duration(0,1:size(eventsUse,1),0)';
for e = 1:size(eventsUse,1)
    fprintf('%d\t %s\n',e,min(abs(t-eventsUse.HostUnixTime(e))))
    [eventsUse.fftTimeDiff(e), eventsUse.fftIndex(e) ] = min(abs(t-eventsUse.HostUnixTime(e)));
end
eventsUseForAnalysis = eventsUse(eventsUse.fftTimeDiff < minutes(3),:);


labels = {'off','on'}; 
colors = [0.8 0 0 0.5; 0 0.8 0 0.5];
ttls   = {'STN 0-1','STN 1-3','M1 8-10','M1 9-11'};
hfig = figure; 
for i = 1:4
    hsub(i) = subplot(2,2,i); hold on;
end
for ll = 1:length(labels)
   idxUse = strcmp( eventsUseForAnalysis.label, labels{ll});
   fftIdx = eventsUseForAnalysis.fftIndex(idxUse); 
   for c = 1:4 
       fldnm = sprintf('key%dfftOut',c-1); 
       y = fftResultsTd.(fldnm)(:,fftIdx);
       x = fftResultsTd.ff; 
       hplt = plot(hsub(c),x,y,'Color',colors(ll,:),'LineWidth',3);
       types = eventsUseForAnalysis.EventType(idxUse);
       times = eventsUseForAnalysis.fftTimeDiff(idxUse);
       for h = 1:length(hplt)
           hplt(h).UserData.type = types{h};
           hplt(h).UserData.dur = times(h);
       end
       title(hsub(c),ttls{c}); 
       xlim(hsub(c),[0 100]); 
       xlabel(hsub(c),'Freq (Hz)');
       ylabel(hsub(c),'Power  (log_1_0\muV^2/Hz)');
       set(hsub(c),'FontSize',18); 
   end
end
hfig.Color = 'w';
dcm_obj = datacursormode(hfig);
dcm_obj.UpdateFcn = @myupdatefcn;
dcm_obj.SnapToDataVertex = 'on';
datacursormode on;


% plot jpeg of figure
prfig.plotwidth           = 25;
prfig.plotheight          = 25*0.6;
mkdir(fullfile(dirname,'figures')); 
prfig.figdir              = fullfile(dirname,'figures');
prfig.figtype             = '-djpeg';
prfig.closeafterprint     = 0;
prfig.resolution          = 300;
prfig.figname  = 'all_home_data_with_events';
plot_hfig(hfig,prfig); 



% save matlab of figure 
filenamesave = fullfile(dirname,'figures','events_base_on_data.fig'); 
% savefig(hfig,filenamesave); 
% close(hfig);



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