function DB=CollectMetaData(DB,varargin)
% COLLECTMETADATA   Collects meta data for all records in database
%
%   Example
%       ...=CollectMetaData
%
%   See also: helprep, contentsrpt

%% Info
% * TODO: Sample todo
% * FIXME: Sample fixme
%
%   Created: 25-Sep-2007 
%   $Revision$  $Date$
%
%   Copyright 2007  Martin Heesemann <heesema AT uni-bremen DOT de>


%% Self-test
if ~exist('DB','var')
    DB=FindTFiles;
    varargin={};
end

%% Define options
Opts.PlotProgress=false;
Opts.DoPlot=false;
Opts=ParseFunOpts(Opts,varargin);
Failed=[];
for i=1:length(DB)
    CurrDir=DB(i).Dir;
    if ~Opts.PlotProgress
        fprintf('%d / %d\n',i,length(DB));
    end
    for FNo=1:length(DB(i).Files)
        CurrFile=fullfile(CurrDir,DB(i).Files{FNo});
        
        % Plot Progress
        if Opts.PlotProgress
            if FNo==1
                fprintf('\n%4d: ',i);
            else
                fprintf('      |--> ');
            end
            fprintf('%s\n',CurrFile);
        end
        % Get Defaults
        try
            Data=ImportTemperatureData(fullfile(DB(i).Dir,DB(i).Files{FNo}),'DoPlot',Opts.DoPlot);
        catch
            'failed'
            fullfile(DB(i).Dir,DB(i).Files{FNo})
            Failed=[Failed i];
            continue
        end
        if (isfield(Data,'ImportInfo') && isfield(Data.ImportInfo,'DataType'))
            DB(i).DataType=Data.ImportInfo.DataType;
%             DB(i).DataType
        end
        if (isfield(Data,'OrigData') && isfield(Data.OrigData,'Info'))
            CurrInfo=DB(i).Info;
            NewInfo=Data.OrigData.Info;
            IFields=fieldnames(CurrInfo);
            for FieldNo=1:length(IFields)
                if (isempty(CurrInfo.(IFields{FieldNo})) && ... 
                        isfield(NewInfo,IFields{FieldNo}))
                    CurrInfo.(IFields{FieldNo})=NewInfo.(IFields{FieldNo});
                    %fprintf('%s: %s\n',NewInfo.(IFields{FieldNo}),IFields{FieldNo});
                end
            end
            
            DB(i).Info=ParseFunOpts(DB(i).Info, Data.OrigData.Info);
        end
    end
%     DB(i).DataType
%     DB(i).Info
%     Data=ImportTemperatureData(fullfile(DB(i).Dir,DB(i).Files{1}),'DoPlot',true);
%     if isempty(Data)
%         DB(i).BadData=true;
%         break
%     else
%         DB(i).BadData=false;
%     end
%     if isfield(Data.ImportInfo,'DataType')
%         DB(i).DataType=Data.ImportInfo.DataType;
%     else
%         DB(i).DataType='Unknown';
%     end
% 
%     if strcmp(DB(i).DataType,'ADARA')
%         DB(i).Leg=Data.OrigData.Info.Leg;
%         DB(i).Site=Data.OrigData.Info.Site;
%         DB(i).Serial=Data.OrigData.Info.SerialNumber;
%         DB(i).Hole=Data.OrigData.Info.Hole;
%         DB(i).Core=Data.OrigData.Info.Core;
%         DB(i).Depth=Data.OrigData.Info.Depth;
%     end
end

if ~isempty(Failed)
    DB(Failed)=[];
end