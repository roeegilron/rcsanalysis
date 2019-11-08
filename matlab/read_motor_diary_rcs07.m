function read_motor_diary_rcs07(fn)
motodiaryRaw = readtable(fn);
timeInDay  = datetime(motodiaryRaw.studyTime,'Format','HH:mm');
timeInDay.Format = 'dd.MM.uuuu HH:mm';


dateUse  = datetime(motodiaryRaw.studyDate); 
dateUse.Format = 'dd.MM.uuuu HH:mm';

timeStart = dateUse + timeofday(timeInDay);
timeStart.TimeZone = 'America/Los_Angeles';
timeEnd   = timeStart + minutes(30); 

% put in new variable 
motorDiary = table(); 
motorDiary.timeStart = timeStart;
motorDiary.timeEnd = timeEnd;

% 0 = asleep  1 = awake 
motorDiary.asleep = motodiaryRaw.x0_asleep_1_awake;
% off vs on 0 = off 1 = on 
motorDiary.state = motodiaryRaw.x0_off_1_on;
% 1 = non trob dyskinesia 
motorDiary.dyskinesiaMild = motodiaryRaw.x1_non_troublesomeDyskinesia;
% 1 =  trob dyskinesia 
motorDiary.dyskinesiaSevere = motodiaryRaw.x1_troublesomeDyskinesia;
% 1 =  non trob tremor 
motorDiary.tremorMild = motodiaryRaw.x1_non_troublesomeTremor;
% 1 =   trob tremor 
motorDiary.x1_troublesomeTremor = motodiaryRaw.x1_troublesomeTremor;
% 1 =   med taken
motorDiary.meds = motodiaryRaw.medTaken;
idxkeep = ~isnat(motorDiary.timeEnd); 
motorDiary = motorDiary(idxkeep,:); 

% on time  
% total time 
asleep = motorDiary.asleep; 
asleep(isnan(asleep)) = 15; 
state = motorDiary.state; 
state(isnan(state)) = 15; 
ontime = sum ( (asleep == 1) & (state==1) );
offtime  = sum ( (asleep == 1) & (state==0) );
fprintf('%.2f time on (%.1f hours), %.2f off (%.1f hours)\n',...
    ontime/(ontime+offtime), ontime/2,...
    offtime/(ontime+offtime),offtime/2);
end