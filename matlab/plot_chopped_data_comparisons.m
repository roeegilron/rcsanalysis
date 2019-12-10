function plot_chopped_data_comparisons()
close all;
clc;
dirname = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/in_clinic/rest_2nd_try';
params.figdir  = dirname;
params.figtype = '-dpdf';
params.resolution = 150;
params.closeafterprint = 0;
params.figname = 'on_off_meds_all_patients_2nd_try';
params.plotwidth = 35;
params.plotheight = 25;

% make database 
ff = findFilesBVQX(dirname,'*.mat');
datTbl = table(); 
for f = 1:length(ff)
    [pn,fn] = fileparts(ff{f}); 
    datTbl.patient{f} = fn(1:5);
    datTbl.side{f} = fn(end);
    if any(strfind(fn,'on'))
     datTbl.med{f}  = 'on';   
    else
     datTbl.med{f}  = 'off';    
    end
    datTbl.fn{f} = fn; 
    
    load(ff{f});
    datTbl.data{f} = outdatachunk;
    datTbl.outRec{f} = outRec;
    for c = 1:4
        datTbl.(sprintf('key%d',c-1)){f} = outRec.tdData(c).chanFullStr;
    end
    clear outdatachunk
    datTbl.ff{f} = ff{f}; 
end

patients = {'RCS02','RCS05','RCS06','RCS07'};
types    = {'rest_off_meds','rest_on_meds'};
sides    = {'L','R'};
medstates = {'on','off'}; 
canperside = [1 2; 3 4];
typeLeg  = {'off meds','on meds'};

colorsUse   = [ 0 0.8 0 0.5; 0.8 0 0 0.5];
ttls   = {'STN 0-2','STN 1-3','M1 8-10','M1 9-11'};
cnsUsePerPatient = [1 , 3  ;...
    2 , 4  ;...
    2 , 4  ;...
    2 , 4];



%% plot evetything
plotthis = 1;
cntplt = 1;
hfig = figure;
hfig.Color = 'w';
if plotthis
    for p = 1:length(patients)
        for s = 1:2 % channel group 
            for c = canperside(s,:)
                for ss = 1:2 % loop on side
                    subplot(length(patients),8,cntplt); cntplt = cntplt + 1;
                    hold on;
                    for m = 1:2
                        idxuse = strcmp(datTbl.patient,patients{p}) & ...
                            strcmp(datTbl.side,sides{ss}) & ...
                            strcmp(datTbl.med,medstates{m} );
                        outdatcomplete = datTbl.data{idxuse};
                        times = outdatcomplete.derivedTimes;
                        srate = unique( outdatcomplete.samplerate );
                        
                        fnm = sprintf('key%d',c-1);
                        y = outdatcomplete.(fnm);
                        y = y - mean(y);
                        [fftOut,f]   = pwelch(y,srate,srate/2,0:1:srate/2,srate,'psd');
                        
                        plot(f,log10(fftOut),'LineWidth',4,'Color',colorsUse(m,:));
                        
                        
                        xlim([0 120]);
                        xlabel('Frequency (Hz)');
                        ylabel('Power  (log_1_0\muV^2/Hz)');
                        ttluse = sprintf('%s %s %s',patients{p},sides{ss},ttls{c});
                        title(ttluse,'FontSize',16);
                    end
                    legend(medstates);
                end
            end
        end
    end
    params.figname = 'on_off_meds_all_patients_2nd_try';
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