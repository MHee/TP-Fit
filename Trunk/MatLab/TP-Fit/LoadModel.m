function M=LoadModel(ModelType,varargin)
% LOADMODEL   Load reference model table base on ModelType.
%   The main purpose of this function is to select the right reference
%   model table depending on the ModelType an locate it on disk. All
%   functions that import reference model tables should use this function
%   and not directly load the models to prevent problems if the location or
%   the defaults for the models change!
%   The "ModelType" specifies the geometry and the modelled property (e.g.
%   APCT_T is a temperature model using APCT geometry). Currently supported 
%   ModelTypes are (APCT_T | DVTP_T | TeKaNeedle_T).
%   Have a look in the Hacker Guide for the exact structure of 
%   the reference model table returend in M.
%
%   Example
%       % To run a self-test use
%       M=LoadModel;
%
%       % Load DVTP temperature table
%       M=LoadModel('DVTP_T');
%
%       % Overide model type and use specific file, and be verbose about
%       % which file was loaded. A warning is issued.
%       M=LoadModel('','ForceModel','X:\ Path to file .mat','Verbose',true);
%
%   See also: GetRefDecay

%   Copyright 2007  Martin Heesemann <heesema AT uni-bremen DOT de>


%% Self-test
% Definition of the self-test run when no arguments are given
if ~exist('ModelType','var')
    ModelType='';
    varargin={'ForceModel',LocateModel('APCT_TModels.mat'),'Verbose',true};
end

%% Define options
% Default options
Opts.ForceModel=[]; % Location of *.mat file fored to be loaded
Opts.Verbose=false;
Opts=ParseFunOpts(Opts,varargin);

%% Select model
if ~isempty(Opts.ForceModel)
    % Load forced model
    ModelFile=Opts.ForceModel;
    warning('TPFit:ModelForced',...
        'Use of Model %s was forced!',ModelFile);
else
    % Figure out what model to use for the specified ModelType
    switch ModelType
        case 'APCT_T'
            ModelFile='APCT_TModels.mat';
        case 'DVTP_T'
            ModelFile='DVTP_TModels.mat';
        case 'TeKaNeedle_T'
            ModelFile='TeKaNeedle_TModels.mat';
        otherwise
            error(['Bad model type: ' ModelType]);
    end
    ModelFile=LocateModel(ModelFile);
end

%% Load model
L=load(ModelFile);
M=L.M;

% Store the location of the used reference model
M.Info.ModelFile=ModelFile;

if Opts.Verbose
    fprintf('Reference model "%s" loaded.\n',ModelFile);
end

%% Local functions

function MLocation=LocateModel(ModelFile)
% Locate model file on disk and return full path. 
% Models are expected to be under ....TP-Fit/RefModels/
MLocation=fullfile(fileparts(mfilename('fullpath')),'RefModels',ModelFile);