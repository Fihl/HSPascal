unit HSSerialOld;

interface

Uses
  SysEvent, MemoryMgr, SystemMgr, SerialMgrOld;

Type
  THSSerialH = Record
    ID: Integer; //User data
    Error: Err;
    Open: Boolean;
    OverRun: Boolean;
    BreakOnSysEventAvail: Boolean;  //Set to False to disable
    FlushOnOverrun: Boolean;        //Set to False to disable
    gSerialRefNum: UInt16;
    Baud: Int32;
    Buffer: Pointer;
  end;

  THSSerialHOld = THSSerialH; //Just another name, if needed in main program
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
  ser8Plain  = serSettingsFlagBitsPerChar8 | serSettingsFlagStopBits1;
  ser8Flow =   serSettingsFlagBitsPerChar8 | serSettingsFlagStopBits1 |
               serSettingsFlagFlowControl | serSettingsFlagRTSAutoM |
               serSettingsFlagCTSAutoM;
  serErrAlreadyOpen = serErrAlreadyOpen;

implementation

Function  HSSerCreate(var H: THSSerialH): Boolean;
begin
  FillChar(H,SizeOf(H),0);
  HSSerCreate:= SysLibFind('Serial Library', H.gSerialRefNum)=0;
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

    Error := SerOpen(gSerialRefNum, Port, Baud);
    if Error=serErrAlreadyOpen then
      rc:=SerClose(gSerialRefNum);

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
    rc:=SerSetReceiveBuffer(gSerialRefNum, NIL, 0);
    rc:=MemPtrFree(Buffer);
    Buffer:=NIL;
  end;
end;

procedure HSSerClose(var H: THSSerialH);
var rc: Err;
begin
  with H do begin
    ClearBuffer(H);
    if gSerialRefNum<>0 then
      rc:=SerClose(gSerialRefNum);
  end;
  FillChar(H,SizeOf(H),0);
end;

Procedure HSSerSetPortParams(var H: THSSerialH; BufSize, NewBaud, PortParms: Int32);
var
  SerSettings: SerSettingsType;
begin
  with H do begin
    if BufSize>512 then begin
      ClearBuffer(H);
      Inc(BufSize,32); //Additional for overhead (Palm spec)
      Buffer:=MemPtrNew(BufSize);
      Error := SerSetReceiveBuffer(gSerialRefNum, Buffer, BufSize);
    end;
    if Baud<>0 then Baud:=NewBaud;
    SerSettings.baudRate:=Baud;
    SerSettings.flags:=PortParms; //serDefaultSettings; //serSettingsFlagBitsPerChar8
    SerSettings.ctsTimeout:=0;
    if PortParms<>0 then Error:=SerSetSettings(gSerialRefNum,@SerSettings);
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
begin
  with H do begin
    S:='';
    if BreakOnSysEventAvail then B:=SysEventAvail else B:=False;
    if not B then begin
      if MaxCount>SizeOf(S)-1 then MaxCount:=SizeOf(S)-1;
      Error := SerReceiveWait(gSerialRefNum, MaxCount, MaxWait);

      if (Error=0) or (Error=serErrTimeOut) then begin //Else error of some kind
        Error := SerReceiveCheck(gSerialRefNum, numBytesPending);
        N:=numBytesPending;
        if N>0 then begin
          if N>MaxCount then N:=MaxCount;
          N := SerReceive(gSerialRefNum, @S[1], N, 0, Error);
          S[N+1]:=#0;
        end;
      end;

      if Error=serErrLineErr then begin
        OverRun:=True;
        N:=SerClearErr(gSerialRefNum);              // Clear the error
        if FlushOnOverrun then begin
          SerReceiveFlush(gSerialRefNum, MaxWait);  // AND Flush
          S:='';
        end;
      end;
    end;
  end;
  HSSerRx:=S;
end;

Procedure HSSerTx(var H: THSSerialH; Const S: String);
var rc: Err;
begin
  with H do
    rc:=SerSend(gSerialRefNum, @S, Length(S), Error);
end;

end.
