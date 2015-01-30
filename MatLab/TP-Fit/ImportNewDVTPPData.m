function Data=ImportNewDVTPPData(FileName,varargin)
% IMPORTDVTPDATA   Imports data of the new DVTP(P) Data logger
%
%   See also: ImportTemperatureData

%%
% Copyright (C) 2007  Martin Heesemann  <heesema AT uni-bremen DOT de>

% This file is part of TP-Fit.
%
%     TP-Fit is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
%     TP-Fit is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
%
%     You should have received a copy of the GNU General Public License
%     along with TP-Fit.  If not, see <http://www.gnu.org/licenses/>.


%% Self-test
if ~exist('FileName','var')

    %[DatFile,DatPath]=uigetfile({'*.dat';'*.*'},'DVTPP Data (New Version)');
    %FileName=fullfile(DatPath, DatFile)
    %FileName='SETP_Test.dat';
    FileName='SETP_Test_original.dat';
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


%% Read Data
fid=fopen(FileName);
if (fid<1)
    warning('TPFit:FileNotFound','Could not open file %s',FileName);
    return
end

%% Import Header Info
fLocateLine(fid,' ACQUISITION DATE:');
Info.StartDateStr=fscanf(fid,' ACQUISITION DATE:,,,%s');
Info.CF2_Serial=fscanf(fid,' CF-2 SERIAL NUMBER:,,,%s');
Info.ProgramVersion=fscanf(fid,' PROGRAM VERSION:,,,%s');
Info.LastCalibration=fscanf(fid,' LAST CALIBRATION DATE:,,,%s');
Info.FileReference=fscanf(fid,'FILE REFERENCE:,,,%s');
Info.PressureTransducerID=fscanf(fid,' PRESSURE TRANSDUCER S/N:,,,%s');

%% Import Data Section
fLocateLine(fid,'HH:MM:SS','Continue',true);
DataBlock=textscan(fid,'%s %f %f %f %f %s %s %f %f %f','delimiter',',');

RefDateNum=datenum(Info.StartDateStr);

TStop=min(find(strcmp(DataBlock{1},'')))-1;
Data.DateNum=datenum(DataBlock{1}(1:TStop))-datenum('00:00:00')+RefDateNum;
Data.t=(Data.DateNum-Data.DateNum(1))/...
    (datenum('00:00:01')-datenum('00:00:00'));

Data.T=DataBlock{2}(1:TStop);
Data.R=DataBlock{3}(1:TStop);
Data.Tint=DataBlock{4}(1:TStop);
Data.Vbat=DataBlock{5}(1:TStop);
Data.P=str2double(DataBlock{6}(1:TStop)); % Pressure can be empty !!!

Data.DateNumG=datenum(DataBlock{7})-datenum('00:00:00')+RefDateNum;
Data.tG=(Data.DateNumG-Data.DateNum(1))/...
    (datenum('00:00:01')-datenum('00:00:00'));

Data.Gx=DataBlock{8};
Data.Gy=DataBlock{9};
Data.Gz=DataBlock{10};

fclose(fid);

if any(diff(Data.DateNum)<=0)
    warndlg(['There are times extending mid-night!!!!  ' ...
        'That is not handled for this type of data, yet.']);
end

Data.Info=Info;
%Data.DataBlock=DataBlock;

if Opts.DoPlot
    clf
    LegendLoc='SouthEast';

    ha(1)=subplot(4,1,1);
    hold on
    plot(Data.t,Data.T,'r');
    plot(Data.t,Data.Tint,'r:');
    legend({'T','T_{int}'},'Location',LegendLoc);
    ylabel('Temperature (°C)');

    ha(2)=subplot(4,1,2);
    hold on
    plot(Data.t,Data.Vbat,'g');
    legend({'Battery'},'Location',LegendLoc);
    ylabel('Voltage (V)');

    ha(3)=subplot(4,1,3);
    hold on
    plot(Data.t,Data.P,'b');
    legend({'Pressure'},'Location',LegendLoc);
    ylabel('Pressure (PSI)');

    ha(4)=subplot(4,1,4);
    hold on
    plot(Data.tG,Data.Gx,'k');
    plot(Data.tG,Data.Gy,'r');
    plot(Data.tG,Data.Gz,'g');
    legend({'acc_x','acc_y','acc_z'},'Location',LegendLoc);
    ylabel('Acceleration (g)');
    xlabel('Time (s)');

    set(ha,...
        'Box','on');

    linkaxes(ha,'x');
end

return





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Old Stuff
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Info.Expedition=fscanf(fid,' LEG  %s',1);
Info.Hole=fscanf(fid,' HOLE %s',1);
Info.Core=fscanf(fid,' CORE %s',1);
Info.Site=num2str(sscanf(ODPName,'%d%*s'));


[Data.DateStr, Data.No, Data.T1, Data.T2, Data.Ti, Data.Tr, Data.ap, Data.am]=...
    textread(FileName,'%s %f %f %f %f %f %f %f','headerlines',4);
Win=[0:2];
apStd=0.5*ones(size(Data.ap));
DiffT=[0 ;diff(Data.T1)];
CumDiffT=zeros(size(DiffT));
for No=1:(length(apStd)-max(Win))
    apStd(No)=median(Data.ap(Win+No));
    CumDiffT(No)=sum(DiffT(Win+No)/length(Win));
end

%((datenum(Data.DateStr(2))-datenum(Data.DateStr(1))))/(datenum('00:00:01')-datenum('00:00:00'))
%t=datenum(Data.DateStr);
t=(((datenum(Data.DateStr(2))-datenum(Data.DateStr(1))))/(datenum('00:00:01')-datenum('00:00:00')))*[1:length(Data.DateStr)];
%t=(datenum(Data.DateStr(2))-datenum(Data.DateStr(1)))*[0:length(Data.DateStr)-1];
%t=t/60;
Data.t=round(t)';
%t=Data.No;


%
% Plot
%

if Opts.DoPlot
    figure(gcf);
    cla;

    set(gcf,...
        'PaperType','A4',...
        'PaperUnits','centimeters');

    %     PaperSize=get(gcf,'PaperSize');
    %     %PaperPosition=[0.5 0.5 PaperSize-1];
    %     PaperPosition=[5 17 13 9];
    %     Position=[5 34 (660*PaperPosition(3)/PaperPosition(4)) 660];
    %     set(gcf,...
    %         'PaperPosition',PaperPosition,...
    %         'Position',Position);

    XLim=[t(1) t(length(t))];
    %XLim=[50 65];

    %
    % Acceleration
    %
    %hAcc=axes;
    hAcc=gca;
    AxesPos=get(gca,'Position');
    %     AxesPos(3:4)=0.9*AxesPos(3:4);
    %     AxesPos(1:2)=0.05+AxesPos(1:2);
    %     set(gca,'Position',AxesPos);

    YLim=[0 2.5*max([Data.ap(find(isfinite(Data.ap))); 0.1])];
    hold on
    % Plot Acceleration
    plot(t,Data.ap,'k.-','Color',0.85*[1 1 1])
    plot(t,Data.am,'k-','Color',0.6*[1 1 1])

    LabelInd=round(([-0.1 0 0.1]+0.5)*length(t));
    %text(t(LabelInd(3)),Data.ap(LabelInd(3)),'Acc.','VerticalAlignment','bottom');
    hold off

    xlabel('Time (s)');
    ylabel('Uncalibrated Acceleration');
    %datetick('x')
    set(gca,...
        'YLim',YLim,...
        'XLim',XLim,...
        'Box','off',...
        'TickDir','out',...
        'YMinorTick','on',...
        'XMinorTick','on',...
        'YAxisLocation','right',...
        'XAxisLocation','bottom');


    AccPos=get(gca,'Position');

    %
    % Temperature Data
    %
    hDat=axes('Position',AccPos);
    hold on

    plot(t,Data.T1,'r')
    plot(t,Data.T2,'b')

    %text(t(LabelInd(1)),Data.T1(LabelInd(1)),'T1','VerticalAlignment','bottom');
    %text(t(LabelInd(2)),Data.T2(LabelInd(2)),'T2','VerticalAlignment','top');

    % Dummy lines for acceleration in legend
    plot([0 1],[-1000 -1000],'k.-','Color',0.85*[1 1 1])
    plot([0 1],[-1000 -1000],'k-', 'Color',0.6*[1 1 1])

    hold off

    [FPath,ODPName]=fileparts(FileName);
    title(['DVTP:' upper(ODPName)]);

    YLim=[floor(min([Data.T1' Data.T2'])) ...
        ceil(max([Data.T1' Data.T2']))];

    ylabel('Temperature (°C)');
    %datetick('x')
    set(gca,...
        'XLim',XLim,...
        'YLim',YLim,...
        'Color','none',...
        'XTickLabel',[],...
        'TickDir','out',...
        'YMinorTick','on',...
        'XMinorTick','on',...
        'XAxisLocation','top',...
        'Box','off');


    [Dummy,MaxTInd]=max(Data.T1);
    if MaxTInd < 0.5*length(t)
        LegendPos=1;
    else
        LegendPos=2;
    end
    h=legend('T1','T2','Peak acc.','Mean acc.',LegendPos);
    set(h,...
        'Color',[0.8 0.8 0.8],...
        'XColor',[0.7 0.7 0.7],...
        'YColor',[0.7 0.7 0.7],...
        'FontSize',6)
    linkaxes([hDat,hAcc],'x');
    grid on;
end
