function Data=ImportAdaraData(FileName,varargin)
% IMPORTADARADATA   Reads old APCT data in ADARA ASCII format
%   
%   Example
%       Data=ImportAdaraData('FileName.Dat');
%
%   See also: ImportTemperatureData, ImportAdaraFit

%% Info
%
%   Created: 22-Sep-2007 
%
%   Copyright 2007  Martin Heesemann <heesema AT uni-bremen DOT de>


%% Self-test
if ~exist('FileName','var')
    %FileName='1034e03h.Dat';
    
    [DatFile,DatPath]=uigetfile({'*.dat;*.new'},'Old Adara TFit data');
    FileName=fullfile(DatPath, DatFile)

    varargin={'DoPlot',true};
end

%% Define options
Opts.DoPlot=true;
Opts=ParseFunOpts(Opts,varargin);

fid=fopen(FileName,'r');
if (fid<1)
    warning('Could not open file %s',FileName);
    return
end

%% Get Meta data
fLocateLine(fid,'Serial Number:');
Info.ToolID=num2str(fscanf(fid,'%*21c %d',1));

fLocateLine(fid,'Cruise Leg:');
Info.Expedition=num2str(fscanf(fid,'%*21c %d',1));

fLocateLine(fid,'Site:');
Info.Site=num2str(fscanf(fid,'%*21c %d',1));

fLocateLine(fid,'Hole:');
Info.Hole=upper(fscanf(fid,'%*21c %s',1));

fLocateLine(fid,'Core:');
Info.Core=num2str(upper(fscanf(fid,'%*21c %d',1)));

fLocateLine(fid,'Subbottom depth:');
Info.Depth=num2str(upper(fscanf(fid,'%*21c %f',1)));

if isempty(Info.Site)
    [Dummy,BaseName]=fileparts(FileName);
    Info.Site=num2str(sscanf(BaseName,'%d%*s'));
end


Data.Info=Info;

%% Load complete header
fLocateLine(fid,'Event Number:');
HeaderLength=ftell(fid);
fseek(fid,0,'bof');
Data.Header=fscanf(fid,'%1c',HeaderLength-1);
Data.T=[];
Data.t=[];
Data.EventIdx=[1];
tOffset=0;
NEvents=0;
while fLocateLine(fid,'Event Number:','IssueError',false);
    NEvents=NEvents+1;
    [Data.Event{NEvents},T,t,tNext]=ReadEventInfo(fid,FileName);
    Data.T=[Data.T; T];
    Data.t=[Data.t; t+tOffset];
    Data.EventIdx=[Data.EventIdx length(Data.T)+1];
    tOffset=tOffset+tNext;
end
fclose(fid);

if Opts.DoPlot
    cla;
    figure(gcf);
    plot(Data.t, Data.T,'-')
    xlabel('t (s)');
    ylabel('T (°C)');
    [FPath,ODPName]=fileparts(FileName);
    title(['APCT:' upper(ODPName) ' (Adara)']);
    set(gca,...
        'TickDir','out',...
        'XMinorTick','on',...
        'YMinorTick','on',...
        'XLim',[min(Data.t) max(Data.t)]);
end

function [Event,T,t,tNext]=ReadEventInfo(fid,FileName)
Event.Number=fscanf(fid,'%*17c %d%*s',1);
fLocateLine(fid,'Start time','EditFile',FileName);
Event.tStart=fscanf(fid,'%*17c %11c%*s',1);
fLocateLine(fid,'Stop time','EditFile',FileName);
Event.tStop=fscanf(fid,'%*17c %11c%*s',1);
fLocateLine(fid,'Increment time','EditFile',FileName);
Event.tInc=fscanf(fid,'%*17c %11c%*s',1);
Event.Sampling=str2num(Event.tInc(end-1:end));
fLocateLine(fid,'Number Scans','EditFile',FileName);
Event.NScans=fscanf(fid,'%*17c %d%*s',1);
fgetl(fid);
T=textscan(fid,'%*d, %f',Event.NScans);
T=T{1};
T=T(:);
t=(1:length(T))'*Event.Sampling;
tNext=(length(T)+1)*Event.Sampling;



% if ~exist('Event','var')
%     % find the event with most data in it
%     fid=fopen(FileName,'r');
%     Event=0;
%     while ~feof(fid)
%         Line=fgetl(fid);
%         NScansLine=findstr('Number Scans:',Line);
%         if ~isempty(NScansLine);
%             Event=Event+1;
%             NScans(Event)=sscanf(Line,'%*s %*s %*s %d');
%         end
%     end
%     [Dummy,Event]=max(NScans);
% end
% 
% % Find Event
% HeaderCount=0;
% FoundEvent=false;
% EventCountLine=[];
% 
% fid=fopen(FileName,'r');
% 
% while ~FoundEvent
%     HeaderCount=HeaderCount+1;
%     Line=fgetl(fid);
%     if feof(fid)
%         fclose(fid)
%         error(['Event not found in ' FileName ' !!!']);
%     end
%     % look for Event Count
%     if isempty(EventCountLine)
%         EventCountLine=findstr('Event count:',Line);
%         if ~isempty(EventCountLine)
%             Data.EventCount=sscanf(Line,'%*s %*s %*s %d');
%         end
%     end
%     
%     % look for Event
%     EventLine=findstr('Event Number:',Line);
%     if ~isempty(EventLine)
%         CurrentEvent=sscanf(Line,'%*s %*s %*s %d');
%         if (CurrentEvent == Event)
%             FoundEvent=true;
%         end
%     end
% end
% % Gather Event Information
% Data.Event=Event;
% Line=fgetl(fid);
% Data.StartTime=sscanf(Line,'%*s %*s %*s %11s');
% Line=fgetl(fid);
% Data.StopTime=sscanf(Line,'%*s %*s %*s %11s');
% Line=fgetl(fid);
% Data.SampleInterv=sscanf(Line,'%*s %*s %*s %11s');
% Line=fgetl(fid);
% Data.NoOfSamples=sscanf(Line,'%*s %*s %*s %d');
% HeaderCount=HeaderCount+4;
% Data.HeaderCount=HeaderCount;
% fclose(fid)
% 
% % Read Data
% [Data.No, Data.T]=...
%     textread(FileName,'%d, %f',Data.NoOfSamples,'headerlines',HeaderCount);
% 
% 
% SampleIntervSec=(datenum(Data.SampleInterv(3:end))-datenum('00:00'))/(datenum('00:00:01')-datenum('00:00'));
% Data.t=(Data.No-Data.No(1))*SampleIntervSec;
% return
% 
