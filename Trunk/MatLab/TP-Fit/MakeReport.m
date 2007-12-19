function MakeReport(Data,FileName,varargin)

if exist('FileName','var')
    % Write to file
    fid=fopen(FileName,'wt');
else
    % Dump to screen
    fid=1;
end

Opts.Delimiter=sprintf('\t');
%Opts.Delimiter='|';

Opts=ParseFunOpts(Opts,varargin);
DL=Opts.Delimiter;

% Change the section below to costumize the Data report!

NSft=Data.Res.BestSft; % Use best Time-shift

fprintf(fid,' = TP-Fit Report =\n\n');

fprintf(fid,'TP-Fit Version %g\n\n%s processed by %s (%s)\n\n',...
    Data.TPFitInfo.Version,...
    Data.ImportInfo.DatFile, Data.Info.Operator,datestr(now,0));

fprintf(fid,' == Results ==\n');
fprintf(fid,'%sEstimated formation temperature (°C):%s %.2f\n',...
                            DL,DL,Data.Res.Fit(NSft,2));
fprintf(fid,'%sMean misfit (°C):%s %.2g\n\n',...
                            DL,DL,Data.Res.NLSqr(NSft));

fprintf(fid,' == Model Parameters ==\n');
fprintf(fid,'%sk (W/(m K)):%s %.2f\n',...
                            DL,DL,Data.Res.k);
fprintf(fid,'%src (MJ/(m³K)):%s %.2f\n',...
                            DL,DL,Data.Res.rc*1e-6);
fprintf(fid,'%st-sft (s):%s %.3f\n',...
                            DL,DL,Data.Res.tSfts(NSft));
fprintf(fid,'%sModel Type:%s %s\n\n',...
                            DL,DL,Data.ModelType);
                        
fprintf(fid,' == Picks ==\n');
fprintf(fid,'%st0 (s):%s %.0f\n',...
                            DL,DL,Data.Picks.t0);
fprintf(fid,'%sWindow Start (s):%s %.0f\n',...
                            DL,DL,Data.Picks.Window(1));
fprintf(fid,'%sWindow Stop (s):%s %.0f\n\n',...
                            DL,DL,Data.Picks.Window(2));

                        
fprintf(fid,' == Meta Data ==\n\n');
Info=Data.Info;
fprintf(fid,'%sExpedition:%s %s\n',...
                            DL,DL,Info.Expedition);
fprintf(fid,'%sSite:%s %s\n',...
                            DL,DL,Info.Site);
fprintf(fid,'%sHole:%s %s\n',...
                            DL,DL,Info.Hole);
fprintf(fid,'%sCore:%s %s\n',...
                            DL,DL,Info.Core);
fprintf(fid,'%sCore type:%s %s\n\n',...
                            DL,DL,Info.CoreType);
                        
fprintf(fid,'%sDepth (mbsf):%s %s\n',...
                            DL,DL,Info.Depth);
fprintf(fid,'%sDepth error (m):%s %s\n\n',...
                            DL,DL,Info.DepthError);
                        
fprintf(fid,'%sSediment thermal conductivity (W/(m K)):%s %s\n',...
                            DL,DL,Info.Initial_k);
fprintf(fid,'%sSediment heat capacity (J/(m³ K)):%s %s\n\n',...
                            DL,DL,Info.Initial_rC);

fprintf(fid,'%sTool type:%s %s\n',...
                            DL,DL,Info.ToolType);
fprintf(fid,'%sData format:%s %s\n\n',...
                            DL,DL,Data.ImportInfo.DataType);

fprintf(fid,'%sEstimated temperature error (°C):%s %s\n',...
                            DL,DL,Info.TError);
fprintf(fid,'%sData quality description:%s %s\n',...
                            DL,DL,Info.DataQuality);
fprintf(fid,'%sData quality number:%s %s\n\n',...
                            DL,DL,Info.DataQualityNo);

fprintf(fid,' == Comment ==\n');
for i=1:length(Info.Comment)
    fprintf(fid,'%s\n',Info.Comment{i});
end
fprintf(fid,'\n');

fprintf(fid,' == Plots ==\n');
[FDir, FBaseName]=fileparts(FileName);
fprintf(fid,'[[%s | {{%s}}]]\n',...
    [strrep(FBaseName,'Report','Result') '.eps'],...
    [strrep(FBaseName,'Report','Result') '.png']);

fprintf(fid,'[[%s | {{%s}}]]\n\n',...
    [strrep(FBaseName,'Report','Contours') '.eps'],...
    [strrep(FBaseName,'Report','Contours') '.png']);

                                             
% fprintf(fid,...
%     'Model parameters: k= %.2f (W/mK)  rc= %.2f (MJ/m³K) t-sft= %.3f (s)\n\n',...
%     Data.Res.k,Data.Res.rc*1e-6,Data.Res.tSfts(NSft));                        

fprintf(fid,' == Results vs time-shift ==\n');
fprintf(fid,'%sTime-shift (s)%sMean misfit (°C)%sTemperature (°C)\n',DL,DL,DL);
fprintf(fid,[DL '%10.3f' DL '%10.3f' DL '%10.3f\n'],...
[Data.Res.tSfts; Data.Res.StdDev; Data.Res.Fit(:,2)']);

% Picked time Window
%fprintf(fid,'\n\nPicked time window after penetration\n');
%fprintf(fid,['Start: %10.1f (s)\n' 'Stop:  %10.1f (s)\n'],Data.Picks.Window);


% Data & Model
fprintf(fid,' == Data and model ==\n');
RefDat=GetRefDecay(Data.Res.k,Data.Res.rc,...
    'ts',Data.tr-Data.Res.tSfts(NSft),...
    'ModelType',Data.ModelType);

Ts=Data.Res.Fit(NSft,1)*RefDat.T+Data.Res.Fit(NSft,2);

fprintf(fid,[DL 'Time (s)' DL 'T_Data (°C)' DL 'T_Model (°C)\n']);
fprintf(fid,[DL '%10.1f' DL '%10.4f' DL '%10.4f\n'],...
[Data.tr Data.T Ts]');



% if not screen-dump, close file
if fid~=1
    fclose(fid);
end

%
% Plot Data
%

% figure(1)
% clf;
% hold on;
% plot(Data.tr,Ts,'r')
% plot(Data.tr,Data.T)
