function plot_chopped_data_comparisons()
close all;
clc;
dirname = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/in_clinic/rest';
params.figdir  = dirname;
params.figtype = '-djpeg';
params.resolution = 300;
params.closeafterprint = 0;
params.figname = 'on_off_meds_all_patients';
params.plotwidth = 25;
params.plotheight = 25;

ff = findFilesBVQX(dirname,'*.mat');
patients = {'RCS01','RCS02','RCS05','RCS07'};
types    = {'rest_off_meds','rest_on_meds'};
typeLeg  = {'off meds','on meds'};
colorsUse   = [0.8 0 0 0.5; 0 0.8 0 0.5];
ttls   = {'STN 0-1','STN 1-3','M1 8-10','M1 9-11'};
cnsUsePerPatient = [1 , 3  ;...
    2 , 4  ;...
    2 , 4  ;...
    2 , 4];
% create figure;
hfig = figure;
cnt = 1;
for p = 1:length(patients)
    for c = 1:4
        hsub(p,c) = subplot(length(patients),4,cnt);
        hold on;
        cnt = cnt + 1;
    end
end

%% plot evetything
plotthis = 0;
if plotthis
    for p = 1:length(patients)
        for t = 1:length(types)
            idxUse = (cellfun(@(x) any(strfind(x,patients{p})),ff) & ...
                cellfun(@(x) any(strfind(x,types{t})),ff) ) ;
            idxLoad = find(idxUse ==1);
            load(ff{idxLoad});
            outdatcomplete = outdatachunk;
            times = outdatcomplete.derivedTimes;
            srate = unique( outdatcomplete.samplerate );
            for c = 1:4
                
                fnm = sprintf('key%d',c-1);
                y = outdatcomplete.(fnm);
                y = y - mean(y);
                [fftOut,f]   = pwelch(y,srate,srate/2,0:1:srate/2,srate,'psd');
                
                hplt(p,t,c) = plot(hsub(p,c),f,log10(fftOut),'LineWidth',4,'Color',colorsUse(t,:));
                
                
                xlim(hsub(p,c),[0 120]);
                xlabel(hsub(p,c),'Frequency (Hz)');
                ylabel(hsub(p,c),'Power  (log_1_0\muV^2/Hz)');
                ttluse = sprintf('%s %s',patients{p},ttls{c});
                title(hsub(p,c),ttluse,'FontSize',16);
            end
        end
    end
    params.figname = 'on_off_meds_all_channels';
    hfig.Color = 'w';
    plot_hfig(hfig,params)
end
%% plot only select sub channels (this is what we keep
% create figure;
plotthis = 0;
if plotthis
    hfig = figure;
    cnt = 1;
    for p = 1:length(patients)
        for c = 1:2
            hsub(p,c) = subplot(length(patients),2,cnt);
            hold on;
            cnt = cnt + 1;
        end
    end
    for p = 1:length(patients)
        for t = 1:length(types)
            idxUse = (cellfun(@(x) any(strfind(x,patients{p})),ff) & ...
                cellfun(@(x) any(strfind(x,types{t})),ff) ) ;
            idxLoad = find(idxUse ==1);
            load(ff{idxLoad});
            outdatcomplete = outdatachunk;
            times = outdatcomplete.derivedTimes;
            srate = unique( outdatcomplete.samplerate );
            for c = 1:2
                cuse = cnsUsePerPatient(p,c);
                fnm = sprintf('key%d',cuse-1);
                y = outdatcomplete.(fnm);
                y = y - mean(y);
                [fftOut,f]   = pwelch(y,srate,srate/2,0:1:srate/2,srate,'psd');
                
                hplt(p,t,c) = plot(hsub(p,c),f,log10(fftOut),'LineWidth',4,'Color',colorsUse(t,:));
                
                
                xlim(hsub(p,c),[0 120]);
                xlabel(hsub(p,c),'Frequency (Hz)');
                ylabel(hsub(p,c),'Power  (log_1_0\muV^2/Hz)');
                ttluse = sprintf('%s %s',patients{p},ttls{cuse});
                title(hsub(p,c),ttluse,'FontSize',16);
            end
        end
    end
    for p = 1:length(patients)
        for c = 1:2
            legend(hsub(p,c),typeLeg);
        end
    end
    params.figname = 'on_off_meds_select_channels';
    hfig.Color = 'w';
    plot_hfig(hfig,params)
end
betaFreqs = [15 20 29 16];

%% PAC PAC PAC plot only select sub channels (this is what we keep
% create figure;
addpath(genpath(fullfile('..','..','PAC')));
close all;
pacparams.PhaseFreqVector      = 5:2:50;
pacparams.AmpFreqVector        = 10:5:200;

pacparams.PhaseFreq_BandWidth  = 4;
pacparams.AmpFreq_BandWidth    = 10;
pacparams.computeSurrogates    = 0;
pacparams.numsurrogate         = 0;
pacparams.alphause             = 0.05;
pacparams.plotdata             = 0;
pacparams.useparfor            = 0; % if true, user parfor, requires parallel computing toolbox
pacparams.regionnames          = {'STN','M1'};

hfig = figure;
cnt = 1;
for p = 1:length(patients)    
    for c = 1:2
        for t = 1:2
            hsub(p,t,c) = subplot(length(patients),4,cnt);
            hold on;
            cnt = cnt + 1;
            
        end
    end
end
for p = 1:length(patients)
    for t = 1:length(types)
        idxUse = (cellfun(@(x) any(strfind(x,patients{p})),ff) & ...
            cellfun(@(x) any(strfind(x,types{t})),ff) ) ;
        idxLoad = find(idxUse ==1);
        load(ff{idxLoad});
        outdatcomplete = outdatachunk;
        times = outdatcomplete.derivedTimes;
        srate = unique( outdatcomplete.samplerate );
        for c = 1:2
            cuse = cnsUsePerPatient(p,c);
            fnm = sprintf('key%d',cuse-1);
            y = outdatcomplete.(fnm);
            y = y - mean(y);
            if srate == 250 
                pacparams.AmpFreqVector        = 10:5:80;
            elseif srate == 1e3
                pacparams.AmpFreqVector        = 10:5:200;
            elseif srate == 500
                pacparams.AmpFreqVector        = 10:5:200;
            end
            results = computePAC(y',srate,pacparams);
            res = results(1);
            contourf(hsub(p,t,c),res.PhaseFreqVector+res.PhaseFreq_BandWidth/2,...
                res.AmpFreqVector+res.AmpFreq_BandWidth/2,...
                res.Comodulogram',30,'lines','none')
            shading interp
            ttly = sprintf('Amplitude Frequency %s (Hz)',ttls{cuse});
            ylabel(hsub(p,t,c),ttly)
            ttlx = sprintf('Phase Frequency %s (Hz)',ttls{cuse});
            xlabel(hsub(p,t,c),ttlx)
            ttluse = sprintf('%s %s %s',patients{p},typeLeg{t},ttls{cuse});
            title(hsub(p,t,c),ttluse);
            set(hsub(p,t,c),'FontSize',18);
            
        end
    end
end

params.figname = 'on_off_meds_PAC';
hfig.Color = 'w';
plot_hfig(hfig,params)
betaFreqs = [15 20 29 16];
end