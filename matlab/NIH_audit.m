
load('/Volumes/BACKUP_DRIVE/Starr_Lab_Folder/Data_Analysis/First_Pass_Data_Analysis/data/database/db1_with_brdy.mat')
idxlook = cellfun(@(x) any(strfind(x,'2017')),resTabAll.time);
res2017 = resTabAll(idxlook,:);
dtData      = cellfun(@(x) datetime(x),res2017.time);
idxkeep     = month(dtData)>=9 & month(dtData)<=12;
res2017 = res2017(idxkeep,:);
dtData      = cellfun(@(x) datetime(x),res2017.time);
close all; 
for d = 1:size(res2017,1)
    hfig = figure;
    hfig.Color = 'w';
    if res2017.med(d)
        medState = 'med on';
    else
        medState = 'med off';
    end
    
    
    if res2017.stim(d)
        stimState = 'stim on';
    else
        stimState = 'stim off';
    end
    ttluse = {};
    ttluse{1,1} = sprintf('%s %s %s',res2017.task{d}, medState, stimState); 
    ttluse{1,2} =  sprintf('%s %s %s',res2017.patient{d}, datetime(dtData(d),'Format','yyyy/MM/dd hh:mm'));
    subplot(3,1,1); 
    x = res2017.psdlfpF{d};
    y = res2017.psdlfp{d};
    plot(x,y,'LineWidth',2);
    title('LFP');
    xlabel('Frequency (Hz)');
    ylabel('Power (log_1_0\muV^2/Hz)');
    xlim([3 100]);
    
    subplot(3,1,2); 
    x = res2017.psdecogF{d};
    y = res2017.psdecog{d};
    plot(x,y,'LineWidth',2);
    title('ECOG');
    xlabel('Frequency (Hz)');
    ylabel('Power (log_1_0\muV^2/Hz)');
    xlim([3 100]);
    
    subplot(3,1,3); 
    plot(x,y,'LineWidth',2);
    x = res2017.coherfreq{d};
    y = res2017.cpherpower{d};
    title('Coherence');
    xlabel('Frequency (Hz)');
    ylabel('ms coherence');
    xlim([3 100]);
    sgtitle(ttluse,'FontSize',16); 
    
    figdir = '/Users/roee/Box/OLD_SHARES/NIH_audit';
    
    ttlsave = sprintf('%s_%s_%s_med-%d_stim-%d',res2017.patient{d}, datetime(dtData(d),'Format','yyyy_MM_dd_hh-mm'),...
        res2017.task{d}, res2017.med(d), res2017.stim(d));
    hpanel.fontsize = 16;
    hfig.Renderer='Painters';
    clear prfig;
    prfig.figdir = figdir;
    prfig.figtype = '-dpdf';
    prfig.resolution = 600;
    prfig.plotwidth           = 10;
    prfig.plotheight          = 10*1.2;
    prfig.figname             = ttlsave;
    plot_hfig(hfig,prfig)
    close(hfig);
end