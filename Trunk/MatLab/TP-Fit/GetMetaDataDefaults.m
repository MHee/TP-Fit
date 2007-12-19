function MData=GetMetaDataDefaults(varargin)
% GETMETADATADEFAULTS  Initialize the meta data for TP-Fit
%   
%   Example
%       Info=GetMetaDataDefaults
%       Info=GetMetaDataDefaults('GetDefaults',false)
%
%   See also: GuessMetaData, CollectMetaData (TDataExplorer)

%% Info
%
%   Copyright 2007  Martin Heesemann <heesema AT uni-bremen DOT de>


%% Define options
Opts.GetDefaults=true;
Opts=ParseFunOpts(Opts,varargin);


% 
% See also GuessMetaData

MData.Expedition='???';
MData.Site='????';
MData.Hole='?';
MData.Core='??';
MData.CoreType='?';
MData.Depth='??';
MData.DepthError='??';
MData.ToolID='???';
MData.ToolType='????';
MData.Operator='Martin Heesemann';
MData.Initial_k='1';
MData.Initial_rC='3.4e6';
MData.TError='??';
MData.DataQuality='None';
MData.DataQualityNo=1;
MData.Comment='';

if ~Opts.GetDefaults
    % Clear everything
    fields=fieldnames(MData);
    for i=1:length(fields)
        MData.(fields{i})='';
    end
end
