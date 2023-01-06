unit HspcUI;

{$ifdef VersionCMD} NO WAY!! {$Endif}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ComCtrls, Menus, ExtCtrls,
  ShellApi, ShlObj, ActiveX, ComObj,
  Global, HSPMain,
  Misc, Util,
  GlobalUI, Editor, Scanner,
  MRUFiles;

type
  eSetInfo = (eBlank,eSaving,eCompiling,eModified,ePos,eStatus,eError);

  TUI = class(TForm)
    pc1: TPageControl;
    OpenDialogPas: TOpenDialog;
    OpenDialogHelp: TOpenDialog;
    PopupMenu1: TPopupMenu;
    FontDialog1: TFontDialog;
    PrinterSetupDialog1: TPrinterSetupDialog;
    PrintDialog1: TPrintDialog;
    FindDialog1: TFindDialog;
    ReplaceDialog1: TReplaceDialog;
    Timer1: TTimer;
    //Menu follows!!
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    New1: TMenuItem;
    Open1: TMenuItem;
    Close1: TMenuItem;
    Save1: TMenuItem;
    Saveas1: TMenuItem;
    N1: TMenuItem;
    Print1: TMenuItem;
    Printersetup1: TMenuItem;
    MenuMRU: TMenuItem;
    Exit1: TMenuItem;
    Edit1: TMenuItem;
    Cut1: TMenuItem;
    Copy1: TMenuItem;
    Paste1: TMenuItem;
    Cut1Popup: TMenuItem;
    Copy1Popup: TMenuItem;
    Paste1Popup: TMenuItem;
    N3: TMenuItem;
    Selectall1: TMenuItem;
    Character1: TMenuItem;
    Left1: TMenuItem;
    Right1: TMenuItem;
    Center1: TMenuItem;
    N4: TMenuItem;
    Compiler1: TMenuItem;
    Options1: TMenuItem;
    Information1: TMenuItem;
    N5: TMenuItem;
    Upload1: TMenuItem;
    Compile1: TMenuItem;
    Again1: TMenuItem;
    Incremental1: TMenuItem;
    GotoLine1: TMenuItem;
    DebugWindow: TMenuItem;
    meLastCompile: TMenuItem;
    SaveAll1: TMenuItem;
    N6: TMenuItem;
    miHelp: TMenuItem;
    miHelpAbout: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    Help1: TMenuItem;
    N9: TMenuItem;
    PalmOSHelp1: TMenuItem;
    PalmOSHelp2: TMenuItem;
    PalmOSHelp3: TMenuItem;
    PalmOSHelp4: TMenuItem;
    PalmOSHelp5: TMenuItem;
    PalmOSHelp6: TMenuItem;
    PalmOSHelp7: TMenuItem;
    PalmOSHelp8: TMenuItem;
    PalmOSHelp9: TMenuItem;
    panMemo1: TPanel;
    Memo1: TMemo;
    Splitter1: TSplitter;
    sbUI: TStatusBar;
    N2: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button1Click(Sender: TObject);
    procedure MenuSelectTag(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    function  OpenFile(Name: String): TTabSheet;
  public
    procedure AddHelp(const Token,Fil,Cmd: String);
  private
    function  LocateTabSheet(Name: String): TTabsheet;
    function  LocateTabSheetN(No: Integer): TTabsheet;
    function  EditorN(No: Integer): THSEdit;
    function  MenuSelect(MenuID: Integer; ParmN: Integer=0; ParmS: String=''): Boolean;
    procedure RestartTimer;
    procedure DoOpen;
    procedure WMDropFiles(var Msg: TWMDropFiles);   message WM_DROPFILES;
  private
    MenuPDF: Array[mnuHelpPDF1..mnuHelpPDF9] of String;
    procedure SetMenues;
  private  // Find / Replace
    LastFindCmd: Integer;
    LastFindPos: TPoint;
    FindEditor: TEditor; //=TRichEdit!
    procedure FindNotify(Sender: TObject);
    procedure ReplaceNotify(Sender: TObject);
    procedure SetInfo(What: eSetInfo; S: String='');
  public
  private //MRU
    MRU: TMRUFiles;
    Procedure MRUOnClick(Sender: TObject; const FileName: String);
  end;

var
  UI: TUI;

implementation

uses DebugFrm, AboutFrm, SplashFrm, HelpFrm;

{$R *.DFM}

procedure TUI.FormCreate(Sender: TObject);
procedure Check1(Menu: TMenuItem);
var Id,F,S: String;
begin
  Id:=i2s(Menu.Tag-mnuHelpPDF1+1);
  //Caption!
  F:=Id+'_C';
  S:=IniFileLoad(IniHelp, F, Menu.Caption); IniFileSave(IniHelp, F, S);
  Menu.Caption:=S;
  //Data
  F:=Id+'_F';
  case Menu.Tag of mnuHelpPDF1..mnuHelpPDF9: MenuPDF[Menu.Tag]:=F else EXIT end;
  if Menu.Visible then S:=S+'.pdf' else S:='';
  S:=IniFileLoad(IniHelp, F, S);
  if Length(S)>2 then begin
    Menu.Visible:=True;
    IniFileSave(IniHelp, F, S);
  end;
end;

var
  N: Integer;
  S: String;
  Menu: TMenuItem;
begin //FormCreate
  // {$b+} if ((n<3) or (n<4)) and (n<5) then N:=1;
  // {$b+} if (not (n<3) or (n<4)) and (n<5) then N:=1;
  for N:=0 to ComponentCount-1 do
    if Components[N] is TMenuItem then begin
      Menu:=TMenuItem(Components[N]);
      with Menu do begin
        if (Tag<>0) and (not Assigned(OnClick)) then begin
          if iPos('PalmOSHelp',Name)>0 then //Help 1..9
            Check1(Menu);
          OnClick:=MenuSelectTag;
        end;
      end;
    end;
  FindDialog1.OnFind:=FindNotify;
  ReplaceDialog1.OnFind:=FindNotify;
  ReplaceDialog1.OnReplace:=ReplaceNotify;
  SetMenues;
  MRU:=TMRUFiles.Create(NIL);
  MRU.MenuItem:=MenuMRU;
  MRU.LoadFromIni(IniFileName,IniMRU);
  MRU.OnClick:=MRUOnClick;
  S:=ParamStr(1);
  if not (S2Char(S,' ') in ['A'..'z']) then
    S:=IniFileLoad(IniMemory, 'LastCompile', '');
  if S<>'' then begin
    //if Pos('.',S)=0 then S:=S+'.pas';
    OpenFile(S);
  end;
  //  SetCurrentDir(ParamStr(1));
  IniFilePosLoad(Self,'UI');
  DragAcceptFiles(Handle, True);
end;

procedure TUI.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose:=MenuSelect(mnuExitF4);
  MRU.SaveToIni(IniFileName,IniMRU);
  MRU.Free;
end;

procedure TUI.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  IniFilePosSave(Self,'UI');
  Inherited;
end;

procedure TUI.SetMenues;
begin
  meLastCompile.Caption:='Open '+ExtractFileName(IniFileLoad(IniMemory, 'LastCompile', 'Test.pas'));
end;

Procedure TUI.MRUOnClick(Sender: TObject; const FileName: String);
begin
  OpenFile(FileName);
  MRU.Add(FileName);
end;

procedure TUI.WMDropFiles(var Msg: TWMDropFiles);
var
  Fil: String;
  N: Integer;
  //SLI: TShellLinkInfo;
  PF: IPersistFile;
  SL: IShellLink;
  WS: WideString;
  AStr: Array[0..MAX_PATH] of Char;
  FindData: TWin32FindData;
begin
  try
    try
      for N:=0 to 100 do begin
        SetLength(Fil,300);
        if DragQueryFile(Msg.Drop, N, PChar(Fil), 300) <= 0 then BREAK
        else begin
          Fil:=Trim(PChar(Fil)); //See IShellLinkA in ShlObj
          if iPos('.lnk',Fil)<>0 then begin
            WS:=Fil;
            OleCheck(CoCreateInstance(CLSID_ShellLink, nil, CLSCTX_INPROC_SERVER, IShellLink, SL));
            {The IShellLink implementer must also support the IPersistFile interface. Get an interface pointer to it. }
            PF := SL as IPersistFile;
            OleCheck(PF.Load(PWideChar(WS), STGM_READ)); { Load file into IPersistFile object }
            OleCheck(SL.Resolve(0, SLR_ANY_MATCH or SLR_NO_UI));
            OleCheck(SL.GetPath(AStr,MAX_PATH,FindData,SLGP_RAWPATH));//SLGP_SHORTPATH));
            Fil:=AStr;
          end;
          OpenFile(Fil);
          Msg.Result := 0;
        end;
      end;
    except
    end;
  finally
    DragFinish(Msg.Drop);
  end;
  inherited;
end;

procedure TUI.MenuSelectTag(Sender: TObject);
begin
  if Sender is TMenuItem then
    MenuSelect(TMenuItem(Sender).Tag);
end;

procedure TUI.SetInfo(What: eSetInfo; S: String='');
begin
  Case What of
  ePos:      sbUI.Panels[sbUI_Line].Text:=S;
  eModified: begin
               sbUI.Panels[sbUI_Modif].Text:=S;
               if S<>'' then begin
                 sbUI.Color:=clBtnFace;
                 sbUI.Panels[sbUI_Info].Text:='';       //Blank status field
               end;
             end
  else
    sbUI.Color:=clBtnFace;
    Case What of
    /////eBlank: ;
    eSaving:     S:='Saving...'+S;
    eCompiling:  begin
                   if S='' then S:='Compiling...';
                   sbUI.Panels[sbUI_Modif].Text:=''
                 end;
    eError:      sbUI.Color:=clRed;
    end;
    sbUI.Panels[sbUI_Info].Text:=S;
    sbUI.Hint:=S;
    sbUI.Showhint:=S<>'';
  end;
  sbUI.Update;
end;

function TUI.LocateTabSheet(Name: String): TTabsheet;
var N: Integer;
begin
  for N:=0 to pc1.PageCount-1 do begin
    Result:=LocateTabSheetN(N);   //pc1.Pages[N];
    if CmpStr(ExpandFileName(Name),
              ExpandFileName(EditorN(N).GetEditorMisc(eLongFileName))) then EXIT;
  end;
  Result:=Nil;
end;
function TUI.LocateTabSheetN(No: Integer): TTabsheet;
begin
  Result:=pc1.Pages[No]
end;
function TUI.EditorN(No: Integer): THSEdit;
begin
  Result:=THSEdit(pc1.Pages[No].Tag);
  if Result=NIL then
    Raise Exception.Create('No file:'+i2s(No));
end;

function TUI.OpenFile(Name: String): TTabSheet;
var
  ts: TTabSheet;
  F: THSEdit;
  S: String;
  N,W: Integer;
Const UntitledNo: Integer=0;
begin
  Result:=NIL;
  RestartTimer;
  ts:=LocateTabSheet(Name);
  if ts<>NIL then
    pc1.ActivePage:=ts
  else begin
    F:=THSEdit.Create(Self);
    if Name='' then Begin
      Inc(UntitledNo);
      Name:='Untitled'+IntToStr(UntitledNo)+'.pas';
      S:=F.Open(Name,FALSE);
      F.Untitled:=True;
    end else begin
      S:=F.Open(Name,TRUE);
      if S='' then begin
        Name:=Name+'.pas';
        S:=F.Open(Name,TRUE);
      end;
      if S<>'' then begin
        MRU.Add(Name);
        MRU.SaveToIni(IniFileName,IniMRU);
      end;
    end;
    if S='' then begin
      F.Free;
      EXIT;
    end;
    ////Caption:=S; //////////////????
    ts:=TTabsheet.Create(pc1);
    ts.Tag:=Integer(F);
    SetLength(S,Length(S)-Length(ExtractFileExt(S)));  //Without ext
    ts.Caption:=S;
    ts.PageControl:=pc1;
    F.Parent:=ts;
    //F.Editor.PlainText:=True;
    F.Visible:=True;
    pc1.ActivePage:=ts;
    W:=30; for N:=0 to pc1.PageCount-1 do
       W:=Max(W,pc1.Canvas.TextWidth(THSEdit(pc1.Pages[N].Tag).Caption));
    pc1.TabWidth:=W+20;
  end;
  Result:=ts;
end;

procedure TUI.FindNotify(Sender: TObject);
var
  NewPos: integer;
  cd: TFindDialog;
  st: TSearchTypes;
begin
  cd := (Sender as TFindDialog);
  st:=[];
  if frMatchCase in cd.Options then st := st+[stMatchCase];
  if frWholeWord in cd.Options then st := st+[stWholeWord];
  NewPos := FindEditor.FindText(cd.FindText, FindEditor.SelStart+FindEditor.SelLength, Length(FindEditor.Text), st);
  if NewPos <> -1 then begin
    FindEditor.SelStart := NewPos;
    FindEditor.SelLength := Length(cd.FindText);
    SendMessage(FindEditor.Handle, EM_SCROLLCARET, 0,0);  ///WHY Already done in SelLength
  end
  (** else begin
    MessageDlg('End of document reached',mtInformation,[mbOK],0);
    RichEdit1.SelStart := 0;
  end; (**)
end;

procedure TUI.ReplaceNotify(Sender: TObject);
begin
  if FindEditor.SelLength <> 0 then
    FindEditor.SelText :=  ReplaceDialog1.ReplaceText;
  FindNotify(Sender);

  if frReplaceAll in ReplaceDialog1.Options then
    while (FindEditor.SelLength <> 0) do begin
      //ReplaceDialog1Replace(Sender);
      FindEditor.SelText :=  ReplaceDialog1.ReplaceText;
      FindNotify(Sender);
    end;
end;

procedure TUI.DoOpen;
begin
  with OpenDialogPas do begin
    FileName:=IniFileLoad(IniMemory, 'FileOpen', 'HSPascal.pas');
    DefaultExt:='.pas';
    //Options:=
    if Execute then begin
      OpenFile(FileName);
      IniFileSave(IniMemory, 'FileOpen', OpenDialogPas.FileName);
    end;
  end;
end;

Function MyUICallBack(S: String): Boolean;
begin
  Result:=True; //Do continue compiling
  S:=Format('Compiling: %s',[S]);
  UI.SetInfo(eCompiling,S);
end;

function TUI.MenuSelect(MenuID: Integer; ParmN: Integer=0; ParmS: String=''): Boolean;
var
  Act: TTabSheet;
  MyEditor: THSEdit;
  N: Integer;
  URL,S: String;
  B,Restart: Boolean;
  Options: TStringList;
begin
  Result:=False; Restart:=True;
  Act:=pc1.ActivePage; MyEditor:=Nil;
  case MenuID of  //Unimplemented
  mnuUpload, mnuInfo, mnuOptions,
  mnuFindFilesX,mnuFindIncX:
    begin MessageDlg('Unimplemented',mtInformation, [mbOk], 0); EXIT end;
  end;
  if Act<>Nil then begin
    MyEditor:=THSEdit(Act.Tag);
    FindEditor:=MyEditor.Editor; //Find/Replace
    if LastFindPos.Y=0 then
      LastFindPos:=Point(UI.Left+MyEditor.Left + 100, UI.Top+MyEditor.Top+10);
    case MenuID of
    //mnuFindFilesX,mnuFindIncX,
    mnuFind:    begin
                  LastFindCmd:=MenuID; MenuID:=0;
                  S:=MyEditor.GetEditorMisc(eSelection1Line);
                  if S<>'' then FindDialog1.FindText:=S;
                  FindDialog1.Position := LastFindPos;
                  FindDialog1.Execute;
                  //LastFindPos:=FindDialog1.Position;
                end;
    mnuReplace: begin
                  LastFindCmd:=MenuID; MenuID:=0;
                  S:=MyEditor.GetEditorMisc(eSelection1Line);
                  if S<>'' then ReplaceDialog1.FindText:=S;
                  ReplaceDialog1.Position := LastFindPos;
                  ReplaceDialog1.Execute;
                  //LastFindPos:=ReplaceDialog1.Position;
                end;
    mnuFindNext:
      case LastFindCmd of
      mnuFind:    FindNotify(FindDialog1);
      mnuReplace: ReplaceNotify(ReplaceDialog1);
      end;
    end;
  end;

  if MyEditor<>NIL then
    Result:=MyEditor.MenuSelect(MenuID,ParmN,ParmS);
  if not Result then begin
    case MenuID of
    mnuClose:
      if MyEditor.CanClose then begin
        MyEditor.Free; //Act.PageControl:=NIL;
        Act.Free;
      end;
    mnuNew:        OpenFile('');
    mnuOpen:       DoOpen;
    mnuSaveAll:    for N:=0 to pc1.PageCount-1 do
                     EditorN(N).MenuSelect(mnuSave);
    mnuPrintSetup: PrinterSetupDialog1.Execute;
    mnuExitF4:     for N:=0 to pc1.PageCount-1 do
                     if NOT EditorN(N).CanClose then EXIT;
    mnuExit:       begin
                     FormCloseQuery(NIL, B);
                     if B then Application.Terminate;
                   end;

    mnuHelpPDF1..
    mnuHelpPDF9:   begin
                     //URL:='http://www.palmos.com/cgi-bin/sdk40.cgi';
                     URL:='http://www.palmos.com/dev/support/docs/palmos40-docs.zip';
                     URL:=IniFileLoad(IniURL, 'PDF', URL);
                     IniFileSave(IniURL, 'PDF', URL);
                     if FormHelp=NIL then
                       FormHelp := TFormHelp.Create(Application);
                     S:=IniFileLoad(IniHelp, MenuPDF[MenuID], '');
                     B:=(Pos('\',S)>0) and FileExists(S);
                     if not B then with OpenDialogHelp do begin
                       FileName:=S;
                       DefaultExt:='.pdf'; //Options:=
                       B:=Execute;
                       if B then begin
                         S:=FileName;
                         B:=FileExists(S);
                         IniFileSave(IniHelp, MenuPDF[MenuID], S);
                       end;
                     end;
                     if B then begin
                       if FormHelp.Pdf1.Src<>S then begin
                         //FormHelp.Visible:=False;
                         FormHelp.Pdf1.Src:=S;
                       end;
                       FormHelp.Visible:=True;
                     end else begin
                       case MenuID of
                       mnuHelpPDF1..mnuHelpPDF3:
                         begin
                           if mrYes=MessageDlg(
                               'Please get Palm documentation from '#13+URL+#13+
                               'Then place an unzipped copy in any folder.'#13#13+
                               'Do it now?'#13+
                               'Then press "Yes" and accept the Palm license', mtConfirmation, [mbNo,mbYes], 0) then
                           begin
                             ShellExecute(Application.Handle,PChar('Open'),PChar(URL),nil,nil,SW_SHOWNORMAL);

                             //URL:='http://www.palmos.com/cgi-bin/sdk40.cgi/sdk40-docs.zip';
                             //if mrYes=MessageDlg('Remember to press "I AGREE"'#13+
                             //                    'Then press "Yes" to download!', mtConfirmation, [mbCancel,mbYes], 0) then
                             //  ShellExecute(Application.Handle,PChar('Open'),PChar(URL),nil,nil,SW_SHOWNORMAL);
                             MessageDlg('1: Unzip to any folder'#13+
                                        '2: Retry the help menu'#13+
                                        '3: Select the correct downloaded file', mtConfirmation, [mbOk], 0);
                           end;
                         end;
                       end;
                     end;
                   end;
    mnuHelpAbout:  begin
                     AboutBox.ShowModal;
                     SplashForm.Splash(3000);
                   end;
    mnuDebugWin:   begin
                     FormDebug.Visible := not FormDebug.Visible;
                     Restart:=False;
                   end;
    mnuOpenF10:      //OpenFile('R:\Hspc\Test.pas');
                     OpenFile(IniFileLoad(IniMemory, 'LastCompile', 'Test.pas'));
                     //OpenFile('R:\Hspc\Pvs\Test.pas');
                     //MenuSelect(mnuCompile);

    mnuCompile:
      if Act<>Nil then begin
        FormDebug.DebugClear;
        SetInfo(eSaving);
        for N:=0 to pc1.PageCount-1 do EditorN(N).MenuSelect(mnuSave);
        ///Timer1Timer(Nil);  //Update "Modified"
        SetInfo(eCompiling);
        FillChar(UIIntf,SizeOf(UIIntf),0);
        UIIntf.Src:=MyEditor.GetEditorMisc(eLongFileName);
        UIIntf.CallBack:=MyUICallBack;
        IniFileSave(IniMemory, 'LastCompile', UIIntf.Src);
        SetMenues;
        SplashForm.Splash(0);

        Options:=TStringList.Create;
        try
          S:=LoadOptions(Options,ExtractFilePath(UIIntf.Src)); //Return Filename
        finally
          Options.Free;
        end;

        if DoCompiler then begin
          //SetInfo(eBlank);
          SetInfo(eStatus,Format('Lines compiled: %d',[UIIntf.TotLinesCompiled]));
        end else begin
          with UIIntf do
            SetInfo(eError,Format('Error %d, %s',[ErrNo,ErrStr]));
          if UIIntf.ErrFile<>'' then begin
            Act:=OpenFile(UIIntf.ErrFile);
            //MessageDlg(Format('Error Line:%d, Pos:%d, Len:%d, Str:%s',
            //[UIIntf.ErrLine,UIIntf.ErrPos,UIIntf.ErrLen,UIIntf.ErrLineStr]),mtError, [mbOk], 0);
            if Act=Nil then begin
              MessageDlg(Format('Error in file %s, Line:%d',
                                [UIIntf.ErrFile,UIIntf.ErrLine]),
                                mtError, [mbOk], 0)
            end else
              THSEdit(Act.Tag).MenuSelect(mnuGotoLine,Max(1,UIIntf.ErrLine),'',
              UIIntf.ErrPos,UIIntf.ErrLen);
          end;
        end;
      end;
    else EXIT; //Result=False;
    end;
    Result:=True;
  end;
  if Restart then RestartTimer;
end;

procedure TUI.Button1Click(Sender: TObject);
begin
  MenuSelect(mnuGotoLine,3);
end;

procedure TUI.RestartTimer;
begin
  Timer1.Interval:=50;
end;
procedure TUI.Timer1Timer(Sender: TObject);
var
  Act: TTabSheet;
  Pos: TPoint;
  S: String;
begin
  Act:=pc1.ActivePage;
  if Act<>Nil then begin
    if not (TObject(Act.Tag) is THSEdit) then EXIT;
    if Timer1.Interval<=100 then //Else BringToFront all the time
      THSEdit(Act.Tag).Editor.SetFocus;
    if THSEdit(Act.Tag).Editor.Modified then S:='Modified';
    Pos:=THSEdit(Act.Tag).Editor.CaretPos;
    SetInfo(ePos,Format('%d,%d',[Pos.Y+1,Pos.X+1]));
    SetInfo(eModified,S);
  end;
  Timer1.Interval:=500;
end;

procedure TUI.AddHelp(const Token,Fil,Cmd: String);
var S: String; Start,Stop,M,N: Integer; SL:TStringList;
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
      if pos('{$',SL[N])+pos(';',SL[N])>0 then Start:=N+1;
    for N:=Min(SL.Count-1,Stop+10) downto Stop+1 do    //Remove lines after
      if pos(';',SL[N])>0 then Stop:=N-1;
    for N:=Stop downto Start do                        //Remove blank lines before
      if SL[N]<>'' then Start:=N;
    M:=Min(100, (Abs(Memo1.Font.Height)+3)* (1+Stop-Start));
    N:=Memo1.ClientHeight;
    //if N<M then
    if N<50 then if M=100 then Dec(M);
    if M<>100 then //!!!!!!!
      panMemo1.Height:=panMemo1.Height+M-N;
    //if Memo1.ClientHeight<40 then Memo1.ClientHeight:=40;
    //Visible:=True;
    Memo1.Lines.Clear;
    for N:=Start to Stop do
      Memo1.Lines.Add(SL[N]);
    Memo1.Lines.Add(Fil);
    Memo1.SelStart:=0; Memo1.SelLength:=0;
  finally
    //RichEdit1.Lines.EndUpdate;
    SL.Free;
  end;
end;

end.

