unit ZLib1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

Uses ZLib, ZLib2;

procedure TForm1.Button1Click(Sender: TObject);
var
  S: String; P: Pointer; N,PSize: Integer;
  M: TMemoryStream; DC: TZDecompressionStream;
begin
  S:=Edit1.Text + #13#10;
  //TZCompressionLevel = (zcNone, zcFastest, zcDefault, zcMax);
  S:=ZCompressStr(S);
  Edit2.Text:=IntToStr(Length(S))+' '+S;
  //S:=ZDeCompressStr(S);

  M:=TMemoryStream.Create;
  M.Write(S[1],Length(S)); M.Position:=0;
  DC:=TZDecompressionStream.Create(M);
  SetLength(S,100000);
  N:=DC.Read(S[1],Length(S));
  SetLength(S,N);
  DC.Free;
  Edit1.Text:=S;

  ///Edit1.Text:=S;
  exit;
  ZCompress(@S[1],Length(S),P,PSize);
  SetLength(S,PSize); Move(P^,S[1],PSize);
  Edit2.Text:=S;
end;

procedure t6p7p2p2d4;
var
   i, max : integer;
   b: Boolean;
procedure T; begin if B then writeln('Ok') else writeln('Bad') end;
procedure F; begin b:=not b; t end;
begin
(***
   max:=-(-maxint);
   i:=-maxint;
   if odd(maxint) then
      i:=(max-((max div 2)+1))*2
   else
      i:=(max-(max div 2))*2;
(***)
//   asm trap #8 end;
   i:=1; b:=i<2; t;
   i:=2; b:=i<2; f; //
   i:=3; b:=i<2; f;
   i:=1; b:=2>i; t;
   i:=2; b:=2>i; f;
   i:=3; b:=2>i; f;
   writeln('-------');

   i:=1; b:=i>2; f;
   i:=2; b:=i>2; f; //
   i:=3; b:=i>2; t;
   i:=1; b:=2<i; f;
   i:=2; b:=2<i; f;
   i:=3; b:=2<i; t;

(**if (maxint-1<=i) and (i<=maxint) then
      PASS('6.7.2.2-4')
   else
      FAIL('6.7.2.2-4')
(***)
end;

procedure TForm1.Button2Click(Sender: TObject);
var S: String;
//P: Pointer; PSize: Integer;
Const Ch: Char='1';
begin
////////////// test!!!  t6p7p2p2d4;
  S:=LoadFromZip('xx.zip','xx\Xx'+Ch+'.txt',FALSE);
  Inc(Ch); if Ch>'4' then Ch:='1';
  Edit2.Text:=S;
end;

end.

