function make_rest_data_witney()

rootdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/results/in_clinic/rest_share_witney'; 
ff = findFilesBVQX(rootdir,'*.mat'); 
fid = fopen(fullfile(rootdir,'electrodes.txt'),'w+');
for f = 1:length(ff)
    [pn,fn] = fileparts(ff{f}); 
    load(ff{f}); 
    fnsave = sprintf('%s.csv',fn);  
    filenameuse = fullfile(rootdir,fnsave);
    writetable(outdatachunk,filenameuse);
    fprintf(fid,'%s\n',fn); 
    for c = 1:4
        fprintf(fid,'%s\n',outRec.tdData(c).chanFullStr);
    end
    fprintf(fid,'\n\n');
end
fclose(fid);
end