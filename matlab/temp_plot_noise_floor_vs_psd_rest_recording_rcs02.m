function temp_plot_noise_floor_vs_psd_rest_recording_rcs02()
hfig = figure;
hsub(1) = subplot(2,2,1); hold on; % stn L 
hsub(1).Title.String = 'STN L';

hsub(2) = subplot(2,2,2); hold on; % stn R 
hsub(2).Title.String = 'STN R';

hsub(3) = subplot(2,2,3); hold on; % m1 L 
hsub(3).Title.String = 'M1 L';

hsub(4) = subplot(2,2,4); hold on; % m1 R 
hsub(4).Title.String = 'M1 R';

% L 404H and right is 398H
outdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/presentations/figures';

% load data 
rootDir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02';
sessionName = 'Session1557172456029';
fdirs = findFilesBVQX(rootDir,sessionName,struct('dirs',1)); 

frawMats = findFilesBVQX(fdirs{1},'RawDataAccel.mat');
frawJsons = findFilesBVQX(fdirs{1},'RawDataAccel.json');

titles = {'STN L','STN R','M1 L','M1 R'}; 
chansNoise = {'+0-0','+0-0','+9-9','+9-9'}; 
cnms = {'key0','key2'}; 
% XXX to get stuff in right order 
% L 404H and right is 398H
frawJsons = flipud(frawJsons);
% XXX 

cnt = 1; 
for f = 1:length(frawJsons) % loop on devices 
    [pn,fn] = fileparts(frawJsons{f});
    [outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerTable] =  ...
        MAIN_load_rcs_data_from_folder(pn);
    for i = 1:2
        
        szes = size(outdatcomplete,1);
        idxhalf = ceil(szes/2);
        timecut  = outdatcomplete.derivedTimes(idxhalf);
        idxuse = outdatcomplete.derivedTimes > timecut;
        hsb = hsub(cnt);
        
        cfnm = cnms{i}; 
        x = outdatcomplete.(cfnm)(idxuse);
        x =  x - mean(x);
        [fftOut,f]   = pwelch(x,1e3,1e3/2,0:1:500,1e3,'psd');
        clear x
        
        hplt = plot(hsb,f,log10(fftOut));
        hplt.LineWidth = 3;
        hplt.LineStyle = '-.';
        hplt.Color = [0.8 0 0 0.7];
        
        title(hsb,titles(cnt));
        xlabel(hsb,'Frequency (Hz)');
        ylabel(hsb,'Power  (log_1_0\muV^2/Hz)');
        set(hsb,'FontSize',16);
        res(f,i).fftOut = fftOut;
        res(f,i).f = f;
        cnt = cnt + 1;
    end
end
sgtitle('noise floor comparison rcs02','FontSize',25); 
% print 
hfig.PaperPositionMode = 'manual';
hfig.PaperSize         = [15 8]; 
hfig.PaperPosition     = [ 0 0 15 8]; 
fnmuse = fullfile(outdir,'factor_over_noise_floor.jpeg'); 
print(hfig,fnmuse,'-r300','-djpeg')
res(2).fftOut = fftOut; 
res(2).f =f;
save(fullfile(outdir,'results.mat'),'res');

figdir = outdir; 
figname = 'noise floor factor.fig';

savefig(hfig,fullfile(figdir,figname)); 




%% load noise floor dat a 
rawfn = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS_test/noise-floor-test-2/RCS-tests-Oct9-2018/test31/Session1539112319744/DeviceNPC700395H/RawDataTD.mat';
[pn,fn] = fileparts(rawfn); 

load(rawfn);



%% plot noise floor data  
szes = size(outdatcomplete,1);
idxhalf = ceil(szes/2);
timecut  = outdatcomplete.derivedTimes(idxhalf);
idxuse = outdatcomplete.derivedTimes > timecut; 
x = outdatcomplete.key0(idxuse); 
x =  x - mean(x); 
[fftOut,f]   = pwelch(x,1e3,1e3/2,0:1:250,1e3,'psd');
clear x 

hplt = plot(hsub(1),f,log10(fftOut));
hplt.LineWidth = 3; 
hplt.LineStyle = '-.';
hplt.Color = [0.8 0 0 0.7];
hStn(1) = hplt;
title(hsub(1),'LFP');
xlabel(hsub(1),'Frequency (Hz)');
ylabel(hsub(1),'Power  (log_1_0\muV^2/Hz)'); 
set(hsub(1),'FontSize',16);
res(1).fftOut = fftOut; 
res(1).f = f; 

x = outdatcomplete.key2(idxuse); 
x =  x - mean(x); 
[fftOut,f]   = pwelch(x,1e3,1e3/2,0:1:250,1e3,'psd');
clear x 
hplt = plot(f,log10(fftOut));

hplt.LineWidth = 3; 
hplt.Color = [0.8 0 0 0.7];
hplt.LineStyle = '-.';
hM1(1) = hplt;
res(2).fftOut = fftOut; 
res(2).f = f; 

title(hsub(2),'ECOG');
xlabel(hsub(2),'Frequency (Hz)');
ylabel(hsub(2),'Power  (log_1_0\muV^2/Hz)'); 
set(hsub(2),'FontSize',16);

%% load rc+s
load('/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v06-home-visit-3-week/rc+s_data/rcs_comp/Session1541438482992/DeviceNPC700395H/off meds.mat')


%% plot rc+s 
x = outdatachunk.key1; 
x =  x - mean(x); 
[fftOut,f]   = pwelch(x,1e3,1e3/2,0:1:250,1e3,'psd');
clear x 

hplt = plot(hsub(1),f,log10(fftOut));
hplt.LineWidth = 3; 
hplt.Color = [0 0 0.8 0.7];
hStn(2) = hplt;
res(3).fftOut = fftOut; 
res(3).f = f; 


x = outdatachunk.key3; 
x =  x - mean(x); 
[fftOut,f]   = pwelch(x,1e3,1e3/2,0:1:250,1e3,'psd');
res(4).fftOut = fftOut; 
res(4).f = f; 
clear x 
hplt = plot(f,log10(fftOut));
hplt.LineWidth = 3; 
hplt.Color = [0 0 0.8 0.7];
hM1(2) = hplt;

%% legend 
legend(hM1,{'+8-8','+9-11'});
legend(hStn,{'+0-0','+1-3'});

% print 
hfig.PaperPositionMode = 'manual';
hfig.PaperSize         = [15 8]; 
hfig.PaperPosition     = [ 0 0 15 8]; 
fnmuse = fullfile(outdir,'noisefloorpsd.jpeg'); 
print(hfig,fnmuse,'-r300','-djpeg')
save(fullfile(outdir,'results.mat'),'res');

%% plot multiple 
hfig = figure;
hsub(1) = subplot(2,1,1); hold on; % stn 
title('STN') 
hplt = plot(res(1).f, res(3).fftOut ./ res(1).fftOut);
hplt.LineWidth = 3; 
hplt.Color = [0.8 0 0 0.7];
ylabel('Factor over noise floor'); 
set(gca, 'YScale', 'log')

set(hsub(1),'FontSize',16);
axis tight 
minval = min(res(3).fftOut ./ res(1).fftOut); 
sprintf('m1 min val %.2f',minval);
hsub(2) = subplot(2,1,2); hold on; % m1 

title('M1') 
hplt = plot(res(2).f, res(4).fftOut ./ res(2).fftOut );
set(gca, 'YScale', 'log')

minval = min(res(4).fftOut ./ res(2).fftOut); 
sprintf('m1 min val %.2f',minval);
hplt.LineWidth = 3; 
hplt.Color = [0.8 0 0 0.7];
ylabel('Factor over noise floor'); 
set(hsub(2),'FontSize',16);
axis tight 
% print 
hfig.PaperPositionMode = 'manual';
hfig.PaperSize         = [15 8]; 
hfig.PaperPosition     = [ 0 0 15 8]; 
fnmuse = fullfile(outdir,'factor_over_noise_floor.jpeg'); 
print(hfig,fnmuse,'-r300','-djpeg')
res(2).fftOut = fftOut; 
res(2).f =f;
save(fullfile(outdir,'results.mat'),'res');

figdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v06-home-visit-3-week/figures';
figname = 'noise floor factor.fig';
savefig(hfig,fullfile(figdir,figname)); 

