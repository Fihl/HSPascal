/*
 -------------------------------------------------------------------------
 Copyright (c) 2002, Cooperative Computers, Inc., Mountain View, CA, USA.
 All rights reserved.
 (c) HSPascal September-2002, Pascal syntax for HSPascal http://HSPascal.Fihl.net

 LICENSE TERMS

 The free distribution and use of this software in both source and binary
 form is allowed (with or without changes) provided that:

   1. distributions of this source code include the above copyright
      notice, this list of conditions and the following disclaimer;

   2. distributions in binary form include the above copyright
      notice, this list of conditions and the following disclaimer
      in the documentation and/or other associated materials;

   3. the copyright holder's name is not used to endorse products
      built using this software without specific written permission.

 DISCLAIMER

 This software is provided 'as is' with no explcit or implied warranties
 in respect of any properties, including, but not limited to, correctness
 and fitness for purpose.
 -------------------------------------------------------------------------
 Issue Date: September 9, 2002
*/
/*************************************************************************
 *
 * Credit where Credit is due:
 *
 * Dr. Brian Gladman
 * -----------------
 *
 * The underlying AES implementation was developed by Dr. Brian Gladman.
 * Please visit his AES website at :
 *     http://fp.gladman.plus.com/cryptography_technology/rijndael/
 *
 * AESLib does it best to preserve Dr. Gladman's code, structure, and
 * flexibility.
 *
 * Duncan Wong of Northeastern University
 * --------------------------------------
 *
 * Duncan Wong provided me with the source code to his AES implementation
 * for Palm OS.  Wong discovered the importance of placing the AES tables
 * in the storage heap, as opposed to trying to allocate dynamic memory
 * for them.  Wong's implementation created a Palm Database to contain
 * the tables.  This implementation stored those tables as resources
 * within AESLib Resource Database instead of creating a separate
 * database.
 * Please visit his AES for Palm OS website at:
 *     http://www.ccs.neu.edu/home/ahchan/wsl/PalmCryptoLib/Rijndael/
 *
 * September 9th, 2002     -   Stuart Eichert (Cooperative Computers, Inc.)
 *
 ************************************************************************/

/*************************************************************************
 *
 * ARM Processor support
 *
 * This release of AESLib contains support for the ARM processor and OS/5.
 * Specifically an additional ARM code resource is included that will be
 * called when running on ARM hardware.
 *
 * For the best performance, it is recommended that developers allocate
 * their aes_ctx structures using MemPtrNew in order to ensure that they
 * are 4 byte aligned.  If the structure is not 4 byte aligned AESLib
 * has to move it into a piece of memory that is.  This copy slows down
 * performance of the library.
 *
 * Preliminary results show AESLib running approximately 3 times faster
 * on ARM hardware.
 ************************************************************************/

Unit AESLib;

Interface

/* Palm OS common definitions */
Uses SystemMgr, SystemResources,ErrorBase;

//HSPascal extensions
Type AESblk16=String[16];   // now 17 bytes!  Array[0..15] of Char;
Const sysLibTrapBase = sysLibTrapName;

/*************************************************************************
 *
 * The BLOCK_SIZE, KS_LENGTH, and definition of aes_ctx are usually found
 * in aes.h, but for this shared library they are moved to AESLib.h so
 * that developers only have to include one header file.
 *
 ************************************************************************/

Const
  BLOCK_SIZE =16;
  KS_LENGTH  =64; //4 * BLOCK_SIZE;

Type
  aes_fret=UInt16;   /* type for function return value       */
  aes_rval = aes_fret;
Const aes_bad     =0;           /* bad function return value            */
Const aes_good    =1;           /* good function return value           */


/**********************************************************************
 *
 * Remember to zero the aes_ctx structure before using it.
 *
 **********************************************************************/

/* Important structures */
Type
  aes_ctx = Record
    k_sch: Array [0..KS_LENGTH-1] of UInt32;   /* the encryption key schedule */
    n_rnd: UInt32  ;              /* the number of cipher rounds */
    n_blk: UInt32;              /* the number of bytes in the state */
  end;

/* If we're actually compiling the library code, then we need to
 * eliminate the trap glue that would otherwise be generated from
 * this header file in order to prevent compiler errors in CW Pro 2. */
//#ifdef BUILDING_AESLIB #define SYS_TRAP(trapNum) #else
//#define SYS_TRAP(trapNum) SYS_TRAP(trapNum) #endif

/*********************************************************************
 * Type and creator of Sample Library database
 *********************************************************************/

Const AESLibCreatorID        ='AESL';
Const AESLibTypeID           =sysFileTLibrary;

/*********************************************************************
 * Internal library name which can be passed to SysLibFind()
 *********************************************************************/

Const AESLibName             ='AESLib';

/*********************************************************************
 * AESLib result codes
 * (appErrorClass is reserved for 3rd party apps/libraries.
 * It is defined in SystemMgr.h)
 *********************************************************************/

/* invalid parameter */
Const AESLibErrParam                    =appErrorClass | 1;

/* library is not open */
Const AESLibErrNotOpen                  =appErrorClass | 2;

/* returned from AESLibClose() if the library is still open */
Const AESLibErrStillOpen                =appErrorClass | 3;

/* not enough memory */
Const AESLibErrOutOfMemory              =appErrorClass | 4;

/* could not open our resource database */
Const AESLibErrDatabaseOpen             =appErrorClass | 5;

/*********************************************************************
 * API Prototypes
 *********************************************************************/

Function AESLib_OpenLibrary(var refNumP: UInt16): Err;
Function AESLib_CloseLibrary(refNum: UInt16): Err;

/* Standard library open, close, sleep and wake functions */

Function AESLibOpen(refNum: UInt16): Err;
        SYS_TRAP(sysLibTrapOpen);

Function AESLibClose(refNum: UInt16): Err;
        SYS_TRAP(sysLibTrapClose);

Function AESLibSleep(refNum: UInt16): Err;
        SYS_TRAP(sysLibTrapSleep);

Function AESLibWake(refNum: UInt16): Err;
        SYS_TRAP(sysLibTrapWake);

/* AES API functions */

Function AESLibEncKey(refNum: UInt16; var in_key;
                      klen: Integer; var cx: aes_ctx): aes_rval;
        SYS_TRAP(sysLibTrapBase + 5);

Function AESLibEncBlk(refNum: UInt16; var in_blk, out_blk: AESblk16;
                               var cx: aes_ctx): aes_rval;
        SYS_TRAP(sysLibTrapBase + 6);

Function AESLibDecKey(refNum: UInt16; var in_key;
                               klen: Integer; var cx: aes_ctx): aes_rval;
        SYS_TRAP(sysLibTrapBase + 7);

Function AESLibDecBlk(refNum: UInt16; var in_blk,out_blk: AESblk16;
                               var cx: aes_ctx): aes_rval;
        SYS_TRAP(sysLibTrapBase + 8);



Implementation

Uses HSUtils;

/*
 * FUNCTION: AESLib_OpenLibrary
 *
 * DESCRIPTION:
 *
 * User-level call to open the library.  This inline function
 * handles the messy task of finding or loading the library
 * and calling its open function, including handling cleanup
 * if the library could not be opened.
 *
 * PARAMETERS:
 *
 * refNumP
 *                Pointer to UInt16 variable that will hold the new
 *      library reference number for use in later calls
 *
 *
 * CALLED BY: System
 *
 * RETURNS:
 *                errNone
 *                memErrNotEnoughSpace
 *    sysErrLibNotFound
 *    sysErrNoFreeRAM
 *    sysErrNoFreeLibSlots
 *
 */

Function AESLib_OpenLibrary(var refNumP: UInt16): Err;
var
  Error,rc: Err;
  ifErrs: UInt16;
  Loaded: Boolean;
begin
  Loaded:=False;
  Error := SysLibFind(AESLibName, refNumP); /* first try to find the library */
  if Error = sysErrLibNotFound then begin  /* If not found, load the library instead */
    Error := SysLibLoad(S2U32(AESLibTypeID), S2U32(AESLibCreatorID), refNumP);
    Loaded := True;
  end;
  if Error = errNone then begin
    Error := AESLibOpen(refNumP);
    if Error <> errNone then begin
      if Loaded then
        rc:=SysLibRemove(refNumP);
      refNumP := sysInvalidRefNum;
    end;
  end;
  AESLib_OpenLibrary:=Error;
end;



/*
 * FUNCTION: AESLib_CloseLibrary
 *
 * DESCRIPTION:
 *
 * User-level call to closes the shared library.  This handles removal
 * of the library from system if there are no users remaining.
 *
 * PARAMETERS:
 *
 * refNum
 *                Library reference number obtained from AESLib_OpenLibrary().
 *
 * CALLED BY: Whoever wants to close the library
 *
 * RETURNS:
 *                errNone
 *                sysErrParamErr
 */

Function AESLib_CloseLibrary(refNum: UInt16): Err;
var Error, rc: Err;
begin
  if refNum = sysInvalidRefNum then begin
    AESLib_CloseLibrary:=sysErrParamErr;
    EXIT;
  end;

  Error := AESLibClose(refNum);
  if Error = errNone then
    rc:=SysLibRemove(refNum) /* no users left, so unload library */
  else
    if Error = AESLibErrStillOpen then
      Error := errNone; /* don't unload library, but mask "still open" from caller  */
end;

End.
