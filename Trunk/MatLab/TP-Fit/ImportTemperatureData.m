function [Data,FileName]=ImportTemperatureData(varargin)
%ImportTemperatureData Import data of IODP/ODP downhole temperature tools
%
% Data files of APCT-3 (ANTARES), older APCT tools (ADARA), and DVTP (DVTP)
% tools are supported.
% If the function is called without input parameters, the user can
% interactively pick a file and the filetype (given in braces above) is
% automaticly determined. The filetype can also be set by specifying a
% parameter value pair (e.g. 'FileType','ANTARES'). Furthermore it is
% possible to specify the filename directly. When loading ADARA files the
% "event" with most data in it is loaded, automaticly. In case this is not
% the event that has the relevant data in it, use the ('EventNo',#) option
% to load the event you want!

% Martin Heesemann 07.12.2006

% Return undefined options ?

% Process command-line options
Opts.FileType=[];
Opts.StartDir='';
Opts.EditBad=false; % Automatically open bad files in Matlab Editor
Opts.DoPlot=false;
[Opts, unusedOpts]=ParseFunOpts(Opts,varargin);
if length(unusedOpts)==1
    FileName=unusedOpts{1};
end

% Get the FileName
if ~exist('FileName','var')
    [DatFile,DatPath]=uigetfile({'*.dat;*.eng;*.mat;*.new;*.npm;*.fit';'*.dat';'*.eng';'*.mat'},'Select Data or Session File',Opts.StartDir);
    FileName=fullfile(DatPath, DatFile);
else
    [DatPath,DatFile,ext] = fileparts(FileName);
    DatFile=[DatFile ext];
end

% Make sure the file exists
if ~exist(FileName,'file');
    warning('TPFit:FileNotFound','File %s does not exist!',FileName);
    Data=[];
    return
end

% Is it a save matlab-session? -> Load it and return!
[Dummy1,Dummy2,ext]=fileparts(FileName);
if strcmpi(ext,'.mat')
    load(FileName);
    if exist('Data','var')
        if (isfield(Data,'SynthInfo') && ~isfield(Data,'TPFitInfo'))
            % This is a plain GeTTMo model and not a Session file
            Data.ImportInfo.DatFile=[Dummy2 ext];
        end
        if isfield(Data,'T')
            % We assume that T is valid data
            % and that the rest is also okay ;-)
            if Opts.DoPlot
                PlotMatData(Data,FileName); %See below
            end
            return
        end
    end
    warning('TPFit:NoSession',[FileName ' is not a valid session!']);
    Data=[];
    return
end

% Check the FileType of the input data
if ~isempty(Opts.FileType)
    % User has supplied file type
    FileType=Opts.FileType;
else
    % Automaticly determine file type (ADARA, ANTARES, DVTP)
    fid=fopen(FileName,'r');
    Line1=fgetl(fid);
    Line2=fgetl(fid);
    Line3=fgetl(fid);
    fseek(fid,0,'bof'); % rewind file

    if (strncmp(Line1,...
            '" **** Adara Temperature Tool Data File Version 3.0 ****"',56) || ...
            strncmp(Line2,...
            '" **** Adara Temperature Tool Data File Version 3.0 ****"',56) || ...
            strncmp(Line2,...
            '" **** Adara Temperature Tool Data File Version 3.0 ****"',56))
        FileType='ADARA';
    elseif (strncmp(Line1,'origin:',6) && strncmp(Line2,'string:',6))
        FileType='DVTP';
    elseif (strncmp(Line1,'origin:',6) && strcmpi(ext,'.dat'))
        FileType='DVTP_RAW';
    elseif fLocateLine(fid,'CF-2 SERIAL NUMBER:','IssueError',false)
        FileType='SETP_PROTOTYPE';
    elseif strncmp(Line3,'# LoggerIdentifier',18)
        FileType='ANTARES';
    elseif strcmpi(ext,'.npm')
        FileType='QBASIC_NEEDLE';
    elseif strcmpi(ext,'.fit')
        FileType='TPFIT_RES';
    else
        warning('TPFit:UnknownFormat','Sorry, cannot determine data type of %s !',FileName );
        if Opts.EditBad
            edit(FileName);
        end
        Data=[];
        fclose(fid);
        return
    end
    fclose(fid);
end

% Import Data with routines depending on FileType
switch upper(FileType)
    case {'ADARA'}
        OrigData=ImportAdaraData(FileName,'DoPlot',Opts.DoPlot);
        Data.T=OrigData.T;
        Data.t=OrigData.t;
    case {'ANTARES'}
        OrigData=ImportWinTempDat(FileName,'DoPlot',Opts.DoPlot);
        Data.T=OrigData.TRaw;
        Data.t=OrigData.t;
    case {'DVTP'}
        OrigData=ImportDVTPData(FileName,'DoPlot',Opts.DoPlot);
        Data.T=OrigData.T1;
        Data.t=OrigData.t;
    case {'DVTP_RAW'}
        OrigData=ImportDVTPRawData(FileName,'DoPlot',Opts.DoPlot);
        Data.T=OrigData.T1;
        Data.t=OrigData.t;
    case {'SETP_PROTOTYPE'}
        OrigData=ImportNewDVTPPData(FileName,'DoPlot',Opts.DoPlot);
        Data.T=OrigData.T;
        Data.t=OrigData.t;
    case {'QBASIC_NEEDLE'}
        OrigData=ImportNeedleData(FileName,'DoPlot',Opts.DoPlot);
        Data.T=OrigData.T;
        Data.t=OrigData.t;
    case {'TPFIT_RES'}
        OrigData=ImportAdaraFit(FileName,'DoPlot',Opts.DoPlot);
        Data.ModelType='APCT_T';
        Data.T=OrigData.Data.T;
        Data.t=OrigData.Data.t;
    otherwise
        warning('TPFit:UnknownData',['Sorry, unsupported data type! ' FileType ]);
        Data=[];
        return
end

% Put together all information for later use
Info.DataType=FileType;
Info.ImportDate=datestr(now);
Info.DatFile=DatFile;
Info.DatPath=DatPath;
FileInfo=dir(FileName);
Info.FileDate=FileInfo.date;
Data.ImportInfo=Info;
Data.OrigData=OrigData;


%% Subfunctions

function PlotMatData(Data,FileName)
cla;
figure(gcf);
plot(Data.t, Data.T,'-')
xlabel('t (s)');
ylabel('T (°C)');
[FPath,ODPName]=fileparts(FileName);
title([upper(ODPName) ' (mat-file)'],'interpreter','none');
set(gca,...
    'TickDir','out',...
    'XMinorTick','on',...
    'YMinorTick','on',...
    'XLim',[min(Data.t) max(Data.t)]);