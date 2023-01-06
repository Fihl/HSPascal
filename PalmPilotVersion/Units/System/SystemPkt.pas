/******************************************************************************
 *
 * Copyright (c) 1994-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: SystemPkt.h
 *
 * Description:
 *    Structure of System Packets for the Serial Link Manager. These
 * packets are used by the Debugger, Console, and Remote UI modules
 * for communication with the host computer.
 *
 * History:
 *    6/26/95  RM - Created by Ron Marianetti
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit SystemPkt;

interface

Uses SystemMgr, SerialLinkMgr;

//*************************************************************************
//   Constants for System Packets
//*************************************************************************

// Max # of bytes we can read/write at a time with the ReadMem and WriteMem
//  commands;
Const
  sysPktMaxMemChunk       =256; 

// Maximum body size for System Packets. This is big enough to have
//  256 bytes of data for the Read and Write Mem command plus whatever other
//  parameters are in the body for these commands.
  sysPktMaxBodySize       =sysPktMaxMemChunk+16;
  sysPktMaxBodySizeM2     =sysPktMaxMemChunk+16-2;


// Default nitial timeout value for packet receive routines in ticks
  // sysPktInitialTimeout    =sysTicksPerSecond*10;



//*************************************************************************
// Packet Body Structure
//*************************************************************************

// Generic System Packet Body
Type
  SysPktBodyPtr = ^SysPktBodyType;
  SysPktBodyType = Record
    command,_filler: UInt8;
    data: Array[0..sysPktMaxBodySizeM2] of UInt8;
  end;

//*************************************************************************
// The max size of the array of SlkWriteDataTypes used by System Packet
//  assembly routines in order to minimize stack usage.
//*************************************************************************
Const
  sysPktMaxBodyChunks=3;



//*************************************************************************
// packet commands
//*************************************************************************

//--------------------------------------------------------------------
// get state command
//--------------------------------------------------------------------
Const
  sysPktStateCmd             =0x00;
  sysPktStateRsp             =0x80;

//--------------------------------------------------------------------
// read memory command
//--------------------------------------------------------------------
  sysPktReadMemCmd           =0x01;
  sysPktReadMemRsp           =0x81;

type
  SysPktReadMemCmdPtr = ^SysPktReadMemCmdType;
  SysPktReadMemCmdType = Record
    command,_filler: UInt8;                   // Common Body header
    address: Pointer;                // Address to read
    numBytes: UInt16;                              // # of bytes to read
  end;

  SysPktReadMemRspPtr = ^SysPktReadMemRspType;
  SysPktReadMemRspType = Record
    command,_filler: UInt8;                   // Common Body header
    // UInt8          data[?];                // variable size
  end;


//--------------------------------------------------------------------
// write memory command
//--------------------------------------------------------------------
Const sysPktWriteMemCmd          =0x02;
Const sysPktWriteMemRsp          =0x82;

Type
  SysPktWriteMemCmdPtr = ^SysPktWriteMemCmdType;
  SysPktWriteMemCmdType = Record
    command,_filler: UInt8;                   // Common Body header
    address: Pointer;                // Address to write
    numBytes: UInt16;                           // # of bytes to write
    // UInt8          data[?];                // variable size data
  end;

  SysPktWriteMemRspPtr = ^SysPktWriteMemRspType;
  SysPktWriteMemRspType  = Record
     command,_filler: UInt8;                   // Common Body header
  End;


//--------------------------------------------------------------------
// single-step command
//--------------------------------------------------------------------
Const sysPktSingleStepCmd        =0x03;
// no response

//--------------------------------------------------------------------
// get routine name command
//--------------------------------------------------------------------
Const sysPktGetRtnNameCmd        =0x04;
Const sysPktGetRtnNameRsp        =0x84;

//--------------------------------------------------------------------
// read registers command
//--------------------------------------------------------------------
Const sysPktReadRegsCmd          =0x05;
Const sysPktReadRegsRsp          =0x85;


//--------------------------------------------------------------------
// write registers command
//--------------------------------------------------------------------
Const sysPktWriteRegsCmd         =0x06;
Const sysPktWriteRegsRsp         =0x86;

//--------------------------------------------------------------------
// continue command
//--------------------------------------------------------------------
Const sysPktContinueCmd          =0x07;
// no response


//--------------------------------------------------------------------
// Remote Procedure call
//--------------------------------------------------------------------
Const sysPktRPCCmd               =0x0A;
Const sysPktRPCRsp               =0x8A;

Type
  SysPktRPCParamType = Record
    byRef: UInt8;                      // true if param is by reference
    size: UInt8;                       // # of Bytes of paramData (must be even)
    data: Array[0..0] of UInt16;                // variable length array of paramData
  end;

  SysPktRPCType = Record
    command,_filler: UInt8;                   // Common Body header
    trapWord: UInt16;                  // which trap to execute
    resultD0: UInt32;                  // result from D0 placed here
    resultA0: UInt32;                  // result from A0 placed here
    numParams: UInt16;                 // how many parameters follow
    // Following is a variable length array ofSlkRPCParamInfo's
    param: array [0..0] of SysPktRPCParamType;
  end;


//--------------------------------------------------------------------
// Set/Get breakpoints
//--------------------------------------------------------------------
Const sysPktGetBreakpointsCmd    =0x0B;
Const sysPktGetBreakpointsRsp    =0x8B;
Const sysPktSetBreakpointsCmd    =0x0C;
Const sysPktSetBreakpointsRsp    =0x8C;


//--------------------------------------------------------------------
// Remote UI Support - These packets are used by the screen driver
//  and event manager to support remote viewing and control of a Pilot
//  over the serial port.
//--------------------------------------------------------------------
Const sysPktRemoteUIUpdCmd       =0x0C;

Type
  SysPktRemoteUIUpdCmdType = Record
    command,_filler: UInt8;                   // Common Body header

   // These parameters are sent from traget to host after drawing operations
    rowBytes: UInt16;                     // rowbytes of update area
    fromY: UInt16;                        // top of update rect
    fromX: UInt16;                        // left of update rect
    toY: UInt16;                          // top of screen rect
    toX: UInt16;                          // left of screen rect
    height: UInt16;                       // bottom of update rect
    width: UInt16;                        // right of update rect

   // The actual pixels of the update area follow
    pixels: UInt16;                       // variable length...

  end;


Const sysPktRemoteEvtCmd         =0x0D;

Type
  SysPktRemoteEvtCmdType = Record
    command,_filler: UInt8;                   // Common Body header

   // These parameters are sent from host to target to feed pen and keyboard
   //  events. They do not require a response.
    penDown: Boolean;                     // true if pen down
    padding1: UInt8;       
    penX: Int16;                          // X location of pen
    penY: Int16;                          // Y location of pen

    keyPress: Boolean;                    // true if key event follows
    padding2: UInt8;    
    keyModifiers: UInt16;                 // keyboard modifiers
    keyAscii: WChar;                      // key ascii code
    keyCode: UInt16;                      // key virtual code
  end;


//--------------------------------------------------------------------
// Enable/Disable DbgBreak's command
//--------------------------------------------------------------------
Const
  sysPktDbgBreakToggleCmd       =0x0D;
  sysPktDbgBreakToggleRsp       =0x8D;


//--------------------------------------------------------------------
// Program Flash command - programs one sector of the FLASH ram
// If numBytes is 0, this routine returns info on the flash in:
//   manuf - manufacturer code
//   device - device code
//--------------------------------------------------------------------
  sysPktFlashCmd                =0x0E;     // OBSOLETE AS OF 3.0! SEE BELOW!
  sysPktFlashRsp                =0x8E;     // OSBOLETE AS OF 3.0! SEE BELOW!


//--------------------------------------------------------------------
// Get/Set communication parameters
//--------------------------------------------------------------------
  sysPktCommCmd                 =0x0F;
  sysPktCommRsp                 =0x8F;

Type
  SysPktCommCmdPtr = ^SysPktCommCmdType;
  SysPktCommCmdType = Record
    command,_filler: UInt8;                   // Common Body header
    doSet: Boolean;                               // true to change parameters
    padding: UInt8;                   
    baudRate: UInt32;                           // new baud rate
    flags: UInt32;                              // new flags
  end;

  SysPktCommRspPtr = ^SysPktCommRspType;
  SysPktCommRspType = Record
    command,_filler: UInt8;                   // Common Body header
    baudRate: UInt32;                           // current baud rate
    flags: UInt32;                              // current flags
  end;

//--------------------------------------------------------------------
// Get/Set Trap Breaks
//--------------------------------------------------------------------
Const
  sysPktGetTrapBreaksCmd        =0x10;
  sysPktGetTrapBreaksRsp        =0x90;
  sysPktSetTrapBreaksCmd        =0x11;
  sysPktSetTrapBreaksRsp        =0x91;


//--------------------------------------------------------------------
// Gremlins Support - These packets are used by the screen driver
//  and event manager to support remote viewing and control of a Pilot
//  over the serial port.
//--------------------------------------------------------------------
  sysPktGremlinsCmd          =0x12;

Type
  SysPktGremlinsCmdType = Record
    command,_filler: UInt8;                   // Common Body header

   // These parameters are sent from target to host to send Gremlins stuff
   action: UInt16; 
   data: Array[0..31] of UInt8;
  end;

// Gremlins action codes
Const
  sysPktGremlinsIdle         =1;   
  sysPktGremlinsEvent        =2;   


//--------------------------------------------------------------------
// Find data - searches a range of addresses for data
//--------------------------------------------------------------------
  sysPktFindCmd           =0x13;
  sysPktFindRsp           =sysPktFindCmd | 0x80;

Type
  SysPktFindCmdPtr = ^SysPktFindCmdType;
  SysPktFindCmdType = Record
    command,_filler: UInt8;                   // Common Body header

    firstAddr: UInt32;                          // first address to search
    lastAddr: UInt32;                           // last address to begin searching
    numBytes: UInt16;                           // number of data bytes to match
    caseInsensitive: Boolean;                   // if true, perform a case-insensitive search
    padding: UInt8;    
  end;

  SysPktFindRspPtr = ^SysPktFindRspType;
  SysPktFindRspType = Record
    command,_filler: UInt8;                   // Common Body header

   addr: UInt32;                                // address where data was found
   found: Boolean;                              // true if data was found
   padding: UInt8; 
  end;


//--------------------------------------------------------------------
// Get/Set Trap Conditionals. These are used to tell the debugger
//  to conditionally break on a trap depending on the value of the
//  first word on the stack. They are used when setting a-traps on
//  library calls. This is a 3.0 feature. 
//--------------------------------------------------------------------
Const
  sysPktGetTrapConditionsCmd       =0x14;
  sysPktGetTrapConditionsRsp       =0x94;
  sysPktSetTrapConditionsCmd       =0x15;
  sysPktSetTrapConditionsRsp       =0x95;


//--------------------------------------------------------------------
// Checksum data - checksums a range of memory.
// This is a (late) 3.0 feature.
//--------------------------------------------------------------------
  sysPktChecksumCmd          =0x16;
  sysPktChecksumRsp          =sysPktChecksumCmd | 0x80;

Type
  SysPktChecksumPtr = ^SysPktChecksumType;
  SysPktChecksumType = Record
    command,_filler: UInt8;                   // Common Body header

    firstAddr: UInt32;                          // -> first address to checksum
    numBytes: UInt16;                           // -> number of bytes to checksum
    seed: UInt16;                               // -> initial checksum value
    checksum: UInt16;                           // <- checksum result
  end;


//--------------------------------------------------------------------
// NEW Program Flash command - programs one sector of the FLASH ram
// If numBytes is 0, this routine returns address to store flash code.
// Supercedes Obsolete 1.0 and 2.0 sysPktFlashCmd call above in the 3.0 ROM
//--------------------------------------------------------------------
Const
  sysPktExecFlashCmd            =0x17;
  sysPktExecFlashRsp            =sysPktExecFlashCmd | 0x80;



//--------------------------------------------------------------------
// message from remote unit
//--------------------------------------------------------------------
  sysPktRemoteMsgCmd            =0x7f;


//--------------------------------------------------------------------
// sysPktRemoteMsg
// Send a text message
//--------------------------------------------------------------------
Type
  SysPktRemoteMsgCmdptr = ^SysPktRemoteMsgCmdType;
  SysPktRemoteMsgCmdType = Record
    command,_filler: UInt8;                   // Common Body header
    //text: UInt8;                            // variable length text goes here
  end;


/*******************************************************************
 * Prototypes
 *******************************************************************/

//================================================================
//
// Host Only Routines.
//
//================================================================

(**********************************************************************
   //-------------------------------------------------------------------
   // RPC
   //------------------------------------------------------------------
   // Init preparate on an RPC packet header and body.
   Err      SlkRPCInitPacket(SlkPktHeaderType* headerP, UInt16 dstSocket,
                  SysPktRPCType* bodyP, UInt16 trapWord);


   // Stuff a parameter into an RPC packet body
   void *   SlkRPCStuffParam(SysPktRPCType* bodyP, void* dataP,
                     Int16 dataSize, Boolean byRef);

   // Send RPC packet and wait for response.
   Err      SlkRPCExecute(SlkPktHeaderPtr headerP, SysPktRPCType* bodyP,
                     Boolean async);

**********************************************************************)

implementation

end.

