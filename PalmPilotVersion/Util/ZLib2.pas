unit ZLib2;

interface

Function LoadFromZip(ZipFile,Fil: String; UsePathInfo: Boolean=True): String;

implementation

Uses SysUtils, PackerIO, Util;

Function LoadFromZip(ZipFile,Fil: String; UsePathInfo: Boolean=True): String;
var
  S: String;
  Hdr: tIORec;
begin
  Result:='';
  PackerIO.InitHdr(Hdr);
  if not OpenPackFile(Hdr,ZipFile) then EXIT;
  if not UsePathInfo then
    Fil:=ExtractFileName(Fil);
  while NextPackFile(Hdr) do begin
    if Hdr.ioSize=0 then CONTINUE;
    S:=Hdr.ioName;
    ReplaceStr('/','\',999,S);
    if not UsePathInfo then
      S:=ExtractFileName(S);
    if not CmpStr(S,Fil) then CONTINUE;
    SetLength(S,Hdr.ioSize);
    if PackIoRead(Hdr,S[1],Hdr.ioSize) then begin
      Result:=S;
      BREAK;
    end;
    Result:='';
  end;
  ClosePackFile(Hdr);
end;

end.

