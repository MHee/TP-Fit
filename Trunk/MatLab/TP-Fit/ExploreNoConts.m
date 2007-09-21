function ExploreNoConts(Data,varargin)
%Create contour plot for TP-Fit that is used for data exploring

Opts.hResults=[];
Opts.hTPFit=[];
[Opts, noOpt]=ParseFunOpts(Opts,varargin);


hResults=Opts.hResults;

%if exist('hResults','var')
if ishandle(hResults)
    UDat.Data=Data;
    UDat.hResults=hResults;
    UDat.hTPFit=Opts.hTPFit;
    set(gcf,'UserData',UDat);
    set(gcf,'Pointer','fullcrosshair');
%    [Res,Data]=MakeFit(UDat.Data,Cnt.k(minDevIdx),Cnt.rc(minDevIdx));
    hFig=gcf;
    figure(hResults);
    PlotFitResults(Data);
    figure(hFig);
end
%end


clf;


% %%%%%%%%%%%%%%%%%
h=axes;


plot(Data.Res.k,Data.Res.rc*1e-6,...
    'ko','MarkerFaceColor',[1 1 1],'Tag','Marker');    

hold off
set(h,...
    'XMinorTick','on',...
    'YMinorTick','on',...
    'TickDir','out',...
    'XLim',[0.5 2.5],...
    'YLim',[2.3 4.3],...
    'ButtonDownFcn','PlotContoursHandler(gcbo,gcf)');


grid on

title(sprintf('%s%s%s%s   %s',...
    Data.Info.Site,Data.Info.Hole,Data.Info.Core,Data.Info.CoreType,...
    Data.Info.ToolType));

ylabel('\rhoC (MJ/(m³K))');
xlabel('Thermal conductivity (W/(m K))');


