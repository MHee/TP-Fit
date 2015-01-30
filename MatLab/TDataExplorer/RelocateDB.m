function Data=RelocateDB(Data,varargin)
% RELOCATEDB   Template for m-files
%   This is a m-file skeleton. Just replace the Dummy text and you are
%   ready to go!!!
%
%   Example
%       ...=RelocateDB
%
%   See also: helprep, contentsrpt

%% Info
% * TODO: Sample todo
% * FIXME: Sample fixme
%
%   Created: 27-Sep-2007
%   $Revision$  $Date$
%
%   Copyright 2007  Martin Heesemann <heesema AT uni-bremen DOT de>


%% Self-test
if ~exist('Data','var')
    load('LocalDB_APCT_02.mat');
    varargin={};
end


%% Define options
Opts.Records=1;
Opts.StartRec=[];

Opts=ParseFunOpts(Opts,varargin);

if isempty(Opts.StartRec)
    Opts.StartRec=Opts.Records(1);
end

%% Main code
if isfield(Data,'TDataExplorer')
    % Input was handle
    handles=Data;
    Data=get(handles.TDataExplorer,'UserData');
    HandleInput=true;
else
    HandleInput=false;
end
FileName=Data.DB(Opts.StartRec).Files{1};
OldDir=Data.DB(Opts.StartRec).Dir;
[FileName, NewDir]=uigetfile(FileName, sprintf('Select new location of %s',FileName));
if ~FileName
    return
end
[Dummy,FileNameBase]=fileparts(FileName);
if ~strcmp(FileNameBase,Data.DB(Opts.StartRec).BaseName)
    msgbox('Files do not match!!!','Ooops','error');
    beep;
    return
end

NewDir=fileparts(NewDir);
%NewDir='d:\home\martin\TODP\GeTTMo\Experiments\TDataExplorer\TTool_Data\APCT\144\871'
if strcmp(OldDir,NewDir)
    warning('TDataExplorer:Relocate','Nothing to do!!!');
end
if exist(NewDir,'dir')
    fprintf('Record %3d\n',Opts.StartRec);
    Data.DB(Opts.Records(1)).Dir=NewDir;
else
    fprintf('Record %3d failed!!!!\n',Opts.StartRec);
end
fprintf('Old: %s\nNew: %s\n\n',OldDir,NewDir)

if (length(Opts.Records) > 1)
    OldDirR=fileparts(fullfile(OldDir,'/'));
    Count=0;
    NNew=length(NewDir);
    NOld=length(OldDirR);
    if strcmp(OldDirR,NewDir)
        warning('TDataExplorer:Relocate','Nothing to do!!!');
        %return
    end
    while strcmp(NewDir(NNew-Count),OldDirR(NOld-Count))
        Count=Count+1;
    end
    Count=Count-1;
    NewDirStart=NewDir(1:NNew-Count);

    for i=1:length(Opts.Records)
        Record=Opts.Records(i);
        OldDir=Data.DB(Record).Dir;
        OldDirR=fileparts(fullfile(OldDir,'/')); % Replacement (OS independent)
        NewDir=fullfile(NewDirStart, OldDirR(end-Count:end));
        if exist(NewDir,'dir')
            fprintf('Record %3d\n',Record);
            Data.DB(Record).Dir=NewDir;
        else
            fprintf('Record %3d failed!!!!\n',Record);
        end
        fprintf('Old: %s\nNew: %s\n\n',OldDir,NewDir)
    end
end

if HandleInput
    set(handles.TDataExplorer,'UserData',Data);
    Data='No Filter';
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
return

function Out=DeleteBadData(handles)
Out='No Filter';
set(handles.FilterText,'String','');
if ~strcmp(questdlg({'This cannot be undone!', 'Proceed?'},...
        'Delete Bad Records','No'),'Yes')
    return
end
Data=get(handles.TDataExplorer,'UserData');
DB=Data.DB;
BadRecs=find([DB.BadData])
DB(BadRecs)=[];
Data.DB=DB;
Data.CurrRec=1;
set(handles.TDataExplorer,'UserData',Data);
