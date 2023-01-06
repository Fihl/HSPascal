/******************************************************************************
 *
 * Copyright (c) 1995-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: SysUtils.h
 *
 * Description:
 *   These are miscellaneous routines.
 *
 * History:
 *    April 27, 1995 Created by Roger Flores
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit SysUtils;

interface

Type
  //_comparF: Function(p1,p2: Pointer; other: Int32): Int16;
  CmpFuncPtr= Pointer;

  //_searchF: Function(var searchData, arrayData; other: Int32): Int16;
  SearchFuncPtr= Pointer;

/************************************************************
 * Constants
 *************************************************************/
Const
  sysRandomMax      =0x7FFF;         // Max value returned from SysRandom()


/************************************************************
 * Macros
 *************************************************************/
//#define Abs(a) (((a) >= 0) ? (a) : -(a))

/************************************************************
 * procedures
 *************************************************************/

Function SysBinarySearch (var baseP; numOfElements, width: Int16;
            searchF: SearchFuncPtr; searchData: Pointer;
            other: Int32; var position: Int32; findFirst: Boolean): Boolean;
                  SYS_TRAP(sysTrapSysBinarySearch);

Procedure SysInsertionSort (var baseP; numOfElements, width: Int16;
            comparF: CmpFuncPtr; other: Int32);
                  SYS_TRAP(sysTrapSysInsertionSort);

Procedure SysQSort (var baseP; numOfElements, width: Int16;
            comparF: CmpFuncPtr; other: Int32);
                  SYS_TRAP(sysTrapSysQSort);

Procedure SysCopyStringResource(str: pChar; theID: Int16);
                  SYS_TRAP(sysTrapSysCopyStringResource);

Function SysFormPointerArrayToStrings(c: pChar; stringCount: Int16): MemHandle;
                  SYS_TRAP(sysTrapSysFormPointerArrayToStrings);


// Return a random number ranging from 0 to sysRandomMax.
// Normally, 0 is passed unless you want to start with a new seed.
Function SysRandom(newSeed: Int32): Int16;
                  SYS_TRAP(sysTrapSysRandom);


Function SysStringByIndex(resID, index: UInt16; strP: pChar; maxLen: UInt16): Pointer;
                  SYS_TRAP(sysTrapSysStringByIndex);

Function SysErrString(error: Err; strP: pChar; maxLen: UInt16): Pointer;
                  SYS_TRAP(sysTrapSysErrString);

// This function is not to be called directly.  Instead, use the various Emu* calls
// in EmuTraps.h because they work for Poser, the device, and the simulator, and
// they are safer because of the type checking.
//UInt32 HostControl(HostControlTrapNumber selector, ...) SYS_TRAP(sysTrapHostControl);


implementation

end.
