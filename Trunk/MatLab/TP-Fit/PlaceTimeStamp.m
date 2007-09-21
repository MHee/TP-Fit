function h=PlaceTimeStamp(varargin)
%PlaceTimeStamp Plots a time stamp on the current plot

Opts.DateFmt=0;
Opts.PreStr=[];
Opts=ParseFunOpts(Opts,varargin);

TimeStr=datestr(now,Opts.DateFmt);

h=annotation('textbox',...
    'FontName','Arial',...
    'FontSize',8,...
    'HorizontalAlignment','right',...
    'VerticalAlignment','middle',...
    'LineStyle','none',... 'none'
    'Margin',1,...
    'String',[Opts.PreStr TimeStr]);

Pos=get(h,'Position');
aPos=get(gca,'Position');
%Pos(1:2)=[1-Pos(3) 0];
Pos(1:2)=[aPos(1)+aPos(3)-Pos(3) 0];

set(h,'Position',Pos);

%get(h)