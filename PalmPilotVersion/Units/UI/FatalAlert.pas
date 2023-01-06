/******************************************************************************
 *
 * Copyright (c) 1994-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: FatalAlert.h
 *
 * Description:
 *        This file defines the system Fatal Alert support.
 *
 * History:
 *              September 12, 1994      Created by Art Lamb
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit FatalAlert;

interface

{$ifdef PalmVer35} Uses Traps35; {$endif}

// Value returned by SysFatalAlert
Const
  fatalReset         =0;
  fatalEnterDebugger =1;
  fatalDoNothing     =-1;
  fatalDoNothingU    =$FFFF;

Function SysFatalAlert(Const msg: String): UInt16;
      SYS_TRAP(sysTrapSysFatalAlert);

{$ifdef PalmVer35}
Procedure SysFatalAlertInit; SYS_TRAP(sysTrapSysFatalAlertInit);
{$endif}

implementation

end.

