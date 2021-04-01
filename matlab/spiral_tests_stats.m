%% read csv 
% get all csv and write out times: 
rootdir = '/Users/roee/Box/RC-S_Studies_Regulatory_and_Data/Patient In-Clinic Data/RCS02/OL vs CL Finger Taps Videos/Spiral task Data';
ff = findFilesBVQX(rootdir,'*.csv');

fid = fopen(fullfile(rootdir,'spiral_data_stats.csv'),'w+'); 
for f = 1:length(ff)
    spiralData = readtable(ff{f}); 
    [pn,fn] = fileparts(ff{f}); 
    time = spiralData.t_received(end) - spiralData.t_received(1); 
    fprintf(fid, '%s\t%.2f\t\n',fn,time); 
end
fclose(fid); 
return 
%%
back = '/Users/roee/Box/RC-S_Studies_Regulatory_and_Data/Patient In-Clinic Data/RCS02/OL vs CL Finger Taps Videos/Spiral task Data/RCS02_2021_01_16_06_08AM_L_Background.png';
spiral = '/Users/roee/Box/RC-S_Studies_Regulatory_and_Data/Patient In-Clinic Data/RCS02/OL vs CL Finger Taps Videos/Spiral task Data/RCS02_2021_01_16_06_08AM_L_Image.png'; 

img1 = imread(back);
img2 = imread(spiral); 

figure; 
subplot(1,1,1); 
image(img1); 
hold on; 
plot(spiralData.location_previous_precise_x_in_view,spiralData.location_previous_precise_y_in_view);



%% 