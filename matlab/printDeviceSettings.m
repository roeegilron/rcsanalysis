function printDeviceSettings(deviceSettingsFn)
[pn,fn,ext] = fileparts(deviceSettingsFn); 
load(deviceSettingsFn); 
for i = 1:length(outRec)
    fprintf('[%0.3d]\n',i)
    fprintf('%s\n',outRec(i).timeStart);
    fprintf('%s\n',outRec(i).timeEnd);
    tdDat = outRec(i).tdData; 
    for c = 1:4
        fprintf('\t%s\n',tdDat(c).chanFullStr)
    end
    fprintf('\n\n'); 
end


%% print to file 
fnm = fullfile(pn,[fn '.txt']);
fid = fopen(fnm,'w+'); 
for i = 1:length(outRec)
    fprintf(fid,'[%0.3d]\n',i);
    fprintf(fid,'%s\n',outRec(i).timeStart);
    fprintf(fid,'%s\n',outRec(i).timeEnd);
    tdDat = outRec(i).tdData; 
    for c = 1:4
        fprintf(fid,'\t%s\n',tdDat(c).chanFullStr)
    end
    fprintf(fid,'\n\n'); 
end
fclose(fid);
end