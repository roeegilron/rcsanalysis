function read_motor_diary(fn)
motorDiary = readtable(fn);
state = motorDiary.state; 
asleep = motorDiary.asleep; 
ontime = sum ( (asleep == 0) & (state==1) );
offtime  = sum ( (asleep == 0) & (state==0) );

fprintf('%.2f time on (%.1f hours), %.2f off (%.1f hours)\n',...
    ontime/(ontime+offtime), ontime/2,...
    offtime/(ontime+offtime),offtime/2);
[pn,fn] = fileparts(fn); 
fnsave = fullfile(pn,'motorDiary.mat'); 
save(fnsave,'motorDiary'); 
end