/******************************************************************************
 *
 * Copyright (c) 1995-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: SerialMgr.h
 *
 * Description:
 *    Include file for Serial manager
 *
 * History:
 *    1/14/98     SerialMgr.h created by Ben Manuto
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit SerialMgr;

interface

Uses {$ifdef PalmVer35} Traps33, {$endif}
     ErrorBase;

// New Serial manager feature number
Const
  sysFtrNewSerialPresent     =1;

/********************************************************************
 * Serial Manager Errors
 * the constant serErrorClass is defined in SystemMgr.h
 ********************************************************************/

  serErrBadParam          =serErrorClass | 1;
  serErrBadPort           =serErrorClass | 2;
  serErrNoMem             =serErrorClass | 3;
  serErrBadConnID         =serErrorClass | 4;
  serErrTimeOut           =serErrorClass | 5;
  serErrLineErr           =serErrorClass | 6;
  serErrAlreadyOpen       =serErrorClass | 7;
  serErrStillOpen         =serErrorClass | 8;
  serErrNotOpen           =serErrorClass | 9;
  serErrNotSupported      =serErrorClass | 10;    // functionality not supported
  serErrNoDevicesAvail    =serErrorClass | 11;    // No serial devices were loaded or are available.


//
// mask values for the lineErrors  from SerGetStatus
//

  serLineErrorParity      =0x0001;         // parity error
  serLineErrorHWOverrun   =0x0002;         // HW overrun
  serLineErrorFraming     =0x0004;         // framing error
  serLineErrorBreak       =0x0008;         // break signal asserted
  serLineErrorHShake      =0x0010;         // line hand-shake error
  serLineErrorSWOverrun   =0x0020;         // HW overrun
  serLineErrorCarrierLost =0x0040;         // CD dropped


/********************************************************************
 * Serial Port Definitions
 ********************************************************************/

  serPortLocalHotSync   =0x8000;      // Use physical HotSync port

  serPortCradlePort     =0x8000;      // Use the RS-232 cradle port.
  serPortIrPort         =0x8001;      // Use available IR port.
      

// This constant is used by the Serial Link Mgr only
  serPortIDMask         =0xC000;


/********************************************************************
 * Serial Settings Descriptor
 ********************************************************************/
   
  srmSettingsFlagStopBitsM         =0x00000001;     // mask for stop bits field
  srmSettingsFlagStopBits1         =0x00000000;     //  1 stop bits   
  srmSettingsFlagStopBits2         =0x00000001;     //  2 stop bits   
  srmSettingsFlagParityOnM         =0x00000002;     // mask for parity on
  srmSettingsFlagParityEvenM       =0x00000004;     // mask for parity even
  srmSettingsFlagXonXoffM          =0x00000008;     // (NOT IMPLEMENTED) mask for Xon/Xoff flow control
  srmSettingsFlagRTSAutoM          =0x00000010;     // mask for RTS rcv flow control
  srmSettingsFlagCTSAutoM          =0x00000020;     // mask for CTS xmit flow control
  srmSettingsFlagBitsPerCharM      =0x000000C0;     // mask for bits/char
  srmSettingsFlagBitsPerChar5      =0x00000000;     //  5 bits/char   
  srmSettingsFlagBitsPerChar6      =0x00000040;     //  6 bits/char   
  srmSettingsFlagBitsPerChar7      =0x00000080;     //  7 bits/char   
  srmSettingsFlagBitsPerChar8      =0x000000C0;     //  8 bits/char
  srmSettingsFlagFlowControl       =0x00000100;     // mask for enabling/disabling special flow control feature
                                                            //  for the software receive buffer.   


// Default settings
  srmDefaultSettings = srmSettingsFlagBitsPerChar8 |
                       srmSettingsFlagStopBits1    |
                       srmSettingsFlagRTSAutoM;

  //Macro: NONO srmDefaultCTSTimeout    =5*sysTicksPerSecond;


// Status bitfield constants

  srmStatusCtsOn           =0x00000001;
  srmStatusRtsOn           =0x00000002;
  srmStatusDsrOn           =0x00000004;
  srmStatusBreakSigOn      =0x00000008;


//
// Info fields describing serial HW capabilities.
//

  serDevCradlePort         =0x00000001;     // Serial HW controls RS-232 serial from cradle connector of Pilot.
  serDevRS232Serial        =0x00000002;     // Serial HW has RS-232 line drivers
  serDevIRDACapable        =0x00000004;     // Serial Device has IR line drivers and generates IRDA mode serial.
  serDevModemPort          =0x00000008;     // Serial deivce drives modem connection.
  serDevCncMgrVisible      =0x00000010;     // Serial device port name string to be displayed in Connection Mgr panel.


Type
  DeviceInfoPtr = ^DeviceInfoType;
  DeviceInfoType = Record
    serDevCreator: UInt32;                        // Four Character creator type for serial driver ('sdrv')
    serDevFtrInfo: UInt32;                        // Flags defining features of this serial hardware.
    serDevMaxBaudRate: UInt32;                    // Maximum baud rate for this device.
    serDevHandshakeBaud: UInt32;                  // HW Handshaking is reccomended for baud rates over this
    serDevPortInfoStr: pChar;                      // Description of serial HW device or virtual device.
    reserved: Array[0..7] of UInt8;               // Reserved.
  end;


/********************************************************************
 * Type of a wakeup handler procedure which can be installed through the
 *   SerSetWakeupHandler() call.
 ********************************************************************/
// void (*WakeupHandlerProcPtr)(UInt32 refCon);
//  WakeupHandlerProcPtr: Procedure(refCon: UInt32);
  WakeupHandlerProcPtr = Pointer;

/********************************************************************
 * Type of an emulator-mode only blocking hook routine installed via
 * SerControl function serCtlEmuSetBlockingHook.  This is supported only
 * under emulation mode.  The argument to the function is the value
 * specified in the SerCallbackEntryType structure.  The intention of the
 * return value is to return false if serial manager should abort the
 * current blocking action, such as when an app quit event has been received;
 * otherwise, it should return true.  However, in the current implementation,
 * this return value is ignored.  The callback can additionally process
 * events to enable user interaction with the UI, such as interacting with the
 * debugger.
 ********************************************************************/
// Boolean (*BlockingHookProcPtr)  (UInt32 userRef);
//  BlockingHookProcPtr: Function(userRef: UInt32): Boolean;
  BlockingHookProcPtr = Pointer;

/********************************************************************
 * Serial Library Control Enumerations (Pilot 2.0)
 ********************************************************************/

/********************************************************************
 * Structure for specifying callback routines.
 ********************************************************************/
  SrmCallbackEntryPtr = ^SrmCallbackEntryType;
  SrmCallbackEntryType = Record
    funcP: BlockingHookProcPtr;                // function pointer
    userRef: UInt32;                           // ref value to pass to callback
  end;


  SrmCtlEnum = (
    srmCtlFirstReserved = 0,      // RESERVE 0

    srmCtlSetBaudRate,            // Sets the current baud rate for the HW.
                                  // valueP = MemPtr to Int32, valueLenP = MemPtr to sizeof(Int32)
                                 
    srmCtlGetBaudRate,            // Gets the current baud rate for the HW.
                                 
    srmCtlSetFlags,               // Sets the current flag settings for the serial HW.

    srmCtlGetFlags,               // Gets the current flag settings the serial HW.
   
    srmCtlSetCtsTimeout,          // Sets the current Cts timeout value.
   
    srmCtlGetCtsTimeout,          // Gets the current Cts timeout value.
   
    srmCtlStartBreak,             // turn RS232 break signal on:
                                  // users are responsible for ensuring that the break is set
                                  // long enough to genearate a valid BREAK!
                                  // valueP = 0, valueLenP = 0
                                 
    srmCtlStopBreak,              // turn RS232 break signal off:
                                  // valueP = 0, valueLenP = 0

    srmCtlStartLocalLoopback,     // Start local loopback test
                                  // valueP = 0, valueLenP = 0
                                 
    srmCtlStopLocalLoopback,      // Stop local loopback test
                                  // valueP = 0, valueLenP = 0


    srmCtlIrDAEnable,             // Enable  IrDA connection on this serial port
                                  // valueP = 0, valueLenP = 0

    srmCtlIrDADisable,            // Disable  IrDA connection on this serial port
                                  // valueP = 0, valueLenP = 0

    srmCtlRxEnable,               // enable receiver  ( for IrDA )

    srmCtlRxDisable,              // disable receiver ( for IrDA )

    srmCtlEmuSetBlockingHook,     // Set a blocking hook routine FOR EMULATION
                                  // MODE ONLY - NOT SUPPORTED ON THE PILOT
                                  //PASS:
                                  // valueP = MemPtr to SerCallbackEntryType
                                  // *valueLenP = sizeof(SerCallbackEntryType)
                                  //RETURNS:
                                  // the old settings in the first argument                            

    srmCtlUserDef,                // Specifying this opCode passes through a user-defined
                                  //  function to the DrvControl function. This is for use
                                  //  specifically by serial driver developers who need info
                                  //  from the serial driver that may not be available through the
                                  //  standard SrmMgr interface.
                                 
    srmCtlGetOptimalTransmitSize, // This function will ask the port for the most efficient buffer size
                                  // for transmitting data packets.  This opCode returns serErrNotSupported
                                  // if the physical or virtual device does not support this feature.
                                  // The device can return a transmit size of 0, if send buffering is
                                  // requested, but the actual size is up to the caller to choose.
                                  // valueP = MemPtr to UInt32 --> return optimal buf size
                                  // ValueLenP = sizeof(UInt32)

    srmCtlSetDTRAsserted,         // Enable or disable DTR.

    srmCtlGetDTRAsserted,         // Determine if DTR is enabled or disabled.

    srmCtlLAST,                   // ***** ADD NEW ENTRIES BEFORE THIS ONE
    srmNoCtlJustForce16Bits=999   // HSPascal special to force parameters to be 16 bits (SrmControl)
  );


/********************************************************************
 * Serial Hardware Library Routines
 ********************************************************************/

// *****************************************************************
// * New Serial Manager trap selectors
// *****************************************************************

  sysSerialSelector = ( // The order of this enum *MUST* match the sysSerialSelector in SerialMgr.c
   sysSerialInstall = 0,
   sysSerialOpen,
   sysSerialOpenBkgnd,
   sysSerialClose,
   sysSerialSleep,
   sysSerialWake,
   sysSerialGetDeviceCount,
   sysSerialGetDeviceInfo,
   sysSerialGetStatus,
   sysSerialClearErr,
   sysSerialControl,
   sysSerialSend,
   sysSerialSendWait,
   sysSerialSendCheck,
   sysSerialSendFlush,
   sysSerialReceive,
   sysSerialReceiveWait,
   sysSerialReceiveCheck,
   sysSerialReceiveFlush,
   sysSerialSetRcvBuffer,
   sysSerialRcvWindowOpen,
   sysSerialRcvWindowClose,
   sysSerialSetWakeupHandler,
   sysSerialPrimeWakeupHandler,

   maxSerialSelector = sysSerialPrimeWakeupHandler    // Used by SerialMgrDispatch.c
  );


{$ifdef PalmVer35}
Function SerialMgrInstall: Err; //System called only
   SYS_TRAP(sysTrapSerialDispatch,sysSerialInstall);

Function SrmOpen(port, baud: UInt32; var newPortIdP: UInt16): Err;
   SYS_TRAP(sysTrapSerialDispatch,sysSerialOpen);

Function SrmOpenBackground(port, baud: UInt32; var newPortIdP: UInt16): Err;
   SYS_TRAP(sysTrapSerialDispatch,sysSerialOpenBkgnd);

Function SrmClose(portId: UInt16): Err;
   SYS_TRAP(sysTrapSerialDispatch,sysSerialClose);

Function SrmSleep: Err;
   SYS_TRAP(sysTrapSerialDispatch,sysSerialSleep);

Function SrmWake: Err;
   SYS_TRAP(sysTrapSerialDispatch,sysSerialWake);

Function SrmGetDeviceCount(var numOfDevicesP: UInt16): Err;
   SYS_TRAP(sysTrapSerialDispatch,sysSerialGetDeviceCount);

Function SrmGetDeviceInfo(deviceID: UInt32; var deviceInfoP: DeviceInfoType): Err;
   SYS_TRAP(sysTrapSerialDispatch,sysSerialGetDeviceInfo);

Function SrmGetStatus(portId: UInt16; var statusFieldP: UInt32; var lineErrsP: UInt16): Err;
   SYS_TRAP(sysTrapSerialDispatch,sysSerialGetStatus);

Function SrmClearErr(portId: UInt16): Err;
   SYS_TRAP(sysTrapSerialDispatch,sysSerialClearErr);

//Note: Use ord(srmCtlSetBaudRate) instead of srmCtlSetBaudRate
Function SrmControl(portId: UInt16; op: SrmCtlEnum; valueP: Pointer; var valueLenP: UInt16): Err;
   SYS_TRAP(sysTrapSerialDispatch,sysSerialControl);

Function SrmSend(portId: UInt16; bufP: Pointer; count: UInt32; var errP: Err): UInt32;
   SYS_TRAP(sysTrapSerialDispatch,sysSerialSend);

Function SrmSendWait(portId: UInt16): Err;
   SYS_TRAP(sysTrapSerialDispatch,sysSerialSendWait);

Function SrmSendCheck(portId: UInt16; var numBytesP: UInt32): Err;
   SYS_TRAP(sysTrapSerialDispatch,sysSerialSendCheck);

Function SrmSendFlush(portId: UInt16): Err;
   SYS_TRAP(sysTrapSerialDispatch,sysSerialSendFlush);

Function SrmReceive(portId: UInt16; rcvBufP: Pointer; count: UInt32; timeout: Int32; var errP: Err): UInt32;
   SYS_TRAP(sysTrapSerialDispatch,sysSerialReceive);

Function SrmReceiveWait(portId: UInt16; bytes: UInt32; timeout: Int32): Err;
   SYS_TRAP(sysTrapSerialDispatch,sysSerialReceiveWait);

Function SrmReceiveCheck(portId: UInt16; var numBytesP: UInt32): Err;
   SYS_TRAP(sysTrapSerialDispatch,sysSerialReceiveCheck);

Function SrmReceiveFlush(portId: UInt16; timeout: Int32): Err;
   SYS_TRAP(sysTrapSerialDispatch,sysSerialReceiveFlush);

Function SrmSetReceiveBuffer(portId: UInt16; bufP: Pointer; bufSize: UInt16): Err;
   SYS_TRAP(sysTrapSerialDispatch,sysSerialSetRcvBuffer);

Function SrmReceiveWindowOpen(portId: UInt16; var bufPP: Pointer; var sizeP: UInt32): Err;
   SYS_TRAP(sysTrapSerialDispatch,sysSerialRcvWindowOpen);

Function SrmReceiveWindowClose(portId: UInt16; bytesPulled: UInt32): Err;
   SYS_TRAP(sysTrapSerialDispatch,sysSerialRcvWindowClose);

Function SrmSetWakeupHandler(portId: UInt16; procP: WakeupHandlerProcPtr; refCon: UInt32): Err;
   SYS_TRAP(sysTrapSerialDispatch,sysSerialSetWakeupHandler);

Function SrmPrimeWakeupHandler(portId: UInt16; minBytes: UInt16): Err;
   SYS_TRAP(sysTrapSerialDispatch,sysSerialPrimeWakeupHandler);

//Procedure SrmSelectorErrPrv(serialSelector: UInt16); // used only by SerialMgrDispatch.c

{$endif}

implementation

end.

