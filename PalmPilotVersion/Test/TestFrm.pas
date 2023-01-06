unit TestFrm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.Button1Click(Sender: TObject);
type
  PX = ^TX;
  TX= Record
    a,b: Integer;
    P: PX;
  end;
var
  B: TX;
asm
  lea edi,b
  mov tx.p[edi],eax
  mov tx.b[edi],eax
end;


end.
