Unit Declare;

Interface

Uses Global, Buildin{TUnit6b};

Type
  TUnit7=Class(TUnit6b)
    DoInterface: Boolean;
    Procedure DoProc(ProcWhat: eSym; ParentObj: TypPtr);
    Procedure DoDeclare(Inter: Boolean; var UsageA6: Longint; PFLAG: sPFLAG; ProcSym: pSymRec);
    Procedure InitProcSymRec(ProcSym: pSymRec);
  Private
    Function  FindType(AllowUndef: Boolean; TypeName: String; ProcSym: pSymRec): TypPtr; ///Override;
    Function  FindTYPIDN: TypPtr;
    Function  DoVar(Flag: tDoVar; EndSym: eSym; var Offset: Integer; ProcSym: pSymRec): Integer;
    Function  TYPIDN(AllowUndef: Boolean; NormalVersion: Boolean=True): TypPtr;
    procedure DoType(ProcSym: pSymRec);
    Procedure DoLabel;
    Procedure DoConst;
    Procedure DbgDumpVar(DumpWhat: tDoVar; VarSym, ProcSym: pSymRec; RecDefNo: Integer=0);
    Procedure DbgDumpSym(T: TypPtr);
    procedure ForwardStuff(Declare: Boolean; Const S: String);
  Private
    Undef: Array of Record
      ID: Str63;
      xUndefSymPos: TypPtr;
      xSymPos: pSymRec;
    end;
  end;

Implementation

Uses SysUtils, Util, Misc, Scanner, HspMain, Dag;

{ DoDeclare ======================================= }
Procedure TUnit7.DoDeclare(Inter: Boolean; var UsageA6: Longint; PFLAG: sPFLAG; ProcSym: pSymRec);
begin
  //Debug('Declare, SLEV='+i2s(SLEV));
  repeat
    //DLEV:=SLEV;
    case Next.Ch of
    SVAR:  begin
             if PDNoA6Frame in PFLAG then Error(Err_ASM); //No var if no A6
             ScanNext;
             if SLEV=0 then DoVar(dvGlobal,SSEM,Glb.UsageA5,NIL)  //if DLEV=0 then
             else           DoVar(dvLocal,SSEM,UsageA6,ProcSym);
             Glb.UsageA5:=EvenSize(Glb.UsageA5);
             UsageA6:=EvenSize(UsageA6);
           end;
    SLBL:  if Inter then Error(ord(SIMP)) Else DoLabel;
    STYP:  DoType(ProcSym);
    SCON:  DoConst;
    SDESTRUCTOR,
    SCONSTRUCTOR,   /// ?? if SYM.DoingInterface
    SPRO,
    SFUN:  DoProc(Next.Ch,NIL);
    SRSRC: DeclareResource;
    SIDN:  Error(Ord(SBGN));
    Else   BREAK
    end;
  until FALSE;
end;

{ FindTYPIDN ======================================== }
Function  TUnit7.FindTYPIDN: TypPtr;
var P: TypPtr;
begin
  P:=TYPIDN(True);
  if P=NIL then Error(ExpTypeID);
  Result:=P;
end;

{ TYPIDN ========================================== }
Function  TUnit7.TYPIDN(AllowUndef: Boolean; NormalVersion: Boolean=True): TypPtr;
var P: pSymRec; Scan: Boolean;
begin
  Result:=NIL;
  Scan:= NormalVersion;
  if not (Next.Ch in [SIDN,SSTR]) then EXIT; ////Error(ord(SIDN));
  if Next.Ch=SSTR then
    Result:=@StandardType[xStr]
  else begin
    P:=ScanSym(AllowUndef, DummyWithCode);
    if P<>NIL then                      {NIL only allowed if AllowUndef}
      if P^.What=STYPP then begin
        Result:=P^.TTYPP;
        if Result=NIL then
          if not AllowUndef then InternalError0;
        if NormalVersion and (Result=NIL) then begin
          SetLength(Undef,Length(Undef)+1);
          with Undef[High(Undef)] do begin ID:=Next.IdnBuf; xSymPos:=P end;
        end;
      end else
        Scan:=False;
  end;
  if Scan then ScanNext;
end;


{ FindType ======================================== }
Function  TUnit7.FindType(AllowUndef: Boolean; TypeName: String; ProcSym: pSymRec): TypPtr;

{ ARYTYP ========================================== }
Function  SimType: TypPtr;	Forward;

Function  ARYTYP: TypPtr;
Function  SubAry: TypPtr;
var Inx,Elem: TypPtr; NewTyp: tType; TypeId: String;
begin
  TypeId:=TypeName; TypeName:='';
  Inx:=SimType;
  with Inx^ do begin
    ZeroTyp(NewTyp); //TTYPE=TARY
    if Scan(SCOM) then
      Elem:=SubAry
    else begin
      Find(SRBR); Find(SOF);
      Elem:=FindType(False,'',ProcSym);
      { ar[type] of Packed: type not only 1..oo, but also as BOOLEAN etc}
      if (Elem=@StandardType[xCHR]) and (TTYPE in [TINT,TUSR]) and (TMINV=1) and (TMAXV<>1) then begin
        NewTyp.TTYPE:=TPAC; NewTyp.TMINV:=TMINV; NewTyp.TMAXV:=TMAXV;
        NewTyp.TSIZE:=EvenSize(TMAXV-TMINV+1);  {Elem^.TSIZE =1}
        Result:=EnterScopeBlkType(NewTyp,'Packed');
        EXIT;
      End;
    End;
    NewTyp.TTYPE:=TARY;
    NewTyp.TSIZE:=EvenSize(Elem^.TSIZE*(TMAXV-TMINV+1));
    Result:=EnterScopeBlkType(NewTyp,TypeId);
    Result^.TELEP:=Elem;
    Result^.TIDXP:=Inx;
  End;
end;

begin {ARYTYP}
  ScanNext; Find(SLBR);
  ARYTYP:=SubAry;
end;

{ OBJTYP ========================================== }
Function  OBJTYP: TypPtr;
var pNewTyp: TypPtr;		{The OBJECT itself}

Procedure FLIST1(Var Offset: Longint);
var ProcsDefined: Boolean; {{{Buffer: tSymbol; {{{}
begin
  //If SPtr<SptrLow then Error(Err_Memory);
  ProcsDefined:=False; 
  repeat
    case Next.Ch of
    SPRO,SFUN,SCONSTRUCTOR,SDESTRUCTOR:
      begin
        ProcsDefined:=True;	{No variables after this!}
        DoProc(Next.Ch,pNewTyp);
      end;
    SPRIVATE,SPUBLIC, //???
    SEND: BREAK;
    else
      if ProcsDefined then BREAK else begin
        {SetRecordFlag(SkipTopScope);  {Type are ALREADY SNONE}
        DoVar(dvRecord,SNONE,Offset, ProcSym);
        {SetRecordFlag(NoSkip); {}
        if not Scan(SSEM) then BREAK;
      end;
    end;
  until FALSE;
  Offset:=EvenSize(Offset);
end;

var {OBJTYP}
  Offset: Longint;
  ScopePtr: TScope;
  P2: TypPtr;
  NewTyp: tType;
begin {OBJTYP}
  ScanNext;
  ZeroTyp(NewTyp); NewTyp.TTYPE:=TOBJ; Offset:=0;
  ScopePtr:=NewScope(skObject,'Obj');
  pNewTyp:=EnterScopeBlkType(NewTyp,TypeName);
  pNewTyp^.TSCOP:=ScopePtr;
  if Scan(SLPA) then begin
    P2:=FindTYPIDN; if P2^.TTYPE<>TOBJ then Error(Err_NotAnOBJ);
    SetScopeSamePrivate(ScopePtr, P2^.TSCOP, NIL);
    Find(SRPA);
  end;
  repeat
    FLIST1(Offset);
    SYM.CurScopePrivate:=TRUE; if Scan(SPRIVATE) then CONTINUE;
    SYM.CurScopePrivate:=not SYM.DoingInterface;
    if Scan(SPUBLIC) then CONTINUE;
    BREAK
  UNTIL False;
  Find(SEND);
  DisposeScope;
  pNewTyp^.TSIZE:=EvenSize(Offset);
  Result:=pNewTyp;
end;

{ RECTYP ========================================== }
Function  RECTYP: TypPtr;
var OffsetMax: Longint;

procedure PRSEC(var Offset: Longint);
begin
  {SetRecordFlag(SkipTopScope); {Type are ALREADY SNONE}
  DoVar(dvRecord, SNONE, Offset, ProcSym);
  if OffsetMax<Offset then OffsetMax:=Offset;
  {SetRecordFlag(NoSkip); {}
end;

Procedure FLIST2(Var Offset: Longint; EndSym: eSym);
var I: Longint;
begin
  //If SPtr<SptrLow then Error(Err_Memory);
  while not Scan(EndSym) do begin
    if Scan(SCAS) then begin
      if TYPIDN(True,FALSE)<>NIL then {No error while doing TYPIDN}
        ScanNext
      else PRSEC(Offset);
      Find(SOF);
      repeat
        if Scan(EndSym) then EXIT;
        repeat FCON
        until not Scan(SCOM);
        Find(SCOL); FindSLPA;
        I:=Offset; FLIST2(I,SRPA);	{Use I. Do not update Offset!}
      until not Scan(SSEM);
    end else begin
      PRSEC(Offset);
      if Scan(SSEM) then CONTINUE;
    end;
    Find(EndSym);
    BREAK;
  end;
  //if OffsetMax=0 then Error(Ord(SIDN)); //No fields?
end;

var {RECTYP}
  Offset: Longint;
  ScopePtr: TScope;
  NewTyp: tType;
  P: TypPtr;
  TypeId: String;
begin
  TypeId:=TypeName; TypeName:='';
  ScanNext; Offset:=0; OffsetMax:=0;
  ScopePtr:=NewScope(skRecord,'Rec');
  FLIST2(Offset, SEND);
  //if OffsetMax=0 then OffsetMax:=2;
  DisposeScope;
  ZeroTyp(NewTyp); NewTyp.TTYPE:=TREC; NewTyp.TSIZE:=EvenSize(OffsetMax);
  P:=EnterScopeBlkType(NewTyp,TypeId);
  Result:=P;
  P^.TSCOP:=ScopePtr;
end;

{ SETTYP ========================================== }
Function  SETTYP: TypPtr;
var P,T: TypPtr; NewTyp: tType;
begin
  ScanNext; Find(SOF); T:=SimType; //T:=FindType;
  With T^ do begin
    if (TMINV<0) or (TMAXV>255) or (TMINV>TMAXV) then
      Error(Err_SetBase);
    ZeroTyp(NewTyp); NewTyp.TTYPE:=TSET;
    NewTyp.TSIZE:=EvenSize((TMAXV shr 3) - (TMINV shr 3) +1);
    P:=EnterScopeBlkType(NewTyp,TypeName);
    Result:=P;
    P^.TELEP:=T;
  end;
end;

{ PTRTYP ========================================== }
Function  PTRTYP(AllowUndef: Boolean): TypPtr;
var T: TType;
begin
  T:=StandardType[xPTR];  //Take copy!
  Result:=EnterScopeBlkType(T,TypeName);
  ScanNext;
  if AllowUndef then begin //UndefAllowed then begin
    Find(SIDN);
    SetLength(Undef,Length(Undef)+1);
    with Undef[High(Undef)] do begin
      xUndefSymPos:=Result;
      ID:=Next.IdnBuf;
      //Done: TTYPE=TPTR, TBASE=StandardType[xPTR], TELEP=StandardType[xUNT])
      //Miss: TELEP
    end;
  end else
    Result^.TELEP:=FindType(False,'',ProcSym);
end;

{ STRTYP ========================================== }
Function  STRTYP: TypPtr;
var NewTyp: tType; L: Longint;
begin
  ScanNext;
  if Scan(SLBR) then begin
    ZeroTyp(NewTyp); NewTyp.TTYPE:=TSTR;
    L:=FICON; CheckRange(L,0,255,InvStrLen);
    NewTyp.TMAXV:=L; NewTyp.TSIZE:=EvenSize(L+1);
    STRTYP:=EnterScopeBlkType(NewTyp,TypeName);
    Find(SRBR);
  end else
    STRTYP:=@StandardType[xStr];
end;

{ SCATYP ========================================== }
Function  SCATYP: TypPtr; //ENUM Enumerated
var BaseType: TypPtr;
    NewTyp: tType; Val: Longint;
    SymRec: tSymRec;
    P: pSymRec;
begin
  FindSLPA; //ScanNext;
  ZeroTyp(NewTyp); NewTyp.TTYPE:=TUSR;
  BaseType:=EnterScopeBlkType(NewTyp,TypeName);
  BaseType^.TBASE:=BaseType;
  Result:=BaseType;
  Val:=0;
  BaseType^.TSIZE:=1;
  BaseType^.TMINV:=Maxint;
  ZeroSym(SymRec);
  repeat
    SymRec.What:=SCON;
    SymRec.CTYPP:=BaseType;
    SymRec.CIVAL:=Val;
    //P:=InsSym(SymRec);
    P:=InsSymAbs(GetScopeTopNotRecObj,Symrec);
    Find(SIDN);
    if Scan(SEQS) then begin        //HSPC Extension like C#
      Val:=FUCON;
      //if not (FCON^.TTYPE in [TINT,TUSR]) then Error(ExpCInt);
      //Val:=Next.IValue;             //$a800=43008
      P^.CIVAL:=Val;
      SkipDebug:=TRUE;
    end;
    if BaseType^.TMINV>Val then BaseType^.TMINV:=Val;
    if BaseType^.TMAXV<Val then BaseType^.TMAXV:=Val;
    if Val > 256 then BaseType^.TSIZE:=2;
    Inc(Val);
  until Not Scan(SCOM);
  SkipDebug:=FALSE;
  Find(SRPA);
end;

{ SBRTYP ========================================== }
Function  SBRTYP: TypPtr; {Subrange Returnes NIL if not found}
var P,P1,P2: TypPtr;
  NewTyp: tType;
begin
  Result:=NIL;
  if Next.Ch in [SIDN,SICO,SMIN,SPLS,SCCO] then
    With NewTyp do begin
      ZeroTyp(NewTyp); //TTYPE=TUSER (SBRTYP)
      P1:=CON; TMINV:=Next.IValue;
      if P1=NIL then EXIT;
      if not (P1^.TTYPE in SetSimType) then Error(Err_InvSub);
      Find(SDPE);
      P2:=CON; TMAXV:=Next.IValue;
      if P1<>P2 then Error(TypeMismatch);
      if TMINV>TMAXV then Error(Err_BoundErr);
      NewTyp.TTYPE:=TUSR;
      if (TMAXV>MaxInt16) or (TMINV<-MaxInt16-1) then TSIZE:=4
      else
        if (TMAXV>127) or (TMINV<-127-1) then TSIZE:=2 else TSIZE:=1;
      P2:=P1^.TBASE; //NO NO NO TTYPE:=P2^.TTYPE;
      P:=EnterScopeBlkType(NewTyp,TypeName);
      Result:=P;
      P^.TBASE:=P2;
      (*****
      //Packed byte/word. 0..255, 0..32767
      if TMINV=0 then begin
        N:=0;
        if TMAXV=$0000FFFF then inc(N,2);
        if TMAXV=$000000FF then inc(N,1);
        if N<>0 then begin
          P^.TPACF:=PACfollows; {TBASE= ^Packed version}
          NewTyp.TSIZE:=N; NewTyp.TPACF:=PACbyte; {PACword????}
          P3:=EnterScopeBlkType(NewTyp);
          P3^.TBASE:=P2;
        end;
      end;
      (********)
    end;
end;

{ SimType ========================================= }
Function  SimType: TypPtr;
var T: TypPtr;
begin
  case Next.Ch of
  SLPA:  T:=SCATYP; //ENUM Enumerated
  else   T:=TYPIDN(False);
         if T=NIL then
           T:=SBRTYP;
  end;
  if (T=NIL) or not (T^.TTYPE in SetSimType) then begin
    if T=NIL then
      Error(ExpTOrdinal);
  end;
  SimType:=T;
End;


{ FindType ======================================== }
var
  OldPACF: Boolean;
  T: TypPtr;
begin {FindType}
  OldPACF:=PACF; PACF:=False;
  PACF:=Scan(SPAC);
  case Next.Ch of
  SARY: T:=ARYTYP;
  SREC: T:=RECTYP;
  SOBJ: T:=OBJTYP;
  else                    {if T<>NIL Then Goto Ok; {}
    PACF:=False;
    case Next.Ch of
    SSET: T:=SETTYP;   {Find(SSET)}
    SCAR: T:=PTRTYP(AllowUndef);   {Find(SCAR)} {May return NIL if UndefAllowed(SEFLG) set}
    SSTR: T:=STRTYP;   {Find(SSTR)}
    SLPA: T:=SCATYP;   {FindSLPA. Enumerated}
    //SFIL: T:=FILTYP; {Find(SFIL)}
    Else  T:=TYPIDN(AllowUndef);  //(False);
          if T=NIL then
            T:=SBRTYP;
    end;
  end;
  if T=NIL then
    Error(Unknown);
  //if T^.TTYPE=TPTR then if T^.TELEP^.TTYPE=TNON Then begin   ///???????
  //    if Not AllowUndef then
  //      Error(Err_Type);
  //end;
//Ok:
  if OldPACF then
    if T^.TPACF<>NIL then
      T:=T^.TPACF; //TBASE;
      //Inc(Longint(T),SizeOf(tType));	{Return packed version if wanted}
  FindType:=T;
  PACF:=OldPACF;
end;

procedure TUnit7.ForwardStuff(Declare: Boolean; Const S: String);
var N: Integer;
begin
  N:=Forwards.FwdName.IndexOf(S);
  if Declare then begin
    if N>=0 then begin
      Forwards.FwdName.Delete(N);
      Dec(Forwards.FWDCNT);
    end;
  end else
    if N<0 then begin
      Inc(Forwards.FWDCNT); Forwards.FwdName.Add(S);
    end;
end;

(******************************************************************************)
{ DoProc ========================================== }
Procedure TUnit7.DoProc(ProcWhat: eSym; ParentObj: TypPtr);
var
  ProcSym: pSymRec;

Function  FindProcLen(VarSym: pSymRec): Integer; {Max 4 bytes, else neg, VAR=>0}
var P: TypPtr;
begin
  P:=VarSym^.VTYPP;
  with P^ do begin
    if TSIZE>32767 then Error(Err_Variables);
    Result:=4; if VarSym^.VVARF in [vfVAR,vfVarConst] then EXIT;
    if TTYPE=TSET then Error(Err_MustBeVAR); // or EXIT // Size=4
    //if TTYPE in [TFIL,TTXT] then Error(Err_FilesVAR); {Must be var}
    {Must Real/String also be psudo-var?, then make -TSIZE too!!!!!!!!!!!!!}
    if TSIZE>4 then Result:=-EvenSize(TSIZE)
    else            Result:=EvenSize(TSIZE);
  end;
end;

//Set addresses as AFTER procedure invocation
//PASCAL calling convention
Procedure SetAddrsPas(VarSym,ProcSym: pSymRec; SymCnt: Integer; var Offset,LocalOffset: Longint);
var Size: Longint; S: pSymRec;
begin
  if not (VarSym^.VVARF in [vfLocal,vfVar,vfVarCopy,vfVarConst]) then
    InternalError('VAR problem');
  if SymCnt<>1 then begin
    S:=VarSym;
    Inc(Integer(S),SymRecSize(S^));
    SetAddrsPas(S,ProcSym,SymCnt-1,Offset,LocalOffset);
  end;
  //if VarSym^.VTYPP^.TTYPE=TSET then begin
  //  VarSym^.VVARF:=vfVar;
  //  VarSym^.VADDR:=Offset;
  //  Size:=4;
  //end else begin
  Size:=FindProcLen(VarSym);
  /////VarSym^.VVARF:=vfLocal;
  if Size>0 then
    VarSym^.VADDR:=Offset
  else begin
    if not (VarSym^.VVARF in [vfVar,vfVarConst]) then
      VarSym^.VVARF:=vfVarCopy;
    Inc(LocalOffset,Size);	{Locals below A6}
    VarSym^.VADDR:=LocalOffset;
    with ProcSym^ do begin
      Inc(PCpyParmCnt);
      if PCpyParmCnt>High(PCpyParm) then InternalError('Too many parameters to copy');
      PCpyParm[PCpyParmCnt].Above:=Offset;
      PCpyParm[PCpyParmCnt].Below:=LocalOffset;
      PCpyParm[PCpyParmCnt].Size:=Abs(Size);
    end;
    Size:=4;		        {Params above A6 (Pointer to real stuff)}
  end;
  inc(Offset,Size);		{Params above A6}
  DbgDumpVar(dvPHead, VarSym, ProcSym);
end;

Procedure CheckMetode;
begin
  if ParentObj=NIL then
    Error(Err_NotAnOBJ);
  with ParentObj^ do if TMSIZ=0 then TMSIZ:=4;	{Exact 4????????????}
end;

{ DoHeader ======================================== }
Procedure DoHeader(FirstTime: Boolean; ScopePtr: TScope);
var
  VarSym: pSymRec;
  LocalOffset,Offset: Longint;
  Typ:	TypPtr;
begin {DoHeader}
  if FirstTime then with ProcSym^ do begin
    PPARS:=8;
    if SLEV>1 then Inc(PPARS,4); //Local procs
    if ParentObj<>NIL then Inc(PPARS,4); //Object
  end;
  if Scan(SLPA) then
    if FirstTime then begin
      with ProcSym^ do case ProcWhat of
      SCONSTRUCTOR: begin CheckMetode; Include(PFLAG,PDconstructor); end;
      SDESTRUCTOR:  begin CheckMetode; Include(PFLAG,PDdestructor); end;
      end;
      Offset:=0;
      repeat
        VARF:=Scan(SVAR); if not VARF then CONSTF:=Scan(SCON);
        Inc(ProcSym^.PPARC,DoVar(dvPHead,SNONE,Offset,ProcSym));
      until not Scan(SSEM);
      VARF:=False; CONSTF:=False;
      Find(SRPA);
      Offset:=ProcSym^.PPARS; //No params yet!
      LocalOffset:=0;	{8(12) and up, 0 and down}
      VarSym:=ProcSym;;;;;;;; //Pointer(ScopePtr);
      inc(Integer(VarSym),SymRecSize(VarSym^));   ///////////!!!!!!!!!!!!!!!!!!!
      SetAddrsPas(VarSym,ProcSym,ProcSym^.PPARC,Offset,LocalOffset);
      ProcSym^.PPARS:=Offset;
      ProcSym^.UsageA6:=LocalOffset;
    end else begin
      if ProcSym^.PPARC>0 then repeat ScanNext until Scan(SRPA);
    end;
  if FirstTime then ProcSym^.PUSTK:=ProcSym^.PPARS;
  if ProcSym^.PUSTK<8 then
    InternalError0;
  if ProcWhat=SFUN then
    if FirstTime then begin
      Find(SCOL);
      Typ:=FindTYPIDN;
      if not (Typ^.TTYPE in FuncType) then Error(InvalidResult);
      if Typ^.TTYPE=TREA then Typ:=@StandardType[xSNG];
      ProcSym^.PTYPP:=Typ;
      if ParamByRef(Typ) then
        ProcSym^.XUNSTK:=4;
    end else begin
      if Scan(SCOL) then repeat ScanNext until Next.Ch=SSEM
    end;
end; {DoHeader}

{ DefineBody ========================================== }
procedure DefineBody(CurProcName: String; SysProcNo: Integer);
var SelfScope,OldScopePtr: TScope; SelfRec: tSymRec;
begin
  //Inc(SLEV);
  with ProcSym^ do begin
    Include(PFLAG,PDdefined);     //NOW or later?
    Include(PFLAG,PDdoingDef);

    OldScopePtr:=NIL;;;;;;;;;;//<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    ///OldScopePtr:=NewScope(pSymArr(GetTypPtr(PSCOP)),0,skProcedure);

    SelfScope:=NewScope(skProcedure,'ProcBody');
    SetScopeSamePrivate(SelfScope, ProcSym^.PSCOP, NIL);

    if ParentObj<>NIL then begin
      Unimplemented;;;;
      SetScopeSamePrivate(OldScopePtr, ParentObj^.TSCOP, NIL);
      With SelfRec do begin {{{ZeroBlockSym(SelfRec); {--}
        What:=SVAR;
        VVARF:=vfVar{VARF};
        VSLEV:=SLEV; //DLEV;
        VADDR:=8;
        Next.IdnBuf:='SELF'; {{ Next.IdnModus:=999; {Only one link in scope!}
        VTYPP:=ParentObj;
        InsSym(SelfRec);
        SetScopeSamePrivate(OldScopePtr, NIL, SelfScope);  //????
        UNIMPLEMENTED;;;;;;;
      end;
    end;
    DoDeclare(False,UsageA6,PFLAG,ProcSym);

    //PRef.FixUsed:=True; PRef.UNo:=UnitNo;
    //PRef.GrpInx:=Length(mCodeGrps);
    if [PDasm] * PFlag <> [] then begin
      if PRef.GrpInx<>StPart(SASM,CurProcName,ProcSym) then InternalError0;
    end else
      if PRef.GrpInx<>StPart(SBGN,CurProcName,ProcSym) then InternalError0;
    //mCodeGrps[High(mCodeGrps)].SysProcNo:=SysProcNo;
    mCodeGrps[PRef.GrpInx].SysProcNo:=SysProcNo;
    DisposeScope;
    Find(SSEM);
    //if PDforward in PFLAG then ForwardStuff(CurProcName);
    PFLAG:=PFLAG-[PDdoingDef,{PDextrn,}PDforward,PDsystrap];
  end;
  //Dec(SLEV);
end;

{ DoBody ========================================== }
procedure DoBody(First: Boolean; CurProcName: String);
var
  SysProcNo: Integer;
  MakeForward,SkipBody: Boolean;
begin
  SysProcNo:=0;
  SkipBody:=DoInterface;
  Find(SSEM);
  if DoInterface and Not First then
    Error(DupID);
  MakeForward:=True;
  with ProcSym^ do
  repeat
    Case Next.Ch of
    SDIRSYS: begin  //SysProc declaration
               //if (SLEV>0) or not DoInterface then Error(Err_InvDir);
               if SLEV<>1 then Error(Err_InvDir);
               Include(PFLAG,PDSysProc);
               if PTYPP<>NIL then begin
                 if PUSTK<8 then InternalError0;
                 //Dec(PUSTK,PTYPP^.TSIZE);
                 PUSTK:=PPARS-PTYPP^.TSIZE;
                 /////Dec(PPARS,PTYPP^.TSIZE);
               end;
               ScanNext; {FindSLPA;} PFUNO:=FICON; {Find(SRPA);} Find(SSEM);
               if PFUNO>MaxSysProc then InternalError0;
               Glb.SysProc[PFUNO]:=ProcSym;
               SysProcNo:=PFUNO;
             end;
    STRP:    begin //SysTrap
               //if SLEV<>1 then Error(Err_InvDir);
               PFLAG:=PFLAG+[PDsystrap,PDdefined,  PDcdecl]; //PDcdecl!!
               ScanNext; FindSLPA;
               //FCON; PFUNO:=Next.IValue;
               PFUNO:=FUCON;
               while Scan(SPLS) do
                 Inc(PFUNO,FUCON);
               if ScanSCOM then begin
                 PFUNO:=PFUNO + ( (FUCON+1) shl 16); //1 extra!!!
               end;
               Find(SRPA); Find(SSEM);
               SkipBody:=True;
               MakeForward:=False;
             end;
    CDECL:   begin
               Include(PFLAG,PDcdecl);
               ScanNextAndFindSem;
             end;
    SVIRTUAL:if not DoInterface then ScanNextAndFindSem {Unness, but nice}
             else if ParentObj=NIL then BREAK
             else begin
               Include(PFLAG,PDvirtual);
               if PDconstructor in PFLAG then Error(Err_ObjNoConstr);
               ScanNextAndFindSem;
             end;
    SFWD:    {if not DoInterface then Error(Err_InvDir) else //??????
             }begin
               //if SLEV<>1 then Error(Err_InvDir);
               //NameForward(CurProcName);
               ScanNextAndFindSem;
               SkipBody:=True;
               Include(PFLAG,PDforward);
             end;
    SASSEM:  begin ScanNextAndFindSem; Include(PFLAG,PDasm);
             end;
    SNOA6FRAME:
             begin ScanNextAndFindSem; Include(PFLAG,PDNoA6Frame);       //NO USE!! Dec(PPARS,4); //No LINK #nn,A6
             end;
    {SEXT:   if SLEV>0 then Error(Err_Extrn);{}
    else     BREAK;
    end;
  Until False;
  if not SkipBody then begin
    MakeForward:=False;
    DefineBody(CurProcName,SysProcNo);
  end;
  ForwardStuff(not MakeForward, CurProcNameCase);
end;

{ DoProc ========================================== }
var
  ScopePtr: TScope;
  SymRec: tSymRec;
  CurProcName: String;
begin {DoProc}
  ZeroSym(SymRec);
  ScanNext;
  if Next.Ch<>SIDN then Error(ord(SIDN));
  if SYM.DoingInterface and not IsMainModule then
    if cdMakeHelp in OptionsLocal.Active then begin
      if MakeHelp='' then MakeHelp:=IBUGLB.SrcPTR^.IBUNAME+'=';
      MakeHelp:=Format('%s,%s:%d',[MakeHelp,Next.IdnBufCase,IBUGLB.SrcPTR^.IBULINENO]);
    end;
  CurProcName:=Next.IdnBuf; CurProcNameCase:=Next.IdnBufCase;
  IsMainMod:=IsMainModule;
  CP:=CurProcNameCase;

  //ScopePtr:=SYM.UnitScope;
  //if ScopePtr=NIL then
    ScopePtr:=GetScopeTop;

  ProcSym:=ScanScope(ScopePtr);
  Inc(SLEV);
  if ProcSym=NIL then begin
    SymRec.What:=ProcWhat;
    ProcSym:=InsSym(SymRec);
    ScopePtr:=NewScope(skProcedure,'Proc2');
    ProcSym^.PSCOP:=ScopePtr;
    ProcSym^.PSLEV:=SLEV;
    Find(SIDN);
    InitProcSymRec(ProcSym); //////////
    DoHeader(True,ScopePtr);
    DisposeScope;
    //InitProcSymRec(ProcSym);
    DoBody(True,CurProcName);
  end else begin			{Second time named}
    if DoInterface or IsMainModule then
      if not (PDforward in ProcSym^.PFLAG) then Error(DupID);
    with ProcSym^ do
      if (What=STYPP) then begin
        if ParentObj<>NIL then UNIMPLEMENTED;;;;;;;;;//which error
        ParentObj:=FindTYPIDN;    {The OBJECT itself}
        {{{ ParentObj:=GetTypPtr(TTYPP); {{}
        Find(SPER);
        ProcSym:=ScanScope(ParentObj^.TSCOP);
        if ProcSym=NIL then Error(Err_ExpMethod);
      end;
    if not (ProcSym^.What in [SPRO,SFUN,SDESTRUCTOR,SCONSTRUCTOR]) then
      Error(DupID);
    ScanNext;
    DoHeader(False,NIL);
    DoBody(False,CurProcName);
  end;
  Dec(SLEV);
end; {DoProc}

(******************************************************************************)
procedure TUnit7.InitProcSymRec(ProcSym: pSymRec);
begin
  with ProcSym^ do begin //ProcSym^.PRef
    PRef.FixUsed:=True;
    PRef.PCRel:=False;
    PRef.UNo:=UnitNo;
    PRef.GrpInx:=Length(mCodeGrps);
    SetLength(mCodeGrps,Length(mCodeGrps)+1);
    mCodeGrps[PRef.GrpInx].ProcName:=CurProcName+'??';
    if [cdD,cdL]*OptionsLocal.Active<>[] then begin
      mCodeGrps[PRef.GrpInx].MapDoShow_LD:=True;
      Glb.AnyMappedD:=True
    end;
    Inc(Glb.TDbgProcNo); ProcSym^.TDbgProcNo:=Glb.TDbgProcNo;
  end;
end;

(******************************************************************************)
Procedure TUnit7.DbgDumpSym(T: TypPtr);
var S: String; RecDefNo,N,Base: Integer;
begin
  if T=NIL then EXIT;
  if cdY in OptionsLocal.Active then
  with T^ do begin
    if TDbgNo=0 then EXIT;
    if TDbgNo<0 then EXIT;
    TDbgNo := -TDbgNo;
    Case TTYPE of
    TSET,TPTR: //T ; T# ; Name ; Size ; Base ; x ; x ; Element ; x ; x
      begin
        S:=Format(';;%d;;',[Abs(TELEP^.TDbgNo)]);
        DbgDumpSym(TELEP);
      end;
    TARY: //T ; T# ; Name ; Size ; Base ; x ; x ; Element ; Index ; x
      begin
        S:=Format(';;%d;%d;',[Abs(TELEP^.TDbgNo),Abs(TIDXP^.TDbgNo)]);
        DbgDumpSym(TELEP);
        DbgDumpSym(TIDXP);
      end;
    //?? TOBJ,
    //??TPRO,   {Procedure }
    //???TPAC,   {Packed array of char ?? Use TSTR only??}
    TREC: //T ; T# ; Name ; Size ; Base ; min ; max ; x ; x ; RecDefNo
      begin
        Inc(Glb.RecDefNo); RecDefNo:=Glb.RecDefNo;
        S:=Format('%d;%d;;;%d',[TMINV,TMAXV,Glb.RecDefNo]);
        for N:=0 to TScop.Table.Count-1 do     //t^.TScop.Table.Count,r
          DbgDumpVar(dvRecord, pSymRec(TScop.Table.Objects[N]),NIL,RecDefNo);
      end;
    TNON,TSTR,TREA,TINT,TBOL,TCHR,TUSR:
      S:=Format('%d;%d;;;',[TMINV,TMAXV]);
    else EXIT
    end;
    if T<>TBASE then DbgDumpSym(TBASE);
    if TBASE<>NIL then Base:=Abs(TBASE^.TDbgNo) else Base:=0;
    S:=Format('T;%d;%s;%s;%d;%d;%s',[Abs(TDbgNo),TDbgName,TypeVisible[TTYPE],TSIZE,Base ,S]);
    //PackFlag!!
    //DebugIfL(S);
    Glb.TestMapFile.Add(S);
  end;
end;

Procedure TUnit7.DbgDumpVar(DumpWhat: tDoVar; VarSym, ProcSym: pSymRec; RecDefNo: Integer=0);
var Pno,Lev: Integer; S: String;
Const LastProcSym: pSymRec=NIL;
begin
  if cdY in OptionsLocal.Active then
  with VarSym^ do begin
    if DumpWhat=dvRecord then
      if RecDefNo=0 then
        EXIT;
    if What<>SVAR then EXIT;
    if (ProcSym=NIL) and (DumpWhat=dvPHead) then EXIT; //SysProc
    if DumpWhat<>dvRecord then begin
      if LastProcSym<>ProcSym then Glb.TestMapFile.Add(';----');
      LastProcSym:=ProcSym;
    end;
    DbgDumpSym(VTYPP);
    if RecDefNo=0 then Lev:=VSLEV else Lev:=-1; //Record = -1
    if ProcSym=NIL then PNo:=0 else PNo:=ProcSym^.TDbgProcNo;
    S:=Format('V;%s;%d;%d;%d;%s;%d;',[DbgName,VADDR,PNo,Lev,DbgDoVar[DumpWhat],Abs(VTYPP^.TDbgNo)]);
    if RecDefNo>0 then
      S:=S+i2s(RecDefNo);
    //DebugIfL(S);
    Glb.TestMapFile.Add(S); //V
    Glb.AnyMappedY:=True;
  end;
end;

(******************************************************************************)
{ DoVar =========================================== }
Function TUnit7.DoVar(Flag: tDoVar; EndSym: eSym; var Offset: Longint; ProcSym: pSymRec): Integer;
Var
  DoVarCntBatch: Integer;
  DoVarCntTotal: Integer;       {Global returned count}
  SymRec: tSymRec;              {Global for recursive use}
  IncAddr: ShortInt;

Function  DoVarList(Inx: Integer): Pointer;
var Typ:    TypPtr;
    SymPos: pSymRec;
    Id:     String;
begin
  Inc(DoVarCntTotal); Inc(DoVarCntBatch);
  SymPos:=InsSym(SymRec);
  Id:=Next.IdnBufCase;
  Find(SIDN);
  if Scan(SCOM) then
    Typ:=DoVarList(Inx+1)
  else begin
    if Flag=dvPHead then begin
      if (Next.Ch<>SCOL) and VARF then begin
        Typ:=@StandardType[xUNT];
        if Next.Ch=SIDN then Find(SCOL); //(var B C D E: Integer); trapped!!
      end else begin
        Find(SCOL);
        {done elsewhere if not (Next.Ch in [SIDN,SSTR]) then Error(ExpID); {}
        Typ:=FindTYPIDN;
        //if (Typ.TTYPE=TSET) and not VARF then Error(asdasdasd);
      end
    end else begin
      Find(SCOL);
      if Next.Ch=SOBJ then Error(Err_Type); {Not as var!}
      Typ:=FindType(False,'',ProcSym);
    end;
    if Typ^.TSIZE>1 then
      Offset:=EvenSize(Offset);
  end;
  //Fix "const". vfVarConst => vfGlobal/vfLocal
  with SymPos^ do if (VVARF=vfVarConst) and (Typ^.TTYPE in eSimpType) then
    if SLEV=0 then VVARF:=vfGlobal else VVARF:=vfLocal;
  Result:=Typ;
  with SymPos^ do begin
    DbgName:=Id;
    if Flag<>dvPHead then begin //Done in DoHeader
      if IncAddr>0 then VADDR:=Offset+Inx*Typ^.TSIZE      //0,2,4,6
      else              VADDR:=Offset-(1+Inx)*Typ^.TSIZE; //-2,-4,-6,-8
      if Abs(VADDR)>=32767 then
        Error(Err_Variables);
    end;
    SymPos^.VTYPP:=Typ;
    if Flag<>dvPHead then
      DbgDumpVar(Flag, SymPos,ProcSym);
  end;
end;

var Typ: TypPtr;
begin {DoVar}
  DoVarCntTotal:=0;
  if Flag in IncVars then IncAddr:=1 else IncAddr:=-1;
  With SymRec do
    repeat
      DoVarCntBatch:=0;
      ZeroSym(SymRec);
      What:=SVAR;
      VSLEV:=SLEV;   //DLEV
      if VARF then
        VVARF:=vfVar
      else
        if CONSTF then
          VVARF:=vfVarConst
        else
          if SLEV=0 then
            VVARF:=vfGlobal
          else
            VVARF:=vfLocal;
      Typ:=DoVarList(0); //Fix "const". vfVarConst => vfGlobal/vfLocal
      //if VVARF in [vfVar,vfVarConst] then
      //  Inc(Offset,IncAddr * 4)
      //else
        Inc(Offset,IncAddr * DoVarCntBatch*Typ^.TSIZE);
      //Offset:=EvenSize(Offset);
      if EndSym<>SNONE then Find(EndSym);	{After tagfield in case!}
    until Next.Ch<>SIDN;			{Never true for Procedure hdr's}
  DoVar:=DoVarCntTotal;
end;

(*****************************************************************************)
{ DoType ========================================== }
procedure TUnit7.DoType(ProcSym: pSymRec);
var SymRec: tSymRec;		{Global for recursive use}
  Typ: TypPtr;
  Sym: pSymRec;
  N: Integer;
  H: tNext;
  TypeName: String;
begin
  ScanNext;
  ZeroSym(SymRec);
  if Length(Undef)<>0 then
    InternalError('Undefined types');
  repeat
    SymRec.What:=STYPP;
    Sym:=InsSym(SymRec);
    With Sym^ do begin
      What:=SNONE; //Not STYPP until correct
      TypeName:=Next.IdnBufCase;
      Find(SIDN);
      Find(SEQS);
      PACF:=False; Typ:=FindType(True,TypeName,ProcSym);
      Find(SSEM);
      What:=STYPP; TTYPP:=Typ;
    End;
  Until Next.Ch<>SIDN;

  H:=Next;
  for N:=0 to High(Undef) do with Undef[N] do
    if xUndefSymPos<>NIL then begin
      Typ:=xUndefSymPos;
      Next.IdnBuf:=ID; LastScanPtr:=NIL;
      Sym:=ScanScope(GetScopeTop);
      if Sym=NIL then
        Sym:=ScanSym(False,DummyWithCode); //FindType;
      if DummyWithCode <> NIL then Error(Unknown); //never!!
      if Sym=NIL then Error(UndefPType,' ^'+ID);
      if Sym^.What<>STYPP then
        Error(Unknown);
      Typ^.TELEP:=Sym^.TTYPP;
    end;
  for N:=0 to High(Undef) do with Undef[N] do
    if xSymPos<>NIL then begin
      Sym:=xSymPos; Next.IdnBuf:=ID; Next.Ch:=SIDN;
      Sym^.TTYPP:= TYPIDN(FALSE,FALSE);
      if Sym^.TTYPP=NIL then Error(Unknown, ID);;;;
      if Sym^.What<>STYPP then Error(Unknown, ID);;;;
      if Sym^.TTYPP^.TTYPE<>TPTR then Error(Unknown, ID);;;;
    end;
  Next:=H;
  SetLength(Undef,0);
end;

{ DoLabel ========================================= }
Procedure TUnit7.DoLabel;
var SymRec: tSymRec;
begin
  ScanNext;
  With SymRec do begin
    ZeroSym(SymRec);
    What:=SLBL;
    LSLEV:=SLEV;
    // LNLEV:=0; LADDR:=NIL;
    Repeat
      IntIdn; //Label # => String ID's
      InsSym(SymRec);
      Find(SIDN);
    Until not Scan(SCOM);
  End;
  Find(SSEM);
end;

{ DoConst ========================================= }
procedure TUnit7.DoConst;
procedure DoSomeConst;
var
  xIdnBuf:  Str63;
  Typ: TypPtr;
  SymRec:   tSymRec;
  TType:    eType;
begin
  With Next,SymRec do repeat
    ZeroSym(SymRec); What:=SCON;
    if Ch=SCOL then begin
      UNIMPLEMENTED;   {........ typed const}
    end else begin
      xIdnBuf:=IdnBuf;
      Find(SIDN); Find(SEQS);
      Typ:=Con;
      if Typ=NIL then
        InternalError0;
      SymRec.CTYPP:=Typ;
      TType:=Typ^.TTYPE;
      case TType of
      TPTR,TBOL,
      TUSR: CIVAL:=IValue; //ALSO MAKE ARITH ON INTEGERS!!!!
      TREA: CRVAL:=RValue;
      TINT: begin  //BETTER ALSO DO REAL EXPR WITH (,),*,/,+,-
              CIVAL:=IValue;
              (********
              ///xIdnBuf:=Next.IdnBuf;
              //REMOVE !!!!!!!!!!!!!!!!!
              while Next.Ch in [SPLS,SMIN,SOR,SAND] do begin //No hierachy
                NextCh:=Next.Ch;
                ScanNext;
                Typ2:=Con;
                if Typ2^.TTYPE<>TINT then Error(ExpCInt);
                case NextCh of
                SPLS: Inc(CIVAL,IValue);
                SMIN: Dec(CIVAL,IValue);
                SOR:  CIVAL:=CIVAL OR IValue;
                SAND: CIVAL:=CIVAL AND IValue;
                end;
              end;
              IdnBuf:=xIdnBuf; {Restore ID}
              ********)
            end;
      TCHR: begin   //Better do this in Con()
              CIVAL:=IValue;
              while Scan(SPLS) do begin
                if SymRec.CTYPP<>@StandardType[xPAC] then begin //First time around!!
                  CSVAL:=Chr(IValue);
                  SymRec.CTYPP:=@StandardType[xPAC];
                end;
                if not (Con^.TTYPE in [TCHR,TPAC]) then Error(ExpCStr);
                CSVAL:=CSVAL+SValue;
              end;
            end;
      TPAC: begin   //Better do this in Con()
              CSVAL:=SValue;
              while Scan(SPLS) do begin
                if not (Con^.TTYPE in [TCHR,TPAC]) then Error(ExpCStr);
                CSVAL:=CSVAL+SValue;
              end;
            end;
      else  Error(Err_Error)
      end;
      IdnBuf:=xIdnBuf; {Restore ID}
      InsSym(SymRec)
    end;
    Find(SSEM)
  Until Ch<>SIDN;
end;
begin {DoConst}
  ScanNext;
  DoSomeConst;
end;

End.

