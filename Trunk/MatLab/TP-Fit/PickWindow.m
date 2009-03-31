function varargout = PickWindow(varargin)
%PICKWINDOW M-file for PickWindow.fig
%      PICKWINDOW, by itself, creates a new PICKWINDOW or raises the existing
%      singleton*.
%
%      H = PICKWINDOW returns the handle to a new PICKWINDOW or the handle to
%      the existing singleton*.
%
%      PICKWINDOW('Property','Value',...) creates a new PICKWINDOW using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to PickWindow_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      PICKWINDOW('CALLBACK') and PICKWINDOW('CALLBACK',hObject,...) call the
%      local function named CALLBACK in PICKWINDOW.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PickWindow

% Last Modified by GUIDE v2.5 08-Dec-2006 00:26:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PickWindow_OpeningFcn, ...
                   'gui_OutputFcn',  @PickWindow_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


function PickWindowPlot(handles)
Data=get(handles.figure1,'UserData');
%Pos=[.07 .12 .7 .85];
Data.Picks.UsedDat=find( ( (Data.tr>=Data.Picks.Window(1))&(Data.tr<=Data.Picks.Window(2))));

axes(handles.t_axes);
XLim=get(gca,'XLim');
YLim=get(gca,'YLim');
cla;


patch([XLim(1) XLim(1) Data.Picks.Window(1) Data.Picks.Window(1)],...
    [YLim fliplr(YLim)],...
    .9*[1 1 1],...
    'EdgeColor','none');
patch([XLim(2) XLim(2) Data.Picks.Window(2) Data.Picks.Window(2)],...
    [YLim fliplr(YLim)],...
    .9*[1 1 1],...
    'EdgeColor','none');


plot([0 0],YLim,'k--','LineWidth',1.5);
hold on;

if (isfield(Data,'OrigData') && isfield(Data.OrigData,'T2'))
    plot(Data.tr, Data.OrigData.T2,'.-','Color',[.7 .7 1]);
end
plot(Data.tr,Data.T,'.-');

%plot(Data.tr(Data.Picks.UsedDat),Data.T(Data.Picks.UsedDat),'g.');
%hold off;

set(handles.t_axes,...
    'XLim',XLim,...
    'YLim',YLim,...
    'XMinorTick','on',...
    'YMinorTick','on',...
    'Layer','top',...
    'XAxisLocation','top',...
    ...'Position',Pos,...
    'TickDir','out');
grid on;
ylabel('Temperature (°C)');

axes(handles.deriv_axes);
cla;
set(gca,'YScale','log');
hold on;

YLim=[1e-5 1e3];
patch([XLim(1) XLim(1) Data.Picks.Window(1) Data.Picks.Window(1)],...
    [YLim fliplr(YLim)],...
    .9*[1 1 1],...
    'EdgeColor','none');
patch([XLim(2) XLim(2) Data.Picks.Window(2) Data.Picks.Window(2)],...
    [YLim fliplr(YLim)],...
    .9*[1 1 1],...
    'EdgeColor','none');


Dt=diff(Data.tr);

t=Data.tr(1)+cumsum(Dt)-0.5*Dt;
DT=diff(Data.T)./Dt;
AvDT=MovingAverage(DT);
Av_t=MovingAverage(t);
semilogy(Av_t,abs(AvDT),'g-','LineWidth',6);
semilogy([0 0],YLim,'k--','LineWidth',1.5);
hold on;

Pos=find((DT>0));
Neg=find((DT<0));
semilogy(t(Pos),DT(Pos),'r.');
semilogy(t(Neg),-DT(Neg),'b.');
%semilogy(t,abs(DT),'k:');
xlabel('Time (s)');
ylabel('Temperatuer change (°C/s)');

set(handles.deriv_axes,...
    'XLim',XLim,...
    'YLim',[1e-5 Inf],...
    'XMinorTick','on',...
    'YMinorTick','on',...
    'Layer','top',...
    'Box','on',...
    'XAxisLocation','bottom',...
    ...'Position',Pos,...
    'TickDir','out');
xlabel('Time after penetration (s)');
grid on
set(handles.figure1,'UserData',Data);

function y=MovingAverage(x)
m=5;
n=length(x);
z = [0 cumsum(x(:)')];
y = ( z(m+1:n+1) - z(1:n-m+1) ) / m;


function AfterZoom(hFig,evd)
% removed because it creates errors ?!

% % fprintf('Changed Zoom to [%f %f]; [%f %f]!!!\n',[get(evd.Axes,'XLim') get(evd.Axes,'YLim')]);
% handles.t_axes=evd.Axes;
% handles.figure1=hFig;
% PickWindowPlot(handles);



function PickWindow_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for PickWindow
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PickWindow wait for user response (see UIRESUME)
% uiwait(handles.figure1);
set(hObject,'ToolBar','Figure');

Data=get(handles.figure1,'UserData');
set(handles.t0,'String',num2str(Data.Picks.t0));
set(handles.WinStart,'String',num2str(Data.Picks.Window(1)));
set(handles.WinStop,'String',num2str(Data.Picks.Window(2)));
set(handles.Operator,'String',Data.Info.Operator);

Data.tr=Data.t-Data.Picks.t0;
set(handles.figure1,'UserData',Data);

%Pos=[.07 .12 .7 .8];
axes(handles.t_axes);
set(handles.t_axes,...
    'TickDir','out',...
    'XAxisLocation','top',...
    'Box','on',...
    'Layer','top',...
    'XMinorTick','on',...
    ...'Position',Pos,...
    'YMinorTick','on');
if (isfield(Data.Session,'XLim') & isfield(Data.Session,'YLim'));
    set(handles.t_axes,...
        'XLim',Data.Session.XLim,...
        'YLim',Data.Session.YLim);
end

xlabel('t (s)');
ylabel('T (°C)');

linkaxes([handles.t_axes,handles.deriv_axes],'x');

PickWindowPlot(handles);
%axis auto

h = zoom;
set(h,'ActionPostCallback',@AfterZoom);
set(h,'Enable','on');

PickWindowPlot(handles);


% --- Outputs from this function are returned to the command line.
function varargout = PickWindow_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Pick_t0.
function Pick_t0_Callback(hObject, eventdata, handles)
% hObject    handle to Pick_t0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[x,y]=ginput(1);

Data=get(handles.figure1,'UserData');
t0=round(x+Data.Picks.t0);
Diff_t0=Data.Picks.t0-t0;
Data.Picks.t0=t0;
Data.tr=Data.t-t0;
set(handles.figure1,'UserData',Data);
set(handles.t0,'String',num2str(round(t0)));
XLim=get(handles.t_axes,'XLim');
set(handles.t_axes,'XLim',XLim+Diff_t0);
PickWindowPlot(handles);

% --- Executes on button press in Pick_WinStart.
function Pick_WinStart_Callback(hObject, eventdata, handles)
% hObject    handle to Pick_WinStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[x,y]=ginput(1);

Data=get(handles.figure1,'UserData');
Data.Picks.Window(1)=round(x);
set(handles.figure1,'UserData',Data);
set(handles.WinStart,'String',num2str(round(x)));
PickWindowPlot(handles);


function WinStart_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WinStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function WinStart_Callback(hObject, eventdata, handles)
% hObject    handle to WinStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of WinStop as text
%        str2double(get(hObject,'String')) returns contents of WinStop as a double
Data=get(handles.figure1,'UserData');
Data.Picks.Window(1)=round(str2double(get(hObject,'String')));
set(handles.figure1,'UserData',Data);
PickWindowPlot(handles);



function WinStop_Callback(hObject, eventdata, handles)
% hObject    handle to WinStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of WinStop as text
%        str2double(get(hObject,'String')) returns contents of WinStop as a double
Data=get(handles.figure1,'UserData');
Data.Picks.Window(2)=round(str2double(get(hObject,'String')));
set(handles.figure1,'UserData',Data);
PickWindowPlot(handles);


% --- Executes during object creation, after setting all properties.
function WinStop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WinStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in Pick_WinStop.
function Pick_WinStop_Callback(hObject, eventdata, handles)
% hObject    handle to Pick_WinStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[x,y]=ginput(1);

Data=get(handles.figure1,'UserData');
Data.Picks.Window(2)=round(x);
set(handles.figure1,'UserData',Data);
set(handles.WinStop,'String',num2str(round(x)));
PickWindowPlot(handles);



function Operator_Callback(hObject, eventdata, handles)
% hObject    handle to Operator (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Operator as text
%        str2double(get(hObject,'String')) returns contents of Operator as a double
Data=get(handles.figure1,'UserData');
Data.Info.Operator=get(hObject,'String');
set(handles.figure1,'UserData',Data);

% --- Executes during object creation, after setting all properties.
function Operator_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Operator (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function t0_Callback(hObject, eventdata, handles)
% hObject    handle to t0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of t0 as text
%        str2double(get(hObject,'String')) returns contents of t0 as a double
Data=get(handles.figure1,'UserData');
t0=round(str2double(get(hObject,'String')));
Data.Picks.t0=t0;
Data.tr=Data.t-t0;
set(handles.figure1,'UserData',Data);
PickWindowPlot(handles);



% --- Executes during object creation, after setting all properties.
function t0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to t0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function UnZoom_Callback(hObject, eventdata, handles)
% hObject    handle to Done (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axis(handles.t_axes,'auto');

Data=get(handles.figure1,'UserData');
Data.Session.XLim=get(handles.t_axes,'XLim');
Data.Session.YLim=get(handles.t_axes,'YLim');
set(handles.t_axes,...
    'XLim',Data.Session.XLim,...
    'YLim',Data.Session.YLim);


% Data.Session.XLim=[-Inf +Inf];
% Data.Session.YLim=[-Inf +Inf];
% set(handles.t_axes,...
%     'XLim',Data.Session.XLim,...
%     'YLim',Data.Session.YLim);

set(handles.figure1,'UserData',Data);
evd.Axes=handles.t_axes;
AfterZoom(handles.figure1,evd);

% --- Executes on button press in Done.
function Done_Callback(hObject, eventdata, handles)
% hObject    handle to Done (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Data=get(handles.figure1,'UserData');
Data.Session.XLim=get(handles.t_axes,'XLim');
Data.Session.YLim=get(handles.t_axes,'YLim');
set(handles.figure1,'UserData',Data);
%handles
uiresume(handles.figure1);

% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Data=get(handles.figure1,'UserData');
set(gcf,...
    'PaperType','A4',...
    'PaperPosition',[4 4 18 1/sqrt(2)*18])
print('-depsc','-noui',[Data.Info.Hole Data.Info.Core Data.Info.CoreType '_Pick.eps']);


% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


