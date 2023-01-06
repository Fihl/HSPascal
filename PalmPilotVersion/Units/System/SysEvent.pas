/******************************************************************************
 *
 * Copyright (c) 1994-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: SysEvent.h
 *
 * Description:
 *        This file defines event structures and routines.
 *
 * History:
 *    September 26, 1994   Created by Art Lamb
 *       05/05/98 art   Add Text Services event.
 *       07/23/98 kwk   Changed UInt16 field in keyDown event to WChar.
 *       08/20/98 kwk   Split tsmEvent into tsmConfirmEvent & tsmFepButtonEvent.
 *       09/07/98 kwk   Added EvtPeekEvent routine declaration.
 *       10/13/98 kwk   Removed EvtPeekEvent until API can be finalized.
 *       03/11/99 grant Fixed types of pointers in SysEventType data fields.
 *       05/31/99 kwk   Added tsmFepModeEvent event.
 *       07/14/99 jesse Moved UI structures & constants to Event.h
 *                      defined ranges for future UI & system events.
 *       07/30/99 kwk   Moved TSM events here from Event.h
 *       09/12/99 gap   Add new multi-tap implementation
 *       09/14/99 gap   Removed EvtGetTrapState.
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit SysEvent;

interface

Uses Font, Rect, Window;

Type
  SysEventsEnum = (
    sysEventNilEvent = 0,
    sysEventPenDownEvent,
    sysEventPenUpEvent,
    sysEventPenMoveEvent,
    sysEventKeyDownEvent,
    sysEventWinEnterEvent,
    sysEventWinExitEvent,
    sysEventAppStopEvent = 22,
    sysEventTsmConfirmEvent = 35,
    sysEventTsmFepButtonEvent,
    sysEventTsmFepModeEvent,

    // add future UI level events in this numeric space
    // to save room for new system level events
    sysEventNextUIEvent = 0x0800,

    // <chg 2-25-98 RM> Equates added for library events
    sysEventFirstINetLibEvent = 0x1000,
    sysEventFirstWebLibEvent = 0x1100,

    // <chg 10/9/98 SCL> Changed firstUserEvent from 32767 (0x7FFF) to 0x6000
    // Enums are signed ints, so 32767 technically only allowed for ONE event.
    sysEventFirstUserEvent = 0x6000,
    sysEventLastUserEvent  = 0x7FFF
  );


Const
// keyDownEvent modifers
  shiftKeyMask       =0x0001;
  capsLockMask       =0x0002;
  numLockMask        =0x0004;
  commandKeyMask     =0x0008;
  optionKeyMask      =0x0010;
  controlKeyMask     =0x0020;
  autoRepeatKeyMask  =0x0040;      // True if generated due to auto-repeat
  doubleTapKeyMask   =0x0080;      // True if this is a double-tap event
  poweredOnKeyMask   =0x0100;      // True if this is a double-tap event
  appEvtHookKeyMask  =0x0200;      // True if this is an app hook key
  libEvtHookKeyMask  =0x0400;      // True if this is a library hook key

// define mask for all "virtual" keys
// appEvtHookKeyMask | libEvtHookKeyMask | commandKeyMask
  virtualKeyMask     =0x0608;


// Event timeouts
  evtWaitForever     =-1;
  evtNoWait          =0;


Type
  _GenericEventType = Record
    datum: array[0..7] of UInt16;
  end;

  _PenUpEventType = Record
    start: PointType;            // display coord. of stroke start
    _end: PointType;              // display coord. of stroke start
  end;

  _KeyDownEventType = Record
    chr: WChar;               // ascii code
    keyCode: UInt16;          // virtual key code
    modifiers: UInt16;
  end;

  _WinEnterEventType = Record
    enterWindow: WinHandle;
    exitWindow: WinHandle;
  end;

  _WinExitEventType = Record
    enterWindow: WinHandle;
    exitWindow: WinHandle;
  end;

  _TSMConfirmType = Record
    yomiText: pChar;
    formID: UInt16;
  end;

  _TSMFepButtonType = Record
    buttonID: UInt16;
  end;

  _TSMFepModeEventType = Record
    mode: UInt16;             // kwk - use real type for mode?
  end;


// The event record.
  SysEventType = Record
    eType: SysEventsEnum;
    penDown: Boolean;
    tapCount: UInt8;
    screenX: Coord;
    screenY: Coord;
    case integer of
    1: (generic: _GenericEventType);
    1: (penUp: _PenUpEventType);
    1: (keyDown: _KeyDownEventType);
    1: (winEnter: _WinEnterEventType);
    1: (winExit: _WinExitEventType);
    1: (tsmConfirm: _TSMConfirmType);
    1: (tsmFepButton: _TSMFepButtonType);
    1: (tsmFepMode: _TSMFepModeEventType);
    1: (data: array[0..19] of Byte);
  end;


// Events are stored in the event queue with some extra fields:
  SysEventStoreType = Record
    event: SysEventType;
    id: UInt32;                  // used to support EvtAddUniqueEvent
  end;


//---------------------------------------------------------------------
// Event Functions
//---------------------------------------------------------------------

/* jwm: This lot should be in a private header file, no? */

Procedure SysEventInitialize;
                     SYS_TRAP(sysTrapEvtInitialize);

Procedure SysEventAddToQueue (var Event: SysEventType);
                     SYS_TRAP(sysTrapEvtAddEventToQueue);

Procedure SysEventAddUniqueToQueue(var Event: SysEventType; id: UInt32;
            inPlace: Boolean);
                     SYS_TRAP(sysTrapEvtAddUniqueEventToQueue);

Procedure SysEventCopy (var SrcEvent: SysEventType; var DestEvent: SysEventType);
                     SYS_TRAP(sysTrapEvtCopyEvent);

Procedure SysEventGet (var Event: SysEventType; timeout: Int32);
                     SYS_TRAP(sysTrapEvtGetEvent);

Function  SysEventAvail: Boolean;
                     SYS_TRAP(sysTrapEvtEventAvail);

// For Compatibility.. source modules should use EvtGetPen instead.
//#define     PenGetPoint(a,b,c)    EvtGetPen(a,b,c)


// zzz  make into a routine
//#define EvtSetNullEventTick(tick)   \
//   if (NeedNullTickCount == 0 ||    \
//       NeedNullTickCount > tick ||  \
//       NeedNullTickCount <= TimGetTicks ())  \
//      NeedNullTickCount = tick;

implementation

end.

