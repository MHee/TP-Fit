function Res=MakeOptimFit(Data,k,rc,M)
% WARNING Moved from standart deviation to Least Squares!!!

if exist('M','var')
    RefDat=GetRefDecay(k,rc,'M',M,'NearestWarning',false);
else
    RefDat=GetRefDecay(k,rc,'ModelType',Data.ModelType);
end

MinSft=-150;
MaxSft=Data.Picks.Window(1);

[BestSft,StdDev]=fminbnd(@(tSft)Qual(tSft,Data,RefDat),...
    MinSft,MaxSft,...
    optimset('TolX',0.1)); %'Display','iter'

SDat.t=Data.tr(Data.Picks.UsedDat);
SDat.T=interp1(RefDat.t+BestSft,RefDat.T,SDat.t,'cubic');
Fit=polyfit(SDat.T,Data.T(Data.Picks.UsedDat),1);

InPartFit=[round(2*length(SDat.t)/3):length(SDat.t)];
PartFit=polyfit(SDat.T(InPartFit),Data.T(Data.Picks.UsedDat(InPartFit)),1);

Res.BestSft=BestSft;
%Res.StdDev=std(Data.T(Data.Picks.UsedDat)-polyval(Fit,SDat.T));
Res.NLSqr=StdDev;

Res.Fit=Fit;
Res.PartFit=PartFit;
Res.tSfts=[MinSft MaxSft];


function NLSqr=Qual(tSft,Data,RefDat)
SDat.t=Data.tr(Data.Picks.UsedDat);
SDat.T=interp1(RefDat.t+tSft,RefDat.T,SDat.t,'cubic');
Fit=polyfit(SDat.T,Data.T(Data.Picks.UsedDat),1);
Diff=Data.T(Data.Picks.UsedDat)-polyval(Fit,SDat.T);
%StdDev=std(Diff);
NLSqr=sqrt((Diff(:)'*Diff(:))/(length(Diff)-1));

