function plot_data_pac_rcs(dirname)
%% pac path
addpath(genpath('/Users/roee/Starr_Lab_Folder/Data_Analysis/PAC'));
%% set params
params.figdir  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v05-home-visit/figures';
params.figtype = '-djpeg';
params.resolution = 300;
params.closeafterprint = 1;

%% pac params
pacparams.PhaseFreqVector      = 5:2:50;
pacparams.AmpFreqVector        = 10:5:200;

pacparams.PhaseFreq_BandWidth  = 4;
pacparams.AmpFreq_BandWidth    = 10;
pacparams.computeSurrogates    = 0;
pacparams.numsurrogate         = 0;
pacparams.alphause             = 0.05;
pacparams.plotdata             = 0;
pacparams.useparfor            = 0; % if true, user parfor, requires parallel computing toolbox


ff = findFilesBVQX(dirname,'*.mat');
include = {'standing'}; %{'rest walking ipad standing
include = {'standing'}; %{'rest walking ipad standing
include = {'rest-off-meds','rest-on-meds'};
idxOutRec = [3, 1];
cns = 1:4;
% cns = [1 3];
%% plot pac


for i = 1:length(include);
    hfig = figure;
    idxuse = cellfun(@(x) any(strfind(x,include{i})),ff);
    if sum(idxuse) >= 1
        load(ff{idxuse});
        outdatcomplete = outdatachunk;
        times = outdatcomplete.derivedTimes;
        srate = unique( outdatcomplete.samplerate );
        nmplt = 1;
        for c = cns
            if c > 2
                nmpltuse = 2;
                ttlstr = 'ECOG';
            else
                nmpltuse = 1;
                ttlstr = 'LFP';
            end
            hsub(nmplt) = subplot(2,2,c);
            hold on;
            fnm = sprintf('key%d',c-1);
            y = outdatcomplete.(fnm);
            y = y - mean(y);
            yout(:,c) = y';1
            results = computePAC(y',srate,pacparams);
            %% pac plot
            outRecUse  = outRec(idxOutRec(i));
            contourf(results.PhaseFreqVector+results.PhaseFreq_BandWidth/2,...
                results.AmpFreqVector+results.AmpFreq_BandWidth/2,...
                results.Comodulogram',30,'lines','none')
            shading interp
            set(gca,'fontsize',14)
            ttly = sprintf('Amplitude Frequency %s (Hz)',outRecUse.tdData(c).chanOut);
            ylabel(ttly)
            ttlx = sprintf('Phase Frequency %s (Hz)',outRecUse.tdData(c).chanOut);
            xlabel(ttlx)
            title(ttlstr);
            
            nmplt = nmplt + 1;
        end
        clear yout y; 
        
        
    end
    params.figname = sprintf('%s-PAC',include{i});
    plot_hfig(hfig,params)
end

end