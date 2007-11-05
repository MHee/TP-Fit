function TPFit(varargin)
%TPFIT  Check TP-Fit installation and launch GUI window
%   TP-Fit is a
%
%   Example
%       ...=TPFit
%
%   See also: helprep, contentsrpt

%% Info
% * TODO: Sample todo
% * FIXME: Sample fixme
%
%   Created: 28-Sep-2007 
%   $Revision$  $Date$
%
%   Copyright 2007  Martin Heesemann <heesema AT uni-bremen DOT de>


% TODO: Do test for previous installations
% TODO: Add to path permanently
% TODO: Add to Toolbox menu in (Start)
% TODO: Remove from path

%% Define options
Opts.Remove=false; % Remove TP-Fit from path

if ~isempty(which('ParseFunOpts'))
    Opts=ParseFunOpts(Opts,varargin);
    
    if Opts.Remove
        % Remove TP-Fit from path
        rmpath(fileparts(which('TPFit_Window.m')));
        rmpath(fileparts(which('TDataExplorer.m')));
        rmpath(fileparts(which('TPFit.m')));
        return
    end
end

% Check check whether TP-Fit is properly installed
CheckTPFitInstallation

% Launch Version Info (HTML Docu)
ShowTPFitHelp;

% Launch TDataExplorer
TDataExplorer;

% Launch TP-Fit
TPFit_Window;

function CheckTPFitInstallation
BasePath=fileparts(mfilename('fullpath'));
TPFitPath=fullfile(BasePath,'TP-Fit');
TDataExplorerPath=fullfile(BasePath,'TDataExplorer');
%ModelPath=fullfile(BasePath,'RefModels');

%OldBasePath=fileparts(which('APCT_TModels.mat'))
%OldModelPath=fileparts(which('APCT_TModels.mat'))
OldTPFitPath=fileparts(which('TPFit_VersionInfo'));
if ~isempty(OldTPFitPath)
    % TP-Fit already on path
    if ~isequal(TPFitPath,OldTPFitPath)
        warning('Over-riding old version of TP-Fit');
        %rmpath()
    end
    OldVersion=TPFit_VersionInfo
end
% Set Path 

addpath(BasePath);
addpath(TPFitPath);
addpath(TDataExplorerPath);
%addpath(ModelPath);


