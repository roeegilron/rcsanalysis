function save_device_id_master_table()
%% code to generate device id / patient combos from existing database 

dirSave = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database';
clear masterTable;
masterTable = table();
cnt = 1; 
% rcs01
masterTable.deviceId{cnt}  =  lower('NPC700395H');
masterTable.patient{cnt}   = 'RCS01';
masterTable.side{cnt}      = 'L';
masterTable.area{cnt}      = 'STN'; 
masterTable.diagnosis{cnt} = 'PD'; 
cnt = cnt + 1;

% rcs02
masterTable.deviceId{cnt}  =  lower('NPC700398H');
masterTable.patient{cnt}   = 'RCS02';
masterTable.side{cnt}      = 'L';
masterTable.area{cnt}      = 'STN'; 
masterTable.diagnosis{cnt} = 'PD'; 
cnt = cnt + 1;

masterTable.deviceId{cnt}  =  lower('NPC700404H');
masterTable.patient{cnt}   = 'RCS02';
masterTable.side{cnt}      = 'R';
masterTable.area{cnt}      = 'STN'; 
masterTable.diagnosis{cnt} = 'PD'; 
cnt = cnt + 1;

% rcs03
masterTable.deviceId{cnt}  =  lower('NPC700411H');
masterTable.patient{cnt}   = 'RCS03';
masterTable.side{cnt}      = 'L';
masterTable.area{cnt}      = 'GP'; 
masterTable.diagnosis{cnt} = 'PD'; 
cnt = cnt + 1;

masterTable.deviceId{cnt}  =  lower('NPC700447H');
masterTable.patient{cnt}   = 'RCS03';
masterTable.side{cnt}      = 'R';
masterTable.area{cnt}      = 'GP'; 
masterTable.diagnosis{cnt} = 'PD'; 
cnt = cnt + 1;

% rcs04
masterTable.deviceId{cnt}  =  lower('NPC700418H');
masterTable.patient{cnt}   = 'RCS04';
masterTable.side{cnt}      = 'L';
masterTable.area{cnt}      = 'STN'; 
masterTable.diagnosis{cnt} = 'dystonia'; 
cnt = cnt + 1;

masterTable.deviceId{cnt}  =  lower('NPC700412H');
masterTable.patient{cnt}   = 'RCS04';
masterTable.side{cnt}      = 'R';
masterTable.area{cnt}      = 'STN'; 
masterTable.diagnosis{cnt} = 'dystonia'; 
cnt = cnt + 1;
        
% rcs05
masterTable.deviceId{cnt}  =  lower('NPC700414H');
masterTable.patient{cnt}   = 'RCS05';
masterTable.side{cnt}      = 'L';
masterTable.area{cnt}      = 'STN'; 
masterTable.diagnosis{cnt} = 'PD'; 
cnt = cnt + 1;

masterTable.deviceId{cnt}  =  lower('NPC700415H');
masterTable.patient{cnt}   = 'RCS05';
masterTable.side{cnt}      = 'R';
masterTable.area{cnt}      = 'STN'; 
masterTable.diagnosis{cnt} = 'PD'; 
cnt = cnt + 1;
 
% rcs06
masterTable.deviceId{cnt}  =  lower('NPC700424H');
masterTable.patient{cnt}   = 'RCS06';
masterTable.side{cnt}      = 'L';
masterTable.area{cnt}      = 'STN'; 
masterTable.diagnosis{cnt} = 'PD'; 
cnt = cnt + 1;

masterTable.deviceId{cnt}  =  lower('NPC700425H');
masterTable.patient{cnt}   = 'RCS06';
masterTable.side{cnt}      = 'R';
masterTable.area{cnt}      = 'STN'; 
masterTable.diagnosis{cnt} = 'PD'; 
cnt = cnt + 1;

% rcs07
masterTable.deviceId{cnt}  =  lower('NPC700419H');
masterTable.patient{cnt}   = 'RCS07';
masterTable.side{cnt}      = 'L';
masterTable.area{cnt}      = 'STN'; 
masterTable.diagnosis{cnt} = 'PD'; 
cnt = cnt + 1;

masterTable.deviceId{cnt}  =  lower('NPC700403H');
masterTable.patient{cnt}   = 'RCS07';
masterTable.side{cnt}      = 'R';
masterTable.area{cnt}      = 'STN'; 
masterTable.diagnosis{cnt} = 'PD'; 
cnt = cnt + 1;

% rcs08
masterTable.deviceId{cnt}  =  lower('NPC700444H');
masterTable.patient{cnt}   = 'RCS08';
masterTable.side{cnt}      = 'L';
masterTable.area{cnt}      = 'STN'; 
masterTable.diagnosis{cnt} = 'PD'; 
cnt = cnt + 1;

masterTable.deviceId{cnt}  =  lower('NPC700421H');
masterTable.patient{cnt}   = 'RCS08';
masterTable.side{cnt}      = 'R';
masterTable.area{cnt}      = 'STN'; 
masterTable.diagnosis{cnt} = 'PD'; 
cnt = cnt + 1;

% rcs09
masterTable.deviceId{cnt}  =  lower('NPC700434H');
masterTable.patient{cnt}   = 'RCS09';
masterTable.side{cnt}      = 'L';
masterTable.area{cnt}      = 'GP'; 
masterTable.diagnosis{cnt} = 'PD'; 
cnt = cnt + 1;

masterTable.deviceId{cnt}  =  lower('NPC700449H');
masterTable.patient{cnt}   = 'RCS09';
masterTable.side{cnt}      = 'R';
masterTable.area{cnt}      = 'GP'; 
masterTable.diagnosis{cnt} = 'PD'; 
cnt = cnt + 1;

% rcs10
masterTable.deviceId{cnt}  =  lower('NPC700436H');
masterTable.patient{cnt}   = 'RCS10';
masterTable.side{cnt}      = 'L';
masterTable.area{cnt}      = 'GP'; 
masterTable.diagnosis{cnt} = 'PD'; 
cnt = cnt + 1;

masterTable.deviceId{cnt}  =  lower('NPC700430H');
masterTable.patient{cnt}   = 'RCS10';
masterTable.side{cnt}      = 'R';
masterTable.area{cnt}      = 'GP'; 
masterTable.diagnosis{cnt} = 'PD'; 
cnt = cnt + 1;
save(fullfile(dirSave, 'deviceIdMasterList.mat'),'masterTable'); 
writetable(masterTable,fullfile(dirSave,'deviceIdMasterList.csv'));
end