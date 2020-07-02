function concatenate_and_plot_TD_data_from_database_table(database,patdir,label)
%% this function will concatenate some data given a few parameters 
% see MAIN_create_subsets_of_home_data_for_analysis for how this database
% is created - this function is only meant to be called from that function 

% loop through sessions database and find little bits of actigraphy/td data that were cut
% into little pieces using MAIN_create_subsets_of_home_data_for_analysis
% above 



%% actigraphy data 
%%%%%%%%%%
%%%%%%%%%%
% START ACC 
% START ACC 
% START ACC 
%%%%%%%%%%
%%%%%%%%%%
%%%%%%%%%%
cnttime = 1; 

for ss = 1:size(database,1) 
    sessionDir = findFilesBVQX(patdir,database.sessname{ss},struct('dirs',1,'depth',1));
    ff = findFilesBVQX(sessionDir{1}, 'processedAccData.mat');
    if ~isempty(ff)
        processedActigraphyFiles{ss,1} = ff{1};
        database.AccExist(ss) = 1; 
    else
        database.AccExist(ss) = 0; 
    end
end
database.processedActigraphyFiles = processedActigraphyFiles;
totalHours = sum(database.duration);
existHours = sum(database.duration(logical(database.AccExist)));
missingHours = sum(database.duration(~logical(database.AccExist))); 
fprintf('for patient dir:\n%s\n',patdir); 
fprintf('total database size is %s\n',totalHours); 
fprintf('actigraphy files exist for %s\n', existHours);
fprintf('actigraphy files missing for %s\n',missingHours);
fprintf('files exist for %%%1.6f of data\n',(existHours/totalHours)*100); 

accProcDat = struct();
accFileDur = NaT;

ffAcc = database.processedActigraphyFiles(logical(database.AccExist));
for f = 1:length(ffAcc)
    %     process and analyze acc data
    load(ffAcc{f},'accData');
    
    if isempty(fieldnames(accProcDat))
        if isstruct(accData)
            accProcDat = accData;
            accFileDur.TimeZone = accData(1).timeStart.TimeZone;
            accFileDur(cnttime,1) = accData(1).timeStart;
            accFileDur(cnttime,2) = accData(end).timeStart;
            cnttime = cnttime+1;
        end
    else
        if ~isempty(accData)
            accProcDat = [accProcDat accData];
            accFileDur(cnttime,1) = accData(1).timeStart;
            accFileDur(cnttime,2) = accData(end).timeStart;
            cnttime = cnttime+1;
        end
    end
    fprintf('acc file %d/%d done\n',f,length(ffAcc));
    clear accData;
end
fnsave = sprintf('processedDataAcc__%s.mat',label);
save( fullfile(patdir,fnsave),'accProcDat','accFileDur','database','-v7.3')

%%%%%%%%%%
%%%%%%%%%%
% END ACC 
% END ACC 
% END ACC 
%%%%%%%%%%
%%%%%%%%%%
%%%%%%%%%%




%% time domain data 
%%%%%%%%%%
%%%%%%%%%%
% START TD 
% START TD 
% START TD 
%%%%%%%%%%
%%%%%%%%%%
%%%%%%%%%%
cnttime = 1; 

for ss = 1:size(database,1) 
    sessionDir = findFilesBVQX(patdir,database.sessname{ss},struct('dirs',1,'depth',1));
    ff = findFilesBVQX(sessionDir{1}, 'proc*TD*.mat');
    if ~isempty(ff)
        processedTDFiles{ss,1} = ff{1};
        database.TdExist(ss) = 1; 
    else
        database.TdExist(ss) = 0; 
    end
end
database.processedTDFiles = processedTDFiles;
totalHours = sum(database.duration);
existHours = sum(database.duration(logical(database.TdExist)));
missingHours = sum(database.duration(~logical(database.TdExist))); 
fprintf('for patient dir:\n%s\n',patdir); 
fprintf('total database size is %s\n',totalHours); 
fprintf('actigraphy files exist for %s\n', existHours);
fprintf('actigraphy files missing for %s\n',missingHours);
fprintf('files exist for %%%1.6f of data\n',(existHours/totalHours)*100); 

tdProcDat = struct();
timeDomainFileDur = NaT;
ffTD = database.processedTDFiles(logical(database.TdExist));
for f = 1:length(ffTD)
    %     process and analyze acc data
    load(ffTD{f},'processedData','params');
    
    if isempty(fieldnames(tdProcDat))
        if isstruct(processedData)
            tdProcDat = processedData;
            timeDomainFileDur.TimeZone = processedData(1).timeStart.TimeZone;
            timeDomainFileDur(cnttime,1) = processedData(1).timeStart;
            timeDomainFileDur(cnttime,2) = processedData(end).timeStart;
            cnttime = cnttime+1;
        end
    else
        if ~isempty(processedData)
            tdProcDat = [tdProcDat processedData];
            timeDomainFileDur(cnttime,1) = processedData(1).timeStart;
            timeDomainFileDur(cnttime,2) = processedData(end).timeStart;
            cnttime = cnttime+1;
        end
    end
    clear processedData
    fprintf('time domain file %d/%d done\n',f,length(ffTD));
end
fnsave = sprintf('processedData__%s.mat',label);
save( fullfile(patdir,fnsave),'tdProcDat','params','timeDomainFileDur','database','-v7.3')
%%%%%%%%%%
%%%%%%%%%%
% END TD 
% END TD 
% END TD 
%%%%%%%%%%
%%%%%%%%%%
%%%%%%%%%%

%% plot recording duration to see how much data was recoded per day  
% split up recordings that are not in the samy day 
% params to print the figures
prfig.plotwidth           = 25;
prfig.plotheight          = 25*0.6;
mkdir(fullfile(patdir,'figures')); 
prfig.figdir              = fullfile(patdir,'figures');
prfig.figtype             = '-djpeg';
prfig.closeafterprint     = 0;
prfig.resolution          = 300;

idxNotSameDay = day(timeDomainFileDur(:,1)) ~= day(timeDomainFileDur(:,2));
allTimesSameDay = timeDomainFileDur(~idxNotSameDay,:); 
allTimesDiffDay = timeDomainFileDur(idxNotSameDay,:); 
% for idx that is not the same day, split it 
newTimesDay1 = [allTimesDiffDay(:,1) (allTimesDiffDay(:,1) - timeofday(allTimesDiffDay(:,1)) + day(1)) - minutes(1)];
newTimesDay2 = [((allTimesDiffDay(:,2) - timeofday(allTimesDiffDay(:,2))) + minutes(2)  ) allTimesDiffDay(:,2) ];
% concatenate all times 
allTimesNew  = sortrows([allTimesSameDay ; newTimesDay1 ; newTimesDay2],1); 
daysUse      = day(allTimesNew); 
montsUse     = month(allTimesNew); 
unqMonthsAndDays = sortrows(unique([montsUse(:,1) daysUse(:,1) ],'rows'),[1 2],'ascend');

% get y values for graph 
 
for d = 1:size(allTimesNew,1)
    monthTemp = month(allTimesNew(d,1));
    dayTemp = day(allTimesNew(d,1));
    idxUse = find(monthTemp == unqMonthsAndDays(:,1) & dayTemp == unqMonthsAndDays(:,2));
    yValue(d) = idxUse; 
    dateTime(idxUse,1) = allTimesNew(d,1);
end
% get labels for y values
ylabelsUse = {}; 
for d = 1:size(unqMonthsAndDays,1)
    dayTemp = day(dateTime(d,1));
    [m,str] = month(datenum(dateTime(d,1)));
    ylabelsUse{d,1} = sprintf('%s %d',str,dayTemp);
end
% plot figure 
hfig = figure; 
hold on; 
hax = subplot(1,1,1); 
plot(timeofday( allTimesNew' ),[yValue' yValue']',...
    'LineWidth',10,...
    'Color',[0.8 0 0 0.7]);
hax.YTick = [1 : 1: max(yValue)];
hax.YTickLabel = ylabelsUse;
hax.YLim = [hax.YLim(1)-1 hax.YLim(2)+1];
set(gca,'FontSize',16); 
ttluse = sprintf('Continous Chronic Recording at Home (%s hours)',sum(timeDomainFileDur(:,2) - timeDomainFileDur(:,1))); 
title(ttluse);
set(gcf,'Color','w'); 
prfig.figname  = sprintf('continous recording report __ %s',label);

plot_hfig(hfig,prfig); 

%% do fft but on sep recordings  
for i = 1:length( tdProcDat )
    for c = 1:4
        fn = sprintf('key%d',c-1);
        if size(tdProcDat(i).(fn),1) < size(tdProcDat(i).(fn),2)
            tdProcDat(i).(fn) = tdProcDat(i).(fn)';
        end
    end
end

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

% check for outliers 
hfig = figure;
idxWhisker = []; 
for c = 1:4 
    fn = sprintf('key%dfftOut',c-1); 
    hsub = subplot(2,2,c); 
    meanVals = mean(fftResultsTd.(fn)(40:60,:));
    boxplot(meanVals);
    q75_test=quantile(meanVals,0.75);
    q25_test=quantile(meanVals,0.25);
    w=2.0;
    wUpper(c) = w*(q75_test-q25_test)+q75_test;
    idxWhisker(:,c) = meanVals' < wUpper(c);

end
idxkeep = idxWhisker(:,1) &  idxWhisker(:,2) & idxWhisker(:,3) & idxWhisker(:,4) ; 
close(hfig)
fnsave = sprintf('psdResults__%s.mat',label);
save( fullfile(patdir,fnsave),'params','fftResultsTd','idxkeep','timeDomainFileDur','database')

%% process actigraphy data 
if ~isempty(fieldnames( accProcDat))
    for a = 1:size(accProcDat,2)
        start = tic;
        dat = [];
        dat(:,1) = accProcDat(a).XSamples;
        dat(:,2) = accProcDat(a).YSamples;
        dat(:,3) = accProcDat(a).ZSamples;
        datOut = processActigraphyData(dat,64);
        accMean  = mean(datOut);
        accVari  = mean(var(dat));
        accResults(a).('accMean') = accMean;
        accResults(a).('accVari') = accVari;
        accResults(a).('timeStart') = accProcDat(a).timeStart;
        accResults(a).('timeEnd') = accProcDat(a).timeEnd;
    end
    
    % check for outliers
    hfig = figure;
    idxWhisker = [];
    boxplot([accResults.accMean]);
    q75_test=quantile(meanVals,0.75);
    q25_test=quantile(meanVals,0.25);
    w=2.0;
    wUpper(1) = w*(q75_test-q25_test)+q75_test;
    idxWhisker(:,1) = meanVals' < wUpper(c);
    idxkeepAcc = idxWhisker;
    close(hfig)
    
    fnsave = sprintf('accResults__%s.mat',label);
    save( fullfile(patdir,fnsave),'params','accResults','idxkeepAcc','timeDomainFileDur','database')
end







%%  cohernece 



patient = database.patient{1};
switch patient
    case 'RCS01'
        areaname = 'stn';
    case 'RCS02'
        areaname = 'stn';
    case 'RCS03'
        areaname = 'gpi';
    case 'RCS04'
        areaname = 'stn';
    case 'RCS05'
        areaname = 'stn';
    case 'RCS06'
        areaname = 'stn';
    case 'RCS07'
        areaname = 'stn';
    case 'RCS08'
        areaname = 'stn';
    case 'RCS09'
        areaname = 'gpi';
    case 'RCS10'
        areaname = 'gpi';
end

startall = tic;
startload = tic;
fprintf('file loaded in %.2f seconds \n',toc(startload));
%% do fft but on sep recordings
for i = 1:length( tdProcDat )
    for c = 1:4
        fn = sprintf('key%d',c-1);
        if size(tdProcDat(i).(fn),1) < size(tdProcDat(i).(fn),2)
            tdProcDat(i).(fn) = tdProcDat(i).(fn)';
        end
    end
end

if strcmp(areaname,'stn')
    pairname = {'STN 0-2','M1 8-10';...
        'STN 0-2','M1 9-11';...
        'STN 1-3','M1 8-10';...
        'STN 1-3','M1 9-11'};
    paircontact = [0 2;...
        0 3;...
        1 2;...
        1 3];
    fieldnamesuse = {'stn02m10810','stn02m10911','stn13m10810','stn13m0911'};
elseif strcmp(areaname,'gpi')
    pairname = {'GPi 0-1','M1 8-9';...
        'GPi 0-1','M1 10-11';...
        'GPi 2-3','M1 8-9';...
        'GPi 2-3','M1 10-11'};
    paircontact = [0 2;...
        0 3;...
        1 2;...
        1 3];
    fieldnamesuse = {'gpi01m10809','gpi01m1011','gpi23m10809','gpi23m1011'};
    
end


Fs = unique(cell2mat(cellfun(@(x) str2num(x(end-4:end-2)), database.chan1, 'UniformOutput', false)));
for cc = 1:length(pairname)
    startchan = tic;
    fnuse = sprintf('key%d',paircontact(cc,1));
    stndat = [tdProcDat.(fnuse)];
    
    fnuse = sprintf('key%d',paircontact(cc,2));
    m1dat = [tdProcDat.(fnuse)];
    
    start = tic;
    [Cxy,F] = mscohere(stndat,m1dat,...
        2^(nextpow2(Fs)),...
        2^(nextpow2(Fs/2)),...
        2^(nextpow2(Fs)),...
        Fs);
    endtime = toc(start);
    coherenceResultsTd.(fieldnamesuse{cc}) = Cxy;
    clear Cxy
    fprintf('channel %d done in  %.2f seconds \n',cc,toc(startchan));
end

coherenceResultsTd.paircontact = paircontact;
coherenceResultsTd.pairname = pairname;
coherenceResultsTd.srate = Fs;
coherenceResultsTd.ff = F;
coherenceResultsTd.timeStart = [tdProcDat.timeStart];
coherenceResultsTd.timeEnd = [tdProcDat.timeEnd];



fnsave = sprintf('coherenceResults__%s.mat',label);
save( fullfile(patdir,fnsave),'params','coherenceResultsTd','timeDomainFileDur','database')





return 











