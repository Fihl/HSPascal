/******************************************************************************
 *
 * Copyright (c) 1994-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: FeatureMgr.h
 *
 * Description:
 *    Header for the Feature Manager
 *
 * History:
 *    11/14/94  RM - Created by Ron Marianetti
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit FeatureMgr;

interface

uses
  {x$ifdef PalmVer31} Traps31, {x$endif}
  ErrorBase;

/************************************************************
 * Feature manager error codes
 * the constant ftrErrorClass is defined in ErrorBase.h
 *************************************************************/
Const
  ftrErrInvalidParam            = ftrErrorClass | 1;
  ftrErrNoSuchFeature           = ftrErrorClass | 2;
  ftrErrAlreadyExists           = ftrErrorClass | 3;
  ftrErrROMBased                = ftrErrorClass | 4;
  ftrErrInternalErr             = ftrErrorClass | 5;


/************************************************************
 * Feature Manager procedures
 *************************************************************/

// HSPascal!
//
// Remember to use function s2u32(Const S: String): UInt32 as defined in HSUtils
// Use it as: x:=FtrPtrNew(s2u32('TEST'), 123, 8, MyPointer);

// Init the feature Manager
Function FtrInit: Err;
                     SYS_TRAP(sysTrapFtrInit);

// Get a feature
Function FtrGet(creator: UInt32; featureNum: UInt16; var valueP: UInt32): Err;
                     SYS_TRAP(sysTrapFtrGet);

// Set/Create a feature.
Function FtrSet(creator: UInt32; featureNum: UInt16; newValue: UInt32): Err;
                     SYS_TRAP(sysTrapFtrSet);

// Unregister a feature
Function FtrUnregister(creator: UInt32; featureNum: UInt16): Err;
                     SYS_TRAP(sysTrapFtrUnregister);

// Get a feature by index
Function FtrGetByIndex(index: UInt16; romTable: Boolean;
               var creatorP: UInt32; var numP: UInt16; var valueP: UInt32): Err;
                     SYS_TRAP(sysTrapFtrGetByIndex);

// Get temporary space from storage heap
Function FtrPtrNew(creator: UInt32; featureNum: UInt16; size: UInt32; var newPtrP: Pointer): Err;
                     SYS_TRAP(sysTrapFtrPtrNew);

// Release temporary space to storage heap
Function FtrPtrFree(creator: UInt32; featureNum: UInt16): Err;
                     SYS_TRAP(sysTrapFtrPtrFree);


// Resize block of temporary storage
Function FtrPtrResize(creator: UInt32; featureNum: UInt16; newSize: UInt32; var newPtrP: Pointer) : Err;
                     SYS_TRAP(sysTrapFtrPtrResize);

implementation

end.

