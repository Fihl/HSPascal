Unit HSPMain;

Interface

Uses
  Classes, SysUtils, Global, Declare{TUnit7};

function DoCompiler: Boolean;

Type
  TUnit8=Class(TUnit7)
  Private
    procedure CompileSrcPart1Inter(DoPGM: Boolean);
    procedure CompileSrcPart2Imple;
    Procedure UsesCL;
    Procedure CompileModule(Name: String; MustBeProgram: Boolean);
    Procedure CompileModule2(Const Name: String; MustBeProgram: Boolean);
  end;

  TUnit = TUnit8;

Implementation

Uses
  Global2, Util, Misc, uMisc1, Scanner, Stmt, CodeReal, RsrcIo, Dag, CodeDag
  {$ifdef VersionUI} , Forms, Dialogs, DebugFrm {$Endif}
  ;

function GlbUnit(Inx: Integer): TUnit;
begin
  if Inx>=GlbUnits.Count then Result:=NIL  // 0..Count-1
  else begin
    Result:=Pointer(GlbUnits.Objects[Inx]);
    if Result.UnitNo<>Inx then
      InternalError0;
  end;
end;

Function AccumulateAllUnits(What: eAccumulateAllUnits): Integer;
var N: Integer;
begin
  Result:=0;
  for N:=0 to GlbUnits.Count-1 do
    Inc(Result,GlbUnit(N).AccumulateAllUnits(What));
end;

procedure SetUiData(AUnit: TUnit; E: ECompException; S: String='');
begin
  if UIIntf.ErrNo<>0 then EXIT;
  if AUnit.IBUGLB.SrcPTR=NIL then begin
    UIIntf.ErrFile:='';
    UIIntf.ErrLine:=0;
  end else begin
    UIIntf.ErrFile:=AUnit.IBUGLB.SrcPTR.IBUNAME;
    UIIntf.ErrLine:=AUnit.IBUGLB.SrcPtr.IBULINENO;
  end;
  UIIntf.ErrPos :=AUnit.IBU.ErrPos;
  UIIntf.ErrLen :=Max(0,AUnit.IBU.PTR-AUnit.IBU.ErrPos);
  UIIntf.ErrLineStr:=AUnit.IBU.Line;
  if E=NIL then begin
    UIIntf.ErrStr :='Internal Error 998';
    if S<>'' then UIIntf.ErrStr:=S;
    UIIntf.ErrNo  :=998;
  end else begin
    UIIntf.ErrStr :=E.Message;
    UIIntf.ErrNo  :=E.Rc;
  end;
  Write('Compile Error in ???');
  if UIIntf.ErrLine=0 then
    UIIntf.ErrLine:=1; //??
end;

(******************************************************************************)
{ CompileSrcPart1Inter ====================================== }
procedure TUnit8.CompileSrcPart1Inter(DoPGM: Boolean);
procedure AutoUsesSystems;
var MaxCh,Ch: Char;
begin
  MaxCh:=#0;
  for Ch:='1' to LastHSSys do //HSSys1 HSSys2 HSSys3 HSSys4
    if CmpStr(UnitName,'HSSys'+Ch) then
      BREAK else MaxCh:=Ch;
  for Ch:='1' to MaxCh do  //HSSys1 HSSys2 HSSys3 HSSys4
    CompileModule('HSSys'+Ch,False);
end;
var DummyUsageA6: Integer;
begin //CompileSrcPart1Inter
  with Forwards do begin FWDCNT:=0; FwdName.Clear end;
  if SYM.Cnt=0 then begin
    //ScopePtr:=
    NewScope(skNONE,'Defaults');   //Done for ALL units!!
    EnterDefType;{(ScopePtr);{}
  end else InternalError0;
  try
    try
      DoingMain:=DoPGM;
      IsProg:= DoPGM;
      if DoPGM then begin
        DoInterface:=False; //ScanProgramHdr(SPGM);
        CmpWhat:=CmpProgram;
        IsMainModule:=True;
      end else begin
        //ScanProgramHdr(SUNI);
        Find(SINF);
        DoInterface:=True;
        CmpWhat:=CmpUnit;
      end;
      if ParamStr(1)<>'-SKIPHSSYS' then
        AutoUsesSystems;
      UsesCL;
      if CmpWhat=CmpProgram then
        SYM.UnitScope:=NewScope(skProgram,UnitName)
      else
        SYM.UnitScope:=NewScope(skUnit,UnitName);
      DummyUsageA6:=0; DoDeclare(True,DummyUsageA6,[],NIL);
      if DummyUsageA6<>0 then InternalError('Space used2!!??');
    except
      on E: ECompException do begin SetUiData(Self, E); RAISE end;
      on E: Exception do begin SetUiData(Self, NIL, E.Message); RAISE end;
      else SetUiData(Self, NIL); RAISE
    end
  finally
  end;
end;

procedure TUnit8.CompileSrcPart2Imple;
var
  DummyUsageA6: Integer;
  SymRec: tSymRec;
  ProcSym: pSymRec;
begin {CompileSrcPart2Imple}
  try
    try
      if MakeHelp<>'' then
        MakeHelpTxt.Add(MakeHelp);
      if DoInterface then begin //otherwise Program
        DoInterface:=False;
        Find(SIMP);
        UsesCL;
        SYM.DoingInterface:=False;
        SYM.CurScopePrivate:=True;
        DummyUsageA6:=-2000;;; DoDeclare(False,DummyUsageA6,[],NIL);
        if DummyUsageA6<>-2000 then InternalError('Space used1!!??');
      end;
      if Next.Ch=SBGN then begin
        mCodeGrpMain:=Length(mCodeGrps);

        ZeroSym(SymRec);
        SymRec.What:=SPRO;
        ProcSym:=InsSym(SymRec);
        InitProcSymRec(ProcSym);
        {G2:=}StPart(SBGN,'ProgramBegin',ProcSym);   //=mCodeGrpMain

        //Done in dagCodeProc mCodeGrps[mCodeGrpMain].ProcName:='Main';
        mCodeGrps[mCodeGrpMain].MainProc:=True;
        if Length(mCodeGrps)=mCodeGrpMain then InternalError0; //G=G2 !!
      end else Find(SEND);
      if not (Next.Ch in [SPER,SDPE,SRBR]) then Error(ord(SPER));
      if Forwards.FWDCNT<>0 then
        Error(Err_UndefFWD,Forwards.FwdName.CommaText);
    except
      on E: ECompException do begin SetUiData(Self, E); RAISE end;
      on E: Exception do begin SetUiData(Self, NIL, E.Message); RAISE end;
      else SetUiData(Self, NIL); RAISE
    end;

    {if LargeDebug then
      for N:=1 to Length(UsedScopes) do
        with tUnit0(Pointer(GlbUnits.Objects[Ord(UsedScopes[N])])) do
          Debug(Format('Unit(%s): %s, %d',[Self.UnitName,UnitName,UnitNo]));
    {}
  finally
  end;
end;

{ UsesCL ========================================== }
Procedure TUnit8.UsesCL;
begin
  if Scan(SUSE) then begin
    repeat
      Find(SIDN);
      CompileModule(Next.IdnBuf,False);
    until not Scan(SCOM);
    Find(SSEM);
  end;
end;

{ CompileModule ========================================== }
Procedure TUnit8.CompileModule(Name: String; MustBeProgram: Boolean);
var
  N: Integer;
  AUnit: TUnit;
  Fil,S: String;
begin //CompileModule
  if Name='' then
    Error(Err_NoSrc);

  if pos('.',ExtractFileName(Name))=0 then Insert('.pas',Name,999);

  Fil:=UpCaseStr(ExtractFileName(Name));
  N:=GlbUnits.IndexOf(Fil);
  if N<0 then begin
    AUnit:=TUnit.Create;
    AUnit.UnitNo:=GlbUnits.Count;
    GlbUnits.AddObject(Fil,AUnit);

    if false then
    if Assigned(UIIntf.CallBack) then begin
      S:=CurCompList+Fil;
      UIIntf.CallBack(S);
    end;

    //ErrorStr2:=CurCompList+Name;
    AUnit.CompileModule2(Name, MustBeProgram); //CompileSrcPart1Inter
    AUnit.DidCompileModule2:=True;
  end else begin
    AUnit:=Pointer(GlbUnits.Objects[N]);
    if not AUnit.DidCompileModule2 then begin
      S:=CurCompList;
      Error(Err_CircRef,'Uses '+S);
    end;
  end;
  N:=GlbUnits.IndexOf(Fil);
  if Pos(Char(N),UsedScopes)>0 then
    Error(Err_AlreadyUsed);
  UsedScopes:=UsedScopes+Char(N); //String of Inx into GlbUnits

  NewScope(skUnit,Name);
  SYM.Scopes[SYM.Cnt].LinkSameScope:=AUnit.SYM.UnitScope;

  if SYM.UnitScope<>NIL then begin
    SYM.Scopes[SYM.Cnt-1]:=SYM.Scopes[SYM.Cnt];   //Move new top down below UnitScope
    SYM.Scopes[SYM.Cnt]:=SYM.UnitScope;
  end;
end;

Procedure TUnit8.CompileModule2(Const Name: String; MustBeProgram: Boolean);
var What: eSym;
begin
  //StartTime:=Now;
  EnterReserved;
  try
    //Write('Compiling: '+Name);
    if not OpenSrc(Name) then
      Error(Err_NoSrc,Name);
    if MustBeProgram then What:=SPGM else What:=SUNI;
    try
      ScanNext;
      Find(What);
      UnitName:=Next.IdnBuf; Find(SIDN);
      IsProg:= What=SPGM;
      if What=SPGM then if Scan(SLPA) then begin
        repeat Find(SIDN) until not Scan(SCOM);
        Find(SRPA);
      End;
      Find(SSEM);
    except
      on E: ECompException do begin SetUiData(Self, E); RAISE end;
      on E: Exception do begin SetUiData(Self, NIL, E.Message); RAISE end;
      else SetUiData(Self, NIL); RAISE
    end;
    CompileSrcPart1Inter(What=SPGM);
    (***if LargeDebug then
      for N:=0 to High(mCodeGrps) do with mCodeGrps[N] do
        Debug(Format('%s: %s, U%d, M%d, B%d, C%d, C#%d, F%d, F#%d, P#:%d',[
                 Name,ProcName,ord(Used), Ord(MainProc),CodeBaseB,CodeFirst,CodeCntW,
                 FixupFirst,FixupCnt,SysProcNo]));
    ***)
  finally
    //Write(Format('Compile time: %.1fS (%s)',[(Now-StartTime)*(24*60*60),UnitName]));
  end;
end;

(******************************************************************************)
Procedure StripCode(DoDebug: Boolean);
var
  CodeSize,G,N: Integer; AUnit,MainUnit: TUnit;
begin
  MainUnit:=GlbUnit(00000{GlbUnits.Count-1});
  if DoDebug then Debug('Main:'+MainUnit.UnitName);
  MainUnit.StripCodeAddMain(TRUE,DoDebug);

  //Include needed SysProcs, not included in normal program!
  if MainUnit.CmpWhat=CmpProgram then begin
    for N:=0 to GlbUnits.Count-1 do begin
      AUnit:=GlbUnit(N);
      if AUnit<>NIL then
      with AUnit do
        for G:=Low(mCodeGrps) to High(mCodeGrps) do
          with mCodeGrps[G] do
            if SysProcNo in [ISysInit,ISysTerm] then
              AUnit.StripCodeAdd(G,DoDebug);
    end;
  end;

  repeat
    CodeSize:=AccumulateAllUnits(eTotalCodeUsedW);
    //M:=Glb.GlobalCodeSizeB;  ///TEST TOO!!!
    for N:= +1 to GlbUnits.Count-1 do
      GlbUnit(N).StripCodeAddMain(FALSE,DoDebug);
    //M:=Glb.GlobalCodeSizeB;  ///TEST TOO
  until CodeSize=AccumulateAllUnits(eTotalCodeUsedW);
end;

Procedure RelocateAllAfterPC(BreakPC, Ofs: Integer);
var
  G,N: Integer; AUnit: TUnit;
begin
  for N:=0 to GlbUnits.Count-1 do begin
    AUnit:=GlbUnit(N);
    if AUnit<>NIL then
    with AUnit do
      for G:=Low(mCodeGrps) to High(mCodeGrps) do
        with mCodeGrps[G] do
          if CodeBaseB>=BreakPC then
            Inc(CodeBaseB,Ofs);
  end;
end;

(******************************************************************************)
Procedure CallInitCode(DoDebug: Boolean);
var
  C,COfs,CMax,BraLen,G,N,CodeSizeW: Integer;
  AUnit,MainUnit: TUnit;
  Fix: TRef;

Procedure CodeW(W: Integer; W2: Integer=MaxLongInt);
begin
  if C+COfs>=CMax then
    InternalError0;
  MainUnit.mCode[C+COfs]:=W and $0000FFFF;
  inc(COfs);
  if W2<>MaxLongInt then CodeW(W2);
end;
Procedure AddFixup(Fix: TRef; Where: Integer);
var F: Integer;
begin
  Fix.Where:=Where; Fix.FixUsed:=True;
  with MainUnit do begin
    F:=Length(mFixup);
    SetLength(mFixup,F+1);
    inc(mCodeGrps[G].FixupCnt);
    mFixup[F]:=Fix;
    CodeW(-1); //Garbage
  end;
end;

begin
  MainUnit:=GlbUnit(00000{GlbUnits.Count-1});
  if DoDebug then Debug('Main:'+MainUnit.UnitName);
  FillChar(Fix,SizeOf(Fix),0); Fix.FixUsed:=True;
  CodeSizeW:=0; //bra.w!   bra.s
  BraLen:=2+4;  //+4 = SKIP SysExit!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  for N:=0 to GlbUnits.Count-1 do begin
    AUnit:=GlbUnit(N);
    if AUnit.HasMainProc then
      if AUnit.mCodeGrps[AUnit.CodeGrpMain].Used then begin
        Inc(CodeSizeW,2);
        Inc(BraLen,4);
      end;
  end;
  //if CodeSizeW>120 then Inc(CodeSizeW); //bra.w
  Inc(CodeSizeW,2+2+ 1+2+1); //bsr SysProc1, beq.w, moveq #0,d0 bsr sysProc2, rts
  RelocateAllAfterPC(0, CodeSizeW*2);
  with MainUnit do begin
    C:=Length(mCode); CMax:=C+CodeSizeW; COfs:=0;

    G:=Length(mCodeGrps); SetLength(mCodeGrps,G+1);
    AllocateCodeBlock(G,CodeSizeW);

    inc(TotalCodeUsedW,CodeSizeW);
    Inc(Glb.GlobalCodeSizeB,CodeSizeW*2);
    MainUnit.mCodeGrps[G-1].MainProc:=False;  /////!!!!!!
    with mCodeGrps[G] do begin
      Used:=True;
      MainProc:=True;   //CodeBaseB := ??????
      FixupFirst:=Length(mFixup);
      ProcName:='HSPascal';
      CodeBaseB:=0;
    end;
    CodeW(opcBSR); AddFixup(LocateSysProc(ISysInit),COfs*2);
    CodeW(opcBNE,BraLen);
    for N:=GlbUnits.Count-1 downto 0 do begin
      AUnit:=GlbUnit(N);
      if AUnit.HasMainProc or AUnit.IsMainModule then begin
        if AUnit.mCodeGrps[AUnit.CodeGrpMain].Used or AUnit.IsMainModule then begin
          CodeW(opcBSR);
          Fix.UNo:=AUnit.UnitNo; Fix.GrpInx:=AUnit.CodeGrpMain;
          AddFixup(Fix,COfs*2); //Also CodeW(xx) //Offset from CodeBaseB
if DoDebug then Debug('InitCode: '+UnitName+'.'+AUnit.mCodeGrps[Fix.GrpInx].ProcName+
' GrpInx:'+i2s(Fix.GrpInx)+' CodeAddr:'+i2h4((C+COfs)*2-2));
        end;
      end;
    end;
    CodeW(opcBSR); AddFixup(LocateSysProc(ISysTerm),COfs*2);
    //LabelEXIT:
    CodeW(opcMOVEQ0D0);
    CodeW(opcRTS);
  end;
end;

(******************************************************************************)
procedure FixupBSRs(var AllCode: CodeWordArray; DoDebug: Boolean);  //Work on AllCode
var F,G,Max,Diff,Src,Dst,U: Integer; AUnit,AUnit2: TUnit; S: String;
begin
  Max:=High(AllCode);
  for U:=0 to GlbUnits.Count-1 do begin
    AUnit:=GlbUnit(U); if AUnit=NIL then Internalerror0;
    //with AUnit do
    for G:=0 to AUnit.CodeGrpLast do
    with AUnit.mCodeGrps[G] do
      if Used then
        for F:=FixupFirst to FixupFirst+FixupCnt-1 do
        with AUnit.mFixup[F] do begin
          AUnit2:=GlbUnit(UNo); if AUnit2=NIL then InternalError0;
          Dst:=AUnit2.mCodeGrps[GrpInx].CodeBaseB;
          Src:=CodeBaseB+Where;
          Diff:=Dst-Src;
S:=Format('%s.%s %.4x => %.4x %s.%s (%d,%d)',
[AUnit.UnitName,ProcName,Src,Dst,AUnit2.UnitName,AUnit2.mCodeGrps[GrpInx].ProcName,GrpInx,F]);
if DoDebug then Debug(S); 
if AUnit2.mCodeGrps[GrpInx].ProcName='' then begin
  DebugIfL('Missing proc!!');  /// InternalError('CodeStrip. Code missing');
  InternalError('CodeStrip. Code missing');
end;
          if Dst=0 then
            InternalError('CodeStrip''ed too much');
          Src:=Src div 2;
          if Src>Max then
            InternalError0;
          AllCode[Src]:=Word(Diff);
        end;
  end;
end;

(******************************************************************************)
function DoCompiler: Boolean;
var
  M,N: Integer;
  AUnit: TUnit;
  CurrentDir,S,S2: String;
  Rsrc: TRsrc;
  StartTime: TDateTime;
  AllCode: CodeWordArray;
Const
  Code0: Record AboveA5,BelowA5,jmpSize,ofs_jmptab: LongWord;
                jmptab1,jmptab2,jmptab3,jmptab4: Word
         End=(AboveA5:$30000000; BelowA5:$08000000; jmpSize:$08000000; ofs_jmptab:$20000000;
              jmptab1:0; jmptab2:$3c3f; jmptab3:$0100; jmptab4:$F0a9);

begin
  try
    try
      Result:=False;
      InitCompiler;
      CurCodeDag:=NIL;

      {$include Expire.pas}

      NextRsrcLocated:=1100;   /////$0444;   //!!!!!!!!!!!!1092
      SkipDebug:=   FALSE;
      ErrorStr2:='';
      StartTime:=Now;
      GlbUnits:=TStringList.Create;
      if HSPascalLibCache=NIL then HSPascalLibCache:=TStringList.Create;

      CurrentDir:=GetCurrentDir;
      S:=ExtractFilePath(UIIntf.Src);
      SetCurrentDir(S);

      AUnit:=TUnit.Create;
      try    AUnit.CompileModule(UIIntf.Src,TRUE);   //Always ONLY "Program"
             Result:=True;
      except Result:=False;  //on E: ECompException do SetUiData(AUnit, E)
      end;

      {$include Expire.pas}
      if Assigned(UIIntf.CallBack) then UIIntf.CallBack('Implementation');
      AUnit.Free;
      if Result then begin
        N:=0;
        while N<GlbUnits.Count do begin
          AUnit:=GlbUnit(N);
          try
            //Write('Part2: '+AUnit.UnitName);
            AUnit.CompileSrcPart2Imple;
            AUnit.CloseSrc;
          except
            Result:=False;
            BREAK;
          end;
          inc(N);
        end;
      end;
      for N:=0 to GlbUnits.Count-1 do begin
        GlbUnit(N).CloseSrc; //In case of errors
        if FALSE then
        if TestMode then
          Debug(Format('Unit(%d): %s',[N, GlbUnits[N]]));
      end;


      if Result then begin
        {$include Expire.pas}
        if Assigned(UIIntf.CallBack) then UIIntf.CallBack('Linking');
        //Result:=False;
        try
          {$ifdef VersionUI} FormDebug.DebugClear; {$Endif}
          DebugIfL('StripCode *  *  *  *  *  *  *  *  *  *  *  *  *  *');

          if Glb.AnyMappedD or Glb.AnyMappedL then begin
            for N:=1 to High(Glb.MapFileList) do begin
              S:=Format('F;%d;%s',[N,Glb.MapFileList[N].Name]);
              //DebugIfL(S);
              Glb.TestMapFile.Add(S); //F
            end;
            for N:=0 to High(Glb.MapProcList) do
              if Glb.MapProcList[N].Mapped then begin
                S:=Format('P;%d;%s',[Glb.MapProcList[N].TDbgProcNo,Glb.MapProcList[N].Name]);
                //DebugIfL(S);
                Glb.TestMapFile.Add(S); //P
              end;
          end;

          StripCode(FALSE and TestMode);

          DebugIfL('CallInitCode');
          CallInitCode(FALSE and TestMode);

          {$include Expire.pas}

          for M:=0 to GlbUnits.Count-1 do
            with GlbUnit(M) do
              for N:=Low(mCodeGrps) to High(mCodeGrps) do with mCodeGrps[N] do
                if Used and MapDoShow_LD then begin
                  S:=Format('A;%d;%.4x;%.4x',[MapProcNo,CodeBaseB,CodeCntW*2]);
                  //NONO if TestMode then S:=S+'  ;;;('+Glb.MapProcList[MapProcNo].Name+')';
                  //DebugIfL(S);
                  Glb.TestMapFile.Add(S); //A
                end;

          DebugIfL('Binary code #1');
          SetLength(AllCode,Glb.GlobalCodeSizeB div 2);
          M:=0;
          for N:=0 to GlbUnits.Count-1 do
            Inc(M,GlbUnit(N).StripCodeGetTheCode(AllCode));

          DebugIfL('FixupBSRs');
          FixupBSRs(AllCode,FALSE and TestMode);
          {$include Expire.pas}

          {$ifdef VersionUI} if not TestMode then{} FormDebug.DebugClear; {$Endif}
          N:=High(AllCode);
          if N>2000 then
            Debug('No disassembly, as limit is at 2000 words')
          else
            DisAsm(AllCode,0,High(AllCode));

          if M<>Glb.GlobalCodeSizeB then
            InternalError('Missing some code!');

          //Killing little indian format!
          for N:=Low(AllCode) to High(AllCode) do AllCode[N]:=Swap(AllCode[N]);

          //Write('Collecting rsrc''s');
          //Ok, save some files. *.prc
          //HSSy1, HSSys2, other units, MainProgram last!!
          Rsrc:=TRsrc.Create;
          for N:=0001 to GlbUnits.Count do begin //NOT 0..Count-1!!!
            if N=GlbUnits.Count then AUnit:=GlbUnit(0) else AUnit:=GlbUnit(N); //Main last!!!
            for M:=1 to AUnit.Rsrc.Cnt do
              with AUnit.Rsrc do
                Rsrc.Add1Rsrc(Get1RsrcName(M),Get1RsrcId(M),Get1Rsrc(M));
          end;
          Code0.BelowA5:=SwapL(Abs(Glb.UsageA5));
          {$include Expire.pas}
          Rsrc.Add1Rsrc('code',0,Blk2Str(Code0,SizeOf(Code0)));
          Rsrc.Add1Rsrc('code',1,Blk2Str(AllCode[0],Length(AllCode)*2));
          S:=UIIntf.Src; S:=ChangeFileExt(S,'.prc');
          //Fil:=FileCreate(S);
          {$include Expire.pas}
          if OptionsGlobal.OutputPath<>'' then begin
            S2:=ExtractFilePath(OptionsGlobal.OutputPath); //Already iFormatPath, ie with traling '\'
            if S2<>'' then S2:=iFormatPath(S2);
            S:=S2+ExtractFileName(S);
          end;
          Rsrc.SaveToFile(S);
          Rsrc.Free;
          Write(Format('Compiled %d lines in %.1fS',
                [UIIntf.TotLinesCompiled,(Now-StartTime)*(24*60*60)]));

          if Glb.AnyMappedD or Glb.AnyMappedY then begin
            S:=ChangeFileExt(S,'.map');           // .prc => .map
            Glb.TestMapFile.SaveToFile(S);
            for N:=0 to Glb.TestMapFile.Count-1 do
              DebugIfL(Glb.TestMapFile[N]);
          end;

          Result:=True;
        finally
          for N:=0 to GlbUnits.Count-1 do
            GlbUnit(N).Free;
          GlbUnits.Free;
          SetCurrentDir(CurrentDir);
          //NONO, keep around HSPascalLibCache.Free; HSPascalLibCache:=NIL;
        end;
        if MakeHelpTxt.Count>0 then
          MakeHelpTxt.SaveToFile(MakeHelpName);
      end;
    except
      on E: Exception do begin
        UIIntf.ErrStr :=E.Message;
        Result:=False;
      end;
    end;
  finally
    //
  end;
  DeInitCompiler;
end;

(******
Procedure ObjHeader;
var P: pSymRec; VirtBase: TypPtr;
var NewTyp: tType;
begin
  ZeroSym(NewTyp,SizeOf(NewTyp)); NewTyp.TTYPE:=TPRO;
  if ProcWhat in [SCONSTRUCTOR,SDESTRUCTOR] then CheckMetode;
  ScanNext; if Next.Ch<>SIDN then Error(Unknown);
  P:=ScanScope(GetScopeTop);
  if P=NIL then VirtBase:=NIL
  else begin
    Error(DupID); {{{{{{{ treat virtual again!}
    VirtBase:=NIL;;;;;;
  end;
  UNIMPLEMENTED;;;;;;;;;
end;
(********)

End.

