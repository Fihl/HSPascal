unit HelpFrm;

interface

uses
  Windows, Messages, Forms, SysUtils, Classes, Graphics,
  Controls, Dialogs, OleCtrls, StdCtrls,
  PdfLib_TLB;
  
type
  TFormHelp = class(TForm)
    gbPascal: TGroupBox;
    gbPDF: TGroupBox;
    Pdf1: TPdf;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
  public
  end;

var
  FormHelp: TFormHelp;

implementation

{$R *.DFM}

uses Util, Misc;

procedure TFormHelp.FormCreate(Sender: TObject);
begin
  Inherited;
  IniFilePosLoad(Self,'HelpPdf');
  //pdf1.SetNamedDest('NetHostInfoBufType');
  //pdf1.SetCurrentPage(39);
end;

procedure TFormHelp.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  IniFilePosSave(Self,'HelpPdf');
  Debug(i2s(ord(Action)));
  Inherited;
end;

end.

