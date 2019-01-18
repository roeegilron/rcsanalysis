function plot_ipad_data_temp()
%% fig dir 
params.figdir  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v03-postop/figures';
params.figtype = '-djpeg';
params.resolution = 300;
params.closeafterprint = 1; 
%% load raw data 
% get idxs for ipad event 
% ipad start 3 ipdat stop 4 
rootdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v03-postop/rcs-data/Session1539481694013'; 
ff = findFilesBVQX(rootdir,'*.mat'); 
for f = 1:length(ff)
    load(ff{f});
end
%%
%% find ipad event 
elgs = struct2table([eventLog.Event]);
idxstart = strcmp(elgs.EventSubType,'3');
idxend = strcmp(elgs.EventSubType,'4');

ipadStartUnix = elgs.UnixOffsetTime( idxstart);
ipadEndUnix = elgs.UnixOffsetTime( idxend);
%%
ipadStartDt = ...
    datetime(ipadStartUnix/1000,'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');



ipadEndDt = ...
    datetime(ipadEndUnix/1000,'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');



% ipadEndDt = datetime('13-Oct-2018 19:08:01.000','TimeZone','America/Los_Angeles');

idxipadrec = outdatcomplete.derivedTimes > ipadStartDt & outdatcomplete.derivedTimes < ipadEndDt;
%% set printing defaults 



%% plot ipad raw data 
hfig = figure;
set(0,'defaultAxesFontSize',16)

numplot = 4; 
idxipadrec = 1:length(outdatcomplete.derivedTimes);
times = outdatcomplete.derivedTimes(idxipadrec); 
for c = 1:4
    hsub(c) = subplot(4,1,c); 
    fnm = sprintf('key%d',c-1);
    y = outdatcomplete.(fnm)(idxipadrec); 
    y = y - mean(y); 
    plot(times,y); 
    title(outRec.tdData(c).chanFullStr);
end
linkaxes(hsub,'x');
suptitle('5 hz stim artifact across channels'); 
params.figname = '5 hz stim artifact';
%%
plot_hfig(hfig,params)
%% plot ipad spectrogram 

hfig = figure;
numplot = 4; 
times = outdatcomplete.derivedTimes(idxipadrec); 
for c = 1:4
    hsub(c) = subplot(4,1,c); 
    fnm = sprintf('key%d',c-1);
    y = outdatcomplete.(fnm)(idxipadrec); 
    y = y - mean(y); 
    srate = str2num(strrep(outRec.tdData(c).sampleRate,'Hz',''));
    [s,f,t,p] = spectrogram(y,srate,ceil(0.8750*srate),1:120,srate,...
        'yaxis','power');

    surf(hsub(c),seconds(t), f, 10*log10(p), 'EdgeColor', 'none');
    shading(hsub(c),'interp');
    view(hsub(c),2);
    axis tight;
    xlabel(hsub(c),'seconds');
    ylabel(hsub(c),'Frequency (Hz)');
    title(outRec.tdData(c).chanFullStr);
    
end
linkaxes(hsub,'x');
suptitle('ipad postop'); 
params.figname = 'spectrogram-ipad';
plot_hfig(hfig,params)


%% plot psd and coherence  
hfig = figure;
numplot = 4; 
times = outdatcomplete.derivedTimes(idxipadrec); 
srate = unique( outdatcomplete.samplerate(idxipadrec) ); 
for c = 1:4
    if c > 2 
        nmplt = 2;
        ttlstr = 'ECOG'; 
    else
        nmplt = 1;
        ttlstr = 'LFP'; 
    end
    hsub(c) = subplot(2,2,nmplt); 
    hold on; 
    fnm = sprintf('key%d',c-1);
    y = outdatcomplete.(fnm)(idxipadrec); 
    y = y - mean(y);
    yout(:,c) = y';
    [fftOut,f]   = pwelch(y,srate,srate/2,0:1:srate/2,srate,'psd');
    hplt(c) = plot(f,log10(fftOut));
    hplt(c).LineWidth = 2; 
    %hplt.Color = [0 0 0.8 0.8];
    xlim([0 150]);
    xlabel('Frequency (Hz)');
    ylabel('Power  (log_1_0\muV^2/Hz)');
    title(ttlstr);
    
end
legend(hplt(1:2),{outRec.tdData(1:2).chanOut})
legend(hplt(3:4),{outRec.tdData(3:4).chanOut})
linkaxes(hsub,'x');
% plot coherence 
hcoh = subplot(2,2,[3 4]); 
hold on;
prs = nchoosek(1:4,2);
for p = 1:size(prs,1)
    [Cxy,F] = mscohere(yout(:,prs(p,1)),yout(:,prs(p,2)),...
        2^(nextpow2(srate)),...
        2^(nextpow2(srate/2)),...
        2^(nextpow2(srate)),...
        srate);
    hplot(p) = plot(F,Cxy);
    hplot(p).LineWidth = 2;
    xlabel('Freq (Hz)');
    ylabel('Magnitude-Squared Coherence');
    lgds{p} = [outRec.tdData(prs(p,1)).chanOut ' ' outRec.tdData(prs(p,2)).chanOut];
end
title(hcoh,'coherence');
legend(hplot,lgds)
suptitle('ipad postop'); 
params.figname = 'psd-and-coherence-ipad';
plot_hfig(hfig,params)
%%

end