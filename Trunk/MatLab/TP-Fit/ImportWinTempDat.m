function Data=ImportWinTempDat(FileName,varargin)
% IMPORTWINTEMPDAT.M   Reads WinTemp *.dat file
%   Reads WinTemp *.dat file and returns a Data structure which
%   contains the data in seperate fields.
%   Have a look at the end of the file for field descriptions
%
%   
%   Example
%       Data=ImportWinTempDat
%
%   See also: ImportTemperatureData

%% Info
% 4.7.2002 (Poseidon 291) Martin Heesemann (ReadWinTempDat)
%
% Update: 3.9.2004 (IODP 301T) Martin Heesemann
% * Now all information of Header is included in Data -Structure
% * OneSecond=datenum('00:00:01'); Does not work anymore since MatLab 7!
%   Change to OneSecond=datenum('00:00:02')-datenum('00:00:01');
%
%   Copyright 2007  Martin Heesemann <heesema AT uni-bremen DOT de>

%% Self-test
if ~exist('FileName','var')
    
    [DatFile,DatPath]=uigetfile({'*.dat'},'WinTemp Data');
    FileName=fullfile(DatPath, DatFile)

    varargin={'DoPlot',true};
end

% Make sure the file exists
if ~exist(FileName,'file');
    warning('TPFit:FileNotFound','File %s does not exist!',FileName);
    Data=[];
    return
end


%% Define options
Opts.DoPlot=true;
Opts=ParseFunOpts(Opts,varargin);




%
% Find end of header and get header-information
%
fid=fopen(FileName,'r');
HLine=[];
NumOfHLines=0;
% This identifies the last line of the header
LastLine='yyyy mm dd HH MM SS      Raw     Res[Ohm]   Temp[degC]';
while ~strncmp(LastLine,HLine,length(LastLine))
    HLine=fgetl(fid);
    NumOfHLines=NumOfHLines+1;
    
    % Identify subject of line and store the data
    Subject=sscanf(HLine,'# %s');
    switch Subject
        case 'LoggerIdentifier'
            Data.LoggerID=sscanf(HLine,'# %*s %*s %s');
        case 'Comment'
            Data.Comment=sscanf(HLine,'# %*s %*s %s');
        case 'StartBatteryVoltage'
            Data.Battery(1)=sscanf(HLine,'# %*s %*s %f');
        case 'EndBatteryVoltage'
            Data.Battery(2)=sscanf(HLine,'# %*s %*s %f');
        case 'TotalSampleCount'
            Data.TotalSampleCount=sscanf(HLine,'# %*s %*s %f');
        case 'ResistanceOffset'
            Data.RCoeff(1)=sscanf(HLine,'# %*s %*s %f');
        case 'ResistanceScale'
            Data.RCoeff(2)=sscanf(HLine,'# %*s %*s %f');
        case 'TemperatureOffset'
            Data.TCoeff(1)=sscanf(HLine,'# %*s %*s %f');
        case 'TemperatureLinear'
            Data.TCoeff(2)=sscanf(HLine,'# %*s %*s %f');
        case 'TemperatureCubic'
            Data.TCoeff(3)=sscanf(HLine,'# %*s %*s %f');
    end
end
fclose(fid);

%
% Found out number of header-lines to skip, now read the Data
%
[yyyy, mm, dd, HH, MM, SS, Raw, Res, T]=...
    textread(FileName,'%d %d %d %d %d %d %d %f %f','headerlines',NumOfHLines);
%
% Organize the Data
%

% Datenumber which can be used to do plots vs. time (datetick)
Data.DateNum=datenum(yyyy, mm, dd, HH, MM, SS);

% String containing date and time
Data.DateStr=datestr(Data.DateNum);

% Raw A/D readings
Data.Raw=Raw;

% Resistivities as computed by WinTemp
Data.ResRaw=Res;

% Temperatures as computed by WinTemp
Data.TRaw=T;

% Elapsed time in seconds after the beginning of the measurement (t=0)
OneSec=datenum('00:00:02')-datenum('00:00:01');
Data.t=round((Data.DateNum-Data.DateNum(1))/OneSec);

if Opts.DoPlot
    cla;
    figure(gcf);
    plot(Data.t, Data.TRaw,'-')
    xlabel('t (s)');
    ylabel('T (°C)');
    [FPath,ODPName]=fileparts(FileName);
    title(['APCT:' upper(ODPName) ' (WinTemp)']);
    set(gca,...
        'TickDir','out',...
        'XMinorTick','on',...
        'YMinorTick','on',...
        'XLim',[min(Data.t) max(Data.t)]);
end
