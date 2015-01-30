function Data=ImportNeedleData(FileName)

DoPlot=1;
[fid,Message]=fopen(FileName,'r');
if (fid==-1)
    warning(Message);
end

Header=textscan(fid,'%*15c %s',11);
fclose(fid)
Header=Header{1}

Info.Core=Header{1};
Info.Channel=str2num(Header{2});
Info.Date=Header{3};
Info.Time=Header{4};
Info.Operator=Header{5};
Info.Depth=Header{6};
Info.SamplingRate=str2num(Header{7});
Info.Pre=str2num(Header{8});
Info.Pulse=str2num(Header{9});
Info.Decay=str2num(Header{10});
Info.hPower=str2num(Header{11});
Data.Info=Info;

[Idx,R]=textread(FileName,'%f %f','headerlines',11);


A(1)=1.1273831249583954e-003;
A(2)=2.3438360900838187e-004;
A(3)=8.6720247915471324e-008;

T=(1./(A(1)+A(2)*log(R)+A(3)*(log(R).^3)))-273.15;

Data.T=T;
Data.t=(Idx-Info.Pre)*Info.SamplingRate;
Data.R=R;
Data.H=Header;

if DoPlot
    figure(1);
    subplot(2,1,1);
    plot(Data.t,R);
    set(gca,'XAxisLocation','top');
    ylabel('R (\Omega)');
    grid on;

    subplot(2,1,2);
    plot(Data.t,T);
    ylabel('T (°C)');
    xlabel('t (s)');
    grid on
end