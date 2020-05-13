function plot_tbl_stats(fid,sense_stim_table)
%% print report about data set

fprintf(fid, 'sensing and stimulation settings report of database size and settings\n\n\n'); 

fprintf(fid, 'information in brackets contains amount of data in that condition in the format:\n'); 
fprintf(fid, '[HH:MM:SS]\n\n\n'); 

fprintf(fid, '%%%%%%%%\n'); 
fprintf(fid, '%%%%%%%%\n'); 
fprintf(fid, '%%%%%%%%\n'); 
fprintf(fid, '%%%%%%%%\n\n'); 
fprintf(fid, 'OFF STIM\n\n'); 
fprintf(fid, '%%%%%%%%\n\n'); 

% sense settings: 
idxkeep = ~sense_stim_table.stimulation_on;
tbluse = sense_stim_table(idxkeep,:); 
fprintf(fid, '[%s] hours of data OFF stim\n\n', sum(tbluse.duration)); 
fprintf(fid,'\tunique settings per channel:\n'); 
fprintf(fid,'\t *note that hour count/ channel can contain partial overlaps across channels\n\n')
for c = 1:4 
    
    fprintf(fid,'\tchan %d:\n',c); 
    cfn = sprintf('chan%d',c); 
    unqsettings = unique(sense_stim_table.(cfn)); 
    for u = 1:length(unqsettings)
        idxchan = strcmp(tbluse.(cfn), unqsettings{u}); 
        fprintf(fid,'\t\t[%s]\t%s\n',sum(tbluse.duration(idxchan)),unqsettings{u});
        
    end
end 


fprintf(fid, '%%%%%%%%\n'); 
fprintf(fid, '%%%%%%%%\n'); 
fprintf(fid, '%%%%%%%%\n'); 
fprintf(fid, '%%%%%%%%\n\n'); 
fprintf(fid, 'ON STIM\n\n'); 
fprintf(fid, '%%%%%%%%\n\n'); 

% sense settings: 
idxkeep = logical(sense_stim_table.stimulation_on);
tbluse = sense_stim_table(idxkeep,:); 
fprintf(fid, '[%s] hours of data ON stim\n\n', sum(tbluse.duration)); 
fprintf(fid,'\tunique settings per channel:\n'); 
fprintf(fid,'\t *note that hour count/ channel can contain partial overlaps across channels\n\n')
for c = 1:4 
    
    fprintf(fid,'\tchan %d:\n',c); 
    cfn = sprintf('chan%d',c); 
    unqsettings = unique(sense_stim_table.(cfn)); 
    for u = 1:length(unqsettings)
        idxchan = strcmp(tbluse.(cfn), unqsettings{u}); 
        fprintf(fid,'\t\t[%s]\t%s\n',sum(tbluse.duration(idxchan)),unqsettings{u});
        
    end
end 

% stim settings 
fprintf(fid, '%%%%%%%%\n');
fprintf(fid, '%%%%%%%%\n');
fprintf(fid,'\nSTIM SETTINGS:\n');
fprintf(fid, '%%%%%%%%\n\n'); 
stim_electrodes = unique(tbluse.electrodes);
for e = 1:length(stim_electrodes)
   idxelec = strcmp(tbluse.electrodes, stim_electrodes{e}); 
   fprintf(fid,'[%s] %s\n',sum(tbluse.duration(idxelec)), stim_electrodes{e});
   unqCurrents = unique(tbluse.amplitude_mA(idxelec)); 
   for uc = 1:length(unqCurrents)
       idxcur = tbluse.amplitude_mA == unqCurrents(uc);
       idxcur_use = idxelec & idxcur;
       fprintf(fid,'\t\t [%s] %.2f mA\n',sum(tbluse.duration(idxcur_use)),unqCurrents(uc));
   end
end


fclose(fid);

end