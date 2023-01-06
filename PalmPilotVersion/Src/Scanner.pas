Unit Scanner;
{$H-,I- asdasdasd,D-}

Interface

Uses Windows, Classes, SysUtils, ZLib, ZLib2, Global, Global2, Util, Misc;

Const
  IBUMax	= 16;		{Max level}
  IBULineSize	= 128;		{Max characters per line}
  IBULineSizeMax= 130;
  IBUBlkSize	= 2048;
  IBUBlkSizeMax	= 2200;		{2048+128}

Type
  tIBUGLOB=Record
    PTR:	Integer;	{Read pointer}
    LAST:	Integer;	{Max pointer}
    ERRPOS:	Integer;
    LINE:	String;
  End;

  pSrcBuf= ^tSrcBuf;
  tSrcBuf= Record
    IBUGLOB:	tIBUGLOB;	{Save version of global stuff}
    IBUCndLevel:Byte;	        {if then else level}
    IBULINENO:	Integer;        {line number}
    IBUNAME:	String;         {Window with text}
    IBUFileNo:  Integer;
    MemStream:  TMemoryStream;  //For decompression or raw reading
    DCStream:   TZDecompressionStream; //ONLY created for compressed files
    RestOfLine: AnsiString;
  End;

Type
  CommentType=(comSingle,   // {    }
               comDouble,   // (*  */
               comC         // /*  */
               );
Type
  TUnit1=Class(TUnit0)
    DoingEOLN: Boolean; //ASM stuff
    DoingASM: Boolean;  //ASM stuff
    StopF: Boolean;			{True after bad Stmt's}
    OptionsLocal: TOptions;
    Constructor Create;
    Destructor Destroy; Override;
    Procedure ScanNext;
    Function  Scan(What: eSym): Boolean;
    Procedure Find(What: eSym);

    Function  ScanSLPA: Boolean;
    Function  ScanSLBR: Boolean;
    Function  ScanSSEM: Boolean;
    Function  ScanSCOL: Boolean;
    Function  ScanSCOM: Boolean;
    procedure ScanNextAndFindSem;
    Procedure FindSCOM;
    procedure FindSLPA;   //remove??
    procedure FindSRPA;   //remove??

    procedure IntIdn;
    procedure DoStr;
    procedure DoNumeric;
    procedure DoHex;

    Function  CON: TypPtr;
    Function  FCON: TypPtr;
    Function  FICON: Longint;
    Function  FSCON: String;
    Function  FUCON: Longint; //Integer or enumerated
    Function  Sign: eSign;
    Function  Constant: TypPtr;

    Function  OpenSrc(Name: String): Boolean;
    Procedure CloseSrc;
    Procedure NextLine;
    function  SkipBlanks: Boolean; //First check for DoingEOLN. Return True if SEOLN must be set
    Procedure DoComment(Why: CommentType; Size: Byte);	{'{', '(*', '/*'}
    procedure NextCh;
  private
    SrcOpened: Boolean;
  public //ONLY FOR ERROR HANDLING TO KNOW!!!!!
    IBU: tIBUGLOB;              {Global current copy of line & ptr's}
    IBUGLB: Record
      CNT: 0..IBUMax;
      SrcPTR: pSrcBuf;
      SrcPTRs: Array[1..IBUMax] of pSrcBuf;
    End;
  end;

Function LoadOptions(ParmsExtra: TStringList; LocalDir: String): String; //Return Filename

Implementation

Uses SyDefault;

Constructor TUnit1.Create;
begin
  Inherited;
  OptionsLocal:=TOptions.Create;
  OptionsLocal.Assign(OptionsGlobal);
end;

Destructor TUnit1.Destroy;
begin
  OptionsLocal.Free;
  Inherited
end;

Function  TUnit1.Scan(What: eSym): Boolean;
begin
  if Next.Ch=What then begin
    Scan:=True;
    ScanNext;
  end else Scan:=False;
end;

Function  TUnit1.ScanSLPA: Boolean; Begin ScanSLPA:=Scan(SLPA) End;
Function  TUnit1.ScanSLBR: Boolean; Begin ScanSLBR:=Scan(SLBR) End;
Function  TUnit1.ScanSSEM: Boolean; Begin ScanSSEM:=Scan(SSEM) End;
Function  TUnit1.ScanSCOL: Boolean; Begin ScanSCOL:=Scan(SCOL) End;
Function  TUnit1.ScanSCOM: Boolean; Begin ScanSCOM:=Scan(SCOM) End;

procedure TUnit1.ScanNextAndFindSem;
begin
  ScanNext; Find(SSEM);
end;

Procedure TUnit1.FindSCOM;
begin
  Find(SCOM)
end;
procedure TUnit1.FindSLPA;
begin
  Find(SLPA)
end;
procedure TUnit1.FindSRPA;
begin
  Find(SRPA)
end;

Procedure TUnit1.Find(What: eSym);
begin
  if Next.Ch=What then ScanNext else
    Error(ord(What));
end;

(*ScanNext*********************************************************************)
Procedure TUnit1.ScanNext;
procedure DoDouble(s: eSym); begin inc(IBU.PTR,2); Next.Ch:=s end;
procedure DoSingle(s: eSym); begin inc(IBU.PTR); Next.Ch:=s end;
procedure DoIdentifier;
var N: Integer; aChar: Char;
begin
  with Next,IBU do begin
    IdnBuf:=''; IdnBufCase:='';
    repeat
      aChar:=LINE[PTR];
      if not (aChar in IDChars) then BREAK;
      Insert(aChar,IdnBufCase,999);
      Insert(UpCase(aChar),IdnBuf,999); inc(PTR)
    until FALSE;
    N:=Integer(Self.ScanScope(ResWords));
    if N=0 then Ch:=SIDN else Ch:=eSym(Lo(N));
  end;
end;

(*ScanNext*********************************************************************)
Const CaseTab: array[' '..#127] of ShortInt=(
  -1,			{ ' '		}
  -1,			{ '!' (SESC)	}
  -1,			{ '"'		}
  -10,			{ '#'		}
  -4,			{ '$'		}
  ord(SPRC),		{ '%'		}
  -1,			{ '&' (SAND)	}
  -3,			{ "'"		}
  -5,			{ '('		}
  ord(SRPA),		{ ')'		}
  ord(SAST),		{ '*'		}
  ord(SPLS),		{ '+'		}
  ord(SCOM),		{ ','		}
  ord(SMIN),		{ '-'		}
  -6,			{ '.'		}
  ord(SSLA),		{ '/'		}
  -2,-2,-2,-2,-2,-2,-2,-2,-2,-2,		{'0'..'9'	}
  -7,			{ ':'		}
  ord(SSEM),		{ ';'		}
  -8,			{ '<'		}
  ord(SEQS),		{ '='		}
  -9,			{ '>'		}
  -1,			{ '?'		}
  -11,			{ '@' (SCAT)	}
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,	{ 'A'..'Z' }
  ord(SLBR),		{ '['		}
  -1,			{ '\'		}
  ord(SRBR),		{ ']'		}
  ord(SCAR),		{ '^'		}
  0,			{ '_'		}
  -1,			{ '`'		}
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,	{ 'a'..'z' }
  -1,			{'{'		}
  ord(SOR), 		{'|' (SOR)	}
  -1,			(* '}'		*)
  ord(SNOT),		{'~' (SNOT)	}
  -1			{DEL		}
  );
var
  i: ShortInt;
  FoundEOLN: Boolean;
Begin {ScanNext}
  With IBU do begin
    if DoingEOLN and (Next.Ch=SEOLN) then NextLine;  //In case of "MOVE #123,d0 ;Comment here!!!"
    FoundEOLN:=SkipBlanks;	{DOES remove all white space's, except if DoingEOLN}
    if FoundEOLN or (LINE[PTR]<' ') then begin
      Next.Ch:=SEOLN;
      EXIT;
    end;
    ERRPOS:=PTR;
    if LINE[PTR]>#127 then Error(Err_Syntax);
    i:=CaseTab[LINE[PTR]];
    case i of
    1..99: DoSingle(eSym(i));
      0: DoIdentifier;
     -2: DoNumeric;
     -3: DoStr;
     -4: if LINE[PTR+1]<>'$' then DoHex    //$$FileInfo
         else begin
           Inc(PTR,2);
           DoIdentifier;
           Next.Ch:=SSCO;
           with IBUGLB.SrcPTR^ do
                  if (Next.IdnBuf='FILEINFO') then      Next.SValue:=Format('%s(%d)',[ExtractFileName(IBUNAME),IBULINENO])
             else if (Next.IdnBuf='FILENAME') then Next.SValue:=Format('%s',[ExtractFileName(IBUNAME)])
             else if (Next.IdnBuf='FILENAMEFULL') then Next.SValue:=Format('%s',[IBUNAME])
             else if (Next.IdnBuf='FILELINE') then Next.SValue:=Format('%d',[IBULINENO])

             else if (Next.IdnBuf='APPLNAME') then Next.SValue:=Format('%s',[OptionsGlobal.ApplName])
             else if (Next.IdnBuf='APPLID') or (Next.IdnBuf='CREATOR')
                                              then Next.SValue:=Format('%s',[OptionsGlobal.ApplID])
             else Error(Err_Int)
         end;
{ ( }-5: if LINE[PTR+1]='.' then DoDouble(SLBR) else DoSingle(SLPA);
{ . }-6: Case LINE[PTR+1] of
         '.': DoDouble(SDPE);
         ')': DoDouble(SRBR);
         else DoSingle(SPER);
         end;
{ : }-7: if LINE[PTR+1]='=' then DoDouble(SCEQ) else DoSingle(SCOL);
{ < }-8: Case LINE[PTR+1] of
         '<': DoDouble(SSHL);
         '>': DoDouble(SNES);
         '=': DoDouble(SLES);
         else DoSingle(SLTS);
         end;
{ > }-9: Case LINE[PTR+1] of
         '>': DoDouble(SSHR);
         '=': DoDouble(SGES);
         else DoSingle(SGTS);
         end;
{ ^}-10: // '#'
         If DoingASM then DoSingle(SNUM) else
           DoStr;  //Maybe "#define asdasdasd 123" C syntax
{ @}-11: If DoingASM then DoIdentifier else DoSingle(SCAT);
    else Error(Err_Syntax); NextCh;
    end;
  end;
  StopF:=False;
  LastScanPtr:=NIL;		{Scan symbol table next time around}
End;

procedure TUnit1.DoStr;
var C: Char; Ok: Boolean;
begin
  with Next,IBU do begin
    SValue:='';
    Repeat
      C:=LINE[PTR];
      case C of
      '''': begin
              Inc(PTR); Ok:=False;
              Repeat
                C:=LINE[PTR]; Inc(PTR);
                case C of
                #0:   begin Error(Err_String); EXIT; end;
                '''': begin Ok:=True;
                        if LINE[PTR]='''' then Insert(C,SValue,999);
                      end;
                else Insert(C,SValue,999);
                end;
              until Ok;
            end;
      '^':  begin
              Insert(chr($3F and ord(Upcase(LINE[PTR+1]))),SValue,999); inc(PTR,2);
            end;
      '#':  begin
              Inc(PTR); DoNumeric;
              if Ch<>SICO then begin Error(Err_String); EXIT; end;
              Insert(Char(Lo(IValue)),SValue,999);
            end;
      else  Ch:=SSCO;
            if Length(SValue)=1 then begin
              CH:=SCCO;
              IValue:=ord(SValue[1]);
            end;
            EXIT;
      end;
    until PTR>LAST;	{Error exit}
  end;
end;

procedure TUnit1.DoNumeric;
var
  Err,P1,P2: Integer;
  S: String[127];
begin
  with Next,IBU do
    if LINE[PTR]='$' then DoHex else begin
      S:=Copy(LINE,PTR,999); Insert(' ',S,999);
      Val(S,IValue,P1); P2:=0;
      if (P1>0) and ((S[P1]='.') or (UpCase(S[P1])='E')) then begin
        Val(S,RValue,P2);
        if P2=0 then P2:=Length(S); //bug, if no room for next char
        if P2=P1+1 then begin   { "123.." or "123.)" }
          if (S[P2]='.') or (S[P2]=')') then P2:=0;
        end;
      end;
      dec(P1); dec(P2);
      if P1>=P2 then begin
        inc(PTR,P1); Ch:=SICO;
        S[0]:=Char(P1); Val(S,IValue,P1); Err:=Err_Int;
      end else begin
        inc(PTR,P2); Ch:=SRCO;
        S[0]:=Char(P2); Val(S,RValue,P1); Err:=Err_Real;
      end;
      if P1<>0 then Error(Err);
    end;
end;

procedure TUnit1.DoHex;
var I: Integer; I64: Int64;
begin
  with Next,IBU do begin
    I64:=0; IValue:=0; Inc(PTR);
    while LINE[PTR] in HexDigits do begin
      I:=ord(UpCase(LINE[PTR]))-ord('0'); if I>9 then Dec(I,ord('A')-(ord('9')+1));
      //if IValue<$0FFFFFFF then IValue:=IValue*16+I else Error(Err_Int);
      if I64<$0FFFFFFF then I64:=I64*16+I else Error(Err_Int);
      Inc(PTR);
    end;
    Ch:=SICO;
    Move(I64,IValue,SizeOf(IValue));
  end;
end;

procedure TUnit1.IntIdn; //Label # => String ID's
begin
  with Next do
    if Ch=SICO then begin
      Ch:=SIDN;
      IdnBuf:=i2s(IValue);
    end;
end;

procedure TUnit1.NextCh;
begin
  with IBU do
    if PTR>=LAST then begin
      //if DoingEOLN then FoundEOLN:=True //ASM stuff
      //  else
      NextLine;
    end else inc(PTR);
end;

function TUnit1.SkipBlanks: Boolean;
begin
  Result:=False;
  With IBU do
  repeat
    while LINE[PTR] in [#1..' '] do inc(PTR); //White, except #0
    case LINE[PTR] of
    #0:  if DoingEOLN then BREAK else NextLine; //ASM stuff
    '{': DoComment(comSingle,1);
    '(': if LINE[PTR+1]<>'*' then BREAK else
           DoComment(comDouble,2);
    '/': case LINE[PTR+1] of
         '/': begin
                if DoingEOLN then begin Result:=True; BREAK end; //ASM stuff
                NextLine;
              end;
         '*': DoComment(comC,2);
         else BREAK
         end;
    ';': begin if DoingEOLN then Result:=True; BREAK end; //ASM stuff
    else BREAK
    end;
  until FALSE;
end;

{ *******************************************************}
{ *							*}
{ *	CONSTANT EVALUATORS				*}
{ *							*}
{ *******************************************************}

Function TUnit1.FCON: TypPtr;
begin
  Result:=CON;
  if Result=NIL then Error(ExpConst);
End;

{Find string constant (TPAC), Out = value}
Function TUnit1.FSCON: String;
begin
  if FCON^.TTYPE in [TCHR,TPAC] then Result:=Next.SValue
  else Error(ExpCStr);
End;

{Find integer constant, Out = value}
Function TUnit1.FICON: Longint;
begin
  if FCON^.TTYPE<>TINT then Error(ExpCInt);
  Result:=Next.IValue;
End;

Function TUnit1.FUCON: Longint;
begin
  if not (FCON^.TTYPE in [TINT,TUSR]) then Error(ExpCInt);
  Result:=Next.IValue;
end;

{ Scan sign}
Function TUnit1.Sign: eSign;
begin
  case Next.Ch of
  SMIN: begin ScanNext; Sign:=SignMinus End;
  SPLS: begin ScanNext; Sign:=SignPlus  End;
  Else  Sign:=SignNone
  End;
End;

{ Scan unsigned constant, Out Constant type}
Function TUnit1.Constant: TypPtr;
var P: pSymRec; 
begin
  Result:=NIL;
  if Next.Ch=SCAR then begin {Convert caret symbol to string that starts with a control character}
    StopF:=False;
    LastScanPtr:=NIL;		{Scan symbol table next time around}
    if IBU.Ptr>1 then dec(IBU.PTR);
    DoStr;
  end;
  case Next.Ch of
  SICO: Result:=@StandardType[xLON];
  SRCO: Result:=@StandardType[xSNG]; //xEXT]; {ext-real const}
  SCCO: Result:=@StandardType[xCHR]; {char const}
  SSCO: Result:=@StandardType[xPAC]; {string const}
  SNIL: begin                          {NIL pointer const}
          Result:=@StandardType[xPTR];
          Next.IValue:=0;
        end;
  SIDN: begin
          P:=ScanSym(False,DummyWithCode);
          //if P=NIL then EXIT;
          //if P^.What<>SCON then EXIT else //NO ScanNext!
          if P<>NIL then
          if P^.What=SCON then begin
            Result:=P^.CTYPP;
            with Next do
              case Result^.TTYPE of
              TREA: RValue:=P^.CRVAL;
              TPAC: SValue:=P^.CSVAL;
              TSTR: InternalError('TSTR');
              else  IValue:=P^.CIVAL;
              End;
          end;
        end;
  else  Error(ExpConst); //InternalError0??
  end;
  if Result<>NIL then
    ScanNext;
End;

{ Scan signed constant, Out Constant type or NIL }
Function TUnit1.CON: TypPtr;
Var S: eSign; NCh: eSym; N: Integer;
begin
  S:=SIGN;
  Result:=Constant;
  if S<>SignNone then begin
    if Result=NIL then Error(ExpEIR);
    with Next do begin
      case Result^.TTYPE of
      TINT: if S=SignMinus then IValue:=-IValue;
      TREA: if S=SignMinus then RValue:=-RValue;
      else  Error(ExpCIR);
      end;
    end;
  end;
  if Result<>NIL then if Result^.TTYPE=TINT then begin
    while Next.Ch in [SPLS,SMIN,SOR,SAND] do begin //No hierachy
      NCh:=Next.Ch; N:=Next.IValue;
      ScanNext;
      if Constant^.TTYPE<>TINT then Error(ExpCInt);
      case NCh of
      SPLS: Next.IValue:= N +   Next.IValue;
      SMIN: Next.IValue:= N -   Next.IValue;
      SOR:  Next.IValue:= N OR  Next.IValue;
      SAND: Next.IValue:= N AND Next.IValue;
      end;
    end;
  end;
end;

Function  TUnit1.OpenSrc(Name: String): Boolean;
var
  N,I,rc: Integer;
  P: pSrcBuf;
  S,Fil,Path: String;
  Data: AnsiString;
  IBUFILE: File;
begin
  Result:=False;
  Path:=ExtractFilePath(Name);
  Fil:=ExtractFileName(Name);
  AddSearch(Path); //Add myself??
  With IBUGLB do begin
    if CNT=IBUMax then EXIT;
    New(P); ZeroBlock(P^, SizeOf(P^)); //P:=NewZero(SizeOf(SrcPTRs[1]^));
    With P^ do begin
      MemStream:=TMemoryStream.Create;
      S:=LocateUsingSearch(Name);
      if S<>'' then begin
        FileMode := 0; Assign(IBUFILE,S); Reset(IBUFILE,1);
        if IOResult=0 then begin
          IBUNAME:=S;
          if Assigned(UIIntf.CallBack) then UIIntf.CallBack(CurCompList+S);
          I:=FileSize(IBUFILE);
          SetLength(Data,I); BlockRead(IBUFILE,Data[1],I,rc);
          CloseFile(IBUFILE);
          Result:=True;
        end;
      end;

      //Load library
      if Data='' then begin
        Name:=ChangeFileExt(Name, '.Hsu');
        N:=HSPascalLibCache.IndexOf(Name);
        if N>=0 then begin
          Data:=HSPascalLibCacheS[N] //UniqueString(Data);
        end else begin
          for N:=0 to SearchPaths.Count do begin
            if N=SearchPaths.Count then Path:=ExtractFilePath(ParamStr(0)) else Path:=SearchPaths[N];
            Path:=Path+HSPasLibZip;
            Data:=LoadFromZip(Path, Name, FALSE);
            if Data<>'' then BREAK;
          end;
          if Data<>'' then begin
            N:=HSPascalLibCache.Add(Name);
            SetLength(HSPascalLibCacheS,N+1); HSPascalLibCacheS[N]:=Data;
          end;
        end;

        Result:=Data<>'';
        if Result then begin
          IBUNAME:=Format('HSPascal Library(%s): %s',[Path,ChangeFileExt(ExtractFileName(Name),'')]);
          UniqueString(Data);
          Byte(Data[1]):=Byte(Data[1]) xor $AA;
          try    Data:=ZDeCompressStr(Data);  //Unzip twice
          except InternalError('Cannot load Library:'+Name);
          end;
          DCStream:=TZDecompressionStream.Create(MemStream);
        end;
      end;

      if Result then begin
        SrcOpened:=True;
        MemStream.Write(Data[1],Length(Data)); MemStream.Position:=0;
        if CNT>0 then begin
          SrcPTRs[CNT]^.IBUGLOB:=IBU;	{Save current}
        end;
        inc(CNT); SrcPTRs[CNT]:=P; SrcPTR:=P;
        NextLine;			{Set new current}
        IBUFileNo:=Length(Glb.MapFileList);
        SetLength(Glb.MapFileList,IBUFileNo+1);
        with Glb.MapFileList[IBUFileNo] do
          Name:=IBUNAME;
      end;
    end;
  end;
end;

Procedure TUnit1.CloseSrc;
begin
  if SrcOpened then
  With IBUGLB do begin
    SrcOpened:=False;
    with SrcPTR^ do begin
      ////////////Close(IBUFILE);
      DCStream.Free;
      MemStream.Free;
    end;
    Dispose(SrcPtr); //DispZero(SrcPTR);
    SrcPTRs[CNT]:=NIL; SrcPTR:=NIL;
    Dec(CNT);
    if CNT>0 then begin
      SrcPTR:=SrcPTRs[CNT];
      IBU:=SrcPTR^.IBUGLOB;		{Restore current}
    end;
  end;
end;

Procedure TUnit1.NextLine;
var N: Integer; S: AnsiString;
Const MaxRd=500;
begin
  With IBU,IBUGLB.SrcPTR^ do begin
    Inc(UIIntf.TotLinesCompiled);
    if MemStream<>NIL then
      if Length(RestOfLine)<MaxRd then begin
        SetLength(S,MaxRd);
        if DCStream<>NIL then N:=DCStream.Read(S[1],MaxRd) else N:=MemStream.Read(S[1],MaxRd);
        SetLength(S,N);
        RestOfLine:=RestOfLine+S;
        if N=0 then begin
          DCStream.Free; DCStream:=NIL;   //Optimise speed, conserve memory
          MemStream.Free; MemStream:=NIL;
        end;
      end;
    //if EOF(IBUFILE) then Error(Err_EOF);
    if RestOfLine='' then Error(Err_EOF);
    repeat
      N:=Pos(#13,RestOfLine); if N>0 then BREAK;
      N:=Pos(#10,RestOfLine); if N>0 then BREAK;
      RestofLine:=RestofLine+#13#10; //Redo last line, perfect terminated!
    until FALSE;
    LINE:=Copy(RestOfLine,1,N-1);
    if RestOfLine[N+1]=#10 then Inc(N); //Remove two: #13#10
    RestOfLine:=Copy(RestOfLine,N+1,9999);
    //Readln(IBUFILE,LINE);
    //if IOResult<>0 then {EOF} ;
    PTR:=1; LAST:=ord(LINE[0])+1;       {Point to last #0}
    if LAST>=256 then
      Error(Err_LineTooLong);
    LINE[LAST]:=#0;		        {Additional end mark}
    Inc(IBULINENO);
    {$Ifdef DebugOutput} write(ibulineno+1:40,' >>',line); {$Endif}
  end;
end;

(******************************************************************************)
Function GetDirIndex(S: String; MakeError: Boolean): cdCompDir;
begin
  for Result:=Low(cdCompDir) to High(cdCompDir) do
    if CmpStr(S,DirTable[Result]) then EXIT;
  if MakeError then Error(Err_InvDir);
  Result:=cdNONE;
end;

function GetOne(var S: String): String;
var M,N: Integer;
begin
  N:=Pos(';',S); M:=Pos(',',S);
  if M>0 then if N>M then N:=M;
  Result:=Trim(Copy(S,1,N-1));
  Delete(S,1,N);
end;

Procedure TUnit1.DoComment(Why: CommentType; Size: Byte);	{'{', '(*', '/*'}
procedure SkipComment(Why: CommentType); {'{', '(*', '/*'}
begin
  SkipDebug:=   TRUE;
  with IBU do
    case Why of
    comSingle: while LINE[PTR]<>'}' do
                 NextCh;
    comDouble: begin
                 while not ((LINE[PTR]='*') and (LINE[PTR+1]=')')) do
                   NextCh;
                 NextCh;
               end;
    comC:      begin
                 while not ((LINE[PTR]='*') and (LINE[PTR+1]='/')) do
                   NextCh;
                 NextCh;
               end;
    end;
  SkipDebug:=   FALSE
end;
function GetDirName: String; //xxx, as in {$ifdef xxx}
begin
  Result:='';
  //repeat NextCh until not (IBU.LINE[IBU.PTR] in [' ',^I]);
  with IBU do
//    while LINE[PTR] in IDChars+['*','?','\',':','.',';','-','+',',',' ',^I] do begin //Include leading spaces
    while IBU.LINE[IBU.PTR] in IDChars+[' '..'A','\',^I]-['}'] do begin //Include leading spaces
      if IBU.LINE[IBU.PTR]='*' then if IBU.LINE[IBU.PTR+1]=')' then BREAK;
      Insert(LINE[PTR],Result,999);
      Inc(PTR);
    end;
    //if TestEndComment then begin end;////////////!!!!!!!!!
    SkipComment(Why);
  Result:=Trim(Result);
end;
function GetDirIdent: String; //xxx, as in {$xxx
begin
  Result:='';
  with IBU do
    while LINE[PTR] in IDChars do begin
      Insert(UpCase(LINE[PTR]),Result,999);
      Inc(PTR);
    end;
end;

function SkipText: Boolean; //Skip text until ELSE or ENDIF, same level. True if ended by ELSE
var I: cdCompDir; Why2: CommentType;
begin
  with IBU do
  repeat
    Why2:=comDouble;
    case IBU.LINE[IBU.PTR] of
    '{': Why2:=comSingle;
    '(': if LINE[PTR+1]<>'*' then begin NextCh; CONTINUE end;
    '/': begin if LINE[PTR+1]='/' then NextLine else NextCh; CONTINUE end;
    '''': begin
            repeat NextCh until (LINE[PTR]='''') or (PTR=LAST); //Simple version
            CONTINUE;
          end;
    else  NextCh;
          CONTINUE
    end;
    NextCh;
    if Why2=comDouble then NextCh;
    if LINE[PTR]<>'$' then begin
      SkipComment(Why2);
      CONTINUE;
    end;
    NextCh;
    I:=GetDirIndex(GetDirIdent,False);
    SkipComment(Why2);
    Result:= I=cdELSE;
    case I of
    cdELSE,cdENDIF: EXIT;
    cdIFDEF,cdIFNDEF,cdIFOPT:
      repeat
      until NOT SkipText; //repeat until ELSE part skipped
    end;
    NextCh;
  until FALSE;
end;

function StartApplication(Cmd: AnsiString): Boolean;
var
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  StartFlg: Boolean;
  lpExitCode: DWord;
  RC: Integer;
begin
  Result:=False;
  Cmd:=Trim(Cmd); if Cmd='' then EXIT;
  FillChar(StartupInfo, SizeOf(TStartupInfo), 0);
  with StartupInfo do begin
    cb := SizeOf(TStartupInfo);
    dwFlags := STARTF_USESHOWWINDOW or STARTF_FORCEONFEEDBACK;
    {if FRunTime or Preview then wShowWindow := SW_SHOWMINNOACTIVE else{}
    wShowWindow := SW_SHOWNORMAL;
  end;
  StartFlg:=CreateProcess(NIL, PChar(Cmd), nil, nil, False,
    CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS,
    nil, nil, StartupInfo, ProcessInfo);
  RC:=GetLastError;
  if not StartFlg then begin
    RC:=iPos('start ',Cmd);
    if RC <> 1 then
      Cmd:='Start '+Cmd;
    if RC <> 1 then begin // allready tried createprocess(nil, 'start +'cmd',...
      StartFlg:=CreateProcess(NIL, PChar(Cmd), nil, nil, False,
        CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, nil, nil, StartupInfo, ProcessInfo);
      RC:=GetLastError;
    end;
  end;
  if not StartFlg then begin
    StartFlg:=CreateProcess(PChar('Start'), PChar(Cmd), nil, nil, False,
      CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, nil, nil, StartupInfo, ProcessInfo);
    RC:=GetLastError;
  end;
  lpExitCode:=0;
  if StartFlg then
    with ProcessInfo do begin
      Result := True;
      WaitForsingleObject(hProcess,INFINITE);
      GetExitCodeProcess(hProcess,lpExitCode);
    end
  else
    ;;;//Debug('StartApplication Error RC %d',[RC]);
  if RC<>0 then
    Error(Err_BadExec,i2s(RC));
  if lpExitCode<>0 then
    Error(Err_BadExec,i2s(1000+lpExitCode));
  ///??? ProcessInfo.Free;
end;

// Process conditional construct
procedure ProcessCond(B: Boolean);
begin
  SkipComment(Why);
  Inc(IBUGLB.SrcPTR^.IBUCndLevel);
  if NOT B then begin //Not DEFINED => Skip this section
    if NOT SkipText then Dec(IBUGLB.SrcPTR^.IBUCndLevel);
  end;
end;

var N: Integer; B,Saved: Boolean; I: cdCompDir; AnsiS,AnsiS2: AnsiString; S,S2,CurrentDir: String;
begin {DoComment}
  Saved:=DoingEOLN; DoingEOLN:=False; //ASM stuff!
  with IBU do begin
    Inc(PTR,Size-1);
    NextCh;
    if LINE[PTR]='$' then begin
      repeat
        NextCh;
        I:=GetDirIndex(GetDirIdent,True);
        B:=True;
        if I in DirOnOff then
          case LINE[PTR] of
          '+': begin Include(OptionsLocal.Active,I); B:=False end;
          '-': begin Exclude(OptionsLocal.Active,I); B:=False end;
          end;
        if B then BREAK;
        if LINE[PTR+1]=',' then NextCh else BREAK;
      until FALSE;
      if B then
      Case I of
      cdIFDEF:  ProcessCond(OptionsLocal.ScanCondSym(GetDirName));
      cdIFNDEF: ProcessCond(NOT OptionsLocal.ScanCondSym(GetDirName));
      cdELSE:
        begin
          if IBUGLB.SrcPTR.IBUCndLevel=0 then Error(Err_MispDir);
          SkipComment(Why);
          if SkipText then
            Dec(IBUGLB.SrcPTR.IBUCndLevel);
        end;
      cdENDIF: if IBUGLB.SrcPTR.IBUCndLevel>0 then Dec(IBUGLB.SrcPTR.IBUCndLevel)
               else Error(Err_MispDir);
      cdIFOPT:
        begin
          I:=GetDirIndex(GetDirName,True);
          if not (I in DirOnOff) then Error(Err_InvDir);
          with IBU do
            case LINE[PTR] of
            '+': B:=True;
            '-': B:=False;
            else Error(Err_InvDir);
            end;
          B:= B=(I in OptionsLocal.Active);
          ProcessCond(B);
        end;
      cdEXECUTE:
        begin
          S:=GetDirName+';';
          AnsiS2:=GetOne(S); AnsiS:=GetOne(S);
          ReplaceDollarTokens(AnsiS);
          ReplaceDollarTokens(AnsiS2);
          CurrentDir:=GetCurrentDir;
          if AnsiS<>'' then SetCurrentDir(AnsiS);
          try B:=StartApplication(AnsiS2) except B:=False end;
          SetCurrentDir(CurrentDir);
          if not B then
            Error(Err_BadExec);
          //if ShellExecute(Application.Handle,PChar('Open'),PChar(S),nil,nil,SW_SHOWNORMAL)<=32 then;;;
        end;
      cdSetDEFAULT:  begin
                       for N:=0 to OptionsLocal.OptionsDefined.Count-1 do
                         OptionsGlobal.DefCondSymb(OptionsLocal.OptionsDefined[N],FALSE{Not recursive});
                         OptionsGlobal.Active:=OptionsLocal.Active;
                     end;
      else
        S:=GetDirName+';';
        repeat
          S2:=GetOne(S); if S2='' then BREAK;
          case I of
          cdDEFINE:      OptionsLocal.DefCondSymb(S2);
          cdUNDEF:       OptionsLocal.ClrCondSymb(S2);
          cdR:           if not Rsrc.LoadFromFileWildCard(S2) then Error(Err_FileNotFound);
          cdO:           OptionsGlobal.OutputPath:=S2;  //GLOBAL!!
          cdI,
          cdSrchPath:    AddSearch(S2);
          cdAppNameType: begin OptionsGlobal.ApplName:=S2; OptionsGlobal.ApplID:=GetOne(S) end;
          cdMaxString:   begin N:=s2i(S2); SetMaxString(N); if N<10 then Error(Err_InvDir) end;
          else Error(Err_InvDir);
          end;
        until FALSE;
      end;
    end;
  end;
  SkipComment(Why);
  NextCh;
  DoingEOLN:=Saved;
end;

(** CmdLine parsing ***********************************************************)
Procedure ParseParms(Parm: String);
var
  Ch1,Ch2: Char;
  I: cdCompDir;
  S: String;
  N: Integer;
  AnsiS: AnsiString;
begin
  if S2Char(Parm,' ')='$' then begin
    Delete(Parm,1,1); Ch1:=S2Char(Parm,' ');
    Delete(Parm,1,1); Ch2:=S2Char(Parm,' ');
    I:=GetDirIndex(Ch1,False);
    if I in DirOnOff then
      case Ch2 of
      '+': Include(OptionsGlobal.Active,I);
      '-': Exclude(OptionsGlobal.Active,I);
      end;
    EXIT;
  end;

  if CmpStr(Parm,'testmode') then begin
    TestMode:=True;
    EXIT;
  end;

  if CmpStr(Parm,'V') then begin
    Verbose:=True;
    EXIT;
  end;

  N:=Pos(' ',Parm);
  if N=0 then begin
    N:=2;  //  -Dxxxx
    if Length(Parm)=1 then EXIT;
  end;

  S:=Copy(Parm,1,N-1);
  I:=GetDirIndex(S,False);
  Parm:=Trim(Copy(Parm,N,999))+';';
  AnsiS:=Parm; ReplaceDollarTokens(AnsiS); Parm:=AnsiS;
  repeat
    S:=GetOne(Parm); if S='' then BREAK;
    Case I of
    cdD,cdDEFINE: OptionsGlobal.DefCondSymb(S);
    cdUNDEF:  OptionsGlobal.ClrCondSymb(S);  //Cannot do
    //cdR: if not Rsrc.LoadFromFileWildCard(GetDirName) then Error(Err_FileNotFound); //Err_InvDir);
    cdO:            OptionsGlobal.OutputPath:=iFormatPath(S);
    cdI,cdSrchPath: AddSearch(iFormatPath(S));
    cdAppNameType:  begin OptionsGlobal.ApplName:=S; OptionsGlobal.ApplID:=GetOne(Parm); BREAK end;
    cdMaxString:    begin N:=s2i(S); SetMaxString(N); if N<10 then Error(Err_InvDir) end;
    else            Debug('Unknown: '+S);   //!!!!!!!!!!!!!!!
    end;
  until FALSE;
end;

Function LoadOptions(ParmsExtra: TStringList; LocalDir: String): String; //Return Filename
var
  M,N: Integer;
  S: String;
  Parms: TStringList;
begin
  Result:='';

  Parms:=TStringList.Create;
  S:=ChangeFileExt(iFormatPath(LocalDir)+ExtractFileName(ParamStr(0)),'.cfg'); //Local copy
  if not FileExists(S) then
    S:=ChangeFileExt(ParamStr(0),'.cfg');     
  try
    Parms.LoadFromFile(S);
  except
  end;

  for N:=1 to ParamCount do begin
    S:=ParamStr(N);
    Parms.Add(S);
  end;

  SearchPaths.Clear;
  OptionsGlobal.Free;
  OptionsGlobal:=TOptions.Create;  //Will create HSPascal, 68000, VER20
  OptionsGlobal.OutputPath:='';
  OptionsGlobal.Active:=DerDefault; 
  OptionsGlobal.ApplName:='';
  OptionsGlobal.ApplID:='';   //GLOBAL ONLY. From scanner used in Rsrc SaveFile

  for M:=1 to 2 do begin
    if M=2 then
      if ParmsExtra=NIL then CONTINUE else Parms.Assign(ParmsExtra);
    for N:=0 to Parms.Count-1 do begin
      S:=Parms[N];
      //Debug(S);
      case UpCase(S2Char(S,' ')) of
      '-','/': ParseParms(Copy(S,2,999));
      #00..' ',';': ;
      else
        if Result<>'' then
          Error(Err_Commandline,S);
        Result:=S;
      end;
    end;
  end;
  Parms.Free;
end;

(********************************************************************************
C:\>apps\bp\bin\tpc.exe
Turbo Pascal  Version 7.0  Copyright (c) 1983,92 Borland International
Syntax: TPC [options] filename [options]
  -B = Build all units                -L = Link buffer on disk
  -D<syms> = Define conditionals      -M = Make modified units
  -E<path> = EXE/TPU directories      -O<path> = Object directories
  -F<seg>:<ofs> = Find error          -Q = Quiet compile
  -GD = Detailed map file             -T<path> = TPL/CFG directory
  -GP = Map file with publics         -U<path> = Unit directories
  -GS = Map file with segments        -V = Debug information in EXE
  -I<path> = Include directories      -$<dir> = Compiler directive
Compiler switches: -$<letter><state>  (defaults are shown below)
  A- Word alignment       I+ I/O error checking   R- Range checking
  B- Full boolean eval    L- Local debug symbols  S- Stack checking
  D+ Debug information    N- 80x87 instructions   T- Typed pointers
  E+ 80x87 emulation      O- Overlays allowed     V- Strict var-strings
  F+ Force FAR calls      P- Open string params   X- Extended syntax
  G+ 80286 instructions   Q- Overflow checking
Memory sizes: -$M<stack>,<heapmin>,<heapmax>  (default: 60000,75008,655360)
********************************************************************************)
end.

