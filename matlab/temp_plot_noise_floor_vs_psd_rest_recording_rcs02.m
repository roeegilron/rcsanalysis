function temp_plot_noise_floor_vs_psd_rest_recording_rcs02()
hfig = figure;
hsub(1) = subplot(2,2,1); hold on; % stn L
hsub(1).Title.String = 'STN L';

hsub(2) = subplot(2,2,2); hold on; % stn R
hsub(2).Title.String = 'STN R';

hsub(3) = subplot(2,2,3); hold on; % m1 L
hsub(3).Title.String = 'M1 L';

hsub(4) = subplot(2,2,4); hold on; % m1 R
hsub(4).Title.String = 'M1 R';

% L 404H and right is 398H
outdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/presentations/figures';

% load data noise floor
rootDir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02';
sessionName = 'Session1557172456029';% noise floor
fdirs = findFilesBVQX(rootDir,sessionName,struct('dirs',1));

frawMats = findFilesBVQX(fdirs{1},'RawDataAccel.mat');
frawJsons = findFilesBVQX(fdirs{1},'RawDataAccel.json');

titles = {'STN L','STN R','M1 L','M1 R'};
chansNoise = {'+0-0','+0-0','+9-9','+9-9'};
chansDat = {'+1-3','+1-3','+9-11','+9-11'};
cnms = {'key0','key2'};
% XXX to get stuff in right order
% L 404H and right is 398H
% frawJsons = flipud(frawJsons);
% XXX ''

%% load noise data

cnt = 1;
res = struct();
for f = 1:length(frawJsons) % loop on devices
    [pn,fn] = fileparts(frawJsons{f});
    [outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerTable] =  ...
        MAIN_load_rcs_data_from_folder(pn);
    for i = 1:2
        
        szes = size(outdatcomplete,1);
        idxhalf = ceil(szes/2);
        timecut  = outdatcomplete.derivedTimes(idxhalf);
        idxuse = outdatcomplete.derivedTimes > timecut;
        hsb = hsub(cnt);
        
        cfnm = cnms{i};
        x = outdatcomplete.(cfnm)(idxuse);
        x =  x - mean(x);
        [fftOut,ff]   = pwelch(x,1e3,1e3/2,0:1:500,1e3,'psd');
        clear x
        
        hplt = plot(hsb,ff,log10(fftOut));
        hplt.LineWidth = 3;
        hplt.LineStyle = '-.';
        hplt.Color = [0.8 0 0 0.7];
        
        title(hsb,titles(cnt));
        xlabel(hsb,'Frequency (Hz)');
        ylabel(hsb,'Power  (log_1_0\muV^2/Hz)');
        set(hsb,'FontSize',16);
        res(f,i).fftOut = fftOut';
        res(f,i).f = ff;
        cnt = cnt + 1;
    end
end
resNoise = res;





%% load and plot real data
leftDir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/v04_10_day/rcs_data/montage_data/montage_files/RCS02L/Session1557937334709/DeviceNPC700398H';
[datM1, datSTN] = load_montage_data(leftDir);

hsub(1);% stn L
hsub(2);% stn R
hsub(3);% m1 L
hsub(4);% m1 R

% stn left 
[fftOut,ff]   = pwelch(datSTN.dat,1e3,1e3/2,0:1:500,1e3,'psd');

hplt = plot(hsub(1),ff,log10(fftOut));
hplt.LineWidth = 3;
hplt.LineStyle = '-';
hplt.Color = [0 0 0.8 0.7];

resDat(1,1).fftOut = fftOut';
resDat(1,1).f = ff;

% m1  left 
[fftOut,ff]   = pwelch(datM1.dat,1e3,1e3/2,0:1:500,1e3,'psd');

hplt = plot(hsub(3),ff,log10(fftOut));
hplt.LineWidth = 3;
hplt.LineStyle = '-';
hplt.Color = [0 0 0.8 0.7];

resDat(1,2).fftOut = fftOut';
resDat(1,2).f = ff;

rightDir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/v04_10_day/rcs_data/montage_data/montage_files/RCS02R/Session1557938153564/DeviceNPC700404H';
[datM1, datSTN] = load_montage_data(rightDir);

% stn left 
[fftOut,ff]   = pwelch(datSTN.dat,1e3,1e3/2,0:1:500,1e3,'psd');

hplt = plot(hsub(2),ff,log10(fftOut));
hplt.LineWidth = 3;
hplt.LineStyle = '-';
hplt.Color = [0 0 0.8 0.7];

resDat(2,1).fftOut = fftOut';
resDat(2,1).f = ff;

% m1  left 
[fftOut,ff]   = pwelch(datM1.dat,1e3,1e3/2,0:1:500,1e3,'psd');

hplt = plot(hsub(4),ff,log10(fftOut));
hplt.LineWidth = 3;
hplt.LineStyle = '-';
hplt.Color = [0 0 0.8 0.7];

resDat(2,2).fftOut = fftOut';
resDat(2,2).f = ff;


% plot legend 
chansNoise = {'+0-0','+0-0','+9-9','+9-9'};
chansDat = {'+1-3','+1-3','+9-11','+9-11'};

for i = 1:4
    legend(hsub(i),{chansNoise{i} chansDat{i}});
end


sgtitle('noise floor comparison rcs02','FontSize',25);
% print
hfig.PaperPositionMode = 'manual';
hfig.PaperSize         = [15 8];
hfig.PaperPosition     = [ 0 0 15 8];
fnmuse = fullfile(outdir,'noise_floor_comparison_rcs02.jpeg');
print(hfig,fnmuse,'-r300','-djpeg')


%% plot factor over noise floor 
hfig = figure;
hsub(1) = subplot(2,2,1); hold on; % stn L
hsub(1).Title.String = 'STN L';

hsub(2) = subplot(2,2,2); hold on; % stn R
hsub(2).Title.String = 'STN R';

hsub(3) = subplot(2,2,3); hold on; % m1 L
hsub(3).Title.String = 'M1 L';

hsub(4) = subplot(2,2,4); hold on; % m1 R
hsub(4).Title.String = 'M1 R';

resDat;% row is left and right (1 is left, 2 is right) 
resNoise;  % column is stn and m1 1 is stn, 2 is m1 

% left stn
hplt = plot(hsub(1), resDat(1,1).f, resDat(1,1).fftOut ./ resNoise(1,1).fftOut );
set(hsub(1), 'YScale', 'log');
hplt.LineWidth = 3;
hplt.Color = [0.8 0 0 0.7];
ylabel('Factor over noise floor');
set(hsub(1),'FontSize',16);
axis tight

% left m1
hplt = plot(hsub(3), resDat(1,2).f, resDat(1,2).fftOut ./ resNoise(1,2).fftOut );
set(hsub(3), 'YScale', 'log');
hplt.LineWidth = 3;
hplt.Color = [0.8 0 0 0.7];
ylabel('Factor over noise floor');
set(hsub(3),'FontSize',16);
axis tight

% right stn
hplt = plot(hsub(2), resDat(2,1).f, resDat(2,1).fftOut ./ resNoise(2,1).fftOut );
set(hsub(2), 'YScale', 'log');
hplt.LineWidth = 3;
hplt.Color = [0.8 0 0 0.7];
ylabel('Factor over noise floor');
set(hsub(2),'FontSize',16);
axis tight

% right m1
hplt = plot(hsub(4), resDat(2,2).f, resDat(2,2).fftOut ./ resNoise(2,2).fftOut );
set(hsub(4), 'YScale', 'log');
hplt.LineWidth = 3;
hplt.Color = [0.8 0 0 0.7];
ylabel('Factor over noise floor');
set(hsub(4),'FontSize',16);
axis tight


sgtitle('factor over noise floor rcs02','FontSize',25);


% print
hfig.PaperPositionMode = 'manual';
hfig.PaperSize         = [15 8];
hfig.PaperPosition     = [ 0 0 15 8];
fnmuse = fullfile(outdir,'factor_over_noise_floor_rcs02.jpeg');
print(hfig,fnmuse,'-r300','-djpeg')






end


function [avgDatM1, avgDatSTN] = load_montage_data(dataDir)
app = struct();
app.dataDir = dataDir;
[outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerTable] =  MAIN_load_rcs_data_from_folder(app.dataDir);
outdatcomplete.derivedTimes(1)
[fnn,pnn] = fileparts(app.dataDir);
[fnn,sessionName] = fileparts(fnn);
figTitle = sprintf('%s %s',outdatcomplete.derivedTimes(1),sessionName);

deviceSettingsFn = fullfile(app.dataDir,'DeviceSettings.json');
outRec = loadDeviceSettingsForMontage(deviceSettingsFn);
% figure out add / subtract factor for event times (if pc clock is not same
% as INS time).
idxTimeCompare = find(outdatcomplete.PacketRxUnixTime~=0,1);
packRxTimeRaw  = outdatcomplete.PacketRxUnixTime(idxTimeCompare);
packtRxTime    =  datetime(packRxTimeRaw/1000,...
    'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
derivedTime    = outdatcomplete.derivedTimes(idxTimeCompare);
timeDiff       = derivedTime - packtRxTime;


secs = outdatcomplete.derivedTimes;
app.subTime = secs(1);
% find start events
idxStart = cellfun(@(x) any(strfind(x,'Start')),eventTable.EventType);
idxEnd = cellfun(@(x) any(strfind(x,'Stop')),eventTable.EventType);
% populdate controller
app.montagefileDropDown.Items = eventTable.EventType(idxStart);
app.montagefileDropDown.ItemsData= 1:sum(idxStart);
app.montagefileDropDown.Value = 1;

% insert event table markers and link them
app.ets = eventTable(idxStart,:);
app.ete = eventTable(idxEnd,:);
app.hpltStart = gobjects(sum(idxStart),4);
app.hpltEnd = gobjects(sum(idxStart),4);
cntStn = 1;
cntM1 = 1;
for i = 1:sum(idxStart)
    for c = 1:4
        
        % start
        xval = app.ets.UnixOffsetTime(i) + timeDiff;
        startTime = xval;
        % end
        xval = app.ete.UnixOffsetTime(i)+timeDiff;
        endTime = xval;
        
        % get raw data
        cfnm = sprintf('key%d',c-1);
        y = outdatcomplete.(cfnm);
        secsUse = secs;
        idxuse = secsUse > startTime & secsUse < endTime;
        % get sample rate
        sr = str2num(strrep(outRec(i).tdData(c).sampleRate,'Hz',''));
        if c <=2
            % save raw data in order to plot psds
            app.rawDatSTN(cntStn).rawdata = y(idxuse);
            app.rawDatSTN(cntStn).sr = sr;
            app.rawDatSTN(cntStn).chan = sprintf('+%s-%s',outRec(i).tdData(c).plusInput,outRec(i).tdData(c).minusInput);
            app.rawDatSTN(cntStn).chanFullStr = outRec(i).tdData(c).chanFullStr;
            cntStn = cntStn + 1;
        else
            % save raw data in order to plot psds
            app.rawDatM1(cntM1).rawdata = y(idxuse);
            app.rawDatM1(cntM1).sr = sr;
            app.rawDatM1(cntM1).chan = sprintf('+%s-%s',outRec(i).tdData(c).plusInput,outRec(i).tdData(c).minusInput);
            app.rawDatM1(cntM1).chanFullStr = outRec(i).tdData(c).chanFullStr;
            cntM1 = cntM1 + 1;
        end
    end
    
end
chans = {app.rawDatM1.chanFullStr}';
idxuse = cellfun(@(x) any(strfind(x,'1000Hz')), chans); 
dat = app.rawDatM1(idxuse);
% recticy, average and take out first 5 seconds of data 
d1 = dat(1).rawdata; 
d1 = d1 - mean(d1); 
d2 = dat(2).rawdata;
d2 = d2 - mean(d2); 
datMean = [d1 , d2]; 
avgDatM1.dat = mean(datMean(5e3:end),1);
avgDatM1.sr = dat.sr;
avgDatM1.chanFullStr = dat.chanFullStr;
avgDatM1.chan = dat.chan;
% 

chans = {app.rawDatSTN.chanFullStr}';
idxuse = cellfun(@(x) any(strfind(x,'1000Hz')), chans); 
dat = app.rawDatSTN(idxuse);
% recticy, average and take out first 5 seconds of data 
d1 = dat(1).rawdata; 
d1 = d1 - mean(d1); 
d2 = dat(2).rawdata;
d2 = d2 - mean(d2); 
datMean = [d1 , d2]; 
avgDatSTN.dat = mean(datMean(5e3:end),1);
avgDatSTN.sr = dat.sr;
avgDatSTN.chanFullStr = dat.chanFullStr;
avgDatSTN.chan = dat.chan;

end
