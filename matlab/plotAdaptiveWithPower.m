function plotAdaptiveWithPower()
%% load data 
diruse = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS_test/adaptive_example/3_6_19/Session1551920127934/DeviceNPC700239H/';
diruse = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS_test/adaptive_scs_test/VerificationData/Session1553285473069_showsSCSWhenAdaptiveIsOnButInGroupA/DeviceNPC700239H';
diruse = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v18_adaptive_month5/all_rcs_data/Session1553549911973/DeviceNPC700395H';
fnAdaptive = fullfile(diruse,'AdaptiveLog.json'); 
[outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerTable] =  MAIN_load_rcs_data_from_folder(diruse);
res = readAdaptiveJson(fnAdaptive); 

%% plot adaptive 
cntplt = 1;
figure;
hold on; 
uxtimes = datetime(powerTable.timestamp/1000,...
    'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
uxtimes = powerTable.timestamp - powerTable.timestamp(1); 
% plot power 
hplt = plot(uxtimes(5:end),powerTable.Band1(5:end)); 
huse(cntplt) = hplt; cntplt = cntplt + 1; 
hplt.Color = [0 0 0.8 0.7];
hplt.LineWidth = 4; 

% plot adaptive 

% uxtimes = datetime([res.timing.timestamp]/1000,...
%     'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');

uxtimes = res.timing.timestamp - res.timing.timestamp(1); 
adaptive = res.adaptive; 
fnmsPlot = {'LD0_highThreshold','LD0_lowThreshold'};
nrows = length(fnmsPlot); 
for f = 1:length(fnmsPlot)
    hplt = plot(uxtimes(5:end),adaptive.(fnmsPlot{f})(5:end));
    huse(cntplt) = hplt; cntplt = cntplt + 1; 
    for h = 1:length(hplt)
        hplt(h).LineWidth = 3;
%         hplt(h).Color = [0 0 0.8 0.7];
    end
%     ttluse = strrep(fnmsPlot{f},'_',' ');
%     title(ttluse); 
end
ylabel('power (a.u.)'); 
fnmsPlot = {'CurrentAdaptiveState','CurrentProgramAmplitudesInMilliamps','LD0_output','Ld0DetectionStatus'};
nrows = length(fnmsPlot); 
for f = 1:length(fnmsPlot)
    yyaxis('right');
    if strcmp(fnmsPlot{f},'Ld0DetectionStatus')
        y = adaptive.(fnmsPlot{f})./100;
    else
        y = adaptive.(fnmsPlot{f});
    end
    if size(y,1) == 4
        y = y(1,:);
    end
    hplt = plot(uxtimes,y);
    huse(cntplt) = hplt; cntplt = cntplt + 1;
    for h = 1:length(hplt)
        hplt(h).LineWidth = 3;
%         hplt(h).Color = [0 0 0.8 0.7];
    end
%     ttluse = strrep(fnmsPlot{f},'_',' ');
%     title(ttluse); 
end
set(gca,'YLim',[0 3]);
ylabel('current amp / adaptive state'); 
title('test run aDBS with PicoScope input'); 
title('Streaming while adaptive Is On But In GroupA');
%% plot legend
legend(huse,{'Power','LD0 highThreshold','LD0 lowThreshold',...
    'CurrentAdaptiveState','CurrentProgramAmplitudesInMilliamps','LD0 output','Ld0DetectionStatus'});
set(gca,'FontSize',16);

% current adaptive algorithm 
adapCut = adaptive.CurrentProgramAmplitudesInMilliamps(1,:);
idxuse = adapCut >=2 & adapCut <=3 ;
figure;plot(adapCut(idxuse))
mean(adapCut(idxuse))

end
