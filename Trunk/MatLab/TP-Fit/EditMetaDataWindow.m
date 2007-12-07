function varargout = EditMetaDataWindow(varargin)
% EDITMETADATAWINDOW M-file for EditMetaDataWindow.fig
%      EDITMETADATAWINDOW, by itself, creates a new EDITMETADATAWINDOW or raises the existing
%      singleton*.
%
%      H = EDITMETADATAWINDOW returns the handle to a new EDITMETADATAWINDOW or the handle to
%      the existing singleton*.
%
%      EDITMETADATAWINDOW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EDITMETADATAWINDOW.M with the given input arguments.
%
%      EDITMETADATAWINDOW('Property','Value',...) creates a new EDITMETADATAWINDOW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before EditMetaDataWindow_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to EditMetaDataWindow_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help EditMetaDataWindow

% Last Modified by GUIDE v2.5 07-Dec-2007 01:44:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @EditMetaDataWindow_OpeningFcn, ...
                   'gui_OutputFcn',  @EditMetaDataWindow_OutputFcn, ...
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


% --- Executes just before EditMetaDataWindow is made visible.
function EditMetaDataWindow_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to EditMetaDataWindow (see VARARGIN)

% Choose default command line output for EditMetaDataWindow
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes EditMetaDataWindow wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% Load list of Data-Descriptions
FileDir=fileparts(mfilename('fullpath'));
DescList=textread(fullfile(FileDir,'DataDescriptions.lst'),'%s',...
    'commentstyle','shell','whitespace','\n');
set(handles.QualitySelector,'String',DescList);


% --- Outputs from this function are returned to the command line.
function varargout = EditMetaDataWindow_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function CommentEdit_Callback(hObject, eventdata, handles)
% hObject    handle to CommentEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CommentEdit as text
%        str2double(get(hObject,'String')) returns contents of CommentEdit as a double


% --- Executes during object creation, after setting all properties.
function CommentEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CommentEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in AcceptButton.
function AcceptButton_Callback(hObject, eventdata, handles)
% hObject    handle to AcceptButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in CancelButton.
function CancelButton_Callback(hObject, eventdata, handles)
% hObject    handle to CancelButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in QualitySelector.
function QualitySelector_Callback(hObject, eventdata, handles)
% hObject    handle to QualitySelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns QualitySelector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from QualitySelector


% --- Executes during object creation, after setting all properties.
function QualitySelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to QualitySelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ToolTypeText_Callback(hObject, eventdata, handles)
% hObject    handle to ToolTypeText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ToolTypeText as text
%        str2double(get(hObject,'String')) returns contents of ToolTypeText as a double


% --- Executes during object creation, after setting all properties.
function ToolTypeText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ToolTypeText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ToolIDEdit_Callback(hObject, eventdata, handles)
% hObject    handle to ToolIDEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ToolIDEdit as text
%        str2double(get(hObject,'String')) returns contents of ToolIDEdit as a double


% --- Executes during object creation, after setting all properties.
function ToolIDEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ToolIDEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ExpeditionEdit_Callback(hObject, eventdata, handles)
% hObject    handle to ExpeditionEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ExpeditionEdit as text
%        str2double(get(hObject,'String')) returns contents of ExpeditionEdit as a double


% --- Executes during object creation, after setting all properties.
function ExpeditionEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ExpeditionEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SiteEdit_Callback(hObject, eventdata, handles)
% hObject    handle to SiteEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SiteEdit as text
%        str2double(get(hObject,'String')) returns contents of SiteEdit as a double


% --- Executes during object creation, after setting all properties.
function SiteEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SiteEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function HoleEdit_Callback(hObject, eventdata, handles)
% hObject    handle to HoleEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of HoleEdit as text
%        str2double(get(hObject,'String')) returns contents of HoleEdit as a double


% --- Executes during object creation, after setting all properties.
function HoleEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HoleEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function CoreEdit_Callback(hObject, eventdata, handles)
% hObject    handle to CoreEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CoreEdit as text
%        str2double(get(hObject,'String')) returns contents of CoreEdit as a double


% --- Executes during object creation, after setting all properties.
function CoreEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CoreEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DepthEdit_Callback(hObject, eventdata, handles)
% hObject    handle to DepthEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DepthEdit as text
%        str2double(get(hObject,'String')) returns contents of DepthEdit as a double


% --- Executes during object creation, after setting all properties.
function DepthEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DepthEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DepthErrEdit_Callback(hObject, eventdata, handles)
% hObject    handle to DepthErrEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DepthErrEdit as text
%        str2double(get(hObject,'String')) returns contents of DepthErrEdit as a double


% --- Executes during object creation, after setting all properties.
function DepthErrEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DepthErrEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function kEdit_Callback(hObject, eventdata, handles)
% hObject    handle to kEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of kEdit as text
%        str2double(get(hObject,'String')) returns contents of kEdit as a double


% --- Executes during object creation, after setting all properties.
function kEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to kEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rcEdit_Callback(hObject, eventdata, handles)
% hObject    handle to rcEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rcEdit as text
%        str2double(get(hObject,'String')) returns contents of rcEdit as a double


% --- Executes during object creation, after setting all properties.
function rcEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rcEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TErrEdit_Callback(hObject, eventdata, handles)
% hObject    handle to TErrEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TErrEdit as text
%        str2double(get(hObject,'String')) returns contents of TErrEdit as a double


% --- Executes during object creation, after setting all properties.
function TErrEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TErrEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit12_Callback(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit12 as text
%        str2double(get(hObject,'String')) returns contents of edit12 as a double


% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function CoreTypeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to CoreTypeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CoreTypeEdit as text
%        str2double(get(hObject,'String')) returns contents of CoreTypeEdit as a double


% --- Executes during object creation, after setting all properties.
function CoreTypeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CoreTypeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Compute_rc.
function Compute_rc_Callback(hObject, eventdata, handles)
% hObject    handle to Compute_rc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


