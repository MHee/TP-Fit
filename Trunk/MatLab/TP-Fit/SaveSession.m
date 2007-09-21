function SaveSession(Data)
[pathstr,name,ext,versn] = fileparts(Data.ImportInfo.DatFile);

DefaultName=[Data.ImportInfo.DatPath name '_Session01.mat'];
[FileName,PathName]=uiputfile('*.mat','Save Session...', DefaultName);

if FileName
    disp([PathName FileName]);
    save([PathName FileName],'Data');
end