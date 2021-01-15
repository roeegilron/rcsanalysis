function plot_chronic_stim_daily_plots()
%% this function creates daily plot of chronic stimulation 
%% plots: 
%% 1. psds 
%% 2. spectral reprentation 
%% 3. spec. frequency by day / correlated with PKG graphs 
%% 4. confusion matrix of frequencies / rescaled / normalized 

% to recreate data that into this, steps:
% 1. create_sample_data_set_chronic_stim_vs_off_stim
% 2. open_save_spectral_data_new_algo
% 3. plot_chronic_stim_daily_plots (to plot) 

%% load database 
fnuse = '/Volumes/RCS_DATA/chronic_stim_vs_off/database/database_from_device_settings.mat';
load(fnuse);
%% 

%% find specific patients, and for each of these patietns, specific sides and days 
% the output strucutre is such: 
% where each side of 'spectralPatient' is one side 
% and within spectral patietn itself - you have unique days. 

% spectralPatient(s).outSpectral = outSpectral;
% spectralPatient(s).tblSide = tblSide;

unqPatients = unique(masterTableLightOut.patient);
unqPatients = unqPatients(2:end); % XXXX 
for p = 1:length(unqPatients)
    % find unique days for this patient. 
    idxpat = cellfun(@(x) any(strfind(x,unqPatients{p})),masterTableLightOut.patient);
    dbPat  = masterTableLightOut(idxpat,:);
    tabDates = table();
    [tabDates.y,tabDates.m,tabDates.d] = ymd(dbPat.timeStart);
    unqDates = unique(tabDates,'rows');
    for d = 1:size(unqDates,1) % loop on dates 
        idxDates = (tabDates.y == unqDates.y(d)) &  ... 
                   (tabDates.m == unqDates.m(d)) &  ... 
                   (tabDates.d == unqDates.d(d));
        dbDates = dbPat(idxDates,:);
        unqSides = unique(dbDates.side);
        % init struct 
        spectralPatient = struct();
        for s = 1:length(unqSides) % loop on sides 
            idxside = cellfun(@(x) any(strfind(x,unqSides{s})),dbDates.side);
            dbSide = dbDates(idxside,:);
            % init variables
            cntSide = 1;
            for fs = 1:size(dbSide,1) % look for data in each side, put it the right structure 
                % get the folder to look into: 
                [pn,fn] = fileparts(dbSide.deviceSettingsFn{fs}); 
                fileLoad = fullfile(pn,'combinedDataTable.mat');
                if exist(fileLoad,'file')
                    % find the patient
                    % find the unique days
                    % within each unique days, find data that is opened (combined meta
                    % data) and concatanate this data
                    %         idxuse =  & ...
                    %             cellfun(@(x)
                    %             any(strfind(x,unqPatients{p})),masterTableLightOut.patient);
                    variableInfo = who('-file', fileLoad);
                    if sum(cellfun(@(x) any(strfind(x,'outSpectral')),variableInfo))>0
                        load(fileLoad,'outSpectral');
                        skipPlot = 1;
                        if ~isempty(outSpectral)
                            fnmsSpectral = fieldnames(outSpectral);
                            for ff = 1:length(fnmsSpectral)
                                spectralPatient(fs).outSpectral.(fnmsSpectral{ff}){cntSide} = outSpectral(fnmsSpectral{ff}){1};
                            end
                            spectralPatient(fs).tblSide(cntSide) = dbSide(fs,:);
                            cntSide = cntSide +1;
                        end
                    end
                end
            end
        end % end loop on sides 
        x = 2;
    end
end


%% 

end