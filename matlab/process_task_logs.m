function process_task_logs(dirname)
%%

ff = findFilesBVQX(dirname,'*.csv',struct('depth',1)); 

%%

for f = 1:length(ff)
    taskData = table();
    try
            taskDataRaw = readtable(ff{f});
            if max(taskDataRaw.Var1) < 500 % var 1 is not time, open differently
                t = datetime(taskDataRaw.Var2/1000,'ConvertFrom','posixTime',...
                    'TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
                tStart = datetime(t(1),'Format','uuuu-MM-dd HH_mm_ss');
                tEnd = datetime(t(end),'Format','uuuu-MM-dd HH_mm_ss');
                taskData.time = t;
                taskData.event = taskDataRaw.Var3;
                filenameUse = sprintf('task_file_name___%s___%s.mat',tStart,tEnd);
                fnsave = fullfile(dirname,filenameUse);
                save(fnsave,'taskData');
                clear t
            else
                taskDataRaw = readtable(ff{f});
                t = datetime(taskDataRaw.Var1/1000,'ConvertFrom','posixTime',...
                    'TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
                tStart = datetime(t(1),'Format','uuuu-MM-dd HH_mm_ss');
                tEnd = datetime(t(end),'Format','uuuu-MM-dd HH_mm_ss');
                taskData.time = t;
                taskData.event = taskDataRaw.Var2;
                filenameUse = sprintf('task_file_name___%s___%s.mat',tStart,tEnd);
                fnsave = fullfile(dirname,filenameUse);
                save(fnsave,'taskData');
                clear t
            end
    catch
        % it didn't work bcs of delimters - fix
        fid = fopen(ff{f});
        tline = fgetl(fid);
        [pn,fn,ext] = fileparts(ff{f});
        mkdir(fullfile(pn,'fixed_logs'));
        pn = fullfile(pn,'fixed_logs');
        % write meta data 
        if any(strfind(tline,'version'))
            fileNameMeta = fullfile(pn,[fn '_meta' ext]);
            fidMeta = fopen(fileNameMeta,'w+');
            fprintf(fidMeta,'%s\n',tline); 
            tline = fgetl(fid);
            fprintf(fidMeta,'%s\n',tline); 
        end
        fclose(fidMeta);
        % keep reading the actual file 
        fileNameFixed = fullfile(pn,[fn '_fixed' ext]);
        fidFixed = fopen(fileNameFixed,'w+');

        tline = fgetl(fid);
        trialCnt = 1; 
        while ischar(tline)
            if strcmp(tline(1:3),'159')
                fprintf(fidFixed,'Trial: %d,%s\n',0,tline)
            else
                fprintf(fidFixed,'%s\n',tline)
            end
            tline = fgetl(fid);
        end
        fclose(fidFixed);
        fclose(fid);
        % open the fixed files 
        metaData = readtable(fileNameMeta);
        taskDataRaw = readtable(fileNameFixed,'ReadVariableNames',0,'Delimiter',',');
        t = datetime(taskDataRaw.Var2/1000,'ConvertFrom','posixTime',...
            'TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
        tStart = datetime(t(1),'Format','uuuu-MM-dd HH_mm_ss');
        tEnd = datetime(t(end),'Format','uuuu-MM-dd HH_mm_ss');
        taskData.time = t;
        taskData.event = taskDataRaw.Var3;
        filenameUse = sprintf('task_file_name___%s___%s.mat',tStart,tEnd);
        fnsave = fullfile(dirname,filenameUse);
        save(fnsave,'taskData','metaData');
        clear t
    end
end

end