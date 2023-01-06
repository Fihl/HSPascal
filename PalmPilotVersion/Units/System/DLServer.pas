/******************************************************************************
 *
 * Copyright (c) 1995-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: DLServer.h
 *
 * Description:
 *    Desktop Link Protocol(DLP) Server implementation definitions.
 *
 * History:
 *    vmk   7/12/95  Created by Vitaly Marty Kruglikov
 *    vmk   7/12/96  Converted to HTAL architecture
 *    jmp   12/23/99 Fix <> vs. "" problem.
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit DLServer;

interface

Uses ErrorBase, DataMgr;

//#include "PalmOptErrorCheckLevel.h"


/************************************************************
 * DLK result codes
 * (dlkErrorClass is defined in SystemMgr.h)
 *************************************************************/
//#pragma mark *Error Codes*

Const
  dlkErrParam        =dlkErrorClass | 1;  // invalid parameter
  dlkErrMemory       =dlkErrorClass | 2;  // memory allocation error
  dlkErrNoSession    =dlkErrorClass | 3;  // could not establish a session
  dlkErrSizeErr      =dlkErrorClass | 4;  // reply length was too big
  dlkErrLostConnection=dlkErrorClass | 5;  // lost connection
  dlkErrInterrupted  =dlkErrorClass | 6;  // sync was interrupted (see sync state)
  dlkErrUserCan      =dlkErrorClass | 7;  // cancelled by user

/********************************************************************
 * Desktop Link system preferences resource for user info
 * id = sysResIDDlkUserInfo, defined in SystemResources.h
 ********************************************************************/
//#pragma mark *User Info Preference*

  dlkMaxUserNameLength        =40;
  dlkUserNameBufSize          =dlkMaxUserNameLength + 1;

{$ifdef ERROR_CHECK_FULL}
  dlkMaxLogSize               =20480; //20 * 1024;
{$else}
  dlkMaxLogSize               =2048; //2 * 1024;
{$endif}

Type
  DlkSyncStateType = (
    dlkSyncStateNeverSynced = 0,     // never synced
    dlkSyncStateInProgress,          // sync is in progress
    dlkSyncStateLostConnection,      // connection lost during sync
    dlkSyncStateLocalCan,            // cancelled by local user on handheld
    dlkSyncStateRemoteCan,           // cancelled by user from desktop
    dlkSyncStateLowMemoryOnTD,       // sync ended due to low memory on handheld
    dlkSyncStateAborted,             // sync was aborted for some other reason
    dlkSyncStateCompleted,           // sync completed normally

    // Added in PalmOS v3.0:
    dlkSyncStateIncompatibleProducts // sync ended because desktop HotSync product
                                     // is incompatible with this version
                                     // of the handheld HotSync
   );

Const
  dlkUserInfoPrefVersion   =0x0102;   // current user info pref version: 1.2

Type
  DlkUserInfoHdrType = Record
    version: UInt16;                   // pref version number
    userID: UInt32;                    // user id
    viewerID: UInt32;                  // id assigned to viewer by the desktop
    lastSyncPC: UInt32;                // last sync PC id
    succSyncDate: UInt32;              // last successful sync date
    lastSyncDate: UInt32;              // last sync date
    lastSyncState: DlkSyncStateType;   // last sync status
    reserved1: UInt8;                  // Explicitly account for 16-bit alignment padding
    lanSyncEnabled: UInt16;            // if non-zero, LAN Sync is enabled
    hsTcpPortNum: UInt32;              // TCP/IP port number of Desktop HotSync
    dwReserved1: UInt32;               // RESERVED -- set to NULL!
    dwReserved2: UInt32;               // RESERVED -- set to NULL!
    userNameLen: UInt8;                // length of name field(including null)
    reserved2: UInt8;                  // Explicitly account for 16-bit alignment padding
    syncLogLen: UInt16;                // length of sync log(including null)
  end;

  DlkUserInfoPtr  =^DlkUserInfoType;
  DlkUserInfoType = Record
    header: DlkUserInfoHdrType;        // fixed size header
    nameAndLog: array[0..1] of char;   // user name, followed by sync log;
                                       // both null-terminated(for debugging)
  end;


/********************************************************************
 * Desktop Link system preferences resource for the Conduit Filter Table
 * id = sysResIDDlkCondFilterTab, defined in SystemResources.h
 ********************************************************************/
//#pragma mark *Conduit Filter Preference*

//
// Table for specifying conduits to "filter out" during HotSync
//

// This table consists of DlkCondFilterTableHdrType header followed by a
// variable number of DlkCondFilterEntryType entries

  DlkCondFilterTableHdrPtr = ^DlkCondFilterTableHdrType;
  DlkCondFilterTableHdrType = Record
    entryCount: UInt16;
  end;

  DlkCondFilterEntryPtr = ^DlkCondFilterEntryType;
  DlkCondFilterEntryType = Record
    creator: UInt32;
    typ_:    UInt32;
  end;

  DlkCondFilterTablePtr = ^DlkCondFilterTableType;
  DlkCondFilterTableType = Record
    hdr: DlkCondFilterTableHdrType; // table header
    entry: array[0..0] of DlkCondFilterEntryType; // variable number of entries
  end;


/********************************************************************
 * DLK Session Structures
 ********************************************************************/
//#pragma mark *Session Structures*


// DesktopLink event notification callback.  If non-zero is returned,
// sync will be cancelled as soon as a safe point is reached.
  DlkEventType = (
    dlkEventOpeningConduit = 1,         // conduit is being opened -- paramP
                                        // is null;

    dlkEventDatabaseOpened,             // client has opened a database -- paramP
                                        // points to DlkEventDatabaseOpenedType;

    dlkEventCleaningUp,                 // last stage of sync -- cleaning up (notifying apps, etc) --
                                        // paramP is null

    dlkEventSystemResetRequested        // system reset was requested by the desktop client
                                        // (the normal action is to delay the reset until
                                        // end of sync) -- paramP is null
  );

// Prototype for the event notification callback
//typedef Int16 (*DlkEventProcPtr)(UInt32 eventRef, DlkEventType dlkEvent, void * paramP);
  DlkEventProcPtr = Pointer;

// Parameter structure for dlkEventDatabaseOpened
// Added new fields for Pilot v2.0     vmk   12/24/96
  DlkEventDatabaseOpenedType = Record
    dbR: DmOpenRef;           // open database ref (v2.0)
    dbNameP: PChar;           // database name
    dbType: UInt32;           // databse type (v2.0)
    dbCreator: UInt32;        // database creator
  end;

// Prototype for the "user cancel" check callback function
//typedef Int16 (*DlkUserCanProcPtr)(UInt32 canRef);
  DlkUserCanProcPtr = Pointer;

//
// List of modified database creators maintained by DLP Server
//
  DlkDBCreatorList = Record
    count: UInt16;            // number of entries in the list
    listH: MemHandle;            // chunk MemHandle of the creators list
  end;

//
// Desktop Link Server state flags
//
Const
  dlkStateFlagVerExchanged    =0x8000;
  dlkStateFlagSyncDateSet     =0x4000;

//
// DLP Server session information
//
Type
  DlkServerSessionPtr = ^DlkServerSessionType;
  DlkServerSessionType = Record
    htalLibRefNum: UInt16;    // HTAL library reference number - the library has a live connection
    maxHtalXferSize: UInt32;  // Maximum transfer block size

    // Information supplied by user
    eventProcP: DlkEventProcPtr;    // ptr to DesktopLink event notification proc
    eventRef: UInt32;      // user reference value for event proc
    canProcP: DlkUserCanProcPtr;      // ptr to user-cancel function
    canRef: UInt32;        // parameter for canProcP()
    condFilterH: MemHandle;   // MemHandle of conduit filter table(DlkCondFilterTableHdrPtr) or 0 for none

    // Current database information
    dlkDBID: UInt8;       // Desktop Link database MemHandle of the open database
    reserved1: UInt8;
    dbR: DmOpenRef;           // TouchDown database access pointer -- if null, no current db
    cardNo: UInt16;        // memory module number
    dbCreator: UInt32;     // creator id
    dbName: String[dmDBNameLength-1]; // DB name
    dbOpenMode: UInt16;    // database open mode
    created: Boolean;       // true if the current db was created
    isResDB: Boolean;       // set to true if resource database
    ramBased: Boolean;      // true if the db is in RAM storage
    readOnly: Boolean;      // true if the db is read-only
    dbLocalI: LocalID;      // TouchDown LocalID of the database
    initialModNum: UInt32; // initial DB modification number
    curRecIndex: UInt32;   // current record index for enumeration functions
                                     // (0=beginning)

    // List of modified database creators maintained by DLP Server
    creatorList: DlkDBCreatorList;

    // Session status information
    syncState: DlkSyncStateType; // current sync state;

    complete: Boolean;      // set to true when completion request
                                     // has been received

    conduitOpened: Boolean; // set to true after the first coduit
                                     // is opened by remote

    logCleared: Boolean;    // set to true after sync log has been
                                     // cleared during the current session;
          // The log will be cleared before any new entries are added or at
          // the end of sync in case no new entries were added.
          // (we do not clear the log at the beginning of sync in case the
          // user cancels during the "identifying user" phase; in this
          // event, the spec calls for preserving the original log)

    resetPending: Boolean;  // set to true if system reset is pending;
                            // the reset will be carried out at end
                            // of sync

    // Current request information
    gotCommand: Boolean;    // set to true when got a request
    cmdTID: UInt8;          // current transaction ID
    reserved2: UInt8;
    cmdLen: UInt16;         // size of data in request buffer
    cmpP: Pointer;          // pointer to command
    cmdH: MemHandle;        // MemHandle of command buffer

    // Fields added in PalmOS v3.0
    wStateFlags: UInt16;   // bitfield of dlkStateFlag... bits
    dbSearchState: DmSearchStateType; // database search state for iterative
                                      // searches using DmGetNextDatabaseByTypeCreator
  end;


/********************************************************************
 * DLK Function Parameter Structures
 ********************************************************************/
//#pragma mark *Function Parameter Structures*

//
// Parameter passed to DlkControl()
//
  DlkCtlEnum = (
    dlkCtlFirst = 0,           // reserve 0
    //
    // Pilot v2.0 control codes:
    //
    dlkCtlGetPCHostName,       // param1P = ptr to text buffer; (can be null if *(UInt16 *)param2P is 0)
                               // param2P = ptr to buffer size(UInt16);
                               // returns actual length, including null, in *(UInt16 *)param2P which may be bigger than # of bytes copied.

    dlkCtlSetPCHostName,       // param1P = ptr to host name(zero-terminated) or NULL if *param2 is 0
                               // param2P = ptr to length(UInt16), including NULL (if length is 0, the current name is deleted)

    dlkCtlGetCondFilterTable,  // param1P =   ptr to destination buffer for filter table, or NULL if *param2 is 0
                               // param2P =   on entry, ptr to size of buffer(UInt16) (the size may be 0)
                               //             on return, size, in bytes, of the actual filter table

    dlkCtlSetCondFilterTable,  // param1P =   ptr to to conduit filter table, or NULL if *param2 is 0
                               // param2P =   ptr to size of filter table(UInt16) (if size is 0, the current table will be deleted)

    dlkCtlGetLANSync,          // param1P =   ptr to store for the LANSync setting(UInt16): 0 = off, otherwise on
                               // param2P =   not used, set to NULL

    dlkCtlSetLANSync,          // param1P =   ptr to the LANSync setting(UInt16): 0 = off, otherwise on
                               // param2P =   not used, set to NULL

    dlkCtlGetHSTCPPort,        // param1P =   ptr to store for the Desktop HotSync TCP/IP port number(UInt32) -- zero if not set
                               // param2P =   not used, set to NULL

    dlkCtlSetHSTCPPort,        // param1P =   ptr to the Desktop HotSync TCP/IP port number(UInt32)
                               // param2P =   not used, set to NULL

    dlkCtlSendCallAppReply,    // param1P =   ptr to DlkCallAppReplyParamType structure
                               // param2P =   not used, set to NULL
                               //
                               // RETURNS: send error code; use this error code
                               // as return value from the action code handler


    dlkCtlGetPCHostAddr,       // param1P = ptr to text buffer; (can be null if *(UInt16 *)param2P is 0)
                               // param2P = ptr to buffer size(UInt16);
                               // returns actual length, including null, in *(UInt16 *)param2P which may be bigger than # of bytes copied.

    dlkCtlSetPCHostAddr,       // param1P = ptr to host address string(zero-terminated) or NULL if *param2 is 0
                               // param2P = ptr to length(UInt16), including NULL (if length is 0, the current name is deleted)


    dlkCtlGetPCHostMask,       // param1P = ptr to text buffer; (can be null if *(UInt16 *)param2P is 0)
                               // param2P = ptr to buffer size(UInt16);
                               // returns actual length, including null, in *(UInt16 *)param2P which may be bigger than # of bytes copied.

    dlkCtlSetPCHostMask,       // param1P = ptr to subnet mask string(zero-terminated) or NULL if *param2 is 0
                               // param2P = ptr to length(UInt16), including NULL (if length is 0, the current name is deleted)


    dlkCtlLAST                 // *KEEP THIS ENTRY LAST*
  );


//
// Parameter passed to DlkStartServer()
//
  DlkServerParamPtr = ^DlkServerParamType;
  DlkServerParamType = record
    htalLibRefNum: UInt16;    // HTAL library reference number - the library has a live connection
    eventProcP: DlkEventProcPtr;    // ptr to DesktopLink event notification proc
    eventRef: UInt32;         // user reference value for event proc
    reserved1: UInt32;        // reserved - set to NULL
    reserved2: UInt32;        // reserved - set to NULL
    condFilterH: MemHandle;   // MemHandle of conduit filter table(DlkCondFilterTableHdrPtr) or 0 for none
  end;

//
// Parameter passed with DlkControl()'s dlkCtlSendCallAppReply code
//
  DlkCallAppReplyParamType = Record
    pbSize: UInt16;         // size of this parameter block (set to sizeof(DlkCallAppReplyParamType))
    dwResultCode: UInt32;   // result code to be returned to remote caller
    resultP: Pointer;       // ptr to result data
    dwResultSize: UInt32;   // size of reply data in number of bytes
    dlRefP: Pointer;        // DesktopLink reference pointer from
                            // SysAppLaunchCmdHandleSyncCallAppType
    dwReserved1: UInt32;    // RESERVED -- set to null!!!
  end;

/********************************************************************
 * DesktopLink Server Routines
 ********************************************************************/

//
// SERVER API
//

// * RETURNED: 0 if session ended successfully; otherwise: dlkErrParam,
// *           dlkErrNoSession, dlkErrLostConnection, dlkErrMemory,
// *           dlkErrUserCan
Function DlkStartServer(paramP: DlkServerParamPtr): Err;
                     SYS_TRAP(sysTrapDlkStartServer);

Function DlkGetSyncInfo(var succSyncDateP, lastSyncDateP: UInt32;
         var syncStateP: DlkSyncStateType;
         nameBufP: PChar; logBufP: PChar; var logLenP: Int32): Err;
                     SYS_TRAP(sysTrapDlkGetSyncInfo);

// DOLATER... this is a temporary function for debugging modem manager.
// remove it when done.
Procedure DlkSetLogEntry(textP: PChar; textLen: Int16; append: Boolean);
                     SYS_TRAP(sysTrapDlkSetLogEntry);

// Dispatch a DesktopLink request (exposed for patching)
Function DlkDispatchRequest(sessP: DlkServerSessionPtr): Err;
                     SYS_TRAP(sysTrapDlkDispatchRequest);

Function DlkControl(op: DlkCtlEnum; param1P, param2P: Pointer): Err;
            SYS_TRAP(sysTrapDlkControl);

/********************************************************************
 * DLK Macros
 ********************************************************************/
implementation

end.

