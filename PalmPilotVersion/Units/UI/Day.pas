/******************************************************************************
 *
 * Copyright (c) 1994-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: Day.h
 *
 * Description:
 *        This file defines the date picker month object's  structures 
 *   and routines.
 *
 * History:
 *              May 31, 1995    Created by Roger Flores
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit Day;

interface

Uses DateTime, {Event, {}Rect;

Type
  SelectDayType = (
    selectDayByDay,      // return d/m/y
    selectDayByWeek,     // return d/m/y with d as same day of the week
    selectDayByMonth     // return d/m/y with d as same day of the month
  );

  DaySelectorPtr = ^DaySelectorType;
  DaySelectorType = Record
    bounds: RectangleType;
    visible: Boolean;
    reserved1: UInt8;
    visibleMonth: Int16;     // month actually displayed
    visibleYear: Int16;      // year actually displayed
    selected: DateTimeType;
    selectDayBy: SelectDayType;
    reserved2: UInt8;
  end;

Procedure DayDrawDaySelector(selectorP: DaySelectorPtr);
         SYS_TRAP(sysTrapDayDrawDaySelector);

Function DayHandleEvent(selectorP: DaySelectorPtr; var Event{: EventType}): Boolean;
         SYS_TRAP(sysTrapDayHandleEvent);

Procedure DayDrawDays(selectorP: DaySelectorPtr);
         SYS_TRAP(sysTrapDayDrawDays);

implementation

end.

