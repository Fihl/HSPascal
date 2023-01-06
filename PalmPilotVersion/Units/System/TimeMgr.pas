/******************************************************************************
 *
 * Copyright (c) 1995-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: TimeMgr.h
 *
 * Description:
 *    Time manager functions
 *
 * History:
 *    1/19/95  roger - Created by Roger Flores
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit TimeMgr;

interface

Uses ErrorBase;

/************************************************************
 * Time Manager result codes
 * (timErrorClass is defined in SystemMgr.h)
 *************************************************************/
Const
  timErrMemory       =timErrorClass | 1;

/************************************************************
 * Function Prototypes
 *************************************************************/

//-------------------------------------------------------------------
// Initialization
//-------------------------------------------------------------------
Function TimInit: Err; SYS_TRAP(sysTrapTimInit);


//-------------------------------------------------------------------
// API
//-------------------------------------------------------------------

// seconds since 1/1/1904
Function TimGetSeconds: UInt32;           SYS_TRAP(sysTrapTimGetSeconds);

// seconds since 1/1/1904
Procedure TimSetSeconds(seconds: UInt32); SYS_TRAP(sysTrapTimSetSeconds);

// ticks since power on
Function TimGetTicks: UInt32;             SYS_TRAP(sysTrapTimGetTicks);

implementation

end.

