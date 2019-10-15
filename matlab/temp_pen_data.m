function temp_pen_data();

%% load data 
dat = readmatrix('/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS_test/pen_task/DataPoints.txt'); 
%%
figure;
idxZero  = find(dat(:,1) == 0 & dat(:,2)==0);
idxStart = [1; idxZero(1:2:end)+10];
idxEnd = [idxZero(1:2:end)-10 ;size(dat,1)];
diffPlot = []; 
for i = 1:length(idxStart)
    diffPlot = [diffPlot ; diff(dat(idxStart(i):idxEnd(i),3))];
end

%%
figure;
histogram(diffPlot,'BinWidth',1,'Normalization','probability');

%%
close all;
for i = 1:length(idxStart)
    figure;histogram(diff(dat(idxStart(i):idxEnd(i),3)),'BinWidth',1,'Normalization','probability')
end

