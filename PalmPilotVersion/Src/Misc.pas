Unit Misc;

Interface

Uses Windows, Classes, SysUtils, Global, Util;

Procedure AddSearch(S: String);
Function  LocateUsingSearch(Name: String): String;

Function LocateSysProc(SysProcInx: Integer): TRef;

var SkipDebug: Boolean;
procedure Write(Const S: String);
procedure WriteCMD(Const S: String);

procedure SetError(Err: Integer);
Function  ErrorStr(No: Integer): String;
//procedure WriteErrorStr(No: Integer);
procedure Error(Rc: Integer; Error2: String='');
Procedure CheckRange(Val,Min,Max: Longint; Err: Integer);

Procedure InternalError(Const S: String);
Procedure InternalError0;
Procedure UNIMPLEMENTED;

Var
  xxxxHeapError: Boolean;	{Can be set before a batch creation}

Procedure ZeroBlock(Var Blk; Size: Longint);
Procedure ZeroSym(Var Blk: tSymRec);
Procedure ZeroTyp(Var Blk: tType);

Var CmpErr: Integer;
    DebugErrorStr: String;
    ErrorStr2: String;  //For InternError(xx)

{ Error numbers }

Const
  Err_Error		=	140;
  Err_FileNotFound	=	143;
  Err_Commandline       =       144;
  Err_NoSrc		=	148;
  Err_CannotWr          =       149;

  Err_InvSub		=	151;
  Err_BoundErr		=	152;
  Err_InvFOR		=	153;
  Err_IllAssignment	=	154;
  Err_String		=	155;
  Err_Int		=	160;
  Err_Real		=	157;
  Err_Div0		=	158;
  Err_StructLarge	=	159;
  Err_ExpEChar		=	161;
  Err_InvCast		=	162;
  Err_InvalAddr		=	163;
  Err_LabelX2		=	164;
  Err_CannotBreak       =       165;
  //Err_InvFType		=	165;
  Err_BadRdWr		=	166;
  Err_MustBeVAR		=	167;
  //Err_FileFile		=	168;
  Err_ExpVTPointer	=	169;
  Err_SetBase		=	170;
  Err_InvGOTO		=	171;
  Err_LabelBlock	=	172;
  Err_UndefFWD		=	173;
  Err_UndefAsmLabel	=	174;
  Err_Type		=	175;
  Err_Stmt		=	176;
  Err_Expr		=	177;
  Err_InvEDef		=	178;
  Err_InvERef		=	179;
  Err_Symbols		=	180;
  Err_Scope		=	181;
  Err_Variables		=	183;
  Err_Complicated	=	184;
  Err_ComplicatedWith   =       185;
  Err_Code		=	186;
  Err_UnitNotFound	=	187;
  Err_ProgName		=	188;
  Err_MissUnit		=	189;
  Err_Syntax		=	190;
  Err_EOF		=	191;
  Err_LineTooLong	=	192;
  Err_InvDir		=	193;
  Err_BadExec           =       194;
  //Err_SchoolLim		=	194;
  //Err_UndefEXT		=	195;
  //Err_BadObject		=	196;
  Err_InvSysProc	=	196;
  //Err_ggggggggggg	=	197;
  Err_Internal		=	199;
  //Err_16Bit		=	200;
  Err_AlreadyUsed       =       201;
  Err_CircRef           =       202;
  Err_DupUnit		=	203;
  Err_CondVar		=	204;
  Err_MispDir		=	205;
  Err_MisENDIF		=	206;
  Err_FindYes		=	207;
  Err_FindNo		=	208;
  Err_FindProg		=	209;
  Err_FoundUnit		=	210;
  Err_ASM		=	211;
  Err_ASM1		=	212;
  Err_ASM2		=	213;
  Err_ASM3		=	214;
  Err_ASM4		=	215;
  Err_ASM5		=	216;
  Err_ASM6		=	217;

  ExpEBoolean		=	220;
  ExpCInt		=	221;
  ExpEInt		=	222;
  ExpVInt16		=	223;
  ExpVInt32		=	224;
  ExpCIR		=	225;
  ExpEIR		=	226;
  ExpVIR		=	227;
  ExpVPointer		=	228;
  ExpVRecord		=	229;
  ExpTOrdinal		=	230;
  ExpEOrdinal		=	231;
  ExpCStr		=	232; 
  ExpEStr		=	233;
  ExpVStr		=	234;
  ExpTypeID		=	236;
  ExpIDField		=	237;
  ExpConst		=	238;
  ExpVar		=	239;
  UndefLabel		=	240;
  Unknown		=	241;
  UndefPType		=	242;
  DupID			=	243;
  TypeMismatch		=	244;
  ConstRange		=	245;
  CaseTypes		=	246;
  OpTypes		=	247;
  InvalidResult		=	248;
  InvStrLen		=	249;
  Err_NotAnOBJ		=	250;
  Err_ObjNoConstr	=	251;
  Err_ExpMethod		=	252;
  Err_Extrn = Err_Error;

const
  MaxDebugList=30;

procedure Debug(S: String);
procedure DebugIfL(S: String);
procedure DebugList(Name: String; List: TStringList);

Implementation

Uses
  {$ifdef VersionUI} HspcUI, DebugFrm, {$Endif}
  Scanner;

Function  ErrorStrBasic(No: Integer): String; forward;

procedure WriteCMD(Const S: String);
begin
  Writeln(S);
end;

procedure Write(Const S: String);
begin
  ///{$ifdef VersionCMD} if not SkipDebug then WriteCMD(S);          {$Endif}
  {$ifdef VersionUI}  if not SkipDebug then FormDebug.Write(S);   {$Endif}
end;

Procedure ZeroBlock(Var Blk; Size: Longint);
begin
  FillChar(Blk,Size,#0)
end;
Procedure ZeroSym(Var Blk: tSymRec);
begin
  FillChar(Blk,SizeOf(Blk),#0)
end;

Procedure ZeroTyp(Var Blk: tType);
begin
  FillChar(Blk,SizeOf(Blk),#0)
end;

(*****
procedure WriteErrorStr(No: Integer);
var n: Integer; S: String;
begin
  with IBU do begin
    write(Line);
    for n:=1 to ERRPOS-1 do S:=S+' ';
    for N:=ERRPOS to PTR-1 do S:=S+'^';
    write(S);
  end;
  S:=ErrorStr(No);
  write('Error: '+i2s(ConvertedErrorNumber)+', '+S);
end;
(*************)

procedure Error(Rc: Integer; Error2: String='');
var S: String; E: ECompException;
begin
  if Rc<>0 then begin
    //S:='Error: '+i2s(Rc)+': '+ErrorStr(Rc)+ErrorStr2+' '+Error2;
    S:=ErrorStr(Rc)+ErrorStr2+' '+Error2;
    if DebugErrorStr<>'' then S:=S+' <'+DebugErrorStr+'>';
    Debug(S);
    E:=ECompException.Create(S);
    E.rc:=rc;
    Raise E;
  end;
  //LongJmp(GlbTarget,Rc);
end;

Function  ErrorStr(No: Integer): String;
begin
  Result:=ErrorStrBasic(No);
end;

procedure SetError(Err: Integer);
begin
  if (CmpErr<>0) or (Err=0) then EXIT;
  CmpErr:=Err;
end;

Procedure UNIMPLEMENTED;
begin
  Error(Err_Error)
end;

Procedure InternalError0;
var n: Byte;
begin
  n:=0;
  if N=0 then InternalError('?')
end;
Procedure InternalError(Const S: String);
begin
  ErrorStr2:=' ('+S+')';
  Error(Err_Internal)
end;

Procedure CheckRange(Val,Min,Max: Longint; Err: Integer);
begin
  if (Val<Min) or (Val>Max) then
    Error(Err);
end;

procedure DebugIfL(S: String);
begin
  if TestMode then Write(S);
end;

procedure Debug(S: String);
begin
{$ifndef SkipListBox}
  Write(S);
{$endif}
end;

procedure DebugList(Name: String; List: TStringList);
var N: Integer;
begin
  N:=List.Count; if N>MaxDebugList then N:=MaxDebugList;
  for N:=0 to N-1 do
    Debug(Format('%s %3d: %S',[Name,N,List[N]]));
end;

Function LocateSysProc(SysProcInx: Integer): TRef;
var P: pSymRec;
begin
  P:=Glb.SysProc[SysProcInx];
  if P=NIL then InternalError('SysProc not installed:'+i2s(SysProcInx));
  if not (P^.What in [SPRO,SFUN]) then InternalError0;
  Result:=P^.PRef;
end;

Function  ErrorStrBasic(No: Integer): String;
Var S: String;
begin
  Case No of
  ExpEboolean: S:='Boolean expression expected';
  //ExpVFile: S:='File variable expected';
  ExpCInt: S:='Integer constant expected';
  ExpEInt: S:='Integer expression expected';
  ExpVInt16: S:='Integer variable expected';
  ExpVInt32: S:='Longint variable expected';
  ExpCIR: S:='Integer or real constant expected';
  ExpVIR: S:='Integer or real expression expected';
  ExpEIR: S:='Integer or real variable expected';
  ExpVPointer: S:='Pointer variable expected';
  ExpVRecord: S:='Record variable expected';
  ExpTOrdinal: S:='Ordinal type expected';
  ExpEOrdinal: S:='Ordinal expression expected';
  ExpCStr: S:='String constant expected';
  ExpEStr: S:='String expression expected';
  ExpVStr: S:='String variable expected';
  ExpTypeID: S:='Type identifier expected';
  ExpIDField: S:='Field identifier expected';
  ExpConst: S:='Constant expected';
  ExpVar: S:='Variable expected';
  UndefLabel: S:='Undefined label';
  Unknown: S:='Unknown identifier';
  UndefPType: S:='Undefined type in pointer definition';
  DupID: S:='Duplicate identifier';
  TypeMismatch: S:='Type mismatch';
  ConstRange: S:='Constant out of range';
  CaseTypes: S:='Constant and CASE types do not match';
  OpTypes: S:='Operand types does not match operator';
  InvalidResult: S:='Invalid result type';
  InvStrLen: S:='Invalid string length';
  Err_UndefAsmLabel: S:='Undefined label in ASM statement';
  Err_InvSub: S:='Invalid subrange base type';
  Err_BoundErr: S:='Lower bound greater than upper bound';
  Err_InvFOR: S:='Invalid FOR control variable';
  Err_IllAssignment: S:='Illegal assignment';
  Err_String: S:='String constant exceeds line';
  Err_Int: S:='Error in integer constant';
  Err_Real: S:='Error in real constant';
  Err_Div0: S:='Division by zero';
  Err_StructLarge: S:='Structure too large';
  //Err_xxx: S:='Constants are not allowed here'; {}
  Err_ExpEChar: S:='Char expression expected';
  Err_InvCast: S:='Invalid type cast argument';
  Err_InvalAddr: S:='Invalid ''@'' argument';
  Err_LabelX2: S:='Label already defined';
  Err_CannotBreak: S:='Cannot use BREAK/CONTINUE here';
  //65: Err_InvFType: S:='Invalid file type';
  Err_BadRdWr: S:='Cannot read or write variables of this type';
  Err_MustBeVAR: S:='Must be VAR parameters';
  //68: Err_FileFile: S:='File components may not be files';
  Err_ExpVTPointer: S:='Typed Pointer variable expected';
  Err_SetBase: S:='Set base type out of range';
  Err_InvGOTO: S:='Invalid GOTO';
  Err_LabelBlock: S:='Label not within current block';
  Err_UndefFWD: S:='Undefined FORWARD procedure: ';
  Err_Type: S:='Error in type';
  Err_Stmt: S:='Error in statement';
  Err_Expr: S:='Error in expression';
  Err_InvEDef: S:='Invalid external definition, symbol = ';
  Err_InvERef: S:='Invalid external reference, symbol = ';
  Err_Symbols: S:='Too many symbols';
  Err_Scope: S:='Too many nested scopes';
  Err_Variables: S:='Too many variables';
  Err_Complicated: S:='Expression too complicated';
  Err_ComplicatedWith: S:='Too many nested with';
  Err_Code: S:='Too much code';
  Err_UnitNotFound: S:='Unit not found';
  Err_ProgName: S:='Bad unit or program name: ';
  Err_MissUnit: S:='Unit missing: ';
  Err_Syntax: S:='Syntax error';
  Err_EOF: S:='Unexpected end of text';
  Err_LineTooLong: S:='Line too long';
  Err_InvDir: S:='Invalid compiler directive';
  Err_BadExec: S:='Cannot do $Execute directive';
  Err_InvSysProc: S:='Cannot call SysProc function';
  //94: Err_SchoolLim: S:='School version limit in this program, sorry';
  //95: Err_UndefEXT: S:='Undefined EXTERNAL procedure: ';
  //96: Err_BadObject: S:='Bad data in objectfile: ';
  Err_Internal: S:='Internal error';
  //Err_16Bit: S:='No room in 16 bit fixup field, try with $F+';
  Err_AlreadyUsed: S:='Unit already used';
  Err_CircRef: S:='Circular unit references';
  Err_DupUnit: S:='Duplicate unit name: ';
  Err_CondVar: S:='Conditional variable missing';
  Err_MispDir: S:='Misplaced conditional directive';
  Err_MisENDIF: S:='ENDIF directive missing';
  Err_FindYes: S:='Target address found';
  Err_FindNo: S:='Target address not found';
  Err_FindProg: S:='Find only works on PROGRAM files';
  Err_FoundUnit: S:='Error found in unit: ';
  Err_ASM: S:='ASM expected';
  Err_ASM1: S:='Parameter error';
  Err_ASM2: S:='Offset to large';
  Err_ASM3: S:='Only An or PC allowed';
  Err_ASM4: S:='68000 register expected';
  Err_ASM5: S:='Expression too complex';
  Err_ASM6: S:='Constant string cannot be used';
  Err_ExpMethod: S:='Method identifier expected';

  Err_Error: S:='Error ';
  Err_FileNotFound: S:='File not found: ';
  Err_Commandline: S:='Cmdline (parameter) error: ';
  Err_NoSrc: S:='Source not found: ';
  Err_CannotWr: S:='Cannot save to file: ';
  Err_NotAnOBJ: S:='OBJECT type expected';
  Err_ObjNoConstr: S:='CONSTRUCTOR cannot have VIRTUAL';
  else
    Case eSym(No) of
    SSEM: S:=''';'' expected';
    SCOL: S:=''':'' expected';
    SCOM: S:=''','' expected';
    SLPA: S:='''('' expected';
    SRPA: S:=''')'' expected';
    SEQS: S:='''='' expected';
    SCEQ: S:=''':='' expected';
    SLBR: S:='''['' expected';
    SRBR: S:=''']'' expected';
    SPER: S:='''.'' expected';
    SDPE: S:='''..'' expected';
    SBGN: S:='BEGIN expected';
    SPGM: S:='PROGRAM expected';
    SUNI: S:='UNIT expected';
    SDO: S:='DO expected';
    SEND: S:='END expected';
    SOF: S:='OF expected';
    SINF: S:='INTERFACE expected';
    STHN: S:='THEN expected';
    STO: S:='TO or DOWNTO expected';
    SIMP: S:='IMPLEMENTATION expected';
    SASM: S:='ASM expected';
    SIDN: S:='Identifier expected';
    end;
  end;
  Result:=S;
end;

Procedure AddSearch(S: String);
var N: Integer;
begin
  S:=Trim(S); if S='' then EXIT;
  if not ( (Length(S)>=2) and (S[2]=':') ) then
    if S[1]<>'\' then
      if S[1]<>'.' then
        S:=GetCurrentDir+'\'+S;
  if S[Length(S)]<>'\' then S:=S+'\';
  for N:=0 to SearchPaths.Count-1 do if CmpStr(S,SearchPaths[N]) then EXIT;
  SearchPaths.Add(S);
end;

Function  LocateUsingSearch(Name: String): String;
var N: Integer; S: String;
begin
  Result:='';
  for N:=-2 to SearchPaths.Count do begin
    case N of
    -2:  begin S:=ExtractFileName(Name) end; //First find, no matter absolute path!!!!???
    -1:  begin S:=Name; Name:=ExtractFileName(Name) end; //First find exact as written, using path!
    else if N=SearchPaths.Count then
           S:=ExtractFilePath(ParamStr(0))+Name
         else
           S:=SearchPaths[N]+Name
    end;
    if FileExists(S) then begin
      Result:=ExpandFileName(S);
      BREAK;
    end;
  end;
end;

End.

