/******************************************************************************
 *
 * Copyright (c) 1994-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: Event.h
 *
 * Description:
 *        This file defines UI event structures and routines.
 *
 * History:
 *              September 26, 1994      Created by Art Lamb
 *              07/14/99 jesse  Separated from Event.h
 *              09/12/99        gap     Add for new multi-tap implementation
 *              09/14/99        gap     Removed EvtGetTrapState.
 *              10/28/99        kwk     Added EvtKeydownIsVirtual macro.
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit Event;

interface

Uses Form, SysEvent, Window, Control, List, Day, Field, Table, ScrollBar, Menu;

Type
  eventsEnum = (
    nilEvent = 0,           // system level
    penDownEvent,           // system level
    penUpEvent,             // system level
    penMoveEvent,           // system level
    keyDownEvent,           // system level
    winEnterEvent,          // system level
    winExitEvent,           // system level
    ctlEnterEvent,
    ctlExitEvent,
    ctlSelectEvent,
    ctlRepeatEvent,
    lstEnterEvent,
    lstSelectEvent,
    lstExitEvent,
    popSelectEvent,
    fldEnterEvent,
    fldHeightChangedEvent,
    fldChangedEvent,
    tblEnterEvent,
    tblSelectEvent,
    daySelectEvent,
    menuEvent,
    appStopEvent = 22,         // system level
    frmLoadEvent,
    frmOpenEvent,
    frmGotoEvent,
    frmUpdateEvent,
    frmSaveEvent,
    frmCloseEvent,             // = $1C
    frmTitleEnterEvent,
    frmTitleSelectEvent,
    tblExitEvent,
    sclEnterEvent,
    sclExitEvent,
    sclRepeatEvent,
    tsmConfirmEvent = 35,      // system level
    tsmFepButtonEvent,         // system level
    tsmFepModeEvent,           // system level
    attnIndicatorEnterEvent,    // for attention manager's indicator
    attnIndicatorSelectEvent,   // for attention manager's indicator

    // add future UI level events in this numeric space
    // to save room for new system level events
    menuCmdBarOpenEvent = 0x0800,
    menuOpenEvent,
    menuCloseEvent,
    frmGadgetEnterEvent,
    frmGadgetMiscEvent,

    // <chg 2-25-98 RM> Equates added for library events
    firstINetLibEvent = 0x1000,
    firstINetLibEventPlus1 = 0x1001,  //Cannot add enumerated 
    firstWebLibEvent = 0x1100,

    // <chg 10/9/98 SCL> Changed firstUserEvent from 32767 (0x7FFF) to 0x6000
    // Enums are signed ints, so 32767 technically only allowed for ONE event.
    firstUserEvent = 0x6000,
    lastUserEvent  = 0x7FFF
  );

  // The event record.
  EventPtr = ^EventType;
  EventType = Record
    eType: eventsEnum;      //16 bits
    penDown: Boolean;
    tapCount: UInt8;
    screenX: Coord;
    screenY: Coord;
    data: Record
    Case Integer of
      0: (EventRaw: Array[0..19] of Byte);
      1: (generic: _GenericEventType);
      1: (penUp: _PenUpEventType);
      1: (keyDown: _KeyDownEventType);
      1: (winEnter: _WinEnterEventType);
      1: (winExit: _WinExitEventType);
      1: (tsmConfirm: _TSMConfirmType);
      1: (tsmFepButton: _TSMFepButtonType);
      1: (tsmFepMode: _TSMFepModeEventType);
      1: (ctlEnter: Record
               controlID: UInt16;
               pControl: ControlPtr;
             end);
      1: (ctlSelect: Record
           controlID: UInt16;
           pControl: ControlPtr;
           on: Boolean;
           reserved1: UInt8;
           value: UInt16;                 // used for slider controls only
         End);

      1: (ctlRepeat: Record
           controlID: UInt16;
           pControl: ControlPtr;
           time: UInt32;
           value: UInt16; // used for slider controls only
         End);

      1: (ctlExit: Record
           controlID: UInt16;
           pControl: ControlPtr;
         End);           

      1: (fldEnter: Record
           fieldID: UInt16;
           pField: FieldPtr;
         End);

      1: (fldHeightChanged: Record
           fieldID: UInt16;
           pField: FieldPtr;
           newHeight: Int16;
           currentPos: UInt16;
         End);

      1: (fldChanged: Record
           fieldID: UInt16;
           pField: FieldPtr;
         End);

      1: (fldExit: Record
           fieldID: UInt16;
           pField: FieldPtr;
         End);

      1: (lstEnter: Record
           listID: UInt16;
           pList: ListPtr;
           selection: Int16;
         End);

      1: (lstExit: Record
           listID: UInt16;
           pList: ListPtr;
         End);

      1: (lstSelect: Record
           listID: UInt16;
           pList: ListPtr;
           selection: Int16;
         End);

      1: (tblEnter: Record
           tableID: UInt16;
           pTable: TablePtr;
           row: Int16;
           column: Int16;
         End);

      1: (tblExit: Record
           tableID: UInt16;
           pTable: TablePtr;
           row: Int16;
           column: Int16;
         End);

      1: (tblSelect: Record
           tableID: UInt16;
           pTable: TablePtr;
           row: Int16;
           column: Int16;
         End);

      1: (frmLoad: Record formID: UInt16 end);
      1: (frmOpen: Record formID: UInt16 end);
      1: (frmGoto: Record
           formID: UInt16
           recordNum: UInt16        // index of record that contain a match
           matchPos: UInt16         // postion in record of the match.
           matchLen: UInt16         // length of match.
           matchFieldNum: UInt16    // field number string was found int
           matchCustom: UInt16      // application specific info
         end);

      1: (frmClose: Record
           formID: UInt16;
         End);

      1: (frmUpdate: Record
           formID: UInt16;
           updateCode: UInt16;           // Application specific
         End);

      1: (frmTitleEnter: Record
           formID: UInt16;
         End);

      1: (frmTitleSelect: Record
           formID: UInt16;
         End);

      1: (attnIndicatorEnter: Record
           formID: UInt16;
         End);

      1: (attnIndicatorSelect: Record
           formID: UInt16;
         End);

      1: (daySelect: Record
           pSelector: DaySelectorPtr;
           selection: Int16;
           useThisDate: Boolean;
           reserved1: UInt8;
         End);

      1: (menu: Record
           itemID: UInt16;
         End);

      1: (popSelect: Record
           controlID: UInt16;
           pControl: ControlPtr;
           listID: UInt16;
           pList: ListPtr;
           selection: Int16;
           priorSelection: Int16;
         End);

      1: (sclEnter: Record
           scrollBarID: UInt16;
           pScrollBar: ScrollBarPtr;
         End);

      1: (sclExit: Record
           scrollBarID: UInt16;
           pScrollBar: ScrollBarPtr;
           value: Int16;
           newValue: Int16;
         End);

      1: (sclRepeat: Record
           scrollBarID: UInt16;
           pScrollBar: ScrollBarPtr;
           value: Int16;
           newValue: Int16;
           time: UInt32;
         End);

      1: (menuCmdBarOpen: Record
           preventFieldButtons: Boolean; // set to stop the field from automatically adding cut/copy/paste
           reserved: UInt8;
         End);

      1: (menuOpen: Record
           menuRscID: UInt16;
           //pMenu: MenuBarPtr;
           cause: Int16;
         End);
      
      1: (gadgetEnter: Record
           gadgetID: UInt16;            // must be same as gadgetMisc
           pGadget: FormGadgetPtr;      // must be same as gadgetMisc
         End);

      1: (gadgetMisc: Record
           gadgetID: UInt16;            // must be same as gadgetEnter
           pGadget: FormGadgetPtr;      // must be same as gadgetEnter
           selector: UInt16;
           pData: MemPtr;
         End);

      end;
   end;

//---------------------------------------------------------------------
// Event Functions
//---------------------------------------------------------------------

Procedure EvtAddEventToQueue(var Event: EventType); SYS_TRAP(sysTrapEvtAddEventToQueue);

Procedure EvtAddUniqueEventToQueue(var Event: EventType; id: UInt32;
            inPlace: Boolean); SYS_TRAP(sysTrapEvtAddUniqueEventToQueue);

Procedure EvtCopyEvent(var Source, Dest: EventType); SYS_TRAP(sysTrapEvtCopyEvent);

Procedure EvtGetEvent(var Event: EventType; timeout: Int32); SYS_TRAP(sysTrapEvtGetEvent);

function  EvtEventAvail: Boolean; SYS_TRAP(sysTrapEvtEventAvail);

Procedure EvtGetPen(var pScreenX, pScreenY: Int16; var pPenDown: Boolean);
  SYS_TRAP(sysTrapEvtGetPen);

implementation

end.

