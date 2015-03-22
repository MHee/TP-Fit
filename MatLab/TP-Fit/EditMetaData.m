function [MData,ModelType]=EditMetaData(varargin)
% Edit the Meta-Data that is used and stored in TP-Fit data

Opts.GetDefaults=true;
Opts.DatFileName='';
Opts.ModelType='';
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

hWin=EditMetaDataWindow(MData,'ModelType',Opts.ModelType);
DataOK=false;
Cancel=false;
while ~DataOK && ~Cancel
    set(hWin,...
        'WindowStyle','modal',...
        'Name',['Basename: ' Opts.DatFileName]);
    uiwait(hWin);
    handles=guidata(hWin);
    Cancel=handles.Cancel;
    if ~Cancel
        DataOK=CheckMetaData(handles.MData);
    end
end
MData=handles.MData;
ModelType=handles.ModelType;
delete(hWin);

function DataOK=CheckMetaData(MData)
DataOK=true;
if ~isstruct(MData)
    hWarn=warndlg('Something is wrong!!!');
    DataOK=false;
elseif ~isfinite(str2double(MData.Initial_k))
    hWarn=warndlg('k has to be numeric!!!');
    DataOK=false;    
elseif ~isfinite(str2double(MData.Initial_rC))
    hWarn=warndlg('rc has to be numeric!!!');
    DataOK=false;    
elseif ~isfinite(str2double(MData.Depth))
    hWarn=warndlg('You did not enter a depth!','Warning...','modal');
    DataOK=true;        
end

if ~DataOK
    uiwait(hWarn);
end
return



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Old Stuff
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% FieldNames=fieldnames(MData);
%     
% NLines=ones(size(FieldNames));
% NLines(end)=5;
% 
% DataOK=false;
% while ~DataOK
%     FieldContents=struct2cell(MData);
%     MDataChanged=inputdlg(FieldNames,'Edit Meta-Data',NLines,FieldContents);
%     if ~isempty(MDataChanged)
%         for i=1:length(FieldNames)
%             MData.(FieldNames{i})=MDataChanged{i};
%         end
%     end
%     
%     if ~isempty(MData.Initial_k) && isempty(MData.Initial_rC)
%         % Set Initial_rC to \citet{Horai1985}
%         k=str2double(MData.Initial_k);
%         kappa=(3.657*k-0.70)*1e-7; % /10e7
%         MData.Initial_rC=sprintf('%.2g',k./kappa);
%     end
%     
%     
%     DataOK=true;
% %     if length(str2num(MData.Depth))==1
% %         DataOK=true;
% %     else
% %         DataOK=false;
% %         warning('Depth must be a scalar number !!!');
% %     end
% end
