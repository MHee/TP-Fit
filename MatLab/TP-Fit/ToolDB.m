classdef ToolDB < handle
% ToolDB A class that implements a database 
    properties
        DB=struct('DataTypes',[],'ToolTypes',[],'ToolSettings',[]);
        Opts=struct(...
                'DBFile',[mfilename('fullpath'),'.json']);
    end
    methods
        function self=ToolDB(varargin)
            self.Opts=ParseFunOpts(self.Opts,varargin);
%             if strcmp(self.Opts.DBFile,'')
%                 self.Opts.DBFile=[mfilename('fullpath')];
%             end
            self.loadDB;
        end
        function loadDB(self)
            if exist(self.Opts.DBFile,'file')
                self.DB=loadjson(self.Opts.DBFile);
            else
                fprintf('ToolDB.json does not exist, loading default!\n');
                self.DB=loadjson([self.Opts.DBFile,'_default']);
            end
            for table={'DataTypes','ToolTypes','ModelTypes','ToolSettings'}
                self.DB.(char(table))=cell2mat(self.DB.(char(table)));
            end
        end
        function saveDB(self)
            savejson('',self.DB,self.Opts.DBFile);
        end
        function addToolSetting(self,Setting)
            defaultSetting.DataType='';
			defaultSetting.ToolID='_All_';
			defaultSetting.ToolType='';
			defaultSetting.ModelType='';
            
            newSetting=ParseFunOpts(defaultSetting,Setting);
            fldNames=fieldnames(newSetting);
            
            for i=1:length(fldNames)
                fldNames(i);
                if strcmp(newSetting.(char(fldNames(i))),'')
                    warning('All fields in new setting have to be set!!!');
                    return
                end
            end
            
            if self.hasToolSetting(newSetting.DataType,'ToolID',newSetting.ToolID)
                warning('Setting %s - %s already exist!!! Keeping original.',...
                    newSetting.DataType,newSetting.ToolID)
                return
            end
            
            self.DB.ToolSettings(end+1)=newSetting;
            self.saveDB
        end
        
        function outSetting=findToolSetting(self,DataType,varargin)
            Opts.ToolID='_ALL_'; % Default setting for all Instruments of certain datatype
            Opts=ParseFunOpts(Opts,varargin);
            outSetting=[];
            DataTypes={self.DB.ToolSettings(:).DataType};
            ToolIDs={self.DB.ToolSettings(:).ToolID};
            idx=find(strcmp(DataTypes,DataType)&strcmp(ToolIDs,Opts.ToolID));
            if isempty(idx)
                % Specific ToolID not found, look for generic settings
                idx=find(strcmp(DataTypes,DataType)&strcmp(ToolIDs,'_ALL_'));
            end
            switch length(idx) 
                case 1
                    outSetting = self.DB.ToolSettings(idx);
                case 0
                    warning('No matching settings found for %s -- %s',DataType, Opts.ToolID)
                otherwise
                    warning('Several matching tool settings!!!')
            end 
        end
        
        function answer=hasToolSetting(self,DataType,varargin)
            Opts.ToolID='_ALL_'; % Default setting for all Instruments of certain datatype
            Opts=ParseFunOpts(Opts,varargin);
            DataTypes={self.DB.ToolSettings(:).DataType};
            ToolIDs={self.DB.ToolSettings(:).ToolID};
            answer=any(strcmp(DataTypes,DataType)&strcmp(ToolIDs,Opts.ToolID));
        end
 
    end % methods
end % classdef

