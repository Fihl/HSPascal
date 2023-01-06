/******************************************************************************
 *
 * Copyright (c) 1998-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: StdIOProvider.h
 *
 * Description:
 *   This header file must be included by apps that want to provide
 * a standard IO window and "execute" standard IO apps in it. See the
 * comments in the file "StdIOProvier.c" for more info
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit StdIOProvider;

interface

uses StdIOPalm, SysEvent;


/****************************************************************
 * Provider SioGlobalsType includes the client visible fields
 * in the beginning
 ****************************************************************/
Type
  SioProvGlobalsptr = ^SioProvGlobalsType;
  SioProvGlobalsType = Record
    client: SioGlobalsType;
    provA5: UInt32;                // saved A5 register
    textH: MemHandle;              // holds latest text
    formID: UInt16;                // Form ID that contains text field
    fieldID: UInt16;               // Field ID
    scrollerID: UInt16;
    echo: Boolean;
    reserved: UInt8;
  end;


/*******************************************************************
 * Function Prototypes
 ********************************************************************/

(***** NO Traps supplied
Function SioInit(formID: UInt16; fieldID: UInt16; scrollerID: UInt16): Err;
Function SioFree: Err;
Function SioHandleEvent(var eventP: SysEventType): Boolean;

// This routine will execute a command line. It is faster than
//  using the "system()" call but can only be used by the
//  StdIO provider app itself.
Function SioExecCommand(cmd: pChar): Int16;

procedure SioClearScreen;
*********)

implementation

end.

