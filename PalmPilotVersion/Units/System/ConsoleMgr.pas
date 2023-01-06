/******************************************************************************
 *
 * Copyright (c) 1994-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: ConsoleMgr.h
 *
 * Description:
 *    This module implements simple text in and text out to a console
 *  application on the other end of the serial port. It talks through
 *  the Serial Link Manager and sends and receives packets of type slkPktTypeConsole.
 *
 * History:
 *    10/25/94  RM - Created by Ron Marianetti
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit ConsoleMgr;

interface


/********************************************************************
 * Console Manager Routines
 ********************************************************************/

Function ConPutS(Const Message: String): Err;
            SYS_TRAP(sysTrapConPutS);

Function ConGetS(Message: pChar; Timeout: Int32): Err;
            SYS_TRAP(sysTrapConGetS);


implementation

end.

