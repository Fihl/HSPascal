/******************************************************************************
 *
 * Copyright (c) 1995-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: Crc.h
 *
 * Description:
 *    This is the header file for the CRC calculation routines for Pilot.
 *
 * History:
 *    May 10, 1995   Created by Vitaly Kruglikov
 *    05/10/95 vmk   Created by Vitaly Kruglikov.
 *    09/10/99 kwk   Crc16CalcBlock takes a const void *.
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit Crc; 

interface

/********************************************************************
 * CRC Calculation Routines
 * These are define as external calls only under emulation mode or
 *  under native mode from the module that actually installs the trap
 *  vectors
 ********************************************************************/

//-------------------------------------------------------------------
// API
//-------------------------------------------------------------------

// Crc16CalcBlock()
//
// Calculate the 16-bit CRC of a data block using the table lookup method.
//
Function Crc16CalcBlock(bufP: Pointer; count, crc: UInt16): UInt16;
                     SYS_TRAP(sysTrapCrc16CalcBlock);

//Function Crc16CalcBigBlock(bufP: Pointer; count: UInt32; crc: UInt16): UInt16;

implementation

end.

