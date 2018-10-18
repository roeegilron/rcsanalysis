function plot_ipad_data_temp()
%% fig dir 
figdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v03-postop/figures';
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



ipadEndDt = datetime('13-Oct-2018 19:08:01.000','TimeZone','America/Los_Angeles');

idxipadrec = outdatcomplete.derivedTimes > ipadStartDt & outdatcomplete.derivedTimes < ipadEndDt;
%% 

%% plot ipad raw data 
hfig = figure;
set(0,'defaultAxesFontSize',16)

numplot = 4; 
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
    xlabel(hsub(c),'seconds');
    ylabel(hsub(c),'Frequency (Hz)');
    title(outRec.tdData(c).chanFullStr);
    
    axis tight; 
end
linkaxes(hsub,'x');


%% plot psd and coherence  
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
    xlabel(hsub(c),'seconds');
    ylabel(hsub(c),'Frequency (Hz)');
    title(outRec.tdData(c).chanFullStr);
    
    axis tight; 
end
linkaxes(hsub,'x');

end