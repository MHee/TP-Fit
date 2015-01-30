function [RefDat,M]=GetRefDecay(k,rc,varargin)
%This function gives access to the modelled APCT-3 referece curves
% A call of the function could look like this:
% RefDat=GetRefDecay(1.11,3.3e6,'ts',[0:10:100],'Print',true,'FileName','Test.Dmp')
% Here, RefDat is a structure that holds desired information. If 'ts' is
% given, the result is interpolated to the times that are given (from 0s to
% 100s in steps of 10s in the example). Otherwise, original model times are
% returned. If 'Print' is true, ASCII data of the results is dumped to the
% screen. This dump can be redirected to a file by ALSO providing a
% 'FileName'.

% Martin Heesemann 09.12.2006

% Default Options
Opts.ts=[];
Opts.Print=false;
Opts.NSens=1; % Virtual Sensor to use
Opts.FileName=[];
Opts.GetT2=false; % Get second temperature (of DVTP data)
Opts.InterpProps=false;
Opts.NearestWarning=true;
Opts.ModelType='APCT_T';
Opts.M=[]; % Provide Model Matrix to speed up Process
Opts=ParseFunOpts(Opts,varargin);

if ~exist('k','var')
    k=1;
    rc=3.4e6;
end

if isempty(Opts.M)
    M=LoadModel(Opts.ModelType);
else
    M=Opts.M;
end

use_T2=Opts.GetT2 && isfield(M,'T2');

% Check if Parameters are in Range of matrix
if ( (k<min(M.ks)) || (k>max(M.ks)) || (rc<min(M.rcs)) || (rc>max(M.rcs)))
    warning('Parameters are out of Range!!!!');
    RefDat=0;
    return
end

% Find nearest k in lookup table
[dummy,i]=min(abs(M.ks-k));
if (abs(M.ks(i)-k) < eps(1e3))
    kInTable=true;
else
    kInTable=false;
end
 
% Find nearest rc in lookup table
[dummy,j]=min(abs(M.rcs-rc));
if (abs(M.rcs(j)-rc) < eps(1e9))
    rcInTable=true;
else
    rcInTable=false;
end

if ( ~Opts.InterpProps || (kInTable && rcInTable) )
    % Do not interpolate thermal props
    if (~kInTable && Opts.NearestWarning)
        warning('k not in model lookup table. Unsing closest!');
    end
    if (~rcInTable && Opts.NearestWarning)
        warning('rc not in model lookup table. Unsing closest!');
    end
    RefDat.k=M.ks(i);
    RefDat.rc=M.rcs(j);
    RefDat.t=M.t;
    RefDat.T=M.T{i,j}(Opts.NSens,:);
    if use_T2
        RefDat.T2=M.T2{i,j};
    end
else
    % Interpolate thermal props
    RefDat.k=k;
    RefDat.rc=rc;
    RefDat.t=M.t;
    
    k_G=repmat(M.k,[1 1 length(M.t)]);
    rc_G=repmat(M.rc,[1 1 length(M.t)]);
    t_G(1,1,:)=M.t;
    t_G=repmat(t_G,[size(k_G,1) size(k_G,2) 1]);
    T_G=zeros(size(k_G));
    if use_T2
        T2_G=T_G;
    end
    for i = 1:length(M.ks)
        for j= 1:length(M.rcs)
            T_G(i,j,:)=M.T{i,j}(Opts.NSens,:);
            if use_T2
                T2_G(i,j,:)=M.T2{i,j};
            end
        end
    end
    
    RefDat.T= interp3(rc_G,k_G,t_G,T_G,rc,k,M.t,'cubic',NaN);
    RefDat.T=RefDat.T(:)';
    if use_T2
        RefDat.T2= interp3(k_G,rc_G,t_G,T2_G,rc,k,M.t,'cubic',NaN);
        RefDat.T2=RefDat.T2(:)';
    end
end

% Interpolate times, if ts are supplied
if ~isempty(Opts.ts)
    % RefDat.T=interp1(RefDat.t,RefDat.T,Opts.ts,'cubic',NaN); % "cubic" is discouraged
    RefDat.T=interp1(RefDat.t,RefDat.T,Opts.ts,'pchip',NaN);
    if use_T2
        % RefDat.T2=interp1(RefDat.t,RefDat.T2,Opts.ts,'cubic',NaN); % "cubic" is discouraged
        RefDat.T2=interp1(RefDat.t,RefDat.T2,Opts.ts,'pchip',NaN);
    end
    RefDat.t=Opts.ts;
end

if Opts.Print
    fid=1; % Dump output on screen
    if ~isempty(Opts.FileName)
        % Dump to file if FileName is provided
        fid=fopen(Opts.FileName,'w');
    end
    
    fprintf(fid,'APCT-3 Model: k= %.2f (W/(m K)); rc= %.2f (MJ/ m^3 K)\n',RefDat.k,RefDat.rc*1e-6);
    fprintf(fid,'t (s)\tT (°C)\n');
    fprintf(fid,'%f\t%f\n',[RefDat.t;RefDat.T]);
    
    if ~isempty(Opts.FileName)
        fclose(fid);
    end
end

RefDat.ModelType=Opts.ModelType;
RefDat.ModelInfo=M.Info;