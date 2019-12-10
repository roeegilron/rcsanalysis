function plot_data_psd_overlay(dirname)
%% set params
close all;
params.figdir  = dirname;
params.figtype = '-djpeg';
params.resolution = 300;
params.closeafterprint = 1; 
params.figname = 'dyskinesia_rcs06_stim_rate_rate_titrate_2_4';
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
include = {'dyskinesia_130hz_0.1ma','dyskinesia_130hz_0.5ma',...
    'dyskinesia_130hz_stim_off'};

include = {'dyskinesia_150hz_0.5ma','dyskinesia_130hz_0.5ma',...
    'dyskinesia_180hz_0.5ma'};


cns = 1:4;
cns = [1 3];
cns = [2 4];
%% plot psd
lgaxesLFP = [];
lgttlsLFP = {};

lgaxesECOG = [];
lgttlsECOG = {};
hfig = figure;
% set up subplots 
hsub(1) = subplot(1,2,1);
hsub(2) = subplot(1,2,2);


for i = 1:length(include)
    fileload = findFilesBVQX(dirname,[include{i} '.mat']);
    if ~isempty(fileload)
        load(fileload{1});
        outdatcomplete = outdatachunk;
        times = outdatcomplete.derivedTimes;
        srate = unique( outdatcomplete.samplerate );
        nmplt = 1; 
        for c = cns
            if c > 2
                nmpltuse = 2;
                ttlstr = 'M1';
            else
                nmpltuse = 1;
                ttlstr = 'STN';
            end
            axes(hsub(nmpltuse)); %only set up for 2 plots
            hold on;
            fnm = sprintf('key%d',c-1);
            y = outdatcomplete.(fnm);
            y = y - mean(y);
            if pnorm.zscore 
                y = zscore(y);
            end
            yout(:,c) = y';
            [fftOut,f]   = pwelch(y,srate,srate/2,0:1:srate/2,srate,'psd');
            if pnorm.norm 
                idxnorm = f > pnorm.normUse(1) & f < pnorm.normUse(2);
                divBy = std(fftOut(idxnorm)); 
                fftOut = fftOut./divBy; 
            end
            if pnorm.mean
                idxnorm = f > pnorm.normUse(1) & f < pnorm.normUse(2);
                divBy = mean(fftOut(idxnorm));
                fftOut = fftOut./divBy;

            end
            hplt(nmplt) = plot(f,log10(fftOut));
            hplt(nmplt).LineWidth = 2;
            %hplt.Color = [0 0 0.8 0.7];
            hplt(nmplt).Color = [hplt(nmplt).Color 0.75];
            xlim([0 150]);
            xlabel('Frequency (Hz)');
            ylabel('Power  (log_1_0\muV^2/Hz)');
            set(gca,'FontSize',20);
            ttl(nmplt) = title(ttlstr,'FontSize',30);
            clear y yout;   
            ttlout{nmplt} = [strrep( include{i}, '_',' ') outRec(1).tdData(c).chanOut];
            % add legends
            if c > 2
                lgaxesECOG = [lgaxesECOG hplt(nmplt)];
                lgttlsECOG = [lgttlsECOG ttlout(nmplt)];
            else
                lgaxesLFP = [lgaxesLFP hplt(nmplt)];
                lgttlsLFP = [lgttlsLFP ttlout(nmplt)];
            end
            nmplt = nmplt + 1;
        end
    end
end
legend(lgaxesLFP,lgttlsLFP,'FontSize',20);
legend(lgaxesECOG,lgttlsECOG,'FontSize',20);
hfig.Color = 'w';
plot_hfig(hfig,params)
end