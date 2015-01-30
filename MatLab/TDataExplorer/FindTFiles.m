function DB=FindTFiles(StartDir,varargin)
% FINDTFILES   Template for m-files
%   This is a m-file skeleton. Just replace the Dummy text and you are
%   ready to go!!!
%
%   Example
%       ...=FindTFiles
%
%   See also: helprep, contentsrpt

%% Info
% * TODO: Sample todo
% * FIXME: Sample fixme
%
%   Created: 23-Sep-2007
%   $Revision$  $Date$
%
%   Copyright 2007  Martin Heesemann <heesema AT uni-bremen DOT de>


%% Self-test
if ~exist('StartDir','var')
    %CurrDir='.';
    % StartDir='d:\home\martin\TODP\APC3\TP-Fit\TestData';
    % StartDir='E:\Balder\heesema\T_ODP\Data\ADARA\Leg 167';
    StartDir='E:\Balder\heesema\T_ODP\Data\ADARA';
    varargin={};
end

%% Define options
Opts.Recurse=true;
Opts.InRecursion=false;
Opts.Extentions={'*.fit','*.eng','*.dat','*.new','*.mat'};
Opts=ParseFunOpts(Opts,varargin);

%% Main code
FileCount=0;
DB=[];
for i=1:length(Opts.Extentions)
    DatFiles=dir(fullfile(StartDir, Opts.Extentions{i}));
    for j=1:length(DatFiles)
        FileCount=FileCount+1;
        DB(FileCount).Files={DatFiles(j).name};
        [Dummy,BaseName]=fileparts(DB(FileCount).Files{1});
        DB(FileCount).BaseName=BaseName;
        DB(FileCount).Dir=StartDir;
    end
end

FileCount=0;
while (FileCount < length(DB))
    FileCount=FileCount+1;


    SameBase=strmatch(DB(FileCount).BaseName,{DB.BaseName});
    %{BaseName DB(SameBase).Files}
    if (length(SameBase)>1)
        % Group files with same base name
        DB(FileCount).Files=[DB(SameBase).Files];
        DB(SameBase(2:end))=[];
    end

end

if Opts.Recurse
    Dirs=dir(StartDir);
    for i=1:length(Dirs)
        CurrDir=Dirs(i).name;
        if ( (CurrDir(1) ~= '.') && Dirs(i).isdir)
            %fullfile(StartDir,CurrDir)
            DB=[DB FindTFiles(fullfile(StartDir,CurrDir),'InRecursion',true)];
            %FindTFiles(fullfile(StartDir,CurrDir))
        end
    end
end

%% Initialize fields after all recursion
if ~Opts.InRecursion
    Info=GetMetaDataDefaults('GetDefaults',false);
    for i=1:length(DB)
        DB(i).DataType='';
        DB(i).Info=Info;
        DB(i).BadData=false;
        % DB(i).Interesting=false; % Interesting is not used any more
        DB(i).Tags=[];
    end
end