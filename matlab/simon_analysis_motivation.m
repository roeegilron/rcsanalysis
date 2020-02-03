function simon_analysis()
%% load and open data 
rootdir = '/Volumes/RCS_DATA/RCS06/RCSO6_R';
MAIN_report_data_in_folder(rootdir); 
load(fullfile(rootdir,'database.mat'));
MAIN_load_rcsdata_from_folders(rootdir); 
%%
%% cut that data up 
hfig = figure; 
hfig.Color = 'w'; 
for i = 1:size(tblout)
    [pn,fn] =  fileparts(tblout.tdfile{i}); 
    [outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerOut,adaptiveTable] =  MAIN_load_rcs_data_from_folder(pn);
    secsUse = outdatcompleteAcc.derivedTimes;
    dtvec  = datevec(secsUse(end));
    dtvec(4) = 4;
    dtvec(5) = 0;
    dateover = datetime(dtvec);
    dateover.TimeZone = secsUse.TimeZone;
    idxusse = secsUse > dateover;
    x = outdatcompleteAcc.XSamples(idxusse);
    y = outdatcompleteAcc.YSamples(idxusse);
    z = outdatcompleteAcc.ZSamples(idxusse);
    x = x - mean(x); 
    z = y - mean(y); 
    z = y - mean(z); 
    subplot(7,1,i); 
    hold on; 
    plot(secsUse(idxusse),x);
    plot(secsUse(idxusse),y);
    plot(secsUse(idxusse),z);
    fprintf('%s\n',secsUse(end))
end
% get limits 
haxes = get(hfig,'Children');
limits(1,:) = datetime({'10-Dec-2019 05:06:04.015'   '10-Dec-2019 05:06:25.746'});
limits(2,:) = datetime({'11-Dec-2019 07:55:25.382'   '11-Dec-2019 07:57:11.399'});
limits(3,:) = datetime({'14-Dec-2019 05:54:44.241'   '14-Dec-2019 05:57:31.714'});
limits(4,:) = datetime({'15-Dec-2019 07:10:19.025'   '15-Dec-2019 07:10:53.426'});
limits(5,:) = datetime({'16-Dec-2019 07:40:23.480'   '16-Dec-2019 07:43:24.726'});
limits(6,:) = datetime({'18-Dec-2019 06:55:08.682'   '18-Dec-2019 06:59:31.904'});
limits(7,:) = datetime({'19-Dec-2019 06:45:45.734'   '19-Dec-2019 06:46:48.511'});
%%
%% do some correlations 
close all; 
addpath(genpath(fullfile(pwd,'toolboxes','panel-2.14')));
hfig = figure; 
hfig.Color = 'w';
hpanel = panel();
hpanel.pack(7,4); 
for i = 1:size(tblout)
    [pn,fn] =  fileparts(tblout.tdfile{i}); 
    [outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerOut,adaptiveTable] =  MAIN_load_rcs_data_from_folder(pn);
    secstime = outdatcomplete.derivedTimes; 
    time1 = limits(i,1); time1.TimeZone = secstime.TimeZone; 
    time2 = limits(i,2); time2.TimeZone = secstime.TimeZone; 
    time2 = secstime(end); 
    time1 = secstime(end) - minutes(2); 
    idxuse = secstime >= time1 & secstime <= time2;
    for c = 1:4
        hsub = hpanel(i,c).select();
        axes(hsub); 
        hold on; 
        fnuse = sprintf('key%d',c-1);
        y = outdatcomplete.(fnuse)(idxuse); 
        srate = unique(outdatcomplete.samplerate);
        [fftOut,f]   = pwelch(y,srate,srate/2,0:1:srate/2,srate,'psd');
%         plot(f,log10(fftOut));
        plot(secstime(idxuse),y);
        title(outRec.tdData(c).chanFullStr);
%         xlim([3 60]);
    end
end
hpanel.margin = 20;

%% 
end