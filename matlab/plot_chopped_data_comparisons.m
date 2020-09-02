function plot_chopped_data_comparisons()
close all;
clc;
dirname = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/in_clinic/rest_3rd_try';
params.figdir  = dirname;
params.figtype = '-dpdf';
params.resolution = 150;
params.closeafterprint = 0;
params.figname = 'on_off_meds_all_patients_3rd_try';
params.plotwidth = 35;
params.plotheight = 25;

% make database 
ff = findFilesBVQX(dirname,'RCS*.mat');
datTbl = table(); 
for f = 1:length(ff)
    [pn,fn] = fileparts(ff{f}); 
    datTbl.patient{f} = fn(1:5);
    datTbl.side{f} = fn(end);
    if any(strfind(fn,'on'))
     datTbl.med{f}  = 'on';   
    else
     datTbl.med{f}  = 'off';    
    end
    datTbl.fn{f} = fn; 
    
    load(ff{f});
    datTbl.data{f} = outdatachunk;
    datTbl.outRec{f} = outRec;
    for c = 1:4
        datTbl.(sprintf('key%d',c-1)){f} = outRec.tdData(c).chanFullStr;
    end
    clear outdatachunk
    datTbl.ff{f} = ff{f}; 
end

patients = {'RCS02','RCS05','RCS06','RCS07','RCS08'};
types    = {'rest_off_meds','rest_on_meds'};
sides    = {'L','R'};
medstates = {'on','off'}; 
canperside = [1 2; 3 4];
typeLeg  = {'off meds','on meds'};

colorsUse   = [ 0 0.8 0 0.5; 0.8 0 0 0.5];
ttls   = {'STN 0-2','STN 1-3','M1 8-10','M1 9-11'};
cnsUsePerPatient = [1 , 3  ;...
    2 , 4  ;...
    2 , 4  ;...
    2 , 4];


fnmsave = fullfile(dirname,'patientRAWDATA_in_clinic.mat');
save(fnmsave);

%% plot evetything
plotthis = 1;
cntplt = 1;
hfig = figure;
hfig.Color = 'w';
patientPSD_in_clinic = table(); 
cntOut = 1; 
if plotthis
    for p = 1:length(patients)
        for s = 1:2 % channel group 
            for c = canperside(s,:)
                for ss = 1:2 % loop on side
                    subplot(length(patients),8,cntplt); cntplt = cntplt + 1;
                    hold on;
                    for m = 1:2
                        idxuse = strcmp(datTbl.patient,patients{p}) & ...
                            strcmp(datTbl.side,sides{ss}) & ...
                            strcmp(datTbl.med,medstates{m} );
                        outdatcomplete = datTbl.data{idxuse};
                        times = outdatcomplete.derivedTimes;
                        srate = unique( outdatcomplete.samplerate );
                        % get data and cmoptue psd 
                        fnm = sprintf('key%d',c-1);
                        y = outdatcomplete.(fnm);
                        y = y - mean(y);
                        [fftOut,f]   = pwelch(y,srate,srate/2,0:1:srate/2,srate,'psd');
                        fftLogged = log10(fftOut); 
                        % plot 
                        plot(f,log10(fftOut),'LineWidth',4,'Color',colorsUse(m,:));
                        xlim([0 120]);
                        xlabel('Frequency (Hz)');
                        ylabel('Power  (log_1_0\muV^2/Hz)');
                        ttluse = sprintf('%s %s %s',patients{p},sides{ss},ttls{c});
                        title(ttluse,'FontSize',16);
                        % save data to plot group averages later
                        patientPSD_in_clinic.patient{cntOut} = patients{p};
                        patientPSD_in_clinic.side{cntOut} = sides{ss};
                        patientPSD_in_clinic.medstate{cntOut} = medstates{m};
                        patientPSD_in_clinic.electrode{cntOut} = ttls{c};
                        patientPSD_in_clinic.rawdata{cntOut} = y;
                        patientPSD_in_clinic.srate{cntOut} = srate;
                        patientPSD_in_clinic.ff{cntOut} = f;
                        patientPSD_in_clinic.fftOut{cntOut} = fftLogged; 
                        idxnorm = f >=5 & f <=90; 
                        fftLogged = fftLogged./abs((mean(fftLogged(idxnorm))));
%                         idxnorm = f >=51 & f <=90; 
%                         fftLogged(idxnorm) = fftLogged(idxnorm)./abs((mean(fftLogged(idxnorm))));
                        patientPSD_in_clinic.fftOutNorm{cntOut} = fftLogged; 
                        cntOut = cntOut + 1; 
                    end
                    legend(medstates);
                end
            end
        end
    end
    params.figname = 'on_off_meds_all_patients_3rd_try_v1_normed_all_psd';
    plot_hfig(hfig,params)
end
%% plot coherence table as well 
uniquePatiets = unique(patientPSD_in_clinic.patient); 
medStates     = unique(patientPSD_in_clinic.medstate); 
posSides      = unique(patientPSD_in_clinic.side); 
uniqeElec     = unique(patientPSD_in_clinic.electrode); 
m1Elecs       = uniqeElec(1:2);
stnElecs      = uniqeElec(3:4);
%%
patientCOH_in_clinic = table();
cntOut = 1; 
for p = 1:length(uniquePatiets) % loop on patients 
    for m = 1:length(medStates)
        for s = 1:length(posSides)
            for c = 1:length(m1Elecs)
                for n = 1:length(stnElecs)
                    idxSTN    =  strcmp(patientPSD_in_clinic.patient,uniquePatiets{p}) & ...
                                 strcmp(patientPSD_in_clinic.medstate, medStates{m}) & ... 
                                 strcmp(patientPSD_in_clinic.side,posSides{s}) & ...
                                 strcmp(patientPSD_in_clinic.electrode,stnElecs{n});
                             
                    idxM1     =  strcmp(patientPSD_in_clinic.patient,uniquePatiets{p}) & ...
                                 strcmp(patientPSD_in_clinic.medstate,medStates{m}) & ...
                                 strcmp(patientPSD_in_clinic.side,posSides{s}) & ...
                                 strcmp(patientPSD_in_clinic.electrode,m1Elecs{c});

                    chan1 = stnElecs{n};
                    chan2 = m1Elecs{c};
                    x = patientPSD_in_clinic(idxSTN,:).rawdata{1};
                    y = patientPSD_in_clinic(idxM1,:).rawdata{1};
                    Fs = patientPSD_in_clinic(idxSTN,:).srate{1};
                    [Cxy,F] = mscohere(x',y',...
                        2^(nextpow2(Fs)),...
                        2^(nextpow2(Fs/2)),...
                        2^(nextpow2(Fs)),...
                        Fs);
                    patientCOH_in_clinic.patient{cntOut} = uniquePatiets{p};
                    patientCOH_in_clinic.side{cntOut} = posSides{s};
                    patientCOH_in_clinic.medstate{cntOut} = medStates{m};
                    patientCOH_in_clinic.chan1{cntOut} = chan1;
                    patientCOH_in_clinic.chan2{cntOut} = chan2;
                    patientCOH_in_clinic.srate{cntOut} = Fs;
                    patientCOH_in_clinic.mscoherence{cntOut} = Cxy;
                    patientCOH_in_clinic.ffCoh{cntOut} = F;
                    cntOut = cntOut + 1; 
                end
            end
        end
    end
end
%%

fnmsave = fullfile(dirname,'patientPSD_in_clinic.mat');
save(fnmsave,'patientPSD_in_clinic','patientCOH_in_clinic');

return
%% plot PAC 
dirname = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/in_clinic/rest_3rd_try';
fnmsave = fullfile(dirname,'patientPSD_in_clinic.mat');
addpath(genpath(fullfile('..','..','PAC')));
load(fnmsave,'patientPSD_in_clinic');

close all;
pacparams.PhaseFreqVector      = 5:2:50;
pacparams.AmpFreqVector        = 10:5:200;

pacparams.PhaseFreq_BandWidth  = 4;
pacparams.AmpFreq_BandWidth    = 10;
pacparams.computeSurrogates    = 0;
pacparams.numsurrogate         = 0;
pacparams.alphause             = 0.05;
pacparams.plotdata             = 0;
pacparams.useparfor            = 0; % if true, user parfor, requires parallel computing toolbox
pacparams.regionnames          = {'STN','M1'};

prfig.figdir  = dirname;
prfig.figtype = '-dpdf';
prfig.resolution = 150;
prfig.closeafterprint = 1;
prfig.plotwidth = 35;
prfig.plotheight = 27;


uniquePatients = unique(patientPSD_in_clinic.patient);
for p = 1:length(uniquePatients)
    hfig = figure; 
    hfig.Color = 'w';
    idxpat = strcmp(patientPSD_in_clinic.patient,uniquePatients{p});
    pdb = patientPSD_in_clinic(idxpat,:); 
    for c = 1:size(pdb,1)
        subplot(4,4,c); 
        y = pdb.rawdata{c};
        srate = pdb.srate{c};
        if srate == 250
            pacparams.AmpFreqVector        = 10:5:80;
        elseif srate == 1e3
            pacparams.AmpFreqVector        = 10:5:200;
        elseif srate == 500
            pacparams.AmpFreqVector        = 10:5:200;
        end
        results = computePAC(y',srate,pacparams);
        res = results(1);
        contourf(res.PhaseFreqVector+res.PhaseFreq_BandWidth/2,...
            res.AmpFreqVector+res.AmpFreq_BandWidth/2,...
            res.Comodulogram',30,'lines','none')
        shading interp
        ttly = sprintf('Amplitude Frequency %s (Hz)',pdb.electrode{c});
        ylabel(ttly)
        ttlx = sprintf('Phase Frequency %s (Hz)',pdb.electrode{c});
        xlabel(ttlx)
        ttluse = sprintf('%s %s %s med %s',uniquePatients{p},pdb.side{c},pdb.electrode{c},pdb.medstate{c});
        title(ttluse);
        set(gca,'FontSize',20);
    end
    prfig.figname = sprintf('PAC_%s.pdf',uniquePatients{p});
    plot_hfig(hfig,prfig)
end

%% plot coherence across patients 
dirname = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/in_clinic/rest_3rd_try';
fnmsave = fullfile(dirname,'patientPSD_in_clinic.mat');
addpath(genpath(fullfile('..','..','PAC')));
load(fnmsave,'patientPSD_in_clinic');

close all;
pacparams.PhaseFreqVector      = 5:2:50;
pacparams.AmpFreqVector        = 10:5:200;


prfig.figdir  = dirname;
prfig.figtype = '-dpdf';
prfig.resolution = 150;
prfig.closeafterprint = 1;
prfig.plotwidth = 25;
prfig.plotheight = 15;


uniquePatients = unique(patientPSD_in_clinic.patient);
sides = {'L','R'};
medstate = {'on','off'}; 
pairsuse = {'STN 0-2','M1 8-10';...
    'STN 0-2','M1 9-11';...
    'STN 1-3','M1 8-10';...
    'STN 1-3','M1 9-11'};
colorsUse = [0 0.8 0 0.6;...    
             0.8 0 0 0.6];    
for p = 1:length(uniquePatients)
    hfig = figure; 
    hfig.Color = 'w';
    idxpat = strcmp(patientPSD_in_clinic.patient,uniquePatients{p});
    pdb = patientPSD_in_clinic(idxpat,:); 
    cntplt = 1; 
    for s = 1:length(sides)% loop on side s
        for r = 1:size(pairsuse,1)
            hsb(cntplt) = subplot(4,2,cntplt); cntplt = cntplt + 1; 
            hold on; 
            for m = 1:length(medstate)
                idxrec = strcmp(pdb.side,sides{s}) & strcmp(pdb.medstate,medstate{m});
                dbuse = pdb(idxrec,:);
                idxpair1 = strcmp(dbuse.electrode,idxpairs{r,1});
                y1 = dbuse.rawdata{idxpair1};
                idxpair2 = strcmp(dbuse.electrode,idxpairs{r,2});
                y2 = dbuse.rawdata{idxpair2};
                Fs = dbuse.srate{1};
                [Cxy,F] = mscohere(y1',y2',...
                    2^(nextpow2(Fs)),...
                    2^(nextpow2(Fs/2)),...
                    2^(nextpow2(Fs)),...
                    Fs);
                hplot = plot(F,Cxy,'LineWidth',2,'Color',colorsUse(m,:));
                xlabel('Frequency (Hz)'); 
                ylabel('MS coherence'); 
            end
            ttluse = sprintf('%s %s - %s',sides{s}, pairsuse{r,1},pairsuse{r,2});
            title(ttluse); 
            xlim([0 100]); 
            set(gca,'FontSize',16); 
        end
    end
    linkaxes(hsb,'y');  
    sgtitle(uniquePatients{p},'FontSize',25);
    prfig.figname = sprintf('Coherence_%s.pdf',uniquePatients{p});
    plot_hfig(hfig,prfig)
end
%% 

%% do stats using GEE 
dirname = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/in_clinic/rest_3rd_try';
fnmsave = fullfile(dirname,'patientPSD_in_clinic.mat');
addpath(genpath(fullfile('toolboxes','GEEQBOX')));
load(fnmsave,'patientPSD_in_clinic');

%% STN 

idxstn = cellfun(@(x) any(strfind(x,'STN')),patientPSD_in_clinic.electrode);
pdbSTN = patientPSD_in_clinic(idxstn,:); 

% groups:  

% id = subject id 
% percent  = beta level averaged between 13-30 
% month - categorical med on/off 
% X - matrix of conditions incdluing (numerical): 
%  1. med state (on/off) 
%  2. side (L/R) 
%  3. montage (0-2 / 1-3) 
uniquePatients = unique(pdbSTN.patient); 
id = zeros(size(pdbSTN,1),1);
for p = 1:length(uniquePatients)
    for i = 1:size(pdbSTN,1)
        id( strcmp(pdbSTN.patient,uniquePatients{p}) ) = p;
    end
end
montage = zeros(size(pdbSTN,1),1);
unqeMontage = unique(pdbSTN.electrode);
montage( strcmp(pdbSTN.electrode,unqeMontage{1}) ) = 1;
montage( strcmp(pdbSTN.electrode,unqeMontage{2}) ) = 2;

medstate = zeros(size(pdbSTN,1),1);
medstate( strcmp(pdbSTN.medstate,'on') ) = 1;
medstate( strcmp(pdbSTN.medstate,'off') ) = 2;

side = zeros(size(pdbSTN,1),1);
side( strcmp(pdbSTN.side,'L') ) = 1;
side( strcmp(pdbSTN.side,'R') ) = 2;

% compute average beta 
meanbeta  = [];
for i = 1:size(pdbSTN,1)
    ff = pdbSTN.ff{i};
    idxuse = ff >= 13 & ff <= 30; 
    meanbeta(i,1) = mean(pdbSTN.fftOutNorm{i}(idxuse));
end

const = ones(size(meanbeta,1),1); 
X = [medstate, montage, side, const];
varnames ={'med state','montage','side','const'}; 
[betahat, alphahat, results] = gee(id, meanbeta, medstate, X, 'n', 'equi', varnames);

%% M1 

idxstn = cellfun(@(x) any(strfind(x,'M1')),patientPSD_in_clinic.electrode);
pdbM1 = patientPSD_in_clinic(idxstn,:); 

% groups:  

% id = subject id 
% percent  = beta level averaged between 13-30 
% month - categorical med on/off 
% X - matrix of conditions incdluing (numerical): 
%  1. med state (on/off) 
%  2. side (L/R) 
%  3. montage (0-2 / 1-3) 
uniquePatients = unique(pdbM1.patient); 
id = zeros(size(pdbM1,1),1);
for p = 1:length(uniquePatients)
    for i = 1:size(pdbM1,1)
        id( strcmp(pdbM1.patient,uniquePatients{p}) ) = p;
    end
end
montage = zeros(size(pdbM1,1),1);
unqeMontage = unique(pdbM1.electrode);
montage( strcmp(pdbM1.electrode,unqeMontage{1}) ) = 1;
montage( strcmp(pdbM1.electrode,unqeMontage{2}) ) = 2;

medstate = zeros(size(pdbM1,1),1);
medstate( strcmp(pdbM1.medstate,'on') ) = 1;
medstate( strcmp(pdbM1.medstate,'off') ) = 2;

side = zeros(size(pdbM1,1),1);
side( strcmp(pdbM1.side,'L') ) = 1;
side( strcmp(pdbM1.side,'R') ) = 2;

% compute average beta 
meanbeta  = [];
for i = 1:size(pdbM1,1)
    ff = pdbM1.ff{i};
    idxuse = ff >= 65 & ff <= 85; 
    meanbeta(i,1) = mean(pdbM1.fftOutNorm{i}(idxuse));
end

const = ones(size(meanbeta,1),1); 
X = [medstate, montage, side, const];
varnames ={'med state','montage','side','const'}; 
[betahat, alphahat, results] = gee(id, meanbeta, medstate, X, 'n', 'equi', varnames);




%% plot normalized data across patients 
dirname = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/in_clinic/rest_3rd_try';
fnmsave = fullfile(dirname,'patientPSD_in_clinic.mat');
load(fnmsave,'patientPSD_in_clinic');


pdb = patientPSD_in_clinic;
% plot 
hfig = figure;
hfig.Color = 'w'; 

% stn 
subplot(1,2,1);hold on; 
% med on 
idxkeep = (pdb.srate == 500) & ...
           strcmp(pdb.electrode,'STN 1-3') & ... 
           strcmp(pdb.medstate,'on');
psds = cell2mat(pdb.fftOutNorm(idxkeep));
ff = pdb.ff(idxkeep);
ff = ff{1}; 
% have issue with RCS02 - only recorded data at 250Hz. Need to include him
% seperatly. 
idxnorm = ff >=5 & ff <=90;
psds = psds(:,idxnorm); 
idxkeep = (pdb.srate == 250) & ...
           strcmp(pdb.electrode,'STN 1-3') & ... 
           strcmp(pdb.medstate,'on');
psds02 = cell2mat(pdb.fftOutNorm(idxkeep));
ff = pdb.ff(idxkeep);
ff = ff{1}; 
idxnorm = ff >=5 & ff <=90;
psds02 = psds02(:,idxnorm); 
psds = [psds;psds02];
ff = ff(idxnorm);


% plot(ff,psds,'LineWidth',1,'Color',[0 0.8 0 0.3]);
hsbH = shadedErrorBar(ff,psds,{@mean,@(x) std(x)*1});
hsbH.mainLine.Color = [0 0.8 0 0.5];
hsbH.mainLine.LineWidth = 3;
hsbH.patch.FaceAlpha = 0.1;
hLine(1) = hsbH.mainLine;

% med off 
idxkeep = (pdb.srate == 500) & ...
           strcmp(pdb.electrode,'STN 1-3') & ... 
           strcmp(pdb.medstate,'off');
psds = cell2mat(pdb.fftOutNorm(idxkeep));
ff = pdb.ff(idxkeep);
ff = ff{1}; 
% have issue with RCS02 - only recorded data at 250Hz. Need to include him
% seperatly. 
idxnorm = ff >=5 & ff <=90;
psds = psds(:,idxnorm); 
idxkeep = (pdb.srate == 250) & ...
           strcmp(pdb.electrode,'STN 1-3') & ... 
           strcmp(pdb.medstate,'off');
psds02 = cell2mat(pdb.fftOutNorm(idxkeep));
ff = pdb.ff(idxkeep);
ff = ff{1}; 
idxnorm = ff >=5 & ff <=90;
psds02 = psds02(:,idxnorm); 
psds = [psds;psds02];
ff = ff(idxnorm);


% plot(ff,psds,'LineWidth',1,'Color',[0.8 0 0 0.3]);
hsbH = shadedErrorBar(ff,psds,{@mean,@(x) std(x)*1});
hsbH.mainLine.Color = [0.8 0 0 0.5];
hsbH.mainLine.LineWidth = 3;
hsbH.patch.FaceAlpha = 0.1;
hLine(2) = hsbH.mainLine;

hold on;
set(gca,'XLim',[5 90])
xlabel('Frequency (Hz)');
ylabel('Power  (log_1_0\muV^2/Hz)');
title('STN 0-1','FontSize',16);
legend(hLine,{'defined on','defined off'});

% m1 
subplot(1,2,2);hold on; 
% med on 
idxkeep = (pdb.srate == 500) & ...
           strcmp(pdb.electrode,'M1 8-10') & ... 
           strcmp(pdb.medstate,'on');
psds = cell2mat(pdb.fftOutNorm(idxkeep));
ff = pdb.ff(idxkeep);
ff = ff{1}; 
% have issue with RCS02 - only recorded data at 250Hz. Need to include him
% seperatly. 
idxnorm = ff >=5 & ff <=90;
psds = psds(:,idxnorm); 
idxkeep = (pdb.srate == 250) & ...
           strcmp(pdb.electrode,'M1 8-10') & ... 
           strcmp(pdb.medstate,'on');
psds02 = cell2mat(pdb.fftOutNorm(idxkeep));
ff = pdb.ff(idxkeep);
ff = ff{1}; 
idxnorm = ff >=5 & ff <=90;
psds02 = psds02(:,idxnorm); 
psds = [psds;psds02];
ff = ff(idxnorm);


% plot(ff,psds,'LineWidth',1,'Color',[0 0.8 0 0.3]);
hsbH = shadedErrorBar(ff,psds,{@mean,@(x) std(x)*1});
hsbH.mainLine.Color = [0 0.8 0 0.5];
hsbH.mainLine.LineWidth = 3;
hsbH.patch.FaceAlpha = 0.1;
hLine(1) = hsbH.mainLine;

% med off 
idxkeep = (pdb.srate == 500) & ...
           strcmp(pdb.electrode,'M1 8-10') & ... 
           strcmp(pdb.medstate,'off');
psds = cell2mat(pdb.fftOutNorm(idxkeep));
ff = pdb.ff(idxkeep);
ff = ff{1}; 
% have issue with RCS02 - only recorded data at 250Hz. Need to include him
% seperatly. 
idxnorm = ff >=5 & ff <=90;
psds = psds(:,idxnorm); 
idxkeep = (pdb.srate == 250) & ...
           strcmp(pdb.electrode,'M1 8-10') & ... 
           strcmp(pdb.medstate,'off');
psds02 = cell2mat(pdb.fftOutNorm(idxkeep));
ff = pdb.ff(idxkeep);
ff = ff{1}; 
idxnorm = ff >=5 & ff <=90;
psds02 = psds02(:,idxnorm); 
psds = [psds;psds02];
ff = ff(idxnorm);

% plot(ff,psds,'LineWidth',1,'Color',[0.8 0 0 0.3]);
hsbH = shadedErrorBar(ff,psds,{@mean,@(x) std(x)*1});
hsbH.mainLine.Color = [0.8 0 0 0.5];
hsbH.mainLine.LineWidth = 3;
hsbH.patch.FaceAlpha = 0.1;
hLine(2) = hsbH.mainLine;

legend(hLine,{'defined on','defined off'});

hold on;
set(gca,'XLim',[5 90])
xlabel('Frequency (Hz)');
ylabel('Power  (log_1_0\muV^2/Hz)');
title('M1 8-10','FontSize',16);
sgtitle('Defined on/off in clinic (8 STNs, 4 patients)','FontSize',25);
params.figname = 'on_off_meds_all_patients_average_in_clinic';
params.plotwidth = 15;
params.plotheight = 10;
params.figdir  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/figures';

plot_hfig(hfig,params)

%%

%% plot at home data 
load('/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/at_home/patientPSD_at_home.mat');
hfig = figure;
hfig.Color = 'w'; 
pdb = patientPSD_at_home;

% stn 
subplot(1,2,1);hold on; 
set(gca,'XLim',[5 90])
% med on 
idxkeep = (pdb.srate == 250) & ...
           strcmp(pdb.electrode,'STN 1-3') & ... 
           strcmp(pdb.medstate,'on');
psds = cell2mat(pdb.fftOutNorm(idxkeep));
ff = pdb.ff(idxkeep);
ff = ff{1}; 
% plot(ff,psds,'LineWidth',1,'Color',[0 0.8 0 0.3]);
hsbH = shadedErrorBar(ff,psds,{@mean,@(x) std(x)*1});
hsbH.mainLine.Color = [0 0.8 0 0.5];
hsbH.mainLine.LineWidth = 3;
hsbH.patch.FaceAlpha = 0.1;
hLine(1) = hsbH.mainLine;

% med off 
idxkeep = (pdb.srate == 250) & ...
           strcmp(pdb.electrode,'STN 1-3') & ... 
           strcmp(pdb.medstate,'off');
psds = cell2mat(pdb.fftOutNorm(idxkeep));
ff = pdb.ff(idxkeep);
ff = ff{1}; 
% plot(ff,psds,'LineWidth',1,'Color',[0.8 0 0 0.3]);

hsbH = shadedErrorBar(ff,psds,{@mean,@(x) std(x)*1});
hsbH.mainLine.Color = [0.8 0 0 0.5];
hsbH.mainLine.LineWidth = 3;
hsbH.patch.FaceAlpha = 0.1;
hLine(2) = hsbH.mainLine;

hold on;
xlabel('Frequency (Hz)');
ylabel('Power  (log_1_0\muV^2/Hz)');
title('STN 0-1','FontSize',16);
legend(hLine,{'PKG estimate - on','PKG estimate - off'});

% m1 
subplot(1,2,2);hold on; 
% med on 
idxkeep = (pdb.srate == 250) & ...
           strcmp(pdb.electrode,'M1 8-10') & ... 
           strcmp(pdb.medstate,'on');
psds = cell2mat(pdb.fftOutNorm(idxkeep));
ff = pdb.ff(idxkeep);
ff = ff{1}; 
% plot(ff,psds,'LineWidth',1,'Color',[0 0.8 0 0.3]);

hsbH = shadedErrorBar(ff,psds,{@mean,@(x) std(x)*1});
hsbH.mainLine.Color = [0 0.8 0 0.5];
hsbH.mainLine.LineWidth = 3;
hsbH.patch.FaceAlpha = 0.1;
hLine(1) = hsbH.mainLine;
% med off 
idxkeep = (pdb.srate == 250) & ...
           strcmp(pdb.electrode,'M1 8-10') & ... 
           strcmp(pdb.medstate,'off');
psds = cell2mat(pdb.fftOutNorm(idxkeep));
ff = pdb.ff(idxkeep);
ff = ff{1}; 
% plot(ff,psds,'LineWidth',1,'Color',[0.8 0 0 0.3]);
hsbH = shadedErrorBar(ff,psds,{@mean,@(x) std(x)*1});
hsbH.mainLine.Color = [0.8 0 0 0.5];
hsbH.mainLine.LineWidth = 3;
hsbH.patch.FaceAlpha = 0.1;
hLine(2) = hsbH.mainLine;
legend(hLine,{'PKG estimate - on','PKG estimate - off'});
hold on;
set(gca,'XLim',[5 90])
xlabel('Frequency (Hz)');
ylabel('Power  (log_1_0\muV^2/Hz)');
title('M1 8-10','FontSize',16);
params.figname = 'on_off_meds_all_patients_average_at_home';
params.plotwidth = 15;
params.plotheight = 10;
sgtitle('PKG defined on/off at home  (8 STNs, 4 patients)','FontSize',25);
plot_hfig(hfig,params)

%% 

return

%% plot only select sub channels (this is what we keep
% create figure;
plotthis = 0;
if plotthis
    hfig = figure;
    cnt = 1;
    for p = 1:length(patients)
        for c = 1:2
            hsub(p,c) = subplot(length(patients),2,cnt);
            hold on;
            cnt = cnt + 1;
        end
    end
    for p = 1:length(patients)
        for t = 1:length(types)
            idxUse = (cellfun(@(x) any(strfind(x,patients{p})),ff) & ...
                cellfun(@(x) any(strfind(x,types{t})),ff) ) ;
            idxLoad = find(idxUse ==1);
            load(ff{idxLoad});
            outdatcomplete = outdatachunk;
            times = outdatcomplete.derivedTimes;
            srate = unique( outdatcomplete.samplerate );
            for c = 1:2
                cuse = cnsUsePerPatient(p,c);
                fnm = sprintf('key%d',cuse-1);
                y = outdatcomplete.(fnm);
                y = y - mean(y);
                [fftOut,f]   = pwelch(y,srate,srate/2,0:1:srate/2,srate,'psd');
                
                hplt(p,t,c) = plot(hsub(p,c),f,log10(fftOut),'LineWidth',4,'Color',colorsUse(t,:));
                
                
                xlim(hsub(p,c),[0 120]);
                xlabel(hsub(p,c),'Frequency (Hz)');
                ylabel(hsub(p,c),'Power  (log_1_0\muV^2/Hz)');
                ttluse = sprintf('%s %s',patients{p},ttls{cuse});
                title(hsub(p,c),ttluse,'FontSize',16);
            end
        end
    end
    for p = 1:length(patients)
        for c = 1:2
            legend(hsub(p,c),typeLeg);
        end
    end
    params.figname = 'on_off_meds_select_channels';
    hfig.Color = 'w';
    plot_hfig(hfig,params)
end
betaFreqs = [15 20 29 16];

%% PAC PAC PAC plot only select sub channels (this is what we keep
% create figure;
addpath(genpath(fullfile('..','..','PAC')));
close all;
pacparams.PhaseFreqVector      = 5:2:50;
pacparams.AmpFreqVector        = 10:5:200;

pacparams.PhaseFreq_BandWidth  = 4;
pacparams.AmpFreq_BandWidth    = 10;
pacparams.computeSurrogates    = 0;
pacparams.numsurrogate         = 0;
pacparams.alphause             = 0.05;
pacparams.plotdata             = 0;
pacparams.useparfor            = 0; % if true, user parfor, requires parallel computing toolbox
pacparams.regionnames          = {'STN','M1'};

hfig = figure;
cnt = 1;
for p = 1:length(patients)    
    for c = 1:2
        for t = 1:2
            hsub(p,t,c) = subplot(length(patients),4,cnt);
            hold on;
            cnt = cnt + 1;
            
        end
    end
end
for p = 1:length(patients)
    for t = 1:length(types)
        idxUse = (cellfun(@(x) any(strfind(x,patients{p})),ff) & ...
            cellfun(@(x) any(strfind(x,types{t})),ff) ) ;
        idxLoad = find(idxUse ==1);
        load(ff{idxLoad});
        outdatcomplete = outdatachunk;
        times = outdatcomplete.derivedTimes;
        srate = unique( outdatcomplete.samplerate );
        for c = 1:2
            cuse = cnsUsePerPatient(p,c);
            fnm = sprintf('key%d',cuse-1);
            y = outdatcomplete.(fnm);
            y = y - mean(y);
            if srate == 250 
                pacparams.AmpFreqVector        = 10:5:80;
            elseif srate == 1e3
                pacparams.AmpFreqVector        = 10:5:200;
            elseif srate == 500
                pacparams.AmpFreqVector        = 10:5:200;
            end
            results = computePAC(y',srate,pacparams);
            res = results(1);
            contourf(hsub(p,t,c),res.PhaseFreqVector+res.PhaseFreq_BandWidth/2,...
                res.AmpFreqVector+res.AmpFreq_BandWidth/2,...
                res.Comodulogram',30,'lines','none')
            shading interp
            ttly = sprintf('Amplitude Frequency %s (Hz)',ttls{cuse});
            ylabel(hsub(p,t,c),ttly)
            ttlx = sprintf('Phase Frequency %s (Hz)',ttls{cuse});
            xlabel(hsub(p,t,c),ttlx)
            ttluse = sprintf('%s %s %s',patients{p},typeLeg{t},ttls{cuse});
            title(hsub(p,t,c),ttluse);
            set(hsub(p,t,c),'FontSize',18);
            
        end
    end
end

params.figname = 'on_off_meds_PAC';
hfig.Color = 'w';
plot_hfig(hfig,params)
betaFreqs = [15 20 29 16];
end