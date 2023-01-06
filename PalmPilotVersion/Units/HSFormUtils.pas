unit HSFormUtils;

interface

Function  S2Handle(Const S: String): MemHandle;
Procedure S2Field(FldID: UInt16; Const S: String);
Function  Field2S(FldID: UInt16): String;

implementation

Uses Field, Form, MemoryMgr;

Function S2Handle(Const S: String): MemHandle;
var
  NewH: MemHandle;
  NewP: ^String;
  Err:  Integer;
begin
  NewH := MemHandleNew(Length(S)+1);
  NewP := MemHandleLock(NewH);
  NewP^ := S;
  Err:=MemHandleUnlock(NewH);
  S2Handle := NewH;
end;

Procedure S2Field(FldID: UInt16; Const S: String);
var
  Fld: FieldPtr;
  OldH, NewH: MemHandle;
  Err: Integer;
  P: Pointer;
begin
  Fld := FrmGetObjectPtr(FrmGetActiveForm, FrmGetObjectIndex(FrmGetActiveForm, FldID) );
  OldH := FldGetTextHandle(Fld);
  NewH := S2Handle(S);
  FldSetTextHandle(Fld, NewH);
  if OldH<>NIL then Err := MemHandleFree(OldH);
  FldDrawField(Fld)
end;

Function  Field2S(FldID: UInt16): String;
var
  Fld: FieldPtr;
  H: MemHandle;
  Err: Integer;
  P: ^String;
begin
  Fld := FrmGetObjectPtr(FrmGetActiveForm, FrmGetObjectIndex(FrmGetActiveForm, FldID) );
  //Field2S := Fld^.Text; EXIT;
  H:=FldGetTextHandle(Fld);
  if H=NIL then Field2S:='' else begin
    P:=MemHandleLock(H);
    Field2S:=P^;
    Err:=MemHandleUnlock(H);
  end;
end;

end.

