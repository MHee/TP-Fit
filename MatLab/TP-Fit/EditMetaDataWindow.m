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

% Last Modified by GUIDE v2.5 13-Dec-2007 16:55:18

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

% Is set when figure is close without accepting data
handles.Cancel=false; 

% Load list of Data-Descriptions
FileDir=fileparts(mfilename('fullpath'));
DescList=textread(fullfile(FileDir,'DataDescriptions.lst'),'%s',...
    'commentstyle','shell','whitespace','\n');
set(handles.QualitySelector,'String',DescList);

% Populate Figure
if mod(length(varargin),2)
    % varargin is uneven (first parameter contains default meta-data)
    MData=varargin{1};
    handles.MData=MData;
    
    set(handles.ExpeditionEdit,'String',MData.Expedition);
    set(handles.SiteEdit,'String',MData.Site);
    set(handles.HoleEdit,'String',MData.Hole);
    set(handles.CoreEdit,'String',MData.Core);
    set(handles.CoreTypeEdit,'String',MData.CoreType);
    set(handles.DepthEdit,'String',MData.Depth);
    set(handles.DepthErrEdit,'String',MData.DepthError);
    set(handles.ToolIDEdit,'String',MData.ToolID);
    set(handles.ToolTypeText,'String',MData.ToolType);
    set(handles.OperatorEdit,'String',MData.Operator);
    set(handles.kEdit,'String',MData.Initial_k);
    set(handles.rcEdit,'String',MData.Initial_rC);
    set(handles.TErrEdit,'String',MData.TError);
    set(handles.CommentEdit,'String',MData.Comment);
    
    % Find the current data-description in the list
    DescNo=find(strcmpi(MData.DataQuality,DescList));
    if isempty(DescNo)
        hWarn=warndlg('Could not find Data Quality value in list. Added value at bottom of list');
        uiwait(hWarn);
        DescNo=length(DescList)+1;
        DescList{DescNo}=MData.DataQuality{1};
        set(handles.QualitySelector,'String',DescList);
    end    
    set(handles.QualitySelector,'Value',DescNo);
    
else
    handles.MData=[];
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes EditMetaDataWindow wait for user response (see UIRESUME)
% uiwait(handles.EditMetaDataWindow);


% --- Outputs from this function are returned to the command line.
function varargout = EditMetaDataWindow_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;  %handles.MData; 



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
MData=handles.MData;
    
MData.Expedition=get(handles.ExpeditionEdit,'String');
MData.Site=get(handles.SiteEdit,'String');
MData.Hole=get(handles.HoleEdit,'String');
MData.Core=get(handles.CoreEdit,'String');
MData.CoreType=get(handles.CoreTypeEdit,'String');
MData.Depth=num2str(str2double(get(handles.DepthEdit,'String')));
MData.DepthError=get(handles.DepthErrEdit,'String');
MData.ToolID=get(handles.ToolIDEdit,'String');
MData.ToolType=get(handles.ToolTypeText,'String');
MData.Operator=get(handles.OperatorEdit,'String');
MData.Initial_k=get(handles.kEdit,'String');
MData.Initial_rC=get(handles.rcEdit,'String');
MData.TError=get(handles.TErrEdit,'String');
MData.Comment=cellstr(get(handles.CommentEdit,'String'));
% Make shure no " is in Comment
MData.Comment=strrep(MData.Comment,'"','''');
MData.Expedition=get(handles.ExpeditionEdit,'String');
QualStrs=get(handles.QualitySelector,'String');
QualNo=get(handles.QualitySelector,'Value');
MData.DataQuality=QualStrs{QualNo};
MData.DataQualityNo=num2str(QualNo);
% Update handles structure
handles.MData=MData;
guidata(hObject, handles);
uiresume(handles.EditMetaDataWindow);

% --- Executes on button press in CancelButton.
function CancelButton_Callback(hObject, eventdata, handles)
% hObject    handle to CancelButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
EditMetaDataWindow_CloseRequestFcn(handles.EditMetaDataWindow, eventdata, handles);
%pause(1)
%delete(handles.EditMetaDataWindow);

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
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end



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

%function text13_CreateFcn(hObject, eventdata, handles)

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



function OperatorEdit_Callback(hObject, eventdata, handles)
% hObject    handle to OperatorEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of OperatorEdit as text
%        str2double(get(hObject,'String')) returns contents of OperatorEdit as a double


% --- Executes during object creation, after setting all properties.
function OperatorEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OperatorEdit (see GCBO)
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
k=str2double(get(handles.kEdit,'String'));
if isfinite(k)
        % Set Initial_rC to \citet{Herzen1959}
        kappa=(3.657*k-0.70)*1e-7; % /10e7
        set(handles.rcEdit,'String',sprintf('%.2g',k./kappa));
else
    warndlg('Enter a valid thermal conductivity first!!!');
end



% --- Executes when user attempts to close EditMetaDataWindow.
function EditMetaDataWindow_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to EditMetaDataWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
if handles.Cancel
    % Cancel was hit already, close now
    delete(hObject);
else
    handles.Cancel=true;
    guidata(hObject,handles);
    uiresume(hObject);
    set(hObject,'WindowStyle','normal');
end




