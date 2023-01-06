/******************************************************************************
 *
 * Copyright (c) 1994-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: SystemMgr.h
 *
 * Description:
 *    Pilot system equates
 *
 * History:
 *    10/27/94 RM    Created by Ron Marianetti 
 *    10/07/96 SCL   Added sysAppLaunchFlagDataRelocated flag
 *    11/13/96 vmk   Added sysErrDelayWakened error code
 *    08/12/98 dia   Added sysFtrNumGremlinsSupportGlobals.
 *    08/18/98 SCL   Added sysFtrNumHwrMiscFlags and ...FlagsExt.
 *                   Redefined sysFtrNumProcessorID.
 *    08/23/98 SCL   Merged in tsmErrorClass.
 *    09/07/98 kwk   Added SysWantEvent routine declaration.
 *    10/05/98 jfs   Added SysLCDContrast trap descriptor
 *    04/08/99 kwk   Added sysFtrNumVendor (OS 3.3 and later)
 *    06/28/99 kwk   Added omErrorClass.
 *    08/11/99 kwk   Added sysFtrNumCharEncodingFlags.
 *    11/01/99 kwk   Moved SysWantEvent to SystemPrv.h
 *    12/03/99 SCL   Moved SysAppInfoType, SysAppStartup, and SysAppExit
 *                   here from SystemPrv.h (for StartupCode/Runtime)
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit SystemMgr;

interface

Uses {x$ifdef PalmVer35} Traps30, Traps31, Traps35, {x$endif}
     Menu, Bitmap, SystemResources, ErrorBase, DataMgr;

// <SystemResources.h>           // Resource definitions.
// <Rect.h>
// <Font.h>
// <Window.h>
// <InsPoint.h>
// <Event.h>
// <DataMgr.h>                   // for DmOpenRef
// <LibTraps.h>

/***********************************************************
 * Rules for creating and using the Command Parameter Block
 * passed to SysUIAppSwitch
 *************************************************************/

// A parameter block containing application-specific information may be passed
// to an application when launching it via SysUIAppSwitch.  To create the
// parameter block, you allocate a memory block using MemPtrNew and then you must
// call MemPtrSetOwner to set the block's owner ID to 0.  This assigns the block's
// ownership to the system so that it will not be automatically freed by the system
// when the calling app exits. The command block must be self contained. It must not
// have pointers to anything on the stack or in memory blocks owned by an application.
// The launching and launched applications do not need to worry about freeing the
// command block since the system will do this after the launched application exits.
// If no parameter block is being passed, this parameter must be NULL.


/************************************************************
 * Action Codes
 *
 * IMPORTANT ACTION CODE CONSIDERATIONS:
 *
 * Many action codes are "sent" to apps via a direct function call into the app's
 * PilotMain() function without launching the app.  For these action codes, the
 * application's global and static variables are *not* available, unless the
 * application is already running. Some action codes are synchronized with the
 * currently running UI applcation via the event manager (alarm action codes,
 * for example), while others, such as HotSync action codes, are sent from a
 * background thread. To find out if your app is running (is the current UI
 * app) when an action code is received, test the sysAppLaunchFlagSubCall flag
 * (defined in SystemMgr.h) which is passed to your PilotMain in the
 * launchFlags parameter (the third PilotMain parameter). If it is non-zero,
 * you may assume that your app is currently running and the global variables
 * are accessible. This information is useful if your app maintains an open
 * data database (or another similar resource) when it is running. If the app
 * receives an action code and the sysAppLaunchFlagSubCall is set in
 * launchFlags, the handler may access global variables and use the open
 * database handle while handling the call. On the other hand, if the
 * sysAppLaunchFlagSubCall flag is not set (ie., zero), the handler will need
 * to open and close the database itself and is not allowed to access global
 * or static variables.
 *
 *************************************************************/

Const

// NOTE: for defining custom action codes, see sysAppLaunchCmdCustomBase below.

// System SysAppLaunch Commands
  sysAppLaunchCmdNormalLaunch      =0;  // Normal Launch

  sysAppLaunchCmdFind              =1;  // Find string

  sysAppLaunchCmdGoTo              =2;  // Launch and go to a particular record

  sysAppLaunchCmdSyncNotify        =3;
    // Sent to apps whose databases changed during
    // HotSync after the sync has been completed,
    // including when the app itself has been installed
    // by HotSync. The data database(s) must have the
    // same creator ID as the application for this
    // mechanism to function correctly. This is a
    // good opportunity to update/initialize/validate
    // the app's data, such as resorting records,
    // setting alarms, etc.
    //
    // Parameter block: None.
    // Restrictions: No accessing of global or
    //    static variables; no User Interface calls.
    // Notes: This action code is sent via a
    //    direct function call into the app's
    //    PilotMain function from the background
    //    thread of the HotSync application.


  sysAppLaunchCmdTimeChange        =4;
    // Sent to all applications and preference
    // panels when the system time is changed.
    // This notification is the right place to
    // update alarms and other time-related
    // activities and resources.
    //
    // Parameter block: None.
    // Restrictions: No accessing of global or
    //    static variables; no User Interface calls.
    // Notes: This action code is sent via a direct
    //    function call into the app's PilotMain
    //    function without "launching" the app.

  sysAppLaunchCmdSystemReset       =5;
    // Sent to all applications and preference
    // panels when the system is either soft-reset
    // or hard-reset.  This notification is the
    // right place to initialize and/or validate
    // your application's preferences/features/
    // database(s) as well as to update alarms and
    // other time-related activities and resources.
    //
    // Parameter block: SysAppLaunchCmdSystemResetType
    // Restrictions: No accessing of global or
    //    static variables; no User Interface calls.
    // Notes: This action code is sent via a direct
    //    function call into the app's PilotMain
    //    function without "launching" the app.

  sysAppLaunchCmdAlarmTriggered    =6;
    // Sent to an application at the time its
    // alarm time expires (even when another app
    // is already displaying its alarm dialog box).
    // This call is intended to allow the app to
    // perform some very quick activity, such as
    // scheduling the next alarm or performing a
    // quick maintenance task.  The handler for
    // sysAppLaunchCmdAlarmTriggered must take as
    // little time as possible and is *not* allowed
    // to block (this would delay notification for
    // alarms set by other applications).
    //
    // Parameter block: SysAlarmTriggeredParamType
    //    (defined in AlarmMgr.h)
    // Restrictions: No accessing of global or
    //    static variables unless sysAppLaunchFlagSubCall
    //    flag is set, as discussed above.
    // Notes: This action code is sent via a direct
    //    function call into the app's PilotMain
    //    function without "launching" the app.

  sysAppLaunchCmdDisplayAlarm      =7;
    // Sent to an application when it is time
    // to display the alarm UI. The application
    // is responsible for making any alarm sounds
    // and for displaying the alarm UI.
    // sysAppLaunchCmdDisplayAlarm calls are ordered
    // chronoligically and are not overlapped.
    // This means that your app will receive
    // sysAppLaunchCmdDisplayAlarm only after
    // all earlier alarms have been displayed.
    //
    // Parameter block: SysDisplayAlarmParamType
    //    (defined in AlarmMgr.h)
    // Restrictions: No accessing of global or
    //    static variables unless sysAppLaunchFlagSubCall
    //    flag is set, as discussed above.  UI calls are
    //    allowed to display the app's alarm dialog.
    // Notes: This action code is sent via a direct
    //    function call into the app's PilotMain
    //    function without "launching" the app.

  sysAppLaunchCmdCountryChange     =8;  // The country has changed

  sysAppLaunchCmdSyncRequestLocal  =9;
    // Sent to the HotSync application to request a
    // local HotSync.  ("HotSync" button was pressed.)

  sysAppLaunchCmdSyncRequest       =sysAppLaunchCmdSyncRequestLocal;  // for backward compatibility

  sysAppLaunchCmdSaveData          =10;
    // Sent to running app before sysAppLaunchCmdFind
    // or other action codes that will cause data
    // searches or manipulation.

  sysAppLaunchCmdInitDatabase      =11;
    // Sent to an application when a database with
    // a matching Creator ID is created during
    // HotSync (in response to a "create db"
    // request). This allows the application to
    // initialize a newly-created database during
    // HotSync.  This might include creating some
    // default records, setting up the database's
    // application and sort info blocks, etc.
    //
    // Parameter block: SysAppLaunchCmdInitDatabaseType
    // Restrictions: No accessing of global or
    //    static variables; no User Interface calls.
    // Notes: This action code is sent via a
    //    direct function call into the app's
    //    PilotMain function from the background
    //    thread of the HotSync application.

  sysAppLaunchCmdSyncCallApplicationV10  =12;
    // Used by DesktopLink Server command "call application";
    // Pilot v1.0 only!!!

//------------------------------------------------------------------------
// New launch codes defined for PalmOS 2.0
//------------------------------------------------------------------------

  sysAppLaunchCmdPanelCalledFromApp   =13;
    // The panel should display a done
    // button instead of the pick list.
    // The Done button will return the user
    // to the last app.

  sysAppLaunchCmdReturnFromPanel      =14;
    // A panel returned to this app

  sysAppLaunchCmdLookup               =15;
    // Lookup info managed by an app

  sysAppLaunchCmdSystemLock           =16;
    // Lock the system until a password is entered.

  sysAppLaunchCmdSyncRequestRemote    =17;
    // Sent to the HotSync application to request
    // a remote HotSync.  ("Remote HotSync" button
    // was pressed.)

  sysAppLaunchCmdHandleSyncCallApp    =18;
    // Pilot v2.0 and greater.  Sent by DesktopLink Server to an application to handle
    // the "call application" command; use DlkControl with
    // control code dlkCtlSendCallAppReply to send the reply(see DLServer.h).
    // This action code replaces the v1.0 code sysAppLaunchCmdSyncCallApplication.
    // vmk 11/26/96

  sysAppLaunchCmdAddRecord             =19;
    // =Add a record to an applications's database.


//------------------------------------------------------------------------
// Standard Service Panel launch codes (used by network panel, dialer panel, etc.)
// (LATER... document parameter block structures)
//------------------------------------------------------------------------
  sysSvcLaunchCmdSetServiceID         =20;
  sysSvcLaunchCmdGetServiceID         =21;
  sysSvcLaunchCmdGetServiceList       =22;
  sysSvcLaunchCmdGetServiceInfo       =23;


  sysAppLaunchCmdFailedAppNotify       =24; // An app just switched to failed.
  sysAppLaunchCmdEventHook             =25; // Application event hook callback
  sysAppLaunchCmdExgReceiveData        =26; // Exg command for app to receive data.
  sysAppLaunchCmdExgAskUser            =27; // Exg command sent before asking user.


//------------------------------------------------------------------------
// Standard Dialer Service launch codes (30 - 39 reserved)
// (LATER... document parameter block structures)
//------------------------------------------------------------------------

    // sysDialLaunchCmdDial: dials the modem(optionally displays dial progress UI), given service id
    // and serial library reference number
  sysDialLaunchCmdDial                 =30;
    // sysDialLaunchCmdHangUp: hangs up the modem(optionally displays disconnect progress UI), given service id
    // and serial library reference number
  sysDialLaunchCmdHangUp               =31;
  sysDialLaunchCmdLast                 =39;


//------------------------------------------------------------------------
// Additional standard Service Panel launch codes (used by network panel, dialer panel, etc)
// (40-49 reserved)
//------------------------------------------------------------------------

  sysSvcLaunchCmdGetQuickEditLabel     =40;    // SvcQuickEditLabelInfoType
  sysSvcLaunchCmdLast                  =49;


//------------------------------------------------------------------------
// New launch codes defined for PalmOS 3.x where x >= 1
//------------------------------------------------------------------------

  sysAppLaunchCmdURLParams             =50;
    // Sent from the Web Clipper application.
    // This launch code gets used to satisfy
    // URLs like the following:
    //    palm:memo.appl?param1=value1&param2=value2
    // Everything in the URL past the '?' is passed
    // to the app as the cmdPBP parameter of PilotMain().

  sysAppLaunchCmdNotify                =51;
    // This is a NotifyMgr notification sent
    // via SysNotifyBroadcast.  The cmdPBP parameter
    // points to a SysNotifyParamType structure
    // containing more specific information
    // about the notification (e.g., what it's for).
                                                   
  sysAppLaunchCmdOpenDB                =52;
    // Sent to switch to an application and have it
    // "open" up the given data file. The cmdPBP
    // pointer is a pointer to a SysAppLaunchCmdOpenDBType
    // structure that has the cardNo and localID of the database
    // to open. This action code is used by the Launcher
    // to launch data files, like Eleven PQA files that
    // have the dmHdrAttrLaunchableData bit set in their
    // database attributes. 

  sysAppLaunchCmdAntennaUp             =53;
    // Sent to switch only to the launcher when
    // the antenna is raised and the launcher
    // is the application in the buttons preferences
    // that is to be run when the antenna is raised is
    // the launcher.

  sysAppLaunchCmdGoToURL               =54;
    // Sent to Clipper to have it launch and display
    // a given URL.  cmdPBP points to the URL string.


// ***ADD NEW SYSTEM ACTION CODES BEFORE THIS COMMENT***

//------------------------------------------------------------------------
// Custom action code base (custom action codes begin at this value)
//------------------------------------------------------------------------
  sysAppLaunchCmdCustomBase  =0x8000;

// Your custom launch codes can be defined like this:
//
// MyAppCustomActionCodes = (
//    myAppCmdDoSomething = sysAppLaunchCmdCustomBase,
//    myAppCmdDoSomethingElse,
//    myAppCmdEtcetera
//  );



//------------------------------------------------------------------------
// SysAppLaunch flags (passed to PilotMain)
//------------------------------------------------------------------------

  sysAppLaunchFlagNewThread    =0x01;  // create a new thread for application
                                       //  - implies sysAppLaunchFlagNewStack
  sysAppLaunchFlagNewStack     =0x02;  // create separate stack for application
  sysAppLaunchFlagNewGlobals   =0x04;  // create new globals world for application
                                       //  - implies new owner ID for Memory chunks
  sysAppLaunchFlagUIApp        =0x08;  // notifies launch routine that this is a UI app being
                                       //  launched.
  sysAppLaunchFlagSubCall      =0x10;  // notifies launch routine that the app is calling it's
                                       //  entry point as a subroutine call. This tells the launch
                                       //  code that it's OK to keep the A5 (globals) pointer valid
                                       //  through the call.
                                       // IMPORTANT: This flag is for internal use by
                                       //  SysAppLaunch only!!! It should NEVER be set
                                       //  by the caller.
  sysAppLaunchFlagDataRelocated=0x80;  // global data (static ptrs) have been "relocated"
                                       //  by either SysAppStartup or StartupCode.c
                                       // IMPORTANT: This flag is for internal use by
                                       //  SysAppLaunch only!!! It should NEVER be set
                                       //  by the caller.

// The set of private, internal flags that should never be set by the caller
   sysAppLaunchFlagPrivateSet     =sysAppLaunchFlagSubCall | sysAppLaunchFlagDataRelocated;



//-------------------------------------------------------------------
// Parameter blocks for action codes
// NOTE: The parameter block for the  sysAppLaunchCmdFind  and sysAppLaunchCmdGoTo
//  action codes are defined in "Find.h";
//---------------------------------------------------------------------------

Type
// For sysAppLaunchCmdSaveData
  SysAppLaunchCmdSaveDataType = Record
    uiComing: Boolean; // true if system dialog will be put up
                       // before coming action code arrives.
    reserved1: UInt8;
  end;

// For sysAppLaunchCmdSystemReset
  SysAppLaunchCmdSystemResetType= Record
    hardReset: Boolean;                         // true if system was hardReset, false if soft-reset.
    createDefaultDB: Boolean;                   // true if app should create default database.
   end;


// For sysAppLaunchCmdInitDatabase
  SysAppLaunchCmdInitDatabaseType = Record
    dbP: DmOpenRef;                             // Handle of the newly-created database,
                                                //    already open for read/write access.
                                                //    IMPORTANT: The handler *MUST* leave
                                                //    this database handle open on return.
    creator: UInt32;                            // Creator ID of the newly-created database
    typ: UInt32;                                // Type ID of the newly-created database
    version: UInt16;                            // Version number of the newly-created database
  end;


// For sysAppLaunchCmdSyncCallApplicationV10
// This structure used on Pilot v1.0 only.  See sysAppLaunchCmdHandleSyncCallApp
// for later platforms.
  SysAppLaunchCmdSyncCallApplicationTypeV10 = Record
    action: UInt16;                    // call action id (app-specific)
    paramSize: UInt16;                 // parameter size
    paramP: Pointer;                   // ptr to parameter
    remoteSocket: UInt8;               // remote socket id
    tid: UInt8;                        // command transaction id
    handled: Boolean;                  // if handled, MUST be set true by the app
    reserved1: UInt8;       
  end;


// For sysAppLaunchCmdHandleSyncCallApp (Pilot v2.0 and greater).
// This structure replaces SysAppLaunchCmdSyncCallApplicationType
// which was used in Pilot v1.0
  SysAppLaunchCmdHandleSyncCallAppType = Record
    pbSize: UInt16;                    // this parameter block size (set to sizeof SysAppLaunchCmdHandleSyncCallAppType)
    action: UInt16;                    // call action id (app-specific)
    paramP: Pointer;                   // ptr to parameter
    dwParamSize: UInt32;               // parameter size
    dlRefP: Pointer;                   // DesktopLink reference pointer for passing
                                       // to DlkControl()'s dlkCtlSendCallAppReply code

    handled: Boolean;                  // initialized to FALSE by DLServer; if
                                       // handled, MUST be set TRUE by the app(the
                                       // handler MUST call DlkControl with
                                       // control code dlkCtlSendCallAppReply);
                                       // if the handler is not going to send a reply,
                                       // it should leave this field set to FALSE, in which
                                       // case DesktopLink Server will send the default
                                       // "unknown request" reply.

    reserved1: UInt8;       

    replyErr: Err;                     // error from dlkCtlSendCallAppReply

    // RESERVED FOR FUTURE EXTENSIONS
    dwReserved1: UInt32;               // RESERVED -- set to null!!!
    dwReserved2: UInt32;               // RESERVED -- set to null!!!

    // Target executable creator and type for testing the mechanism
    // in EMULATION MODE ONLY!!!
    //UInt32      creator;
    //   UInt32      type;
  end;

// For sysAppLaunchCmdFailedAppNotify
  SysAppLaunchCmdFailedAppNotifyType = Record
    creator: UInt32;      
    typ: UInt32;      
    result: Err;         
  end;


// For sysAppLaunchCmdOpenDB
  SysAppLaunchCmdOpenDBType = Record
    cardNo: UInt16;      
    dbID: LocalID;     
  end;


/************************************************************
 * Function prototype for libraries
 *************************************************************/

// ***IMPORTANT***
// ***IMPORTANT***
// ***IMPORTANT***
//
// The assembly level TrapDispatcher() function uses a hard-coded value for
// the size of the structure SysLibTblEntryType to obtain a pointer to a
// library entry in the library table.  Therefore, any changes to this structure,
// require corresponding changes in TrapDispatcher() in ROMBoot.c.  Furthermore,
// it is advantageous to keep the size of the structure a power of 2 as this
// improves performance by allowing the entry offset to be calculated by shifting
// left instead of using the multiply instruction.  vmk 8/27/96 (yes, I fell into
// this trap myself)
  SysLibTblEntryPtr = ^SysLibTblEntryType;
  SysLibTblEntryType = Record
    dispatchTblP: MemHandle;                      // pointer to library dispatch table
    globalsP: Pointer;                            // Library globals

    // New INTERNAL fields for v2.0 (vmk 8/27/96):
    dbID: LocalID;                                // database id of the library
    codeRscH: Pointer;                            // library code resource handle for RAM-based libraries
  end;

// Emulated versions of libraries have a slightly different dispatch table
// Enough for the offset to the library name and the name itself.
//........

// Library entry point procedure
// Err (*SysLibEntryProcPtr)(UInt16 refNum, SysLibTblEntryPtr entryP);
  SysLibEntryProcPtr = Pointer;
  
// This library refNum is reserved for the Debugger comm library
Const
  sysDbgCommLibraryRefNum    =0;

// This portID is reserved for identifying the debugger's port
  sysDbgCommPortID           =0xC0FF;

// This refNum signals an invalid refNum
  sysInvalidRefNum           =0xFFFF;


/************************************************************
 * Function prototype for Kernel
 *************************************************************/
Type
// Task termination procedure prototype for use with SysTaskSetTermProc
// void (*SysTermProcPtr)(UInt32 taskID, Int32 reason);
  SysTermProcPtr = Pointer;

// Timer procedure for use with SysTimerCreate
// void (*SysTimerProcPtr)(Int32 timerID, Int32 param);
  SysTimerProcPtr = Pointer;




/************************************************************
 * System Errors
 *************************************************************/
Const
  sysErrTimeout                    =sysErrorClass | 1;
  sysErrParamErr                   =sysErrorClass | 2;
  sysErrNoFreeResource             =sysErrorClass | 3;
  sysErrNoFreeRAM                  =sysErrorClass | 4;
  sysErrNotAllowed                 =sysErrorClass | 5;
  sysErrSemInUse                   =sysErrorClass | 6;
  sysErrInvalidID                  =sysErrorClass | 7;
  sysErrOutOfOwnerIDs              =sysErrorClass | 8;
  sysErrNoFreeLibSlots             =sysErrorClass | 9;
  sysErrLibNotFound                =sysErrorClass | 10;
  sysErrDelayWakened               =sysErrorClass | 11;    // SysTaskDelay wakened by SysTaskWake before delay completed.
  sysErrRomIncompatible            =sysErrorClass | 12;
  sysErrBufTooSmall                =sysErrorClass | 13;
  sysErrPrefNotFound               =sysErrorClass | 14;

// NotifyMgr error codes:
  sysNotifyErrEntryNotFound        =sysErrorClass | 16; // could not find registration entry in the list
  sysNotifyErrDuplicateEntry       =sysErrorClass | 17; // identical entry already exists
  sysNotifyErrBroadcastBusy        =sysErrorClass | 19; // a broadcast is already in progress - try again later.
  sysNotifyErrBroadcastCancelled   =sysErrorClass | 20; // a handler cancelled the broadcast

// AMX error codes continued - jb 10/20/98
  sysErrMbId                       =sysErrorClass | 21;
  sysErrMbNone                     =sysErrorClass | 22; 
  sysErrMbBusy                     =sysErrorClass | 23;
  sysErrMbFull                     =sysErrorClass | 24;
  sysErrMbDepth                    =sysErrorClass | 25;
  sysErrMbEnv                      =sysErrorClass | 26;

// NotifyMgr Phase #2 Error Codes:
  sysNotifyErrQueueFull            =sysErrorClass | 27; // deferred queue is full.
  sysNotifyErrQueueEmpty           =sysErrorClass | 28; // deferred queue is empty.
  sysNotifyErrNoStackSpace         =sysErrorClass | 29; // not enough stack space for a broadcast
  sysErrNotInitialized             =sysErrorClass | 30; // manager is not initialized

// AMX error/warning codes continued - jed 9/10/99
  sysErrNotAsleep                  =sysErrorClass | 31;    // Task woken by SysTaskWake was not asleep, 1 wake pending


// Power Manager error codes - should these be located elsewhere? -soe-
  pwrErrNone                       =pwrErrorClass | 00;
  pwrErrBacklight                  =pwrErrorClass | 01;
  pwrErrRadio                      =pwrErrorClass | 02;
  pwrErrBeam                       =pwrErrorClass | 03;



/************************************************************
 * System Features
 *************************************************************/
  sysFtrCreator        =sysFileCSystem;    // Feature Creator

  sysFtrNumROMVersion  =1;                 // ROM Version
         // 0xMMmfsbbb, where MM is major version, m is minor version
         // f is bug fix, s is stage: 3-release,2-beta,1-alpha,0-development,
         // bbb is build number for non-releases 
         // V1.12b3   would be: 0x01122003
         // V2.00a2   would be: 0x02001002
         // V1.01     would be: 0x01013000

  sysFtrNumProcessorID =2;                 // Product id
         // 0xMMMMRRRR, where MMMM is the processor model and RRRR is the revision.
  sysFtrNumProcessorMask  =0xFFFF0000;     // Mask to obtain processor model
  sysFtrNumProcessor328   =0x00010000;     // Motorola 68328    (Dragonball)
  sysFtrNumProcessorEZ    =0x00020000;     // Motorola 68EZ328  (Dragonball EZ)
  sysFtrNumProductID   =sysFtrNumProcessorID; // old (obsolete) define

  sysFtrNumBacklight   =3;                 // Backlight
         // bit 0:   1 if present. 0 if Feature does not exist or backlight is not present

  sysFtrNumEncryption  =4;                 // Which encryption schemes are present
  sysFtrNumEncryptionMaskDES  =0x00000001; // bit 0: 1 if DES is present

  sysFtrNumCountry     =5;                 // International ROM identifier
         // Result is of type CountryType as defined in Preferences.h.
         // Result is essentially the "default" country for this ROM.
         // Assume cUnitedStates if sysFtrNumROMVersion >= 02000000
         // and feature does not exist. Result is in low sixteen bits.
         
  sysFtrNumLanguage    =6;                 // Language identifier
         // Result is of untyped; values are defined in Incs:BuildRules.h
         // Result is essentially the "default" language for this ROM.
         // This is new for the WorkPad (v2.0.2) and did NOT exist for any of the
         // following: GermanPersonal, GermanPro, FrenchPersonal, FrenchPro
         // Thus we can't really assume anything if the feature doesn't exist,
         // though the actual language MAY be determined from sysFtrNumCountry,
         // above. Result is in low sixteen bits.

  sysFtrNumDisplayDepth   =7;              // Display depth
         // Result is the "default" display depth for the screen. (Added in PalmOS 3.0)
         // This value is used by ScrDisplayMode when setting the default display depth.
         
  sysFtrNumHwrMiscFlags      =8;           // HwrMiscFlags value (Added in PalmOS 3.1)
  sysFtrNumHwrMiscFlagsExt   =9;           // HwrMiscFlagsExt value (Added in PalmOS 3.1)
         
  sysFtrNumIntlMgr           =10;
         // Result is a set of flags that define functionality supported
         // by the Int'l Manager.

  sysFtrNumEncoding          =11;
         // Result is the character encoding (defined in TextMgr.h) supported
         // by this ROM. If this feature doesn't exist then the assumed encoding
         // is latin (Windows code page 1252).
         
  sysFtrDefaultFont          =12;
         // Default font ID used for displaying text.

  sysFtrDefaultBoldFont      =13;
         // Default font ID used for displaying bold text.

  sysFtrNumGremlinsSupportGlobals  =14;    // Globals for supporting gremlins.
         // This value is a pointer to a memory location that stores global variables
         // needed for intelligently supporting gremlins.  Currently, it is only used
         // in Progress.c.  It is only initialized on first use (gremlins and progress
         // bar in combination) when ERROR_CHECK_LEVEL == ERROR_CHECK_FULL.

  sysFtrNumVendor            =15;
         // Result is the vendor id, in the low sixteen bits.

  sysFtrNumCharEncodingFlags =16;
         // Flags for a given character encoding, specified in TextMgr.h
         
  sysFtrNumNotifyMgrVersion  =17; // version of the NotifyMgr, if any
         
         
         
/************************************************************
 * ROM token information (for SysGetROMToken, below)
 *************************************************************/
// Additional tokens and token information is located in <Hardware.h>
  sysROMTokenSnum         ='snum';   // Memory Card Flash ID (serial number)


/************************************************************
 * Macros for extracting and combining ROM/OS version components
 *************************************************************/

// ROM/OS stage numbers
  sysROMStageDevelopment   =0;
  sysROMStageAlpha         =1;
  sysROMStageBeta          =2;
  sysROMStageRelease       =3;


(****** No macroes in HSPascal
// MACRO: sysMakeROMVersion
//
// Builds a ROM version value from the major, minor, fix, stage, and build numbers
//
#define sysMakeROMVersion(major, minor, fix, stage, buildNum)        \
      (                                                              \
      (((UInt32)((UInt8)(major) & 0x0FF)) << 24) |                   \
      (((UInt32)((UInt8)(minor) & 0x00F)) << 20) |                   \
      (((UInt32)((UInt8)(fix)   & 0x00F)) << 16) |                   \
      (((UInt32)((UInt8)(stage) & 0x00F)) << 12) |                   \
      (((UInt32)((UInt16)(buildNum) & 0x0FFF)))                         \
      )


// Macros for parsing the ROM version number
// (the system OS version is obtained by calling
// FtrGet(sysFtrCreator, sysFtrNumROMVersion, dwOSVerP), where dwOSVerP is
// a pointer to to a UInt32 variable that is to receive the OS version number)
#define sysGetROMVerMajor(dwROMVer)    (((UInt16)((dwROMVer) >> 24)) & 0x00FF)
#define sysGetROMVerMinor(dwROMVer)    (((UInt16)((dwROMVer) >> 20)) & 0x000F)
#define sysGetROMVerFix(dwROMVer)      (((UInt16)((dwROMVer) >> 16)) & 0x000F)
#define sysGetROMVerStage(dwROMVer)    (((UInt16)((dwROMVer) >> 12)) & 0x000F)
#define sysGetROMVerBuild(dwROMVer)    (((UInt16)(dwROMVer))         & 0x0FFF)
(********)



/************************************************************
 * System Types
 *************************************************************/

Type

// Types of batteries installed.
  SysBatteryKind = (
    sysBatteryKindAlkaline=0,
    sysBatteryKindNiCad,
    sysBatteryKindLiIon,
    sysBatteryKindRechAlk,
    sysBatteryKindNiMH,
    sysBatteryKindLiIon1400,
    sysBatteryKindLast=0xFF   // insert new battery types BEFORE this one
  );

// Different battery states (output of hwrBattery)
  SysBatteryState = (
    sysBatteryStateNormal=0,
    sysBatteryStateLowBattery,
    sysBatteryStateCritBattery,
    sysBatteryStateShutdown
  );


// SysCreateDataBaseList can generate a list of database.
  SysDBListItemType = Record
    name: String[dmDBNameLength-1];
    creator: UInt32;      
    typ: UInt32;      
    version: UInt16;      
    dbID: LocalID;     
    cardNo: UInt16;
    iconP: BitmapPtr;
  end;


// Structure of a generic message that can be send to a mailbox
// through the SysMailboxSend call. Note, this structure MUST
// be  CJ_MAXMSZ bytes large, where CJ_MAXMSZ is defined in
// the AMX includes.
  SysMailboxMsgType = Record
    data: Array[0..2] of UInt32;
  end;


Const
// Constants used by the SysEvGroupSignal call
  sysEvGroupSignalConstant         =0; 
  sysEvGroupSignalPulse            =1; 

// Constants used by the SysEvGroupWait call
  sysEvGroupWaitOR                 =0; 
  sysEvGroupWaitAND                =1; 



/************************************************************
 * System Pre-defined "file descriptors"
 * These are used by applications that use the  Net Library's
 *   NetLibSelect() call
 *************************************************************/
  sysFileDescStdIn                 =0;


/************************************************************
 * Function Prototypes
 *************************************************************/

// Prototype for Pilot applications entry point
//Not needed in HSPascal
//Function PilotMain(cmd: UInt16; cmdPBP: Pointer; launchFlags: UInt16): UInt32;


// SystemMgr routines
Procedure SysUnimplemented;
                     SYS_TRAP(sysTrapSysUnimplemented);

Procedure SysColdBoot(card0P: Pointer; card0Size: UInt32;
                     card1P: Pointer; card1Size: UInt32;
                     sysCardHeaderOffset: UInt32);
                     SYS_TRAP(sysTrapSysColdBoot);

Procedure SysInit;
                     SYS_TRAP(sysTrapSysInit);

Procedure SysReset;
                     SYS_TRAP(sysTrapSysReset);

(*** ???
Procedure SysPowerOn(card0P: Pointer; card0Size: UInt32;
                     card1P: Pointer; card1Size: UInt32;
                     sysCardHeaderOffset: UInt32; reFormat: Boolean);
(*********)

Procedure SysDoze(onlyNMI: Boolean);
                     SYS_TRAP(sysTrapSysDoze);

Function SysSetPerformance(var sysClockP: UInt32; var cpuDutyP: UInt16): Err;
                     SYS_TRAP(sysTrapSysSetPerformance);

Procedure SysSleep(untilReset: Boolean; emergency: Boolean);
                     SYS_TRAP(sysTrapSysSleep);

Function SysSetAutoOffTime(seconds: UInt16): UInt16;
                     SYS_TRAP(sysTrapSysSetAutoOffTime);

Function SysTicksPerSecond: UInt16;
                     SYS_TRAP(sysTrapSysTicksPerSecond);

Function SysLaunchConsole: Err;
                     SYS_TRAP(sysTrapSysLaunchConsole);

Function SysHandleEvent(var Event{: EventType}): Boolean;
                     SYS_TRAP(sysTrapSysHandleEvent);

{x$ifdef PalmVer35}
Function SysWantEvent(var Event{: EventType}; var needsUI: Boolean): Boolean;
                     SYS_TRAP(sysTrapSysWantEvent);
{x$endif}

Procedure SysUILaunch;
                     SYS_TRAP(sysTrapSysUILaunch);

Function SysUIAppSwitch(cardNo: UInt16; dbID: LocalID; cmd: UInt16; cmdPBP: MemPtr): Err;
                     SYS_TRAP(sysTrapSysUIAppSwitch);

Function SysCurAppDatabase(var cardNoP: UInt16; var dbIDP: LocalID): Err;
                     SYS_TRAP(sysTrapSysCurAppDatabase);

Function SysBroadcastActionCode(cmd: UInt16; cmdPBP: MemPtr): Err;
                     SYS_TRAP(sysTrapSysBroadcastActionCode);

Function SysAppLaunch(cardNo: UInt16; dbID: LocalID; launchFlags: UInt16;
                     cmd: UInt16; cmdPBP: MemPtr; var resultP: UInt32): Err;
                     SYS_TRAP(sysTrapSysAppLaunch);

Function SysNewOwnerID: UInt16;
                     SYS_TRAP(sysTrapSysNewOwnerID);

Function SysSetA5(newValue: UInt32): UInt32;
                     SYS_TRAP(sysTrapSysSetA5);


//#if EMULATION_LEVEL != EMULATION_NONE
//MemPtr      SysCardImageInfo(cardNo: UInt16; var sizeP: UInt32);
//Procedure SysCardImageDeleted(cardNo: UInt16);
//#endif  // EMULATION_LEVEL != EMULATION_NONE

{x$ifdef PalmVer35} 
Function SysUIBusy(doSet, value: Boolean): UInt16;
                     SYS_TRAP(sysTrapSysUIBusy);

Function SysLCDContrast(doSet: Boolean; newContrastLevel: UInt8): Uint8;
                     SYS_TRAP(sysTrapSysLCDContrast);

Function SysLCDBrightness(doSet: Boolean; newBrightnessLevel: UInt8): UInt8;
                     SYS_TRAP(sysTrapSysLCDBrightness);
{x$endif}


// System Dialogs
Procedure SysBatteryDialog;
                     SYS_TRAP(sysTrapSysBatteryDialog);

// Utilities
Function SysSetTrapAddress(trapNum: UInt16; procP: Pointer): Err;
                     SYS_TRAP(sysTrapSysSetTrapAddress);

Function SysGetTrapAddress(trapNum: UInt16): Pointer;
                     SYS_TRAP(sysTrapSysGetTrapAddress);

Function SysDisableInts: UInt16;
                     SYS_TRAP(sysTrapSysDisableInts);

Procedure SysRestoreStatus(status: UInt16);
                     SYS_TRAP(sysTrapSysRestoreStatus);

Function SysGetOSVersionString: pChar;
                     SYS_TRAP(sysTrapSysGetOSVersionString);

// The following trap is a public definition of HwrGetROMToken from <Hardware.h>
// See token definitions (like sysROMTokenSerial) above...
Function SysGetROMToken(cardNo: UInt16; token: UInt32; dataP: Pointer; var sizeP: UInt16): Err;
                     SYS_TRAP(sysTrapHwrGetROMToken);


// Library Management
Function SysLibInstall(libraryP: SysLibEntryProcPtr; var refNumP: UInt16): Err;
                     SYS_TRAP(sysTrapSysLibInstall);

Function SysLibLoad(libType: UInt32; libCreator: UInt32; var refNumP: UInt16): Err;
                     SYS_TRAP(sysTrapSysLibLoad);


Function SysLibRemove(refNum: UInt16): Err;
                     SYS_TRAP(sysTrapSysLibRemove);

Function SysLibFind(const nameP: String; var refNumP: UInt16): Err;
                     SYS_TRAP(sysTrapSysLibFind);

Function SysLibTblEntry(refNum: UInt16): SysLibTblEntryPtr;
                     SYS_TRAP(sysTrapSysLibTblEntry);

// Generic Library calls
Function SysLibOpen(refNum: UInt16): Err;
                     SYS_TRAP(sysLibTrapOpen);
Function SysLibClose(refNum: UInt16): Err;
                     SYS_TRAP(sysLibTrapClose);
Function SysLibSleep(refNum: UInt16): Err;
                     SYS_TRAP(sysLibTrapSleep);
Function SysLibWake(refNum: UInt16): Err;
                     SYS_TRAP(sysLibTrapWake);


//-----------------------------------------------------
// Kernel Prototypes
//-----------------------------------------------------
// Task Creation and deleation
Function SysTranslateKernelErr(error: Err): Err;
                     SYS_TRAP(sysTrapSysTranslateKernelErr);

Function SysTaskCreate(var taskIDP, creator: UInt32; codeP: Pointer;
                     stackP: MemPtr;
                     stackSize, attr, priority, tSlice: UInt32): Err;
                     SYS_TRAP(sysTrapSysTaskCreate);
                     
Function SysTaskDelete(taskID: UInt32; priority: UInt32): Err;
                     SYS_TRAP(sysTrapSysTaskDelete);

Function SysTaskTrigger(taskID: UInt32): Err;
                     SYS_TRAP(sysTrapSysTaskTrigger);

Function SysTaskID: UInt32;
                     SYS_TRAP(sysTrapSysTaskID);

Function SysTaskDelay(Delay: Int32): Err;
                     SYS_TRAP(sysTrapSysTaskDelay);

Function SysTaskSetTermProc(taskID: UInt32; termProcP: SysTermProcPtr): Err;
                     SYS_TRAP(sysTrapSysTaskSetTermProc);

Function SysTaskSwitching(enable: Boolean): Err;
                     SYS_TRAP(sysTrapSysTaskSwitching);

Function SysTaskWait(timeout: Int32): Err;
                     SYS_TRAP(sysTrapSysTaskWait);

Function SysTaskWake(taskID: UInt32): Err;
                     SYS_TRAP(sysTrapSysTaskWake);

Procedure SysTaskWaitClr;
                     SYS_TRAP(sysTrapSysTaskWaitClr);

Function SysTaskSuspend(taskID: UInt32): Err;
                     SYS_TRAP(sysTrapSysTaskSuspend);

Function SysTaskResume(taskID: UInt32): Err;
                     SYS_TRAP(sysTrapSysTaskResume);


// Counting Semaphores
Function SysSemaphoreCreate(var smIDP, tagP: UInt32; initValue: Int32): Err;
                     SYS_TRAP(sysTrapSysSemaphoreCreate);

Function SysSemaphoreDelete(smID: UInt32): Err;
                     SYS_TRAP(sysTrapSysSemaphoreDelete);

Function SysSemaphoreWait(smID, priority, timeout: Int32): Err;
                     SYS_TRAP(sysTrapSysSemaphoreWait);

Function SysSemaphoreSignal(smID: UInt32): Err;
                     SYS_TRAP(sysTrapSysSemaphoreSignal);

Function SysSemaphoreSet(smID: UInt32): Err;
                     SYS_TRAP(sysTrapSysSemaphoreSet);


// Resource Semaphores
Function SysResSemaphoreCreate(var smIDP, tagP: UInt32): Err;
                     SYS_TRAP(sysTrapSysResSemaphoreCreate);

Function SysResSemaphoreDelete(smID: UInt32): Err;
                     SYS_TRAP(sysTrapSysResSemaphoreDelete);

Function SysResSemaphoreReserve(smID, priority: UInt32; timeout: Int32): Err;
                     SYS_TRAP(sysTrapSysResSemaphoreReserve);
                     
Function SysResSemaphoreRelease(smID: UInt32): Err;
                     SYS_TRAP(sysTrapSysResSemaphoreRelease);



// Timers
Function SysTimerCreate(var timerIDP,tagP: UInt32;
                     timerProc: SysTimerProcPtr; periodicDelay: UInt32;
                     param: UInt32): Err;
                     SYS_TRAP(sysTrapSysTimerCreate);

Function SysTimerDelete(timerID: UInt32): Err;
                     SYS_TRAP(sysTrapSysTimerDelete);

Function SysTimerWrite(timerID, value: UInt32): Err;
                     SYS_TRAP(sysTrapSysTimerWrite);

Function SysTimerRead(timerID: UInt32; var valueP: UInt32): Err;
                     SYS_TRAP(sysTrapSysTimerRead);


// Information
Function SysKernelInfo(paramP: Pointer): Err;
                     SYS_TRAP(sysTrapSysKernelInfo);

Function SysCreateDataBaseList(typ, creator: UInt32; var dbCount: UInt16;
                  var dbIDs: MemHandle; lookupName: Boolean): Boolean;
                     SYS_TRAP(sysTrapSysCreateDataBaseList);

Function SysCreatePanelList(var panelCount: UInt16; var panelIDs: MemHandle): Boolean;
                     SYS_TRAP(sysTrapSysCreatePanelList);

Function SysBatteryInfo(doSet: Boolean; var warnThresholdP, criticalThresholdP: UInt16;
                  var maxTicksP: Int16; var kindP: SysBatteryKind; var pluggedIn: Boolean; var percentP: UInt8): UInt16;
                     SYS_TRAP(sysTrapSysBatteryInfo);

Function SysBatteryInfoV20(doSet: Boolean; var warnThresholdP, criticalThresholdP: UInt16;
                  var maxTicksP: Int16; var kindP: SysBatteryKind; var pluggedIn: Boolean): UInt16;
                     SYS_TRAP(sysTrapSysBatteryInfoV20);

Function SysGetStackInfo(var startPP, endPP: MemPtr): Boolean;
                     SYS_TRAP(sysTrapSysGetStackInfo);



// Mailboxes
Function SysMailboxCreate(var mbIDP, tagP: UInt32; depth: UInt32): Err;
                     SYS_TRAP(sysTrapSysMailboxCreate);

Function SysMailboxDelete(mbID: UInt32): Err;
                     SYS_TRAP(sysTrapSysMailboxDelete);

Function SysMailboxFlush(mbID: UInt32): Err;
                     SYS_TRAP(sysTrapSysMailboxFlush);

Function SysMailboxSend(mbID: UInt32; msgP: Pointer; wAck: UInt32): Err;
                     SYS_TRAP(sysTrapSysMailboxSend);

Function SysMailboxWait(mbID: UInt32; msgP: Pointer; priority: UInt32;
                        timeout: Int32): Err;
                     SYS_TRAP(sysTrapSysMailboxWait);

// Event Groups
Function SysEvGroupCreate(var evIDP, tagP: UInt32; init: UInt32): Err;
                     SYS_TRAP(sysTrapSysEvGroupCreate);

//Function SysEvGroupDelete(UInt32 evID): Err;                         // save trap table space - don't need
                     //SYS_TRAP(sysTrapSysEvGroupDelete);

Function SysEvGroupSignal(evID, mask, value: UInt32; typ: Int32): Err;
                     SYS_TRAP(sysTrapSysEvGroupSignal);

Function SysEvGroupRead(evID: UInt32; var valueP: UInt32): Err;
                     SYS_TRAP(sysTrapSysEvGroupRead);
                     
Function SysEvGroupWait(evID, mask, value: UInt32;
                           matchType, timeout: Int32): Err;
                     SYS_TRAP(sysTrapSysEvGroupWait);

implementation

end.

