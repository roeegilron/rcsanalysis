function plot_home_data_based_on_motor_diary(dirname)
close all;
addpath(genpath(fullfile(pwd,'toolboxes','shadedErrorBar')));
% this function relies on psdresults + all events existing in the .
% directory
load(fullfile(dirname,'motorDiary.mat'));
load(fullfile(dirname,'psdResults.mat'));

% create table with idx of fft results in all events and the time
% difference
t = [fftResultsTd.timeStart];
% concatenate off and on events

plot_events_with_shaded_error_bars(dirname,motorDiary, fftResultsTd )

return 

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

function plot_events_with_shaded_error_bars(dirname,motorDiary, fftResultsTd)
labels = [];
figureTitles{1} = 'all_home_data_motor_diary_events_shaded_error_bars';
labelTitles = {'alseep','off','on'};
labels(:,1) = motorDiary.asleep==1; 
labels(:,2) = motorDiary.state==0; 
labels(:,3) = motorDiary.state==1;

% 
% labels = [];
% figureTitles{1} = 'all_home_data_motor_diary_events_shaded_error_bars_conditions';
% labelTitles = {'dysk mild','dysk severe','tremor mild','tremor severe'};
% labels(:,1) = motorDiary.dyskinesiaMild==1; 
% labels(:,2) = motorDiary.dyskinesiaSevere==1; 
% labels(:,3) = motorDiary.tremorMild==1; 
% labels(:,4) = motorDiary.tremorSevere==1; 
% 
% 
% labels = [];
% figureTitles{1} = 'all_home_data_motor_diary_events_shaded_error_bars_tremor-vs-dysk';
% labelTitles = {'dysk','tremor'};
% labels(:,1) = logical(motorDiary.dyskinesiaMild==1) | logical(motorDiary.dyskinesiaSevere == 1); 
% labels(:,2) = logical(motorDiary.tremorMild==1)     | logical(motorDiary.tremorSevere==1); 

labels = logical(labels);

t = [fftResultsTd.timeStart];


colors = [0.8 0 0 0.6; 0 0.8 0 0.6; 0.9 0.64 0 0.6 ; 0.9 0.64 0 0.2];
ttls   = {'STN 0-1','STN 1-3','M1 8-10','M1 9-11'};
hfig = figure;
for i = 1:4
    hsub(i) = subplot(2,2,i); hold on;
end
hfig.Position = [672         255        1619        1083];
hpltPlaceHolders = gobjects(size(labels,2),4);
for ll = 1:size(labels,2)
    timeStart = motorDiary.timeStart(labels(:,ll));
    timeEnd = motorDiary.timeEnd(labels(:,ll));
    timeStart.TimeZone = t.TimeZone;
    timeStart.Format = t.Format;
    timeEnd.TimeZone = t.TimeZone;
    timeEnd.Format = t.Format;
    
    idxFft = zeros(size(t,2),1); 
    for i = 1:size(timeStart,1)
        idxadd = find(  (t>=(timeStart(i)) & (t<=timeEnd(i)))  == 1);
        idxFft(idxadd) = 1; 
    end
    counts(ll) = sum(idxFft);
    
    for c = 1:4
        fldnm = sprintf('key%dfftOut',c-1);
        y = fftResultsTd.(fldnm)(:,logical(idxFft));
        x = fftResultsTd.ff;
%         hplt = plot(hsub(c),x,y,'Color',colors(ll,:),'LineWidth',0.5);
%         for h = 1:length(hplt)
%             hplt(h).Color = [hplt(h).Color 0.5];
%         end
        axes(hsub(c));
        hshadedError = shadedErrorBar(x',y',{@median,@(yy) std(yy)./sqrt(size(yy,1))});
%         hshadedError = shadedErrorBar(x',y',{@median,@(yy) std(yy)});
        hshadedError.mainLine.Color = colors(ll,:);
        set(hshadedError.mainLine,'LineWidth',2)
        hshadedError.patch.FaceColor = colors(ll,1:3);
        hpltPlaceHolders(ll,c) = hshadedError.mainLine;
        title(hsub(c),ttls{c});
        xlim(hsub(c),[0 100]);
        xlabel(hsub(c),'Freq (Hz)');
        ylabel(hsub(c),'Power  (log_1_0\muV^2/Hz)');
        set(hsub(c),'FontSize',18);
    end
end
% add legends
axes(hsub(2));
hpltsUseLegend = hpltPlaceHolders(:,2);
legend(hpltsUseLegend,labelTitles);

hfig.Color = 'w';
dcm_obj = datacursormode(hfig);
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