function plot_stim_titrations_manual_saved_files()

patient = 'RCS07';
side = 'L';
folderuse = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS07/v19_stim_titration_1/rcs_data/StarrLab/RCS07L/stim_titrations';
meds = {'off_meds','on_meds'};
for m = 1:length(meds)
    rootfold = fullfile(folderuse,meds{m});
    ff = findFilesBVQX(rootfold,'rest*.mat');
    for f = 1:length(ff)
        load(ff{f});
        [pn,fn] = fileparts(ff{f});
        
        outdat.(meds{m})(f).powerChunk = powerChunk;
        outdat.(meds{m})(f).outdatachunk = outdatachunk;
        outdat.(meds{m})(f).powerMeta = powerMeta;
        outdat.(meds{m})(f).eventTable = eventTable;
        outdat.(meds{m})(f).current = str2num(fn(end-2:end));
    end
end

%% plot power data
powerMeta.powerBandInHz
for p = 1%:size(powerMeta(1).powerBandInHz,1)
    hfig = figure;
    hfig.Color = 'w';
    ttluse = sprintf('band %d %s',p,powerMeta(1).powerBandInHz{p});
    title(ttluse);
    for m = 1:length(meds)
        dat = outdat.(meds{m});
        for c = 1:length(dat)
            xpos = dat(c).current;
            hold on;
            bandfn = sprintf('Band%d',p);
            rawpowerdat = dat(c).powerChunk.(bandfn);
            mean_beta = median(rawpowerdat);
            hsc = scatter(xpos,mean_beta,1e3,'filled');
            ampwrite = sprintf('%0.1f',dat(c).current);
            text(xpos, mean_beta, ampwrite);
            if m == 1
                cond = 'on';
                colorUse = [0.8 0 0.5];
            else
                cond = 'off';
                colorUse = [0 0.8 0.5];
            end
            hsc.MarkerFaceColor = colorUse;
            hsc.MarkerFaceAlpha = 0.6;
            
        end
    end
    set(gca,'FontSize',16);
    xlabel('Current (mA)');
    ylabel('internally (on RCS) computed Power (a.u.)');
end

%% plot time domain data
hfig = figure;
hfig.Color = 'w';
ttluse = sprintf('band %d %s',p,powerMeta(1).powerBandInHz{p});
title(ttluse);
meds = {'off_meds','on_meds'};
for m = 1:length(meds)
    dat = outdat.(meds{m});
    if m == 1 
        colorUse = [0.8 0 0.5];
    else
        colorUse = [0 0.8 0.5];
    end
    for cn = 1:4
        fnuse = sprintf('key%d',cn-1);
        ttluse = outRec(end).tdData(cn).chanFullStr;
        subplot(2,2,cn);
        hold on;
        for c = 1:length(dat)
            % get times
            tdTAble = dat(c).outdatachunk;
            tdtimes = tdTAble.derivedTimes - tdTAble.derivedTimes(1);
            timeabove = tdtimes(end) - seconds(30);
            idxkeep   = tdtimes >= timeabove;
            
            tddat = tdTAble.(fnuse)(idxkeep,:);
            sr  = unique(tdTAble.samplerate(idxkeep,:));
            [fftOut,ff]   = pwelch(tddat,sr,sr/2,0:1:sr/2,sr,'psd');
            
            ampwrite = sprintf('%0.1fmA',dat(c).current);
            hp = plot(ff,log10(fftOut));
            hp.LineWidth = 2; 
            hp.Color = colorUse; 
            if dat(c).current > 1 
                hp.LineStyle = '-.';
            else
                hp.LineStyle = '-';
            end
        end
        xlim([1 100]);
        xlabel('Freq (Hz)');
        ylabel('Power (log_1_0\muV^2/Hz)');
        title(ttluse);
        set(gca,'FontSize',16);
        

    end
end


end





