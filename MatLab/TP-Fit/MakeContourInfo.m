function Data=MakeContourInfo(Data,varargin)

Opts.tSft=[]; % leave empty to optimize tSft or supply fixed tSft
[Opts,M]=ParseFunOpts(Opts,varargin);

M=LoadModel(Data.ModelType); % load('DecayMatrix.mat');

Ni=length(M.ks);
Nj=length(M.rcs);

Contour.k=zeros(Ni,Nj);
Contour.rc=zeros(Ni,Nj);
Contour.BestSft=zeros(Ni,Nj);
Contour.StdDev=zeros(Ni,Nj);
Contour.NLSqr=zeros(Ni,Nj);
Contour.Tf=zeros(Ni,Nj);
Contour.Tf_1_3=zeros(Ni,Nj);
        
h = waitbar(0,'Please wait...');
for i=1:Ni
    for j=1:Nj
        Res=MakeOptimFit(Data,M.ks(i),M.rcs(j),M,'tSft',Opts.tSft); % ,'tSft',0
        Contour.k(i,j)=M.ks(i);
        Contour.rc(i,j)=M.rcs(j);
        Contour.BestSft(i,j)=Res.BestSft;
%        Contour.StdDev(i,j)=Res.StdDev;
        Contour.NLSqr(i,j)=Res.NLSqr;
        Contour.Tf(i,j)=Res.Fit(2);
        Contour.Tf_1_3(i,j)=Res.PartFit(2);
    end
    waitbar(i/length(M.ks),h);
end
close(h);
Contour.tSfts=Res.tSfts;
Data.Contour=Contour;