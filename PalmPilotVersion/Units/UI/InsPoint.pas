/******************************************************************************
 *
 * Copyright (c) 1995-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: InsPoint.h
 *
 * Description:
 *        This file defines insertion point routines.
 *
 * History:
 *              Jan 25, 1995    Created by Art Lamb
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit InsPoint;

interface

// Blink interval is half of a second
Const
  //insPtBlinkInterval   =(sysTicksPerSecond / 2);
  insPtWidth           =2;

Procedure InsPtInitialize;
                     SYS_TRAP(sysTrapInsPtInitialize);

Procedure InsPtSetLocation (x,y: Int16);
                     SYS_TRAP(sysTrapInsPtSetLocation);

Procedure InsPtGetLocation (var x,y: Int16);
                     SYS_TRAP(sysTrapInsPtGetLocation);

Procedure InsPtEnable (enableIt: Boolean);
                     SYS_TRAP(sysTrapInsPtEnable);

Function InsPtEnabled: Boolean;
                     SYS_TRAP(sysTrapInsPtEnabled);

Procedure InsPtSetHeight(height: Int16);
                     SYS_TRAP(sysTrapInsPtSetHeight);

Function InsPtGetHeight: Int16;
                     SYS_TRAP(sysTrapInsPtGetHeight);

Procedure InsPtCheckBlink;
                     SYS_TRAP(sysTrapInsPtCheckBlink);

implementation

end.

