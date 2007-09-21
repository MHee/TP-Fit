function Data=ImportAdaraData(FileName,Event)

if ~exist('Event','var')
    % find the event with most data in it
    fid=fopen(FileName,'r');
    Event=0;
    while ~feof(fid)
        Line=fgetl(fid);
        NScansLine=findstr('Number Scans:',Line);
        if ~isempty(NScansLine);
            Event=Event+1;
            NScans(Event)=sscanf(Line,'%*s %*s %*s %d');
        end
    end
    [Dummy,Event]=max(NScans);
end

% Find Event
HeaderCount=0;
FoundEvent=false;
EventCountLine=[];

fid=fopen(FileName,'r');

while ~FoundEvent
    HeaderCount=HeaderCount+1;
    Line=fgetl(fid);
    if feof(fid)
        fclose(fid)
        error(['Event not found in ' FileName ' !!!']);
    end
    % look for Event Count
    if isempty(EventCountLine)
        EventCountLine=findstr('Event count:',Line);
        if ~isempty(EventCountLine)
            Data.EventCount=sscanf(Line,'%*s %*s %*s %d');
        end
    end
    
    % look for Event
    EventLine=findstr('Event Number:',Line);
    if ~isempty(EventLine)
        CurrentEvent=sscanf(Line,'%*s %*s %*s %d');
        if (CurrentEvent == Event)
            FoundEvent=true;
        end
    end
end
% Gather Event Information
Data.Event=Event;
Line=fgetl(fid);
Data.StartTime=sscanf(Line,'%*s %*s %*s %11s');
Line=fgetl(fid);
Data.StopTime=sscanf(Line,'%*s %*s %*s %11s');
Line=fgetl(fid);
Data.SampleInterv=sscanf(Line,'%*s %*s %*s %11s');
Line=fgetl(fid);
Data.NoOfSamples=sscanf(Line,'%*s %*s %*s %d');
HeaderCount=HeaderCount+4;
Data.HeaderCount=HeaderCount;
fclose(fid)

% Read Data
[Data.No, Data.T]=...
    textread(FileName,'%d, %f',Data.NoOfSamples,'headerlines',HeaderCount);


SampleIntervSec=(datenum(Data.SampleInterv(3:end))-datenum('00:00'))/(datenum('00:00:01')-datenum('00:00'));
Data.t=(Data.No-Data.No(1))*SampleIntervSec;
return

plot(Data.t, Data.T,'-')
xlabel('t (s)');
ylabel('T (°C)');
title(strtok(FileName,'.'));
set(gca,...
    'TickDir','out',...
    'XMinorTick','on',...
    'YMinorTick','on',...
    'XLim',[min(Data.t) max(Data.t)]);
