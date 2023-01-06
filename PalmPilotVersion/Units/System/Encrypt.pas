/******************************************************************************
 *
 * Copyright (c) 1994-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: Encrypt.h
 *
 * Description:
 *    Equates for encryption/digestion routines in pilot
 *
 * History:
 *    7/31/96  RM - Created by Ron Marianetti   
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit Encrypt;

interface

/************************************************************
 * Function Prototypes
 *************************************************************/

// Perform reversible encryption or decryption of 8 byte string in
//  srcP using 8 byte key keyP. Place 8 byte result in dstP.
Function EncDES(var srcP, keyP, dstP; encrypt: Boolean): Err;
         SYS_TRAP(sysTrapEncDES);


// Digest a string of bytes and produce a 128 bit result using
//   the MD4 algorithm.
Function EncDigestMD4(var strP; strLen: UInt16; var digestP16): Err;
         SYS_TRAP(sysTrapEncDigestMD4);


// Digest a string of bytes and produce a 128 bit result using
//   the MD5 algorithm.
//Function EncDigestMD5(UInt8 * strP, UInt16 strLen, UInt8 digestP[16]): Err;
Function EncDigestMD5(var strP; strLen: UInt16; var digestP16): Err;
         SYS_TRAP(sysTrapEncDigestMD5);

implementation

end.

