function create_pseudo_random_stim_tiration()
clc;
%% 

minamp = 0; 
inclectionpoint = 0.9;
maxamp = 1.4; 
inc1    = 0.3; 
inc2    = 0.2;

series = [minamp:inc1:inclectionpoint  inclectionpoint+inc2:inc2: maxamp]; 
if series(end) ~= maxamp
    series = [series maxamp];
end

% create 5e3 random sequences and compute the absolute difference 
for i = 1:5e3
    rng(i);
    meanseries(i) = mean(abs(diff(series(randperm(length(series))))));
end
[maxdiffm idx] = max(meanseries);

rng(idx); 
seriesuse = series(randperm(length(series)));
mean(abs(diff(seriesuse)));
fprintf('%0.2f\n',seriesuse);
    
end