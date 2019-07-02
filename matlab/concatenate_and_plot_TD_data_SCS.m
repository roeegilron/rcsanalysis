function concatenate_and_plot_TD_data()
if ismac 
    rootdir  = '/Volumes/Samsung_T5/RCS02/RCS02_all_home_data_processed/data/RCS02L';
else isunix
    rootdir  = '/home/starr/ROEE/data/RCS02L/';
end
ff = findFilesBVQX(rootdir,'proc*TD*.mat');
ffAcc = findFilesBVQX(rootdir,'proc*Acc*.mat');


tdProcDat = struct();
accProcDat = struct();
for f = 1:length(ff)
    
    load(ff{f},'processedData');
    if isempty(fieldnames(tdProcDat))
        tdProcDat = processedData;
    else
        if ~isempty(processedData)
            tdProcDat = [tdProcDat processedData];
        end
    end
    clear processedData
    
    % process and analyze acc data
%     load(ffAcc{f},'accData');
%     
%     if isempty(fieldnames(accProcDat))
%         accProcDat = accData;
%     else
%         if ~isempty(accData)
%             accProcDat = [accProcDat accData];
%         end
%     end
%     clear accData;
end
save( fullfile(rootdir,'processedData.mat'),'params','tdProcDat','accProcDat','-v7.3')
%% load processed data and print times for each file 
load('/Volumes/Samsung_T5/RCS02/RCS02_all_home_data_processed/data/RCS02L/processedDataSepFiles.mat');
times = [tdProcDatSep.duration];
for t = 1:length(times)
    fprintf('%d %s\n',t,times(t));
end
tdProcDatSep(36); 


%% plot coverage by day 
for i = 1:length(tdProcDatSep)
    times = [tdProcDatSep(i).res.timeEnd];
    timeStarts(i) = times(1); 
    timeEnds(i) = times(end); 
end
hfig = figure; 
hax = subplot(1,1,1); 
hold on; 
daysRec =   day(timeEnds);
unqday = unique(  daysRec ); 
[yy,mm,dd] = ymd(timeEnds(1));
for d = 1:length(timeEnds) 
    idxday = find(daysRec == unqday(d));
    [h,m,s] = hms(timeEnds(idxday));
    startTimes = datetime(repmat(yy,size(h,1),1), ...
                          repmat(mm,size(h,1),1), ...
                          repmat(dd,size(h,1),1), ...
                          h,m,s);
    startTimes.TimeZone = endTimes.TimeZone;
    endTimes = timeEnds(idxday);
    plot([startTimes endTimes],[d d],...
        'LineWidth',10,...
        'Color',[0.8 0 0 0.7]);
    ylabels{d} = sprintf('May %d',unqday(d));
        
end
ylim([0 length(unqday)+1]);

hax.YTickLabel = [{' '} ;ylabels';  {' '}];
datetick('x','HH:MM');
set(gca,'XLim',...
    [datetime('03-Nov-2018 00:00:12.995') ...
     datetime('04-Nov-2018 00:01:22.949')]);

 
title('Continous Chronic Recording at Home');
figdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS02/v06_home_data/figures';
figname = 'continous recording.fig';
savefig(hfig,fullfile(figdir,figname)); 




%% do fft but on sep recordings  
for c = 1:4
    start = tic;
    fn = sprintf('key%d',c-1);
    dat = [tdProcDat.(fn)];
    sr = 250; 
    [fftOut,ff]   = pwelch(dat,sr,sr/2,0:1:sr/2,sr,'psd');
    fftResultsTd.([fn 'fftOut']) = log10(fftOut); 
    fprintf('chanel %d done in %.2f\n',c,toc(start))
end
fftResultsTd.ff = ff; 
fftResultsTd.timeStart = [tdProcDat.timeStart];
fftResultsTd.timeEnd = [tdProcDat.timeEnd];

save( fullfile(rootdir,'psdResults.mat'),'params','fftResultsTd')

%% plot the data 
for c = 1:4
    start = tic;
    fn = sprintf('key%d',c-1);
    dat = [tdProcDat.(fn)];
    sr = 250; 
    [fftOut,ff]   = pwelch(dat,sr,sr/2,0:1:sr/2,sr,'psd');
    fftResultsTd.([fn 'fftOut']) = log10(fftOut); 
    fprintf('chanel %d done in %.2f\n',c,toc(start))
end
fftResultsTd.ff = ff; 
fftResultsTd.timeStart = [tdProcDat.timeStart];
fftResultsTd.timeEnd = [tdProcDat.timeEnd];

save( fullfile(rootdir,'psdResults.mat'),'params','fftResultsTd')

%% plot td data 
% get idx to plot 
for c = 1:4 
    fn = sprintf('key%dfftOut',c-1); 
    idxkeep = fftResultsTd.(fn)(120,:) < -7;
end
hfig = figure; 
ttls = {'STN 0-2','STN 1-3','M1 8-10','M1 9-11'}; 
for c = 1:4 
    fn = sprintf('key%dfftOut',c-1); 
    hsub = subplot(2,2,c); 
    plot(fftResultsTd.ff,fftResultsTd.(fn)(:,idxkeep),'LineWidth',0.2,'Color',[0 0 0.8 0.2]); 
end

figure;
ttls = {'STN 0-2','STN 1-3','M1 8-10','M1 9-11'}; 
for c = 1:4 
    hsub(c) = subplot(4,1,c); 
    fn = sprintf('key%dfftOut',c-1); 
    C = fftResultsTd.(fn)(:,idxkeep);
    
    y = fftResultsTd.ff;
    imagesc(C);
    title(ttls{c});
    set(gca,'YDir','normal') 
    ylabel('Frequency (Hz)');
    set(gca,'FontSize',20); 
end
sgtitle('160 hours of data -30 sec chunks - RCS02L','FontSize',30)
linkaxes(hsub,'x');

% cortex - gamma - 75-79; 
% beta - stn - 19-24 

figure;
powerBeta = mean(fftResultsTd.key1fftOut(19:24,idxkeep)); 
powerGama = mean(fftResultsTd.key1fftOut(75:79,idxkeep)); 
x = fftResultsTd.timeEnd(idxkeep); 

hold on; 
scatter(x,rescale(  powerBeta, 0, 0.45) );
scatter(x,rescale(  powerGama, 0.5, 1) );
legend('Beta','Gamma');


for c = 1:4 
    hsub(c) = subplot(4,1,c); 
    fn = sprintf('key%dfftOut',c-1); 
    C = fftResultsTd.(fn)(:,idxkeep);
    
    imagesc(C);
    title(ttls{c});
    set(gca,'YDir','normal') 
    ylabel('Frequency (Hz)');
    set(gca,'FontSize',20); 
end
sgtitle('160 hours of data -30 sec chunks - RCS02L','FontSize',30)
linkaxes(hsub,'x');

