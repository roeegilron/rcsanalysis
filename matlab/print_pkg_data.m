function print_pkg_data()
dirname = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/pkg_data';
ff = findFilesBVQX(dirname,'PKG*.pdf',struct('depth',1));
pkgTable = table(); 
for f = 1:length(ff)
    [pn,fn,ext] = fileparts(ff{f}); 
    dateraw = regexp( fn, '(?<=_)\d+(?=_)', 'match' ); 
    datetime(dateraw{1},'Format','yyyyMMdd');
    t = datetime(dateraw{1},'Format','yyyyMMdd');
    t.Format = 'yyyy-MMM-dd';
    pkgTable.time(f) = t;
    patient = regexp( fn, '(?<=_)\D+(?=_)', 'match' ); 
    pkgTable.patient{f} = patient{1}(4:end);
    pkgTable.filename{f} = fn;
end

findstr = '091944';
pkgTable
pkgTable(cellfun(@(x) any(strfind(x,findstr)),pkgTable.filename),:)
end