function temp_plot_pain_tooth_brushing()
%%
fn1 = '/Volumes/RCS_DATA/RCS_pain/RCS04_1984.mat';
load(fn1)

% 59 RMotor1	A59	premotor
% 60 RMotor2	A60	premotor
% 61 RMotor3	A61	Motor Ctx - Hand knob
% 62 RMotor4	A62	Motor Ctx - Hand knob
% 63 RMotor5	A63	Sensory Ctx
% 64 RMotor6	A64	Sensory Ctx

%% 

ch_alt_names = {};
ch_alt_names{59} = '1 premotor';
ch_alt_names{60} = '2 premotor';
ch_alt_names{61} = '3 Motor Ctx - Hand knob';
ch_alt_names{62} = '4 Motor Ctx - Hand knob';
ch_alt_names{63} = '5 Sensory Ctx';
ch_alt_names{64} = '6 Sensory Ctx';


%%
hfig = figure;
hfig.Color = 'w'; 

sr = 1e4; 
idxuse = nchoosek([59:1:64],2);
for i = 1:size(idxuse,1);
    hsb(i) = subplot(4,4,i);
    dat = data(idxuse(i,1),:) - data(idxuse(i,2),:);
    [fftOut,ff]   = pwelch(dat,sr,sr/2,0:1:1e2,sr,'psd');
    plot(ff,log10(fftOut));
    ttluse = sprintf('%s %s', ch_alt_names{idxuse(i,1)}, ch_alt_names{idxuse(i,2)});
    title(ttluse); 
end
    


end

