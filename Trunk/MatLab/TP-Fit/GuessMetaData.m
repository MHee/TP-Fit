function Data=GuessMetaData(Data,varargin)

Opts.Info=GetMetaDataDefaults;
Opts=ParseFunOpts(Opts,varargin);

MData=Opts.Info;
switch Data.ImportInfo.DataType
    case 'DVTP'
        MData.ToolType='DVTP';
    case 'SETP_PROTOTYPE'
        MData.ToolType='SETP';
        MData.ToolID=Data.OrigData.Info.CF2_Serial;
    case 'ANTARES'
        MData.ToolType='APCT-3';
        MData.ToolID=Data.OrigData.LoggerID;
    case 'ADARA'
        MData.ToolType='APCT';
    case 'TPFIT_RES'
        MData.ToolType='APCT';
        Data.Picks.t0=Data.t(Data.OrigData.Picks.r0);
        Data.Picks.Window=Data.t([Data.OrigData.Picks.rStart ...
            Data.OrigData.Picks.rEnd])'-Data.Picks.t0;
        Data.tr=Data.t-Data.Picks.t0;
        Data.Picks.UsedDat=find( ( (Data.tr>=Data.Picks.Window(1))&(Data.tr<=Data.Picks.Window(2))));
        Data.Session.XLim=[-100 100+Data.Picks.Window(2)];
        Data.Session.YLim=[min(Data.T) max(Data.T)];
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