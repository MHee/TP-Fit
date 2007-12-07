function MakeReport(Data,FileName)

if exist('FileName','var')
    % Write to file
    fid=fopen(FileName,'wt');
else
    % Dump to screen
    fid=1;
end

% Change the section below to costumize the Data report!

NSft=Data.Res.BestSft; % Use best Time-shift

fprintf(fid,'TP-Fit Report\n\n');
fprintf(fid,'Estimated formation temperature: %.2f °C\n\n',...
                            Data.Res.Fit(NSft,2));
fprintf(fid,...
    'Model parameters: k= %.2f (W/mK)  rc= %.2f (MJ/m³K) t-sft= %.3f (s)\n\n',...
    Data.Res.k,Data.Res.rc*1e-6,Data.Res.tSfts(NSft));                        
                        
fprintf(fid,'Time-Shift (s) StdDev (°C)  Temperature (°C)\n');
fprintf(fid,'%10.3f  %10.3f %10.3f\n',...
[Data.Res.tSfts; Data.Res.StdDev; Data.Res.Fit(:,2)']);

% Picked time Window
fprintf(fid,['\n\nPicked time window after penetration\n']);
fprintf(fid,['Start: %10.1f (s)\n' 'Stop:  %10.1f (s)\n'],Data.Picks.Window);



% Data & Model
RefDat=GetRefDecay(Data.Res.k,Data.Res.rc,...
    'ts',Data.tr-Data.Res.tSfts(NSft),...
    'ModelType',Data.ModelType);

Ts=Data.Res.Fit(NSft,1)*RefDat.T+Data.Res.Fit(NSft,2);

fprintf(fid,['\n\nData and Model\n' 'Time (s) T_Data (°C) T_Model (°C)\n']);
fprintf(fid,'%10.1f  %10.4f %10.4f\n',...
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
