function plot_transition_in_motor_state_with_pkg_single_subject()

%% panel b - transition in motor state - psd and coherence in spectrogram form

fignum = 4; 
load('/Volumes/RCS_DATA/RCS03/raw_data_push_jan_2020/SCBS/RCS03L/RCS03L_pkg_and_rcs_dat_synced_10_min.mat');
figdirout = '/Volumes/RCS_DATA/RCS03/raw_data_push_jan_2020/SCBS/RCS03L/figures';
usetime = 0; % if usetime is 1 it will plot according to time of day so you can see gaps 
% otherwise it will plot everything in idx units and fill out time after
% the fact 

plotpanels = 1;
if plotpanels
    hfig = figure;
    hfig.Color = 'w';
    cntplt = 1;
    numplots = 4;
else
    cntplt = 1;
    numplots = 4;
end


% STN %%%
hsb = [];
ttls = {'STN','M1','coherence stn-m1'};
fieldnamesuse = {'key1fftOut','key2fftOut','gpi01m1011'};
hsb = gobjects(3,1);
for c = 1:3
    if plotpanels
        hsb(cntplt) = subplot(numplots,1,cntplt); cntplt = cntplt + 1;
    else
        hpanel(1,2,cntplt,1).select(); % loop on 3rd position; 
        hsb(cntplt) = gca;
        cntplt = cntplt + 1;
    end
    idxuse = 1:436;
    ffts = []; idxnormalize = []; times = []; idxzero =[];
    
    ffts = allDataPkgRcsAcc.(fieldnamesuse{c});
    
    idxnormalize = allDataPkgRcsAcc.ffPSD > 3 &  allDataPkgRcsAcc.ffPSD <90;
    if c == 3 
        freqs = allDataPkgRcsAcc.ffCoh; 
    else
        freqs = allDataPkgRcsAcc.ffPSD;
    end
    meandat = abs(mean(ffts(:,idxnormalize),2)); % mean within range, by row
    % the absolute is to make sure 1/f curve is not flipped
    % since PSD values are negative
    meanmat = repmat(meandat,1,size(ffts,2));
    ffts = ffts./meanmat;
    
    if ~usetime % if I am not using time, change the idx zeros to only have a gap of 1 value
        % get rid of idxzero in idxuse
        % change idxzero to account for areas to leave a line
        times = allDataPkgRcsAcc.timeStart(idxuse);
        idxzero = diff(times) <= minutes(2) ;
        idxlines = [diff(idxzero)==1 0]; % locations of lines
        idxGaps = idxuse(logical(idxlines));
        idxuse = idxuse(~idxzero);
    end
    
    % imagesc(ffts(idxuse,:)');
    times = allDataPkgRcsAcc.timeStart(idxuse);
    fftsUse = ffts(idxuse,:);
    dkvals  = allDataPkgRcsAcc.dkVals(idxuse); 
    
    % change to either plot data in times or in idx units
    timesrep = repmat(times,size(fftsUse,2),1)';
    frequse  = repmat(freqs,1,size(fftsUse,1))';
    
    % only plot non gap areas
    idxzero = find(diff(times) <= minutes(2))+1 ;
    for i = 1:length(idxzero)
        fftsUse(idxzero(i),:) = NaN;
    end
    
    gaps = times(find(diff(times)~=minutes(2)==1) +1 ) -times(find(diff(times)~=minutes(2)==1)  );
        fprintf('total time %s\n',times(end)-times(1));
    fprintf('gap mean %s (range %s-%s)\n',mean(gaps),min(gaps),max(gaps));

    
    % change to either plot data in times or in idx units
    timesrep = repmat(times,size(fftsUse,2),1)';
    if usetime
        timesmat = datenum(timesrep);
        timevec = datenum(times);
    else
        timevec = 1:length(times);
        timesmat = repmat(timevec,size(fftsUse,2),1)';
        
        % don't incldue lines
        loclines = [ (diff(times) ~= minutes(2)) logical(0)];
        timediff = [logical(1) ~(diff(times) ~= minutes(2))];
        loclines = find(loclines(timediff)==1) + 1;
        timevec = 1:sum(timediff);
        fftsUse = fftsUse(timediff,:);
        dkvals  = dkvals(timediff); 
        timesmat = repmat(timevec,size(fftsUse,2),1)';
        frequse  = repmat(freqs,1,size(fftsUse,1))';
    end
    
    h = pcolor(timesmat, frequse,fftsUse);
    hc = colorbar;
    hc.Label.String = 'Norm power (a.u.)';
    hold on;
    set(h, 'EdgeColor', 'none');
    
    set(gca,'YDir','normal')
    ylim([1 100]);
    title(ttls{cntplt-1});
    if usetime
        datetick('x','dd-mm HH:MM');
    else
        ylims = get(gca,'YLim');
        plot([loclines',loclines']',ylims,'LineWidth',1,'Color',[0.5 0.5 0.5 0.5]);
    end
    ylabel('Frequency (Hz)');
    hsb(cntplt-1).XTick = [];
end



% dyskeinsia values
if plotpanels
    hsb(cntplt) = subplot(numplots,1,cntplt); cntplt = cntplt + 1;
else
    hpanel(1,2,cntplt,1).select(); % loop on 3rd position;
    hsb(cntplt) = gca;
end
hold on;
dkvals(dkvals==0) = 0.1;
dkvals = log10(dkvals);
scatter(timevec, dkvals,...
    10,'filled','MarkerFaceColor',[0 0 0],'MarkerFaceAlpha',0.5);

movData = movmean(dkvals,[10 10]);

plot(timevec,movData,'LineWidth',1,...
    'Color',[0 0 0 0.5]); 
title('Dyskinesia'); 

linkaxes(hsb,'x'); 
axis tight;

if usetime
    datetick('x','dd-mm HH:MM');
else
    for i = 1:length(hsb(numplots).XTick)
       labraw = hsb(numplots).XTickLabel(i);
       labuse = datetime(times(str2num(labraw{1})),'Format','h:mm');
       hsb(numplots).XTickLabel{i} = sprintf('%s',labuse);
    end
%     hsb(numplots).XTickLabel{1} = '';
%     hsb(numplots).XTickLabel{end} = '';
    
end
xlabel('Time'); 
ylabel('DK vals (a.u.)');

if plotpanels
    prfig.plotwidth           = 10;
    prfig.plotheight          = 9;
    prfig.figdir             = figdirout;
    prfig.figname             = 'Fig4_panelE_rcs02';
    plot_hfig(hfig,prfig)
end
%%
