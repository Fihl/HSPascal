Unit Util;
{xx$D-}

Interface

Uses {$ifdef VersionUI} Forms, {$Endif}
     Windows, Classes, Messages, IniFiles, SysUtils;

Const
  IniMemory  = 'Memory'; //Persistent';
  IniHelp    = 'Help';
  IniURL     = 'URL';
  IniScrPos  = 'ScrPos';
  IniMRU     = 'Recent Files';

Function  Max(m,n: Integer): Integer;
Function  Min(m,n: Integer): Integer;
Function  EvenSize(L: Longint): Longint;
Function  Hex(Number, Digits: Integer): String;
Function  SPtr: Integer;

Function  Blk2Str(var Blk; Len: Integer): String;
Function  S2Char(Const S: String; Def: Char): Char;
Function  CmpStr(Const S1,S2: String): Boolean;
Function  UpCaseStr(Const S: String): String;
function  iFormatPath(Path: string): string;
function  iPos(S1,S2: String): Integer;

Function  s2i(Const S: String): Integer;
Function  i2s(N: Integer): String;
Function  i2h4(N: Integer): String;
Function  i2sl(N: Integer; Len: Byte): String;
Function  s2lenL(Const S: String; Len: Byte): String;
Function  s2lenR(Const S: String; Len: Byte): String;

function  ReplaceStr(Ch1,Ch2: Char; Cnt: Integer; var Dest: String): Integer;
Procedure ReplaceStrChars(CharsFrom,CharsTo: String; var Dest: String);

function  ImmTst(RegOfs,L,H: Integer): Boolean;
Procedure SendKey(Handle: THandle; Key: Word);

function  IniFileLoad(Const Header, Item, Default: String; Fil: String=''): String;
Procedure IniFileSave(Const Header, Item, Data: String; Fil: String='');
{$ifdef VersionUI}
Procedure IniFilePosLoad(Form: TForm; Const Header: String);
procedure IniFilePosSave(Form: TForm; Const Header: String);
{$endif}

Procedure ReplaceDollarTokens(var S: String); // $(exe)

Function  IsALetterDigit(Ch: Char): Boolean;
Function  IsALetter(Ch: Char): Boolean;
Function  IsADigit(Ch: Char): Boolean;
Function  IsAHexDigit(Ch: Char): Boolean;

Function  LoadFile(Const Fil: String): String;

Const
  NatLangLower='æøåüäöéúáóé';
  NatLangUpper='ÆØÅÜÄÖÉÚÁÓÉ';

Var
  IniFileName: String;

Implementation

Procedure SendKey(Handle: THandle; Key: Word);
begin
  SendMessage(Handle, WM_KEYDOWN, Key, 0);
  SendMessage(Handle, WM_KEYUP,   Key, 0);
end;

Function Max(m,n: Integer): Integer;
begin
  if m>n then Max:=m else Max:=n
end;

Function Min(m,n: Integer): Integer;
begin
  if m<n then Min:=m else Min:=n
end;

Function  EvenSize(L: Longint): Longint;
begin
  if L<0 then Result:=(L SHR 1) SHL 1
  else        Result:=(L+1) and $FFFFFFFE
end;

Function  Hex(Number, Digits: Integer): String;
CONST hexdigit: ARRAY[0..15] OF char = '0123456789ABCDEF';
VAR d: Integer;
    h: String;
BEGIN
  SetLength(H,digits);
  FOR d:=digits DOWNTO 1 DO BEGIN
    h[d]:=hexdigit[number AND 15];
    number:=number SHR 4;
  END;
  hex:=h;
END;

Function SPtr: Integer; ASSEMBLER;
ASM
  MOV EAX,ESP
END;

Function  s2i(Const S: String): Integer;
begin
  Result:=0;
  if S='' then EXIT;
  if not (S[1] in ['$','0'..'9']) then EXIT;
  try    Result:=StrToInt(S)
  except Result:=0
  end;
end;

Function i2s(N: Integer): String;
begin
  Result:=IntToStr(N)
end;

Function  i2h4(N: Integer): String;
begin
  Result:= Format('%.4x',[N and $0000FFFF])
end;

Function i2sl(N: Integer; Len: Byte): String;
begin
  Result:=IntToStr(N);
  Result:=s2lenR(Result,Len);
end;

Function s2lenR(Const S: String; Len: Byte): String;
begin
  Result:=S;
  while Length(Result)<Len do Result:=' '+Result;
end;

Function s2lenL(Const S: String; Len: Byte): String;
begin
  Result:=S;
  while Length(Result)<Len do Result:=Result+' ';
end;

Function Blk2Str(var Blk; Len: Integer): String;
begin
  Result:='';
  If Len>0 then begin
    SetLength(Result,Len);
    Move(Blk,Result[1],Len); //Is checked for <>''!
  end;
end;

Function S2Char(Const S: String; Def: Char): Char;
begin
  if S='' then Result:=Def else Result:=S[1]
end;

// replace Ch1 with Ch2 max Cnt (or -1) in Dest
// returns number of replace-actions occurred
function ReplaceStr(Ch1,Ch2: Char; Cnt: Integer; var Dest: String): Integer;
var i: Integer;
begin
  Result:=0;
  while Cnt<>0 do begin
    i:=pos(Ch1,Dest);
    if i>0 then begin
      Dest[i]:=Ch2;
      Dec(Cnt);
      Inc(Result);
    end else BREAK;
  end;
end;

Procedure ReplaceStrChars(CharsFrom,CharsTo: String; var Dest: String);
var N: Integer;
begin
  N:=Length(CharsFrom);
  While Length(CharsTo)<N do CharsTo:=CharsTo+' ';
  for N:=1 to N do
    ReplaceStr(CharsFrom[N],CharsTo[N],999,Dest);
end;

Function  CmpStr(Const S1,S2: String): Boolean;
begin
  Result:=AnsiCompareText(S1,S2)=0
end;

Function UpCaseStr(Const S: String): String;
var N: Integer;
begin
  Result:=S;
  For N:=1 to Length(Result) do
    Result[N]:=UpCase(Result[N]);
end;

function  iPos(S1,S2: String): Integer;
begin
  S1:=UpCaseStr(S1);
  S2:=UpCaseStr(S2);
  Result:=Pos(S1,S2)
end;

function iFormatPath(Path: string): string;
var
  N: Integer;
begin
  Result:=Path;
  if (Result <> '') and (Copy(Result,Length(Result),1) <> '\') then
    Result:=Result+'\';
  for N:=Length(Result) downto 3 do
    if Copy(Result,N,2)='\\' then
      Delete(Result,N,1);
end;

function ImmTst(RegOfs,L,H: Integer): Boolean;
begin
  Result:=(L<=RegOfs) and (RegOfs<=H)
end;

//Read from real .Ini files
function  IniFileLoad(Const Header, Item, Default: String; Fil: String=''): String;
var IniFile: TIniFile;
begin
  if Fil='' then Fil:=IniFileName;
  IniFile:= TIniFile.Create(Fil);
  try     Result:=Trim(IniFile.ReadString(Header, Item, Default));
  finally IniFile.Free;
  end;
end;

//Write to real .Ini files
Procedure IniFileSave(Const Header, Item, Data: String; Fil: String='');
var IniFile: TIniFile;
begin
  if Fil='' then Fil:=IniFileName;
  IniFile:= TIniFile.Create(Fil);
  try     IniFile.WriteString(Header, Item, Data);
  finally IniFile.Free;
  end;
end;

{$ifdef VersionUI}
Procedure IniFilePosLoad(Form: TForm; Const Header: String);
var
  A: Array[0..3] of Integer;
  N: Integer;
  Ok: Boolean;
  Items: TStringList;
Const
  Names: Array[0..3] of String=('Left','Top','Width','Height');
begin
  Items:=TStringList.Create;
  Items.CommaText:=IniFileLoad(IniScrPos, Header, '');
  if not (Form.WindowState=wsNormal) then EXIT;
  Ok:=Items.Count=4;
  if Ok then
  try
    for N:=0 to 3 do begin
      A[N]:=s2i(Items.Values[Names[N]]);
      Ok:=Ok and (A[N]<>0);
    end;
    if Ok then begin
      Form.SetBounds(A[0], A[1], A[2], A[3]);
      if (Form.Left+10 > Screen.Width) or (Form.Top+10 > Screen.Height) or
         (Form.Left+Form.Width < 10) or (Form.Top < -10) then
      Form.SetBounds(Screen.Width div 3, Screen.Height div 3, A[2], A[3]);
    end;
  except
  end;
  Items.Free;
end;

procedure IniFilePosSave(Form: TForm; Const Header: String);
begin
  if Form.WindowState=wsNormal then
  With Form do IniFileSave(IniScrPos, Header,
    Format('Left=%d, Top=%d, Width=%d, Height=%d', [Left,Top,Width,Height]) );
end;
{$Endif}

Procedure ReplaceDollarTokens(var S: String);
var N: Integer;
begin
  repeat
    N:=iPos('$(exe)',S);
    if N>0 then begin
      Delete(S,N,6);
      if Copy(S,1,1)='\' then Delete(S,1,1);
      Insert(ExtractFilePath(ParamStr(0)),S,N);
      CONTINUE;
    end;
    BREAK;
  until FALSE;
end;

// this function should use the windows function isCharAlphaNumeric
Function  IsALetterDigit(Ch: Char): Boolean;
begin
  Result:=IsALetter(Ch) or IsADigit(Ch)
end;

// this function should use the windows function isCharAlpha
Function IsALetter(Ch: Char): Boolean;
begin
  Result:= Ch in ['a'..'z','A'..'Z'];
  if not Result then
    Result:=Pos(Ch,NatLangLower)+Pos(Ch,NatLangUpper)>0
end;

Function IsADigit(Ch: Char): Boolean;
begin
  Result:= Ch in ['0'..'9']
end;

Function IsAHexDigit(Ch: Char): Boolean;
begin
  Result:= Ch in ['0'..'9','a'..'f','A'..'F']
end;

Function LoadFile(Const Fil: String): String;
var
  iFileHandle, iFileLength: Integer;
begin
  Result:='';
  iFileHandle := FileOpen(Fil, fmOpenRead);
  if iFileHandle>0 then begin
    iFileLength := FileSeek(iFileHandle,0,2);
    FileSeek(iFileHandle,0,0);
    SetLength(Result, iFileLength);
    FileRead(iFileHandle, Result[1], iFileLength);
    FileClose(iFileHandle);
  end;
end;

begin
  IniFileName:=ParamStr(0);
  IniFileName:=ChangeFileExt(IniFileName,'.ini');
End.

