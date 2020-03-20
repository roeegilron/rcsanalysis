function print_stim_and_sense_settings_in_folders(dirname)
% this will print the channels recorded from in each file 
% it will only choose files in which the sense settings have not changed
% mid file (e.g. smpaling rate change, montage files etc.) 
databasefile = fullfile(dirname,'database.mat'); 
if exist(databasefile,'file') 
    load(databasefile);
else
    MAIN_report_data_in_folder(dirname); 
end
if iscell(tblout.startTime)
    idxkeep = cellfun(@(x) ~isempty(x),tblout.startTime);
    datTab = tblout(idxkeep,:);
    datTab.duration = cellfun(@(x) x(1),datTab.duration);
elseif isdatetime( tblout.startTime)
    datTab = tblout;
end

sense_stim_table = table();
sense_stim_table.duration(1) = duration();
sense_stim_table.start_time(1) = NaT;
sense_stim_table.group{1} = 'NA';
sense_stim_table.activeGroup{1} = 'NA';
sense_stim_table.stimulation_on(1) = 0;
sense_stim_table.program{1} = 'NA';
sense_stim_table.pulseWidth_mcrSec(1) = NaN;
sense_stim_table.amplitude_mA(1) = NaN;
sense_stim_table.rate_Hz(1) = NaN;
sense_stim_table.electrodes{1} = 'NA';
sense_stim_table.chan1{1} = 'NA';
sense_stim_table.chan2{1} = 'NA';
sense_stim_table.chan3{1} = 'NA';
sense_stim_table.chan4{1} = 'NA';
sense_stim_table.session{1} = 'NA';

    

cntbl = 1; 
fid = fopen(fullfile(dirname,'stimAndDeviceSettingsLog.txt'),'w+');
for s = 1:size(datTab,1) 
    [pn,fn,ext] = fileparts(datTab.tdfile{s});
    jsonfn = fullfile(pn,'DeviceSettings.json');
    if isfile(jsonfn)
        loadDeviceSettings(jsonfn);
        load(fullfile(pn,'DeviceSettings.mat'));
        if length(outRec) == 1 % only choose files in which sense settinsg have not changed 
            jsonfn = fullfile(pn,'StimLog.json');
            loadStimSettings(jsonfn);
            load(fullfile(pn,'StimLog.mat'));
            
            % put device settings in output table 
            for cc = 1:4
                fnuse = sprintf('chan%d',cc);
                sense_stim_table.(fnuse){cntbl} = outRec.tdData(cc).chanFullStr;
            end
            try
                fprintf(fid,'%s - %s\n',datTab.startTime{s}, datTab.endTime{s});
                fprintf(fid,'\t - duration %s \t%s\n',datTab.duration(s),datTab.sessname{s});
                sense_stim_table.duration(cntbl) = datTab.duration(s);
                sense_stim_table.start_time(cntbl) = datTab.startTime{s};
                sense_stim_table.session{cntbl} = datTab.sessname{s};
            catch
                fprintf(fid,'%s - %s\n',datTab.startTime(s), datTab.endTime(s));
                fprintf(fid,'\t - duration %s \t%s\n',datTab.duration(s),datTab.sessname{s});
                sense_stim_table.duration(cntbl) = datTab.duration(s);
                sense_stim_table.start_time(cntbl) = datTab.startTime(s);
                sense_stim_table.session{cntbl} = datTab.sessname{s};

            end
            if isempty(stimState)
                fprintf(fid,'\t - STIM IS OFF\n')
                sense_stim_table.group{cntbl} = 'NA';
                sense_stim_table.activeGroup{cntbl} = 'NA';
                sense_stim_table.stimulation_on(cntbl) = 0;
                sense_stim_table.program{cntbl} = 'NA';
                sense_stim_table.pulseWidth_mcrSec(cntbl) = NaN;
                sense_stim_table.amplitude_mA(cntbl) = NaN;
                sense_stim_table.rate_Hz(cntbl) = NaN;
                sense_stim_table.electrodes{cntbl} = 'NA';


            else
                stimTable = stimState(logical(stimState.activeGroup),:);
                fprintf(fid,'\t - stim:\t group %s - stim state %d stim amp %.2f rate %.2f\n',...
                    stimTable.group,stimTable.stimulation_on,stimTable.amplitude_mA, stimTable.rate_Hz);
                
                sense_stim_table.group{cntbl} = stimTable.group;
                sense_stim_table.activeGroup{cntbl} = stimTable.activeGroup;
                sense_stim_table.stimulation_on(cntbl) = stimTable.stimulation_on;
                sense_stim_table.program{cntbl} = stimTable.program;
                sense_stim_table.pulseWidth_mcrSec(cntbl) = stimTable.pulseWidth_mcrSec;
                sense_stim_table.amplitude_mA(cntbl) = stimTable.amplitude_mA;
                sense_stim_table.rate_Hz(cntbl) = stimTable.rate_Hz;
                sense_stim_table.electrodes{cntbl} = stimTable.electrodes{1};

            end
            cntbl = cntbl +1;
            fprintf(fid,'\n');
            fprintf(fid,'\t\t\t\t\t\t\t\t\t%s\n',outRec.tdData.chanFullStr);
            fprintf(fid,'\n\n\');
        end
    end
end
flsave = fullfile(dirname,'stim_and_sense_settings_table.mat');
save(flsave,'sense_stim_table');
