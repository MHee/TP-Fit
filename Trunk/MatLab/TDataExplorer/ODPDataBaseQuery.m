function ODPDataBaseQuery(varargin)
% ODPDATABASEQUERY   Template for m-files
%   This is a m-file skeleton. Just replace the Dummy text and you are
%   ready to go!!!
%
%   Example
%       ...=ODPDataBaseQuery
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
%if ~exist('DataURL','var')
    % Downhole temperature tools
    % DataURL='http://iodp.tamu.edu/janusweb/physprops/adara.cgi';

    % Themal conductivity from needle probes
    % DataURL='http://iodp.tamu.edu/janusweb/physprops/tcondat.cgi';

    % Moisture and density
    % DataURL='http://iodp.tamu.edu/janusweb/physprops/maddat.cgi';

    % GRA bulk density
    % DataURL='http://iodp.tamu.edu/janusweb/physprops/gradat.cgi';

    %varargin={}; %{'DataSets',{'gradat'}}; {'DataSets',{'adara'}};
%end

%% Define options
Opts.DataSets={'adara','tcondat','maddat'}; %,'gradat'
Opts.Site='1028';
Opts.OutDir='';
Opts.SkipExisting=true;
Opts.TryInBrowser=false;
Opts=ParseFunOpts(Opts,varargin);
BaseURL='http://iodp.tamu.edu/janusweb/physprops/';

%% Main code
for i=1:length(Opts.DataSets)
    DataSet=Opts.DataSets{i};
    DataURL=[BaseURL DataSet '.cgi'];
    DatFile=[Opts.Site '_USIO_' DataSet '.html'];
    FullFileName=fullfile(Opts.OutDir,DatFile);
    
    %outHTML=urlread(DataURL,'post',{'leg','','site','1175','hole','','core',''});
    fprintf('\n%d of %d: %s\n',i,length(Opts.DataSets),DataSet);
    if Opts.SkipExisting && exist(FullFileName,'file')
        fprintf('%s exist. Skipping!!!\n',FullFileName);
        continue % Skip this dataset
    end

    fprintf('Aquiring %s \n',FullFileName);

    [outHTML,URLStatus]=urlread(DataURL,'post',{'site',Opts.Site});
    fprintf('Status: %g\n',URLStatus);
    if ~URLStatus
        fprintf('Sorry, was not able to get\n%s\n',FullFileName);
        CompleteURL=[DataURL '?site=' Opts.Site];
        fprintf('Trying to open\n%s\nin browser!!!\n',CompleteURL);
        if Opts.TryInBrowser
            web(CompleteURL,'-browser');
        end
        continue % Nothing to write to disk
    end

    %% Fix links in html
    %
    outHTML=strrep(outHTML,'="../',['="' BaseURL '../']);
    outHTML=strrep(outHTML,['href="' DataSet],['href="' BaseURL DataSet]);
    outHTML=strrep(outHTML,'href="/database/index.html"','href="http://iodp.tamu.edu/database/index.html"');

    %     % Strip data from HTML
    %     [DatStart,DatStop]=regexp(outHTML,'<pre>.*</pre>');
    %     outASCII=outHTML(DatStart+6:DatStop-6);

    fid=fopen(FullFileName,'w');
    %fprintf(fid,'%s',outASCII);
    fprintf(fid,'%s',outHTML);
    fclose(fid);
end