function plot_all_embedded_adaptive_from_database()
close all; clc;
%% load database
rootdir_orig = '/Users/roee/Starr Lab Dropbox/';
patientFolders  = fullfile(rootdir_orig,'RC+S Patient Un-Synced Data');

database_folder = fullfile(rootdir_orig,'RC+S Patient Un-Synced Data','database');
figdir          = fullfile(database_folder,'figures_adaptive');

load(fullfile(database_folder,'sense_stim_database.mat'));
%%
db = sense_stim_database;


params.group = 'D';
params.stim  = 1;
params.min_size = hours(1);

%%
reloadDB = 0;

if reloadDB

idxuse = strcmp(db.group,params.group) & ...
    db.stimulation_on == params.stim & ...
    db.duration >= params.min_size;
dbAdapt = db(idxuse,:);

% loop on this databse and only plot files in which adaptive is actually
% changing
db = dbAdapt;
for d = 1:size(db,1)
    start  = tic;
    patdir = findFilesBVQX(patientFolders,['*', db.patient{d} '*'],struct('dirs',1,'depth',1));
    scbsdir = findFilesBVQX(patdir{1},'SummitContinuousBilateralStreaming',struct('dirs',1));
    patsid = findFilesBVQX(scbsdir,[db.patient{d} ,db.side{d}],struct('dirs',1));
    sessdir = findFilesBVQX(patsid{1}, ['*',db.sessname{d} ,'*'],struct('dirs',1));
    devdir  = findFilesBVQX(sessdir{1},'*evice*',struct('dirs',1,'depth',1));
    fnSettings = fullfile(devdir{1},'DeviceSettings.json');
    adaptiveSettings = loadAdaptiveSettings(fnSettings); 
    cur(1,1) = adaptiveSettings.currentMa_state0(1);
    cur(1,2) = adaptiveSettings.currentMa_state1(1);
    cur(1,3) = adaptiveSettings.currentMa_state2(1);
    db.CurrentStates(d,:) = cur; 
    db.devdir{d}  = devdir;
    if length( unique(cur) ) > 1 
        db.AdaptiveCurrentChanging(d) = 1;
    else
        db.AdaptiveCurrentChanging(d) = 0;
    end 
    fprintf('%d/%d done in %.2f \n',d,size(db,1),toc(start));
end
    save(fullfile(database_folder,'adaptive_database.mat'),'db');
else
    load(fullfile(database_folder,'adaptive_database.mat'),'db');
end
%%
% plot only 

%% loop on adaptive database and create plots on a daily basis
% ploy only adaptive with large chnages 
idxLargeChangs = abs(db.CurrentStates(:,1) - db.CurrentStates(:,3)) > 0.2;
dbAdapt = db(idxLargeChangs,:); 
dbAdapt(:,{'rectime','patient','side','CurrentStates'})
uniquePatients = unique(dbAdapt.patient);
for p = 1:length(uniquePatients)
    patDB = dbAdapt(strcmp(dbAdapt.patient,uniquePatients{p}) , :);
    
    % find the unique days in each recordingt
    tbl = table();
    [tbl.y,tbl.m,tbl.d] = ymd(patDB.startTime);
    unqDays = unique(tbl,'rows');
    % only look at 2020 data 
    unqDays = tbl(tbl.y == 2020,:);
    for u = 1:size(unqDays,1)
        idxPlot = year(patDB.startTime) == tbl.y(u) & ...
            month(patDB.startTime) == tbl.m(u) & ...
            day(patDB.startTime) == tbl.d(u);
        aDBSplot = patDB(idxPlot,:);
        plot_adbs_day(aDBSplot,patientFolders,figdir)
    end
end
end

function plot_adbs_day(db,rootdir,figdir)
close all;
%% decide which files actually have current changes 
%% and find all the files / load data 
for s = 1:size(db,1) 
    patdir = findFilesBVQX(rootdir,['*', db.patient{s} '*'],struct('dirs',1,'depth',1));
    scbsdir = findFilesBVQX(patdir{1},'SummitContinuousBilateralStreaming',struct('dirs',1));
    patsid = findFilesBVQX(scbsdir,[db.patient{s} ,db.side{s}],struct('dirs',1));
    sessdir = findFilesBVQX(patsid{1}, ['*',db.sessname{s} ,'*'],struct('dirs',1));
    devdir  = findFilesBVQX(sessdir{1},'*evice*',struct('dirs',1,'depth',1));
    fnAdaptive = fullfile(devdir{1},'AdaptiveLog.json');
    fnDeviceSettings = fullfile(devdir{1},'DeviceSettings.json');
    mintrim = 10;
    
    % load adapative 
    [deviceSettingsOut,stimStatus,~]  = loadDeviceSettingsForMontage(fnDeviceSettings);
    res = readAdaptiveJson(fnAdaptive);
    cur = res.adaptive.CurrentProgramAmplitudesInMilliamps(1,:);
    timestamps = datetime(datevec(res.timing.timestamp./86400 + datenum(2000,3,1,0,0,0))); % medtronic time - LSB is seconds
    uxtimes = datetime(res.timing.PacketGenTime/1000,...
        'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
    yearUse = mode(year(uxtimes));
    idxKeepYear = year(uxtimes)==yearUse;
    
    % inputs
    ld0 = res.adaptive.LD0_output(idxKeepYear);
    ld0_high = res.adaptive.LD0_highThreshold(idxKeepYear);
    ld0_low  = res.adaptive.LD0_lowThreshold(idxKeepYear);
    timesUseDetector = uxtimes(idxKeepYear);
    idxkeepdet = timesUseDetector > (timesUseDetector(1) + minutes(mintrim));
    
    timesUseDetector = timesUseDetector(idxkeepdet);
    ld0 = ld0(idxkeepdet);
    ld0_high = ld0_high(idxkeepdet);
    ld0_low = ld0_low(idxkeepdet);
    
    % get rid of negative diffs (e.g. times for past)
    idxbad = find(seconds(diff(timesUseDetector))<0)+1;
    idxkeep = setxor(1:length(timesUseDetector),idxbad);
    timesUseDetector = timesUseDetector(idxkeep);
    ld0 = ld0(idxkeep);
    ld0_high = ld0_high(idxkeep);
    ld0_low = ld0_low(idxkeep);
    
    timesUseCur = uxtimes(idxKeepYear);
    idxkeepcur = timesUseCur > (timesUseCur(1) + minutes(mintrim));
    timesUseCur = timesUseCur(idxkeepcur);
    
    % trim start of file
    cur = cur(idxkeepcur);
    
    db.cur{s} = cur; 
    db.timesUseDetector{s} = timesUseDetector;
    db.timesUseCur{s} = timesUseCur;
    db.ld0{s} =  ld0;
    db.ld0_high{s}  = ld0_high;
    db.ld0_low{s} = ld0_low; 
    uniqCurrents = unique(cur); 
    if length(uniqCurrents) == 1
        db.adaptive_running(s) = 0; 
    else
        db.adaptive_running(s) = 1; 
    end

end

    %% set up figure
    hfig = figure;
    hfig.Color = 'w';
    hpanel = panel();
    hpanel.pack('h',{10 []});
    hpanel(2).pack(4,1);
    hpanel.select('all');
    hpanel.fontsize = 12;
    %%
    nrows = 4;
    for i = 1:nrows
        hpanel(2,i,1).select();
        hsb(i) = gca; 
        hold(hsb(i),'on');
    end
    %% plot data 
    
    unqSides = unique(db.side);
    for ss = 1:length(unqSides)
        
        idxuse = strcmp(db.side,unqSides{ss});
        dbuse = db(idxuse,:); 
        for d = 1:size(dbuse,1)
            % plot the detector
            orderplot = [1 2 3 4];
            if strcmp(dbuse.side(d),'L')
                idxplot = 1; 
            elseif strcmp(dbuse.side(d),'R')
                idxplot = 3; 
            end
            timesUseDetector = dbuse.timesUseDetector{d};
            ld0 = dbuse.ld0{d};
            ld0_high = dbuse.ld0_high{d};
            ld0_low = dbuse.ld0_low{d};
            
            % remove outliers 
            outlierIdx = isoutlier(ld0);
            ld0 = ld0(~outlierIdx);
            ld0_high = ld0_high(~outlierIdx);
            ld0_low = ld0_low(~outlierIdx);
            timesUseDetector = timesUseDetector(~outlierIdx);
            
            
            hplt = plot(hsb(idxplot),timesUseDetector,ld0,'LineWidth',2.5,'Color',[0 0 0.8 ]);
            hplt = plot(hsb(idxplot),timesUseDetector,ld0_high,'LineWidth',2,'Color',[0.8 0 0 ]);
            hplt.LineStyle = '-.';
            hplt.Color = [hplt.Color 0.7];
            hplt = plot(hsb(idxplot),timesUseDetector,ld0_low,'LineWidth',2,'Color',[0.8 0 0]);
            hplt.LineStyle = '-.';
            hplt.Color = [hplt.Color 0.7];
            prctile_99 = prctile(ld0,99);
            prctile_1  = prctile(ld0,1);
            if prctile_1 > ld0_low(1)
                prctile_1 = ld0_low(1) * 0.9;
            end
            if prctile_99 < ld0_high(1) 
                prctile_99 = ld0_high(1)*1.1;
            end
            ylim(hsb(idxplot),[prctile_1 prctile_99]);
            ttlus = sprintf('Control signal %s',unqSides{ss});
            title(hsb(idxplot),ttlus);
            ylabel(hsb(idxplot),'Control signal (a.u.)');
            set(hsb(idxplot),'FontSize',16);
            % plut the current 
            idxplot = idxplot + 1; 
            timesUseCur = dbuse.timesUseCur{d};
            cur = dbuse.cur{d};
            % remove outliers 
            outlierIdx = isoutlier(cur);
            cur = cur(~outlierIdx);
            timesUseCur = timesUseCur(~outlierIdx);

            

            plot(hsb(idxplot),timesUseCur,cur,'LineWidth',3,'Color',[0 0.8 0 0.7]);
            for i = 1:3 
                states{i} = sprintf('%0.1fmA',dbuse.CurrentStates(i));

                if i == 2 
                    if dbuse.CurrentStates(i) == 25.5
                        states{i} = 'HOLD';
                    end
                end
            end
            ttlus = sprintf('Current in mA %s [%s, %s, %s]',unqSides{ss},states{1},states{2},states{3});
            title(hsb(idxplot) ,ttlus);
            ylabel( hsb(idxplot) ,'Current (mA)');
            set( hsb(idxplot),'FontSize',16);
            
        end
    end
    % get link axes to work - time zone issue with empty axes 
    if strcmp(unique(dbuse.side),{'L'})
        plot(hsb(3),[timesUseCur(1) timesUseCur(end)],[0 0],'Color',[1 1 1]);
        plot(hsb(4),[timesUseCur(1) timesUseCur(end)],[0 0],'Color',[1 1 1]);
    elseif strcmp(unique(dbuse.side),{'R'})
        plot(hsb(1),[timesUseCur(1) timesUseCur(end)],[0 0],'Color',[1 1 1]);
        plot(hsb(2),[timesUseCur(1) timesUseCur(end)],[0 0],'Color',[1 1 1]);
    end
    linkaxes(hsb,'x');
    ttlLarge{1,1} = dbuse.patient{1}; 
    [y,m,d] = ymd(dbuse.startTime(1));
    ttlLarge{2,1} = sprintf('%.4d/%.2d/%.2d',y,m,d);
    sgtitle(ttlLarge,'FontSize',16);
    
    
    strPrint = getAdaptiveHumanReadaleSettings(fnDeviceSettings,0);
    if ~isempty(strPrint)
        x = 2;
    end
    % save figure; 
    fig_title = sprintf('%s_%d_%0.2d-%0.2d',dbuse.patient{1},y,m,d);
    prfig.plotwidth           = 20;
    prfig.plotheight          = 9;
    prfig.figdir              = figdir;
    prfig.figtype             = '-djpeg';
    prfig.closeafterprint     = 0;
    prfig.resolution          = 300;
    prfig.figname             = fig_title;
    plot_hfig(hfig,prfig);
    close(hfig);


end