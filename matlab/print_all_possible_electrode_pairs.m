function print_all_possible_electrode_pairs()
clc;
stn = nchoosek(0:3,2); 
m1  = nchoosek(8:11,2); 
fprintf('\n'); 
fprintf('all possible stn pairs:\n'); 
for i = 1:size(stn,1); 
    fprintf('%d\t%d\t\n',stn(i,1),stn(i,2));
end
fprintf('\n'); 
fprintf('all possible M1 pairs:\n'); 
for i = 1:size(m1,1); 
    fprintf('%d\t%d\t\n',m1(i,1),m1(i,2));
end
fprintf('\n'); 


fprintf('all pairs between m1 and stn:\n'); 
for m = 1:size(m1,1)
    for s = 1:size(stn,1)
        fprintf('m1:\t%d\t%d\tstn\t%d\t%d\t\n',...
            m1(m,1),m1(m,2),...
            stn(s,1),stn(s,2));
    end
end

end