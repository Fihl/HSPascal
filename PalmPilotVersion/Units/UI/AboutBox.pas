/******************************************************************************
 *
 * Copyright (c) 1995-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: AboutBox.h
 *
 * Description:
 *        This file defines About Box routines
 *
 * History:
 *              October 25th, 1995      Created by Christopher Raff
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit AboutBox;

interface

Procedure AbtShowAbout(Creator: UInt32);
                         SYS_TRAP(sysTrapAbtShowAbout);

implementation

end.

