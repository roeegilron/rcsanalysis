function plot_chronic_power()


rootdir = '/Volumes/RCS_DATA/RCS07/v17_on_stim/RCS07L/'; 
ff = findFilesBVQX(rootdir,'RawDataPower.mat'); 
figure; hold on;
powerbands = [];
for f = 7:length(ff)
    load(ff{f}); 
    idxkeep = ~powerTable.IsPowerChannelOverrange;
    powerTable = powerTable(idxkeep,:);     
    bandHz(:,f) = powerBandInHz.powerBandInHz;
    uxtimes = datetime(powerTable.PacketRxUnixTime/1000,...
    'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
    power_band = powerTable.Band1;
    prctile_99 = prctile(power_band,99);
    idxkeep2 = power_band < prctile_99;
    hsc1 = scatter(uxtimes(idxkeep2), power_band(idxkeep2),2,'filled');
    hsc1.MarkerFaceColor = [ 0 0 0.8];
    hsc1.MarkerFaceAlpha = 0.1;
    powerbands = [powerbands; powerTable.Band1];
    hmean = movmean(powerTable.Band1,[6000 0]); 
    hsc2 = plot(uxtimes, hmean,'LineWidth',1,'Color',[0 0 0 0.5]);
end
% figure;
% % boxplot(powerbands); 
% h = histogram(powerbands)
end