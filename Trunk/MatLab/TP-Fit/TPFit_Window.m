function varargout = TPFit_Window(varargin)
% T3FIT_WINDOW M-file for TPFit_Window.fig
%      T3FIT_WINDOW, by itself, creates a new T3FIT_WINDOW or raises the existing
%      singleton*.
%
%      H = T3FIT_WINDOW returns the handle to a new T3FIT_WINDOW or the handle to
%      the existing singleton*.
%
%      T3FIT_WINDOW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in T3FIT_WINDOW.M with the given input arguments.
%
%      T3FIT_WINDOW('Property','Value',...) creates a new T3FIT_WINDOW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TPFit_Window_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TPFit_Window_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help TPFit_Window

% Last Modified by GUIDE v2.5 08-Dec-2006 06:11:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @TPFit_Window_OpeningFcn, ...
    'gui_OutputFcn',  @TPFit_Window_OutputFcn, ...
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


% --- Executes just before TPFit_Window is made visible.
function TPFit_Window_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TPFit_Window (see VARARGIN)

% Choose default command line output for TPFit_Window
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes TPFit_Window wait for user response (see UIRESUME)
% uiwait(handles.figure1);

Settings=LoadUserSettings(handles);
Pos=get(handles.TPFit,'Position');
if isfield(Settings,'WinPos')
    Pos(1:2)=Settings.WinPos.TPFit(1:2);
    set(handles.TPFit,'Position',Pos);
else
    Settings.WinPos.TPFit=get(handles.TPFit,'Position');
    Settings.WinPaperPos=[];
    set(handles.Load,'UserData',Settings);
end

function TPFit_Window_DeleteFcn(hObject, eventdata, handles)
if strcmp(questdlg('Save Session before quitting?!','','Yes','No','Yes'),'Yes')
    Save_Callback(hObject, eventdata, handles)
end
disp('Have a nice day!!!');


% --- Outputs from this function are returned to the command line.
function varargout = TPFit_Window_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Load.
function Load_Callback(hObject, eventdata, handles,FileName)
% hObject    handle to Load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Settings=get(handles.Load,'UserData');
if exist('FileName','var')
    [Data, FileName]=ImportTemperatureData(FileName);
else
    [Data, FileName]=ImportTemperatureData('StartDir',Settings.DataDir);
    %,... 'DefaultInfo',Settings.Info
end

if (isstruct(Data) && ~isempty(Data))
    Settings.CurrentFile=FileName;
    
    if ~isfield(Data,'Info')
        Settings.Info;
        Data=GuessMetaData(Data,'Info',Settings.Info);
        %Data.Info;
    end

    TPFitInfo=TPFit_VersionInfo;
    fprintf('\n====== TP-Fit Version %g ======\n',TPFitInfo.Version);
    if ~isfield(Data,'TPFitInfo')
        % New data -> Add TPFitInfo
        Data.TPFitInfo=TPFitInfo;
    else
        % Data was allready processed by TP-Fit
        if isequal(TPFitInfo,Data.TPFitInfo)
            fprintf('Data was allready processed with this version of TP-Fit\n');
            %structree(TPFitInfo);
        else
            warndlg({'Version mismatch detected !!!';...
                'See prompt for details'});
            fprintf('Data was processed with TP-Fit version:\n');
            structree(Data.TPFitInfo);
            fprintf('Your version is:\n');
            structree(TPFitInfo);
            fprintf('Version info will be "updated" to your version!!!!!\n');
            Data.TPFitInfo=TPFitInfo;
        end
    end


    set(handles.TPFit,'UserData',Data);
    UpdateButtonColors(handles);

    Settings.DataDir=Data.ImportInfo.DatPath;
    SaveUserSettings(handles,Settings);
    CloseExtWindows(handles);
end

function EditMetaData_Callback(hObject, eventdata, handles)
Data=get(handles.TPFit,'UserData');
Settings=get(handles.Load,'UserData');

if isempty(Data)
    msgbox('Load data first!!!','','warn');
    return
end
if isfield(Data,'Info')
    %     if ~isfield(Data.Info,'Core')
    %         Data=GuessMetaData(Data);
    %     end
    Data.Info=EditMetaData(Data.Info);
else
    Data.Info=EditMetaData;
end

if isfield(Data,'Picks')
    % Ensure Fit is updated if Metadata is changed afterwards
    [Res,Data]=MakeFit(Data,str2num(Data.Info.Initial_k),str2num(Data.Info.Initial_rC));
end

set(handles.TPFit,'UserData',Data);
Settings.Info=Data.Info;
SaveUserSettings(handles,Settings);

UpdateButtonColors(handles);


% --- Executes on button press in Pick.
function Pick_Callback(hObject, eventdata, handles)
% hObject    handle to Pick (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Data=get(handles.TPFit,'UserData');
Data=GetPicks(Data);

% Make sure no old results are used!!!
if isfield(Data,'Res')
    Data=rmfield(Data,'Res');
end

set(handles.TPFit,'UserData',Data);
UpdateButtonColors(handles);


% --- Executes on button press in Fit.
function Fit_Callback(hObject, eventdata, handles)
% hObject    handle to Fit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Data=get(handles.TPFit,'UserData');
OpenExtWindow(handles,'Results');
clf;
%set(gcf,...
%    'Position',[5 82 773 899],...   [5 381 1000 600],...
%    'PaperPosition',[0.6345 0.6345 19.7150 28.4084]); %[0.6 3.3 28.4 17]

if ~isfield(Data,'Res')
    [Res,Data]=MakeFit(Data,str2num(Data.Info.Initial_k),str2num(Data.Info.Initial_rC));
end
PlotFitResults(Data,'hTPFit',handles.TPFit);
set(handles.TPFit,'UserData',Data);
figure(handles.TPFit);

% --- Executes on button press in contours.
function contours_Callback(hObject, eventdata, handles)
% hObject    handle to contours (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Data=get(handles.TPFit,'UserData');
Data=MakeContourInfo(Data);
set(handles.TPFit,'UserData',Data);
UpdateButtonColors(handles);

% --- Executes on button press in Explore.
function Explore_Callback(hObject, eventdata, handles)
% hObject    handle to Explore (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Data=get(handles.TPFit,'UserData');
hResults=OpenExtWindow(handles,'Results');
clf;
%set(gcf,'Position',[5 381 1000 600]);
OpenExtWindow(handles,'Contours');
clf;
%set(gcf,'Position',[1014 183 376 799]);

if isfield(Data,'Contour')
    PlotContours(Data,'hResults',hResults,'hTPFit',handles.TPFit);
else
    ExploreNoConts(Data,'hResults',hResults,'hTPFit',handles.TPFit);
    %set(gcf,'Position',[1019 690 369 296]);
    %axes('XLim',[0.5 2.5],'YLim',[2.3 4.3]);
    %grid on;
    %ylabel('Heat capacity (MJ/(m³K))');
    %xlabel('Thermal conductivity (W/(m K))');
end

% KeepGoing=true;
% while KeepGoing
%     [k,rc,botton]=ginput(1);
%     if botton==1
%         hold on
%         plot(k,rc,'ko','MarkerFaceColor',[1 1 1]);
%         hold off
%         figure(1)
%         [Res,Data]=MakeFit(Data,k,rc*1e6);
%         PlotFitResults(Data);
%         figure(2);
%     else
%         KeepGoing=false;
%     end
% end
% set(handles.TPFit,'UserData',Data);
% figure(handles.TPFit);

% --- Executes on button press in Save.
function Save_Callback(hObject, eventdata, handles)
% hObject    handle to Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Data=get(handles.TPFit,'UserData');
Settings=get(handles.Load,'UserData');
SaveSession(Data,Settings.CurrentFile);
%handles

function Report_Callback(hObject, eventdata, handles)
Data=get(handles.TPFit,'UserData');
Settings=get(handles.Load,'UserData');

[RPath,RBase]=fileparts(Settings.CurrentFile);
FileBase=fullfile(RPath,RBase);

TimeStampStr=sprintf('TP-Fit V%g: %s processed by %s   ',...
    Data.TPFitInfo.Version,Data.ImportInfo.DatFile, Data.Info.Operator);

MakeReport(Data,[FileBase '_Report.txt']);
%get(gcf)
h=OpenExtWindow(handles,'Results');
hStmp=PlaceTimeStamp('PreStr',TimeStampStr);
%set(0,'CurrentFigure',h);figure(h);pause(2);
%drawnow;
%get(gcf,'Name')
%gcf
print('-f63001','-depsc','-painters',...  ,'-adobecset'
    [FileBase '_Result.eps']);

print('-f63001','-dpng','-r300',...  ,'-adobecset'
    [FileBase '_Result.png']);

delete(hStmp);

h=OpenExtWindow(handles,'Contours');
hStmp=PlaceTimeStamp('PreStr',TimeStampStr);
%set(0,'CurrentFigure',h);figure(h);pause(2);
%set(gcf,'Selected','on')
%get(gcf,'Name')
%get(gcf,'Selected')
%gcf
print('-f63002','-depsc','-painters',...  ,'-adobecset'
    [FileBase '_Contours.eps']);

print('-f63002','-dpng','-r300',...  ,'-adobecset'
    [FileBase '_Contours.png']);

delete(hStmp);


function Extras_Callback(hObject, eventdata, handles)
Extra=menu('Make a Choice',...
    'Data -> Workspace',...
    'WorkSpace -> Data',...
    'Screen dump',...
    'Application Info',...
    'Comment Window',...
    'Save Window Positions',...
    'Launch Help');


switch Extra
    case 1
        % Data -> Workspace
        disp('Exported "Data" to Workspace');
        Data=get(handles.TPFit,'UserData')
        assignin('base','Data',Data);
    case 2
        % WorkSpace -> Data
        if evalin('base','exist(''Data'',''var'')')
            Data=evalin('base','Data');
            set(handles.TPFit,'UserData',Data);
        else
            disp('Sorry not "Data" Structure in Workspace!!!');
        end
    case 3
        % Screen Dump
        Data=get(handles.TPFit,'UserData');
        structree(Data);
    case 4
        % Show Application info
        handles
        AppData=get(handles.Quit,'UserData')
        assignin('base','AppData',AppData);
        Settings=get(handles.Load,'UserData')
        assignin('base','Settings',Settings);

    case 5
        % Show Comment Window
        h=OpenExtWindow(handles,'Comment')

    case 6
        SaveWindowPositions(handles)
    case 7
        % Launch Version Info
        ShowTPFitHelp;
end


function Quit_Callback(hObject, eventdata, handles)
CloseExtWindows(handles);
close(handles.TPFit);

%
% Local functions
%

function AppData=InitializeAppData(handles)
% Initialze Application data that is only used during run time and store it
% in the "Quit" button

hWins.TPFit=handles.TPFit;
hWins.Results=[];
hWins.Contours=[];
hWins.Pick=[];
hWins.Comment=[];
AppData.hWins=hWins;
set(handles.Quit,'UserData',AppData);

%% OpenExtWindow
function h=OpenExtWindow(handles,WTitle)
% Manages the external windows

AppData=get(handles.Quit,'UserData');
if isempty(AppData)
    AppData=InitializeAppData(handles);
end
hWins=AppData.hWins;

Settings=get(handles.Load,'UserData');
WinPos=Settings.WinPos;
WinPaperPos=Settings.WinPaperPos;

if isfield(hWins,WTitle)
    if ishandle(hWins.(WTitle))
        % Activate existing window
        figure(hWins.(WTitle));
    else
        % Create new Window
        switch WTitle
            case 'Results'
                hWins.Results=figure(63001);
                set(63001,'Name',WTitle,'NumberTitle','off');
                
                % Set Paper Defaults
                set(63001,...
                    'PaperType','A4','PaperUnits','centimeters',...
                    'PaperOrientation','portrait',...
                    'PaperPosition',[1 1 [20.984 29.6774]-1]);
                
            case 'Contours'
                hWins.Contours=figure(63002);
                set(63002,'Name',WTitle,'NumberTitle','off');
                
                % Set Paper Defaults
                set(63002,...
                    'PaperType','A4','PaperUnits','centimeters',...
                    'PaperOrientation','portrait',...
                    'PaperPosition',[1 1 [20.984 29.6774]-1]);
                
            otherwise
                hWins.(WTitle)=figure('IntegerHandle','on',...
                    'Name',WTitle,'NumberTitle','off');
        end
        % Position new Window
        if isfield(WinPos,WTitle)
            set(hWins.(WTitle),'Position',WinPos.(WTitle));
            set(hWins.(WTitle),'PaperPosition',WinPaperPos.(WTitle));
        end
    end
    h=hWins.(WTitle);
else
    warning([WTitle ' Window is not yet supported!!!']);
end

AppData.hWins=hWins;
set(handles.Quit,'UserData',AppData);

function CloseExtWindows(handles)
% Close Windows
AppData=get(handles.Quit,'UserData');
if ~isempty(AppData)
    hWins=struct2cell(AppData.hWins);
    hWins=[hWins{:}];
    close(hWins(find( ishandle(hWins) & ~(hWins == handles.TPFit))));
end


function SaveWindowPositions(handles)
% Store positions (and PaperPosition) of open windows
AppData=get(handles.Quit,'UserData');
if isempty(AppData)
    AppData=InitializeAppData(handles);
end
hWins=AppData.hWins;

Settings=get(handles.Load,'UserData');
WinPos=Settings.WinPos;
WinPaperPos=Settings.WinPaperPos;

WNames=fieldnames(hWins);
WHs=struct2cell(hWins);
for i=1:length(WHs)
    if ishandle(WHs{i})
        WinPos.(WNames{i})=get(WHs{i},'Position');
        WinPaperPos.(WNames{i})=get(WHs{i},'PaperPosition');
    end
end
WinPos
WinPaperPos
Settings.WinPos=WinPos;
Settings.WinPaperPos=WinPaperPos;
SaveUserSettings(handles,Settings)

function Settings=LoadUserSettings(handles)
SPath=fileparts(which('TPFit_Window.m'));
SFile=[SPath filesep 'UserSettings.mat'];
if ~exist(SFile,'file')
    % Create Default user settings
    Settings.DataDir='';
    Settings.ScreenSize=get(0,'ScreenSize');
    Settings.Info=GetMetaDataDefaults;
    disp(['Created: ' SFile]);
    save(SFile,'Settings');
end
load(SFile);
disp(['Loaded: ' SFile]);

ScreenSize=get(0,'ScreenSize');
if any(ScreenSize<Settings.ScreenSize)
    warndlg('Default settings for small screens are use!!!')
    load(which('UserSettingsSmallScreen.mat'));
end

% Store settings in Load-Button ;-)
set(handles.Load,'UserData',Settings);

function SaveUserSettings(handles,Settings)
if ~exist('Settings','var')
    Settings=get(handles.Load,'UserData');
else
    set(handles.Load,'UserData',Settings);
end
SPath=fileparts(which('TPFit_Window.m'));
SFile=[SPath filesep 'UserSettings.mat'];
save(SFile,'Settings');

function UpdateButtonColors(handles)
gray=[0.8314 0.8157 0.7843];
green=[0.8314 1 0.7843];

Colors.Load=gray;
Colors.EditMetaData=gray;
Colors.Pick=gray;
Colors.Fit=gray;
Colors.contours=gray;
Colors.Explore=gray;
Colors.Save=gray;
Colors.Report=gray;
Colors.Quit=gray;

Data=get(handles.TPFit,'UserData');

if isfield(Data,'ImportInfo')
    Colors.Load=green;
end

if isfield(Data,'Info')
    Colors.EditMetaData=green;
end

if isfield(Data,'Picks')
    Colors.Pick=green;
end

if isfield(Data,'Contour')
    Colors.contours=green;
end

FNames=fieldnames(Colors);
CData=struct2cell(Colors);

for i=1:length(FNames)
    set(handles.(FNames{i}),'BackGroundColor',CData{i});
end

function ReportResults(hObject, eventdata, handles,Res,hTPFit)
% Take Results from Contour Explorer
Data=get(hTPFit,'UserData');
Data.Res=Res;
set(hTPFit,'UserData',Data);