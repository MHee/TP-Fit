%% Working with reference models
% This section describes how to work with TP-Fit reference models.


%% Load reference model tables
% TP-Fit reference models are stored in look-up tables that are stored in
% Matlab *.mat files on disc. It is possible to load this tables by using
% the Matlab load function or by just drag and drop the *.mat files, containing
% a single structure variable M, on the command window. However, it is
% recommended to use the |LoadModel(ModelType)| function (type |help LoadModel| for
% details), to access these models. If the model locations or names will
% change, only |LoadModel| has to be adapted to keep all depending code
% working. To load the DVTP reference temperature table type:
M=LoadModel('DVTP_T');

%%
% The APCT table can be loaded with
M=LoadModel('APCT_T');

%% The table structure
% The lookup table structure |M| contains the following fields:
M

%%
% The vectors ks and rcs contain a list of all different sediment thermal
% conductivities (ks) and volumetric heat capacities (rcs) provided in the
% lookup tables. See the following subsets of ks and rcs:
ks=M.ks([1:3 end-1:end])
rcs=M.rcs([1:3 end-1:end])

%%
% The tables (matrices) k and rc contain somewhat redundant information and
% are provided for security/convenience. They contain the values in ks and
% rcs ordered in a 2D lookup table (k increasing with rows and rc
% increasing with columns). Compare the results of the following commands
% with the ks and rcs printed above:
i=3;
j=2;
k=M.k(i,j)
rc=M.rc(i,j)

%% 
% A vector of reference temperatures corresponding to k and rc 
% can be retrieved by:
T=M.T{i,j};

%%
% Temperatures are stored in an array of cells ({i,j} and not (i,j)!!!).
% The DVTP model also contains the field |T2| which contains model
% temperatures at the location of the second thermistor.

%%
% The model times, stored in the vector M.t, are not necessarily
% equidistant! Most models use a logarithmic time scale:
t=M.t;
tStart=t(1:3)
tEnd=t(end-2:end)
TStart=T(1:3)
TEnd=T(end-2:end)

%%
% Furthermore, |LoadModel| adds the location from where the model was
% loaded to the |M.Info| field which can contain also other optional
% information regarding the model:
M.Info.ModelFile

%% High-level reference model access
% The model table structure, contained in |M|, is difficult to handle,
% since times are not equidistant, and the structure of the tables may
% change in the future. Therfore, it is recommended to access the reference
% models through the "high-level" function |GetRefDecay|, if possible!
%
% Below, several examples of GetRefDecay calls are shown and the resulting 
% RefData is compared in a plot
%
% If called without parameters |GetRefDecay| will use a set of standard
% parameters. A APCT temperature model with sediment thermal conductivity
% k=1 and volumetric heat capacity rc=3.5e6 will be returned. The
% temperatures T are still at the same times t (not equidistant) as in the
% model *.mat file. The Info field of the |M| structure (see above) is
% stored in the |ModelInfo| field. 
RefData{1}=GetRefDecay;
disp(RefData{1});

%%
% To get a reference model corresponding to certain parameters, both
% parameters have to be provided (|GetRefDecay(k,rc)|). If two output
% variables are requested, |GetRefDecay| also returnes the table structure
% |M| that was loaded. The parameters have to be in the range of the table,
% otherwise NaNs are returned. If the parameters are in between table
% entries, the closest entries are chosen by default (see warning):
[RefData{2},M]=GetRefDecay(1.08,3.55e6);
k=RefData{2}.k
rc=RefData{2}.rc

%%
% It is also possible to interpolate between closest table entries 
% (|,'InterpProps',true|) instead. But this "3D" interpolation is rather slow!
%
% Also, for every call of |GetRefDecay| the reference table has to be
% loaded from disc. If you want to get many models from the *same* table it
% is possible to speed things up by retrieving the table (|M|) 
% during the first call (see above) and reuse it with (|,'M',M|).
RefData{3}=GetRefDecay(1.08,3.55e6,'InterpProps',true,'M',M);
k=RefData{3}.k
rc=RefData{3}.rc

%%
% All the data above is still at original model times. If you want the
% model at specific times (e.g. from 0s to 300s in 10s intervals), time
% interpolation is enabled using the |'ts'| parameter. Time interpolation
% is much faster than parameter interpolation (both types of interpolation
% can be combined!).
RefData{4}=GetRefDecay(2.08,4.2e6,'InterpProps',true,'ts',0:10:300);

%%
% To load a model other than the APCT temperature model the model type (see
% |LoadModel|) as to be specified, explicitly. Using the DVTP Model it is
% also possible to retrieve the temperatures of the second sensor
% (|,'GetT2',true|).
RefData{5}=GetRefDecay(1,3.5e6,'ModelType','DVTP_T','GetT2',true);
disp(RefData{5});

%%
% To get a nice ASCII table of the reference model use the |Print| option
% (|,'Print',true|) if you specifiy an additional filename
% (|,'FileName','MyOutFile.dat'|) the ASCII-table is dumped to the file
% instead to the promt:
GetRefDecay(1,3.5e6,'ts',[0:10:50],'Print',true);

%% Graphical model comparison
% Ignore the following code and have a look at the figure below
clf;
a1=subplot(2,1,1);
hold on;
N=length(RefData);
Colors=lines(N);
for i=1:N
    LStr{i}=sprintf('%d: k:%.3f rc:%.3e  (%s)\n',...
                            i,RefData{i}.k,RefData{i}.rc,RefData{i}.ModelType);
    h(i)=plot(RefData{i}.t,RefData{i}.T,'.-','Color',Colors(i,:));
    if isfield(RefData{i},'T2')
        plot(RefData{i}.t,RefData{i}.T2,'.:','Color',Colors(i,:));
    end
end
xlabel('Time (s)');
ylabel('Normalized temperature');

AxesParams={'Box','on',...
    'TickDir','out'};
set(gca,'XLim',[0 10*60],AxesParams{:});
legend(h,LStr,'Interpreter','none');

a2=subplot(2,1,2);
copyobj(h(1:3),gca);
xlabel('Time (s)');
ylabel('Normalized temperature');
set(gca,'XLim',[0 10],AxesParams{:});

%%
% Each line numbered in the legend corresponds to the |RefData{i}| of the
% previous section. The dotted line shows the second thermistor of the DVTP
% model. The lower plot high-lights the interpolation of thermal
% properties. The upper and the lower lines are straiht from the look-up
% table, while the red line is intepolated between these two. Also, the
% different sampling rates/intervals can be seen.

