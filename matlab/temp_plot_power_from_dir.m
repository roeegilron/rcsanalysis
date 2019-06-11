function temp_plot_power_from_dir()
rootdir = '/Volumes/Samsung_T5/RCS02/all_data_june3/RCS02L'; 
ff = findFilesBVQX(rootdir,'RawDataPower.mat');
tableOut = table(); 
for f = 1:length(ff)
    load(ff{f}); 
    tableOut = [tableOut; powerTable]; 
    clear powerTable;
end

%% plot
uxtimes = datetime(tableOut.PacketRxUnixTime/1000,...
    'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');

bandsUse = [1 2 5 6 7 8] ;
freBands = {'16.97 - 23.8Hz',...
    '7.93 - 13.79Hz',...
    '6.71 - 13.79z',...
    '16.97 - 24.05Hz',...
    '4.52 - 6.96Hz',...
    '16.97 - 21.61Hz'};
nmplts   = length(bandsUse);
hfig = figure;
for b = 1:length(bandsUse)
    hsub(b) = subplot(nmplts,1,b);
    bandsfn = sprintf('Band%d',bandsUse(b));
    hplt = plot( hsub(b),uxtimes,tableOut.(bandsfn),'LineWidth',2,'Color',[0 0 0.8 0.8]);
    ylims = get(gca,'YLim'); 
    hold on; 
%     t = eventTable.UnixOffsetTime;
%     plot([t t],ylims); 
    title(freBands{b});
    set(hsub(b),'FontSize',16);
end
linkaxes(hsub,'x');

end