function PlotContours(Data,varargin)
%Create contour plot for TP-Fit that is used for data exploring


Cnt=Data.Contour;
%[minDev,minDevIdx]=min(Cnt.StdDev(:));
[minDev,minDevIdx]=min(Cnt.NLSqr(:));

Opts.hResults=[];
Opts.hTPFit=[];

% Start with best fitting defaults
Opts.k=Cnt.k(minDevIdx);
Opts.rc=Cnt.rc(minDevIdx);

[Opts, noOpt]=ParseFunOpts(Opts,varargin);

Opts

hResults=Opts.hResults;

%if exist('hResults','var')
if ishandle(hResults)
    UDat.Data=Data;
    UDat.hResults=hResults;
    UDat.hTPFit=Opts.hTPFit;
    set(gcf,'UserData',UDat);
    set(gcf,'Pointer','fullcrosshair');
    [Res,Data]=MakeFit(UDat.Data,Opts.k,Opts.rc);
    hFig=gcf;
    figure(hResults);
    PlotFitResults(Data);
    figure(hFig);
end
%end


clf;


% %%%%%%%%%%%%%%%%%
subplot(4,1,1);
%[C,h1]=contourf(Cnt.k,Cnt.rc*1e-6,Cnt.StdDev);
[C,h1]=contourf(Cnt.k,Cnt.rc*1e-6,Cnt.NLSqr);
set(h1,'ShowText','on','TextStep',get(h1,'LevelStep')*2,...
        'ButtonDownFcn','PlotContoursHandler(gcbo,gcf)');

%MinLevel=min(get(h1,'LevelList'))
levels=get(h1,'LevelList');
MinLevel=levels(2);

hMinPatch=findobj(h1,'Type','Patch','UserData',MinLevel);
set(hMinPatch,'EdgeColor','w');
MinXDat=get(hMinPatch,'XData');
MinYDat=get(hMinPatch,'YData');

hold on
plot(Cnt.k(minDevIdx),Cnt.rc(minDevIdx)*1e-6,...
    'kp','MarkerFaceColor','r','MarkerSize',12,...
        'ButtonDownFcn','PlotContoursHandler(gcbo,gcf)');

plot(Opts.k,Opts.rc*1e-6,...
    'ko','MarkerFaceColor',[1 1 1],'Tag','Marker');    

text(0.98,0.98,...
    sprintf('%s%s%s%s   %s',...
    Data.Info.Site,Data.Info.Hole,Data.Info.Core,Data.Info.CoreType,...
    Data.Info.ToolType),...
    'VerticalAlignment','top',...
    'HorizontalAlignment','right',...
    'FontWeight','bold',...
    'Color','w',...
    'BackgroundColor','none',...
    'EdgeColor','none',...
    'Units','normalized');

hold off
set(gca,'XMinorTick','on',...
    'YMinorTick','on');
set(gca,'XTickLabel',[]);
grid on
ylabel('\rhoC (MJ/(m³K))');
title('Standart deviation(k, \rhoC) [°C]');

% %%%%%%%%%%%%%%%%%
subplot(4,1,2);
[C,h2]=contourf(Cnt.k,Cnt.rc*1e-6,Cnt.Tf);
set(h2,'ShowText','on','TextStep',get(h2,'LevelStep')*2,...
        'ButtonDownFcn','PlotContoursHandler(gcbo,gcf)');

hold on
plot(Cnt.k(minDevIdx),Cnt.rc(minDevIdx)*1e-6,'kp',...
    'MarkerFaceColor','r','MarkerSize',12,...
    'ButtonDownFcn','PlotContoursHandler(gcbo,gcf)');

plot(Opts.k,Opts.rc*1e-6,...
    'ko','MarkerFaceColor',[1 1 1],'Tag','Marker');    
    
PlotMinCont(MinXDat,MinYDat);    
hold off


grid on
set(gca,'XTickLabel',[]);
set(gca,'XMinorTick','on','YMinorTick','on');
ylabel('\rhoC (MJ/(m³K))');
title('Estimated temperature(k, \rhoC) [°C]');

% %%%%%%%%%%%%%%%%%
subplot(4,1,3);
[C,h3]=contourf(Cnt.k,Cnt.rc*1e-6,Cnt.BestSft);
set(h3,'ShowText','on','TextStep',get(h3,'LevelStep')*2,...
        'ButtonDownFcn','PlotContoursHandler(gcbo,gcf)');

hold on
plot(Cnt.k(minDevIdx),Cnt.rc(minDevIdx)*1e-6,'kp','MarkerFaceColor','r',...
    'MarkerSize',12,...
    'ButtonDownFcn','PlotContoursHandler(gcbo,gcf)');

plot(Opts.k,Opts.rc*1e-6,...
    'ko','MarkerFaceColor',[1 1 1],'Tag','Marker');    

PlotMinCont(MinXDat,MinYDat);    
hold off

grid on
set(gca,'XTickLabel',[]);
set(gca,'XMinorTick','on','YMinorTick','on');
ylabel('\rhoC (MJ/(m³K))');
%xlabel('Thermal conductivity (W/(m K))');
title('Time-shift(k, \rhoC) [s]');
%return

% %%%%%%%%%%%%%%%%%
subplot(4,1,4);
DiffT=Cnt.Tf-Cnt.Tf_1_3;
[Dummy,MinDiffT]=min(abs(DiffT(:)));
%DiffScale=round((31*DiffT)/max(max(abs(DiffT))))+32;
[C,h4]=contourf(Cnt.k,Cnt.rc*1e-6,abs(DiffT));
set(h4,'ShowText','on','TextStep',get(h4,'LevelStep')*2,...
        'ButtonDownFcn','PlotContoursHandler(gcbo,gcf)');

hold on
plot(Cnt.k(MinDiffT),Cnt.rc(MinDiffT)*1e-6,'kp',...
    'MarkerFaceColor','r','MarkerSize',12,...
    'ButtonDownFcn','PlotContoursHandler(gcbo,gcf)');

plot(Opts.k,Opts.rc*1e-6,...
    'ko','MarkerFaceColor',[1 1 1],'Tag','Marker'); 

% Report Best Fit to TP-Fit
Res=MakeFit(UDat.Data,Opts.k,Opts.rc);
if ishandle(UDat.hTPFit)
    TPFit_Window('ReportResults',UDat.hTPFit,[],UDat.hTPFit,Res,UDat.hTPFit);
end


PlotMinCont(MinXDat,MinYDat);
    
hold off

grid on
set(gca,'XMinorTick','on','YMinorTick','on');
ylabel('\rhoC (MJ/(m³K))');
xlabel('Thermal conductivity (W/(m K))');
title('Window-based \DeltaT(k, \rhoC) [°C]');


% hMinStds2=copyobj(hMinPatch,h2);
% hMinStds3=copyobj(hMinPatch,h3);
% hMinStds4=copyobj(hMinPatch,h4);
% set([ hMinStds3 hMinStds4],'FaceColor','none')

function PlotMinCont(x,y);
if ~isempty(x)
    if ~iscell(x)
        x={x};
        y={y};
    end
    for i=1:length(y)
        plot(x{i},y{i},'w',...
            'ButtonDownFcn','PlotContoursHandler(gcbo,gcf)');
    end
end