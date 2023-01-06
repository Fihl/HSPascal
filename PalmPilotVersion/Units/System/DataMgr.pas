/******************************************************************************
 *
 * Copyright (c) 1994-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: DataMgr.h
 *
 * Description:
 *    Header for the Data Manager
 *
 * History:
 *    11/14/94  RM - Created by Ron Marianetti
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit DataMgr;

interface

Uses
  Traps33, Traps35, ErrorBase, MemoryMgr;

Type
  DmResType = UInt32;
  DmResID = UInt16;

/************************************************************
 * Category equates
 *************************************************************/
Const
  dmRecAttrCategoryMask =0x0F;   // mask for category #

  dmRecNumCategories =16;     // number of categories

  dmCategoryLength   =16;     // 15 chars + 1 null terminator

  dmAllCategories    =0xff;
  dmUnfiledCategory  =0;
  dmMaxRecordIndex   =0xffff;

// Record Attributes
//
// *** IMPORTANT:
// ***
// *** Any changes to record attributes must be reflected in dmAllRecAttrs and dmSysOnlyRecAttrs ***
// ***
// *** Only one nibble is available for record attributes
//
// *** ANY CHANGES MADE TO THESE ATTRIBUTES MUST BE REFLECTED IN DESKTOP LINK
// *** SERVER CODE (DLCommon.h, DLServer.c)
  dmRecAttrDelete      =0x80; // delete this record next sync
  dmRecAttrDirty       =0x40; // archive this record next sync
  dmRecAttrBusy          =0x20;  // record currently in use
  dmRecAttrSecret      =0x10; // "secret" record - password protected


  // All record atributes (for error-checking)
  dmAllRecAttrs          = dmRecAttrDelete | dmRecAttrDirty; /// | dmRecAttrBusy | dmRecAttrSecret;
  
  // Record attributes which only the system is allowed to change (for error-checking)
  dmSysOnlyRecAttrs    = dmRecAttrBusy;


/************************************************************
 * Database Header equates
 *************************************************************/
  dmDBNameLength       = 32;     // 31 chars + 1 null terminator

// Attributes of a Database
//
// *** IMPORTANT:
// ***
// *** Any changes to database attributes must be reflected in dmAllHdrAttrs and dmSysOnlyHdrAttrs ***
// ***
  dmHdrAttrResDB  =0x0001; // Resource database
  dmHdrAttrReadOnly  =0x0002; // Read Only database
  dmHdrAttrAppInfoDirty =0x0004; // Set if Application Info block is dirty
               // Optionally supported by an App's conduit
  dmHdrAttrBackup =0x0008; // Set if database should be backed up to PC if
               // no app-specific synchronization conduit has
               // been supplied.
  dmHdrAttrOKToInstallNewer=0x0010; // This tells the backup conduit that it's OK
                                        //  for it to install a newer version of this database
               //  with a different name if the current database is
               //  open. This mechanism is used to update the
               //  Graffiti Shortcuts database, for example.
  dmHdrAttrResetAfterInstall=0x0020;   // Device requires a reset after this database is
               // installed.
  dmHdrAttrCopyPrevention=0x0040;   // This database should not be copied to
  dmHdrAttrStream  =0x0080;   // This database is used for file stream implementation.
  dmHdrAttrHidden  =0x0100;   // This database should generally be hidden from view
                                        //  used to hide some apps from the main view of the
               //  launcher for example.
               // For data (non-resource) databases, this hides the record
               //  count within the launcher info screen.
  dmHdrAttrLaunchableData=0x0200;   // This data database (not applicable for executables)
               //  can be "launched" by passing it's name to it's owner
               //  app ('appl' database with same creator) using
               //  the sysAppLaunchCmdOpenNamedDB action code.
  dmHdrAttrOpen      =0x8000;        // Database not closed properly

  // All database atributes (for error-checking)
  dmAllHdrAttrs      = dmHdrAttrResDB | dmHdrAttrReadOnly | dmHdrAttrAppInfoDirty |
                          dmHdrAttrBackup | dmHdrAttrOKToInstallNewer | dmHdrAttrResetAfterInstall |
                          dmHdrAttrCopyPrevention | dmHdrAttrStream | dmHdrAttrOpen;
  // Database attributes which only the system is allowed to change (for error-checking)
  dmSysOnlyHdrAttrs  = dmHdrAttrResDB | dmHdrAttrOpen;

/************************************************************
 * Unique ID equates
 *************************************************************/
  dmRecordIDReservedRange=1;     // The range of upper bits in the database's uniqueIDSeed from 0 to this number are
               // reserved and not randomly picked when a database is created.
  dmDefaultRecordsID  =0;     // Records in a default database are copied
               // with their uniqueIDSeeds set in this range.
  dmUnusedRecordID    =0;     // Record ID not allowed on the device

/************************************************************
 * Mode flags passed to DmOpenDatabase
 *************************************************************/
  dmModeReadOnly        =0x0001;    // read  access
  dmModeWrite           =0x0002;    // write access
  dmModeReadWrite       =0x0003;    // read & write access
  dmModeLeaveOpen       =0x0004;    // leave open when app quits
  dmModeExclusive       =0x0008;    // don't let anyone else open it
  dmModeShowSecret         =0x0010;    // force show of secret records

// Generic type used to represent an open Database
Type
  DmOpenRef= Pointer;

/************************************************************
 * Structure passed to DmGetNextDatabaseByTypeCreator and used
 *  to cache search information between multiple searches.
 *************************************************************/
  DmSearchStatePtr =^DmSearchStateType;
  DmSearchStateType = Record
    info: Array[0..7] of UInt32
  end;

/************************************************************
 * Structures used by the sorting routines
 *************************************************************/
  SortRecordInfoPtr = ^SortRecordInfoType;
  SortRecordInfoType= Record
    attributes: UInt8;                 // record attributes;
    uniqueID: array[0..2] of UInt8;       // unique ID of record
  end;

  //Function DmComparF (P1,P2: Pointer; Other: Int16; P: SortRecordInfoPtr; appInfoH: MemHandle): Int16;
  DmComparF = Pointer;


/************************************************************
 * Database manager error codes
 * the constant dmErrorClass is defined in ErrorBase.h
 *************************************************************/
Const
  dmErrMemError      =     dmErrorClass | 1;
  dmErrIndexOutOfRange  =     dmErrorClass | 2;
  dmErrInvalidParam  =     dmErrorClass | 3;
  dmErrReadOnly      =     dmErrorClass | 4;
  dmErrDatabaseOpen  =     dmErrorClass | 5;
  dmErrCantOpen      =     dmErrorClass | 6;
  dmErrCantFind      =     dmErrorClass | 7;
  dmErrRecordInWrongCard=     dmErrorClass | 8;
  dmErrCorruptDatabase  =     dmErrorClass | 9;
  dmErrRecordDeleted =     dmErrorClass | 10;
  dmErrRecordArchived   =     dmErrorClass | 11;
  dmErrNotRecordDB   =     dmErrorClass | 12;
  dmErrNotResourceDB =     dmErrorClass | 13;
  dmErrROMBased      =     dmErrorClass | 14;
  dmErrRecordBusy =     dmErrorClass | 15;
  dmErrResourceNotFound =          dmErrorClass | 16;
  dmErrNoOpenDatabase   =     dmErrorClass | 17;
  dmErrInvalidCategory  =     dmErrorClass | 18;
  dmErrNotValidRecord   =     dmErrorClass | 19;
  dmErrWriteOutOfBounds =          dmErrorClass | 20;
  dmErrSeekFailed =     dmErrorClass | 21;
  dmErrAlreadyOpenForWrites=            dmErrorClass | 22;
  dmErrOpenedByAnotherTask=           dmErrorClass | 23;
  dmErrUniqueIDNotFound =          dmErrorClass | 24;
  dmErrAlreadyExists =     dmErrorClass | 25;
  dmErrInvalidDatabaseName=           dmErrorClass | 26;
  dmErrDatabaseProtected=     dmErrorClass | 27;

/************************************************************
 * Values for the direction parameter of DmSeekRecordInCategory
 *************************************************************/
  dmSeekForward      =1;
  dmSeekBackward  =-1;

/************************************************************
 * Data Manager procedures
 *************************************************************/

// Initialization
Function DmInit: Err; SYS_TRAP(sysTrapDmInit);

Type
  Char4= Packed array[0..3] of Char;
// Directory Lists
Function DmCreateDatabase(cardNo: UInt16; Const NameP: String; creator,typ: UInt32; resDB: Boolean): Err; SYS_TRAP(sysTrapDmCreateDatabase);

Function DmCreateDatabaseFromImage(bufferP: MemPtr): Err; SYS_TRAP(sysTrapDmCreateDatabaseFromImage);


Function DmDeleteDatabase(cardNo: UInt16; dbID: LocalID): Err; SYS_TRAP(sysTrapDmDeleteDatabase);

Function DmNumDatabases(cardNo: UInt16): UInt16; SYS_TRAP(sysTrapDmNumDatabases);

Function DmGetDatabase(cardNo: UInt16; index: UInt16): LocalID; SYS_TRAP(sysTrapDmGetDatabase);

Function DmFindDatabase(cardNo: UInt16; Const nameP: String): LocalID; SYS_TRAP(sysTrapDmFindDatabase);

Function DmGetNextDatabaseByTypeCreator(newSearch: Boolean;
               stateInfoP: DmSearchStatePtr;
               Typ: UInt32;
               creator: UInt32;
               onlyLatestVers: Boolean;
               var cardNo: UInt16;
               var dbID: LocalID): Err; SYS_TRAP(sysTrapDmGetNextDatabaseByTypeCreator);

// Database info
Function DmDatabaseInfo(cardNo: UInt16; dbID: LocalID;
               nameP: PChar;  //NIL or Return buffer
               var attributes: UInt16;
               var version: UInt16;
               var crData: UInt32;
               var modDataP: UInt32;
               var bckUpDate: UInt32;
               var modNum: UInt32;
               var appInfoIDP,sortInfoIDP: LocalID;
               var typ: UInt32;
               var creator: UInt32): Err; SYS_TRAP(sysTrapDmDatabaseInfo);

Function DmSetDatabaseInfo(cardNo: UInt16; dbID: LocalID;
               Const nameP: String;
               var attributes: UInt16;
               var version: UInt16;
               var crData: UInt32;
               var modDataP: UInt32;
               var bckUpDate: UInt32;
               var modNum: UInt32;
               var appInfoIDP,sortInfoIDP: LocalID;
               var typ: UInt32;
               var creator: UInt32): Err; SYS_TRAP(sysTrapDmSetDatabaseInfo);

Function DmDatabaseSize(cardNo: UInt16; dbID: LocalID;
               var numRecords: UInt32;
               var totalBytes: UInt32;
               var dataBytes: UInt32): Err; SYS_TRAP(sysTrapDmDatabaseSize);

// This routine can be used to prevent a database from being deleted (by passing
//  true for 'protect'). It will increment the protect count if 'protect' is true
//  and decrement it if 'protect' is false. This is used by code that wants to
//  keep a particular record or resource in a database locked down but doesn't
//  want to keep the database open. This information is keep in the dynamic heap so
//  all databases are "unprotected" at system reset.
Function DmDatabaseProtect(cardNo: UInt16; dbID: LocalID; protect: Boolean): Err; SYS_TRAP(sysTrapDmDatabaseProtect);

// Open/close Databases
Function DmOpenDatabase(cardNo: UInt16; dbID: LocalID; mode: UInt16): DmOpenRef; SYS_TRAP(sysTrapDmOpenDatabase);

Function DmOpenDatabaseByTypeCreator(Typ: UInt32; creator: UInt32; mode: UInt16): DmOpenRef; SYS_TRAP(sysTrapDmOpenDatabaseByTypeCreator);

Function DmOpenDBNoOverlay(cardNo: UInt16; dbID: LocalID; mode: UInt16): DmOpenRef; SYS_TRAP(sysTrapDmOpenDBNoOverlay);

Function DmCloseDatabase(dbP: DmOpenRef): Err; SYS_TRAP(sysTrapDmCloseDatabase);


// Info on open databases
Function DmNextOpenDatabase(currentP: DmOpenRef): DmOpenRef; SYS_TRAP(sysTrapDmNextOpenDatabase);

Function DmOpenDatabaseInfo(dbP: DmOpenRef;
               var dbIDP: LocalID;
               var openCount: UInt16;
               var mode: UInt16;
               var cardNo: UInt16;
               var resDB: Boolean): Err; SYS_TRAP(sysTrapDmOpenDatabaseInfo);

Function DmGetAppInfoID(dbP: DmOpenRef): LocalID; SYS_TRAP(sysTrapDmGetAppInfoID);

Procedure DmGetDatabaseLockState(dbR: DmOpenRef;
               var highest: UInt8;
               var count: UInt32;
               var busy: UInt32); SYS_TRAP(sysTrapDmGetDatabaseLockState);

// Utility to unlock all records and clear busy bits
Function DmResetRecordStates(dbP: DmOpenRef): Err; SYS_TRAP(sysTrapDmResetRecordStates);


// Error Query
Function DmGetLastErr: Err; SYS_TRAP(sysTrapDmGetLastErr);


//------------------------------------------------------------
// Record based access routines
//------------------------------------------------------------

// Record Info
Function DmNumRecords(dbP: DmOpenRef): UInt16; SYS_TRAP(sysTrapDmNumRecords);

Function DmNumRecordsInCategory(dbP: DmOpenRef; category: UInt16): UInt16; SYS_TRAP(sysTrapDmNumRecordsInCategory);

Function DmRecordInfo(dbP: DmOpenRef; index: UInt16;
               var attr: UInt16;
               var uniqueID: UInt32;
               var chunkID: LocalID): Err;
                     SYS_TRAP(sysTrapDmRecordInfo);

Function DmSetRecordInfo(dbP: DmOpenRef; index: UInt16;
               var attr: UInt16;
               var uniqueID: UInt32): Err; SYS_TRAP(sysTrapDmSetRecordInfo);

// Record attaching and detaching
Function DmAttachRecord(dbP: DmOpenRef;
               var at: UInt16;
               newH: MemHandle;
               var oldH: MemHandle): Err; SYS_TRAP(sysTrapDmAttachRecord);

Function DmDetachRecord(dbP: DmOpenRef; index: UInt16; var oldH: MemHandle): Err; SYS_TRAP(sysTrapDmDetachRecord);

Function DmMoveRecord(dbP: DmOpenRef; from,too: UInt16): Err; SYS_TRAP(sysTrapDmMoveRecord);

// Record creation and deletion
Function DmNewRecord(dbP: DmOpenRef; var at: UInt16; size: UInt32): MemHandle; SYS_TRAP(sysTrapDmNewRecord);

Function DmRemoveRecord(dbP: DmOpenRef; index: UInt16): Err; SYS_TRAP(sysTrapDmRemoveRecord);

Function DmDeleteRecord(dbP: DmOpenRef; index: UInt16): Err; SYS_TRAP(sysTrapDmDeleteRecord);

Function DmArchiveRecord(dbP: DmOpenRef; index: UInt16): Err; SYS_TRAP(sysTrapDmArchiveRecord);

Function DmNewHandle(dbP: DmOpenRef; size: UInt32): MemHandle; SYS_TRAP(sysTrapDmNewHandle);

Function DmRemoveSecretRecords(dbP: DmOpenRef): Err; SYS_TRAP(sysTrapDmRemoveSecretRecords);


// Record viewing manipulation
Function DmFindRecordByID(dbP: DmOpenRef; uniqueID: UInt32; var indexP: UInt16): Err; SYS_TRAP(sysTrapDmFindRecordByID);

Function DmQueryRecord(dbP: DmOpenRef; index: UInt16): Memhandle; SYS_TRAP(sysTrapDmQueryRecord);

Function DmGetRecord(dbP: DmOpenRef; index: UInt16): Memhandle; SYS_TRAP(sysTrapDmGetRecord);

Function DmQueryNextInCategory(dbP: DmOpenRef; var indexP: UInt16; category: UInt16): Memhandle; SYS_TRAP(sysTrapDmQueryNextInCategory);

Function DmPositionInCategory(dbP: DmOpenRef; index: UInt16;  category: UInt16): UInt16; SYS_TRAP(sysTrapDmPositionInCategory);

Function DmSeekRecordInCategory(dbP: DmOpenRef; var indexP: UInt16; offset: UInt16;
            direction: Int16; category: UInt16): Err; SYS_TRAP(sysTrapDmSeekRecordInCategory);


Function DmResizeRecord(dbP: DmOpenRef; index: UInt16; newSize: UInt32): Memhandle; SYS_TRAP(sysTrapDmResizeRecord);

Function DmReleaseRecord(dbP: DmOpenRef; index: UInt16; dirty: Boolean): Err; SYS_TRAP(sysTrapDmReleaseRecord);

Function DmSearchRecord(recH: MemHandle; var dbPP: DmOpenRef): UInt16; SYS_TRAP(sysTrapDmSearchRecord);


// Category manipulation
Function DmMoveCategory(dbP: DmOpenRef; toCategory,fromCategory: UInt16; dirty: Boolean): Err; 
                     SYS_TRAP(sysTrapDmMoveCategory);

Function DmDeleteCategory(dbR: DmOpenRef; categoryNum: UInt16): Err; SYS_TRAP(sysTrapDmDeleteCategory);
                     
                     
// Validation for writing
Function DmWriteCheck(rec: Pointer; offset,bytes: UInt32): Err; SYS_TRAP(sysTrapDmWriteCheck);

// Writing
Function DmWrite(rec: Pointer; offset: UInt32; srcP: Pointer; bytes: UInt32): Err; SYS_TRAP(sysTrapDmWrite);

Function DmStrCopy(rec: Pointer; offset: UInt32; Const srcP: String): Err; SYS_TRAP(sysTrapDmStrCopy);

Function DmSet(rec: Pointer; offset: UInt32; bytes: UInt32; value: UInt8): Err; SYS_TRAP(sysTrapDmSet);

//------------------------------------------------------------
// Resource based access routines
//------------------------------------------------------------

// High level access routines
Function DmGetResource(typ: DmResType; resID: DmResID): Memhandle; SYS_TRAP(sysTrapDmGetResource);

Function DmGet1Resource(typ: DmResType; resID: DmResID): MemHandle; SYS_TRAP(sysTrapDmGet1Resource);

Function DmReleaseResource(resourceH: MemHandle): Err; SYS_TRAP(sysTrapDmReleaseResource);

Function DmResizeResource(resourceH: MemHandle; newSize: UInt32): Memhandle; SYS_TRAP(sysTrapDmResizeResource);


// Searching resource databases
Function DmNextOpenResDatabase(dbP: DmOpenRef): DmOpenRef; SYS_TRAP(sysTrapDmNextOpenResDatabase);

Function DmFindResourceType(dbP: DmOpenRef; resType: DmResType; typeIndex: UInt16): UInt16; SYS_TRAP(sysTrapDmFindResourceType);

Function DmFindResource(dbP: DmOpenRef; resType: DmResType; resID: DmResID; resH: MemHandle): UInt16; SYS_TRAP(sysTrapDmFindResource);

Function DmSearchResource(resType: DmResType; resID: DmResID; resH: MemHandle; var dbPP: DmOpenRef): UInt16; SYS_TRAP(sysTrapDmSearchResource);

// Resource Info
Function DmNumResources(dbP: DmOpenRef): UInt16; SYS_TRAP(sysTrapDmNumResources);

Function DmResourceInfo(dbP: DmOpenRef; index: UInt16;
               var resType: DmResType;
               var resIDP: DmResID;
               var chunkLocalIDP: LocalID): Err; SYS_TRAP(sysTrapDmResourceInfo);

Function DmSetResourceInfo(dbP: DmOpenRef; index: UInt16;
               var resTypeP: DmResType;
               var resIDP: DmResID): Err; SYS_TRAP(sysTrapDmSetResourceInfo);



// Resource attaching and detaching
Function DmAttachResource(dbP: DmOpenRef; newH: MemHandle;  resType: DmResType; resID: DmResID): Err; SYS_TRAP(sysTrapDmAttachResource);

Function DmDetachResource(dbP: DmOpenRef; index: UInt16;  var oldHP: MemHandle): Err; SYS_TRAP(sysTrapDmDetachResource);

// Resource creation and deletion
Function DmNewResource(dbP: DmOpenRef; resType: DmResType; resID: DmResID; size: UInt32): Memhandle; SYS_TRAP(sysTrapDmNewResource);

Function DmRemoveResource(dbP: DmOpenRef; index: UInt16): Err; SYS_TRAP(sysTrapDmRemoveResource);

// Resource manipulation
Function DmGetResourceIndex(dbP: DmOpenRef; index: UInt16): Memhandle; SYS_TRAP(sysTrapDmGetResourceIndex);

// Record sorting
Function DmQuickSort(dbP: DmOpenRef; compar: DmComparF; other: Int16): Err; SYS_TRAP(sysTrapDmQuickSort);

Function DmInsertionSort(dbR: DmOpenRef; compar: DmComparF; other: Int16): Err; SYS_TRAP(sysTrapDmInsertionSort);

Function DmFindSortPosition(dbP: DmOpenRef; var newRecord; newRecordInfo: SortRecordInfoPtr; compar: DmComparF; other: Int16): UInt16; SYS_TRAP(sysTrapDmFindSortPosition);

Function DmFindSortPositionV10(dbP: DmOpenRef; var newRecord; compar: DmComparF; other: Int16): UInt16; SYS_TRAP(sysTrapDmFindSortPositionV10);

implementation

end.

