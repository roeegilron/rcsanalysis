function write_blank_motor_diary()
rootdir = '/Volumes/RCS_DATA 1/RCS06/v10_3_week_before_stimon/data_dump/motor_diaries_raw';
diaryName = 'rcs06_diary_blank.csv'; 
motorDiary = table();
FirsttimeStart  = datetime('10/11/2019 06:00','Format','MM/dd/uuuu HH:mm');
LasttimeStart   = datetime('10/14/2019 05:30','Format','MM/dd/uuuu HH:mm');
timeStart = NaT;
timeEnd = NaT; 
curtime = FirsttimeStart; 
cnt = 1; 
while LasttimeStart >= curtime
    timeStart(cnt,1) = curtime; 
    timeEnd(cnt,1)   = timeStart(cnt) + minutes(30); 
    curtime = timeEnd(cnt); 
    cnt = cnt+1; 
end
motorDiary.timeStart = timeStart;
motorDiary.timeEnd = timeEnd;

% 1 = asleep  0 = awake 
motorDiary.asleep = zeros(size(motorDiary.timeStart,1),1);
% off/on 0 = off 1 = on 
motorDiary.state = zeros(size(motorDiary.timeStart,1),1);
% 1 = non trob dyskinesia 
motorDiary.dyskinesiaMild = zeros(size(motorDiary.timeStart,1),1);
% 1 =  trob dyskinesia 
motorDiary.dyskinesiaSevere = zeros(size(motorDiary.timeStart,1),1);
% 1 =  non trob tremor 
motorDiary.tremorMild = zeros(size(motorDiary.timeStart,1),1);
% 1 =   trob tremor 
motorDiary.tremorSevere = zeros(size(motorDiary.timeStart,1),1);

writetable(motorDiary,fullfile(rootdir,diaryName));
end