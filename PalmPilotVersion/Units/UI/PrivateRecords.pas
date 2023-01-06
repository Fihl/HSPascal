/******************************************************************************
 *
 * Copyright (c) 1996-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: PrivateRecords.h
 *
 * Description:
 *        This header file defines a generic private record maintainance dialogs, etc.
 *
 * History:
 *              6/23/99.        Created by Craig Skinner
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit PrivateRecords;

interface

{$ifdef PalmVer35}
Uses
  Traps35;
// Defines needed for hidden record visual determination.
Type
  privateRecordViewEnum = (
    showPrivateRecords = 0x00,
    maskPrivateRecords,
    hidePrivateRecords
  );

//-----------------------------------------------------------------------
// Prototypes
//-----------------------------------------------------------------------

Function SecSelectViewStatus: privateRecordViewEnum;
      SYS_TRAP(sysTrapSecSelectViewStatus);

Function SecVerifyPW(newSecLevel: privateRecordViewEnum): Boolean;
      SYS_TRAP(sysTrapSecVerifyPW);

{$endif}

implementation

end.

