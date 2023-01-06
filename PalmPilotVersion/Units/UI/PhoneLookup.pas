/******************************************************************************
 *
 * Copyright (c) 1994-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: PhoneLookup.h
 *
 * Description:
 *        This file defines phone number lookup structures and routines.
 *
 * History:
 *              July 23, 1996   Created by Art Lamb
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit PhoneLookup;

interface

Uses Field;

Procedure PhoneNumberLookup(var fldP: FieldType);
         SYS_TRAP(sysTrapPhoneNumberLookup);

implementation

end.

