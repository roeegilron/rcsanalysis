function plot_compare_montage_data_from_saved_montage_files(dirname)
% you need to run this function first:
% open_and_save_montage_data_in_sessions_directory

ff = findFilesBVQX(dirname,'rawMontageData.mat');
figdir = fullfile(dirname,'figures');
montageTableFn = fullfile(dirname,'montageTable.mat');
if exist(montageTableFn,'file')
    load(montageTableFn); 
else
    report_motnage_files_in_dir(dirname); 
    load(montageTableFn); 
end
partAllOrPart = input('do you want to plot all data or part of the data? [1 all 2 part]? '); 
if partAllOrPart == 2
    tableToSave
    fprintf('\n'); 
    montageToPlot = input('type out montage nubmer you want to plot: '); 
    ff = ff(montageToPlot);
end

mkdir(figdir);
% get unique channels
unqchannel_lfp = {};
unqchannel_ctx = {};
for f = 1:length(ff)
    load(ff{f});
    for s = 1:size(montageDataRaw,1)
        unqchannel_lfp = [unqchannel_lfp {montageDataRaw.TimeDomainDataStruc{s}(1:2).chanOut}];
        unqchannel_ctx = [unqchannel_ctx {montageDataRaw.TimeDomainDataStruc{s}(3:4).chanOut}];
    end
    
    if exist('montagDataRawManualIdxs','var')
        montageDataRaw = montagDataRawManualIdxs;
    end
end
unqlfp = unique(unqchannel_lfp);
unqctx = unique(unqchannel_ctx);



addpath(genpath(fullfile(pwd,'toolboxes','panel-2.14')));
hfig = figure('Visible','on');
hfig.Color = 'w';
hfig.Position = [1000         547        1020         791];
hpanel = panel();
hpanel.pack(2,6);
for i = 1:6
    for c = 1:2
        hsb = hpanel(c,i).select();
        axes(hsb);
        hold on;
        plotFreqPatches(hsb);
    end
end


if partAllOrPart == 2
    color = ['r','b'];
end
targetsr = '500Hz';
targelpf = '100Hz';
% stn 
addtitleTopPlots = ['sr = ',targetsr, ', lfp = ', targelpf];
for u = 1:length(unqlfp)
    for f = 1:length(ff)
        load(ff{f});

        if exist('montagDataRawManualIdxs','var')
            montageDataRaw = montagDataRawManualIdxs;
        end
        if f == 1
            montageDataRaw = montageDataRaw(2:end,:);
        end
        for s = 1:size(montageDataRaw,1)
            for c = 1:2
                tdc = montageDataRaw.TimeDomainDataStruc{s}(c);
                usechanl = strcmp(tdc.chanOut,unqlfp{u}) & ...
                    strcmp(tdc.lpf1,targelpf) & ...
                    strcmp(tdc.lpf2,targelpf) & ...
                    strcmp(tdc.sampleRate,targetsr) ;
                if usechanl
                    y = montageDataRaw.data{s}(:,c); 
                    y = y-mean(y); 
                    hsb = hpanel(1,u).select();
                    axes(hsb);
                    hold on; 
                    sr  = 500; 
                    [fftOut,freqs]   = pwelch(y,sr,sr/2,2:1:(sr/2 - 50),sr,'psd');
                    fftlog  = log10(fftOut);
                    % normalize
                    idxfreq = freqs >=10 & freqs<=90;
                    meanfreq = abs(mean(fftlog(idxfreq)));
                    fftplot = fftlog./meanfreq;
                    if partAllOrPart == 2
                        hplt = plot(freqs,fftplot,'LineWidth',1,'Color',color(f));
                    else
                        hplt = plot(freqs,fftplot,'LineWidth',1,'Color',[0 0 0.8 0.2]);
                    end
                    hplt.UserData.dirname = ff{f};

                    title([unqlfp{u},' ',addtitleTopPlots]);
                    xlabel('Freq. (Hz)');
                    ylabel('norm power');
                    xlim([3 100]);
                end                
            end
        end
        if partAllOrPart == 2
            legendConditions{f} = tableToSave.EventSubType(find(tableToSave.montageNumber==montageToPlot(f)));
        end
    end
end

if partAllOrPart == 2
    for ii=1:length(legendConditions)
        legendConditions{ii}
    end
end

% ctx
targelpf1 = '450Hz';
targelpf2 = '1700Hz';
addtitleTopPlots = ['sr = ',targetsr, ', lfp1 = ', targelpf1];
for u = 1:length(unqctx)
    for f = 1:length(ff)
        load(ff{f})
        if exist('montagDataRawManualIdxs','var')
            montageDataRaw = montagDataRawManualIdxs;
        end
        if f == 1
            montageDataRaw = montageDataRaw(2:end,:);
        end
        for s = 1:size(montageDataRaw,1)
            for c = 3:4
                tdc = montageDataRaw.TimeDomainDataStruc{s}(c);
                usechanl = strcmp(tdc.chanOut,unqctx{u}) & ...
                    strcmp(tdc.lpf1,targelpf1) & ...
                    strcmp(tdc.lpf2,targelpf2) & ...
                    strcmp(tdc.sampleRate,targetsr) ;
                if usechanl
                    y = montageDataRaw.data{s}(:,c);
                    y = y-mean(y); 
                    hsb = hpanel(2,u).select();
                    axes(hsb);
                    hold on; 
                    sr  = 500; 
                    [fftOut,freqs]   = pwelch(y,sr,sr/2,2:1:(sr/2 - 50),sr,'psd');
                    fftlog  = log10(fftOut);
                    % normalize
                    idxfreq = freqs >=10 & freqs<=90;
                    meanfreq = abs(mean(fftlog(idxfreq)));
                    fftplot = fftlog./meanfreq;
                    if partAllOrPart == 2
                        hplt = plot(freqs,fftplot,'LineWidth',1,'Color',color(f));
                    else
                        hplt = plot(freqs,fftplot,'LineWidth',1,'Color',[0 0 0.8 0.2]);
                    end
                    hplt.UserData.dirname = ff{f};
                    title([unqctx{u},' ', addtitleTopPlots]);
                    xlabel('Freq. (Hz)');
                    ylabel('norm power'); 
                    xlim([3 100]);
                end                
            end
        end
    end
end


dcm_obj = datacursormode(hfig);
dcm_obj.UpdateFcn = @myupdatefcn;
dcm_obj.SnapToDataVertex = 'on';
datacursormode on;
  
end

function plot_data_per_recording(montageDataRaw,hpanel,clr)

for i = 1:6%size(montageDataRaw,1)
    % psd
    ydat = montageDataRaw.data{i};
    sr  = montageDataRaw.samplingRate(i);
    for c = 1:4
        hsb = hpanel(i,c).select();
        axes(hsb);
        hold on;
        y = ydat(:,c);
        y = y - mean(y);
        if sum(y) ~= 0
            [fftOut,f]   = pwelch(y,sr,sr/2,2:1:(sr/2 - 50),sr,'psd');
            fftlog  = log10(fftOut);
            % normalize 
            idxfreq = f >=10 & f<=90;
            meanfreq = abs(mean(fftlog(idxfreq)));
            fftplot = fftlog./meanfreq;
            plotFreqPatches(hsb);
            plot(f,fftplot,'LineWidth',2,'Color',clr);
            xlabel('Freq (Hz)');
            ylabel('norm power');
            chanchar = montageDataRaw.TimeDomainDataStruc{i}(c).chanOut;
            ttlstr = sprintf('PSD %s',chanchar);
            title(ttlstr);
            xlim([3 100]);
        end
    end
end
end


function [txt] = myupdatefcn(~,event_obj)
% Customizes text of data tips
dirname = event_obj.Target.UserData.dirname;
[pn,fn] = fileparts(dirname);
evenfn = fullfile(pn,'EventLog.json');
eventTable  = loadEventLog(evenfn);
idxdiscard = cellfun(@(x) any(strfind(lower(x),'leadloc')),eventTable.EventType) | ...
    cellfun(@(x) any(strfind(lower(x),'montage')),eventTable.EventType) | ...
    cellfun(@(x) any(strfind(lower(x),'battery')),eventTable.EventType) ;
eventTime = eventTable.sessionTime(1);
eventToReport = eventTable(~idxdiscard,:);
for e = 1:size(eventToReport,1)
    stringsreport{e} = sprintf('\t%s \t%s\n',eventToReport.EventType{e}, eventToReport.EventSubType{e});
end



pos = get(event_obj,'Position');
txt = {['Freq : ', sprintf('%.2f',pos(1))],...
       ['Power: ', sprintf('%.2f',pos(2))],...
       ['Sub Report: ', strrep( stringsreport{1},'_','-')],...
       ['Sub Report 2: ',strrep( stringsreport{2},'_','-')],...
       ['Time Of Day: ', sprintf('%s',eventTime)]};
end

