program PreCompHdr;
{$APPTYPE CONSOLE}
uses
  Windows, Classes, SysUtils, ZLib, ZLib2;

Procedure ConvertFile(Fil: String);
var Data: String; M: TMemoryStream; F: File;
begin
  M:=TMemoryStream.Create;
  try
    M.LoadFromFile(Fil);
    SetLength(Data,M.Size);
    if Data<>'' then begin
      M.Read(Data[1],M.Size);

      Data:=ZCompressStr(Data);
      Data:=ZCompressStr(Data);
      Byte(Data[1]):=Byte(Data[1]) xor $AA;

      Fil:=ChangeFileExt(Fil, '.Hsu');
      AssignFile(F,Fil); Rewrite(F,1);
      BlockWrite(F,Data[1],Length(Data));
      CloseFile(F);
    end;
  except
    Writeln('Cannot open file: '+Fil);
    Readln;
  end;
  M.Free;
end;

Procedure DumpFile(Fil: String);
var S: String; Ch: Char;
begin
  For Ch:='1' to '3' do begin
    S:=LoadFromZip(Fil,'xx\Xx'+Ch+'.txt',FALSE);
    Writeln(Ch+'-'+S);
  end;
  S:=LoadFromZip(Fil,'readMe.txt',FALSE);
  Writeln(S);
  Sleep(1000);
end;

begin
(*****
  writeln(99.9999:2);
  writeln(99.9999:8);
  writeln(99.9999:12);
  writeln(99.9999:13);
  writeln(99.9999:14);
  writeln(99.9999:15);
  writeln(99.9999:12:2);
  writeln(99.9999:12:5);
  writeln(99.9999:12:0);
  writeln(99.9999:18:5);
(********)
  if ParamCount<>1 then begin
    Writeln('Syntax: PreCompHdr <FileName>');
    Sleep(1000);
    HALT
  end;
  //DumpFile(ParamStr(1));
  ConvertFile(ParamStr(1));
end.
