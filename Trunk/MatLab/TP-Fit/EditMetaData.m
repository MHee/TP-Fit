function MData=EditMetaData(MData)
% Edit the Meta-Data that is used and stored in TP-Fit data

if ~exist('MData','var')
    MData=GetMetaDataDefaults;
end

% If Old MData does not contain found in MetaDataDefaults add the
% DefaultFields
MData=ParseFunOpts(GetMetaDataDefaults,MData);

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
