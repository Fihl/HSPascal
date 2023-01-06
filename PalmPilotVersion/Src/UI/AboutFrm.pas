unit AboutFrm;

{$ifdef VersionCMD} NO WAY!! {$Endif}

interface

uses
  Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls,
  Global;

type
  TAboutBox = class(TForm)
    Panel1: TPanel;
    ProgramIcon: TImage;
    ProductName: TLabel;
    edHSVersion: TLabel;
    Copyright: TLabel;
    CommentsLimited: TLabel;
    OKButton: TButton;
    Label1: TLabel;
    procedure OnCloseIt(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutBox: TAboutBox;

implementation

{$R *.DFM}

procedure TAboutBox.OnCloseIt(Sender: TObject);
begin
  Close
end;

procedure TAboutBox.FormCreate(Sender: TObject);
begin
  edHSVersion.Caption:=HSVersion;
  CommentsLimited.Caption:=AboutHelpTxt;
  if TimeLimited then
    CommentsLimited.Font.Color:=clRed;
end;

end.

