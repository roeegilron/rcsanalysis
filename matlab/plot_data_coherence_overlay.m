function plot_data_coherence_overlay(dirname)
%% set params
close all;
params.figdir  = dirname;
params.figtype = '-djpeg';
params.resolution = 300;
params.closeafterprint = 1; 
params.figname = 'on_vs_off_data_at_home_coherence';
params.plotwidth = 17;
params.plotheight = 12;
%% set params norm 
pnorm.norm    = 0; 
pnorm.normUse = [0 100]; 
pnorm.zscore  = 0; 
pnorm.mean  = 0;

ff = findFilesBVQX(dirname,'*.mat');
include = {'rest','ipad','walking','standing'}; %{'rest walking ipad standing
include = {'active-recharge','passiveMaybe'};
include = {'active-recharge','passive-recharge'};
include = {'rest-off-meds','rest-on-meds'};
include = {'group a active 100hz lpf','group a active lpf open','group b passive 100hz lpf','group b passive lpf open'};
include = {'group a active 100hz lpf','group b passive 100hz lpf'};
include = {'group a active lpf open','group b passive lpf open'};
include = {'off meds','on meds'};
include = {'off-stim-on-meds','on-stim-on-meds'};
include = {'rest-off-stim-off-meds','rest-on-stim-off-meds'};
include = {'off-stim-on-meds','on-stim-on-meds'};
include = {'rest_0-1','rest_0-8','rest_1-6','rest_2_5'};
include = {'dysk_start','before_dysk'};
include = {'dysk_start','before_dysk'};
include = {'noise_floor_in_inc','noise_floor_no_incubator'};
include = {'in_incubator','outside_incubator'};
include = {'anesthesiaL','awakeL'};
include = {'anesthesiaR','awakeR'};
include = {'stim 0.8ma A','stim off ','stim 1.1ma A'};
include = {'anesthesiaR','awakeR'};
include = {'on_home','off_home_tremor','off_home_tremor_night'};

cns = 1:4;
cns = [1 3];
cns = [2 3];

%% plot psd
lgaxesLFP = [];
lgttlsLFP = {};

lgaxesECOG = [];
lgttlsECOG = {};
hfig = figure;
% set up subplots 

hsub(1) = subplot(2,3,1);
hsub(2) = subplot(2,3,4);
hsub(3) = subplot(2,3,2);
hsub(4) = subplot(2,3,5);
hsub(5) = subplot(2,3,3);
hsub(6) = subplot(2,3,6);

cnPairs = [1 2;... % stn stn 
           3 4;... % m1 m1 
           1 3;... % m1 m1 
           1 4;... 
           2 3;...
           2 4];
           



for i = 1:length(include)
    fileload = findFilesBVQX(dirname,[include{i} '.mat']);
    if ~isempty(fileload)
        load(fileload{1});
        outdatcomplete = outdatachunk;
        times = outdatcomplete.derivedTimes;
        srate = unique( outdatcomplete.samplerate );
        nmplt = 1; 
        for c = 1:size(cnPairs,1)
            axes(hsub(c)); 
            hold on;
            % first channel 
            cIdx1 = cnPairs(c,1);
            fnm = sprintf('key%d',cIdx1-1);
            y1 = outdatcomplete.(fnm);
            y1 = y1 - mean(y1);
            
            cIdx2 = cnPairs(c,2);
            fnm = sprintf('key%d',cIdx2-1);
            y2 = outdatcomplete.(fnm);
            y2 = y2 - mean(y2);
            
            %% plot cohenece
            Fs = unique(outdatcomplete.samplerate);
            [Cxy,F] = mscohere(y1',y2',...
                2^(nextpow2(Fs)),...
                2^(nextpow2(Fs/2)),...
                2^(nextpow2(Fs)),...
                Fs);
            idxplot = F > 0 & F < 100;
            hplot = plot(F(idxplot),Cxy(idxplot));
            xlabel('Freq (Hz)');
            ylabel('MS Coherence');
            
            hplt(i,nmplt) = plot(F(idxplot),Cxy(idxplot));
            hplt(i,nmplt).LineWidth = 2;
            %hplt.Color = [0 0 0.8 0.7];
            hplt(i,nmplt).Color = [hplt(i,nmplt).Color 0.75];
            xlim([0 100]);
            ttlGraph = sprintf('C between %s and %s',... 
                outRec(1).tdData(cIdx1).chanOut,...
                outRec(1).tdData(cIdx2).chanOut);
            set(gca,'FontSize',20);
            
            title(ttlGraph,'FontSize',20);
            clear y1 y2 cIdx1 cIdx2;

            nmplt = nmplt + 1;
        end
    end
end
% make legend just on the top right graph 
for i = 1:length(include)
    lgdttils{i} = strrep(include{i},'_',' ');
end
axes(hsub(5));
legend(hplt(:,3),lgdttils,'Location','best')
hfig.Color = 'w';
plot_hfig(hfig,params)
end