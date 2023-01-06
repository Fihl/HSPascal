/******************************************************************************
 *
 * Copyright (c) 1997-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: ExgMgr.h
 *
 * Description:
 *    Include file for Exg system functions
 *
 * History:
 *    5/23/97 Created by Gavin Peacock
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit ExgMgr;

interface

Uses {x$ifdef PalmVer30} Traps30, {x$endif}
     ErrorBase;

Const
  exgMemError           =exgErrorClass | 1;
  exgErrStackInit       =exgErrorClass | 2;  // stack could not initialize
  exgErrUserCancel      =exgErrorClass | 3;
  exgErrNoReceiver      =exgErrorClass | 4;  // receiver device not found
  exgErrNoKnownTarget   =exgErrorClass | 5;  // can't find a target app
  exgErrTargetMissing   =exgErrorClass | 6;  // target app is known but missing
  exgErrNotAllowed      =exgErrorClass | 7;  // operation not allowed
  exgErrBadData         =exgErrorClass | 8;  // internal data was not valid
  exgErrAppError        =exgErrorClass | 9;  // generic application error
  exgErrUnknown         =exgErrorClass | 10; // unknown general error
  exgErrDeviceFull      =exgErrorClass | 11; // device is full
  exgErrDisconnected    =exgErrorClass | 12; // link disconnected
  exgErrNotFound        =exgErrorClass | 13; // requested object not found
  exgErrBadParam        =exgErrorClass | 14; // bad parameter to call
  exgErrNotSupported    =exgErrorClass | 15; // operation not supported by this library
  exgErrDeviceBusy      =exgErrorClass | 16; // device is busy
  exgErrBadLibrary      =exgErrorClass | 17; // bad or missing ExgLibrary


Type
  ExgGoToPtr = ^ExgGoToType;
  ExgGoToType = Record
    dbCardNo: UInt16;                    // card number of the database
    dbID: LocalID;                    // LocalID of the database
    recordNum: UInt16;                   // index of record that contain a match
    uniqueID: UInt32;                    // postion in record of the match.
    matchCustom: UInt32;                 // application specific info
  end;

  ExgSocketPtr = ^ExgSocketType;
  ExgSocketType = Record
    libraryRef: UInt16;   // identifies the Exg library in use
    socketRef: UInt32;    // used by Exg library to identify this connection
    target: UInt32;       // Creator ID of application this is sent to
    count: UInt32;        // # of objects in this connection (usually 1)
    length: UInt32;       // # total byte count for all objects being sent (optional)
    time: UInt32;      // last modified time of object (optional)
    appData: UInt32;   // application specific info
    goToCreator: UInt32;   // creator ID of app to launch with goto after receive
    goToParams: ExgGoToType; // If launchCreator then this contains goto find info
    flags: UInt16;  
      //localMode:1; // Exchange with local machine only mode
      //packetMode:1;// Use connectionless packet mode (Ultra)
      //noGoTo:1;   // Do not go to app (local mode only)
      //noStatus:1; // Do not display status dialogs
      //reserved:12;// reserved system flags
    description: PChar;  // text description of object (for user)
    typ: PChar;       // Mime type of object (optional)
    name: PChar;      // name of object, generally a file name (optional)
  end;


// structures used for sysAppLaunchCmdExgAskUser launch code parameter
// default is exgAskDialog (ask user with dialog...
  ExgAskResultType = (exgAskDialog,exgAskOk,exgAskCancel);

  ExgAskParamPtr = ^ExgAskParamType;
  ExgAskParamType = Record
    socketP: ExgSocketPtr;     
    result: ExgAskResultType;         // what to do with dialog
    reserved: UInt8;            
  end;

Const
  exgSeparatorChar ='\t';    // char used to separate multiple registry entries

  exgRegLibraryID =$fffc;               // library register thier presence
  exgRegExtensionID =$fffd;          // filename extenstion registry
  exgRegTypeID =$fffe;                  // MIME type registry

  exgDataPrefVersion =0;
  exgMaxTitleLen     =20;             // max size for title from exgLibCtlGetTitle

  exgLibCtlGetTitle  =1;              // get title for Exg dialogs
  exgLibCtlSpecificOp =$8000;           // start of range for library specific control codes


Type
  ExgDBReadProcPtr= Pointer;
  ExgDBDeleteProcPtr= Pointer;
  ExgDBWriteProcPtr= Pointer;
(*** DOLATER
typedef Err (*ExgDBReadProcPtr)
            (void* dataP, UInt32* sizeP, void* userDataP);

typedef Boolean   (*ExgDBDeleteProcPtr)
            (const char* nameP, UInt16 version, UInt16 cardNo,
            LocalID dbID, void* userDataP);

typedef Err (*ExgDBWriteProcPtr)
            (const void* dataP, UInt32* sizeP, void* userDataP);
(***)


Function ExgInit: Err;
      SYS_TRAP(sysTrapExgInit);

Function ExgConnect(socketP: ExgSocketPtr): Err;
      SYS_TRAP(sysTrapExgConnect);

Function ExgPut(socketP: ExgSocketPtr): Err;
      SYS_TRAP(sysTrapExgPut);

Function ExgGet(socketP: ExgSocketPtr): Err;
      SYS_TRAP(sysTrapExgGet);

Function ExgAccept(socketP: ExgSocketPtr): Err;
      SYS_TRAP(sysTrapExgAccept);

Function ExgDisconnect(socketP: ExgSocketPtr; error: Err): Err;
      SYS_TRAP(sysTrapExgDisconnect);

Function ExgSend(socketP: ExgSocketPtr; const bufP: PChar; bufLen: UInt32; var error: Err): UInt32;
      SYS_TRAP(sysTrapExgSend);

Function ExgReceive(socketP: ExgSocketPtr; bufP: Pointer; bufLen: UInt32; var error: Err): UInt32;
      SYS_TRAP(sysTrapExgReceive);

Function ExgRegisterData(creatorID: UInt32; id: UInt16; dataTypesP: PChar): Err;
      SYS_TRAP(sysTrapExgRegisterData);

Function ExgNotifyReceive(socketP: ExgSocketPtr): Err;
      SYS_TRAP(sysTrapExgNotifyReceive);


Function ExgDBRead(
      readProcP: ExgDBReadProcPtr;    
      deleteProcP: ExgDBDeleteProcPtr;     
      userDataP: Pointer;            
      var dbIDP: LocalID;         
      cardNo: UInt16;
      var needResetP: Boolean;         
      keepDates: Boolean): Err;
      SYS_TRAP(sysTrapExgDBRead);

Function ExgDBWrite(
      writeProcP: ExgDBWriteProcPtr;   
      userDataP: Pointer;            
      nameP: PChar;         
      dbID: LocalID;
      cardNo: UInt16): Err;
      SYS_TRAP(sysTrapExgDBWrite);

implementation

end.

