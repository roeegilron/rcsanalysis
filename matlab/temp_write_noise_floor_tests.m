%% rerun data 
rootdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS_test/noise-floor-test-3- 37c-incub';
ff = findFilesBVQX(rootdir,'Raw*.mat');
for f = 1:length(ff)
    rawfn = ff{f};
    noise_floor_temp(rawfn)
end
outdir = rootdir; 
close all; 
%% load data 
titls = {...
    'Fs = 1e3Hz Mode 3 with ratio 32',...
    'Fs = 1e3Hz Mode 4 with ratio 4',...
    'Fs=500Hz mode 4 and ratio 4',...
    'Fs=500Hz mode 4 and ratio 32'}; 


ff = findFilesBVQX(rootdir,'results.mat');

%% plot data 
hfig = figure;
alpha = 0.8; 
colors = [0.8 0.0 0.0 alpha;...
    0.0 0.8 0.0 alpha;...
    0.0 0.0 0.8 alpha;...
    0.8 0.2 0.8 alpha];

for f = 1:length(ff)
    load(ff{f});
    hsb(1) = subplot(2,1,1);
    hold on;
    hplt = plot(res(1).f,log10(res(1).fftOut));
    hplt.LineWidth = 3;
    hplt.Color = colors(f,:);
    title('Noise Floor Channel 0');
    xlabel('Frequency (Hz)');
    ylabel('Power  (log_1_0\muV^2/Hz)');
    set(gca,'FontSize',16);
    
    
    hsb(2) = subplot(2,1,2);
    hold on;
    hplt = plot(res(2).f,log10(res(2).fftOut));
    hplt.LineWidth = 3;
    hplt.Color = colors(f,:);
    title('Noise Floor Channel 1');
    xlabel('Frequency (Hz)');
    ylabel('Power  (log_1_0\muV^2/Hz)');
    set(gca,'FontSize',16);
    clear res; 

end
legend(hsb(1),titls);
legend(hsb(2),titls);
linkaxes(hsb,'x'); 

hfig.PaperPositionMode = 'manual';
hfig.PaperSize         = [15 8]; 
hfig.PaperPosition     = [ 0 0 15 8]; 
fnmuse = fullfile(outdir,'noisefloorpsd.jpeg'); 
print(hfig,fnmuse,'-r300','-djpeg')
