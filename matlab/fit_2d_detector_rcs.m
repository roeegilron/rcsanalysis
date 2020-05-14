%% fit detector 
clc;
x = linspace(200,800,100)';
y = linspace(2e3,1e3,100)';
det = fittype('b*w2 - (w1/w2)*x');
f = fit(x,y,det)
 