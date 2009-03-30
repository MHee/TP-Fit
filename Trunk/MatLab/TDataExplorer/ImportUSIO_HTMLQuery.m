function Data=ImportUSIO_HTMLQuery(FileName,varargin)
% IMPORTUSIO_HTMLQUERY   Template for m-files
%   This is a m-file skeleton. Just replace the Dummy text and you are
%   ready to go!!!
%   
%   Example
%       ...=ImportUSIO_HTMLQuery
%
%   See also: helprep, contentsrpt

%% Info
% * TODO: Sample todo
% * FIXME: Sample fixme
%
%   Created: 02-Oct-2007 
%   $Revision$  $Date$
%
%   Copyright 2007  Martin Heesemann <heesema AT uni-bremen DOT de>


%% Self-test
if ~exist('FileName','var')
    FileName='d:\home\martin\TODP\TTool_Database\All_USIO_TTool_Measurements.html';
    %     FileName='d:\home\martin\TODP\TTool_Database\APCT\168\1023\1023_USIO_adara.html';
    varargin={'Type','adara'};
%    FileName='d:\home\martin\TODP\TTool_Database\APCT\168\1023\1023_USIO_tcondat.html';
%    varargin={'Type','tcondat'};
end

%% Define options
Opts.Type='adara';
Opts=ParseFunOpts(Opts,varargin);

%% Read complete HTML File
fid=fopen(FileName,'r');
HTMLStr=fread(fid, '*char')';
fclose(fid);

%% Strip data from HTML
[DatStart,DatStop]=regexp(HTMLStr,'<pre>.*</pre>');
ASCIIData=HTMLStr(DatStart+6:DatStop-6);

%% Structure data depending on Data type

switch Opts.Type
    case 'adara'
        AllDat=textscan(ASCIIData,'%s %s %s %s %s %f %f %f %f %s %s %s %s',...
            'delimiter','\t',...
            'headerLines',1);
        
        Data.Leg=AllDat{1};
        Data.Site=AllDat{2};
        Data.Hole=AllDat{3};
        Data.Core=AllDat{4};
        Data.CoreType=AllDat{5};
        Data.ToolName=AllDat{12};
        Data.T=AllDat{9};
        Data.z=AllDat{7};
    case 'tcondat'
        AllDat=textscan(ASCIIData,'%s %s %s %s %s %s %f %f %f %s %f %s %s %s',...
            'delimiter','\t',...
            'headerLines',1);

        Data.Leg=AllDat{1};
        Data.Site=AllDat{2};
        Data.Hole=AllDat{3};
        Data.Core=AllDat{4};
        Data.CoreType=AllDat{5};
        Data.ToolName=AllDat{12};
        Data.k=AllDat{11};
        Data.z=AllDat{9};
    case 'maddat'
        AllDat=textscan(ASCIIData,'%s %s %s %s %s %s %f %f %f %f %f %f %f %f %f %f %s %s',...
            'delimiter','\t',...
            'headerLines',1);

        Data.Leg=AllDat{1};
        Data.Site=AllDat{2};
        Data.Hole=AllDat{3};
        Data.Core=AllDat{4};
        Data.CoreType=AllDat{5};
        Data.z=AllDat{9};
        Data.WW=AllDat{10};
        Data.WD=AllDat{11};
        Data.BulkDens=AllDat{12};
        Data.DryDens=AllDat{13};
        Data.GrainDens=AllDat{14};
        Data.Poro=AllDat{15};
        Data.VR=AllDat{16};
        Data.Method=AllDat{17};
        Data.Comments=AllDat{18};
    case 'pwldat'
        AllDat=textscan(ASCIIData,'%s %s %s %s %s %s %f %f %f',...
            'delimiter','\t',...
            'headerLines',1);

        Data.Leg=AllDat{1};
        Data.Site=AllDat{2};
        Data.Hole=AllDat{3};
        Data.Core=AllDat{4};
        Data.CoreType=AllDat{5};
        Data.z=AllDat{8};
        Data.vp=AllDat{9};
        
    otherwise
        Data=[];
        waring('ImportUSIO:UnknownType',...
            'Sorry, do not know how to import %s!!!',Opts.Type);


end


