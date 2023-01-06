Unit HSSys4;

{ By Christen Fihl                     }
{ Copyright (C) 1990,2001 Christen Fihl}

interface
{$R-,S-,D-}
{$MakeHelp-}

Const
  sndError=3;
  ErrStack = 201;
  ErrRange = 202;

Type //; system\systemprv.h
  PSysAppInfoType = ^SysAppInfoType;
  SysAppInfoType = Record
    cmd: SmallInt;
    cmdPBP: Pointer;
    LaunchFlags: SmallInt;
    taskID: Longint;
    codeH: Pointer;
    dbP: Pointer;
    stackP: Pointer;
    globalsChunkP: Pointer;
    memOwnerID: SmallInt;
    dmAccessP: Longint;
    dmLastErr: SmallInt;
    errExceptionP: Pointer;
  End;

Var
  GlobalsPtr:    Pointer;
  PrevGlobals:   Pointer;
  SysAppInfoPtr: PSysAppInfoType;
  RandSeed:      LongInt;   { Random Seed global }
  //Followin is yet used
  {HighStak:     Pointer;   { Top of stack area }
  LowStack:      Pointer;   { Bottom of stack area }
  LastPC:        LongInt;   { Last known address, set by range and stack check}
  RetSP:         Pointer;   { Initial Top of Stack }
  ExitProc:      Pointer;   { User installable exit procedures }
  ExitCode:      SmallInt;  { Error number. Usable in exit procedures }
  ErrorAddr:     Pointer;   { Error address. Usable in exit procedures }
  PrgBase:       Pointer;   { Program load address}

procedure SysInit; SysProc ISysInit;
procedure SysExit; SysProc ISysTerm;
procedure SysHalt; SysProc ISysHalt;
procedure SysInitLib; SysProc ISysInitLib;
procedure SysExitLib; SysProc ISysTermLib;

procedure SysCASE; Assembler; NoA6Frame; SysProc PSysCase;
procedure SysPCopy; Assembler; NoA6Frame; SysProc PSysPCopy;
procedure XLDS(var Src,Dst: String); SysProc ISysStrLd;
procedure XSTS(var Src,Dst: String{; Len: SmallInt in D0!}); SysProc ISysStrSto;
procedure XSCP(S2,S1: Pointer); SysProc ISysStrCmp;
procedure XCON(Src,Dst: Pointer); SysProc ISysStrAdd;
procedure XCPY(Dst,Src: Pointer; Pos,Len: SmallInt); SysProc FSysStrCopy;
procedure XPOS; SysProc FSysStrPos;
procedure XPOSch; SysProc FSysStrPosCh;
procedure XINS(Src,Dst: Pointer; Max,Pos: SmallInt); SysProc PSysStrIns;
procedure XDEL(Str: Pointer; Pos,Cnt: SmallInt); SysProc PSysStrDel;
procedure XUPC; SysProc FSysUpcase;
procedure XSTRL; Assembler; NoA6Frame; SysProc FSysStrLen;
procedure _PadNMoveStr(var FromS,ToS: String; Width,MaxLen: Integer);

procedure XLDZ(Src,Dst: Pointer; Sizeo,Zero: SmallInt); Assembler; NoA6Frame; SysProc ISysSetLd;
procedure XLZZ; Assembler; NoA6Frame; SysProc ISysSetLdZero;
procedure XAZE(No: SmallInt); Assembler; NoA6Frame; SysProc ISysSetAdd1;
procedure XAZR(Frst,Last: SmallInt); Assembler; NoA6Frame; SysProc ISysSetAddN;
procedure XSTZ(Src,Dst: Pointer; Size,Zero: SmallInt); Assembler; NoA6Frame; SysProc ISysSetSto;
procedure XZIN(No: SmallInt; Dst: Pointer); Assembler; NoA6Frame; SysProc ISysSetIn;
procedure XZEQ; Assembler; NoA6Frame; SysProc ISysSetEQ;
procedure XZGE; Assembler; NoA6Frame; SysProc ISysSetGE;
procedure XZLE; Assembler; NoA6Frame; SysProc ISysSetLE;
procedure XZUN; Assembler; NoA6Frame; SysProc ISysSetUnion;
procedure XZDI; Assembler; NoA6Frame; SysProc ISysSetDiff;
procedure XZIS; Assembler; NoA6Frame; SysProc ISysSetInter;

procedure XMOV(Src,Dst: Pointer; Cnt: SmallInt); Assembler; NoA6Frame; SysProc PSysMove;
procedure XFLC(Dst: Pointer; Cnt: SmallInt; Val: Byte); Assembler; NoA6Frame; SysProc PSysFillChar;

procedure XNEW(VAR Ptr: Pointer; Size: Longint); Assembler; NoA6Frame; SysProc PSysMemGet;
procedure XDIS(Ptr: Pointer; Size: Longint); Assembler; NoA6Frame; SysProc PSysMemFree;
procedure XMEM; Assembler; NoA6Frame; SysProc FSysMemAvail;
procedure XMAX; Assembler; NoA6Frame; SysProc FSysMemMaxAvail;

procedure XMUL32; Assembler; NoA6Frame; SysProc ISys32Mul;
procedure XSQRI; Assembler; NoA6Frame; SysProc ISys32Sqr;
procedure XDIVI; Assembler; NoA6Frame; SysProc ISys32Div;
procedure XMODI; Assembler; NoA6Frame; SysProc ISys32Mod;
procedure XABS16;  Assembler; NoA6Frame; SysProc FSysAbs16;
procedure XABS32;  Assembler; NoA6Frame; SysProc FSysAbs32;

procedure XRNDI; Assembler; NoA6Frame; SysProc FSysRandomI;
procedure XRNDR; Assembler; NoA6Frame; SysProc FSysRandomR;
procedure XRNDZ; Assembler; NoA6Frame; SysProc PSysRandomize;

procedure XSTK; Assembler; NoA6Frame; SysProc ISysOptStack;
procedure XCRL; Assembler; NoA6Frame; SysProc ISysOptRangeL;
procedure XCRW; Assembler; NoA6Frame; SysProc ISysOptRangeW;

procedure IntStr(I: Longint; W: SmallInt; var S: String; LenOfS: SmallInt); Assembler; SysProc ISysStringI;
procedure StrInt(var S: String; VAR I, Pos: SmallInt); Assembler; SysProc PSysValI;

implementation

Uses HSUtils;

//Return NZ if cannot start normally
//Also D0=cmd or -1 if error
{$ifdef HackProgram}
procedure SysInit; Assembler; NoA6Frame; SysProc ISysInit; ASM cmp d0,d0 end;
{$else}
procedure SysInit; Assembler; SysProc ISysInit;
var
  LocalGlobalsPtr: Pointer;
  LocalPrevGlobals: Pointer;
  LocalSysAppInfoPtr: PSysAppInfoType;
ASM     //Err SysAppStartup(AppInfoPtr, PrevGlobals, GlobalsPtr)
        pea     LocalGlobalsPtr
        pea     LocalPrevGlobals
        pea     LocalSysAppInfoPtr
        SysTrap SysAppStartup
        //add     #12,sp
        move.l  LocalGlobalsPtr,d1
        move.l  LocalPrevGlobals,d2
        move.l  LocalSysAppInfoPtr,a0
        tst.w   d0
        bne     @SUErr
        //done! move.l  LocalSysAppInfoPtr,a0
        move.w  SysAppInfoType.cmd(a0),d0  //sysAppLaunchCmdNormalLaunch is 0
        bne     @Stop                      //No support for Find etc, only Apps
        //trap #8
        move.l  d1,GlobalsPtr              //Now into A5 area
        move.l  d2,PrevGlobals
        move.l  a0,SysAppInfoPtr
        //SysTrap FPlInit

        move.l  4(a6),a0                   // Keep A0 on program-load-point (for test only)
        subq.l  #4,a0                      // A4 might already be set by Palm OS
        {$ifdef fnDebug}
        lea     8(a0),a1                   // locate second last BSR in init sequence
@BSRs:  cmp.w   #$6100,8(a1)
        addq    #4,a1
        beq     @BSRs
        move.w  -(a1),d0
        add.w   d0,a1                      // Main program entry point
        move.l  a1,PrgBase
        trap    #8
        {$endif}
        moveq   #0,d0                      //RetZ
        bra     @9
@SUErr: move.w  #sndError,-(sp)
        SysTrap SndPlaySystemSound
        //add     #2,sp
@Stop:  move.l  d1,-(sp)
        move.l  d2,-(sp)
        move.l  a0,-(sp)
        SysTrap SysAppExit
        moveq   #-1,d0                     //RetNZ, ERROR
@9:
end;
{$endif}

procedure SysExit; Assembler; NoA6Frame; SysProc ISysTerm;  //!!!!!!!!!!!!!!!!!!
ASM     //SysTrap FplFree
{$ifndef HackProgram}
        move.l  GlobalsPtr,-(sp)
        move.l  PrevGlobals,-(sp)
        move.l  SysAppInfoPtr,-(sp)
        SysTrap SysAppExit
        add     #3*4,sp
        moveq   #0,d0
{$endif}
end;

procedure SysInitLib; Assembler; NoA6Frame; SysProc ISysInitLib;
ASM     move.l  (sp)+,A0                //Return
        movem.l D3/D4,-(sp)
        move.l  8(sp),d4                //SysLibTblEntryPtr
        move.w  12(sp),d3               //RefNum
        moveq   #0,d0
        jmp     (a0)
end;
procedure SysExitLib; Assembler; NoA6Frame; SysProc ISysTermLib;
ASM     move.l  (sp)+,a0
        movem.l (sp)+,D3/D4
        jmp     (a0)
end;

{Returns A3 = ErrorAddr if error else garbage}        //!!!!!!!!!!!!!!!!!!
procedure SysTerm; Assembler; NoA6Frame;
ASM     MOVE.L  A6,-(SP)
        {Show error}
        TST.L   ErrorAddr
        //BEQ   @Ok
@Ok:    MOVE.W  ExitCode,D0
        EXT.L   D0
        MOVE.L  (SP)+,A6
END;

{ RunError() }
procedure SysError; Assembler; NoA6Frame; ////////// SysProc ISysTerm; {No use of A6}
ASM     MOVE.L  PrgBase,D0
        TST.L   (SP)
        BEQ     @1
        SUB.L   D0,(SP)                 {ErrorAddr}
@1:     MOVE.L  (SP)+,ErrorAddr
        MOVE.W  (SP)+,ExitCode
        ;MOVE.L  HighStak,SP             {Give all stack to user}
@2:     MOVE.L  ExitProc,A0
        CLR.L   ExitProc
        MOVE.L  A0,D0
        BEQ     @3
        JSR     (A0)                    {Call uses Exit() routines}
        BRA     @2                      {Call "Term" as the last one}
@3:     MOVE.L  RetSP,SP                {Give some stack to user}
        ADDQ.L  #4,SP //???             {Is exact now}
        MOVE.L  (SP)+,D0                {Return}
END;

procedure SysHalt; Assembler; NoA6Frame; SysProc ISysHalt;

ASM     CLR.L   (SP)                    {Kill return addr (error addr)}
        JMP     SysError                //DOLATER
END;

//In D0.L, A0
procedure SysCASE; Assembler; NoA6Frame; SysProc PSysCase;
ASM
        MOVE.L  A1,A0                   //Oct-2003, BigCODE1
@1:     MOVEQ   #0,D2                   //If END; (ELSE)
        MOVE.W  (A0)+,D1
        BMI     @9                      //FFFF
        MOVE.B  D1,D2                   //Caseno lo byte
        LSR.W   #8,D1                   //CaseType 0=Range, 3=Single
        BNE     @Sing
@Rang:  MOVE.L  (A0)+,D1
        CMP.L   (A0)+,D0
        BGT     @1
        CMP.L   D1,D0
        BLT     @1
        BRA     @9
@Sing:  MOVE.W  (A0)+,D1                //NE!
        BRA     @S8
@S1:    CMP.L   (A0)+,D0
@S8:    DBEQ    D1,@S1
        BNE     @1
@9:     ADD.W   D2,D2                   //Step by 2
        MOVE.L  (SP),A0
        LEA     2(A0,D2.W),A0
        ADD.W   (A0),A0                 //Address of Case statement
end;
//32bit Integer:  CC00 LLLLLLLLLL..HHHHHHHHHH CC00 LLLLLLLLLL..HHHHHHHHHH
//16bit SmallInt: CC03 NNNN 11111111,2222222222,33333333,44444444

//      D0      Number of words to move less one
//      SP+4    Dst offset from A6
//      SP+6    Offset to Src^ from A6
procedure SysPCopy; Assembler; NoA6Frame; SysProc PSysPCopy;
ASM     MOVEM.W 4(SP),A0/A1             //Dst,Src
        MOVE.L  0(A6,A1.W),A1           //Above A6, a pointer
        LEA     0(A6,A0.W),A0           //Below A6
@1:     MOVE.W  (A1)+,(A0)+
        DBRA    D0,@1
        MOVE.L  (SP)+,(SP)
end;

{ *******************************************************}
{ *                                                     *}
{ *     STRING ROUTINES                                 *}
{ *                                                     *}
{ *******************************************************}

//Load string to StrNN
// In   8(SP) = Source
//      4(SP) = Destination

procedure XLDS(var Src,Dst: String); Assembler; SysProc ISysStrLd;
ASM     //MOVE.W  #MaxString+1,-(SP)
        //MOVE.L  Src,-(SP)
        //MOVE.L  Dst,-(SP)
        //SysTrap StrNCopy                //Buggy version
        MOVE.L  Src,-(SP)
        MOVE.L  Dst,-(SP)
        //MOVE.W  #MaxString+1,-(SP)
        MOVE    #MaxString+1,D0
        JSR     XSTS
END;

// Store string
// In    8(SP) = Source
//       4(SP) = Destination
//         D0 = Maximum length (W) incl \0

procedure XSTS(var Src,Dst: String{; Len: SmallInt D0!}); Assembler; SysProc ISysStrSto;
ASM     //MOVE.W  Len,-(SP)
        //MOVE.L  Src,-(SP)
        //MOVE.L  Dst,-(SP)
        //SysTrap StrNCopy              //Buggy version
        MOVE.L    Src,A0
        MOVE.L    Dst,A1
        //MOVE.W    Len,D0              //Already there
        //SUBQ.W    #1,D0                 //Real data is one less
        SUBQ.W    #2,D0                 //v2.01 Real data is one less, and zero terminated
        BLE       @8
        //BRA       @2
@1:     MOVE.B    (A0)+,(A1)+
@2:     DBEQ      D0,@1
        BEQ       @9
@8:     CLR.B     (A1)                  //End if not already copied
@9:
END;

// String concatenation
// In   8(SP) = Source
//      4(SP) = Destination

procedure XCON(Src,Dst: Pointer); Assembler; SysProc ISysStrAdd;
ASM     //MOVE.W  #MaxString+1,-(SP)
        //MOVE.L  Src,-(SP)
        //MOVE.L  Dst,-(SP)
        //SysTrap StrNCat
        MOVE.L  Src,A0
        MOVE.L  Dst,A1
        MOVEQ   #MaxString-1,D0        //Real data is one less, also 1 less because no JMP @2
@1:     TST.B   (A1)+
@2:     DBEQ    D0,@1
        SUBQ.W  #1,A1
        ADDQ.L  #1,D0
        JMP     @4
@3:     MOVE.B  (A0)+,(A1)+
@4:     DBEQ    D0,@3
@9:     CLR.B   (A1)
END;

// String compare
// In   8(SP) = S2 Source
//      4(SP) = S1 Destination
// Out  CCR   = Result in Z and C
procedure XSCP(S2,S1: Pointer); Assembler; SysProc ISysStrCmp;
(******* OLD CODE!!
ASM     MOVE.L  S2,-(SP)
        MOVE.L  S1,-(SP)
        //SysTrap StrCaselessCompare
        //TST.W   D0
        //BNE     @9
        SysTrap StrCompare
@9:     TST.W   D0                      //>0 if S1>S2 (Left>Right)
END;
(*******)
ASM     MOVE.L  S2,-(SP)
        SysTrap StrLen
        MOVE.W  D0,-(SP)
        MOVE.L  S1,-(SP)
        SysTrap StrLen                  //Length(S1)
        MOVE.L  (SP)+,A0                //S1
        MOVE.W  (SP)+,D1                //Length(S2)
        MOVE.L  (SP)+,A1                //S2
        MOVE.W  D0,D2
        CMP.W   D1,D2                   //D2:=min(D0,D1)
        BLS     @1
        MOVE.W  D1,D2
@1:     SUBQ.W  #1,D2
        BCS     @3
@2:     CMPM.B  (A1)+,(A0)+
        DBNE    D2,@2
        BNE     @4
@3:     CMP.W   D1,D0                   //Original lengths
@4:
END;
(******)


// COPY function
// In  12(SP) = Destination
//      8(SP) = Source
//      6(SP) = Position
//      4(SP) = Length

procedure XCPY(Dst,Src: Pointer; Pos,Len: SmallInt); Assembler; SysProc FSysStrCopy;
ASM     MOVEM.L Src,A0/A1               //Get Dst too
        MOVE.W  Pos,D0
@1:     SUBQ.W  #1,D0                   //Skip inital part of Src
        BLE     @6
        TST.B   (A0)+
        BNE     @1
@5:     SUBQ.W  #1,A0                   //From exceeds source
@6:     MOVE.W  Len,D0                  //Cannot make more than MaxLen bytes
        BRA     @8
@7:     MOVE.B  (A0)+,(A1)+             //XSTS!
@8:     DBEQ    D0,@7
@9:     CLR.B   (A1)
END;


// INSERT procedure
// Insert(S,T,P) - T:=Copy(T,1,P-1)+S+Copy(T,P,255)
// In  12(SP) = Source string
//      8(SP) = Target string
//      6(SP) = Maximum length (incl \0)
//      4(SP) = Position

procedure XINS(Src,Dst: Pointer; Max,Pos: SmallInt); Assembler; SysProc PSysStrIns;
Var Temp,Temp2: String;
ASM     PEA     Temp
        MOVE.L  Dst,-(SP)
        MOVE.W  #1,-(SP)
        MOVE.W  Pos,-(SP)
        SUBQ.W  #1,(SP)
        JSR     XCPY                    //XCPY(Dst,Src: Pointer; Pos,Len: SmallInt)
        MOVE.L  Src,-(SP)
        PEA     Temp
        JSR     XCON                    //XCON(Src,Dst: Pointer)
        PEA     Temp2
        MOVE.L  Dst,-(SP)
        MOVE.W  Pos,-(SP)
        MOVE.W  #MaxString+1,-(SP)
        JSR     XCPY                    //XCPY(Dst,Src: Pointer; Pos,Len: SmallInt)
        PEA     Temp2
        PEA     Temp
        JSR     XCON                    //XCON(Src,Dst: Pointer)
        PEA     Temp
        MOVE.L  Dst,-(SP)
        //MOVE.W  Max,-(SP)
        MOVE.W  Max,D0
        JSR     XSTS                    //XSTS(Src,Dst: Pointer; Len: SmallInt)
END;

// DELETE procedure
// Delete(S,P,N) - S:=Copy(S,1,P-1)+Copy(S,P+N,255)
// In   8(SP) = String
//      6(SP) = Position
//      4(SP) = Count

procedure XDEL(Str: Pointer; Pos,Cnt: SmallInt); Assembler; SysProc PSysStrDel;
Var Temp,Temp2: String;
ASM     PEA     Temp
        MOVE.L  Str,-(SP)
        MOVE.W  #1,-(SP)
        MOVE.W  Pos,-(SP)
        SUBQ.W  #1,(SP)
        JSR     XCPY                    //XCPY(Dst,Src: Pointer; Pos,Len: SmallInt)
        PEA     Temp2
        MOVE.L  Str,-(SP)
        MOVE.W  Pos,D0
        ADD.W   Cnt,D0
        MOVE.W  D0,-(SP)
        MOVE.W  #MaxString+1,-(SP)
        JSR     XCPY                    //XCPY(Dst,Src: Pointer; Pos,Len: SmallInt)
        PEA     Temp2
        PEA     Temp
        JSR     XCON                    //XCON(Src,Dst: Pointer)
        PEA     Temp
        MOVE.L  Str,-(SP)
        //MOVE.W  #MaxString+1,-(SP)
        MOVE    #MaxString+1,D0
        JSR     XSTS                    //XSTS(Src,Dst: Pointer; Len: SmallInt)
END;

// POS function
// In   8(SP) = Pattern string
//      4(SP) = Target string
// Out  4(SP) = Position
procedure XPOS; Assembler; NoA6Frame; SysProc FSysStrPos; {No params => special format}
ASM     MOVE.L  8(SP),-(SP)
        MOVE.L  8(SP),-(SP)
        SysTrap StrStr
        MOVEM.L (SP)+,D0/D1/A1
        MOVE.L  A0,D1
        SUB.L   D0,D1
        ADDQ.L  #1,D1                   //found: 1..oo
        BPL     @9
        MOVEQ   #0,D1                   //not found: 0
@9:     ADD     #8,SP
        MOVE.W  D1,-(SP)
        JMP     (A1)
END;

// POS function
// In   6(SP) = Pattern Char
//      4(SP) = Target string
// Out  4(SP) = Position
procedure XPOSch; Assembler; NoA6Frame; SysProc FSysStrPosCh;
ASM     MOVEM.L (SP)+,A0/A1
        MOVE.B  (SP),D0
        CLR.W   (SP)
        MOVEQ   #0,D1
@1:     ADDQ.W  #1,D1
        CMP.B   (A1)+,D0
        BHI     @1                              //Above, then not /0 !
        BEQ     @8
        TST.B   (A1)                            //End of string?
        BEQ     @9
        BRA     @1
@8:     MOVE.W  D1,(SP)
@9:     JMP     (A0)
END;

// Upcase(ch: char): char
// Must keep D0-D2

procedure XUPC; Assembler; NoA6Frame; SysProc FSysUpcase;
ASM     MOVE.L  (SP)+,A0
        CMP.W   #'a',(SP)
        BLT     @9
        CMP.W   #'z',(SP)
        BGT     @9
        SUB.W   #' ',(SP)
@9:     JMP     (A0)
END;

procedure XSTRL; Assembler; NoA6Frame; SysProc FSysStrLen;  //Return Word!!
ASM     MOVE.L  4(SP),-(SP)
        SysTrap StrLen
        ADDQ    #4,SP
        MOVE.L  (SP)+,A0
        ADDQ    #2,SP
        MOVE.W  D0,(SP)
        JMP     (A0)
END;

procedure _PadNMoveStr(var FromS,ToS: String; Width,MaxLen: Integer);
var N: Integer;
begin
  FillChar(ToS,MaxLen,0);
  N:=Min(MaxLen,Length(FromS));
  if Width>N then FillChar(ToS,Width-N,' '); //Empty string with enough spaces
  //XSTS(FromS,ToS,N);
  Insert(FromS,ToS,10000); //XINS. Do NOT uses ToS:=ToS+FromS
end;

{ *******************************************************}
{ *                                                     *}
{ *     SET ROUTINES                                    *}
{ *                                                     *}
{ *******************************************************}

{ NOTE: Keep set discriptor on stack while adding elements! XLZZ, XAZE, XAZR}

{ Load zero set
{ In    0(SP) = Destination
{ Out   Set discriptor is keept on stack}
procedure XLZZ; Assembler; NoA6Frame; SysProc ISysSetLdZero;
ASM     MOVE.L  4(SP),A0
        MOVEQ   #8-1,D0
@1:     CLR.L   (A0)+
        DBRA    D0,@1
END;

{ Add set element}
{ In    2(SP) = Destination
{       0(SP) = Element number
{ Out   SP    = SP+2}
{       Set discriptor is keept on stack}
procedure XAZE(No: SmallInt); Assembler; NoA6Frame; SysProc ISysSetAdd1;
ASM     MOVE.L  (SP)+,A1
        MOVE.W  (SP)+,D0
        MOVE.L  (SP),A0                 //Keep on stack
        MOVEQ   #0,D1
        MOVE.B  D0,D1
        LSR.W   #3,D1
        BSET    D0,0(A0,D1.W)
        JMP     (A1)
END;

{ Add set range}
{ In    4(SP) = Destination
{       2(SP) = First element number
{       0(SP) = Last element number
{ Out   SP    = SP+4}
{       Set discriptor is keept on stack}
procedure XAZR(Frst,Last: SmallInt); Assembler; NoA6Frame; SysProc ISysSetAddN;
ASM     MOVE.L  (SP)+,A1
        MOVEM.W (SP)+,D0/D1             {Last/First}
        MOVE.L  (SP),A0                 {Keep on stack}
        SUB.B   D1,D0
        BCS     @9
        MOVEQ   #0,D2
        MOVE.B  D1,D2
        OR.B    #$F8,D1
        LSR.W   #3,D2
        ADD.W   D2,A0
@1:     BSET    D1,(A0)
        ADDQ.B  #1,D1
        BNE     @2
        ADDQ.L  #1,A0
        MOVEQ   #-8,D1
@2:     SUBQ.B  #1,D0
        BCC     @1
@9:     JMP     (A1)
END;

{ Load set}
{ In    8(SP) = A1 Source
{       4(SP) = A0 Destination
{       2(SP) = D1 Size in bytes
{       0(SP) = D0 Zero byte count}
procedure XLDZ(Src,Dst: Pointer; Size,Zero: SmallInt); Assembler; NoA6Frame; SysProc ISysSetLd;
ASM     MOVE.L  (SP)+,D2
        MOVEM.W (SP)+,D0/D1             //D0=Zero, D1=Size
        MOVEM.L (SP)+,A0/A1             //A0=Dst, A1=Src
        MOVE.L  D2,-(SP)                //Return address
        MOVEQ   #32,D2
        SUB.W   D0,D2
        SUB.W   D1,D2
        BRA     @2
@1:     CLR.B   (A0)+
@2:     DBRA    D0,@1
        BRA     @4
@3:     MOVE.B  (A1)+,(A0)+
@4:     DBRA    D1,@3
        BRA     @6
@5:     CLR.B   (A0)+
@6:     DBRA    D2,@5
END;

{ Store set}
{ In    8(SP) = A1 Source
{       4(SP) = A0 Destination
{       2(SP) = D1 Size in bytes
{       0(SP) = D0 Zero byte count
{ Out   SP    = SP+12}
procedure XSTZ(Src,Dst: Pointer; Size,Zero: SmallInt); Assembler; NoA6Frame; SysProc ISysSetSto;
ASM     MOVE.L  (SP)+,D2
        MOVEM.W (SP)+,D0/D1             {Zero/Size}
        MOVEM.L (SP)+,A0/A1             {Dst/Src}
        MOVE.L  D2,-(SP)                //Return address
        ADD.W   D0,A1
        BRA     @2
@1:     MOVE.B  (A1)+,(A0)+
@2:     DBRA    D1,@1
END;

{ Set inclusion test}
{ In    4(SP) = A1 Destination
{       0(SP) = D0 Element number
{ Out   SP    = SP+6}
{       CCR   = NE if included}
{       D0.B  = Boolean}
procedure XZIN(No: SmallInt; Dst: Pointer); Assembler; NoA6Frame; SysProc ISysSetIn;
ASM     MOVE.L  (SP)+,A0
        MOVE.W  (SP)+,D0
        MOVE.L  (SP)+,A1
        CMP.W   #256,D0
        BCS     @1
        MOVEQ   #0,D0
        BRA     @9
@1:     MOVE.W  D0,D1
        LSR.W   #3,D1
        BTST    D0,0(A1,D1.W)
        SNE     D0
        NEG.B   D0
@9:     JMP     (A0)
END;

{ Set equal test}
{ In    4(SP) = A1 Destination
{       0(SP) = A0 Source
{ Out   SP    = SP+8}
{       CCR.Z = Set if equal}
procedure XZEQ; Assembler; NoA6Frame; SysProc ISysSetEQ;
ASM     MOVEM.L (SP)+,D0/A0/A1
        MOVE.L  D0,-(SP)
        MOVEQ   #8-1,D0
@1:     CMPM.L  (A0)+,(A1)+             // PalmDebugger cannot disassemble this one!
        DBNE    D0,@1
END;

{ Set greater or equal test}
{ In    4(SP) = A1 Destination
{       0(SP) = A0 Source
{ Out   SP    = SP+8}
{       CCR.Z = Set if greater or equal}

procedure XZGE; Assembler; NoA6Frame; SysProc ISysSetGE;
ASM     MOVEM.L (SP)+,D0/A0/A1
        MOVE.L  D0,-(SP)
        MOVEQ   #8-1,D0
@1:     MOVE.L  (A0)+,D1
        OR.L    (A1),D1
        CMP.L   (A1)+,D1
        DBNE    D0,@1
END;

{ Set less or equal test}
{ In    4(SP) = A1 Destination
{       0(SP) = A0 Source
{ Out   SP    = SP+8}
{       CCR.Z = Set if less or equal}

procedure XZLE; Assembler; NoA6Frame; SysProc ISysSetLE;
ASM     MOVEM.L (SP)+,D0/A0/A1
        MOVE.L  D0,-(SP)
        MOVEQ   #8-1,D0
@1:     MOVE.L  (A1)+,D1
        OR.L    (A0),D1
        CMP.L   (A0)+,D1
        DBNE    D0,@1
END;

{ Set union}
{ In    4(SP) = A1 Destination
{       0(SP) = A0 Source
{ Out   SP    = SP+8}

procedure XZUN; Assembler; NoA6Frame; SysProc ISysSetUnion;
ASM     MOVEM.L (SP)+,D0/A0/A1
        MOVE.L  D0,-(SP)
        MOVEQ   #8-1,D0
@1:     MOVE.L  (A0)+,D1
        OR.L    D1,(A1)+
        DBRA    D0,@1
END;

{ Set difference}
{ In    4(SP) = A1 Destination
{       0(SP) = A0 Source
{ Out   SP    = SP+8}

procedure XZDI; Assembler; NoA6Frame; SysProc ISysSetDiff;
ASM     MOVEM.L (SP)+,D0/A0/A1
        MOVE.L  D0,-(SP)
        MOVEQ   #8-1,D0
@1:     MOVE.L  (A0)+,D1
        NOT.L   D1
        AND.L   D1,(A1)+
        DBRA    D0,@1
END;

{ Set intersection}
{ In    4(SP) = A1 Destination
{       0(SP) = A0 Source
{ Out   SP    = SP+8}

procedure XZIS; Assembler; NoA6Frame; SysProc ISysSetInter;
ASM     MOVEM.L (SP)+,D0/A0/A1
        MOVE.L  D0,-(SP)
        MOVEQ   #8-1,D0
@1:     MOVE.L  (A0)+,D1
        AND.L   D1,(A1)+
        DBRA    D0,@1
END;

{ *******************************************************}
{ *                                                     *}
{ *     BYTE ORIENTED ROUTINES                          *}
{ *                                                     *}
{ *******************************************************}

{ Move procedure}

procedure XMOV(Src,Dst: Pointer; Cnt: SmallInt); Assembler; NoA6Frame; SysProc PSysMove;
ASM     MOVE.L  (SP)+,A1                {RetAddr}
        MOVE.W  (SP)+,A0                {Cnt}
        MOVEM.L (SP)+,D0/D1             {Dst,Src}
        MOVEM.L D0/D1/A0/A1,-(SP)       {Dst,Src,Cnt,RetAddr}
        SysTrap MemMove                 {MemMove(Dst,Src,Cnt: Long)}
        ADD     #12,SP
        RTS
END;
(* Old Move
ASM     MOVE.L  (SP)+,D2
        MOVE.W  (SP)+,D0
        MOVEM.L (SP)+,A0/A1             {Dst,Src}
        MOVE.L  D2,-(SP)                //Return address
        CMP.L   A1,A0
        BCS     @2                      {1.12 CFN. Bug fix: Before @1!!!!!!!}
        ADD.W   D0,A0
        ADD.W   D0,A1
        BRA     @12
@11:    MOVE.B  -(A1),-(A0)             {Move memory up}
@12:    DBRA    D0,@11
        BRA     @99
@1:     MOVE.B  (A1)+,(A0)+             {Move memory downward}
@2:     DBRA    D0,@1
@99:
END;
(******************************************************************************)

{ FillChar procedure}
procedure XFLC(Dst: Pointer; Cnt: SmallInt; Val: Byte); Assembler; NoA6Frame; SysProc PSysFillChar;
ASM     MOVE.B  4+0(SP),-(SP)             {Val}
        MOVE.W  6+2(SP),-(SP)             {Cnt}
        CLR.W   -(SP)                     {Hi(Cnt)}
        MOVE.L  8+6(SP),-(SP)             {Dest}
        SysTrap MemSet
        ADD     #10,SP
END;
(*** Old
ASM     MOVE.L  (SP)+,A1
        MOVE.B  (SP)+,D0                {Val}
        MOVE.W  (SP)+,D1                {Cnt}
        MOVE.L  (SP)+,A0
        BRA     @2
@1:     MOVE.B  D0,(A0)+
@2:     DBRA    D1,@1
        JMP     (A1)
END;
(******************************************************************************)

{ *******************************************************}
{ *                                                     *}
{ *     POINTER AND HEAP ROUTINES                       *}
{ *                                                     *}
{ *******************************************************}

{GetMem(var P; Size: Longint)}

procedure XNEW(VAR Ptr: Pointer; Size: Longint); Assembler; NoA6Frame; SysProc PSysMemGet;
ASM     MOVE.L  4(SP),-(SP)
        SysTrap MemPtrNew               //P590
        MOVEM.L (SP)+,D0/D1/D2/A1       //D0=Junk, D1=Return address, D2=Size, A1=Ptr
        MOVE.L  A0,(A1)
        MOVE.L  D1,-(SP)
        CLR.W   -(SP)
        MOVE.L  D2,-(SP)
        MOVE.L  A0,-(SP)
        SysTrap MemSet
        ADD     #10,SP
END;

{ FreeMem(Ptr, Size);}

procedure XDIS(Ptr: Pointer; Size: Longint); Assembler; NoA6Frame; SysProc PSysMemFree;
ASM     MOVE.L  8(SP),A0                //Ptr
        MOVE.L  (A0),-(SP)
        SysTrap MemPtrFree              //P591
        MOVE.L  4(SP),A0
        ADD     #4+4+8,SP               //Garbage + return + Size + Ptr
        JMP     (A0)
END;

{ MemAvail function}

procedure XMEM; Assembler; NoA6Frame; SysProc FSysMemAvail;
ASM     MOVE.L  (SP),-(SP)              //Return
        CLR.L   -(SP)                   //Space for Max
        PEA     (SP)                    //Uses 2* Long!
        PEA     12(SP)                  //Free is returned
        CLR.W   -(SP)
        SysTrap MemHeapFreeBytes        //P583
        ADD     #10+4,SP
END;

{ MaxAvail function}

procedure XMAX; Assembler; NoA6Frame; SysProc FSysMemMaxAvail;
ASM     MOVE.L  (SP),-(SP)              //Return
        PEA     4(SP)                   //Max is returned
        CLR.L   -(SP)                   //Space for Free
        PEA     (SP)                    //Uses 2* Long!
        CLR.W   -(SP)
        SysTrap MemHeapFreeBytes        //P583
        ADD     #10+4,SP
END;

{ *******************************************************}
{ *                                                     *}
{ *     LongInt ROUTINES                                *}
{ *                                                     *}
{ *******************************************************}

{ Long multiply D0 by D1}
{ OUT D0}
procedure XMULI; Assembler; NoA6Frame;
ASM     MOVE.L  D3,-(SP)
        MOVE.L  D0,D2
        SWAP    D2
        MULU    D1,D2                   //H*L
        MOVE.L  D1,D3
        SWAP    D3
        MULU    D0,D3                   //L*H
        ADD.W   D3,D2
        SWAP    D2
        CLR.W   D2
        MULU    D1,D0                   //L*L
        ADD.L   D2,D0
        MOVE.L  (SP)+,D3
END;

procedure XMUL32; Assembler; NoA6Frame; SysProc ISys32Mul;
ASM     MOVEM.L 4(SP),D0/D1
        JSR     XMULI
        MOVE.L  (SP)+,(SP)
        MOVE.L  D0,4(SP)
END;

{ Long SmallInt square}

procedure XSQRI; Assembler; NoA6Frame; SysProc ISys32Sqr;
ASM     MOVE.L  4(SP),D0
        MOVE.L  D0,D1
        JSR     XMULI
        MOVE.L  D0,4(SP)
END;

{ Out D0=DIV result, D1=MOD result}
procedure XDIVMOD; Assembler; NoA6Frame;
ASM     MOVEM.L D3/D4,-(SP)
        MOVEQ   #0,D4
        TST.L   D0
        BPL     @1
        NEG.L   D0
        MOVEQ   #-1,D4
@1:     TST.L   D1
//      BEQ     @Div0
@Ok:    BPL     @2
        NEG.L   D1
        NOT.W   D4
@2:     MOVE.L  D1,D2
        SUB.L   D1,D1
        MOVEQ   #32,D3
@3:     ADDX.L  D1,D1
        SUB.L   D2,D1
        BCC     @4
        ADD.L   D2,D1
@4:     ADDX.L  D0,D0
        DBRA    D3,@3
        NOT.L   D0
        TST.W   D4
        BEQ     @5
        NEG.L   D0
@5:     SWAP    D4
        TST.W   D4
        BEQ     @6
        NEG.L   D1
@6:     MOVEM.L (SP)+,D3/D4
END;

{ Long divide D0 by D1}
procedure XDIVI; Assembler; NoA6Frame; SysProc ISys32Div;
ASM     MOVE.L  8(SP),D0
        MOVE.L  4(SP),D1
        JSR     XDIVMOD
        MOVE.L  (SP)+,(SP)
        MOVE.L  D0,4(SP)
END;

{ Long D0 modulo D1}
procedure XMODI; Assembler; NoA6Frame; SysProc ISys32Mod;
ASM     MOVE.L  8(SP),D0
        MOVE.L  4(SP),D1
        JSR     XDIVMOD
        MOVE.L  (SP)+,(SP)
        MOVE.L  D1,4(SP)
END;

{ *******************************************************}
{ *                                                     *}
{ *     Misc SmallInt                                   *}
{ *                                                     *}
{ *******************************************************}

procedure XABS32; Assembler; NoA6Frame; SysProc FSysAbs32;
ASM     TST.L   4(SP)
        BPL     @9
        NEG.L   4(SP)
@9:
END;
procedure XABS16; Assembler; NoA6Frame; SysProc FSysAbs16;
ASM     TST.W   4(SP)
        BPL     @9
        NEG.W   4(SP)
@9:
END;

{ *******************************************************}
{ *                                                     *}
{ *     RANDOM                                          *}
{ *                                                     *}
{ *******************************************************}

{ Get new random number.}
{ New := Old * 134775813 + 1}
{ Out   D0.L    Next random}

procedure NewRand; Assembler; NoA6Frame;
ASM     MOVE.L  #134775813,D0
        MOVE.L  RandSeed,D1
        JSR     XMULI
        ADDQ.L  #1,D0
        MOVE.L  D0,RandSeed
END;

{ Randomize}
procedure XRNDZ; Assembler; NoA6Frame; SysProc PSysRandomize;
ASM     SysTrap TimGetTicks             //Ticks since boot
        MOVE.L  D0,RandSeed             //Not ok yet. Better use clock etc
end;

{ Random(N: SmallInt): SmallInt;}
{ ALSO return random in D0.W for use in XRNDR!}
procedure XRNDI; Assembler; NoA6Frame; SysProc FSysRandomI;
ASM     JSR     NewRand
        CLR.W   D0
        MOVE.W  4(SP),D1
        BEQ     @1
        SWAP    D0
        DIVU    D1,D0
        SWAP    D0
@1:     MOVE.W  D0,4(SP)
END;

{ Random: Real;}
{ Returns 0<=random<1 in a Single (32 bit) value}

procedure XRNDR; Assembler; NoA6Frame; SysProc FSysRandomR;
ASM     JSR     NewRand                 {D0.L := NextRandom}
        MOVEQ   #31,D2
@1:     LSL.L   #1,D0
        DBCS    D2,@1
        BEQ     @8                      {Zero}
        ADD.W   #(127-1)-31,D2
        MOVE.B  D2,D0                   {Add Exponent to Single Value}
        ROR.L   #8,D0                   {Move into position (well allmost)}
        LSR.L   #1,D0                   {Sign:=0}
@8:     MOVE.L  (SP),-(SP)
        MOVE.L  D0,4(SP)
END;

{ *******************************************************}
{ *                                                     *}
{ *     ERROR ROUTINES                                  *}
{ *                                                     *}
{ *******************************************************}

procedure ChkSBrk; Assembler; NoA6Frame;
ASM
END;

procedure XSTK; Assembler; NoA6Frame; SysProc ISysOptStack;
ASM     MOVE.L  (SP)+,A0
        MOVE.L  (SP),LastPC             { Who called this procedure?}
        MOVE.L  (A0),A1                 { Read nnnn form "LINK #nnnn,A6"}
        LEA     -126(SP,A1.W),A1        { Stack Check(NN bytes)}
        CMP.L   LowStack,A1
        BLS     @Err
        JMP     ChkSBrk
@Err:   MOVE.W  #ErrStack,-(SP)
        MOVE.L  A0,-(SP)
        JMP     SysError
END;

{ Check range long}
procedure XCRL; Assembler; NoA6Frame; SysProc ISysOptRangeL;
ASM     MOVE.L  (SP)+,A0
        CMP.L   (A0)+,D0
        BLT     @1
        CMP.L   (A0)+,D0
        BGT     @1
        MOVE.L  A0,LastPC
        JMP     ChkSBrk
@1:     MOVE.W  #ErrRange,-(SP)
        MOVE.L  A0,-(SP)
        JMP     SysError
END;

{ Check range word}
procedure XCRW; Assembler; NoA6Frame; SysProc ISysOptRangeW;
ASM     MOVE.L  (SP)+,A0
        CMP.W   (A0)+,D0
        BLT     @1
        CMP.W   (A0)+,D0
        BGT     @1
        MOVE.L  A0,LastPC
        JMP     ChkSBrk
@1:     MOVE.W  #ErrRange,-(SP)
        MOVE.L  A0,-(SP)
        JMP     SysError
END;

{ *******************************************************}
{ *                                                     *}
{ *     VAL/STR ROUTINE                                 *}
{ *                                                     *}
{ *******************************************************}

procedure IntStr(I: Longint; W: SmallInt; var S: String; LenOfS: SmallInt); Assembler; SysProc ISysStringI;
VAR Buffer: Packed array[1..12] of Char;
ASM     MOVE.L  I,-(SP)
        PEA     Buffer
        SysTrap StrIToA                 //P647
        PEA     Buffer
        MOVE.L  S,-(SP)
        MOVE.W  W,-(SP)
        MOVE.W  LenOfS,-(SP)
        JSR     _PadNMoveStr            //_PadNMoveStr(Buffer,S,W,LenOfS);
END;

procedure StrInt(var S: String; VAR I, Pos: SmallInt); Assembler; SysProc PSysValI;
ASM     MOVE.L  S,-(SP)
        SysTrap StrAToI
        MOVE.L  I,A0
        MOVE.L  D0,(A0)
        MOVE.L  Pos,A0
        CLR.W   (A0)                    //Anything better?
END;

end.

