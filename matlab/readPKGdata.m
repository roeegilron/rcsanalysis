function readPKGdata()
%% load pkg data
fn = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/v07_3_week/pkg/scores_20190515_124018 .csv';
pkgTable = readtable(fn); 
% plot pkg data 
figure;
cntplt = 1;
hsb(cntplt) = subplot(2,1,cntplt); cntplt = cntplt +1; 
hp = plot(pkgTable.DateTime,pkgTable.DK);
hp.Color = [0 0.8 0 0.7];
hp.LineWidth = 3; 
title('Dyksinesia');
set(gca,'FontSize',16);
hsb(cntplt) = subplot(2,1,cntplt);  cntplt = cntplt +1; 
hp = plot(pkgTable.DateTime,pkgTable.BK);
hp.Color = [0 0 0.8 0.7];
hp.LineWidth = 3; 
title('Bradykinesia');
set(gca,'FontSize',16);
linkaxes(hsb,'x'); 

%% load power data 
rcsFolder = '/Volumes/Samsung_T5/RCS02/RCS02_all_home_data_processed/data/RCS02L'; 
ff = findFilesBVQX(rcsFolder,'RawDataPower.mat');
ptOut = table(); 
pbOut = {};
for f = 1:length(ff)
    load(ff{f},'powerTable','powerBandInHz');
    pt = powerTable; 
    pbs = powerBandInHz;
    clear powerTable powerBandInHz; 
    if ~isempty(pt)
        ptOut = [ptOut ; pt];
        pbOut = [pbOut, pbs];
    end
end
% load acgriaphy 
rcsFolder = '/Volumes/Samsung_T5/RCS02/RCS02_all_home_data_processed/data/RCS02L'; 
ff = findFilesBVQX(rcsFolder,'RawDataAccel.mat');
accOut = table(); 
for f = 1:length(ff)
    load(ff{f});
    accOut = [accOut; outdatcomplete];
end
figure;
hold on; 
t = accOut.derivedTimes;
idxkeep = year(t) == 2019;
t = t(idxkeep); 
x = accOut.XSamples(idxkeep);
y = accOut.YSamples(idxkeep);
z = accOut.ZSamples(idxkeep);
plot(t,x-mean(x));
plot(t,y-mean(y));
plot(t,z-mean(z));
%% plot
figure;
cntplt = 1;
hsb(cntplt) = subplot(4,1,cntplt); cntplt = cntplt +1; 
hp = plot(pkgTable.DateTime,pkgTable.DK);
hp.Color = [0 0.8 0 0.7];
hp.LineWidth = 3; 
title('Dyksinesia');
set(gca,'FontSize',16);
hsb(cntplt) = subplot(4,1,cntplt);  cntplt = cntplt +1; 
hp = plot(pkgTable.DateTime,pkgTable.BK);
hp.Color = [0 0 0.8 0.7];
hp.LineWidth = 3; 
title('Bradykinesia');
set(gca,'FontSize',16);

hsb(cntplt) = subplot(4,1,cntplt);  cntplt = cntplt +1; 
hold on;
plot(t,x-mean(x));
plot(t,y-mean(y));
plot(t,z-mean(z));

title('acc rc+s');
set(gca,'FontSize',16);


uxtimes = datetime(ptOut.PacketRxUnixTime/1000,...
    'ConvertFrom','posixTime','Format','dd-MMM-yyyy HH:mm:ss.SSS');


zscores = zscore(ptOut.Band7); 
idxkeep = abs(zscores)<4; 
hsb(cntplt) = subplot(4,1,cntplt); cntplt = cntplt +1; 
plot(uxtimes(idxkeep),ptOut.Band7(idxkeep)); 
title('acc rc+s');
set(gca,'FontSize',16);

linkaxes(hsb,'x'); 

end