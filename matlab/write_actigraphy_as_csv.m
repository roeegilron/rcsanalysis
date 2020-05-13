function write_actigraphy_as_csv()
%%
% open all data 
rootdir = '/Volumes/RCS_DATA/adaptive_at_home_testing/';
patients = findFilesBVQX(rootdir,'RCS*',struct('dirs',1,'depth',1));

for p = 1:length(patients)
    patsides = findFilesBVQX(patients{p},'RCS*',struct('dirs',1,'depth',1));
    for pp = 1:length(patsides)
        diropen = patsides{pp}; 
        MAIN_report_data_in_folder(diropen); 
        MAIN_load_rcsdata_from_folders(diropen);
    end
end
ff = findFilesBVQX(rootdir,'RawDataAccel.mat');
outdir = fullfile(rootdir,'csvs');
mkdir(outdir); 

for f = 1:length(ff)
    load(ff{f});
    x = 2;
    [pn,fn] = fileparts(ff{f});
    [pn,fn] = fileparts(pn);
    [pn,fn] = fileparts(pn);
    [pn,patient_and_side] = fileparts(pn);
    allTimes = outdatcomplete.derivedTimes;
    allTimes.Format = 'dd-MMM-yyyy__HH-mm';
    filenameuse = sprintf('%s___%s----%s_acc.csv',patient_and_side,allTimes(1),allTimes(end));
    fnwriteout = fullfile(outdir,filenameuse);
    writetable(outdatcomplete,fnwriteout);
end
%%
end