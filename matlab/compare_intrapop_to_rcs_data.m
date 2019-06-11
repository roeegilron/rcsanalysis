function compare_intrapop_to_rcs_data()
%% This funciton compares intraop to RC+S data
% it reiles on code here:
% '/Users/roee/Starr_Lab_Folder/Data_Analysis/1_intraop_data_analysis'
% note that you want to re-reference the data according to what you did
% with RC+S data
%% clear stuff 
clear all;
close all;
clc;
%% intraop data:
% ecog
fnm = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v02-surgery/intraop/NO data/analyzed/RCS01_Lecog_Llfp_rest_postlead_newlocatio2_ecog_filt.mat';
% left side 
fnm = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/v01_or_day/NeuroOmega/cora_analysis/done/RCS02_bilatM1_Llfp_rest_postlead_ecog_filt.mat';
% right side 
fnm = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/v01_or_day/NeuroOmega/cora_analysis/done/RCS02_bilatM1_Llfp_rest_postlead_ecog_filt.mat';
% both sides 
fnm = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/v01_or_day/NeuroOmega/cora_analysis/RCS02_bilatM1_bilatlfp_rest_postlead_ecog_filt.mat';

load(fnm);
clear fnm

%% load rest rc+s data
% right side
fnm = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v03-postop/rcs-data/Session1539481694013/DeviceNPC700395H/rest.mat';
% left side 
% fnm = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/v04_10_day/rcs_data/off_meds/RCS02L/Session1557938513404/DeviceNPC700398H/rest.mat';
load(fnm);
clear fnm;

%% re ref neuromega data according to RC+S recording config 

outdatcomplete = outdatachunk ;
cns = {outRec.tdData.chanOut};
% get NeuroOmega Channels 
for c = 1:length(cns)
    idxmins = str2num(outRec.tdData(c).minusInput);
    idxplus = str2num(outRec.tdData(c).plusInput);
    if c <= 2 
        idxmins = idxmins + 1; 
        idxplus = idxplus + 1; 
        neuroOmegaDat(c).dat = lfp.contact(idxplus).signal - lfp.contact(idxmins).signal;
    else
        idxmins = idxmins - 7;
        idxplus = idxplus - 7;
        neuroOmegaDat(c).dat = ecog.contact(idxplus).signal - ecog.contact(idxmins).signal;
    end
    
    neuroOmegaDat(c).chanName = sprintf('Neuro-Omega %s',cns{c});

end
neuroOmegaTab = struct2table(neuroOmegaDat);

%% plot data 
hfig = figure; 
for c = 1:length(cns)
    if c > 2
        nmpltuse = 2;
        ttlstr = 'ECOG';
    else
        nmpltuse = 1;
        ttlstr = 'LFP';
    end
    hsub(c) = subplot(2,2,c);
    
    % RC+S 
    hold on;
    fnm = sprintf('key%d',c-1);
    y = outdatcomplete.(fnm);
    y = y - mean(y);
    srate = unique(outdatcomplete.samplerate);
    [fftOut,f]   = pwelch(y,srate,srate/2,0:1:srate/2,srate,'psd');
    idxnorm = f > 5 & f < 150; 
    fftOut = fftOut./mean(fftOut(idxnorm));
    hplt(c,1) = plot(f,log10(fftOut));
    hplt(c,1).LineWidth = 2;
    hplt(c,1).Color = [0 0 0.8 0.8];
    xlim([0 250]);
    xlabel('Frequency (Hz)');
    ylabel('Power  (log_1_0\muV^2/Hz)');
    lgndttls{1} = sprintf('RC+S %s',outRec.tdData(c).chanFullStr);
    title(ttlstr);
    fprintf('%s %s rms = %.2f\n',lgndttls{1},ttlstr,rms(y).*1e3);
    clear y yout;
    
    % Neuro Omega (intra op);
    hold on;
    y = neuroOmegaTab.dat(c,:);
    y = y - mean(y);
    srate = ecog.Fs(c);
    [fftOut,f]   = pwelch(y,srate,srate/2,0:1:srate/2,srate,'psd');
    idxnorm = f > 5 & f < 150;
    fftOut = fftOut./mean(fftOut(idxnorm));
    hplt(c,2) = plot(f,log10(fftOut));
    hplt(c,2).LineWidth = 2;
    hplt(c,2).Color = [0.8 0 0 0.8];
    xlim([0 250]);
    xlabel('Frequency (Hz)');
    ylabel('Power  (log_1_0\muV^2/Hz)');
    lgndttls{2} = neuroOmegaDat(c).chanName;
    title(ttlstr);
    fprintf('%s %s rms = %.2f\n',neuroOmegaDat(c).chanName,ttlstr,rms(y));
    clear y yout;
    legend(hplt(c,:),lgndttls);
    % add legends

end
suptitle('Comparison of RC+S and NeuroOmega - normalized 5-150Hz');
% set params
params.figdir  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v03-postop/figures';
params.figtype = '-djpeg';
params.resolution = 300;
params.closeafterprint = 1;
params.figname = 'rc-s_vs_neuroomega-normalized-5-150';
% plot_hfig(hfig,params)
figdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v06-home-visit-3-week/figures';
figname = 'neuroomega vs rc+s.fig';
savefig(hfig,fullfile(figdir,figname)); 


%% plot pac 
pacparams.PhaseFreqVector      = 5:2:50;
pacparams.AmpFreqVector        = 10:5:200;

pacparams.PhaseFreq_BandWidth  = 4;
pacparams.AmpFreq_BandWidth    = 10;
pacparams.computeSurrogates    = 0;
pacparams.numsurrogate         = 0;
pacparams.alphause             = 0.05;
pacparams.plotdata             = 0;
pacparams.useparfor            = 0; % if true, user parfor, requires parallel computing toolbox

%% pac path
addpath(genpath('/Users/roee/Starr_Lab_Folder/Data_Analysis/PAC'));
for c = 1:4
    if c > 2
        nmpltuse = 2;
        ttlstr = 'ECOG';
    else
        nmpltuse = 1;
        ttlstr = 'LFP';
    end
    hfig = figure; 
    % rc+s data 
    hsb = subplot(1,2,1); 
    srate = unique( outdatcomplete.samplerate );
    fnm = sprintf('key%d',c-1);
    y = outdatcomplete.(fnm);
    y = y - mean(y);
    results = computePAC(y',srate,pacparams);
    % plot pac 
    contourf(results.PhaseFreqVector+results.PhaseFreq_BandWidth/2,...
        results.AmpFreqVector+results.AmpFreq_BandWidth/2,...
        results.Comodulogram',30,'lines','none')
    shading interp
    set(gca,'fontsize',14)
    ttly = sprintf('Amplitude Frequency %s (Hz)',outRec.tdData(c).chanOut);
    ylabel(ttly)
    ttlx = sprintf('Phase Frequency %s (Hz)',outRec.tdData(c).chanOut);
    xlabel(ttlx)
    ttluse = [ttlstr ' - RC+S'];
    title(ttluse);
    % plot neuroomega 
    hsb = subplot(1,2,2);
    srate = ecog.Fs(c);
    fnm = sprintf('key%d',c-1);
    y = neuroOmegaTab.dat(c,:);
    y = y - mean(y);
    results = computePAC(y,srate,pacparams);
    % plot pac 
    contourf(results.PhaseFreqVector+results.PhaseFreq_BandWidth/2,...
        results.AmpFreqVector+results.AmpFreq_BandWidth/2,...
        results.Comodulogram',30,'lines','none')
    shading interp
    set(gca,'fontsize',14)
    ttly = sprintf('Amplitude Frequency %s (Hz)',outRec.tdData(c).chanOut);
    ylabel(ttly)
    ttlx = sprintf('Phase Frequency %s (Hz)',outRec.tdData(c).chanOut);
    xlabel(ttlx)
    ttluse = [ttlstr ' - NeuroOmega'];
    title(ttluse);
    % print figure;
    suptitle(sprintf('Comparison of RC+S and NeuroOmega %s',ttlstr));
    % set params
    params.figdir  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v03-postop/figures';
    params.figtype = '-djpeg';
    params.resolution = 300;
    params.closeafterprint = 1;
    params.figname = sprintf('PAC-%s-%s',ttlstr,outRec.tdData(c).chanOut);
    plot_hfig(hfig,params)
end

end