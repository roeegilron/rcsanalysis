%% set up video 
close all; clear all;
hfig = figure; 
hfig.Color = 'w';

%% plot raw data 
% simulate freq bands 
x = linspace(1,100,1e3); 
y = ones(1,1000);
% y(1:10) = y(1:10)./(x(1:10).^4); 
% y(11:end) = y(11:end)./(x(11:end).^2); 
y(1:end) = y(1:end)./(x(1:end).^4); 
baselinePSD = log10(y);

%% start with no oscilationrs 
% hline = plot(x,baselinePSD);
% hline.LineWidth = 4; 
% hline.Color    = [0.9 0 0 0.6]; 
xlabel('Frequency (Hz'); 
ylabel('Power  (log_1_0\muV^2/Hz)');
title('Oscillatory activity correlates with specific motor signs'); 
set(gca,'FontSize',20);

ylim = get(gca,'YLim');
ydat = [ylim(2) ylim(2) ylim(1) ylim(1)];

%% add each oscilation in turn (each seperatly
% add oscilation 
freqs = [... 
         7 13;...
         15 30;...
         75 85]; 
height = [0.8 1.5 2 3]; 
numsecondsPerOscilation = 0.1;

handles.freqranges = freqs;
cuse = parula(size(handles.freqranges,1));
patchTitle = {'Tremor','Levodopa med state, movement','Dyskinesia'};
tempPSD = baselinePSD;
for f = 1:size(freqs,1)
    hold on;
    if f == 1
    end
    heights = 2.85;
    for i = 1:length(heights)
        if i ==1 
            % plot the patch first
            freq = handles.freqranges(f,:);
            xdat = [freq(1) freq(2) freq(2) freq(1)];
            handles.hPatches(f) = patch('XData',xdat,'YData',[1 1 -8 -8],'YLimInclude','off');
            handles.hPatches(f).Parent = gca;
            handles.hPatches(f).FaceColor = cuse(f,:);
            handles.hPatches(f).FaceAlpha = 0.3;
            handles.hPatches(f).EdgeColor = 'none';
            handles.hPatches(f).Visible = 'on';

        end
        idxuse = x > freqs(f,1) & x < freqs(f,2);
        win = blackmanharris(sum(idxuse==1));
        win = win.* heights(i);
%         tempPSD = baselinePSD;
       
        tempPSD(idxuse) = tempPSD(idxuse)+win';
        drawnow;
        if f == size(freqs,1)
            hline = plot(x,tempPSD);
            hline.LineWidth = 4;
            hline.Color    = [0.9 0 0 0.6];
            xlabel('Frequency (Hz');
            ylabel('Power  (log_1_0\muV^2/Hz)');
            title('Oscillatory activity correlates with specific motor signs');
            set(gca,'FontSize',20);
        end

%         writeVideo(v,fullVidFrame);
    end
end
legend(handles.hPatches,patchTitle);

%% 

figdirout = '/Users/roee/Box/rcs paper paper on first five bilateral implants/revision for nature biotechnology/figures/Fig5_states_estimates_group_data_and_ AUC';
prfig.plotwidth           = 8;
prfig.plotheight          = 7;
prfig.figdir              = figdirout;
prfig.figname             = 'Fig5_simulated_freqs';
prfig.figtype             = '-dpdf';
plot_hfig(hfig,prfig)
