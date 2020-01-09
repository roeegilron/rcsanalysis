function plot_home_data_based_on_events(dirname)
addpath(genpath(fullfile(pwd,'toolboxes','shadedErrorBar')));
close all;
% this function relies on psdresults + all events existing in the .
% directory
load(fullfile(dirname,'allEvents.mat'));
load(fullfile(dirname,'psdResults.mat'));

plot_stim_events(allEvents,fftResultsTd)
% create table with idx of fft results in all events and the time
% difference
t = [fftResultsTd.timeStart];
% concatenate off and on events

% add a field to on and off events re their lable
allEvents.offEvents.label = repmat({'off'},size(allEvents.offEvents,1),1);
allEvents.onEvents.label = repmat({'on'},size(allEvents.onEvents,1),1);
allEvents.onEventsWithDykinesia.label = repmat({'on with dyskinesia'},size(allEvents.onEventsWithDykinesia,1),1);
allEvents.onEventsWithOutDykinesia.label = repmat({'on with out dyskinesia'},size(allEvents.onEventsWithOutDykinesia,1),1);
% choose what events to include 
eventsUse = [allEvents.offEvents ; allEvents.onEventsWithDykinesia ; allEvents.onEventsWithOutDykinesia];
eventsUse.fftIndex = zeros(size(eventsUse,1),1);
eventsUse.fftTimeDiff = duration(0,1:size(eventsUse,1),0)';
for e = 1:size(eventsUse,1)
    fprintf('%d\t %s\n',e,min(abs(t-eventsUse.HostUnixTime(e))))
    [eventsUse.fftTimeDiff(e), eventsUse.fftIndex(e) ] = min(abs(t-eventsUse.HostUnixTime(e)));
end
eventsUseForAnalysis = eventsUse(eventsUse.fftTimeDiff < minutes(3),:);

figureTypes = 4;
figureTitles{1} = 'all_home_data_with_events';
figureTitles{2} = 'all_home_data_with_events_off';
figureTitles{3} = 'all_home_data_with_events_on_with_dyskinesia';
figureTitles{4} = 'all_home_data_with_events_on_with_out_dyskinesia';
labelsAll{1,:} = {'off','on with dyskinesia','on with out dyskinesia'};
labelsAll{2,:} = {'off'};
labelsAll{3,:} = {'on with dyskinesia'};
labelsAll{4,:} = {'on with out dyskinesia'};
% plot_events_with_shaded_error_bars(dirname,eventsUseForAnalysis,labelsAll{1,:},fftResultsTd )

for ff = 1:figureTypes
    
    labels = labelsAll{ff,:};
    colors = [0.8 0 0 0.6; 0 0.8 0 0.6; 0.9 0.64 0 0.6];
    ttls   = {'STN 0-1','STN 1-3','M1 8-10','M1 9-11'};
    hfig = figure;
    for i = 1:4
        hsub(i) = subplot(2,2,i); hold on;
    end
    hfig.Position = [672         255        1619        1083];
    hpltPlaceHolders = gobjects(length(labels),4);
    for ll = 1:length(labels)
        idxUse = strcmp( eventsUseForAnalysis.label, labels{ll});
        fftIdx = eventsUseForAnalysis.fftIndex(idxUse);
        for c = 1:4
            fldnm = sprintf('key%dfftOut',c-1);
            y = fftResultsTd.(fldnm)(:,fftIdx);
            x = fftResultsTd.ff;
            hplt = plot(hsub(c),x,y,'Color',colors(ll,:),'LineWidth',2);
            types = eventsUseForAnalysis.EventType(idxUse);
            subtypes = eventsUseForAnalysis.EventSubType(idxUse);
            idxemptytofill = find(cellfun(@(x) isempty(x),subtypes)==1);
            subtypes(idxemptytofill) = {''};
            abstimes  = eventsUseForAnalysis.HostUnixTime(idxUse);
            times = eventsUseForAnalysis.fftTimeDiff(idxUse);
            for h = 1:length(hplt)
                hplt(h).UserData.type = types{h};
                hplt(h).UserData.dur = times(h);
                hplt(h).UserData.subtypes = subtypes(h);
                hplt(h).UserData.abstimes = abstimes(h);
                
            end
            hpltPlaceHolders(ll,c) = hplt(h);
            title(hsub(c),ttls{c});
            xlim(hsub(c),[0 100]);
            xlabel(hsub(c),'Freq (Hz)');
            ylabel(hsub(c),'Power  (log_1_0\muV^2/Hz)');
            set(hsub(c),'FontSize',18);
        end
    end
    % add legends
    for i = 1:4
        axes(hsub(i));
        for ll = 1:length(labels)
            legendLabels{ll} = sprintf('%s (n=%d)',labels{ll},sum(strcmp(eventsUseForAnalysis.label,labels{ll})));
        end
        legend(hpltPlaceHolders(:,i),legendLabels);
    end
    hfig.Color = 'w';
    dcm_obj = datacursormode(hfig);
    dcm_obj.UpdateFcn = @myupdatefcn;
    dcm_obj.SnapToDataVertex = 'on';
    datacursormode on;
    
    [pn,fn] = fileparts(dirname);
    superTitleUse = sprintf('%s %s side',fn(1:end-1),fn(end));
    sgtitle(superTitleUse,'FontSize',25);
    % plot jpeg of figure
    prfig.plotwidth           = 25;
    prfig.plotheight          = 25*0.6;
    mkdir(fullfile(dirname,'figures'));
    prfig.figdir              = fullfile(dirname,'figures');
    prfig.figtype             = '-djpeg';
    prfig.closeafterprint     = 0;
    prfig.resolution          = 300;
    prfig.figname  = figureTitles{ff};
    plot_hfig(hfig,prfig);
    filenamesave = fullfile(dirname,'figures',prfig.figname);
    savefig(hfig,filenamesave);
    close(hfig);
end





end

function [txt] = myupdatefcn(~,event_obj)
% Customizes text of data tips
str = event_obj.Target.UserData.type;
strub = event_obj.Target.UserData.subtypes;
abstime = event_obj.Target.UserData.abstimes;
tim = event_obj.Target.UserData.dur(1);

pos = get(event_obj,'Position');
txt = {['Freq : ', sprintf('%.2f',pos(1))],...
       ['Power: ', sprintf('%.2f',pos(2))],...
       ['Sub Report: ', str],...
       ['Sub Report 2: ', strub{1}],...
       ['Time Diff: ', sprintf('%s',tim)]...
       ['Time Of Day: ', sprintf('%s',abstime)]};
end

function plot_events_with_shaded_error_bars(dirname,eventsUseForAnalysis,labelsAll,fftResultsTd)

figureTypes = 4;
figureTitles{1} = 'all_home_data_with_events_shaded_error_bars';

    
    labels = labelsAll;
    colors = [0.8 0 0 0.6; 0 0.8 0 0.6; 0.9 0.64 0 0.6];
    ttls   = {'STN 0-1','STN 1-3','M1 8-10','M1 9-11'};
    hfig = figure;
    for i = 1:4
        hsub(i) = subplot(2,2,i); hold on;
    end
    hfig.Position = [672         255        1619        1083];
    hpltPlaceHolders = gobjects(length(labels),4);
    for ll = 1:length(labels)
        idxUse = strcmp( eventsUseForAnalysis.label, labels{ll});
        fftIdx = eventsUseForAnalysis.fftIndex(idxUse);
        for c = 1:4
            fldnm = sprintf('key%dfftOut',c-1);
            y = fftResultsTd.(fldnm)(:,fftIdx);
            x = fftResultsTd.ff;
%             hplt = plot(hsub(c),x,y,'Color',colors(ll,:),'LineWidth',2);
            axes(hsub(c));
            hshadedError = shadedErrorBar(x',y',{@median,@(yy) std(yy)./sqrt(size(yy,1))});
            hshadedError.mainLine.Color = colors(ll,:);
            set(hshadedError.mainLine,'LineWidth',2)
            hshadedError.patch.FaceColor = colors(ll,1:3);
            hpltPlaceHolders(ll,c) = hshadedError.mainLine;
            types = eventsUseForAnalysis.EventType(idxUse);
            subtypes = eventsUseForAnalysis.EventSubType(idxUse);
            title(hsub(c),ttls{c});
            xlim(hsub(c),[0 100]);
            xlabel(hsub(c),'Freq (Hz)');
            ylabel(hsub(c),'Power  (log_1_0\muV^2/Hz)');
            set(hsub(c),'FontSize',18);
        end
    end
    % add legends
    for i = 1:4
        axes(hsub(i));
        legend(hpltPlaceHolders(:,i),labelsAll);
    end
    hfig.Color = 'w';
    dcm_obj = datacursormode(hfig);
    dcm_obj.UpdateFcn = @myupdatefcn;
    dcm_obj.SnapToDataVertex = 'on';
    datacursormode on;
    
    [pn,fn] = fileparts(dirname);
    superTitleUse = sprintf('%s %s side',fn(1:end-1),fn(end));
    sgtitle(superTitleUse,'FontSize',25);
    % plot jpeg of figure
    prfig.plotwidth           = 25;
    prfig.plotheight          = 25*0.6;
    mkdir(fullfile(dirname,'figures'));
    prfig.figdir              = fullfile(dirname,'figures');
    prfig.figtype             = '-djpeg';
    prfig.closeafterprint     = 0;
    prfig.resolution          = 300;
    prfig.figname  = figureTitles{1};
    plot_hfig(hfig,prfig);
    filenamesave = fullfile(dirname,'figures',prfig.figname);
    savefig(hfig,filenamesave);
    close(hfig);

    return;
end

function plot_stim_events(allEvents,fftResultsTd)
ttls   = {'STN 0-2','STN 0-3','M1 8-10','M1 9-11'};
hfig = figure;
hfig.Color = 'w'; 
for i = 1:4
    hsub(i) = subplot(2,2,i); hold on;
end

eventTable = allEvents.condsAndStim;
allY = {};
for s = 1:size(eventTable,1)
    for c = 1:4 % loop on all channels
        axes(hsub(c));
        fldnm = sprintf('key%dfftOut',c-1);
        times = fftResultsTd.timeStart; 
        ts = eventTable.startTime(s);
        te = eventTable.endTime(s);
        ts.TimeZone = fftResultsTd.timeStart.TimeZone;
        te.TimeZone = fftResultsTd.timeStart.TimeZone;
        fftIdx = [];
        fftIdx = isbetween(times,ts,te);
        y = [];
        y = fftResultsTd.(fldnm)(:,fftIdx);
        x = fftResultsTd.ff;
        if ~isempty(y)
            if eventTable.AmplitudeInMilliamps(s)>1.5
                if eventTable.Dyskinesia(s)
                    datout(s,c).onstim_off = y; 
                else
                    datout(s,c).onstim_on = y; 
                end
            else
                if eventTable.Dyskinesia(s)
                    datout(s,c).offstim_off = y; 
                else
                    datout(s,c).offstim_on = y; 
                end
            end
        end
    end
end


for c = 1:4 % loop on all channels
    axes(hsub(c));
    %                     hplt = plot(hsub(c),x,y,'LineWidth',1,'Color',[0.8 0 0 0.5],'LineStyle','-.');
    try 
    y = []; 
    y = [datout(:,c).onstim_off];
    hshadedError = shadedErrorBar(x',y',{@median,@(y) std(y)./sqrt(size(y,1))});
    hshadedError.mainLine.Color = [0.8 0 0.2];
    hshadedError.mainLine.LineWidth = 2;
    hshadedError.patch.FaceColor = [0.8 0 0];
    hshadedError.patch.FaceAlpha = 0.2;
    end
    
    try 
    y = [];
    y = [datout(:,c).onstim_on];
    hshadedError = shadedErrorBar(x',y',{@median,@(y) std(y)./sqrt(size(y,1))});
    hshadedError.mainLine.Color = [0.7 0 0];
    hshadedError.mainLine.LineWidth = 2;
    hshadedError.patch.FaceColor = [0.8 0 0];
    hshadedError.patch.FaceAlpha = 0.2;
    end
    
    try
        y = []; 
    y = [datout(:,c).offstim_off];
    hshadedError = shadedErrorBar(x',y',{@median,@(y) std(y)./sqrt(size(y,1))});
    hshadedError.mainLine.Color = [0.9 0 0.9];
    hshadedError.mainLine.LineWidth = 2;
    hshadedError.patch.FaceColor = [0 0 0.8];
    hshadedError.patch.FaceAlpha = 0.2;
    end
    
    try
        y = []; 
    y = [datout(:,c).offstim_on];
    hshadedError = shadedErrorBar(x',y',{@median,@(y) std(y)./sqrt(size(y,1))});
    hshadedError.mainLine.Color = [0 0 0.9];
    hshadedError.mainLine.LineWidth = 2;
    hshadedError.patch.FaceColor = [0 0 0.9];
    hshadedError.patch.FaceAlpha = 0.2;
    end
    title(hsub(c),ttls{c});
%     xlim(hsub(c),[0 100]);
    xlabel(hsub(c),'Freq (Hz)');
    ylabel(hsub(c),'Power  (log_1_0\muV^2/Hz)');
    set(hsub(c),'FontSize',18);
end
end

