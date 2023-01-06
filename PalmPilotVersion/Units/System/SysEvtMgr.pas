/******************************************************************************
 *
 * Copyright (c) 1994-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: SysEvtMgr.h
 *
 * Description:
 *    Header for the System Event Manager
 *
 * History:
 *    03/22/95 RM    Created by Ron Marianetti
 *    07/23/98 kwk   Changed UInt16 param in EvtEnqueueKey to WChar.
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit SysEvtMgr;

interface

Uses {$ifdef PalmVer35} Traps35, {$endif}
     Rect, ErrorBase, SysEvent;

Const
/************************************************************
 * System Event Manager Errors
 *************************************************************/
  evtErrParamErr       = evtErrorClass | 1;
  evtErrQueueFull      = evtErrorClass | 2;
  evtErrQueueEmpty     = evtErrorClass | 3;

Type
/************************************************************
 * Commands for EvtSetAutoOffTimer()
 *************************************************************/
  EvtSetAutoOffCmd = (
    SetAtLeast,    // turn off in at least xxx seconds
    SetExactly,    // turn off in xxx seconds
    SetAtMost,     // turn off in at most xxx seconds
    SetDefault,    // change default auto-off timeout to xxx seconds
    ResetTimer     // reset the timer to the default auto-off timeout
  );


/*************************************************************
 * System Event Manager procedures
 *************************************************************/

//-----------------------------------------------------------------
// High Level Calls
//------------------------------------------------------------------
Function EvtSysInit: Err;
                  SYS_TRAP(sysTrapEvtSysInit);

// Return next "System" event. This routine will send strokes to Graffiti as necessary
//  and return a key event. Otherwise, it will return a simple pen down or pen
//  up event, or put the processor to sleep for a max time of 'timeout' if
// no events are available.
Procedure EvtGetSysEvent(var Event: SysEventType; timeout: Int32);
                  SYS_TRAP(sysTrapEvtGetSysEvent);


// Return true if there is a low level system event (pen or key) available
Function EvtSysEventAvail(ignorePenUps: Boolean): Boolean;
                  SYS_TRAP(sysTrapEvtSysEventAvail);


// Translate a stroke in the silk screen area to a key event
Function EvtProcessSoftKeyStroke(var startPtP, endPtP: PointType): Err;
                  SYS_TRAP(sysTrapEvtProcessSoftKeyStroke);


//-----------------------------------------------------------------
// Pen Queue Utilties
//------------------------------------------------------------------

// Replace current pen queue with another of the given size
Function EvtSetPenQueuePtr(penQueueP: MemPtr; size: UInt32): Err;
                  SYS_TRAP(sysTrapEvtSetPenQueuePtr);

// Return size of current pen queue in bytes
Function EvtPenQueueSize: UInt32;
                  SYS_TRAP(sysTrapEvtPenQueueSize);

// Flush the pen queue
Function EvtFlushPenQueue: Err;
                  SYS_TRAP(sysTrapEvtFlushPenQueue);


// Append a point to the pen queue. Passing -1 for x and y means 
//  pen-up (terminate the current stroke). Called by digitizer interrupt routine
Function EvtEnqueuePenPoint(var ptP: PointType): Err;
                  SYS_TRAP(sysTrapEvtEnqueuePenPoint);


// Return the stroke info for the next stroke in the pen queue. This MUST
//  be the first call when removing a stroke from the queue
Function EvtDequeuePenStrokeInfo(var startPtP, endPtP: PointType): Err;
                  SYS_TRAP(sysTrapEvtDequeuePenStrokeInfo);

// Dequeue the next point from the pen queue. Returns non-0 if no
//  more points. The point returned will be (-1,-1) at the end
//  of the stroke.
Function EvtDequeuePenPoint(var retP: PointType): Err;
                  SYS_TRAP(sysTrapEvtDequeuePenPoint);


// Flush the entire stroke from the pen queue and dispose it
Function EvtFlushNextPenStroke: Err;
                  SYS_TRAP(sysTrapEvtFlushNextPenStroke);




//-----------------------------------------------------------------
// Key Queue Utilties
//------------------------------------------------------------------

// Replace current key queue with another of the given size. This routine will
//  intialize the given key queue before installing it
Function EvtSetKeyQueuePtr(keyQueueP: MemPtr; size: UInt32): Err;
                  SYS_TRAP(sysTrapEvtSetKeyQueuePtr);

// Return size of current key queue in bytes
Function EvtKeyQueueSize: UInt32;
                  SYS_TRAP(sysTrapEvtKeyQueueSize);

// Flush the key queue
Function EvtFlushKeyQueue: Err;
                  SYS_TRAP(sysTrapEvtFlushKeyQueue);


// Append a key to the key queue. 
Function EvtEnqueueKey(ascii: WChar; keycode, modifiers: UInt16): Err;
                  SYS_TRAP(sysTrapEvtEnqueueKey);

// Return true of key queue empty.
Function EvtKeyQueueEmpty: Boolean;
                  SYS_TRAP(sysTrapEvtKeyQueueEmpty);


// Pop off the next key event from the key queue and fill in the given
//  event record structure. Returns non-zero if there aren't any keys in the
//  key queue. If peek is non-zero, key will be left in key queue.
Function EvtDequeueKeyEvent(var Event: SysEventType; peek: UInt16): Err;
                  SYS_TRAP(sysTrapEvtDequeueKeyEvent);


//-----------------------------------------------------------------
// General Utilities
//------------------------------------------------------------------
// Force the system to wake-up. This will result in a null event being
//  sent to the current app.
Function EvtWakeup: Err;
                  SYS_TRAP(sysTrapEvtWakeup);

// Reset the auto-off timer. This is called by the SerialLink Manager in order
//  so we don't auto-off while receiving data over the serial port.
Function EvtResetAutoOffTimer: Err;
                  SYS_TRAP(sysTrapEvtResetAutoOffTimer);

{$ifdef PalmVer35}
Function EvtSetAutoOffTimer(cmd: EvtSetAutoOffCmd; timeout: UInt16): Err;
                  SYS_TRAP(sysTrapEvtSetAutoOffTimer);
{$endif}

// Set Graffiti enabled or disabled.
Procedure EvtEnableGraffiti(enable: Boolean);
                  SYS_TRAP(sysTrapEvtEnableGraffiti);

implementation

end.

