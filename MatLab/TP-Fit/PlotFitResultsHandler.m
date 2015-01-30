function PlotFitResultsHandler(Obj,hObj,hResFig)
set(gca,'Interruptible','off');
pause(0.3);
switch Obj
    case 'StdAxes'
        %disp('StdAxes');
        PlotFitResults('PlotTs',1);
        set(gcf,'Pointer','fullcrosshair');
    case 'TsAxes'
        %get(gcf,'SelectionType')
        if strcmp(upper(get(gcf,'SelectionType')),'ALT')
            PlotFitResults;
            set(gcf,'Pointer','arrow');
        else
            tSft=get(hObj,'CurrentPoint');
            tSft=tSft(1);
            fprintf('Time-Sft: %.3f\n', tSft);
            PlotFitResults('PlotTs',1,'tSft',tSft);
        end
    case 'ParamTab'
        Data=get(hResFig,'UserData');
        hTPFit=get(hObj,'UserData');
        hSel=figure(63003);
        set(hSel,'Name','Select Parameters','NumberTitle','off');
        ExploreNoConts(Data,'hResults',hResFig,'hTPFit',hTPFit);

    otherwise
        disp(['Cannot handle ' Obj]);
end