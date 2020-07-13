function hfig = plot_pac_from_results(results)
hfig = figure;
for aa = 1:length(results)
    if length(results) ~=1
        subplot(2,2,aa)
        if aa <= 2
            ttlgrp = 'PAC within';
        else
            ttlgrp = 'PAC between';
        end
    else
        ttlgrp = 'PAC within';
    end
    
    Com_reshaped = results(aa).Comodulogram;
    zcom = results(aa).zComodulogram;
    idxover = zcom < -1.5 | zcom > 1.5;
    Com_reshaped(~idxover) = 0;
    AmpFreq_BandWidth = results(aa).AmpFreq_BandWidth;
    AmpFreqVector = results(aa).AmpFreqVector;
    PhaseFreq_BandWidth  = results(aa).PhaseFreq_BandWidth;
    PhaseFreqVector  = results(aa).PhaseFreqVector;
    ttlAmp = results(aa).ttlAmp;
    PhaseArea = results(aa).PhaseArea;
    
    contourf(PhaseFreqVector+PhaseFreq_BandWidth/2,AmpFreqVector+AmpFreq_BandWidth/2,Com_reshaped',30,'lines','none')
    set(gca,'fontsize',14)
    ttly = sprintf('Amplitude Frequency %s (Hz)',ttlAmp);
    ylabel(ttly)
    ttlx = sprintf('Phase Frequency %s (Hz)',PhaseArea);
    xlabel(ttlx)
    title(ttlgrp);
end

end