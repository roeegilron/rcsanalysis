function betaOverTimeAnalysis()
%% load data
clear all;
clc;
fn{1} = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v06-home-visit-3-week/rc+s_data/rcs_comp/Session1541438482992/DeviceNPC700395H/off_meds_long.mat';
fn{2} = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v06-home-visit-3-week/rc+s_data/rcs_comp/Session1541451381569/DeviceNPC700395H/on_meds_long_section.mat';

% 20 minutes off meds
% 52 minutes on meds

%%
hfig = figure;
for c = 1:4
    hsub(c) = subplot(2,2,c);
    hold on;
end;
for m = 1:length(fn)% loop on meds stats 
    load(fn{m});
    % calc data to average
    windowsize = 1024;
    srate = unique( outdatachunk.samplerate );
    for c = 1:4 % loop on channels
        fnm = sprintf('key%d',c-1);
        y = outdatachunk.(fnm);
        y = y - mean(y);
        stop = 0;
        idxuse = 1:1:1024;
        cnt = 1;
        while ~ stop
            if idxuse(end) > length(y)
                stop = 1;
                break;
            end
            Fs = 500;            % Sampling frequency
            T = 1/srate;             % Sampling period
            L = 1024;             % Length of signal
            
            Y = fft((y(idxuse)-mean(y(idxuse))).*hanning(1024));
            P2 = abs(Y/L);
            P1 = P2(1:L/2+1);
            P1(2:end-1) = 2*P1(2:end-1);
            P1 = 10*log10(P1);
            P1out(cnt,:) = P1;
            cnt = cnt + 1;
            idxuse = idxuse + srate/2;
        end
        res(m).(fnm) = P1out;
        clear P1out
    end
    
    % plot averages
    f = Fs*(0:(L/2))/L;
    for c = 1:4
        axes(hsub(c)); 
        fnm = sprintf('key%d',c-1);
        pout = res(m).(fnm);
        hsbrs(m,c) = shadedErrorBar(f,pout,{@median,@(x) std(x)*1.96},'lineprops',{'r','markerfacecolor','k'});
        title(outRec.tdData(c).chanFullStr);
    end
end
% format colors 
clrs(1,:) = [0.8 0 0];% off meds
clrs(2,:) = [0 0.8 0];% on meds
alphaLine = 0.9;
alphaFace = 0.1; 
lw = 3; 
for m = 1:2
    for c = 1:4
        hsbrs(m,c).mainLine.Color = [clrs(m,:) alphaLine]; 
        hsbrs(m,c).mainLine.LineWidth = lw; 
        hsbrs(m,c).patch.MarkerFaceColor = clrs(m,:); 
        hsbrs(m,c).patch.FaceColor = clrs(m,:); 
        hsbrs(m,c).patch.FaceAlpha = alphaFace; 
        
    end
end
linkaxes(hsub,'x');
xlim([0 200]); 
prfig.plotwidth           = 15;
prfig.plotheight          = 15; 
prfig.figdir              = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v06-home-visit-3-week/figures';
prfig.figtype             = '-djpeg';
prfig.closeafterprint     = 0; 
prfig.resolution          = 300; 
prfig.figname             = 'med off vs on variability'; 
% plot_hfig(hfig,prfig); 

%% plot histogram according to update rates 
updateRates = [1 5 10 20 30]; 
binsForUpdr = [0.5, 0.1,0.1,0.1, 0.1];
binwidth    = [2 5 10]; 

centerFreq  = [15.5, 15.5 18.5 19.5]; 


for b = 1:length(binwidth)
    for u = 1:length(updateRates)
        
        hfig = figure;
        for c = 1:4 % loop on channels
            hsub(c) = subplot(2,2,c); hold on; 
            for m = 1:2
                fnm = sprintf('key%d',c-1);
                pout = res(m).(fnm);
                idxf = f > centerFreq(c) - binwidth(b)/2 & f < centerFreq(c) + binwidth(b)/2;
                power = mean(pout(:,idxf),2);
                ur = updateRates(u); 
                pwrTrun = power(1:(length(power)-rem(length(power),ur)));
                reshpPower = reshape(pwrTrun,length(pwrTrun)/ur,ur);
                powerUse = mean(reshpPower,2);
                h = histogram(powerUse,'BinWidth',binsForUpdr(u),'Normalization','probability'); 
                h.FaceColor = clrs(m,:); 
                h.FaceAlpha = 0.5;
                xlabel('beta power');
                ylabel('prob.'); 
                title(outRec.tdData(c).chanFullStr);
            end
            legend({'off meds','on meds'});
        end
        ttluse = sprintf('ur = %d (%.2f secs) bw = %d (n = %d)',...
            updateRates(u),...
            (updateRates(u)*1024)/srate,...
            binwidth(b),...
            length(reshpPower));
        suptitle(ttluse); 
        % save figure
        prfig.figname = sprintf('med histograms ur - %0.2d bw %0.2d',updateRates(u),binwidth(b));
%         plot_hfig(hfig,prfig); 
    end
end

%% do this only for stn 1-3 in subplot fashion for poster presenation
updateRates = [1  30]; 
binsForUpdr = [0.5, 0.1,0.1,0.1, 0.1];
binwidth    = [2  10]; 
bins        = [2 60]; % in seconds

centerFreq  = [15.5, 15.5 18.5 19.5]; 

c = 2; % chan 1-1
hfig = figure;
hsub(1) = subplot(2,2,2);
hsub(2) = subplot(2,2,4);
hsub(3) = subplot(2,2,[1 3]);
fs = 40;
hold on;
for i = 1:2
    u =i; % update rate 1
    ur = updateRates(u);
    b = 1; % bw 1;
    axes(hsub(i));
    hold on;
    for m = 1:2
        
        
        fnm = sprintf('key%d',c-1);
        pout = res(m).(fnm);
        idxf = f > centerFreq(c) - binwidth(b)/2 & f < centerFreq(c) + binwidth(b)/2;
        power = mean(pout(:,idxf),2);
        ur = updateRates(u);
        pwrTrun = power(1:(length(power)-rem(length(power),ur)));
        reshpPower = reshape(pwrTrun,length(pwrTrun)/ur,ur);
        powerUse = mean(reshpPower,2);
        h = histogram(powerUse,'BinWidth',binsForUpdr(u),'Normalization','probability');
        h.FaceColor = clrs(m,:);
        h.FaceAlpha = 0.5;
        xlabel('beta power (a.u.)');
        ylabel('Prob. (%)');
        ttluse = sprintf('STN on/off meds - %d bins',bins(i));
        title(ttluse);
    end
    legend({'off meds','on meds'});
    set(gca,'FontSize',fs);
end
% plot general med effect 
axes(hsub(3));
hold on;
fnm = 'key1';
for m = 1:2
    pout = res(m).(fnm);
    power = mean(pout,1);
    hplt = plot(f,power);
    hplt.Color = [clrs(m,:) 0.7];
    hplt.LineWidth = 3;
end
legend({'off meds','on meds'});
ylabel(hsub(3),'Power (log_1_0\muV^2/Hz)');
xlabel(hsub(3),'Frequency (Hz)');

title('STN medication effect - 1 hour average');
set(gca,'FontSize',fs);
xlim([1 100]); 

% plot hfig
p.plotwidth           = 450/10;
p.plotheight          = 139/10;
p.figdir              = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v06-home-visit-3-week/figures';
p.figname             = 'STN med effects';
p.figtype             = '-dpdf';
p.closeafterprint     = 1;
hfig.PaperSize = [p.plotwidth p.plotheight];
hfig.Units = 'centimeters';
hfig.PaperPositionMode = 'manual';
plot_hfig(hfig,p);
