function plot_raw_rcs_data(fldrname)
%% add path 
addpath(genpath(fullfile(pwd,'toolboxes','Annotate-v1.1.0')));
%% this functiosn plots
hfig = figure;
[outdatcomplete,outRec,eventTable,outdatcompleteAcc, powerTable] =  MAIN_load_rcs_data_from_folder(fldrname);
dat.outdatcomplete = outdatcomplete;
dat.outdatcompleteAcc = outdatcompleteAcc;
dat.eventTable = eventTable;
dat.outRec = outRec;
dat.fldername = fldrname;
dat.hfigRaw = hfig; 

%% get figure
hfig.Units = 'normalized';

% Create a psd button 
btn = uicontrol();
btn.Parent = hfig;
btn.Style = 'pushbutton';
btn.String = 'PSD + spect';
btn.Units = 'normalized';
btn.Position = [0.0170    0.9513    0.1045    0.0444];
btn.Callback = @plot_psd_and_spect;



hzoom = zoom(hfig); 
hzoom.Motion = 'horizontal';
hzoom.Enable = 'on';

hfig.UserData = dat;
%% plot raw data


idxTimeCompare = find(outdatcomplete.PacketRxUnixTime~=0,1);
packRxTimeRaw  = outdatcomplete.PacketRxUnixTime(idxTimeCompare); 
packtRxTime    =  datetime(packRxTimeRaw/1000,...
            'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
derivedTime    = outdatcomplete.derivedTimes(idxTimeCompare); 
timeDiff       = derivedTime - packtRxTime;

numplots = 5;
for c = 1:4 % loop on channels
    fnm = sprintf('key%d',c-1);
    y = outdatcomplete.(fnm);
    y = y - mean(y);
    hsub(c) = subplot(numplots,1,c);
    hplt = plot(hsub(c),outdatcomplete.derivedTimes,y);
    hplt.LineWidth = 2;
    hplt.Color = [0 0 0.8 0.7];
    title( hsub(c),outRec(1).tdData(c).chanFullStr );
    set(hsub(c),'FontSize',18);
   
    

    % plot event numbers 
    [events,eIdxs] = unique(eventTable.EventType);
    colrsUse = distinguishable_colors(length(eIdxs));
    for e = 1:length(eIdxs)
        eventIdxs = strcmp(events(e),eventTable.EventType);
        ylims = get(gca,'YLim');
        hold on;
        t = eventTable.UnixOffsetTime(eventIdxs) + timeDiff;% bcs clock time may be off compared to INS time
        tevents = repmat(t,1,2); 
        yevents = repmat(ylims,size(tevents,1),1);
        hplt = plot(tevents',yevents');
        for p = 1:length(hplt)
            hplt(p).Color = [colrsUse(e,:) 0.6];
            hplt(p).LineWidth = 3;
        end
        hplts(1,e) = hplt(1); 
    end
%     legend(hplts,events');
    
     % plot annotations 
   
    NewAxisTicks  = (eventTable.UnixOffsetTime + timeDiff)';
    NewAxisLabels = eventTable.EventSubType;
    newAxTick     = [ NewAxisTicks];
    newAxLabels   = [ NewAxisLabels];
    [sortedTicks, idxs] = sort(newAxTick);
    try
        if c == 1
            hsub(c).XTick = sortedTicks;
            hsub(c).XTickLabel = newAxLabels(idxs);
        end
    catch 
        fprintf('ticksn not working \n');
    end
end

% plot accleratoin
hsub(c+1) = subplot(numplots,1,5);
hold on;
axsUse = {'X','Y','Z'};
for i = 1:3
    fnm = sprintf('%sSamples',axsUse{i});
    y = outdatcompleteAcc.(fnm);
    y = y - mean(y);
    set(hsub(c+1),'FontSize',18);
    hplt = plot(hsub(c+1),outdatcompleteAcc.derivedTimes,y);
    hplt.LineWidth = 2;
    hplt.Color = [hplt.Color 0.7];
end
title(hsub(c+1),'actigraphy');
legend({'x','y','z'});
linkaxes(hsub,'x');
for h = 1:length(hsub)
    hsub(h).YLimMode = 'auto';
end

end

function plot_psd_and_spect(btn,event)
%% plot PSD with std error bars
outdatcomplete = btn.Parent.UserData.outdatcomplete;
outRec = btn.Parent.UserData.outRec;
srate = unique( outdatcomplete.samplerate );
xlims = get(gca,'XLim');
t = outdatcomplete.derivedTimes; 
idxus = t > xlims(1) & t < xlims(2); 
tuse = outdatcomplete.derivedTimes(idxus); 


t = tuse - tuse(1); 
windowsize = 1024;
for c = 1:4 % loop on channels 
    fnm = sprintf('key%d',c-1);
    y = outdatcomplete.(fnm)(idxus);
    y = y - mean(y);
    % plot gausian spectrogram 
    res(c) = compute_spectrogram_gaussian(y,srate); 
    [fftOut,f]   = pwelch(y,srate,srate/2,0:1:srate/2,srate,'psd');
    fout(c).f = f; 
    fout(c).fftOut = log10(fftOut); 
end

% plot figures
npltrows = 2; 
npltclms = 2; 


% plod psd with standard error 

hfigPsdStdErr = figure;
for c = 1:4
    hsub(c) = subplot(npltrows,npltclms,c); 
    hold on; 
    f = res(c).center_frequencies; 
    s = res(c).analytic_signal; 
    stdErr = std(log10(abs(s))');
    hsb = shadedErrorBar(f,mean(log10(abs(s)),2),[stdErr; stdErr]);
    title( hsub(c),outRec(1).tdData(c).chanFullStr );
    xlabel('Frequency (Hz)');
    ylabel('Power (log_1_0\muV^2/Hz)');
end
linkaxes(hsub,'xy');

% plod psd pwelch 
hfigPsdPwelch = figure;
for c = 1:4
    hsub(c) = subplot(npltrows,npltclms,c); 
    hplt = plot(hsub(c),fout(c).f,fout(c).fftOut);
    hplt.LineWidth = 2; 
    title( hsub(c),outRec(1).tdData(c).chanFullStr );
    xlabel('Frequency (Hz)');
    ylabel('Power (log_1_0\muV^2/Hz)');
end
linkaxes(hsub,'xy');

% plot spectroram 
hfigSpect = figure;
for c = 1:4
    hsub(c) = subplot(npltrows,npltclms,c); 
    f = res(c).center_frequencies; 
    s = res(c).analytic_signal; 
    imagesc('XData',seconds(t),'YData',f,'CData',10*log10(abs(s)));
    axis tight 
    shading interp 
    title( hsub(c),outRec(1).tdData(c).chanFullStr );
    xlabel('Seconds');
    ylabel('Frequency (Hz)');
end
linkaxes(hsub,'xy');

% save and print stuff
dat = btn.Parent.UserData;
snapshotdir = fullfile(dat.fldername,'snapshots'); 
mkdir(snapshotdir); 

snapfn = sprintf('snapshot-%s-%s',...
    datestr(tuse(1),30),...
    datestr(tuse(end),30));
snapuse = fullfile(snapshotdir,snapfn); 
mkdir(snapuse); 

fnmres = sprintf('snapshot-%s-%s.mat',...
    datestr(tuse(1),30),...
    datestr(tuse(end),30));
fnsmv = fullfile(snapuse,fnmres);
% dont save satat for now - it takes up a lot of space
% save(fnsmv,'res','tuse','fout','dat'); 


% params to print the figures 
params.plotwidth           = 12;
params.plotheight          = 12*0.6;
params.figdir              = snapuse;
params.figtype             = '-djpeg';
params.closeafterprint     = 1; 
params.resolution          = 300;




fnmres = sprintf('snapshot-%s-%s_psdStdErr',...
    datestr(tuse(1),30),...
    datestr(tuse(end),30));
fnsmv = fullfile(snapuse,[fnmres '.fig']);
savefig(hfigPsdStdErr,fnsmv,'compact') 
params.figname             = fnmres;
plot_hfig(hfigPsdStdErr,params); 

fnmres = sprintf('snapshot-%s-%s_psdPwelch',...
    datestr(tuse(1),30),...
    datestr(tuse(end),30));
fnsmv = fullfile(snapuse,[fnmres '.fig']);
savefig(hfigPsdPwelch,fnsmv,'compact') 
params.figname             = fnmres;
plot_hfig(hfigPsdPwelch,params); 

fnmres = sprintf('snapshot-%s-%s_spectrogram',...
    datestr(tuse(1),30),...
    datestr(tuse(end),30));
fnsmv = fullfile(snapuse,[fnmres '.fig']);
savefig(hfigSpect,fnsmv,'compact') 
params.figname             = fnmres;
plot_hfig(hfigSpect,params); 


fnmres = sprintf('snapshot-%s-%s_raw',...
    datestr(tuse(1),30),...
    datestr(tuse(end),30));
fnsmv = fullfile(snapuse,[fnmres '.fig']);
savefig(dat.hfigRaw,fnsmv,'compact') 
params.figname             = fnmres;
params.plotwidth           = 24;
params.plotheight          = 24*0.6;

plot_hfig(dat.hfigRaw,params); 

end





