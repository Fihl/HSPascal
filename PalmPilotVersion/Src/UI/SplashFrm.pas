unit SplashFrm;

{$ifdef VersionCMD} NO WAY!! {$Endif}

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls;

type
  TSplashForm = class(TForm)
    Panel1: TPanel;
    Image1: TImage;
    Timer1: TTimer;
    procedure Timer1Timer(Sender: TObject);
  public
    Procedure Splash(HowLong: Integer);
  end;

var
  SplashForm: TSplashForm;

implementation

{$R *.DFM}

Procedure TSplashForm.Splash(HowLong: Integer);
begin
  Timer1.Interval:=HowLong;
  if HowLong>0 then begin
    Timer1.Enabled:=True;
    Show;
    Update;
  end else Hide;
end;

procedure TSplashForm.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled:=False;
  ///{ $include Expire.pas}   // Needs "Uses Global"
  Hide;
end;

end.

