function varargout = TDataExplorer(varargin)
% TDATAEXPLORER M-file for TDataExplorer.fig
%      TDATAEXPLORER, by itself, creates a new TDATAEXPLORER or raises the existing
%      singleton*.
%
%      H = TDATAEXPLORER returns the handle to a new TDATAEXPLORER or the handle to
%      the existing singleton*.
%
%      TDATAEXPLORER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TDATAEXPLORER.M with the given input arguments.
%
%      TDATAEXPLORER('Property','Value',...) creates a new TDATAEXPLORER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TDataExplorer_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TDataExplorer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TDataExplorer

% Last Modified by GUIDE v2.5 28-Sep-2007 13:32:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TDataExplorer_OpeningFcn, ...
                   'gui_OutputFcn',  @TDataExplorer_OutputFcn, ...
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

% --- Executes just before TDataExplorer is made visible.
function TDataExplorer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TDataExplorer (see VARARGIN)

Data.DB=[];
Data.CurrRec=1;
Data.Filter=[];
set(handles.TDataExplorer,'UserData',Data,...
    'KeyPressFcn',@TDataExplorer_KeyHandler);

hAllObj=findobj(handles.TDataExplorer,'KeyPressFcn','');
set(hAllObj,'KeyPressFcn',@TDataExplorer_KeyHandler);
set(handles.FilterText,'KeyPressFcn',''); % this should take all keys ;-)

hZoom=zoom(handles.TPlot);
set(hZoom,'UIContextMenu',get(handles.TPlot,'UIContextMenu'));
%UpdateWidgets(handles);

% Choose default command line output for TDataExplorer
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using TDataExplorer.
if strcmp(get(hObject,'Visible'),'off')
    APCImage=imread(fullfile(fileparts(mfilename('full')),...
        'CuttingShoe.jpg'));
    
    hImage=image(APCImage);
%    get(hImage)
    set(hImage,'ButtonDownFcn',...
        'TDataExplorer(''OpenMenuItem_Callback'',gcbo,[],guidata(gcbo))');
    set(handles.TPlot,'Visible','off');
    axis equal
    clear('APCImage');
end

% Delete save Figure / new figure from toolbar
TBButtons=findall(gcf,'Type','uipushtool','-regexp','Tag','Standard');
delete(TBButtons);



% UIWAIT makes TDataExplorer wait for user response (see UIRESUME)
% uiwait(handles.TDataExplorer);


% --- Outputs from this function are returned to the command line.
function varargout = TDataExplorer_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function SaveDB_Callback(hObject, eventdata, handles)
Data=get(handles.TDataExplorer,'UserData');
Settings=get(handles.OpenMenuItem,'UserData');

if isfield(Settings,'DBLocation') && ~isempty(Settings.DBLocation)
    save(Settings.DBLocation,'Data');
    fprintf('\n%s\nSaved to: %s\n',datestr(now),Settings.DBLocation);
else
    SaveAs_Callback([], eventdata, handles);
end

% --------------------------------------------------------------------
function New_DB_Callback(hObject, eventdata, handles)
StartDir=uigetdir(pwd);
StartDir=inputdlg('Start here?','Confirm',1,{StartDir});
%assignin('base','StartDir',StartDir);
StartDir=StartDir{1};
Data=get(handles.TDataExplorer,'UserData');
fprintf('------ Looking for files -----\n');
DB=FindTFiles(StartDir);
fprintf('------ Collecting meta data -----\n');
DB=CollectMetaData(DB);
Data.DB=DB;
Data.CurrRec=1;
Data.CurrentTag=[];
Data.Filter=1:length(Data.DB);
% for i=1:length(Data.DB)
%     Data.DB(i).BadData=0;
%     % Data.DB(i).Interesting=0; % Interesting replaced by tags
%     Data.DB(i).Tags=[];
% end
set(handles.TDataExplorer,'UserData',Data);
ScaleSlider(handles);
UpdateWidgets(handles);


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Data=get(handles.TDataExplorer,'UserData');
[FileName,PathName] = uigetfile('*.mat');
FullFileName=fullfile(PathName,FileName);
if ~isequal(FileName, 0)
    load(FullFileName);
    if ~(exist('Data','var') && isfield(Data,'DB'))
        warning('TDataExplorer:NoFile','No Data base File!!!!');
        return
    end
else
    warning('TDataExplorer:NoFile','No File!!!!');
    return
end

if ~isfield(Data,'CurrRec')
    Data.CurrRec=1;
    Data.Filter=1:length(Data.DB);
end
% Read Tag-Names
if ~isfield(Data,'TagNames')
    Data.TagNames={'Click right to edit',...
        '2','3','4','5','6','7','8','9','10'};
end
set(handles.TagList,'String',Data.TagNames);

if ~isfield(Data,'CurrentTag')
    Data.CurrentTag=1;
end

fprintf('Opened %s\n',FullFileName);

Settings=get(handles.OpenMenuItem,'UserData');
Settings.DBLocation=FullFileName;
set(handles.TDataExplorer,'Name',...
    sprintf('TDataExplorer - %s',FullFileName));
set(handles.OpenMenuItem,'UserData',Settings);

set(handles.TDataExplorer,'UserData',Data);
ScaleSlider(handles);
UpdateWidgets(handles);


% --------------------------------------------------------------------
function SaveAs_Callback(hObject, eventdata, handles)
% hObject    handle to SaveAs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Data=get(handles.TDataExplorer,'UserData');
Settings=get(handles.OpenMenuItem,'UserData');

if isfield(Settings,'DBLocation') && ~isempty(Settings.DBLocation)
    FileFilter=Settings.DBLocation;
else
    FileFilter='*.mat';
end
[FName,FPath] = uiputfile(FileFilter,'Save data base ...');
if FName
    save(fullfile(FPath,FName),'Data');
    fprintf('%s\nSaved to: %s\n',datestr(now),fullfile(FPath,FName));
    
    Settings.DBLocation=fullfile(FPath,FName);
    set(handles.TDataExplorer,'Name',...
        sprintf('TDataExplorer - %s',fullfile(FPath,FName)));

    set(handles.OpenMenuItem,'UserData',Settings);
else
    beep;
end


% --------------------------------------------------------------------
function DB2Prompt_Callback(hObject, eventdata, handles)
Data=get(handles.TDataExplorer,'UserData');
assignin('base','DB',Data.DB);

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.TDataExplorer)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.TDataExplorer,'Name') '?'],...
                     ['Close ' get(handles.TDataExplorer,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.TDataExplorer)



% --- Executes on selection change in FilesBox.
function FilesBox_Callback(hObject, eventdata, handles)
% hObject    handle to FilesBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns FilesBox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from FilesBox

% SaveFig default extension
Data=get(handles.TDataExplorer,'UserData');
ListFiles = get(hObject,'String');
CurrFile= ListFiles{get(hObject,'Value')};
[Dummy1,Dummy2,FExt]=fileparts(CurrFile);
Data.CurrentFileType=FExt;
set(handles.TDataExplorer,'UserData',Data);

UpdateWidgets(handles);

% --- Executes during object creation, after setting all properties.
function FilesBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FilesBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Left.
function Left_Callback(hObject, eventdata, handles)
Data=get(handles.TDataExplorer,'UserData');
if isempty(Data.DB)
    UpdateWidgets(handles);
    return
end


InFilter=find((Data.Filter==Data.CurrRec));
if (InFilter && (InFilter>1))
    Data.CurrRec=Data.Filter(InFilter-1);
else
    Data.CurrRec=Data.CurrRec-1;
end

if Data.CurrRec < 1 
    Data.CurrRec=length(Data.DB);
    beep;
end
set(handles.TDataExplorer,'UserData',Data);
UpdateWidgets(handles);


% --- Executes on button press in right.
function right_Callback(hObject, eventdata, handles)
% hObject    handle to right (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Data=get(handles.TDataExplorer,'UserData');
if isempty(Data.DB)
    UpdateWidgets(handles);
    return
end

InFilter=find((Data.Filter==Data.CurrRec));
if (InFilter && (InFilter<length(Data.Filter)))
    Data.CurrRec=Data.Filter(InFilter+1);
else
    Data.CurrRec=Data.CurrRec+1;
end

if ((Data.CurrRec > length(Data.DB)) || ((Data.CurrRec > max(Data.Filter))) )
    Data.CurrRec=1;
    beep;
end

set(handles.TDataExplorer,'UserData',Data);
UpdateWidgets(handles);


% --- Executes on slider movement.
function RecSlider_Callback(hObject, eventdata, handles)
% hObject    handle to RecSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
Data=get(handles.TDataExplorer,'UserData');
Data.CurrRec=round(get(hObject,'Value'));
set(handles.TDataExplorer,'UserData',Data);
UpdateWidgets(handles);

function ScaleSlider(handles)
Data=get(handles.TDataExplorer,'UserData');
set(handles.RecSlider,'Min',1,...
    'Max',length(Data.DB),...
    'SliderStep',[0.05 0.2],...
    'Value',1);



% --- Executes during object creation, after setting all properties.
function RecSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RecSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in ShowResults.
function ShowResults_Callback(hObject, eventdata, handles)
% hObject    handle to ShowResults (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Data=get(handles.TDataExplorer,'UserData');
h=figure('Position',[100 300 520 630],'Tag','ResultPlot');
set(h,'UserData',Data.Data);
PlotFitResults('Figure',h);
set(handles.DeletePlots,'Enable','on');

% --- Executes on button press in DeletePlots.
function DeletePlots_Callback(hObject, eventdata, handles)
delete(findobj('tag','ResultPlot'));
set(hObject,'Enable','off');



% --------------------------------------------------------------------
function FilesBoxMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FilesBoxMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function EditData_Callback(hObject, eventdata, handles)
% hObject    handle to EditData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Data=get(handles.TDataExplorer,'UserData');
if isempty(Data.DB)
    beep
    return
end

FileName=fullfile(Data.DB(Data.CurrRec).Dir,...
    Data.DB(Data.CurrRec).Files{Data.CurrFile});
[FDir,BaseName,Ext]=fileparts(FileName);

JustView=strmatch(lower(Ext),...
    {'.mat','.htm','.hmtl','.doc','.fig','.exe','.pdf'});

if JustView
    ImportedMatFileData=open(FileName);
    fprintf('Opened %s !\n',FileName);
    if ~isempty(ImportedMatFileData)
        fprintf('Exported to Workspace\n');
        assignin('base','ImportedMatFileData',ImportedMatFileData);
        open('ImportedMatFileData');
    end
else
    edit(FileName);
end




% --------------------------------------------------------------------
function TPlotMenu_Callback(hObject, eventdata, handles)
% hObject    handle to TPlotMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function PlotInExtFig_Callback(hObject, eventdata, handles)

Data=get(handles.TDataExplorer,'UserData');
if isempty(Data.DB)
    beep
    return
end

FileName=fullfile(Data.DB(Data.CurrRec).Dir,...
    Data.DB(Data.CurrRec).Files{Data.CurrFile});

h=figure('Tag','TDataExplorer_Ext',...
    'Name',FileName);
nh=copyobj(handles.TPlot,h);

% Find axes overlays (DVTP) 
hAll=findobj(handles.TDataExplorer,'Type','axes');
ValidH=struct2cell(handles);
setdiff(hAll,[ValidH{:}])
nho=copyobj(setdiff(hAll,[ValidH{:}]),h)

set([nh nho(1)],'Position',[0.1300    0.1100    0.7750    0.8150]);
set(handles.DelExtFigs,'Enable','on');

% --------------------------------------------------------------------
function DelExtFigs_Callback(hObject, eventdata, handles)
delete(findobj('Tag','TDataExplorer_Ext')); %,'-and','Type','axes'
set(hObject,'Enable','off');




% --------------------------------------------------------------------
function TPlotMarkerOn_Callback(hObject, eventdata, handles)
Lines=findobj(handles.TPlot,'Type','line');
set(Lines,'Marker','.');

% --------------------------------------------------------------------
function TPlotMarkerOff_Callback(hObject, eventdata, handles)
Lines=findobj(handles.TPlot,'Type','line');
set(Lines,'Marker','none');



function FilterText_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of FilterText as text
%        str2double(get(hObject,'String')) returns contents of FilterText
%        as a double

UpdateWidgets(handles);

% --- Executes during object creation, after setting all properties.
function FilterText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FilterText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in FilterList.
function FilterList_Callback(hObject, eventdata, handles)
% Get filter from list and put it in filter line
FilterNo=get(hObject,'Value');
if (FilterNo>1)
    contents = get(hObject,'String');
    set(handles.FilterText,'String',contents{FilterNo});
else
    % Reset Filter
    Data=get(handles.TDataExplorer,'UserData');
    set(handles.FilterText,'String','');
    Data.Filter=[1:length(Data.DB)];
    set(handles.TDataExplorer,'UserData',Data);
%     UpdateWidgets(handles);
end
UpdateWidgets(handles);

% --- Executes during object creation, after setting all properties.
function FilterList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FilterList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function UnZoom_Callback(hObject, eventdata, handles)
set(handles.TPlot,...
    'XLimMode','auto',...
    'YLimMode','auto');

% --------------------------------------------------------------------
function StoreLimits_Callback(hObject, eventdata, handles)
Data=get(handles.TDataExplorer,'UserData');
CurrFile=get(handles.FilesBox,'Value');
Data.DB(Data.CurrRec).XLims{CurrFile}=get(handles.TPlot,'XLim');
Data.DB(Data.CurrRec).YLims{CurrFile}=get(handles.TPlot,'YLim');
zoom off;
set(handles.TDataExplorer,'UserData',Data);





% --------------------------------------------------------------------
function SendToTPFit_Callback(hObject, eventdata, handles)
Data=get(handles.TDataExplorer,'UserData');
if isempty(Data.DB)
    beep
    return
end

FileName=fullfile(Data.DB(Data.CurrRec).Dir,...
    Data.DB(Data.CurrRec).Files{Data.CurrFile});

% Take care of relative path
%if FileName(1)=='.'
AbsFileName=fullfile(pwd,FileName);
if exist(AbsFileName,'file')
    FileName=AbsFileName;
end
%end
%FileName
 
hTPFit=TPFit_Window;
handlesTPFit=guidata(hTPFit);
TPFit_Window('Load_Callback',handlesTPFit.Load,[],handlesTPFit,FileName);




% --- Executes on button press in BadData.
function BadData_Callback(hObject, eventdata, handles)
Data=get(handles.TDataExplorer,'UserData');
Data.DB(Data.CurrRec).BadData=get(hObject,'Value');
set(handles.TDataExplorer,'UserData',Data);
UpdateWidgets(handles);


% --- Executes on button press in ShowBadData.
function ShowBadData_Callback(hObject, eventdata, handles)
UpdateWidgets(handles);

% --- Executes on selection change in TagList.
function TagList_Callback(hObject, eventdata, handles)
    Data=get(handles.TDataExplorer,'UserData');
    Data.CurrentTag=get(hObject,'Value');
if ~get(handles.ShowTaggedOnly,'Value')
    % Tag the Record with the newly seleted Tag, 
    % but only if the "Show Tagged only" filter is not selected
    % Assume user wants to browse using tags    
    Data.DB(Data.CurrRec).Tags=...
        union(Data.DB(Data.CurrRec).Tags, Data.CurrentTag);
end
set(handles.TDataExplorer,'UserData',Data);
UpdateWidgets(handles);
uicontrol(handles.right);
%uicontrol(handles.TDataExplorer);

% --- Executes during object creation, after setting all properties.
function TagList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TagList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in TaggedData.
function TaggedData_Callback(hObject, eventdata, handles)
Data=get(handles.TDataExplorer,'UserData');
Tags=Data.DB(Data.CurrRec).Tags;
CurrentTag=get(handles.TagList,'Value');
if get(hObject,'Value')
    % Tag Data
    Tags=union(Tags,CurrentTag);
else
    % Untag Data
    Tags=setdiff(Tags,CurrentTag);
end
Data.DB(Data.CurrRec).Tags=Tags;
set(handles.TDataExplorer,'UserData',Data);
UpdateWidgets(handles);

% --- Executes on button press in ShowTaggedOnly.
function ShowTaggedOnly_Callback(hObject, eventdata, handles)
UpdateWidgets(handles);




%% -- Update Widgets --

function UpdateWidgets(handles)
Data=get(handles.TDataExplorer,'UserData');
if isempty(Data.DB)
    OpenMenuItem_Callback(handles.OpenMenuItem, [], handles);
    return
end

% check directory
if ~exist(Data.DB(Data.CurrRec).Dir,'dir')
    WhatsNext=...
        questdlg('Relocate?','Cannot find directory',...
        'Yes','No','Yes');
    if strcmp(WhatsNext,'Yes')
        Relocate_Callback(handles.Relocate, [], handles);
        Data=get(handles.TDataExplorer,'UserData');
    end
end

% Check for new files
MatchFiles=dir(fullfile(Data.DB(Data.CurrRec).Dir,...
    [Data.DB(Data.CurrRec).BaseName '*']));
MatchFiles={MatchFiles.name};
if isempty(MatchFiles)
    MatchFile='All files gone!!!';
    Data.CurrentFiles=1;
end
if ((length(MatchFiles)~= length(Data.DB(Data.CurrRec).Files)) || ...
        ~isempty(setdiff(MatchFiles,Data.DB(Data.CurrRec).Files)))
    Data.CurrentFiles=1;
    Data.DB(Data.CurrRec).Files=MatchFiles;
    % Kill saved limits :-(
    Data.DB(Data.CurrRec).XLims={};
    Data.DB(Data.CurrRec).YLims={};
    set(handles.TDataExplorer,'UserData',Data);
end

Data=RunFilter(handles);
Filter=Data.Filter;
% Checkbox filters
if ~get(handles.ShowBadData,'Value')
    % Hide Bad Data
    BadData=find([Data.DB.BadData]);
    Filter=setdiff(Filter,BadData);
end

if get(handles.ShowTaggedOnly,'Value')
    % Only show tagged data
    Filter=intersect(Filter,FindTag(Data.DB,Data.CurrentTag));
    % Filter=find([Data.DB.Interesting]);
end


% Set filter hist
NotInFilter=setdiff([1:length(Data.DB)],Filter);

if (length(Data.DB)>100)
    xout=linspace(1,length(Data.DB),100);
else
    xout=1:length(Data.DB);
end
nIn=hist(Filter,xout);
nOut=hist(NotInFilter,xout);
bar(handles.FilterHist,xout,[nIn;nOut]',1,'stacked','EdgeColor','none');
axis(handles.FilterHist,'tight');
set(handles.FilterHist,...
    'XLim',[1 length(Data.DB)],...
    'XTick',[],...
    'YTick',[],...
    'Visible','off',...
    'XColor','w',...
    'YColor','w');
hold(handles.FilterHist,'on');
HistYLim=get(handles.FilterHist,'YLim');
plot(handles.FilterHist,Data.CurrRec*[1 1],get(gca,'YLim'),...
    'w:','LineWidth',2);
plot(handles.FilterHist,Data.CurrRec,HistYLim(1),...
    'w^','MarkerFaceColor','w');
hold(handles.FilterHist,'off');

% Check Filter
if isempty(Filter)
    set(handles.CurRecTxt,'String','Nothing ToDo!!!');
    set(handles.FilesBox,'String','');
    cla(handles.TPlot);
    set(handles.TPlot,'Visible','off');
    return
end
set(handles.TPlot,'Visible','on');


% Check if current record is in filter
[Dummy,BestRec]=min(abs(Filter-Data.CurrRec));
Data.CurrRec=Filter(BestRec);

CurrFile=get(handles.FilesBox,'Value');
if (CurrFile > length(Data.DB(Data.CurrRec).Files))
    CurrFile=length(Data.DB(Data.CurrRec).Files);
    set(handles.FilesBox,'Value',CurrFile);
end
Data.CurrFile=CurrFile;
set(handles.FilesBox,'String',Data.DB(Data.CurrRec).Files);
set(handles.CurrDirTxt,'String',Data.DB(Data.CurrRec).Dir);

% Delete old axes
h=findobj(gcf,'Type','axes'); % Delete old DVTP axes
ValidH=struct2cell(handles);
delete(setdiff(h,[ValidH{:}]));

axes(handles.TPlot);
set(gca,'XLimMode','auto','YLimMode','auto');

% Stay with one type of file
if isfield(Data,'CurrentFileType')
    for i=1:length(Data.DB(Data.CurrRec).Files)
        [Dummy1,Dummy2,FExt]=fileparts(Data.DB(Data.CurrRec).Files{i});
        if strcmpi(FExt,Data.CurrentFileType)
            Data.CurrentFile=i;
            set(handles.FilesBox,'Value',i);
            break
        end
    end
end

Data.Data=ImportTemperatureData(fullfile(Data.DB(Data.CurrRec).Dir,...
    Data.DB(Data.CurrRec).Files{CurrFile}),'DoPlot',true);

if (isfield(Data.DB(Data.CurrRec),'XLims') &&...
        (CurrFile<=length(Data.DB(Data.CurrRec).XLims)) && ...
        ~isempty(Data.DB(Data.CurrRec).XLims{CurrFile}));
    
    set(handles.TPlot,...
        'XLim',Data.DB(Data.CurrRec).XLims{CurrFile},...
        'YLim',Data.DB(Data.CurrRec).YLims{CurrFile});
end

% Take a (Info) structure and dumps it into the toolstring of the FilesBox
set(handles.FilesBox,'TooltipString',Struct2Str(Data.DB(Data.CurrRec).Info));

% Show Comment as tool tip
CommentLines=cellstr(Data.DB(Data.CurrRec).Info.Comment);
if ~isempty(CommentLines)
    if (length(CommentLines)>1)
        for i=1:length(CommentLines)
            CommentLines{i}=sprintf('%s\n',CommentLines{i});
        end
    elseif isempty(CommentLines{1})
        CommentLines{1}='No Comment';
    end
else
    CommentLines{1}='No Comment';
end
set(handles.UsedTags,'TooltipString',...
    sprintf([CommentLines{:}]));



% Copy tags from Data to GUI
set(handles.BadData,'Value',(Data.DB(Data.CurrRec).BadData && 1));
Tags=Data.DB(Data.CurrRec).Tags;
if isempty(intersect(Data.CurrentTag,Tags))
    set(handles.TaggedData,'Value',false);
else
    set(handles.TaggedData,'Value',true);
end

if isempty(Tags)
    set(handles.UsedTags,'String',{'Hit space to tag'});
else
    TagNames=get(handles.TagList,'String');
    set(handles.UsedTags,'String',TagNames(Tags));
end
    
%set(handles.TagList,'Value',Data.DB(Data.CurrRec).Tags);


if isfield(Data.Data,'Res')
    set(handles.ShowResults,'Enable','on');
else
%    set(handles.ShowResults,'Enable','inactive');
    set(handles.ShowResults,'Enable','off');
end


set(handles.CurRecTxt,'String',sprintf('Record: %d/%d',Data.CurrRec,length(Data.DB)));
set(handles.RecSlider,'Value',Data.CurrRec);
Data.Filter=Filter;
set(handles.TDataExplorer,'UserData',Data);





%% ---- Helper Funtions ----
%% Filters
function Data=RunFilter(handles)
Data=get(handles.TDataExplorer,'UserData');
FilterStr=get(handles.FilterText,'String');
if isempty(FilterStr)
    Data.Filter=[1:length(Data.DB)];
else
    DB=Data.DB;
    try
        NewFilter=eval(FilterStr);
        if ~ischar(NewFilter)
            Data.Filter=NewFilter;
        else
            % Reload Data that might has changed by "Filter"
            Data=get(handles.TDataExplorer,'UserData');
        end
    catch
        % Error in filter command
        ErrorStruct=lasterror;
        fprintf('\nExecuted: %s\n',FilterStr);
        fprintf('Error in filter!!!\n%s\n',ErrorStruct.message);
        beep;
    end
end


function Found=FindTag(DB,TagIdxs)
% Find records that contain any of the TagIdxs
Found=zeros(size(DB));
for i=1:length(DB)
    if ~isempty(intersect(DB(i).Tags,TagIdxs))
        Found(i)=true;
    end
end

Found=find(Found);

function Found=FindInfo(DB,Field,Content)
% Find records with the following Info field
Found=zeros(size(DB));
for i=1:length(DB)
    if (isfield(DB(i).Info,Field) && strcmpi(DB(i).Info.(Field),Content))
        Found(i)=true;
    end
end

Found=find(Found);

function Found=FindCopies(DB)
% Find records which have the same BaseName
[SBaseNames,SIdx]=sort({DB.BaseName});

Found=zeros(size(DB));
for i=2:length(DB)
    if strcmpi(SBaseNames(i-1),SBaseNames(i));
        Found(i-1)=true;
        Found(i)=true;
    end
end

Found=SIdx(find(Found));
%DB(Found).BaseName

% Sort and savefig the rest
DB=DB(Found);
[SBaseNames,SIdx]=sort({DB.BaseName});
DB=DB(SIdx);
save('CopiesOnlySorted.mat','DB');

function Out=DeleteBadData(handles)
Out='No Filter';
set(handles.FilterText,'String','');
if ~strcmp(questdlg({'This cannot be undone!', 'Proceed?'},...
        'Delete Bad Records','No'),'Yes')
    return
end
Data=get(handles.TDataExplorer,'UserData');
DB=Data.DB;
BadRecs=find([DB.BadData])
DB(BadRecs)=[];
Data.DB=DB;
Data.CurrRec=1;
set(handles.TDataExplorer,'UserData',Data);


function Out=TagUploadBad(handles)
Out='No Filter';
set(handles.FilterText,'String','');
if ~strcmp(questdlg({'This cannot be undone!', 'Proceed?'},...
        'Tag upload files bad','Yes'),'Yes')
    return
end

Data=get(handles.TDataExplorer,'UserData');
DB=Data.DB;
IsCopy=FindCopies(DB);
for i=1:length(DB)
    if (~isempty(findstr(lower(DB(i).Dir),'upload')) && ...
            (length(DB(i).Files)==1) && ~isempty(intersect(i,IsCopy)))
        DB(i).BadData=true;
    end
end
Data.DB=DB;
set(handles.TDataExplorer,'UserData',Data);


%% Misc
function NotImplemented(hObj)
if ~exist('hObj','var')
    Tag='????';
else
    Tag=get(hObj,'Tag');
end
msgbox(sprintf('%s is not implemented!',Tag),'warn');

%% ------ New Guide Stuff -----------

% --------------------------------------------------------------------
function Import2Prompt_Callback(hObject, eventdata, handles)
Data=get(handles.TDataExplorer,'UserData');
if isempty(Data.DB)
    beep
    return
end

FileName=fullfile(Data.DB(Data.CurrRec).Dir,...
    Data.DB(Data.CurrRec).Files{Data.CurrFile});
Data=ImportTemperatureData(FileName);
assignin('base','Data',Data);
fprintf('Imported %s as Data!\n',FileName);



% --- Executes on selection change in ToolFilterMenu.
function ToolFilterMenu_Callback(hObject, eventdata, handles)
% hObject    handle to ToolFilterMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns ToolFilterMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ToolFilterMenu
NotImplemented(hObject);

% --- Executes during object creation, after setting all properties.
function ToolFilterMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ToolFilterMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --------------------------------------------------------------------
function DelFigsSubmenu_Callback(hObject, eventdata, handles)
% hObject    handle to DelFigsSubmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function DebugSubMenu_Callback(hObject, eventdata, handles)
% hObject    handle to DebugSubMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function HandlesToPrompt_Callback(hObject, eventdata, handles)
handles
assignin('base','handles',handles);
Data=get(handles.TDataExplorer,'UserData');
Data
assignin('base','Data',Data);

% --- Executes when user attempts to close TDataExplorer.
function TDataExplorer_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to TDataExplorer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(questdlg('Do you really want to quit?'),'Yes')
    delete(hObject);
end




% --------------------------------------------------------------------
function EditMetaData_Callback(hObject, eventdata, handles)
Data=get(handles.TDataExplorer,'UserData');
[Data.DB(Data.CurrRec).Info,Data.DB(Data.CurrRec).ModelType]=...
                  EditMetaData(Data.DB(Data.CurrRec).Info,...
                                  'ModelType',Data.DB(Data.CurrRec).ModelType);
set(handles.TDataExplorer,'UserData',Data);
UpdateWidgets(handles);

% % Edit comment
% function UsedTags_ButtonDownFcn(hObject, eventdata, handles)
% Data=get(handles.TDataExplorer,'UserData');
% Data.DB(Data.CurrRec).Info=EditMetaData(Data.DB(Data.CurrRec).Info);
% set(handles.TDataExplorer,'UserData',Data);
% UpdateWidgets(handles);


% --- Executes on key press over TDataExplorer with no controls selected.
function TDataExplorer_KeyHandler(hObject, event)
% hObject    handle to TDataExplorer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=guidata(hObject);
Data=get(handles.TDataExplorer,'UserData');
%event.Key

switch event.Key
    case 'leftarrow'
        Left_Callback(handles.Left, [], handles);
    case 'rightarrow'
        right_Callback(handles.right, [], handles);
    case 'b'
        NewState=~get(handles.BadData,'Value');
        set(handles.BadData,'Value',NewState);
        BadData_Callback(handles.BadData, [], handles);
        if NewState
            fprintf('BadData: %d - %s\n',...
                Data.CurrRec,Data.DB(Data.CurrRec).BaseName);
        else
            fprintf('GoodData: %d - %s\n',...
                Data.CurrRec,Data.DB(Data.CurrRec).BaseName);
        end
        beep;
    case 'space'
        NewState=~get(handles.TaggedData,'Value');
        set(handles.TaggedData,'Value',NewState);
        TaggedData_Callback(handles.TaggedData, [], handles); % Leave Tag alo 
    case 'z'
        zoom;
        figure(handles.TDataExplorer);
        %set(handles.TDataExplorer,'KeyPressFcn',@TDataExplorer_KeyHandler)    
    case 's'
        StoreLimits_Callback(handles.StoreLimits, [], handles);
end
%uicontrol(handles.right);


% --------------------------------------------------------------------
function TagMenu_Callback(hObject, eventdata, handles)
% hObject    handle to TagMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function EditTagName_Callback(hObject, eventdata, handles)
TagNum=get(handles.TagList,'Value');
TagStr=get(handles.TagList,'String');
TagStr(TagNum)=inputdlg('New Tag Name:','Rename Tag ...',1,TagStr(TagNum));
set(handles.TagList,'String',TagStr);

Data=get(handles.TDataExplorer,'UserData');
Data.TagNames=TagStr;
set(handles.TDataExplorer,'UserData',Data);

% --------------------------------------------------------------------
function ShowTagList_Callback(hObject, eventdata, handles)
Data=get(handles.TDataExplorer,'UserData');
InTag=FindTag(Data.DB,Data.CurrentTag);
TagNames=get(handles.TagList,'String');
% inputdlg('Changes are rejected...','Records in current tag',1,...
%     cellstr(num2str(InTag)));
fprintf('%s:\n[',TagNames{Data.CurrentTag});
fprintf('%d ',InTag);
fprintf(']\n');
for i=1:length(InTag)
    fprintf('%4d: %s %s\n',InTag(i),Data.DB(i).BaseName,Data.DB(i).Dir);
end


% --------------------------------------------------------------------
function CurrSelToTag_Callback(hObject, eventdata, handles)
% hObject    handle to CurrSelToTag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
NotImplemented(hObject);



% --------------------------------------------------------------------
function Relocate_Callback(hObject, eventdata, handles)
% hObject    handle to Relocate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Data=get(handles.TDataExplorer,'UserData');
WhatsNext=...
    questdlg('Relocate?','Cannot find directory',...
    'Record','Database','Cancel','Database');
switch WhatsNext
    case 'Record'
        Data=RelocateDB(Data,'Records',Data.CurrRec);
        set(handles.TDataExplorer,'UserData',Data);
    case 'Database'
        Data=RelocateDB(Data,...
            'Records',[1:length(Data.DB)],...
            'StartRec',1); %Data.CurrRec
        set(handles.TDataExplorer,'UserData',Data);
end

set(handles.TDataExplorer,'UserData',Data);


% --------------------------------------------------------------------
function AddTag_Callback(hObject, eventdata, handles)
TagStr=get(handles.TagList,'String');
N=length(TagStr)+1;
TagStr(N)=inputdlg('New Tag Name:','Rename Tag ...',1,{'New Tag'});
set(handles.TagList,'String',TagStr,'Value',N);

Data=get(handles.TDataExplorer,'UserData');
Data.TagNames=TagStr;
set(handles.TDataExplorer,'UserData',Data);




% --------------------------------------------------------------------
function RemoveRec_Callback(hObject, eventdata, handles)
Data=get(handles.TDataExplorer,'UserData');
Data.DB(Data.CurrRec)=[];
set(handles.TDataExplorer,'UserData',Data);
UpdateWidgets(handles);




% --------------------------------------------------------------------
function SaveFig_Callback(hObject, eventdata, handles)
% hObject    handle to SaveFig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
NotImplemented(hObject);




% --------------------------------------------------------------------
function EditMetaData_Tag_Callback(hObject, eventdata, handles)
% hObject    handle to EditMetaData_Tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
EditMetaData_Callback(hObject, [], handles)

