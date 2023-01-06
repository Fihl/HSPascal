unit Dag;
{$H-}
interface

Uses Global, Global2, Misc;

{Global ********************************************************************}
Type eSubMonOPs = (opNEG,opNOT,opORD);
//Type eSubCase	= (CaseStart,CaseSingle,CaseDouble,CaseElse,CaseEnd);
Type eSubFor	= (ForInc,ForDec);
Type eSubSet	= (SetStart,SetItems);

Const
  OpcBSR  = $6100;
  OpcBRA  = $6000;
  OpcDBRA = $50C0;
  //OpcDBRA = $51C8;      //+Dn
  OpcRTS  = $4E75;
  opcBNE  = $6600;      //BNE.W xx
  opcMOVEQ0D0 = $7000; //MoveQ #0,D0

(*REGS*************************)
Type
  eReg		= (rNONE,rUNDEF,			{rUNDEF for tEA use}
   		   rD0,rD1,rD2,rD3,rD4,rD5,rD6,rD7,
		   rA0,rA1,rA2,rA3,rA4,rA5,rA6,rA7);
  tRegSet	= Set of eReg;
Const
  RegFirst	= rD0;
  RegLast	= rA7;
  RegFirstDn    = rD0;
  RegFirstAn    = rA0;

  //RegA_Self     = rA4;
  RegA_Global   = rA5;
  RegA_Local    = rA6;
  RegA_SP       = rA7;

  RegsValid:    tRegSet= [rD0..rD7,rA0..rA7];
  RegsData:     tRegSet= [rD0..rD7];
  RegsAddr:     tRegSet= [rA0..rA5];
  RegsWith:     tRegSet= [rA2..rA4];
  RegsScratch:  tRegSet= [rD0..rD2,rA0,rA1{,rF0..rF2}];
  RegsWorkDn:   tRegSet= [rD0..rD7];
  RegsWorkAn:   tRegSet= [rA0..rA1];
  RegsBind:     tRegSet= [rD0..rD7,rA0..rA1]; //=Data+WorkAn (-With)
  RegsNoMOVEM:  tRegSet = [rD0..rD2,rA0,rA1,rA5..rA7];
  RegNames:     Array[eReg] of String=('','',
   		   'D0','D1','D2','D3','D4','D5','D6','D7',
		   'A0','A1','A2','A3','A4','A5','A6','A7');
Var
  RegsIdx	: tRegSet absolute RegsData;	{Used for Dn in dd(An,Dn)}

{***** Registers ***************************************************************}

Const
  MaxVars=	255;
  MaxTemps=	20;
Type
  sVars=	0..MaxVars;
  sTemps=	0..MaxTemps;

(*VARS*************************)
Type
  eVarDesc=
    Record
      vdSym:	pSymRec;
      dag:	tDag0;
      {{ UseCnt,UsedCnt: Integer; {}
      {{ FirstU, LastU:	tDag1; {}
    End;
Var
  Vars: Record
    Unsaved:	set of sVars;
    Cnt:	sVars;
    Vars:	array[sVars] of eVarDesc;
  End;

(*TEMPS************************)
Type
  eTempDesc=
    Record
      dag:	tDag0;	 	{0=Unused}
      Adr,Size:	Integer;
    End;
Var
  Temps: Record
    Cnt:	sTemps;
    Temps:	array[sTemps] of eTempDesc;
  End;

Type eP=(pcBad,
         pcVar,
         pcNewBB,
         pcBinOP, {eSubBinOPs}
         pcMonOP, {eSubMonOPs}
         pcPROCFUNC, {User proc/func}
         pcStaFUNC, {Standard eSubFunc}
         pcStaPROC, {Standard eSubPROC}
         pcFuncParm,  {PEA A6 relativ addr (variable)}
         pcCAST, {TypeCast}
         pcSTO,  {0=STO, 1=NO STO} {0=xx, 1=Are now in Vars[] table}
         pcSET,  {eSubSet=(SetStart,SetItems);}
         pcFOR,	 {eSubFor=(ForInc,ForDec);}
         pcWHILE,   // pcWHILE LBL1 BE STMT JMP LBL2
         pcREPEAT,  // pcREPEAT LBL STMT JMP
         pcIF,
         pcCASE, 
         pcJMP,	 {eSubJmp=(JMP,JMPF,LAB)}
         pcADDR,
         pcWITH,
         pcDEREF, {Pointer deref}
         pcOFFSET, {record offset}
         pcARRAY,
         pcConst,
         pcRawCode,
         pcMisc,
         pcEnter,
         pcFuncRes,
         pcLink			{Last!}
         );

Const
  OpCodes: Array[eP] of String=(
         'pcBad',
         'pcVar',
         'pcNewBB',
         'pcBinOP', {eSubBinOPs}
         'pcMonOP', {eSubMonOPs}
         'pcPROCFUNC', {User proc/func}
         'pcStaFUNC', {Standard eSubFunc}
         'pcStaPROC', {Standard eSubPROC}
         'pcFuncParm',  {PEA A6 relativ addr (variable)}
         'pcCAST', {TypeCast}
         'pcSTO',  {0=STO, 1=NO STO} {0=xx, 1=Are now in Vars[] table}
         'pcSET',  {eSubSet=(SetStart,SetItems);}
         'pcFOR',	 {eSubFor=(ForInc,ForDec);}
         'pcWHILE',   // pcWHILE LBL1 BE STMT JMP LBL2
         'pcREPEAT',  // pcREPEAT LBL STMT JMP
         'pcIF',
         'pcCASE',
         'pcJMP',	 {eSubJmp=(JMP,JMPF,LAB)}
         'pcADDR',
         'pcWITH',
         'pcDEREF', {Pointer deref}
         'pcOFFSET', {record offset}
         'pcARRAY',
         'pcConst',
         'pcRawCode',
         'pcMisc',
         'pcEnter',
         'pcFuncRes',
         'pcLink'	{Last!}
         );

Type  eSysProcType = (eProcUndef, eProc, ePasFunc, {Pascal Proc/Func}
                      eFuncD0, eFuncA0); ///, eFuncSP);

Type
  eCode=(codNONE,			{always check CodeReal}
         codEA,                         //Only code 0+EA_part
         codENTER,codLEAVE,codCALL,codRTS,codJMP,
         codMOVE,codLEA,codPEA,
         codEQ,codNE,codGT,codLT,codGE,codLE,
         codCMP,codADD,codSUB,codOR,codXOR,
         codEXT,codCLR,codTST,
         codNEG,codNOT,codSWAP,
         codMUL,codRDV,codDIV,codMOD,codAND,codSHL,codSHR);

Type
  eSubBinOPs = (op0,
                opSIN,
                opEQ,opNE,opGT,opLT,opGE,opLE,
                opCMP,opADD,opSUB,opOR,opXOR,
                opMUL,opRDV,opDIV,opMOD,opAND,opSHL,opSHR);
Const
  cRelOP=[opEQ..opLE];
Const
  BinCode: array[eSubBinOPs] of eCode = (
             codNONE,
             codNONE, //
             codNONE,codNONE,codNONE,codNONE,codNONE,codNONE,
             codCMP,codADD,codSUB,codOR,codXOR,
             codMUL,codRDV,codDIV,codDIV,codAND,codSHL,codSHR);
  ccCodes: array[eSubBinOPs] of eCondJumps = (
    CondNONE,CondNE,
    CondEQ,CondNE,CondGT,CondLT,CondGE,CondLE,
    CondEQ,CondNONE,CondNONE,CondNE,CondNE,
    CondNONE,CondNONE,CondNONE,CondNONE,CondNE,CondNONE,CondNONE);
  //opRDV & codRDV not 68k instruction!!

{***** EA **********************************************************************}
Type
  eEA=(
    {without displacement}
    EDREG,	{00	Dn}
    EAREG,	{08	An}
    EAIND,	{10	(An)}
    EAINC,	{18	(An)+}
    EADEC,	{20	-(An)}
    {with displacement}
    EADIS,	{28	disp(An)}
    EAIXw,	{30	disp(An,Xi.w)}		{Psudo}
    EAIXl,	{30	disp(An,Xi.l)}		{Psudo}
    //EABSW,	{38	Abs.W @@@}
    //EABSL,	{39	Abs.L}
    EPDIS,	{3A	disp(PC)}
    EIMED,	{3C	#data}
    {}
    ENONE	{--	NONE!!!}
  );
Type
  eEASize=	(easB,easW,easL,easNone);
Const
  K68Size: array[eEASize] of byte=(0,1,2,2); //easNone => easL !
  EASizeCvt4: array[0..4] of eEASize=(easNone,easB,easW,easNone,easL);
  SpaceUsedWork: array[eEASize] of byte=(1,2,4,4); //easNone => easL !
Type
  pEA = ^tEA;                           //Almost never used
  tEA= Record
    EAh:	eEA;			{EA mode}
    EAl:	eReg;
    EAi:	eReg;			{Index reg if any}
    EAofs:	Integer;		{EAi=rUNDEF=>Unused when in Address()}
    EASize:	eEASize;                {Still need size field}
    //EATempInx:  sTemps;
  End;
Const
  EA0:          tEA=(EAh: eNONE; EAl:rNONE;     EAi:rNONE; EAofs:0; EASize:easB); //; EATempInx:0);
  EA_none:      tEA=(EAh: ENONE; EAl:rNONE;     EAi:rNONE; EAofs: 0);
  EA_EnterLeave:tEA=(EAh: EAREG; EAl:rA6;       EAi:rNONE; EAofs: 0; EAsize: easW);
  EA_imm0:      tEA=(EAh: EIMED; EAl:rNONE;     EAi:rNONE; EAofs: 0);
  EA_imm1:      tEA=(EAh: EIMED; EAl:rNONE;     EAi:rNONE; EAofs: 1);
  EA_imm4:      tEA=(EAh: EIMED; EAl:rNONE;     EAi:rNONE; EAofs: 4);
  EA_imm255:    tEA=(EAh: EIMED; EAl:rNONE;     EAi:rNONE; EAofs: 255);
  EA_immWn:     tEA=(EAh: EIMED; EAl:rNONE;     EAi:rNONE; EAofs: 0; EASize: easW);
  EA_imm1L:     tEA=(EAh: EIMED; EAl:rNONE;     EAi:rNONE; EAofs: 1; EASize: easL);
  //EA_AMisc:     tEA=(EAh: EAREG; EAl:RegA_Misc; EAi:rNONE; EAofs: 0; EAsize: easW);
  EA_A6IND:     tEA=(EAh: EADIS; EAl:rA6;       EAi:rNONE; EAofs: 0);
  EA_Dn:        tEA=(EAh: EDREG; EAl:rNONE;     EAi:rNONE; EAofs: 0);
  EA_An:        tEA=(EAh: EAREG; EAl:rNONE;     EAi:rNONE; EAofs: 0; EAsize: easL);
  EA_A0:        tEA=(EAh: EAREG; EAl:rA0;       EAi:rNONE; EAofs: 0; EAsize: easL);
  EA_A1:        tEA=(EAh: EAREG; EAl:rA1;       EAi:rNONE; EAofs: 0; EAsize: easL);
  EA_A7:        tEA=(EAh: EAREG; EAl:rA7;       EAi:rNONE; EAofs: 0; EAsize: easL);
  //EA_Index:	tEA=(EAh: INDEX; EAl:rNONE;     EAi:rNONE; EAofs: 0);
  EA_D0:        tEA=(EAh: EDREG; EAl:rD0;       EAi:rNONE; EAofs: 0);
  EA_D0Byte:    tEA=(EAh: EDREG; EAl:rD0;       EAi:rNONE; EAofs: 0; EASize: easB);
  EA_A7PushNoS: tEA=(EAh: EADEC; EAl:rA7;       EAi:rNONE; EAofs: 0);
  EA_A7PushL:   tEA=(EAh: EADEC; EAl:rA7;       EAi:rNONE; EAofs: 0; EASize: easL);
  EA_A7PopL:    tEA=(EAh: EAINC; EAl:rA7;       EAi:rNONE; EAofs: 0; EASize: easL);
  EA_A7DISofs:  tEA=(EAh: EADIS; EAl:rA7;       EAi:rNONE; EAofs: 0);
  EA_JSRxxx:    tEA=(EAh: EPDIS; EAl:rNONE;     EAi:rNONE; EAofs: 0); //Call sysproc!

{***** Dag *********************************************************************}
Type
  tDag1 = Class;
  FixLocalArray= Array of Record Pos: Integer; Dag: tDag1 end;
  eKind=(kNone,kRef,kConst,kTmp,kRes,kCond); {ord(kNone)=0000!}
  //No kSTR !!!
  //kStk is kRes, where OpRec.aEA:=EA_A7Pop;
  tOpRec = Record
    aEA:	tEA;
    OTYPE:      eType;
    Addressed:  Boolean;
    xxOTyp:	TypPtr;                 //See EAsize too
    ConstVal:   Variant;                //Not in variant record
    VarInx:	Byte;		        //0,1..255}
    {{{IdxFlg:	(ifNone,ifWord,ifLong); {{{{{{{{}
    WithCode:   tDag0;
    OSLEV:      Byte;
    SetDesc:    Longint;                //ZeroOfs<<16 + Size    <>0 if used
    MockupSet:  Boolean;
    Case FKind: eKind of
    kRef:	(VVarF: eVarF; Indexed: Boolean; VADDR: Integer; {OSym:	pSymRec;});
    kConst:	(//ConI: Integer;
                 //ConS: String[255];
                 //ConR: Double
                 ); {Maybe also keep 0..-1 state as 68000!}
    kRes:	((**Case InReg: Boolean of True:  (ResReg: eReg); False: (ResAddr: Integer) ***)
                 InReg: (eFalse,eTrue,eAddr);//Boolean;  //Set when aEA ok, but Dn not loaded
                 );
    kCond:	(/// FalseLink: tDag1; CndConst: (cFalse,cTrue,cNone);
                 kCondD0Ok: Boolean;  //Set to Dn if valid reg. After SysTrap where D0 is ok boolean
                 //ccFalse: eCondJumps;
                 ccTrue: eCondJumps;
                 ReservedReg: tEA;
                 );
    kTmp:       ();
    {MaxSize:	Byte;			{0,1,2,??}
    {RegsUsed:	Set of eReg;		{See aEA,Ref!!!!!}
    {RegsOk:	Set of eReg;		{Maybe saved somewhere}
  End;

  //tDagList = Array of tDag1;
  tDag1 = Class(tDag0)
    Owner:        TUnit0;
    Id:           Integer; //Index of myself
    op:		  eP;
    op2:	  Integer;
    op3:          Integer; //LinkSize / UnstackSize
    opMisc:       Record Above,Below,Size: SmallInt end;
    opS:          CodeWordArray;    //CodeRaw (Assem.pas DC.x B,W,L)
    OpSFix:       TRefArray;        //ProcFunc ref
    OpSFixLocal:  FixLocalArray;    //Short addresses
    //parmL,parmR: tDag1;
    //dagList:     array[1..10] of tDag1;
    SkipWalkParmL: Boolean;    //Set for pcJMP,..
    ///ConstVal: 	 Variant;
    LabelCnt:	  Integer;               {Reg use cnt}
    Selected:     Boolean;
    SysProcType:  eSysProcType;          //pcPROCFUNC
    IsALabelxOP2Is0:    Boolean;               //pcPROCFUNC
    IsATrapProc:  Boolean;               //pcPROCFUNC
    IsALeaf:      Boolean;
    ForLevel:     Byte;
    OpRec:	  tOpRec;
    Comment:	  Str63; 
    CodeAddr:     Integer;
    CodeAddrLeft: Integer;

    xxRefCnt:	  Integer;               {Ref'ed by}
    Procedure     SetKind(AKind: eKind);
    Property      Kind: eKind Read OpRec.FKind Write SetKind;
    Procedure     AssignType(Code2: tDag1);
    Procedure     AssignButNotType(Code2: tDag1);
    Class Function CalcSize(Typ: TypPtr): eEASize;
    Class Function CalcSizeBytes(Typ: TypPtr): Integer;
    Procedure     SetSize(Typ: TypPtr);  overload;
    Procedure     SetSize(Size: eEASize);  overload;
    Function      Size: eEASize;
    Function      SizeNoImm: eEASize;
    Function      Cost: Byte;
    Function      ConI: Integer;
    Function      ConS: String;
    Function      IsIConst(var Value: Integer): Boolean;
    Function      IsImm: Boolean;
    //procedure CodeInstr(What: eCode; const lEA,rEA: tEA; Size: eEASize=easNone; CodeWhere: tDag1=NIL); virtual; abstract;
    //procedure CodeInstr0(What: eCode);  virtual; abstract;
    //procedure CodeInstr1(What: eCode; const lEA: tEA);  virtual; abstract;
  End;
Const MaxLabelCnt=10000;

procedure MkEA(var EA: tEA; xEAh: eEA; xEAl: eReg; xOffset: Integer; Size: eEASize);
procedure MkEA_IMM(var aEA: tEA; Imm: Integer; Size: eEASize);
procedure MkEA_A6(var EA: tEA; xOffset: Integer; Size: eEASize=easL);
Function  IsImm1_8(var OP: tEA): Boolean;
Function  IsImmInt8(const OP: tEA): Boolean;
Function  IsImmInt16(var OP: tEA): Boolean;
Function  IsImmInt32(var OP: tEA): Boolean;
Function ImmSize(var OP: tEA): eEASize;
Procedure CalcMOVEM(const Regs: tRegSet; var ToMem,FromMem,BitCount: Integer; var EA: tEA);
Function  MinSize(Left,Right: tDag1): eEASize;
Function  ParamByRef(T: TypPtr): Boolean;
Function  IsOfsInt8(const OP: tEA): Boolean;

(*REGS*************************)
Type
  eRegType	= (eRegNONE,eRegData,eRegAddr,eRegFPXXX);
  tRegs=
    Array [eReg] of Record
      RegType:   eRegType;
      UsedByDag: tDag1;
      {Also maybe searce for this reg used in any other address calcs!}
      {{ Alias:	set of sVars; {}
    End;
Var
  Regs		: tRegs;
  MaxRec	: tRegSet;
  RegsFree	: tRegSet;
Const
  RegsOrig: array[eReg] of eRegType = (
    eRegNone,eRegNone,
    eRegData,eRegData,eRegData,eRegData,eRegData,eRegData,eRegData,eRegData,
    eRegAddr,eRegAddr,eRegAddr,eRegAddr,eRegAddr,eRegAddr,eRegAddr,eRegAddr
    );
  RegBits: array[eReg] of Byte=(
    255,255,
    0,1,2,3,4,5,6,7,
    0,1,2,3,4,5,6,7);
  RegBits4: array[eReg] of Byte=(
    255,255, 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15);

implementation

procedure MkEA_A6(var EA: tEA; xOffset: Integer; Size: eEASize=easL);
begin
  MkEA(EA,EADIS,rA6,xOffset,Size);
end;

procedure MkEA_IMM(var aEA: tEA; Imm: Integer; Size: eEASize);
begin
  MkEA(aEA,EIMED,rNONE, Imm, Size);
end;

procedure MkEA(var EA: tEA; xEAh: eEA; xEAl: eReg; xOffset: Integer; Size: eEASize);
begin
  FillChar(EA, SizeOf(EA), 0);
  with EA do begin
    EAh:=xEAh; EAl:=xEAl; EAofs:=xOffset; EAi:=rNONE;
    EAsize:=Size;
    (*****
    Case Size of
    1:   EASize:=easB;
    2:   EAsize:=easW;
    else EAsize:=easL
    end;
    (*****)
  end;
end;

Procedure tDag1.SetKind(AKind: eKind);
begin
  OpRec.FKind:=AKind
end;

Procedure tDag1.AssignType(Code2: tDag1);
begin
  OpRec.xxOTyp:=Code2.OpRec.xxOTYP;
  OpRec.OTYPE:=Code2.OpRec.OTYPE;
end;
Procedure tDag1.AssignButNotType(Code2: tDag1);
var
  OldOTYPE: eType;
  OldOTyp:TypPtr;
begin
  OpRec.WithCode:=Code2.OpRec.WithCode;
  //.....
  OldOTYPE:=OpRec.OTYPE; OldOTyp:=OpRec.xxOTyp;
  OpRec:=Code2.OpRec;
  OpRec.OTYPE:=OldOTYPE; OpRec.xxOTyp:=OldOTyp;
end;

Class Function tDag1.CalcSize(Typ: TypPtr): eEASize;
begin
  case Typ^.TSIZE of
  1:   Result:=easB;
  2:   Result:=easW;
  else Result:=easL;
  end;
end;
Class Function tDag1.CalcSizeBytes(Typ: TypPtr): Integer;
begin
  Result:=Typ^.TSIZE
end;
Function  MinSize(Left,Right: tDag1): eEASize;
begin
  Result:=Left.OpRec.aEA.EASize;
  if Result>Right.OpRec.aEA.EASize then
    Result:=Right.OpRec.aEA.EASize;
end;

Function ParamByRef(T: TypPtr): Boolean;
begin
  //if T^.What<>SVAR then InternalError0;
  Result:=(T.TSize>4) //or (OpRec.OTYPE in [TSTR,TSET]);
  //or not (OpRec.OTYPE in eSimpType) //TREA..TUSR
  or not (T.TTYPE in eSimpType) //TREA..TUSR
end;

Procedure tDag1.SetSize(Typ: TypPtr);
begin
  OpRec.aEA.EAsize:=CalcSize(Typ)
end;
Procedure tDag1.SetSize(Size: eEASize);
begin
  OpRec.aEA.EAsize:=Size
end;

Function  tDag1.Size: eEASize;
begin
  Result:=OpRec.aEA.eaSize;
  if Result=easNone then
    Result:=easL;
end;
Function  tDag1.SizeNoImm: eEASize;
begin
  if OpRec.aEA.EAh=EIMED then Result:=easNone else Result:=OpRec.aEA.eaSize
end;

Function tDag1.Cost: Byte;
begin
  if OpRec.VVarF in [vfVarConst,vfVar] then
    Result:=50
  else
    case OpRec.aEA.EAh of
    EIMED:     if (-128<=OpRec.aEA.EAofs) and (OpRec.aEA.EAofs<=127) then
                 Result:=1
               else Result:=5;
    EDREG:     Result:=2;
    EAREG:     Result:=3;
    EAIND:     Result:=4;
    EADIS:     Result:=6;
    EAIXw,
    EAIXl:     Result:=7;
    EPDIS:     Result:=5;
    else       Result:=99;
    end;
end;

Function tDag1.IsIConst(var Value: Integer): Boolean;
begin
  Value:=0;
  Result:= op=pcConst;
  if Result then
    Value:=ConI;
end;

Function  tDag1.ConI: Integer;
begin
  try    Result:=OpRec.ConstVal;
  except Error(ExpCInt); Result:=0;
  end
end;

Function  tDag1.ConS: String;
begin
  if OpRec.OTYPE=TCHR then Result:=Chr(Lo(ConI))
  else
    try    Result:=OpRec.ConstVal;
    except Error(ExpCStr); Result:='';
    end
end;

Function tDag1.IsImm: Boolean;
begin
  Result:= OpRec.aEA.EAh=EIMED
end;

Function ImmSize(var OP: tEA): eEASize;
begin
  if IsImmInt8(OP) then Result:=easB
  else if IsImmInt16(OP) then Result:=easW
  else Result:=easL
end;

Function IsImm1_8(var OP: tEA): Boolean;
begin
  Result:=False;
  if OP.EAh=EIMED then
    Result:=(1<=OP.EAofs) and (OP.EAofs<=8)
end;
Function IsImmInt8(const OP: tEA): Boolean;
begin
  Result:=False;
  if OP.EAh=EIMED then
    Result:=(-128<=OP.EAofs) and (OP.EAofs<=127)
end;
Function IsOfsInt8(const OP: tEA): Boolean;
begin
  Result:=False;
  if OP.EAh in [EAIXw,EAIXl] then
    Result:=(-128<=OP.EAofs) and (OP.EAofs<=127)
end;
Function IsImmInt16(var OP: tEA): Boolean;
begin
  Result:=False;
  if OP.EAh=EIMED then
    Result:=(-32768<=OP.EAofs) and (OP.EAofs<=32767)
end;
Function IsImmInt32(var OP: tEA): Boolean;
begin
  Result:= OP.EAh=EIMED
end;

Procedure CalcMOVEM(const Regs: tRegSet; var ToMem,FromMem,BitCount: Integer; var EA: tEA);
var N: Integer; R: eReg;
begin
  ToMem:=0; FromMem:=0; BitCount:=0;
  EA:=EA_D0; N:=0;
  for R:=rD0 to rA7 do begin
    if R in Regs then begin
      if R in [rA0..rA7] then EA:=EA_A0; EA.EAl:=R;
      Inc(ToMem,   1 shl (15-N));
      Inc(FromMem, 1 shl N);
      Inc(BitCount);
    end;
    Inc(N)
  end;
  EA.EAsize:=easL;
end;

end.

