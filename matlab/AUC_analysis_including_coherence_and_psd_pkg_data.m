function AUC_analysis_including_coherence_and_psd_pkg_data()
% the original function that gets data for this is
% plot_pkg_data_all_subjects()
% and the subheading string to search for that generates the data is:
% get and plot coherence data and put it in one structure
% data is saved in:
% /Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home




% loop on patient, side to get AUC for each patient and minute
% gap
datadir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home';
resultsdir_AUC = datadir;
%% XXX
%             uniquePatients = {'RCS07'};
%% XXX
sides = {'L','R'};
uniquePatients = {'RCS02','RCS06','RCS05','RCS07'};
for p = 1:length(uniquePatients) % loop on patients
    for s = 1:2 % loop on side
        filenamesearch = sprintf('coherence_and_psd %s %s *.mat',uniquePatients{p},sides{s});
        ff = findFilesBVQX(datadir,filenamesearch);
        load(ff{1});
        %% get states and frequencies per patient
        % get specific frequenceis per patiet
        rawstates = allDataPkgRcsAcc.states';
        switch uniquePatients{p}
            case 'RCS02'
                % R
                cnls  =  [0  1  2  3  0  1  2  3  ];
                freqs =  [19 19 24 25 75 75 76 76];
                ttls  = {'STN beta','STN beta','M1 beta','M1 beta','STN gamma','STN gamma','M1 gamma','M1 gamma'};
                onidx = cellfun(@(x) any(strfind(x,'dyskinesia severe')),rawstates);
                offidx = cellfun(@(x) any(strfind(x,'off')),rawstates) | ...
                    cellfun(@(x) any(strfind(x,'on')),rawstates) | ...
                    cellfun(@(x) any(strfind(x,'tremor')),rawstates);
                sleeidx = cellfun(@(x) any(strfind(x,'sleep')),rawstates);
                allstates = rawstates;
                allstates(onidx) = {'on'};
                allstates(offidx) = {'off'};
                allstates(sleeidx) = {'sleep'};
                statesUse = {'off','on'};
            case 'RCS05'
                cnls  =  [0  1  2  3  0  1  2  3  ];
                freqs =  [27 27 27 27 61 61 61 61];
                ttls  = {'STN beta','STN beta','M1 beta','M1 beta','STN gamma','STN gamma','M1 gamma','M1 gamma'};
                onidx = cellfun(@(x) any(strfind(x,'dyskinesia')),rawstates) | ...
                    cellfun(@(x) any(strfind(x,'on')),rawstates);
                offidx = cellfun(@(x) any(strfind(x,'off')),rawstates) | ...
                    cellfun(@(x) any(strfind(x,'tremor')),rawstates);
                sleeidx = cellfun(@(x) any(strfind(x,'sleep')),rawstates);
                allstates = rawstates;
                allstates(onidx) = {'on'};
                allstates(offidx) = {'off'};
                allstates(sleeidx) = {'sleep'};
                statesUse = {'off','on'};
                
            case 'RCS06'
                cnls  =  [0  1  2  3  0  1  2  3  ];
                freqs =  [19 19 14 26 55 55 61 61];
                ttls  = {'STN beta','STN beta','M1 beta','M1 beta','STN gamma','STN gamma','M1 gamma','M1 gamma'};
                onidx = cellfun(@(x) any(strfind(x,'dyskinesia')),rawstates) | ...
                    cellfun(@(x) any(strfind(x,'on')),rawstates);
                offidx = cellfun(@(x) any(strfind(x,'off')),rawstates) | ...
                    cellfun(@(x) any(strfind(x,'tremor')),rawstates);
                sleeidx = cellfun(@(x) any(strfind(x,'sleep')),rawstates);
                allstates = rawstates;
                allstates(onidx) = {'on'};
                allstates(offidx) = {'off'};
                allstates(sleeidx) = {'sleep'};
                statesUse = {'off','on'};
                
            case 'RCS07'
                cnls  =  [0  1  2  3  0  1  2  3  ];
                freqs =  [19 20 21 24 76 79 80 80];
                ttls  = {'STN beta','STN beta','M1 beta','M1 beta','STN gamma','STN gamma','M1 gamma','M1 gamma'};
                onidx = cellfun(@(x) any(strfind(x,'dyskinesia')),rawstates) | ...
                    cellfun(@(x) any(strfind(x,'on')),rawstates);
                offidx = cellfun(@(x) any(strfind(x,'off')),rawstates) | ...
                    cellfun(@(x) any(strfind(x,'tremor')),rawstates);
                sleeidx = cellfun(@(x) any(strfind(x,'sleep')),rawstates);
                allstates = rawstates;
                allstates(onidx) = {'on'};
                allstates(offidx) = {'off'};
                allstates(sleeidx) = {'sleep'};
                statesUse = {'off','on'};
        end
        %% get all the data ready for both cohernece and for psd 
        % get the labels
        idxuse = strcmp(allstates,'off') | strcmp(allstates,'on');
        labelsRaw = allstates(idxuse);
        labels = zeros(size(labelsRaw,1),1);
        labels(strcmp(labelsRaw,'on')) = 1;
        

        % data psd 
        cntfeature = 1; 
        for c = 1:length(cnls)
            % get channel
            fn = sprintf('key%dfftOut',cnls(c));
            % get freq
            idxfreq = psdResults.ff >= freqs(c)-1 & psdResults.ff <= freqs(c)+1;
            rescaledat = rescale(mean(allDataPkgRcsAcc.(fn)(idxuse,idxfreq),2),0,1); 
            alldataUse(:,cntfeature) = rescaledat; 
            labelMeta{cntfeature,1}  = ttls{c}; 
            cntfeature = cntfeature + 1; 
        end
        meanbetafreq = mean(freqs(1:4)); 
        meangammafrq = mean(freqs(5:8)); 
        freqsloop    = [meanbetafreq meangammafrq]; 
        freqnames    = {'beta','gamma'}; 
        cohfieldnames = {'stn02m10810','stn02m10911','stn13m10810','stn13m0911'}; 
        for fc = 1:length(freqnames)
            for ac = 1:length(cohfieldnames)
                % get channel
                fn = sprintf('%s',cohfieldnames{ac});
                % get freq
                idxfreq = cohResults.ff >= freqsloop(fc)-2 & cohResults.ff <= freqsloop(fc)+2;
                rescaledat = rescale(mean(allDataPkgRcsAcc.(fn)(idxuse,idxfreq),2),0,1);
                alldataUse(:,cntfeature) = rescaledat;
                labelMeta{cntfeature,1}  = sprintf('STN-M1 coh %s',freqnames{fc});
                cntfeature = cntfeature + 1;
            end
        end
        
        
        %% fit the model
        
        %% loop on areas
        alldat = [];
        for c = 1:length(labelMeta)
            start = tic;
            % get channel
            dat = alldataUse(:,c);
            %% disc
            rng(1); % For reproducibility
            cvp = cvpartition(logical(labels),'Kfold',5,'stratify',logical(1));
            doshuffle = 1;
            if doshuffle
                numshuffls = 5e3;
            else
                numshuffls = 1;
            end
            for si =1:numshuffls+1
                for k = 1:5
                    idxTrn = training(cvp,k); % Training set indices
                    idxTest = test(cvp,k);    % Test set indices
                    tblTrn = array2table(dat(idxTrn,:));
                    tblTrn.Y = labels(idxTrn);
                    if doshuffle
                        if si > 1 % first is real
                            rng(si);
                            labs = labels(idxTrn);
                            idxshuffle = randperm(length(labs));
                            labs = labs(idxshuffle);
                            tblTrn.Y = labs;
                        end
                    end
                    Mdl = fitcdiscr(tblTrn,'Y');
                    [labeltest,scoretest,costest] = predict(Mdl,dat(idxTest,:));
                    if doshuffle
                        [X,Y,T,AUC(k,si),OPTROCPT] = perfcurve(logical(labels(idxTest)),scoretest(:,2),'true');
                    else
                        [X,Y,T,AUC(k),OPTROCPT] = perfcurve(logical(labels(idxTest)),scoretest(:,2),'true');
                    end
                end
            end
            if doshuffle
                realVal = mean(AUC(:,1));
                shufflevals = mean(AUC(:,2:end),1);
                AUCout(c) = realVal;
                sumsmaller = sum(realVal < mean(AUC(:,2:end),1));
                if sumsmaller == 0
                    pval = 1/numshuffls;
                else
                    pval = sumsmaller/numshuffls;
                end
                AUCpOut(c) = pval;
            else
                AUCout(c) = mean(AUC);
            end
            fprintf('[%0.2d/%0.2d] finished %s %s %s in %.2f\n',...
                    c, length(labelMeta)+1, uniquePatients{p},sides{s},labelMeta{c},toc(start));
        end
        %% use all areas
        for si =1:numshuffls+1
            for k = 1:5
                idxTrn = training(cvp,k); % Training set indices
                idxTest = test(cvp,k);    % Test set indices
                tblTrn = array2table(alldataUse(idxTrn,:));
                tblTrn.Y = labels(idxTrn);
                if doshuffle
                    if si > 1 % first is real
                        rng(si);
                        labs = labels(idxTrn);
                        idxshuffle = randperm(length(labs));
                        labs = labs(idxshuffle);
                        tblTrn.Y = labs;
                    end
                end
                Mdl = fitcdiscr(tblTrn,'Y');
                [labeltest,scoretest,costest] = predict(Mdl,alldataUse(idxTest,:));
                if doshuffle
                    [X,Y,T,AUC(k,si),OPTROCPT] = perfcurve(logical(labels(idxTest)),scoretest(:,2),'true');
                else
                    [X,Y,T,AUC(k),OPTROCPT] = perfcurve(logical(labels(idxTest)),scoretest(:,2),'true');
                end
            end
        end
        if doshuffle
            realVal = mean(AUC(:,1));
            shufflevals = mean(AUC(:,2:end),1);
            AUCout(c+1) = realVal;
            sumsmaller = sum(realVal < mean(AUC(:,2:end),1));
            if sumsmaller == 0
                pval = 1/numshuffls;
            else
                pval = sumsmaller/numshuffls;
            end
            AUCpOut(c+1) = pval;
        else
            AUCout(c+1) = mean(AUC);
        end
        fprintf('[%0.2d/%0.2d] finished %s %s %s in %.2f\n',...
            c+1, length(labelMeta)+1, uniquePatients{p},sides{s},'all areas',toc(start));
        %%
        labelMetaTitles = labelMeta;
        labelMetaTitles{17,1} = 'all areas';
        AUC_results_table = table(); 
        for r = 1:length(AUCout)
            AUC_results_table.patient{r} = uniquePatients{p};
            AUC_results_table.side{r} = sides{s};
            AUC_results_table.area{r} = labelMetaTitles{r}; 
            AUC_results_table.AUC(r) = AUCout(r); 
            AUC_results_table.AUCp(r) = AUCpOut(r);             
        end
        fnmmuse = sprintf('%s_%s_AUC_by_min_results_with_coherence.mat',uniquePatients{p},...
            sides{s});
        fnmsave = fullfile(resultsdir_AUC,fnmmuse);
        readme = {'AUC is a matrix with cnls and freqs being the columns used to train a linead disc analysis. the last column is all data combines (all areas'};
        save(fnmsave,'AUC_results_table','cnls','freqs','readme');
        clear alldataUse
        % save this patient data
    end
end



end