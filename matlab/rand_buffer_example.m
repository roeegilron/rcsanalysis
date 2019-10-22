function randy_buffer_example()
clc;
buffersize = 3000; % in ms 
intersampl = [2500 3100 3300];
datapoints = 10; 
steps      = 10; 
% create data
rng(1);
points = [];
points = datasample(intersampl,1);
for d = 1:datapoints-1
    rng(d);
    points = [points; (points(end) +  datasample(intersampl,1))];
end
newpoints = points;
for i = 1:steps
    
    newpoint = datasample(intersampl,1); 
    fprintf('old points\t new points\t\n');
    
   
    fprintf('step %d\n',i);
    oldpoints = newpoints;
    newpoints = [oldpoints(2:end); (oldpoints(end) + oldpoints)];
    for d = 1:datapoints-1
        fprintf('%d\t %d\t\n',oldpoints(d)-oldpoints(1),newpoints(d)-newpoints(1));
    end
    fprintf('\n\n');
end
end