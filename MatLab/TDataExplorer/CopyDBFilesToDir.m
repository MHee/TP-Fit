function DB=CopyDBFilesToDir(DB,NDir)
% COPYDBFILESTODIR   Copy all files refered to in DB to new Directory
%   A Subdirectory structure (Exp\Site) is used
%   
%   Example
%       ...=CopyDBFilesToDir
%
%   See also: 

%% Info
%
%   Created: 26-Sep-2007 
%   Copyright 2007  Martin Heesemann <heesema AT uni-bremen DOT de>


%% Self-test
if ~exist('DB','var')
    load('OnE_Final');
    DB=Data.DB;
    NDir='.\TTool_Data\APCT';
    varargin={};
end

%% Define options
Opts.Test=false;
Opts=ParseFunOpts(Opts,varargin);

%% Main code
fid=fopen('Copy.log','w');

for i=1:length(DB)
    OldDir=DB(i).Dir;
    for j=1:length(DB(i).Files)
        OldFile=DB(i).Files{j};
        NewDir=fullfile(NDir,DB(i).Info.Expedition,DB(i).Info.Site);
        if ~exist(NewDir,'dir')
            fprintf('Create: %s\n',NewDir);
            fprintf(fid,'Create: %s\n',NewDir);
            if ~Opts.Test
                mkdir(NewDir);
            end
        end
        TargetF=fullfile(NewDir,OldFile);
        SourceF=fullfile(OldDir,OldFile);
        if ~exist(TargetF,'file')
            fprintf('Copy: %s ->\n      %s\n',SourceF,TargetF);
            fprintf(fid,'Copy: %s ->\n      %s\n',SourceF,TargetF);
            if ~Opts.Test
                copyfile(SourceF,TargetF);
            end
        else
            fprintf('Skip: %s ->\n      %s\n',SourceF,TargetF);
            fprintf(fid,'Skip: %s ->\n      %s\n',SourceF,TargetF);
        end
    end
end

fclose(fid);