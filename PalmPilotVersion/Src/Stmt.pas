Unit Stmt;

interface

Uses Global, Assem, Dag, CodeDag;

Type
  TUnit6=Class(TUnit5b)
    Function  StPart(What: eSym; CurProcName: String; ProcSym: pSymRec): Integer; Override;
    Procedure DoFunction(P: pSymRec; var Code00: tDag0); Override;
  private
    Function  Statement(LCONT, LBREAK, LEXIT: tDag): tDag;
    Procedure CKEXP(L,R: TypPtr);
    Function  ComSt(LCONT, LBREAK, LEXIT: tDag): tDag;
    Function  STASM: tDag;
  end;

implementation

Uses SysUtils, Scanner, Util, Misc, Buildin, Global2;

(*StPart***********************************************************************)
Function TUnit6.StPart(What: eSym; CurProcName: String; ProcSym: pSymRec): Integer; //Ret=PGRPIX
var
  N,FlagNoFrame: Integer;
  LExit,Code,CodeStmt,CodeEnter,C2: tDag;
  ProcName: String;
begin
  Global.CurProcName:=CurProcName;
  CurProcNameCase:=CurProcName; ///???????? why, dolater
  ProcName:=CurProcName;
  if Assigned(UIIntf.CallBack) then begin
    //UIIntf.CallBack(UnitName+', '+ProcName,-1);
    With IBU,IBUGLB.SrcPTR^ do N:=IBULINENO;
    UIIntf.CallBack(Format('%s(%d): %s',[UnitName,N,ProcName]));
  end;
  C2:=NIL;
  //Result:=0;
  AsmScope:=NewScope(skProcedure,'AsmScope');
  if ProcSym=NIL then InternalError0;       //MainProc!!
  if PDNoA6Frame in ProcSym^.PFLAG then FlagNoFrame:=0 else FlagNoFrame:=2;
  CurAddrTemp:=ProcSym^.UsageA6; MaxAddrTemp:=EvenSize(CurAddrTemp);
  dagInitializeProc(ProcName,ProcSym);

  CodeEnter:=CodeIns(pcEnter,FlagNoFrame,NIL,NIL,ProcName);
  for N:=1 to ProcSym^.PCpyParmCnt do
    with ProcSym^.PCpyParm[N] do begin
      C2:=CodeIns(pcMisc,1,C2,NIL);
      C2.opMisc.Above:=Above;
      C2.opMisc.Below:=Below;
      C2.opMisc.Size:=Size;
    end;
  CodeEnter.ParmAfter:=C2;
  LExit:=CodeJmpLabel('LExit');
  if What=SASM then begin
    CodeStmt:=STASM;
    DidASM:=True; //Usefull for debug break!
  end else begin
    Find(What);
    CodeStmt:=ComSt(nil,nil,LExit);
  end;
  CodeStmt:=CodeLd(CodeStmt,LExit);
  Code:=CodeIns(pcEnter,FlagNoFrame + 1,CodeEnter,CodeStmt,ProcName);
  //CodeEnter.op3:=MaxAddrTemp;
  //Code.op3:=ProcSym^.PPARS-8; //Above A6 size!
  //if PDSysProc in ProcSym^.PFLAG then
    Code.op3:=ProcSym^.PUSTK+ProcSym^.XUNSTK-8; //Above A6 size!, also return param ptr.
  Result:=dagCodeProc(Code, ProcSym, ProcName);
  DisposeScope;
end;

(*ComSt************************************************************************)
Function TUnit6.ComSt(LCONT, LBREAK, LEXIT: tDag): tDag;
Const Errs: array[boolean] of Byte=(Err_Stmt,Ord(SSEM));
Var St: tDag;
begin
  St:=Statement(LCONT, LBREAK, LEXIT);
  Result:=CodeLD(CodeIns(pcNewBB,0,NIL,NIL,'NBB0') {} ,St); {}
  While not Scan(SEND) do begin
    if not Scan(SSEM) then Error(Errs[StopF]);
    St:=Statement(LCONT, LBREAK, LEXIT);
    Result:=CodeLD(Result,St);
  end;
  Result:=CodeIns(pcNewBB,1,Result,NIL,'NBB1'); {Save regs, etc}
end;

Function TUnit6.STASM: tDag;
var Code2: tDag;
begin
  Result:=NIL;
  try
    DoingASM:=True;     //Before ALL ScanXX with ASM statements
    DoingEOLN:=True;
    Find(SASM); ///ScanNext;
    repeat
      DoingEOLN:=True;  //Before ALL ScanXX  with ASM statements
      while ScanSSEM do ;
      if Scan(SEND) then BREAK;
      AsmLine(Code2);
      //DoingEOLN:=False; //Before ALL ScanXX with ASM statements
      Scan(SEOLN);      //Get rid of SEOLN flag
      Result:=CodeLd(Result,Code2);
    until False;
    if AsmUndefLabels<>0 then Error(Err_UndefAsmLabel);
  finally //Reset in case of errors
    DoingASM:=False;
    DoingEOLN:=False;
    ScanNext;           //Get rid of SEOLN flag
  end;
end;

(*Statement********************************************************************)
Function  TUnit6.Statement(LCONT, LBREAK, LEXIT: tDag): tDag;

// IF BE THEN E1
// IF BE THEN E1 ELSE E2
Procedure STIF(var Code: tDag);
var LabelElse,LabelElseOk,CodeB,CodeThen,CodeElse,JUMP: tDag;
begin
  ScanNext;
  //LabelElse:=CodeJmp(CondLABEL,NIL,'STIFelse');
  LabelElse:=NIL; BExpressionJmp(LabelElse,CodeB);  //jmp to LabelElse if FALSE
  Find(STHN);
  CodeThen:=Statement(LCONT, LBREAK, LEXIT);
  if Scan(SELS) then begin
    LabelElseOk:=CodeJmpLabel('STIFok');
    JUMP:=CodeJmp(CondT,LabelElseOk,'STIF2');
    CodeElse:=Statement(LCONT, LBREAK, LEXIT);
    Code:=CodeList(pcIF,2,[CodeB,CodeThen,JUMP,LabelElse,CodeElse,LabelElseOk],'HasElse');
  end else begin
    Code:=CodeList(pcIF,1,[CodeB,CodeThen,LabelElse],'NoElse');
  end;
end;

// WHILE BE DO STMT
// pcWHILE L1 BE STMT JMP L2
Procedure STWHILE(var Code: tDag);
var BE,E1,JMP,LCont,LBreak: tDag;
begin
  ScanNext;
  LCont:=CodeJmpLabel('LContinue');
  //LBreak:=CodeJmpLabel('LBreak');
  LBreak:=NIL; BExpressionJmp(LBreak,BE);  //jmp to LBreak if FALSE
  Find(SDO);
  E1:=Statement(LCont,LBreak,LEXIT);
  JMP:=CodeJmp(CondT,LCont,'STWHILE4');
  Code:=CodeList(pcWHILE,0,[LCont,BE,E1,JMP,LBreak]);
end;

// REPEAT STMT UNTIL BE
// pcREPEAT xx xx xx
Procedure STREPEAT(var Code: tDag);
var LLoop,LCont,BE,LBreak: tDag;
begin
  ScanNext;
  //LLoop:=CodeJmpLabel('Repeat');
  LCont:=CodeJmpLabel('LContinue');
  LBreak:=CodeJmpLabel('LBreak');
  repeat
    Code:=CodeLD(Code,Statement(LCont,LBreak,LEXIT));
    if Scan(SUNT) then BREAK;
    Find(SSEM);
  until FALSE;
  LLoop:=NIL; BExpressionJmp(LLoop,BE);  //jmp to LCont if FALSE
  Code:=CodeList(pcREPEAT,0,[LLoop,Code,LCont,BE,LBreak]);
end;

// FOR V := E1 TO|DOWNTO E2 DO STMT
// pcFOR V E1 E2 LBL1 STMT LCONT LBREAK
Procedure STFOR(var Code: tDag);
var V, E1, E2: TypPtr; OP: eSym; B: eSubFor;
  CodeV, EFrom, ETo, LLoop, LCont, LBreak, CodeStmt: tDag;
begin
  LLoop:=CodeJmpLabel('Loop');
  LCont:=CodeJmpLabel('LContinue');
  LBreak:=CodeJmpLabel('LBreak');
  ScanNext;
  Inc(NLEV);            //FOR nesting level
  V:=FIVAR(CodeV,TRUE); {MUST BE COPIED!! to temp var first!!!!}
  if (CodeV.OpRec.OSLEV<>0) and (CodeV.OpRec.OSLEV<>SLEV) then
    Error(Err_InvFOR);
  if not (V^.TTYPE in SetSimType) then
    Error(Err_InvFor);
  {CHECK GLOBAL/LOCAL & not INDEXED/INDIRECT  !!!!!!!!!}
  Find(SCEQ);
  E1:=Expression(EFrom); EFrom:=CodeIns(pcMisc,2,EFrom,NIL);
  CKEXP(V,E1);	{L,R}
  if Scan(SDTO) then OP:=SDTO else begin OP:=STO; Find(STO); end;
  E2:=Expression(ETo);   ETo:=CodeIns(pcMisc,2,ETo,NIL);
  CKEXP(V,E2);	{L,R}
  Find(SDO);
  if OP=STO then B:=ForInc else B:=ForDec;
  CodeStmt:=Statement(LCont, LBreak, LEXIT);
  Code:=CodeList(pcFOR,ord(B), [CodeV, EFrom, ETo, LLoop, CodeStmt, LCont, LBreak]);
  Code.ForLevel:=NLEV; 
  Dec(NLEV);
end;

// CASE E of C1,... else end
// pcCASE
Procedure STCASE(var Code: tDag);
var
  EB: TypPtr;
Function FindLabel: Integer;
var E: TypPtr; Code: tDag;
begin
  InsNotAllowed:=True; E:=CExpression(Code); InsNotAllowed:=False;
  if E^.TBASE<>EB then Error(CaseTypes);
  //if E^.TSIZE>MaxSize then Error(ExpEOrdinal); //Always 4!!
  Result:=Code.ConI;
end;
var
  Expr,LNext: tDag;
  E: TypPtr;
  Ok: Boolean;
  Single: Array[1..500] of Integer;
  Double: Array[1..500] of Record A,B: Integer end;
  Codes:  Array of tDag;
  CaseNo, N, L1, L2, SCnt, DCnt: Integer;
  ResStr: String;
  DummyEA: tEA;
Label Lend,Lelse;
procedure AddS(N: Integer);
begin
  if SCnt>=High(Single) then InternalError('Case');
  Inc(SCnt); Single[SCnt]:=N;
end;
Procedure AddResB(B: Integer);
begin
  ResStr:=ResStr+Char(lo(B))
end;
Procedure AddResW(W: Integer);
begin
  AddResB(Lo(Swap(W))); AddResB(Lo(W));
end;
Procedure AddResL(L: Integer);
begin
  AddResW(L shr 16); AddResW(L);
end;
(*STCASE************************************************************************)
begin
  ScanNext; E:=CExpression(Expr); EB:=E^.TBASE; Find(SOF);
  Expr:=CodeIns(pcMisc,2,Expr,NIL);
  //MaxSize:=E.TSIZE;
  LNext:=CodeJmpLabel('LNext');
  SetLength(Codes,1); //#0=else, #1=stmt's
  repeat
    SCnt:=0; DCnt:=0;
    repeat
      L1:=FindLabel;
      if Scan(SDPE) then begin
        L2:=FindLabel;
        if Abs(L2-L1)<=2 then for N:=L1 to L2 do AddS(N)
        else
          if DCnt<High(Double) then begin
            Inc(DCnt); with Double[DCnt] do begin A:=L1; B:=L2 end;
          end;
      end else
        AddS(L1);
    until not Scan(SCOM);
    Find(SCOL);
    SetLength(Codes,Length(Codes)+1);
    CaseNo:=High(Codes); if CaseNo>255 then InternalError0;
    Code:=Statement(LCONT, LBREAK, LEXIT);
    if Code=NIL then Code:=LNext
    else Code:=CodeLd(Code, CodeJmp(CondT,LNext,'CaseBreak'));
    Codes[High(Codes)]:=Code;
    Ok:=Scan(SSEM);
    //Double: CC00 LLLLLLLLLL..HHHHHHHHHH CC00 LLLLLLLLLL..HHHHHHHHHH
    for N:=1 to DCnt do begin
      AddResB(0);                    //Casetype=0 = Double
      AddResB(CaseNo);               //Caseno = lo byte
      AddResL(Double[N].A); AddResL(Double[N].B);
    end;
    //Single: CC03 NNNN 11111111,2222222222,33333333,44444444
    if SCnt>0 then begin
      AddResB(3);                    //Casetype=3 = Single
      AddResB(CaseNo);               //Caseno = lo byte
      AddResW(SCnt);
      for N:=1 to SCnt do
        AddResL(Single[N]); //Type #3= N*Single CaseConsts
    end;
    case Next.Ch of
    SEND: begin ScanNext; goto Lend; end;
    SELS: begin ScanNext; goto Lelse; end;
    end;
    if not Ok then Find(SEND); {Never found!}
  until False;
Lelse:
  Code:=ComSt(LCONT, LBREAK, LEXIT);
  Codes[0]:=CodeLd(Code, CodeJmp(CondT,LNext,'CaseElse'));
Lend:
  if not Assigned(Codes[0]) then Codes[0]:=LNext; //No ELSE, then END
  AddResW($FFFF);
  N:=tDag.AddPCRelData(ResStr,DummyEA);
  Code:=CodeList(pcCASE,N,Codes);
  Code.ParmL:=Expr;
  Code.ParmExit:=LNext;
end;

Procedure ASFI(P: pSymRec; var Code: tDag); {V:=Function}
var E: TypPtr; Code2: tDag;
begin
  ScanNext;
  Code2:=CodeIns(pcVAR,0,NIL,NIL,'ASFI1');
  with Code2.OpRec do begin
    xxOTyp:=P^.PTYPP;
    OTYPE:=P^.PTYPP^.TTYPE;
    Code2.SetSize(P^.PTYPP);
    VADDR:=P^.PUSTK;      //Unstack size = Return value position
    OSLEV:=P^.PSLEV;
    Indexed:=False;
    if ParamByRef(Code2.OpRec.xxOTYP) then VVarF:=vfVar else VVarF:=vfLocal;
  end;
  Find(SCEQ);
  E:=Expression(Code);
  CKEXP(P^.PTYPP,E);	{L,R}
  Code:=CodeInsSTO(Code2,Code,'ASFI2'); {!!!!!!!!!!}
end;

Procedure ASST(var Code: tDag); {Assign V:=Expr}
var E,V: TypPtr; Code2: tDag;
begin
  V:=FIVAR(Code2);
  if (V^.TTYPE in [TNON{,TFIL,TTXT}]) then Error(Err_IllAssignment);
  Find(SCEQ);
  E:=Expression(Code);
  CKEXP(V,E);	{L,R}
  Code:=CodeInsSTO(Code2,Code,'ASST');
end;

// pcWITH 0, Left=PrevStmt, Right=V
// pcWITH 1, STMT, prev-line
Procedure STWITH(var Code: tDag);
var V: TypPtr; ScoCnt: Integer; Code2: Array of tDag; Code1: tDag;
begin
  DebugNStmt; ScanNext; ScoCnt:=0;
  repeat
    Inc(ScoCnt);
    V:=FIVAR(Code1);
    SetLength(Code2, ScoCnt); Code2[ScoCnt-1]:=Code1;
    if Code1.op=pcDEREF then //pcDEREF, op2=1 !!
      Code1.op2:=1; //Save an A0 to A2 load!!
    if not (V^.TTYPE in [TREC,TOBJ]) then Error(ExpVRecord);
    NewScope(skWith,'With');
    with GetScopeTop do begin
      LinkSameScope:=V^.TSCOP;
      SYM.SWithCode[SYM.Cnt]:=Code1;
    end;
    Code:=CodeIns(pcWITH,0,Code,Code1);
  until not Scan(SCOM);
  Find(SDO);
  DebugNStmt;
  Code:=CodeLD(Code,Statement(LCONT, LBREAK, LEXIT));
  for ScoCnt:=1 to ScoCnt do begin
    Code:=CodeIns(pcWITH,9,Code,Code2[ScoCnt-1]);
    DisposeScope;
  end;
end;

Procedure STGOTO(var Code: tDag);
var P: pSymRec; WithCode: TDag0;
begin
  DebugNStmt;
  ScanNext;
  IntIdn; //Label # => String ID's
  P:=ScanSym(False, WithCode);
  with P^ do begin
    if (What<>SLBL) then Error(UndefLabel);
    if LSLEV<>SLEV then Error(Err_LabelBlock);
    if LADDR=NIL then LADDR:=CodeJmpLabel('STGOTO');
    Code:=CodeJmp(CondT,tDag(LADDR),'STGOTO');
  End;
  ScanNext;
end;

Procedure DEFLBL(var Code: tDag);
var P: pSymRec; WithCode: TDag0;
begin
  IntIdn;	//Label # => String ID's   Make SICO to SIDN
  P:=ScanSym(False, WithCode);
  with P^ do begin
    if (What<>SLBL) then Error(UndefLabel);
    if LDEFI then Error(Err_LabelX2);
    if LADDR=NIL then LADDR:=CodeJmpLabel('DEFLBL');
    LDEFI:=True;	{Defined label}
    Code:=tDag(LADDR);
  end;
  ScanNext; Find(SCOL);
end;

{= Statement ==================================================================}
var P: pSymRec; Code,CodeLabel: tDag;
Label LStatement; Var WithCode: TDag0;
begin
  Result:=NIL;
  //If SPtr<SptrLow then Error(Err_Memory);
  CodeLabel:=NIL;
LStatement:
  Code:=NIL;
  StopF:=True;
  case Next.Ch of
  SSEM: Exit;
  SBGN:	begin Find(SBGN);
          Code:=ComSt(LCONT, LBREAK, LEXIT);
        end;
  {{ SPRO: STPRO(Code); {{???}
  SIF:	STIF(Code);
  SWHL:	STWHILE(Code);
  SREP:	STREPEAT(Code);
  SFOR:	STFOR(Code);
  SCAS:	STCASE(Code);
  SWTH:	STWITH(Code);
  SASM:	Code:=STASM;
  SGTO:	STGOTO(Code);
  SICO: begin
          DEFLBL(Code);
          CodeLabel:=CodeLd(CodeLabel,Code);
          Goto LStatement;
        End; {Do Again}
  SIDN: begin
          P:=ScanSym(False, WithCode);
          case P^.What of
          SVAR: ASST(Code);
          SSTP: StaProc(P,tDag0(Code));
          SPRO: begin
                  ScanNext;
                  DoFunction(P, tDag0(Code));
                end; //STPRO(P,Code);
          SFUN: ASFI(P,Code);
          SLBL: begin
                  DEFLBL(Code);
                  CodeLabel:=CodeLd(CodeLabel,Code);
                  Goto LStatement;
                End; {Do Again}
          {{{{{     else  Error(Err_Error); {{{{{{{{}
          End;
      end;
  // else {Nothing}
  SCONT:  if LCONT=NIL then Error(Err_CannotBreak)
          else begin
            ScanNext; Code:=CodeLd(Code,CodeJmp(CondT,LCONT,'CONTINUE'));
          end;
  SBREAK: if LBREAK=NIL then Error(Err_CannotBreak)
          else begin
            ScanNext; Code:=CodeLd(Code,CodeJmp(CondT,LBREAK,'CONTINUE'));
          end;
  SEXIT: begin ScanNext; Code:=CodeLd(Code,CodeJmp(CondT,LEXIT,'ProcEXIT')) end;
  end;
  Statement:=CodeLd(CodeLabel,Code);
end;

{ CKEXP =======================================================================}
{ Check expression type
; In	R = Pointer to source operand  (TYPE!!!!!!!!!!!)
;	L = Pointer to destination type record}

Function SetElementBaseA1(T: TypPtr): TypPtr;
begin
  if T^.TELEP=NIL then SetElementBaseA1:=@GlbEmptySet
  else begin
    SetElementBaseA1:=T^.TELEP^.TBASE;
  end;
end;

Procedure TUnit6.CKEXP(L,R: TypPtr);
var LT,RT: eType; B: Boolean;
begin
  if L<>R then begin
    RT:=R^.TTYPE; LT:=L^.TTYPE;
    B:=False;
    case LT of
    TINT,TBOL,TCHR,TUSR: B:= L^.TBASE=R^.TBASE;
    TREA: B:=(RT=TINT) or (RT=TREA);
    TSTR: case RT of
          TCHR,TPAC,TSTR: B:=True;
          TPTR: B:=R^.TELEP^.TTYPE=TCHR;
          end;
    TPAC: B:=(RT in [TPAC,TSTR]) and (L^.TSIZE=R^.TSIZE);
    TSET: begin
            B:= RT=TSET;
            if B then begin
              L:=SetElementBaseA1(L); R:=SetElementBaseA1(R);
              if (L<>@GlbEmptySet) and (R<>@GlbEmptySet) then
                B:= L=R;
            end;
          end;
    TPTR: begin
            B:= RT=TPTR;
            if B then begin
              L:=L^.TELEP; R:=R^.TELEP;
              if (L<>@StandardType[xUNT]) and (R<>@StandardType[xUNT]) then
                B:= L=R;
            end;
          end;
    //TFIL,TTXT
    (**TNON,
    TARY,
    TREC,
    TOBJ: B:=False;
    (***)
    end;
    if not B then Error(TypeMismatch);
  end;
end;

{ DoFunction ==================================================================}
Procedure TUnit6.DoFunction(P: pSymRec; var Code00: tDag0); {Procedure statement}
var
  Code: tDag absolute Code00; //Typecast!!
  StackUse,Param,N: Integer;
  VarSym: pSymRec;
  ExprTyp,ParamTyp: TypPtr;
  Code2: tDag;
  SysProcType: eSysProcType;
  CStack: Boolean;
  Params: Array[1..100] of tDag;
begin {DoFunction}
  DebugNStmt;
  StackUse:=0;
  with P^ do begin
    if PPARC<>0 then begin
      FindSLPA;
      VarSym:=@SPROlast;
      Param:=PPARC;
      for Param:=1 to Param do begin
        with VarSym^ do begin
          ParamTyp:=VTYPP;
          if VVARF in [vfVar,vfVarCopy,vfVarConst] then begin
            if VVARF in [vfVarCopy,vfVarConst] then begin
              ExprTyp:=Expression(Code2);
              CKEXP(ParamTyp,ExprTyp);
              if ParamTyp^.TSIZE>2 then Inc(StackUse,4) else Inc(StackUse,2);
            end else begin
              Inc(StackUse,4);
              ExprTyp:=FIVAR(Code2);
              if (ParamTyp^.TTYPE=TNON) or
                 ((ParamTyp^.TTYPE=TNON) and (cdV in OptionsLocal.Active)) then {OK}
              else
                if ParamTyp<>ExprTyp then Error(TypeMismatch);
            end;
            //0: Record -> Var     => Pea
            //1: Var    -> Var     => MOVE.L
            //2: Var    -> Value   => MOVE.L (called prod does the copy)
            //if ParamTyp^.TSIZE<=0 then N:=1 else N:=0; //1=To a Var
            //Code:=CodeIns(pcFuncParm,N,Code2,NIL,'VarPARAM'+CHAR(Param+48));
            if Code2.OpRec.VVARF in [vfVar,vfVarConst{}] then
              Code:=CodeIns(pcFuncParm,1,Code2,NIL,'VarPARAM'+CHAR(Param+48))
            else
              Code:=CodeIns(pcFuncParm,0,Code2,NIL,'VarPARAM'+CHAR(Param+48));
          end else begin
            ExprTyp:=Expression(Code2);
            CKEXP(ParamTyp,ExprTyp);
            if ParamTyp^.TSIZE>2 then Inc(StackUse,4) else Inc(StackUse,2);
            //if Code2.OpRec.OTYPE=TSET then
            //  Code:=CodeIns(pcFuncParm,3,Code2,NIL,'PARAM'+CHAR(Param+48)) {Set to stack (as tempset)}
            //else
              if Code2.OpRec.VVARF=vfVarConst then
                Code:=CodeIns(pcFuncParm,1,Code2,NIL,'PARAM'+CHAR(Param+48)) {move @S to stack}
              else
                Code:=CodeIns(pcFuncParm,2,Code2,NIL,'PARAM'+CHAR(Param+48)); {less than 4 bytes to stack}
            //Code2.SetSize(ParamTyp);
            Code.SetSize(ParamTyp);
          end;
          Code.OpRec.OType:=ParamTyp^.TTYPE;
          Code.OpRec.xxOTyp:=ParamTyp;
          Params[Param]:=Code;
        end;
        if Param<>PPARC then begin
          Find(SCOM);
          Inc(Longint(VarSym),SymRecSize(VarSym^));
        end;
      end;
      FindSRPA;
    end;
    Code:=NIL;
    //PFLAG=PDnormal,PDdefined,PDdoingDef,PDasm,PDNoFrame,PDNoResultSpace
    //      PDconstructor,PDdestructor,PDvirtual,Pdmethod,
    //      PDforward,PDinline,PDsystrap,PDcdecl{,PDextrn});
    CStack:=[PDcdecl,PDsystrap] * PFLAG <> [];
    SysProcType:=eProc;
    if What=SFUN then begin
      if CStack then
        case PTYPP^.TTYPE of
        TPTR,
        TSTR: SysProcType:=eFuncA0;
        //TBOL: SysProcType:=eFuncD0BoolC;
        else  SysProcType:=eFuncD0;
        end
      else
        SysProcType:=ePasFunc;
      if PDSysProc in PFLAG then Error(Err_InvSysProc);
    end;
    if PDsystrap in PFLAG then
      Code2:=CodeCallTrap(SysProcType,P^.PFUNO,StackUse)
    else
      Code2:=CodeProcFunc(SysProcType,OpcBSR,P^.PRef,PSLEV,'doPROC');

    (**
    if PDcdecl in PFLAG then
      for Param:=PPARC downto 1 do Code:=CodeLD(Code,Params[Param])
    else
      for Param:=1 to PPARC do Code:=CodeLD(Code,Params[Param]);
    (**)
    SetLength(Code2.ParmList,PPARC);
    for N:=1 to PPARC do
      if PDcdecl in PFLAG then Code2.ParmList[PPARC-N]:=Params[N] //PPARC-1 .. 0
      else Code2.ParmList[N-1]:=Params[N];                        //0 .. PPARC-1

    if P^.What=SFUN then begin
      Code2.OpRec.xxOTyp:=P^.PTYPP;
      Code2.OpRec.OTYPE:=P^.PTYPP^.TTYPE;
      Code2.ParmL:=CodeIns(pcFuncRes,0,NIL,NIL,'RESULT');
    end;
    //Code2.ParmL:=Code;
    Code:=Code2;
  end;
  //Code:=CodeLd(Code,Code2);
end;

{==============================================================================}

end.

