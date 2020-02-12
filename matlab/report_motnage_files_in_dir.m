function report_motnage_files_in_dir(dirname)


ff = findFilesBVQX(dirname,'rawMontageData.mat');
txtfn = fullfile(dirname,'folders_with_motnage.txt');
fid = fopen(txtfn,'w+'); 

tableToSave = table(); 
for f = 1:length(ff) % loop ib montage files
    fprintf(fid, '[%0.2d]\t\n',f); 
    % use a function called fileparts
    [pn,fn] = fileparts(ff{f});
    tempdirname = pn; 
    fprintf(fid, '\t\t\t%s\n',tempdirname); 
    evenfn = fullfile(pn,'EventLog.json');
    eventTable  = loadEventLog(evenfn); 
    idxdiscard = cellfun(@(x) any(strfind(lower(x),'leadloc')),eventTable.EventType) | ...
        cellfun(@(x) any(strfind(lower(x),'montage')),eventTable.EventType) | ...
         cellfun(@(x) any(strfind(lower(x),'battery')),eventTable.EventType) ;
     fprintf(fid, '\t TIME: %s\n',eventTable.sessionTime(1)); 
     eventToReport = eventTable(~idxdiscard,:); 
     for e = 1:size(eventToReport,1)
         fprintf(fid,'\t%s \t%s\n',eventToReport.EventType{e}, eventToReport.EventSubType{e});
     end
     fprintf(fid,'\n\n');
     montageNum = repmat(f,size(eventToReport,1),1);
     currTable = table();
     currTable.montageNumber = montageNum;
     currTable = [currTable, eventToReport(:,{'sessionid','sessionTime','EventSubType','EventType'})]; 
     
     tableToSave = [tableToSave; currTable];
     
end
% close the text file: 
fclose(fid); 
tablesvname = fullfile(dirname,'montageTable.mat'); 
save(tablesvname,'tableToSave'); 
end
