function save_device_id_master_table()
%% code to generate device id / patient combos from existing database 
dirSave = '/Users/roee/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database';
clear masterTable;
masterTable = table();
cnt = 1; 

% pain ins 1 
masterTable.deviceId{cnt}  =  lower('NPC700355H');
masterTable.patient{cnt}   = 'benchtop';
masterTable.side{cnt}      = '1';
masterTable.area{cnt}      = 'pain'; 
masterTable.diagnosis{cnt} = 'i cant feel my body'; 
masterTable.implntDate(cnt)= datetime('30-Jul-0000','TimeZone','America/Los_Angeles');
masterTable.progDate(cnt) = datetime('01-Apr-2020','TimeZone','America/Los_Angeles');
cnt = cnt + 1;

% pain ins 2
masterTable.deviceId{cnt}  =  lower('NPC700353H');
masterTable.patient{cnt}   = 'benchtop';
masterTable.side{cnt}      = '2';
masterTable.area{cnt}      = 'pain'; 
masterTable.diagnosis{cnt} = 'i cant feel my body'; 
masterTable.implntDate(cnt)= datetime('30-Jul-0000','TimeZone','America/Los_Angeles');
masterTable.progDate(cnt) = datetime('01-Apr-2020','TimeZone','America/Los_Angeles');
cnt = cnt + 1;

% uknown INS 3
masterTable.deviceId{cnt}  =  lower('NPC700239H');
masterTable.patient{cnt}   = 'benchtop';
masterTable.side{cnt}      = '3';
masterTable.area{cnt}      = 'unknown'; 
masterTable.diagnosis{cnt} = 'unknown'; 
masterTable.implntDate(cnt)= datetime('30-Jul-0000','TimeZone','America/Los_Angeles');
masterTable.progDate(cnt) = datetime('01-Apr-2020','TimeZone','America/Los_Angeles');
cnt = cnt + 1;

%UCSF ins 1
masterTable.deviceId{cnt}  =  lower('NPC700354H');
masterTable.patient{cnt}   = 'benchtop';
masterTable.side{cnt}      = '1';
masterTable.area{cnt}      = 'starr PD'; 
masterTable.diagnosis{cnt} = 'first in the world!'; 
masterTable.implntDate(cnt)= datetime('30-Jul-0000','TimeZone','America/Los_Angeles');
masterTable.progDate(cnt) = datetime('01-Apr-2020','TimeZone','America/Los_Angeles');
cnt = cnt + 1;

% UCSF ins 2
masterTable.deviceId{cnt}  =  lower('NPC700378H');
masterTable.patient{cnt}   = 'benchtop';
masterTable.side{cnt}      = '2';
masterTable.area{cnt}      = 'starr PD'; 
masterTable.diagnosis{cnt} = 'second in the world!'; 
masterTable.implntDate(cnt)= datetime('30-Jul-0000','TimeZone','America/Los_Angeles');
masterTable.progDate(cnt) = datetime('01-Apr-2020','TimeZone','America/Los_Angeles');
cnt = cnt + 1;

% rcs01
masterTable.deviceId{cnt}  =  lower('NPC700395H');
masterTable.patient{cnt}   = 'RCS01';
masterTable.side{cnt}      = 'L';
masterTable.area{cnt}      = 'STN'; 
masterTable.diagnosis{cnt} = 'PD'; 
masterTable.implntDate(cnt)= datetime('12-Oct-2018','TimeZone','America/Los_Angeles');
masterTable.progDate(cnt) = datetime('09-Nov-2019','TimeZone','America/Los_Angeles');
cnt = cnt + 1;

% rcs02
masterTable.deviceId{cnt}  =  lower('NPC700398H');
masterTable.patient{cnt}   = 'RCS02';
masterTable.side{cnt}      = 'L';
masterTable.area{cnt}      = 'STN'; 
masterTable.diagnosis{cnt} = 'PD'; 
masterTable.implntDate(cnt)= datetime('07-May-2019','TimeZone','America/Los_Angeles');
masterTable.progDate(cnt) = datetime('04-Jun-2019','TimeZone','America/Los_Angeles');
cnt = cnt + 1;masterTable.deviceId{cnt}  =  lower('NPC700404H');
masterTable.patient{cnt}   = 'RCS02';
masterTable.side{cnt}      = 'R';
masterTable.area{cnt}      = 'STN'; 
masterTable.diagnosis{cnt} = 'PD'; 
masterTable.implntDate(cnt)= datetime('07-May-2019','TimeZone','America/Los_Angeles');
masterTable.progDate(cnt) = datetime('04-Jun-2019','TimeZone','America/Los_Angeles');
cnt = cnt + 1;

% rcs03
masterTable.deviceId{cnt}  =  lower('NPC700411H');
masterTable.patient{cnt}   = 'RCS03';
masterTable.side{cnt}      = 'L';
masterTable.area{cnt}      = 'GP'; 
masterTable.diagnosis{cnt} = 'PD'; 
masterTable.implntDate(cnt)= datetime('14-Jan-2020','TimeZone','America/Los_Angeles');
masterTable.progDate(cnt) = datetime('10-Jul-2019','TimeZone','America/Los_Angeles');
cnt = cnt + 1;masterTable.deviceId{cnt}  =  lower('NPC700447H');
masterTable.patient{cnt}   = 'RCS03';
masterTable.side{cnt}      = 'R';
masterTable.area{cnt}      = 'GP'; 
masterTable.diagnosis{cnt} = 'PD'; 
masterTable.implntDate(cnt)= datetime('11-Jun-2019','TimeZone','America/Los_Angeles');
masterTable.progDate(cnt) = datetime('13-Feb-2020','TimeZone','America/Los_Angeles');
cnt = cnt + 1;

% rcs04
masterTable.deviceId{cnt}  =  lower('NPC700418H');
masterTable.patient{cnt}   = 'RCS04';
masterTable.side{cnt}      = 'L';
masterTable.area{cnt}      = 'STN'; 
masterTable.diagnosis{cnt} = 'dystonia'; 
masterTable.implntDate(cnt)= datetime('02-Jul-2019','TimeZone','America/Los_Angeles');
masterTable.progDate(cnt) = datetime('30-Jul-2019','TimeZone','America/Los_Angeles');
cnt = cnt + 1;masterTable.deviceId{cnt}  =  lower('NPC700412H');
masterTable.patient{cnt}   = 'RCS04';
masterTable.side{cnt}      = 'R';
masterTable.area{cnt}      = 'STN'; 
masterTable.diagnosis{cnt} = 'dystonia'; 
masterTable.implntDate(cnt)= datetime('02-Jul-2019','TimeZone','America/Los_Angeles');
masterTable.progDate(cnt) = datetime('30-Jul-2019','TimeZone','America/Los_Angeles');
cnt = cnt + 1;

% rcs05
masterTable.deviceId{cnt}  =  lower('NPC700414H');
masterTable.patient{cnt}   = 'RCS05';
masterTable.side{cnt}      = 'L';
masterTable.area{cnt}      = 'STN'; 
masterTable.diagnosis{cnt} = 'PD'; 
masterTable.implntDate(cnt)= datetime('16-Jul-2019','TimeZone','America/Los_Angeles');
masterTable.progDate(cnt) = datetime('15-Aug-2019','TimeZone','America/Los_Angeles');
cnt = cnt + 1;masterTable.deviceId{cnt}  =  lower('NPC700415H');
masterTable.patient{cnt}   = 'RCS05';
masterTable.side{cnt}      = 'R';
masterTable.area{cnt}      = 'STN'; 
masterTable.diagnosis{cnt} = 'PD'; 
masterTable.implntDate(cnt)= datetime('16-Jul-2019','TimeZone','America/Los_Angeles');
masterTable.progDate(cnt) = datetime('15-Aug-2019','TimeZone','America/Los_Angeles');
cnt = cnt + 1;

% rcs06
masterTable.deviceId{cnt}  =  lower('NPC700424H');
masterTable.patient{cnt}   = 'RCS06';
masterTable.side{cnt}      = 'L';
masterTable.area{cnt}      = 'STN'; 
masterTable.diagnosis{cnt} = 'PD'; 
masterTable.implntDate(cnt)= datetime('10-Oct-2019','TimeZone','America/Los_Angeles');
masterTable.progDate(cnt) = datetime('05-Nov-2019','TimeZone','America/Los_Angeles');
cnt = cnt + 1;masterTable.deviceId{cnt}  =  lower('NPC700425H');
masterTable.patient{cnt}   = 'RCS06';
masterTable.side{cnt}      = 'R';
masterTable.area{cnt}      = 'STN'; 
masterTable.diagnosis{cnt} = 'PD'; 
masterTable.implntDate(cnt)= datetime('10-Oct-2019','TimeZone','America/Los_Angeles');
masterTable.progDate(cnt) = datetime('05-Nov-2019','TimeZone','America/Los_Angeles');
cnt = cnt + 1;

% rcs07
masterTable.deviceId{cnt}  =  lower('NPC700419H');
masterTable.patient{cnt}   = 'RCS07';
masterTable.side{cnt}      = 'L';
masterTable.area{cnt}      = 'STN'; 
masterTable.diagnosis{cnt} = 'PD'; 
masterTable.implntDate(cnt)= datetime('09-Sep-2019','TimeZone','America/Los_Angeles');
masterTable.progDate(cnt) = datetime('18-Oct-2019','TimeZone','America/Los_Angeles');
cnt = cnt + 1;masterTable.deviceId{cnt}  =  lower('NPC700403H');
masterTable.patient{cnt}   = 'RCS07';
masterTable.side{cnt}      = 'R';
masterTable.area{cnt}      = 'STN'; 
masterTable.diagnosis{cnt} = 'PD'; 
masterTable.implntDate(cnt)= datetime('09-Sep-2019','TimeZone','America/Los_Angeles');
masterTable.progDate(cnt) = datetime('18-Oct-2019','TimeZone','America/Los_Angeles');
cnt = cnt + 1;

% rcs08
masterTable.deviceId{cnt}  =  lower('NPC700444H');
masterTable.patient{cnt}   = 'RCS08';
masterTable.side{cnt}      = 'L';
masterTable.area{cnt}      = 'STN'; 
masterTable.diagnosis{cnt} = 'PD'; 
masterTable.implntDate(cnt)= datetime('28-Jan-2020','TimeZone','America/Los_Angeles');
masterTable.progDate(cnt) = datetime('24-Mar-2020','TimeZone','America/Los_Angeles');
cnt = cnt + 1;masterTable.deviceId{cnt}  =  lower('NPC700421H');
masterTable.patient{cnt}   = 'RCS08';
masterTable.side{cnt}      = 'R';
masterTable.area{cnt}      = 'STN'; 
masterTable.diagnosis{cnt} = 'PD'; 
masterTable.implntDate(cnt)= datetime('28-Jan-2020','TimeZone','America/Los_Angeles');
masterTable.progDate(cnt) = datetime('24-Mar-2020','TimeZone','America/Los_Angeles');
cnt = cnt + 1;

% rcs09
masterTable.deviceId{cnt}  =  lower('NPC700434H');
masterTable.patient{cnt}   = 'RCS09';
masterTable.side{cnt}      = 'L';
masterTable.area{cnt}      = 'GP'; 
masterTable.diagnosis{cnt} = 'PD'; 
masterTable.implntDate(cnt)= datetime('01-Apr-2020','TimeZone','America/Los_Angeles');
masterTable.progDate(cnt) = datetime('04-May-2020','TimeZone','America/Los_Angeles');
cnt = cnt + 1;masterTable.deviceId{cnt}  =  lower('NPC700449H');
masterTable.patient{cnt}   = 'RCS09';
masterTable.side{cnt}      = 'R';
masterTable.area{cnt}      = 'GP'; 
masterTable.diagnosis{cnt} = 'PD'; 
masterTable.implntDate(cnt)= datetime('01-Apr-2020','TimeZone','America/Los_Angeles');
masterTable.progDate(cnt) = datetime('04-May-2020','TimeZone','America/Los_Angeles');
cnt = cnt + 1;

% rcs10
masterTable.deviceId{cnt}  =  lower('NPC700436H');
masterTable.patient{cnt}   = 'RCS10';
masterTable.side{cnt}      = 'L';
masterTable.area{cnt}      = 'GP'; 
masterTable.diagnosis{cnt} = 'PD'; 
masterTable.implntDate(cnt)= datetime('28-May-2020','TimeZone','America/Los_Angeles');
masterTable.progDate(cnt) = datetime('26-Jun-2020','TimeZone','America/Los_Angeles');
cnt = cnt + 1;masterTable.deviceId{cnt}  =  lower('NPC700430H');
masterTable.patient{cnt}   = 'RCS10';
masterTable.side{cnt}      = 'R';
masterTable.area{cnt}      = 'GP'; 
masterTable.diagnosis{cnt} = 'PD'; 
masterTable.implntDate(cnt)= datetime('28-May-2020','TimeZone','America/Los_Angeles');
masterTable.progDate(cnt) = datetime('26-Jun-2020','TimeZone','America/Los_Angeles');
cnt = cnt + 1;

% rcs11
%
masterTable.deviceId{cnt}  =  lower('NPC700472H');
masterTable.patient{cnt}   = 'RCS11';
masterTable.side{cnt}      = 'L';
masterTable.area{cnt}      = 'STN'; 
masterTable.diagnosis{cnt} = 'PD'; 
masterTable.implntDate(cnt)= datetime('01-Oct-2020','TimeZone','America/Los_Angeles');
masterTable.progDate(cnt) = datetime('17-Nov-2020','TimeZone','America/Los_Angeles');
cnt = cnt + 1;masterTable.deviceId{cnt}  =  lower('NPC700473H');
masterTable.patient{cnt}   = 'RCS11';
masterTable.side{cnt}      = 'R';
masterTable.area{cnt}      = 'STN'; 
masterTable.diagnosis{cnt} = 'PD'; 
masterTable.implntDate(cnt)= datetime('01-Oct-2020','TimeZone','America/Los_Angeles');
masterTable.progDate(cnt) = datetime('17-Nov-2020','TimeZone','America/Los_Angeles');
cnt = cnt + 1;

% rcs12
%
masterTable.deviceId{cnt}  =  lower('NPC700477H');
masterTable.patient{cnt}   = 'RCS12';
masterTable.side{cnt}      = 'L';
masterTable.area{cnt}      = 'STN'; 
masterTable.diagnosis{cnt} = 'PD'; 
masterTable.implntDate(cnt)= datetime('27-Oct-2020','TimeZone','America/Los_Angeles');
masterTable.progDate(cnt) = datetime('16-Dec-2020','TimeZone','America/Los_Angeles');
cnt = cnt + 1;masterTable.deviceId{cnt}  =  lower('NPC700476H');
masterTable.patient{cnt}   = 'RCS12';
masterTable.side{cnt}      = 'R';
masterTable.area{cnt}      = 'STN'; 
masterTable.diagnosis{cnt} = 'PD'; 
masterTable.implntDate(cnt)= datetime('27-Oct-2020','TimeZone','America/Los_Angeles');
masterTable.progDate(cnt) = datetime('16-Dec-2020','TimeZone','America/Los_Angeles');
cnt = cnt + 1;

% rcs13
%
cnt = cnt + 1;masterTable.deviceId{cnt}  =  lower('DeviceNPC700474H');
masterTable.patient{cnt}   = 'RCS13';
masterTable.side{cnt}      = 'R';
masterTable.area{cnt}      = 'STN'; 
masterTable.diagnosis{cnt} = 'dystonia'; 
masterTable.implntDate(cnt)= datetime('23-Dec-2020','TimeZone','America/Los_Angeles');
masterTable.progDate(cnt) = datetime('15-Jan-2021','TimeZone','America/Los_Angeles');
cnt = cnt + 1;

% rcs14
%
cnt = cnt + 1;masterTable.deviceId{cnt}  =  lower('DeviceNPC700481H');
masterTable.patient{cnt}   = 'RCS14';
masterTable.side{cnt}      = 'L';
masterTable.area{cnt}      = 'GP';
masterTable.diagnosis{cnt} = 'PD';
masterTable.implntDate(cnt)= datetime('23-March-2020','TimeZone','America/Los_Angeles');
masterTable.progDate(cnt) = datetime('27-April-2021','TimeZone','America/Los_Angeles');
cnt = cnt + 1;



% save 
save(fullfile(dirSave, 'deviceIdMasterList.mat'),'masterTable'); 
writetable(masterTable,fullfile(dirSave,'deviceIdMasterList.csv'));


end