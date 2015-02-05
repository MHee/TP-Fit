function varargout = addAntaresToolCfg(varargin)
% ADDANTARESTOOLCFG MATLAB code for addAntaresToolCfg.fig
%      ADDANTARESTOOLCFG by itself, creates a new ADDANTARESTOOLCFG or raises the
%      existing singleton*.
%
%      H = ADDANTARESTOOLCFG returns the handle to a new ADDANTARESTOOLCFG or the handle to
%      the existing singleton*.
%
%      ADDANTARESTOOLCFG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ADDANTARESTOOLCFG.M with the given input arguments.
%
%      ADDANTARESTOOLCFG('Property','Value',...) creates a new ADDANTARESTOOLCFG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before addAntaresToolCfg_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to addAntaresToolCfg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help addAntaresToolCfg

% Last Modified by GUIDE v2.5 26-Jan-2015 12:16:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @addAntaresToolCfg_OpeningFcn, ...
                   'gui_OutputFcn',  @addAntaresToolCfg_OutputFcn, ...
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

% --- Executes just before addAntaresToolCfg is made visible.
function addAntaresToolCfg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to addAntaresToolCfg (see VARARGIN)

% Choose default command line output for addAntaresToolCfg
handles.output = [];
if ~length(varargin)==2
    error('Need two arguments (ToolDB followed by new ToolID');
end
handles.ToolDB=varargin{1};
handles.ToolID=varargin{2};

set(handles.serial_popupmenu,'String',{handles.ToolID});
set(handles.serial_popupmenu,'Value',1);

% Update handles structure
guidata(hObject, handles);

% Insert custom Title and Text if specified by the user
% Hint: when choosing keywords, be sure they are not easily confused 
% with existing figure properties.  See the output of set(figure) for
% a list of figure properties.
if(nargin > 3)
    for index = 1:2:(nargin-3),
        if nargin-3==index, break, end
        switch lower(varargin{index})
         case 'title'
          set(hObject, 'Name', varargin{index+1});
         case 'string'
          set(handles.text1, 'String', varargin{index+1});
        end
    end
end

% Determine the position of the dialog - centered on the callback figure
% if available, else, centered on the screen
FigPos=get(0,'DefaultFigurePosition');
OldUnits = get(hObject, 'Units');
set(hObject, 'Units', 'pixels');
OldPos = get(hObject,'Position');
FigWidth = OldPos(3);
FigHeight = OldPos(4);
if isempty(gcbf)
    ScreenUnits=get(0,'Units');
    set(0,'Units','pixels');
    ScreenSize=get(0,'ScreenSize');
    set(0,'Units',ScreenUnits);

    FigPos(1)=1/2*(ScreenSize(3)-FigWidth);
    FigPos(2)=2/3*(ScreenSize(4)-FigHeight);
else
    GCBFOldUnits = get(gcbf,'Units');
    set(gcbf,'Units','pixels');
    GCBFPos = get(gcbf,'Position');
    set(gcbf,'Units',GCBFOldUnits);
    FigPos(1:2) = [(GCBFPos(1) + GCBFPos(3) / 2) - FigWidth / 2, ...
                   (GCBFPos(2) + GCBFPos(4) / 2) - FigHeight / 2];
end
FigPos(3:4)=[FigWidth FigHeight];
set(hObject, 'Position', FigPos);
set(hObject, 'Units', OldUnits);

updateImage(handles);

% Make the GUI modal
set(handles.addAntaresCfgDlg,'WindowStyle','modal')

% UIWAIT makes addAntaresToolCfg wait for user response (see UIRESUME)
uiwait(handles.addAntaresCfgDlg);

% --- Outputs from this function are returned to the command line.
function updateImage(handles)
% Show a question icon from dialogicons.mat - variables questIconData
% and questIconMap
selection=get(handles.tooltype_popupmenu,'Value');
switch selection
    case 1
        load dialogicons.mat
        IconData=questIconData;
        questIconMap(256,:) = get(handles.addAntaresCfgDlg, 'Color');
        IconCMap=questIconMap;
        Img=image(IconData, 'Parent', handles.img_axes);
        set(handles.addAntaresCfgDlg, 'Colormap', IconCMap);
    case 2
        imgFilename=fullfile(fileparts(mfilename('fullpath')),'Resources','APCT.jpg');
        ImgDat=imread(imgFilename);
        Img=image(ImgDat, 'Parent', handles.img_axes); 
    case 3
        imgFilename=fullfile(fileparts(mfilename('fullpath')),'Resources','SET01.jpg');
        ImgDat=imread(imgFilename);
        Img=image(ImgDat, 'Parent', handles.img_axes);
    case 4
        load dialogicons.mat
        IconData=warnIconData;
        warnIconMap(256,:) = get(handles.addAntaresCfgDlg, 'Color');
        IconCMap=warnIconMap;
        Img=image(IconData, 'Parent', handles.img_axes);
        set(handles.addAntaresCfgDlg, 'Colormap', IconCMap);
end

set(handles.img_axes, ...
    'Visible', 'off', ...
    'YDir'   , 'reverse'       , ...
    'XLim'   , get(Img,'XData'), ...
    'YLim'   , get(Img,'YData')  ...
    );
function varargout = addAntaresToolCfg_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.addAntaresCfgDlg);

% --- Executes when user attempts to close addAntaresCfgDlg.
function addAntaresCfgDlg_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to addAntaresCfgDlg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
    delete(hObject);
end


% --- Executes on key press over addAntaresCfgDlg with no controls selected.
function addAntaresCfgDlg_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to addAntaresCfgDlg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Check for "enter" or "escape"
if isequal(get(hObject,'CurrentKey'),'escape')
    % User said no by hitting escape
    handles.output = 'No';
    
    % Update handles structure
    guidata(hObject, handles);
    
    uiresume(handles.addAntaresCfgDlg);
end    
    
if isequal(get(hObject,'CurrentKey'),'return')
    uiresume(handles.addAntaresCfgDlg);
end    


% --- Executes on selection change in serial_popupmenu.
function serial_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to serial_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns serial_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from serial_popupmenu


% --- Executes during object creation, after setting all properties.
function serial_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to serial_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in tooltype_popupmenu.
function tooltype_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to tooltype_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns tooltype_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from tooltype_popupmenu
if get(hObject,'Value')==1
    set(handles.save_button,'enable','off');
else
    set(handles.save_button,'enable','on');
end
updateImage(handles);

% --- Executes during object creation, after setting all properties.
function tooltype_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tooltype_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in save_button.
function save_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selection =get(handles.tooltype_popupmenu,'Value');
choices=get(handles.tooltype_popupmenu,'String');
choice=choices{selection};
switch selection
    case 1
        % Nothing selected, keep trying
        return
    case 2
        % APCT-3 selected, save
        fprintf('Saving %s settings to tool database!\n',choice);
        Setting.DataType='ANTARES';
        Setting.ToolID=handles.ToolID;
        Setting.ToolType='APCT-3';
		Setting.ModelType='APCT_T';
        handles.ToolDB.addToolSetting(Setting);
    case 3
        % SET2 selceted, save
        fprintf('Saving %s settings to tool database!\n',choice);
        Setting.DataType='ANTARES';
        Setting.ToolID=handles.ToolID;
        Setting.ToolType='SET2';
		Setting.ModelType='DVTP_T';
        handles.ToolDB.addToolSetting(Setting);
    case 4
        % Other nothing to do
        warning('Nothing selected, user is on her own...');
end


handles.output = choice;

% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.addAntaresCfgDlg);
