function Data=GuessMetaData(Data,varargin)

Opts.Info=GetMetaDataDefaults;
Opts=ParseFunOpts(Opts,varargin);

MData=Opts.Info;

switch Data.ImportInfo.DataType
    case 'DVTP'
        MData.ToolType='DVTP';
    case 'ANTARES'
        MData.ToolType='APCT-3';
        MData.ToolID=Data.OrigData.LoggerID;
    case 'ADARA'
        MData.ToolType='APCT';
    case 'SYNTH'
        %MData.ToolType='Synthetic';
        %Data.Info=MData;
        return
end

MData.Site=num2str(sscanf(Data.ImportInfo.DatFile,'%d'));
MData.Hole=upper(char(sscanf(Data.ImportInfo.DatFile,'%*d%1c%*d%*c')));
MData.Core=num2str(sscanf(Data.ImportInfo.DatFile,'%*d%*1c%d%*1c'),'%02.0f');
MData.CoreType=upper(char(sscanf(Data.ImportInfo.DatFile,'%*d%*1c%*d%1c')));
if strcmp(MData.CoreType,'.')
    MData.CoreType='';
end

% Make shure everything is a string to avoid errors if anything sneaks in
% through the defaults...
Fields=fieldnames(MData);
for i=1:length(Fields)
    if ~isstr(MData.(Fields{i}))
        MData.(Fields{i})='';
    end
end

Data.Info=MData;