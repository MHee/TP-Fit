function PlotFitResults(varargin)
% 
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

if isempty(Opts.NSft)
    NSft=Data.Res.BestSft;
else
    NSft=Opts.NSft;
end

if ~isempty(Opts.tSft)
    if ~( (Opts.tSft<min(Data.Res.tSfts)) || (Opts.tSft>max(Data.Res.tSfts)) )
        [Dummy,NSft]=min(abs(Data.Res.tSfts-Opts.tSft));
    end
end

if ~isempty(Opts.Figure)
    figure(Opts.Figure)
end

if ~Opts.PlotTs
    set(gcf,'Pointer','Arrow');
end

clf;

% Raw data plot
hDat=subplot(3,1,1);
hold on
XLim=Data.Session.XLim;
YLim=Data.Session.YLim;

% Make shure results are in plot-Limits
MinY=min([Data.Res.Fit(NSft,2) Data.Res.PartFit(NSft,2)]);
MaxY=max([Data.Res.Fit(NSft,2) Data.Res.PartFit(NSft,2)]);
if YLim(1)> MinY
    YLim(1) = MinY-0.2;
end
if YLim(2) < MaxY
    YLim(2) = MaxY+0.2;
end

% Plot unused region
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

% Plot resulting temperatures
plot(XLim,Data.Res.Fit(NSft,2)*[1 1],'--','Color',[1 .7 .7],'LineWidth',1.5);
plot(XLim,Data.Res.PartFit(NSft,2)*[1 1],'k:');

plot(XLim,Data.Res.Fit(NSft,2)*[1 1],'ko','MarkerFaceColor',[1 .7 .7]);
plot(XLim,Data.Res.PartFit(NSft,2)*[1 1],'.');

RefDat=GetRefDecay(Data.Res.k,Data.Res.rc,...
    'ts',[0 logspace(0,4,50)],...
    'ModelType',Data.ModelType);

plot(RefDat.t+Data.Res.tSfts(NSft),...
    Data.Res.Fit(NSft,1)*RefDat.T+Data.Res.Fit(NSft,2),...
    'Color',[1 .7 .7],'LineWidth',5);


if (isfield(Data,'OrigData') && isfield(Data.OrigData,'T2'))
    plot(Data.tr, Data.OrigData.T2,'.-','Color',[.7 .7 1]);
end
plot(Data.tr, Data.T,'.-');

%Plot Selection markers
plot(Data.tr(Data.Picks.UsedDat(1)), Data.T(Data.Picks.UsedDat(1)),'k^','LineWidth',1.5);
plot(Data.tr(Data.Picks.UsedDat(end)), Data.T(Data.Picks.UsedDat(end)),'kv','LineWidth',1.5);
plot(Data.tr(Data.Picks.UsedDat(Data.Res.InPartFit(1))),...
     Data.T(Data.Picks.UsedDat(Data.Res.InPartFit(1))),'kd','LineWidth',1.5);

if (Opts.PlotTFitRes && isfield(Data,'OrigData') && isfield(Data.OrigData,'Model'))
    plot(XLim,Data.OrigData.Fit.Tf*[1 1],':','Color',[1 0 0],'LineWidth',1.5);
    plot(Data.OrigData.Model.t,...
        Data.OrigData.Fit.b*Data.OrigData.Model.T+Data.OrigData.Fit.Tf,'r');
    fprintf('TFit-Results (TPFit-TFit: %.3f °C)\n',...
        Data.Res.Fit(NSft,2)-Data.OrigData.Fit.Tf);
    TFitRes.Fit=Data.OrigData.Fit;
    TFitRes.Seds=Data.OrigData.Props.Seds;
    structree(TFitRes);
end

% plot(Data.tr(Data.Picks.UsedDat), Data.T(Data.Picks.UsedDat),'g.','MarkerSize',7);
% plot(Data.tr(Data.Picks.UsedDat(Data.Res.InPartFit)),...
%     Data.T(Data.Picks.UsedDat(Data.Res.InPartFit)),'r.','MarkerSize',5);

% plot(Data.tr(Data.Picks.UsedDat), Data.T(Data.Picks.UsedDat),'g--','LineWidth',5);
% 
% plot(Data.tr([Data.Picks.UsedDat(1) Data.Picks.UsedDat(end)]),...
%     Data.T([Data.Picks.UsedDat(1) Data.Picks.UsedDat(end)]),...
%     'go','MarkerFaceColor','g','MarkerSize',5);
% 
% DotLocs=round(linspace(Data.Res.InPartFit(1),Data.Res.InPartFit(end),10));
% plot(Data.tr(Data.Picks.UsedDat(DotLocs)),...
%     Data.T(Data.Picks.UsedDat(DotLocs)),'r.','Color','r','LineWidth',1.5);...'ko','MarkerFaceColor','r','MarkerSize',5);

% plot(Data.tr([Data.Picks.UsedDat(DotLocs(1)) Data.Picks.UsedDat(end)]),...
%     Data.T([Data.Picks.UsedDat(DotLocs(1)) Data.Picks.UsedDat(end)]),...
%     'k^','MarkerFaceColor','r','MarkerSize',5);


set(gca,...
    'Layer','top',...
    'Box','on',...
    'TickDir','out',...
    'XMinorTick','on',...
    'YMinorTick','on',...
    'XLim',XLim,...
    'YLim',YLim,...
    'XAxisLocation','top');
%grid on;
xlabel('Time after penetration (s)');
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

% text(0.6,0.95,...
%     sprintf('Exp %s - %s%s%s%s @ %s mbsf\n%s #%s',...
%     Data.Info.Expedition,...
%     Data.Info.Site,Data.Info.Hole,Data.Info.Core,Data.Info.CoreType,Data.Info.Depth,...
%     Data.Info.ToolType,Data.Info.ToolID),...
%     'Units','normalized',...
%     'VerticalAlignment','top',...
%     'HorizontalAlignment','center',...
%     'BackgroundColor','w',...
%     'EdgeColor','k');

hold off

%
% Diff Plot
%
hDiff=subplot(3,1,2);

% Plot unused region
YLim=[1e-4 1];
semilogy([0 0],YLim,'k--','LineWidth',1.5);
hold on
patch([XLim(1) XLim(1) Data.Picks.Window(1) Data.Picks.Window(1)],...
    [YLim fliplr(YLim)],...
    .9*[1 1 1],...
    'EdgeColor','none');
patch([XLim(2) XLim(2) Data.Picks.Window(2) Data.Picks.Window(2)],...
    [YLim fliplr(YLim)],...
    .9*[1 1 1],...
    'EdgeColor','none');
semilogy([0 0],YLim,'k--','LineWidth',1.5);
%hold on

InModel=find( (Data.tr-Data.Res.tSfts(NSft))>=0 );
tDiff=Data.tr(InModel);
InWin=find( ((tDiff>=Data.Picks.Window(1))&(tDiff<=Data.Picks.Window(2))) );
RefDat=GetRefDecay(Data.Res.k,Data.Res.rc,...
    'ts',tDiff-Data.Res.tSfts(NSft),...
    'ModelType',Data.ModelType);

Diff=Data.T(InModel)-(Data.Res.Fit(NSft,1)*RefDat.T+Data.Res.Fit(NSft,2));
Pos=find(Diff>0);
Neg=find(Diff<0);

% MeanWinDiff=mean(abs(Diff(InWin)));
% hFitWin=semilogy(Data.Picks.Window,MeanWinDiff*[1 1],'k--','LineWidth',2);

StdWinDiff=std(Diff(InWin));
hFitWin=semilogy(Data.Picks.Window,StdWinDiff*[1 1],'k--','LineWidth',2);

hold on

%hNeg=semilogy(tDiff(Neg),-Diff(Neg),'o','MarkerFaceColor','w','MarkerSize',4);
%hPos=semilogy(tDiff(Pos),Diff(Pos),'.','MarkerSize',12); %,'MarkerFaceColor','b'

hNeg=semilogy(tDiff(Neg),-Diff(Neg),'bv','MarkerFaceColor','b','MarkerSize',4);
hPos=semilogy(tDiff(Pos),Diff(Pos),'r^','MarkerFaceColor','r','MarkerSize',4); %,'MarkerFaceColor','b'


%Plot selection markers
plot(tDiff(Data.Picks.UsedDat(1)-InModel(1)+1), abs(Diff(Data.Picks.UsedDat(1)-InModel(1)+1)),'k^','LineWidth',1.5);
plot(tDiff(Data.Picks.UsedDat(end)-InModel(1)+1), abs(Diff(Data.Picks.UsedDat(end)-InModel(1)+1)),'kv','LineWidth',1.5);
plot(tDiff(Data.Picks.UsedDat(Data.Res.InPartFit(1))-InModel(1)+1),...
     abs(Diff(Data.Picks.UsedDat(Data.Res.InPartFit(1))-InModel(1)+1)),'kd','LineWidth',1.5);


hold off
set(gca,...
    'Layer','top',...
    'Box','on',...
    'TickDir','out',...
    'XMinorTick','on',...
    'YMinorTick','on',...
    'XLim',get(hDat,'XLim'),...
    'YLim',YLim);
xlabel('Time after penetration (s)');
%ylabel('Temperature residual \epsilon_T + T_e \epsilon_\Theta (°C)');
ylabel('Temperature residual \epsilon (°C)');
grid on
legend([hPos,hNeg,hFitWin],{'Data above model','Data below model','\epsilon_{RMS}'},...
    'Location','North'); % 'Best'



%
% Model vs Data plot
%
subplot(3,2,5);
Res=Data.Res;
xx=[0 max(Res.T(NSft,:))];
yy=polyval(Res.PartFit(NSft,:),xx);
yy1=polyval(Res.Fit(NSft,:),xx);

hAll=plot(xx,yy1,'-','Color',[1 .7 .7],'LineWidth',1.5);
hold on;
hPart=plot(xx,yy,'k-');
hTAll=plot(xx(1),yy1(1),'ko','MarkerFaceColor',[1 .7 .7]);
%hTPart=plot(xx(1),yy(1),'ko','MarkerFaceColor','r','MarkerSize',5);
hTPart=plot(xx(1),yy(1),'k.');

plot(Res.T(NSft,:),Data.T(Data.Picks.UsedDat),'.');

%Plot Selection markers
plot(Res.T(NSft,1),Data.T(Data.Picks.UsedDat(1)),'k^','LineWidth',1.5);
plot(Res.T(NSft,end),Data.T(Data.Picks.UsedDat(end)),'kv','LineWidth',1.5);
plot(Res.T(NSft,Data.Res.InPartFit(1)),Data.T(Data.Picks.UsedDat(Data.Res.InPartFit(1))),'kd','LineWidth',1.5);

hold off;
grid on;
set(gca,...    
    'Layer','top',...
    'Box','on',...
    'TickDir','out',...
    'XMinorTick','on',...
    'YMinorTick','on');

%text(0.02,0.9,'Estimated T','Units','normalized','Color','k');
%text(0.02,0.8,sprintf('%.2f°C',yy1(1)),'Units','normalized','Color','g');
%text(0.02,0.7,sprintf('%.2f°C',yy(1)),'Units','normalized','Color','r');
legend([hTAll hTPart hAll,hPart],...
    {sprintf('%.2f°C',yy1(1)), sprintf('%.2f°C',yy(1)),'1/1 window','1/3 window'},...
    'Location','SouthEast'); %'Best'

xlabel('Reference Model');
%xlabel('\sffamily Reference model $\tilde{\Theta}(t-t_{Sft})$','Interpreter','latex')
ylabel('Measured temperature (°C)');

%
% Time Sft plot
%
hTSft=subplot(3,2,6);
plot(Res.tSfts,Res.StdDev,'k.-')
hold on
plot(Res.tSfts(NSft),Res.StdDev(NSft),'o');
xlabel('Time-shift (s)');
ylabel('\epsilon_{RMS} (°C)');
set(gca,...
    'Layer','top',...
    'Box','on',...
    'TickDir','out',...
    'XMinorTick','on',...
    'YMinorTick','on',...
    'YAxisLocation','right',...
    'ButtonDownFcn','PlotFitResultsHandler(''StdAxes'')');

grid on;
hTxt=text(0.04,0.95,...
    sprintf('k= %.2f (W/(m K)\n\\rhoC= %.2f (MJ/(m³ K)\ntime-shift= %.1f s\n\\epsilon_{RMS}= %.1f (mK)',...
    Data.Res.k,Data.Res.rc*1e-6,Res.tSfts(NSft),Res.StdDev(NSft)*1e3),...
    'Units','normalized',...
    'VerticalAlignment','top',...
    ...'HorizontalAlignment','right',...
    'BackgroundColor','w',...
    'EdgeColor','k');
if ~isempty(Opts.hTPFit)
    set(hTxt,...
        'ButtonDownFcn','PlotFitResultsHandler(''ParamTab'',gcbo,gcf)',...
        'UserData',Opts.hTPFit)
end

if Opts.PlotTs
    % Change of Formation temperature overlay
    set(hTSft,'Box','off');
    hFT=axes('Position',get(hTSft,'Position'));
    plot(Res.tSfts,Res.Fit(:,2),'--','Color',[1 .7 .7],'LineWidth',1.5);
    hold on
    plot(Res.tSfts,Res.PartFit(:,2),'k:');
    plot(Res.tSfts(NSft),Res.Fit(NSft,2),'ko','MarkerFaceColor',[1 .7 .7]);
    plot(Res.tSfts(NSft),Res.PartFit(NSft,2),'k.');
    hold off
    ylabel('Estimated temperature (°C)');
    set(hFT,'Color','none',...
        'Box','off',...
        'XAxisLocation','top',...
        'XTickLabel',[],...
        'ButtonDownFcn','PlotFitResultsHandler(''TsAxes'',gcbo)');
    linkaxes([hTSft hFT],'x');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % Diff plot
% FPos=get(gcf,'Position');
% FPos(2)=FPos(2)-300;
% FPos(4)=300;
% hParentF=gcf;
% 
% figure(8)
% clf;
% set(gcf,'Position',FPos);
% 
% 
% figure(hParentF);