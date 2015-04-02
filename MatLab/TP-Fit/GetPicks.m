function Data=GetPicks(Data)
if ~isfield(Data,'ModelType')
    switch Data.ImportInfo.DataType
        case {'ANTARES','ADARA','TPFIT_RES'}
            Data.ModelType='APCT_T';
        case {'DVTP','SETP_PROTOTYPE','DVTP_RAW'}
            Data.ModelType='DVTP_T';
        case 'QBASIC_NEEDLE'
            Data.ModelType='TeKaNeedle_T';
            if ~isfield(Data,'Picks')
                Picks.t0=0;
                Picks.Window=[0 max(Data.t)-3];
                Data.Picks=Picks;
                Data.tr=Data.t;
            end

        otherwise
            error('Do not know which reference model to use...');
    end
end

if ~isfield(Data,'Picks')
    Picks.t0=0;
    Picks.Window=[60 600];
    Data.Picks=Picks;
    Data.tr=Data.t;
end
if ~isfield(Data,'Info')
    Data.Info.Operator='Andy Fisher';
end
if ~isfield(Data,'Session')
    Data.Session.XLim=[-Inf Inf];
    Data.Session.YLim=[-Inf Inf];
end


h=PickWindow('UserData',Data);
uiwait(h);
try
    Data=get(h,'UserData');
    close(h);
catch
    warndlg({'Something went wrong during picking!',...
        'Try again and make sure you save the picks before you close the dialog!'});
end


