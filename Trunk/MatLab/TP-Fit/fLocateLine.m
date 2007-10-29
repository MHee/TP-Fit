function [FoundStr,Lines]=fLocateLine(fid,MatchString,varargin)
% FLOCATELINE   Locate next line in file that contains a MatchString
%   Look in script for the availiable options and defaults
%   
%   Example
%       ...=fLocateLine
%
%   See also: ImportAdaraData, ImportAdaraFit

%% Info
%   Created: 22-Sep-2007 
%
%   Copyright 2007  Martin Heesemann <heesema AT uni-bremen DOT de>

%% Define options
Opts.EditFile=[]; % Edit this file if string is not found
Opts.Continue=false; % Leave file pointer at start of next line?
Opts.verbose=false;
Opts.IssueError=true; % Produce an error if nothing is found before end of file
Opts=ParseFunOpts(Opts,varargin);

SavedPos=ftell(fid); % Rember current file position
FoundStr=false;
Lines={};
LineCount=0;
while (~FoundStr && ~feof(fid))
    LineStartPos=ftell(fid); % Rember current file position
    Line=fgetl(fid);
    if Opts.verbose
        Line
    end
    LineCount=LineCount+1;
    if ~isempty(strfind(Line,MatchString))
        FoundStr=true;
        if ~Opts.Continue
            %fseek(fid,-1*length(Line),'cof'); % rewind last line
            fseek(fid,LineStartPos,'bof'); % rewind last line
        else
            Lines{LineCount}=Line;
        end
    elseif (nargout>1)
        Lines{LineCount}=Line;
    end
end

if ~FoundStr
    % Reset old file position if it was not possible to locate the string
    fseek(fid,SavedPos,'bof');
    if ~isempty(Opts.EditFile)
            edit(Opts.EditFile);
    end
    if Opts.IssueError
        fclose(fid)
        error('Could not find "%s" in file!!!',MatchString)
    end
end