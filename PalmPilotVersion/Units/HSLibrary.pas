Unit HSLibrary;

Interface

Uses
  SystemMgr, MemoryMgr, ErrorMgr;

Procedure InitLibPointers50(RefNum: Integer; Const LibName: String);
Procedure InstallLib(RefNum,SlotNo: Integer; Proc: Pointer);

Procedure InitGlobalMem(RefNum,Size: Integer);
Procedure FreeGlobalMem(RefNum: Integer);

Function  GetGlobalMemPtr(RefNum: Integer): Pointer;

Implementation

Const
  MaxJmps = 50;
Type
  JmpRange = -5..MaxJmps; //Name,Open(-4),Close(-3),Sleep(-2),Wake(-1), User+0, User+1,
  Jmp32Bit=Record OP1: Integer; Abs32: Longint; OP2: Integer end;
  PJmpTable = ^TJmpTable;
  TJmpTable = Record
    Offset: Array[JmpRange] of Integer;
    Name:   String;
    Jmps:   Array[JmpRange] of Jmp32Bit;
  end;

Procedure InitLibPointers50(RefNum: Integer; Const LibName: String);
var P: PJmpTable; N: Integer; L: SysLibTblEntryPtr;
begin
  GetMem(P,SizeOf(TJmpTable));
  N:=MemPtrSetOwner(P,0);
  L:=SysLibTblEntry(RefNum);
  L^.dispatchTblP:=MemHandle(P);
  with P^ do begin
    Name:=LibName;
    Offset[-5]:=Longint(@Name)-Longint(P);
    for N:=-4 to MaxJmps do begin
      Offset[N]:=Longint(@Jmps[N])-Longint(P);
      InstallLib(RefNum,N,NIL);
    end;
  end;
end;

Procedure InstallLib(RefNum,SlotNo: Integer; Proc: Pointer);
var L: SysLibTblEntryPtr; P: PJmpTable;
begin
  ASM   TST.L   Proc
        BNZ     @9
        BSR     @2
        MOVEQ   #0,D0                   //Dummy procedure, now in "Proc"
        RTS
  @2:   MOVE.L  (SP)+,Proc
  @9:
  END;
  L:=SysLibTblEntry(RefNum);
  ErrDisplayFileLineMsgIf(L=NIL,$$FileName,$$FilelineNo,'1 SysLibTblEntry=NIL');  //$$FilelineNo an integer!!!
  P:=Pointer(L^.dispatchTblP);
  ErrDisplayFileLineMsgIf(P=NIL,$$FileName,$$FilelineNo,'1 dispatchTblP=NIL');
  //// with P^.Jmps[SlotNo] do begin    // BUG, locate later
    P^.Jmps[SlotNo].  OP1:=$2F3C; //Move.l #$xxxxxxxx,-(sp)
    P^.Jmps[SlotNo].  Abs32:=Longint(Proc);
    P^.Jmps[SlotNo].  OP2:=$4E75; //rts
  //// end;
end;

Procedure InitGlobalMem(RefNum,Size: Integer);
var L: SysLibTblEntryPtr;
begin
  L:=SysLibTblEntry(RefNum);
  ErrDisplayFileLineMsgIf(L=NIL,$$FileName,$$FilelineNo,'2 SysLibTblEntry=NIL');
  GetMem(L^.GlobalsP,Size);
end;

Procedure FreeGlobalMem(RefNum: Integer);
var L: SysLibTblEntryPtr;
begin
  L:=SysLibTblEntry(RefNum);
  ErrDisplayFileLineMsgIf(L=NIL,$$FileName,$$FilelineNo,'3 SysLibTblEntry=NIL');
  FreeMem(L^.GlobalsP,0{Unused}); L^.GlobalsP:=NIL;
end;

Function  GetGlobalMemPtr(RefNum: Integer): Pointer;
var L: SysLibTblEntryPtr;
begin
  L:=SysLibTblEntry(RefNum);
  ErrDisplayFileLineMsgIf(L=NIL,$$FileName,$$FilelineNo,'3 SysLibTblEntry=NIL');
  ErrDisplayFileLineMsgIf(L^.GlobalsP=NIL,$$FileName,$$FilelineNo,'4 GlobalsP=NIL');
  GetGlobalMemPtr:=L^.GlobalsP;
end;

end.
