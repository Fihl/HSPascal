unused!!!!!!!!!!
unit F1HelpFrm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics,
  Controls, Forms, Dialogs, StdCtrls, ComCtrls;

type
  TFormHelpF1 = class(TForm)
    RichEdit1: TRichEdit;
    butCancel: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
  public
    procedure Clear;
    procedure Add(const Token,Fil,Cmd: String);
  end;

var
  FormHelpF1: TFormHelpF1;

implementation

{$R *.DFM}

uses Util, Misc;

procedure TFormHelpF1.FormCreate(Sender: TObject);
begin
  Inherited;
  IniFilePosLoad(Self,'HelpF1');
  //pdf1.SetNamedDest('NetHostInfoBufType');
  //pdf1.SetCurrentPage(39);
end;

procedure TFormHelpF1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  IniFilePosSave(Self,'HelpF1');
  Debug(i2s(ord(Action)));
  Inherited;
end;

procedure TFormHelpF1.Clear;
begin
  RichEdit1.Lines.Clear;
end;

procedure TFormHelpF1.Add(const Token,Fil,Cmd: String);
var S: String; Start,Stop,N: Integer; SL:TStringList;
begin
  Caption:='Help information from: '+Fil;
  SL:=TStringList.Create;
  //RichEdit1.Lines.BeginUpdate;
  try
    SL.LoadFromFile(Fil);
    S:=Cmd; N:=iPos(','+Token,S);
    Delete(S,1,N);
    Delete(S,Pos(',',S),9999); N:=Pos(':',S);
    N:=s2i(Copy(S,N+1,9))-1;
    Start:=N; Stop:=N;
    for N:=Max(0,Start-10) to Start-1 do               //Remove lines before
      if iPos('$endif',SL[N])+ pos(';',SL[N])>0 then Start:=N+1;
    for N:=Min(SL.Count-1,Stop+10) downto Stop+1 do    //Remove lines after
      if pos(';',SL[N])>0 then Stop:=N-1;
    for N:=Stop downto Start do                        //Remove blank lines before
      if SL[N]<>'' then Start:=N;
    RichEdit1.Lines.Clear;
    for N:=Start to Stop do
      RichEdit1.Lines.Add(SL[N]);
    Visible:=True;
  finally
    //RichEdit1.Lines.EndUpdate;
    SL.Free;
  end;
end;

end.

