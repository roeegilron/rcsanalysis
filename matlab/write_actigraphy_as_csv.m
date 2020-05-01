function write_actigraphy_as_csv()
%%
rootdir = '/Volumes/RCS_DATA/adaptive_at_home_testing/RCS06';
ff = findFilesBVQX(rootdir,'RawDataAccel.mat');
outdir = fullfile(rootdir,'csvs');
mkdir(outdir); 
patient = 'RCS05';

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