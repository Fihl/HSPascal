unit Buildin;

interface

Uses Global, CodeDag, Stmt{TUnit6};

Type
  TUnit6b=Class(TUnit6)
    Procedure StaProc(P: pSymRec; var CodeX0: tDag0); Override;
    Function  StaFunc(P: pSymRec; var CodeX0: tDag0): TypPtr; Override;
  private
    Function  IExpression(DoExp: Boolean=True; DefaultInt: Integer=0): tDag;
    Function  SExpression(DoVar: Boolean=False): tDag;
  end;

implementation

Uses Dag, Util, Misc, Expr;

{==============================================================================}
Function  TUnit6b.IExpression(DoExp: Boolean=True; DefaultInt: Integer=0): tDag;
var T: TypPtr;
begin
  if DoExp then begin
    T:=Expression(Result);
    if T^.TBASE^.TTYPE<>TINT then Error(ExpEInt);
    Result.SetSize(T);
  end else
    Result:=CodeConst(DefaultInt,TINT);
end;
Function  TUnit6b.SExpression(DoVar: Boolean=False): tDag;
var T: TypPtr;
begin
  if DoVar then T:=FIVAR(Result) else T:=Expression(Result);
  if not (T^.TTYPE in [TSTR,TPAC]) then   //IsString!!!
    if T^.TTYPE<>TPTR then Error(ExpEIR)
    else if T^.TELEP^.TTYPE<>TCHR then Error(ExpEIR);
end;

{==============================================================================}
Procedure TUnit6b.StaProc(P: pSymRec; var CodeX0: tDag0);
var
  PN: Byte; T: TypPtr;
  ParamList5: array[0..4] of tDag;
begin {StaProc}
  CodeX0:=NIL;
  ScanNext;
  PN:=P^.ProcNo;
  FillChar(ParamList5,SizeOf(ParamList5),0);
  Case PN of
  PSysRandomize: ;
  PSysNew, //New(var P), Dispose(var P)
  PSysDispose: begin
      FindSLPA;
      T:=FIVAR(ParamList5[0]);
      if T.TTYPE <> TPTR then Error(ExpVPointer);
      if T^.TELEP^.TSIZE=0 then Error(Err_ExpVTPointer);
      ParamList5[1]:=CodeConst(T^.TELEP^.TSIZE,TINT);
      FindSRPA;
      case PN of //Same proc as GetMem(P,nn);
      PSysNew:     PN:=PSysMemGet;
      PSysDispose: PN:=PSysMemFree
      end;
    end;
  PSysMemGet,
  PSysMemFree: begin
      FindSLPA;
      if FIVAR(ParamList5[0]).TTYPE <> TPTR then Error(ExpVPointer);
      FindSCOM;
      ParamList5[1]:=IExpression;
      FindSRPA;
    end;
  PSysFillChar: begin //Fillchar(V, I, nn);
      FindSLPA;
      //SetLength(ParamList5,3);
      SCVAR(ParamList5[0]);
      FindSCOM;
      ParamList5[1]:=IExpression;
      FindSCOM;
      {T:=}CExpression(ParamList5[2]);
      //if (not IsImm) and (T.TSIZE>2) then Error(ExpEOrdinal);
      FindSRPA;
    end;
  PSysMove: begin //Move(V1,V2,N)
      FindSLPA;
      SCVAR(ParamList5[0]); FindSCOM;
      SCVAR(ParamList5[1]); FindSCOM;
      ParamList5[2]:=IExpression;
      FindSRPA;
    end;
  ISysInc,
  ISysDec: begin { Inc/Dec (sc: scalar [,n: integer]) }
      FindSLPA;
      T:=FIVAR(ParamList5[0]);
      if ParamList5[0].op=pcCAST then Error(ExpTOrdinal); //!!!! DOLATER HACK!!!!
      if not (T^.TTYPE in SetSimTypeINC) then Error(ExpTOrdinal);
      ParamList5[1]:=IExpression(Scan(SCOM),1);
      //ParamList5[1].SetSize(T);
      FindSRPA;
    end;
  //ISysStringR, //Unused
  ISysStringI:
    begin	//Str(x:int/real [:w[:dec]],var s:string)
      FindSLPA;
      T:=Expression(ParamList5[0]);
      Case T^.TBASE^.TTYPE of
      TINT: ParamList5[1]:=IExpression(Scan(SCOL),0);
      TREA: begin
              PN:=ISysStringR;
              ParamList5[1]:=IExpression(Scan(SCOL),10);         {Default=10}
              ParamList5[2]:=IExpression(Scan(SCOL),-1);         {Default=-1}
            end;
      Else  Error(ExpEIR);
      End;
      Find(SCOM);
      T:=FIVAR(ParamList5[3]);  //NOTE #3!!! Always
      if T^.TTYPE<>TSTR then Error(ExpVStr);
      ParamList5[4]:=CodeConst(T^.TSIZE,TINT);
      FindSRPA;
    end;
  PSysValR, //Unused
  PSysValI:
    begin //Val(s:string,var x:int/real,var pos: integer)
      FindSLPA;
      //if Expression(ParamList5[0])^.TTYPE<>TSTR then Error(ExpEStr); //SExpression(Code);
      ParamList5[0]:=SExpression;
      FindSCOM;
      T:=FIVAR(ParamList5[1]);
      case T^.TBASE^.TTYPE of
      TINT: begin PN:=PSysValI; if T^.TSIZE<>4 then Error(ExpVInt32) end;
      TREA: PN:=PSysValR;
      else Error(ExpVIR);
      end;
      FindSCOM;
      T:=FIVAR(ParamList5[2]);
      //FVARPi1; =  T:=FIVAR();
      if (T^.TBASE^.TTYPE<>TINT) or (T^.TSIZE<>2) then Error(ExpVInt16);
      FindSRPA;
    end;
  PSysStrIns: //Insert(S,var S,n)
    begin
      FindSLPA;
      ParamList5[0]:=SExpression;
      FindSCOM;
      ParamList5[1]:=SExpression(True);
      FindSCOM;
      ParamList5[2]:=IExpression;
      FindSRPA;
    end;
  PSysStrDel: //Delete(var S,n,n)
    begin
      FindSLPA;
      ParamList5[0]:=SExpression(True);
      FindSCOM;
      ParamList5[1]:=IExpression; FindSCOM;
      ParamList5[2]:=IExpression;
      FindSRPA;
    end;
  Else InternalError('Buildin, missing StaProc:'+i2s(PN));
  End;
  if PN<>0 then
    CodeX0:=tDag(CodeList(pcStaPROC,PN,ParamList5));
end;

{==============================================================================}
Function  TUnit6b.StaFunc(P: pSymRec; var CodeX0: tDag0): TypPtr;
var
  FN: Integer; T: TypPtr;
  Code: tDag absolute CodeX0;
  CodeR: tDag;
  ParamList5: array[0..4] of tDag;
begin
  ScanNext;
  FN:=P^.FuncNo; CodeR:=NIL; CodeX0:=NIL; T:=NIL;
  FillChar(ParamList5,SizeOf(ParamList5),0);

  case FN of
  FSysMemAvail,FSysMemMaxAvail:
      T:=@StandardType[xLON];
  FSysTrunc,FSysRound: // I:=xx(Real)
    begin
      FindSLPA;
      T:=Expression(Code);
      if not (T^.TBASE^.TTYPE in [TINT,TREA]) then Error(ExpEIR); {ARG_N}
      T:=@StandardType[xLON];
      FindSRPA;
    end;
  ISys32Sqr,FSysSqr:
    begin
      FindSLPA;
      T:=Expression(Code);
      case T^.TBASE^.TTYPE of
      TINT: FN:=ISys32Sqr;
      TREA: FN:=FSysSqr;
      else  Error(ExpEIR);
      end;
      FindSRPA;
    end;
  FSysInt,FSysSqrt,FSysArcTan,FSysSin,FSysCos,FSysLN,FSysExp: //R:=f(R)
    begin
      FindSLPA;
      T:=Expression(Code);
      if not (T^.TBASE^.TTYPE in [TINT,TREA]) then Error(ExpEIR);
      T:=@StandardType[xSNG]; {NOTE!!!!!!! Single}
      FindSRPA;
    end;
  FSysUpCase: //Upcase(Ch)
    begin
      FindSLPA;
      T:=Expression(Code);
      if T^.TTYPE<>TCHR then Error(Err_ExpEChar);
      FindSRPA;
    end;
  FSysStrLen: //Length(S)
    begin
      FindSLPA;
      Code:=SExpression;
      FindSRPA;
      T:=@StandardType[xSmall];
    end;
  FSysStrCopy: //S:=Copy(S,N,N)
    begin
      FindSLPA;
      ParamList5[0]:=SExpression; FindSCOM;
      ParamList5[1]:=IExpression; FindSCOM;
      ParamList5[2]:=IExpression; FindSRPA;
      T:=@StandardType[xStr];
      Code:=CodeList(pcStaFUNC,FN,ParamList5); FN:=0;
    end;
  FSysStrPos: //N:=Pos(s,s)
    begin
      FindSLPA;
      Code:=SExpression;
      FindSCOM;
      CodeR:=SExpression;
      FindSRPA;
      T:=@StandardType[xSmall];
    end;
  FSysOdd,FSysChr,FSysLo: //Odd(Long), Chr(Byte), Lo(Long)
    begin
      FindSLPA;
      T:=Expression(Code);
      if T^.TBASE^.TTYPE<>TINT then Error(ExpEInt);
      FindSRPA;
      Case FN of
      FSysLo:    T:=@StandardType[xBYT];
      FSysOdd:   T:=@StandardType[xBOL];
      FSysChr:   T:=@StandardType[xCHR];
      End;
    end;
  FSysPtr: //Pointer(Long)
    begin
      FindSLPA;
      Code:=IExpression;
      T:=@StandardType[xPTR];
      FindSRPA;
    end;
  FSysOrd: //Ord(ordinal)
    begin
      FN:=0; //No pcStaFunc code!!
      FindSLPA;
      T:=Expression(Code);   ///PushW);
      //Code.SetSize(T);
      Code:=CodeIns(pcMonOP,ord(opORD),Code,NIL,'MonOP ORD');
      if not (T^.TBASE^.TTYPE in [TPTR,TINT,TBOL,TCHR,TUSR]) then Error(ExpEOrdinal);
      case T^.TSIZE of
      2:   T:=@StandardType[xSmall];
      4:   T:=@StandardType[xLON];
      else T:=@StandardType[xBYT];
      end;
      FindSRPA;
    end;
  FSysSucc,FSysPred:
    begin
      FindSLPA;
      T:=CExpression(Code);
      if Scan(SCOM) then
        CExpression(CodeR);
      Find(SRPA);
    End;
  FSysAbs32: //and FSysAbs16 and FSysAbsR
    begin
      FindSLPA;
      T:=Expression(Code);
      case T^.TBASE^.TTYPE of
      TINT: if T^.TSIZE<4 then begin
              FN:=FSysAbs16; //16 / 32
              T:=@StandardType[xSmall]; //Byte/Small => Small
            end;
      TREA: FN:=FSysAbsR;
      else  Error(ExpEIR);
      end;
      FindSRPA;
    end;
  FSysSizeOf:
    begin
      FN:=0; //No pcStaFunc code!!
      FindSLPA;
      P:=ScanSym(False,DummyWithCode);
      case P^.What of
      STYPP: begin T:=P^.TTYPP; ScanNext end;
      SVAR:  T:=SCVAR(Code); //code not used!
      Else   Error(ExpVar);
      end;
      Code:=CodeConst(T^.TSIZE,TINT);
      T:=@StandardType[xLON];
      FindSRPA;
    end;
  FSysAddr:
    begin
      FindSLPA;
      T:=ADRFAC(Code);
      FindSRPA;
      FN:=0;  //No runtime!
    end;
  FSysRandomI:
    if Scan(SLPA) then begin //Random(Word)
      Code:=IExpression;
      T:=@StandardType[xSmall];
      FindSRPA;
    end else begin
      T:=@StandardType[xSNG]; {NOTE!!!!!!! Single}
      FN:=FSysRandomR;
    end;
  else  InternalError('Buildin, missing StaFunc:'+i2s(FN));
  end;
  if FN<>0 then
    Code:=CodeIns(pcStaFUNC,FN,Code,CodeR);
    //Code:=CodeList(pcStaFUNC,FN,[Code]); {!!!}
  Result:=T;
  Code.SetSize(Result);
  Code.OpRec.OTYPE:=T.TTYPE;
end;

end.

