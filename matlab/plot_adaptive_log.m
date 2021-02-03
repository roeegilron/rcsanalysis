function plot_adaptive_log(fn)
%%
%%
warning('off','MATLAB:table:RowsAddedExistingVars');
[adaptiveLogTable, rechargeSessions, groupChanges] = read_adaptive_txt_log(fn);

% find device settings so you can also print some meta data on the log 
[pn,~] = fileparts(fn); 
[pnn,~] = fileparts(pn); 
fndeviceSettings = fullfile(pnn,'DeviceSettings.json'); 

%% need access to the database / downloaded file for these settings 
ds = get_meta_data_from_device_settings_file(fndeviceSettings);
patientAndSide = sprintf('%s %s',ds.patient{1},ds.side{1});

%% get detector settings 
% addpath(genpath('/Users/roee/Documents/Code/Analysis-rcs-data/code'));
% strOut = getAdaptiveHumanReadaleSettings(ds,1);


% old left overt - need to fix 
% [DetectorSettings,AdaptiveStimSettings,AdaptiveRuns_StimSettings] = createAdaptiveSettingsfromDeviceSettings(pnn);
% [TD_SettingsOut, Power_SettingsOut, FFT_SettingsOut, metaData] = createDeviceSettingsTable(pnn);

%%
allDays =  day(adaptiveLogTable.time);
allMonths = month(adaptiveLogTable.time);
unqDays  = unique(day(adaptiveLogTable.time));
unqMonth = unique(month(adaptiveLogTable.time));

for m = 1:length(unqMonth)
    for d = 1:length(unqDays)
        idxuse = allMonths == unqMonth(m) & allDays == unqDays(d); 
        aPlot = adaptiveLogTable(idxuse,:); 
        if ~isempty(aPlot)
            aPlot = sortrows(aPlot,'time');
            dayPlot = table(); 
            dCnt = 1; 
            for i = 1:size(aPlot,1)
                if i == 1 
                   dayPlot.time(dCnt) = aPlot.time(i); 
                   dayPlot.current(dCnt) = aPlot.prog0(i); 
                   dayPlot.state(dCnt)   = aPlot.newstate(i);
                   dCnt = dCnt + 1; 
                else 
                   if aPlot.prog0(i) == aPlot.prog0(i-1)
                       dayPlot.time(dCnt) = aPlot.time(i);
                       dayPlot.current(dCnt) = aPlot.prog0(i);
                       dayPlot.state(dCnt)   = aPlot.newstate(i);
                       dCnt = dCnt + 1;
                   else
                       dayPlot.time(dCnt) = aPlot.time(i);
                       dayPlot.current(dCnt) = aPlot.prog0(i-1);
                       dayPlot.state(dCnt)   = aPlot.newstate(i-1);
                       dCnt = dCnt + 1;
                       dayPlot.time(dCnt) = aPlot.time(i);
                       dayPlot.current(dCnt) = aPlot.prog0(i);
                       dayPlot.state(dCnt)   = aPlot.newstate(i);
                       dCnt = dCnt + 1;
                   end
                end
            end
            % make a timeline of group changes for the day 
            % based on the last time a setting was changed in the log 
%             groupChangeBeforeIdx = groupChanges.time <= dayPlot.time(1);
%             groupChangeBefor = groupChanges(groupChangeBeforeIdx,:);
%             [yAdaptive,mAdaptive,dAdaptive] = ymd(dayPlot.time(1)); 
%             for gc = 1:size(groupChangeBefor,1)
%                 [yGc,mGc,dGc] = ymd(groupChangeBefor.time(gc)); 
%                 if yAdaptive == yGc & mAdaptive == mGc & dGc == dAdaptive
%                 else
%                     idxBreak = gc; 
%                     break; 
%                 end
%             end
%             groupChangesUse = groupChangeBefor(1:idxBreak,:);
%             groupChangeCompute = sortrows(groupChangesUse,{'time'});
%             dateVecFirstEntry = datevec(groupChangeCompute.time(1));
%             dateVecFirstEntry(1) = yAdaptive;
%             dateVecFirstEntry(2) = mAdaptive;
%             dateVecFirstEntry(3) = dAdaptive;
%             dateVecFirstEntry(4) = 0;
%             dateVecFirstEntry(5) = 0;
%             dateVecFirstEntry(6) = 1;
%             dateFirstEntry = datetime(dateVecFirstEntry);
%             dateFirstEntry.TimeZone = groupChangeCompute.time(1).TimeZone;
%             groupChangeCompute.time(1) = dateFirstEntry; 
%             cntGroup = 1; 
%             groupUseOut = [];  timeUse = [];
%             for gc = 1:size(groupChangeCompute,1) 
%                 switch groupChangeCompute(gc)
%                     case 'A'
%                         groupUse = 1;
%                     case 'B'
%                         groupUse = 2;
%                     case 'C'
%                         groupUse = 3;
%                     case 'D'
%                         groupUse = 4;
%                 end
%                 if gc > 1
%                     groupUseOut(cntGroup) = groupUseOut(end); 
%                     timeUse(cntGroup) = groupChangeCompute(gc);
%                     cntGroup  = cntGroup  + 1;
%                     groupUseOut(cntGroup) = groupUse;
%                     timeUse(cntGroup) = groupChangeCompute(gc);
%                     cntGroup  = cntGroup  + 1;
%                 else
%                     groupUseOut(cntGroup) = groupUse; 
%                     timeUse(cntGroup) = groupChangeCompute(gc); 
%                     cntGroup  = cntGroup  + 1;i
%                 end
%                 
%             end
            
            %% plot 
            % compute weighted average for the day 
            numSecsPerCurrent = seconds(diff(dayPlot.time));
            currentsUse = dayPlot.current(2:end); 
            currentsWeighted = {};
            for a = 1:length(currentsUse)
                currentsWeighted{a} = repmat(currentsUse(a),1,numSecsPerCurrent(a));
            end
            weightedMean  = mean([currentsWeighted{:}]);
            nonWeightedMean = mean(dayPlot.current);
            fprintf('w mean = %.2f non weighted mean = %.2f\n',weightedMean,nonWeightedMean);
            
            % plot 
            hfig = figure;
            hfig.Color = 'w';
            hPlt = plot(dayPlot.time,dayPlot.current,'LineWidth',2,'Color',[0 0 0.8 0.5]);
            hsb = gca;
            ylims = hsb.YLim;
            hsb.YLim(1) = hsb.YLim(1)*0.9;
            hsb.YLim(2) = hsb.YLim(2)*1.1;
            ttluse{1,1} = patientAndSide;
            ttluse{1,2} = sprintf('%d/%d/%d (%.2fmA = avg current)',month(dayPlot.time(1)),day(dayPlot.time(1)),year(dayPlot.time(1)),weightedMean);
            
            title(ttluse);
            ttlsave = sprintf('%d_%d_%d',month(dayPlot.time(1)),day(dayPlot.time(1)),year(dayPlot.time(1)));
            
            [pn,~] = fileparts(fn);
            prfig.plotwidth           = 8;
            prfig.plotheight          = 6;
            prfig.figdir             = pn;
            prfig.figname             = ttlsave;
            prfig.figtype             = '-djpeg';
            plot_hfig(hfig,prfig)
            close(hfig);
            
            % save data 
            [yyy,mmm,ddd] = ymd(dayPlot.time(1));
            [hhh,MIN,~] = hms(dayPlot.time(1));
            fnsave = sprintf('%d_%0.2d_%0.2d__%0.2d-%0.2d.mat',yyy,mmm,ddd,hhh,MIN);
            fnTosave = fullfile(pn,fnsave);
            save(fnTosave,'aPlot');

            %%
        end
    end
end
return 

%%
end