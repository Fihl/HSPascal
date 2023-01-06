program HSPC;
{$APPTYPE CONSOLE}
uses
  Classes, SysUtils, Global, Misc, Scanner, HSPMain;

Function MyUICallBack(S: String): Boolean;
begin
  Result:=True; //Do continue compiling
  WriteCMD(S);
end;

Procedure DoIt;
var
  S: String;
  N: Integer;
begin
  FillChar(UIIntf,SizeOf(UIIntf),0);
  try
    S:=LoadOptions(NIL,GetCurrentDir); //Return Filename
  except
    S:=''
  end;
  if S='' then begin
    WriteCMD('High Speed Pascal, '+HSVersionDate);
    WriteCMD(AboutHelpTxt);
    WriteCMD('Syntax:  hspc [options] file');
    WriteCMD('options: -$D+, -I SearchPaths, -O OutputPath');
    EXIT
  end;
  S:=ExpandFileName(S);
  UIIntf.Src:=ExtractFileName(S);
  if Verbose then UIIntf.CallBack:=MyUICallBack;
  S:=ExtractFilePath(S);
  ChDir(S);
  if not DoCompiler then
    with UIIntf do begin
      if Verbose then begin
        WriteCmd(ErrLineStr);
        S:=''; for N:=1 to ErrPos-1 do S:=S+' ';
        for n:=1 to ErrLen do S:=S+'^';
        WriteCMD(S);
      end;
      S:=Format('%s;%d;%d;%d;%d-%s', [ErrFile,ErrLine,ErrPos,ErrLen,ErrNo,ErrStr]);
        //R:\hspc\test.pas:8:27:3:170-Set base type out of range
        //      end else
        //        S:=Format('%s:%d:%d-%s', [ErrFile,ErrLine,ErrNo,ErrStr]);
        //        //R:\hspc\test.pas:8:170-Set base type out of range
      WriteCmd(S);
      Halt(4);
    end;
end;

begin
  DoIt;
end.