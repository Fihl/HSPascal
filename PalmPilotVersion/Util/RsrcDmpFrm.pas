unit RsrcDmpFrm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, StdCtrls,
  RsrcIo;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    meDump: TMemo;
    edFile: TEdit;
    buDump: TButton;
    Button1: TButton;
    procedure buDumpClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    Rsrc: TRsrc;
  end;

var
  Form1: TForm1;

implementation

Uses uMisc1;

{$R *.DFM}

procedure TForm1.buDumpClick(Sender: TObject);
var
  RsrcNo,Loop,P: Integer;
  SInfo,S4,B: String;
Function S2I(S: String): Cardinal;
begin
  Result:=0;
  while S<>'' do begin Result:=Result*256+ord(S[1]); Delete(S,1,1) end;
end;
Function Hex(N,Size: Cardinal): String;
begin
  Result:=Format('%.8x',[N]);
  Result:=Copy(Result,9-Size,Size);
end;
Function HexS_D(S: String): String;
begin
  Result:=Hex(S2I(S), Length(S)*2)+'('+i2s(S2I(S))+')';
end;
Function HexS(S: String): String;
begin
  Result:=Hex(S2I(S), Length(S)*2);
end;
procedure D(S: String);
var N: Integer;
begin
  S:=SInfo+S; SInfo:='';
  For N:=1 to Length(S) do
    if S[N]=#0 then S[N]:='.';
  //S:=S4+': '+Hex(Loop,2)+' - '+Hex(P-1,4)+': '+' '+S;
  meDump.Lines.Add(S);
end;
Function G(Cnt: Integer): String;
begin
  Result:=Copy(B,P,Cnt); Inc(P,Cnt);
end;
procedure Dump(Pat: String);
var Asc,S,S2: String; N: Integer;
begin
  Asc:=Copy(B,P,500);
  for N:=1 to Length(Asc) do
    if not (Asc[N] in [' '..#126]) then Asc[N]:='.';
  for N:=1 to Length(Pat) do
    if P>Length(B) then BREAK
    else
      Case Pat[N] of
      'C': begin S2:=G(1); if S2=#0 then S2:='.'; S:=S+S2 end;
      'W': S:=S+' '+HexS_D(G(2));
      'L': S:=S+' '+HexS_D(G(4));
      'w': S:=S+' '+HexS(G(2));
      'l': S:=S+' '+HexS(G(4));
      ' ': S:=S+' ';
      end;
  D(S+'='+Asc)
end;
procedure DumpCode;
var S: String;
begin
  Delete(B,100,10000);
  if RsrcNo=0 then
    Dump('llll wwwwwwwwww') //Dump('LLLL WWWWWW')
  else begin
    while P<Length(B) do
      S:=S+Hex(s2i(G(2)),4)+' ';
    D(S+' Max 100 Words!');
  end;
end;
begin
  Rsrc:=TRsrc.Create;
  if not Rsrc.LoadFromFile(edFile.Text) then EXIT;
  with Rsrc.Buf do
    meDump.Lines.Add(Rsrc.GetInfo);
  Loop:=Rsrc.Cnt;
  for Loop:=1 to Loop do begin
    Update;
    P:=1; B:=Rsrc.Get1Rsrc(Loop);
    with Rsrc.Rsrcs[Loop] do begin
      RsrcNo:=RNo;
      S4:=Name;
      D(Name+'-'+i2h2(RsrcNo)+'   '+i2s(AbsPos)+'='+i2h2(AbsPos)+', '+i2s(L2));
    end;
    if (S4='tver') or (S4='tain') then
      D(PChar(B))
    else if S4='code' then
      DumpCode
      //else if S4='data' then Dump('wwwwwwwwwwwwwWL')
    else
      Dump('wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww');
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  edFile.Text:='C:\Palm\Examples\xxx.prc';
  Rsrc.SaveToFile(edFile.Text);
end;

end.
