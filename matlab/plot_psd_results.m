function plot_psd_results(psd_results_fn)

load(psd_results_fn);
[pn,fn,ext] = fileparts(psd_results_fn);
hfig = figure;
hfig.Position = [1154         266        1317         886];
hfig.Color = 'w';
for c = 1:4
    hsb(c) = subplot(2,2,c);
    hold on;
    fn = sprintf('key%dfftOut',c-1);
    dat = fftResultsTd.(fn);
    rng(c);
    r = ceil(size(dat,1) .* rand(1500,1));
    dat = dat(:,r);
    idxnormalize = fftResultsTd.ff > 3 &  fftResultsTd.ff <90;
    meandat = abs(mean(dat(:,idxnormalize),2)); % mean within range, by row
    % the absolute is to make sure 1/f curve is not flipped
    % since PSD values are negative
    meanmat = repmat(meandat,1,size(dat,2));
%     dat = dat./meanmat;
    plot(fftResultsTd.ff', dat,'LineWidth',0.05,'Color',[0 0 0.8 0.05]);
    xlim([3 100]);
    xlabel('Time (Hz)');
    ylabel('Power (log_1_0\muV^2/Hz)');
    ylims = hsb(c).YLim;
    plot([4 4],ylims,'LineWidth',3,'LineStyle','-.','Color',[0.2 0.2 0.2 0.1]);
    plot([13 13],ylims,'LineWidth',3,'LineStyle','-.','Color',[0.2 0.2 0.2 0.1]);
    plot([30 30],ylims,'LineWidth',3,'LineStyle','-.','Color',[0.2 0.2 0.2 0.1]);
    set(gca,'FontSize',16);
end

end