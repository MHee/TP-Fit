function PlotContoursHandler(hObj,hFig)
UDat=get(hFig,'UserData');
if isempty(UDat)
    return
end

if strcmp(get(hObj,'Type'),'axes')
    % No Contours
    hAx=hObj;
else
    % Contours
    hAx=get(hObj,'Parent');
end
Pos=get(hAx,'CurrentPoint');
Pos=Pos(1,1:2);
k=Pos(1);
rc=Pos(2);

kLim=get(hAx,'XLim');
rcLim=get(hAx,'YLim');

if (k<kLim(1))
    k=kLim(1);
elseif (k>kLim(2))
    k=kLim(2);
end

if (rc<rcLim(1))
    rc=rcLim(1);
elseif (rc>rcLim(2))
    rc=rcLim(2);
end

[Res,Data]=MakeFit(UDat.Data,k,rc*1e6);
if ishandle(UDat.hTPFit)
    TPFit_Window('ReportResults',UDat.hTPFit,[],UDat.hTPFit,Res,UDat.hTPFit);
end

if ishandle(UDat.hResults)
    figure(UDat.hResults);
else
    close(hFig);
    return
end

PlotFitResults(Data,'hTPFit',UDat.hTPFit);
figure(hFig);

h=findobj('Tag','Marker');
set(h,'XData',Res.k,'YData',Res.rc*1e-6);