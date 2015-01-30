function SaveSession(Data,DatFileName)

if exist('DatFileName','var')
    [pathstr,name]=fileparts(DatFileName);
else
    [pathstr,name] = fileparts(Data.ImportInfo.DatFile);
    %Data.ImportInfo.DatPath
end

DefaultName=fullfile(Data.ImportInfo.DatPath, [name '_Session01.mat']);
[FileName,PathName]=uiputfile('*.mat',...
    ['Save Session: ' Data.ImportInfo.DatFile],...
    DefaultName);

if FileName
    disp([PathName FileName]);
    save([PathName FileName],'Data');
end