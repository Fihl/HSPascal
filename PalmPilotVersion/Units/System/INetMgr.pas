/******************************************************************************
 *
 * Copyright (c) 1996-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: INetMgr.h
 *
 * Description:
 *   This header file contains equates for the Internet Library.
 *
 * History:
 *    6/2/97   Created by Ron Marianetti
 *    12/23/99 Fix <> vs. "" problem. (jmp)
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit INetMgr;

interface

Uses
  DataMgr, SystemResources, ErrorBase, Event;

Type
  INetUInt8Ptr = ^UInt8; //Or just PChar! Would look better
  INetUInt8Ptr2 = PChar; //Used for interface procedures

Const

// Creator. Used for both the database that contains the INet Library and
//  it's features for the feature manager.
  inetCreator          =sysFileCINetLib;      // The Net Library creator

// INet Library features have this creator
  inetLibFtrCreator    =sysFileCINetLib;      // creatorID of INet Lib features.

// Name of the InetLib
  inetLibName          ='INet.lib';           // pass in to SysLibFind()


// Feature inetCreator, #0 is index of the the version number feature.
// The Feature creator is inetLibFtrCreator.
// Encoding is: 0xMMmfsbbb, where MM is major version, m is minor version
// f is bug fix, s is stage: 3-release,2-beta,1-alpha,0-development,
// bbb is build number for non-releases
// V1.12b3   would be: 0x01122003
// V2.00a2   would be: 0x02001002
// V1.01     would be: 0x01013000
  inetFtrNumVersion    =0;

  inetLibType          =sysFileTLibrary;      // Our Net Code Resources Database type


// ID for proxy IP address in flash
  inetFlashProxyID           ='IP';
  inetDefaultFlashProxyID    ='DP';
//Also uses mobitexNetworkIdUS and mobitexNetworkIdCanada (0xb433 and 0xc4d7) to store
//current proxies for US and Canada. The responsibility for writing these and keeping
//them in sync lies with the Wireless panel, not with netlib.

//-----------------------------------------------------------------------------
// IP addresses of Elaine servers - used for default wireless proxies
//-----------------------------------------------------------------------------
  netProxyIPManhattanHGA        =0x0A0186A5;        // Manhattan HGA = 10.1.134.165 or MAN 100005
  netProxyIPTuscanyHGA          =0x0A0186A3;        // Tuscany HGA = 10.1.134.163 or MAN 100003
  netProxyIPRonsHGA             =0x0A0186A4;        // Ron's HGA = 10.1.134.164 or MAN 100004
  netProxyIPDefaultHGA          =netProxyIPManhattanHGA;
  netProxyIPDefaultHGAStr       ='10.1.134.165';    //Should correspond to above value
  netProxyIPDefaultHGACanada    =netProxyIPManhattanHGA;
  netProxyIPDefaultHGAStrCanada ='10.1.134.165';    //Should correspond to above value


/********************************************************************
* Error codes
********************************************************************/
  inetErrNone                   =0;
  inetErrTooManyClients         =inetErrorClass | 1;    // Too many clients already
  inetErrHandleInvalid          =inetErrorClass | 2;    // Invalid inetH or sockH
  inetErrParamsInvalid          =inetErrorClass | 3;    //
  inetErrURLVersionInvalid      =inetErrorClass | 4;    // 
  inetErrURLBufTooSmall         =inetErrorClass | 5;    // 
  inetErrURLInvalid             =inetErrorClass | 6;    // 
  inetErrTooManySockets         =inetErrorClass | 7;    // 
  inetErrNoRequestCreated       =inetErrorClass | 8;
  inetErrNotConnected           =inetErrorClass | 9;
  inetErrInvalidRequest         =inetErrorClass | 10;
  inetErrNeedTime               =inetErrorClass | 11;
  inetErrHostnameInvalid        =inetErrorClass | 12;
  inetErrInvalidPort            =inetErrorClass | 13;
  inetErrInvalidHostAddr        =inetErrorClass | 14;
  inetErrNilBuffer              =inetErrorClass | 15;
  inetErrConnectTimeout         =inetErrorClass | 16;
  inetErrResolveTimeout         =inetErrorClass | 17;
  inetErrSendReqTimeout         =inetErrorClass | 18;
  inetErrReadTimeout            =inetErrorClass | 19;
  inetErrBufTooSmall            =inetErrorClass | 20;
  inetErrSchemeNotSupported     =inetErrorClass | 21;
  inetErrInvalidResponse        =inetErrorClass | 22;
  inetErrSettingTooLarge        =inetErrorClass | 25;
  inetErrSettingSizeInvalid     =inetErrorClass | 26;
  inetErrRequestTooLong         =inetErrorClass | 27;
  inetErrSettingNotImplemented  =inetErrorClass | 28;

// Configuration errors
  inetErrConfigNotFound         =inetErrorClass | 29;
  inetErrConfigCantDelete       =inetErrorClass | 30;
  inetErrConfigTooMany          =inetErrorClass | 31;
  inetErrConfigBadName          =inetErrorClass | 32;
  inetErrConfigNotAlias         =inetErrorClass | 33;
  inetErrConfigCantPointToAlias =inetErrorClass | 34;
  inetErrConfigEmpty            =inetErrorClass | 35;
  inetErrConfigAliasErr         =inetErrorClass | 37;

  inetErrNoWirelessInterface    =inetErrorClass | 38;

// Encryption related errors
  inetErrEncryptionNotAvail     =inetErrorClass | 39;
// Need to re-send transaction because server told us to reset our
//  encryption sequence number
  inetErrNeedRetryEncSeqNum     =inetErrorClass | 40;
// Need to re-send transaction because server sent us a new
//  public key to use. 
  inetErrNeedRetryEncPublicKey  =inetErrorClass | 41;

  inetErrResponseTooShort       =inetErrorClass | 42;

// errors specific to handling Mobitex ILLEGAL responses
  inetErrMobitexIllegalOKHost   =inetErrorClass | 43;
  inetErrMobitexIllegalBadHost  =inetErrorClass | 44;
// see error 92 also

// HTTP errors
  inetErrHTTPBadRequest         =inetErrorClass | 45;
  inetErrHTTPUnauthorized       =inetErrorClass | 46;
  inetErrHTTPForbidden          =inetErrorClass | 47;
  inetErrHTTPNotFound           =inetErrorClass | 48;
  inetErrHTTPMethodNotAllowed   =inetErrorClass | 49;
  inetErrHTTPNotAcceptable      =inetErrorClass | 50;
  inetErrHTTPProxyAuthRequired  =inetErrorClass | 51;
  inetErrHTTPRequestTimeout     =inetErrorClass | 52;
  inetErrHTTPConflict           =inetErrorClass | 53;
  inetErrHTTPGone               =inetErrorClass | 54;
  inetErrHTTPLengthRequired     =inetErrorClass | 55;
  inetErrHTTPPreconditionFailed =inetErrorClass | 56;
  inetErrHTTPRequestTooLarge    =inetErrorClass | 57;
  inetErrHTTPRequestURITooLong  =inetErrorClass | 58;
  inetErrHTTPUnsupportedType    =inetErrorClass | 59;
  inetErrHTTPServerError        =inetErrorClass | 60;

// CTP errors
  inetErrCTPServerError         =inetErrorClass | 61;

// Cache errors
  inetErrTypeNotCached          =inetErrorClass | 62;
  inetErrCacheInvalid           =inetErrorClass | 63;

// Palm: and PalmCall: scheme errors
  inetErrURLDispatched          =inetErrorClass | 64;
  inetErrDatabaseNotFound       =inetErrorClass | 65;

  inetErrCTPMalformedRequest    =inetErrorClass | 66;
  inetErrCTPUnknownCommand      =inetErrorClass | 67;
  inetErrCTPTruncated           =inetErrorClass | 68;
  inetErrCTPUnknownError        =inetErrorClass | 69;
  inetErrCTPProxyError          =inetErrorClass | 70;
  inetErrCTPSocketErr           =inetErrorClass | 71;
    
  inetErrCTPInvalidURL          =inetErrorClass | 72;
  inetErrCTPReferringPageOutOfDate =inetErrorClass | 73;
  inetErrCTPBadRequest          =inetErrorClass | 74;
  inetErrUNUSED                 =inetErrorClass | 75;
  inetErrCTPMailServerDown      =inetErrorClass | 76;
  inetErrCTPHostNotFound        =inetErrorClass | 77;


// Content Conversion Errors
  inetErrCTPContentInvalidTag       =inetErrorClass | 78;
  inetErrCTPContentInternal         =inetErrorClass | 79;
  inetErrCTPContentDataEnd          =inetErrorClass | 80;
  inetErrCTPContentResourceTooBig   =inetErrorClass | 81;
  inetErrCTPContentNoNoFrames       =inetErrorClass | 82;
  inetErrCTPContentUnsupportedContent    =inetErrorClass | 83;
  inetErrCTPContentUnsupportedEncoding   =inetErrorClass | 84;
  inetErrCTPContentBadForm               =inetErrorClass | 85;
  inetErrCTPContentBadFormMissingAction  =inetErrorClass | 86;
  inetErrCTPContentBadFormMissingMethod  =inetErrorClass | 87;
  inetErrCTPContentNoSourceData     =inetErrorClass | 88;
  inetErrCTPContentBadImage         =inetErrorClass | 89;
  inetErrCTPContentImageTooLarge    =inetErrorClass | 90;

// Mobitex illegal handled error code.  This error is sent after
//INetLib handles inetErrMobitexIllegalOKHost or inetErrMobitexIllegalBadHost
//errors.  The application needs to know that something went wrong and it needs
//to change state.  This error does not need to be displayed to the user.
  inetErrMobitexErrorHandled    =inetErrorClass | 91;

// Proxy down, non-default host, show dialog asking to revert to default
  inetErrProxyDownBadHost       =inetErrorClass | 92;

// A second type of readtime.  This should occur only when some data is received
// and the connection is lost.
  inetErrHostConnectionLost     =inetErrorClass | 93;

// Unable to locate link record within a PQA file
  inetErrLinkNotFound           =inetErrorClass | 94;
//

/********************************************************************
* Input flags
********************************************************************/
//-----------------------------------------------------------------------------
// flag word definitions for INetLibURLOpen
//-----------------------------------------------------------------------------
  inetOpenURLFlagLookInCache =0x0001;
  inetOpenURLFlagKeepInCache =0x0002;
  inetOpenURLFlagForceEncOn  =0x0008; // use encryption even if
                                      //  scheme does not desire it
  inetOpenURLFlagForceEncOff =0x0010; // no encryption even if
                                      //  scheme desires it

//-----------------------------------------------------------------------------
// flag word definitions for INetURLInfo. These flags bits are set in the
//   flags field of the INetURLINfoType structure by INetLibURLGetInfo()
//-----------------------------------------------------------------------------
  inetURLInfoFlagIsSecure    =0x0001;
  inetURLInfoFlagIsRemote    =0x0002;
  inetURLInfoFlagIsInCache   =0x0004;


/********************************************************************
* Configuration Support
********************************************************************/
//-----------------------------------------------------------------------------
// Names of built-in configuration aliases available through the
//  INetLibConfigXXX calls
//-----------------------------------------------------------------------------
  inetCfgNameDefault      ='.Default';     // The default configuration
  inetCfgNameDefWireline  ='.DefWireline'; // The default wireline configuration
  inetCfgNameDefWireless  ='.DefWireless'; // The default wireless configuration
  inetCfgNameCTPDefault   ='.CTPDefault';  // Points to either .CTPWireline or .CTPWireless
  inetCfgNameCTPWireline  ='.CTPWireline'; // Wireline through the Jerry Proxy
  inetCfgNameCTPWireless  ='.CTPWireless'; // Wireless through the Jerry Proxy


//--------------------------------------------------------------------
// Structure of a configuration name. Used by INetLibConfigXXX calls
//---------------------------------------------------------------------
  inetConfigNameSize      =32;

Type
  INetConfigNamePtr = ^INetConfigNameType;
  INetConfigNameType = Record
    name: String[inetConfigNameSize-1];   // name of configuration
  end;

/********************************************************************
 * Scheme Types
 ********************************************************************/
  INetSchemeEnum = (
    inetSchemeUnknown = -1,
    inetSchemeDefault = 0,
   
    inetSchemeHTTP,                        // http:
    inetSchemeHTTPS,                       // https:
    inetSchemeFTP,                         // ftp:
    inetSchemeGopher,                      // gopher:
    inetSchemeFile,                        // file:
    inetSchemeNews,                        // news:
    inetSchemeMailTo,                      // mailto:
    inetSchemePalm,                        // palm:
    inetSchemePalmCall,                    // palmcall:
   
    inetSchemeMail,                        // not applicable to URLS, but used
                                           //  for the INetLibSockOpen call when
                                           //  creating a socket for mail IO
    inetSchemeMac,                         // mac: - Mac file system HTML

    inetSchemeFirst = inetSchemeHTTP,      // first one
    inetSchemeLast = inetSchemeMail        // last one
  );


/********************************************************************
 * Scheme Ports
 ********************************************************************/
Const
  inetPortFTP    =21;
  inetPortHTTP   =80;
  inetPortGopher =70;
  inetPortNews   =119;
  inetPortHTTPS  =44;



/********************************************************************
 * Structure of a cracked URL.
 ********************************************************************/
Type
  INetURLType = Record
    version: UInt16;                         // should be 0, for future compatibility

    schemeP: INetUInt8Ptr;                   // ptr to scheme portion
    schemeLen: UInt16;                       // size of scheme portion
    schemeEnum: UInt16;                      // INetSchemEnum

    usernameP: INetUInt8Ptr;                 // ptr to username portion
    usernameLen: UInt16;                     // size of username

    passwordP: INetUInt8Ptr;                 // ptr to password portion
    passwordLen: UInt16;                     // size of password

    hostnameP: INetUInt8Ptr;                 // ptr to host name portion
    hostnameLen: UInt16;                     // size of host name

    port: UInt16;                            // port number

    pathP: INetUInt8Ptr;                     // ptr to path portion
    pathLen: UInt16;                         // size of path

    paramP: INetUInt8Ptr;                    // param (;param)
    paramLen: UInt16;                        // size of param

    queryP: INetUInt8Ptr;                    // query (?query)
    queryLen: UInt16;                        // size of query

    fragP: INetUInt8Ptr;                     // fragment (#frag)
    fragLen: UInt16;                         // size of fragment
  end;



/********************************************************************
 * Structure for INetURLInfo. This structure is filled in with info
 *  about a URL. 
 ********************************************************************/
  INetURLInfoType = Record
   version: UInt16;                         // should be 0, for future compatibility

   flags: UInt16;                           // flags word, one or ore of
                                            //   inetURLInfoFlagXXX flags
   undefined: UInt32;                       // reserved for future use
  end;



/********************************************************************
 * Content and Compression Type Enums(from proxy server or PQA Builder)
 ********************************************************************/
  INetContentTypeEnum = (
    inetContentTypeTextPlain = 0,
    inetContentTypeTextHTML,
    inetContentTypeImageGIF,
    inetContentTypeImageJPEG,
    inetContentTypeApplicationCML,
    inetContentTypeImagePalmOS,
    inetContentTypeOther
  );

  INetCompressionTypeEnum = (
    inetCompressionTypeNone = 0,
    inetCompressionTypeBitPacked,
    inetCompressionTypeLZ77
  );

/********************************************************************
 * Proxy Types
 ********************************************************************/
  INetProxyEnum = (
    inetProxyNone = 0,                     // no proxy
    inetProxyCTP = 1                       // CTP (Jerry) proxy
  );



/********************************************************************
 * Settings for the INetLibSettingSet/Get call.
 ********************************************************************/
  INetSettingEnum = (
    inetSettingProxyType,                  // (RW) UInt32, INetProxyEnum

    inetSettingProxyName,                  // (RW) Char[], name of proxy
    inetSettingProxyPort,                  // (RW) UInt32,  TCP port # of proxy

    inetSettingProxySocketType,            // (RW) UInt32, which type of socket to use
                                           //  netSocketTypeXXX
   
    inetSettingCacheSize,                  // (RW) UInt32, max size of cache
    inetSettingCacheRef,                   // (R) DmOpenRef, ref of cache DB
   
    inetSettingNetLibConfig,               // (RW) UInt32, Which NetLib config to use.
      
    inetSettingRadioID,                    // (R)  UInt32[2], the 64-bit radio ID
    inetSettingBaseStationID,              // (R)  UInt32, the radio base station ID
   
    inetSettingMaxRspSize,                 // (W) UInt32 (in bytes)
    inetSettingConvAlgorithm,              // (W) UInt32 (CTPConvEnum)
    inetSettingContentWidth,               // (W) UInt32 (in pixels)
    inetSettingContentVersion,             // (W) UInt32 Content version (encoder version)

    inetSettingNoPersonalInfo,             // (RW) UInt32 send no deviceID/zipcode

    inetSettingUserName,

    inetSettingLast
  );


/********************************************************************
 * Settings for the INetLibSockSettingSet/Get call. 
 ********************************************************************/
  INetSockSettingEnum = (
    inetSockSettingScheme,                 // (R) UInt32, INetSchemeEnum
    inetSockSettingSockContext,            // (RW) UInt32,

    inetSockSettingCompressionType,        // (R) Char[]
    inetSockSettingCompressionTypeID,      // (R) UInt32 (INetCompressionTypeEnum)
    inetSockSettingContentType,            // (R) Char[]
    inetSockSettingContentTypeID,          // (R) UInt32 (INetContentTypeEnum)
    inetSockSettingData,                   // (R) UInt32, pointer to data
    inetSockSettingDataHandle,             // (R) UInt32, MemHandle to data
    inetSockSettingDataOffset,             // (R) UInt32, offset to data from MemHandle

    inetSockSettingTitle,                  // (RW) Char[]
    inetSockSettingURL,                    // (R) Char[]
    inetSockSettingIndexURL,               // (RW) Char[]
   
    inetSockSettingFlags,                  // (W) UInt16, one or more of
                                           //   inetOpenURLFlagXXX flags
                                          
    inetSockSettingReadTimeout,            // (RW) UInt32. Read timeout in ticks
   
    inetSockSettingContentVersion,         // (R) UInt32, version number for content

    inetSockSettingLast
  );




/********************************************************************
 * Possible socket status values that can be returned from INetLibSockStatus
 ********************************************************************/
  INetStatusEnum = (
    inetStatusNew,                         // just opened
    inetStatusResolvingName,               // looking up host address
    inetStatusNameResolved,                // found host address
    inetStatusConnecting,                  // connecting to host
    inetStatusConnected,                   // connected to host
    inetStatusSendingRequest,              // sending request
    inetStatusWaitingForResponse,          // waiting for response
    inetStatusReceivingResponse,           // receiving response
    inetStatusResponseReceived,            // response received
    inetStatusClosingConnection,           // closing connection
    inetStatusClosed,                      // closed
    inetStatusAcquiringNetwork,            // network temporarily
                                           // unreachable; socket on hold
    inetStatusPrvInvalid = 30              // internal value, not
                                           // returned by INetMgr. Should
                                           // be last.
  );



/********************************************************************
 * HTTP Attributes which can be set/get using the
 *  INetLibHTTPAttrSet/Get calls.
 *
 * Generally, attributes are only set BEFORE calling 
 *    INetLibSockHTTPReqSend
 * and attributes are only gotten AFTER the complete response
 *     has been received.
 *
 * Attributes marked with the following flags:
 *    (R)   - read only
 *    (W)   - write only
 *    (RW)  - read/write
 *    (-)   - not implemented yet
 ********************************************************************/
  INetHTTPAttrEnum = (

    // local error trying to communicate with server, if any
    inetHTTPAttrCommErr,                   // (R) UInt32, read-only
   
    // object attributes, defined at creation
    inetHTTPAttrEntityURL,                 // (-) Char[], which resource was requested
   

    //-----------------------------------------------------------
    // Request only attributes
    //-----------------------------------------------------------
    inetHTTPAttrReqAuthorization,          // (-) Char[]     
    inetHTTPAttrReqFrom,                   // (-) Char[]
    inetHTTPAttrReqIfModifiedSince,        // (-) UInt32
    inetHTTPAttrReqReferer,                // (-) Char[]

    // The following are ignored unless going through a CTP proxy
    inetHTTPAttrWhichPart,                 // (W) UInt32 (0 -> N)
    inetHTTPAttrIncHTTP,                   // (W) UInt32 (Boolean) only applicable
                                           //   when inetHTTPAttrConvAlgorithm set to
                                           //   ctpConvNone
    inetHTTPAttrCheckMailHi,               // (W) UInt32
    inetHTTPAttrCheckMailLo,               // (W) UInt32
    inetHTTPAttrReqContentVersion,         // (W) UInt32 Desired content version. Represented
                                           //  as 2 low bytes. Lowest byte is minor version,
                                           //  next higher byte is major version. 
   
   

    //--------------------------------------------------------------
    // Response only attributes
    //--------------------------------------------------------------
    // Server response info
    inetHTTPAttrRspAll,                    // (-) Char[] - entire HTTP response including
                                           //   data
    inetHTTPAttrRspSize,                   // (R) UInt32 - entire HTTP Response size including
                                           //   header and data
    inetHTTPAttrRspVersion,                // (-) Char[]
    inetHTTPAttrResult,                    // (R) UInt32 (ctpErrXXX when using CTP Proxy)
    inetHTTPAttrErrDetail,                 // (R) UInt32 (server/proxy err code when
                                           //      using CTP Proxy)
    inetHTTPAttrReason,                    // (R) Char[]
    inetHTTPAttrDate,                      // (-) UInt32
    inetHTTPAttrNoCache,                   // (-) UInt32
    inetHTTPAttrPragma,                    // (-) Char[]
    inetHTTPAttrServer,                    // (-) Char[]
    inetHTTPAttrWWWAuthentication,         // (-) Char[]

    // Returned entity attributes
    inetHTTPAttrContentAllow,              // (-) Char[]
    inetHTTPAttrContentLength,             // (R) UInt32
    inetHTTPAttrContentLengthUncompressed, // (R) UInt32 (in bytes)
    inetHTTPAttrContentPtr,                // (-) Char *
    inetHTTPAttrContentExpires,            // (-) UInt32
    inetHTTPAttrContentLastModified,       // (-) UInt32
    inetHTTPAttrContentLocation,           // (-) Char[]
    inetHTTPAttrContentLengthUntruncated,  // (R) UInt32
    inetHTTPAttrContentVersion,            // (R) UInt32, actual content version. Represented
                                           //  as 2 low bytes. Lowest byte is minor version,
                                           //  next higher byte is major version.
    inetHTTPAttrContentCacheID,            // (R) UInt32, cacheID for this item
    inetHTTPAttrReqSize                    // (R) UInt32 size of request sent
  );




/********************************************************************
 * Structure of our Internet events. This structure is a superset of
 *  the regular event type. Note that we use the first 2 user events
 *  for the Internet Library so any app that uses this library must be
 *  to use user event IDs greater than inetLastEvent.
 *
 *  library refNum in it....
 ********************************************************************/
Const
  inetSockReadyEvent            =firstINetLibEvent;
  inetSockStatusChangeEvent     =firstINetLibEventPlus1; //Enumerated!!
  inetLastEvent                 =firstINetLibEventPlus1;

Type
  INetEventType = Record
    eType: UInt16;         
    penDown: Boolean; 
    reserved: UInt8;           //TapCount
    screenX: Int16;          
    screenY: Int16;          
    case Integer of
    1: (generic: Record datum: Array[0..7] of UInt16 end);
    1: (inetSockReady: Record
          sockH: MemHandle;                        // socket MemHandle
          context: UInt32;                         // application defined
          inputReady: Boolean;                     // true if ready for reads
          outputReady: Boolean;                    // true if ready for writes
        end);
    1: (inetSockStatusChange: Record
          sockH: MemHandle;                        // socket MemHandle
          context: UInt32;                         // application defined
          status: UInt16;                          // new status
          sockErr: Err;                            // socket err, if any
        end);
  end;

/********************************************************************
 * Commands for InetLibWiCmd
 ********************************************************************/
  WiCmdEnum = (
    wiCmdInit =0,
    wiCmdClear,
    wiCmdSetEnabled,
    wiCmdDraw,
    wiCmdEnabled,
    wiCmdSetLocation,
    wiCmdErase
  );

/********************************************************************
 * INet Library functions.
 ********************************************************************/

  INetLibTrapNumberEnum = (
    inetLibTrapSettingGet = sysLibTrapCustom,
    inetLibTrapSettingSet,
   
    inetLibTrapGetEvent,
   
    inetLibTrapURLOpen,
   
    inetLibTrapSockRead,
    inetLibTrapSockWrite,

    inetLibTrapSockOpen,
    inetLibTrapSockClose,
    inetLibTrapSockStatus,
    inetLibTrapSockSettingGet,
    inetLibTrapSockSettingSet,
    inetLibTrapSockConnect,

    // Utilities
    inetLibTrapURLCrack,
    inetLibTrapURLsAdd,
    inetLibTrapURLsCompare,
    inetLibTrapURLGetInfo,
   
    // HTTP calls
    inetLibTrapSockHTTPReqCreate,
    inetLibTrapSockHTTPAttrSet,
    inetLibTrapSockHTTPReqSend,
    inetLibTrapSockHTTPAttrGet,
   
    // Mail traps
    inetLibTrapSockMailReqCreate,
    inetLibTrapSockMailAttrSet,
    inetLibTrapSockMailReqAdd,
    inetLibTrapSockMailReqSend,
    inetLibTrapSockMailAttrGet,
    inetLibTrapSockMailQueryProgress,
   
    // Cache calls
    inetLibTrapCacheList,
    inetLibTrapCacheGetObject,
   
    // Config calls
    inetLibConfigMakeActive_,
    inetLibConfigList_,
    inetLibConfigIndexFromName_,
    inetLibConfigDelete_,
    inetLibConfigSaveAs_,
    inetLibConfigRename_,
    inetLibConfigAliasSet_,
    inetLibConfigAliasGet_,
   
    //wireless Indicator
    inetLibTrapWiCmd,
   
    // File Calls
    inetLibTrapSockFileGetByIndex,
   
    inetLibTrapCheckAntennaState,

    inetLibTrapLast
  );


/********************************************************************
 * Structure of cache entry
 * Used as a parameter to INetLibCacheList. If urlP or titleP are NULL,
 * the corresponding length fields will be updated with the desired lengths
 ********************************************************************/
  INetCacheEntryPtr = ^INetCacheEntryType;
  INetCacheEntryType = Record
    urlP: INetUInt8Ptr;
    urlLen: UInt16;

    titleP: INetUInt8Ptr;
    titleLen: UInt16;

    lastViewed: UInt32;                   // seconds since 1/1/1904
    firstViewed: UInt32;                  // seconds since 1/1/1904
  end;
  INetCacheEntryP = INetCacheEntryPtr;

/********************************************************************
 * Structure for INetLibCacheGetObject. This structure is filled in with info
 *  about a cache entry.
 ********************************************************************/
  INetCacheInfoPtr = ^INetCacheInfoType;
  INetCacheInfoType = Record
    recordH: MemHandle;                  
    contentType: INetContentTypeEnum;
    encodingType: INetCompressionTypeEnum; 
    uncompressedDataSize: UInt32;               
    flags: UInt8;                
    reserved: UInt8;
    dataOffset: UInt16;                               // offset to content
    dataLength: UInt16;                               // size of content
    urlOffset: UInt16;                                // offset to URL
    viewTime: UInt32;                                 // time last viewed
    createTime: UInt32;                               // time entry was created
    murlOffset: UInt16;                               // offset to master URL
  end;



//--------------------------------------------------
// Library initialization, shutdown, sleep and wake
//--------------------------------------------------
Function INetLibOpen (libRefnum, config: UInt16; flags: UInt32;
               cacheRef: DmOpenRef; cacheSize: UInt32;
               var inetHP: MemHandle): Err;
                  SYS_TRAP(sysLibTrapOpen);

Function INetLibClose (libRefnum: UInt16; inetH: MemHandle): Err;
                  SYS_TRAP(sysLibTrapClose);

Function INetLibSleep (libRefnum: UInt16): Err;
                  SYS_TRAP(sysLibTrapSleep);

Function INetLibWake (libRefnum: UInt16): Err;
                  SYS_TRAP(sysLibTrapWake);

//--------------------------------------------------
// Settings
//--------------------------------------------------
Function INetLibSettingGet(libRefnum: UInt16; inetH: MemHandle;
               setting: UInt16; /*INetSettingEnum */
               bufP: Pointer; var bufLenP: UInt16): Err;
                  SYS_TRAP(inetLibTrapSettingGet);

Function INetLibSettingSet(libRefnum: UInt16; inetH: MemHandle;
               setting: UInt16; /*INetSettingEnum*/
               bufP: Pointer; bufLen: UInt16): Err;
                  SYS_TRAP(inetLibTrapSettingSet);


//--------------------------------------------------
// Event Management
//--------------------------------------------------

Procedure INetLibGetEvent(libRefnum: UInt16; inetH: MemHandle;
               var eventP: INetEventType; timeout: Int32);
                  SYS_TRAP(inetLibTrapGetEvent);



//--------------------------------------------------
// High level calls
//--------------------------------------------------

Function INetLibURLOpen(libRefnum: UInt16; inetH: MemHandle;
               urlP: INetUInt8Ptr2;
               cacheIndexURLP: INetUInt8Ptr2; var sockHP: MemHandle;
               timeout: Int32; flags: UInt16): Err;
                  SYS_TRAP(inetLibTrapURLOpen);


Function INetLibSockClose(libRefnum: UInt16; socketH: MemHandle): Err;
                  SYS_TRAP(inetLibTrapSockClose);


//--------------------------------------------------
// Read/Write
//--------------------------------------------------

Function INetLibSockRead(libRefnum: UInt16; sockH: MemHandle;
               bufP: Pointer; reqBytes: UInt32;
               var actBytesP: UInt32; timeout: Int32): Err;
                  SYS_TRAP(inetLibTrapSockRead);

Function INetLibSockWrite(libRefnum: UInt16; sockH: MemHandle;
               bufP: Pointer; reqBytes: UInt32;
               var actBytesP: UInt32; timeout: Int32): Err;
                  SYS_TRAP(inetLibTrapSockWrite);


//--------------------------------------------------
// Low level Socket calls
//--------------------------------------------------

Function INetLibSockOpen(libRefnum: UInt16; inetH: MemHandle;
               scheme: UInt16; /*INetSchemEnum*/
               var sockHP: MemHandle): Err;
                  SYS_TRAP(inetLibTrapSockOpen);

Function INetLibSockStatus(libRefnum: UInt16; socketH: MemHandle;
               var statusP: UInt16;
               var sockErrP: Err; var inputReadyP, outputReadyP: Boolean): Err;
                  SYS_TRAP(inetLibTrapSockStatus);


Function INetLibSockSettingGet(libRefnum: UInt16; socketH: MemHandle;
               setting: UInt16; /*INetSockSettingEnum*/
               bufP: Pointer;
               var bufLenP: UInt16): Err;
                  SYS_TRAP(inetLibTrapSockSettingGet);

Function INetLibSockSettingSet(libRefnum: UInt16; socketH: MemHandle;
               setting: UInt16; /*INetSockSettingEnum*/
               bufP: Pointer;
               bufLen: UInt16): Err;
                  SYS_TRAP(inetLibTrapSockSettingSet);


Function INetLibSockConnect(libRefnum: UInt16; sockH: MemHandle;
               hostnameP: INetUInt8Ptr2;
               port: UInt16;
               timeout: Int32): Err;
                  SYS_TRAP(inetLibTrapSockConnect);

//--------------------------------------------------
// HTTP specific calls
//--------------------------------------------------

Function INetLibSockHTTPReqCreate(libRefnum: UInt16; sockH: MemHandle;
               verbP: INetUInt8Ptr2;
               resNameP: INetUInt8Ptr2;
               refererP: INetUInt8Ptr2): Err;
                  SYS_TRAP(inetLibTrapSockHTTPReqCreate);

Function INetLibSockHTTPAttrSet(libRefnum: UInt16; sockH: MemHandle;
               attr: UInt16; /*inetHTTPAttrEnum*/
               attrIndex: UInt16;
               bufP: INetUInt8Ptr2;
               bufLen: UInt16;
               flags: UInt16): Err;
                  SYS_TRAP(inetLibTrapSockHTTPAttrSet);

Function INetLibSockHTTPReqSend(libRefnum: UInt16; sockH: MemHandle;
               writeP: Pointer;
               writeLen: UInt32;
               timeout: Int32): Err;
                  SYS_TRAP(inetLibTrapSockHTTPReqSend);

Function INetLibSockHTTPAttrGet(libRefnum: UInt16; sockH: MemHandle;
               attr: UInt16; /*inetHTTPAttrEnum*/
               attrIndex: UInt16;
               bufP: Pointer; var buflenP: UInt32): Err;
                  SYS_TRAP(inetLibTrapSockHTTPAttrGet);



//--------------------------------------------------
// Utilities
//--------------------------------------------------

Function INetLibURLCrack(libRefnum: UInt16; urlTextP: INetUInt8Ptr2; var urlP: INetURLType): Err;
                  SYS_TRAP(inetLibTrapURLCrack);

Function INetLibURLsAdd(libRefnum: UInt16;
               baseURLStr, embeddedURLStr, resultURLStr: PChar;
               var resultLenP: UInt16): Err;
                  SYS_TRAP(inetLibTrapURLsAdd);

Function INetLibURLsCompare(libRefnum: UInt16;
               URLStr1, URLStr2: PChar): Int16;
                  SYS_TRAP(inetLibTrapURLsCompare);

Function INetLibURLGetInfo(libRefnum: UInt16; inetH: MemHandle;
               urlTextP: INetUInt8Ptr2;
               var urlInfoP: INetURLInfoType): Err;
                  SYS_TRAP(inetLibTrapURLGetInfo);

Function INetLibWiCmd (refNum: UInt16; cmd: UInt16; /*WiCmdEnum*/
               enableOrX, y: UInt16 {int}): Boolean;
                  SYS_TRAP(inetLibTrapWiCmd);

Function INetLibCheckAntennaState(refNum: UInt16): Err;
                  SYS_TRAP(inetLibTrapCheckAntennaState);

//--------------------------------------------------
// Cache interface
//--------------------------------------------------

Function INetLibCacheList(libRefnum: UInt16; inetH: MemHandle;
               cacheIndexURLP: INetUInt8Ptr2;
               var indexP: UInt16; var
               uidP: UInt32;
               cacheP: INetCacheEntryP): Err;
                  SYS_TRAP(inetLibTrapCacheList);

Function INetLibCacheGetObject(libRefnum: UInt16;
               clientParamH: MemHandle;
               urlTextP: INetUInt8Ptr2;
               uniqueID: UInt32;
               cacheInfoP: INetCacheInfoPtr): Err;
                  SYS_TRAP(inetLibTrapCacheGetObject);

//--------------------------------------------------
// Configuration Calls
//--------------------------------------------------
Function INetLibConfigMakeActive(refNum: UInt16; inetH: MemHandle;
               configIndex: UInt16): Err;
                  SYS_TRAP(inetLibConfigMakeActive_);

Function INetLibConfigList(refNum: UInt16; var INetConfigNameType {nameArray[]};
               var arrayEntriesP: UInt16): Err;
                  SYS_TRAP(inetLibConfigList_);

Function INetLibConfigIndexFromName(refNum: UInt16; nameP: INetConfigNamePtr;
               var indexP: UInt16): Err;
                  SYS_TRAP(inetLibConfigIndexFromName_);

Function INetLibConfigDelete(refNum: UInt16; index: UInt16): Err;
                  SYS_TRAP(inetLibConfigDelete_);

Function INetLibConfigSaveAs(refNum: UInt16; inetH: MemHandle;
               nameP: INetConfigNamePtr): Err;
                  SYS_TRAP(inetLibConfigSaveAs_);

Function INetLibConfigRename(refNum: UInt16; index: UInt16;
               newNameP: INetConfigNamePtr): Err;
                  SYS_TRAP(inetLibConfigRename_);

Function INetLibConfigAliasSet(refNum: UInt16; configIndex: UInt16;
               aliasToIndex: UInt16): Err;
                  SYS_TRAP(inetLibConfigAliasSet_);

Function INetLibConfigAliasGet(refNum: UInt16; aliasIndex: UInt16;
               var indexP: UInt16;
               var isAnotherAliasP: Boolean): Err;
                  SYS_TRAP(inetLibConfigAliasGet_);

//--------------------------------------------------
// File specific calls
//--------------------------------------------------

Function   INetLibSockFileGetByIndex(libRefnum: UInt16; sockH: MemHandle;
               index: UInt32;
               var handleP: MemHandle;
               var offsetP: UInt32;
               var lengthP: UInt32): Err;
                  SYS_TRAP(inetLibTrapSockFileGetByIndex);

implementation

end.

