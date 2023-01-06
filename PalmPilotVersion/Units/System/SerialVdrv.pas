/******************************************************************************
 *
 * Copyright (c) 1995-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: SerialVdrv.h
 *
 * Description:
 *    Constants and data structures for virtual driver ('vdrv') code.
 *
 * History:
 *    5/11/98  Created by Ben Manuto
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit SerialVdrv;

interface

Uses SerialDrvr;


// ********** Constants

Const
  kVdrvResType       ='vdrv';


// ********** 
Type
  VdrvCtlOpCodeEnum = (                    // Control function opCodes
    vdrvOpCodeNoOp = 0,
    vdrvOpCodeSetBaudRate = 0x1000,        // Set the port's baud rate.
    vdrvOpCodeSetSettingsFlags,            // Set the ports send/rvc settings
    vdrvOpCodeSetCtsTimeout,               // The HW handshake timeout.
    vdrvOpCodeClearErr,                    // Clear any HW errors.
    vdrvOpCodeSetSleepMode,                // Put in sleep mode.
    vdrvOpCodeSetWakeupMode,               // Wake from sleep mode.
    vdrvOpCodeFIFOCount,                   // Return bytes in FIFO
    vdrvOpCodeStartBreak,                  // Start a break signal.
    vdrvOpCodeStopBreak,                   // Stop a break signal
    vdrvOpCodeStartLoopback,               // Start loopback mode.
    vdrvOpCodeStopLoopback,                // Stop loopback mode.
    vdrvOpCodeFlushTxFIFO,                 // Flush the TX FIFO.
    vdrvOpCodeFlushRxFIFO,                 // Flush the RX FIFO.
    vdrvOpCodeSendBufferedData,            // Send any buffered data in e vdrv.
    vdrvOpCodeRcvCheckIdle,                // Check idle state.
    vdrvOpCodeEmuSetBlockingHook,          // Special opCode for the simulator.
    vdrvOpCodeGetOptTransmitSize,          // Get the optimal TX buffer size for this port.
    vdrvOpCodeGetMaxRcvBlockSize,          // Get the optimal RX buffer size for this port.
    vdrvOpCodeNotifyBytesReadFromQ,        // Notify the vdrv bytes have been removed from Q.
    vdrvOpCodeSetDTRAsserted,              // Assert or deassert DTR signal
    vdrvOpCodeGetDTRAsserted,              // Yields 'true' if DTR is asserted, 'false' otherwise.

    // --- Insert new control code above this line
    vdrvOpCodeUserDef = 0x2000
  );

  VdrvDataPtr= Pointer;

(*****
 Err (*VdrvOpenProcPtr)(VdrvDataPtr *drvrDataP, UInt32 baudRate, DrvrHWRcvQPtr rcvQP);
 Err (*VdrvCloseProcPtr)(VdrvDataPtr drvrDataP);

 UInt16 (*VdrvStatusProcPtr)(VdrvDataPtr drvrDataP);
 Err (*VdrvControlProcPtr)(VdrvDataPtr drvrDataP,
                           VdrvCtlOpCodeEnum controlCode,
                           void *controlDataP,
                           UInt16 *controlDataLenP);

 Err (*VdrvReadProcPtr)(VdrvDataPtr drvrDataP, void **bufP, UInt32 *sizeP);
 UInt32 (*VdrvWriteProcPtr)(VdrvDataPtr drvrDataP, void *bufP, UInt32 size, Err *errP);
*****)
  VdrvOpenProcPtr = Pointer;
  VdrvCloseProcPtr = Pointer;
  VdrvStatusProcPtr = Pointer;
  VdrvControlProcPtr = Pointer;
  VdrvReadProcPtr = Pointer;
  VdrvWriteProcPtr = Pointer;

  VdrvAPIPtr = ^VdrvAPIType;
  VdrvAPIType = Record
    drvOpen: VdrvOpenProcPtr;     
    drvClose: VdrvCloseProcPtr;    
    drvControl: VdrvControlProcPtr;  
    drvStatus: VdrvStatusProcPtr;   
    drvRead: VdrvReadProcPtr;
    drvWrite: VdrvWriteProcPtr;
  end;

implementation

end.

