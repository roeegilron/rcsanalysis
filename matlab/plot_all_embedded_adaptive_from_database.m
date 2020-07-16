function plot_all_embedded_adaptive_from_database()
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

idxuse = strcmp(db.group,params.group) & ...
    db.stimulation_on == params.stim & ...
    db.duration >= params.min_size;
dbAdapt = db(idxuse,:);

%%

%% loop on adaptive database and create plots on a daily basis
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

%% decide which files actually have current changes 
%% and find all the files / load data 
for s = 1:size(db,1) 
    patdir = findFilesBVQX(rootdir,['*', db.patient{s} '*'],struct('dirs',1,'depth',1));
    scbsdir = findFilesBVQX(patdir{1},'SummitContinuousBilateralStreaming',struct('dirs',1));
    patsid = findFilesBVQX(scbsdir,[db.patient{s} ,db.side{s}],struct('dirs',1));
    sessdir = findFilesBVQX(patsid{1}, ['*',db.sessname{s} ,'*'],struct('dirs',1));
    devdir  = findFilesBVQX(sessdir{1},'*evice*',struct('dirs',1,'depth',1));
    fnAdaptive = fullfile(devdir{1},'AdaptiveLog.json');
    
    mintrim = 10;
    
    % load adapative 
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
if sum(db.adaptive_running) == 0
    return; 
    % in group d but current isn't changing at all on either side
else
    %% set up figure
    hfig = figure;
    hfig.Color = 'w';
    nrows = 4;
    for i = 1:nrows
        hsb(i) = subplot(nrows,1,i);
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
            if ss <= 2 
                idxplot = 1; 
                
            else
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
            ttlus = sprintf('Current in mA %s',unqSides{ss});
            title(hsb(idxplot) ,ttlus);
            ylabel( hsb(idxplot) ,'Current (mA)');
            set( hsb(idxplot),'FontSize',16);
            
        end
    end
    % get link axes to work - time zone issue with empty axes 
    if strcmp(unique(dbuse.side),{'L'})
        plot(hsb(3),timesUseCur(1),0);
        plot(hsb(4),timesUseCur(1),0);
    elseif strcmp(unique(dbuse.side),{'R'})
        plot(hsb(1),timesUseCur(1),0);
        plot(hsb(2),timesUseCur(1),0);
    end
    linkaxes(hsb,'x');
    ttlLarge{1,1} = dbuse.patient{1}; 
    [y,m,d] = ymd(dbuse.startTime(1));
    ttlLarge{2,1} = sprintf('%.4d/%.2d/%.2d',y,m,d);
    sgtitle(ttlLarge,'FontSize',16);
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

end

end