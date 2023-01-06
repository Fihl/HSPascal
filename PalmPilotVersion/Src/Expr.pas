Unit Expr;

interface

Uses SysUtils, Global, CodeDag, Dag, Rsrc{TUnit4};

Const
  MaxOPno=6;
Type
  tOPTable=Record
    sOP: Set of eSym;
    Sym: packed array [0..MaxOPno] of eSym;
    OP:  packed array [0..MaxOPno] of eSubBinOPs;
    Mask:array [BinOpTyp] of Set of eSubBinOPs;
  End;

  TUnit5=Class(TUnit4)
    Function  Expression(var Code: tDag): TypPtr;
    Function  CExpression(var Code: tDag): TypPtr;        {Ordinal}
    Procedure BExpressionJmp(var LFalse, Code: tDag);
    Function  FIVAR(var Code: tDag; OnlySimpleVar: Boolean=False): TypPtr;
    Function  SCVAR(var Code: tDag): TypPtr;
    Function  ADRFAC(var Code: tDag): TypPtr; 
  private
    Function  Expres(var LTrue,LFalse,Code: tDag): TypPtr;
    Function  BinOP(L, R: TypPtr; Ch: eSym; var OPTable: tOPTable;
                    LCode: tDag; var Code: tDag; Const Comment: String): TypPtr;
    Function  FUNFAC(P: pSymRec; var Code: tDag): TypPtr;
    Function  SetFactor(var Code: tDag): TypPtr;
    Function  SCTYP(var Code: tDag; OnlySimpleVar: Boolean=False): TypPtr;
  end;

implementation

Uses Util, Misc, SyDefault, Stmt, Buildin;

Const
  TRELOP: tOPTable = (sOP: [SEQS,SNES,SGTS,SLTS,SGES,SLES, SIN {SIN are Special}];
                      Sym: (SEQS,SNES,SGTS,SLTS,SGES,SLES,SNONE);
                      OP:  (opEQ,opNE,opGT,opLT,opGE,opLE,OP0);
                      Mask:(
			[opEQ,opNE,opGE,opLE],			{TSET}
			[opEQ,opNE,opGT,opLT,opGE,opLE],	{TPAC}
			[opEQ,opNE],				{TPTR}
			[opEQ,opNE,opGT,opLT,opGE,opLE],	{TSTR}
			[opEQ,opNE,opGT,opLT,opGE,opLE],	{TREA}
			[opEQ,opNE,opGT,opLT,opGE,opLE],	{TINT}
			[opEQ,opNE,opGT,opLT,opGE,opLE],	{TBOL}
			[opEQ,opNE,opGT,opLT,opGE,opLE],	{TCHR}
			[opEQ,opNE,opGT,opLT,opGE,opLE])	{TUSR}
                      );
  TADDOP: tOPTable = (sOP: [SPLS,SMIN,SOR,SXOR];
                      Sym: (SPLS,SMIN,SOR,SXOR,SNONE,SNONE,SNONE);
                      OP:  (opADD,opSUB,opOR,opXOR,OP0,OP0,OP0);
                      Mask:(
			[opADD,opSUB],				{TSET}
			[],					{TPAC}
			[],					{TPTR}
			[opADD],				{TSTR}
			[opADD,opSUB],				{TREA}
			[opADD,opSUB,opOR,opXOR],		{TINT}
			[opOR,opXOR],				{TBOL}
			[],					{TCHR}
			[])					{TUSR}
                      );
  TMULOP: tOPTable = (sOP: [SAST,SSLA,SDIV,SMOD,SAND,SSHL,SSHR];
                      Sym: (SAST,SSLA,SDIV,SMOD,SAND,SSHL,SSHR);
                      OP:  (opMUL,opRDV,opDIV,opMOD,opAND,opSHL,opSHR);
                      Mask:(
			[opMUL],				{TSET}
			[],					{TPAC}
			[],					{TPTR}
			[],					{TSTR}
			[opMUL,opRDV],				{TREA}
			[opMUL,opDIV,opMOD,opSHL,opSHR,opAND],	{TINT}
			[opAND],				{TBOL}
			[],					{TCHR}
			[])					{TUSR}
                       );

Const GlbOptIndex: packed array [SAND..SLES] of Shortint=(
	4,	{SAND	}
	2,	{SDIV	}
	3,	{SMOD	}
	2,	{SOR	}
	5,	{SSHL	}
	6,	{SSHR	}
	3,	{SXOR	}
	0,	{SPLS	}
	1,	{SMIN	}
	0,	{SAST	}
	1,	{SSLA	}
	0,	{SEQS	}
	1,	{SNES	}
	2,	{SGTS	}
	3,	{SLTS	}
	4,	{SGES	}
	5	{SLE	} );

{========================================================================}
{LTrue, LFalse is set to jumps, fx not allowed for Expression}//NOT SUPPORTED YET!!!!!!
Function  TUnit5.Expres(var LTrue,LFalse,Code: tDag): TypPtr; {Main procedure}

Function Factor(var LTrue,LFalse,Code: tDag): TypPtr;
var L,po: TypPtr; P: pSymRec; WithCode: tDag0;
begin
  LTrue:=NIL; LFalse:=NIL; //NOT SUPPORTED YET!!!!!!
  Case Next.Ch of
  SIDN: begin
          P:=ScanSym(False, WithCode);
          case P^.What of
          SVAR:	begin
                  Result:=SCTYP(Code);
                  Code.OpRec.WithCode:=WithCode;
                end;
          STYPP: Begin
                   PO:=P^.TTYPP;
                   if PO^.TTYPE=TOBJ then begin
                     ScanNext; Find(SPER);
                     if Next.Ch<>SIDN then Error(ord(SIDN));

                     UNIMPLEMENTED; //////
                     P:=ScanScope(PO^.TSCOP);

                     if P^.What<>SFUN then Error(Err_ExpMethod);
                     Result:=FUNFAC(P,Code);
                   end else begin
                     Result:=SCTYP(Code);
                     {{ DagSetFlag(Code,dfDeRef); {}
                     {{ Code:=CodeIns(pcDREF,0,Code,0,'fac SIDN'); {}
                   end;
                 end;
          SFUN:	Result:=FUNFAC(P,Code);
          SSTF:	Result:=StaFunc(P,tDag0(Code));
          else
            L:=CONSTANT; Result:=L; if L=NIL then Error(Err_Expr);
            case L^.TTYPE of
            TINT..TUSR: begin
                          Code:=CodeConst(Next.IValue,L^.TTYPE);
                          Code.SetSize(L)
                        end;
            TREA:       Code:=CodeConst(Next.RValue,TREA);
            TPAC,
            TSTR:       Code:=CodeConst(Next.SValue,TSTR);
            else        InternalError0
            end;
          end;
          {{{{{{{ ScanNext; {{{{{{{{{}
        end;
  SCAR,SRCO,SCCO,SSCO,
  SICO: begin
          L:=CONSTANT; Result:=L; if L=NIL then Error(Err_Expr);
          case L^.TTYPE of
          TREA: Code:=CodeConst(Next.RValue,TREA);
          TPAC: With Result^ do begin
                  TMINV:=1; TMAXV:=Length(Next.SValue);
                  TSIZE:=EvenSize(TMAXV-TMINV+1);
                  Code:=CodeConst(Next.SValue,TSTR);
                end;
          TSTR: Code:=CodeConst(Next.SValue,TSTR);
          TCHR: Code:=CodeConst(Next.IValue,TCHR);
          else  begin Code:=CodeConst(Next.IValue,TINT); Code.SetSize(L) end;
          end;
          Code.OpRec.xxOTyp:=L;
        end;
  SLPA: begin ScanNext; Result:=Expres(LTrue,LFalse,Code); Find(SRPA) end;
  SLBR: begin ScanNext; Result:=SetFactor(Code); end;
  SCAT: begin ScanNext; Result:=ADRFAC(Code); end;
  SNIL: begin ScanNext; Code:=CodeConst(0,TPTR); Result:=@StandardType[xPtr]
        end;
  else  Result:=NIL; //Keep hints away!
        Error(Err_Expr);
  End;
end;

Function SignFact(var LTrue,LFalse,Code: tDag): TypPtr;
var OP: eSign;
begin
  OP:=Sign;
  Result:=Factor(LTrue,LFalse,Code);
  if OP<>SignNone then begin
    if not (Result.TTYPE in [TREA,TINT,TUSR]) then Error(Err_Expr);
    if OP=SignMinus then
      if Code.op=pcConst then
        Code.OpRec.ConstVal:= -Code.OpRec.ConstVal
      else begin
        Code:=CodeIns(pcMonOP,ord(opNEG),Code,NIL,'MonOP NEG');
        Code.AssignType(Code.ParmL);
      end;
  end;
end;

Function CompFact(var LTrue,LFalse,Code: tDag): TypPtr;
begin
  if Next.Ch=SNOT then begin
    ScanNext;
    Result:=SignFact(LTrue,LFalse,Code);
    if not (Result.TTYPE in [TBOL,TINT]) then Error(Err_Expr);
    Code:=CodeIns(pcMonOP,ord(opNOT),Code,NIL,'MonOP NOT');
    Code.AssignType(Code.ParmL);
  end else
    Result:=SignFact(LTrue,LFalse,Code);
end;

Function Term(var LTrue,LFalse,Code: tDag): TypPtr;
var L,R: TypPtr; OP: eSym; Code2: tDag;
begin
  L:=CompFact(LTrue,LFalse,Code);
  while Next.Ch in TMULOP.sOP do begin
    Code2:=Code;
    OP:=Next.Ch; ScanNext; R:=CompFact(LTrue,LFalse,Code);
    L:=BinOP(L,R,OP,TMULOP,Code2,Code,'Term');
  end;
  Result:=L;
end;

Function SimpleExpr(var LTrue,LFalse,Code: tDag): TypPtr;
var L,R: TypPtr; OP: eSym; Code2: tDag;
begin
  L:=Term(LTrue,LFalse,Code);
  while Next.Ch in TADDOP.sOP do begin
    Code2:=Code;
    OP:=Next.Ch; ScanNext; R:=Term(LTrue,LFalse,Code);
    L:=BinOP(L,R,OP,TADDOP,Code2,Code,'SimpleExpr');
  end;
  Result:=L;
end;

{Function  Expres(var LTrue,LFalse,Code: tDag): TypPtr; {Main procedure}
var L,R: TypPtr; OP: eSym; Code2: tDag; LT: eType;
begin {Expres}
  L:=SimpleExpr(LTrue,LFalse,Code);
  if Next.Ch in TRELOP.sOP then begin	{sOP includes SIN too!}
    Code2:=Code;
    OP:=Next.Ch; ScanNext; R:=SimpleExpr(LTrue,LFalse,Code);
    if OP=SIN then begin
      LT:=L^.TTYPE;
      if not (LT in [TINT..TUSR]) then Error(ExpEOrdinal);

      if R^.TELEP<>NIL then
      if R^.TELEP^.TBASE=NIL then Error(TypeMismatch);  //????
      //if R^.TBASE=NIL then Error(TypeMismatch);  //????
      //if LT<>R^.TBASE^.TTYPE then

      //if LT<>R^.TELEP^.TBASE^.TTYPE then
      if L^.TBASE<>R^.TELEP^.TBASE then
        Error(TypeMismatch);
      Code:=CodeIns(pcBinOP,ord(opSIN),Code2,Code,'BINOP: IN');
      L:=@StandardType[xBOL];
      Code.OpRec.OTYPE:=TBOL;
      Code.OpRec.xxOTyp:=L;
    end else
      L:=BinOP(L,R,OP,TRELOP,Code2,Code,'Expres');
  end;
  Result:=L;
end;

{========================================================================}
Function  TUnit5.ADRFAC(var Code: tDag): TypPtr;
var P: TypPtr; S: pSymRec; WithCode: TDag0;
begin
  S:=ScanSym(False, WithCode); {Does NOT do ScanNext!}
  case S^.What of
  SPRO,SFUN: begin
               if [PDsystrap,PDcdecl,PDSysProc]*S^.PFLAG <>[] then Error(Err_InvalAddr);
               //Code:=CodeProcFunc(eProc,OpcBSR,S^.PRef,'@PROC');
               Code:=CodeIns(pcADDR,1,NIL,NIL);
               with Code do begin
                 SetLength(OpS,2);
                 SetLength(OpSFix,2);
                 OpS[0]:=$41FA; //LEA d(PC),a0
                 OpS[1]:=2;
                 OpSFix[1]:=S^.PRef;
               end;
               ScanNext;
             end;
  else ///Error(Err_InvalAddr);
    P:=SCVAR(Code);
    if P=NIL then InternalError0;
    Code:=CodeIns(pcADDR,0,Code,NIL);
    Code.OpRec.aEA.EAsize:=easL;
    //Code.OpRec.WithCode:=WithCode;
  end;
  Result:=@StandardType[xPTR];
end;

{========================================================================}
//Will modify "Code"
Function  TUnit5.BinOP(L, R: TypPtr; Ch: eSym; var OPTable: tOPTable;
                LCode: tDag; var Code: tDag; Const Comment: String): TypPtr;
var LT,RT: eType; OP: eSubBinOPs; T,U: TypPtr;
    LI,RI: Integer;
    LB,RB: Boolean;
  {$ifdef Debug} N: Integer; {$Endif}
Const MaxTyp: array[BinOpTyp,BinOpTyp] of eType=(
      { TSET  TPAC  TPTR  TSTR  TREA  TINT  TBOL  TCHR  TUSR
{TSET} (TSET, tnon, tnon, tnon, tnon, tnon, tnon, tnon, tnon ),
{TPAC} (tnon, TSTR, tnon, TSTR, tnon, tnon, tnon, TSTR, tnon ),
{TPTR} (tnon, tnon, TPTR, tnon, tnon, tnon, tnon, tnon, tnon ),
{TSTR} (tnon, TSTR, tnon, TSTR, tnon, tnon, tnon, TSTR, tnon ),
{TREA} (tnon, tnon, tnon, tnon, TREA, TREA, tnon, tnon, tnon ),
{TINT} (tnon, tnon, tnon, tnon, TREA, TINT, tnon, tnon, TINT ),
{TBOL} (tnon, tnon, tnon, tnon, tnon, tnon, TBOL, tnon, TBOL ),	{????=TBOL???}
{TCHR} (tnon, TSTR, tnon, TSTR, tnon, tnon, tnon, TSTR, TCHR ),
{TUSR} (tnon, tnon, tnon, tnon, tnon, TINT, TBOL, TCHR, TUSR ) );
Type tHasNewType=TPAC..TCHR; Const HasNewType:Set of tHasNewType=[TPAC..TCHR];
Const NewStaTyp: array [tHasNewType] of eResType=
        (xPAC,xPTR,xSTR,xSNG,xLON,xBOL,xCHR);
begin //BINOP
  LT:=L^.TTYPE; RT:=R^.TTYPE;
  T:=L;
  OP:=OPTable.OP[GlbOptIndex[Ch]];
  {$Ifdef Debug}
  N:=-1; repeat inc(N) until OPTable.Sym[N]=Ch;
  if N<>GlbOptIndex[Ch] then Error(5);
  {$Endif}
  if LT=RT then begin
    case LT of
    TSTR,
    TPAC: if OP=opADD then LT:=TSTR else
            if (L^.TSIZE<>R^.TSIZE) or (L^.TMINV<>R^.TMINV) then
              Error(TypeMismatch);
    TCHR: if OP=opADD then begin LT:=TSTR; T:=@StandardType[xSTR] end;
    TSET: begin
            //if L^.TELEP<>NIL then begin   //CORRECT ???????
            if R^.TELEP=NIL then R^.TELEP:=L^.TELEP;
            if L^.TELEP=NIL then L^.TELEP:=R^.TELEP;
            if L^.TELEP=NIL then begin
              L^.TELEP:=@StandardType[xTmpSet];
              R^.TELEP:=@StandardType[xTmpSet];
            end;
            T:=TypPtr(TypPtr(L^.TELEP)^.TBASE);
            U:=TypPtr(TypPtr(R^.TELEP)^.TBASE);
            if T<>U then Error(TypeMismatch);
            T:=L;
            //end;
          end;
    TPTR: begin
            T:=L^.TELEP; U:=R^.TELEP;
            if not ( (T=U) or (T=@StandardType[xUNT]) or (U=@StandardType[xUNT]) ) then
              Error(TypeMismatch)
          end;
    TREA: ;
    TUSR: ; /// LT:=TBOL; T:=@StandardType[xBOL];
    TBOL: if (LCode.op=pcConst) and (Code.op=pcConst) then
            try
              LB:=Boolean(LCode.ConI and 1); RB:=Boolean(Code.ConI and 1);
              case OP of
              opOR:  begin LCode:=NIL; Code:=CodeConst(LB OR RB,TBOL) end;
              opXOR: begin LCode:=NIL; Code:=CodeConst(LB XOR RB,TBOL) end;
              opAND: begin LCode:=NIL; Code:=CodeConst(LB AND RB,TBOL) end;
              opEQ:  begin LCode:=NIL; Code:=CodeConst(LB =  RB,TBOL) end;
              opNE:  begin LCode:=NIL; Code:=CodeConst(LB <> RB,TBOL) end;
              opGT:  begin LCode:=NIL; Code:=CodeConst(LB >  RB,TBOL) end;
              opLT:  begin LCode:=NIL; Code:=CodeConst(LB <  RB,TBOL) end;
              opGE:  begin LCode:=NIL; Code:=CodeConst(LB >= RB,TBOL) end;
              opLE:  begin LCode:=NIL; Code:=CodeConst(LB <= RB,TBOL) end;
              end;
            except
              on E:Exception do InternalError('Constant overflow:'+E.Message)
            end;
    TINT: if OP=opRDV then begin LT:=TREA; T:=@StandardType[xSNG] end
          else begin
            if (LCode.op=pcConst) and (Code.op=pcConst) then
              try
                LI:=LCode.ConI; RI:=Code.ConI;
                case OP of
                //opEQ,opNE,opGT,opLT,opGE,opLE,opCMP,
                opADD: begin LCode:=NIL; Code:=CodeConst(LI+RI,TINT) end;
                opSUB: begin LCode:=NIL; Code:=CodeConst(LI-RI,TINT) end;
                opOR:  begin LCode:=NIL; Code:=CodeConst(LI OR RI,TINT) end;
                opXOR: begin LCode:=NIL; Code:=CodeConst(LI XOR RI,TINT) end;
                opAND: begin LCode:=NIL; Code:=CodeConst(LI AND RI,TINT) end;
                opMUL: begin LCode:=NIL; Code:=CodeConst(LI * RI,TINT) end;
                opDIV: begin LCode:=NIL; Code:=CodeConst(LI DIV RI,TINT) end;
                opMOD: begin LCode:=NIL; Code:=CodeConst(LI MOD RI,TINT) end;
                opSHL: begin LCode:=NIL; Code:=CodeConst(LI SHL RI,TINT) end;
                opSHR: begin LCode:=NIL; Code:=CodeConst(LI SHR RI,TINT) end;
                opEQ:  begin LCode:=NIL; Code:=CodeConst(LI =   RI,TINT) end;
                opNE:  begin LCode:=NIL; Code:=CodeConst(LI <>  RI,TINT) end;
                opGT:  begin LCode:=NIL; Code:=CodeConst(LI >   RI,TINT) end;
                opLT:  begin LCode:=NIL; Code:=CodeConst(LI <   RI,TINT) end;
                opGE:  begin LCode:=NIL; Code:=CodeConst(LI >=  RI,TINT) end;
                opLE:  begin LCode:=NIL; Code:=CodeConst(LI <=  RI,TINT) end;
                end;
              except
                on E:Exception do InternalError('Constant overflow:'+E.Message)
              end;
          end;
    else Error(TypeMismatch)   //DOLATER JUST REMOVE THIS ERROR!
    end;
  end else begin
    LT:=MaxTyp[LT,RT];
    if (LT=TUSR) or (RT=TUSR) then
      if L.TBASE<>R.TBASE then
        Error(OpTypes);
  end;
  if OP in cRelOP then T:=@StandardType[xBOL] else
    if LT in HasNewType then T:=@StandardType[NewStaTyp[LT]];
  if not (LT in ValidBinOpTyp) then Error(OpTypes);
  if LCode<>NIL then //else already coded as a const
    if OP in OPtable.Mask[LT] then Code:=CodeIns(pcBinOP,ord(OP),LCode,Code,Comment)
    else Error(OpTypes);
  Result:=T;
  Code.OpRec.OTYPE:=T^.TTYPE;
end;

{========================================================================}
Function  TUnit5.SetFactor(var Code: tDag): TypPtr;
var P: TypPtr;
Function SetExpres: tDag;
var S: TypPtr;
begin
  S:=CExpression(Result);
  if P^.TELEP=NIL then P^.TELEP:=S;
  if S^.TBASE<>P^.TELEP^.TBASE then
    Error(TypeMismatch);
end;

var
  NewTyp: tType;
  C1,C2: tDag;
  Codes:  Array of tDag;
begin {SetFactor}
  ZeroTyp(NewTyp); NewTyp.TTYPE:=TSET; NewTyp.TSIZE:=32;
  P:=EnterScopeBlkType(NewTyp,'');
  if Next.Ch<>SRBR then
    repeat
      C1:=SetExpres; C2:=NIL;
      if Scan(SDPE) then
        C2:=SetExpres;
      SetLength(Codes,Length(Codes)+2);
      Codes[High(Codes)-1]:=C1; Codes[High(Codes)]:=C2;
    Until not Scan(SCOM);
  Find(SRBR);
  //if P^.TELEP=NIL then
  //  P^.TELEP:=@StandardType[xTmpSet];
  Code:=CodeIns(pcSET,ord(SetStart),NIL,NIL);
  Code.OpRec.OTYPE:=TSET;
  Code.OpRec.SetDesc:=$00000020;
  Code.ParmAfter:=CodeList(pcSET,ord(SetItems),Codes);
  SetFactor:=P;
end;

{========================================================================}
Function  TUnit5.FUNFAC(P: pSymRec; var Code: tDag): TypPtr;
begin
  ScanNext;
  //Result:=@P^.TTYP;
  Result:=P^.PTYPP;
  DoFunction(P,tDag0(Code));
  Code.SetDagResStack(Result.TTYPE,tDag.CalcSize(Result));
  Code.SetSize(Result);
end;

{ SCTYP =================================================================}
Function  TUnit5.SCTYP(var Code: tDag; OnlySimpleVar: Boolean=False): TypPtr;
var pT: TypPtr; CurOfs: Integer;

Procedure FlushOfs;
begin
  if CurOfs<>0 then begin
    //Code:=CodeIns(pcOffset,0,Code,CodeConst(CurOfs,TINT));
    Code:=CodeIns(pcOffset,CurOfs,Code,NIL);
    Code.OpRec.aEA.EAsize:=Code.ParmL.OpRec.aEA.EAsize;
    CurOfs:=0;
  end;
end;

Function CKPTR(var Code: tDag): Boolean;
begin
  CKPTR:=False;
  if Scan(SCAR) then begin
    CKPTR:=True;
    FlushOfs;
    pT:=pT^.TELEP;
    Code:=CodeIns(pcDEREF,0,Code,NIL);
    Code.SetSize(pT);
  end;
end;

Function CKREC(var Code: tDag): Boolean;
var P: pSymRec;
begin
  Result:=Scan(SPER);
  if Result then begin
    P:=ScanScope(pT^.TSCOP);
    if (P=NIL) then Error(ExpIDField);
    pT:=TypPtr(P^.VTYPP);
    if pT=NIL then Error(ExpIDField);
    ScanNext;
    Inc(CurOfs,P^.VADDR);
    Code.SetSize(pT);
  end;
end;

Function CKARY(var Code: tDag): Boolean;
var INX_A1,ARYELE,TypInx: TypPtr;
var CodeInx: tDag;
begin
  CKARY:=False;
  if Scan(SLBR) then begin
    CKARY:=True;
    repeat {until no further ','}
      TypInx:=CExpression(CodeInx);
      if pT^.TTYPE=TARY then begin
        ARYELE:=TypPtr(pT^.TELEP);
        INX_A1:=TypPtr(pT^.TIDXP); {Get index type}
      end else begin	{=> TPAC, TSTR, packed array of char}
        ARYELE:=@StandardType[xCHR];
        INX_A1:=@StandardType[xINTwrk];  //Type=????
        INX_A1^.TMINV:=pT^.TMINV;
	INX_A1^.TMAXV:=pT^.TMAXV;
      end;
      {Check that index and expression types match}
      if INX_A1^.TBASE<>TypInx^.TBASE then
        Error(TypeMismatch);
      Dec(CurOfs,ARYELE^.TSIZE * INX_A1^.TMINV); //Base offset
      {Code index}
      //CodeMul:=CodeConst(ARYELE^.TSIZE,TINT);
      pT:=ARYELE;
      Code:=CodeIns(pcARRAY,ARYELE^.TSIZE,Code,CodeInx);
      /////Code.OpRec.Sym:=
      Code.SetSize(pT);
      if not (pT^.TTYPE in [TSTR,TPAC,TARY]) then BREAK;
      if not Scan(SCOM) then BREAK;
    until FALSE;
    Find(SRBR);
  end
end;

{ SCTYP =================================================================}
var P: pSymRec; RepFlg: Boolean; S: String; WithCode: TDag0; pT2: TypPtr;
begin //SCTYP
  P:=ScanSym(False, WithCode); {Does NOT do ScanNext!}
  case P^.What of
  SVAR:  begin
           S:=Next.IdnBuf; ScanNext;
           pT:=P^.VTYPP;
           Code:=CodeVar(P, 'V: '+S);
           Code.SetSize(pT);
           Code.OpRec.WithCode:=WithCode;
         end;
  STYPP: begin
           pT:=P^.TTYPP;
           if not (pT^.TTYPE in [TPTR,TINT,TBOL,TCHR,TUSR]) then
             Error(Err_InvCast);
           ScanNext;
           FindSLPA; pT2:=Expression(Code);
           if not (pT2^.TTYPE in [TPTR,TINT,TBOL,TCHR,TUSR]) then
             Error(Err_InvCast);
           Code:=CodeIns(pcCAST,0,Code,NIL);
           Code.OpRec.OTYPE:=pT^.TTYPE; ///Code.OpRec.xxOTYP:=pT;
           Code.SetSize(pT);
           Find(SRPA)
         end;
  else   Error(Err_Expr);
  end;
  CurOfs:=0;
  if not OnlySimpleVar then
  repeat
    RepFlg:=False;
    case pT^.TTYPE of
    TPAC,
    TSTR,
    TARY: RepFlg:=CKARY(Code);
    TOBJ,
    TREC: RepFlg:=CKREC(Code);
    TPTR: RepFlg:=CKPTR(Code);
    end;
  until not RepFlg;
  FlushOfs;
  SCTYP:=pT;
  Code.OpRec.xxOTyp:=pT;
  Code.OpRec.OTYPE:=pT^.TTYPE;
  Code.SetSize(pT);     //Done again!!
  Code.ConstructSetDesc;
end;

{========================================================================}
Function  TUnit5.Expression(var Code: tDag): TypPtr;
var LTrue,LFalse: tDag;
begin
  LTrue:=NIL; LFalse:=NIL; //NOT SUPPORTED YET!!!!!!
  Result:=Expres(LTrue,LFalse,Code);
  if LFalse<>NIL then Error(Err_Error);		{!!!????????}
  Code.SetSize(Result);
end;

Function  TUnit5.CExpression(var Code: tDag): TypPtr;
var T: TypPtr;
begin
  T:=Expression(Code); CExpression:=T;
  if not (T^.TTYPE in [TINT..TUSR]) then Error(ExpEOrdinal);
  Code.SetSize(Result);
end;

//Expression + BEQ NELabel  (If, While, Repeat)
Procedure TUnit5.BExpressionJmp(var LFalse, Code: tDag);
var T: TypPtr; LTrue: tDag;
begin
  LTrue:=NIL; LFalse:=NIL; //NOT SUPPORTED YET!!!!!!
  T:=Expres(LTrue,LFalse,Code);
  if T^.TTYPE<>TBOL then
    Error(ExpEBoolean);
  //Code:=CodeBool(1,Code,NIL); //pcJmpBool => codTST (ea)

  if LFalse<>NIL then Error(Err_Error);		{!!!????????}
  LFalse:=CodeJmpLabel('LabelF');
  Code:=CodeJmpCC(LFalse,Code,'JmpF');
  ///Code.SetSize(T);
end;

{ FIVAR =================================================================}
Function  TUnit5.FIVAR(var Code: tDag; OnlySimpleVar: Boolean=False): TypPtr;
begin
  if Next.Ch<>SIDN then Error(ExpVar);
  Result:=SCTYP(Code,OnlySimpleVar);
  //Code.SetSize(Result);  Done in SCTYP
  if Result=NIL then Error(ExpVar);
  if Result^.TTYPE=TNON then Error(ExpVar);
end;

Function  TUnit5.SCVAR(var Code: tDag): TypPtr;
begin
  if Next.Ch<>SIDN then Error(ExpVar);
  Result:=SCTYP(Code);
  //Code.SetSize(Result);  Done in SCTYP
end;

end.

