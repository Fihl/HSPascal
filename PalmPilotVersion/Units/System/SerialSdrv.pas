/******************************************************************************
 *
 * Copyright (c) 1995-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: SerialSdrv.h
 *
 * Description:
 *    Constants and data structures for serial drvr ('sdrv') code.
 *
 * History:
 *    5/11/98  Created by Ben Manuto
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit SerialSdrv;  //DOLATER; !! HAL_CALL !!!!

interface

Uses SerialDrvr;


// ¥¥¥¥¥¥¥¥¥¥ Constants

Const kSdrvResType       ='sdrv';


// ¥¥¥¥¥¥¥¥¥¥ Typdefs

Type
  SdrvCtlOpCodeEnum = (                    // Control function opCodes
    sdrvOpCodeNoOp = 0,
    sdrvOpCodeSetBaudRate = 0x1000,        // Set baud rate
    sdrvOpCodeSetSettingsFlags,            // Set port send/rcv settings.
    sdrvOpCodeClearErr,                    // Clear any HW errors.
    sdrvOpCodeEnableUART,                  // Enable the UART.
    sdrvOpCodeDisableUART,                 // Disable the UART.
    sdrvOpCodeEnableUARTInterrupts,        // Enable the UART interrupts.
    sdrvOpCodeDisableUARTInterrupts,       // Disable the UART interrupts.
    sdrvOpCodeSetSleepMode,                // Put the HW in sleep mode.
    sdrvOpCodeSetWakeupMode,               // Wake the HW from sleep mode.
    sdrvOpCodeRxEnable,                    // Enable the RX lines.
    sdrvOpCodeRxDisable,                   // Disbale the RX lines.
    sdrvOpCodeLineEnable,                  // Enable the RS-232 lines.
    sdrvOpCodeFIFOCount,                   // Return bytes in HW FIFO.
    sdrvOpCodeEnableIRDA,                  // Enable the IR mode for the UART.
    sdrvOpCodeDisableIRDA,                 // Disable the IR mode for the UART.
    sdrvOpCodeStartBreak,                  // Start a break signal.
    sdrvOpCodeStopBreak,                   // Stop a break signal.
    sdrvOpCodeStartLoopback,               // Start loopback mode.
    sdrvOpCodeStopLoopback,                // Stop loopback mode.
    sdrvOpCodeFlushTxFIFO,                 // Flush HW TX FIFO.
    sdrvOpCodeFlushRxFIFO,                 // Flsuh HW RX FIFO.
    sdrvOpCodeGetOptTransmitSize,          // Get HW optimal buffer size.
    sdrvOpCodeEnableRTS,                   // De-assert the RTS line to allow data to be received.
    sdrvOpCodeDisableRTS,                  // Assert the RTS line to prevent rcv buffer overflows.
    sdrvOpCodeSetDTRAsserted,              // Assert or deassert DTR signal
    sdrvOpCodeGetDTRAsserted,              // Yields 'true' if DTR is asserted, 'false' otherwise.

    // --- Insert new control code above this line
    sdrvOpCodeUserDef = 0x2000
  );


  SdrvDataPtr= Pointer;

(*****
typedef void (*SerialMgrISPProcPtr)(void *portP);
typedef Err (*SdrvOpenProcPtr)(SdrvDataPtr *drvrDataP,
                               UInt32 baudRate,
                               void *portP,
                               void *saveDataProc);
typedef Err (*SdrvCloseProcPtr)(SdrvDataPtr drvrDataP);
typedef Err (*SdrvControlProcPtr)(SdrvDataPtr drvrDataP,
                                 SdrvCtlOpCodeEnum controlCode,
                                 void *controlDataP,
                                 UInt16 *controlDataLenP);
typedef UInt16 (*SdrvStatusProcPtr)(SdrvDataPtr drvrDataP);
typedef UInt16 (*SdrvReadCharProcPtr)(SdrvDataPtr drvrDataP);
typedef Err (*SdrvWriteCharProcPtr)(SdrvDataPtr drvrDataP, UInt8 aChar);
*****)
  SerialMgrISPProcPtr = Pointer;
  SdrvOpenProcPtr = Pointer;
  SdrvCloseProcPtr = Pointer;
  SdrvControlProcPtr = Pointer;
  SdrvStatusProcPtr = Pointer;
  SdrvReadCharProcPtr = Pointer;
  SdrvWriteCharProcPtr = Pointer;

  SdrvAPIPtr = ^SdrvAPIType;
  SdrvAPIType = Record
    drvOpen: SdrvOpenProcPtr;
    drvClose: SdrvCloseProcPtr;
    drvControl: SdrvControlProcPtr;  
    drvStatus: SdrvStatusProcPtr;
    drvReadChar: SdrvReadCharProcPtr;
    drvWriteChar: SdrvWriteCharProcPtr;
  end;


// Normally, serial drvr functions are accessed (by the NewSerialMgr)
// through the above SdrvAPIType structure of ProcPtrs.

// However, SerialMgrDbg.c (the Serial Mgr linked to the boot/debugger code)
// needs to call the HAL's debug serial code through the HAL_CALL macro.


(** HAL_CALL ???
Function DrvOpen(var drvrData: SdrvDataPtr; baudRate: UInt32; portP: Pointer;
            saveDataProc: SerialMgrISPProcPtr): Err;
      HAL_CALL(sysTrapDbgSerDrvOpen);

Function DrvClose(drvrData: SdrvDataPtr): Err;
      HAL_CALL(sysTrapDbgSerDrvClose);

Function DrvControl(drvrData: SdrvDataPtr; controlCode: SdrvCtlOpCodeEnum;
               controlData: Pointer; var controlDataLen: UInt16): Err;
      HAL_CALL(sysTrapDbgSerDrvControl);

Function DrvStatus(drvrData: SdrvDataPtr): UInt16;
      HAL_CALL(sysTrapDbgSerDrvStatus);

Function DrvWriteChar(drvrData: SdrvDataPtr; aChar: UInt8): Err;
      HAL_CALL(sysTrapDbgSerDrvWriteChar);

Function DrvReadChar(drvrData: SdrvDataPtr): UInt16;
      HAL_CALL(sysTrapDbgSerDrvReadChar);

(********)

implementation

end.

