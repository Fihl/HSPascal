/******************************************************************************
 *
 * Copyright (c) 1994-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: PenMgr.h
 *
 * Description:
 *    Include file for Pen manager
 *
 * History:
 *    6/5/96 Created by Ron Marianetti
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit PenMgr;

interface

Uses Rect, ErrorBase;

/********************************************************************
 * Pen Manager Errors
 * the constant serErrorClass is defined in ErrorBase.h
 ********************************************************************/
Const
  penErrBadParam          =penErrorClass | 1;
  penErrIgnorePoint       =penErrorClass | 2;


/********************************************************************
 * Pen manager Routines
 ********************************************************************/


// Initializes the Pen Manager
Function PenOpen: Err;
            SYS_TRAP(sysTrapPenOpen);

// Closes the Pen Manager and frees whatever memory it allocated
Function PenClose: Err;
            SYS_TRAP(sysTrapPenClose);


// Put pen to sleep
Function PenSleep: Err;
            SYS_TRAP(sysTrapPenSleep);

// Wake pen
Function PenWake: Err;
            SYS_TRAP(sysTrapPenWake);


// Get the raw pen coordinates from the hardware.
Function PenGetRawPen(var penP: PointType): Err;
            SYS_TRAP(sysTrapPenGetRawPen);
            
// Reset calibration in preparation for setting it again
Function PenResetCalibration: Err;
            SYS_TRAP(sysTrapPenResetCalibration);

// Set calibration settings for the pen
Function PenCalibrate (
            var digTopLeftP, digBotRightP, scrTopLeftP, scrBotRightP: PointType): Err;
            SYS_TRAP(sysTrapPenCalibrate);

// Scale a raw pen coordinate into screen coordinates
Function PenRawToScreen(var penP: PointType): Err;
            SYS_TRAP(sysTrapPenRawToScreen);

// Scale a screen pen coordinate back into a raw coordinate
Function PenScreenToRaw(var penP: PointType): Err;
            SYS_TRAP(sysTrapPenScreenToRaw);
            
implementation

end.

