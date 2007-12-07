function Data=ImportDVTPRawData(FileName,varargin)
% IMPORTDVTPDATA   Imports the original DVTP data format
%   Example
%       ...=ImportDVTPData
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

    [DatFile,DatPath]=uigetfile({'*.dat';'*.*'},'WinTemp Data');
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






%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
%
%

[Data.DateStr, Data.No, Data.T1, Data.T2, Data.Ti, Data.Tr, Data.ap, Data.am]=...
    textread(FileName,'%s %f\r\n%s %s %s %s %s %s','headerlines',3);

Data.T1=hex2dec(Data.T1);

K0=98333.36;
K1=68360.96;
R1=99981.15;

A0=0.0008093895836;
A1=0.0002256377282;
A3=0.00000007718739823;

prompt = {'K0','K1','R1','A0','A1','A3'};
dlg_title = 'Check calibration factors!!!!';
num_lines = 1;
def = cellstr(num2str([K0 K1 R1 A0 A1 A3]','%.10e'));
UpdatedConsts = inputdlg(prompt,dlg_title,num_lines,def);
UpdatedConsts = num2cell(str2num(char(UpdatedConsts)));
[K0 K1 R1 A0 A1 A3]=deal(UpdatedConsts{:})

R=R1*(K1-Data.T1)./(K0-(K1-Data.T1));
T=1 ./ (A0 + A1*log(R) + A3*log(R).^3);
Data.T1=T-273.15;

Data.T2=mean(Data.T1)*ones(size(Data.T1));
%Data.T2=hex2dec(Data.T2);

Data.Ti=hex2dec(Data.Ti);
Data.Tr=hex2dec(Data.Tr);
Data.ap=hex2dec(Data.ap);
Data.am=hex2dec(Data.am);

%fid=fopen(FileName,'r');
%Data=textscan(fid,'%s %f %x %x %x %x %x %x','headerlines',3);
%fclose(fid);
%return

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
    clf;
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

% return
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% % estimate Autopick
% MeanNoise=mean(apStd);
% LowNoise=find((apStd<0.15*MeanNoise));
%
% [Dummy,PenStart]=max(CumDiffT);
% [Dummy,PenStop] =min(CumDiffT);
%
%
% figure(1)
% subplot(4,1,1)
% plot(Data.No,Data.T2,'g.-')
% hold on
% plot(Data.No,Data.T1,'b.-')
% plot(Data.No([PenStart PenStop]),Data.T1([PenStart PenStop]),'r*')
% hold off
%
% if (PenStart<PenStop)
%     XLim=[PenStart-5 PenStop+5];
% else
%     XLim=get(gca,'Xlim');
% end
%
% set(gca,...
%     'XLim',XLim,...
%     'TickDir','out',...
%     'XMinorTick','on',...
%     'YMinorTick','on',...
%     'Box','on',...
%     'XGrid','on'...
%     )
% h=title(FileName);
% set(h,'Interpreter','none');
% ylabel('Temperature (°C)');
%
% subplot(4,1,2)
% plot(Data.No, [Data.ap Data.am],'.-')
% set(gca,...
%     'XLim',XLim,...
%     'TickDir','out',...
%     'XMinorTick','on',...
%     'YMinorTick','on',...
%     'Box','on',...
%     'XGrid','on'...
%     )
% ylabel('Acceleration (???)');
%
% subplot(4,1,3)
% plot(Data.No,[1 ;diff(Data.T1)])
% set(gca,...
%     'XLim',XLim,...
%     'TickDir','out',...
%     'XMinorTick','on',...
%     'YMinorTick','on',...
%     'Box','on',...
%     'XGrid','on'...
%     )
% subplot(4,1,4)
% plot(Data.No,apStd)
% hold on
% plot(Data.No(LowNoise),apStd(LowNoise),'r.')
% hold off
% set(gca,...
%     'XLim',XLim,...
%     'TickDir','out',...
%     'XMinorTick','on',...
%     'YMinorTick','on',...
%     'Box','on',...
%     'XGrid','on'...
%     )
% xlabel('Sample no.');
%
% figure(2)
%
% %plot(Data.No,[1 ;abs(diff(Data.T1))]./apStd)
% plot(Data.No,Data.T2,'g-')
% hold on
% plot(Data.No,Data.T1,'b-')
% plot(Data.No([PenStart PenStop]),Data.T1([PenStart PenStop]),'r*')
% hold off
%
% set(gca,...
%  ...   'XLim',XLim,...
%     'TickDir','out',...
%     'XMinorTick','on',...
%     'YMinorTick','on',...
%     'Box','on',...
%     'XGrid','on'...
%     )
%
% figure(3)
% plot(Data.No,Data.T2,'g.-')
% hold on
% plot(Data.No,Data.T1,'b.-')
% plot(Data.No([PenStart PenStop]),Data.T1([PenStart PenStop]),'r*')
% hold off
% legend('T2', 'T1', 'AutoPick',0)
% set(gca,...
%     'XLim',XLim,...
%     'TickDir','out',...
%     'XMinorTick','on',...
%     'YMinorTick','on',...
%     'Box','on',...
%     'XGrid','on'...
%     )
% grid on
% h=title(FileName);
% set(h,'Interpreter','none');
% ylabel('Temperature (°C)');
% xlabel('Sample no.');
% figure(2)