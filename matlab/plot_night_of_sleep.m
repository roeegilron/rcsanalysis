function plot_night_of_sleep()
%% load night of sleep
dirname = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS05/v05_3week/data_dump/SummitContinuousBilateralStreaming/RCS05L/Session1565065870905/DeviceNPC700414H';
[outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerTable] =  MAIN_load_rcs_data_from_folder(dirname);
%%
for c = 1:4 % loop on channels 
    fnm = sprintf('key%d',c-1);
    y = outdatcomplete.(fnm);
    y = y - mean(y);
    % plot gausian spectrogram 
    srate = unique(outdatcomplete.samplerate);
    res(c) = compute_spectrogram_gaussian_sleep(y,srate); 
    [fftOut,f]   = pwelch(y,srate,srate/2,0:1:srate/2,srate,'psd');
    fout(c).f = f; 
    fout(c).fftOut = log10(fftOut); 
end


%% plot spectroram 
hfigSpect = figure;
npltrows = 4; 
npltclms =1; 
t = hour(hour(outdatcomplete.derivedTimes)); 

for c = 1:4
    hsub(c) = subplot(npltrows,npltclms,c); 
    f = res(c).center_frequencies; 
    s = res(c).analytic_signal; 
    imagesc('XData',t,'YData',f,'CData',10*log10(abs(s)));
    axis tight 
    shading interp 
    title( hsub(c),outRec(1).tdData(c).chanFullStr );
    xlabel('Seconds');
    ylabel('Frequency (Hz)');
end
linkaxes(hsub,'xy');


axsUse = {'X','Y','Z'};
for i = 1:3
    fnm = sprintf('%sSamples',axsUse{i});
    y = outdatcompleteAcc.(fnm);
    y = y - mean(y);
    datAcc(:,i) = y';
end


%%

figure;
subplot(2,1,1); 
srate = 250;
windowUse = srate * 10; cl
overlapFac = 0.875; 
frerange = [0.5:0.5:4 4:1:10 10:2:40];
y = outdatcomplete.key2;
y = y -mean(y); 
spectrogram(y,windowUse,ceil(overlapFac*window),frerange,srate,'yaxis','power');
shading interp 

subplot(2,1,2); 

rescaledData = processActigraphyData(datAcc,64);
timeAcc = seconds(outdatcompleteAcc.derivedTimes-outdatcompleteAcc.derivedTimes(1)); 
plot(timeAcc,rescaledData); 



movingwin=[0.5 0.05]; % set the moving
%window dimensions
params.Fs = 250; % sampling frequency
params.fpass=[0 40]; % frequencies ofinterest
params.tapers = [5 9]; % tapers
params.trialave = 1; % average over trials
params.err = 0; % no error
data = y; 
[S1,t,f] = mtspecgramc(data,movingwin,params); % computespectrogram
figure;
plot_matrix(S1,t,f);
xlabel([]); % plot spectrogram
caxis([-60 -30]);
colorbar;

rescaledData = processActigraphyData(data,sr)


doc spectrogram
end