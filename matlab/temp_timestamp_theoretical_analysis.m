function temp_timestamp_theoretical_analysis()
close all; clear all; clc;
%% Introduciton: 

% The main unknown that this function is trying to solve is the value N
% e.g. the number of max_st (= 2^16*1e4) * N that is possible. 
% there are some ambiguous cases in which both values seem a-priori
% possible. 
% For example: 
% time stamp 1 (ts1) = 10 
% time stamp 2 (ts2) = 29 
% It should be possible to compute two values of N in this case, 

% case A: 
ts1 = 10; % time stamp 2, LSB - seconds 
ts2 = 29; % time stamp 2, LSB - seconds 
max_st = (2^16/1e4); % max system tick value in seconds 
N = 3;  % multiple of max_st 
% ignoring any possible system tick values: 
ts2_computed_value = ts1 + (N * max_st); 
fprintf('ts2 possible value: %.2f\n',ts2_computed_value)

% case B: 
ts1 = 10; % time stamp 2, LSB - seconds 
ts2 = 29; % time stamp 2, LSB - seconds 
max_st = (2^16/1e4); % max system tick value in seconds 
N = 2;  % multiple of max_st (note than in previous example N = 3). 
% ignoring any possible system tick values: 
ts2_computed_value = ts1 + (N * max_st); 
% now we can add any number of seconds smaller than max_st 
% to get to our value of ts2, for example: 
add_factor = 5.9; 
ts2_computed_value = ts2_computed_value + add_factor; 
fprintf('ts2 possible value: %.2f\n',ts2_computed_value)

% as above case illustrates, the value of N can be ambigous, 
% and this can results in incorrect estimation of large gaps in the data 
% and accumulation of erros, especially in large files. 
% the below code is trying to prove (empirically) 
% that it is not in fact possible to have two results, 
% and based on the constraints that system tick imposes, 
% it is possible to get a definitive answer on a case by case basis. 

%%

clc;

% time stamp1 and time stamp 2 in seconds 
% timestamp count number of seconds (LSB - seconds) 
% the numbers below are chosen since they allow ambgious factors of N 
% this example should be expandable to cover all possible cases 
% since the relative difference between time stamps values in ambigous cases is
% the main factor
ts1 = [9 10]; 
ts2 = 29; 
% system tick 1 and 2 
% system tick is is a rollover counter with 100microsec LSB 

%bound the problem - vector version 
max_st = (2^16/1e4); % max system tick value in seconds 
st_vec = 1:1:2^16';  % create a vector of all possible system tick raw values 
st_vec = st_vec';    % transpose vector for easier vectorization 

% compute possilbe system tick values in which a conflict arises 
systemTick1_values = []; 
ts1out = [];

% this assumes either minimim or maximum time difference in time stamp
% values. each case will be discussed in turn. 

% A. The least significant bit (LSB) of time stamp is 1 second. 
% B. As such, we don't know if the true value of time stamp is 1 second
%    or 1.9999 seconds.
% C. The max possible difference in time stamp are cases in which: 
%       1. time stamp 1 (ts1) is equal to 9.00001 & (for example) 
%       2. time stamp 2 (ts2) is equal to 29.9999 (for example). 
% D. The min possible difference in time stamp are cases in which: 
%       1. time stamp 1 (ts1) is equal to 10.999999 & 
%       2. time stamp 2 (ts2) is equal to 29.00001 (for example). 
% D. We then take all possible values of system tick 1 (st1) 
%    and see if the difference between ts2 and ts1 (ts2-ts1) 
%    is smaller than max_st, and larger than zero 
% E. Though we don't know the exact value of ts1, we can at least 
%    bound the problem and see what values of st1 are possible 
%    assuming the max possible difference between ts2 and ts1 

%% best possible alogirhtm would be to side step the proble entirely 
%% just keep tossing data until this isn't a problem anymore. 
%% so find the next place in the data in which you have a second 
%% roleover event - and then you know the number N of seconds that has rolled over. 


single_tick_in_sec = 1/1e4; % single system tick in seconds 
poss_system_tick_vec_in_sec = (st_vec ./ (2^16/1e4));
start = tic; 

ts_pairs_out = [];
for i = 1:2 % loop on possible values of timestamp 
    ts1_poss_values = ts1(i) : single_tick_in_sec : ((ts1(i)+1)-single_tick_in_sec);
    ts2_poss_values = ts2 : single_tick_in_sec : ((ts2+1)-single_tick_in_sec);
    
    minN = floor( (ts2 - (ts1(i)+1)) / max_st );
    maxN = floor( ((ts2+1) - ts1(i)) / max_st);

    
    % get all possible pairs between ts1 and ts2 vectors 
    [A,B] = meshgrid(ts1_poss_values,ts2_poss_values);
    c = cat(2,A',B');
    ts_pairs = reshape(c,[],2);
    
    % bounding the problem: 
    % for each pair: 
    % 1. ts1 + maxN * max_st should be smaller than ts2 
    % 2  ts1 + minN * max_st should be smaller than ts2 
    
    idx_max = (ts_pairs(:,1) + (maxN * max_st) ) <= ts_pairs(:,2);
    idx_min = (ts_pairs(:,1) + (minN * max_st) ) <= ts_pairs(:,2);
    both_poss = idx_min & idx_max;
    
    % difference between ts2 - (ts1 + N * max_st) should be smaller than
    % max_st; 
    ts_pairs = ts_pairs(both_poss,:); 
    idx_max = (ts_pairs(:,2)  - (ts_pairs(:,1) + (maxN * max_st))) <= max_st;
    idx_min = (ts_pairs(:,2)  - (ts_pairs(:,1) + (minN * max_st))) <= max_st;
    both_poss = idx_min & idx_max;
    
    ts_pairs_both = ts_pairs(both_poss,:); 
    
    ts_pairs_out = [ts_pairs_out; ts_pairs_both];
    
    
end

% plot possible pair combinations: 
figure;
subplot(2,1,1); 
plot(ts_pairs_out(:,1),ts_pairs_out(:,2)); 
subplot(2,1,2); 
diffsMax = ts_pairs_out(:,2)- (ts_pairs_out(:,1) + maxN*max_st);
diffsMin = ts_pairs_out(:,2)- (ts_pairs_out(:,1) + minN*max_st);
secs_diff = 

histogram(diffs_in_secs);


% loop on all possible pair combinations (abmigous) 
% and see if you can find a system tick combination 
% that will work for both cases 
vec_secs = (1:2^16)./1e4;
sys_tic1 = 1:2^16; 
sys_tic1 = sys_tic1'; 
min_n_sec = minN .* max_st;
max_n_sec = maxN .* max_st;

cntmin = 1; 
cntmax = 1;
cnt = 1; 

sys_tick_difference = []; % difference (delta) between system tick values 
for t = 1:size(ts_pairs_out,1) 
    ts1_use = ts_pairs_out(t,1); 
    ts2_use = ts_pairs_out(t,2); 
    % there are problems with floating point numbers in matlab 
    % in essence, incrementation isn't happening as expected 
    % so have to do this clunky check to see if difference 
    % is smaller 1/1e4 (one system tick). 
    

    idxtick_min = abs( ts2_use - (ts1_use +  sys_tic1./1e4 + min_n_sec) ) <= 1/1e4;
    idxtick_max = abs( ts2_use - (ts1_use +  sys_tic1./1e4 + max_n_sec) ) <= 1/1e4;

    sys_tick_difference(cnt,1) = ts1_use;
    sys_tick_difference(cnt,2) = ts2_use;
    
    min_poss = sum(idxtick_min == 1) >= 1;
    if min_poss
        idx_min_choose = sys_tic1( idxtick_min ); 
        idx_min_choose = idx_min_choose(1); 
    end
    max_poss = sum(idxtick_max == 1) >= 1;
    if max_poss
        idx_max_choose = sys_tic1( idxtick_max );
        idx_max_choose = idx_max_choose(1);
    end

    if min_poss & max_poss
        both_poss_difference(cnt,1) = ts1_use;
        both_poss_difference(cnt,2) = ts2_use;
        both_poss_difference(cnt,3) = idx_min_choose;
        both_poss_difference(cnt,4) = idx_max_choose; 
        cnt = cnt + 1;
    end
    
     if min_poss & ~ max_poss
         min_poss_difference(cntmin,1) = ts1_use;
         min_poss_difference(cntmin,2) = ts2_use;
         min_poss_difference(cntmin,3) = idx_min_choose;
         cntmin = cntmin + 1;
     end
    
     if ~min_poss & max_poss
         max_poss_difference(cntmax,1) = ts1_use;
         max_poss_difference(cntmax,2) = ts2_use;
         max_poss_difference(cntmax,3) = idx_max_choose;
         cntmax = cntmax + 1;
     end
end

time_to_finish = toc(start); 
fprintf('done 0.01 percent in %s secs\n',toc(start));



fid = fopen('results_time_stamp_analysis.txt','w+'); 
cnt = 1; 
for tt = 1:length(ts1) 
    for s1 = 1:2^16
        for s2 = 1:2^16
            ts1use = ts1(tt); 
            st1use = s1; 
            st2use = s2; 
            [N_out,both_options_possible,both_options_impossible] =  checkTimeStamps(ts1use,ts2,st1use,st2use); 
            fprintf(fid,'%.2f\t, %d\t, %d\t, %d\t, %d\t, %d\t,%d\t \n',...
                N_out,both_options_possible,both_options_impossible,...
                ts1use,ts2,st1use,st2use); 
        end
    end
end
fclose(fid);




end

function [N_out,both_options_possible,both_options_impossible] =  checkTimeStamps(ts1,ts2,st1,st2)


max_st = (2^16/1e4); 

% is the number of 6.553 seconds blocks possibley ambiguous? (n * 6.553)
minN = (ts2 - (ts1+1)) / max_st; 
maxN = ((ts2+1) - ts1) / max_st; 
% is minN or MaxN both possible (e.g. ambigous) given current system tick? 

% check min: 
minTimeDifference = ts2 - ( ts1 +  (st1 / (2^16/1e4)) + (floor(minN) * max_st) ); 
maxTimeDifference = (ts2+1) - (ts1 +  (st1 / (2^16/1e4)) + (floor(maxN) * max_st) ); 


if minN ~= maxN % if the number of potential 6 second blocks is ambgious 
%     fprintf('\tmin N %.2f\n\tmax N %.2f\n',minN,maxN);
%     fprintf('\tmin time difference %.2f\n\tmax time difference %.2f\n',minTimeDifference,maxTimeDifference);
    
    if logical(minTimeDifference <= max_st) && logical(minTimeDifference >= 0)
        minpossible = 1; 
    else
        minpossible = 0; 
    end
    if logical(maxTimeDifference <= max_st) && logical(maxTimeDifference >= 0)
        maxpossible = 1; 
    else
        maxpossible = 0; 
    end
    if maxpossible == 0 && minpossible == 0 
        both_options_impossible = 1; 
    else
        both_options_impossible = 0;
    end
        
    if minpossible == 1 && maxpossible == 1 % check to see which one is true based on systemtick2
        % check min:
        poss_min = ts1 +  (st1 / (2^16/1e4)) + (floor(minN) * max_st) + st2/(2^16/1e4);
        % check max:
        poss_max = ts1 +  (st1 / (2^16/1e4)) + (floor(maxN) * max_st) + st2/(2^16/1e4);
%         fprintf('\t poss min - %.2f\n',poss_min);
%         fprintf('\t poss max - %.2f\n',poss_max);
        if floor(poss_min) == ts2
            N_out = minN;
        elseif floor(poss_max) == ts2
            N_out = maxN;
        else
            % this means this combination of system tick
            % and time stamp is not possible 
            N_out = NaN;
        end
        
        if (floor(poss_min) == ts2 ) & (floor(poss_max) == ts2 )
            both_options_possible = 1;
        else
            both_options_possible = 0;
        end
    else
        both_options_possible = 0;
        if minpossible 
            N_out = minN; 
        else
            N_out = maxN; 
        end 
    end
else
    N_out = minN; 
end



end