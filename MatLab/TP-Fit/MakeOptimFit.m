function Res=MakeOptimFit(Data,k,rc,varargin)
% varargin is a parameter value list. If the number of elements of varargin
% is not even, then the first element is assumed to be a model matrix M

% WARNING Moved from standart deviation to Least Squares!!!

Opts.tSft=[]; % leave empty to optimize tSft or supply fixed tSft
[Opts,M]=ParseFunOpts(Opts,varargin);

if ~isempty(M)   %exist('M','var')
    M=M{1};
    RefDat=GetRefDecay(k,rc,'M',M,'NearestWarning',false);
else
    RefDat=GetRefDecay(k,rc,'ModelType',Data.ModelType);
end

MinSft=-150;
MaxSft=Data.Picks.Window(1);

if isempty(Opts.tSft)
    % Do optimization
    [BestSft,StdDev]=fminbnd(@(tSft)Qual(tSft,Data,RefDat),...
        MinSft,MaxSft,...
        optimset('TolX',0.1)); %'Display','iter'
else
    % Use fixed tSft
    BestSft=Opts.tSft;
    StdDev=Qual(Opts.tSft,Data,RefDat);
end

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
NLSqr=sqrt((Diff(:)'*Diff(:))/(length(Diff)));

