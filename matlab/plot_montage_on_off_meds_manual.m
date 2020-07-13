function plot_montage_on_off_meds_manual()

% off meds
% right 
params.datadir{1} = '/Users/juananso/Starr Lab Dropbox/RC+S Patient Un-Synced Data/RCS10 Un-Synced Data/SummitData/SummitContinuousBilateralStreaming/RCS10R/Session1592584999926/DeviceNPC700430H';
% left 
params.datadir{1} = '/Users/juananso/Starr Lab Dropbox/RC+S Patient Un-Synced Data/RCS10 Un-Synced Data/SummitData/SummitContinuousBilateralStreaming/RCS10L/Session1592585002796/DeviceNPC700436H';

% on meds
% right 
params.datadir{2} = '/Users/juananso/Starr Lab Dropbox/RC+S Patient Un-Synced Data/RCS10 Un-Synced Data/SummitData/SummitContinuousBilateralStreaming/RCS10R/Session1592592974806/DeviceNPC700430H';
% left 
params.datadir{2} = '/Users/juananso/Starr Lab Dropbox/RC+S Patient Un-Synced Data/RCS10 Un-Synced Data/SummitData/SummitContinuousBilateralStreaming/RCS10L/Session1592592981750/DeviceNPC700436H';

params.outdir  = '/Users/juananso/Dropbox (Personal)/Work/DATA/RCS_patients/RCS10/3week/athome_off_on_montage/output';
params.figdir  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS07/v15_athome_off_on_montage/figures';
params.side = {'L','R'};

% off meds
% right 
% params.datadir{1} = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS05/v04_10_day/rcs_data/starrlab/RCS05R/Session1563899210979/DeviceNPC700415H';
% % left 
% params.datadir{1} = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS05/v04_10_day/rcs_data/starrlab/RCS05L/Session1563899944211/DeviceNPC700414H';
% % on meds
% % right 
% params.datadir{2} = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS05/v04_10_day/rcs_data/starrlab/RCS05R/Session1563909455247/DeviceNPC700415H';
% % left 
% params.datadir{2} = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS05/v04_10_day/rcs_data/starrlab/RCS05L/Session1563909759970/DeviceNPC700414H';
% 
% % off meds left 
% params.datadir{1} = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS07/v15_athome_off_on_montage/off_meds/RCS07R/Session1569436056338/DeviceNPC700403H';
% % on meds left 
% params.datadir{2} = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS07/v15_athome_off_on_montage/on_meds_without_dykinesia/RCS07R/Session1569346542818/DeviceNPC700403H';
% params.outdir  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS07/v15_athome_off_on_montage/figures';
% params.figdir  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS07/v15_athome_off_on_montage/figures';
% params.side    = 'R';

% params to print the figures
prfig.plotwidth           = 25;
prfig.plotheight          = 25*0.6;
prfig.figdir              = params.outdir;
prfig.figtype             = '-djpeg';
prfig.closeafterprint     = 0;
prfig.resolution          = 300;

for d = 1:length(params.datadir)
    [outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerTable] =  MAIN_load_rcs_data_from_folder(params.datadir{d});
    
    idxnonzero = find(outdatcomplete.PacketRxUnixTime~=0);
    packtRxTimes    =  datetime(outdatcomplete.PacketRxUnixTime(idxnonzero)/1000,...
        'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
    
    
    deviceSettingsFn = fullfile(params.datadir{d},'DeviceSettings.json');
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
            idxElectrodes = i;
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
                app(d).rawDatSTN(cntStn).rawdata = y(idxuse);
                app(d).rawDatSTN(cntStn).sr = sr;
                app(d).rawDatSTN(cntStn).chan = sprintf('+%s-%s',outRec(idxElectrodes).tdData(c).plusInput,outRec(idxElectrodes).tdData(c).minusInput);
                app(d).rawDatSTN(cntStn).chanFullStr = outRec(idxElectrodes).tdData(c).chanFullStr;
                app(d).rawDatSTN(cntStn).stimAmp = stimAmp;
                cntStn = cntStn + 1;
            else
                % save raw data in order to plot psds
                app(d).rawDatM1(cntM1).rawdata = y(idxuse);
                app(d).rawDatM1(cntM1).sr = sr;
                app(d).rawDatM1(cntM1).chan = sprintf('+%s-%s',outRec(idxElectrodes).tdData(c).plusInput,outRec(idxElectrodes).tdData(c).minusInput);
                app(d).rawDatM1(cntM1).chanFullStr = outRec(idxElectrodes).tdData(c).chanFullStr;
                app(d).rawDatM1(cntM1).stimAmp = stimAmp;
                cntM1 = cntM1 + 1;
            end
        end
    end
    prfig.figname             = 'all_raw_data_with_events';
    plot_hfig(hfig,prfig);
end

% plot med on med off;
close all;
chanNames = {'rawDatSTN','rawDatM1'};
medstate = {'off med','on med'}; 
colorsUse = [0.8 0 0 0.8; 0 0.8 0 0.8];
for c = 1:length(chanNames)
    hfig  = figure; hold on; 
    for i = 1:10
        subplot(5,2,i); hold on; 
        for m = 1:2 % loop on med state - first is off meds 
            rawdat = app(m).(chanNames{c})(i).rawdata;
            sr     = app(m).(chanNames{c})(i).sr;
            [fftOut,ff]   = pwelch(rawdat,sr,sr/2,0:1:sr/2,sr,'psd');
            plot(ff,log10(fftOut),'LineWidth',4,...
                'Color',colorsUse(m,:));
        end
        xlim([3 100]);
        electrodeUse     = app(m).(chanNames{c})(i).chan;
        titleUse = sprintf('%s %s %s',params.side,chanNames{c},electrodeUse); 
        title(titleUse);
        legend(medstate);
        set(gca,'FontSize',18); 
        set(gcf,'Color','w'); 
    end
    prfig.figname             = sprintf('%s',chanNames{c}); 
    plot_hfig(hfig,prfig);
end
x =2 ;