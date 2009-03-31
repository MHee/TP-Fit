function TPFitInfo=TPFit_VersionInfo
% TPFitInfo=TPFit_VersionInfo returns version information for TP-Fit.
%   This information is included in the Data structure to track which
%   version of TP-Fit was used to process the data.
TPFitInfo.Version=1.0;

RevFile=...
    [fileparts(mfilename('fullpath')) filesep '..' filesep '..' filesep 'REVISION'];

try
    Revision=textread(RevFile,'%s',1); % for Future use with SVN
    TPFitInfo.Revision=Revision{1};
catch
    TPFitInfo.Revision='Could not be determined';
end