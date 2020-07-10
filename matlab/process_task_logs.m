function process_task_logs(dirname)
%%

ff = findFilesBVQX(dirname,'*.csv'); 
%%

for f = 1:length(ff)
    taskData = table();
    taskDataRaw = readtable(ff{f}); 
    x = 2;
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

end