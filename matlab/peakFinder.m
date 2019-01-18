function varargout = peakFinder(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @peakFinder_OpeningFcn, ...
                   'gui_OutputFcn',  @peakFinder_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end


% --- Executes just before peakFinder is made visible.
function peakFinder_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
set(hObject,'toolbar','figure');
set(hObject,'WindowButtonUpFcn',@MouseUp);
set(hObject,'WindowButtonMotionFcn',@MouseMove);
guidata(hObject, handles);
handles.dat = varargin{1};
% plot selection 
handles.figure1 = gcf; 
guidata(hObject, handles);
handles.output = [];

%% XXX 
updatePlot();
% UIWAIT makes peakFinder wait for user response (see UIRESUME)
uiwait(handles.figure1);

function updatePlot()
handles = guidata(gcf);
%% setup 
if ~isfield(handles,'chanstr')
    fnms = fieldnames(handles.dat);
    idxs = ~cellfun(@(x) strcmp(x,'srate'),fnms);
    fnmsuse = fnms(idxs);
    handles.chanstr = fnmsuse;
end
if isempty(handles.hChanSelect.String) % populate possible channels / set deafults 
    handles.hChanSelect.String = handles.chanstr;
    % det default value 
    idxss = cellfun(@(x) strcmp(x,'Erg1'),handles.chanstr);
    if sum(idxss) ~=0
        handles.hChanSelect.Value = find(idxss==1);
    end
end
handles.hMethodUse.String = {'peaks','bounds'};
handles.hMethodUse.Value  = 1; 
handles.hMethodUse.Max    = 1; 
chanameplot = handles.chanstr{handles.hChanSelect.Value};
handles.datPlot =  handles.dat.(chanameplot);
handles.srate   = handles.dat.srate;
% flip signal 
multipby = 1;
if isfield(handles,'flipSignal')
    if handles.flipSignal 
        multipby = -1; 
        handles.flipSignal = 0;
    else
        multipby = 1; 
    end
end
% only positive 
if isfield(handles,'onlyPositive')
    if handles.onlyPositive
        handles.datPlot = abs(handles.datPlot);
        handles.onlyPositive = 0;
    end
end

rawDat = handles.datPlot.*(multipby); 
datPlot = double(rawDat-mean(rawDat)); 
secs    = ([0:length(datPlot)-1])./handles.srate;
cla(handles.hAxes);
%% band pass
if isfield(handles,'bpprressed')
    if handles.bpprressed
        bp = designfilt('bandpassiir',...
            'FilterOrder',4, ...
            'HalfPowerFrequency1',str2num(handles.hBPlow.String{1}),...
            'HalfPowerFrequency2',str2num(handles.hBPhigh.String{1}), ...
            'SampleRate',handles.srate);
        datPlot = filtfilt(bp,datPlot);
        handles.bpprressed = 0;
    end
end
% plot data 
axes(handles.hAxes);
plot(secs,datPlot,'LineWidth',1,'Color',[0 0 0.9 0.6]);
handles.datPlot = datPlot;
handles.secs = secs; 
hold on;
ylabel('Voltage');
xlabel('Seconds');

% plot thresh line upper
if ~isfield(handles,'hThreshLine')
    ylims = handles.hAxes.YLim;
    xlims = handles.hAxes.XLim;
    handles.ythresh = mean(ylims);
    handles.hThreshLine = plot(handles.hAxes,xlims,[handles.ythresh handles.ythresh],...
        'LineWidth',2,...
        'Color', [0.9 0 0 0.7],...
        'ButtonDownFcn', @MouseDown,...
        'UserData','thresh');
else
    xlims = handles.hAxes.XLim;
    handles.hThreshLine = plot(handles.hAxes,handles.hAxes.XLim,[handles.ythresh handles.ythresh],...
        'LineWidth',2,...
        'Color', [0.9 0 0 0.7],...
        'ButtonDownFcn', @MouseDown,...
        'UserData','thresh');
end

% plot thresh line lower
if ~isfield(handles,'hThreshLineLower')
    ylims = handles.hAxes.YLim;
    xlims = handles.hAxes.XLim;
    handles.ythreshLower = ylims(1) * 1.2;
    handles.hThreshLineLower = plot(handles.hAxes,xlims,[handles.ythreshLower handles.ythreshLower],...
        'LineWidth',2,...
        'Color', [0 0.9 0 0.7],...
        'ButtonDownFcn', @MouseDown,...
        'UserData','threshlower');
else
    xlims = handles.hAxes.XLim;
    handles.hThreshLineLower = plot(handles.hAxes,handles.hAxes.XLim,[handles.ythreshLower handles.ythreshLower],...
        'LineWidth',2,...
        'Color', [0 0.9 0 0.7],...
        'ButtonDownFcn', @MouseDown,...
        'UserData','threshlower');
end
    
% plot start line 
if ~isfield(handles,'hStartLine')
    ylims = handles.hAxes.YLim;
    xlims = handles.hAxes.XLim;
    handles.xstart = xlims(1) + 10;
    handles.hStartLine = plot(handles.hAxes,[handles.xstart handles.xstart],ylims,...
        'LineWidth',2,...
        'Color', [0.9 0 0 0.7],...
        'ButtonDownFcn', @MouseDown,...
        'UserData','start');
else
    ylims = handles.hAxes.YLim;
    handles.hStartLine = plot(handles.hAxes,[handles.xstart handles.xstart],ylims,...
        'LineWidth',2,...
        'Color', [0.9 0 0 0.7],...
        'ButtonDownFcn', @MouseDown,...
        'UserData','start');
end
% plot end line 
if ~isfield(handles,'hEndLine')
    ylims = handles.hAxes.YLim;
    xlims = handles.hAxes.XLim;
    handles.xend = xlims(2) - 10;
    handles.hEndLine = plot(handles.hAxes,[handles.xend handles.xend],ylims,...
        'LineWidth',2,...
        'Color', [0.9 0 0 0.7],...
        'ButtonDownFcn', @MouseDown,...
        'UserData','end');
else
    ylims = handles.hAxes.YLim;
    handles.hEndLine = plot(handles.hAxes,[handles.xend handles.xend],ylims,...
        'LineWidth',2,...
        'Color', [0.9 0 0 0.7],...
        'ButtonDownFcn', @MouseDown,...
        'UserData','end');
end
% zoom y 
% zoom out 
% 
    
%% wrap up 
guidata(gcf,handles);

function MouseMove(gcbo,event,handles)
handles = guidata(gcf);
if isfield(handles,'StartMouseDown')
    if handles.StartMouseDown
        cp = get ( handles.hAxes, 'CurrentPoint' );
        set ( handles.hStartLine, 'XData', [cp(1,1) cp(1,1)] );
    end
end

if isfield(handles,'EndMouseDown')
    if handles.EndMouseDown
        cp = get ( handles.hAxes, 'CurrentPoint' );
        set ( handles.hEndLine, 'XData', [cp(1,1) cp(1,1)] );
    end
end

if isfield(handles,'ThreshMouseDown')
    if handles.ThreshMouseDown
        cp = get ( handles.hAxes, 'CurrentPoint' );
        set ( handles.hThreshLine, 'YData', [cp(1,2) cp(1,2)] );
    end
end
if isfield(handles,'ThreshLineLower')
    if handles.ThreshLineLower
        cp = get ( handles.hAxes, 'CurrentPoint' );
        set ( handles.hThreshLineLower, 'YData', [cp(1,2) cp(1,2)] );
    end
end

function MouseUp(obj,event)
handles = guidata(gcf);
%% let the handle let me know which linke it is 
handles.StartMouseDown = 0;
handles.EndMouseDown = 0;
handles.ThreshMouseDown = 0;
handles.ThreshLineLower = 0;
guidata(gcf,handles);

function MouseDown(obj,event)
handles = guidata(gcf);
%% let the handle let me know which linke it is 
switch obj.UserData
    case 'start'
        handles.StartMouseDown = 1;
        handles.EndMouseDown = 0;
        handles.ThreshMouseDown = 0;
        handles.ThreshLineLower = 0;
    case 'end'
        handles.StartMouseDown = 0;
        handles.EndMouseDown = 1;
        handles.ThreshMouseDown = 0;
        handles.ThreshLineLower = 0;
    case 'thresh'
        handles.StartMouseDown = 0;
        handles.EndMouseDown = 0;
        handles.ThreshMouseDown = 1;
        handles.ThreshLineLower = 0;
    case 'threshlower'
        handles.StartMouseDown = 0;
        handles.EndMouseDown = 0;
        handles.ThreshMouseDown = 0;
        handles.ThreshLineLower = 1;
        
end
guidata(gcf,handles);



% --- Outputs from this function are returned to the command line.
function varargout = peakFinder_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.locuse;
delete(handles.figure1);


% --- Executes on button press in hFindBeeps.
function hFindBeeps_Callback(hObject, eventdata, handles)
handles = guidata(gcf);
dat = handles.datPlot;
secs = handles.secs;
% set defaults: 
pksuse =[]; locuse = [];
handles.hEndLine.XData(1)
idxuse = secs > handles.hStartLine.XData(1) & secs < handles.hEndLine.XData(1);
dat = dat(idxuse);
secs = secs(idxuse);
thresh = handles.hThreshLine.YData(1);
threshlow = handles.hThreshLineLower.YData(1);
methuse = handles.hMethodUse.String{handles.hMethodUse.Value};
if isempty(str2num(handles.hMinPeakDistanceSecs.String)) % use deafult 
    mindistnace = 2; 
else
    mindistnace = str2num(handles.hMinPeakDistanceSecs.String);
end
switch methuse
    case 'peaks'
        [pksuse,locuse,~,~] = findpeaks(dat,secs,...
            'MinPeakDistance',mindistnace,...
            'MinPeakHeight', thresh);
    case 'bounds'
        [pksuse,locuse,~,~] = findpeaks(dat,secs,...
            'MinPeakDistance',mindistnace,...
            'MinPeakHeight', thresh);

        upper = handles.hThreshLine.YData(1);
        lower = handles.hThreshLineLower.YData(2); 
        dattemp = dat; 
        dattemp(dat<lower) = 0; 
        dattemp(dat>lower) = 1; 
        idxuseBounds = find(diff(dattemp)==1);
        locuse = secs(idxuseBounds);
        pksuse = repmat(lower,length(locuse),1);
end

% remove ecog 
if isfield(handles,'scatterecog')
    for s = 1:length(handles.scatterecog)
        delete(handles.scatterecog(s));
    end
    handles = rmfield(handles,'scatterecog');
end

axes(handles.hAxes);
for s = 1:length(pksuse)
    handles.scatterecog(s) = ...
        scatter(locuse(s),pksuse(s),...
        400,'r',...
        'UserData',1,...
        'ButtonDownFcn',@ScatterPressed,...
        'UserData',0);
    handles.hlines(s) = ...
        plot([locuse(s) locuse(s)],handles.hAxes.YLim,...
        'Color',[0.5 0.5 0 0.6],...
        'LineWidth',1,...
        'UserData',1,...
        'Visible','off');
end
handles.locuse = locuse;
guidata(gcf,handles);

function ScatterPressed(obj,event)
if ~obj.UserData
    obj.MarkerFaceColor = 'b';
    obj.UserData = 1;
elseif obj.UserData
    obj.MarkerFaceColor = 'none';
    obj.UserData = 0;
end

handles = guidata(gcf);
guidata(gcf,handles);

    

% --- Executes on button press in hMarkBeeps.
function hMarkBeeps_Callback(hObject, eventdata, handles)
% hObject    handle to hMarkBeeps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in hExcludeMarked.
function hExcludeMarked_Callback(hObject, eventdata, handles)
handles = guidata(gcf); 
datuse = [handles.scatterecog.UserData];
delete(handles.scatterecog(logical(datuse)));
handles.scatterecog = handles.scatterecog(~logical(datuse));
handles.locuse = handles.locuse(~logical(datuse));
guidata(gcf,handles);


% --- Executes on button press in hDone.
function hDone_Callback(hObject, eventdata, handles)

handles = guidata(gcf);
handles.output = handles.locuse;
uiresume(handles.figure1); 

% hObject    handle to hDone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function hBPlow_Callback(hObject, eventdata, handles)
% hObject    handle to hBPlow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hBPlow as text
%        str2double(get(hObject,'String')) returns contents of hBPlow as a double


% --- Executes during object creation, after setting all properties.
function hBPlow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hBPlow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hBPhigh_Callback(hObject, eventdata, handles)
% hObject    handle to hBPhigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hBPhigh as text
%        str2double(get(hObject,'String')) returns contents of hBPhigh as a double


% --- Executes during object creation, after setting all properties.
function hBPhigh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hBPhigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hMinPeakDistanceSecs_Callback(hObject, eventdata, handles)
% hObject    handle to hMinPeakDistanceSecs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hMinPeakDistanceSecs as text
%        str2double(get(hObject,'String')) returns contents of hMinPeakDistanceSecs as a double


% --- Executes during object creation, after setting all properties.
function hMinPeakDistanceSecs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hMinPeakDistanceSecs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in hUseVariability.
function hUseVariability_Callback(hObject, eventdata, handles)
% hObject    handle to hUseVariability (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hUseVariability



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2


% --- Executes on button press in hFlipSignal.
function hFlipSignal_Callback(hObject, eventdata, handles)
handles = guidata(gcf);
handles.flipSignal = 1; 
guidata(gcf,handles);
updatePlot()
% hObject    handle to hFlipSignal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in hZoomOut.
function hZoomOut_Callback(hObject, eventdata, handles)
% hObject    handle to hZoomOut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in hResetThresh.
function hResetThresh_Callback(hObject, eventdata, handles)
% hObject    handle to hResetThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in hPositiveOnly.
function hPositiveOnly_Callback(hObject, eventdata, handles)
handles = guidata(gcf);
handles.onlyPositive = 1; 
guidata(gcf,handles);
updatePlot()
% hObject    handle to hPositiveOnly (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in hChanSelect.
function hChanSelect_Callback(hObject, eventdata, handles)
updatePlot();
% hObject    handle to hChanSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns hChanSelect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from hChanSelect


% --- Executes during object creation, after setting all properties.
function hChanSelect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hChanSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in hBandPass.
function hBandPass_Callback(hObject, eventdata, handles)
handles = guidata(gcf); 
handles.bpprressed = 1; 
guidata(gcf,handles); 
updatePlot()


% --- Executes on button press in hShowLines.
function hShowLines_Callback(hObject, eventdata, handles)
handles = guidata(gcf);
if isfield(handles,'hlines')
    if handles.hShowLines.Value
        for s = 1:length(handles.hlines)
            handles.hlines(s).Visible = 'on';
        end
    else
        for s = 1:length(handles.hlines)
            handles.hlines(s).Visible = 'off';
        end
    end
end

% Hint: get(hObject,'Value') returns toggle state of hShowLines


% --- Executes on selection change in hMethodUse.
function hMethodUse_Callback(hObject, eventdata, handles)
% hObject    handle to hMethodUse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns hMethodUse contents as cell array
%        contents{get(hObject,'Value')} returns selected item from hMethodUse


% --- Executes during object creation, after setting all properties.
function hMethodUse_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hMethodUse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in hZoomY.
function hZoomY_Callback(hObject, eventdata, handles)
handles = guidata(gcf);
dat = handles.datPlot;
secs = handles.secs;
% set defaults: 
idxuse = secs > handles.hStartLine.XData(1) & secs < handles.hEndLine.XData(1);
dat = dat(idxuse);
maxdat = max(dat); 
mindat = min(dat); 
if handles.hThreshLineLower.YData(1) < mindat
    handles.hThreshLineLower.YData = [mindat mindat].*0.9;
end

if handles.hThreshLine.YData(1) > maxdat
    handles.hThreshLine.YData = [maxdat maxdat].*0.8;
end
handles.hAxes.YLim = [mindat *1.1 maxdat * 1.1];
