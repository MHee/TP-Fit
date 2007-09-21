function Data=CreateSyntheticData(varargin)
% This function creates synthetic downhole tool data to test TP-Fit


Opts.k=1;
Opts.rc=3.5e6;
Opts.ts=[0:1:1200];
Opts.ModelType='APCT_T';
Opts.Noise=1e-3;
Opts.FileName=[Opts.ModelType];

Opts=ParseFunOpts(Opts,varargin);

OutDir=[fileparts(which('CreateSyntheticData')) filesep ...
    '..' filesep '..' filesep 'TestData' filesep 'Synthetic' filesep];

Data=GetRefDecay(Opts.k,Opts.rc,'ts',Opts.ts,'ModelType',Opts.ModelType);
Data.T(end)=-0.1;
Data.T=100*Data.T'; Data.t=Data.t';

if ~isempty(Opts.Noise)
    Data.T=Data.T+ Opts.Noise*randn(size(Data.T));
end
Data.Info=GetMetaDataDefaults;
Data.ModelType=Opts.ModelType;
Data.ImportInfo.DatPath=OutDir;
Data.ImportInfo.DatFile=Opts.FileName;
%Data.Session.YLim=[-10 110];
save([OutDir Opts.FileName],'Data');