function plotFreqPatches(hax)
handles.freqranges = [1 4; 4 8; 8 13; 13 20; 20 30; 30 50; 50 90];
handles.freqnames  = {'Delta', 'Theta', 'Alpha','LowBeta','HighBeta','LowGamma','HighGamma'}';
cuse = parula(size(handles.freqranges,1));
ydat = [10 10 -10 -10];
handles.axesclr = hax;
for p = 1:size(handles.freqranges,1)
    freq = handles.freqranges(p,:);
    xdat = [freq(1) freq(2) freq(2) freq(1)];
    handles.hPatches(p) = patch('XData',xdat,'YData',ydat,'YLimInclude','off');
    handles.hPatches(p).Parent = hax;
    handles.hPatches(p).FaceColor = cuse(p,:);
    handles.hPatches(p).FaceAlpha = 0.3;
    handles.hPatches(p).EdgeColor = 'none';
    handles.hPatches(p).Visible = 'on';
end

end
