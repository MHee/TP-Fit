function Data=ImportTemperatureData(varargin)
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
Opts.EventNo=[]; % Which Event to use in ADARA files
Opts.StartDir='';
[Opts, unusedOpts]=ParseFunOpts(Opts,varargin);
if length(unusedOpts)==1
    FileName=unusedOpts{1};
end

% Get the FileName
if ~exist('FileName','var')
    [DatFile,DatPath]=uigetfile({'*.dat;*.eng;*.mat;*.new;*.npm';'*.dat';'*.eng';'*.mat'},'Select Data or Session File',Opts.StartDir);
    FileName=fullfile(DatPath, DatFile);
else
    [DatPath,DatFile,ext] = fileparts(FileName);
    DatFile=[DatFile ext];
end

% Make sure the file exists
if ~exist(FileName,'file');
    warning('TPFit:FileNotFound','File %s does not exist!',FileName);
    Data=0;
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
           return
       end
    end
    warning('TPFit:NoSession',[FileName ' is not a valid session!']);
    Data=0;
    return
end

% Check the FileType of the input data
if ~isempty(Opts.FileType) 
    % User has supplied file type
    FileType=Opts.FileType;
else 
    % Automaticly determine file type (ADARA, ANTARES, DVTP)
    fid=fopen(FileName);
    Line1=fgetl(fid);
    Line2=fgetl(fid);
    Line3=fgetl(fid);
    fclose(fid);

    if (strncmp(Line1,...
            '" **** Adara Temperature Tool Data File Version 3.0 ****"',56) || ...
            strncmp(Line2,...
            '" **** Adara Temperature Tool Data File Version 3.0 ****"',56) || ...
            strncmp(Line2,...
            '" **** Adara Temperature Tool Data File Version 3.0 ****"',56))
        FileType='ADARA';
    elseif strncmp(Line1,'origin:',6)
        FileType='DVTP';
    elseif strncmp(Line3,'# LoggerIdentifier',18)
        FileType='ANTARES';
    elseif strcmpi(ext,'.npm')
        FileType='QBASIC_NEEDLE';
    else
        warning('TPFit:UnknownFormat',['Sorry, cannot determine data type of ' FileName ]);
        Data=0;
        return
    end
end

% Import Data with routines depending on FileType
switch upper(FileType)
    case {'ADARA'}
        if isempty(Opts.EventNo)
            OrigData=ImportAdaraData(FileName);
        else
            OrigData=ImportAdaraData(FileName,Opts.EventNo);
        end
            
        Data.T=OrigData.T;
        Data.t=OrigData.t;
    case {'ANTARES'}
        OrigData=ReadWinTempDat(FileName);
        Data.T=OrigData.TRaw;
        Data.t=OrigData.t;
    case {'DVTP'}
        OrigData=ImportDVTPData(FileName);
        Data.T=OrigData.T1;
        Data.t=OrigData.t;
    case {'QBASIC_NEEDLE'}
        OrigData=ImportNeedleData(FileName);
        Data.T=OrigData.T;
        Data.t=OrigData.t;
    otherwise
        warning('TPFit:UnknownData',['Sorry, unsupported data type! ' FileType ]);
        Data=0;
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
