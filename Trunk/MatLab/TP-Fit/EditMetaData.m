function MData=EditMetaData(varargin)
% Edit the Meta-Data that is used and stored in TP-Fit data

Opts.GetDefaults=true;
[Opts, unusedOpts]=ParseFunOpts(Opts,varargin);

if length(unusedOpts)==1
    % Usually MData is first unused option
    MData=unusedOpts{1};
end

if ~exist('MData','var')
    MData=GetMetaDataDefaults('GetDefaults',Opts.GetDefaults);
end

% Make sure Meta Data contains all fields that are defined in the defaults
MData=ParseFunOpts(GetMetaDataDefaults('GetDefaults',Opts.GetDefaults),MData);

FieldNames=fieldnames(MData);
    
NLines=ones(size(FieldNames));
NLines(end)=5;

DataOK=false;
while ~DataOK
    FieldContents=struct2cell(MData);
    MDataChanged=inputdlg(FieldNames,'Edit Meta-Data',NLines,FieldContents);
    if ~isempty(MDataChanged)
        for i=1:length(FieldNames)
            MData.(FieldNames{i})=MDataChanged{i};
        end
    end
    
    DataOK=true;
%     if length(str2num(MData.Depth))==1
%         DataOK=true;
%     else
%         DataOK=false;
%         warning('Depth must be a scalar number !!!');
%     end
end
