function varargout = threshold_beep_finder(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @threshold_beep_finder_OpeningFcn, ...
                   'gui_OutputFcn',  @threshold_beep_finder_OutputFcn, ...
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
% End initialization code - DO NOT EDIT


% --- Executes just before threshold_beep_finder is made visible.
function threshold_beep_finder_OpeningFcn(hObject, eventdata, handles, varargin)
set(hObject,'toolbar','figure');
set(hObject,'menubar','figure');

set(handles.figure1,...
    'WindowButtonMotionFcn', @MouseMove,...
    'WindowButtonUpFcn', @MouseUp );
% set zoooming behaviour 
% 
zoom xon 
handles.ZoomOutPressedEEG = 0; 
handles.ZoomOutPressedECOG = 0; 

% setAxesZoomConstraint(handles.ZoomIn,handles.axEEG,'x')
% 
% set the initial variables eeg 
eegraw = varargin{1};
rawfnms = fieldnames(eegraw);
idxchoose = cellfun(@(x) ~any(strfind(x,'srate')),rawfnms);
rawfnms = rawfnms(idxchoose);
handles.eeg_xlims = [0.5 40]; 
% set pop up values 
handles.channel_select_eeg.String = rawfnms;
handles.channel_select_eeg.Value = 1;



% set up variables ecog 
brraw  = varargin{2};
bruse.lfp = brraw.lfp.*-1;
bruse.ecog = brraw.ecog.*-1;
bruse.srate = brraw.sr; 

rawfnms = fieldnames(bruse);
idxchoose = cellfun(@(x) ~any(strfind(x,'srate')),rawfnms);
rawfnms = rawfnms(idxchoose);
handles.channel_select_ecog.String = rawfnms;
handles.channel_select_ecog.Value = 2;
handles.ecog_xlims = [0.5 20]; 

handles.eegThresh = 2;
handles.ecogThresh = 2;


% save variables in handles strucutre 
handles.eegdat = eegraw; 
handles.ecogdat =  bruse;
handles.ecogTempSr = bruse.srate;
handles.eegSR = eegraw.soundsrate;
handles.eegdat.srate = eegraw.soundsrate;

% set band pass settings
handles.bpecog = 0; 
handles.bpeeg = 0; 
% set ouptput 
handles.output = [];
% Update handles structure
guidata(gcf, handles);

updatePlot();
uiwait(handles.figure1);

% UIWAIT makes threshold_beep_finder wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = threshold_beep_finder_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.allignData;
delete(handles.figure1);


% --- Executes on button press in flipEEG.
function flipEEG_Callback(hObject, eventdata, handles)
idx = handles.channel_select_eeg.Value; 
rawfnms = handles.channel_select_eeg.String;
datplot = handles.eegdat.(rawfnms{idx});
handles.eegdat.(rawfnms{idx}) = datplot .* (-1);
guidata(hObject, handles);
updatePlot();

% hObject    handle to flipEEG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in flipECOG.
function flipECOG_Callback(hObject, eventdata, handles)
% hObject    handle to flipECOG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in eeg_channel_selec.
function eeg_channel_selec_Callback(hObject, eventdata, handles)

% hObject    handle to eeg_channel_selec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns eeg_channel_selec contents as cell array
%        contents{get(hObject,'Value')} returns selected item from eeg_channel_selec


% --- Executes during object creation, after setting all properties.
function eeg_channel_selec_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eeg_channel_selec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ecoc_channel_selec.
function ecoc_channel_selec_Callback(hObject, eventdata, handles)
% hObject    handle to ecoc_channel_selec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ecoc_channel_selec contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ecoc_channel_selec


% --- Executes during object creation, after setting all properties.
function ecoc_channel_selec_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ecoc_channel_selec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in selectThreshEEG.
function selectThreshEEG_Callback(hObject, eventdata, handles)
thresh= get ( handles.hThreshEEG, 'YData');
handles.eegThresh = thresh(1);
guidata(handles.figure1, handles);
% hObject    handle to selectThreshEEG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in find_beeps_eeg.
function find_beeps_eeg_Callback(hObject, eventdata, handles)
datause = handles.datPlotEEG;
xlimsuse = handles.axEEG.XLim;

secs = [1:length(datause)]./handles.eegSR; 
idxuse = secs > xlimsuse(1) & secs < xlimsuse(2);
[pksuse,locuse,~,~] = findpeaks(datause(idxuse),secs(idxuse),...
    'MinPeakDistance',0.1,...
    'MinPeakHeight', handles.hThreshEEG.YData(1) );


if isfield(handles,'scattereeg')
    for s = 1:length(handles.scattereeg)
        delete(handles.scattereeg(s));
    end
    handles = rmfield(handles,'scattereeg');
end
axes(handles.axEEG);
hold on;
for s = 1:length(pksuse)
    handles.scattereeg(s) = ...
        scatter(...
        locuse(s),pksuse(s),...
        400,'r',...
        'UserData',1,...
        'ButtonDownFcn',@ScatterPressed,...
        'UserData',0);
end
handles.axEEG.XLim = xlimsuse;
guidata(gcf,handles);

% --- Executes on button press in flip_signal_ecog.
function flip_signal_ecog_Callback(hObject, eventdata, handles)
idx = handles.channel_select_ecog.Value; 
rawfnms = handles.channel_select_ecog.String;
datplot = handles.ecogdat.(rawfnms{idx});
handles.ecogdat.(rawfnms{idx}) = datplot .* (-1);
guidata(hObject, handles);
updatePlot();

% hObject    handle to flip_signal_ecog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in select_thresh_ecog.
function select_thresh_ecog_Callback(hObject, eventdata, handles)
thresh = get ( handles.hThreshECOG, 'YData');
handles.ecogThresh = thresh(1);
guidata(handles.figure1, handles);
% hObject    handle to select_thresh_ecog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in find_beeps_ecog.
function find_beeps_ecog_Callback(hObject, eventdata, handles)

datause = handles.datPlotECOG;
xlimsuse = handles.axECOG.XLim;
secs = [1:length(datause)]./handles.ecogTempSr; 
idxuse = secs > xlimsuse(1) & secs < xlimsuse(2);


[pksuse,locuse,~,~] = findpeaks(datause(idxuse),secs(idxuse),...
    'MinPeakDistance',0.1,...
    'MinPeakHeight', handles.hThreshECOG.YData(1) );

% remove ecog 
if isfield(handles,'scatterecog')
    for s = 1:length(handles.scatterecog)
        delete(handles.scatterecog(s));
    end
    handles = rmfield(handles,'scatterecog');
end

axes(handles.axECOG);
for s = 1:length(pksuse)
    handles.scatterecog(s) = ...
        scatter(locuse(s),pksuse(s),...
        400,'r',...
        'UserData',1,...
        'ButtonDownFcn',@ScatterPressed,...
        'UserData',0);
end
guidata(gcf,handles);



% --- Executes on button press in align_start.
function align_start_Callback(hObject, eventdata, handles)
% hObject    handle to align_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in compute_sr.
function compute_sr_Callback(hObject, eventdata, handles)
handles = guidata(gcf);
% get eeg differnces 
cnt = 1; 
for s = 1:length(handles.scattereeg)
    if handles.scattereeg(s).UserData
        eegpoint(cnt) = handles.scattereeg(s).XData * handles.eegSR;
        cnt = cnt + 1; 
    end
end
% get ecog differences 
cnt = 1; 
for s = 1:length(handles.scatterecog)
    if handles.scatterecog(s).UserData
        ecogpoint(cnt) = handles.scatterecog(s).XData  * handles.ecogTempSr;
        cnt = cnt + 1; 
    end
end

Diffecog = ecogpoint(2)- ecogpoint(1); % XXX just use first point consider changing
Diffeeg = eegpoint(2)- eegpoint(1);
ecogSR  = (handles.eegdat.srate * Diffecog ) / Diffeeg;
ecogsr = round(ecogSR);
handles.allignData.eegsync = eegpoint; 
handles.allignData.ecogsync = ecogpoint; 
handles.allignData.diffecog = Diffecog;
handles.allignData.diffeeg = Diffeeg;
handles.allignData.ecogsr  = ecogsr;
handles.allignData.eegsr   = handles.eegdat.srate;
% update handles structure  
guidata(handles.figure1,handles);

handles.sr_text.String = sprintf('SR is %d',ecogsr);
% hObject    handle to compute_sr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in channel_select_eeg.
function channel_select_eeg_Callback(hObject, eventdata, handles)
updatePlot();


% --- Executes during object creation, after setting all properties.
function channel_select_eeg_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in channel_select_ecog.
function channel_select_ecog_Callback(hObject, eventdata, handles)
updatePlot();

function channel_select_ecog_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function MouseMove(gcbo,event,handles)
handles = guidata(gcf);
if handles.eegThreshMouseDown
    cp = get ( handles.axEEG, 'CurrentPoint' );
    set ( handles.hThreshEEG, 'YData', [cp(1,2) cp(1,2)] );
end

if handles.ecogThreshMouseDown
    cp = get ( handles.axECOG, 'CurrentPoint' );
    set ( handles.hThreshECOG, 'YData', [cp(1,2) cp(1,2)] );
end



function MouseUp(gcbo,event,handles)
handles = guidata(gcf);
handles.eegThreshMouseDown = 0; 
handles.ecogThreshMouseDown = 0;
guidata(gcf,handles);



function MouseDown(obj,event)
handles = guidata(gcf);
%% let the handle let me know which linke it is 
switch obj.UserData
    case 'eeg'
        handles.eegThreshMouseDown = 1;
    case 'ecog'
        handles.ecogThreshMouseDown = 1;
end
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





function updatePlot()
handles = guidata(gcf);
%% update the plot according to current settings 

%%  plot eeg 
cla ( handles.axEEG );
rawfnms = handles.channel_select_eeg.String; 
idx = handles.channel_select_eeg.Value; 
datplot = handles.eegdat.(rawfnms{idx}); 

if handles.bpeeg
    bp1 = str2num(handles.LowerBPeeg.String);
    bp2 = str2num(handles.upperBPeegData.String);
    bp = designfilt('bandpassiir',...
        'FilterOrder',4, ...
        'HalfPowerFrequency1',bp1,...
        'HalfPowerFrequency2',bp2, ...
        'SampleRate',handles.eegdat.srate);
    datplot = filtfilt(bp,double(datplot));
else
    datplot = datplot; 
end

handles.datPlotEEG = zscore(datplot);
secs = [1:length(datplot)]./handles.eegSR; 
plot(secs,handles.datPlotEEG,...
    'Parent',handles.axEEG,...
    'LineWidth',0.5,....
    'Color',[1 0 0 0.2]);
hold on;
if isfield(handles,'hThreshEEG')
    delete(handles.hThreshEEG)
end
handles.eegThresh = max(handles.datPlotEEG) * 0.7;
handles.hThreshEEG = line([0 max(secs)],...
    [handles.eegThresh handles.eegThresh],...
    'Parent',handles.axEEG,...
    'LineWidth',2,...
    'Color',[1 0 0 0.2],...
    'ButtonDownFcn',@MouseDown,...
    'UserData','eeg');
handles.eegThreshMouseDown = 0;
xlabel(handles.axEEG,'seconds');
ylabel(handles.axEEG,'voltage');
handles.axEEG.XLim = [min(secs) max(secs)];

% set zooming eeg 
if handles.ZoomOutPressedEEG
    handles.eeg_xlims = handles.axEEG.XLim;
else
    xlim(handles.axEEG,handles.eeg_xlims)
end


%% plot ecog 
cla ( handles.axECOG );

rawfnms = handles.channel_select_ecog.String; 
idx = handles.channel_select_ecog.Value; 
datplot = handles.ecogdat.(rawfnms{idx}); 

if handles.bpecog
    bp1 = str2num(handles.LowerBPEcogdata.String);
    bp2 = str2num(handles.upperBPecogData.String);
    bp = designfilt('bandpassiir',...
        'FilterOrder',4, ...
        'HalfPowerFrequency1',bp1,...
        'HalfPowerFrequency2',bp2, ...
        'SampleRate',handles.ecogTempSr);
    datplot = filtfilt(bp,double(datplot));
else
    datplot = datplot; 
end

handles.datPlotECOG = zscore(datplot);
secs = [1:length(datplot)]./handles.ecogTempSr; 
plot(handles.axECOG,secs,handles.datPlotECOG,...
    'LineWidth',0.5,....
    'Color',[0 0 1 0.2]);
hold on;
if isfield(handles,'hThreshECOG')
    delete(handles.hThreshECOG)
end
handles.ecogThresh = max(handles.datPlotECOG) * 0.7;

handles.hThreshECOG = line(handles.axECOG,[0 max(secs)],...
    [handles.ecogThresh handles.ecogThresh],...
    'LineWidth',2,...
    'Color',[1 0 0 0.2],...
    'ButtonDownFcn',@MouseDown,...
    'UserData','ecog');
xlabel('seconds');
ylabel('voltage');
handles.ecogThreshMouseDown = 0;
xlabel(handles.axECOG,'seconds');
ylabel(handles.axECOG,'voltage');
handles.axECOG.XLim = [min(secs) max(secs)];

% set zooming ecog 
if handles.ZoomOutPressedECOG
    handles.ecog_xlims = handles.axECOG.XLim;
else
    xlim(handles.axECOG,handles.ecog_xlims)
end


guidata(gcf, handles);


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)


% --- Executes on button press in CloseFigure.
function CloseFigure_Callback(hObject, eventdata, handles)
% hObject    handle to CloseFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(gcf);
handles.output = handles.allignData; 
uiresume(handles.figure1); 
% delete(handles.figure1);


% --- Executes on button press in ZoomOutEEG.
function ZoomOutEEG_Callback(hObject, eventdata, handles)
rawfnms = handles.channel_select_eeg.String; 
idx = handles.channel_select_eeg.Value; 
datplot = handles.eegdat.(rawfnms{idx}); 

secs = [1:length(datplot)]./handles.eegSR; 
handles.eeg_xlims = [min(secs) max(secs)];

xlim(handles.axEEG,handles.eeg_xlims)
handles.ZoomOutPressedEEG = 1;
updatePlot();
guidata(gcf, handles);




% --- Executes on button press in zoomOutECOG.
function zoomOutECOG_Callback(hObject, eventdata, handles)
rawfnms = handles.channel_select_ecog.String; 
idx = handles.channel_select_ecog.Value; 
datplot = handles.ecogdat.(rawfnms{idx}); 

secs = [1:length(datplot)]./handles.ecogTempSr; 
handles.ecog_xlims = [min(secs) max(secs)];

xlim(handles.axECOG,handles.ecog_xlims)
handles.ZoomOutPressedECOG = 1;
guidata(gcf, handles);




% --- Executes on button press in ZoomYEEG.
function ZoomYEEG_Callback(hObject, eventdata, handles)
handles = guidata(gcf);
rawfnms = handles.channel_select_eeg.String; 
idx = handles.channel_select_eeg.Value; 
datplot = handles.datPlotEEG;
secs = [1:length(datplot)]./handles.eegSR; 
idxx = secs > handles.axEEG.XLim(1) & secs < handles.axEEG.XLim(2);
miny = min(datplot(idxx)) - min(datplot(idxx)) *0.1;
maxy = max(datplot(idxx)) + max(datplot(idxx)) *0.1;
handles.axEEG.YLim = [miny maxy];
handles.eegThresh = maxy/2; 
guidata(gcf, handles);






% --- Executes on button press in ZoomYecog.
function ZoomYecog_Callback(hObject, eventdata, handles)
handles = guidata(gcf);
rawfnms = handles.channel_select_ecog.String; 
idx = handles.channel_select_ecog.Value; 
datplot = handles.datPlotECOG;
secs = [1:length(datplot)]./handles.ecogTempSr; 
idxx = secs > handles.axECOG.XLim(1) & secs < handles.axECOG.XLim(2);


miny = min(datplot(idxx)) - min(datplot(idxx)) *0.1;
maxy = max(datplot(idxx)) + max(datplot(idxx)) *0.1;
handles.axECOG.YLim = [miny maxy];
handles.ecogThresh = maxy/2; 

guidata(gcf, handles);

% --- Executes on button press in BandPassEEG.
function BandPassEEG_Callback(hObject, eventdata, handles)
handles = guidata(gcf); 
handles.bpeeg = 1; 
guidata(gcf,handles);


% --- Executes on button press in BandPassECOGdata.
function BandPassECOGdata_Callback(hObject, eventdata, handles)
handles = guidata(gcf); 
handles.bpecog = 1; 
guidata(gcf,handles);

function LowerBPeeg_Callback(hObject, eventdata, handles)

function LowerBPeeg_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function upperBPeegData_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function upperBPeegData_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function LowerBPEcogdata_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function LowerBPEcogdata_CreateFcn(hObject, eventdata, handles)


function upperBPecogData_Callback(hObject, eventdata, handles)

function upperBPecogData_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function updateThePlot_Callback(hObject, eventdata, handles)
updatePlot();
