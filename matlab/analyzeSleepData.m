function analyzeSleepData()
%% open data
rootdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v06-home-visit-3-week/rc+s_data/DMP_data/RCS01';
rootdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v06-home-visit-3-week/rc+s_data/DMP_dump_2';
sessdirs = findFilesBVQX(rootdir,'DeviceNPC700395H*',struct('dirs',1));
fidF = fopen('failed files.txt','w+');
fidS = fopen('sucesss files.txt','w+');
for s = 1:length(sessdirs)
    try
        start = tic;
        [~] = MAIN_load_rcs_data_from_folder(sessdirs{s});
        fprintf('folder %d out of %d done in %f\n',...
            s,length(sessdirs),toc(start));
        fprintf(fidS,'%s\n',sessdirs{s});
    catch
        fprintf(fidF,'%s\n',sessdirs{s});
        
    end
end

%% read data
rootdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v06-home-visit-3-week/rc+s_data/DMP_data/RCS01';
rootdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v06-home-visit-3-week/rc+s_data/DMP_dump_2';
figdir  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v06-home-visit-3-week/rc+s_data/DMP_data/figures';
resdir  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v06-home-visit-3-week/results/sleep_data'; 

ffiles = findFilesBVQX(rootdir,'RawDataTD.mat');
tdfile  = findFilesBVQX(rootdir,'DeviceSettings.mat');
acfile  = findFilesBVQX(rootdir,'RawDataAccel.mat'); 
for f = 1:length(ffiles)
    load(ffiles{f});
    load(tdfile{f});
    fileLen(f) = minutes(minutes(outdatcomplete.derivedTimes(end) - outdatcomplete.derivedTimes(1)));
    if  fileLen(f) > minutes(1)
        fprintf('file len is %s minutes\n', fileLen(f));
    end
    %     fprintf('file % d of %d\n',f,length(ffiles));
    allDat(f).outdatcomplete = outdatcomplete; 
    allDat(f).outRec = outRec; 
    allDat(f).fileLen = fileLen(f); 
    load(acfile{f}); 
    allDat(f).outdatcompleteAcc = outdatcomplete; 
    clear outdatcomplete 
end
figure;
histogram(fileLen);
save(fullfile(resdir,'raw_sleep_data2.mat'),'allDat','-v7.3'); 
%% plot table of continous recordings 
clc;
clear all;
close all;
resdir  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v06-home-visit-3-week/results/sleep_data'; 
load(fullfile(resdir,'raw_sleep_data.mat'),'allDat'); 
sleepDat = struct2table(allDat); 
%% plot spectral representation of the data from DMP (it has weird behaviour in which recording stops every 30 seconds) 
clear all; 
close all; 
resdir  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v06-home-visit-3-week/results/sleep_data'; 
load(fullfile(resdir,'raw_sleep_data2.mat'),'allDat'); 

sleepDat = struct2table(allDat); 
% params set
params.maxgap = seconds( 1* 0.5 ); % max gap you allow in seconds between two data points 
params.minchunksize = seconds(20); % min chunk size you will accept 
params.plot =  0; % do you want to plot data 
%% 
% idnetifny isues with sampling rate 
cnt = 1;
sleepChunks = table();

cnt = 1;
sleepChunks = table();
for f = 1:size(sleepDat,1)
    outdatcomplete = allDat(f).outdatcomplete; 
    srate = unique(outdatcomplete.samplerate);
    outDat = sleepDat.outdatcomplete{f};
    dateArray = outDat.derivedTimes;
    
    if  sleepDat.fileLen(f) > minutes(1) & length(srate) ==1 
        y = outDat.key3; 
        res = findIdxOfContinousData(y,dateArray,params);
        srate = unique(outDat.samplerate); 
        fprintf('file len is %.2f minutes, max dur %s total chunks %s\n', minutes(sleepDat.fileLen(f)),...
            res.maxDuration,sum(res.durations));
        for r = 1:size(res.startIdx,1)
            for c = 1:4
                fnm = sprintf('key%d',c-1);
                y = outDat.(fnm);
                y = y - mean(y);
                
                %             sleepDat.outRec{1,1}(1).tdData(1).chanFullStr;
                
                
                sleepChunks.time(cnt) = outDat.derivedTimes(res.startIdx(r));
                sleepChunks.duration(cnt) = res.durations(r);
                
                ychunk = y(res.startIdx(r):res.endIdx(r));
                
                [fftOut,freq]   = pwelch(ychunk,srate,srate/2,0:1:100,srate,'psd');
                if sum(log10(fftOut))==0
                    x = 2;
                end
                
                sleepChunks.freq(cnt,:) = freq;
                chanName = sprintf('chan%d_fftOut',c);
                sleepChunks.(chanName)(cnt,:) = log10(fftOut);
            end
            cnt = cnt + 1;
        end
        
    end
end
resdir  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v06-home-visit-3-week/results/sleep_data'; 
save(fullfile(resdir,'sleepChunks2.mat'),'sleepChunks');    

   


%% prep data
% preallocate size 
elmtns = cell2mat(arrayfun(@(x) size(x.raw,1), resChunks,'UniformOutput',false));
datOut = zeros(sum(elmtns),4);  
timeOut = zeros(sum(elmtns),1);  
c = arrayfun(@(x) x.raw, resChunks, 'UniformOutput', false);
rawDat(:,:) = vertcat(c{:});
c = arrayfun(@(x) datenum(x.time), resChunks, 'UniformOutput', false);
timeOut(:) = vertcat(c{:});
%%

hfig = figure;
for i = 1:4
    hsb(i) = subplot(4,1,i);
    plot(timeOut,rawDat(:,i));
    datetick('x',14);
end
linkaxes(hsb,'x');

figure;
srate = 250;
spectrogram(rawDat(:,4),srate,ceil(0.875*srate),2:2:50,srate,'yaxis','psd')
%%


hfig = figure;
for f = 1:length(resChunks)
    for i = 1:4
        if f == 1 
            hsb(i) = subplot(4,1,i);hold on; 
        else
           axes(hsb(i)); 
        end
        plot(resChunks(f).time,resChunks(f).raw(:,i));
    end
end

%% plot raw data
save('temp-all-data-damp','dataOut');
figure;
plot(dataOut.derivedTimes,dataOut.key3)'

%% save figures
rootdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v06-home-visit-3-week/rc+s_data/DMP_data/RCS01';
figdir  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v06-home-visit-3-week/rc+s_data/DMP_data/figures';

ffiles = findFilesBVQX(rootdir,'RawDataTD.mat');
tdfile  = findFilesBVQX(rootdir,'DeviceSettings.mat');
for f = 1:length(ffiles)
    load(ffiles{f});
    load(tdfile{f});
    fileLen(f) = minutes(minutes(outdatcomplete.derivedTimes(end) - outdatcomplete.derivedTimes(1)));
    if  fileLen(f) > minutes(1)
        fprintf('file len is %s minutes\n', fileLen(f));
        hfig = figure('Visible','on');
        hfig.Position = [1000         369        1356         969];
        for i = 1:4
            fnm = sprintf('key%d',i-1);
            hsb(i) = subplot(4,1,i);
            y = outdatcomplete.(fnm);
            y = y - mean(y);
            hplt = plot(outdatcomplete.derivedTimes,y );
            %             ylim([prctile(y,0.05) prctile(y,99.5)]);
            clear y;
            title(outRec(1).tdData(i).chanFullStr);
            set(gca,'FontSize',16);
        end
        linkaxes(hsb,'x');
        spttl = sprintf('%s %s %.2f min',...
            outRec(1).timeStart,...
            outRec(end).timeEnd,...
            minutes(fileLen(f)));
        %         suptitle(spttl);
        ZoomHandle = zoom(hfig);
        ZoomHandle.Motion = 'Horizontal';
        figname = sprintf('%0.3d -%.2f min %s.fig',...
            f,...
            minutes(fileLen(f)),...
            strrep(datestr(outRec(1).timeStart,31),':','-'));
        saveas(hfig,fullfile(figdir,figname));
        
        fprintf('file % d of %d\n',f,length(ffiles));
        clear outdatcomplete
        close(hfig);
    end
end


%% write sleep video PSD
params.minChunkSize = 20; % in seconds
rootdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v06-home-visit-3-week/rc+s_data/DMP_data/RCS01';
figdir  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v06-home-visit-3-week/rc+s_data/DMP_data/figures';
cnt = 1;
ffiles = findFilesBVQX(rootdir,'RawDataTD.mat');
tdfile  = findFilesBVQX(rootdir,'DeviceSettings.mat');
for f = 1:length(ffiles)
    load(ffiles{f});
    load(tdfile{f});
    fileLen(f) = minutes(minutes(outdatcomplete.derivedTimes(end) - outdatcomplete.derivedTimes(1)));
    if  fileLen(f) > minutes(1)
        fprintf('file len is %s minutes\n', fileLen(f));
        difs = milliseconds(diff(outdatcomplete.derivedTimes));
        idxsMs =  find(difs > 10);
        for cc = 1:length(idxsMs) -1
            idxChunk = idxsMs(cc)+ srate*5 : 1: idxsMs(cc+1);
            if ceil(length(idxChunk)/srate) > params.minChunkSize % make sure chunk size is big 
                for i = 1:4
                    fnm = sprintf('key%d',i-1);
                    y = outdatcomplete.(fnm);
                    y = y(idxChunk);
                    y = y - mean(y);
                    [fftOut,freq]   = pwelch(y,srate,srate/2,0:1:100,srate,'psd');
                    
                    resChunks(cnt).fftOut(i,:) = log10(fftOut);
                    resChunks(cnt).mins(i) = min(log10(fftOut));
                    resChunks(cnt).maxs(i) = max(log10(fftOut));
                    resChunks(cnt).f(i,:) = freq;
                    resChunks(cnt).chanStr{i}   = outRec(1).tdData(i).chanFullStr;
                    resChunks(cnt).time{i}   = datestr(outdatcomplete.derivedTimes(idxChunk(1)),31);
                end
                cnt = cnt + 1;
            end
        end
    end
    fprintf('file %d out of %d done\n',f,length(ffiles));
end
figdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v06-home-visit-3-week/rc+s_data/DMP_data';
figname = 'psdDataInChunk.mat'; 
save(fullfile(figdir,figname),'resChunks');


%% write sleep video in video frame 
clear params; 
params.figdir  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v06-home-visit-3-week/rc+s_data/DMP_data/figs-raw-vid';
params.figtype = '-djpeg';
params.resolution = 200;
params.closeafterprint = 1; 

load('/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v06-home-visit-3-week/rc+s_data/DMP_data/psdDataInChunk.mat'); 
srate = 250;
% quality control 
for r = 1:length(resChunks)
    if ~isempty(resChunks(r).mins)
        idxRuse(r) = 1;
        mins(r,:) = resChunks(r).mins;
        maxs(r,:) = resChunks(r).maxs;
    else
        idxRuse(r) = 0; 
    end
end
minUse = min(mins,[],1);
maxUse = max(maxs,[],1);
resChunkUse = resChunks(find(idxRuse==1)); 
ttlsUse = {'STN 0-2','STN 1-3','M1 8-10', 'M1 9-11'};

fnm = fullfile(params.figdir,'sleepDemo.mp4'); 
v = VideoWriter(fnm,'MPEG-4');
v.FrameRate = 15; 
open(v);



for r = 1:length(resChunkUse)
    hfig = figure('Visible','off');
    hfig.Position = [1000         365        1437         973];
    for i = 1:4
        if i > 2 
            clr = [0.8 0 0 0.7];
        else
            clr = [0 0 0.8 0.7];
        end
        subplot(2,2,i);
        f = resChunkUse(r).f(i,:);
        fftOut = resChunkUse(r).fftOut(i,:);
        plt = plot(f,fftOut);
        plt.LineWidth = 3; 
        plt.Color = clr; 
        ylim([minUse(i) maxUse(i)]);
        xlabel('Frequency (Hz)');
        ylabel('Power (log_1_0\muV^2/Hz)');
        title(resChunkUse(r).chanStr{i});
        title(ttlsUse{i}); 
        set(gca,'FontSize',18);
    end
%     httl = suptitle(resChunkUse(r).time{i});
    htxt = text(0,0.5, resChunkUse(r).time{i}); 
    htxt.Position = [ -49.791666666666671   2.947195662337627   0.000000000000014];
    htxt.FontSize = 30;
    htxt.FontWeight = 'bold' ;
    frame = getframe(hfig);
    writeVideo(v,frame);

%     plot_hfig(hfig,params)
    params.figname = sprintf('%0.4d',r); 
    fprintf('fig %d out of %d printed\n',r,length(resChunkUse));
end
close(v);


end