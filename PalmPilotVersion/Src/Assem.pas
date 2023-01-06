Unit Assem;
{$B+}

Interface

Uses Expr, Dag, CodeDag;

Type
  TUnit5b=Class(TUnit5)
    Procedure AsmLine(var Code: tDag);
  private
    OpFound: String;
    Procedure AsmInitTables;
  end;

Implementation

Uses Classes, SysUtils, Global, Misc, Util;

(*********
  111: S:=Chr(Ord(Err_ASM))+'ASM expected';
  112: S:=Chr(Ord(Err_ASM1))+'Parameter error';
  113: S:=Chr(Ord(Err_ASM2))+'Offset to big';
  114: S:=Chr(Ord(Err_ASM3))+'Only An or PC allowed';
  115: S:=Chr(Ord(Err_ASM4))+'68000 register expected';
  116: S:=Chr(Ord(Err_ASM5))+'Expression too complex';
  117: S:=Chr(Ord(Err_ASM6))+'Constant string cannot be used';
**********)

Type
  eSize= (
    B0  , //	0	;Only byte allowed (or no size)
    W0	, //	1	;Only word allowed (or no size)
    L0	, //	2	;Only long allowed (or no size)
    N0	, //	3	;No size allowed
    BWL6	, //	4	;Check OP.B XX,An! 00=B, 01=W, 10=L in pos 6..7
    WL18	, //	5	;0=W, 1=L i position 8 (ADDA & SUBA & CMPA)
    BWL12M	, //	6	;MOVE 01=B, 11=W, 10=L in position 12..13
    WL212	, //	7	;W=%11, L=%10
    WL16	, //	8	;For MOVEM & MOVEP & EXT
    SN);         //	9	;LABEL
  //DL0	, //	10	;.LONG (or no size)
  //DBL0	, //	11	;.BYTE or .LONG (or no size)
Const
  DB0=B0;

Type
  eRegs=(
  None		, //	00
  Spec		, //	01
  Lab		, //	02
  Dreg0		, //	03
  Dreg9		, //	04
  Areg0		, //	05
  Areg9		, //	06
  ALL0		, //	07	;EA
  ALT0		, //	08	;EA
  ALTDATA0	, //	09	;EA
  ALTDATA6	, //	10	;EA	;Only for MOVE
  ALTMEM0	, //	11	;EA
  AregP0	, //	12	;MOVEM & CMPM (An)+
  AregP9	, //	13	;CMPM         (An)+
  RegListM	, //	14
  AregM0	, //	15	;-(An)				;3 bit
  AregM9	, //	16	;-(An)				;3 bit
  CONT0		, //	17	;EA
  ALTCONT0	, //	18	;EA	;MOVEM
  Imm		, //	19	;8, 16 or 32 bit immediate
  Imm3		, //	20	;ADDQ, SUBQ, ASR. Position=9!
  Imm04		, //	21	;TRAP
  Imm08		, //	22	;MOVEQ
  Imm16		, //	23	;LINK, STOP, Bxxx
  DATA0		, //	24	;EA
  DAY0		, //	25	;MOVEP				;3 bit
  DATAC		, //	26	;BTST, Also allow d(PC,..)
  Imm16SysTrap  );//    27      ;SysTrap WITHOUT "#"

Type
  eParmFlag = (FNone,FJMP16,FJMP32,FMOVEM,
               FSpecSR,FSpecCCR,FSpecUSP); //Flag=0,1,2

  TTableRec = Record
    rFirst:      Boolean;
    rName:       String;
    Case rWhat: (eRec,eAlias,eInit,eDC) of
    eRec: (
      rOpCnt:    Byte;
      rOpSize:   eSize;
      rOpFlags:  eParmFlag;
      rOpSrc:    eRegs;
      rOpDst:    eRegs;
      rOpCode:   Word);
    eAlias: (rRecPtr: Integer);
    eInit:  (rAliasName: Str6);
  End;
Var
  TableRec: Array[1..220] of TTableRec;
  TableRecMax: Integer;
  AsmSymb: TStringList; //Int(Object)= Index into TableRec
  AsmRegs: TStringList; //Int(Object)= (Dn,An,PC,Spec)<<8 + RegNo
  CodeWords: CodeWordArray;

Type
  TOper=Record
    RegNo:    Byte;
    RegIdx:   Byte;
    RegType:  Byte;      //0=Dn, 1=An, 2=PC, 3=Special
    RegMode:  Integer;   //Bitmask for Addressing mode used
    RegOfs:   Integer;
    LabFixup: tDag;     //@Labels
    BsrFixup: TRef;      //Interproc Fixup. RegType=2
  End;

(******************************************************************************)
Procedure TUnit5b.AsmLine(var Code: tDag);

Function  DefLocal(DoDefine: Boolean): tDag; Forward; //True if @Label found/defined

Procedure Expr0(var O: TOper); Forward;
Function  Expr1: TOper; Forward;
Function  Expr3: TOper; Forward;
Function  Expr4: TOper; Forward;
Function  Expr8: TOper; Forward;
Function  EFact: TOper; Forward;
Function  ScanSize: Integer; Forward;
Function  EFvar: TOper; Forward;

Function  AddSize(Size: eSize): Boolean; forward;
Function  IsEOF: Boolean; forward; //EOLN, 'END' or ';'
Function  ChkCal(var OP: TOper; Instr: Integer; Reg: eRegs): Boolean; forward;
Function  RegLst: Boolean; forward;
Function  XALL(var OP: TOper; Var RetB: Integer): Boolean; forward;
function  CodDisp(Size: Byte; RegOfs: Integer): Boolean; forward;

Var
  OP1,OP2: TOper;
  RegList: Array[1..2] of Word;
  OpCnt: Byte;
  xInstr: Integer;                      //TableRec index
  BWL: Word;                            //0=.B, 1=.W, 2=.L. +$FF00 => Specified
                                        //4=.S,(5=.W, 6=.L)
  CodeBFlg: Integer;
  OpPtr: Integer;
  OpCode: Word;
  OpCodes: Array[1..6] of
    Record
      OPWord:  Integer;
      OPFixup: tDag;
      BsrFixup: TRef;
    End;

Const
  BitDn		=	0	;  //Dn
  BitAn		=	1	;  //An
  BitIAn	=	2	;  //(An)
  BitIAnI	=	3	;  //(An)+
  BitIAnD	=	4	;  //-(An)
  BitdIAn	=	5	;  //d(An)
  BitdAnRi	=	6	;  //d(An,Ri)
  BitAbs16	=	7	;  //XXXX
  BitAbs32	=	8	;  //XXXXXXXX
  BitdPC	=	9	;  //d(PC)
  BitdPCRi	=	10	;  //d(PC,Ri)
  BitImm	=	11	;  //#nn

  MBitDn	=	1 shl BitDn	;  //Dn
  MBitAn	=	1 shl BitAn	;  //An
  MBitIAn	=	1 shl BitIAn	;  //(An)
  MBitIAnI	=	1 shl BitIAnI	;  //(An)+
  MBitIAnD	=	1 shl BitIAnD	;  //-(An)
  MBitdIAn	=	1 shl BitdIAn	;  //d(An)
  MBitdAnRi	=	1 shl BitdAnRi	;  //d(An,Ri)
  MBitAbs16	=	1 shl BitAbs16	;  //XXXX
  MBitAbs32	=	1 shl BitAbs32	;  //XXXXXXXX
  MBitdPC	=	1 shl BitdPC	;  //d(PC)
  MBitdPCRi	=	1 shl BitdPCRi	;  //d(PC,Ri)
  MBitImm	=	1 shl BitImm	;  //#nn
  MSpec		=	1 shl 14;

  ModeSpec	=	$4000; //%0100000000000000
  ModeData	=	$0FFD; //%0000111111111101
  ModeMem	=	$0FFC; //%0000111111111100
  ModeCont	=	$07E4; //%0000011111100100
  ModeAlter	=	$01FF; //%0000000111111111
  ModeAll	=	$0FFF; //%0000111111111111
  PCBTSTMode	=	$0600; //%0000011000000000 ;PC relative for BTST
  ModeAltData	=	ModeAlter and ModeData;
  ModeAltMem	=	ModeAlter and ModeMem;
  ModeAltCont	=	ModeAlter and ModeCont;
  PCModeAltData	=	ModeAltData or PCBTSTMode; //For BTST, also on d(PC,..)

Procedure DoLine;
Procedure Check1(Var OP: TOper);
var IsNum: Boolean;
begin
  IsNum:=Scan(SNUM);
  Expr0(OP);
  if OP.RegMode=MBitImm then begin
    if ImmTst(OP.RegOfs,-32768,32767) then
      OP.RegMode:=MBitAbs16
    else
      OP.RegMode:=MBitAbs32;  //Also for "SysTrap $a000"
  end;
  if IsNum then begin
    if (OP.RegMode=MBitAbs16)
    or (OP.RegMode=MBitAbs32) then OP.RegMode:=MBitImm
    else Error(ExpCInt);
  end;
end;

begin {DoLine}
  if IsEOF then EXIT;
  Check1(OP1);
  if (OP1.RegMode and (MBitAn+MBitDn)) =0 then begin
    RegList[1]:=0;  //Clear if cannot be a RegList
    RegList[2]:=0;
  end;
  if IsEOF then EXIT;
  Find(SCOM);
  Check1(OP2);
end;

Function Parse(Instr: Integer): Boolean;
var First: Boolean;
begin
  Result:=True; First:=True;
  repeat
    if Not First then begin
      inc(Instr);
      if TableRec[Instr].rFirst then BREAK;
    end;
    First:=False;
    with TableRec[Instr] do begin
      Case rWhat of
      eAlias: if Parse(rRecPtr) then EXIT; //Ok!
      eRec: if OPCnt=rOPCnt then begin
              OpFound:=rName;
              FillChar(OPCodes,SizeOf(OPCodes),0);
              OpPtr:=0; OpCode:=rOPCode;
              if OPCnt>=1 then if not ChkCal(OP1,Instr,rOpSrc) then CONTINUE;
              if OPCnt>=2 then if not ChkCal(OP2,Instr,rOpDst) then CONTINUE;
              if not AddSize(rOpSize) then CONTINUE;
              EXIT; //Ok!
            end;
      end;
    end;
  Until False;
  Result:=False;
end;

Procedure CodeW(W: Integer);
begin
  SetLength(CodeWords,Length(CodeWords)+1);
  CodeWords[Length(CodeWords)-1]:=W and $FFFF;
end;

procedure ReturnCode;
var N: Integer; S: String;
begin
  if (OpPtr=1) and ((OpCodes[1].OPFixup<>NIL) or OpCodes[1].BsrFixup.FixUsed) then begin
    //RawOP:=(OpCode and $F0FF);
    if OpCodes[1].OPFixup<>NIL then begin
      if (OpCode and $F0F8)=$50C8 then  //OpCode=22473 = DBEQ D1
        Code:=CodeLD(Code,CodeJmpASM(OpCode and $F0FF,eCondJumps($F and (OpCode shr 8)),OpCodes[1].OPFixup,'AsmDBcc'))
      else //Bcc
        Code:=CodeLD(Code,CodeJmpASM(OpCode and $F0FF,eCondJumps($F and (OpCode shr 8)),OpCodes[1].OPFixup,'AsmJMPcc'))
    end else
      //if OpCode=$6100 then
      //Code:=CodeLD(Code,CodeProcFunc(eProc,RawOP,eCondJumps($F and (OpCode shr 8)),OpCodes[1].BsrFixup,'AsmProcFuncCC'));
      Code:=CodeLD(Code,CodeProcFunc(eProc,OpCode,OpCodes[1].BsrFixup,1,'AsmProcFuncCC'));
    (*******
    if OpCode=$6100 then             //BSR = $6100 (also JSR!)
      ///Code:=CodeLD(Code,CodeIns(pcPROCFUNC,0,Code,NIL)
      InternalError('Hpc RetCode')   ////////
    else if (RawOP=$50C8)            //'DBT',$50C8
         or (RawOP=$6000) then       //'BCC',$6400 (except BSR/JSR)
           Code:=CodeLD(Code,CodeJmpASM(RawOP,eCondJumps($F and (OpCode shr 8)),OpCodes[1].OPFixup,'AsmJMPcc'))
         else
           InternalError('Hpc RetCode');
    (***********)
  end else begin
    CodeW(OpCode);
    S:=Format('%.4x',[OpCode]);
    for N:=1 to OpPtr do
      with OpCodes[N] do begin
        CodeW(OpWord);
        S:=S+Format(' %.4x',[OpWord and $FFFF]);
      end;
    ///if S<>'' then Debug(S);
    if Length(CodeWords)>0 then
      Code:=CodeLD(Code,CodeRawArray(CodeWords,'HSASM '+OpFound));
  end;
end;

Function ChkCal(var OP: TOper; Instr: Integer; Reg: eRegs): Boolean;
Const P9: Array[eRegs] of Byte=(0,0,0,0,9,0,9,0,0,0,0,0,0,9,0,0,9,0,0,0,0,0,0,0,0,0,0,0);
Const Flags: Array[eRegs] of Word=(
MSpec,MSpec,MBitdPC,MBitDn,MBitDn,MBitAn,MBitAn,ModeAll,ModeAlter,
ModeAltData,ModeAltData,ModeAltMem,MBitIAnI,MBitIAnI,MSpec,
MBitIAnD,MBitIAnD,ModeCont,ModeAltCont,
MBitImm,MBitImm,MBitImm,MBitImm,MBitImm,ModeData,MBitdIAn,PCModeAltData,MBitAbs32);
var O,O2: Integer;
begin
  with TableRec[Instr] do begin
    Result:=False;
    if (OP.RegMode and Flags[Reg])=0 then begin //??????
      if rOpFlags=FMOVEM then
        if OP.RegMode and (MBitAn+MBitDn) <>0 then
          Result:=RegLst;
      EXIT;
    end;
    case Reg of
    None:     Result:=True;
    Spec:     if rOpFlags in [FSpecSR,FSpecCCR,FSpecUSP] then
                Result:= OP.RegNo= byte(rOpFlags); //minus FSpecSR??
    Lab:
      begin
        CodDisp(1,0);               //XXXX
        OpCodes[OpPtr].OpFixup:=OP.LabFixup;
        OpCodes[OpPtr].BsrFixup:=OP.BsrFixup;
        Result:= (OP.LabFixup<>Nil) or OP.BsrFixup.FixUsed;
      end;
    CONT0,ALTCONT0,ALTMEM0,DATA0,DATAC,
    ALTDATA0,ALL0,ALT0:
      begin
        Result:=XALL(OP,O);
        OpCode:=OpCode or (O shl P9[Reg]);
      end;
    ALTDATA6:
      begin
	Result:=XALL(OP,O);		//Swap EA, and move to position 6
        O:=O shl 3;
        O2:=O;
        O:=O shl (9-3);
        O:=O or O2;
        O:=O and $0FC0;         //%0000.1111.1100.0000
        OpCode:=OpCode or O;    //No shift
      end;
    Dreg0,Dreg9,Areg0,Areg9,AregM0,AregM9,AregP0,AregP9:
      begin
        OpCode:=OpCode or (($07 and OP.RegNo) shl P9[Reg]); //Keep 3 bits for An or Dn
        Result:=True;
      end;
    RegListM: Result:=RegLst;
    Imm: //8, 16 or 32 bit immediate
           if lo(BWL)=2 then Result:=CodDisp(2,OP.RegOfs)
           else Result:=CodDisp(1,OP.RegOfs);
    Imm3: //ADDQ, SUBQ, ASR. Position=9!
          begin
            OpCode:=OpCode or ((OP.RegOfs and $0007) shl 9);
            Result:=ImmTst(OP.RegOfs,1,8);
          end;
    Imm04: //;TRAP
          begin
            OpCode:=OpCode or lo(OP.RegOfs);
            Result:=ImmTst(OP.RegOfs,0,15);
          end;
    Imm08:
          begin
            OpCode:=OpCode or lo(OP.RegOfs);
            Result:=ImmTst(OP.RegOfs,-128,127);
          end;
    Imm16: //;LINK, STOP, Bxxx
          Result:=CodDisp(1,OP.RegOfs);
    Imm16SysTrap: //;SysTrap $a000
          begin Result:=TRUE; CodDisp(1,OP.RegOfs) end;
    DAY0: if OP.RegMode and (MBitIAn or MBitdIAn)<>0 then begin
            Result:=CodDisp(1,OP.RegOfs);
            OpCode:=OpCode or (($07 and OP.RegNo) shl P9[Reg]); //Keep 3 bits for An or Dn
          end;
    else InternalError('Hpc ChkCal')
    end;
  end;
end;

Function XALL(var OP: TOper; Var RetB: Integer): Boolean;
var N: Byte; Ok: Boolean;
procedure ChkRegMode; //(OP, N, (OP.RegNo and 7) + (N*$08));
begin
  Case N of
  BitDn,     //Dn
  BitAn,     //An
  BitIAn,    //(An)
  BitIAnI,   //(An)+
  BitIAnD: ; //-(An)
  BitdAnRi,  //d(An,Ri)
  BitdPCRi:  //d(PC,Ri)
    if OP.LabFixup<>NIL then Ok:=False  //No fixup allowed
    else begin
      CodDisp(1,OP.RegIdx shl 8 +       //IIIIW000. IIII=IndexReg, W=W/L
              lo(OP.RegOfs));
      Ok:=lo(OP.RegOfs) = OP.RegOfs;
    end;
  BitImm:    //Long, then save a longword
    if OP.LabFixup<>NIL then Ok:=False //No fixup allowed
    else
      case lo(BWL) of
      2:   CodDisp(2,OP.RegOfs);          //XXXXXXXX 32 bit
      else CodDisp(1,OP.RegOfs);          //XXXX
      end;
  BitdPC,    //d(PC)
  BitdIAn,   //d(An)
  BitAbs16:  //XXXX
    begin
      CodDisp(1,OP.RegOfs);               //XXXX
      if OP.LabFixup<>NIL then Error(Err_ASM1); //No fixup allowed
    end;
  BitAbs32:
    begin
      CodDisp(2,OP.RegOfs);               //XXXXXXXX
      if OP.LabFixup<>NIL then //OpCodes[OpPtr].OpFixup:=OP.LabFixup;
        Error(Err_ASM1);
    end;
  else InternalError('Asm XALL');
  end;
end;
begin {XALL}
  Result:=True; Ok:=True;
  if OP.LabFixup<>NIL then begin
    Result:=False;
    EXIT
  end;
  RetB:=OP.RegNo and 7;
  for N:=BitDn to BitdAnRi do begin
    if (1 shl N) = OP.RegMode then begin
      ChkRegMode;
      EXIT;
    end;
    inc(RetB,8); //00001000
  end;
  RetB:=$38; //00111000
  for N:=BitAbs16 to BitImm do begin
    if (1 shl N) = OP.RegMode then begin
      ChkRegMode;
      EXIT;
    end;
    Inc(RetB,1); //00000001
  end;
  Result:=Ok;
end;

Function RegLst: Boolean;
begin
  Result:=False;
  if RegList[1]<>0 then begin
    inc(OpPtr); //Make room for one word with bit mask
    OPcodes[2]:=OPcodes[1];
    if OpCode=$48A0 then //Tested before bits or'ed into it!!
      RegList[1]:=RegList[2];        //Use reversed RegList
    OPcodes[1].OpWord:=RegList[1];   //Right after OPcode word
    OPcodes[1].OpFixup:=NIL; OPcodes[1].BsrFixup.FixUsed:=False; //Ness??????
    Result:=True;
  end;
end;

function CodDisp(Size: Byte; RegOfs: Integer): Boolean;
begin
  if Size=2 then begin
    CodDisp(1,RegOfs shr 16);
    CodDisp(1,RegOfs);
    Result:=True;
  end else begin
    Inc(OpPtr);
    OpCodes[OpPtr].OpWord:=RegOfs;
    Result:=ImmTst(RegOfs,-32768,32767);
  end;
end;

//Modify OPcode with size bits
//Out	Zero if ok
Function AddSize(Size: eSize): Boolean;
var xx: Word; UnSpec: Boolean;
begin
  Result:=False;
  UnSpec:=(BWL shr 8)=0; //or not specified
  xx:=BWL and 3; //D1=BWL (2 bits only). Flags ALSO set
  case Size of    //operandsize, Size(4 bit)
  B0: Result:=UnSpec or (xx=0);   //B
  W0,
  SN: Result:=UnSpec or (xx=1); //W0 + SN
  L0: Result:=UnSpec or (xx=2);   //L
  N0: Result:=UnSpec;             //N0
  BWL6: begin //Check XXX.B An,<EA> not allowed
       if xx=0 then //XXX.B An,<EA>
         if ((1 shl BitAn) and OP1.RegMode)<>0 then EXIT;
       //00=B, 01=W, 10=L in position 6..7. (00,40,80)
       OpCode:=OpCode or (xx shl 6);
       Result:=True;
     end;
  WL18: begin //0=W, 1=L i pos 8 (ADDA & SUBA & CMPA)
       if xx<>0 then begin //.BYTE not allowed
         xx:=(xx shr 1) shl 8;
         OpCode:=OpCode or xx;
         Result:=True;
       end;
     end;
  BWL12M: begin //MOVE 01=B, 11=W, 10=L in position 12..13
       case xx of // 00=B, 01=W, 10=L in position 6..7. (00,40,80)
       0: OpCode:=OpCode or $1000;
       1: OpCode:=OpCode or $3000;
       2: OpCode:=OpCode or $2000;
       end;
       Result:=True;
     end;
  WL212: if xx<>0 then begin //not Byte!  //S_WL212  W=%11, L=%10
       OpCode:=OpCode or ((xx or 2) shl 12);
       Result:=True;
     end;
  WL16: if xx<>0 then begin //S_WL16   For MOVEM & MOVEP & EXT
       xx:=(xx shr 1) shl 6;
       OpCode:=OpCode or xx;
       Result:=True;
     end;
  else InternalError('Asm AddSize');
  end;
end;

//******************************************************************************

Procedure Expr0_OP1(Min,Max: Integer);
begin
  Expr0(OP1);
  if OP1.RegMode<>MBitImm then Error(ExpCInt);
  if not ImmTst(OP1.RegOfs,Min,Max) then Error(Err_Int);
end;

Procedure Expr0(var O: TOper);
var O2: TOper; xx: word;
begin
  Inc(OPcnt);
  ///FillChar(O,SizeOf(O),0);
  //try
    O:=Expr1;
  //except
  //  Error(Err_ASM1);
  //end;
  if Scan(SLPA) then begin
    O2:=EFact;  //Find An or PC
    if (O2.RegNo and $60)=0 then //aPADRRRR. a=Any reg, P=PC, A=An, D=Dn
      Error(Err_Asm4); // "An" or "PC" register?, Expected other register
    O.RegNo:=O2.RegNo;
    xx:=0;
    if (O.RegNo and $40)<>0 then begin //PC
      O.RegMode:=MBitdPC;
      xx:=MBitdPCRi;
    end else
    if (O.RegNo and $20)<>0 then begin //An
      O.RegMode:=MBitIAn;
      xx:=MBitdAnRi;
    end else
    if O.RegNo<>0 then Error(Err_Asm3);
    if XX=0 then begin
      O.RegMode:=MBitAbs16;
      Find(SRPA);
    end else begin
      // d(An... or d(An...
      if ScanSCom then begin
        // d(An,...
        O.RegMode:=xx;                 //(An) => d(An,Xn). d(PC) => d(PC,Xn)
        //Find Xn [.W | .L]
        O2:=EFact;
        if (O2.RegNo and $C0)=0 then  //#7=An, #6=PC
          Error(Err_ASM4);            //Expected other register
        xx:=ScanSize;
        Case Lo(xx) of
        1:   xx:=0;   // .W
        2:   xx:=$08; // .L
        else Error(Err_ASM1);
        end;
        O.RegIdx:=xx+ ((O2.RegNo and $0F) shl 4);
      end;
      Find(SRPA);
      if MBitIAn=O.RegMode then           //(An)+ without offset?
        if (O.RegOfs=0) and (O.LabFixup=NIL) then
          if Scan(SPLS) then
            O.RegMode:=MBitIAnI;          //(An) => (An)+
    end;
  end;
  if (O.LabFixup<>NIL) or (O.RegOfs<>0) then
    if O.RegMode=MBitIAn then
      O.RegMode:=MBitdIAn;
end;

Function Scan4(B: Array of eSym): eSym;
var N: Byte;
begin
  Result:=SNONE;
  for N:=Low(B) to High(B) do
    if Next.Ch=B[N] then begin
      Result:=Next.Ch;
      ScanNext;
      BREAK;
    end;
end;

Function CheckConst1(var O: TOper): Integer;
begin
  Result:=O.RegOfs;
  if (O.RegMode and (MBitAbs16+MBitAbs32+MBitImm))=0 then
    Error(Err_ASM1); //Not a constant (Parameter error)
end;
Function CheckConstX(var O1: TOper; O2: TOper): Integer;
begin
  CheckConst1(O1);
  Result:=CheckConst1(O2);
end;

Function Expr1: TOper; // +, -, |, ^
var O2: TOper;
begin
  Result:=Expr3;
  repeat
    Case Scan4([SPLS,SMIN,SOR,SCAR]) of
    SPLS: begin
            O2:=Expr3;
            Inc(Result.RegOfs,O2.RegOfs);
            if O2.LabFixup<>NIL then
              if Result.LabFixup<>NIL then Error(Err_ASM1)
              else Result.RegMode:=O2.RegMode;
          end;
    SMIN: Result.RegOfs:=Result.RegOfs -   CheckConstX(Result,Expr3);
    SOR:  Result.RegOfs:=Result.RegOfs or  CheckConstX(Result,Expr3);
    SCAR: Result.RegOfs:=Result.RegOfs xor CheckConstX(Result,Expr3);
    else  BREAK
    end;
  until FALSE;
end;

Function Expr3: TOper; //  *, /, %, &, <<, >>
begin
  Result:=Expr4;
  repeat
    Case Scan4([SAST,SSLA,SPRC,SAND,SSHL,SSHR]) of
    SAST: Result.RegOfs:=Result.RegOfs *   CheckConstX(Result,Expr4);
    SSLA: Result.RegOfs:=Result.RegOfs DIV CheckConstX(Result,Expr4);
    SPRC: Result.RegOfs:=Result.RegOfs MOD CheckConstX(Result,Expr4);
    SAND: Result.RegOfs:=Result.RegOfs AND CheckConstX(Result,Expr4);
    SSHL: Result.RegOfs:=Result.RegOfs SHL CheckConstX(Result,Expr4);
    SSHR: Result.RegOfs:=Result.RegOfs SHR CheckConstX(Result,Expr4);
    else  BREAK
    end;
  until FALSE;
end;

Function Expr4: TOper; // Monadic: +. -, !, ()
begin
  Case Scan4([SPLS,SMIN,SESC]) of
  SPLS: begin Result:=Expr4; CheckConst1(Result) end;
  SMIN: if ScanSLPA then begin
          Result:=EFact;
          if (Result.RegNo and $80)=0  then Error(Err_ASM4); //An
          if (Result.RegNo and $40)<>0 then Error(Err_ASM4); //not PC
          Result.RegMode:=MBitIAnD;
          Find(SRPA);
        end else begin
          Result:=Expr4;
          Result.RegOfs:=  - CheckConst1(Result);
        end;
  SESC: begin
          Result:=Expr4;
          Result.RegOfs:=NOT CheckConst1(Result);
        end;
  else  Result:=Expr8;
  end;
end;

Function Expr8:	TOper;
begin
  if ScanSLPA then begin
    Result:=Expr1;
    Find(SRPA);
    if Result.RegMode=MBitAn then begin  //'(An)' ?
      Result.RegMode:=MBitIAn;           //'(An)' !
      if Scan(SPLS) then
        Result.RegMode:=MBitIAnI;        //'(An)+' !
    end;
  end else Result:=EFact;
end;

Function ScanRegs: Integer;
begin
  Result:=-1;
  if Next.Ch=SIDN then begin
    Result:=AsmRegs.IndexOf(Next.IdnBuf);
    if Result>=0 then begin
      Result:=Integer(AsmRegs.Objects[Result]); //(Dn,An,PC,Spec)<<8 + RegNo
      ScanNext;
    end;
  end;
end;

Procedure ChkList(FrstReg: Integer); //MOVEM
procedure AddOne(R: Integer);
begin
  R:=R and 15;
  RegList[1]:=RegList[1] or (1 shl R);
  RegList[2]:=RegList[2] or (1 shl (15-R));
end;
var Ch: eSym; N,I: Integer;
begin
  if RegList[1]<>0 then EXIT;          //Only one list per line
  AddOne(FrstReg);
  Repeat
    Ch:=Scan4([SMIN,SSLA]); //  '/' or '-'   D0-D2/A0-A2
    if Ch=SNONE then BREAK;
    N:=ScanRegs;
    if Lo( N shr 8 ) >1 then Error(Err_ASM1);
    if Ch=SMIN then begin
      for I:=FrstReg to N do AddOne(I);
    end else AddOne(N);
    FrstReg:=N;
  until False;
end;

Function EFact:	TOper;
var N: Integer;
begin
  FillChar(Result,SizeOf(Result),0);
  N:=ScanRegs;
  if N<0 then begin Result:=EFvar; EXIT end;
  Result.RegNo:=Lo(N);
  Result.RegType:=Lo( N shr 8 );
  Case Result.RegType of
  0: begin //Dn
       Result.RegMode:=MBitDn;
       Result.RegNo:=Result.RegNo or $90; //%10010000 = Dn
     end;
  1: begin //An
       Result.RegMode:=MBitAn;
       Result.RegNo:=Result.RegNo or $A0; //%10100000 = An
     end;
  2: begin //PC
       Result.RegMode:=MBitdPC;
       Result.RegNo:=Result.RegNo or $C0; //%11000000 = d(PC)
     end;
  3: Result.RegMode:=MSpec; //Special
  else InternalError('Asm EFact');
  end;
  if Result.RegType<=1 then // Dn or An
    ChkList(Result.RegNo);
end;

Function EFvar: TOper;
var Sym: pSymRec;
begin
  FillChar(Result,SizeOf(Result),0);
  // if Scan(SCON) then TINT,TREA,TSTR: !!!
  if Scan(SPRO) or Scan(SFUN) then begin
    //Result.LabFixup:=-1;
    Result.RegMode:=MBitdPC;   //MBitAbs16;
    Result.RegNo:=$C0; //%11000000 = d(PC)
    InternalError('Asm EFVar');
    EXIT
  end;
  if Scan(SICO) or Scan(SCCO) then begin
    Result.RegOfs:=Next.IValue;
    Result.RegMode:=MBitImm;
    EXIT
  end;

  Result.LabFixup:=DefLocal(False);
  if Result.LabFixup<>NIL then begin
    Result.RegType:=2;      //0=Dn, 1=An, 2=PC, 3=Special
    Result.RegMode:=MBitdPC;
    Result.RegNo:=$C0; //%11000000 = d(PC)
    EXIT
  end;

  Sym:=ScanSym(True,DummyWithCode);
  if Sym=NIL then begin
    Next.IdnBuf:='SysTrap'+Next.IdnBuf;      //SysTrap Special hack
    Sym:=ScanSym(True,DummyWithCode);
    Delete(Next.IdnBuf,1,7);
  end;
  if Sym<>NIL then begin
    if Sym^.What=STYPP then begin
      Find(SIDN);
      Find(SPER); 
      SYM:=ScanScope(Sym^.TTYPP.TSCOP);
      if SYM=NIL then Error(Err_ASM1);
    end;
    with Sym^ do begin
      Case Sym^.What of
      SVAR: begin
              Result.RegType:=1;      //0=Dn, 1=An, 2=PC, 3=Special
              Result.RegMode:=MBitdIAn;
              Result.RegOfs:=VADDR;
              if BWL=1 then //Not specified
                if VTYPP^.TSIZE=4 then
                  BWL:=2;    //Make it .L, but still not specified!
              if VSLEV=0 then Result.RegNo:=5 //A5   Sym^.VSLEV
              else
                if VSLEV<>SLEV then Error(Err_ASM5) //DLEV ??
                else Result.RegNo:=6; //A6
            end;
      SPRO,
      SFUN: begin
              if PDsystrap in PFLAG then begin
                Result.RegOfs:=PFUNO and $FFFF;  //Constant. Cannot handle D2=xx
                Result.RegMode:=MBitImm;
              end else begin
                Result.RegMode:=MBitdPC;   //MBitAbs16;
                Result.RegNo:=$C0; //%11000000 = d(PC)
                Result.RegType:=2;   //0=Dn, 1=An, 2=PC, 3=Special
                Result.BsrFixup:=Sym^.PRef;
              end;
            end;
      SCON: if CTYPP^.TTYPE=TCHR then begin
              Result.RegMode:=MBitImm;
              ///  Result.RegOfs:=CSVAL;  //Constant
              Error(Err_ASM1);;;;
            end else
              if not (CTYPP^.TTYPE in SetSimType) then Error(Err_ASM1)
              else begin
                Result.RegMode:=MBitImm;
                Result.RegOfs:=CIVAL;  //Constant
              end;
      else  Error(Err_ASM)
      end;
      ScanNext;
      EXIT
    end;
  end;

  Sym:=ScanScope(AsmScope);
  if Sym<>NIL then begin  //Also @Result!!
    InternalError('Asm TEST THIS1');    //Result.LabFixup := Sym; !!
    Result.RegType:=2;                     //0=Dn, 1=An, 2=PC, 3=Special
    Result.RegMode:=MSpec; //MBitdPC;      //Bitmask for Addressing mode used
    Result.LabFixup:=tDag(Sym^.LADDR);
    EXIT
  end;
  //@result= RegOfs:=PPARS, #MBitdIAn, #%10101000+6
  Error(Unknown);
end;

Function  DefLocal(DoDefine: Boolean): tDag; //True if @Label found/defined
var SymRec: tSymRec; Sym: pSymRec;
begin
  Result:=NIL;
  if (Copy(Next.IdnBuf,1,1)='@')and (Next.Ch=SIDN) then begin
    Sym:=ScanScope(AsmScope);
    //if DoDefine or (sym<>nil) then Result:=NIL;;;;;;;;;;;;;
    if Sym<>NIL then begin
      if DoDefine then begin
        if Sym^.LDEFI then Error(Err_LabelX2);
        Sym^.LDEFI:=True; {Defined label}
        Dec(AsmUndefLabels);
      end;
      Result:=tDag(Sym^.LADDR);
    end else with SymRec do begin
      ZeroSym(SymRec);
      What:=SLBL; {{{{LSLEV:=SLEV; {{{{{} LNLEV:=0;
      LADDR:=CodeJmpLabel('ASM'+Next.IdnBuf);
      Result:=tDag(LADDR);
      LDEFI:=DoDefine; //Defined, if a label
      //IntIdn; //Label # => String ID's
      InsSym(SymRec);
      if not DoDefine then Inc(AsmUndefLabels);
    End;
    ScanNext;
    if DoDefine then begin
      Code:=CodeLD(Code,Result);
      Find(SCOL);
    end;
  End;
end;

procedure CodeB(B: Integer);
begin
  B:=lo(B);
  if CodeBFlg>=0 then begin
    CodeW(CodeBFlg shl 8+ B);
    CodeBFlg:=-1;
  end else CodeBFlg:=B;
end;

procedure DoConst; // Handle DC.B, DC.W & DC.L
var N: Integer;
begin
  repeat
    case lo(BWL) of
    0: if Next.Ch=SSCO then begin
         for N:=0 to Length(Next.SValue) do CodeB(ord(Next.SValue[N]));
         ScanNext;
       end else begin
         Expr0_OP1(-128,255);
         CodeB(OP1.RegOfs);
       end;
    1: begin
         Expr0_OP1(-32768,32767);
         CodeW(OP1.RegOfs);
       end;
    2: begin
         Expr0_OP1(-MaxInt,MaxInt);
         CodeW(OP1.RegOfs shr 16);
         CodeW(OP1.RegOfs);
       end;
    Else Error(ExpCInt);
    end;
    if IsEOF then BREAK;
    Find(SCOM);
  until FALSE;
  CodeB(0);
  if Length(CodeWords)>0 then
    Code:=CodeLD(Code,CodeRawArray(CodeWords,'HSASM '+OpFound));
end;

Function IsEOF: Boolean; //EOLN, 'END' or ';'
begin
  Result:=Next.Ch in [SEND,SSEM,SEOLN]
end;

Type eSize=(eB,eW,eL,eS);
// In	D0	Bitmask for allowed size's
// Out	D0.B	Bitno for size found. hi(D0.W)=FF if size specified
//              0,1,2= B,W,L
Function ScanSize: Integer;
begin
  //Result:=1; //Default= .W
  Result:=1; // .W !!  //2; //Default= .L !!!!!           ????W or Long???
  if Scan(SPER) then begin
    if Length(Next.IdnBuf)=1 then begin
      Case Next.IdnBuf[1] of
      'B': Result:=$FF00;
      'W': Result:=$FF01;
      'L': Result:=$FF02;
      'S': Result:=$FF04;
      else Error(0);
      end;
      ScanNext;
    end else Error(Err_ASM1);
  end;
end;

(******************************************************************************)
begin {AsmLine}
  Code:=NIL;
  CodeBFlg:=-1;
  AsmInitTables;
  OpCnt:=0; RegList[1]:=0; RegList[2]:=0; 
  repeat
    if IsEOF then EXIT;
    DefLocal(TRUE);   //Define labels direct to dag
    if IsEOF then EXIT;
    xInstr:=AsmSymb.IndexOf(Next.IdnBuf);
    if xInstr>=0 then BREAK; //Found instruction
    Error(Unknown);
    ScanNext;
  until FALSE;
  xInstr:=Integer(AsmSymb.Objects[xInstr]);
  ScanNext;
  BWL:=ScanSize;              //Hi=Flag, Lo=BitNo 0,1,2=B,W,L
  SetLength(CodeWords,0);
  if TableRec[xInstr].rWhat=eDC then
    DoConst
  else begin
    DoLine;
    if not Parse(xInstr) then
      Error(Err_ASM1);
    ReturnCode;
  end;
end;

(******************************************************************************)
Procedure TUnit5b.AsmInitTables;

Procedure EnterName(Name: String);
var N: Integer; F: Boolean;
Const LastName: Str6='';
begin
  Name:=Trim(Name);
  F:=Name<>'';
  if Name='' then Name:=LastName; LastName:=Name;
  Inc(TableRecMax);
  if TableRecMax>=High(TableRec) then
    InternalError('Asm InitTables');
  TableRec[TableRecMax].rName:=Name; //Test
  TableRec[TableRecMax].rFirst:= F;
  N:=AsmSymb.IndexOf(Name);
  if N<0 then
    AsmSymb.AddObject(Name,Pointer(TableRecMax));
end;

Procedure Symb(Name: String; Cnt,Code: Integer; Size: eSize; Src,Dst: eRegs; Flags: eParmFlag);
begin
  EnterName(Name);
  with TableRec[TableRecMax] do begin
    rWhat:=eRec;
    rOpCnt:=Cnt;
    rOpSize:=Size;
    rOpFlags:=Flags;
    rOpSrc:=Src;
    rOpDst:=Dst;
    rOpCode:=Code;
  end;
end;

Procedure Sym0(Name: String; OPcnt,OPCode: Integer; Size: eSize; Src,Dst: eRegs);
begin
  Symb(Name,OPcnt,OPCode,Size,Src,Dst,FNONE);
end;

Procedure SymA(Name,Alias: String);
begin
  EnterName(Name);
  with TableRec[TableRecMax] do begin
    rWhat:=eInit;
    rAliasName:=Trim(Alias);
  end;
end;

Procedure EnterRegs(Name: String; B1,B2: Integer);
begin
  AsmRegs.AddObject(Name,Pointer(B1 shl 8 + B2));
end;

procedure FixupSymbols;
var M,N: Integer;
begin
  for N:=1 to TableRecMax do
    with TableRec[N] do
      if rWhat=eInit then begin
        M:=AsmSymb.IndexOf(rAliasName);
        if M<0 then
          InternalError('Asm InitFixup');
        M:=Integer(AsmSymb.Objects[M]);
        rWhat:=eAlias;
        rRecPtr:=M;
      end;
end;

begin {AsmInitTables}
  if TableRecMax>0 then EXIT;
  AsmSymb:=TStringList.Create; //Int(Object)= Index into TableRec. Alias are Neg(No)
  AsmSymb.Duplicates:=dupError; AsmSymb.Sorted:=True;

  AsmRegs:=TStringList.Create; //Int(Object)= (Dn,An,PC,Spec)<<8 + RegNo
  AsmRegs.Duplicates:=dupError; AsmRegs.Sorted:=True;

  EnterRegs('D0',0,0);                      //0=Dn
  EnterRegs('D1',0,1);
  EnterRegs('D2',0,2);
  EnterRegs('D3',0,3);
  EnterRegs('D4',0,4);
  EnterRegs('D5',0,5);
  EnterRegs('D6',0,6);
  EnterRegs('D7',0,7);

  EnterRegs('A0',1,0+8);                    //1=An
  EnterRegs('A1',1,1+8);
  EnterRegs('A2',1,2+8);
  EnterRegs('A3',1,3+8);
  EnterRegs('A4',1,4+8);
  EnterRegs('A5',1,5+8);
  EnterRegs('A6',1,6+8);
  EnterRegs('A7',1,7+8);
  EnterRegs('SP',1,7+8);

  EnterRegs('PC',2,0);                      //2=PC
  EnterRegs('CCR',3,1);                     //3=Special
  EnterRegs('USP',3,2);
  EnterRegs('SR',3,0);

  EnterName('DC'); TableRec[TableRecMax].rWhat:=eDC;

  SymA('ADD','ADDQ');
  SymA('','ADDI');
  SymA('','ADDA');
  Sym0('',	2,$D000,BWL6,ALL0,Dreg9);
  Sym0('',	2,$D100,BWL6,Dreg9,ALTMEM0);

  Sym0('ADDA',	2,$D0C0,WL18,ALL0,Areg9);
  Sym0('ADDI',	2,$0600,BWL6,Imm,ALTDATA0);
  Sym0('ADDQ',	2,$5000,BWL6,Imm3,ALT0);
  Sym0('ADDX',	2,$D100,BWL6,Dreg0,Dreg9);
  Sym0('',	2,$D108,BWL6,AregM0,AregM9);

  SymA('SUB','SUBQ');
  SymA('','SUBI');
  SymA('','SUBA');
  Sym0('',	2,$9000,BWL6,ALL0,Dreg9);
  Sym0('',	2,$9100,BWL6,Dreg9,ALTMEM0);

  Sym0('SUBA',	2,$90C0,WL18,ALL0,Areg9);
  Sym0('SUBI',	2,$0400,BWL6,Imm,ALTDATA0);
  Sym0('SUBQ',	2,$5100,BWL6,Imm3,ALT0);
  Sym0('SUBX',	2,$9100,BWL6,Dreg0,Dreg9);
  Sym0('',	2,$9108,BWL6,AregM0,AregM9);

  SymA('CMP','CMPI');
  SymA('','CMPA');
  Sym0('',	2,$B000,BWL6,ALL0,Dreg9);
  Sym0('CMPA',	2,$B0C0,WL18,ALL0,Areg9);
  Sym0('CMPI',	2,$0C00,BWL6,Imm,ALTDATA0);
  Sym0('CMPM',	2,$B108,BWL6,AregP0,AregP9);

  SymA('AND','ANDI');
  Sym0('',	2,$C000,BWL6,DATA0,Dreg9);
  Sym0('',	2,$C100,BWL6,Dreg9,ALTMEM0);
  Sym0('ANDI',	2,$0200,BWL6,Imm,ALTDATA0);
  Symb('',	2,$023C,B0,Imm,Spec,FSpecCCR); //to CCR
  Symb('',	2,$023C,N0,Imm,Spec,FSpecCCR); //to CCR ???
  Symb('',	2,$027C,W0,Imm,Spec,FSpecSR);  //to SR

  SymA('OR','ORI');
  Sym0('',	2,$8000,BWL6,DATA0,Dreg9);
  Sym0('',	2,$8100,BWL6,Dreg9,ALTMEM0);
  Sym0('ORI',	2,$0000,BWL6,Imm,ALTDATA0);
  Symb('',	2,$003C,B0,Imm,Spec,FSpecCCR);			//to CCR
  Symb('',	2,$003C,N0,Imm,Spec,FSpecCCR);			//to CCR ???
  Symb('',	2,$007C,W0,Imm,Spec,FSpecSR);			//to SR

  SymA('EOR',	'EORI');
  Sym0('',	2,$B100,BWL6,Dreg9,ALTDATA0);
  Sym0('EORI',	2,$0A00,BWL6,Imm,ALTDATA0);
  Symb('',	2,$0A3C,B0,Imm,Spec,FSpecCCR);			//to CCR
  Symb('',	2,$0A3C,N0,Imm,Spec,FSpecCCR);			//to CCR ???
  Symb('',	2,$0A7C,W0,Imm,Spec,FSpecSR);			//to SR

  Sym0('ASR',	2,$E020,BWL6,Dreg9,Dreg0);
  Sym0('',	2,$E000,BWL6,Imm3,Dreg0);
  Sym0('',	1,$E0C0,W0,ALTMEM0,None);

  Sym0('ASL',	2,$E120,BWL6,Dreg9,Dreg0);
  Sym0('',	2,$E100,BWL6,Imm3,Dreg0);
  Sym0('',	1,$E1C0,W0,ALTMEM0,None);

  Sym0('LSR',	2,$E028,BWL6,Dreg9,Dreg0);
  Sym0('',	2,$E008,BWL6,Imm3,Dreg0);
  Sym0('',	1,$E2C0,W0,ALTMEM0,None);

  Sym0('LSL',	2,$E128,BWL6,Dreg9,Dreg0);
  Sym0('',	2,$E108,BWL6,Imm3,Dreg0);
  Sym0('',	1,$E3C0,W0,ALTMEM0,None);

  Sym0('ROXR',	2,$E030,BWL6,Dreg9,Dreg0);
  Sym0('',	2,$E010,BWL6,Imm3,Dreg0);
  Sym0('',	1,$E4C0,W0,ALTMEM0,None);

  Sym0('ROXL',	2,$E130,BWL6,Dreg9,Dreg0);
  Sym0('',	2,$E110,BWL6,Imm3,Dreg0);
  Sym0('',	1,$E5C0,W0,ALTMEM0,None);

  Sym0('ROR',	2,$E038,BWL6,Dreg9,Dreg0);
  Sym0('',	2,$E018,BWL6,Imm3,Dreg0);
  Sym0('',	1,$E6C0,W0,ALTMEM0,None);

  Sym0('ROL',	2,$E138,BWL6,Dreg9,Dreg0);
  Sym0('',	2,$E118,BWL6,Imm3,Dreg0);
  Sym0('',	1,$E7C0,W0,ALTMEM0,None);

  Sym0('ABCD',	2,$C100,DB0,Dreg0,Dreg9);
  Sym0('',	2,$C108,DB0,AregM0,AregM9);

  Sym0('SBCD',	2,$8100,DB0,Dreg0,Dreg9);
  Sym0('',	2,$8108,DB0,AregM0,AregM9);

  Sym0('NBCD',	1,$4800,DB0,ALTDATA0,None);

  SymA('MOVE','MOVEQ');
  SymA('','MOVEA');
  Sym0('',	2,$0000,BWL12M,ALL0,ALTDATA6);
  Symb('',	2,$44C0,W0,DATA0,Spec,FSpecCCR);        //to CCR (IS a word!!)
  Symb('',	2,$46C0,W0,DATA0,Spec,FSpecSR);         //to SR
  Symb('',	2,$40C0,W0,Spec,ALTDATA0,FSpecSR);      //From SR
  Symb('',	2,$4E60,L0,Areg0,Spec,FSpecUSP);        //to USP
  Symb('',	2,$4E68,L0,Spec,Areg0,FSpecUSP);        //From USP
  Symb('',	2,$4E60,N0,Areg0,Spec,FSpecUSP);        //to USP ???
  Symb('',	2,$4E68,N0,Spec,Areg0,FSpecUSP);        //From USP ???

  Sym0('MOVEA',	2,$0040,WL212,ALL0,Areg9);
  Symb('MOVEM',	2,$48A0,WL16,RegListM,AregM0,FMOVEM);	//+0020 for -(An)
  Symb('',	2,$4C98,WL16,AregP0,RegListM,FMOVEM);	//+0018 for (An)+
  Symb('',	2,$4880,WL16,RegListM,ALTCONT0,FMOVEM);  //ALT-CONTROL (no (An)+ or -(An))
  Symb('',	2,$4C80,WL16,CONT0,RegListM,FMOVEM);

  Sym0('MOVEP',	2,$0108,WL16,DAY0,Dreg9);
  Sym0('',	2,$0188,WL16,Dreg9,DAY0);

  Sym0('MOVEQ',	2,$7000,L0,Imm08,Dreg9);

  Sym0('BCHG',	2,$0140,DB0,Dreg9,ALTDATA0);	//N0 ???
  Sym0('',	2,$0840,DB0,Imm16,ALTDATA0);

  Sym0('BCLR',	2,$0180,DB0,Dreg9,ALTDATA0);
  Sym0('',	2,$0880,DB0,Imm16,ALTDATA0);

  Sym0('BSET',	2,$01C0,DB0,Dreg9,ALTDATA0);
  Sym0('',	2,$08C0,DB0,Imm16,ALTDATA0);

  Sym0('BTST',	2,$0100,DB0,Dreg9,DATAC);	//Same as ALTDATA0 + d(PC,..)
  Sym0('',	2,$0800,DB0,Imm16,DATAC);

  Sym0('CHK',	2,$4180,W0,DATA0,Dreg9);

  Sym0('CLR',	1,$4200,BWL6,ALTDATA0,None);

  Sym0('TST',	1,$4A00,BWL6,ALTDATA0,None);

  Sym0('NEG',	1,$4400,BWL6,ALTDATA0,None);

  Sym0('NEGX',	1,$4000,BWL6,ALTDATA0,None);

  Sym0('NOT',	1,$4600,BWL6,ALTDATA0,None);

  Sym0('TAS',	1,$4AC0,B0,ALTDATA0,None);

  Sym0('DIVS',	2,$81C0,W0,DATA0,Dreg9);
  Sym0('DIVU',	2,$80C0,W0,DATA0,Dreg9);

  Sym0('MULS',	2,$C1C0,W0,DATA0,Dreg9);
  Sym0('MULU',	2,$C0C0,W0,DATA0,Dreg9);

  Sym0('EXG',	2,$C140,L0,Dreg0,Dreg9);
  Sym0('',	2,$C148,L0,Areg0,Areg9);
  Sym0('',	2,$C188,L0,Areg0,Dreg9);
  Sym0('',	2,$C188,L0,Dreg9,Areg0);

  Sym0('EXT',	1,$4880,WL16,Dreg0,None);	//OpMode = 010 or 011 (W or L)

  Sym0('LINK',	2,$4E50,N0,Areg0,Imm16);
  Sym0('UNLK',	1,$4E58,N0,Areg0,None);

  Sym0('STOP',	1,$4E72,N0,Imm16,None);

  Sym0('SWAP',	1,$4840,W0,Dreg0,None);

  Sym0('TRAP',	1,$4E40,N0,Imm04,None);
  Sym0('SYSTRAP', 1,$4E40+sysDispatchTrapNum,N0,Imm16SysTrap,None);  // Trap #15 + $A000

  Sym0('ILLEGAL',	0,$4AFC,N0,None,None);
  Sym0('NOP',	0,$4E71,N0,None,None);
  Sym0('RESET',	0,$4E70,N0,None,None);
  Sym0('RTE',	0,$4E73,N0,None,None);
  Sym0('RTR',	0,$4E77,N0,None,None);
  Sym0('RTS',	0,$4E75,N0,None,None);
  Sym0('TRAPV',	0,$4E76,N0,None,None);

  SymA('BNZ',	'BNE');
  SymA('BZE',	'BEQ');
  SymA('BHS',	'BCC');
  SymA('BLO',	'BCS');
  Symb('BCC',	1,$6400,SN,Lab,None,FJMP16);
  Symb('BCS',	1,$6500,SN,Lab,None,FJMP16);
  Symb('BEQ',	1,$6700,SN,Lab,None,FJMP16);
  Symb('BGE',	1,$6C00,SN,Lab,None,FJMP16);
  Symb('BGT',	1,$6E00,SN,Lab,None,FJMP16);
  Symb('BHI',	1,$6200,SN,Lab,None,FJMP16);
  Symb('BLE',	1,$6F00,SN,Lab,None,FJMP16);
  Symb('BLS',	1,$6300,SN,Lab,None,FJMP16);
  Symb('BLT',	1,$6D00,SN,Lab,None,FJMP16);
  Symb('BMI',	1,$6B00,SN,Lab,None,FJMP16);
  Symb('BNE',	1,$6600,SN,Lab,None,FJMP16);
  Symb('BPL',	1,$6A00,SN,Lab,None,FJMP16);
  Symb('BVC',	1,$6800,SN,Lab,None,FJMP16);
  Symb('BVS',	1,$6900,SN,Lab,None,FJMP16);

  SymA('DBNZ',	'DBNE');
  SymA('DBZE',	'DBEQ');
  SymA('DBHS',	'DBCC');
  SymA('DBLO',	'DBCS');
  SymA('DBRA',	'DBF');
  Symb('DBT',	2,$50C8,N0,Dreg0,Lab,FJMP16);
  Symb('DBF',	2,$51C8,N0,Dreg0,Lab,FJMP16);
  Symb('DBCC',	2,$54C8,N0,Dreg0,Lab,FJMP16);
  Symb('DBCS',	2,$55C8,N0,Dreg0,Lab,FJMP16);
  Symb('DBEQ',	2,$57C8,N0,Dreg0,Lab,FJMP16);
  Symb('DBGE',	2,$5CC8,N0,Dreg0,Lab,FJMP16);
  Symb('DBGT',	2,$5EC8,N0,Dreg0,Lab,FJMP16);
  Symb('DBHI',	2,$52C8,N0,Dreg0,Lab,FJMP16);
  Symb('DBLE',	2,$5FC8,N0,Dreg0,Lab,FJMP16);
  Symb('DBLS',	2,$53C8,N0,Dreg0,Lab,FJMP16);
  Symb('DBLT',	2,$5DC8,N0,Dreg0,Lab,FJMP16);
  Symb('DBMI',	2,$5BC8,N0,Dreg0,Lab,FJMP16);
  Symb('DBNE',	2,$56C8,N0,Dreg0,Lab,FJMP16);
  Symb('DBPL',	2,$5AC8,N0,Dreg0,Lab,FJMP16);
  Symb('DBVC',	2,$58C8,N0,Dreg0,Lab,FJMP16);
  Symb('DBVS',	2,$59C8,N0,Dreg0,Lab,FJMP16);

  SymA('SNZ',	'SNE');
  SymA('SZE',	'SEQ');
  SymA('SHS',	'SCC');
  SymA('SLO',	'SCS');
  Sym0('ST',	1,$50C0,B0,ALTDATA0,None);
  Sym0('SF',	1,$51C0,B0,ALTDATA0,None);
  Sym0('SCC',	1,$54C0,B0,ALTDATA0,None);
  Sym0('SCS',	1,$55C0,B0,ALTDATA0,None);
  Sym0('SEQ',	1,$57C0,B0,ALTDATA0,None);
  Sym0('SGE',	1,$5CC0,B0,ALTDATA0,None);
  Sym0('SGT',	1,$5EC0,B0,ALTDATA0,None);
  Sym0('SHI',	1,$52C0,B0,ALTDATA0,None);
  Sym0('SLE',	1,$5FC0,B0,ALTDATA0,None);
  Sym0('SLS',	1,$53C0,B0,ALTDATA0,None);
  Sym0('SLT',	1,$5DC0,B0,ALTDATA0,None);
  Sym0('SMI',	1,$5BC0,B0,ALTDATA0,None);
  Sym0('SNE',	1,$56C0,B0,ALTDATA0,None);
  Sym0('SPL',	1,$5AC0,B0,ALTDATA0,None);
  Sym0('SVC',	1,$58C0,B0,ALTDATA0,None);
  Sym0('SVS',	1,$59C0,B0,ALTDATA0,None);

  SymA('JSR',	'BSR');
  Symb('',	1,$4E80,N0,CONT0,None,FJMP32);
  Symb('BSR',	1,$6100,SN,Lab,None,FJMP16);

  SymA('JMP',	'BRA');
  Symb('',	1,$4EC0,N0,CONT0,None,FJMP32);
  Symb('BRA',	1,$6000,SN,Lab,None,FJMP16);

  Sym0('LEA',	2,$41C0,N0,CONT0,Areg9);
  Sym0('',	2,$41FA,SN,Lab,Areg9);		//LEA nn(pc),An
  Sym0('PEA',	1,$4840,N0,CONT0,None);
  Sym0('',	1,$487A,SN,Lab,None);		//PEA nn(PC)

  FixupSymbols;
end;

end.

