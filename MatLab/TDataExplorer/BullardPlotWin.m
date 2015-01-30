function varargout = BullardPlotWin(varargin)
% BULLARDPLOTWIN M-file for BullardPlotWin.fig
%      BULLARDPLOTWIN, by itself, creates a new BULLARDPLOTWIN or raises the existing
%      singleton*.
%
%      H = BULLARDPLOTWIN returns the handle to a new BULLARDPLOTWIN or the handle to
%      the existing singleton*.
%
%      BULLARDPLOTWIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BULLARDPLOTWIN.M with the given input arguments.
%
%      BULLARDPLOTWIN('Property','Value',...) creates a new BULLARDPLOTWIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BullardPlotWin_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BullardPlotWin_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help BullardPlotWin

% Last Modified by GUIDE v2.5 02-Oct-2007 16:48:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @BullardPlotWin_OpeningFcn, ...
                   'gui_OutputFcn',  @BullardPlotWin_OutputFcn, ...
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


% --- Executes just before BullardPlotWin is made visible.
function BullardPlotWin_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BullardPlotWin (see VARARGIN)

% Choose default command line output for BullardPlotWin

%Opts.OpenBaseName='d:\home\martin\TODP\TTool_Database\APCT\168\1028\1028_USIO_'
Opts.OpenBaseName=''
Opts=ParseFunOpts(Opts,varargin)

handles.output = hObject;
handles.TDat=[];
handles.kDat=[];

% Update handles structure
guidata(hObject, handles);

if ~isempty(Opts.OpenBaseName)
    AddUSIOTemperatures_Callback(hObject, eventdata, handles,...
        [Opts.OpenBaseName 'adara.html']);
    AddUSIO_tcondat_Callback(hObject, eventdata, handles,...
        [Opts.OpenBaseName 'tcondat.html'])
end

% UIWAIT makes BullardPlotWin wait for user response (see UIRESUME)
% uiwait(handles.BullardPlotWin);


% --- Outputs from this function are returned to the command line.
function varargout = BullardPlotWin_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function SaveBullard_Callback(hObject, eventdata, handles)
% hObject    handle to SaveBullard (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
saveas(gcf,[handles.TDat(1).Site '_BullardPlot.fig']);

% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenBullard_Callback(hObject, eventdata, handles)
% hObject    handle to OpenBullard (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on mouse press over axes background.
function TPlot_ButtonDownFcn(hObject, eventdata, handles)
UpdatePlots(handles);

function TSymbol_ButtonDownFcn(hObject, eventdata, handles)
if strcmp(get(gcf,'SelectionType'),'open')
    n=get(hObject,'UserData');
    EditTemperature(handles,n);
end

function BullSymbol_ButtonDownFcn(hObject, eventdata, handles)
if strcmp(get(gcf,'SelectionType'),'open')
    n=get(hObject,'UserData'); % get Index of measurement
    handles.TDat(n).InBullardFit=~handles.TDat(n).InBullardFit;
    guidata(handles.BullardPlotWin,handles);
    UpdatePlots(handles);
end


% --------------------------------------------------------------------
function AddData_Callback(hObject, eventdata, handles)
% hObject    handle to AddData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function ClearTemperatures_Callback(hObject, eventdata, handles)
handles.TDat=[];
cla(handles.TDiffPlot);
cla(handles.BullardPlot);
cla(handles.LegendPlot);
cla(handles.kPlot);
handles.kDat=[];

legend(handles.LegendPlot,'off');

guidata(handles.BullardPlot, handles);
UpdatePlots(handles);
assignin('base','handles',handles);

% --------------------------------------------------------------------
function AddSingleTemperature_Callback(hObject, eventdata, handles)
% hObject    handle to AddSingleTemperature (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

NewT=handles.TDat(end);
NewT.T=num2str(NewT.T);
NewT.z=num2str(NewT.z);
NewT.InBullardFit=num2str(NewT.InBullardFit);
Fields=fieldnames(NewT);
NewAns=inputdlg(Fields,'Edit new data',1,struct2cell(NewT));
for i=1:length(Fields)
    NewT.(Fields{i})=NewAns{i};
end
NewT.T=str2double(NewT.T);
NewT.z=str2double(NewT.z);
NewT.InBullardFit=str2double(NewT.InBullardFit);
handles.TDat=[handles.TDat NewT];
guidata(hObject,handles);

% --------------------------------------------------------------------
function AddUSIOTemperatures_Callback(hObject, eventdata, handles, FullFileName)

if ~exist('FullFileName','var')
    [FileName,FileDir]=uigetfile('*adara.html','Select Temperature Data',...
        'd:\home\martin\TODP\TTool_Database\APCT\168\1023\1023_USIO_adara.html')
    FullFileName=fullfile(FileDir,FileName);
    DoUpdate=true;
else
    handles=guidata(hObject);
    DoUpdate=false;
end

Data=ImportUSIO_HTMLQuery(FullFileName,'Type','adara');

for i=1:length(Data.T)
    TDat(i).T=Data.T(i);
    TDat(i).z=Data.z(i);
    TDat(i).ToolName=Data.ToolName{i};
    TDat(i).Leg=Data.Leg{i};
    TDat(i).Site=Data.Site{i};
    TDat(i).Hole=Data.Hole{i};
    TDat(i).Core=Data.Core{i};
    TDat(i).CoreType=Data.CoreType{i};
    TDat(i).InBullardFit=1;
end
TDat
handles.TDat=[handles.TDat TDat];

guidata(handles.BullardPlotWin, handles);

if DoUpdate
    UpdatePlots(handles);
end

% --------------------------------------------------------------------
function AddUSIO_tcondat_Callback(hObject, eventdata, handles,FullFileName)
if ~exist('FullFileName','var')
    [FileName,FileDir]=uigetfile('*tcondat.html','Select Temperature Data',...
        'd:\home\martin\TODP\TTool_Database\APCT\168\1023\1023_USIO_tcondat.html')
    FullFileName=fullfile(FileDir,FileName);
else
    handles=guidata(hObject);
end
Data=ImportUSIO_HTMLQuery(FullFileName,'Type','tcondat')
[Data.z,UIdx]=unique(Data.z);
Data.k=Data.k(UIdx);
kGood=find(isfinite(Data.k)&isfinite(Data.z));
Data.k=Data.k(kGood);
Data.z=Data.z(kGood);

Data.R=cumtrapz(Data.z,Data.k);
handles.kDat=Data;
guidata(handles.BullardPlotWin, handles);

UpdatePlots(handles);


%% UpdatePlots
function UpdatePlots(handles)

AxesProps={'Box','on','TickDir','out',...
    'XMinorTick','on','YMinorTick','on',...
    'YLim',[0 Inf],...
    'YDir','reverse'};
linkaxes([handles.TPlot,handles.TDiffPlot,handles.kPlot],'y');

% For debugging
assignin('base','handles',handles);

% Temperatures
axes(handles.TPlot);
cla;
hold on;
TDat=handles.TDat;
if isempty(TDat)
    return
end

if ~isempty(TDat)
    [ToolNames,Dummmy,MarkerNums]=unique({handles.TDat.ToolName});
    Colors=lines(length(ToolNames));
    Markers={'o','s','d','^','v','<','>','h','p'};
    TIsFinite=isfinite([TDat.T]);
    TFinite=[TDat.T];
    TFinite=TFinite(TIsFinite);
    for i=1:length(handles.TDat)
        LegendEntry = sprintf('%s%s%02d%s %9s  %6.2f°C @ %5.1fm ',...
        TDat(i).Site,TDat(i).Hole,str2num(TDat(i).Core),TDat(i).CoreType,...
        TDat(i).ToolName,TDat(i).T,TDat(i).z);
        if isfinite(TDat(i).T)
            if strcmp(TDat(i).ToolName,'DVTP')
                TDat(i).T=TDat(i).T-0.7;
            end

            hTM(i)=plot(TDat(i).T,TDat(i).z,['k' Markers{MarkerNums(i)}],...
                'MarkerFaceColor',Colors(MarkerNums(i),:),...
                'ButtonDownFcn','BullardPlotWin(''TSymbol_ButtonDownFcn'',gcbo,[],guidata(gcbo))',...
                'UserData',i);
        else
            hTM(i)=plot(mean(TFinite),TDat(i).z,'x',...
                'LineWidth',1,...
                'ButtonDownFcn','BullardPlotWin(''TSymbol_ButtonDownFcn'',gcbo,[],guidata(gcbo))',...
                'UserData',i);
        end
        set(hTM(i),...
            'Tag','TMeasurement',...
            'DisplayName',LegendEntry);
    end
else
    hTM=[];
end
xlabel('T (°C)');
ylabel('Depth (m bsf)');
set(gca,AxesProps{:});
grid on

kDat=handles.kDat;


% Thermal conductivity
axes(handles.kPlot);
cla
if ~isempty(kDat)
    plot(kDat.k,kDat.z,'ko',...
        'MarkerSize',4,...
        'MarkerFaceColor',[1 1 1]*.7);
end
set(gca,AxesProps{:},'YAxisLocation','right');
xlabel('k (W/(m K))');
ylabel('Depth (m bsf)');
grid on 

% Bullard Plot
axes(handles.BullardPlot)
cla
hold on
z=[TDat.z];
T=[TDat.T];
InBullardFit=[TDat.InBullardFit];
R=interp1(kDat.z,kDat.R,z,'linear','extrap');
%R=interp1(kDat.z,kDat.R,z,'linear','extrap');
GoodT=find((isfinite(T) & InBullardFit));
p=polyfit(R(GoodT),T(GoodT),1);
text(0.9,0.9,...
    sprintf('Heat-flux %.2f mW/m²\nSeafloor temperature %.2f °C',p(1)*1e3,p(2)),...
    'HorizontalAlignment','right',...
    'Units','normalized');
plot(polyval(p,[0 max(R)]),[0 max(R)],'k--');

% Plot results for site 1039
%p_1039=[0.0115 1.975];
%plot(polyval(p_1039,[0 max(R)]),[0 max(R)],'k:');

for i=1:length(handles.TDat)
    if isfinite(TDat(i).T)
        plot(TDat(i).T,R(i),['k' Markers{MarkerNums(i)}],...
            'MarkerFaceColor',Colors(MarkerNums(i),:),...
                'ButtonDownFcn','BullardPlotWin(''BullSymbol_ButtonDownFcn'',gcbo,[],guidata(gcbo))',...
                'UserData',i);
        if ~TDat(i).InBullardFit
            plot(TDat(i).T,R(i),'rx',...
                'MarkerSize',12,'LineWidth',2,...
                'ButtonDownFcn','BullardPlotWin(''BullSymbol_ButtonDownFcn'',gcbo,[],guidata(gcbo))',...
                'UserData',i);
            
        end
    end
end
plot(p(2),0,'k.');
ylabel('Cumulative  thermal resistance (m² K / W)');
xlabel('Temperature (°C)');
linkaxes([handles.TPlot handles.BullardPlot],'x');
set(gca,AxesProps{:},'XLimMode','auto'); %,'YLim',[0 max(R)]
grid on;


% Temperatures 2
axes(handles.TPlot);
kDat.T=polyval(p,kDat.R);
plot(kDat.T,kDat.z,'k--','HitTest','off');
plot(p(2),0,'k.');

% Temperature Difference
axes(handles.TDiffPlot);
cla
hold on
Tcond=polyval(p,R);
for i=1:length(handles.TDat)
    if isfinite(TDat(i).T)
        plot(TDat(i).T-Tcond(i),TDat(i).z,['k' Markers{MarkerNums(i)}],...
            'MarkerFaceColor',Colors(MarkerNums(i),:));
    end
end
set(gca,AxesProps{:},'YTickLabel',[],'YLim',[0 max([kDat.z(:)' [TDat.z]])]);
grid on

xlabel('\DeltaT (°C)');


% Legend
axes(handles.LegendPlot)
set(gca,'Visible','off');
Pos=get(gca,'Position');
hLegend=legend(hTM);
set(hLegend,'Position',Pos);


% For debugging
assignin('base','handles',handles);


function EditTemperature(handles,n)
% Edit the n-th temperature record
T=handles.TDat(n);
T.T=num2str(T.T);
T.z=num2str(T.z);
T.InBullardFit=num2str(T.InBullardFit);
Fields=fieldnames(T);
Ans=inputdlg(Fields,'Edit new data',1,struct2cell(T));
if isempty(Ans)
    % User pressed CANCEL button
    return
end
for i=1:length(Fields)
    T.(Fields{i})=Ans{i};
end
T.T=str2double(T.T);
T.z=str2double(T.z);
T.InBullardFit=str2double(T.InBullardFit);
handles.TDat(n)=T;
[Dummy,SIdx]=sort([handles.TDat.z]);
handles.TDat=handles.TDat(SIdx);
guidata(handles.BullardPlotWin,handles);
UpdatePlots(handles);

% --------------------------------------------------------------------
function WriteEPS_Callback(hObject, eventdata, handles)
% hObject    handle to WriteEPS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(gcf,'PaperPosition',[0.6345    0.6345   19.7150   28.4084]);
print('-depsc','BullardPlot.eps');



