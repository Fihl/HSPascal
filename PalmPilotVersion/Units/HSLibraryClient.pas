Unit HSLibraryClient;

interface

Function OpenLibrary(var refNumP: UInt16; Const LibName,LibName4: String): Err;
Function CloseLibrary(refNum: UInt16): Err;

//Function SysLibOpen(refNum: UInt16): Err; SYS_TRAP(sysLibTrapOpen);
//Function SysLibClose(refNum: UInt16): Err; SYS_TRAP(sysLibTrapClose);
//Function SysLibWake(refNum: UInt16): Err;  SYS_TRAP(sysLibTrapWake);

implementation

Uses SystemMgr, ErrorBase, HSUtils;

Function OpenLibrary(var refNumP: UInt16; Const LibName,LibName4: String): Err;
var
  Error,rc: Err;
  ifErrs: UInt16;
  Loaded: Boolean;
begin
  Loaded:=False;
  Error := SysLibFind(LibName, refNumP);    // First try to find the library
  if Error = sysErrLibNotFound then begin   // If not found, load the library instead
    Error := SysLibLoad(S2U32('libr'), S2U32(LibName4), refNumP);
    Loaded := True;
  end;
  if Error = errNone then begin
    Error := SysLibOpen(refNumP);
    if Error <> errNone then begin
      if Loaded then
        rc:=SysLibRemove(refNumP);
      refNumP := sysInvalidRefNum;
    end;
  end;
  OpenLibrary:=Error;
end;

Function CloseLibrary(refNum: UInt16): Err;
var Error, rc: Err;
begin
  if refNum = sysInvalidRefNum then begin
    CloseLibrary:=sysErrParamErr;
    EXIT;
  end;
  Error := SysLibClose(refNum);
  if Error = errNone then
    rc:=SysLibRemove(refNum) // no users left, so unload library
  else
    if Error = (appErrorClass | 3) then
      Error := errNone; // don't unload library, but mask "still open" from caller
end;

end.
