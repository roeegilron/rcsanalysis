function res = compute_spectrogram_gaussian(data,fs)
%% params
params.minimum_frequency = 0.1; %lowest freq to examine
params.maximum_frequency = 120; %highest freq to examine (remember Nyquist! <samplingrate/2 at least!)
params.number_of_frequencies = 50; %number of frequencies to look at
params.minimum_frequency_step_size = 0.5;
params.fractional_bandwidth = .35; %this sets the width of the gaussian for filtering. recommend between .2-.35
params.output_type = 'analytic_signal';
% picking frequencies to break up into
center_frequencies=...
    make_center_frequencies(...  %generates a 128 point vector from min to max freq
    params.minimum_frequency,...           %with step size at least step size
    params.maximum_frequency,...          %and more spacing at the higher freq
    params.number_of_frequencies,...
    params.minimum_frequency_step_size)';
%%
tic; 
datUse = data;
for frequency_index = 1:params.number_of_frequencies %loops through one freq at a time
    disp(params.number_of_frequencies - frequency_index+1);
    analytic_signal(frequency_index,:)=...
        gaussian_filter_signal(...
        'output_type',...
        params.output_type,...
        'raw_signal',...
        datUse',...
        'sampling_rate',...
        fs,...
        'center_frequency',...
        center_frequencies(frequency_index),...
        'fractional_bandwidth',...
        params.fractional_bandwidth);
end
res.center_frequencies = center_frequencies;
res.analytic_signal = analytic_signal;
res.params = params; 
return;
%%
fnms = fullfile(fldrname,'spectral_results.mat');
analytic_signal = analytic_signal';
save(fnms,'params','analytic_signal'); 



figure;
stdErrorFun = @(x) std(x)./sqrt(size(x,1)) ;
stdErr = std(analytic_signal');
figure;
hsb = shadedErrorBar(center_frequencies,mean(analytic_signal,2),[stdErr; stdErr]);

%% plot first 10 
anaSigUse = analytic_signal;
anaSigUse = movmean(analytic_signal,[250 0],2); 
hfig = figure; 
numplots = 10; 
cnts = 1:3:21;
for i = 1:numplots
    hsub(i) = subplot(numplots,1,i,'Parent',hfig); 
    plot(outdatcomplete.derivedTimes,abs(anaSigUse(cnts(i),:)));
    ttl = sprintf('center freq = %.2f',center_frequencies(i)); 
    title(ttl); 
end
linkaxes(hsub); 
%%
figure;
p = abs(anaSigUse(1:20,:)); 
pcolor(outdatcomplete.derivedTimes,center_frequencies(1:20), p);
%%

D = pdist(analytic_signal,'spearman'); 




%% plot 
hfig = figure; 
t = (0:1:1e4-1)./500;
f = center_frequencies;
pcolor(t, f,log10(analytic_signal));
shading interp
axis tight 
view(2);
end