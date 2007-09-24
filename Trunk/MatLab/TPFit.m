function TPFit
%TPFIT  Check TP-Fit installation and launch GUI window
%   TP-Fit is a

% TODO: Do test for previous installations
% TODO: Add to path permanently
% TODO: Remove from path

%%
% Firstly,...

% Check check whether TP-Fit is properly installed
CheckTPFitInstallation

% Launch Version Info
ShowTPFitHelp;

% Launch TP-Fit
TPFit_Window;

function CheckTPFitInstallation
BasePath=fileparts(which(mfilename));
ScriptPath=fullfile(BasePath,'TP-Fit');
%ModelPath=fullfile(BasePath,'RefModels');

%OldBasePath=fileparts(which('APCT_TModels.mat'))
%OldModelPath=fileparts(which('APCT_TModels.mat'))
OldScriptPath=fileparts(which('TPFit_VersionInfo'))
if ~isempty(OldScriptPath)
    % TP-Fit already on path
    if ~isequal(ScriptPath,OldScriptPath)
        warning('Over-riding old version of TP-Fit');
        %rmpath()
    end
    OldVersion=TPFit_VersionInfo
end
% Set Path 

addpath(BasePath);
addpath(ScriptPath);
%addpath(ModelPath);


