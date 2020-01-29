function do_coherence_on_sep_recordings()
%% all patient data locations 
clc; close all; clear all;
pkgdatdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/pkg_data/processed_data';
figdirout = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/pkg_data/figures';
resultsdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home/coherence';
load(fullfile(pkgdatdir,'pkgDataBaseProcessed.mat'),'pkgDB');



cnt = 1;
% RCS06
dataFiles{cnt}  = '/Volumes/RCS_DATA/RCS06/v10_3_week_before_stimon/data_dump/SummitContinuousBilateralStreaming/RCS06L/processedData.mat';
psdrFiles{cnt}  = '/Volumes/RCS_DATA/RCS06/v10_3_week_before_stimon/data_dump/SummitContinuousBilateralStreaming/RCS06L/psdResults.mat';
dateChoose{cnt} = datetime('Oct 30 2019','Format','MMM dd yyyy');
peaks(cnt,:)  = [18 22];
channel(cnt) = 1;
patient{cnt} = 'RCS06 L';
side{cnt} = 'L';
cnt = cnt+1;

dataFiles{cnt}  = '/Volumes/RCS_DATA/RCS06/v10_3_week_before_stimon/data_dump/SummitContinuousBilateralStreaming/RCS06R/processedData.mat';
psdrFiles{cnt}  = '/Volumes/RCS_DATA/RCS06/v10_3_week_before_stimon/data_dump/SummitContinuousBilateralStreaming/RCS06R/psdResults.mat';
dateChoose{cnt} = datetime('Oct 30 2019','Format','MMM dd yyyy');
peaks(cnt,:)  = [18 22];
channel(cnt) = 1;
patient{cnt} = 'RCS06 R';
side{cnt} = 'R';
cnt = cnt+1;

% RCS07
dataFiles{cnt}  = '/Volumes/RCS_DATA/RCS07/all_data/RCS07L/processedData.mat';
psdrFiles{cnt}  = '/Volumes/Samsung_T5/RCS07/v14_data_dump/SummitContinuousBilateralStreaming/RCS07L/psdResults.mat';
dateChoose{cnt} = datetime('Sep 20 2019','Format','MMM dd yyyy');
peaks(cnt,:)  = [17 21];
channel(cnt) = 1;
patient{cnt} = 'RCS07 L';
side{cnt} = 'L';
cnt = cnt+1;

dataFiles{cnt}  = '/Volumes/RCS_DATA/RCS07/all_data/RCS07R/processedData.mat';
psdrFiles{cnt}  = '/Volumes/Samsung_T5/RCS07/v14_data_dump/SummitContinuousBilateralStreaming/RCS07R/psdResults.mat';
dateChoose{cnt} = datetime('Sep 20 2019','Format','MMM dd yyyy');
peaks(cnt,:)  = [17 21];
channel(cnt) = 1;
patient{cnt} = 'RCS07 R';
side{cnt} = 'R';
cnt = cnt+1;

% RCS05
dataFiles{cnt}  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS05/v05_3week/data_dump/SummitContinuousBilateralStreaming/RCS05L/processedData.mat';
psdrFiles{cnt}  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS05/v05_3week/data_dump/SummitContinuousBilateralStreaming/RCS05L/psdResults.mat';
dateChoose{cnt} = datetime('Jul 26 2019','Format','MMM dd yyyy');
peaks(cnt,:)  = [17 21];
channel(cnt) = 0;
patient{cnt} = 'RCS05 L';
side{cnt} = 'L';
cnt = cnt+1;

dataFiles{cnt}  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS05/v05_3week/data_dump/SummitContinuousBilateralStreaming/RCS05R/processedData.mat';
psdrFiles{cnt}  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS05/v05_3week/data_dump/SummitContinuousBilateralStreaming/RCS05R/psdResults.mat';
dateChoose{cnt} = datetime('Jul 26 2019','Format','MMM dd yyyy');
peaks(cnt,:)  = [17 21];
channel(cnt) = 0;
patient{cnt} = 'RCS05 R';
side{cnt} = 'R';
cnt = cnt+1;

%RCS02
dataFiles{cnt}  = '/Volumes/Samsung_T5/RCS02/RCS02_all_home_data_processed/data/RCS02L/processedData.mat';
psdrFiles{cnt}  = '/Volumes/Samsung_T5/RCS02/RCS02_all_home_data_processed/data/RCS02L/psdResults.mat';
dateChoose{cnt} = datetime('May 21 2019','Format','MMM dd yyyy');
peaks(cnt,:)  = [17 20];
channel(cnt) = 0;
patient{cnt} = 'RCS02 L';
side{cnt} = 'L';
cnt = cnt+1;

dataFiles{cnt}  = '/Volumes/Samsung_T5/RCS02/RCS02_all_home_data_processed/data/RCS02R/processedData.mat';
psdrFiles{cnt}  = '/Volumes/Samsung_T5/RCS02/RCS02_all_home_data_processed/data/RCS02R/psdResults.mat';
dateChoose{cnt} = datetime('May 21 2019','Format','MMM dd yyyy');
peaks(cnt,:)  = [17 20];
channel(cnt) = 0;
patient{cnt} = 'RCS02 R';
side{cnt} = 'R';
cnt = cnt+1;

dataFiles{cnt}  = '/Volumes/RCS_DATA/RCS03/raw_data_push_jan_2020/SCBS/RCS03L/processedData.mat';
psdrFiles{cnt}  = '/Volumes/RCS_DATA/RCS03/raw_data_push_jan_2020/SCBS/RCS03L/psdResults.mat';
resultsdir = '/Volumes/RCS_DATA/RCS03/raw_data_push_jan_2020/SCBS/RCS03L/';
dateChoose{cnt} = datetime('May 21 2019','Format','MMM dd yyyy');
peaks(cnt,:)  = [17 20];
channel(cnt) = 0;
patient{cnt} = 'RCS03 L';
side{cnt} = 'L';
areaname = 'gpi';
cnt = cnt+1;
%% 

Fs = 250; % XXX note that this is hard coded. 

for d = 9:length(dataFiles)
    startall = tic; 
    startload = tic; 
    load(dataFiles{d});
    fprintf('file loaded in %.2f seconds \n',toc(startload));
    %% do fft but on sep recordings
    for i = 1:length( tdProcDat )
        for c = 1:4
            fn = sprintf('key%d',c-1);
            if size(tdProcDat(i).(fn),1) < size(tdProcDat(i).(fn),2)
                tdProcDat(i).(fn) = tdProcDat(i).(fn)';
            end
        end
    end
    
    if strcmp(areaname,'stn')
    pairname = {'STN 0-2','M1 8-10';...
        'STN 0-2','M1 9-11';...
        'STN 1-3','M1 8-10';...
        'STN 1-3','M1 9-11'};
    paircontact = [0 2;...
                   0 3;...
                   1 2;...
                   1 3];
    fieldnamesuse = {'stn02m10810','stn02m10911','stn13m10810','stn13m0911'};
    elseif strcmp(areaname,'gpi')
        x = 2;
%         0 +1-0 lpf1-450Hz lpf2-1700Hz sr-250Hz
%         1 +3-2 lpf1-450Hz lpf2-1700Hz sr-250Hz
%         2 +9-8 lpf1-450Hz lpf2-1700Hz sr-250Hz
%         3 +11-10 lpf1-450Hz lpf2-1700Hz sr-250Hz
        pairname = {'GPi 0-1','M1 8-9';...
                    'GPi 0-1','M1 10-11';...
                    'GPi 2-3','M1 8-9';...
                    'GPi 2-3','M1 10-11'};
        paircontact = [0 2;...
                       0 3;...
                       1 2;...
                       1 3];
        fieldnamesuse = {'gpi01m10809','gpi01m1011','gpi23m10809','gpi23m1011'};

    end
            
    
    for cc = 1:length(pairname)
        startchan = tic; 
        fnuse = sprintf('key%d',paircontact(cc,1));
        stndat = [tdProcDat.(fnuse)];
        
        fnuse = sprintf('key%d',paircontact(cc,2));
        m1dat = [tdProcDat.(fnuse)];
        
        start = tic; 
        [Cxy,F] = mscohere(stndat,m1dat,...
            2^(nextpow2(Fs)),...
            2^(nextpow2(Fs/2)),...
            2^(nextpow2(Fs)),...
            Fs);
        endtime = toc(start); 
        coherenceResultsTd.(fieldnamesuse{cc}) = Cxy; 
        clear Cxy
        fprintf('channel %d done in  %.2f seconds \n',cc,toc(startchan));
    end
    
    coherenceResultsTd.paircontact = paircontact;
    coherenceResultsTd.pairname = pairname;
    coherenceResultsTd.srate = Fs; 
    coherenceResultsTd.ff = F;
    coherenceResultsTd.timeStart = [tdProcDat.timeStart];
    coherenceResultsTd.timeEnd = [tdProcDat.timeEnd];
    
    metaData.dataFiles = dataFiles{d};
    metaData.patient   = patient{d}(1:5);
    metaData.side = side{d}; 

    patientSaveName = sprintf('coherenceResults_%s%s.mat',metaData.patient,metaData.side);
    save( fullfile(resultsdir,patientSaveName),'coherenceResultsTd','metaData'); 
    fprintf('patient %s side %s done in %.2f\n',toc(startall)); 
end

end