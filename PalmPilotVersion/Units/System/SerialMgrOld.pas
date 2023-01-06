/******************************************************************************
 *
 * Copyright (c) 1995-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: SerialMgrOld.h
 *
 * Description:
 *    Include file for Serial manager
 *
 * History:
 *    2/7/95 Created by Ron Marianetti
 *    7/6/95   vmk   added serDefaultSettings
 *    1/28/98  scl   added Serial Port Definitions
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit SerialMgrOld;

interface

uses ErrorBase, SystemMgr;


/********************************************************************
 * Serial Manager Errors
 * the constant serErrorClass is defined in SystemMgr.h
 ********************************************************************/
Const
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


/********************************************************************
 * Serial Port Definitions
 ********************************************************************/

  serPortDefault          =0x0000;   // Use prefDefSerialPlugIn
  serPortLocalHotSync     =0x8000;   // Use physical HotSync port
  serPortMaskLocal        =0x7FFF;   // Mask off HotSync "hint" (for SerialMgr)


/********************************************************************
 * Serial Settings Descriptor
 ********************************************************************/

Type
  SerSettingsPtr = ^SerSettingsType;
  SerSettingsType = Record
    baudRate: UInt32;               // baud rate
    flags: UInt32;                  // miscellaneous settings
    ctsTimeout: Int32;              // max # of ticks to wait for CTS to become asserted
                                  // before transmitting; used only when
                                  // configured with serSettingsFlagCTSAutoM.
  end;

Const
  serSettingsFlagStopBitsM         =0x00000001; // mask for stop bits field
  serSettingsFlagStopBits1         =0x00000000; //  1 stop bits
  serSettingsFlagStopBits2         =0x00000001; //  2 stop bits
  serSettingsFlagParityOnM         =0x00000002; // mask for parity on
  serSettingsFlagParityEvenM       =0x00000004; // mask for parity even
  serSettingsFlagXonXoffM          =0x00000008; // (NOT IMPLEMENTED) mask for Xon/Xoff flow control
  serSettingsFlagRTSAutoM          =0x00000010; // mask for RTS rcv flow control
  serSettingsFlagCTSAutoM          =0x00000020; // mask for CTS xmit flow control
  serSettingsFlagBitsPerCharM      =0x000000C0; // mask for bits/char
  serSettingsFlagBitsPerChar5      =0x00000000; //  5 bits/char   
  serSettingsFlagBitsPerChar6      =0x00000040; //  6 bits/char   
  serSettingsFlagBitsPerChar7      =0x00000080; //  7 bits/char   
  serSettingsFlagBitsPerChar8      =0x000000C0; //  8 bits/char   


// Default settings
  serDefaultSettings = serSettingsFlagBitsPerChar8  |
                       serSettingsFlagStopBits1     |
                       serSettingsFlagRTSAutoM;

  //NONO. Macro. serDefaultCTSTimeout = 5*sysTicksPerSecond;

//
// mask values for the lineErrors  from SerGetStatus
//

  serLineErrorParity      =0x0001;  // parity error
  serLineErrorHWOverrun   =0x0002;  // HW overrun
  serLineErrorFraming     =0x0004;  // framing error
  serLineErrorBreak       =0x0008;  // break signal asserted
  serLineErrorHShake      =0x0010;  // line hand-shake error
  serLineErrorSWOverrun   =0x0020;  // HW overrun
  serLineErrorCarrierLost =0x0040;  // CD dropped



Type

/********************************************************************
 * Type of a wakeup handler procedure which can be installed through the
 *   SerSetWakeupHandler() call.
 ********************************************************************/
// void (*SerWakeupHandler)  (UInt32 refCon);
//  SerWakeupHandler: Function(refCon: UInt32): Pointer;
  SerWakeupHandler = Pointer;

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
// Boolean (*SerBlockingHookHandler)  (UInt32 userRef);
// SerBlockingHookHandler: Function(userRef: UInt32): Boolean;

  SerBlockingHookHandler = Pointer;



/********************************************************************
 * Serial Library Control Enumerations (Pilot 2.0)
 ********************************************************************/

/********************************************************************
 * Structure for specifying callback routines.
 ********************************************************************/
  SerCallbackEntryPtr = ^SerCallbackEntryType;
  SerCallbackEntryType = Record
    funcP: MemPtr;                     // function pointer
    userRef: UInt32;                   // ref value to pass to callback
  end;

// v2.0 extension
  SerCtlEnum = (
    serCtlFirstReserved = 0,      // RESERVE 0
   
    serCtlStartBreak,             // turn RS232 break signal on:
                                  // users are responsible for ensuring that the break is set
                                  // long enough to genearate a valie BREAK!
                                  // valueP = 0, valueLenP = 0
                                 
    serCtlStopBreak,              // turn RS232 break signal off:
                                  // valueP = 0, valueLenP = 0

    serCtlBreakStatus,            // Get RS232 break signal status(on or off):
                                  // valueP = MemPtr to UInt16 for returning status(0 = off, !0 = on)
                                  // *valueLenP = sizeof(UInt16)
                                 
    serCtlStartLocalLoopback,     // Start local loopback test
                                  // valueP = 0, valueLenP = 0
                                 
    serCtlStopLocalLoopback,      // Stop local loopback test
                                  // valueP = 0, valueLenP = 0

    serCtlMaxBaud,                // Get maximum supported baud rate:
                                  // valueP = MemPtr to UInt32 for returned baud
                                  // *valueLenP = sizeof(UInt32)
   
    serCtlHandshakeThreshold,     // retrieve HW handshake threshold; this is the maximum baud rate
                                  // which does not require hardware handshaking
                                  // valueP = MemPtr to UInt32 for returned baud
                                  // *valueLenP = sizeof(UInt32)
   
    serCtlEmuSetBlockingHook,     // Set a blocking hook routine FOR EMULATION
                                  // MODE ONLY - NOT SUPPORTED ON THE PILOT
                                  //PASS:
                                  // valueP = MemPtr to SerCallbackEntryType
                                  // *valueLenP = sizeof(SerCallbackEntryType)
                                  //RETURNS:
                                  // the old settings in the first argument
                                 

    serCtlIrDAEnable,             // Enable  IrDA connection on this serial port
                                  // valueP = 0, valueLenP = 0

    serCtlIrDADisable,            // Disable  IrDA connection on this serial port
                                  // valueP = 0, valueLenP = 0

    serCtlIrScanningOn,           // Start Ir Scanning mode

    serCtlIrScanningOff,          // Stop Ir Scanning mode

    serCtlRxEnable,               // enable receiver  ( for IrDA )

    serCtlRxDisable,              // disable receiver ( for IrDA )

    serCtlLAST                    // ADD NEW ENTRIES BEFORE THIS ONE
  );


// Start of a custom op code range for licensees that wrote old serial
// manager replacements.  Note that the serial compatiblity library
// does not pass these op codes to new serial manager plugins.
Const serCtlFirstCustomEntry =0xA800;

/********************************************************************
 * Serial Library Routines
 * These are define as external calls only under emulation mode or
 *  under native mode from the module that actually installs the trap
 *  vectors
 ********************************************************************/

// Used by mac applications to map the pilot serial port to a particular macintosh port.
//Function SerSetMapPort(pilotPort: UInt16; macPort: UInt16): UInt16;

// Acquires and opens a serial port with given baud and default settings.
Function SerOpen(refNum, port: UInt16; baud: UInt32): Err;
            SYS_TRAP(sysLibTrapOpen);

// Used by debugger to re-initialize serial port if necessary
//Function SerDbgAssureOpen(refNum, port: UInt16; baud: UInt32): Err;

// Closes the serial connection previously opened with SerOpen.
Function SerClose(refNum: UInt16): Err;
            SYS_TRAP(sysLibTrapClose);

// Puts serial library to sleep
Function SerSleep(refNum: UInt16): Err;
            SYS_TRAP(sysLibTrapSleep);

// Wake Serial library
Function SerWake(refNum: UInt16): Err;
            SYS_TRAP(sysLibTrapWake);

// Get attributes of the serial connection
Function SerGetSettings(refNum: UInt16; settingsP: SerSettingsPtr): Err;
            SYS_TRAP(sysLibTrapCustom);

// Set attributes of the serial connection
Function SerSetSettings(refNum: UInt16; settingsP: SerSettingsPtr): Err;
            SYS_TRAP(sysLibTrapCustom+1);

// Return status of serial connection
Function SerGetStatus(refNum: UInt16; var ctsOnP: Boolean;
            var dsrOnP: Boolean): UInt16;
            SYS_TRAP(sysLibTrapCustom+2);
            
// Reset error condition of serial connection
Function SerClearErr(refNum: UInt16): Err;
            SYS_TRAP(sysLibTrapCustom+3);
            
            


// Sends a buffer of data (may queue it up and return).
Function SerSend10(refNum: UInt16; bufP: Pointer; size: UInt32): Err;
            SYS_TRAP(sysLibTrapCustom+4);

// Waits until the serial transmit buffer empties.
// The timeout arg is ignored; CTS timeout is used
Function SerSendWait(refNum: UInt16; timeout: Int32): Err;
            SYS_TRAP(sysLibTrapCustom+5);

// Returns how many characters are left in the send queue waiting 
//  for transmission
Function SerSendCheck(refNum: UInt16; var numBytesP: UInt32): Err;
            SYS_TRAP(sysLibTrapCustom+6);

// Flushes the data out of the transmit buffer
Function SerSendFlush(refNum: UInt16): Err;
            SYS_TRAP(sysLibTrapCustom+7);




// Receives a buffer of data of the given size.
Function SerReceive10(refNum: UInt16; bufP: Pointer; bytes: UInt32; timeout: Int32): Err;
            SYS_TRAP(sysLibTrapCustom+8);

// Waits for at least 'bytes' bytes of data to arrive at the serial input.
//  but does not read them in
Function SerReceiveWait(refNum: UInt16; bytes: UInt32; timeout: Int32): Err;
            SYS_TRAP(sysLibTrapCustom+9);

// Returns how many characters are in the receive queue
Function SerReceiveCheck(refNum: UInt16; var numBytesP: UInt32): Err;
            SYS_TRAP(sysLibTrapCustom+10);

// Flushes any data coming into the serial port, discarding the data.
Procedure SerReceiveFlush(refNum: UInt16; timeout: Int32);
            SYS_TRAP(sysLibTrapCustom+11);


// Specify a new input buffer.  To restore the original buffer, pass
// bufSize = 0.
Function SerSetReceiveBuffer(refNum: UInt16; bufP: Pointer; bufSize: UInt16): Err;
            SYS_TRAP(sysLibTrapCustom+12);


// The receive character interrupt service routine, called by kernel when
//  a UART interrupt is detected.
Function SerReceiveISP: Boolean;
            SYS_TRAP(sysTrapSerReceiveISP);



// "Back Door" into the serial receive queue. Used by applications (like TCP Media layers)
//  that need faster access to received characters
Function SerReceiveWindowOpen(refNum: UInt16; var bufPP: Pointer; var sizeP: UInt32): Err;
            SYS_TRAP(sysLibTrapCustom+13);
            
Function SerReceiveWindowClose(refNum: UInt16; bytesPulled: UInt32): Err;
            SYS_TRAP(sysLibTrapCustom+14);

// Can be called by applications that need an alternate wakeup mechanism
//  when characters get enqueued by the interrupt routine.
Function SerSetWakeupHandler(refNum: UInt16; procP: SerWakeupHandler; refCon: UInt32): Err;
            SYS_TRAP(sysLibTrapCustom+15);
   
// Called to prime wakeup handler         
Function SerPrimeWakeupHandler(refNum: UInt16; minBytes: UInt16): Err;
            SYS_TRAP(sysLibTrapCustom+16);
   
// Called to perform a serial manager control operation        
// (v2.0 extension)
Function SerControl(refNum: UInt16; op: UInt16; valueP: Pointer; var valueLenP: UInt16): Err;
            SYS_TRAP(sysLibTrapCustom+17);


// Sends a buffer of data (may queue it up and return).
Function SerSend(refNum: UInt16; bufP: Pointer; count: UInt32; var errP: Err): UInt32;
            SYS_TRAP(sysLibTrapCustom+18);

// Receives a buffer of data of the given size.
Function SerReceive(refNum: UInt16; bufP: Pointer; count: UInt32; timeout: Int32; var errP: Err): UInt32;
            SYS_TRAP(sysLibTrapCustom+19);

implementation

end.

