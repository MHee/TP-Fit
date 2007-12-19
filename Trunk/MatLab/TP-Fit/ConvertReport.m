function ConvertReport(ReportName,varargin)
% CONVERTREPORT   Converts a TP-Fit report to a different file format
%   Valid file formats are [{html}|latex|text].
%   
%   Example
%       ...=ConvertReport
%
%   See also: MakeReport

%% Info
% * TODO: Sample todo
% * FIXME: Sample fixme
%
%   Created: 15-Dec-2007 
%
%   Copyright 2007  Martin Heesemann <heesema AT uni-bremen DOT de>


%% Self-test
if ~ispc
    warndlg('Sorry converting reports currently only works on Windows boxes!');
    return
end

if ~exist('ReportName','var')
    [RName,RPath]=uigetfile({'*.txt','*.*'},'Select a report file');
    ReportName=fullfile(RPath,RName);
    varargin={};
end

%% Define options
Opts.Format='html';
Opts=ParseFunOpts(Opts,varargin);

%% Main code
nme_exe=fullfile(fileparts(mfilename('fullpath')),'ReportConverter','nme.exe');
tr_exe=fullfile(fileparts(mfilename('fullpath')),'ReportConverter','tr.exe');

[RPath,RBaseName]=fileparts(ReportName);
ReportBase=fullfile(RPath,RBaseName);
%[tr_exe ' "\t" "|" <' ReportName ' | ' nme_exe '> ' ReportBase '.html']
system([tr_exe ' "\t" "|" <' ReportName ' | ' nme_exe '> ' ReportBase '.html']);

winopen([ReportBase '.html'])
