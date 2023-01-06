/******************************************************************************
 *
 * Copyright (c) 1994-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: SelTime.h
 *
 * Description:
 *        This file defines select time structures and routines.
 *
 * History:
 *              December 6, 1994        Created by Roger Flores
 *           Nick Twyman 8/4/98. Added SelectOneTime trap
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit SelTime;

interface

Uses {$ifdef PalmVer35} Traps31, Traps35, {$endif}
     DateTime;

//-------------------------------------------------------------------
// structures
//-------------------------------------------------------------------

Type
  HMSTime = Record
    hours: UInt8;
    minutes: UInt8;
    seconds: UInt8;
    reserved: UInt8;
  end;

// This is slated to be deleted in the next version.
Function SelectTimeV33(var startTimeP, EndTimeP: TimeType;
                       untimed: Boolean; Const title: String; startOfDay: Int16): Boolean;
                  SYS_TRAP(sysTrapSelectTimeV33);

{$ifdef PalmVer35}
Function SelectTime(var startTimeP, EndTimeP: TimeType;
                    untimed: Boolean; Const title: String;
                    startOfDay, endOfDay, startOfDisplay: Int16): Boolean;
                  SYS_TRAP(sysTrapSelectTime);

Function SelectOneTime(var hour, minute: Int16; Const title: String): Boolean;
                  SYS_TRAP(sysTrapSelectOneTime);
{$endif}

implementation

end.

