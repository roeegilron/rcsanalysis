function plot_stim_titrations_from_auto_montage_RCS02()
%% load data
close all;
%% RCS02 R
useThis = 1;
if useThis    
    rootdir = '/Users/roee/Box/Starr_Lab_Folder/Data_Analysis/RCS_data/results/stim_titrations_adaptive/RCS02R';
    cnt = 1;
    patinetAndSide = 'RCS02_R';
    
    arStateUse{cnt} = 'off, L side on 0mA, off meds';
    groupUseList{cnt} = 'A';
    clrUse{cnt}       = [0.8 0 0];
    edgUse{cnt}       = [1 1 1];
    condsLeg{cnt}     = 'off M contra 0.0mA';
    cnt = cnt + 1;
    
    arStateUse{cnt} = 'off, L side on 2.2mA, off meds';
    groupUseList{cnt} = 'A';
    clrUse{cnt}       = [0.8 0 0];
    edgUse{cnt}       = [0 0 0];
    condsLeg{cnt}     = 'off M contra 2.7mA';
    cnt = cnt + 1;
    
    arStateUse{cnt} = 'off, L side on 2.2mA, on meds';
    groupUseList{cnt} = 'A';
    clrUse{cnt}       = [0 0.8 0];
    edgUse{cnt}       = [0 0 0];
    condsLeg{cnt}     = 'off M contra 2.7mA';
    cnt = cnt + 1;
    
    
    arStateUse{cnt} = 'off, L side on 0mA, on meds';
    groupUseList{cnt} = 'A';
    clrUse{cnt}       = [0 0.8 0];
    edgUse{cnt}       = [1 1 1];
    condsLeg{cnt}     = 'off M contra 2.7mA';
    cnt = cnt + 1;
end
%%

%% RCS02 L
useThis = 0; 
if useThis
    rootdir = '/Users/roee/Box/Starr_Lab_Folder/Data_Analysis/RCS_data/results/stim_titrations_adaptive/RCS02L';
    cnt = 1;
    patinetAndSide = 'RCS02_L';
    
    arStateUse{cnt} = 'off, R side on 2.7mA, off meds';
    groupUseList{cnt} = 'A';
    clrUse{cnt}       = [0.8 0 0];
    edgUse{cnt}       = [0 0 0];
    condsLeg{cnt}     = 'off M contra 2.7mA';
    cnt = cnt + 1;
    
    arStateUse{cnt} = 'off, R side on 0mA, off meds';
    groupUseList{cnt} = 'A';
    clrUse{cnt}       = [0.8 0 0];
    edgUse{cnt}       = [1 1 1];
    condsLeg{cnt}     = 'off M contra 0.0mA';
    cnt = cnt + 1;
    
    arStateUse{cnt} = 'off, R side on 2.7mA, on meds';
    groupUseList{cnt} = 'A';
    clrUse{cnt}       = [0 0.8 0];
    edgUse{cnt}       = [1 1 1];
    condsLeg{cnt}     = 'on M contra 2.7mA';
    cnt = cnt + 1;
    
    
    arStateUse{cnt} = 'off, R side on 0mA, on meds';
    groupUseList{cnt} = 'A';
    clrUse{cnt}       = [0 0.8 0];
    edgUse{cnt}       = [0 0 0];
    condsLeg{cnt}     = 'on M contra 0.0mA';
    cnt = cnt + 1;
end
%%

figdir = '/Users/roee/Box/Starr_Lab_Folder/Data_Analysis/RCS_data/results/stim_titrations_adaptive/figures';
ff = findFilesBVQX(rootdir,'DeviceSettings.json');

hfig = figure;
hfig.Color = 'w';

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
        stimStateChanges = ds.stimStateChanges{1};
        stimStateChangesSort = stimStateChanges(stimStateChanges.duration > seconds(40),:);
        % what settings were used? 
        arState = arStateUse{cntFnd};
        groupUse = groupUseList{cntFnd};
        
        
        %% plot
        timenum = powerOut.powerTable.PacketRxUnixTime;
        t = datetime(timenum/1000,'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
        times.TimeZone = t.TimeZone;
        pt = powerOut.powerTable;
        for bb = 1:8
            subplot(4,2,bb);
            hold on;
            for e = 1:size(times,1)
                idxuse = t > times(e,1) & t < times(e,2);
                fnb = sprintf('Band%d',bb);
                y = pt.(fnb)(idxuse);
                x = stimLevels(e);
                fprintf('%d\n',length(x));
                hsc = scatter(x,mean(y),100,'filled',...
                    'MarkerFaceColor',clrUse{cntFnd},...
                    'MarkerFaceAlpha',0.4,...
                    'MarkerEdgeColor',edgUse{cntFnd});
                xlabel('Stim amp (mA)');
                ylabel(['Power:' powerOut.bands(bb).powerBandInHz{bb}]);
                if bb == 1 & e == 1 
                    hscLeg(cntFnd) = hsc;
                end
                if e == 1 
                    hscLegTest(cntFnd,bb) = hsc;
                end
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
        
    end
end
hsb = hfig.Children(end); 
legend(hscLeg,condsLeg);
% 
% bb = 1; 
% for i = 1:4 
%     for j = 1:2
%         axes(subplot(i,j,bb));
%         legend(hscLegTest(:,bb)',condsLeg');
%         bb = bb + 1; 
%     end
% end
prfig.plotwidth           = 8.5*1.8;
prfig.plotheight          = 11*1.6;
prfig.figdir             = figdir;
prfig.figname             = sprintf('%s_COMPARE_ALL_CONDS',patinetAndSide);
plot_hfig(hfig,prfig)

end