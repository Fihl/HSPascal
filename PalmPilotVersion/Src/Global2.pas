unit Global2;
{  $D-}

interface

Uses Classes, SysUtils, Global, RsrcIo;

Type
  TUnit0=Class
    UnitName: UsesStr;
    UnitNo: Integer;
    Next: tNext;                 //Always clear LastScanPtr when fidling with this one
    IsMainModule: Boolean;       //True for Program or Library
    DidCompileModule2: Boolean;  //Check for circular refs
    CmpWhat: tCmpWhat;           //(CmpUnit,CmpProgram,CmpLibrary)
    UsedScopes: String;          //String of Inx into GlbUnits
    //CodeEng: TObject;          //TCode68K;
    Rsrc: TRsrc;
    MakeHelp: String;            //if $MakeHelp
    //MainUsageA6: Integer;
    Forwards: Record FWDCNT: Integer; FwdName: TStringList end;
    AsmUndefLabels: Integer;
    SYM: Record
      Cnt:		Integer;
      CurScopePrivate:	Boolean;	{Current state of Private(T)/Public(F)}
      DoingInterface:	Boolean;	{T=Interface, F=Implementation}
      Scopes: array[1..MaxScope] of TScope;
      SWithCode: array[1..MaxScope] of TDag0;
      //ScopesUsed:       TList;
      UnitScope:        TScope;         {Units own declarations (almost eq to GetScopeTop)}
      BufPos:           Integer;
      Buffer:           array[0..100000] of Byte;  //Max uses 1-8-2001 = 60000!
    end;
    NLEV:          Byte;                 {For Nesting level}
    SLEV:          Byte;
    VARF,CONSTF:   Boolean;
    //DLEV:          Byte;
    PACF:          Boolean;		{True after PACKED}
    LastScanPtr:   pSymRec; {Cleared whenever the Scanner has been called}
    LastWithCode:  TDag0;
    LastScanScope: TScope;  {Local here, but nice to debug}
    AsmScope:      TScope;  {Used for @1, @2,.. in Assem}
    IsProg:        Boolean; //Easy debug break
    DidASM:        Boolean;
    Constructor Create;
    Destructor  Destroy; Override;
    Function    StPart(What: eSym; CurProcName: String; ProcSym: pSymRec): Integer; Virtual; Abstract;
    Procedure   StaProc(P: pSymRec; var CodeX0: tDag0); Virtual; Abstract;
    Function    StaFunc(P: pSymRec; var CodeX0: tDag0): TypPtr; Virtual; Abstract;
    Procedure DoFunction(P: pSymRec; var Code: tDag0); Virtual; Abstract;
  public
    Function  NewScope(SK: eScopeKind; Const AName: String): TScope;
    Procedure DisposeScope;
    Procedure SetScopeSamePrivate(ThisSc, SameAs, PrivateOne: TScope);
    Function  ScanSym(AllowUndef: Boolean; var WithCode: tDag0): pSymRec;
    Function  ScanScope(Scope: TScope): pSymRec;	    {All related scopes}
    Function  GetScopeTop: TScope;
    Function  GetScopeTopNotRecObj: TScope;
    Procedure EnterScopeBlkNameObj(Scope: TScope; Obj: Integer);
    Function  EnterScopeBlkType(Var Block: TType; Const Name: String): TypPtr;
    Function  InsSym(var SymRec: tSymRec): pSymRec;
    Function  InsSymAbs(Scope: TScope; var SymRec: tSymRec): pSymRec;
  private
    Function  EnterScopeBlkRaw(Var Block; Len: Integer): Pointer;
  public
    mCode:  Array of Word;
    mFixup: Array of TRef; //Record UNo,GrpInx: SmallInt end;
    mCodeGrps: Array of Record
                 ProcName: String; //Debug
                 Used, MainProc: Boolean;
                 CodeBaseB: Integer;
                 CodeFirst,CodeCntW: SmallInt;
                 FixupFirst,FixupCnt: SmallInt;
                 SysProcNo: Byte; //SysInit+SysTerm
                 MapDoShow_LD: Boolean; //cdL & cdD => A records in mapfile
                 MapProcNo: Integer;
               end;
    mCodeGrpMain: Integer; //Initial -1
    mCodeNext,mFixupNext,mCodeGrpsNext: Integer; //All: =Length(mXXX records)
    AnyCodeUsed: Boolean;   //Include Main proc, if any used!
    TotalCodeUsedW: Integer; //After StripCode
    Function  CodeGrpMain: Integer;
    Function  CodeGrpLast: Integer;
    Function  HasMainProc: Boolean;
  end;

Function CurCompList: String;

implementation

Uses
  Misc;

Constructor TUnit0.Create;
begin
  Inherited Create;
  //CodeEng:= TCode68K.Create;
  Rsrc:= TRsrc.Create;
  //SYM.ScopesUsed:=TList.Create;
  SYM.DoingInterface:=True;
  SYM.CurScopePrivate:=False;
  SYM.BufPos:=2;  //Skip offset 0!!
  Forwards.FwdName:=TStringList.Create;
  if dvGlobal in IncVars then
    Glb.UsageA5:=4;   //A5 plus based Skip first. ;loader stores SysAppInfoPtr in  0(a5)
  mCodeGrpMain:=-1;
end;

Destructor TUnit0.Destroy;
var N: Integer;
begin
  //CodeEng.Free;
  Rsrc.Free;
  //SYM.ScopesUsed.Free;
  for N:=1 to SYM.Cnt do SYM.Scopes[N].Free;
  Inherited
end;

Function  TUnit0.NewScope(SK: eScopeKind; Const AName: String): TScope;
begin
  With SYM do begin
    if Cnt>=MaxScope then Error(Err_Scope);
    Inc(Cnt);
    Result:=TScope.Create(SK);
    Result.Name:=AName;
    Scopes[Cnt]:=Result;
    SWithCode[Cnt]:=NIL;
    //ScopesUsed.Add(Result);
    //if LargeDebug then Debug(Format('NewScope %d, %s, %s',[SYM.Cnt,CurProcName,AName]));
  end;
end;

Procedure TUnit0.DisposeScope;
begin
  Dec(SYM.Cnt);
  //if LargeDebug then Debug(Format('DisScope %d, %s',[SYM.Cnt,CurProcName]));
end;

Function  TUnit0.ScanScope(Scope: TScope): pSymRec;	{All related scopes}
Function  ScanScope0(Scope: TScope): pSymRec;
var N: Integer;
begin
  Result:=NIL;
  if Scope=NIL then
    EXIT; //Maybe never, ie internal error
  N:=Scope.Table.IndexOf(Next.IdnBuf);
  if N>=0 then
    Result:=Pointer(Scope.Table.Objects[N]);
end;
begin
  Result:=ScanScope0(Scope); if Result<>NIL then EXIT;
  (****if pScopeHeader(Scope)^.LinkPrivateScope<>NIL then begin
    P:=ScanScope(GetTypPtrx(pScopeHeader(Scope)^.LinkPrivateScope));
    if P<>NIL then goto 9;
  end; (******)
  if Assigned(Scope.LinkSameScope) then
    Result:=ScanScope(Scope.LinkSameScope);
end;

Function  TUnit0.GetScopeTop: TScope;
begin
  Result:=SYM.Scopes[SYM.Cnt];
end;

Function  TUnit0.GetScopeTopNotRecObj: TScope;
var N: Integer;
begin
  with SYM do
    for N:=Cnt downto 1 do begin
      Result:=Scopes[N];
      if Result.SKind in [skRecord, skObject] then CONTINUE;
      EXIT
    end;
  Result:=GetScopeTop;
end;


Function  TUnit0.ScanSym(AllowUndef: Boolean; var WithCode: tDag0): pSymRec; {DOES NOT SCAN NEXT!!!!!!!}
var n: Integer; AUnit: TUnit0;
begin
  if LastScanPtr<>NIL then begin
    Result:=LastScanPtr;
    WithCode:=LastWithCode;
  end else begin
    LastWithCode:=NIL;
    WithCode:=NIL;
    //Scan own scopes
    for N:=SYM.Cnt downto 1 do begin
      LastScanScope:=SYM.Scopes[N];
      Result:=ScanScope(LastScanScope);
      if Result<>NIL then begin
        LastScanPtr:=Result;
        LastWithCode:=SYM.SWithCode[N];
        WithCode:=LastWithCode;
        EXIT
      end;
    end;
    //Scan other module scopes
    for N:=1 to Length(UsedScopes) do begin
      AUnit:=Pointer(GlbUnits.Objects[Ord(UsedScopes[N])]);
      LastScanScope:=AUnit.SYM.UnitScope;   //AUnit.SYM.Scopes[AUnit.SYM.Cnt];
      Result:=ScanScope(LastScanScope);
      if Result<>NIL then begin
        LastScanPtr:=Result;
        EXIT
      end;
    end;

    if (WithCode<>NIL) or not AllowUndef then Error(Unknown);
    LastScanPtr:=NIL;
    Result:=NIL;
  end;
end;

{Used in HspMain & Declare for Objects}
Procedure TUnit0.SetScopeSamePrivate(ThisSc, SameAs, PrivateOne: TScope);
begin
  if SameAs<>NIL then
    ThisSc.LinkSameScope:=SameAs;
  if PrivateOne<>NIL then
    ThisSc.LinkPrivateScope:=PrivateOne;
end;

Procedure TUnit0.EnterScopeBlkNameObj(Scope: TScope; Obj: Integer);
//var WithCode: tDag0; //N: Integer;
begin
  //if ScanScope(Scope,WithCode)<>NIL then Error(DupID);
  //N:=Scope.Table.Count;
  try    Scope.Table.AddObject(Next.IdnBuf, Pointer(Obj));
  except Error(DupID)
  end;
  //if N+1<>Scope.Table.Count then InternalError0;
end;

Function  TUnit0.EnterScopeBlkRaw(Var Block; Len: Integer): Pointer;
begin
  with SYM do begin
    Result:=@Buffer[SYM.BufPos];
    if Odd(Len) then
      Inc(Len);
    if SYM.BufPos+Len>High(Buffer) then
      Error(Err_Symbols);
    Move(Block,Buffer[BufPos],Len);
    Inc(BufPos,Len);
    if MaxBufPos<BufPos then MaxBufPos:=BufPos; //Debug only!!
  end;
end;

Function  TUnit0.EnterScopeBlkType(Var Block: TType; Const Name: String): TypPtr;
begin
  //if Block.TDbgNo<20 then
  //  if Block.TDbgNo>0 then
  //    Block.TDbgNo:=Block.TDbgNo;
  Inc(Glb.TDbgNoSym); Block.TDbgNo:=Glb.TDbgNoSym;
  Block.TDbgName:=Name;
  Result:=EnterScopeBlkRaw(Block,SizeOf(Block))
end;

Function  TUnit0.InsSym(var SymRec: tSymRec): pSymRec;
begin
  Result:=InsSymAbs(GetScopeTop, SymRec);
end;

Function  TUnit0.InsSymAbs(Scope: TScope; var SymRec: tSymRec): pSymRec;
var
  P: pSymRec;
begin
  P:=EnterScopeBlkRaw(SymRec,SymRecSize(SymRec));
  EnterScopeBlkNameObj(Scope, Integer(P));
  Result:=P;
end;

Function  TUnit0.CodeGrpLast: Integer;
begin
  Result:=High(mCodeGrps);
end;

Function  TUnit0.CodeGrpMain: Integer;
begin
  Result:=mCodeGrpMain;
  if Result>CodeGrpLast then
    Result:=-1
end;

Function  TUnit0.HasMainProc: Boolean;
begin
  Result:= CodeGrpMain >= 0
end;

Function CurCompList: String;
var N: Integer;
begin
  Result:='';
  for N:=0 to GlbUnits.Count-1 do
    if not TUnit0(GlbUnits.Objects[N]).DidCompileModule2 then begin
      if Result<>'' then Result:=Result+', ';
      Result:=Result+LowerCase(TUnit0(GlbUnits.Objects[N]).UnitName);
    end;
end;

end.

