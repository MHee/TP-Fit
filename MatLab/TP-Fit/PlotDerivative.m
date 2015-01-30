function PlotDerivative(varargin)
% PLOTDERIVATIVE   Plot time derivative of temperatures in TP-Fit data
%   This is a m-file skeleton. Just replace the Dummy text and you are
%   ready to go!!!
%   
%   Example
%       ...=PlotDerivative
%
%   See also: helprep, contentsrpt

%   Copyright (C) 2007  Martin Heesemann <heesema AT uni-bremen DOT de>

%% This file is part of TP-Fit.
% 
%   TP-Fit is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
% 
%   TP-Fit is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
% 
%   You should have received a copy of the GNU General Public License
%   along with TP-Fit.  If not, see <http://www.gnu.org/licenses/>.


%% Info
%   Created: 21-Dec-2007
%
%   * TODO: Sample todo
%   * FIXME: Sample fixme
%
 
%% Define options
Opts.PlotTFitRes=true;
Opts.NSft=[];
Opts.tSft=[];
Opts.Figure=[];
Opts.hTPFit=[];
Opts.PlotTs=false;
[Opts, noOpt]=ParseFunOpts(Opts,varargin);

if isempty(noOpt)
    Data=get(gcf,'UserData');
    if isempty(Data)
        error('No Data to plot!!!')
    end
else
    Data=noOpt{1};
    set(gcf,'UserData',Data);
end


%% Main code
Dt=diff(Data.tr);

t=Data.tr(1)-0.5*diff(Data.tr(1:2))+cumsum(Dt);
DT=diff(Data.T)./Dt;
AvDT=MovingAverage(DT);
Av_t=MovingAverage(t);

clf;
h(1)=subplot(2,1,1);
% Plot unused region
hold on
XLim=[min(Data.tr) max(Data.tr)];
YLim=[min(Data.T) max(Data.T)];
patch([XLim(1) XLim(1) Data.Picks.Window(1) Data.Picks.Window(1)],...
    [YLim fliplr(YLim)],...
    .9*[1 1 1],...
    'EdgeColor','none');
patch([XLim(2) XLim(2) Data.Picks.Window(2) Data.Picks.Window(2)],...
    [YLim fliplr(YLim)],...
    .9*[1 1 1],...
    'EdgeColor','none');
plot([0 0],YLim,'k--','LineWidth',1.5);
hold on

plot(Data.tr,Data.T,'.-');
ylabel('Temperature (°C)');
text(0.95,0.95,...
    sprintf('%s%s%s%s   %s',...
    Data.Info.Site,Data.Info.Hole,Data.Info.Core,Data.Info.CoreType,...
    Data.Info.ToolType),...
    'Units','normalized',...
    'VerticalAlignment','top',...
    'HorizontalAlignment','right',...
    'BackgroundColor','w',...
    'EdgeColor','k');


h(2)=subplot(2,1,2);
semilogy(Av_t,abs(AvDT),'g-','LineWidth',6);
hold on;

Pos=find((DT>0));
Neg=find((DT<0));
semilogy(t(Pos),DT(Pos),'r.');
semilogy(t(Neg),-DT(Neg),'b.');
%semilogy(t,abs(DT),'k:');
xlabel('Time (s)');
ylabel('Temperatuer change (°C/s)');
linkaxes(h,'x');
set(gca,...
    'YGrid','on',...
    'YMinorTick','on',...
    'YMinorGrid','on',...
    'YLim',[1e-4,Inf]);


function y=MovingAverage(x)
m=5;
n=length(x);
z = [0 cumsum(x(:)')];
y = ( z(m+1:n+1) - z(1:n-m+1) ) / m;

