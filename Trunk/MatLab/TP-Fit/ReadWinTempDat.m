function Data=ReadWinTempDat(DatFile)
% Reads WinTemp *.dat file and returns a Data structure which
% contains the data in seperate fields.
% Have a look at the end of the file for field descriptions
%
% 4.7.2002 (Poseidon 291) Martin Heesemann
%
% Update: 3.9.2004 (IODP 301T) Martin Heesemann
% * Now all information of Header is included in Data -Structure
% * OneSecond=datenum('00:00:01'); Does not work anymore since MatLab 7!
%   Change to OneSecond=datenum('00:00:02')-datenum('00:00:01');
% 

%
% Find end of header and get header-information
%
fid=fopen(DatFile,'r');
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
    textread(DatFile,'%d %d %d %d %d %d %d %f %f','headerlines',NumOfHLines);
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