function TFit=ImportAdaraFit(FileName,varargin)
% IMPORTADARAFIT   Template for m-files
%   This is a m-file skeleton. Just replace the Dummy text and you are
%   ready to go!!!
%   
%   Example
%       ...=ImportAdaraFit
%
%   See also: helprep, contentsrpt

%% Info
% * TODO: Sample todo
% * FIXME: Sample fixme
%
%   Created: 22-Sep-2007 
%   $Revision$  $Date$
%
%   Copyright 2007  Martin Heesemann <heesema AT uni-bremen DOT de>


%% Self-test
if ~exist('FileName','var')
    FileName='1034e09h.Fit';
    %[DatFile,DatPath]=uigetfile({'*.fit'},'Old TFit APCT results');
    %FileName=fullfile(DatPath, DatFile)
    varargin={'DoPlot',true};
end

%% Define options
Opts.DoPlot=true;

[FPath,ODPName,FExt]=fileparts(FileName);
Opts.DatFile=fullfile(FPath,[ODPName '.new']);
if ~exist(Opts.DatFile,'file');
    Opts.DatFile=fullfile(FPath,[ODPName '.dat']);
end
if ~exist(Opts.DatFile,'file');
    Opts.DatFile=[];
end

Opts=ParseFunOpts(Opts,varargin);

%% Main code
fid=fopen(FileName);
if (fid<1)
    warning('Could not open file %s',FileName);
    return
end

% Import Leg information
fLocateLine(fid,'LEG');
Info.Expedition=fscanf(fid,' LEG  %s',1);
Info.Hole=fscanf(fid,' HOLE %s',1);
Info.Core=fscanf(fid,' CORE %s',1);
Info.Site=num2str(sscanf(ODPName,'%d%*s'));



% Import Leg Picks
fLocateLine(fid,'Penetration record');
Picks.r0=fscanf(fid,' Penetration record #  = %d',1);
Picks.rStart=fscanf(fid,' First data to process = %d',1);
Picks.rEnd=fscanf(fid,' Last data to process  = %d',1);

% Import model parameters
fLocateLine(fid,'A=');
Props.r=fscanf(fid,'%*s%f B=%f %*s',2);
fLocateLine(fid,'C1=','verbose',false);
%assignin('base','Line',fgetl(fid))
k=fscanf(fid,'%*s%f C2=%f %*s',2);
Props.Seds.k=k(1);
Props.Probe.k=k(2);
fLocateLine(fid,'D1=');
kappa=fscanf(fid,'%*s%f D2=%f %*s',2);
Props.Seds.rc=k(1)/kappa(1);
Props.Probe.rc=k(2)/kappa(2);
Props.Seds.kappa=kappa(1);
Props.Probe.kappa=kappa(2);

% Import data sampling interval
fLocateLine(fid,'Temperature data at');
Sampling=fscanf(fid,'%*d Temperature data at %f %*s',1);

% Import model results
fLocateLine(fid,'BEST FIT');
fLocateLine(fid,'SHIFT=');
FitRes=fscanf(fid,'%*s%d  T0=  %f   B=  %f     SE= %f',4);
Fit.tSft=FitRes(1);
Fit.Tf=FitRes(2);
Fit.b=FitRes(3);
Fit.LSqr=FitRes(4);

% Import Data
fLocateLine(fid,'REC #','Continue',true);
DataB=textscan(fid,'%s %f %f %f %f'); % Data block

Data.T=DataB{2}';
Data.t=(0:length(Data.T)-1)*Sampling;

InModel=find(isfinite(DataB{3}));
Model.T=DataB{3}';
Model.T=Model.T(InModel);
Model.t=Data.t(InModel);
fclose(fid);

if ~isempty(Opts.DatFile)
    FullData=ImportAdaraData(Opts.DatFile,'DoPlot',false);
    Data.T=FullData.T;
    Data.t=FullData.t;
    Data.tr=FullData.t-FullData.t(Picks.r0);
    Model.t=Model.t;
end

% Save results
TFit.Info=Info;
TFit.Picks=Picks;
TFit.Props=Props;
TFit.Fit=Fit;
TFit.Sampling=Sampling;
TFit.Data=Data;
TFit.Model=Model;

% Data.Res.BestSft=1;
% Data.Res.Fit(1,:)=[Fit.b Fit.Tf];
% Data.Res.PartFit(1,:)=[Fit.b Fit.Tf];
% Data.Picks.Window=([Picks.rStart Picks.rEnd]-Picks.r0)*Sampling;
% Data.Session.XLim=[-Inf +Inf];
% Data.Session.YLim=[-Inf +Inf];
% Data.Res.Model=Model;
% Data.tr=Data.t;
% PlotFitResults(Data)
if Opts.DoPlot
    cla;
    hold on
    if ~isfield(Data,'tr')
        Data.tr=Data.t;
    end
    plot([Data.tr(1) Data.tr(end)],Fit.Tf*[1 1],'k--');
    plot(Model.t,Fit.b*Model.T+Fit.Tf,'Color',[1 .7 .7],'LineWidth',5);
    plot(Data.tr,Data.T,'.-');
    set(gca,...
        'XLim',[-120 Model.t(end)+120],...
        'TickDir','out',...
        'Box','on');
    grid on;
    xlabel('Time after insertion (s)');
    ylabel('Temperature (°C)');
    title(sprintf(['Original TFit Results\n'...
        'Leg %s - %s: k=%.2f W/(m K) T_f=%.2f °C'],...
        Info.Expedition,upper(ODPName), Props.Seds.k, Fit.Tf));
end
