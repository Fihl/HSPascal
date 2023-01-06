/******************************************************************************
 *
 * Copyright (c) 1997-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: ExgLib.h
 *
 * Description:
 *    Include file the Exchange Library interface. The Exchange Library is a
 *    generic interface to any number of librarys. Any Exchange Library
 *    MUST have entrypoint traps in exactly the order listed here.
 *    The System Exchange manager functions call these functions when 
 *    applications make calls to the Exchange manager. Applications will
 *    usually not make direct calls to this API.
 *
 * History:
 *    5/23/97 Created by Gavin Peacock
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit ExgLib; //DOLATER;

interface

Uses ExgMgr;

// special exchange mgr event key
Const exgIntDataChr = $01ff;

//-----------------------------------------------------------------------------
//    Obx library call ID's. Each library call gets the trap number:
//   exgTrapXXXX which serves as an index into the library's dispatch table.
//   The constant sysLibTrapCustom is the first available trap number after
//   the system predefined library traps Open,Close,Sleep & Wake.
//
// WARNING!!! This order of these traps MUST match the order of the dispatch
//  table in and Exchange library!!!
//-----------------------------------------------------------------------------
Type
  ExgLibTrapNumberEnum = (
   exgLibTrapHandleEvent = sysLibTrapCustom,
   exgLibTrapConnect,
   exgLibTrapAccept,
   exgLibTrapDisconnect,
   exgLibTrapPut,
   exgLibTrapGet,
   exgLibTrapSend,
   exgLibTrapReceive,
   exgLibTrapControl,
   exgLibReserved1,
   exgLibTrapLast
  );


/************************************************************
 * Net Library procedures.
 *************************************************************/

//--------------------------------------------------
// Library initialization, shutdown, sleep and wake
//--------------------------------------------------
// Open the library - enable server for receiving data.
Function ExgLibOpen(libRefnum: UInt16): Err;
         SYS_TRAP(sysLibTrapOpen);

Function ExgLibClose(libRefnum: UInt16): Err;
         SYS_TRAP(sysLibTrapClose);
               
Function ExgLibSleep(libRefnum: UInt16): Err;
         SYS_TRAP(sysLibTrapSleep);
               
Function ExgLibWake(libRefnum: UInt16): Err;
         SYS_TRAP(sysLibTrapWake);
               
// MemHandle events that this library needs. This will be called by
// sysHandle event when certain low level events are triggered.               
Function ExgLibHandleEvent(libRefnum: UInt16; eventP: Pointer): Err;
         SYS_TRAP(exgLibTrapHandleEvent);

//  Establish a new connection                  
Function ExgLibConnect(libRefnum: UInt16; exgSocketP: ExgSocketPtr): Err;
         SYS_TRAP(exgLibTrapConnect);

// Accept a connection request from remote end
Function ExgLibAccept(libRefnum: UInt16; exgSocketP: ExgSocketPtr): Err;
         SYS_TRAP(exgLibTrapAccept);

// Disconnect
Function ExgLibDisconnect(libRefnum: UInt16; exgSocketP: ExgSocketPtr; error: Err): Err;
         SYS_TRAP(exgLibTrapDisconnect);

// Initiate a Put command. This passes the name and other information about
// an object to be sent
Function ExgLibPut(libRefnum: UInt16; exgSocketP: ExgSocketPtr): Err;
         SYS_TRAP(exgLibTrapPut);

// Initiate a Get command. This requests an object from the remote end.
Function ExgLibGet(libRefnum: UInt16; exgSocketP: ExgSocketPtr): Err;
         SYS_TRAP(exgLibTrapGet);

// Send data to remote end - called after a Put command
Function ExgLibSend(libRefnum: UInt16; exgSocketP: ExgSocketPtr; const bufP: Pointer; bufLen: UInt32; var errP: Err): UInt32;
         SYS_TRAP(exgLibTrapSend);

// Receive data from remote end -- called after Accept
Function ExgLibReceive(libRefnum: UInt16; exgSocketP: ExgSocketPtr; bufP: pointer; bufSize: UInt32; var errP: Err): UInt32;
         SYS_TRAP(exgLibTrapReceive);

// Send various option commands to the Exg library
Function ExgLibControl(libRefnum: UInt16; op: UInt16; valueP: pointer; var valueLenP: UInt16): Err;
         SYS_TRAP(exgLibTrapControl);

implementation

end.

