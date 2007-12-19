function WriteMetaFile(Data,varargin)
% WRITEMETAFILE   Writes a Meta-Data *.meta file 
%   The *.meta file is basically used for testing
%   
%   Example
%       ...=WriteMetaFile
%
%   See also: helprep, contentsrpt

%% Info
%
%   Created: 15-Dec-2007 
%   $Revision$  $Date$
%
%   Copyright 2007  Martin Heesemann <heesema AT uni-bremen DOT de>


%% Self-test
if ~exist('Data','var')
    Data.Info.Expedition='311';
    Data.Info.Site='1243';
    varargin={};
end

%% Define options
Opts.MetaFile=[];
Opts=ParseFunOpts(Opts,varargin);

%% Main code
if isempty(Opts.MetaFile)
    fid=1;
else
    fid=fopen(Opts.MetaFile,'w');
    if fid==-1
        warning('TPFit:WriteMetaFile','Cannot open file %s',Opts.MeatFile);
        return
    end 
end
MData=Data.Info;

FNames=fieldnames(MData);
for i=1:length(FNames)
    FName=FNames{i};
    FVal=MData.(FName);
    if iscellstr(FVal)
        FVal=sprintf('%s\n',FVal{:});
    end
    fprintf(fid,'%s "%s"\n',FName,FVal);
end

if fid~=1
    fclose(fid);
end

