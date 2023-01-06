program ZLibTest;

uses
  Forms,
  ZLib1 in 'ZLib1.pas' {Form1},
  ZLib2 in 'ZLib2.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
