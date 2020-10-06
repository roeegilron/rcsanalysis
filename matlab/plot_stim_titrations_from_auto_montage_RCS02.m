function plot_stim_titrations_from_auto_montage_RCS02()
%% load data
close all;
rootdir = '/Users/roee/Box/Starr_Lab_Folder/Data_Analysis/RCS_data/results/stim_titrations_adaptive/RCS02R';
% rootdir = '/Users/roee/Box/Starr_Lab_Folder/Data_Analysis/RCS_data/results/stim_titrations_adaptive/RCS05L/Session1601680285650/DeviceNPC700414H';
figdir = '/Users/roee/Box/Starr_Lab_Folder/Data_Analysis/RCS_data/results/stim_titrations_adaptive/figures';
ff = findFilesBVQX(rootdir,'DeviceSettings.json');

cntFnd = 0;
for f = 1:length(ff)
    [pn,~] = fileparts(ff{f});
    [outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerOut,adaptiveTable] =  ...
        MAIN_load_rcs_data_from_folder(pn);
    ds = get_meta_data_from_device_settings_file(ff{f});
    %%
    
    idxStartStop = cellfun(@(x) any(strfind(x,'mA')),eventTable.EventType);
    eventTableUse = eventTable(idxStartStop,:);
    idxStart = cellfun(@(x) any(strfind(lower(x),'start')),eventTableUse.EventType);
    idxEnd = cellfun(@(x) any(strfind(lower(x),'stop')),eventTableUse.EventType);
    eStart = eventTableUse(idxStart,:);
    eEnd = eventTableUse(idxEnd,:);
    for e = 1:size(eStart,1)
        times(e,1) = datetime(eStart.UnixOffsetTime(e));
        times(e,2) = datetime(eEnd.UnixOffsetTime(e));
        strExtract = eStart.EventType{e};
        [~, en] = regexp(strExtract,'Stim amp: ');
        [st, ~] = regexp(strExtract,'mA.');
        stimLevels(e) = str2num(strExtract(en:st-1));
        
        
    end
    if ~isempty(eStart)
        cntFnd = cntFnd + 1;
        idxGroup = cellfun(@(x) any(strfind(lower(x),'003')),eventTable.EventType);
        strGroup = eventTable.EventType(idxGroup);
        if ~isempty(strGroup)
            groupUse = strGroup{1}(end);
        else
            groupUse = 'C';
        end
        switch cntFnd
            case 1
                arState = 'off, L side on 0mA';
                groupUse = 'A';
            case 2
                arState = 'off, L side on 2.2mA';
                groupUse = 'A';
            case 3
                arState = 'off';
                groupUse = 'C';
            case 4
                arState = 'off';
                groupUse = 'A';
        end
        
        
        %% plot
        hfig = figure;
        hfig.Color = 'w';
        timenum = powerOut.powerTable.PacketRxUnixTime;
        t = datetime(timenum/1000,'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
        times.TimeZone = t.TimeZone;
        pt = powerOut.powerTable;
        hold on;
        for bb = 1:8
            subplot(4,2,bb);
            hold on;
            for e = 1:size(times,1)
                idxuse = t > times(e,1) & t < times(e,2);
                fnb = sprintf('Band%d',bb);
                y = pt.(fnb)(idxuse);
                x = stimLevels(e);
                fprintf('%d\n',length(x));
                scatter(x,mean(y),200,'filled','MarkerFaceAlpha',0.2);
                xlabel('Stim amp (mA)');
                ylabel(['Power:' powerOut.bands(bb).powerBandInHz{bb}]);
                switch bb
                    case 1
                        senseSettings = ds.senseSettings{1}.chan1;
                    case 2
                        senseSettings = ds.senseSettings{1}.chan1;
                    case 3
                        senseSettings = ds.senseSettings{1}.chan2;
                    case 4
                        senseSettings = ds.senseSettings{1}.chan2;
                    case 5
                        senseSettings = ds.senseSettings{1}.chan3;
                    case 6
                        senseSettings = ds.senseSettings{1}.chan3;
                    case 7
                        senseSettings = ds.senseSettings{1}.chan4;
                    case 8
                        senseSettings = ds.senseSettings{1}.chan4;
                end
                ttlStr{1,1} = senseSettings{1};
                ttlStr{1,2} = powerOut.bands(bb).powerBandInHz{bb};
                title(ttlStr);
            end
            set(gca,'FontSize',10);
        end
        titleStr{1,1} = sprintf('Group %s',groupUse);
        titleStr{2,1} = sprintf('Stim elec: %s %.2f',ds.stimStatus{1}.electrodes{1},ds.stimStatus{1}.rate_Hz);
        titleStr{3,1} = sprintf('active recharge %s',arState);
        sgtitle(titleStr,'FontSize',10);
        prfig.plotwidth           = 8.5;
        prfig.plotheight          = 11;
        prfig.figdir             = figdir;
        prfig.figname             = sprintf('RCS02R_%0.3d',f);
        plot_hfig(hfig,prfig)

    end

end

end