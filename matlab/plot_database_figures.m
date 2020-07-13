function plot_database_figures()
close all; 
clear all;
clc;
% rootdir = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/';
rootdir = '/Users/juananso/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/';
load(fullfile(rootdir,'sense_stim_database.mat'));
reportdir = fullfile(rootdir,'reports'); 
figdir = fullfile(rootdir,'figures_per_patient-time-recorded');
mkdir(figdir);
mkdir(reportdir); 

%% load patient specific data 
uniquePatients = unique(sense_stim_database.patient);
for p = 1:length(uniquePatients)
    idxpatient = strcmp(sense_stim_database.patient,uniquePatients{p});
    tbl_patient = sense_stim_database(idxpatient,:);
    fprintf('%s \n %s \n %s\n\n',...
        tbl_patient.patient{1},...
        sum(tbl_patient.duration),...
        tbl_patient.startTime(end))
    %% loop on side and create report
    uniqueSides = unique(tbl_patient.side);
    for s = 1:length(uniqueSides)
        idxside = strcmp(tbl_patient.side,uniqueSides{s});
        tbluse = tbl_patient(idxside,:);
        filename = sprintf('%s_%s_sense_stim_report.txt',tbluse.patient{1},tbluse.side{1});
        fid = fopen(fullfile(reportdir,filename),'w+');
        plot_tbl_stats(fid,tbluse);
        plot_continuos_recording_report_from_table(tbluse.startTime,tbluse.duration);
        filename = sprintf('%s_%s_recording_times',tbluse.patient{1},tbluse.side{1});
        hfig = gcf;
        prfig.plotwidth           = 20;
        prfig.plotheight          = 9;
        prfig.figdir              = figdir;
        prfig.figtype             = '-djpeg';
        prfig.closeafterprint     = 1;
        prfig.resolution          = 300;
        prfig.figname             = filename;
        plot_hfig(hfig,prfig);
    end
end


end



