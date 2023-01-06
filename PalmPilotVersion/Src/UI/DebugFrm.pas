unit DebugFrm;

{$ifdef VersionCMD} NO WAY!! {$Endif}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls;

type
  TFormDebug = class(TForm)
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
  public
    procedure Write(Const S: String);
    procedure DebugClear;
  end;

var
  FormDebug: TFormDebug;

implementation

{$R *.DFM}

uses Util, Misc;

procedure TFormDebug.Write(Const S: String);
begin
  Memo1.Lines.Add(S);
end;

procedure TFormDebug.DebugClear;
begin
  FormDebug.Memo1.Lines.Clear
end;

procedure TFormDebug.FormCreate(Sender: TObject);
begin
  Inherited;
  IniFilePosLoad(Self,'Debug');
end;

procedure TFormDebug.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  //Action:=caNone;
  //Visible:=False;
  Debug(i2s(ord(Action)));
  IniFilePosSave(Self,'Debug');
  Inherited;
end;

end.

