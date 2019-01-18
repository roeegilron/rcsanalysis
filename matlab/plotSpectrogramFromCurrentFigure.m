%% plotSpectrogramFromCurrentFigure
params.figdir  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v06-home-visit-3-week/figures/sleep-dmp-data';
params.figtype = '-djpeg';
params.resolution = 300;
params.closeafterprint = 0; 

%% spectral plot
h = gcf;
axes = get(h,'Children');
dataObjs = get(axes,'Children');
dataObjs  = flipud(dataObjs);
params.figname = [strrep(datestr(axes(1).XLim(1),31),':','-') ' _raw'];
plot_hfig(h,params)

axes  = flipud(axes);
srate = 250;
hfig = figure('Position',h.Position);
for i = 1:length(axes)
    hsb(i) = subplot(length(axes),1,i);
    axes(i).XLim
    x = dataObjs{i}.XData;
    idxs = x > axes(i).XLim(1) & x < axes(i).XLim(2);
    y = dataObjs{i}.YData;
    yuse = y(idxs);
    [s,f,t,p] = spectrogram(yuse,srate,ceil(0.875*srate),1:40,srate,'yaxis','psd');
    pscaled = abs(p)./abs(repmat(mean(p,2),1,size(p,2)));
    pcolor(hsb(i),t, f,p);
    colorbar; 
    % sh = surf(t,f,p);
    view(0, 90)
    axis tight
    shading interp
    %     caxis([-1 1])
    view(2);
    xlabel('seconds');
    ylabel('Frequency (Hz)');
    title(axes(i).Title.String);
    set(gca,'FontSize',16);
end
params.closeafterprint = 1; 
params.figname = [strrep(datestr(axes(1).XLim(1),31),':','-') ' _spect'];
plot_hfig(hfig,params)


%% fft
srate = 250;
hfig = figure('Position',h.Position);
for i = 1:length(axes)
    hsb(i) = subplot(2,2,i);
    axes(i).XLim
    x = dataObjs{i}.XData;
    idxs = x > axes(i).XLim(1) & x < axes(i).XLim(2);
    y = dataObjs{i}.YData;
    yuse = y(idxs);
    [fftOut,f]   = pwelch(y,srate,srate/2,0:0.5:100,srate,'psd');
    plot(f,log10(fftOut));
    xlabel('Frequency (Hz)');
    ylabel('Power (log_1_0\muV^2/Hz)');
    title(axes(i).Title.String);
    set(gca,'FontSize',16);
end
params.closeafterprint = 1; 
params.figname = [strrep(datestr(axes(1).XLim(1),31),':','-') ' _psd'];
plot_hfig(hfig,params)

