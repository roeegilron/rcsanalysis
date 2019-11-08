function plot_montage_parent_function()


%% RCS 07 

% left side

% off meds
data{1,1} = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS07/v15_athome_off_on_montage/off_meds/RCS07L/Session1569436511438/DeviceNPC700419H/rawMontageData.mat';
% on meds
data{2,1} = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS07/v15_athome_off_on_montage/on_meds_without_dykinesia/RCS07L/Session1569347506366/DeviceNPC700419H/rawMontageData.mat';

% right side

% off meds
data{1,2} = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS07/v15_athome_off_on_montage/off_meds/RCS07R/Session1569436056338/DeviceNPC700403H/rawMontageData.mat';
% on meds
data{2,2} = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS07/v15_athome_off_on_montage/on_meds_without_dykinesia/RCS07R/Session1569346542818/DeviceNPC700403H/rawMontageData.mat';

figdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS07/v15_athome_off_on_montage/figures';
plot_montage_on_off_meds_saved_data(data,figdir);



%% RCS 05

% left side

% off meds
data{1,1} = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS05/v05_3week/rcs_data/StarrLab/RCS05L/Session1565801585915/DeviceNPC700414H/rawMontageData.mat';
% on meds
data{2,1} = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS05/v05_3week/rcs_data/StarrLab/RCS05L/Session1565810644386/DeviceNPC700414H/rawMontageData.mat';

% right side

% off meds
data{1,2} = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS05/v05_3week/rcs_data/StarrLab/RCS05R/Session1565801178469/DeviceNPC700415H/rawMontageData.mat';
% on meds
data{2,2} = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS05/v05_3week/rcs_data/StarrLab/RCS05R/Session1565810961752/DeviceNPC700415H/rawMontageData.mat';

figdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS05/v05_3week/figures';
plot_montage_on_off_meds_saved_data(data,figdir);



%% RCS 06

% left side

% off meds
data{1,1} = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS06/v00_OR_day/RCSdata/StarrLab/RCS06L/Session1569971901227/DeviceNPC700424H/rawMontageData.mat';
% on meds
data{2,1} = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS06/v00_OR_day/RCSdata/StarrLab/RCS06L/Session1569979258863/DeviceNPC700424H/rawMontageData.mat';

% right side

% off meds
data{1,2} = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS06/v00_OR_day/RCSdata/StarrLab/RCS06R/Session1569973527727/DeviceNPC700425H/rawMontageData.mat';
% on meds
data{2,2} = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS06/v00_OR_day/RCSdata/StarrLab/RCS06R/Session1569979644476/DeviceNPC700425H/rawMontageData.mat';

figdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS06/v00_OR_day/figures';



%% RCS 06 10 day visit 
addpath(genpath(fullfile('..','..','PAC')));
% left side

% off meds
data{1,1} = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS06/v10_day/rcs_data/RCS_data/SCBS/RCS06L/Session1570548340725/DeviceNPC700424H/rawMontageData.mat';
% on meds
data{2,1} = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS06/v10_day/rcs_data/RCS_data/SCBS/RCS06L/Session1570562094151/DeviceNPC700424H/rawMontageData.mat';

% right side

% off meds
data{1,2} = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS06/v10_day/rcs_data/RCS_data/SCBS/RCS06R/Session1570548248261/DeviceNPC700425H/rawMontageData.mat';
% on meds
data{2,2} = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS06/v10_day/rcs_data/RCS_data/SCBS/RCS06R/Session1570561801299/DeviceNPC700425H/rawMontageData.mat';

figdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS06/v10_day/figures';

%%


%% RCS 06 3 week visit 
addpath(genpath(fullfile('..','..','PAC')));
% left side

% off meds
data{1,1} = '/Volumes/RCS_DATA/RCS06/v10_3_week_before_stimon/rcs_data/RCS06L/Session1572885795402/DeviceNPC700424H/rawMontageData.mat';
% on meds
data{2,1} = '/Volumes/RCS_DATA/RCS06/v10_3_week_before_stimon/rcs_data/RCS06L/Session1572900871716/DeviceNPC700424H/rawMontageData.mat';

% right side

% off meds
data{1,2} = '/Volumes/RCS_DATA/RCS06/v10_3_week_before_stimon/rcs_data/RCS06R/Session1572888110541/DeviceNPC700425H/rawMontageData.mat';
% on meds
data{2,2} = '/Volumes/RCS_DATA/RCS06/v10_3_week_before_stimon/rcs_data/RCS06R/Session1572900834135/DeviceNPC700425H/rawMontageData.mat';

figdir = '/Volumes/RCS_DATA/RCS06/v10_3_week_before_stimon/figures';

plot_montage_on_off_meds_saved_data(data,figdir);
%%


%% RCS 06 3 week visit - 1000hz 
addpath(genpath(fullfile('..','..','PAC')));
% left side


dirname = '/Volumes/RCS_DATA/RCS06/v10_3_week_before_stimon/rcs_data/';
montageFilesFound = findFilesBVQX(dirname,'rawMontageData.mat')
fprintf('\n'); 
outMontages = table(); 
for m = 1:length(montageFilesFound)
    [pn,fn] = fileparts(montageFilesFound{m}); 
    ff = findFilesBVQX(pn,'EventLog.mat'); 
    [pn,fn] = fileparts(pn);
    [pn,fn] = fileparts(pn);
    outMontages.session{m} = fn;
    [pn,patientraw] = fileparts(pn);
    outMontages.patient{m} = patientraw(1:end-1);
    outMontages.side{m} = patientraw(end);

    load(ff{1}); 
    montageEvents = eventTable(cellfun(@(x) any(strfind(x,': config')),eventTable.EventType) , :);
    startTime = montageEvents.UnixOffsetTime(1);
    startTime.Format = 'dd-MMM-yyyy HH:mm:ss';
    outMontages.startTime(m) = startTime; 
    endTime = montageEvents.UnixOffsetTime(end);
    endTime.Format = 'dd-MMM-yyyy HH:mm:ss';
    outMontages.endTime(m) = endTime; 
    lastEventRaw = regexp(montageEvents.EventType(end),'[0-9]+','match');
    numMontageFiles = str2num(lastEventRaw{1}{1}); 
    outMontages.numFiles(m) = numMontageFiles;

    dur = endTime-startTime; 
    outMontages.dur{m} = dur;
end
numFiles = 5; % 5 - default , 9 - all pairs, 12 - 1000hz 
timeCompare = outMontages.startTime; 
[y,m,d] = ymd(timeCompare);
dateArray = datetime(y,m,d);
dateUse = datetime('04-Nov-2019');
idxuse = (dateArray == dateUse) & outMontages.numFiles == numFiles; 

tableUse = outMontages(idxuse,:); 

% left side 

% off meds
dataRaw{1,1} = 'Session1572885795402';
% on meds
dataRaw{2,1} = 'Session1572900871716';

% right side

% off meds
dataRaw{1,2} = 'Session1572888110541';
% on meds
dataRaw{2,2} = 'Session1572900834135';

for i = 1:size(dataRaw,1)
    for j = 1:size(dataRaw,2)
        ff = findFilesBVQX(dirname,dataRaw{i,j},struct('dirs',1)); 
        ff = findFilesBVQX(ff{1},'rawMontageData.mat'); 
        data{i,j} = ff{1};
    end
end

figdir = '/Volumes/RCS_DATA/RCS06/v10_3_week_before_stimon/figures1000hz';


plot_montage_on_off_meds_saved_data(data,figdir);

    % plot the montage gui's 
    for i = 1:size(dataRaw,1)
        for j = 1:size(dataRaw,2)
            [pn,fn] = fileparts(data{i,j});
            plot_montage_data(pn); 
        end
    end
%%






%%  plot

