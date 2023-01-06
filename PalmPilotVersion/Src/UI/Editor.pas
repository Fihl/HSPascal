unit Editor;
{xxxxx$Define ShareWare}

{$ifdef VersionCMD} NO WAY!! {$Endif}

interface

uses
  {$ifdef VersionUI} Menus, {$Endif}
  SysUtils, Windows, Messages, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls,
  Misc, Global, GlobalUI, Util;

type
  EdMisc = (eShortFileName,eLongFileName,eSelection1Line,eLineThis,eLinePrev,eLineLin0,eLinePos0);
  TEditor = TRichEdit; //Just to make later adjustments easier
  THSEdit = class(TForm)
    Editor: TRichEdit; //=TEditor
    SaveFileDialog: TSaveDialog;
    procedure AlignClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure EditorKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditorKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    PathName: String;
  public
    Untitled: Boolean;
    function  MenuSelect(Tag: Integer; ParmN: Integer=0; ParmS: String=''; Pn2: Integer=0; Pn3: Integer=0): Boolean;
    function  Open(const AFileName: string; Load: Boolean): String;
    Function  CanClose: Boolean;
    Function  GetEditorMisc(What: EdMisc): String;
  end;

var
  HSEdit: THSEdit;

const
  DefaultFileName = '';
  AlmostMaxLongInt=1000000000;

implementation

uses Clipbrd, Printers, HspcUI, SplashFrm;

{$R *.DFM}

procedure THSEdit.AlignClick(Sender: TObject);
begin
  with Sender as TMenuItem do Checked := True;
  //with Editor.Paragraph do
end;

function THSEdit.Open(const AFileName: string; Load: Boolean): String;
var TabWidth,Lin,N: Integer; S,S2: String; B: Boolean;
begin
  PathName := AFileName;
  Result := ExtractFileName(AFileName);
  with Editor do begin
    {$ifdef ShareWare}
    MaxLength:=2000;                 //ShareWare limitation
    {$else}
    MaxLength:=AlmostMaxLongInt;     //Normal version
    {$Endif}
    try
      if Load then Editor.Lines.LoadFromFile(PathName);
    except
      Result:='';
    end;
    SelStart := 0; Modified := False; TabWidth:=0;
    S2:='2'; //'2' or '8'
    For Lin:=0 to Lines.Count-1 do begin
      S:=Lines[Lin];
      B:= (S<>'') and (Copy(S,Length(S),1)<=' ');
      if Pos(^I,S)>0 then begin
        if TabWidth<=0 then begin
          if not InputQuery(
            Format('Loading %s but tabs found',[ExtractFilename(PathName)]),
                   'Need to turn tabs into spaces'#13'Which size to use (Normally 2 or 8)?',S2) then S2:='';
          TabWidth:=s2i(S2); if (TabWidth<=0) or (TabWidth>99) then BREAK;
        end;
        repeat
          N:=Pos(^I,S); if N=0 then BREAK;
          Delete(S,N,1);
          for N:=N to ((N+TabWidth-1) div TabWidth)*TabWidth do
            Insert(' ',S,N);
        until FALSE;
        B:=True;
      end;
      if B then Lines[Lin]:=TrimRight(S);
    end;
    Editor.Modified := False;
  end;
end;

function THSEdit.CanClose: Boolean;
const
  SWarningText = 'Save file to %s?';
begin
  Result:=True;
  if Editor.Modified then begin
    case MessageDlg(Format(SWarningText, [PathName]), mtConfirmation,
      [mbYes, mbNo, mbCancel], 0) of
    idYes: MenuSelect(mnuSave);
    idCancel: CanClose := False;
    end;
  end;
end;

procedure THSEdit.FormCreate(Sender: TObject);
begin
  PathName := DefaultFileName;
end;

Function THSEdit.GetEditorMisc(What: EdMisc): String;
var Max,N: Integer; S: String;
begin
  Result:='';
  Max:=Length(Editor.Text);
  Case What of
  eShortFileName:    Result := ExtractFileName(PathName);
  eLongFileName:     Result := PathName;
  eLinePos0:         Result:=i2s(Editor.CaretPos.X);
  eLineLin0:         Result:=i2s(Editor.CaretPos.Y);
  eLinePrev:         begin
                       if Editor.CaretPos.Y>0 then
                         Result:=Editor.Lines[Editor.CaretPos.Y-1];
                     end;
  eLineThis:         Result:=Editor.Lines[Editor.CaretPos.Y];
  eSelection1Line:   Case Editor.SelLength of
                     0: begin
                          for N:=Editor.SelStart downto 1 do
                            if IsALetterDigit(Editor.Text[N]) then S:=Editor.Text[N]+S
                            else BREAK;
                          for N:=Editor.SelStart+1 to Max do
                            if IsALetterDigit(Editor.Text[N]) then S:=S+Editor.Text[N]
                            else BREAK;
                          Result:=S;
                        end;
                     1..80: Result := Editor.SelText;
                     end;
    //with Editor do Result := Copy(Text,SelStart+1, SelLength);
  end;
  for N:=1 to Length(Result) do
    if Result[N] in [#13,#10] then begin
      SetLength(Result,N-1); BREAK
    end;
end;

function THSEdit.MenuSelect(Tag: Integer; ParmN: Integer=0; ParmS: String=''; Pn2: Integer=0; Pn3: Integer=0): Boolean;
var
  Lin,L,M,N: Integer;
  S,S2: String;
begin
  Result:=True;
  case Tag of
  mnuSave:
    if Untitled then MenuSelect(mnuSaveAs)  //PathName = DefaultFileName
    else begin
      if Editor.Modified then begin
        For N:=0 to Editor.Lines.Count-1 do begin
          S:=Editor.Lines[N];
          if (S<>'') and (Copy(S,Length(S),1)<=' ') then  //Right trim source
            Editor.Lines[N]:=TrimRight(S);
        end;
        Editor.Lines.SaveToFile(PathName);
      end;
      Editor.Modified := False;
    end;
  mnuSaveAs:
    begin
      SaveFileDialog.FileName := PathName;
      if SaveFileDialog.Execute then begin
        Untitled:=False;
        PathName := SaveFileDialog.FileName;
        Editor.Modified:=True; //!
        S:=ExtractFileExt(PathName);
        if S='' then
          PathName:=PathName+'.pas';
        Caption := ExtractFileName(PathName);
        MenuSelect(mnuSave);
      end;
    end;
  mnuPrint:     if HspcUI.UI.PrintDialog1.Execute then
                  Editor.Print(HSPasName+' '+PathName);
  mnuCut:       Editor.CutToClipboard;
  mnuCopy:      Editor.CopyToClipboard;
  mnuPaste:     Editor.PasteFromClipboard;
  mnuSelectAll: Editor.SelectAll;
  mnuGotoLine:
    begin
      if ParmN=0 then
        ParmN:=s2i(InputBox(HSPasName, 'Goto Line:',''));
      if ParmN<=0 then EXIT;
      M:=0; N:=Min(ParmN,Editor.Lines.Count);
      for N:=0 to N-2 do
        Inc(M,Length(Editor.Lines[N])+2);
      Editor.SelStart:=M+Max(Pn2-1,0);
      Editor.SelLength:=Pn3;
      //SendMessage(Editor.Handle, EM_SCROLLCARET, 0,0);  ///WHY Already done in SelLength
    end;
  mnuHelpF1:     try
                   (**
                   if FormHelpF1=NIL then
                     FormHelpF1 := TFormHelpF1.Create(Application);
                   FormHelpF1.Clear;
                   (***)
                   S:={MyEditor.}GetEditorMisc(eSelection1Line);
                   if MakeHelpTxt.Count=0 then
                     MakeHelpTxt.LoadFromFile(MakeHelpName);
                   for N:=0 to MakeHelpTxt.Count-1 do begin
                     M:=iPos(','+S+':',MakeHelpTxt[N]);
                     if M>0 then begin
                       S2:=MakeHelpTxt.Names[N];
                       //FormHelpF1.Add(S,S2,MakeHelpTxt.Values[S2]);
                       UI.AddHelp(S,S2,MakeHelpTxt.Values[S2]);
                       BREAK
                     end;
                   end;
                 except
                 end;
  mnuBackSpace:  begin
                   Result:=False;
                   if Editor.SelLength=0 then begin
                     N:=s2i(GetEditorMisc(eLinePos0));
                     S:=GetEditorMisc(eLineThis);
                     S:=Trim(Copy(S,1,N));
                     if (S='') and (N>0) then begin
                       M:=0;
                       for Lin:=s2i(GetEditorMisc(eLineLin0))-1 downto 0 do begin
                         S:=Editor.Lines[Lin];
                         S:=Copy(S,1,N);
                         if Trim(S)='' then CONTINUE;
                         for L:=N downto 1 do begin
                           if Trim(Copy(S,1,L))='' then EXIT;
                           Editor.SelStart:=Editor.SelStart-1;
                           Inc(M); Editor.SelLength:=M;
                         end;
                         BREAK;
                       end;
                     end;
                   end;
                 end;
  mnuTabKey:     if Editor.SelLength=0 then begin
                   N:=s2i(GetEditorMisc(eLinePos0))+1;
                   S:=GetEditorMisc(eLinePrev);
                   L:=Length(S);
                   if N>L then EXIT;  //B:=IsALetterDigit(S[N]);
                   while N<=L do
                     if IsALetterDigit(S[N]) then begin
                       Inc(N); Editor.SelText:=' ';
                     end else BREAK;
                   while N<L do
                     if not IsALetterDigit(S[N]) then begin
                       Inc(N); Editor.SelText:=' ';
                     end else BREAK;
                 end;
  mnuEnterKey:   if Editor.SelLength=0 then begin
                   S:=GetEditorMisc(eLinePrev); //Return already done!
                   N:=Length(S)-Length(TrimLeft(S));
                   if N>0 then begin
                     SetLength(S,N); FillChar(S[1],N,' ');
                     Editor.SelText:=S;
                   end;
                 end;
  mnuEnterOpen:  begin
                   Result:=True; //Key Used
                   S:=GetEditorMisc(eSelection1Line);
                   if ExtractFilePath(S)='' then
                     S:=ExtractFilePath(PathName)+S;
                   UI.OpenFile(S);
                 end;
  else Result:=False;
  end;
  ///////Editor.SetFocus;
end;

procedure THSEdit.EditorKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
  VK_F1:     MenuSelect(mnuHelpF1);
  VK_Back:   if Shift=[] then if MenuSelect(mnuBackSpace) then Key:=0;
  VK_Return: if Shift=[ssAlt] then if MenuSelect(mnuEnterOpen) then Key:=0;
  end;
end;

procedure THSEdit.EditorKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Shift=[] then
    case Key of
    VK_Tab:    MenuSelect(mnuTabKey);
    VK_Return: if Shift=[] then MenuSelect(mnuEnterKey);
    end;
end;

end.

