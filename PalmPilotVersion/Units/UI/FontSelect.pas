/******************************************************************************
 *
 * Copyright (c) 1997-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: FontSelect.h
 *
 * Description:
 *        This file defines the font selector routine.
 *
 * History:
 *              September 10, 1997      Created by Art Lamb
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit FontSelect;

interface

{$ifdef PalmVer30}
Uses Font, Traps30;

Function FontSelect(fid: FontID): FontID; SYS_TRAP(sysTrapFontSelect);
{$endif}

implementation

end.

