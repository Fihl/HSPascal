/******************************************************************************
 *
 * Copyright (c) 1995-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: Launcher.h
 *
 * Description:
 *        These are the routines for the launcher.
 *
 * History:
 *              April 27, 1995  Created by Roger Flores
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit Launcher;

interface

Uses Window, Form, DateTime;

Type
  LauncherPtr = ^LauncherType;
  LauncherType = Record
    form: FormPtr;
    numItems: Int16;            // numItems of applications available via the launcher
    columns: Int16;
    rows: Int16;
    topItem: Int16;
    selection: Int8;
    reserved: UInt8;
    appInfoH: MemHandle;        // an array is to be allocated
    timeFormat: TimeFormatType; // Format to display time in
    timeString: array[0..timeStringLength] of Char;
    savedForm: FormPtr;         // the currently active dialog.
  end;

/************************************************************
 * Launcher procedures
 *************************************************************/

Procedure SysAppLauncherDialog; SYS_TRAP(sysTrapSysAppLauncherDialog);

implementation

end.

