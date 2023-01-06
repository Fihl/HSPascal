/******************************************************************************
 *
 * Copyright (c) 1994-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: SelDay.h
 *
 * Description:
 *        This file defines the date picker month object's  structures
 *   and routines.
 *
 * History:
 *              November 10, 1994       Created by Roger Flores
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit SelDay;

interface

Uses DateTime, Day;

Const
  daySelectorMinYear  =firstYear;
  daySelectorMaxYear  =lastYear;

Function SelectDayV10(var month, day, year: Int16; Const title: String): Boolean;
         SYS_TRAP(sysTrapSelectDayV10);

Function SelectDay(selectDayBy: SelectDayType;
                   var month, day, year: Int16; Const title: String): Boolean;
         SYS_TRAP(sysTrapSelectDay);

implementation

end.

