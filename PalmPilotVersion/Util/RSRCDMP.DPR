program RsrcDmp;

uses
  Forms,
  RsrcDmpFrm in 'RsrcDmpFrm.pas' {Form1},
  uMisc1 in 'uMisc1.pas',
  RsrcIo in 'RsrcIo.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
