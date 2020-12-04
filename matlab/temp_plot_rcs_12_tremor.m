function temp_plot_rcs_12_tremor()
%% load data 

% delsys 
load('/Users/roee/Box/RC-S_Studies_Regulatory_and_Data/Patient In-Clinic Data/RCS12/10 Day/Delsys/RCS12_10_day_on_meds_walking_Plot_and_Store_Rep_1.1.mat')

% rcs 
dirname = '/Users/roee/Box/RC-S_Studies_Regulatory_and_Data/Patient In-Clinic Data/RCS12/10 Day/RCS_data/RCS12L/Session1604703616926/DeviceNPC700477H';
[timeDomainData,AccelData] = DEMO_ProcessRCS(dirname);
%%
figure; 
subplot(2,1,1); 
dt    =  datetime(timeDomainData.DerivedTime./1000,...
    'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
plot(seconds(dt-dt(1)),timeDomainData.key0)
title('rcs'); 

subplot(2,1,2); 
plot(Time(1,:),Data(11,:));
title('delsys'); 
%% 


figure; 
subplot(2,1,1); 
hold on; 
dtExcel    =  datetime(AccelData.DerivedTime./1000,...
    'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
dtSecsAcc = seconds(dtExcel - dtExcel(1)); 
plot(dtSecsAcc,AccelData.XSamples - mean(AccelData.XSamples));
plot(dtSecsAcc,AccelData.YSamples - mean(AccelData.YSamples));
plot(dtSecsAcc,AccelData.ZSamples - mean(AccelData.ZSamples));
title('rcs'); 

subplot(2,1,2); 
hold on; 
plot(Time(2,:),Data(2,:)-mean(Data(2,:)));
plot(Time(3,:),Data(3,:)-mean(Data(3,:)));
plot(Time(4,:),Data(4,:)-mean(Data(4,:)));
title('delsys'); 


end