function [Res,Data]=MakeFit(Data,k,rc,M)

if exist('M','var')
    RefDat=GetRefDecay(k,rc,'M',M);
else
    RefDat=GetRefDecay(k,rc,'ModelType',Data.ModelType);
end
OptimRes=MakeOptimFit(Data,k,rc);

tSfts=unique([-50:2.5:Data.Picks.Window(1) 0 Data.Picks.Window(1) OptimRes.BestSft]); %OptimRes.BestSft-20

UsedDat=Data.Picks.UsedDat;
SDat.t=Data.tr(UsedDat);
InPartFit=[round(2*length(SDat.t)/3):length(SDat.t)];

N=length(tSfts);

SDat.T=zeros(N,length(SDat.t));
PartFit=zeros(N,2);
Fit=zeros(N,2);
StdDev=zeros(1,N);
StdDev=zeros(1,N);

for i=1:N
    tSft=tSfts(i);
    SDat.T(i,:)=interp1(RefDat.t+tSft,RefDat.T,SDat.t,'cubic');
    PartFit(i,1:2)=polyfit(SDat.T(i,InPartFit)',Data.T(UsedDat(InPartFit)),1);
    Fit(i,1:2)=polyfit(SDat.T(i,:)',Data.T(UsedDat),1);
    
    Diff=Data.T(UsedDat)-polyval(Fit(i,1:2),SDat.T(i,:))';
    StdDev(i)=std(Diff);
    
    NLSqr(i)=sqrt((Diff(:)'*Diff(:))/(length(Diff)-1));
end
[dummy,Res.BestSft]=min(StdDev);
Res.T=SDat.T;
Res.t=SDat.t;
Res.k=RefDat.k;
Res.rc=RefDat.rc;
Res.Fit=Fit;
Res.PartFit=PartFit;
Res.tSfts=tSfts;
Res.StdDev=StdDev;
Res.NLSqr=NLSqr;
Res.InPartFit=InPartFit;
Data.Res=Res;
