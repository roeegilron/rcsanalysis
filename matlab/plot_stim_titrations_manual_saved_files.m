function plot_stim_titrations_manual_saved_files()
close all;clc;
rootdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/stim_titrations';
figdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/stim_titrations/figures';

patientFolders = findFilesBVQX(rootdir,'RCS*',struct('dirs',1,'depth',1));

%%
for ppp = 1:length(patientFolders)
    [pn,fn] = fileparts(patientFolders{ppp});
    patient = fn(1:end-1);
    side = fn(end);
    
    folderuse = patientFolders{ppp};
    meds = {'off_meds','on_meds'};
    for m = 1:length(meds)
        rootfold = fullfile(folderuse,meds{m});
        ff = findFilesBVQX(rootfold,'rest*.mat');
        for f = 1:length(ff)
            load(ff{f});
            [pn,fn] = fileparts(ff{f});
            [pnn,medscond] = fileparts(pn);
            [pnnn,patientandside] = fileparts(pnn);
%             outdat.(meds{m})(f).powerChunk = powerChunk;
            outdat.(meds{m})(f).outdatachunk = outdatachunk;
%             outdat.(meds{m})(f).powerMeta = powerMeta;
            outdat.(meds{m})(f).eventTable = eventTable;
            outdat.(meds{m})(f).current = str2num(fn(end-2:end));
            fprintf('%s %s %s %s\n',...
                patientandside,medscond,fn,outdatachunk.derivedTimes(1));
            if isempty(outdatachunk)
                fprintf('empty file:\t %s\n',ff{f});
            end
        end
    end
end
%%
%%
clear outdat;
for ppp = 11:12%:length(patientFolders)
    [pn,fn] = fileparts(patientFolders{ppp});
    patient = fn(1:end-1);
    side = fn(end);
    clear outdat;
    folderuse = patientFolders{ppp};
    meds = {'off_meds','on_meds'};
    for m = 1:length(meds)
        rootfold = fullfile(folderuse,meds{m});
        ff = findFilesBVQX(rootfold,'rest*.mat');
        for f = 1:length(ff)
            load(ff{f});
            [pn,fn] = fileparts(ff{f});
            
%             outdat.(meds{m})(f).powerChunk = powerChunk;
            outdat.(meds{m})(f).outdatachunk = outdatachunk;
%             outdat.(meds{m})(f).powerMeta = powerMeta;
            outdat.(meds{m})(f).eventTable = eventTable;
            outdat.(meds{m})(f).current = str2num(fn(end-2:end));
            if isempty(outdatachunk)
                fprintf('empty file:\t %s\n',ff{f});
            end
        end
    end
    
    
    %% plot power data
    skipthis = 0;
    if skipthis
        powerMeta.powerBandInHz
        hfig = figure;
        hfig.Color = 'w';
        
        for p = 1:size(powerMeta(1).powerBandInHz,1)
            ttluse = sprintf('band %d %s',p,powerMeta(1).powerBandInHz{p});
            subplot(2,4,p);
            title(ttluse);
            hold on;
            for m = 1:length(meds)
                dat = outdat.(meds{m});
                for c = 1:length(dat)
                    xpos = dat(c).current;
                    hold on;
                    bandfn = sprintf('Band%d',p);
                    rawpowerdat = dat(c).powerChunk.(bandfn);
                    mean_beta = median(rawpowerdat);
                    hsc = scatter(xpos,mean_beta,2e2,'filled');
                    ampwrite = sprintf('%0.1f',dat(c).current);
                    %                 text(xpos, mean_beta, ampwrite);
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
            set(gca,'FontSize',10);
            xlabel('Current (mA)');
            ylabel('internally (on RCS) computed Power (a.u.)');
        end
        largeTitleUse = sprintf('%s %s',patient,side);
        sgtitle(largeTitleUse,'FontSize',24);
        
        % params to print the figures
        params.plotwidth           = 20;
        params.plotheight          = 20*0.6;
        params.figdir              = figdir;
        params.figtype             = '-djpeg';
        params.closeafterprint     = 0;
        params.resolution          = 300;
        fnmres = sprintf('%s_%s_power_data.jpeg',patient,side);
        params.figname             = fnmres;
        %     plot_hfig(hfig,params);
        close(hfig);
    end
    %% plot time domain data
    hfig = figure;
    hfig.Color = 'w';
    for cn = 1:4
        hsb = subplot(2,2,cn);
        hold on;
        plotFreqPatches(hsb)
    end
    
    meds = {'off_meds','on_meds'};
    for m = 1:length(meds)
        dat = outdat.(meds{m});
        if m == 1
            colorUse = [0.8 0 0.5];
        else
            colorUse = [0 0.8 0.5];
        end
        chanorder = [3 4 1 2];
        for cn = 1:4
            fnuse = sprintf('key%d',chanorder(cn)-1);
            ttluse = outRec(end).tdData(chanorder(cn)).chanFullStr;
            if chanorder(cn) > 2
                area = 'M1';
            else
                area = 'STN';
            end
            ttluse = sprintf('%s +%s-%s',area,...
                outRec(end).tdData(chanorder(cn)).plusInput,...
                outRec(end).tdData(chanorder(cn)).minusInput);
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
                outdat.(meds{m})(c).ff(chanorder(cn),:) = ff;
                outdat.(meds{m})(c).fftOut(chanorder(cn),:) = log10(fftOut);
                ampwrite = sprintf('%0.1fmA',dat(c).current);
                hp = plot(ff,log10(fftOut));
                hp.LineWidth = 2;
                hp.Color = colorUse;
                hpout(m,c,cn) = hp;
                if dat(c).current > 1
                    hp.LineStyle = '-.';
                else
                    hp.LineStyle = '-';
                end
                
            end
            xlim([1 100]);
            xlabel('Freq (Hz)');
            ylabel('Power (log_1_0\muV^2/Hz)');
            title(strrep(ttluse,'_',' '));
            set(gca,'FontSize',16);
            
        end
    end
    largeTitleUse = sprintf('%s %s',patient,side);
    largeTitleUse = strrep(largeTitleUse,'_',' ');
    sgtitle(largeTitleUse,'FontSize',24);

    fprintf('patient %s side %s\n', patient,side);
    % params to print the figures
    params.plotwidth           = 20;
    params.plotheight          = 20*0.6;
    params.figdir              = figdir;
    params.figtype             = '-djpeg';
    params.closeafterprint     = 0;
    params.resolution          = 300;
    fnmres = sprintf('%s_%s_time_domain_data.jpeg',patient,side);
    params.figname             = fnmres;
    plot_hfig(hfig,params);
    
    %% plot power data from time domain data
    dontskipthis = 1;
    if dontskipthis
        patientandside = [patient side];
        switch patientandside
            case 'RCS07L'
                peaks(1) = 17;
                peaks(2) = 66;
                peaks(3) = 65;
                peaks(4) = 6;
                bw = 2.5;
            case 'RCS06L'
                peaks(1) = 17; % 25 is hight beta peak 17 is low beta
                peaks(2) = 80;
                peaks(3) = 9;
                peaks(4) = 79;
                bw = 2.5;
            case 'RCS02L'
                peaks(1) = 21; % 25 is hight beta peak 17 is low beta
                peaks(2) = 67;
                peaks(3) = 24;
                peaks(4) = 65;
                bw = 2.5;
            case 'RCS02R'
                peaks(1) = 18; % 25 is hight beta peak 17 is low beta
                peaks(2) = 66;
                peaks(3) = 23;
                peaks(4) = 65;
                bw = 2.5;
            case 'RCS05L'
                peaks(1) = 17; % 25 is hight beta peak 17 is low beta
                peaks(2) = 25;
                peaks(3) = 24;
                peaks(4) = 7;
                bw = 2.5;
            case 'RCS05R'
                peaks(1) = 25; % 25 is hight beta peak 17 is low beta
                peaks(2) = 65;
                peaks(3) = 10;
                peaks(4) = 79;
                bw = 2.5;
            case 'RCS06L'
                peaks(1) = 18; % 25 is hight beta peak 17 is low beta
                peaks(2) = 79;
                peaks(3) = 10;
                peaks(4) = 79;
                bw = 2.5;
            case 'RCS06R'
                peaks(1) = 18; % 25 is hight beta peak 17 is low beta
                peaks(2) = 76;
                peaks(3) = 10;
                peaks(4) = 65;
                bw = 2.5;
            case 'RCS01L_BP'
                peaks(1) = 14; % 25 is high beta peak 17 is low beta
                peaks(2) = 80;
                peaks(3) = 16;
                peaks(4) = 6;
                bw = 2.5;
            case 'RCS01L_MP'
                peaks(1) = 14; % 25 is high beta peak 17 is low beta
                peaks(2) = 21;
                peaks(3) = 6;
                peaks(4) = 76;
                bw = 2.5;
            case 'RCS08L'
                peaks(1) = 22; % 25 is high beta peak 17 is low beta
                peaks(2) = 65;
                peaks(3) = 12;
                peaks(4) = 81;
                bw = 2.5;
            case 'RCS08R'
                peaks(1) = 22; % 25 is high beta peak 17 is low beta
                peaks(2) = 38;
                peaks(3) = 15;
                peaks(4) = 78;
                bw = 2.5;

        end
        
        hfig = figure;
        hfig.Color = 'w';
        for m = 1:length(meds)
            dat = outdat.(meds{m});
            if m == 1
                colorUse = [0.8 0 0.5];
            else
                colorUse = [0 0.8 0.5];
            end
            
            chanorder = [3 4 1 2];
            for cn = 1:4 % loop on sense electrodes
                ttluse = outRec(end).tdData(cn).chanFullStr;
                subplot(2,2,cn);
                if chanorder(cn) > 2
                    area = 'M1';
                else
                    area = 'STN';
                end

                hold on;
                currents = []; 
                meanpower = [];
                for c = 1:length(dat) % loop on stim current
                    
                    ff = outdat.(meds{m})(c).ff(chanorder(cn),:);
                    fftOut  = outdat.(meds{m})(c).fftOut(chanorder(cn),:);
                    current = outdat.(meds{m})(c).current;
                    idxuse = (ff >= (peaks(chanorder(cn))-bw) ) &  (ff <= (peaks(chanorder(cn))+bw) );
                    meanpower(c) = mean(fftOut(idxuse));
                    currents(c) = current;
                    % plot power
                    hsc = scatter(current,meanpower(c),2e2,'filled');
                    hsc.MarkerFaceColor = colorUse;
                    hsc.MarkerFaceAlpha = 0.6;
                    
                    % plot current in each scatter plot
                    ampwrite = sprintf('%0.1f',dat(c).current);
%                     text(current, meanpower(c), ampwrite);
                    
                    
                end
                % fit a regression line to current over 1ma
                idxcurrents = currents >= 1;
                currentsuse = currents(idxcurrents);
                poweruse    = meanpower(idxcurrents);
                p = polyfit(currentsuse,poweruse,1); % degree 1 linear
                yfit = polyval(p,currentsuse);
                y = poweruse;
                yresid = poweruse - yfit;
                SSresid = sum(yresid.^2);
                SStotal = (length(y)-1) * var(y);
                rsq = 1 - SSresid/SStotal;
                rsq_adj = 1 - SSresid/SStotal * (length(y)-1)/(length(y)-length(p));
                plot(currentsuse, yfit,'LineWidth',2,'Color',colorUse,'LineStyle','-.');
                rsquaredtxt = sprintf('r^2 = %.2f',rsq_adj);
                text(currentsuse(end) , yfit(end), rsquaredtxt);
                
                
                freqsuse = ff(idxuse);
                bandsused(1) = min(freqsuse);
                bandsused(2) = max(freqsuse);                ttluse = sprintf('%s +%s-%s (%d-%d Hz)',area,...
                    outRec(end).tdData(chanorder(cn)).plusInput,...
                    outRec(end).tdData(chanorder(cn)).minusInput,...
                       bandsused(1),   bandsused(2));

                title(strrep(ttluse,'_',' '));

%                 ylbtitle = sprintf('Power computed from TD (%d-%d Hz)',bandsused(1), bandsused(2));
%                ylabel(ylbtitle);

                ylabel('Power (log_1_0\muV^2/Hz)');
                xlabel('Current (mA)');
                set(gca,'FontSize',12);
            end
            
        end
        largeTitleUse = sprintf('%s %s',patient,side);
        largeTitleUse = strrep(largeTitleUse,'_',' ');
        sgtitle(largeTitleUse,'FontSize',24);
        
        % params to print the figures
        params.plotwidth           = 20;
        params.plotheight          = 20*0.6;
        params.figdir              = figdir;
        params.figtype             = '-djpeg';
        params.closeafterprint     = 0;
        params.resolution          = 300;
        fnmres = sprintf('%s_%s_power_from_time_domain_data.jpeg',patient,side);
        params.figname             = fnmres;
        plot_hfig(hfig,params);
    end
end
end





