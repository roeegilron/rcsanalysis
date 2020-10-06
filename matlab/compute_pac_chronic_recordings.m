function compute_pac_chronic_recordings()
%% add paths
addpath(genpath('/Users/roee/Documents/Code/PAC'));
rootdir = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/processed_data/';
% load('/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/processed_data/RCS10_R_processedData__stim_off.mat')
load('/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/processed_data/RCS02_L_processedData__stim_off.mat');
%% transform data 
for i = 1:length( tdProcDat )
    for c = 1:4
        fn = sprintf('key%d',c-1);
        if size(tdProcDat(i).(fn),1) < size(tdProcDat(i).(fn),2)
            tdProcDat(i).(fn) = tdProcDat(i).(fn)';
        end
    end
end
%%
for c = 1:4
    start = tic;
    fn = sprintf('key%d',c-1);
    dat = [tdProcDat.(fn)];
    datOut{c} = dat;
end
%%
prms.PhaseFreqVector = 2:2:50;
prms.AmpFreqVector   = 5:1:70;
prms.useparfor   = 1;
prms.filteruse = 'fir1';
prms.plotdata = 0;
prms.regionnames = {'STN 0-2','MC 8-10'};
idxuse = 250:1:350;
clear res;
for i = 1:size(idxuse,2)
    start = tic;
    datuse = [datOut{1}(:,idxuse(i)), datOut{3}(:,idxuse(i))];
    res(i,:) = computePAC(datuse',250,prms);
    times(i) = toc(start);
end
% comod = []; zcomod = [];
% for r = 1:length(res)
%     comod(:,:,r) = res(r).Comodulogram;
%     zcomod(:,:,r) = res(r).zComodulogram;
% end
%%
hfig = figure;
hfig.PaperPositionMode = 'manual';
hfig.PaperSize         = [16 9]; 
hfig.PaperPosition     = [ 0 0 16 9]; 

hfig.Color = 'w';
fnm = fullfile('/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/processed_data/vidExampleRCS02_all.mp4');
v = VideoWriter(fnm,'MPEG-4');
v.FrameRate = 7; 
open(v);

for i = 1:size(res,1)
    for j = 1:size(res,2)
        subplot(2,2,j);
        results = res(i,j);
        aa = 1;
        Com_reshaped = results(aa).Comodulogram;
        zcom = results(aa).zComodulogram;
        idxover = zcom < -1.5 | zcom > 1.5;
        Com_reshaped(~idxover) = 0;
        AmpFreq_BandWidth = results(aa).AmpFreq_BandWidth;
        AmpFreqVector = results(aa).AmpFreqVector;
        PhaseFreq_BandWidth  = results(aa).PhaseFreq_BandWidth;
        PhaseFreqVector  = results(aa).PhaseFreqVector;
        ttlAmp = results(aa).ttlAmp;
        PhaseArea = results(aa).PhaseArea;
        contourf(PhaseFreqVector+PhaseFreq_BandWidth/2,AmpFreqVector+AmpFreq_BandWidth/2,Com_reshaped',30,'lines','none')
        set(gca,'fontsize',10)
        ttly = sprintf('Amplitude Frequency %s (Hz)',ttlAmp);
        ylabel(ttly)
        ttlx = sprintf('Phase Frequency %s (Hz)',PhaseArea);
        xlabel(ttlx)
        title(sprintf('%s',tdProcDat(idxuse(i)).timeStart));
    end
    % grab frame
    frame = getframe(hfig);
    writeVideo(v,frame);
    
end

close(v);
close(hfig);

return;

%%
  


%%

%% number samples 
x = [33503
3244
5348
4877
3401
5657
1901
16348
1598
27117
903
28624
1790
12408
5355
27755
3695];

hoursCompute = ((numRecs * 0.78)/60)/60;
hoursUse = hoursCompute * 4;
% 160 hours for all combos (within between etc.). 
% multiple by 5000 for reasonable amount of surrogates 
% 6.66 days for one run 

% without running surrogates 
end