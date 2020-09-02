function plot_raw_psd_10_minute_results()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% SET PARAMS
%%%% SET PARAMS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

timeBefore = datetime('2020-03-03');
timeAfer =   datetime('2020-03-14');
patient = 'RCS03';
side = 'L';
patient_psd_file_suffix = 'before_stim'; % the specific psd file trying to plot
% will have a suffix chosenn during the creation process
% made with function: 
% MAIN_create_subsets_of_home_data_for_analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% SET PARAMS
%%%% SET PARAMS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dropboxdir = findFilesBVQX('/Users','Starr Lab Dropbox',struct('dirs',1,'depth',2));
DROPBOX_PATH = dropboxdir;
rootfolder = findFilesBVQX(DROPBOX_PATH,'RC+S Patient Un-Synced Data',struct('dirs',1,'depth',1));
patdir = findFilesBVQX(rootfolder{1},[patient '*'],struct('dirs',1,'depth',1));
% find the home data folder (SCBS fodler
scbs_folder = findFilesBVQX(patdir{1},'SummitContinuousBilateralStreaming',struct('dirs',1,'depth',2));
% assumign you want the same settings for L and R side
pat_side_folders = findFilesBVQX(scbs_folder{1},[patient side],struct('dirs',1,'depth',1));
psd_results_file = findFilesBVQX(pat_side_folders{1},['*psd*' patient_psd_file_suffix '*.mat']);
coh_results_file = findFilesBVQX(pat_side_folders{1},['*coh*' patient_psd_file_suffix '*.mat']);
load(psd_results_file{1}); 
load(coh_results_file{1}); 

% 

%% plot the raw data

hfig = figure;
hfig.Color = 'w';
nrows = 2;
ncols = 4;
rawfnmsocherence = fieldnames(coherenceResultsTd);

rawfnmstd = fieldnames(fftResultsTd);
idxusetd = cellfun(@(x) any(strfind(x,'key')),rawfnmstd);


idxusefncoh = cellfun(@(x) any(strfind(x,'stn')),rawfnmsocherence);

if sum(idxusefncoh)==0
    idxusefncoh = cellfun(@(x) any(strfind(x,'gpi')),rawfnmsocherence);
end

fieldnamesloop = rawfnmsocherence(idxusefncoh | idxusetd);
if sum(idxusefncoh)==0 % gpi case
    error('need to fill this out for GPi');
else % stn case
    titlsUse = {'STN 0-2','STN 1-3','M1 8-10','M1 9-11','STN 0-2 m1 8-10','STN 0-2 m1 9-11','STN 1-3 m1 8-10','STN 1-3 m1 9-11'};
end

cntplt = 1;
for f = 1:length(fieldnamesloop)
    subplot(nrows,ncols,cntplt); cntplt = cntplt + 1;
    datplot = allDataPkgRcsAcc.(fieldnamesloop{f})';
    plot(datplot,'LineWidth',0.1,'Color',[0 0 0.5 0.1]);
    title(titlsUse{f});
    xlim([3,100]);
    xlabel('Frequency (Hz)');
    if f >=4
        ylabel('MS coherence');
    else
        ylabel('Power (log_1_0\muV^2/Hz)');
    end
end

lrgTitle{1} = sprintf('%s %s',patient,sides{sd});
lrgTitle{2} = sprintf('%s - %s',timeBefore,timeAfer);
sgtitle(lrgTitle,'FontSize',18);

figdirout = fullfile(rootdir,'figures');
mkdir(figdirout);
savefn = sprintf('%s%s_praw_rcs_dat_synced_with_pkg_10_min__%s',patient,sides{sd},lrgTitle{2});
savefnFig = [savefn '.fig'];
savefig(hfig,fullfile(figdirout,savefnFig));

prfig.plotwidth           = 13;
prfig.plotheight          = 8;
prfig.figdir              = figdirout;
prfig.figname            = savefn;
prfig.figtype             = '-djpeg';


plot_hfig(hfig,prfig);


end