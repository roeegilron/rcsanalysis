%% set up video 
close all;
hfig = figure; 
hfig.Color = 'w';
v = VideoWriter('simulated_oscilatory_phenomena','MPEG-4'); 
aspectRatio = [16 9];
hfig.Position =  [1000         306        aspectRatio(1)*70        aspectRatio(2)*70];
v.Quality = 100; 
open(v); 


%% plot raw data 
% simulate freq bands 
x = linspace(1,100,1e3); 
y = ones(1,1000);
% y(1:10) = y(1:10)./(x(1:10).^4); 
% y(11:end) = y(11:end)./(x(11:end).^2); 
y(1:end) = y(1:end)./(x(1:end).^4); 
baselinePSD = log10(y);

%% start with no oscilationrs 
hline = plot(x,baselinePSD);
hline.LineWidth = 4; 
hline.Color    = [0.9 0 0 0.6]; 
xlabel('Frequency (Hz'); 
ylabel('Power  (log_1_0\muV^2/Hz)');
title('Oscillatory activity correlates with specific motor signs'); 
set(gca,'FontSize',20);

numseconds = 3;
for i = 1:(numseconds*v.FrameRate)
    fullVidFrame = getframe(hfig);
    writeVideo(v,fullVidFrame);
end
ylim = get(gca,'YLim');
ydat = [ylim(2) ylim(2) ylim(1) ylim(1)];

%% add each oscilation in turn (each seperatly
% add oscilation 
freqs = [4 6;...
         7 13;...
         15 30;...
         75 85]; 
height = [0.8 1.5 2 3]; 
numsecondsPerOscilation = 0.5;

handles.freqranges = freqs;
cuse = parula(size(handles.freqranges,1));
patchTitle = {'Dystonia','Tremor','Levodopa med state, movement','Dyskinesia'};
for f = 1:size(freqs,1)
    cla(gca);
    hold on;
    if f == 1
    end
    heights = [linspace(0,height(f).*0.4,numsecondsPerOscilation*v.FrameRate), ...
               fliplr(linspace(0,height(f).*0.4,numsecondsPerOscilation*v.FrameRate)), ...
               linspace(0,height(f).*0.8,numsecondsPerOscilation*v.FrameRate), ...
               fliplr(linspace(0,height(f).*0.8,numsecondsPerOscilation*v.FrameRate)), ...
               linspace(0,height(f).*0.6,numsecondsPerOscilation*v.FrameRate), ...
               fliplr(linspace(0,height(f).*0.6,numsecondsPerOscilation*v.FrameRate)), ...
               linspace(0,height(f).*0.8,numsecondsPerOscilation*v.FrameRate), ...
               fliplr(linspace(0,height(f).*0.8,numsecondsPerOscilation*v.FrameRate)), ...
               linspace(0,height(f).*0.95,numsecondsPerOscilation*v.FrameRate),...
                fliplr(linspace(0,height(f).*0.95,numsecondsPerOscilation*v.FrameRate))];
    for i = 1:length(heights)
        if i ==1 
            % plot the patch first
            freq = handles.freqranges(f,:);
            xdat = [freq(1) freq(2) freq(2) freq(1)];
            handles.hPatches(f) = patch('XData',xdat,'YData',ydat,'YLimInclude','off');
            handles.hPatches(f).Parent = gca;
            handles.hPatches(f).FaceColor = cuse(f,:);
            handles.hPatches(f).FaceAlpha = 0.3;
            handles.hPatches(f).EdgeColor = 'none';
            handles.hPatches(f).Visible = 'on';

            hline = plot(x,baselinePSD);
            hline.LineWidth = 4;
            hline.Color    = [0.9 0 0 0.6];
            xlabel('Frequency (Hz');
            ylabel('Power  (log_1_0\muV^2/Hz)');
            title('Oscillatory activity correlates with specific motor signs');
            set(gca,'FontSize',20);
            legend(handles.hPatches(f),patchTitle{f});
        end
        idxuse = x > freqs(f,1) & x < freqs(f,2);
        win = blackmanharris(sum(idxuse==1));
        win = win.* heights(i);
        tempPSD = baselinePSD;
        tempPSD(idxuse) = baselinePSD(idxuse)+win';
        hline.YData = tempPSD;
        drawnow;
        fullVidFrame = getframe(hfig);
%         writeVideo(v,fullVidFrame);
    end
end

%% plot all oscilations together 

% add oscilation 
freqs = [4 6;...
         7 13;...
         15 30;...
         75 85]; 
height = [0.8 1.5 2 3]; 
numsecondsPerOscilation = 0.5;

handles.freqranges = freqs;
cuse = parula(size(handles.freqranges,1));
patchTitle = {'Dystonia','Tremor','Levodopa med state, movement','Dyskinesia'};

numSteps = 5;
heights = zeros(size(freqs,1), numsecondsPerOscilation*v.FrameRate*(numSteps*2));

% step to these heigths 
stepTo = [0.8 0.6 0.8 0.2 0.1;... % dystonia
          0.4 0.6 0.8 0.2 0.2;... % tremor
          0.4 0.6 0.8 0.2 0.2;... % levodopa
          0.1 0.2 0.1 0.9 0.95]; % dyskinesia
for f = 1:size(freqs,1)
    for i = 1:numSteps
        startAt = size(heights,2)/numSteps;
        if i ==1 
            idxcolms = 1 : 1 : (startAt);
        else
            idxcolms = startAt*(i-1) : 1 : (startAt*(i-1) + startAt-1);
        end
        heights(f,idxcolms) = [linspace(0,height(f).* stepTo(f,i),numsecondsPerOscilation*v.FrameRate), ...
            fliplr(linspace(0,height(f).*stepTo(f,i),numsecondsPerOscilation*v.FrameRate))];
    end
end
  
            
cla(gca);

for i = 1:size(heights,2)
    if i ==1
        % plot the patch first
        handles.freqranges = freqs;
        cuse = parula(size(handles.freqranges,1));
        
        for p = 1:size(handles.freqranges,1)
            freq = handles.freqranges(p,:);
            xdat = [freq(1) freq(2) freq(2) freq(1)];
            handles.hPatches(p) = patch('XData',xdat,'YData',ydat,'YLimInclude','off');
            handles.hPatches(p).Parent = gca;
            handles.hPatches(p).FaceColor = cuse(p,:);
            handles.hPatches(p).FaceAlpha = 0.3;
            handles.hPatches(p).EdgeColor = 'none';
            handles.hPatches(p).Visible = 'on';
        end
        hline = plot(x,baselinePSD);
        hline.LineWidth = 4;
        hline.Color    = [0.9 0 0 0.6];
        xlabel('Frequency (Hz');
        ylabel('Power  (log_1_0\muV^2/Hz)');
        title('Oscillatory activity correlates with specific motor signs');
        set(gca,'FontSize',20);
        hold on;
    end
    legend(handles.hPatches,{'Dystonia','Tremor','Levodopa med state, movement','Dyskinesia'}); 
    tempPSD = baselinePSD;
    for  f = 1:size(freqs,1)
        idxuse = x > freqs(f,1) & x < freqs(f,2);
        win = blackmanharris(sum(idxuse==1));
        win = win.* heights(f,i);
        tempPSD(idxuse) = baselinePSD(idxuse)+win';
    end
    
    hline.YData = tempPSD;
    drawnow;
    fullVidFrame = getframe(hfig);
    writeVideo(v,fullVidFrame);
end

%%

close(v);
close(hfig);
return 

%% 
    fullVidFrame = getframe(hfig);
    writeVideo(v,fullVidFrame);


% add oscilation 
freqs = [4 6;...
         7 13;...
         15 30;...
         75 85]; 
height = [0.8 1.5 2 3]; 
for f = 1:size(freqs,1)
    idxuse = x > freqs(f,1) & x < freqs(f,2);
    win = blackmanharris(sum(idxuse==1));
    win = win.*height(f);
    rawpsd(idxuse) = rawpsd(idxuse)+win';
end

hfig = figure;
% thnen plot line
hline = plot(x,rawpsd);
hline.LineWidth = 4; 
hline.Color    = [0.9 0 0 0.6]; 


% plot patches first
handles.freqranges = freqs;
handles.freqnames  = {'Delta', 'Theta', 'Alpha','LowBeta','HighBeta','LowGamma','HighGamma'}';
cuse = parula(size(handles.freqranges,1));
ylim = get(gca,'YLim');
ydat = [ylim(2) ylim(2) ylim(1) ylim(1)];
for p = 1:size(handles.freqranges,1)
    freq = handles.freqranges(p,:);
    xdat = [freq(1) freq(2) freq(2) freq(1)];
    handles.hPatches(p) = patch('XData',xdat,'YData',ydat,'YLimInclude','off');
    handles.hPatches(p).Parent = gca;
    handles.hPatches(p).FaceColor = cuse(p,:);
    handles.hPatches(p).FaceAlpha = 0.3;
    handles.hPatches(p).EdgeColor = 'none';
    handles.hPatches(p).Visible = 'on';
end
hold on;


xlabel('Frequency (Hz'); 
ylabel('Power  (log_1_0\muV^2/Hz)');
legend(handles.hPatches,{'Dystonia','Tremor','Levodopa med state, movement','Dyskinesia'}); 
title('Frequency bands "fingerprint" diverse array of motor signs'); 
set(gca,'FontSize',20);


hfig.PaperPositionMode = 'manual';
hfig.PaperSize = [10 16/2];
hfig.PaperPosition = [ 0 0 10 16/2];


dirname = '/Users/roee/Starr_Lab_Folder/Presenting/Posters/Gilron_DBS_2018/figures';
% save as figure 
fn = 'oscilatory-phnemona.fig';
saveas(hfig,fullfile(dirname,fn));
% save as pdf 
fn = 'oscilatory-phnemona.pdf';

fnmsave = fullfile(dirname, fn); 
print(hfig,fnmsave,'-dpdf');
close(hfig);


