Unit Global;

Interface

Uses {$ifdef VersionUI} DebugFrm, {$Endif} Classes, Util, SysUtils;

Const
  BuildDate = 'Aug 23, 2002, #33';                                      //<<<<<<
  HSVersion     = 'HSPascal version 2.02';                              //<<<<<<
{$ifdef VersionFull}
  // 31-7-2002: See hardcoded in Expire.pas                             //<<<<<<
  TimeLimited=False;
  AboutHelpTxt='Build '+BuildDate;
{$else}
  TimeLimited=True;
  AboutHelpTxt='TIMELIMITED TEST VERSION. May not be sold given away or otherwise send to others. '+
               'Program will expire Nov-1, 2002.';                        //<<<<<<
{$endif}
  HSVersionDate = HSVersion+' '+BuildDate;
{$DESCRIPTION 'HSPascal Build #33 (Version 2.0)'}

  //Testing of ifdef's
  {$ifdef VersionUI}  VersionIsUI=True;  {$Endif}
  {$ifdef VersionCMD} VersionIsUI=False; {$Endif}
  VersionIsCMD= not VersionIsUI; //Check ifdef's
  FullVersion=not TimeLimited;   //Check ifdef's

(***************************************************************
  U0   Global
  U1   Scanner
  U1b  CodeDag
  U2   SysTable
  U3   SysDefault
  U4   Main
  U5   Expr
  U5b  Asm
  U6   Stmt
  U7   Declare
***************************************************************)

procedure InitCompiler;
procedure DeInitCompiler;
Procedure SetMaxString(MaxIndex: Integer);

{***** Max Globals *************************************************************}
Const
  MaxScope      =  120;         {Signed byte}
  MaxSysHook    =   70;
  MaxDataGrp    =  255;         {Max 255, In a byte}
  MaxCodeGrp    = 1000;         {??}
  MaxSym        = 3000{32000};  {32KWord = 64KByte}
  MaxSysProc    = 100;          {Indirect for SysProc to pSymRec}

  MaxInt16  = High(SmallInt);
  MaxInt32  = High(LongInt);
  LastHSSys ='5';               {HSSys1..HSSysNN}

  HSPasLibZip='HSPasLib.zip';   //Library
  MaxBufPos: Integer=0;         //Debug. SizeOf(Global2.Buffer) //Max uses 10-2-2001 = 16000!
  PalmVersions: Array[1..5] of String=('PalmVer30','PalmVer31','PalmVer33','PalmVer35','PalmVer40');

Type
  ECompException = class(Exception)
    rc: Integer;
  end;

Type
  UICallBack= Function(S: String): Boolean;
Var
  UIIntf: Record
    Src: String;
    InitSearch: String;
    InitXXX: String;
    ErrNo: Integer;
    ErrStr: String;
    ErrFile: String;
    ErrLine,ErrPos,ErrLen: Integer;
    ErrLineStr: String;
    TotLinesCompiled: Integer;
    CallBack: UICallBack;
    //  SearchPath, ProgOptions, xxxx
  End;
  CurProcName, CurProcNameCase: String;

Type
  tCmpWhat=(CmpUnit,CmpProgram,CmpLibrary);
  tDoVar=(dvGlobal,dvLocal,dvRecord,dvPHead);
Const
  IncVars: Set of tDoVar=[{dvGlobal,}dvRecord];
  DbgDoVar: Array[tDoVar] of Char=('G','L','R','H'); //as shown in "V" records
var
  NextRsrcLocated: Integer;
var
  CurAddrTemp: Integer;         //Current max for a Proc
  MaxAddrTemp: Integer;         //MAX usage for a Proc
  CP: String;                   //CurProcName for debugging
  TestMode: Boolean;
  DoingMain: Boolean;           //??? ikke for god
  IsMainMod: Boolean;           //for Debug
  MakeHelpName: String;

Type
  TRef= Record FixUsed,PCRel: Boolean; Where,UNo,GrpInx{,Ofs}: SmallInt end;  //What:(cCode,cData,cProc);
  CodeWordArray = Array of Word;
  TRefArray = Array of TRef;

Type
  tDag0 = TObject;

  eScopeKind = (skNone,skProgram,skUnit,skFunction,skProcedure,
                   skWith,skRecord,skObject,skResWords);
  //pSymArr=^tSymArr;
  //tSymArr=array[0..MaxSym] of word;   {64KByte}
  TScope=Class
    Name:       String;
    Table:      TStringList;
    //TablePriv:  TStringList;
    LinkSameScope: TScope;
    LinkPrivateScope: TScope; //?? Not used yet
    //WithCode:   tDag0;
    SKind:      eScopeKind;
    Constructor Create(aKind: eScopeKind);
    Destructor  Destroy; Override;
  end;

Type
  UsesStr       = String[15];
  Str63         = String[63];
  Char4         = Packed array[1..4] of Char;
  Str6          = String[6];
  Str255        = String[255];

{ File types Unit, Obj, Include }
Type
  eUses=(eUUnit,eUOBJ,eUInclude);

Var
  ResWords: TScope;
  GlbUnits: TStringList; //Name, Object=Unit
  SearchPaths: TStringList; //Name
  HSPascalLibCache: TStringList; //Name, Object=ZLib Packed code
  HSPascalLibCacheS: Array of String;
  DummyWithCode: tDag0;
  MakeHelpTxt: TStringList;

Const // SYSPROC #'s
  ISysInit        = 01;
  ISysTerm        = 02;
  ISysHalt        = 03;
  PSysMemInit     = 04;
  PSysMemGet      = 05;
  PSysMemFree     = 06;
  FSysMemAvail    = 07;
  FSysMemMaxAvail = 08;
  ISysOptStack    = 09;
  ISysOptRangeL   = 10;
  ISysOptRangeW   = 11;
  PSysRandomize   = 12;

  PSysMove        = 15;
  PSysFillChar    = 16;
  PSysCase        = 17;
  PSysPCopy       = 18;

  ISysStrLd       = 20; //Str to Str
  ISysStrSto      = 21; //Str to Str, Len
  //ISysStrLdChar   = 22; //Pack to Str, Len
  ISysStrCmp      = 23; //Str,Str => CCR
  ISysStrAdd      = 24; //Str:+Str
  FSysStrCopy     = 25;
  FSysStrPos      = 26;
  PSysStrIns      = 27;
  PSysStrDel      = 28;
  FSysUpCase      = 29;
  FSysStrLen      = 30;

  PSysValI        = 35;
  PSysValR        = 36;
  ISysStringI     = 37;
  ISysStringR     = 38;

  ISysSetLd       = 40;
  ISysSetLdZero   = 41;
  ISysSetAdd1     = 42;
  ISysSetAddN     = 43;
  ISysSetSto      = 44;
  ISysSetIn       = 45;
  ISysSetEQ       = 46;
  ISysSetGE       = 47;
  ISysSetLE       = 48;
  ISysSetUnion    = 49;
  ISysSetDiff     = 50;
  ISysSetInter    = 51;

  ISys32Mul       = 60;
  ISys32Sqr       = 61;
  ISys32Div       = 62;
  ISys32Mod       = 63;

  FSysAbs16       = 64;
  FSysAbs32       = 65;

  FSysNegR        = 70; //Real:= -Real;
  FSysAbsR        = 71; //Abs(Real): Real;
  FSysTrunc       = 72; //Trunc(Real): Longint;
  FSysInt         = 73; //Int(Real): Real;
  FSysRound       = 74; //Round(Real); Longint;
  FSysArcTan      = 75; //ArcTan(Real): Real;
  FSysSqr         = 76; //Sqr(Real): Real;
  FSysSqrt        = 77; //Sqrt(Real): Real;
  FSysSin         = 78; //Sin(Real): Real;
  FSysCos         = 79; //Cos(Real): Real;
  FSysLN          = 80; //Ln(Real): Real;
  FSysExp         = 81; //Exp(Real): Real;
  FSysRandomI     = 82; //Random(Integer): Integer;
  FSysRandomR     = 83; //Random: Real;  //Special, no SyDefault

  FRealLoadI      = 84;
  FRealAdd        = 85;
  FRealSub        = 86;
  FRealMul        = 87;
  FRealDiv        = 88;
  FRealCmp        = 89;

  //Special 100..199
  PSysNew      = PSysMemGet+100;      //Same proc as GetMem(P,nn);
  PSysDispose  = PSysMemFree+100;     //Same proc as FreeMem(P,nn);

  //Special 200..255   Most Integer versions without proc's
  FSysPtr      = 202;
  FSysOdd      = 203;
  FSysAddr     = 204;
  FSysSizeOf   = 205;
  FSysChr      = 206;
  FSysOrd      = 207;
  FSysLo       = 209;
  ISysInc      = 210;
  ISysDec      = 211;
  FSysSucc     = 212;
  FSysPred     = 213;
  PSysExit     = 214;

{***** Scanner *****************************************************************}

{ Basic symbol types }
Type
  eSign=(SignNone,SignMinus,SignPlus);

  eSym=(
    SNONE,      {Unknown. Are used}
    SBAD1,      {Another bad. Returned as Ok from LongJmp}

    SAND,       {AND}                           {KEEP sequence of SAND..SLES!}
    SDIV,       {DIV}                           {}
    SMOD,       {MOD}                           {}
    SOR,       {OR}                            {}
    SSHL,       {SHL}                           {}
    SSHR,       {SHR}                           {}
    SXOR,       {XOR}                           {}
    SPLS,       {Plus '+'}                      {}
    SMIN,       {Minus '-'}                     {}
    SAST,       {Asterisk '*'}                  {}
    SSLA,       {Slash '/'}                     {}
    SEQS,       {Equal sign '='}                {}
    SNES,       {Not equal sign '<>'}           {}
    SGTS,       {Greater than sign '>'}         {}
    SLTS,       {Less than sign '<'}            {}
    SGES,       {Greater or equal sign '>='}    {}
    SLES,       {Less or equal sign '<='}       {KEEP sequence of SAND..SLES!}

    SIN,        {IN}
    SNOT,       {NOT}

    SLPA,       {Left parentheses '('}
    SRPA,       {Right parentheses ')'}
    SLBR,       {Left bracket '['}
    SRBR,       {Right bracket ']'}
    SPER,       {Period '.'}
    SCOM,       {Comma ','}
    SCOL,       {Colon ':'}
    SSEM,       {Semicolon ';'}
    SCAR,       {Caret '^'}
    SCEQ,       {Colon equal ':='}
    SDPE,       {Double period '..'}
    SCAT,       {Commercial at '@'}
    SIDN,       {Identifier}
    SICO,       {Integer constant}
    SRCO,       {Real constant}
    SCCO,       {Character constant}
    SSCO,       {String constant}
    SESC,       {Esclamation '!'}
    SNUM,       {Number sign '#'}
    SABS,       {ABSOLUTE}       {Reserved words}
    SARY,       {ARRAY}
    SBGN,       {BEGIN}              {34}
    SCAS,       {CASE}
    SDO,        {DO}
    SDTO,       {DOWNTO}
    SELS,       {ELSE}
    SEND,       {END}
    {SEXT,      {EXTERNAL}
    //SFIL,     {FILE}
    SFOR,       {FOR}
    SFWD,       {FORWARD}
    STRP,       {SYSTRAP}
    CDECL,      {CDECL}
    SFUN,       {FUNCTION}
    SGTO,       {GOTO}
    SIF,        {IF}
    SIMP,       {IMPLEMENTATION}
    SINL,       {INLINE}
    SINF,       {INTERFACE}
    SLBL,       {LABEL}
    SNIL,       {NIL}
    SOF,        {OF}
    SPAC,       {PACKED}
    SPRO,       {PROCEDURE}
    SPGM,       {PROGRAM}
    SREC,       {RECORD}
    SOBJ,       {OBJECT}
    SPRIVATE,
    SPUBLIC,
    SDESTRUCTOR,
    SCONSTRUCTOR,
    SVIRTUAL,

    SREP,       {REPEAT}
    SRSRC,      {RESOURCE}
    SSET,       {SET}
    SSTR,       {STRING}
    STHN,       {THEN}
    STO,        {TO}
    SUNI,       {UNIT}
    SUNT,       {UNTIL}
    SUSE,       {USES}
    SVAR,       {VAR}
    SWHL,       {WHILE}
    SWTH,       {WITH}
    SASM,       {ASM block}
    SASSEM,     {ASSEMBLER directive}
    SNOA6FRAME, {no A6 link}
    SDIRSYS,    {SysProc, Do NOT make CLR -(SP) before function call}
    SPRC,       {'%'}
    SEOLN,      {EOLN for assembler}

    {Symbols also used in RY.A}

    SSTP,       {Standard procedure}
    SSTF,       {Standard function}
    SCON,       {CONST}
    STYP,       {TYPE}
    STYPP,       {Type reference}

    SEXIT,      {EXIT}
    SCONT,      {CONTINUE}
    SBREAK      {BREAK}
  );

Type
  tNext= Record
    Ch:         eSym;
    IdnBuf:     Str63;
    IValue:     Integer;
    RValue:     Extended;
    SValue:     Str255;
    IdnBufCase: Str63;
  end;

{ Data types }
Type
  eType=(
  TNON,   {Untyped }
  TARY,   {Array }
  TREC,   {Record }
  TOBJ,   {Object }
  TPRO,   {Procedure }
  //TFIL, {Typed file }
  //TTXT, {Text file }
  TSET,   {Set }
  TPAC,   {Packed array of char ?? Use TSTR only??}
  TPTR,   {Pointer }
  TSTR,   {String }
  TREA,   {Real }
  TINT,   {Integer }
  TBOL,   {Boolean }
  TCHR,   {Char }
  TUSR);  {User defined scalar's like 22..33 or (red,green,blue)}
Const eSimpType= [TREA..TUSR];
Const TypeVisible: Array[eType] of String[3]=  //as shown in "T" records
  ('---','Ary','Rec','Obj','Pro','Set','Pac','Ptr','Str','Rea','Int','Bol','Chr','Usr');

Type
  TypPtr=^tType; //Record BackLink: Integer; Offset: Integer End;
  tType=Record
    TTYPE:    eType;            {Data type             }
    TSIZE:    Integer;          {Size in bytes         }
    TPACF:    TypPtr;           {If packed             }
    {{TIDXF:  Byte;             {Array index flags     }
    {{TF1:    Byte;             {Filler!!!!!!!}
    TDbgNo:   Integer;          {<0 = $Y dumped        }
    TDbgName: String[8];
    TBASE:    TypPtr;           {Base type (also if Packed) }
    Case Integer of
    0: (TMINV,
        TMAXV:   Longint);      {Min/Max value         }
    1: (TELEP,                  {Element type pointer  }
        TIDXP:   TypPtr;        {Index type pointer    }
        TSCOP:   TScope);       {Scope for Obj, Rec,.. }
    2: (xFpTyp:  Integer);      {Subtype               }
    3: (TELEPx:  TypPtr;        {Same as TELEP!!       }
        TMSIZ:   Integer;       {Object methodes       }
        TMOFS:   Integer);
  End;

Const
  SetSimType:   Set of eType=[TINT,TBOL,TCHR,TUSR];
  SetSimTypeINC:Set of eType=[TPTR,TINT,TBOL,TCHR,TUSR];
  FuncType:     Set of eType=[TPTR,TSTR,TREA,TINT,TBOL,TCHR,TUSR];
  GlbEmptySet:  tType=(TTYPE: TSET); {Used for T<>@GlbEmptySet }
  MaxStringM1:  Integer=0; //Default size and worksize of Strings (normally 63)
Type
  BinOpTyp = TSET..TUSR;
Const
  ValidBinOpTyp = [TSET..TUSR];


Const
  IDChars:   Set of Char = ['@','a'..'z','A'..'Z','0'..'9','_'];
  {Digits:   Set of Char = ['0'..'9']; {}
  HexDigits: Set of Char = ['0'..'9','a'..'f','A'..'F'];

  FP_SizeSingle = 4;

{ Standard types }
Type
  eResType=(
    xSmall,  //Integer
    xLON,    //Longint
    xCHR,    //Char
    xBOL,    //Boolean
    xSTR,    //String
    xSNG,    //Real Single
    //xUNP,    //Unpacked
    xPTR,    //Pointer
    xINTwrk, //
    xPAC,    //Packed array[] of Char   TMINV, TMAXV, TSIZE
    xTiny,   //ShortInt(TinyInt)   UNUSED!!!
    xUNT,    // for Procedure(var XX);
    xBYT,    //Byte
    xTmpSet  //
  );
Const
  xINT = xSmall;  //Integer = 16Bit

Const {NONONO: ONLY TBASE & TELEP has fixup in init code!!}
  StandardType: array[eResType] of tType=(
    //SmallInt 16bit
    (TTYPE:TINT; TSIZE:2; TPACF:nil; TDbgNo:1; TDbgName:'Integer';
      TBASE: @StandardType[xLON];
      TMINV:-MaxInt16-1; TMAXV:MaxInt16),

    //Longint 32bit
    (TTYPE:TINT; TSIZE:4; TPACF:nil; TDbgNo:2; TDbgName:'Longint';
      TBASE: @StandardType[xLON]; TMINV:-MaxInt32-1; TMAXV:MaxInt32),

    //Char
    (TTYPE:TCHR; TSIZE:1; TPACF:nil; TDbgNo:3; TDbgName:'Char';
      {TBASE= ^Packed version}
    //    (TTYPE:TCHR; TSIZE:1; TPACF:nil; {TBASE= ^Packed version}
      TBASE: @StandardType[xCHR]; TMINV:0; TMAXV:255),

    //Boolean
    (TTYPE:TBOL; TSIZE:1; TPACF:nil; TDbgNo:4; TDbgName:'Boolean';
      TBASE: @StandardType[xBOL]; TMINV:0; TMAXV:1),

    //String
    (TTYPE:TSTR; TSIZE:256; TPACF:nil; TDbgNo:5; TDbgName:'String';
      TBASE: @StandardType[xSTR]; TMINV:1; TMAXV:999),  //MaxStringM1 normally 63

    //Real Single
    (TTYPE:TREA; TSIZE:FP_SizeSingle; TPACF:nil; TDbgNo:6; TDbgName:'Real';
      TBASE: @StandardType[xSNG]; xFpTyp: 00),

    //UNP
    //(TTYPE:TNON; TSIZE:0; TPACF:nil; TBASE: @StandardType[xUNP]),
    //Pointer xPTR
    (TTYPE:TPTR; TSIZE:4; TPACF:nil; TDbgNo:7; TDbgName:'Pointer';
      TBASE: @StandardType[xPTR];
      TELEP: @StandardType[xUNT]),

    //xINTwrk?
    (TTYPE:TINT; TSIZE:2; TPACF:nil; TDbgNo:8; TDbgName:'Int2';
      TBASE: @StandardType[xLON]; TMINV:-MaxInt16-1; TMAXV:MaxInt16),

    //PAC
    (TTYPE:TPAC; TSIZE:1; TPACF:nil; TDbgNo:9; TDbgName:'Int1';
      TBASE: @StandardType[xPAC]; TMINV:0; TMAXV:0),

    (***
    //String[1] for CHAR to STRING cvt
    (TTYPE:TSTR; TSIZE:2; TPACF:nil;
      TBASE: @StandardType[xSTR]; TMINV:0; TMAXV:1),

    //String[2] for CHAR to STRING cvt
    (TTYPE:TSTR; TSIZE:4; TPACF:nil;
      TBASE: @StandardType[xSTR]; TMINV:0; TMAXV:2),

    //String[3] for CHAR to STRING cvt
    (TTYPE:TSTR; TSIZE:4; TPACF:nil;
      TBASE: @StandardType[xSTR]; TMINV:0; TMAXV:3),
    (*******)

    //ShortInt(TinyInt)
    (TTYPE:TINT; TSIZE:1; TPACF:nil; TDbgNo:10; TDbgName:'Shortint';
      TBASE: @StandardType[xLON]; TMINV:-128; TMAXV:127),

    //(TTYPE:TPTR; TSIZE:FIBSIZX; TPACF:nil; TBASE: @StandardType[xFILEU]; TELEP: @StandardType[xTiny]),
    //Untyped {Untyped for Pointer, Ptr}
    (TTYPE:TNON; TSIZE:0; TPACF:nil; TDbgNo:11; TDbgName:'Ptr';
     TBASE: @StandardType[xUNT]; TMINV:0; TMAXV:0),

    //Byte = PACKED 0..255
    (TTYPE:TINT; TSIZE:1; TPACF:nil; TDbgNo:12; TDbgName:'Byte';
      TBASE: @StandardType[xLON]; TMINV:0; TMAXV:255),

    //xTmpSet, TELEM=xByt 0..255
    (TTYPE:TSET; TSIZE:32; TPACF:nil; TDbgNo:13; TDbgName:'TempSet';
      TBASE: @StandardType[xLON]; TELEP: @StandardType[xBYT])
  );

{***** Scope *******************************************************************}
Type
  ePFLAG        = (PDnormal,PDdefined,PDdoingDef,
                   PDasm, //ASM
                   PDNoA6Frame,
                   PDconstructor,PDdestructor,PDvirtual,Pdmethod,
                   PDforward,{PDinline,}PDsystrap,PDcdecl,PDSysProc{,PDextrn});
  sPFLAG        = set of ePFLAG;

Type
  eVarF=        (vfXXX,vfGlobal,vfLocal,
                 vfDeref,      //
                 vfVar,        //Real "VAR"
                 vfVarConst,   //Real "CONST"
                 vfVarCopy,    //Psudo Var, if struct.size>4
                 vfPCRel);

Type
  pSymRec=^tSymRec;
  tSymRec= Record
    Filler:     Byte;           {eSym are in a BYTE!}
    Case What: eSym of
    SLBL:(
      LSLEV:    Byte;
      LNLEV:    Byte;
      LDEFI:    Boolean;
      LADDR:    tDag0;
      SLBLlast: Byte);
    SVAR: (                     {Variable data layout  }
      VSLEV:    Byte;           {Static level          }
      VVARF:    eVarF;          {VAR flag              }
      VADDR:    Longint;        {Address (=PZERO)      }
      VTYPP:    TypPtr;         {Type pointer          }
      //VHASH:  Integer;        {Index to Vars[0..255] }
      DbgName:  String[15];     {ODD !!! Maybe String, and then very shortly until address assigned}
      SVARlast: Byte);
    STYPP: (                    {Type reference}
      TTYPP:    TypPtr;
      STYPPlast: Byte);
    SFUN,
    SPRO: (
      PSLEV:    Byte;           {Static level                     }
      PVARF:    eVarF;          {Result VAR flag, if > 4 bytes    }
      PZERO:    Integer;        {=0 (.LongWord for VADDR equ?????????)       }
      PPARS:    Integer;        {Parameters size (above A6) (to remove from stack) }
      PUSTK:    Integer;        {Unstack size (=offset to result) }
      XUNSTK:   Integer;        {0 or 4. Éxtra stack to unstack   }
      PTYPP:    TypPtr;         {Result type pointer              }
      PHASH:    Integer;        {Same as VHASH                    }
      PFLAG:    sPFLAG;         {OBJECT,ASSEMBLER,XASSEMBLER...   }
      PFUNO:    Integer;        {SysTrap/SysProc no highword=moveq d2,(xx-1) if>0}
      PRef:     TRef;           {Ref to this proc                 }
      PPARC:    Integer;        {Parameter count                  }
      PSCOP:    TScope;         {Scope                            }
      PMOFS:    Integer;        {Methode                          }
      UsageA6:  Integer;        {Negative                         }
      TDbgProcNo: Integer;      {}
      PCpyParmCnt: SmallInt;
      PCpyParm: Array[1..10] of Record Above,Below,Size: SmallInt end;
      SPROlast: Byte;           {Also position of first param!    }
      );
    SSTP: (ProcNo: Byte;
           SSTPlast: Byte);       {Label}
    SSTF: (FuncNo: Byte;
           SSTFlast: Byte);       {Label}
    SCON: (
      CTYPP:       TypPtr;
      case eType of
      TINT: (CIVAL: Longint;  CIlast: byte); //& TUSR
      TREA: (CRVAL: Extended; CRlast: byte);
      TSTR: (CSVAL: ShortString    {Last: Use CSVAL[Length+1]});
    );
    (** STYP: ( {Type record} TTYP: tType); **)
    End;

Var
  Glb: Record
    GlobalCodeSizeB: Integer;   //Incremented for each proc used in StripCode
    UsageA5: Integer;           //A5Offset
    MapProcNo: Integer;
    RecDefNo: Integer;          //For mapfile
    TDbgNoSym: Integer;
    TDbgProcNo: Integer;
    AnyMappedD: Boolean;        //Set on first occurence of $D info (ProcAddresses)
    AnyMappedL: Boolean;        //Set on first occurence of $L info (line, stepping)
    AnyMappedY: Boolean;        //Set on first occurence of $Y info (symbols)
    MapProcList: Array of record Name: String; TDbgProcNo: Integer; Mapped: Boolean end;
    MapFileList: Array of record Name: String end;
    TestMapFile: TStringList;
    SysProc: Array[0..MaxSysProc] of pSymRec;
    //TestPtr: ^Pointer;            //for Debug
  end;

Type
  eCondJumps = //68K Version!!!!  //Assem, Bcc, Scc OpCode
  (CondT,CondF,CondHI,CondLS,CondCC,CondCS,CondNE,CondEQ, //m68k 0..7
   CondVC,CondVS,CondPL,CondMI,                           //m68k 8..11
   CondGE,CondLT,CondGT,CondLE,                           //m68k 12..15
   CondNONE
   );
Const
   CondLO=CondCS;
   CondHS=CondCC;
Const
  //CondNoDirection: Set of eCondJumps=[CondNE,CondEQ];
  CondSwapJmp: Array[eCondJumps] of eCondJumps=(
    CondF,CondT,CondLS,CondHI,CondCS,CondCC,CondEQ,CondNE,
    CondVS,CondVC,CondMI,CondPL,
    CondLT,CondGE,CondLE,CondGT,CondNONE);
  CondSwapCnd: Array[eCondJumps] of eCondJumps=(
    CondF,CondT,CondLO,CondHS,CondCS,CondCC,CondEQ,CondNE,
    CondVS,CondVC,CondMI,CondPL, //??
    CondLE,CondGT,CondLT,CondGE,CondNONE);
  mk68cc: array[eCondJumps] of Byte = (0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15, 0);

Const
  sysDbgBreakpointTrapNum = 0;  // For soft breakpoints
  sysDbgTrapNum = 8;            // For compiled breakpoints
  sysDispatchTrapNum = 15;      // Trap dispatcher

Function SymRecSize(S: tSymRec): Integer;

Type
  eAccumulateAllUnits = (eTotalCodeUsedW);

//Var SptrLow: Integer;

Type
  cdCompDir=(cdNONE,
             cdD,          // +/- Debug
             cdL,          // +/- Line information
             cdS,          // +/-
             cdO,          // +/- Optimizer
             cdR,          // +/- RangeCheck / Resource
             cdT,          // +/- Typed @ operator
             cdY,          // +/- Symbol dump
             cdEXECUTE,    // Execute something with parameters
             cdDEFINE,
             cdELSE,
             cdENDIF,
             cdI,          //Include
             cdIFDEF,
             cdIFNDEF,
             cdIFOPT,
             cdUNDEF,
             cdSetDEFAULT,
             cdV,          // +/- var strings
             //cdF,          // +/-
             cdM,          //Memory (Stack)
             //cdW,          //Stack frames
             //cdQ         //Overflow check
             //cdB         //Complete boolean
             cdSrchPath,   //File search path
             cdAppNameType,
             cdMaxString,  //Default 100 bytes
             cdMakeHelp
             );
  TDirSet = Set of cdCompDir;
Const
  DerDefault: TDirSet = [cdR]; //Initial values
  DirOnOff: TDirSet = [cdD,cdL,cdS,cdO,cdR,cdT,cdY,cdMakeHelp]; //Possible +/- options
  DirTable: Array[cdCompDir] of String=('@£$',
        'D','L','S','O','R','T','Y','EXECUTE','DEFINE','ELSE','ENDIF','I','IFDEF','IFNDEF','IFOPT',
        'UNDEF','SETDEFAULT',
        'V','M','SEARCHPATH','APPLNAME','MAXSTRING','MAKEHELP'); //MaxStringM1
Type
  TOptions = Class
    OptionsDefined: TStringList;
    OutputPath: String;        //GLOBAL ONLY.
    Active: Set of cdCompDir;
    ApplName,ApplID: String;   //GLOBAL ONLY. From scanner used in Rsrc SaveFile
    Constructor Create;
    Destructor Destroy; Override;
    procedure Assign(Const From: TOptions);
    function ScanCondSym(Const S: String): Boolean;
    Procedure DefCondSymb(Const S: String; Recursive: Boolean=True);
    Procedure ClrCondSymb(Const S: String);
  end;

Var
  OptionsGlobal: TOptions;
  Verbose: Boolean; // HSPC -V = verbose

Implementation

Uses Misc;

Constructor TScope.Create(aKind: eScopeKind);
begin
  Table:= TStringList.Create;
  Table.Sorted:=True;
  Table.Duplicates:=dupError;
  SKind:=aKind;
end;

Destructor TScope.Destroy;
begin
  Table.Free;
  inherited
end;

Function SymRecSize(S: tSymRec): Integer;
begin
  Result:=0;
  case S.What of
  SLBL:  Result:=Integer(@S.SLBLlast)-Integer(@S);
  SVAR:  Result:=Integer(@S.SVARlast)-Integer(@S);
  STYPP: Result:=Integer(@S.STYPPlast)-Integer(@S);
  SCONSTRUCTOR,
  SDESTRUCTOR,
  SFUN,
  SPRO:  Result:=Integer(@S.SPROlast)-Integer(@S);
  SSTP:  Result:=Integer(@S.SSTPlast)-Integer(@S);
  SSTF:  Result:=Integer(@S.SSTFlast)-Integer(@S);
  SCON:  Case S.CTYPP^.TTYPE of
         TINT..TUSR,
         TPTR: Result:=Integer(@S.CIlast)-Integer(@S);
         TREA: Result:=Integer(@S.CRlast)-Integer(@S);
         //TSTR,
         TPAC: Result:=Integer(@S.CSVAL[0])-Integer(@S)+1+Length(S.CSVAL);
         else  InternalError('SymRecSize1');
         end;
  else   InternalError('SymRecSize2');
  end;
end;

constructor TOptions.Create;
begin
  inherited;
  OptionsDefined:=TStringList.Create;
  OptionsDefined.Add('HSPASCAL');
  OptionsDefined.Add('68000');
  OptionsDefined.Add('VER20');
end;
Destructor TOptions. Destroy;
begin
  OptionsDefined.Free;
  inherited;
end;
procedure TOptions.Assign(Const From: TOptions);
begin
  inherited;
  Active:=From.Active;
  OutputPath:=From.OutputPath;
  OptionsDefined.Assign(From.OptionsDefined);
end;
function TOptions.ScanCondSym(Const S: String): Boolean;
begin
  Result:=OptionsDefined.IndexOf(S)>=0;
end;
Procedure TOptions.DefCondSymb(Const S: String; Recursive: Boolean=True);
var N: Integer;
begin
  if NOT ScanCondSym(S) then begin
    OptionsDefined.Add(S);
    if Recursive then
      for N:=Low(PalmVersions)+1 to High(PalmVersions) do
        if CmpStr(PalmVersions[N],S) then
          DefCondSymb(PalmVersions[N-1]);
  end;
end;
Procedure TOptions.ClrCondSymb(Const S: String);
var N: Integer;
begin
  if ScanCondSym(S) then begin
    OptionsDefined.Delete(OptionsDefined.IndexOf(S));
    for N:=Low(PalmVersions)+1 to High(PalmVersions) do
      if CmpStr(PalmVersions[N],S) then
        ClrCondSymb(PalmVersions[N-1]);
  end;
end;

procedure InitCompiler;
var N: eResType;
begin
  {$ifdef VersionUI}  if not SkipDebug then FormDebug.Memo1.Lines.BeginUpdate;   {$Endif}
  UIIntf.TotLinesCompiled:=0;
  Glb.MapProcList:=NIL;
  Glb.MapFileList:=NIL;
  Glb.TestMapFile.Free;
  FillChar(Glb,SizeOf(Glb),0);
  Glb.TDbgNoSym:=20;
  SetLength(Glb.MapFileList,1); //#0 unused
  Glb.TestMapFile:=TStringList.Create;
  Glb.TestMapFile.Add(';HSPascal map file');
  Glb.TestMapFile.Add(';F File directory        F ; File# ; FileName');
  Glb.TestMapFile.Add(';P Procedure list        P ; ProcNo ; ProcName');
  Glb.TestMapFile.Add(';L Source lines:         L ; File# ; Line# ; Proc# ; RelCodeAddrHex');
  Glb.TestMapFile.Add(';A Procedure addresses   A ; Proc# ; AbsStartHex ; LenHex');
  Glb.TestMapFile.Add(';V Variable              V ; Name ; Offset ; ProcNo ; Level ; TypCh? ; Type# ; Rec#');
  Glb.TestMapFile.Add(';T Type                  T ; T# ; Name ; Typ ; Size ; Base ; Min ; Max ; Element ; Index ; Rec#');
  //Glb.UsageA5:=0;
  //Glb.GlobalCodeSizeB:=0;
  SetMaxString(63);
  for n:=Low(eResType) to High(eResType) do
    with StandardType[n] do begin
      TDbgNo:=Abs(TDbgNo);
      if FALSE THEN //!!!!!!!!!!!!!
      if TELEP=NIL then
        if TMINV+TMAXV=0 then
          TELEP:=@StandardType[xUNT];
    end;
  MakeHelpTxt.Clear;
end;
procedure DeInitCompiler;
begin
  {$ifdef VersionUI}  if not SkipDebug then FormDebug.Memo1.Lines.EndUpdate;   {$Endif}
end;

procedure GlbInit;
begin
  MakeHelpTxt:=TStringList.Create;
  MakeHelpName:=ExtractFilePath(ParamStr(0))+'HSHelp.txt';
  SearchPaths:=TStringList.Create;
  OptionsGlobal:=TOptions.Create;
  //SptrLow:= SPtr-100000;
  /////InitCompiler;
end;

Procedure SetMaxString(MaxIndex: Integer);
begin
  MaxStringM1:=MaxIndex;
  with StandardType[xSTR] do begin
    TSIZE:=MaxIndex+1;
    TMAXV:=MaxIndex+1;
  end;
end;

initialization
  GlbInit;
finalization
  SearchPaths.Free;
  OptionsGlobal.OptionsDefined.Free;
end.

