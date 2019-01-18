function plot_data_psd_overlay(dirname)
%% set params
params.figdir  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v10-3-month/figures';
params.figtype = '-dpdf';
params.resolution = 300;
params.closeafterprint = 1; 
params.figname = 'on-off-stim-on-meds-3-month_2-3';
%% set params norm 
pnorm.norm    = 1; 
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
% include = {'off-stim-on-meds','on-stim-on-meds'};

cns = 1:4;
cns = [2 3];
%% plot psd
lgaxesLFP = [];
lgttlsLFP = {};

lgaxesECOG = [];
lgttlsECOG = {};
hfig = figure;
for i = 1:length(include);
    idxuse = cellfun(@(x) any(strfind(x,include{i})),ff);
    if sum(idxuse) >= 1
        load(ff{idxuse});
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
            hsub(nmplt) = subplot(1,2,nmpltuse);
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
            hplt(nmplt).LineWidth = 5;
            %hplt.Color = [0 0 0.8 0.7];
            hplt(nmplt).Color = [hplt(nmplt).Color 0.75];
            xlim([0 150]);
            xlabel('Frequency (Hz)');
            ylabel('Power  (log_1_0\muV^2/Hz)');
            set(gca,'FontSize',20);
            ttl(nmplt) = title(ttlstr,'FontSize',30);
            clear y yout;
            ttlout{nmplt} = [include{i} outRec(1).tdData(c).chanOut];
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
plot_hfig(hfig,params)
end