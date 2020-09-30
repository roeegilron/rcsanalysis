function randy_chart_historesis_example()
%%
hfig = figure;
h = animatedline;
h.LineStyle = 'none';
h.MarkerSize = 5; 
h.Marker =  'o';
h.MarkerFaceColor = [0.5 0 0 ];

axis([0,4*pi,-1,1])

x = linspace(0,5*pi,1000);
y = sin(x);
start = 1; 
for k = 1:length(x)
    if k >  100
        start = start + 1; 
        clearpoints(h);
    else
        start = 1; 
    end
    addpoints(h,x(start:k),y(start:k));
    drawnow
end

%%
end