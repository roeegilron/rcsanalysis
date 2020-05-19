function plot_data_recorded_across_subjects()

close all; 
clear all;
clc;
rootdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/current_database_file';
load(fullfile(rootdir,'sense_stim_database.mat'));
figdir = rootdir;

params.wake = 6; 
params.sleep = 23; 
%% load patient specific data 
totalTime = table();
cnttbl = 1;
uniquePatients = unique(sense_stim_database.patient);
for p = 1:length(uniquePatients)
    idxpatient = strcmp(sense_stim_database.patient,uniquePatients{p});
    tbl_patient = sense_stim_database(idxpatient,:);
    %% loop on side and create report
    uniqueSides = unique(tbl_patient.side);
    
    for s = 1:length(uniqueSides)
        totalAwake = hours(0);
        totalAsleep = hours(0);
        idxside = strcmp(tbl_patient.side,uniqueSides{s});
        tbluse = tbl_patient(idxside,:);
        
        clear timeDomainFileDur
        timeDomainFileDur(:,1) = tbluse.startTime;
        timeDomainFileDur(:,2) = tbluse.startTime + tbluse.duration;
        
        idxNotSameDay = day(timeDomainFileDur(:,1)) ~= day(timeDomainFileDur(:,2));
        allTimesSameDay = timeDomainFileDur(~idxNotSameDay,:);
        allTimesDiffDay = timeDomainFileDur(idxNotSameDay,:);
        % for idx that is not the same day, split it
        newTimesDay1 = [allTimesDiffDay(:,1) (allTimesDiffDay(:,1) - timeofday(allTimesDiffDay(:,1)) + day(1)) - seconds(1)];
        newTimesDay2 = [((allTimesDiffDay(:,2) - timeofday(allTimesDiffDay(:,2))) + seconds(1)  ) allTimesDiffDay(:,2) ];
        % concatenate all times
        allTimesNew  = sortrows([allTimesSameDay ; newTimesDay1 ; newTimesDay2],1);
        hourtimes = timeofday(allTimesNew); 
        
        for a = 1:length(hourtimes)
            startTime = hourtimes(a,1);
            endTime  = hourtimes(a,2);
            timeToAdd = seconds(0); 
            % option 1 start time and and end time both within awake time 
            if (hour(startTime) >= params.wake & hour(startTime) < params.sleep)  &  (hour(endTime) >= params.wake & hour(endTime) < params.sleep)
                totalAwake = totalAwake + sum(endTime - startTime);
            end
            % option 2 start time before wake and end time in wake range 
            if hour(startTime) < params.wake  & (hour(endTime) >= params.wake & hour(endTime) < params.sleep)
                % sleep time
                timeToAdd = hours(params.wake) - startTime;
                totalAsleep = totalAsleep + timeToAdd;
                % wake time
                timeToAdd = endTime - hours(params.wake);
                totalAwake = totalAwake + timeToAdd;
            end
             % option 3 start time after wake and before sleep and end time in sleep range 
            if (hour(startTime) >= params.wake & hour(startTime) < params.sleep)   &  hour(endTime) >= params.sleep
                % sleep time
                timeToAdd = endTime - hours(params.sleep);
                totalAsleep = totalAsleep + timeToAdd;
                % wake time
                timeToAdd = hours(params.sleep) - startTime;
                totalAwake = totalAwake + timeToAdd;
            end
            % option 4 start time before wake and end time after sleep 
            if hour(startTime) < params.wake   &  hour(endTime) >= params.sleep
                % sleep time 1
                timeToAdd =  hours(params.wake)-startTime;
                totalAsleep = totalAsleep + timeToAdd;
                % sleep time 2
                timeToAdd =  endTime - hours(params.sleep);
                totalAsleep = totalAsleep + timeToAdd;
                % wake time
                timeToAdd = hours(params.sleep) - hours(params.wake);
                totalAwake = totalAwake + timeToAdd;
            end
        end
        
        totalHours = sum(hourtimes(:,2) - hourtimes(:,1));
        totalHoursDatabse = sum(tbluse.duration);

        fprintf('%s %s\n',tbluse.patient{1},tbluse.side{1});
        fprintf('\t database time %s\n',totalHoursDatabse); 
        fprintf('\t convesrs time %s\n',totalHours); 
        fprintf('\t aw + asl time %s\n',totalAwake + totalAsleep); 
        fprintf('\n\n');
        
        totalTime.patient{cnttbl} = tbluse.patient{1};
        totalTime.side{cnttbl} = tbluse.side{1};
        totalTime.awakeHours(cnttbl) = totalAwake;
        totalTime.asleepHours(cnttbl) = totalAsleep;
        cnttbl = cnttbl + 1;
    end
end


uniquePatients = unique(totalTime.patient); 
uniquePatients = uniquePatients([2 5 6 7]);
altPatientNames = uniquePatients;
altPatientNames = {'RCS01';'RCS02';'RCS03';'RCS04'};

recTime = [hours(0) hours(0)];
for p = 1:length(uniquePatients)
    idxuse = strcmp(totalTime.patient,uniquePatients{p});
    recTime(p,1) = sum(totalTime.awakeHours(idxuse));
    recTime(p,2) = sum(totalTime.asleepHours(idxuse));
end
hfig  = figure; 
hfig.Color = 'w';

hbar = bar(recTime);
hsb  = subplot(1,1,1);

hsb.XTickLabel = altPatientNames;
hsb.YLabel.String = 'Hours recoreded'; 
hsb.Title.String = 'Hours recorded at home / patient'; 
hleg = legend({'awake','alseep'},'Location','northeast');
hleg.Box = 'off'; 


hfig = gcf;
prfig.plotwidth           = 20;
prfig.plotheight          = 9;
prfig.figdir              = figdir;
prfig.figtype             = '-djpeg';
prfig.closeafterprint     = 1;
prfig.resolution          = 300;
prfig.figname             = 'paper_patients';
plot_hfig(hfig,prfig);

end