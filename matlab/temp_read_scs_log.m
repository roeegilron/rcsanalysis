function temp_read_scs_log()
%% read data in 
fn = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/Box Sync/RCS01/RCS01-trace-reports/09012019/App-2019-01-08_21-21-51.log'; 
dat = importdata(fn); 
idxbattery = cellfun(@(x) any(strfind(x,'Check current INS battery level')),dat);
batDat = dat(idxbattery); 
cnt = 1; 
for f = 1:length(batDat)
    t = batDat{f};
    if ~isempty(str2num(t(end-3:end-1))) 
        tOut(cnt) = datetime(t(1:19),'Format','yyyy-MM-dd HH:mm:SS');
        per(cnt) = str2num(t(end-3:end-1)); 
        cnt = cnt+1; 
    end
end
%% plot 
figure; 
hplt = plot(tOut,per); 
hplt.LineWidth = 3; 
ylabel('Battery %'); 
xlabel('hours'); 
ylim([0 60]); 
datetick('x','HH:MM'); 
title('Battery level decline'); 

end