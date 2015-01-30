function OutStr=Struct2Str(InStruct,varargin)
% STRUCT2STR   Converts structure to (ToolTip) string
%   
%   Example
%       ...=Struct2Str
%
%   See also: 

%% Info
%
%   Created: 26-Sep-2007 
%   Copyright 2007  Martin Heesemann <heesema AT uni-bremen DOT de>


%% Self-test
if ~exist('InStruct','var')
    InStruct.ab='afafjl';
    InStruct.b= 1;
    InStruct.d= rand(4);
    InStruct.c=InStruct;
    InStruct
    varargin={'Warn','on'};
end

%% Define options
Opts.Warn=false;
Opts=ParseFunOpts(Opts,varargin);

%% Main code
FieldNames=fieldnames(InStruct);

for i=1:length(FieldNames)
    Field=FieldNames{i};
    Val=InStruct.(Field);
    if isstruct(Val)
        SubFields=fieldnames(Val);
        Val=sprintf('%s ',char(SubFields)');
    elseif isnumeric(Val)
        Val=num2str(Val);
    else
        Val=char(Val);
    end
    if (size(Val,1)>1)
        Val=Val(1,:);
    end
    Lines{i}=sprintf('%s : %s\n',Field,Val);
end

OutStr=sprintf([Lines{:}]);