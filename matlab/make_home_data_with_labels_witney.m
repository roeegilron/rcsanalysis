function make_home_data_with_labels_witney()
clc
rootdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/pkg_data/figures/';

ff = findFilesBVQX(rootdir, 'pkg_states*pkg*.mat',struct('depth',1));
outdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/pkg_data/labels_witney';

for f = 1:length(ff)
    [pn,fn] = fileparts(ff{f}); 
    load(ff{f}); 
    
    fnsave = sprintf('%s.csv',fn);
    filout = fullfile(outdir,fnsave);
    labelsOut = table();
    labelsOut.timeStart = allDataPkgRcsAcc.timeStart';
    labelsOut.timeEnd = allDataPkgRcsAcc.timeEnd';
    labelsOut.NumberPSD = allDataPkgRcsAcc.NumberPSD';
    labelsOut.numberPkg2minDataPoints = allDataPkgRcsAcc.numberPkg2minDataPoints';
    labelsOut.states = allstates';
    writetable(labelsOut,filout);
    fprintf('%s\n',fnsave);
    unqstates = unique(allstates);
    for u = 1:length(unqstates)
        fprintf('%s\n',unqstates{u})
    end
    fprintf('\n\n');
end



end