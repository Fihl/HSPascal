/******************************************************************************
 *
 * Copyright (c) 1994-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: MemoryMgr.h
 *
 * Description:
 *    Include file for Memory Manager
 *
 * History:
 *    10/25/94 RM    Created by Ron Marianetti
 *    10/28/99 kwk   Added memErrROMOnlyCard.
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit MemoryMgr;

interface

uses ErrorBase;


/************************************************************
 * Memory Manager Types
 *************************************************************/
Type LocalIDKind =( memIDPtr, memIDHandle);


/************************************************************
 * Flags accepted as parameter for MemNewChunk.
 *************************************************************/
Const
  memNewChunkFlagPreLock            =0x0100;
  memNewChunkFlagNonMovable         =0x0200;
  memNewChunkFlagAtStart            =0x0400;   // force allocation at front of heap
  memNewChunkFlagAtEnd              =0x0800;   // force allocation at end of heap



/************************************************************
 * Memory Manager Debug settings for the MemSetDebugMode function
 *************************************************************/
  memDebugModeCheckOnChange        =0x0001;
  memDebugModeCheckOnAll           =0x0002;
  memDebugModeScrambleOnChange     =0x0004;
  memDebugModeScrambleOnAll        =0x0008;
  memDebugModeFillFree             =0x0010;
  memDebugModeAllHeaps             =0x0020;
  memDebugModeRecordMinDynHeapFree =0x0040;




/************************************************************
 * Memory Manager result codes
 *************************************************************/
  memErrChunkLocked       =memErrorClass | 1;
  memErrNotEnoughSpace    =memErrorClass | 2;
  memErrInvalidParam      =memErrorClass | 3; /* invalid param or requested size is too big */
  memErrChunkNotLocked    =memErrorClass | 4;
  memErrCardNotPresent    =memErrorClass | 5;
  memErrNoCardHeader      =memErrorClass | 6;
  memErrInvalidStoreHeader=memErrorClass | 7;
  memErrRAMOnlyCard       =memErrorClass | 8;
  memErrWriteProtect      =memErrorClass | 9;
  memErrNoRAMOnCard       =memErrorClass | 10;
  memErrNoStore           =memErrorClass | 11;



/********************************************************************
 * Memory Manager Routines
 * These are define as external calls only under emulation mode or
 *  under native mode from the module that actually installs the trap
 *  vectors
 ********************************************************************/


//-------------------------------------------------------------------
// Initialization
//-------------------------------------------------------------------
Function MemInit: Err;
                     SYS_TRAP(sysTrapMemInit);

Function MemKernelInit: Err;
                     SYS_TRAP(sysTrapMemKernelInit);

Function MemInitHeapTable(cardNo: UInt16): Err;
                     SYS_TRAP(sysTrapMemInitHeapTable);

//-------------------------------------------------------------------
// Card formatting and Info
//-------------------------------------------------------------------
Function MemNumCards: UInt16;
                     SYS_TRAP(sysTrapMemNumCards);

Function MemCardFormat(cardNo: UInt16;
               cardNameP, manufNameP, ramStoreNameP: pChar): Err;
                     SYS_TRAP(sysTrapMemCardFormat);

Function MemCardInfo(cardNo: UInt16;
               cardNameP, manufNameP: pChar;
               var versionP: UInt16;
               var crDateP, romSizeP, ramSizeP, freeBytesP: UInt32): Err;
                     SYS_TRAP(sysTrapMemCardInfo);


//-------------------------------------------------------------------
// Store Info
//-------------------------------------------------------------------
Function MemStoreInfo(cardNo, storeNumber: UInt16;
               var versionP, flagsP: UInt16; nameP: pChar;
               var crDateP, bckUpDateP, heapListOffsetP,
                   initCodeOffset1P, initCodeOffset2P: UInt32;
               var databaseDirIDP: LocalID): Err;
                     SYS_TRAP(sysTrapMemStoreInfo);

Function MemStoreSetInfo(cardNo: UInt16; storeNumber: UInt16;
               var versionP, flagsP: UInt16; nameP: pChar;
               var crDateP, bckUpDateP, heapListOffsetP,
                   initCodeOffset1P, initCodeOffset2P: UInt32;
               var databaseDirIDP: LocalID): Err;
                     SYS_TRAP(sysTrapMemStoreSetInfo);


//-------------------------------------------------------------------
// Heap Info & Utilities
//-------------------------------------------------------------------
Function MemNumHeaps(cardNo: UInt16): UInt16;
                     SYS_TRAP(sysTrapMemNumHeaps);

Function MemNumRAMHeaps(cardNo: UInt16): UInt16;
                     SYS_TRAP(sysTrapMemNumRAMHeaps);

Function MemHeapID(cardNo, heapIndex: UInt16): UInt16;
                     SYS_TRAP(sysTrapMemHeapID);

Function MemHeapDynamic(heapID: UInt16): Boolean;
                     SYS_TRAP(sysTrapMemHeapDynamic);

Function MemHeapFreeBytes(heapID: UInt16; var freeP, maxP: UInt32): Err;
                     SYS_TRAP(sysTrapMemHeapFreeBytes);

Function MemHeapSize(heapID: UInt16): UInt32;
                     SYS_TRAP(sysTrapMemHeapSize);

Function MemHeapFlags(heapID: UInt16): UInt16;
                     SYS_TRAP(sysTrapMemHeapFlags);


// Heap utilities
Function MemHeapCompact(heapID: UInt16): Err;
                     SYS_TRAP(sysTrapMemHeapCompact);
                     
Function MemHeapInit(heapID: UInt16; numHandles: Int16; initContents: Boolean): Err;
                     SYS_TRAP(sysTrapMemHeapInit);
                     
Function MemHeapFreeByOwnerID(heapID: UInt16; ownerID: UInt16): Err;
                     SYS_TRAP(sysTrapMemHeapFreeByOwnerID);


//-------------------------------------------------------------------
// Low Level Allocation
//-------------------------------------------------------------------
Function MemChunkNew(heapID: UInt16; size: UInt32; attr: UInt16): MemPtr;
                     SYS_TRAP(sysTrapMemChunkNew);

Function MemChunkFree(chunkDataP: MemPtr): Err;
                     SYS_TRAP(sysTrapMemChunkFree);



//-------------------------------------------------------------------
// Pointer (Non-Movable) based Chunk Routines
//-------------------------------------------------------------------
Function MemPtrNew(size: UInt32): MemPtr;
                     SYS_TRAP(sysTrapMemPtrNew);

//#define        MemPtrFree( p) MemChunkFree(p)
Function MemPtrFree(chunkDataP: MemPtr): Err;
                     SYS_TRAP(sysTrapMemChunkFree);

// Getting Attributes
Function MemPtrRecoverHandle(p: MemPtr): MemHandle;
                     SYS_TRAP(sysTrapMemPtrRecoverHandle);

Function MemPtrFlags(p: MemPtr): UInt16;
                     SYS_TRAP(sysTrapMemPtrFlags);

Function MemPtrSize(p: MemPtr): UInt32;
                     SYS_TRAP(sysTrapMemPtrSize);

Function MemPtrOwner(p: MemPtr): UInt16;
                     SYS_TRAP(sysTrapMemPtrOwner);

Function MemPtrHeapID(p: MemPtr): UInt16;
                     SYS_TRAP(sysTrapMemPtrHeapID);

Function MemPtrDataStorage(p: MemPtr): Boolean;
                     SYS_TRAP(sysTrapMemPtrDataStorage);

Function MemPtrCardNo(p: MemPtr): UInt16;
                     SYS_TRAP(sysTrapMemPtrCardNo);

Function MemPtrToLocalID(p: MemPtr): LocalID;
                     SYS_TRAP(sysTrapMemPtrToLocalID);

// Setting Attributes
Function MemPtrSetOwner(p: MemPtr; owner: UInt16): Err;
                     SYS_TRAP(sysTrapMemPtrSetOwner);
                     
Function MemPtrResize(p: MemPtr; newSize: UInt32): Err;
                     SYS_TRAP(sysTrapMemPtrResize);

Function MemPtrResetLock(p: MemPtr): Err;
                     SYS_TRAP(sysTrapMemPtrResetLock);

Function MemPtrUnlock(p: MemPtr): Err;
                     SYS_TRAP(sysTrapMemPtrUnlock);


//-------------------------------------------------------------------
// MemHandle (Movable) based Chunk Routines
//-------------------------------------------------------------------
Function MemHandleNew(size: UInt32): MemHandle;
                     SYS_TRAP(sysTrapMemHandleNew);

Function MemHandleFree(h: MemHandle): Err;
                     SYS_TRAP(sysTrapMemHandleFree);

// Getting Attributes
Function MemHandleFlags(h: MemHandle): UInt16;
                     SYS_TRAP(sysTrapMemHandleFlags);

Function MemHandleSize(h: MemHandle): UInt32;
                     SYS_TRAP(sysTrapMemHandleSize);

Function MemHandleOwner(h: MemHandle): UInt16;
                     SYS_TRAP(sysTrapMemHandleOwner);

Function MemHandleLockCount(h: MemHandle): UInt16;
                     SYS_TRAP(sysTrapMemHandleLockCount);

Function MemHandleHeapID(h: MemHandle): UInt16;
                     SYS_TRAP(sysTrapMemHandleHeapID);

Function MemHandleDataStorage(h: MemHandle): Boolean;
                     SYS_TRAP(sysTrapMemHandleDataStorage);

Function MemHandleCardNo(h: MemHandle): UInt16;
                     SYS_TRAP(sysTrapMemHandleCardNo);

Function MemHandleToLocalID(h: MemHandle): LocalID;
                     SYS_TRAP(sysTrapMemHandleToLocalID);


// Setting Attributes
Function MemHandleSetOwner(h: MemHandle; owner: UInt16): Err;
                     SYS_TRAP(sysTrapMemHandleSetOwner);

Function MemHandleResize(h: MemHandle; newSize: UInt32): Err;
                     SYS_TRAP(sysTrapMemHandleResize);

Function MemHandleLock(h: MemHandle): MemPtr;
                     SYS_TRAP(sysTrapMemHandleLock);

Function MemHandleUnlock(h: MemHandle): Err;
                     SYS_TRAP(sysTrapMemHandleUnlock);

Function MemHandleResetLock(h: MemHandle): Err;
                     SYS_TRAP(sysTrapMemHandleResetLock);




//-------------------------------------------------------------------
// Local ID based routines
//-------------------------------------------------------------------
Function MemLocalIDToGlobal(local: LocalID; cardNo: UInt16): MemPtr;
                     SYS_TRAP(sysTrapMemLocalIDToGlobal);

Function MemLocalIDKind(local: LocalID): LocalIDKind;
                     SYS_TRAP(sysTrapMemLocalIDKind);

Function MemLocalIDToPtr(local: LocalID; cardNo: UInt16): MemPtr;
                     SYS_TRAP(sysTrapMemLocalIDToPtr);

Function MemLocalIDToLockedPtr(local: LocalID; cardNo: UInt16): MemPtr;
                     SYS_TRAP(sysTrapMemLocalIDToLockedPtr);


//-------------------------------------------------------------------
// Utilities
//-------------------------------------------------------------------
Function MemMove(dstP: Pointer; sP: Pointer; numBytes: Int32): Err;
                     SYS_TRAP(sysTrapMemMove);

Function MemSet(dstP: Pointer; numBytes: Int32; value: UInt8): Err;
                     SYS_TRAP(sysTrapMemSet);

Function MemCmp (s1, s2: Pointer; numBytes: Int32): Int16;
                     SYS_TRAP(sysTrapMemCmp);

Function MemSemaphoreReserve(writeAccess: Boolean): Err;
                     SYS_TRAP(sysTrapMemSemaphoreReserve);

Function MemSemaphoreRelease(writeAccess: Boolean): Err;
                     SYS_TRAP(sysTrapMemSemaphoreRelease);

//-------------------------------------------------------------------
// Debugging Support
//-------------------------------------------------------------------
Function MemDebugMode: UInt16;
                     SYS_TRAP(sysTrapMemDebugMode);

Function MemSetDebugMode(flags: UInt16): Err;
                     SYS_TRAP(sysTrapMemSetDebugMode);

Function MemHeapScramble(heapID: UInt16): Err;
                     SYS_TRAP(sysTrapMemHeapScramble);

Function MemHeapCheck(heapID: UInt16): Err;
                     SYS_TRAP(sysTrapMemHeapCheck);

implementation

end.

