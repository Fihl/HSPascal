/******************************************************************************
 *
 * Copyright (c) 1995-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: SerialDrvr.h
 *
 * Description:
 *    Constants and data structures for serial drvr ('sdrv') code.
 *
 * History:
 *    1/23/98  Created by Ben Manuto
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit SerialDrvr;

interface

// ********** Constants

Const
  kDrvrCreator          =0;         
  kDrvrResID            =0;         
  kDrvrCODEType         ='code';     


// kDrvrVersion is included by all sdrv's and vdrv's and is returned by the drvr to the
// serial manager to show the driver version is consistent with the required version of
// drvr the new serial manager needs in order to operate properly.
  kDrvrVersion          =3;

  kMaxPortDescStrLen    =64;
  kPortDescStrID        =1000;

// Flags denoting capabilities and features of this port.

  portPhysicalPort      =0x00000001;     // Should be unset for virtual port.

  portRS232Capable      =0x00000004;     // Denotes this serialHW has a RS-232 port.
  portIRDACapable       =0x00000008;     // Denotes this serialHW has a IR port and support IRDA mode.

  portCradlePort        =0x00000010;     // Denotes this SerialHW controls the cradle port.
  portExternalPort      =0x00000020;     // Denotes this SerialHW's port is external or on a memory card.
  portModemPort         =0x00000040;     // Denotes this SerialHW communicates with a modem.

  portCncMgrVisible     =0x00000080;     // Denotes this serial port's name is to be displayted in the Connection panel.
  portPrivateUse        =0x00001000;     // Set if this drvr is for special software and NOT general apps in system.


// ********** Structs

Type
  DrvrIRQEnum = (
    drvrIRQNone = 0x00,
    drvrIRQ1 = 0x01,
    drvrIRQ2 = 0x02,
    drvrIRQ3 = 0x04,
    drvrIRQ4 = 0x08,
    drvrIRQ5 = 0x10,
    drvrIRQ6 = 0x20,
    drvrIRQOther = 0x40
  );


// ***** Info about this particular port

  DrvrInfoPtr = ^DrvrInfoType;
  DrvrInfoType = Record
    drvrID: UInt32;                 // e.g. creator type, such as 'u328'
    drvrVersion: UInt32;            // version of code that works for this HW.
    maxBaudRate: UInt32;            // Maximum baud rate for this uart.
    handshakeThreshold: UInt32;     // Baud rate at which hardware handshaking should be used.
    portFlags: UInt32;              // flags denoting features of this uart.
    portDesc: pChar;                // Pointer to null-terminated string describing this HW.
    irqType: DrvrIRQEnum;           // IRQ line for this uart serial HW.
    reserved: UInt8; 
  end;


  DrvrEntryOpCodeEnum = (        // OpCodes for the entry function.
    drvrEntryGetUartFeatures,
    drvrEntryGetDrvrFuncts
  );


  DrvrStatusEnum = (
    drvrStatusCtsOn         = 0x0001,
    drvrStatusRtsOn         = 0x0002,
    drvrStatusDsrOn         = 0x0004,
    drvrStatusTxFifoFull    = 0x0008,
    drvrStatusTxFifoEmpty   = 0x0010,
    drvrStatusBreakAsserted = 0x0020,
    drvrStatusDataReady     = 0x0040,      // For polling mode debugger only at this time.
    drvrStatusLineErr       = 0x0080       // For polling mode debugger only at this time.
  );


// ********** Entry Point Function type

// Err (*DrvEntryPointProcPtr)(DrvrEntryOpCodeEnum opCode, void *uartData);


// ********** ADT and functions for Rcv Queue.

// Err (*WriteByteProcPtr)(void *theQ, UInt8 theByte, UInt16 lineErrs);
// Err (*WriteBlockProcPtr)(void *theQ, UInt8 *bufP, UInt16 size, UInt16 lineErrs);
// UInt32 (*GetSizeProcPtr)(void *theQ);
// UInt32 (*GetSpaceProcPtr)(void *theQ);
  WriteByteProcPtr = Pointer;
  WriteBlockProcPtr = Pointer;
  GetSizeProcPtr = Pointer;
  GetSpaceProcPtr = Pointer;

  DrvrRcvQType = Record
    rcvQ: Pointer;
    qWriteByte: WriteByteProcPtr;  
    qWriteBlock: WriteBlockProcPtr; 
    qGetSize: GetSizeProcPtr;
    qGetSpace: GetSpaceProcPtr;
  end;

implementation

end.

