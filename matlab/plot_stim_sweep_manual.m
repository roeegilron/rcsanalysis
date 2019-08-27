function plot_stim_sweep_manual(datadir,figdir)
% input: string of data directory with a stim sweep session, string of
% figure directoy where you want figures to be output 
% output: figure of stim sweep results 

params.datadir = datadir;
params.outdir  = figdir;

% params to print the figures 
prfig.plotwidth           = 25;
prfig.plotheight          = 25*0.6;
prfig.figdir              = params.outdir;
prfig.figtype             = '-djpeg';
prfig.closeafterprint     = 0; 
prfig.resolution          = 300;


[outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerTable] =  MAIN_load_rcs_data_from_folder(params.datadir);

idxnonzero = find(outdatcomplete.PacketRxUnixTime~=0); 
packtRxTimes    =  datetime(outdatcomplete.PacketRxUnixTime(idxnonzero)/1000,...
    'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');


deviceSettingsFn = fullfile(params.datadir,'DeviceSettings.json');
outRec = loadDeviceSettingsForMontage(deviceSettingsFn);
% figure out add / subtract factor for event times (if pc clock is not same
% as INS time).
idxTimeCompare = find(outdatcomplete.PacketRxUnixTime~=0,1);
packRxTimeRaw  = outdatcomplete.PacketRxUnixTime(idxTimeCompare);
packtRxTime    =  datetime(packRxTimeRaw/1000,...
    'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
derivedTime    = outdatcomplete.derivedTimes(idxTimeCompare);
timeDiff       = derivedTime - packtRxTime;


secs = outdatcomplete.derivedTimes;
app.subTime = secs(1);
% find start events
idxStart = cellfun(@(x) any(strfind(x,'Start')),eventTable.EventType);
idxEnd = cellfun(@(x) any(strfind(x,'Stop')),eventTable.EventType);
% plot data
hfig = figure; 
for c = 1:4
    hsub(c) = subplot(4,1,c); 
    hold(hsub(c),'on');
    cfnm = sprintf('key%d',c-1);
    y = outdatcomplete.(cfnm);
    secsUse = secs;
    plot(secsUse,y,'Parent',hsub(c));
    title(cfnm,'Parent',hsub(c));
end
linkaxes(hsub,'x');
% insert event table markers and link them
ets = eventTable(idxStart,:);
ete = eventTable(idxEnd,:);
hpltStart = gobjects(sum(idxStart),4);
hpltEnd = gobjects(sum(idxStart),4);
cntStn = 1;
cntM1 = 1;
for i = 1:sum(idxStart)
    for c = 1:4
        hsubs = get(hsub(c));
        ylims = hsubs.YLim;
        % start
        [~,idxClosest] = min(abs(packtRxTimes-ets.UnixOffsetTime(i)));
        idxInOutDataCompleteUnits = idxnonzero(idxClosest); 
        xval = outdatcomplete.derivedTimes(idxInOutDataCompleteUnits); 
%         xval = ets.UnixOffsetTime(i) + timeDiff;
        startTime = xval;
        hplt = plot([xval xval],ylims,'Parent',hsub(c),'Color',[0 0.8 0 0.7],'LineWidth',3);
        hpltStart(i,c) = hplt;
        % end
        [~,idxClosest] = min(abs(packtRxTimes-ete.UnixOffsetTime(i)));
        idxInOutDataCompleteUnits = idxnonzero(idxClosest); 
        xval = outdatcomplete.derivedTimes(idxInOutDataCompleteUnits); 
%         xval = ete.UnixOffsetTime(i)+timeDiff;
        endTime = xval;
        hplt = plot([xval xval],ylims,'Parent',hsub(c),'Color',[0.8 0 0 0.7],'LineWidth',3);
        hpltEnd(i,c) = hplt;
        
        % get raw data
        cfnm = sprintf('key%d',c-1);
        y = outdatcomplete.(cfnm);
        secsUse = secs;
        idxuse = secsUse > (startTime - seconds(5)) & secsUse < (endTime + seconds(5));
        % get sample rate
        % xx - since this is stim sweep assume setting always
        % the same
        idxElectrodes = 1;
        sr = str2num(strrep(outRec(idxElectrodes).tdData(c).sampleRate,'Hz',''));
        % get the params of the stim sweep 
        rawStr = ets.EventType{i}; 
        % find stim amp 
        idxStrStart = strfind(rawStr,'Stim amp: ');
        idxStrEnd   = strfind(rawStr,'. Stim Rate:');
        stimAmp = str2double(strrep(strrep(rawStr(idxStrStart:idxStrEnd),'Stim amp: ',''),'mA.','')); 
        outIdxs(i).idxuse = idxuse; 
        outIdxs(i).stimAmp = stimAmp; 
        if c <=2
            % save raw data in order to plot psds
            app.rawDatSTN(cntStn).rawdata = y(idxuse);
            app.rawDatSTN(cntStn).sr = sr;
            app.rawDatSTN(cntStn).chan = sprintf('+%s-%s',outRec(idxElectrodes).tdData(c).plusInput,outRec(idxElectrodes).tdData(c).minusInput);
            app.rawDatSTN(cntStn).chanFullStr = outRec(idxElectrodes).tdData(c).chanFullStr;
            app.rawDatSTN(cntStn).stimAmp = stimAmp; 
            cntStn = cntStn + 1;
        else
            % save raw data in order to plot psds
            app.rawDatM1(cntM1).rawdata = y(idxuse);
            app.rawDatM1(cntM1).sr = sr;
            app.rawDatM1(cntM1).chan = sprintf('+%s-%s',outRec(idxElectrodes).tdData(c).plusInput,outRec(idxElectrodes).tdData(c).minusInput);
            app.rawDatM1(cntM1).chanFullStr = outRec(idxElectrodes).tdData(c).chanFullStr;
            app.rawDatM1(cntM1).stimAmp = stimAmp; 
            cntM1 = cntM1 + 1;
        end
    end
end
prfig.figname             = 'all_raw_data_with_events';
plot_hfig(hfig,prfig);

% plot raw data and spectrial analysis 

for i = 1:length(outIdxs)
    hfig = figure;
    cntplt = 1;
    for c = 1:4
        subplot(4,3,cntplt); cntplt = cntplt + 1; 
        % plot raw data
        cfnm = sprintf('key%d',c-1);
        y = outdatcomplete.(cfnm);
        idxuse = outIdxs(i).idxuse; 
        rawdata = y(idxuse);
        plot(secsUse(idxuse),rawdata); 
        title(outRec(idxElectrodes).tdData(c).chanFullStr); 
        set(gca,'FontSize',16);
        % plot spectral analysis 
        subplot(4,3,cntplt); cntplt = cntplt + 1; 
        spectrogram(rawdata,sr,ceil(0.875*sr),1:120,sr,'yaxis','psd');
        title(outRec(idxElectrodes).tdData(c).chanFullStr); 
        set(gca,'FontSize',16);
        % plot fft
        subplot(4,3,cntplt); cntplt = cntplt + 1; 
        [fftOut,f]   = pwelch(rawdata,sr,sr/2,0:1:sr/2,sr,'psd');
        plot(f,log10(fftOut),'LineWidth',3);
        ylabel('Power  (log_1_0\muV^2/Hz)');
        xlabel('Frequency (Hz)'); 
        title(outRec(idxElectrodes).tdData(c).chanFullStr); 
        set(gca,'FontSize',16);
    end
    ttleuse = sprintf('%0.3d stimAmp %0.2f',i,outIdxs(i).stimAmp);
    sgtitle(ttleuse,'FontSize',20); 
    fnmres = ttleuse;
    prfig.figname             = fnmres;
    plot_hfig(hfig,prfig);

end

% plot fft 
areas = {'rawDatSTN','rawDatM1'}; 
for a = 1:length(  areas )
    datUse = struct2table(app.(areas{a}));
    uniqchannels = unique(datUse.chan); 
    for c = 1:length(uniqchannels)
        datChan = datUse(strcmp(uniqchannels{c},datUse.chan),:);
        hfig = figure; 
        hold on; 
        for s = 1:size(datChan,1)
            x = datChan.rawdata{s};
            srate = datChan.sr(s); 
            [fftOut,f]   = pwelch(x,srate,srate/2,0:1:srate/2,srate,'psd');
            hplt = plot(f,log10(fftOut));
            hplt.LineWidth = 2; 
            
            % data tips
            hplt.DataTipTemplate.DataTipRows(1).Label = 'Freq';
            hplt.DataTipTemplate.DataTipRows(2).Label = 'Power';
            row = dataTipTextRow('Stim amp',repmat([cellstr(sprintf('%0.2f',datChan.stimAmp(s)))],1,length(f)) );
            hplt.DataTipTemplate.DataTipRows(end+1) = row;
            datacursormode toggle
        end
        cntleg = 1; 
        for ll = 1:size(datChan,1)
            outleg{cntleg} = sprintf('%.2fmA',datChan.stimAmp(ll));
            cntleg = cntleg +1;
        end
        legend(outleg); 
        title(datChan.chanFullStr{1});
        ttleuse = sprintf('%s %s chan',areas{a}, datChan.chan{1});
        fnmres = ttleuse;
        prfig.figname             = fnmres;
        plot_hfig(hfig,prfig);
        figname = [ttleuse '.fig']; 
        figsavename = fullfile(params.outdir,figname); 
        savefig(hfig,figsavename); 
    end
end

end