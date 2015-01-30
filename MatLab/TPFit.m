function TPFit(varargin)
%TPFIT  Check TP-Fit installation and launch GUI window
%   TP-Fit is a
%
%   Example
%       ...=TPFit
%
%   See also: helprep, contentsrpt

% Copyright (C) 2007  Martin Heesemann  <heesema AT uni-bremen DOT de>

% This file is part of TP-Fit.
% 
%     TP-Fit is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     TP-Fit is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with TP-Fit.  If not, see <http://www.gnu.org/licenses/>.
    
% TODO: Do test for previous installations
% TODO: Add to path permanently
% TODO: Add to Toolbox menu in (Start)
% TODO: Remove from path

%% Define options
Opts.Remove=false; % Remove TP-Fit from path

if exist('ParseFunOpts','var')
    % ParseFunOpts exist if TP-Fit is installed
    Opts=ParseFunOpts(Opts,varargin);    
    if Opts.Remove
        % Remove TP-Fit from path
        rmpath(fileparts(which('TPFit_Window.m')));
        rmpath(fileparts(which('TDataExplorer.m')));
        rmpath(fileparts(which('TPFit.m')));
        return
    end
elseif ~isempty(varargin)
    error('Cannot process options. TP-Fit is not on your path');
end

% Check check whether TP-Fit is properly installed
CheckTPFitInstallation

% Launch Version Info (HTML Docu)
ShowTPFitHelp;

% Launch TDataExplorer
%TDataExplorer;

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

% Check whether UserSettings are okay
SettingsFile=fullfile(TPFitPath,'UserSettings.mat');
if exist(SettingsFile,'file')
    S=load(SettingsFile);
    if any(S.Settings.ScreenSize ~= get(0,'ScreenSize'))
        % Screen resolution changed
        Answer=questdlg(['The screen size has changed.'...
            'It is recommended to [Delete] the current default settings '...
            'and to store new window positions using the Extras menu!'],...
            'Invalid Settings','Delete','Keep','Delete');
        if strcmp(Answer,'Delete')
            delete(SettingsFile)
            fprintf('Removed %s.',SettingsFile)
        end
    end
end

