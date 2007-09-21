function Data=APCT_Fit(Data)
% Old script that illustrates the command lin use of TP-Fit


% if ~exist('Data','var');
%     %Data=ReadWinTempDat('1325b08.dat');
%     %Data.T=Data.TRaw;
%     
%     % AddPicks
%     %Picks.t0=1929;
%     Data=ImportAdaraData('1023a08h.New',2);
%     Picks.t0=2605;
%     
%     Data.tr=Data.t-Picks.t0; % Relative time (s)
%     Picks.Window=[100 650]; % Window used for evaluation
%     Picks.UsedDat=find( ( (Data.tr>=Picks.Window(1))&(Data.tr<=Picks.Window(2))));
%     Data.Picks=Picks;
%     Session.XLim=[min(Data.tr) max(Data.tr)];
%     Session.YLim=[min(Data.T) max(Data.T)];
%     Data.Session=Session;
%     Data=MakeContourInfo(Data);
% end

if ~exist('Data','var')
    Data=ImportTemperatureData;
end

if ~isfield(Data,'Picks')
    Data=GetPicks(Data);
end

figure(1);
clf;
set(gcf,'Position',[5 381 1000 600]);
[Res,Data]=MakeFit(Data,1,3.5e6);
PlotFitResults(Data);

SaveSession(Data);
return
figure(2);
set(gcf,'Position',[725 99 663 887]);
PlotContours(Data);

KeepGoing=true;
while KeepGoing
    [k,rc,botton]=ginput(1);
    if botton==1
        hold on
        plot(k,rc,'ko','MarkerFaceColor',[1 1 1]);
        hold off
        figure(1)
        [Res,Data]=MakeFit(Data,k,rc*1e6);
        PlotFitResults(Data);
        figure(2);
    else
        KeepGoing=false;
    end
end
    
