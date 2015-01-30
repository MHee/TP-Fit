function Data=ImportUSIO_adara(FileName,varargin)
% IMPORTUSIO_ADARA   Template for m-files
%   This is a m-file skeleton. Just replace the Dummy text and you are
%   ready to go!!!
%   
%   Example
%       ...=ImportUSIO_adara
%
%   See also: helprep, contentsrpt

%% Info
% * TODO: Sample todo
% * FIXME: Sample fixme
%
%   Created: 29-Sep-2007 
%   $Revision$  $Date$
%
%   Copyright 2007  Martin Heesemann <heesema AT uni-bremen DOT de>


%% Self-test
if ~exist('FileName','var')
    FileName='1176_USIO_adara.dat';
    varargin={};
end

%% Define options
Opts.Offset=1;
Opts=ParseFunOpts(Opts,varargin);

%% Main code
fid=fopen(FileName)

IsLeg=[];
while isempty(IsLeg)
    CurrPos=ftell(fid);
    Line=fgets(fid)
    IsLeg=sscanf(Line,'%f',1)
end
fseek(fid,CurrPos,'bof')
out=textscan(fid,'%s %s %s %s %s %f %f %f %f %s %s %s %s','delimiter','\t');
fclose(fid);
Data.Leg=out{1};
Data.Site=out{2};
Data.Hole=out{3};
Data.Core=out{4};
Data.CoreType=out{5};
Data.ToolName=out{12};
Data.T=out{9};
Data.z=out{7};
%Data.T(~isfinite(Data.T))=min(Data.T);
Data.T;
Data.out=out;
figure(2)
set(gcf,'Name','USIO')
clf;
hPlot(1)=subplot(2,2,1)
hold on;
for i=1:length(Data.T)
    if isfinite(Data.T(i))
        h(i)=plot(Data.T(i),Data.z(i),'o');
    else
        h(i)=plot(min(Data.T),Data.z(i),'x');
    end
    LegStr{i}= sprintf('%s%s%02d%s %9s  %6.2f°C @ %5.1fm ',...
        Data.Site{i},Data.Hole{i},str2num(Data.Core{i}),Data.CoreType{i},Data.ToolName{i},Data.T(i),Data.z(i));
end
set(gca,'YDir','reverse')

hPlot(2)=subplot(2,2,2)
hLeg=legend(h,LegStr,'Location','East') %,'Location','SouthOutside'
set(hLeg,'Position',get(hPlot(2),'Position'));
set(hPlot(2),'Visible','off')

