function TPFitInfo=TPFit_VersionInfo
% TPFitInfo=TPFit_VersionInfo returns version information for TP-Fit.
%   This information is included in the Data structure to track which
%   version of TP-Fit was used to process the data.
TPFitInfo.Version=1.1;

RevFile=fullfile(fileparts(mfilename('fullpath')),'..','..','REVISION');
gitMaster=fullfile(fileparts(mfilename('fullpath')),'..','..',...
    '.git','refs','heads','master');
if exist(gitMaster,'file')
    % TP-Fit has access to git repository version info
    % Take to opportunity to copy the info over
    try
        copyfile(gitMaster,RevFile);
    catch
        warning('Was not able to copy Software revision information')
    end
end
try
    Revision=textread(RevFile,'%s',1); % for Future use with SVN
    TPFitInfo.Revision=Revision{1};
catch
    TPFitInfo.Revision='Could not be determined';
end