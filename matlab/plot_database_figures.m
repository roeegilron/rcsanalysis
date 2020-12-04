function plot_database_figures()
close all; 
clear all;
clc;
fprintf('the time is:\n%s\n',datetime('now'));
startTic = tic;



% set destination folders
dropboxFolder = findFilesBVQX('/Users','Starr Lab Dropbox',struct('dirs',1,'depth',2));
if length(dropboxFolder) == 1
    dirname  = fullfile(dropboxFolder{1}, 'RC+S Patient Un-Synced Data');
    rootdir = fullfile(dirname,'database');
else
    error('can not find dropbox folder, you may be on a pc');
end

reportdir = fullfile(rootdir,'reports');
figdir = fullfile(rootdir,'figures_per_patient-time-recorded');
if ~exist(reportdir,'dir')    
    mkdir(reportdir);
end
if ~exist(figdir,'dir')
    mkdir(figdir);
end



load(fullfile(rootdir,'database_from_device_settings.mat'),'masterTableLightOut');
masterTableOut = masterTableLightOut;
%% load patient specific data 
idxkeep = cellfun(@(x) any(strfind(x,'RCS')), masterTableOut.patient);
masterTableOut = masterTableOut(idxkeep,:);
uniquePatients = unique(masterTableOut.patient);
for p = 1:length(uniquePatients)
    idxpatient = strcmp(masterTableOut.patient,uniquePatients{p});
    tbl_patient = masterTableOut(idxpatient,:);
    tbl_patient.duration.Format = 'hh:mm';
    fprintf('%s \n %s \n %s\n\n',...
        tbl_patient.patient{1},...
        sum(tbl_patient.duration),...
        tbl_patient.timeStart(end))
    %% loop on side and create report
    uniqueSides = unique(tbl_patient.side);
    for s = 1:length(uniqueSides)
        idxside = strcmp(tbl_patient.side,uniqueSides{s});
        tbluse = tbl_patient(idxside,:);
        [y,m,d] = ymd(tbluse.timeStart);
        uniqueYears = unique(y);
        uniqueMonths = unique(m);
        for yy = 1:length(uniqueYears)
            for mm = 1:length(uniqueMonths)
                idxTblUnqMonth = y == uniqueYears(yy) & m == uniqueMonths(mm);
                tblToPlot = tbluse(idxTblUnqMonth,:); 
                if ~isempty(tblToPlot)
                    %         plot_tbl_stats(fid,tbluse);
                    patientdir = fullfile(figdir,tblToPlot.patient{1});
                    if ~exist(patientdir,'dir')
                        mkdir(patientdir);
                    end
                    
                    plot_continuos_recording_report_from_table(tblToPlot.timeStart,tblToPlot.duration);
                    filename = sprintf('%s_%d_%0.2d_%s_recording_times',tblToPlot.patient{1},uniqueYears(yy),uniqueMonths(mm),tblToPlot.side{1});
                    hfig = gcf;
                    % include patient name in title
                    title_orig = hfig.Children(1).Title.String;
                    patientName = sprintf('%s %s',tbluse.patient{1},tbluse.side{1});
                    tblToPlot.timeStart.Format = 'MMM/uuuu';
                    title_date = tblToPlot.timeStart(1);
                    titleDateStr = sprintf(' %s',title_date);
                    title_modif =  [patientName ' ' title_orig titleDateStr ];
                    hfig.Children(1).Title.String  = title_modif;
                    prfig.plotwidth           = 20;
                    prfig.plotheight          = 9;
                    prfig.figdir              = patientdir;
                    prfig.figtype             = '-djpeg';
                    prfig.closeafterprint     = 1;
                    prfig.resolution          = 300;
                    prfig.figname             = filename;
                    plot_hfig(hfig,prfig);
                end
            end
        end
    end
end

%% create some summary plots per patient (stim on/ stim off) 
%% load patient specific data 
idxkeep = cellfun(@(x) any(strfind(x,'RCS')), masterTableOut.patient);
masterTableOut = masterTableOut(idxkeep,:);
uniquePatients = unique(masterTableOut.patient);
cntOut = 1; 
tblSummary = table();
for p = 1:length(uniquePatients)
    idxpatient = strcmp(masterTableOut.patient,uniquePatients{p});
    tbl_patient = masterTableOut(idxpatient,:);
    tbl_patient.duration.Format = 'hh:mm';
    fprintf('%s \n %s \n %s\n\n',...
        tbl_patient.patient{1},...
        sum(tbl_patient.duration),...
        tbl_patient.timeStart(end))
    % loop on side and create report
    uniqueSides = unique(tbl_patient.side);
    for st = 1:2 % loop on stim state 
        for s = 1:length(uniqueSides)
            idxside = strcmp(tbl_patient.side,uniqueSides{s});
            tbluse = tbl_patient(idxside,:);
            [y,m,d] = ymd(tbluse.timeStart);
            uniqueYears = unique(y);
            uniqueMonths = unique(m);
            for yy = 1:length(uniqueYears)
                for mm = 1:length(uniqueMonths)
                    idxTblUnqMonth = y == uniqueYears(yy) & m == uniqueMonths(mm);
                    if st == 1 
                        idxstim = tbluse.stimulation_on == 0;
                        stimState = 'off';
                    elseif st == 2 
                        idxstim = tbluse.stimulation_on == 1;
                        stimState = 'on';
                    end
                    tblToPlot = tbluse(idxTblUnqMonth & idxstim,:);
                    if ~isempty(tblToPlot)
                        dateUse = tblToPlot.timeStart(1);
                        tblSummary.patient{cntOut} = tblToPlot.patient{1};
                        tblSummary.side{cntOut} = tblToPlot.side{1};
                        tblSummary.date(cntOut) = dateUse;
                        tblSummary.stimState{cntOut} = stimState;
                        tblSummary.duration(cntOut) = sum(tblToPlot.duration);
                        cntOut = cntOut + 1; 
                    end
                end
            end
        end
    end
end
tblSummary.date.Format = 'MMM-uuuu';
%% plot per patient plots 
uniquePatients = unique(tblSummary.patient);
cntOut = 1; 

cntplt = 1; 
for p = 1:length(uniquePatients)
    idxpatient = strcmp(tblSummary.patient,uniquePatients{p});
    tbl_patient = tblSummary(idxpatient,:);
    % loop on side and create report
    hfig = figure;
    hfig.Color = 'w';
    uniqueSides = unique(tbl_patient.side);
    for s = 1:length(uniqueSides)
        idxuseSide = strcmp(tbl_patient.side,uniqueSides(s));
        tbluse = tbl_patient(idxuseSide,:);
        tbluse = sortrows(tbluse,{'date','stimState'});
        hsb = subplot(3,1,s); 
        hold on;
        for dt = 1:size(tbluse,1)
            hsb.XTickLabel{dt} = sprintf('%s',tbluse.date(dt));
            hbar(dt) = bar(dt, days(tbluse.duration(dt)));
            if strcmp(tbluse.stimState(dt),'on')
                colorUse = [0 0.8 0];
            elseif strcmp(tbluse.stimState(dt),'off')
                colorUse = [0.8 0 0];
            else
                colorUse = [0.5 0.5 0.5];
            end
            hbar(dt).FaceColor = colorUse;
            hbar(dt).FaceAlpha = 0.8;
        end
        ylabel('days');
        clear hbar 
        hsb.XTick = 1:size(tbluse,1);
        hsb.XTickLabelRotation = 45;
        title(sprintf('%s (%s total)',tbluse.side{s},sum(tbluse.duration)));
        sgtitle(sprintf('%s',tbluse.patient{1}));
        clear hsb; 

    end
    % save
    filename = sprintf('1_%s_summary_plot',tbluse.patient{1});
    patientdir = fullfile(figdir,tbluse.patient{1});
    prfig.plotwidth           = 12;
    prfig.plotheight          = 17;
    prfig.figdir              = patientdir;
    prfig.figtype             = '-djpeg';
    prfig.closeafterprint     = 1;
    prfig.resolution          = 300;
    prfig.figname             = filename;
    plot_hfig(hfig,prfig);
end



%%

%% create total amount recorded across patients (in days) 

%% 
timeTook = seconds(toc(startTic));
timeTook.Format = 'hh:mm:ss';
fprintf('finished all figures in %s\n',timeTook);
fprintf('finished job and time is:\n%s\n',datetime('now'))



end



