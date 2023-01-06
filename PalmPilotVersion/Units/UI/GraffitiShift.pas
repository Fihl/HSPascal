/******************************************************************************
 *
 * Copyright (c) 1995-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: GraffitiShift.h
 *
 * Description:
 *        This file defines Griffiti shift state indicator routines.
 *
 * History:
 *              Aug 24, 1995    Created by Art Lamb
 *      mm/dd/yy   initials - brief revision comment
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit GraffitiShift;

interface

Const
  // Graffiti lock flags
  glfCapsLock   =0x01;
  glfNumLock    =0x02;

Type
  GsiShiftState = (
    gsiShiftNone,           // no indicator
    gsiNumLock,             // numeric lock
    gsiCapsLock,            // capital lock
    gsiShiftPunctuation,    // punctuation shift
    gsiShiftExtended,       // extented punctuation shift
    gsiShiftUpper,          // alpha upper case shift
    gsiShiftLower           // alpha lower case
  );

Procedure GsiInitialize;
                     SYS_TRAP(sysTrapGsiInitialize);

Procedure GsiSetLocation(x, y: Int16);
                     SYS_TRAP(sysTrapGsiSetLocation);

Procedure GsiEnable(enableIt: Boolean);
                     SYS_TRAP(sysTrapGsiEnable);

Function GsiEnabled: Boolean;
                     SYS_TRAP(sysTrapGsiEnabled);

Procedure GsiSetShiftState(lockFlags, tempShift: UInt16);
                     SYS_TRAP(sysTrapGsiSetShiftState);

implementation

end.

