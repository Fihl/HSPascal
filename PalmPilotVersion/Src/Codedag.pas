Unit CodeDag;         //BPMark
{$B-}

interface

Uses Global, Util, Misc, Scanner, Dag, CodeReal;

Type
  eAddrPush= (DoFull, DoWaitWithVAR, DoPushAddr, DoWaitWithReload);
  tDag = Class;
  DagArray = array of tDag;
  tDag = Class (tDag1)
    ParmL, ParmR: tDag;
    ParmAfter: tDag; //Coded AFTER myself (pcSET!)
    ParmList: DagArray;
    ParmExit: tDag;
    //RegsUsed: tRegSet;  //UNUSED!!!!!!!!1
    TestUnitNo: Integer; //Breakpoint
    SrcNo: Integer;      //Only set if $L+
    SrcLine: Integer;    //Always set
    //TestProcNo: Integer;
    Procedure FreeFrom;
    Function  FindReg(Const WantedRegs: tRegSet): tEA;
    Procedure ReLoad;
    Procedure BindTo;
    //Function  UsedBy: tRegSet;
    Procedure Save;
    Procedure SaveAll(SingleReg: eReg=rNone);
    Procedure GenCode;
    //procedure CodeInstr(What: eCode; const lEA,rEA: tEA; Size: eEASize=easNone; CodeWhere: tDag1=NIL); override;
    //procedure CodeInstrEA(aOP: Word; const lEA: tEA);
    //procedure CodeInstr0(What: eCode); override;
    //procedure CodeInstr1(What: eCode; const lEA: tEA); override;
    //Procedure CodeRaw(W: Integer);
    //Procedure CodeRaw2(W,W2: Integer);
    Procedure FreeFromAll;
    Procedure CallSysProc(Proc: Integer; DoFreeFromAll: Boolean=True);
    procedure LoadX(var rEA: tEA; PreferedSize: eEASize); //p213
    procedure Load(var EA: tEA; Size: eEASize=easNONE); //p214
    procedure AddressRef(var EA: tEA; Option: eAddrPush=DoFull); //p211
    //procedure JumpCC(CC: eCondJumps; WhereTo: tDag; MakeJump: Boolean=True; BraOPC: Word=OpcBRA);
    Procedure WalkDagFirst;
    Procedure Walk1Dag;
    Procedure Label1Dag;
    Procedure SetDagRes(var EA: tEA; Typ: eType=TNON);
    Procedure SetDagResNoBind(var EA: tEA; Typ: eType=TNON);
    Procedure SetDagResStack(ResOType: eType; Size: eEASize);
    Procedure ConstructSetDesc;
    class function AddPCRelData(S: String; var aEA: tEA): Integer; //NOT first byte!
  private
    procedure STRTMP;
    procedure INTREA;
    procedure SETTMPPush;
    procedure CHRSTR(StoreDirect: pEA=NIL; MaxTemp: Integer=9999);
    procedure PushAddr;
    procedure FixOffset127LeaPea;
    procedure PushI(Size: eEASize=easW);
    procedure PushR;
    procedure PushConstI(N: Integer; Size: eEASize=easW);
    Procedure NewTmp(var EA: tEA; Size: Integer; EASize: eEASize=easL);
    Procedure PushNewTmp(var EA: tEA; Size: Integer; EASize: eEASize=easL);
    Procedure BinOp;
    Procedure CodeProcFuncRaw(ASysProcType: eSysProcType; OpCode: Word; Fix: TRef; Level: Integer; CodeWhere: tDag);
    Procedure DumpRegsUsage(Comment: String);
    procedure SetDagKCond(ccTrue: eCondJumps; CondD0Ok: Boolean=False);
  end;

Type
  TUnit2=Class(TUnit1)
    CodeEng: TCode68K;
    Dags: array of tDag;
    DagSort: array of tDag;          //Index into Dags
    DagSortInx: Integer;
    InsNotAllowed: Boolean;           {Set to check for only Constants}
    CurDagInx:	Integer;              {Global for testing!!!}
    CurProcSym: pSymRec;              {ONLY USED FOR one thing!!!}

    Constructor Create;
    Destructor Destroy; Override;
    Procedure dagInitializeProc(CurProcName: String; ProcSym: pSymRec);
    Function  dagCodeProc(Start: tDag; ProcSym: pSymRec; CurProcName: String): Integer; //Ret=CodegrpInx  //Make the code for 1 dag
    Procedure AllocateCodeBlock(G,CodeSizeW: Integer);

    Function  EnterDagDup(op: eP; op2: Integer; Comm: String; L,R: tDag; Sym: pSymRec; ConX: Integer): tDag;
    Function  EnterDag(o1: eP; o2: Integer; C: String): tDag;
    Procedure SetLeftRight(MySelf,L,R: tDag);

    Function  CodeIns(What: eP; op2: Integer; Left,Right: tDag; Comm: String=''): tDag;
    Function  CodeInsParam(Code: tDag): tDag;
    Function  CodeInsSTO(Left,Right: tDag; Comm: String): tDag;
    Function  CodeConst(Const C: Variant; OTYPE: eType): tDag;
    Function  CodeLD(Left,Right: tDag; Extra: tDag=NIL): tDag;
    Function  CodeVar(C: pSymRec; Comm: String): tDag;
    Function  CodeList(What: eP; op2: Integer; Const A: Array of tDag; Comm: String=''): tDag;

    Function  CodeJmpLabel(Const Comm: String): tDag;
    Function  CodeJmp(JumpCond: eCondJumps; Where: tDag; Comm: String): tDag;
    Function  CodeJmpASM(OpCode: Word; JumpCond: eCondJumps; Where: tDag; Comm: String): tDag;
    Function  CodeJmpCC(Where,Stmt: tDag; Comm: String): tDag;
    Function  CodeProcFunc(SysProcType: eSysProcType; OpCode: Word; Fix: TRef; Level: Integer; Comm: String): tDag;
    Function  CodeCallTrap(SysProcType: eSysProcType; Trap, StackUse: Integer): tDag;
    Function  CodeRawArray(var CodeData: CodeWordArray; Comm: String): tDag;
    Procedure DebugNStmt;
  private
  public
    Procedure StripCodeAdd(G: Integer; DoDebug: Boolean);
    Procedure StripCodeAddMain(Force, DoDebug: Boolean);
    Function  StripCodeGetTheCode(var AllCode: CodeWordArray): Integer;
    Function  AccumulateAllUnits(What: eAccumulateAllUnits): Integer;
  end;

Var
  PCRelData: String;
  CurCodeDag: tDag;

implementation

Uses {$ifdef VersionUI} DebugFrm, {$Endif}
     Global2, SysUtils;

Constructor TUnit2.Create;
begin
  Inherited;
  CodeEng:= TCode68K.Create;
end;

Destructor TUnit2.Destroy;
begin
  CodeEng.Free;
  Inherited
end;

function GlbUnit2(Inx: Integer): TUnit2;
begin
  if Inx>=GlbUnits.Count then Result:=NIL  // 0..Count-1
  else Result:=Pointer(GlbUnits.Objects[Inx]);
end;

{**********************************************************************}
Function GetCurCodeDag: tDag; //Error if not called when CurCodeDag valid
begin
  if CurCodeDag=NIL then
    InternalError0;
  Result:=CurCodeDag
end;

procedure CodeInstr(What: eCode; const lEA,rEA: tEA; aSize: eEASize=easNone);
var
  RetOPS: CodeWordArray;
  Fix: TRef;
  I,M,N: Integer;
  GCCD: tDag;
begin
  GCCD:=GetCurCodeDag;
  with GCCD do begin //Error if not called when CurCodeDag valid
    TUnit2(CurCodeDag.Owner).CodeEng.Code68K(RetOPS,What,lEA,rEA,aSize);
    //TUnit2(Owner).CodeEng.Code68K(RetOPS,What,lEA,rEA,Size);
    DagId68k:=Id;
    N:=Length(OpS); M:=Length(RetOPS);
    SetLength(OpS,N+M);
    for I:=N to N+M-1 do
      OpS[I]:=RetOpS[I-N];
    if lEA.EAh=EPDIS then begin
      SetLength(OpSFix,N+2);
      FillChar(Fix,SizeOf(Fix),0); Fix.FixUsed:=True;
      Fix.PCRel:=True;
      //Fix.UNo:= Fix.GrpInx:=
      OpSFix[N+1]:=Fix;
    end;
  end;
end;
procedure CodeInstr0(What: eCode);
begin
  CodeInstr(What,EA_None,EA_None)
end;
procedure CodeInstr1(What: eCode; const lEA: tEA);
begin
  CodeInstr(What,lEA,EA_None)
end;
procedure CodeInstrEA(aOP: Word; const lEA: tEA);
begin
  CodeInstr1(codEA,lEA);
  with CurCodeDag do
    Inc(OpS[High(OpS)], aOP);
end;

Procedure CodeRaw(W: Integer);
var I: Integer; GCCD: tDag;
begin
  GCCD:=GetCurCodeDag;
  with GCCD do begin //Error if not called when CurCodeDag valid
    I:=Length(OpS); SetLength(OpS,I+1);
    OpS[I]:=Word(W and $0000FFFF);
  end;
end;
Procedure CodeRaw2(W,W2: Integer);
begin
  CodeRaw(W);
  CodeRaw(W2);
end;

{**********************************************************************}

Procedure tDag.BindTo;  //p205
var R: eReg;
Procedure UseIt;
begin
  if not (R in RegsBind) then EXIT;
  if not (R in RegsFree) then
    if Regs[R].UsedByDag<>nil then
      if Regs[R].UsedByDag<>Self then
        InternalError('Register problems, already used:'+RegNames[R]+','+i2s(Regs[R].UsedByDag.Id));
  Exclude(RegsFree,R); Regs[R].UsedByDag:=Self; 
  Include(MaxRec,R);
  //Include(RegsUsed,R);
end;
begin
  with OpRec do case Kind of
    kConst: ;
    kTmp: ;
    kRef,
    kRes: //if InReg then
          begin
            R:=aEA.EAl; UseIt;
            R:=aEA.EAi; UseIt;
          end;
    kCond: //if kCondD0Ok then
           begin
            if kCondD0Ok then begin //=D0!
              R:=aEA.EAl; UseIt;
            end;
            R:=OpRec.ReservedReg.EAl; UseIt;
          end;
    Else  InternalError('BindTo');
    end;
end;

Procedure tDag.FreeFrom; //p206
var R: eReg;
Procedure FreeIt;
begin
  if not (R in RegsBind) then EXIT;
  if Regs[R].UsedByDag=NIL then EXIT;
  if R in RegsFree then
    if Regs[R].UsedByDag<>nil then
      InternalError('Register problems, Free1:'+RegNames[R]);
  if Regs[R].UsedByDag<>Self then
    InternalError(Format('Register problems, Free2:%s(%d)',[RegNames[R],Regs[R].UsedByDag.ID]));
  Include(RegsFree,R); Regs[R].UsedByDag:=NIL;
end;
begin
  if (Kind=kRes) and (OpRec.InReg=eADDR) then EXIT;
  with OpRec do case Kind of
    kConst: ;
    kTmp: ;
    kRef,
    kRes: //if InReg then
          begin
            R:=aEA.EAl; FreeIt;
            R:=aEA.EAi; FreeIt;
          end;
    kCond: //if kCondD0Ok then
          begin
            if kCondD0Ok then begin
              R:=aEA.EAl; FreeIt; //=D0!
            end;
            R:=OpRec.ReservedReg.EAl; FreeIt;
          end;
    ///Else  InternalError0;
    end;
end;

Procedure tDag.PushNewTmp(var EA: tEA; Size: Integer; EASize: eEASize=easL);
begin
  NewTmp(EA, Size, EASize);
  CodeInstr1(codPEA,EA);
end;

Procedure tDag.NewTmp(var EA: tEA; Size: Integer; EASize: eEASize=easL);
begin
  if Size>1 then CurAddrTemp:=EvenSize(CurAddrTemp);
  Dec(CurAddrTemp,Size);
  if MaxAddrTemp>CurAddrTemp then MaxAddrTemp:=CurAddrTemp;
  EA:=EA_A6IND; EA.EAofs:=CurAddrTemp;
  EA.EAsize:=EASize;
end;

Procedure tDag.SaveAll(SingleReg: eReg=rNone);
var R: eReg; OldDag: tDag;
procedure SaveAll1;
begin
  with Regs[R] do
    if (UsedByDag<>NIL) and (UsedByDag<>Self) then begin
      DumpRegsUsage('Save..'+i2s(tDag(UsedByDag).Id));
      OldDag:=CurCodeDag; CurCodeDag:=tDag(UsedByDag); //SEARCH10
      tDag(UsedByDag).Save;
      CurCodeDag:=OldDag; //SEARCH10
    end;
end;
begin
  R:=SingleReg;
  if R<>rNone then SaveAll1
  else
    for R:=RegFirst to RegLast do
      if R in RegsScratch then
        SaveAll1;
  //RegsUsed:=RegsUsed+RegsScratch;
end;

Procedure tDag.Save; //p206
var hEA, lEA, rEA: tEA; N: Integer; IsAddr,B: Boolean;
begin
  with OpRec do
  if aEA.EAh in [EAIXw,EAIXl,EADIS] then begin
    hEA:=aEA; lEA:=aEA; AddressRef(lEA);
    FreeFrom;
    if rA0 in RegsFree then rEA:=EA_A0
    else if rA1 in RegsFree then rEA:=EA_A1 else InternalError('Need another register!');
    CodeInstr(codLEA,lEA,rEA);
    //RegsFree:=RegsFree+[lEA.EAl,lEA.EAi]-[rEA.EAl];
    aEA:=rEA;
    aEA.EASize:=hEA.EASize; aEA.EAh:=EADIS;
    BindTo
  end;
  if Kind=kCond then
    Load(rEA,easB);
  B:=(OpRec.aEA.EAh=EAINC) and (OpRec.aEA.EAl=rA7);
  if B or (not (OpRec.aEA.EAl in RegsFree)) then
  if B or (OpRec.aEA.EAl in (RegsBind{-RegsWith})) then begin
    lEA:=OpRec.aEA;
    IsAddr:= OpRec.aEA.EAh=EADIS;
    if IsAddr then begin
      NewTmp(rEA,4,easL);
      MkEA(lEA,EAREG,lEA.EAl,0,easL);
      CodeInstr(codMOVE,lEA,rEA);
    end else begin
      N:=SpaceUsedWork[lEA.EAsize];
      NewTmp(rEA,N,lEA.EAsize);   //Both N=Size and EASize!!!
      CodeInstr(codMOVE,lEA,rEA);
    end;
    if (not B) and (Regs[lEA.EAl].UsedByDag=NIL) then
      InternalError('Register problems (Save):'+RegNames[lEA.EAl]+','+i2s(ID));
    //with Regs[lEA.EAl].UsedByDag,OpRec do
    FreeFrom;
    case Kind of
    kRes: begin
            OpRec.InReg:=eFalse;
            if IsAddr then OpRec.InReg:=eADDR
            else           OpRec.aEA:=rEA;
            OpRec.aEA.EAofs:=rEA.EAofs;
            //RegsFree:=RegsFree+[lEA.EAl];
          end;
    kCond:InternalError0;
    else  InternalError0;
    end;
  end;
  ///RegsFree:=RegsFree + [lEA.EAl]
end;

(***Function tDag.UsedBy: tRegSet; //p207
begin
  Result:=[];
  With OpRec do begin
    Case Kind of
    kTmp: ;
    kRef: if Indexed then Result:=[aEA.EAi];
    kConst: ;
    kRes: if InReg then Result:=[aEA.EAl];
    kCond: ;
    else  InternalError0;;;;;;
    end;
  end;
end; (***)

///Function BestFor: eReg; //p207
Function  tDag.FindReg(Const WantedRegs: tRegSet): tEA; //207

Function  FirstReg(Regs: tRegSet): eReg;
var R: eReg;
begin
  for R:=RegFirst to RegLast do
    if R in Regs then begin
      Result:=R;
      EXIT;
    end;
  Result:=rNONE;
end;

Function NextBest: eReg; //Cyclic buffer
var R: eReg; var B: Boolean;
begin
  B:=WantedRegs * RegsData <> [];
  inc(LastUsedReg[B]); R:=LastUsedReg[B];
  if not (R in WantedRegs) then //Find first reg if wraparound
    for R:=RegFirst to RegLast do
      if R in WantedRegs then BREAK;
  LastUsedReg[B]:=R;
  NextBest:=R;
end;

var RegsAvail: tRegSet; R,R2: eReg; M: tDag; Ok: Boolean;
//var n: Integer; i: tDag; rEA: tEA;
begin //FindReg
  ///////Result:=EA_Dn;
  R:=rNONE;
  //case First of
  //rD0: RegsAvail:=RegsFree*RegsData;
  //rA0: RegsAvail:=RegsFree*RegsAddr;
  //else
         RegsAvail:=RegsFree*WantedRegs; {Slow version just in case}
  //end;
  if RegsAvail=[] then begin
    (*****
    for n:=Last downto First do
      if  (Regs[n].UsedByDag<>NIL)
      and (Regs[n].UsedByDag in Vars.Unsaved) then
        R:=n;
    (****)
    if R=rNone then begin
      R2:=NextBest; //EndMark
      repeat
        R:=NextBest;
        m:=tDag(Regs[R].UsedByDag);
        Ok:= M=NIL;
        if Ok then BREAK;
        //with m.OpRec do Ok:=(Kind in [kRes,kRef]) and (aEA.EATempInx>0); {Ok=>Already saved}
      Until R=R2;
      Ok:=FALSE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      if not Ok then begin			{Save now}
        if RegsWith*WantedRegs<>[] then Error(Err_ComplicatedWith) else Error(Err_Complicated);
        R:=NextBest;
        (*****
        m:=NIL;
        repeat inc(m)
        until (m=MaxTemps) or (Temps.Temps[m].Dag=NIL);
        i:=Regs[R].UsedByDag;
        with i.OpRec,aEA do begin
          with Temps.Temps[m] do begin
            if dag<>0 then Error(Err_Error);
            dag:=i;	{UsedByDag}
            Size:=2;	{???<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<}
            Dec(CurAddrTemp,Size);
            Adr:=CurAddrTemp;
            rEA:=EA_A6IND; rEA.EAofs:=Adr;
            EAh:=EDREG;			{Prepare for real code}
            CodeInstr(codMOVE,aEA,rEA);
            EAh:=EADIS; EAl:=rA6; EATempInx:=i;
            Kind:=kRef; InReg:=False;
          end;
        end;
        (******)
      end;
    end;
  end else begin
    R:=FirstReg(RegsAvail);
    if WantedRegs * RegsData <> []
    then LastUsedReg[True] :=rD3	{In case no more regs}
    else LastUsedReg[False]:=rA0;	{In case no more regs}
  end;
  case R of
  rD0..rD7: Result:=EA_Dn;
  rA0..rA7: Result:=EA_An;
  else      Error(Err_ComplicatedWith);
  end;
  Result.EAl:=R;
  Include(MaxRec,R);
end;

Procedure tDag.ReLoad;
begin
  InternalError('Reload'); /////////////////////////////////////
end;

//Procedure tDag.SaveAllScratch; begin end;

procedure JumpCC(CC: eCondJumps; WhereTo: tDag; MakeJump: Boolean=True; BraOPC: Word=OpcBRA);
var
  GCCD: tDag;
begin
  GCCD:=GetCurCodeDag;
  with GCCD do begin //Error if not called when CurCodeDag valid
    if MakeJump then CodeRaw(BraOPC or mk68cc[CC] shl 8);
    SetLength(OpSFixLocal,Length(OpSFixLocal)+1);
    with OpSFixLocal[High(OpSFixLocal)] do begin
      Pos:=Length(OpS);
      Dag:=WhereTo;
    end;
    CodeRaw(2); //////TEST TEST
    //SkipWalkParmL:=True;
  end;
end;

//rEA is wanted reg
procedure tDag.LoadX(var rEA: tEA; PreferedSize: eEASize); //p213
var lEA: tEA; B: Boolean;
begin
  ///////////  if not (rEA.EAl in UsedBy) then
  ///////////    Save(rEA);
  with OpRec do begin
    ////rEA:=EA_Dn; rEA.EAl:=R;
    case Kind of
    kTmp,
    kRef:
      begin
        AddressRef(lEA);
        FreeFrom;
        B:=xxOTyp<>NIL;
        if B then
          B:=(CalcSizeBytes(xxOTyp)=1) and (xxOTyp^.TMAXV>127); // 'BYTE=0..255'
        if B then begin    //Unsigned
          rEA.EASize:=easL;
          CodeInstr(codMOVE,EA_imm0,rEA);
          rEA.EASize:=easB;
          CodeInstr(codMOVE,lEA,rEA);
          rEA.EASize:=easL; // Result in rEA
        end else begin
          rEA.EASize:=lEA.EASize;
          CodeInstr(codMOVE,lEA,rEA);
        end;
        Kind:=kRes; InReg:=eTrue;
      end;
    kConst:
      begin
        lEA:=EA_Imm0;
        lEA.EAofs:=ConI;
        rEA.EASize:=PreferedSize;
        if rEA.EASize=easNone then
          rEA.EASize:=ImmSize(lEA);
        CodeInstr(codMOVE,lEA,rEA);
        Kind:=kRes; InReg:=eTrue;
      end;
    kRes:
      case InReg of
      eTrue: begin
        AddressRef(lEA);
        FreeFrom;
        rEA.EAsize:=lEA.EAsize;
        if lEA.EAl<>rEA.EAl then
          CodeInstr(codMOVE,lEA,rEA);
      end;
      eFalse: begin
        AddressRef(lEA);
        FreeFrom;
        rEA.EAsize:=lEA.EAsize;
        CodeInstr(codMOVE,lEA,rEA);
        InReg:=eTrue;
      end;
      eADDR: begin
        rEA:=FindReg(RegsWorkAn);
        aEA.EAl:=EA_A6IND.EAl;
        CodeInstr(codMOVE,aEA,rEA,easL);
        MkEA(rEA,EADIS,rEA.EAl,0,aEA.EAsize);
        InReg:=eFalse;
      end;
      end;
    //kStk: {Later, check if used twice} CodeInstr(codMOVE,RegSP,ord(R),0);  {Increment!!!!!}
    kCond: //// //Condition (eCondJumps)
      begin
        if OpRec.ccTrue=CondNONE then InternalError('CondNONE');
        if not kCondD0Ok then begin //After SysTrap: Boolean, then D0 is Ok
          CodeInstrEA($50C0 + ord(mk68cc[OpRec.ccTrue]) shl 8, rEA); //Sne Scc //SEARCH2
          //CodeInstrEA($50C0 + ord(mk68cc[CondSwapCnd[OpRec.ccFalse]]) shl 8, rEA); //Sne Scc //SEARCH2
          CodeInstrEA($4400, rEA);                                              //NEG Dn  //SEARCH2
          OpRec.ccTrue:=CondNE;  // Flags killed
        end; /// else CodeInstr(codAND,EA_imm1,OpRec.aEA);;
        Kind:=kRes; InReg:=eTrue;
      end;
    else  InternalError0;
    end;

    if PreferedSize <> easNone then
      if rEA.EASize<PreferedSize then begin
        if (xxOTyp<>NIL) and (CalcSizeBytes(xxOTyp)=1) and (xxOTyp^.TMAXV>127) then begin // 'BYTE=0..255'
          rEA.EASize:=PreferedSize;    //Unsigned
          CodeInstr(codAND,EA_imm255,rEA);
        end else begin
          if (PreferedSize>=easW) and (rEA.EASize=easB) then begin
            rEA.EASize:=easW; CodeInstr1(codEXT,rEA)
          end;
          if PreferedSize=easL then begin
            rEA.EASize:=easL; CodeInstr1(codEXT,rEA)
          end;
        end;
      end;
  end;
  OpRec.aEA:=rEA;
  if TestMode then if OpRec.InReg=eTrue then if OpRec.aEA.EAh<>EDREG then
    InternalError('InReg1');
end;

//Do check all calls!!!!!!!!!!!!
procedure tDag.Load(var EA: tEA; Size: eEASize=easNONE); //p214
begin
  with OpRec do begin
    if (Kind=kRes) and (InReg=eTrue) then begin
      EA:=aEA;
      ///FreeFrom;
    end else begin
      //Optimize if size too small: moveq #0,Dn; move.b xx,Dn
      FreeFrom;
      EA:=FindReg(RegsWorkDn);
      LoadX(EA,Size{PreferedSize});
      aEA:=EA;
      BindTo; //SEARCH6
    end;
    if Size<>easNONE then
      if EA.EASize<Size then begin
        if (Size>=easW) and (EA.EASize=easB) then begin
          EA.EASize:=easW; CodeInstr1(codEXT,EA)
        end;
        if Size=easL then begin
          EA.EASize:=Size; CodeInstr1(codEXT,EA)
        end;
      end;
    //EA.EASize:=Size;
  end;
end;

(********** Procedure LoadAddr(X: eReg; rEA: tEA);
var lEA: tEA;
begin
  if not (X in RegsFree) then
    Save(X);			{A0/A1, never save?????}
  AddressRef(EA);
  CodeInstr(codLEA,X,0,0);
end; (**********)

class function tDag.AddPCRelData(S: String; var aEA: tEA): Integer; //NOT first byte!
begin
  Result:=Pos(S,PCRelData)-1; //1..n => 0..n-1
  if Odd(Result) or (Result<0) then begin
    Result:=Length(PCRelData);
    PCRelData:=PCRelData+S;
    if Odd(Length(PCRelData)) then
      PCRelData:=PCRelData+#0;
  end;
  MkEA(aEA,EPDIS,rNONE,Result,easB);
end;

procedure tDag.AddressRef(var EA: tEA; Option: eAddrPush=DoFull); //p211
var
  tempEA,lEA,rEA: tEA;
  AReg: eReg;
  N: Integer;
  S: String;
  FP: Record Case Integer of 1:(Sin: Single); 2: (I: Integer) end;
  PreSet: Boolean;
Function GetPreAddr: tEA;
Const PreAddrReg: tEA=();
begin
  if not PreSet then
    //if IsWith then PreAddrReg:=FindReg(RegsWith) else
    PreAddrReg:=FindReg(RegsWorkAn); //SEARCH5
  PreSet:=True;
  Result:=PreAddrReg;
end;
procedure CheckIndex;
var lEA,rEA: tEA;
begin
  with OpRec,aEA do if EAh in [EAIXw,EAIXl] then begin	{EAh=INDEX if Dn as index reg}
    FreeFrom;
    if (EAofs<-128) or (EAofs>127) then begin
      rEA:=GetPreAddr;
      lEA:=aEA; lEA.EAi:=rNONE; lEA.EAh:=EADIS; //  nn(A5), nn never 0!!
      CodeInstr(codLEA,lEA,rEA); //SEARCH9
      aEA.EAl:=rEA.EAl; aEA.EAofs:=0;
    end;
    BindTo;
  end;
  EA:=OpRec.aEA;
end;
begin
  if (Kind=kRes) and (OpRec.InReg=eADDR) then
    OpRec.Addressed:=False;
  PreSet:=False;
  if OpRec.Addressed then begin
    EA:=OpRec.aEA;
  end else begin
    OpRec.Addressed:=True;
    with OpRec do begin
      //if VVarF=vfXXX then
      //  Debug('VVarF not set!!');
      case Kind of
      kConst:
        begin
          case OTYPE of
          TPTR,TBOL,TCHR,TUSR,
          TINT: MkEA(aEA,EIMED,rNONE,ConI,aEA.EAsize);
          TREA: begin
                  FP.Sin:=ConstVal;
                  MkEA(aEA,EIMED,rNONE,FP.I,aEA.EAsize);
                end;
          TSTR: begin
                  S:=ConstVal+#0;   //S:=Char(Length(S))+S;
                  {N:=}AddPCRelData(S,aEA);
                  Kind:=kRef;
                end;
          else  InternalError0
          end;
          EA:=aEA;
        end;

      //kRes: if InReg then EA:=aEA else begin FreeFrom; {!!!!!!!!!!!already!!}   EA:=aEA; end;
      kTmp: EA:=aEA;
      kRes: if OpRec.InReg=eADDR  then begin
              if Option<>DoWaitWithReload then
                Load(EA)
            end else EA:=aEA;

      //kStk: MkEA(EA,EAINC,rA7,0,0);	{COULD BE PART OF kRes WITH EA SET EAINC}

      kCond: begin
               if kCondD0Ok and (rD0 in RegsFree) then begin
                 EA:=EA_D0Byte;
                 LoadX(EA,easB);
               end else begin
                 kCondD0Ok:=False;
                 EA:=ReservedReg;
                 LoadX(EA,easB);
                 //Load(EA,easB);
               end;
               aEA:=EA;
             end;
      kRef:
        with tempEA do begin
          tempEA:=aEA;		{Take copy (of EAofs&EAsize) before MkEA() calls}
          {AReg first set now if a0/a1, else none/A6 (or PC)}
          AReg:=rNONE;

          if OSLEV>0 then begin //SEARCH4
            //Parameter PreAddr
            //  PSLEV-SLEV = 2..
            //    MOVE.L 8(A6),A0
            //    MOVE.L 8(A0),A0      N times ,N= PSLEV-SLEV-1
            //    MOVE.L 8(A0),
            N:=Owner.SLEV-OpRec.OSLEV;
            //if op2=0 then rEA.EAl:=RegA_Ref else
            //  rEA.EAl:=RegA_Misc;
            for N:=1 to N do begin
              if N=1 then rEA:=GetPreAddr;
              lEA:=aEA; lEA.EAOfs:=8;
              aEA.EAl:=rEA.EAl;
              CodeInstr(codMOVE,lEA,rEA,easL); //SEARCH9);  //BindTo SEARCH5
            end;
            //aEA.EAOfs:=tempEA.EAOfs; //Original offset
            tempEA:=aEA;
          end;

          //if OSym<>NIL then
          if AReg=rNONE then
            case OpRec.VVARF of  //OpRec.Sym^.VVARF of
            vfGlobal:	AReg:=RegA_Global;
            vfDeref,
            vfVarCopy,
            vfLocal:	AReg:=aEA.EAl;  //////////// !!AReg:=RegA_Local;  //SEARCH4
            vfVarConst,
            vfVar:      begin    ///////////////    //SEARCH1
                          AReg:=aEA.EAl;
                          (*****AReg:=PreAddrReg;
                          MkEA(rEA,EADIS,RegA_Local,tempEA.EAofs,easL);
                          MkEA(tempEA,EAREG,AReg,0,easL);
                          CodeWhere.CodeInstr(codMOVE,rEA,tempEA);
                          OpRec.VVarF:=True; (*******)
                        end;
            else        InternalError0
            end;
          if EAh in [EAIXw,EAIXl] then begin
            ReLoad;	{Restore now}
            //if (OpRec.Sym^.VVARF=vfGlobal) then begin
            //if AReg=rNONE then MkEA(EA,EABSL,rNONE,EAofs)
            //else
              MkEA(EA,EADIS,AReg,EAofs,easW);
            rEA:=EA;
            EA:=GetPreAddr; //MkEA(EA,EAREG,PreAddrReg,0,easW); EAofs:=0;
            CodeInstr(codLEA,rEA,EA); //SEARCH9);
            AReg:=GetPreAddr.EAl;
          end;
          if not (EAh in [EAIXw,EAIXl]) then begin	{EAh=INDEX if Dn as index reg}
            if AReg=rNONE then InternalError0 ////MkEA(EA,EABSL,rNONE,EAofs)
            else begin
              if EAofs=0 then MkEA(EA,EAIND,AReg,0,aEA.EAsize)
              else            MkEA(EA,EADIS,AReg,EAofs,aEA.EAsize);
            end;
          end;
          aEA:=EA;
          CheckIndex;
        end;
      else InternalError0;
      end;
      ///////// CFCF FreeFrom; {!!!!!!!!!!! always call this as a signal}
    end;
    if (op=pcPROCFUNC) and (SysProcType=eFuncD0) then
      SaveAll(rD0);
    if not ((Kind=kRes) and (OpRec.InReg=eADDR)) then
      //if Option<>DoWaitWithReload then
      BindTo;
  end;
  case Option of
  DoWaitWithReload,DoWaitWithVAR: ;
  DoFull:
    begin
      CheckIndex;
      if OpRec.VVarF in [vfVar,vfVarConst] then with OpRec do begin
        FreeFrom; {!!!!!!!!!!! always call this as a signal}
        OpRec.VVarF:=vfDeref;
        //AReg:=PreAddrReg;
        //MkEA(rEA,EADIS,RegA_Local,tempEA.EAofs,easL);
        //MkEA(tempEA,EAREG,PreAddrReg,0,easL);
        //CodeWhere.CodeInstr(codMOVE,rEA,tempEA);
        //xx MkEA(rEA,EADIS,RegA_Local,tempEA.EAofs,easL);
        tempEA:=GetPreAddr;  //MkEA(tempEA,EAREG,PreAddrReg,0,easL);    //SEARCH1
        CodeInstr(codMOVE,EA,tempEA); //SEARCH9);
        MkEA(aEA,EADIS,GetPreAddr.EAl,0,aEA.EAsize);
        EA:=aEA;
        BindTo;
      end;
    end;
  DoPushAddr:
    begin
      CheckIndex;
      FreeFrom;
      if (Kind=kConst) and (OpRec.OTYPE=TCHR) then begin
        AddPCRelData(ConS+#0,OpRec.aEA);
        OpRec.VVARF:=vfPCRel;
        OpRec.FKind:=kRef;
      end;
      if OpRec.VVarF in [vfVar,vfVarConst] then with OpRec do begin
        CodeInstr(codMOVE,EA,EA_A7PushL); //SEARCH9);
        OpRec.VVarF:=vfDeref;
        EA:=EA_A7PopL;
      end else begin
        if OpRec.aEA.EAh=EIMED then
          InternalError('PushAddr(Imm)!!');
        OpRec.VVarF:=vfDeref;
        CodeInstr1(codPEA,EA); //SEARCH9);
      end;
    end;
  end;
end; //AddressRef

procedure tDag.FixOffset127LeaPea;
var lEA,rEA: tEA; Ofs: Integer;
begin
  with OpRec,aEA do if EAh in [EAIXw,EAIXl] then
  if not IsOfsInt8(aEA) then begin	{EAh=INDEX if Dn as index reg}
    if aEA.EAl in RegsScratch then begin    //nnnn(Dn,A0) => 0(Dn,A0)
      FreeFrom;
      rEA:=EA_An; rEA.EAl:=aEA.EAl;
      lEA:=aEA; lEA.EAi:=rNONE; lEA.EAh:=EADIS;
      CodeInstr(codLEA,lEA,rEA);
      aEA.EAl:=rEA.EAl; aEA.EAofs:=0;
      BindTo;
    end else begin   //nnnn(Dn,A6) => nnnn(A0)
      FreeFrom;
      Ofs:=aEA.EAofs;
      lEA:=aEA; lEA.EAofs:=0;
      rEA:=FindReg(RegsWorkAn);
      CodeInstr(codLEA,lEA,rEA);
      aEA:=rEA; aEA.EAofs:=Ofs; aEA.EAh:=EADIS; lEA.EAi:=rNONE;
      BindTo;
    end;
  end;
end;

procedure tDag.PushAddr;
var lEA: tEA;
begin
  if Self=NIL then EXIT;
  case Kind of
  kRes: begin
          FixOffset127LeaPea;
          case OpRec.InReg of
          eFalse: CodeInstr1(codPEA,OpRec.aEA);
          eADDR:  begin
                    lEA:=EA_A6IND; lEA.EAofs:=OpRec.aEA.EAofs;
                    CodeInstr(codMOVE,lEA,EA_A7PushL,easL);
                  end;
          eTrue: ;
          else    InternalError('InReg!'); // eTrue
          end;
        end;
  //kRef:  //Do not make MOVE.L 8(A6),A0      PEA (A0) !!
  else
    //V1.AddressRef(V1.OpRec.aEA,DoPushAddr,Self);   //SEARCH9
    AddressRef(OpRec.aEA,DoPushAddr);   //SEARCH9
  end;
  FreeFrom;
end;

procedure tDag.PushR;
begin
  INTREA;
  PushI(easL);
end;

procedure tDag.PushI(Size: eEASize=easW);
var EA: tEA; N: Integer;
begin
  AddressRef(EA);
  if OpRec.aEA.EAh=EIMED then begin
    if Size<=easW then PushConstI(EA.EAofs,Size)
    else begin
      EA.EASize:=Size;
      if (EA.EASize=easL) and ImmTst(EA.EAofs,-32768,32767) then
        EA.EASize:=easW;
      CodeInstr1(codPEA,EA);
    end;
  end else begin
    if EA.EASize=Size then begin
      if not ((EA.EAh=EAINC) and (EA.EAl=rA7)) then begin //Skip if NOP move (sp)+,-(sp)
        EA_A7PushNoS.EAsize:=Size;
        CodeInstr(codMOVE,EA,EA_A7PushNoS);
      end;
    end else begin
      if (EA.EASize>Size) and (EA.EAh in [EAIND,EADIS]) then begin
        N:=0;
        //mk68K specific!!!
        if (EA.EAsize=easW) and (Size=easB) then N:=1;
        if (EA.EAsize=easL) and (Size=easW) then N:=2;
        if (EA.EAsize=easL) and (Size=easB) then N:=3;
        EA.EAh:=EADIS; Inc(EA.EAofs,N);
      end else
        Load(EA,Size);
      EA_A7PushNoS.EAsize:=Size;
      CodeInstr(codMOVE,EA,EA_A7PushNoS);
    end;
  end;
  FreeFrom;
end;

procedure tDag.PushConstI(N: Integer; Size: eEASize=easW);
begin
  EA_immWn.EAofs:=N;
  CodeInstr(codMOVE,EA_immWn,EA_A7PushNoS,Size);
end;

(***********
PACSTR	MOVE.L	OTYPP(A0),A6
	CMP.W	#TPAC,TTYPE(A6)
	BNE.S	@99
	MOVE.L	TMAXV(A6),D0		;=2 or 3 then make string OPCON
	CMP.W	#256,D0
	Err_	CC,TypeMismatch
	CMP.B	#OPSTR,OMODE(A0)
***********)

procedure tDag.STRTMP;
begin
  if Kind<>kTmp then begin
    PushAddr;
    PushNewTmp(OpRec.aEA,MaxStringM1+1);
    CallSysProc(ISysStrLd);
    OpRec.OTYPE:=TSTR;
    OpRec.FKind:=kTmp;
  end;
end;

procedure tDag.SETTMPPush; //Does nothing if doing MockupSet
begin
  if not OpRec.MockupSet then begin
    if (Kind<>kTmp) then begin
      PushAddr;
      PushNewTmp(OpRec.aEA,32);
      if OpRec.SetDesc=0 then
        InternalError('Set1');
      PushConstI(OpRec.SetDesc,easL);
      CallSysProc(ISysSetLd);
      OpRec.OTYPE:=TSET;
      OpRec.FKind:=kTmp;
      OpRec.SetDesc:=$00000020; //Ofs=0, Size=32
      OpRec.xxOTyp:=@StandardType[xTmpSet];
    end;
    PushAddr;
  end;
  OpRec.MockupSet:=False;
end;

procedure tDag.CHRSTR(StoreDirect: pEA=NIL; MaxTemp: Integer=9999);
//const EA_immB1: tEA=(EAh: EIMED; EAl:rNONE; EAi:rNONE; EAofs: 1; EASize: easB);
const EA_imm8:  tEA=(EAh: EIMED; EAl:rNONE; EAi:rNONE; EAofs: 8; EASize: easB);
var   EA,EAres: tEA;
begin
  if OPREC.OTYPE in [TCHR,TINT] then begin
    MaxTemp:=Min(MaxTemp,MaxStringM1+1);
    if StoreDirect<>NIL then EAres:=StoreDirect^
    else NewTmp(EAres,MaxTemp,easW); //256,easW);  //2 or kTmp(256) ???
    AddressRef(EA);
    FreeFrom;
    if Kind=kConst then begin
      EA_immWn.EAofs:=(lo(ConI) shl 8); ///$0100+Lo(ConI);
      CodeInstr(codMOVE,EA_ImmWn,EAres,easW);   //MOVE #xx00,ea
    end else begin
      //AddressRef(EA);
      //EA.EASize:=easB;
      //CodeInstr(codMOVE,EA_ImmB1,EAres,easB);
      //Inc(EAres.EAofs); CodeInstr(codMOVE,EA,EAres,easB); Dec(EAres.EAofs);
      //1: move #0100,ae  & move char,1(ea)
      //2: move $0100,Dn, move.b ch,Dn, move Dn,temp
      //3: load Dn, bind, and #255,Dn

      CodeInstr(codMOVE,EA,EAres,easB);
      EAres.EASize:=easB; Inc(EAres.EAofs); CodeInstr1(codCLR,EAres); Dec(EAres.EAofs);

      //not better. uses 3 lines! Load(EA,easB); CodeInstr(codSHL,EA_Imm8,EA);
      //CodeInstr(codMOVE,EA,EAres,easW);
    end;
    OpRec.aEA:=EAres;
    OpRec.OTYPE:=TSTR;
    OpRec.FKind:=kTmp;
  end;
end;

procedure tDag.INTREA;
begin
  if OpRec.OTYPE=TINT then begin
    if Kind=kConst then
      OpRec.OTYPE:=TREA  //R:=ConI; OpRec.ConstVal:=R;
    else begin
      PushI(easL);
      CallSysProc(FRealLoadI);
      SetDagResStack(TREA,easL);
    end;
  end;
end;

procedure tDag.SetDagRes(var EA: tEA; Typ: eType=TNON);
begin
  SetDagResNoBind(EA,Typ);
  BindTo;
end;
procedure tDag.SetDagResNoBind(var EA: tEA; Typ: eType=TNON);
begin
  with OpRec do begin
    if Typ<>TNON then OTYPE:=Typ;
    aEA:=EA;
    Kind:=kRes;
    case aEA.EAh of
    EDREG,EAREG:
      begin
        InReg:=eTrue;
        //if TestMode then if aEA.EAh<>EDREG then
        //  InternalError('InReg2');
      end;
    else InReg:=eFalse;
    end;
  end;
end;

procedure tDag.SetDagResStack(ResOType: eType; Size: eEASize);
begin
  with OpRec do begin
    Kind:=kRes; InReg:=eFalse;
    OpRec.OTYPE:=ResOType;
    aEA:=EA_A7PopL;
    xxRefCnt:=999;;;;;;;;;
    OpRec.aEA.EAsize:=Size;
  end;
end;

Procedure TDag.ConstructSetDesc;
var m,n: Integer;
begin
  if OpRec.OTYPE=TSET then begin
    //if Glb.TestPtr=nil then
    //  Glb.TestPtr:=@OpRec.xxOTyp^.TELEP;
    if OpRec.xxOTyp^.TELEP=NIL then
      InternalError('Set problems2');
    n:=OpRec.xxOTyp^.TELEP^.TMINV;
    m:=OpRec.xxOTyp^.TELEP^.TMAXV;
    //if (n<0) or (m>0) then EXIT;
    n:=lo(n) div 8; m:=(lo(m) + 7) div 8;
    OpRec.SetDesc:=n shl 16+(m-n); //Ofs, Size
  end;
end;

procedure tDag.SetDagKCond(ccTrue: eCondJumps; CondD0Ok: Boolean=False);
begin
  if ccTrue=CondNONE then InternalError('CondNONE2');
  OpRec.OTYPE:=TBOL;
  OpRec.FKind:=kCond;
  OpRec.ccTrue:=ccTrue;
  OpRec.kCondD0Ok:=CondD0Ok; //True: then FKind could as well be kRes!
  OpRec.ReservedReg:=FindReg(RegsWorkDn); //Load(rEA,easB);
  //BindTo; Done later
end;

procedure tDag.BinOp;
{Oper=op0,opEQ,opNE,opGT,opLT,opGE,opLE,
          opADD,opSUB,opOR,opXOR,
          opMUL,opRDV,opDIV,opMOD,opAND,opSHL,opSHR}
var Help,Left,Right: tDag;
var hEA,lEA,rEA: tEA;
var Oper: eSubBinOPs;
var UseRegL: Boolean;
Const MaxTyp: array[BinOpTyp,BinOpTyp] of eType=(
      { TSET  TPAC  TPTR  TSTR  TREA  TINT  TBOL  TCHR  TUSR
{TSET} (TSET, tnon, tnon, tnon, tnon, tnon, tnon, tnon, tnon ),
{TPAC} (tnon, TSTR, tnon, TSTR, tnon, tnon, tnon, TSTR, tnon ),
{TPTR} (tnon, tnon, TPTR, tnon, tnon, tnon, tnon, tnon, tnon ),
{TSTR} (tnon, TSTR, tnon, TSTR, tnon, tnon, tnon, TSTR, tnon ),
{TREA} (tnon, tnon, tnon, tnon, TREA, TREA, tnon, tnon, tnon ),
{TINT} (TSET, tnon, tnon, tnon, TREA, TINT, tnon, tnon, TINT ),
{TBOL} (TSET, tnon, tnon, tnon, tnon, tnon, TBOL, tnon, TBOL ),	{????=TBOL???}
{TCHR} (TSET, TSTR, tnon, TSTR, tnon, tnon, tnon, TSTR, TCHR ),
{TUSR} (TSET, tnon, tnon, tnon, tnon, TINT, TBOL, TCHR, TUSR ) );

Procedure FreeLR;
begin
  Left.FreeFrom;
  Right.FreeFrom;
end;

// Set: +, -, *, eq, ne, ge, le, IN
procedure DoTSET;
var OP: Integer;
begin
  if Oper=opSIN then begin
    if (Right.opRec.xxOTYP=NIL) or (Right.opRec.xxOTYP^.TSIZE<>32) then
      Right.SETTMPPush  //Does nothing if doing MockupSet
    else
      Right.PushAddr;
    Left.PushI(easW);
    CallSysProc(ISysSetIn);
    SetDagKCond(CondNE,True); //kCondD0Ok!
    //SetDagKCond(CondSwapCnd[CondNE],True); //kCondD0Ok!
    EXIT;
  end;
  case Oper of
  opADD: OP:=ISysSetUnion;
  opSUB: OP:=ISysSetDiff;
  opMUL: OP:=ISysSetInter;
  opEQ,
  opNE:  OP:=ISysSetEQ;
  opGE:  OP:=ISysSetGE; 
  opLE:  OP:=ISysSetLE;
  else   OP:=0; InternalError('Set');
  end;
  CurCodeDag:=Left; //SEARCH10
  Left.SETTMPPush;  //Does nothing if doing MockupSet
  CurCodeDag:=Self; //SEARCH10
  Right.SETTMPPush;  //Does nothing if doing MockupSet
  OpRec.OTYPE:=TSET;
  OpRec.aEA:=Left.OpRec.aEA;
  OpRec.SetDesc:=$00000020; //Ofs=0, Size=32
  OpRec.xxOTyp:=@StandardType[xTmpSet];
  Kind:=kTmp;
  case Oper of
  opEQ,opGE,
  opLE: SetDagKCond(CondEQ);
  opNE: SetDagKCond(CondNE);
  //opLE: SetDagKCond(CondSwapCnd[CondEQ]);
  //opNE: SetDagKCond(CondSwapCnd[CondNE]);
  //opADD,opSUB,opMUL: ;
  end;
  CallSysProc(OP);
end;


procedure DoTINT; Forward;

procedure DoTSTR; //Strings
begin
  //ISysStrLd       = 20; //Str to Str
  //ISysStrSto      = 21; //Str to Str, Len
  //xxISysStrLdChar   = 22; //Pack to Str, Len
  //ISysStrCmp      = 23; //Str,Str => CCR
  //ISysStrAdd      = 24; //Str:+Str
  if (Oper<>opAdd) and (Left.OpRec.OTYPE=TCHR) and (Right.OpRec.OTYPE=TCHR) then begin
    DoTINT;
    EXIT;
  end;
  //CurCodeDag:=Left; //SEARCH10
  Left.CHRSTR;
  Left.AddressRef(lEA,DoWaitWithVAR);
  //CurCodeDag:=Self; //SEARCH10

  case Oper of
  opADD:
    begin
      Left.STRTMP;
      Right.CHRSTR(NIL,2);
      Right.AddressRef(rEA,DoWaitWithVAR);
      Right.PushAddr;
      Left.PushAddr;
      CallSysProc(ISysStrAdd); //(Src,Dst)
      OpRec.OTYPE:=TSTR;
      Left.FreeFrom; // already done in pushaddr!!
      OpRec.aEA:=Left.OpRec.aEA;
      Kind:=kTmp;
    end;
  opEQ,opNE,opGT,opLT,opGE,opLE:
    begin
      Right.CHRSTR(NIL,2);
      Right.AddressRef(rEA,DoWaitWithVAR);
      Right.PushAddr;
      Left.PushAddr;
      CallSysProc(ISysStrCmp);
      SetDagKCond(ccCodes[Oper],False)
      //SetDagKCond(CondSwapCnd[ccCodes[Oper]],False)
    end;
  else InternalError('BinOP TSTR');
  end;
end;

//If Right on stack, then Left cannot be too!
Procedure CheckNotBothOnStack(L,R: tDag); //if NOT transitiv!!
var lEA: tEA;
begin
  if  (R.OpRec.aEA.EAh=EAINC) and (R.OpRec.aEA.EAl=rA7)
  and (L.OpRec.aEA.EAh=EAINC) and (L.OpRec.aEA.EAl=rA7) then begin
    CurCodeDag:=L; //SEARCH10
    L.AddressRef(lEA);
    //L.Load(lEA);
    L.Save; // and freefrom
    CurCodeDag:=Self; //SEARCH10
  end;
end;

procedure DoTREA;
begin
  CurCodeDag:=Left; //SEARCH10
  Left.PushR; //C stack style
  CurCodeDag:=Self; //SEARCH10
  Right.PushR; //C stack style

  SetDagResStack(TREA,easL);
  //OpRec.OTYPE:=TREA;
  //OpRec.aEA:=EA_A7PopL;

  //Ok OpRec.aEA.EASize:=easL;
  Case Oper of
  opADD: CallSysProc(FRealAdd);
  opSUB: CallSysProc(FRealSub);
  opMUL: CallSysProc(FRealMul);
  opRDV: CallSysProc(FRealDiv);
  opEQ,opNE,opGT,opLT,opGE,opLE:
    begin
      CallSysProc(FRealCmp);
      OpRec.OTYPE:=TBOL;
      //Real (FP) compare MUST return both D0 and flags set as after "TST.B D0"
      SetDagKCond(ccCodes[Oper],False); //kCondD0Ok:=False!
      //SetDagKCond(CondSwapCnd[ccCodes[Oper]],False); //kCondD0Ok:=False!
    end;
  else InternalError('DoTREA');
  end;
end;

procedure DoTINT;                       //Left OP Right
var
  LeftImm,RightImm: Boolean;
  Size: eEASize; //Size for operation
  Procedure SetNormal;
  begin
    if RightImm then begin
      Right.AddressRef(rEA);  //SIZE=??
      Left.Load(lEA,easNONE{,rEA.EAsize});        //SEARCH2
      CodeInstr(BinCode[Oper],rEA,lEA);
      FreeLR;
      SetDagResNoBind(lEA);           //SEARCH3
    end else begin
      Left.AddressRef(lEA);  //SIZE=??
      if not LeftImm then
        if Left.Size<{Right.}Size then begin  //22-2-2002
          Left.Load(lEA,{Right.}Size);
          Right.AddressRef(rEA);
          CodeInstr(BinCode[Oper],rEA,lEA);
          SetDagResNoBind(lEA);          //SEARCH3
          EXIT;
        end;
      Right.Load(rEA,lEA.EAsize);        //SEARCH2
      CodeInstr(BinCode[Oper],lEA,rEA);
      FreeLR;
      SetDagResNoBind(rEA);              //SEARCH3
    end;
  end;
begin //DoTINT
  CurCodeDag:=Left; //SEARCH10 SEARCH12
  Left.AddressRef(lEA,DoWaitWithReload);
  CurCodeDag:=Self; //SEARCH10 
  Right.AddressRef(rEA);

  Size:=Left.Size;
  if Size<Right.Size then Size:=Right.Size;

  //if false then
  if (not (Oper in ([{opRDV,}opDIV,opMOD,opSUB,opSHL,opSHR]))) then
    if (Left.OpRec.aEA.EAh=EIMED) {or (Right.Cost<Left.Cost)} then begin
      Help:=Left; Left:=Right; Right:=Help;
      hEA:=lEA; lEA:=rEA; rEA:=hEA;
      if not (Oper in [opEQ,opNE]) then
        OpRec.ccTrue:=CondSwapCnd[OpRec.ccTrue];
        //OpRec.ccFalse:=CondSwapCnd[OpRec.ccFalse];
    end;
  Left.AddressRef(lEA);
  Right.AddressRef(rEA);

  RightImm:= Right.OpRec.aEA.EAh=EIMED;
  LeftImm:=  Left.OpRec.aEA.EAh=EIMED;
  //Right is Imm (maybe)  ///////or Left.Cost xx Right.Cost.  Except for DIVs SHIFTs and IN
  if LeftImm and RightImm then
    Left.Load(lEA,MinSize(Left,Right)); //Never done, as Syntax part of BinOp should handle Imm binops!  !!IS DONE!!!!
  case Oper of
  opEQ,opNE:
    begin
      //if Left.Size<Right.Size then
      //  Left.Load(lEA,Right.Size);
      if not RightImm then Left.Load(lEA,Size);
      CodeInstr(codCMP,rEA,lEA);
      FreeLR;
      SetDagKCond(OpRec.ccTrue);
      //SetDagKCond(OpRec.ccFalse);
    end;
  opGT,opLT,opGE,opLE:
    begin
      //CMP #nn,<ea>
      //CMP <ea>,Dn
      CheckNotBothOnStack(Left,Right);           //NOT transitiv!!
      Left.AddressRef(lEA);
      if not RightImm then Left.Load(lEA,Size);
      CodeInstr(codCMP,rEA,lEA);
      FreeLR;
      SetDagKCond(OpRec.ccTrue);
      //SetDagKCond(OpRec.ccFalse);
    end;
  opMUL:
    begin
      if (not RightImm) and (Right.Size<easW) then begin
        Right.Load(rEA,easW);
        RightImm:=False;
      end;
      if (not LeftImm)  and (Left.Size<easW) then begin
        Left.Load(lEA,easW);
        LeftImm:=False;
      end;
      if (Left.SizeNoImm=easL) or (Right.SizeNoImm=easL) then begin
        Left.PushI(easL);
        Right.PushI(easL);
        CallSysProc(ISys32Mul);
        SetDagResStack(TINT,easL); //OpRec.aEA:=EA_A7PopL;
      end else begin
        if rEA.EAh<>EDREG then begin
          Right.Load(rEA,easW);
          RightImm:=False;
        end;
        SetNormal;
        SetSize(easL);
      end;
    end;
  opADD: SetNormal;
  opOR,opXOR,opAND:
    begin
      if Oper=opXOR then begin  //22-2-2002
        Right.Load(rEA,Size);   //22-2-2002
        if not LeftImm then
          Left.Load(lEA,Size);   //22-2-2002
        //Right.OpRec.aEA.EASize:=Size; Left.OpRec.aEA.EASize:=Size;
      end;
      SetNormal;
      if Left.OpRec.OTYPE=TBOL then
        SetDagKCond(CondSwapCnd[CondNE],OpRec.aEA.EAl=rD0); ///
        //SetDagKCond(CondSwapCnd[ccCodes[Oper]],OpRec.aEA.EAl=rD0); ///
    end;
  opSUB:
    begin
      CheckNotBothOnStack(Left,Right); //NOT transitiv!!
      Left.Load(lEA,easNone); //rEA.EAsize);  //rEA.EAsize ?????
      Right.AddressRef(rEA);
      if RightImm and (rEA.EASize>lEA.EASize) then   //Do in more general proc
        rEA.EASize:=lEA.EASize;
      CodeInstr(BinCode[Oper],rEA,lEA);
      //Right.FreeFrom;
      SetDagResNoBind(lEA);
    end;
  opDIV,opMOD:
    begin  //L,L, not L,L(imm) if imm<32000
      CheckNotBothOnStack(Left,Right); //NOT transitiv!!
      if (not IsImmInt16(Right.OpRec.aEA)) and (rEA.EASize=easL) then begin
        Left.PushI(easL);
        Right.PushI(easL);
        if Oper=opDIV then CallSysProc(ISys32Div) else CallSysProc(ISys32Mod);
        SetDagResStack(TINT,easL); //OpRec.aEA:=EA_A7PopL;
      end else begin
        UseRegL:=True;
        (*******
        if ((Dags[left].OpRec.Kind=kRes) and (Dags[left].OpRec.ResReg<>rNone)) or
           ((Dags[right].OpRec.Kind=kRes) and (Dags[right].OpRec.ResReg<>rNone)) then
          UseReg:=False;
          (*******)
        UseRegL:=FALSE;;;;;;;;;;
        if UseRegL then begin
          Left.AddressRef(lEA);
          Right.AddressRef(rEA);
          CodeInstr(BinCode[Oper],rEA,lEA);
        end else begin
          Right.AddressRef(rEA);
          Left.Load(lEA,easL);
          CodeInstr(BinCode[Oper],rEA,lEA);  //DIV <ea>,Dn
        end;
        if Oper=opMOD then begin
          CodeInstr1(codSWAP,lEA);  //SWAP Dn
        end;
        //Right.FreeFrom;
        SetDagResNoBind(lEA);
        OpRec.aEA.EASize:=easW;
      end;
    end;
  opSHL,opSHR:
    begin
      CheckNotBothOnStack(Left,Right); //NOT transitiv!!
      if IsImm1_8(Right.OpRec.aEA) then begin
        Right.AddressRef(rEA);
        Left.Load(lEA);
        CodeInstr(BinCode[Oper],rEA,lEA,lEA.EASize);  //X:= 3 shl 22 => LSR #3,D33
        SetDagResNoBind(lEA);
      end else begin
        Right.Load(rEA);
        Left.Load(lEA,easB);
        CodeInstr(BinCode[Oper],rEA,lEA,lEA.EASize);  //X:= 33 shl 22 => LSR D22,D33
        //Right.FreeFrom;
        SetDagResNoBind(lEA);
      end;
    end;
  else InternalError('BinOP TINT');
  end;
end;

procedure DoTBOL;                       //Left OP Right
//var N: Integer;
begin //DoTBOL
  //N:=Length(CurCodeDag.ops);
  CurCodeDag:=Left; //SEARCH10 SEARCH12
  Left.AddressRef(lEA,DoWaitWithReload);
  //if N<>Length(CurCodeDag.ops) then
  //  N:=0;
  CurCodeDag:=Self; //SEARCH10 
  Right.AddressRef(rEA);
  case Oper of
  opEQ,opNE:
    begin
      Left.Load(lEA);
      CodeInstr(codCMP,rEA,lEA);
      FreeLR;
      SetDagKCond(OpRec.ccTrue);
      //SetDagKCond(OpRec.ccFalse);
    end;
  opGT,opLT,opGE,opLE:                       //NOT transitiv!!
    begin
      CheckNotBothOnStack(Left,Right);       //NOT transitiv!!
      Left.AddressRef(lEA);
      Left.Load(lEA);
      CodeInstr(codCMP,rEA,lEA);
      FreeLR;
      SetDagKCond(OpRec.ccTrue);
      //SetDagKCond(OpRec.ccFalse);
    end;
  opOR,opXOR,opAND:
    begin
      Left.AddressRef(lEA);
      Right.Load(rEA,easB);
      CodeInstr(BinCode[Oper],lEA,rEA);
      FreeLR;
      SetDagResNoBind(rEA); //aEA:=rEA
      SetDagKCond(CondNE,rEA.EAl=rD0); ///
      //SetDagKCond(CondSwapCnd[CondNE],rEA.EAl=rD0); ///
      //SetDagKCond(CondSwapCnd[ccCodes[Oper]],rEA.EAl=rD0); ///
    end;
  else InternalError('BinOP TBOL');
  end;
end;

begin //BinOP
  lEA:=EA0; rEA:=EA0;
  Oper:=eSubBinOPs(Op2); Left:=ParmL; Right:=ParmR;
  OpRec.ccTrue:=ccCodes[Oper];
  //OpRec.ccFalse:=CondSwapCnd[ccCodes[Oper]];
  Kind:=kRes; OpRec.InReg:=eTrue; //Assume!!
  try
    if not (Left.OpRec.OTYPE  in ValidBinOpTyp) then InternalError('BinOP, Left not valid');
    if not (Right.OpRec.OTYPE in ValidBinOpTyp) then InternalError('BinOP, Right not valid');
    if Oper=opRDV then DoTREA
    else
      case MaxTyp[Left.OpRec.OTYPE,Right.OpRec.OTYPE] of
      TSET: DoTSET;
      TSTR: DoTSTR;
      TREA: DoTREA;
      TPTR,TCHR,TUSR,
      TINT: DoTINT;
      TBOL: DoTBOL;
      else  InternalError('Binary operation');
      end;
    FreeLR;
    BindTo;
    DumpRegsUsage('BinOP');
  except
    Debug('InternalError BinOP Types'); ///  InternalError('BinOP Types')
    RAISE;
  end;
end;

(*CODE**************************************************************************)
// GenCode, LoadX, Load, AddressRef/Misc
//Procedure TUnit2.GenCode;
//procedure AddressRef(var EA: tEA; PreAddrReg: eReg=RegA_Ref);	FORWARD;

(***********************************)
Procedure tDag.GenCode;
var
  ToMem,FromMem,BitCount,n: Integer;
  m: tDag;
  lEA,rEA,vEA: tEA;
  Size: eEASize;
  What: eCode;
  SL,SR: String;
  W: Word;
Const
  EA_imm1: tEA=(EAh: EIMED; EAl:rNONE; EAi:rNONE; EAofs: 1; EASize: easW);
begin {GenCode}
  CurCodeDag:=Self;
  try
    if ParmL<>NIL then SL:=i2sl(ParmL.id,3) else SL:='   ';
    if ParmR<>NIL then SR:=i2sl(ParmR.id,3) else SR:='   ';
    if op=pcConst then Comment:=Format('%s (%s)',[Comment,ConS]);
    DebugErrorStr:=Format('%2d-%2d %10s %s %s op2:%d [%d] %s',[SrcLine,id,OpCodes[op],SL,SR,op2,Length(ParmList),Comment]);
    if TestMode {cdD in TUnit2(Owner).OptionsLocal.Active} then
      if op<>pcLINk then
        DebugIfL(DebugErrorStr);
    //if ID<255 then if ID in [14,17,20..22] then  //BPMark  test6a.pas
    if ID<255 then if ID in [23] then  //BPMark
      ID:=ID;
    case op of
    pcPROCFUNC:
      begin
        SaveAll;
        case SysProcType of
        eProc: ;
        eProcUndef: InternalError0;
        ePasFunc:with OpRec do begin
                   CurCodeDag:=ParmL; //SEARCH10
                   if xxOTyp=NIL then InternalError0;
                   if ParamByRef(xxOTYP) then begin
                     Kind:=kTmp;
                     ParmL.PushNewTmp(aEA, xxOTYP^.TSIZE);
                     InReg:=eFalse;
                     //aEA.EAsize:=easL; //??
                   end else begin
                     SetDagResStack(OTYPE, CalcSize(xxOTyp));
                     lEA:=EA_A7PushL; lEA.EAsize:=aEA.EAsize;
                     if lEA.EAsize=easB then lEA.EAsize:=easW;
                     CodeInstr1(codCLR,lEA); //SEARCH9); //NOP //SEARCH11 ParmL
                   end;
                 end;
        eFuncD0: begin
                   if OpRec.xxOTyp=NIL then InternalError0;
                   Size:=CalcSize(OpRec.xxOTyp);
                   Kind:=kRes; OpRec.aEA:=EA_Dn; OpRec.aEA.EAl:=rD0;
                   OpRec.InReg:=eTrue;
                   //if TestMode then if OpRec.aEA.EAh<>EDREG then InternalError('InReg3');;
                   OpRec.aEA.EASize:=Size;
                   //if SysProcType=eFuncD0BoolC then
                   if OpRec.OTYPE=TBOL then begin
                     OpRec.aEA.EAsize:=easW; //as AND.W #1,Dn do cost the same as AND.B #1,Dn
                     CodeInstr(codAND,EA_imm1,OpRec.aEA);
                     SetDagKCond(CondNE,True); //kCondD0Ok:=TRUE!
                     //SetDagKCond(CondEQ,True); //kCondD0Ok:=TRUE!
                   end;
                   BindTo;
                 end;
        eFuncA0: begin
                   Kind:=kRes; OpRec.aEA:=EA_An; OpRec.aEA.EAl:=rA0;
                   OpRec.InReg:=eTrue; if TestMode then if OpRec.aEA.EAh<>EAREG then InternalError('InReg4');;
                   BindTo;
                 end;
        //eFuncSP: begin SetDagResStack; end;
        end;
      end;
    pcFor: //STFROR
      begin //List=[0=CodeV, 1=EFrom, 2=ETo, 3=Loop, 4=CodeStmt, 5=LCont, 6=LBreak], op2= SDTO/STO
      (*V:=Dn:=EFrom
        if TO then Dn=-(EFrom-ETo) else Dn=EFrom-ETo
        BLT LBreak
        :CodeStmt
      LCont:
        Inc/Dec(V)
        Dec  Dn
        BCC CodeStmt
      LBreak  ****)
        ParmList[0].AddressRef(vEA); //freefrom???
        Size:=vEA.EAsize;
        lEA:=EA_Dn; lEA.EAl:=rD7; lEA.EAsize:=Size;
        if ForLevel>7 then Error(Err_Complicated); // Absolute max!!
        Dec(lEA.EAl,ForLevel-1); //1,2,3 => D7,D6,D5
        if not (lEA.EAl in RegsFree) then Error(Err_Complicated);
        Include(MaxRec,lEA.EAl);
        ///Exclude(RegsFree,lEA.EAl);
CurCodeDag:=ParmList[1];                  //SEARCH9
        ParmList[1].LoadX(lEA,Size);              //Dn
//        CodeInstr(codMOVE,lEA,vEA);       //SEARCH9);   //Dn:=V:=EFrom
CurCodeDag:=ParmList[2];                  //SEARCH9
        ParmList[2].AddressRef(rEA);
        if rEA.EAsize<lEA.EAsize then ParmList[2].Load(rEA,lEA.EAsize);

        CodeInstr(codMOVE,lEA,vEA);       //SEARCH9);   //Dn:=V:=EFrom

        CodeInstr(codSUB,rEA,lEA);        //SEARCH9);
        if eSubFor(op2)=ForInc then begin
          CodeInstr1(codNEG,lEA); //SEARCH9
          What:=codADD
        end else What:=codSUB;
        JumpCC(CondLT,ParmList[6]); //LBreak
CurCodeDag:=ParmList[5];                  //SEARCH9
        CodeInstr(What,EA_imm1,vEA);      //SEARCH9);
        CodeInstr(codSUB,EA_imm1,lEA);    //SEARCH9);
        JumpCC(CondCC,ParmList[3]);
CurCodeDag:=Self;                         //SEARCH9
        ParmList[1].FreeFrom;
        ParmList[2].FreeFrom;
      end;
    pcCASE:    // pcCASE x
      begin
        CurCodeDag:=ParmL; //SEARCH10
        ParmL.LoadX(EA_D0,easL);
        ParmL.FreeFrom;
        MkEA(lEA,EPDIS,rNONE,op2,easB);
        CodeInstr(codLEA,lEA,EA_A0); //SEARCH9);
        ParmL.CallSysProc(PSysCase);
        //ParmL.CodeRaw2($4EFB,$0000 + 2);     //JMP d(PC,Dn.W)   , //D0.W + Disp
        CodeRaw($4ED0);       //JMP (A0)
        N:=High(ParmList);
        for N:=0 to N do begin
          m:=ParmList[N];
          JumpCC(CondT,m,FALSE); //SEARCH10
        end;
        if TestMode then begin      //Param #2=X
          CodeRaw($4E71);       //NOP
          CodeRaw($4E71);       //NOP
        end;
      end;
    //pcLBL: ;
    pcJMP: begin     //0=Label, 1=Bcc, 2=B??(ParmR=Stmt)   eSubJmp=(JMP,JMPF,LAB)
        CurCodeDag:=ParmR; //SEARCH10
        case op2 of
        0: SrcLine:=-SrcLine; //Label, no debug info
        1: begin
             if Length(OpS)<>2 then InternalError0;
           end;
        2: begin
             if ParmR.OpRec.ccTrue=CondNONE then InternalError('CondNONE');
             case ParmR.Kind of //22-2-2002
             kCond: ;
             kConst: begin //Remove jmp when "if true then xxx" 
                       ParmR.AddressRef(lEA);
                       if ParmR.OpRec.aEA.EAofs=1 then  //22-2-2002
                         ParmR.OpRec.ccTrue:=CondT
                       else
                         ParmR.OpRec.ccTrue:=CondF
                     end;
             else
               ParmR.AddressRef(lEA);  //lEA NEVER imm!!
               CodeInstr1(codTST,lEA); //SEARCH9); //SEARCH11 ParmR
               ParmR.OpRec.ccTrue:=CondNE; //??????
               //ParmR.OpRec.ccFalse:=CondEQ; //??????
             end;
             if ParmR.OpRec.ccTrue<>CondT then JumpCC(CondSwapJmp[ParmR.OpRec.ccTrue],ParmL);
             //if ParmR.OpRec.ccFalse<>CondF then JumpCC(ParmR.OpRec.ccFalse,ParmL);
             ParmR.FreeFrom;
           end;
        end;
      end;
    pcEnter:
      begin //op3=unstack size
        case op2 of
        0: ;                   //NoA6Frame Enter
        1: CodeInstr0(codRTS); //NoA6Frame Leave
        2: ;                   //LINK Code! Defered until UNLK time
        3: begin
             //ParmL=LINK Code!
             lEA:=EA_ImmWn; lEA.EAofs:=EvenSize(MaxAddrTemp);
             CurCodeDag:=ParmL; ////
             CodeInstr(codENTER,lEA,EA_EnterLeave); //link A6,#MaxAddrTemp
             CalcMOVEM(MaxRec-RegsNoMOVEM,ToMem,FromMem,BitCount,rEA); //rEA if one reg
             if BitCount=1 then begin
               CodeInstr(codMOVE,rEA,EA_A7PushL);         //MOVE reg,-(SP)
               CurCodeDag:=Self; ////
               CodeInstr(codMOVE,EA_A7PopL,rEA);                //MOVE (SP)+,reg
             end else
               if BitCount>0 then begin
                 CodeRaw2($48E7,ToMem);                         //MOVEM regs,-(SP)
                 CurCodeDag:=Self; ////
                 CodeRaw2($4CDF,FromMem);                       //MOVEM regs,-(SP)
               end;
             CurCodeDag:=Self; ////
             CodeInstr1(codLEAVE,EA_EnterLeave);
             case op3 of
             -9999..0: CodeInstr0(codRTS);
             4: begin
                  CodeRaw($2e9f);  //move.l (sp)+,(sp)
                  CodeInstr0(codRTS)
                end;
             else
               if Odd(op3) then InternalError('Odd stack at RTS');
               CodeRaw($205f); //move.l (sp)+,a0
               lEA:=EA_ImmWn; lEA.EAofs:=Op3;
               CodeInstr(codADD,lEA,EA_A7); //add #n,sp
               CodeRaw($4ed0); //jmp (a0)
             end;
           end;
        end;
        if cdD in TUnit2(Owner).OptionsLocal.Active then  //Procedure names after RTS
          if Odd(op2) then begin
            if Comment='' then Comment:='X';
            if {not} Odd(Length(Comment)) then Comment:=Comment+#0;
            //Inc(Byte(Comment[1]),$80);
            Insert(chr(Length(Comment)+$80),Comment,1);
            for N:=1 to (Length(Comment)+1) div 2 do begin // 'X'#0, 'XX'#0#0, 'XXX'#0
              Move(Comment[N*2-1],W,2);
              CodeRaw(Swap(W));
            end;
            CodeRaw($4E71); ///////!!!!!!!!
          end;
      end;
    pcNewBB: begin
        SrcLine:=-SrcLine; //No debug info
        if TUnit2(Owner).CurProcSym=NIL then internalerror0;
        CurAddrTemp:=TUnit2(Owner).CurProcSym^.UsageA6;
        if op2=0 then begin                           //"Begin"
          ///SetLength(OpS,1); OpS[0]:=$4a40;   /////???
          ;;;;;;; {Start of a block}
        end else begin                                //"End;"
          ///SetLength(OpS,1); OpS[0]:=$4a40;   /////???
          n:=0; while Vars.UnSaved<>[] do begin
            repeat inc(n) until n in Vars.UnSaved; {Special procedure!!!}
            Exclude(Vars.UnSaved,n);
            m:=tDag(Vars.Vars[n].dag);
            Write(' SAVE:'+i2s(n)+'('+i2s(m.Id)+') =>');		{SAVING}
            M.ParmL.AddressRef(lEA);
            M.ParmR.AddressRef(rEA);
            CodeInstr(codMOVE,lEA,rEA); //SEARCH9
          end;
        end;
      end;
    pcStaPROC:
      Begin
        case op2 of
        PSysFillChar:
                 begin
                   ParmList[0].PushAddr; //V //SEARCH9
                   ParmList[1].PushI(easW);           //I
                   ParmList[2].PushI(easB);           //xx
                 end;
        PSysMove:if ParmList[2].IsIConst(N) and (N in [1{,2,4}]) then begin
                   ParmList[0].AddressRef(lEA);
                   ParmList[1].AddressRef(rEA);
                   CodeInstr(codMOVE,lEA,rEA,EASizeCvt4[N]);
                   ParmList[0].FreeFrom;
                   ParmList[1].FreeFrom;
                   op2:=0;
                 end else begin
                   ParmList[0].PushAddr; //V1
                   ParmList[1].PushAddr; //V2
                   ParmList[2].PushI(easW);           //I
                 end;
        ISysInc,ISysDec: begin // Dec(Left,Right)  {Dec(T,TimGetTicks)}
                   if op2=ISysInc then What:=codADD else What:=codSUB;
                   ParmList[0].AddressRef(lEA);
                   ParmList[1].AddressRef(rEA); //Most often Imm!
                   if (rEA.EASize<lEA.EASize) or (not ParmList[1].IsImm) then
                     ParmList[1].Load(rEA,lEA.EASize);
                   CodeInstr(What,rEA,lEA,lEA.EASize);
                   ParmList[0].FreeFrom;
                   ParmList[1].FreeFrom;
                   op2:=0; //Skip runtime
                 end;
        PSysDispose, PSysNew, //Unused! //New(var P), Dispose(var P)
        PSysMemGet,
        PSysMemFree:          //MetMem(var P; Size: Int16), Dispose(var P; Size: Int16)
                 begin
                   ParmList[0].PushAddr;
                   ParmList[1].PushI(easL);
                 end;
        ISysStringR: //Str(x:real [:w[:dec]],var s:string)
          begin
            ParmList[0].PushI(easL);
            ParmList[1].PushI(easW); //Most often Imm!
            ParmList[2].PushI(easW); //Most often Imm!
            ParmList[3].PushAddr;
            ParmList[4].PushI(easW);
          end;
        ISysStringI: //Str(x:int [:w],var s:string)
          begin
            ParmList[0].PushI(easL);
            ParmList[1].PushI(easW); //Most often Imm!
            ParmList[3].PushAddr; //NB: Not #2!!
            ParmList[4].PushI(easW);
          end;
        PSysValR, PSysValI: //Val(s:string,var x:longint/real, var pos: integer)
          begin
            ParmList[0].PushAddr; //S
            ParmList[1].PushAddr; //X
            ParmList[2].PushAddr; //Pos
          end;
        PSysStrIns: //Insert(S,var S,n)
          begin //XINS(Src,Dst: Pointer; Max,Pos: SmallInt); Assembler; SysProc PSysStrIns;
            ParmList[0].PushAddr; //S
            ParmList[1].PushAddr; //S
            ParmList[1].PushConstI(ParmList[1].opRec.xxOTyp.TSIZE,easW);
            ParmList[2].PushI(easW);           //N
          end;
        PSysStrDel: //Delete(var S,n,n)
          begin
            ParmList[0].PushAddr; //S
            ParmList[1].PushI(easW);           //n
            ParmList[2].PushI(easW);           //n
          end;
        //PSysRandomize Just call
        end;
        if op2=0 then FreeFromAll else CallSysProc(op2);
      end;
    pcRawCode:
      ; //for N:=0 to Length(opS)-1 do S:=S+' '+Hex(opS[N],4); //Format('%.4x',[op2]);
    pcMisc:
      case op2 of
      1: begin //Parameter copy
           MkEA(lEA,EIMED,rNONE,opMisc.Below shl 16 OR ($FFFF and opMisc.Above),easL);
           CodeInstr1(codPEA,lEA);
           lEA:=EA_immWn;
           lEA.EAofs:=opMisc.Size div 2-1;
           CodeInstr(codMOVE,lEA,EA_D0,easW);
           CallSysProc(PSysPCopy);
         end;
      2: begin //Free ParmL (FOR; CASE, XXX)
           ParmL.AddressRef(lEA);
           AssignButNotType(ParmL);
           ParmL.FreeFrom;
         end;
      else InternalError0;
      end;
    pcIF,      // pcIF BE E1 JMP E2 LBL
    pcWHILE,   // pcWHILE LBL1 BE STMT JMP LBL2
    pcREPEAT:  // pcREPEAT [LLoop,Code,LCont,BE,LBreak]
      ;
    pcLINK: DebugErrorStr:=''; //DEBUG TEST
    pcFuncRes:  ;
    else
      ////////////Expression//////////////////////////////////////////////////////
      Size:=OPRec.aEA.EAsize;
      //Debug(DebugErrorStr);
      case op of
      pcStaFUNC:
        begin
          case op2 of
          FSysAbs16,FSysAbs32,FSysAbsR:
            begin
              //Size:=CalcSize(ParmL.OpRec.xxOTyp);
              ParmL.AddressRef(lEA);
              Size:=easL;
              if lEA.EASize<=easW then begin //Never real!
                Size:=easW;
                op2:=FSysAbs16;
              end;
              ParmL.PushI(Size);
              CallSysProc(op2);
              SetDagResStack(OpRec.OTYPE,Size);
              //ParmL.Load(lEA); rEA:=EA_Imm1;  //N:=ord(lEA.EAl);
              //CodeInstr(codSHL,rEA,lEA);
              //CodeInstr(codSHR,rEA,lEA);
              //SetDagRes(lEA,TINT);
            end;
          FSysSucc,FSysPred:
            begin
              if op2=FSysSucc then What:=codADD else What:=codSUB;
              OpRec.OTYPE:=ParmL.OpRec.OTYPE;
              ParmL.Load(lEA); ParmL.FreeFrom;
              rEA:=EA_Imm1; CodeInstr(What,rEA,lEA);
              FreeFromAll; /////!!
              SetDagRes(lEA);
              DumpRegsUsage('pcSUCC');
            end;
          FSysOdd:
            begin
              ParmL.Load(lEA); ParmL.FreeFrom;
              CodeInstr(codAND,EA_imm1,lEA,easW);
              FreeFromAll; /////!!
              SetDagKCond(CondNE,lEA.EAl=rD0);
              //SetDagKCond(CondEQ,lEA.EAl=rD0);
            end;
          //FSysOrd: =no code!
          FSysChr,FSysLo:
            begin
              ParmL.AddressRef(lEA);
              ParmL.FreeFrom;
              if lEA.EAh=EIMED then begin
                Kind:=kConst;
                OpRec.aEA:=lEA; OpRec.ConstVal:=Lo(lEA.EAOfs);
              end else begin
                if not IsImmInt16(lEA) then
                  if lEA.EASize<>easB then begin
                    ParmL.Load(lEA); ParmL.FreeFrom;
                    lEA.EASize:=easB;
                  end;
                SetDagRes(lEA);
              end;
              if op2=FSysChr then OpRec.OTYPE:=TCHR else OpRec.OTYPE:=TINT;
            end;

          FSysTrunc,FSysRound,          // I:=xx(Real)
          FSysInt,FSysSqrt,FSysArcTan,FSysSin,
          FSysCos,FSysLN,FSysExp,       //R:=f(R)
          FSysSqr:                      //Sqr(R)
            begin
              ParmL.PushR;
              CallSysProc(op2);
              SetDagResStack(OpRec.OTYPE,easL);
            end;
          FSysUpCase: //Upcase(Ch)
            begin
              ParmL.PushI(easW);
              CallSysProc(FSysUpCase);
              SetDagResStack(OpRec.OTYPE,easW);
            end;
          FSysStrLen:                   //I:=Length(S)
            begin
              if ParmL.OpRec.OTYPE=TPTR then ParmL.PushI(easL) //PChar   !!!!!!!!!!!
              else ParmL.PushAddr;
              CallSysProc(op2);
              SetDagResStack(OpRec.OTYPE,OpRec.aEA.EAsize);
            end;
          FSysStrCopy:
            begin
              ParmList[0].PushNewTmp(OpRec.aEA,MaxStringM1+1);
              OpRec.OTYPE:=TSTR;
              OpRec.FKind:=kTmp;
              if ParmList[0].OpRec.OTYPE=TPTR then ParmList[0].PushI(easL) //PChar   !!!!!!!!!!!
              else ParmList[0].PushAddr;
              ParmList[1].PushI(easW);
              ParmList[2].PushI(easW);
              CallSysProc(op2);
            end;
          FSysStrPos:
            begin
              if ParmL.OpRec.OTYPE=TPTR then ParmL.PushI(easL) //PChar   !!!!!!!!!!!
              else ParmL.PushAddr;

              if ParmR.OpRec.OTYPE=TPTR then ParmR.PushI(easL) //PChar   !!!!!!!!!!!
              else ParmR.PushAddr;

              CallSysProc(op2);
              SetDagResStack(OpRec.OTYPE,OpRec.aEA.EAsize);
            end;
          FSysPtr: ParmL.Load(lEA,easL); //Pointer(Long)

          FSysRandomI: //Random(I)
            begin
              ParmL.PushI(easW); ParmL.FreeFrom;
              CallSysProc(op2);
              SetDagResStack(OpRec.OTYPE,easW);
            end;
          ISys32Sqr: //Sqr(I)
            begin
              ParmL.PushI(easL); ParmL.FreeFrom;
              CallSysProc(op2);
              SetDagResStack(OpRec.OTYPE,easL);
            end;
          FSysRandomR,FSysMemAvail,FSysMemMaxAvail: //No params
            begin
              CallSysProc(op2);
              SetDagResStack(OpRec.OTYPE,easL);
            end;
          //FSysSizeOf: =pcCONST
          //FSysAddr:   =pcADDR
          else InternalError('STFFAC2:'+i2s(op2));
          end;
        end;
      pcVar:  //op2=1 if ASFI
        with OpRec do begin
          //if OSym=NIL then InternalError0;
          Kind:=kRef;
          aEA:=EA_A6IND;
          //aEA.EAh:=EADIS; EAi:=rNONE;
          aEA.EAsize:=Size; //Restore wanted size!!
          aEA.EAofs:={OSym^.}VADDR;     {Keep in REGS[] array???}
          //SEARCH4
          //AddressRef(lEA);
          //VVarF:=OSym^.VVARF;
          // if OTYPE=TBOL then OTYPE:=TBOL;
          if WithCode<>NIL then begin
            if (tDag(OpRec.WithCode).op=pcVar) and not (tDag(OpRec.WithCode).OpRec.VVARF in [vfDeref]) then
              Inc(aEA.EAofs,tDag(OpRec.WithCode).OpRec.aEA.EAofs)
            else begin
              aEA:=tDag(OpRec.WithCode).OpRec.aEA;
              Inc(aEA.EAofs,VADDR);
            end;
            aEA.EAsize:=Size;
            OpRec.Addressed:=True;
          end else begin
            case {OSym^.{}VVARF of
            vfGlobal:     aEA.EAl:=RegA_Global;
            //vfDeref, cannot be!
            vfLocal,
            vfVarCopy:    aEA.EAl:=RegA_Local; //SEARCH4
            vfVarConst,
            vfVar:	begin   //SEARCH1
                            aEA.EAl:=RegA_Local;
                          end;
            else          InternalError0;
            end;
          end;
          //DumpRegsUsage('pcSto');
          BindTo;
        end;
      pcConst:
        with OpRec do begin            //???????????? INT/REAL/STRING
          Kind:=kConst;
          //AddressRef(lEA);
        end;
      pcSto: begin //pcAssign, pcStore!       //see Label1Dag;
          //ParmL MUST make code inside SELF!!!! Else PreAddr uses A0 !!
          if op2=0 then begin
            if ParmL.OpRec.OTYPE=TREA then
              ParmR.INTREA;
            case ParmL.OpRec.OTYPE of
            TNON: InternalError0;
            TSTR,TPAC:
              begin
                if (ParmR.Kind=kConst) and (ParmR.ConS='') then begin
                  ParmL.AddressRef(lEA,DoFull); //Dst   //SEARCH9 //SEARCH10
                  lEA.EAsize:=easW;                  //Word always, byte sufficient!
                  CodeInstr1(codCLR,lEA);
                end else begin
                  ParmR.AddressRef(rEA); //Src //SEARCH4
                  if rEA.EAh=EAINC then //(A7)+
                    InternalError0;
                  //ParmR.PACRES;
                  if ParmR.OpRec.OTYPE in [TCHR,TINT] then begin
                    ParmL.AddressRef(lEA); //Dst
                    ParmR.CHRSTR(@lEA) //StoreDirect
                  end else begin
                    if (ParmR.Kind=kConst) and (Length(ParmR.ConS)<=3) then begin
                      ParmR.AddressRef(rEA);
                      ParmL.AddressRef(lEA,{PreAddr2,}DoFull); //Dst //SEARCH9//SEARCH10
                      CodeInstr(codMOVE,rEA,lEA);
                    end else begin
                      ParmR.AddressRef(rEA);
                      if ParmR.OpRec.OTYPE=TPTR then ParmR.PushI(easL)
                      else ParmR.PushAddr;
                      ParmL.PushAddr; //Cannot be switched. No difference!!!
                      //PushConstI(ParmL.opRec.xxOTyp.TSIZE);
                      EA_immWn.EAofs:=ParmL.opRec.xxOTyp.TSIZE;
                      if ParmL.OpRec.xxOTYP^.TTYPE=TPAC then begin
                        PushConstI(ParmL.opRec.xxOTyp.TSIZE,easW);
                        CallSysProc(PSysMove);
                      end else begin
                        CodeInstr(codMOVE,EA_immWn,EA_D0,easW);
                        CallSysProc(ISysStrSto);
                      end;
                    end;
                  end;
                end;
              end;
            TREA:
              begin
                ParmR.AddressRef(rEA); //Src //SEARCH4
                //ParmR.INTREA;
                rEA:=ParmR.OpRec.aEA;
                if ParmR.Kind<>kRes then
                  ParmR.AddressRef(rEA);   ////????????
                ParmL.AddressRef(lEA,{PreAddr2,}DoFull); //Dst //SEARCH9//SEARCH10
                if lEA.EASize<>easL then
                  InternalError0;
                CodeInstr(codMOVE,rEA,lEA);
              end;
            TSET: //pcSET
              begin
                if not ParmR.OpRec.MockupSet then begin
                  ParmR.AddressRef(rEA); //Src
                  ParmR.PushAddr;
                end;
                ParmL.PushAddr;
                if ParmL.OpRec.SetDesc=0 then
                  InternalError('Set1');
                PushConstI(ParmL.OpRec.SetDesc,easL);
                //PushConstI(ParmL.opRec.xxOTyp.TSIZE);
                //PushConstI(ParmL.opRec.xxOTyp.TELEP^.TMINV div 8);
                { 8(SP) = Source (P)}
                { 4(SP) = Destination (P)}
                { 2(SP) = Size in bytes (W)}
                { 0(SP) = Zero byte count (W)}
                CallSysProc(ISysSetSto);
              end;
            else
              if ParmR.op=pcLink then
                InternalError('pcLinkX!'); ///ParmR:=ParmR.ParmR; ///////////////////////NONO DOLATER eFuncD0!!
              ParmR.AddressRef(rEA); //Src
              ParmL.AddressRef(lEA,DoFull);  //Dst //SEARCH9//SEARCH10
              //ParmL.AddressRef(lEA);  //Dst //SEARCH4

              if lEA.EASize<>rEA.EASize then begin
                if lEA.EASize>rEA.EASize then ParmR.Load(rEA,lEA.EASize)
                else
                  if (rEA.EAh=EAINC) and (rEA.EAl=rA7) then //MOVE.W (SP)+,xx (should be .L)
                    ParmR.Load(rEA);
                if (lEA.EASize<>rEA.EASize) and not ParmR.IsImm then
                  ParmR.Load(rEA);
              end;
              if ParmL.OpRec.xxOTyp=NIL then
                CodeInstr(codMOVE,rEA,lEA)
              else begin
                case ParmL.OpRec.xxOTyp^.TSIZE of
                0: ; ///InternalError('No size');
                1..4: CodeInstr(codMOVE,rEA,lEA);
                else  ParmR.PushAddr;
                      ParmL.PushAddr;
                      PushConstI(ParmL.OpRec.xxOTyp^.TSIZE);
                      CallSysProc(PSysMove);
                end;
              end;
              //DumpRegsUsage('pcSTO1');
              //ParmL.FreeFrom; ParmR.FreeFrom;
              //ParmL.FreeFrom;
            end;
            ParmL.FreeFrom;
            ParmR.FreeFrom;
            ///SetDagResNobind(lEA);
            DumpRegsUsage('pcSTO2');
          end else begin
            ///SetDagResNobind(parmR.OpRec.aEA);  ///???????
          end;
          ParmR.FreeFrom;  //SEARCH3
        end;
      pcArray: //CodeList(pcARRAY,0,[CodeInx,CodeMul],'Array')
        with OpRec do begin
          //op2=Size in byte!
          //if OpRec.VVarF=vfXXX then
          //  OpRec.VVarF:=ParmL.OpRec.VVarF; //22-2-2002  test
          Kind:=kRes; InReg:=eFalse;
          ParmL.AddressRef(lEA);     //Var
          aEA:=lEA; //=ParmL.OpRec.aEA;
          aEA.EASize:=Size;
          if ParmR.Kind=kConst then
            Inc(aEA.EAofs,ParmR.ConI*op2)
          else begin
            ParmR.Load(rEA,easW);		{Load index first time to Dn} {Better delay a while if add to index! 2 dimensional!}
            case op2 of
            1: ;
            2: begin lEA:=EA_Imm1; CodeInstr(codSHL,lEA,rEA) end;
            else MkEA_IMM(lEA, op2, easW); CodeInstr(codMUL,lEA,rEA);
            end;
            if aEA.EAh in [EAIXw,EAIXl] then begin
              MkEA(vEA,EDREG,aEA.EAi,0,easW);
              //vEA:=aEA; vEA.EAh:=EDREG;
              CodeInstr(codADD,rEA,vEA);	        {Add to index. D0:=D0+D1}
              aEA.EAi:=vEA.EAl;
              ///ParmR.FreeFrom;
            end else begin
              {if rEA.EASize=easL then aEA.EAh:=EAIXl else {!!} aEA.EAh:=EAIXw;
              aEA.EAi:=rEA.EAl;
            end;
          end;
          ParmL.FreeFrom;
          ParmR.FreeFrom;
          BindTo;
        end;
      pcOffset:
        with OpRec do begin
          ParmL.AddressRef(aEA);  //,RegA_Ref,False);      //SEARCH1
          //VVarF:=ParmL.OpRec.VVarF;
          //Kind:=kRes; InReg:=ParmL.OpRec.InReg; aEA:=ParmL.OpRec.aEA;  //??????????????????????
          Kind:=kRes; InReg:=eFalse; aEA:=ParmL.OpRec.aEA;
          Inc(aEA.EAofs,op2);
          ParmL.FreeFrom;
          BindTo;
          //OSym:=ParmL.OpRec.Sym;
        end;
      pcDEREF:
        with OpRec do begin
          if op2=1 then begin
            ParmL.AddressRef(OpRec.aEA,DoWaitWithVAR); //pcWITH
            Kind:=kRes; OpRec.InReg:=eFalse;
            ParmL.FreeFrom;
          end else begin
            //CurCodeDag:=ParmL;                //SEARCH9
            ParmL.AddressRef(lEA,DoFull);
            OpRec.aEA:=lEA;
            ParmL.FreeFrom;
            VVarF:=vfDeref;
            rEA:=FindReg(RegsWorkAn);
            //MkEA(rEA,EAREG,xxa0,0,easL);      //SEARCH1
            CodeInstr(codMOVE,lEA,rEA);
            MkEA(aEA,EADIS,rEA.EAl,0,Size);     //Restore original size
            Kind:=kRes; InReg:=eFalse;
            BindTo;
            //CurCodeDag:=Self;                 //SEARCH9
          end;
          //ConstructSetDesc;  //Type set in Stmt.pas
          //ParmL.OpRec:=OpRec;
        end;
      pcWITH:    // pcWITH 0, V1, V2, V3   pcWITH 1, E
        case op2 of
        0: begin //Keep regs on ParmR!
             with ParmR do begin
               N:=1;
               if (OpRec.VVARF in [vfVarCopy]) or (op=pcOFFSET) then
               else
                 if (OpRec.VVARF in [vfVar,vfVarConst]) or (op=pcDEREF) or (op=pcArray) then
                   N:=2
                 else
                   if OpRec.VVARF=vfGlobal then N:=1
                   else
                     if OpRec.VVARF<>vfLocal then InternalError('WITH problem');
               case N of
               1: begin //pcOFFSET
                    rEA:=FindReg(RegsWith);
                    //AddressRef(lEA,TRUE,Self,TRUE{With});
                    AddressRef(lEA,DoWaitWithVAR);
                    FreeFrom;
                    OpRec.VVarF:=vfDeref;
                    CodeInstr(codLEA,lEA,rEA);
                    MkEA(OpRec.aEA,EADIS,rEA.EAl,0,easL);
                    Self.OpRec:=OpRec;
                    Self.Kind:=kRes; Self.OpRec.InReg:=eFalse; //????
                    BindTo;  //Right
                    Exclude(RegsFree,Self.ParmR.OpRec.aEA.EAl);
                  end;
               2: begin //pcArray
                    rEA:=FindReg(RegsWith);
                    //AddressRef(lEA,TRUE,Self,TRUE{With});
                    AddressRef(lEA,DoWaitWithVAR);
                    FreeFrom;
                    OpRec.VVarF:=vfDeref;
                    CodeInstr(codMOVE,lEA,rEA);
                    MkEA(OpRec.aEA,EADIS,rEA.EAl,0,easL);
                    Self.OpRec:=OpRec;
                    Self.Kind:=kRes; Self.OpRec.InReg:=eFalse; //????
                    BindTo;  //Right
                    Exclude(RegsFree,Self.ParmR.OpRec.aEA.EAl);
                  end;
               end;
             end;
           end;
        9: begin
             ParmR.FreeFrom;
             if ParmR.OpRec.aEA.EAl in RegsWith then
               Include(RegsFree,ParmR.OpRec.aEA.EAl);
           end;
        end;
      pcADDR:
        case op2 of
        0: begin //@var
             ParmL.AddressRef(lEA);
             ParmL.FreeFrom;
             OpRec.aEA:=FindReg(RegsWorkAn);
             //MkEA(OpRec.aEA,EAREG,lEA.EAl,0,easL);    //SEARCH1
             CodeInstr(codLEA,lEA,OpRec.aEA);
             Kind:=kRes; OpRec.InReg:=eTrue;
             BindTo;
             //if TestMode then if OpRec.aEA.EAh<>EDREG then InternalError('InReg5');;
           end;
        1: begin //@proc
             OpRec.aEA:=EA_A0;
             Kind:=kRes; OpRec.InReg:=eTrue;
             //if TestMode then if OpRec.aEA.EAh<>EDREG then InternalError('InReg6');;
           end
        end;
      pcFuncParm: //nn(A6), nn=variabel
        begin
          case op2 of
          0: case OpRec.OTYPE of
             TSTR,TPAC:
               begin
                 if ParmL.OpRec.OTYPE in [TCHR,TINT] then begin
                   ParmL.CHRSTR(NIL,2); //StoreDirect
                   CodeInstr1(codPEA,ParmL.OpRec.aEA);
                 end else
                   ParmL.PushAddr;
               end;
             else ParmL.PushAddr;
             end;
          1: CodeInstr(codMOVE,ParmL.OpRec.aEA,EA_A7PushL);
          2: ParmL.PushI({ParmL.}OpRec.aEA.EASize);  //To a Var
          //unused!! 3: ParmL.SETTMPPush;  //Set to stack (as tempset)  //Does nothing if doing MockupSet
          else InternalError0;
          end;
        end;
      pcCAST:  {TypeCast}
        begin
          ParmL.Load(lEA,OpRec.aEA.EASize);
          lEA.EASize:=OpRec.aEA.EASize; //Keep type casted size
          ParmL.FreeFrom;
          SetDagRes(lEA);
        end;
      pcBinOp: BinOP;
      pcMonOp:
        begin
          AssignButNotType(ParmL);
          case eSubMonOPs(Op2) of
          opORD: begin
                   ParmL.AddressRef(OpRec.aEA);
                   ParmL.FreeFrom;
                   SetDagRes(OpRec.aEA)
                 end;
          opNEG: begin
                   if OpRec.OTYPE=TREA then begin
                     ParmL.PushI(easL);
                     CallSysProc(FSysNegR);
                     ParmL.FreeFrom; SetDagResStack(TREA,easL);
                   end else begin
                     ParmL.Load(OpRec.aEA);
                     CodeInstr1(codNEG,OpRec.aEA);
                     ParmL.FreeFrom; SetDagRes(OpRec.aEA);
                   end;
                 end;
          opNOT:
            begin
              if OpRec.ccTrue=CondNONE then InternalError('CondNONE');
              if ParmL.Kind=kCond then
                ParmL.Load(lEA,easB);
              (**
              if ParmL.Kind=kCond then begin  //NEVER!!!!!!!!!!!!!!!
                SetDagKCond(CondSwapCnd[OpRec.ccTrue]);
                //SetDagKCond(CondSwapCnd[OpRec.ccFalse]);
                OpRec.kCondD0Ok:=False;
              end else (******)
              begin
                if OpRec.OTYPE=TBOL then begin
                  ParmL.AddressRef(lEA);
                  rEA:=FindReg(RegsWorkDn); //Dn
                  vEA:=EA_imm1L;
                  CodeInstr(codMOVE,vEA,rEA);
                  CodeInstr(codSUB,lEA,rEA);
                  ParmL.FreeFrom;
                  SetDagRes(rEA);
                end else begin
                  ParmL.Load(lEA);
                  CodeInstr1(codNOT,lEA);
                  CodeInstr1(codNEG,lEA);
                  ParmL.FreeFrom;
                  SetDagRes(lEA);
                end;
              end;
            end;
          else InternalError('MonOP');
          end;
          BindTo;
          DumpRegsUsage('MonoOP');
        end;
    pcSET:
      begin
        case eSubSet(op2) of
        SetStart:
          begin
            Kind:=kTmp;
            OpRec.MockupSet:=True;
            OpRec.SetDesc:=$00000020; //Ofs=0, Size=32
            NewTmp(OpRec.aEA,32);
            CodeInstr1(codPEA,OpRec.aEA);
            CallSysProc(ISysSetLdZero);
          end;
        SetItems:
          begin
            N:=0;
            while N<Length(ParmList) do begin
              ParmList[N].PushI(easW);
              if ParmList[N+1]=NIL then
                CallSysProc(ISysSetAdd1)
              else begin
                ParmList[N+1].PushI(easW);
                CallSysProc(ISysSetAddN);
              end;
              Inc(N,2);
            end;
          end;
        end;
      end;
      else Debug('Missing CASE')
      end;
      ////////////////////////////////////////////////////////////////////////////
    end;
  except
    on E:Exception do begin
      Debug('Error, OP='+i2s(ord(OP))+E.Message);
      DumpRegsUsage('GenCode');
      RAISE
    end;
  end;
  CurCodeDag:=NIL;
  Comment:=DebugErrorStr;  ////////
  DebugErrorStr:='';
end;

Procedure tDag.FreeFromAll;
var N: Integer;
begin
  for N:=Low(ParmList) to High(ParmList) do
    if ParmList[N]<>NIL then begin
      //DumpRegsUsage('Free all');
      ParmList[N].FreeFrom;
    end;
  if ParmL<>NIL then ParmL.FreeFrom;
  if ParmR<>NIL then ParmR.FreeFrom;
end;

Procedure tDag.CallSysProc(Proc: Integer; DoFreeFromAll: Boolean=True);
begin
  CodeProcFuncRaw(eProc,OpcBSR,LocateSysProc(Proc),1,NIL);
  if DoFreeFromAll then FreeFromAll;
end;

//Var DebugBreakID
Var DebugLastDagID: Integer;
Procedure tDag.Walk1Dag;
var N: Integer;
begin
  if Selected then EXIT;
  Selected:=True;
  DebugLastDagID:=Id;
  //if DebugBreakID=Id then
  //  DebugBreakID:=-1;  //Set Breakpoint here
  //if (parmR.LabelCnt<=parmL.LabelCnt)
  //or ({ (op in xxBinOps) and {{} (op in [pcEnter,pcLink,pcNewBB])) then
  if not SkipWalkParmL then //Not for JMPS
    if ParmL<>NIL then
      ParmL.Walk1Dag;
  DebugLastDagID:=Id;
  if ParmR<>NIL then
    ParmR.Walk1Dag;
  DebugLastDagID:=Id;
  N:=High(ParmList);
  for N:=0 to N do
    if ParmList[N]<>NIL then
      if ParmList[N]<>ParmExit then
        ParmList[N].Walk1Dag;
  if ParmExit<>NIL then
    ParmExit.Walk1Dag;
  inc(TUnit2(Owner).DagSortInx);
  TUnit2(Owner).DagSort[TUnit2(Owner).DagSortInx]:=Self;
  if ParmAfter<>NIL then
    ParmAfter.Walk1Dag; //Coded AFTER myself
end;

Procedure tDag.WalkDagFirst;
begin 
  //DebugBreakID:=-1; DebugLastDagID:=-1;
  //if Id=-1 then DebugBreakID:=16;
  try
    if TUnit2(Owner).CurDagInx>1 then Walk1Dag;
  except
    on E:Exception do begin
      Write(Format('Internal error in WalkDag: #%d. "%s"',[DebugLastDagID,E.Message]));
      raise
    end;
  end;
end;

(*******************************************************************************)
(*LABEL*****************************)
Procedure tDag.Label1Dag;
var l,r: Integer;
begin
  begin
    l:=0; r:=0;
    if IsALeaf then begin
      if op in [pcEnter{{{}] then LabelCnt:=0
      else
        (*****
        if Parent.ParmL=Start then begin
          LabelCnt:=1;
        end else LabelCnt:=0;
        (*****)
    end else begin
      if ParmL<>NIL then l:=ParmL.LabelCnt;
      if ParmR<>NIL then r:=ParmR.LabelCnt;
      if l=r then LabelCnt:=l+1 else LabelCnt:=max(l,r);
      if op=pcSTO then begin		{pcSTO}
        if op2>0 then
          Vars.UnSaved:=Vars.Unsaved+[OpRec.VarInx];
      end;
    end;
  end;
end;

(*******************************************************************************)
Procedure TUnit2.dagInitializeProc(CurProcName: String; ProcSym: pSymRec);
begin
  DebugIfL('*********'+UnitName+'.'+CurProcName+'********');
  //Write('Dag Open');
  CodeEng.InitRegs;
  //SetLength(Dags,MaxDags+1);           //0..MaxDags            ///DOLATER
  //SetLength(DagSort,MaxDags+1);        //Index into Dags
  CurDagInx:=1; DagSortInx:=0; CurProcSym:=ProcSym;
  SetLength(Dags,CurDagInx);
  Dags[0]:=tDag.Create; //New(Dags[0]);
  PCRelData:='';
end;

Procedure TUnit2.SetLeftRight(MySelf,L,R: tDag);
begin
  MySelf.ParmL:=L; MySelf.ParmR:=R;
  if L<>NIL then with L do begin
    MySelf.IsALeaf:=False; Inc(xxRefCnt);
  end;
  if R<>NIL then with R do begin
    MySelf.IsALeaf:=False; Inc(xxRefCnt);
  end;
end;

Function  TUnit2.EnterDag(o1: eP; o2: Integer; C: String): tDag;
begin
  //if CurDagInx=75 then
  //  CurDagInx:=CurDagInx;  //BPMark
  if InsNotAllowed then
    if o1<>pcConst then     //Set in STCASE
      Error(ExpConst);
  Result:=tDag.Create;
  Result.Owner:=Self;
  if cdL in OptionsLocal.Active then begin
    Result.SrcNo:=IBUGLB.SrcPTR^.IBUFileNo;
  end;
  Result.SrcLine:=IBUGLB.SrcPTR^.IBULINENO;
  //Result.TestProcNo:=Glb.MapProcNo;
  SetLength(Dags,CurDagInx+1);
  Dags[CurDagInx]:=Result;
  if Result=NIL then Error(Err_error);
  Result.op:=o1; Result.op2:=o2; Result.Comment:=C;
  Result.Id:=CurDagInx;
  Result.IsALeaf:=True;
  Result.xxRefCnt:=1;
  Result.LabelCnt:=MaxLabelCnt; {Used as flag too}
  Result.TestUnitNo:=UnitNo;
  Inc(CurDagInx);
end;

Function  TUnit2.EnterDagDup(op: eP; op2: Integer; Comm: String; L,R: tDag; Sym: pSymRec; ConX: Integer): tDag;
begin
  Result:=EnterDag(op,op2,Comm);
end;
(*****var   i,n: Integer;
begin
  n:=0;
  for i:=DagSeqNo to CurDagInx-1 do begin
    if (op=Dags[i].op) then
      if (op2=Dags[i].op2) then
        if (L=Dags[i].parml) then
          if (R=Dags[i].parmr) then
            if (Sym=Dags[i].oprec.sym) then
       //if FALSE THEN
              case OP of
              pcConst: if ConX=Dags[i].ConstVal then n:=i;
              else     n:=i;
              end;
    if n<>0 then begin
      Result:=Dags[n];
      EXIT;
    end;
  end;
  Result:=EnterDag(op,op2,Comm);
end;
(*******)

{Procedure TUnit2.DagSetFlag(Code: tDag; Flg: eDagFlag);
begin
  Code.Flags:=Flg;
end; {}

(*******************************************************************************)
Function  TUnit2.CodeIns(What: eP; op2: Integer; Left,Right: tDag; Comm: String=''): tDag;
begin
  Result:=EnterDagDup(What,op2,Comm,NIL,NIL,NIL,0);
  //Result:=EnterDag(What,op2,Comm);
  SetLeftRight(Result,Left,Right);
end;

Function  TUnit2.CodeInsParam(Code: tDag): tDag;
begin
  Result:=CodeIns(pcFuncParm,0,Code,NIL,'ParamV');
  Result.op2:=2;  ///////PushI
end;

Function  TUnit2.CodeList(What: eP; op2: Integer; Const A: Array of tDag; Comm: String=''): tDag;
var N: Integer;
begin
  Result:=EnterDag(What,op2,Comm);
  N:=High(A);
  SetLength(Result.ParmList,N+1);
  for N:=0 to N do
    Result.ParmList[N]:=A[N];
end;

Function  TUnit2.CodeVar(C: pSymRec; Comm: String): tDag;
begin
  Result:=EnterDagDup(pcVar,0,Comm,NIL,NIL,NIL,0);
  //Result:=EnterDag(pcVar,0,Comm);

  //Result.OpRec.OSym:=C;
  Result.OpRec.OSLEV:=C^.VSLEV;
  Result.OpRec.VVarF:=C^.VVARF;
  Result.OpRec.VADDR:=C^.VADDR;

  Result.OpRec.xxOTyp:=C^.VTYPP;
  Result.OpRec.OTYPE:=C^.VTYPP^.TTYPE;
  //Result.ConstructSetDesc; Done in SCTYP
end;

Function  TUnit2.CodeConst(Const C: Variant; OTYPE: eType): tDag;
begin
  Result:=EnterDagDup(pcConst,0,'',NIL,NIL,NIL,0);
  //Result:=EnterDag(pcConst,0,Comm);
  Result.OpRec.ConstVal:=C;
  Result.OpRec.OTYPE:=OTYPE;
  Result.OpRec.aEA.EAsize:=easL; //Assume
end;

Function  TUnit2.CodeInsSTO(Left,Right: tDag; Comm: String): tDag;
// var xx: tDag; op2: Byte;
var n: tDag; op2: Byte;
begin
  if (Left=NIL) or InsNotAllowed then Error(ExpConst);
  //Result:=EnterDagDup(pcSTO,0,Comm,NIL,NIL,NIL,0);
  //Result:=EnterDag(pcSTO,0,Comm);
  //SetLeftRight(Result,Left,Right);
  N:=NIL; op2:=0;
  (******
  xx:=Right;
  if FALSE AND ////////////!!!!!!!!!
    xx.IsALeaf and (xx.OPRec.OSym<>NIL) then
    with Vars do begin
      op2:=1;		{Are now in Vars[] table}
      if not ((xx.OPRec.OSym^.VHASH<=Cnt) and (Vars[xx.OPRec.OSym^.VHASH].vdSym=xx.OPRec.OSym)) then begin
        if Cnt>=MaxVars then Error(Err_Error{!!!!!!});
        inc(Cnt);
        xx.OPRec.OSym^.VHASH:=Cnt;
        Vars[Cnt].vdSym:=xx.OPRec.OSym;
      end;
      //n:=EnterDagDup(glDag);
      N:=EnterDagDup(pcSTO,op2,Comm,Left,Right,NIL,0);
      Vars[xx.OPRec.OSym^.VHASH].dag:=n;
      n.OPRec.VarInx:=Cnt;
    end;
  (********)
  //if N=NIL then n:=EnterDagDup(pcSTO,op2,Comm,Right,Left,NIL,0); //!!!NB: Switched Left<->Right!!!!!
  if N=NIL then n:=EnterDagDup(pcSTO,op2,Comm,Left,Right,NIL,0); //Normal version
  Result:=N;
  SetLeftRight(Result,Left,Right);
end;

procedure x3; var xl1: Integer;
procedure xx; var xl2: Integer;
procedure xxx; var xl3: Integer;
procedure xxxx; var xl4: Integer;
begin //xxxx
  xxxx; //8(a6),-(sp)
  xxx;  //8(a6),a0 //8(a0),-(sp)
  xx;   //8(a6),a0 //8(a0),a0 //8(a0),-(sp)
  x3;   //-
  xl1:=1; {8(a6),a0, 8(a0),a0, 8(a0),a0, -4(a0)}
  xl2:=2; {8(a6),a0, 8(a0),a0, -4(a0)}
  xl3:=3; {8(a6),a0, -4(a0)}
  xl4:=4; if xl4=0 then exit; //no hints!!!
end;
begin //xxx
  xxxx; //a6,-(sp)
  xxx;  //8(a6),-(sp)
  xx;   //8(a6),a0 //8(a0),-(sp)
  x3;   //-
  xl1:=1; {8(a6),a0, 8(a0),a0, -4(a0)}
  xl2:=2; {8(a6),a0, -4(a0)}
  xl3:=3;
end;

begin //xx
  xxx; //a6,-(sp)
  xx; //8(a6),-(sp)
  x3; //-
  xl1:=1; {8(a6),a0, -4(a0)}
  xl2:=2;
end;
begin //x3
  xx; //a6,-(sp)
  x3; //-
  xl1:=1;
end;

(***
procedure x3; var xl1: Integer;
procedure xx; var xl2: Integer;
procedure xxx; var xl3: Integer;
procedure xxxx; var xl4: Integer;
procedure xxxxx;
begin
  xx;   //-2 8(a6),a0 //8(a0),a0 //8(a0),a0 //8(a0),-(sp)
  xl1:=1; {8(a6),a0, 8(a0),a0, 8(a0),a0, 8(a0),a0, -4(a0)}
end;
begin //xxxx
  xxxx; // 0 8(a6),-(sp)
  xxx;  //-1 8(a6),a0 //8(a0),-(sp)
  xx;   //-2 8(a6),a0 //8(a0),a0 //8(a0),-(sp)
  x3;   //-
  xl1:=1; {8(a6),a0, 8(a0),a0, 8(a0),a0, -4(a0)}
  xl2:=2; {8(a6),a0, 8(a0),a0, -4(a0)}
  xl3:=3; {8(a6),a0, -4(a0)}
  xl4:=4;
end;
begin //xxx
  xxxx; // 1 a6,-(sp)
  xxx;  // 0 8(a6),-(sp)
  xx;   //-1 8(a6),a0 //8(a0),-(sp)
  x3;   //-
  xl1:=1; {8(a6),a0, 8(a0),a0, -4(a0)}
  xl2:=2; {8(a6),a0, -4(a0)}
  xl3:=3;
end;
begin //xx
  xxx; // 1 a6,-(sp)
  xx;  // 0 8(a6),-(sp)
  x3;  //-
  xl1:=1; {8(a6),a0, -4(a0)}
  xl2:=2;
end;
begin //x3
  xx; // 1 a6,-(sp)
  x3; //-
  xl1:=1;
end;
***)

Procedure tDag.CodeProcFuncRaw(ASysProcType: eSysProcType; OpCode: Word; Fix: TRef; Level: Integer; CodeWhere: tDag);
var N: Integer; GCCD: tDag;
begin
  if not ((CodeWhere=NIL) xor (CurCodeDag=NIL)) then InternalError0;
  if CodeWhere<>NIL then CurCodeDag:=CodeWhere;
  SaveAll;  //Never used!!!!!!!!!!!!!
  SysProcType := ASysProcType;
  if Level>1 then begin
    N:= Owner.SLEV-Level+1;
    case N of
    0: CodeRaw($2F0E);              //PSLEV-SLEV = 0  MOVE.L  A6,-(A7)
    1: CodeRaw2($2F2E,8);           //PSLEV-SLEV = 1  MOVE.L  8(A6),-(A7)
    else                            //PSLEV-SLEV > 1
      CodeRaw2($206E,8);            //                MOVE.L  8(A6),A0
      for N:=3 to N do
        CodeRaw2($2068,8);          //                N-2 * MOVE.L  8(A0),A0
      CodeRaw2($2F28,8);            //                MOVE.L  8(A0),-(A7)
    end;
  end;
  CodeRaw2(OpCode,2);
  GCCD:=GetCurCodeDag;
  with GCCD do begin //Error if not called when CurCodeDag valid
    SetLength(OpSFix,Length(OpS));
    OpSFix[High(OpS)]:=Fix;
  end;
  if CodeWhere<>NIL then CurCodeDag:=NIL; //Was nil!
end;

Procedure tDag.DumpRegsUsage(Comment: String);
var R: eReg;
begin
  if not TestMode then EXIT;
  for R:=RegFirst to RegLast do
    if Regs[R].UsedByDag<>NIL then begin
      if Comment<>'' then Debug(Comment); Comment:='';
      Debug(Format('Id:%d, Reg:%s',[Regs[R].UsedByDag.Id,RegNames[R]]));
    end;
end;

//From Assem & Stmt
Function  TUnit2.CodeProcFunc(SysProcType: eSysProcType; OpCode: Word; Fix: TRef; Level: Integer; Comm: String): tDag;
begin
  Result:=EnterDag(pcPROCFUNC,0,Comm);
  Result.CodeProcFuncRaw(SysProcType, OpCode, Fix,Level,Result);
end;

Function  TUnit2.CodeCallTrap(SysProcType: eSysProcType; Trap, StackUse: Integer): tDag;
begin
  Result:=EnterDag(pcPROCFUNC,0,'');
  Result.IsATrapProc:=True;
  Result.SysProcType:=SysProcType;
  //Result.CTrapStack:=StackUse;
  CurCodeDag:=Result; //SEARCH10
  if Trap shr 16>0 then {MOVEQ #xx,D2}
    CodeRaw($7400+((Trap shr 16)-1));  //PFUNO = 00xxtttt, xx=0 or 1..oo
  CodeRaw($4e4f);
  CodeRaw(Trap and $FFFF);
  if StackUse>0 then
    if StackUse<=8 then begin
      CodeRaw($504F + (StackUse and 7) shl 9);    //ADDQ #n,A7
    end else
      CodeRaw2($DEFC,StackUse);                   //Add.W #n,A7
  //Result.SkipWalkParmL:=True;
  CurCodeDag:=NIL; //SEARCH10
end;

Function  TUnit2.CodeJmpLabel(Const Comm: String): tDag;
begin
  Result:=EnterDag(pcJMP,0,Comm);
  Result.IsALabelxOP2Is0:=True;
  //Result.SkipWalkParmL:=True;
end;

Function  TUnit2.CodeJmp(JumpCond: eCondJumps; Where: tDag; Comm: String): tDag;
begin
  Result:=CodeJmpASM(OpcBRA, JumpCond, Where, Comm);
end;

Function  TUnit2.CodeJmpASM(OpCode: Word; JumpCond: eCondJumps; Where: tDag; Comm: String): tDag;
begin
  Result:=EnterDag(pcJMP,1,Comm);
  Result.OpRec.ccTrue:=JumpCond;
  if CurCodeDag<>NIL then InternalError0; CurCodeDag:=Result; //SEARCH10
  JumpCC(JumpCond,Where,True,OpCode);
  CurCodeDag:=NIL; //SEARCH10
  //SetLength(Result.OpS,2); Result.OpS[0]:=OpCode or (ord(JumpCond) shl 8);
  //Result.OpS[1]:=2; //////TEST TEST
  //SetLeftRight(Result,Where,NIL); Result.SkipWalkParmL:=True;
end;

Function  TUnit2.CodeJmpCC(Where,Stmt: tDag; Comm: String): tDag;
begin
  Result:=EnterDag(pcJMP,2,Comm);
  SetLeftRight(Result,Where,Stmt); Result.SkipWalkParmL:=True;
end;

Function  TUnit2.CodeRawArray(var CodeData: CodeWordArray; Comm: String): tDag; //From Assem.pas
begin
  Result:=EnterDag(pcRawCode,0,Comm);
  Result.opS:=CodeData;
end;

Function  TUnit2.CodeLD(Left,Right: tDag; Extra: tDag=NIL): tDag;
begin
  if Left=NIL then Result:=Right else
  if Right=NIL then Result:=Left else begin
    Result:=EnterDag(pcLink,0,'-');
    SetLeftRight(Result,Left,Right);
  end;
  if Extra<>NIL then
    Result:=CodeLD(Result,Extra);
end;

Procedure TUnit2.DebugNStmt;		{????????????????????????}
begin
end;

Function TUnit2.AccumulateAllUnits(What: eAccumulateAllUnits): Integer;
begin
  Case What of
  eTotalCodeUsedw: Result:=TotalCodeUsedW;
  else InternalError('AccAllUnits');
       Result:=0;
  end;
end;

Procedure TUnit2.StripCodeAdd(G: Integer; DoDebug: Boolean);
var N: Integer; AUnit: TUnit2; S: String;
begin
  if G>CodeGrpLast then InternalError('StripCodeAdd3');
  with mCodeGrps[G] do begin
    if Used then EXIT;
    CodeBaseB:=Glb.GlobalCodeSizeB; Inc(Glb.GlobalCodeSizeB,CodeCntW*2);
    S:=Format('AddCode(%s,%d) %s.%s Base:%.4x Size:%.4x Fix#%d (%d,%d)',
              [UnitName,G,UnitName,ProcName,CodeBaseB,CodeCntW*2,FixupCnt,Ord(MapDoShow_LD),MapProcNo]);
    if DoDebug then Debug(S);
    Used:=True;
    AnyCodeUsed:=True;
    ///if CodeCntW=0 then InternalError('StripCodeAdd1');
    if CodeCntW<0 then InternalError('StripCodeAdd1xxxxxxxxxxx');
    inc(TotalCodeUsedW,CodeCntW);
    //TRef= Record Ofs,UNo,GrpInx: SmallInt end;
    for N:=FixupFirst to FixupFirst+FixupCnt-1 do begin
      AUnit:=GlbUnit2(mFixup[N].UNo);
      if AUnit=NIL then InternalError('StripCodeAdd2');
      AUnit.StripCodeAdd(mFixup[N].GrpInx, DoDebug);
      ///Write('Do fixup right here!!!!!!!!!!!!!!!!!!!');
    end;
  end;
end;

Procedure TUnit2.StripCodeAddMain(Force, DoDebug: Boolean);
begin
  if AnyCodeUsed then
    Force:=True; //Any code used (realy CALLED!), then call "initialization"
  if not HasMainProc then EXIT;

  if HasMainProc then
    if Force or mCodeGrps[CodeGrpMain].MainProc then
      StripCodeAdd(CodeGrpMain, DoDebug);

  //for N:=0 to CodeGrpLast do  ///////////////TEST OF ALL CODE!!! SHAREWARE !!!
  //  if N<>CodeGrpMain then
  //    StripCodeAdd(N);
end;

Function  TUnit2.StripCodeGetTheCode(var AllCode: CodeWordArray): Integer;
var B,G: Integer;
begin
  Result:=0;
  G:=High(mCodeGrps);
  For G:=0 to G do
  with mCodeGrps[G] do
    if Used then begin
      if CodeCntW=0 then
        InternalError(Format('CodeCntW=0, UnitName=%s, G=%d',[UnitName,G]));
      Inc(Result,CodeCntW*2);
      B:=CodeBaseB div 2;
      if B+CodeCntW-1 > High(AllCode) then
        InternalError('Cannot move code beyond end');
      Move(mCode[CodeFirst],AllCode[B],CodeCntW*2);
    end;
end;

//Called at end of each procedure (Stmt.pas)
function TUnit2.dagCodeProc(Start: tDag; ProcSym: pSymRec; CurProcName: String): Integer; //Ret=CodeGrpInx
var I,C,C2,F,F2,M,N,P,CodeSizeW,SrcLNo,MapPNo,MapBase: Integer; PRel: ^Word; S: String;
begin
  if ProcSym=NIL then InternalError0;
  {$ifdef VersionUI}
    if not IsMainModule then
    {if not TestMode then{} FormDebug.DebugClear;
  {$Endif}
  //Result:=0;
  SetLength(DagSort,Length(Dags));        //Index into Dags
  Start.WalkDagFirst;
  //Write('Doing labeling...');
  for N:=1 to DagSortInx do
    DagSort[N].Label1Dag;    ///???????

  //Write('Doing code...'+UnitName+'.'+CurProcName);
  //for N:=1 to Min(50,DagSortInx) do S:=S+' '+i2s(DagSort[N].Id); Debug(S);
  for N:=1 to DagSortInx do
    DagSort[N].GenCode;

  //Write('Doing Addr...');
  CodeSizeW:=0;
  for N:=1 to DagSortInx do with DagSort[N] do begin
    CodeAddr:=CodeSizeW*2; inc(CodeSizeW, Length(OpS));
    CodeAddrLeft:=CodeAddr;
  end;
  for N:=1 to DagSortInx do with DagSort[N] do begin
    //CodeAddr:=CodeSizeW*2; inc(CodeSizeW, Length(OpS));
    //CodeAddrLeft:=CodeAddr;
    //M:=id;
    if ParmL<>NIL then
      if CodeAddrLeft>ParmL.CodeAddrLeft then
        CodeAddrLeft:=ParmL.CodeAddrLeft;
    if ParmR<>NIL then
      if CodeAddrLeft>ParmR.CodeAddrLeft then
        CodeAddrLeft:=ParmR.CodeAddrLeft;
    for M:=0 to High(ParmList) do
      if ParmList[M]<>NIL then
        //if ParmList[M].CodeAddrLeft=0 then
        //  I:=M   ///WHY!!!!!!!!!//////////////////////////
        //else
          if CodeAddrLeft>ParmList[M].CodeAddrLeft then
            CodeAddrLeft:=ParmList[M].CodeAddrLeft;
    //if op=pcLink  then CodeAddrLeft:=D.ParmL.CodeAddrLeft;
    //if (op=pcNewBB) and (ParmL<>NIL) then CodeAddrLeft:=D.ParmL.CodeAddrLeft;
  end;

  if FALSE then
  for N:=1 to DagSortInx do
    with DagSort[N] do
      Debug(Format('%d %d %s',[CodeAddr,CodeAddrLeft,Comment]));

  //Write('Doing Fixup...'+UnitName+'.'+CurProcName+' Size:'+i2s(CodeSizeW*2));
  F:=Length(mFixup); F2:=F;
  for N:=1 to DagSortInx do with DagSort[N] do begin
    (*****if op=pcJMP then
      if op2>0 then begin //0=Label
        if ParmL=NIL then InternalError0;
        Ops[1]:=Word(DagSort[N].ParmL.CodeAddrLeft -CodeAddrLeft -2);
      end;
    (******)
    I:=Length(OpSFixLocal);
    for I:=0 to I-1 do begin
      P:=OpSFixLocal[I].Pos;
      OpS[P]:=Word(DagSort[N].OpSFixLocal[I].Dag.CodeAddrLeft -CodeAddr -P*2);
    end;
    I:=Length(OpSFix);
    for I:=0 to I-1 do
      if OpSFix[I].FixUsed then
        if OpSFix[I].PCRel then
          Inc(OpS[I],CodeSizeW*2 - (CodeAddr+ I*2) )
        else begin
          inc(F2); SetLength(mFixup,F2);
          mFixup[F2-1]:=OpSFix[I];
          mFixup[F2-1].Where:=CodeAddr+2*I;
          if cdD in TUnit2(Owner).OptionsLocal.Active then
            DebugIfL(UnitName+'.'+CurProcName+' GrpInx:'+i2s(OpSFix[I].GrpInx)+
            ' CodeAddr:'+i2s(CodeAddr)+' AddrLeft='+i2s(CodeAddrLeft));
        end;
  end;

  //Write('Doing SaveCode...');
  C:=Length(mCode); C2:=C;

  Result:=ProcSym^.PRef.GrpInx;
  AllocateCodeBlock(Result,CodeSizeW + Length(PCRelData) div 2);

  with mCodeGrps[Result] do begin
    FixupFirst:=F; FixupCnt:=F2-F;   //Length(mFixup)-F;  ///???????
    ProcName:=CurProcName;
    Inc(Glb.MapProcNo);
    SetLength(Glb.MapProcList,Glb.MapProcNo+1);
    MapProcNo:=ProcSym^.TDbgProcNo; //Glb.MapProcNo;
    //if MapDoShow_LD then
    MapPNo:=MapProcNo; // else MapPNo:=0;
    with Glb.MapProcList[Glb.MapProcNo] do begin
      Name:=UnitName+'.'+CurProcName;
      Mapped:=MapDoShow_LD;
      TDbgProcNo:=ProcSym^.TDbgProcNo;
      MapBase:=0;
    end;
  end;

  SrcLNo:=0;
  for N:=1 to DagSortInx do with DagSort[N] do begin  //Collect all code
    if MapPNo>0 then begin
      if (SrcNo<>0) then
      if (SrcLine>0) and (SrcLNo<>SrcLine) then begin
        SrcLNo:=SrcLine;
        Glb.AnyMappedL:=True;
        S:=Format('L;%d;%d;%d;%.4x',[SrcNo,SrcLine,MapPNo,MapBase]);
        //DebugIfL(S);
        Glb.TestMapFile.Add(S); //L
      end;
    end;
    for M:=Low(OpS) to High(OpS) do begin
      mCode[C2]:={Swap}(OpS[M]); Inc(C2); Inc(MapBase,2);
    end;
    if TestMode then
      DisAsm(OpS,Low(OpS),High(OpS),i2s(Id));
  end;

  if PCRelData<>'' then begin
    PRel:=@PCRelData[1];
    for N:=1 to Length(PCRelData) div 2 do begin
      PRel^:=Swap(PRel^); Inc(PRel);
    end;
    Move(PCRelData[1], mCode[C2], Length(PCRelData));
  end;

  //if TestMode then DisAsm(mCode,C,C2-1);

  for N:=0 to High(Dags) do
    Dags[N].Free;
  Dags:=NIL;
  DagSort:=NIL;                //Index into Dags
end;

Procedure TUnit2.AllocateCodeBlock(G,CodeSizeW: Integer);
var C: Integer;
begin
  C:=Length(mCode); SetLength(mCode,C+CodeSizeW);
  with mCodeGrps[G] do begin
    if (CodeFirst or CodeCntW or FixupFirst or FixupCnt) <>0 then
      InternalError0;
    CodeFirst:=C; CodeCntW:=CodeSizeW;
  end;
  mCodeNext:=     Length(mCode);
  mFixupNext:=    Length(mFixup);
  mCodeGrpsNext:= Length(mCodeGrps);
end;

(************
//Procedure call
  PSLEV = 1
    JSR

  PSLEV-SLEV = 0
    MOVE.L A6,-(SP)
    JSR

  PSLEV-SLEV = 1
    MOVE.L 8(A6),-(SP)
    JSR

//Parameter PreAddr
  PSLEV-SLEV = 2..
    MOVE.L 8(A6),A0
    MOVE.L 8(A0),A0      N times ,N= PSLEV-SLEV-1
    MOVE.L 8(A0),-(SP)
    JSR

procedure tDag.AddressRefWhere(var EA: tEA; Option: eAddrPush; CodeWhere: tDag);
var OldCurCodeDag: tDag;
begin
  OldCurCodeDag:=CurCodeDag; CurCodeDag:=CodeWhere;
  AddressRef(EA, Option);
  CurCodeDag:=OldCurCodeDag
end;

(******************)

End.

