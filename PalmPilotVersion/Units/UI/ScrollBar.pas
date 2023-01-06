/******************************************************************************
 *
 * Copyright (c) 1996-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: ScrollBar.h
 *
 * Description:
 *        This file defines scroll bar structures and routines.
 *
 * History:
 *              Feb 6, 1996     Created by Art Lamb
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit ScrollBar;

interface

Uses Rect{, Event};

Type
   ScrollBarRegionType = (sclUpArrow, sclDownArrow, sclUpPage, sclDownPage, sclCar);

   ScrollBarAttrType = Record
     Flags: UInt16;
     // usable       :1;      // Set if part of ui
     // visible         :1;      // Set if drawn, used internally
     // hilighted    :1;      // Set if region is hilighted
     // shown        :1;      // Set if drawn and maxValue > minValue
     // activeRegion         :4;    // ScrollBarRegionType
   end;

   ScrollBarPtr = ^ScrollBarType;
   ScrollBarType = Record
     bounds: RectangleType;
     id: UInt16;
     attr: ScrollBarAttrType;
     value: Int16
     minValue: Int16
     maxValue: Int16
     pageSize: Int16
     penPosInCar: Int16
     savePos: Int16
   end;

Procedure SclGetScrollBar(bar: ScrollBarPtr; var valueP, minP, maxP, pageSizeP: Int16);
                     SYS_TRAP(sysTrapSclGetScrollBar);

Procedure SclSetScrollBar(bar: ScrollBarPtr; value, min, max, pageSize: Int16);
                     SYS_TRAP(sysTrapSclSetScrollBar);

Procedure SclDrawScrollBar(bar: ScrollBarPtr);
                     SYS_TRAP(sysTrapSclDrawScrollBar);

Function SclHandleEvent(bar: ScrollBarPtr; Var Event{: EventType}): Boolean;
                     SYS_TRAP(sysTrapSclHandleEvent);

implementation

end.

