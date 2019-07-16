function plot_noise_floor_from_montage_data()
% assume sampling rate is 1000hz 
% assumes config files used always the same
% first config file is a noise floor recording with lfp contacts shorted
% and only 2 td channels streaming
% second config file is the other time domain channels streaming
params.datadir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS05/v00_noisefloor/rcs_data/RCS05L/Session1563221574752/DeviceNPC700414H'; 
params.outdir  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS05/v00_noisefloor/figures';


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


% plot fft 
appOrig = app; 
app.rawDatSTN = appOrig.rawDatSTN(1);
app.rawDatSTN.rawdata = mean([appOrig.rawDatSTN(1).rawdata, appOrig.rawDatSTN(2).rawdata ],2);

app.rawDatM1 = appOrig.rawDatM1(1);
app.rawDatM1.rawdata = mean([appOrig.rawDatM1(3).rawdata, appOrig.rawDatM1(4).rawdata ],2);
areas = {'rawDatSTN','rawDatM1'}; 
ttlsuse = {'LFP','ECOG'};
hfig = figure; 
for a = 1:length(  areas )
    subplot(2,1,a); 
    x = app.(areas{a}).rawdata;
    srate = 1e3;
    [fftOut,f]   = pwelch(x,srate,srate/2,0:1:srate/2,srate,'psd');
    hplt = plot(f,log10(fftOut),'LineWidth',2,'Color',[0 0 0.8 0.7]);
    hplt.LineWidth = 3;
    title(ttlsuse{a});
    ylabel('Power  (log_1_0\muV^2/Hz)');
    xlabel('Frequency (Hz)');
    set(gca,'FontSize',20); 
end
fnmres = 'noise floor';
prfig.figname             = fnmres;
plot_hfig(hfig,prfig);
end