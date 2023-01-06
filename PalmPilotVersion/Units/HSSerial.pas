unit HSSerial;

interface

{$define PalmVer35}
{$setdefault}

Uses
  HSUtils,
  SysEvent, MemoryMgr, SystemMgr, SystemResources, FeatureMgr,
  SerialMgr;

Type
  THSSerialH = Record
    ID: Integer; //User data
    Error: Err;
    Open: Boolean;
    UseNewSer: Boolean;
    OverRun: Boolean;
    BreakOnSysEventAvail: Boolean;  //Set to False to disable
    FlushOnOverrun: Boolean;        //Set to False to disable
    PortId: UInt16;
    Baud: Int32;
    Buffer: Pointer;
  end;
  THSSerialHNew = THSSerialH; //Just another name, if needed in main program
                              //When using both old and new Serial

Function  HSSerCreate(var H: THSSerialH): Boolean;
Procedure HSSerDestroy(var H: THSSerialH);
function  HSSerOpen(var H: THSSerialH; Port, InitBaud: Int32): Boolean;
procedure HSSerClose(var H: THSSerialH);
Procedure HSSerSetPortParams(var H: THSSerialH; BufSize, NewBaud, PortParms: Int32);
Function  HSSerRx(var H: THSSerialH; MaxCount, MaxWait: Integer): String;
Procedure HSSerTx(var H: THSSerialH; Const S: String);

Function  HSSerPortOpen(var H: THSSerialH): Boolean;
Function  HSSerPortError(var H: THSSerialH): Err;
Function  HSSerPortOverrun(var H: THSSerialH): Boolean;

Const //HSSerSetPortParams(portParams)
  ser8Plain  = srmSettingsFlagBitsPerChar8 | srmSettingsFlagStopBits1;
  ser8Flow =   srmSettingsFlagBitsPerChar8 | srmSettingsFlagStopBits1 |
               srmSettingsFlagFlowControl | srmSettingsFlagRTSAutoM |
               srmSettingsFlagCTSAutoM;
  serErrAlreadyOpen = serErrAlreadyOpen;

  serPortCradlePort   = serPortCradlePort;
  serPortLocalHotSync = serPortLocalHotSync;

implementation

Function  HSSerCreate(var H: THSSerialH): Boolean;
var Value: UInt32;
begin
  HSSerCreate:= False;
  FillChar(H,SizeOf(H),0);
  H.UseNewSer:=True;
  if 0=FtrGet(S2U32(sysFileCSerialMgr), sysFtrNewSerialPresent, Value) then
    HSSerCreate:= Value<>0;
end;

Procedure HSSerDestroy(var H: THSSerialH);
begin
  HSSerClose(H);
end;

function  HSSerOpen(var H: THSSerialH; Port, InitBaud: Int32): Boolean;
var rc: Err;
begin
  with H do begin
    HSSerOpen:=False;
    if InitBaud=0 then InitBaud:=9600; //
    Baud:=InitBaud;

    Error:=SrmOpen(Port, InitBaud, PortId);
    if Error=serErrAlreadyOpen then
      rc:=SrmClose(PortId);

    Open:=Error=0;
    HSSerOpen:=Open;
    BreakOnSysEventAvail:=True;
    FlushOnOverrun:=True;
  end;
end;

Procedure ClearBuffer(var H: THSSerialH);
var rc: Err;
begin
  with H do if Buffer<>NIL then begin
    rc:=SrmSetReceiveBuffer(PortId, NIL, 0);
    rc:=MemPtrFree(Buffer);
    Buffer:=NIL;
  end;
end;

procedure HSSerClose(var H: THSSerialH);
var rc: Err;
begin
  with H do begin
    ClearBuffer(H);
    if PortId<>0 then
      rc:=SrmClose(PortId);
  end;
  FillChar(H,SizeOf(H),0);
end;

Procedure HSSerSetPortParams(var H: THSSerialH; BufSize, NewBaud, PortParms: Int32);
var
  Data4: UInt32; Size2: UInt16;
begin
  with H do begin
    if BufSize>512 then begin
      ClearBuffer(H);
      Inc(BufSize,32); //Additional for overhead (Palm spec)
      Buffer:=MemPtrNew(BufSize);
      Error := SrmSetReceiveBuffer(PortId, Buffer, BufSize);
    end;
    if Baud<>0 then Baud:=NewBaud;
    Size2:=SizeOf(Int32);
    Error:=SrmControl(PortId, srmCtlSetBaudRate,  @Baud, Size2);
    Data4:=SysTicksPerSecond;
    //asm trap #8 end;
    if PortParms<>0 then begin
      //Error:=SrmControl(PortId, srmCtlSetCtsTimeout,@Data4, Size2);
      Error:=SrmControl(PortId, srmCtlSetFlags,     @PortParms, Size2);
    end;
  end;
end;

//******************************************************************************
Function  HSSerPortOpen(var H: THSSerialH): Boolean;
begin
  HSSerPortOpen:= H.Open
end;
Function  HSSerPortOverrun(var H: THSSerialH): Boolean;
begin
  HSSerPortOverrun:= H.OverRun; H.OverRun:=False;
end;
Function  HSSerPortError(var H: THSSerialH): Err;
begin
  HSSerPortError:= H.Error; H.Error:=0;
end;
//******************************************************************************

Function  HSSerRx(var H: THSSerialH; MaxCount, MaxWait: Integer): String;
var
  S: String;
  N: Integer;
  numBytesPending: UInt32;
  B: Boolean;

  procedure HandleRxError(var H: THSSerialH; ErrorCode: Err);
  var N,lineErrsP: UInt16; statusFieldP: UInt32;
  begin
    with H do begin
      Error:=ErrorCode;
      if ErrorCode=serErrLineErr then begin
         //asm trap #8 end;
         //N:=SrmGetStatus(PortId,statusFieldP,lineErrsP);
         OverRun:=True;
         N:=SrmClearErr(PortId);                 // Clear the error
         if FlushOnOverrun then begin
           N:=SrmReceiveFlush(PortId, MaxWait);  // AND Flush
           S:='';
         end;
         Error:=0;
       end;
    end;
  end;
begin
  with H do begin
    S:='';
    if BreakOnSysEventAvail then B:=SysEventAvail else B:=False;
    if not B then begin
      if MaxCount>SizeOf(S)-1 then MaxCount:=SizeOf(S)-1;
      HandleRxError(H,SrmReceiveWait(PortId, MaxCount, MaxWait));

      if (Error=0) or (Error=serErrTimeOut) then begin //Else error of some kind
        HandleRxError(H,SrmReceiveCheck(PortId, numBytesPending));
        N:=numBytesPending;
        if N>0 then begin
          if N>MaxCount then N:=MaxCount;
          N := SrmReceive(PortId, @S[1], N, 0, Error);
          if N>0 then S[N+1]:=#0 else S:='';
          HandleRxError(H,Error);
        end;
      end;

      HandleRxError(H,Error);
    end;
  end;
  HSSerRx:=S;
end;

Procedure HSSerTx(var H: THSSerialH; Const S: String);
var rc: Err;
begin
  with H do
    rc:=SrmSend(PortId, @S, Length(S), Error);
end;

end.
