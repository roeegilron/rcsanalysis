function outidx =  allignSoundFromJsonAndEEG(eegtime,ipadtime)
outidx = [];
hfig = figure('Position',[1000         924        1126         414]);
pb = uicontrol(hfig,'Style','pushbutton','String','Compute',...
                'Position',[50 100 60 40],'Callback',@printdiffs);
            
            
pb = uicontrol(hfig,'Style','pushbutton','String','Done',...
                'Position',[50 20 60 40],'Callback',@donecomp);

ttls = {'eeg markers','json markers'}; 
datanames = {'eegtime','ipadtime'};
for a = 1:length(datanames)
    hsub = subplot(2,1,a);
    hold on;
    dat = eval(datanames{a});
    for s = 1:length(dat)
        handles.(datanames{a})(s) = ...
            scatter(dat(s),0,...
            300,'r',...
            'UserData',1,...
            'ButtonDownFcn',@ScatterPressed,...
            'UserData',0);
        if s~= length(dat)
            struse = sprintf(' . %0.2f',dat(s+1)-dat(s));
            text(dat(s),0,struse,'FontSize',10);
        end
    end
    title(ttls{a});
end
hfig.UserData = handles; 
uiwait(hfig); 
outidx = hfig.UserData;
close(hfig);
end

function ScatterPressed(obj,event)
if ~obj.UserData
    obj.MarkerFaceColor = 'b';
    obj.UserData = 1;
elseif obj.UserData
    obj.MarkerFaceColor = 'none';
    obj.UserData = 0;
end
end

function printdiffs(obj,event)
hfig = obj.Parent;
handles = hfig.UserData;
if sum([handles.eegtime.UserData]) ==2 & sum([handles.ipadtime.UserData]) == 2
    ipdtims = [handles.ipadtime.XData];
    eegtims = [handles.eegtime.XData];
    idxuse_eeg = find([handles.eegtime.UserData] ==1 );
    idxuse_ipd = find([handles.ipadtime.UserData] ==1 );
    newipd = ipdtims(idxuse_ipd(1):idxuse_ipd(2));
    neweeg = eegtims(idxuse_eeg(1):idxuse_eeg(2));
    if length(newipd) == length(neweeg)
    for i = 1:length(newipd)-1
        fprintf('ipad %0.2f eeg %0.2f\n',newipd(i+1) - newipd(i),neweeg(i+1) - neweeg(i))
    end
    fprintf('avg diff = %0.2f\n',mean(abs(diff(newipd)-diff(neweeg))));
    end
else
    fprintf('select only 2 locations in each plot');
end
end

function donecomp(obj,event)
hfig = obj.Parent;
handles = hfig.UserData;
if sum([handles.eegtime.UserData]) ==2 & sum([handles.ipadtime.UserData]) == 2
    ipdtims = [handles.ipadtime.XData];
    eegtims = [handles.eegtime.XData];
    idxuse_eeg = find([handles.eegtime.UserData] ==1 );
    idxuse_ipd = find([handles.ipadtime.UserData] ==1 );
    outidx.ipad = idxuse_ipd(1):idxuse_ipd(2);
    outidx.eeg =  idxuse_eeg(1):idxuse_eeg(2);
    hfig.UserData = outidx; 
end
uiresume(hfig);
end

 