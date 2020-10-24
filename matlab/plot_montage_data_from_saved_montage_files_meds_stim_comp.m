function plot_montage_data_from_saved_montage_files_meds_stim_comp(dirname)
% you need to run this function first:
% open_and_save_montage_data_in_sessions_directory
resdir = '/Users/roee/Box/Starr_Lab_Folder/Data_Analysis/RCS_data/results/stim_titrations_2/results';
ff = findFilesBVQX(dirname,'rawMontageData.mat');
figdir = fullfile(dirname,'figures');
mkdir(figdir);
% do you want to adjust the motnage idx's manually
adjustMontageIdxManually = 1;
if adjustMontageIdxManually
end
extractAllData = 0; % if zero just load data from results folder, otherwise load each patient
if extractAllData
    allDataPerPatient = table();
    cntData = 1;
    for f = 1:length(ff)
        load(ff{f});
        
        if exist('montagDataRawManualIdxs','var')
            montageDataRaw = montagDataRawManualIdxs;
            montageDataHasBeenAdjusted = 1;
        else
            montageDataHasBeenAdjusted = 0;
        end
        clear montagDataRawManualIdxs;
        [pn,fn] = fileparts(ff{f});
        dsFileName = fullfile(pn,'DeviceSettings.json');
        ds = get_meta_data_from_device_settings_file(dsFileName);
        % loop on montage data found, and if it's a valid montage (default size
        % is 13 session in our standard montage)
        % then save it in a data structure;
        % allp atients should have 4 montages that daay:
        % on/off mesd and on stim / "off stim (stim on at 0mA)
        
        if size(montageDataRaw,1) >= 13
            %     plot_data_per_recording(montageDataRaw,figdir,ff{f});
            %     plot_pac_montage_data_within(montageData,figdir,ff{f});
            [pn,fn] = fileparts(ff{f});
            allDataPerPatient.patient{cntData} = ds.patient{1};
            allDataPerPatient.side{cntData} = ds.side{1};
            allDataPerPatient.timeStart(cntData) = ds.timeStart(1);
            
            ss = ds.stimStatus{1};
            allDataPerPatient.group(cntData) = ss.group(1);
            allDataPerPatient.electrodes{cntData} = ss.electrodes{1};
            allDataPerPatient.amplitude_mA{cntData} = ss.amplitude_mA(1);
            allDataPerPatient.rate_Hz(cntData) = ss.rate_Hz(1);
            allDataPerPatient.active_recharge(cntData) = ss.active_recharge(1);
            allDataPerPatient.mode{cntData} = ds.senseSettings{1}.TelmMode{1};
            allDataPerPatient.ratio(cntData) = ds.senseSettings{1}.TelmRatio(1);
            % store the actual data
            allDataPerPatient.montageDataRaw{cntData} = montageDataRaw;
            allDataPerPatient.DataFolder{cntData} = pn;
            allDataPerPatient.montageDataHasBeenAdjusted(cntData) = montageDataHasBeenAdjusted;
            cntData = cntData + 1;
        end
        
        %     plot_montage_data(pn);
        %     rcsDataChopper(pn);
    end
    filesave = fullfile(resdir,'montage_results_all_subjects.mat');
    save(filesave);
else
    filesave = fullfile(resdir,'montage_results_all_subjects.mat');
    load(filesave);
    
end
% only use tables that have active recharged

% allDataPerPatient = allDataPerPatient(logical(allDataPerPatient.active_recharge),:);

% now adjust each file manually if it hasen't been adjust before
% XXX need to fix manual adjustment here that is not workign well
for a = 1:size(allDataPerPatient,1)
    if ~logical(allDataPerPatient.montageDataHasBeenAdjusted)
        %         adjustMontageIdxs( allDataPerPatient.DataFolder{a} );
    end
end


%% plot psd on a per patient  basis - 500Hz, stim aware
plotPsds = 0;
if plotPsds
    uniqePatients = unique(allDataPerPatient.patient);
    uniqueSides = unique(allDataPerPatient.side);
    addpath(genpath(fullfile(pwd,'toolboxes','panel-2.14')));
    
    for p = 1:size(uniqePatients,1) % loop on patients
        for s = 1:size(uniqueSides,1) % loop on sides
            idxPatAnDSise = strcmp(allDataPerPatient.patient,uniqePatients{p}) & ...
                strcmp(allDataPerPatient.side,uniqueSides{s});
            dbPat = allDataPerPatient(idxPatAnDSise,:);
            % setup figure
            hfig = figure('Visible','on');
            hfig.Color = 'w';
            hfig.Position = [1000         547        1020         791];
            hpanel = panel();
            hpanel.pack(5,4);
            cntrow = 1;
            switch str2num(dbPat.electrodes{1}(2))
                case 1 % stim 1
                    coluse(cntrow)  = 1;
                    rowuse(cntrow) = 2;
                    stncol = 1;
                    titleUse{cntrow} = '+0-2';
                    
                case 2
                    coluse(cntrow)  = 2;
                    rowuse(cntrow) = 2;
                    stncol = 2;
                    titleUse{cntrow} = '+1-3';
            end
            % get the other labels
            % and also specific coherence pairs that go with it
            
            % 8-10
            cntrow = cntrow + 1;
            rowuse(cntrow) = 2;
            coluse(cntrow) = 3;
            titleUse{cntrow} = '+8-10';
            % 9-11
            cntrow = cntrow + 1;
            rowuse(cntrow) = 2;
            coluse(cntrow) = 4;
            titleUse{cntrow} = '+9-11';
            % 8-9
            cntrow = cntrow + 1;
            rowuse(cntrow) = 1;
            coluse(cntrow) = 3;
            titleUse{cntrow} = '+8-9';
            % 10-11
            cntrow = cntrow + 1;
            rowuse(cntrow) = 1;
            coluse(cntrow) = 4;
            titleUse{cntrow} = '+10-11';
            
            
            % get colors assigned
            for d = 1:size(dbPat,1)
                if d <= 2
                    dbPat.medState{d} = 'off meds';
                    dbPat.ColrUser{d} = [0.8 0 0];
                end
                if d >2
                    dbPat.medState{d} = 'on meds';
                    dbPat.ColrUser{d} = [0 0.8 0];
                end
                if dbPat.amplitude_mA{d}~=0
                    dbPat.LineStyle{d} = '-.';
                else
                    dbPat.LineStyle{d} = '-';
                end
            end
            % find relevant stn electrodes and plot raw data + psds
            for ar = 1:size(rowuse,2) % loop on area
                scaleLevels = [0 0.5];
                for r = 1:size(dbPat,1)
                    % plot raw data
                    montageDataRaw = dbPat.montageDataRaw{r};
                    rawdata = montageDataRaw.data{rowuse(ar)}(:,coluse(ar));
                    t = montageDataRaw.derivedTimes{rowuse(ar)};
                    % trim first 5 seconds
                    
                    if isduration(t)
                        t = seconds(t);
                    end
                    idxkeep = t>=5 & t<40;
                    t = t(idxkeep);
                    rawdata = rawdata(idxkeep);
                    
                    hsb = hpanel(ar,1).select();
                    hold(hsb,'on');
                    axes(hsb);
                    rawDataRescaled = rescale(rawdata,scaleLevels(1),scaleLevels(2));
                    scaleLevels = scaleLevels + 0.5;
                    plot(hsb,t,rawDataRescaled,...
                        'Color',[dbPat.ColrUser{r} 0.2],...
                        'LineStyle',dbPat.LineStyle{r});
                    title([titleUse{ar} ' raw data']);
                    % plot psd
                    hsb = hpanel(ar,2).select();
                    hold(hsb,'on');
                    axes(hsb);
                    rawdata = rawdata - mean(rawdata);
                    y = rawdata;
                    sr = montageDataRaw.samplingRate(rowuse(ar));
                    [fftOut,f]   = pwelch(y,sr,sr/2,2:1:(sr/2 - 50),sr,'psd');
                    plotFreqPatches(hsb);
                    plot(f,log10(fftOut),...
                        'LineWidth',2,...
                        'Color',[dbPat.ColrUser{r} 0.7],...
                        'LineStyle',dbPat.LineStyle{r});
                    xlabel('Freq (Hz)');
                    ylabel('Power (log_1_0\muV^2/Hz)');
                    title([titleUse{ar} ' PSD']);
                    xlim([3 100]);
                    % plot psd stim artifact
                    hsb = hpanel(ar,3).select();
                    hold(hsb,'on');
                    axes(hsb);
                    plotFreqPatches(hsb);
                    plot(f,log10(fftOut),...
                        'LineWidth',2,...
                        'Color',[dbPat.ColrUser{r} 0.7],...
                        'LineStyle',dbPat.LineStyle{r});
                    xlabel('Freq (Hz)');
                    ylabel('Power (log_1_0\muV^2/Hz)');
                    title([titleUse{ar} ' PSD']);
                    xlim([120 140]);
                    
                    % coherence
                    if ar >=2
                        hsb = hpanel(ar,4).select();
                        hold(hsb,'on');
                        axes(hsb);
                        montageDataRaw = dbPat.montageDataRaw{r};
                        rawdatactx = montageDataRaw.data{rowuse(ar)}(:,coluse(ar)); % ctx  data
                        rawdatastn = montageDataRaw.data{rowuse(ar)}(:,stncol); %  stn data
                        if length(rawdatactx) < (40*sr)
                            rawdatactx = rawdatactx(5*sr : end);
                            rawdatastn = rawdatastn(5*sr : end);
                        else
                            rawdatactx = rawdatactx(5*sr : 40*sr);
                            rawdatastn = rawdatastn(5*sr : 40*sr);
                        end
                        [Cxy,F] = mscohere(rawdatactx',rawdatastn',...
                            2^(nextpow2(sr)),...
                            2^(nextpow2(sr/2)),...
                            2^(nextpow2(sr)),...
                            sr);
                        
                        idxplot = F > 2 & F < 100;
                        
                        plotFreqPatches(hsb);
                        plot(F(idxplot),Cxy(idxplot),...
                            'LineWidth',2,...
                            'Color',[dbPat.ColrUser{r} 0.7],...
                            'LineStyle',dbPat.LineStyle{r});
                        
                        xlabel('Freq (Hz)');
                        ylabel('MS Coherence');
                        ttluse = sprintf('%s-%s coh',titleUse{1},titleUse{ar});
                        title(ttluse);
                        
                        
                    end
                end
            end
            hpanel.de.margin = 20;
            
            % plot meta data
            clear metaData
            maxamp = max(cell2mat(dbPat.amplitude_mA));
            metaData{3,1} = sprintf('%s %s', uniqePatients{p},uniqueSides{s});
            metaData{2,1} = sprintf('stim elec %s',dbPat.electrodes{1});
            metaData{1,1} = sprintf('group %s %.2f(mA) %.2f(Hz)',dbPat.group(1),maxamp,dbPat.rate_Hz(1));
            hsb = hpanel(1,4).select();
            axes(hsb);
            hold(hsb,'on');
            for i = 1:3
                text(0,i,metaData{i,1},'FontSize',15);
            end
            ylim([1 5]);
            box(hsb,'off');
            set(hsb, 'box','off','XTickLabel',[],'XTick',[],'YTickLabel',[],'YTick',[])
            set(hsb,'XColor','none')
            set(hsb,'YColor','none')
            
            % save data
            hpanel.fontsize = 10;  % global font
            hpanel.de.margin = 15;
            hpanel.marginleft =  20;
            hpanel.marginright =  20;
            hpanel.margintop =  10;
            hpanel.marginbottom =  10;
            hfig.PaperPositionMode = 'manual';
            prfig.plotwidth           = 12;
            prfig.plotheight          = 9;
            prfig.figdir             = figdir;
            figname = sprintf('%s_%s_all_montage_compare',uniqePatients{p},uniqueSides{s});
            prfig.figname             = figname;
            prfig.figtype             = '-dpdf';
            plot_hfig(hfig,prfig)
            close(hfig);
        end
    end
end
%%

%% plot PAC from close contacts at 1000Hz on/off stim on/ off meds
uniqePatients = unique(allDataPerPatient.patient);
uniqueSides = unique(allDataPerPatient.side);
addpath(genpath(fullfile(pwd,'toolboxes','panel-2.14')));

for p = 3:size(uniqePatients,1) % loop on patients
    for s = 1:size(uniqueSides,1) % loop on sides
        idxPatAnDSise = strcmp(allDataPerPatient.patient,uniqePatients{p}) & ...
            strcmp(allDataPerPatient.side,uniqueSides{s});
        dbPat = allDataPerPatient(idxPatAnDSise,:);
        % setup figure
        hfig = figure('Visible','on');
        hfig.Color = 'w';
        hfig.Position = [1000         547        1020         791];
        hpanel = panel();
        hpanel.pack(3,4);
        cntrow = 1;
        
        cntrow = 0;
        % 8-9
        cntrow = cntrow + 1;
        rowuse(cntrow) = 12;
        coluse(cntrow) = 3;
        titleUse{cntrow} = '-8+9';
        % 10-11
        cntrow = cntrow + 1;
        rowuse(cntrow) = 13;
        coluse(cntrow) = 3;
        titleUse{cntrow} = '-10+11';
        % 9-10
        cntrow = cntrow + 1;
        rowuse(cntrow) = 8;
        coluse(cntrow) = 3;
        titleUse{cntrow} = '-9+10';
        if strcmp(dbPat.patient{1},'RCS05') & strcmp(dbPat.side{1},'L')
            dbPat = dbPat([1 3:5],:);
        end
        
        % get colors assigned
        for d = 1:size(dbPat,1)
            if d <= 2
                dbPat.medState{d} = 'off meds';
                dbPat.ColrUser{d} = [0.8 0 0];
            end
            if d >2
                dbPat.medState{d} = 'on meds';
                dbPat.ColrUser{d} = [0 0.8 0];
            end
        end
        

        % find relevant stn electrodes and plot raw data + psds
        for ar = 1:size(rowuse,2) % loop on area
            for r = 1:size(dbPat,1) % loop on mmotnage data
                
                
                % plot raw data
                montageDataRaw = dbPat.montageDataRaw{r};
                % only keep data that is under 1 minte (get rid of last file)
                if size(montageDataRaw,1) >= 14
                    idxkeep = montageDataRaw.duration < seconds(60);
                    montageDataRaw = montageDataRaw(idxkeep,:);
                end
                
                rawdata = montageDataRaw.data{rowuse(ar)}(:,coluse(ar));
                t = montageDataRaw.derivedTimes{rowuse(ar)};
                % trim first 5 seconds
                if isduration(t)
                    t = seconds(t);
                end
                idxkeep = t>=5 & t<40;
                t = t(idxkeep);
                rawdata = rawdata(idxkeep);    
                % pac
                pacparams.PhaseFreqVector      = 5:2:50;
                pacparams.AmpFreqVector        = 10:5:400;
                
                pacparams.PhaseFreq_BandWidth  = 4;
                pacparams.AmpFreq_BandWidth    = 10;
                pacparams.computeSurrogates    = 0;
                pacparams.numsurrogate         = 0;
                pacparams.alphause             = 0.05;
                pacparams.plotdata             = 0;
                pacparams.useparfor            = 0; % if true, user parfor, requires parallel computing toolbox
                sr = 1000;
                addpath(genpath(fullfile('..','..','PAC')));
                if sr == 250
                    pacparams.AmpFreqVector        = 10:5:80;
                elseif sr == 500
                    pacparams.AmpFreqVector        = 10:5:200;
                elseif sr == 1000
                    pacparams.AmpFreqVector        = 10:5:420;
                end
                y = rawdata;
                y = y - mean(y);
                hsb = hpanel(ar,r).select();
                axes(hsb);
                if sum(y) ~= 0
                    res = computePAC(y',sr,pacparams);
                    
                    contourf(res.PhaseFreqVector+res.PhaseFreq_BandWidth/2,...
                        res.AmpFreqVector+res.AmpFreq_BandWidth/2,...
                        res.Comodulogram',30,'lines','none')
                    shading interp
                    ttly = sprintf('Amplitude Frequency %s (Hz)',titleUse{ar});
                    ylabel(ttly)
                    ttlx = sprintf('Phase Frequency %s (Hz)',titleUse{ar});
                    xlabel(ttlx)
                    ttlstr{1,1} = sprintf('PAC %s',titleUse{ar});
                    ttlstr{1,2} = sprintf('%s %.2fmA',dbPat.medState{r},dbPat.amplitude_mA{r});
                    title(ttlstr);
                    set(gca,'FontSize',10);
                end
            end
        end
        % plot figure 
        % save data
        hpanel.fontsize = 9;  % global font
        hpanel.de.margin = 20;
        hpanel.marginleft =  20;
        hpanel.marginright =  20;
        hpanel.margintop =  10;
        hpanel.marginbottom =  10;
        hfig.PaperPositionMode = 'manual';
        prfig.plotwidth           = 12;
        prfig.plotheight          = 11;
        prfig.figdir             = figdir;
        figname = sprintf('%s_%s_PAC-results_mc',uniqePatients{p},uniqueSides{s});
        prfig.figname             = figname;
        prfig.figtype             = '-dpdf';
        plot_hfig(hfig,prfig)
        close(hfig);

    end
end
%%
end

function plot_data_per_recording(montageData,figdir,origfile)
addpath(genpath(fullfile(pwd,'toolboxes','panel-2.14')));
for i = 1:size(montageData,1)
    hfig = figure('Visible','on');
    hfig.Color = 'w';
    hfig.Position = [1000         547        1020         791];
    hpanel = panel();
    hpanel.pack(4,5);
    % raw data
    % check min number of samples, and flag if a lot of packet loss
    % default is that this recording is "good"
    badMontageRec = 0;
    
    x = montageData.derivedTimes{i};
    numberOfSamples = length(x);
    % max 10% of samples lost
    dur = x(end) - x(1);
    numberExpectedSamples = seconds(dur) * montageData.samplingRate(i);
    if (numberExpectedSamples / numberOfSamples) < 0.9
        warning('number of expected samples below 90%, problem with this montage');
        badMontageRec = 1;
    end
    % check if there is a gap in this data selection is larger than 10 * 1/smaple rate - which is too much
    if max(diff(seconds(x))) > (1/ montageData.samplingRate(i))*100
        badMontageRec = 1;
    end
    if ~badMontageRec
        if isduration(x)
            idxuse = x > seconds(3) & x < (x(end)-seconds(3));
        else
            idxuse = (x > 3) & x < (x(end)-3);
        end
        x = x(idxuse);
        x = x - x(1);
        sr = montageData.samplingRate(i);
        ydat = montageData.data{i};
        ydat = ydat(idxuse,:);
        for c = 1:4
            hsb = hpanel(c,1).select();
            axes(hsb);
            y = ydat(:,c);
            y = y - mean(y);
            plot(x,y);
            xlabel('Time');
            ylabel('uV');
            if isduration(x)
                xtickformat('mm:ss');
            end
            chanchar = montageData.TimeDomainDataStruc{i}(c).chanOut;
            ttlstr = sprintf('raw %s',chanchar);
            title(ttlstr);
        end
        % spectrogram
        for c = 1:4
            hsb = hpanel(c,2).select();
            axes(hsb);
            y = ydat(:,c);
            y = y - mean(y);
            if sum(y) ~= 0
                srate = sr;
                overlapFac = 0.875;
                spectrogram(y,srate,ceil(overlapFac*srate),1:ceil(srate/2-20),srate,'yaxis','psd');
                shading interp
                axis tight;
                colorbar off;
                chanchar = montageData.TimeDomainDataStruc{i}(c).chanOut;
                ttlstr = sprintf('Spect %s',chanchar);
                title(ttlstr);
            end
        end
        % psd
        for c = 1:4
            hsb = hpanel(c,3).select();
            axes(hsb);
            hold on;
            y = ydat(:,c);
            y = y - mean(y);
            if sum(y) ~= 0
                [fftOut,f]   = pwelch(y,sr,sr/2,2:1:(sr/2 - 50),sr,'psd');
                plotFreqPatches(hsb);
                plot(f,log10(fftOut),'LineWidth',2);
                xlabel('Freq (Hz)');
                ylabel('Power (log_1_0\muV^2/Hz)');
                chanchar = montageData.TimeDomainDataStruc{i}(c).chanOut;
                ttlstr = sprintf('PSD %s',chanchar);
                title(ttlstr);
                
            end
        end
        % pac
        pacparams.PhaseFreqVector      = 5:2:50;
        pacparams.AmpFreqVector        = 10:5:400;
        
        pacparams.PhaseFreq_BandWidth  = 4;
        pacparams.AmpFreq_BandWidth    = 10;
        pacparams.computeSurrogates    = 0;
        pacparams.numsurrogate         = 0;
        pacparams.alphause             = 0.05;
        pacparams.plotdata             = 0;
        pacparams.useparfor            = 0; % if true, user parfor, requires parallel computing toolbox
        pacparams.regionnames          = {'STN','M1'};
        
        addpath(genpath(fullfile('..','..','PAC')));
        if sr == 250
            pacparams.AmpFreqVector        = 10:5:80;
        elseif sr == 500
            pacparams.AmpFreqVector        = 10:5:200;
        elseif sr == 1000
            pacparams.AmpFreqVector        = 10:5:420;
        end
        for c = 1:4
            hsb = hpanel(c,4).select();
            axes(hsb);
            hold on;
            y = ydat(:,c);
            y = y - mean(y);
            if sum(y) ~= 0
                res = computePAC(y',sr,pacparams);
                chanchar = montageData.TimeDomainDataStruc{i}(c).chanOut;
                areasAmp = sprintf('%s',chanchar);
                areasPhase = sprintf('%s',chanchar);
                
                contourf(res.PhaseFreqVector+res.PhaseFreq_BandWidth/2,...
                    res.AmpFreqVector+res.AmpFreq_BandWidth/2,...
                    res.Comodulogram',30,'lines','none')
                shading interp
                ttly = sprintf('Amplitude Frequency %s (Hz)',areasAmp);
                ylabel(ttly)
                ttlx = sprintf('Phase Frequency %s (Hz)',areasPhase);
                xlabel(ttlx)
                ttlstr = sprintf('PAC %s',chanchar);
                title(ttlstr);
                set(gca,'FontSize',10);
            end
        end
        % coherence
        % pairs:
        if sr == 1000
            reps = 2;
        else
            reps = 1;
        end
        for r = 1:reps
            if sr == 1000
                copairs = [1 3; 1 3];
            else
                copairs = [1 3; 1 4; 2 3; 2 4];
            end
            for c = 1:size(copairs,1)
                if sr == 1000
                    hsb = hpanel(r,5).select();
                else
                    hsb = hpanel(c,5).select();
                end
                axes(hsb);
                hold on;
                y1 = ydat(:,copairs(c,1));
                y2 = ydat(:,copairs(c,2));
                if (sum(y1) ~= 0) & (sum(y2) ~= 0)
                    pair1 = montageData.TimeDomainDataStruc{i}(copairs(c,1)).chanOut;
                    pair2 = montageData.TimeDomainDataStruc{i}(copairs(c,2)).chanOut;
                    ttlstr = sprintf('%s - %s coh',pair1, pair2);
                    Fs = sr;
                    [Cxy,F] = mscohere(y1',y2',...
                        2^(nextpow2(Fs)),...
                        2^(nextpow2(Fs/2)),...
                        2^(nextpow2(Fs)),...
                        Fs);
                    if r == 2
                        idxplot = F > 100 & F < 400;
                    else
                        idxplot = F > 2 & F < 100;
                    end
                    hplot = plot(F(idxplot),Cxy(idxplot),'LineWidth',2);
                    xlabel('Freq (Hz)');
                    ylabel('MS Coherence');
                    title(ttlstr);
                end
            end
        end
        timeStart = datetime(montageData.startTime(i),'Format','HH:mm');
        fntitle = sprintf('%0.2d %s %s %s',i,montageData.patient{i},montageData.side{i},timeStart);
        %     sgtitle(fntitle)
        
        hpanel.margin = [20 20 20 20];
        hpanel.fontsize = 13;
        hpanel.de.margin = 20;
        % print the figure
        timeStart = datetime(montageData.startTime(i),'Format','dd-MMM-yyyy_HH-mm');
        fnsave = sprintf('%s_%s_%s_%0.2d',montageData.patient{i},montageData.side{i},timeStart,i);
        prfig.plotwidth           = 20;
        prfig.plotheight          = 15;
        prfig.figdir              = figdir;
        prfig.figtype             = '-djpeg';
        prfig.closeafterprint     = 0;
        prfig.resolution          = 100;
        prfig.figname             = fnsave;
        plot_hfig(hfig,prfig);
        close all;
    end
end





end

function plot_pac_montage_data_within(montageData,figdir,origfile)
close all;
addpath(genpath(fullfile('..','..','PAC')));
timeStart = datetime(montageData.startTime(1),'Format','dd-MMM-yyyy_HH-mm');
fnsave = sprintf('%s_%s_%s',montageData.patient,montageData.side,timeStart);
timeStart = datetime(montageData.startTime(1),'Format','dd-MMM-yyyy HH:mm');
titleName = sprintf('%s %s %s',montageData.patient,montageData.side,timeStart);

pacparams.PhaseFreqVector      = 5:2:50;
pacparams.AmpFreqVector        = 10:5:400;

pacparams.PhaseFreq_BandWidth  = 4;
pacparams.AmpFreq_BandWidth    = 10;
pacparams.computeSurrogates    = 0;
pacparams.numsurrogate         = 0;
pacparams.alphause             = 0.05;
pacparams.plotdata             = 0;
pacparams.useparfor            = 0; % if true, user parfor, requires parallel computing toolbox
pacparams.regionnames          = {'STN','M1'};


cntplt = 1;
if length(montageData.M1) == 8
    % 12 PAC plots
    ncols  = 5;
    nrows  = 4;
elseif length(montageData.M1) == 6
    ncols  = 3;
    nrows  = 4;
elseif length(montageData.M1) == 7
    % 14 PAC plots
    ncols  = 4;
    nrows  = 4;
elseif length(montageData.M1) == 12
    % 14 PAC plots
    ncols  = 6;
    nrows  = 4;
else
    ncols  = 4;
    nrows  = 4;
end
needToSavePacResults = 1;
listOfVariables = who('-file', origfile);
if ismember('pac_results', listOfVariables)
    load(origfile,'pac_results');
    needToSavePacResults = 0;
end
load(origfile,'pac_results')



fldnms = {'LFP','M1'};
hfig = figure;
for a = 1:2 % loop on area
    for n = 1:length(montageData.(fldnms{a}))
        subplot(nrows,ncols,cntplt); cntplt = cntplt + 1;
        dat = montageData.(fldnms{a})(n);
        if dat.sr == 250
            pacparams.AmpFreqVector        = 10:5:80;
        elseif dat.sr == 500
            pacparams.AmpFreqVector        = 10:5:200;
        elseif dat.sr == 1000
            pacparams.AmpFreqVector        = 10:5:420;
        end
        if needToSavePacResults
            res = computePAC(dat.rawdata',dat.sr,pacparams);
            pac_results(n).(fldnms{a}) = res;
        else
            res = pac_results(n).(fldnms{a});
        end
        % pac plot
        areasAmp = sprintf('%s %s',dat.chan,fldnms{a});
        areasPhase = sprintf('%s %s',dat.chan,fldnms{a});
        contourf(res.PhaseFreqVector+res.PhaseFreq_BandWidth/2,...
            res.AmpFreqVector+res.AmpFreq_BandWidth/2,...
            res.Comodulogram',30,'lines','none')
        shading interp
        ttly = sprintf('Amplitude Frequency %s (Hz)',areasAmp);
        ylabel(ttly)
        ttlx = sprintf('Phase Frequency %s (Hz)',areasPhase);
        xlabel(ttlx)
        ttlstr = sprintf('%s %dHz',areasPhase,dat.sr);
        title(ttlstr);
        set(gca,'FontSize',18);
    end
end
save(origfile,'pac_results','-append');
sgtitle(titleName,'FontSize',30);
hfig.Color = 'w';

prfig.plotwidth           = 30;
prfig.plotheight          = 30;
prfig.figdir              = figdir;
prfig.figtype             = '-djpeg';
prfig.closeafterprint     = 0;
prfig.resolution          = 300;
prfig.figname             = fnsave;
plot_hfig(hfig,prfig);
close all;

end



function plot_coherence_montage_data(montageData,figdir,origfile)
results = [];
% set up subplots
app.hfig = figure;
hsub(1) = subplot(2,3,1,'Parent',app.hfig);
hsub(2) = subplot(2,3,4,'Parent',app.hfig);
hsub(3) = subplot(2,3,2,'Parent',app.hfig);
hsub(4) = subplot(2,3,5,'Parent',app.hfig);
hsub(5) = subplot(2,3,3,'Parent',app.hfig);
hsub(6) = subplot(2,3,6,'Parent',app.hfig);
app.hsubCoherence = gobjects(6,1);
for i = 1:6
    app.hsubCoherence(i) = hsub(i);
end

cnPairs = [1 2;... % stn stn
    3 4;... % m1 m1
    1 3;... % m1 m1
    1 4;...
    2 3;...
    2 4];
idxMontage = find(strcmp(app.hCoherenceMontageSelecor.Value,app.hCoherenceMontageSelecor.Items)==1);

outdatcomplete = app.(sprintf('outDataChunks%d',idxMontage));
outRec = app.outRec(idxMontage);
times = outdatcomplete.derivedTimes;
srate = unique( outdatcomplete.samplerate );
nmplt = 1;
i = 1;
for c = 1:size(cnPairs,1)
    axes(hsub(c));
    hold on;
    % first channel
    cIdx1 = cnPairs(c,1);
    fnm = sprintf('key%d',cIdx1-1);
    y1 = outdatcomplete.(fnm);
    y1 = y1 - mean(y1);
    
    cIdx2 = cnPairs(c,2);
    fnm = sprintf('key%d',cIdx2-1);
    y2 = outdatcomplete.(fnm);
    y2 = y2 - mean(y2);
    
    %% plot cohenece
    Fs = unique(outdatcomplete.samplerate);
    [Cxy,F] = mscohere(y1',y2',...
        2^(nextpow2(Fs)),...
        2^(nextpow2(Fs/2)),...
        2^(nextpow2(Fs)),...
        Fs);
    idxplot = F > 0 & F < 100;
    hplot = plot(F(idxplot),Cxy(idxplot),'Parent',hsub(c));
    xlabel(hsub(c),'Freq (Hz)');
    ylabel(hsub(c),'MS Coherence');
    
    xlim([0 100]);
    ttlGraph = sprintf('C between %s and %s',...
        outRec(1).tdData(cIdx1).chanOut,...
        outRec(1).tdData(cIdx2).chanOut);
    set(hsub(c),'FontSize',10);
    
    title(hsub(c),ttlGraph,'FontSize',10);
    clear y1 y2 cIdx1 cIdx2;
    ylims(c,:) = hsub(c).YLim;
    nmplt = nmplt + 1;
end
ylimsUse = [min(ylims(:,1)) max(ylims(:,2))];
for c = 1:6
    set(hsub(c),'Ylim',ylimsUse);
end

end