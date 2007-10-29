function AquireUSIO_ForCompleteDB(Data,varargin)
% AQUIREUSIO_FORCOMPLETEDB   Get data from USIO database for all DB Sites
%   This is a m-file skeleton. Just replace the Dummy text and you are
%   ready to go!!!
%   
%   Example
%       ...=AquireUSIO_ForCompleteDB
%
%   See also: helprep, contentsrpt

%% Info
% * TODO: Sample todo
% * FIXME: Sample fixme
%
%   Created: 29-Sep-2007 
%   $Revision$  $Date$
%
%   Copyright 2007  Martin Heesemann <heesema AT uni-bremen DOT de>


%% Self-test
if ~exist('Data','var')
    Data=evalin('base','Data');
    varargin={};
end

%% Define options
Opts.Offset=1;
Opts=ParseFunOpts(Opts,varargin);

%% Main code
DB=Data.DB;

for i=1:length(DB)
    Sites{i}=DB(i).Info.Site;
    Dirs{i}=DB(i).Dir;
end
[Dummy,UIdx]=unique(Sites);
for i=1:length(UIdx)
    fprintf('(%d of %d) Site %s: %s\n',i ,length(UIdx),Sites{UIdx(i)},Dirs{UIdx(i)});
    ODPDataBaseQuery('Site',Sites{UIdx(i)},...
        'OutDir',Dirs{UIdx(i)},...
        'DataSets',{'adara','tcondat','maddat'},... %,'gradat'
        'SkipExisting',true,...
        'TryInBrowser',false);
end
