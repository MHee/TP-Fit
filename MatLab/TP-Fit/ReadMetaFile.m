function MData=ReadMetaFile(MetaFileName,varargin)
% READMETAFILE   Reads a *.meta file into a structure variable
%   This is 
%   
%   Example
%       ...=ReadMetaFile
%
%   See also: WriteMetaFile

%% Info
% * TODO: Sample todo
% * FIXME: Sample fixme
%
%   Created: 15-Dec-2007 
%   $Revision$  $Date$
%
%   Copyright 2007  Martin Heesemann <heesema AT uni-bremen DOT de>


%% Self-test
if ~exist('MetaFileName','var')
    MetaFileName='Test.meta';
    varargin={};
end

fid=fopen(MetaFileName);
if fid==-1
    warning('TPFit:ReadMetaFile','Cannot open file %s',MetaFileName);
    return
end

%% Define options
Opts.Offset=1;
Opts=ParseFunOpts(Opts,varargin);

%% Main code

FileCont=textscan(fid,'%s %s',...
    'commentStyle',{'/*','*/'},...
    'delimiter','"',... \r\n
    'multipleDelimsAsOne',0,...
    'endOfLine','');
    
FNames=strtrim(FileCont{1});

for i=1:length(FNames)
    if ~isempty(FNames{i})
        MData.(FNames{i})=FileCont{2}{i};
    end
end


fclose(fid);