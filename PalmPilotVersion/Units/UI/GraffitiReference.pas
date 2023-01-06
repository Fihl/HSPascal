/******************************************************************************
 *
 * Copyright (c) 1996-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: GraffitiReference.h
 *
 * Description:
 *        This file defines the Graffiti Reference routines.
 *
 * History:
 *              June 25, 1996   Created by Roger Flores
 *              06/25/96        rsf     Created by Roger Flores
 *              07/30/99        kwk     Moved all reference types other than referenceDefault
 *                                                      into GraffitiReference.c
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit GraffitiReference;

interface

Type
  ReferenceType = (referenceDefault = 0xff);    // based on graffiti mode

/************************************************************
 * Graffiti Reference procedures
 *************************************************************/

Procedure SysGraffitiReferenceDialog(refType: ReferenceType);
                     SYS_TRAP(sysTrapSysGraffitiReferenceDialog);

implementation

end.

