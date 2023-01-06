/******************************************************************************
 *
 * Copyright (c) 1996-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: NetMgr.h
 *
 * Description:
 *   This module contains the interface definition for the TCP/IP
 *  library on Pilot.
 *
 * History:
 *    2/14/96  Created by Ron Marianetti
 *       Name  Date     Description
 *       ----  ----     -----------
 *       jrb   3/13/98  Removed NetIFSettings that are Mobitex specific.
 *                      Added RadioStateEnum for the setting.
 *                      Added NetIFSettingSpecificMobitex
 *                      Added what are considered "generic" wirless settings.
 *       jaq   10/1/98  added netMaxIPAddrStrLen constant
 *       scl   3/ 5/99  integrated Eleven's changes into Main
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit NetMgr;

interface

Uses SystemMgr, SysEvent, ErrorBase;

Type
  NetUInt8Ptr = ^UInt8; //Or just PChar! Would look better
  NetUInt8Ptr2 = PChar; //Used for interface procedures

Const

/********************************************************************
 * Type and creator of Net Library database
 ********************************************************************/

// Creator. Used for both the database that contains the Net Library and
//  it's preferences database.
  netCreator          ='netl';     // Our Net Library creator

// Feature Creators and numbers, for use with the FtrGet() call. This
//  feature can be obtained to get the current version of the Net Library
  netFtrCreator       =netCreator;
  netFtrNumVersion    =0;          // get version of Net Library
  // 0xMMmfsbbb, where MM is major version, m is minor version
  // f is bug fix, s is stage: 3-release,2-beta,1-alpha,0-development,
  // bbb is build number for non-releases
  // V1.12b3   would be: 0x01122003
  // V2.00a2   would be: 0x02001002
  // V1.01     would be: 0x01013000


// Types. Used to identify the Net Library from it's prefs.
  netLibType          ='libr';     // Our Net Code Resources Database type
  netPrefsType        ='rsrc';     // Our Net Preferences Database type


// All Network interface's have the following type:
  netIFFileType       ='neti';     // The filetype of all Network Interfaces

// Each Network interface has a unique creator:
  netIFCreatorLoop    ='loop';     // Loopback network interface creator.
  netIFCreatorSLIP    ='slip';     // SLIP network interface creator.
  netIFCreatorPPP     ='ppp_';     // PPP network interface creator.
//<chg 1-28-98 RM>
  netIFCreatorRAM     ='ram_';     // Mobitex network interface creator


// Special value for configIndex parameter to NetLibOpenConfig that tells it
// to use the current settings - even if they are not the defined default settings
// This is provided for testing purposes
  netConfigIndexCurSettings =0xFFFF;

// <SCL 3/5/99> Commented out netMaxNetIFs since Tim says it should NOT be here!!
// Still need to fix (Eleven) code that currently depends on it...
// Max # of interfaces that can be installed
//define      netMaxNetIFs        =4;


//-----------------------------------------------------------------------------
// Misc. constants
//-----------------------------------------------------------------------------
  netDrvrTypeNameLen     =8;          // Maximum driver type length
  netDrvrHWNameLen       =16;         // Maximum driver hardware name length
  netIFNameLen           =10;         // Maximum interface name (driver type + instance num)
  netIFMaxHWAddrLen      =14;         // Maximum size of a hardware address
  netMaxIPAddrStrLen     =16;         // Max length of an IP address string with null terminator (255.255.255.255)



//-----------------------------------------------------------------------------
// Names of built-in configuration aliases available through the
//  NetLibConfigXXX calls
//-----------------------------------------------------------------------------
  netCfgNameDefault      ='.Default';    // The default configuration
  netCfgNameDefWireline  ='.DefWireline';// The default wireline configuration
  netCfgNameDefWireless  ='.DefWireless';// The default wireless configuration
  netCfgNameCTPWireline  ='.CTPWireline';// Wireline through the Jerry Proxy
  netCfgNameCTPWireless  ='.CTPWireless';// Wireless through the Jerry Proxy


//-----------------------------------------------------------------------------
//Flags for the NetUWirelessAppHandleEvent() utility routine
//-----------------------------------------------------------------------------
  netWLAppEventFlagCTPOnly     =0x00000001; // using wireless radio for CTP protocol only
  netWLAppEventFlagDisplayErrs =0x00000002; // Show error alerts for any errors

//-----------------------------------------------------------------------------
// Option constants that can be passed to NetSocketOptionSet and NetSocketOptionGet
// When an option is set or retrieved, both the level of the option and the
// option number must be specified. The level refers to which layer the option
// refers to, like the uppermost socket layer, for example.
//-----------------------------------------------------------------------------

// Socket level options
//Type NetSocketOptEnum = (
Const
    // IP Level options
    netSocketOptIPOptions = 1;                // options in IP header (IP_OPTIONS)

    // TCP Level options
    netSocketOptTCPNoDelay = 1;               // don't delay send to coalesce packets
    netSocketOptTCPMaxSeg = 2;                // TCP maximum segment size (TCP_MAXSEG)

    // Socket level options
    netSocketOptSockDebug = 0x0001;           // turn on debugging info recording
    netSocketOptSockAcceptConn = 0x0002;      // socket has had listen
    netSocketOptSockReuseAddr = 0x0004;       // allow local address reuse
    netSocketOptSockKeepAlive = 0x0008;       // keep connections alive
    netSocketOptSockDontRoute = 0x0010;       // just use interface addresses
    netSocketOptSockBroadcast = 0x0020;       // permit sending of broadcast msgs
    netSocketOptSockUseLoopback = 0x0040;     // bypass hardware when possible
    netSocketOptSockLinger = 0x0080;          // linger on close if data present
    netSocketOptSockOOBInLine = 0x0100;       // leave received OutOfBand data in line
   
    netSocketOptSockSndBufSize = 0x1001;      // send buffer size
    netSocketOptSockRcvBufSize = 0x1002;      // receive buffer size
    netSocketOptSockSndLowWater = 0x1003;     // send low-water mark
    netSocketOptSockRcvLowWater = 0x1004;     // receive low-water mark
    netSocketOptSockSndTimeout = 0x1005;      // send timeout
    netSocketOptSockRcvTimeout = 0x1006;      // receive timeout
    netSocketOptSockErrorStatus= 0x1007;      // get error status and clear
    netSocketOptSockSocketType = 0x1008;      // get socket type

    // The following are Pilot specific options
    netSocketOptSockNonBlocking = 0x2000;     // set non-blocking mode on or off
    netSocketOptSockRequireErrClear = 0x2001; // return error from all further calls to socket
                                              //  unless  netSocketOptSockErrorStatus is cleared.
    netSocketOptSockMultiPktAddr = 0x2002     // for SOCK_RDM (RMP) sockets. This is the
                                              // fixed IP addr (i.e. Mobitex MAN #) to use
                                              //  for multiple packet requests.
  ; //);




// Option levels for SocketOptionSet and SocketOptionGet
//  NetSocketOptLevelEnum = (
    netSocketOptLevelIP = 0;               // IP level options (IPPROTO_IP)
    netSocketOptLevelTCP = 6;              // TCP level options (IPPROTO_TCP)
    netSocketOptLevelSocket = 0xFFFF;      // Socket level options (SOL_SOCKET)
//  );

Type
// Structure used for manipulating the linger option
  NetSocketLingerType = Record
    onOff: Int16;                            // option on/off
    time: Int16;                             // linger time in seconds
  end;

//-----------------------------------------------------------------------------
// Enumeration of Socket domains and types passed to NetSocketOpen
//-----------------------------------------------------------------------------
  NetSocketAddrEnum = (
    netSocketAddrRaw=0,                          // (AF_UNSPEC, AF_RAW)
    netSocketAddrINET=2,                         // (AF_INET)
    netSocketaddrXX16bit=0x1111                  // Unused, makes size UInt16
  );

  NetSocketTypeEnum = (
    netSocketTypeStream=1,                       // (SOCK_STREAM)
    netSocketTypeDatagram=2,                     // (SOCK_DGRAM)
    netSocketTypeRaw=3,                          // (SOCK_RAW)
    netSocketTypeReliableMsg=4,                  // (SOCK_RDM)
    netSocketTypeLicensee=8                      // Socket entry reserved for licensees.
  );

// Protocols, passed in the protocol parameter to NetLibSocketOpen
Const
  netSocketProtoIPICMP =1;               // IPPROTO_ICMP
  netSocketProtoIPTCP  =6;               // IPPROTO_TCP
  netSocketProtoIPUDP  =17;              // IPPROTO_UDP
  netSocketProtoIPRAW  =255;             // IPPROTO_RAW


//-----------------------------------------------------------------------------
// Enumeration of Socket direction, passed to NetSocketShutdown
//-----------------------------------------------------------------------------
Type
  NetSocketDirEnum = (
    netSocketDirInput=0,
    netSocketDirOutput=1,
    netSocketDirBoth=2
  );


//-----------------------------------------------------------------------------
// Basic Types
//-----------------------------------------------------------------------------
// Socket refnum
  NetSocketRef= Int16;

// Type used to hold internet addresses
  NetIPAddr= UInt32;     // a 32-bit IP address.



//-----------------------------------------------------------------------------
// Structure used to hold an internet socket address. This includes the internet
//  address and the port number. This structure directly maps to the BSD unix
//  struct sockaddr_in.
//-----------------------------------------------------------------------------
  NetSocketAddrINType = Record
    family: NetSocketAddrEnum;              // Address family in HBO (Host UInt8 Order)
    case Integer of
    1: (
         //family: NetSocketAddrEnum;       // Address family in HBO (Host UInt8 Order)
         port: UInt16;                      // the UDP port in NBO (Network UInt8 Order)
         addr: NetIPAddr;                   // IP address in NBO (Network UInt8 Order)
       );
  //end;

// Structure used to hold a generic socket address. This is a generic struct
// designed to hold any type of address including internet addresses. This
// structure directly maps to the BSD unix struct sockaddr.
  //NetSocketAddrType = Record
    2: ( //family: NetSocketAddrEnum;         // Address family
         data: Array[0..13] of UInt8;       // 14 bytes of address
       );
  //end;


// Structure used to hold a raw socket address. When using the netSocketAddrRaw
//  protocol family, the caller must bind() the socket to an interface and
//  specifies the interface using this structure. IMPORTANT: NUMEROUS
//  ROUTINES IN NETLIB RELY ON THE FACT THAT THIS STRUCTURE IS THE SAME
//  SIZE AS A NetSocketAddrINType STRUCTURE.
  //NetSocketAddrRawType = Record
    3: ( //family: NetSocketAddrEnum;         // Address family in HBO (Host UInt8 Order)
         ifInstance: UInt16;                // the interface instance number
         ifCreator: UInt32;                 // the interface creator
       );
  end;

  NetSocketAddrRawType = NetSocketAddrINType;
  NetSocketAddrType = NetSocketAddrINType;

  NetSocketAddrPtr = ^NetSocketAddrType;

// Constant that means "use the local machine's IP address"
Const netIPAddrLocal    =0;        // Can be used in NetSockAddrINType.addr

Type

//-----------------------------------------------------------------------------
// Structure used to hold information about data to be sent. This structure
//  is passed to NetLibSendMsg and contains the optional address to send to,
//  a scatter-write array of data to be sent, and optional access rights
//-----------------------------------------------------------------------------

// Scatter/Gather array type. A pointer to an array of these structs is
//  passed to the NetLibSendPB and NetLibRecvPB calls. It specifies where
//  data should go to or come from as a list of buffer addresses and sizes.
  NetIOVecPtr = ^NetIOVecType;
  NetIOVecType = Record
    bufP: NetUInt8Ptr;                   // buffer address
    bufLen: UInt16;                      // buffer length
  end;

Const netIOVecMaxLen =16;          // max# of NetIOVecTypes in an array

// Read/Write ParamBlock type. Passed directly to the SendPB and RecvPB calls.
Type
  NetIOParamPtr = ^NetIOParamType;
  NetIOParamType = Record
    addrP: NetUInt8Ptr;                      // address - or 0 for default
    addrLen: UInt16;                         // length of address
    iov: NetIOVecPtr;                        // scatter/gather array
    iovLen: UInt16;                          // length of above array
    accessRights: NetUInt8Ptr;               // access rights
    accessRightsLen: UInt16;                 // length of accessrights
  end;

// Flags values for the NetLibSend, NetLibReceive calls
Const
  netIOFlagOutOfBand     =0x01;     // process out-of-band data
  netIOFlagPeek          =0x02;    // peek at incoming message
  netIOFlagDontRoute     =0x04;    // send without using routing



//-----------------------------------------------------------------------------
// Structures used for looking up a host by name or address (NetLibGetHostByName)
//-----------------------------------------------------------------------------

// Equates for DNS names, from RFC-1035
  netDNSMaxDomainName    =255;
  netDNSMaxDomainLabel   =63;

  netDNSMaxAliases       =1;          // max # of aliases for a host
  netDNSMaxAddresses     =4;          // max # of addresses for a host


// The actual results of NetLibGetHostByName() are returned in this structure.
// This structure is designed to match the "struct hostent" structure in Unix.
Type
  NetHostInfoPtr = ^NetHostInfoType;
  NetHostInfoType = Record
    nameP: PChar;                               // official name of host
    nameAliasesP: Pointer; //Char ** nameAliasesP; // array of alias's for the name
    addrType: UInt16;                           // address type of return addresses
    addrLen: UInt16;                            // the length, in bytes, of the addresses
    addrListP: Pointer; //UInt8 ** addrListP;   // array of ptrs to addresses in HBO
  end;


// "Buffer" passed to call as a place to store the results
  NetHostInfoBufPtr = ^NetHostInfoBufType;
  NetHostInfoBufType = Record
    hostInfo: NetHostInfoType;                // high level results of call are here

    // The following fields contain the variable length data that
    //  hostInfo points to
    name: String[netDNSMaxDomainName];        // hostInfo->name

    //Char *aliasList[netDNSMaxAliases+1];      // +1 for 0 termination.
    aliasList: Pointer;

    //Char  aliases[netDNSMaxAliases][netDNSMaxDomainName+1];
    aliases: Array[0..netDNSMaxAliases-1] of String[netDNSMaxDomainName];

    //NetIPAddr*  addressList[netDNSMaxAddresses];
    addressList: Pointer;

    //NetIPAddr   address[netDNSMaxAddresses];
    address: Array[0..netDNSMaxAddresses-1] of NetIPAddr;
  end;


//-----------------------------------------------------------------------------
// Structures used for looking up a service (NetLibGetServByName)
//-----------------------------------------------------------------------------

// Equates for service names
Const
  netServMaxName         =15;         // max # characters in service name
  netProtoMaxName        =15;         // max # characters in protocol name
  netServMaxAliases      =1;          // max # of aliases for a service


// The actual results of NetLibGetServByName() are returned in this structure.
// This structure is designed to match the "struct servent" structure in Unix.
Type
  NetServInfoPtr = ^NetServInfoType;
  NetServInfoType = Record
    nameP: PChar;                               // official name of service
    nameAliasesP: Pointer; //Char ** nameAliasesP; // array of alias's for the name
    port: UInt16;                               // port number for this service
    protoP: PChar;                              // name of protocol to use
  end;

// "Buffer" passed to call as a place to store the results
  NetServInfoBufPtr = ^NetServInfoBufType;
  NetServInfoBufType = Record
    servInfo: NetServInfoType;                  // high level results of call are here

    // The following fields contain the variable length data that
    //  servInfo points to
    name: String[netServMaxName];             // hostInfo->name

    aliasList: array[0..netServMaxAliases] of PChar;     // +1 for 0 termination.
    //Char        aliases[netServMaxAliases][netServMaxName];
    aliases: array[0..netServMaxAliases-1] of String[netServMaxName-1];

    protoName: String[netProtoMaxName];

    reserved: UInt8;       
  end;
   


//--------------------------------------------------------------------
// Structure of a configuration name. Used by NetLibConfigXXX calls
// <chg 1-28-98 RM> added for the new Config calls. 
//---------------------------------------------------------------------
Const netConfigNameSize    =32;
Type
  NetConfigNamePtr = ^NetConfigNameType;
  NetConfigNameType = Record
    name: String[netConfigNameSize-1];           // name of configuration
  end;



/********************************************************************
 * Tracing Flags. These flags are ORed together and passed as a UInt32
 *  in the netSettingTraceFlags setting and netIFSettingTraceFlags to
 *  enable/disable various trace options.
 ********************************************************************/
Const
  netTracingErrors    =0x00000001;       // record errors
  netTracingMsgs      =0x00000002;       // record messages
  netTracingPktIP     =0x00000004;       // record packets sent/received
                                         //  to/from interfaces at the IP layer
                                         // NOTE:  netTracingPktData40 & netTracingPktData
                                         //  will control how much data of each packet is
                                         //  recorded.
  netTracingFuncs     =0x00000008;       // record function flow
  netTracingAppMsgs   =0x00000010;       // record application messages
                                         // (NetLibTracePrintF, NetLibTracePutS)
  netTracingPktData40 =0x00000020;       // record first 40 bytes of packets
                                         //  when netTracingPktsXX is also on.
                                         // NOTE: Mutually exclusive with
                                         //  netTracingPktData and only applicable if
                                         //  one of the netTracingPktsXX bits is also set
  netTracingPktData   =0x00000040;       // record all bytes of IP packets
                                         //  sent/received to/from interfaces
                                         // NOTE: Mutually exclusive with
                                         //  netTracingPkts & netTracingPktData64
  netTracingPktIFHi   =0x00000080;       // record packets sent/received at highest layer
                                         //  of interface (just below IP layer).
                                         // NOTE:  netTracingPktData40 & netTracingPktData
                                         //  will control how much data of each packet is
                                         //  recorded.
  netTracingPktIFMid  =0x00000100;       // record packets sent/received at mid layer
                                         //  of interface (just below IFHi layer).
                                         // NOTE:  netTracingPktData40 & netTracingPktData
                                         //  will control how much data of each packet is
                                         //  recorded.
  netTracingPktIFLow  =0x00000200;       // record packets sent/received at low layer
                                         //  of interface (just below IFMid layer).
                                         // NOTE:  netTracingPktData40 & netTracingPktData
                                         //  will control how much data of each packet is
                                         //  recorded.


// OBSOLETE tracing bit, still used by Network Panel
  netTracingPkts      =netTracingPktIP;


/********************************************************************
 * Command numbers and parameter blocks for the NetLibMaster() call.
 * This call is used to put the Net library into certain debugging modes
 *    or for obtaining statistics from the Net Library.
 *
 ********************************************************************/
Type
  NetMasterEnum = (
    // These calls return info
    netMasterInterfaceInfo,
    netMasterInterfaceStats,
    netMasterIPStats,
    netMasterICMPStats,
    netMasterUDPStats,
    netMasterTCPStats,

    // This call used to read the trace buffer.
    netMasterTraceEventGet              // get trace event by index
  );


  NetMasterPBPtr = ^NetMasterPBType;
  NetMasterPBType = Record
    // These fields are specific to each command
    Case Integer of
    1: //.............................................................
       // InterfaceInfo command
       //.............................................................
       (interfaceInfo: Record
          index: UInt16;                     // -> index of interface
          creator: UInt32;                   // <- creator
          instance: UInt16;                  // <- instance
          netIFP: Pointer;                   // <- net_if pointer

          // driver level info
          drvrName: String[netDrvrTypeNameLen-1];    // <- type of driver (SLIP,PPP, etc)
          hwName: String[netDrvrHWNameLen-1];        // <- hardware name (Serial Library, etc)
          localNetHdrLen: UInt8;             // <- local net header length
          localNetTrailerLen: UInt8;         // <- local net trailer length
          localNetMaxFrame: UInt16;          // <- local net maximum frame size

          // media layer info
          ifName: String[netIFNameLen-1];// <- interface name w/instance
          driverUp: Boolean;                 // <- true if interface driver up
          ifUp: Boolean;                     // <- true if interface is up
          hwAddrLen: UInt16;                 // <- length of hardware address
          hwAddr: Array[0..netIFMaxHWAddrLen-1] of UInt8;    // <- hardware address
          mtu: UInt16;                       // <- maximum transfer unit of interface
          speed: UInt32;                     // <- speed in bits/sec.
          lastStateChange: UInt32;           // <- time in milliseconds of last state change

          // Address info
          ipAddr: NetIPAddr;                 // Address of this interface
          subnetMask: NetIPAddr;             // subnet mask of local network
          broadcast: NetIPAddr;              // broadcast address of local network
        end);

       //.............................................................
       // InterfaceStats command
       //.............................................................
    1:( interfaceStats: Record
           index: UInt16;                     // -> index of interface
           inOctets: UInt32;                  // <- ....
           inUcastPkts: UInt32;      
           inNUcastPkts: UInt32;      
           inDiscards: UInt32;      
           inErrors: UInt32;      
           inUnknownProtos: UInt32;      
           outOctets: UInt32;      
           outUcastPkts: UInt32;      
           outNUcastPkts: UInt32;      
           outDiscards: UInt32;      
           outErrors: UInt32;      
        end);

       //.............................................................
       // IPStats command
       //.............................................................
    1: (ipStats: Record
          ipInReceives: UInt32;      
          ipInHdrErrors: UInt32;      
          ipInAddrErrors: UInt32;      
          ipForwDatagrams: UInt32;      
          ipInUnknownProtos: UInt32;      
          ipInDiscards: UInt32;      
          ipInDelivers: UInt32;      
          ipOutRequests: UInt32;      
          ipOutDiscards: UInt32;      
          ipOutNoRoutes: UInt32;      
          ipReasmReqds: UInt32;      
          ipReasmOKs: UInt32;      
          ipReasmFails: UInt32;      
          ipFragOKs: UInt32;      
          ipFragFails: UInt32;      
          ipFragCreates: UInt32;      
          ipRoutingDiscards: UInt32;      
          ipDefaultTTL: UInt32;      
          ipReasmTimeout: UInt32;      
        end);

       //.............................................................
       // ICMPStats command
       //.............................................................
    1: (icmpStats: Record
          icmpInMsgs: UInt32;         
          icmpInErrors: UInt32;         
          icmpInDestUnreachs: UInt32;         
          icmpInTimeExcds: UInt32;         
          icmpInParmProbs: UInt32;         
          icmpInSrcQuenchs: UInt32;         
          icmpInRedirects: UInt32;         
          icmpInEchos: UInt32;         
          icmpInEchoReps: UInt32;         
          icmpInTimestamps: UInt32;         
          icmpInTimestampReps: UInt32;         
          icmpInAddrMasks: UInt32;         
          icmpInAddrMaskReps: UInt32;         
          icmpOutMsgs: UInt32;         
          icmpOutErrors: UInt32;         
          icmpOutDestUnreachs: UInt32;         
          icmpOutTimeExcds: UInt32;         
          icmpOutParmProbs: UInt32;         
          icmpOutSrcQuenchs: UInt32;         
          icmpOutRedirects: UInt32;         
          icmpOutEchos: UInt32;         
          icmpOutEchoReps: UInt32;         
          icmpOutTimestamps: UInt32;         
          icmpOutTimestampReps: UInt32;         
          icmpOutAddrMasks: UInt32;         
          icmpOutAddrMaskReps: UInt32;         
        end);

       //.............................................................
       // UDPStats command
       //.............................................................
    1: (udpStats: Record
          udpInDatagrams: UInt32;         
          udpNoPorts: UInt32;         
          udpInErrors: UInt32;         
          udpOutDatagrams: UInt32;         
        end);

       //.............................................................
       // TCPStats command
       //.............................................................
    1: (tcpStats: Record
          tcpRtoAlgorithm: UInt32;         
          tcpRtoMin: UInt32;         
          tcpRtoMax: UInt32;         
          tcpMaxConn: UInt32;         
          tcpActiveOpens: UInt32;         
          tcpPassiveOpens: UInt32;         
          tcpAttemptFails: UInt32;         
          tcpEstabResets: UInt32;         
          tcpCurrEstab: UInt32;         
          tcpInSegs: UInt32;         
          tcpOutSegs: UInt32;         
          tcpRetransSegs: UInt32;         
          tcpInErrs: UInt32;         
          tcpOutRsts: UInt32;
        end);

       //.............................................................
       // TraceEventGet command
       //.............................................................
    1: (traceEventGet: Record
          index: UInt16;                  // which event
          textP: PChar;                   // ptr to text string to return it in
        end);
  end;
   


   
   
//-----------------------------------------------------------------------------
// Enumeration of Net settings as passed to NetLibSettingGet/Set. 
//-----------------------------------------------------------------------------
//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
// Global environment settings common to all attached network interfaces,
//   passed to NetLibSettingGet/Set
//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  NetSettingEnum = (
    netSettingResetAll,                 // void, NetLibSettingSet only, resets all settings
                                        //  to their defaults.

    netSettingPrimaryDNS,               // UInt32, IP address of Primary DN Server
    netSettingSecondaryDNS,             // UInt32, IP address of Secondary DN Server
    netSettingDefaultRouter,            // UInt32, IP address of Default router
    netSettingDefaultIFCreator,         // UInt32, Creator type of default interface
    netSettingDefaultIFInstance,        // UInt16, Instance# of default interface
    netSettingHostName,                 // Char[64], name of host (not including domain)
    netSettingDomainName,               // Char[256], domain name of hosts's domain
    netSettingHostTbl,                  // Char[], host table 
    netSettingCloseWaitTime,            // UInt32, time in milliseconds to stay in close-wait state
    netSettingInitialTCPResendTime,     // UInt32, time in milliseconds before TCP resends a packet.
                                        //  This is just the initial value, the timeout is adjusted
                                        //  from this initial value depending on history of ACK times.
                                        //  This is sometimes referred to as the RTO (Roundtrip Time Out)
                                        //  See RFC-1122 for additional information.

   
    // The following settings are not used for configuration, but rather put the
    //  stack into various modes for debugging, etc. 
    netSettingTraceBits = 0x1000,       // UInt32, enable/disable various trace flags (netTraceBitXXXX)
    netSettingTraceSize,                // UInt32, max trace buffer size in bytes. Default 0x800.
                                        //  Setting this will also clear the trace buffer.
    netSettingTraceStart,               // UInt32, for internal use ONLY!!
    netSettingTraceRoll,                // UInt8, if true, trace buffer will rollover after it fills.
                                        //  Default is true.
                                       
    netSettingRTPrimaryDNS,             // used internally by Network interfaces
                                        //  that dynamically obtain the DNS address
    netSettingRTSecondaryDNS,           // used internally by Network interfaces
                                        //  that dynamically obtain the DNS address
                                       
    netSettingConfigTable               // used internally by NetLib - NOT FOR USE BY
                                        //  APPLICATIONS!!

  );


//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
// Settings for each Network Interface, passed to NetLibIFSettingGet/Set
//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  NetIFSettingEnum = (
    //::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    // Reset all settings to defaults
    //::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    netIFSettingResetAll,               // void, NetLibIFSettingSet only, resets all settings
                                        //  to their defaults.
                                       
    //::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    // Status - read only
    //::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    netIFSettingUp,                     // UInt8, true if interface is UP.
    netIFSettingName,                   // Char[32], name of interface

    //::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    // Addressing
    //::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    netIFSettingReqIPAddr,              // UInt32, requested IP address of this interface
    netIFSettingSubnetMask,             // UInt32, subnet mask of this interface
    netIFSettingBroadcast,              // UInt32, broadcast address for this interface

    //::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    // User Info
    //::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    netIFSettingUsername,               // Char[], login script user name
                                        //           If 0 length, then user will be prompted for it
    netIFSettingPassword,               // Char[], login script user password
                                        //           If 0 length, then user will be prompted for it
    netIFSettingDialbackUsername,       // Char[], login script dialback user name.  
                                        //           If 0 length, then netIFSettingUsername is used
    netIFSettingDialbackPassword,       // Char[], login script dialback user password. 
                                        //           If 0 length, then user will be prompted for it
    netIFSettingAuthUsername,           // Char[], PAP/CHAP name. 
                                        //           If 0 length, then netIFSettingUsername is used
    netIFSettingAuthPassword,           // Char[], PAP/CHAP password. 
                                        //           If "$", then user will be prompted for it
                                        //           else If 0 length, then netIFSettingPassword or result
                                        //             of it's prompt (if it was empty) will be used
                                        //           else it is used as-is.
   
    //::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    // Connect Settings
    //::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    netIFSettingServiceName,            // Char[], name of service
    netIFSettingLoginScript,            // Char[], login script
    netIFSettingConnectLog,             // Char[], connect log 
    netIFSettingInactivityTimeout,      // UInt16, # of seconds of inactivity allowed before
                                        //  interface is brought down. If 0 then
                                        //  no inactivity timeout enforced.
    netIFSettingEstablishmentTimeout,   // UInt16, max delay in seconds between connection 
                                        //  establishment stages
   
    // Serial based protocol options
    netIFSettingDynamicIP,              // UInt8, if true, get IP address from server
                                        //  N/A for SLIP
    netIFSettingVJCompEnable,           // UInt8, if true enable VJ Header compression
                                        //  Default is on for PPP, off for SLIP
    netIFSettingVJCompSlots,            // UInt8, # of slots to use for VJ compression.
                                        //  Default is 4 for PPP, 16 for SLIP
                                        //  (each slot uses 256 bytes of RAM).
    netIFSettingMTU,                    // UInt16, maximum transmission unit in bytes
                                        //  ignored in current PPP and SLIP interfaces
    netIFSettingAsyncCtlMap,            // UInt32, bitmask of characters to escape
                                        //  ignored in current PPP interfaces

    // Serial settings, used by serial based network interfaces
    netIFSettingPortNum,                // UInt16, port number to use
    netIFSettingBaudRate,               // UInt32, baud rate in bits/sec.
    netIFSettingFlowControl,            // UInt8, flow control setting bits. Set to 0x01 for
                                        //   hardware flow control, else set to 0x00.
    netIFSettingStopBits,               // UInt8, # of stop bits
    netIFSettingParityOn,               // UInt8, true if parity on
    netIFSettingParityEven,             // UInt8, true if parity even

    // Modem settings, optionally used by serial based network interfaces
    netIFSettingUseModem,               // UInt8, if true dial-up through modem
    netIFSettingPulseDial,              // UInt8, if true use pulse dial, else tone
    netIFSettingModemInit,              // Char[], modem initialization string
    netIFSettingModemPhone,             // Char[], modem phone number string
    netIFSettingRedialCount,            // UInt16, # of times to redial
   

    //---------------------------------------------------------------------------------
    // New Settings as of PalmOS 3.0
    // Power control, usually only implemented by wireless interfaces 
    //---------------------------------------------------------------------------------
    netIFSettingPowerUp,                // UInt8, true if this interface is powered up
                                        //       false if this interface is in power-down mode
                                        //  interfaces that don't support power modes should
                                        //  quietly ignore this setting. 
                                    
    // Wireless or Wireline, read-only, returns true for wireless interfaces. this
    //  setting is used by application level functions to determine which interface(s)
    //  to attach/detach given user preference and/or state of the antenna.
    netIFSettingWireless,               // UInt8, true if this interface is wireless
   


    // Option to query server for address of DNS servers
    netIFSettingDNSQuery,               // UInt8, if true PPP queries for DNS address. Default true


    //---------------------------------------------------------------------------------
    // New Settings as of PalmOS 3.2
    // Power control, usually only implemented by wireless interfaces 
    //---------------------------------------------------------------------------------
                                    
    netIFSettingQuitOnTxFail,           // BYTE  W-only. Power down RF on tx fail
    netIFSettingQueueSize,              // UInt8  R-only. The size of the Tx queue in the RF interface
    netIFSettingTxInQueue,              // BYTE  R-only. Packets remaining to be sent
    netIFSettingTxSent,                 // BYTE  R-only. Packets sent since SocketOpen
    netIFSettingTxDiscard,              // BYTE  R-only. Packets discarded on SocketClose
    netIFSettingRssi,                   // char   R-only. signed value in dBm.
    netIFSettingRssiAsPercent,          // char   R-only. signed value in percent, with 0 being no coverage and 100 being excellent.
    netIFSettingRadioState,             // enum   R-only. current state of the radio
    netIFSettingBase,                   // UInt32 R-only. Interface specific
    netIFSettingRadioID,                // UInt32[2] R-only, two 32-bit. interface specific
    netIFSettingBattery,                // UInt8, R-only. percentage of battery left
    netIFSettingNetworkLoad,            // UInt8, R-only. percent estimate of network loading

    //---------------------------------------------------------------------------------
    // New Settings as of PalmOS 3.3
    //---------------------------------------------------------------------------------

    netIFSettingConnectionName,         // Char [] Connection Profile Name


    //::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    // The following settings are not used for configuration, but rather put the
    //  stack into various modes for debugging, etc. 
    //::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    netIFSettingTraceBits = 0x1000,     // UInt32, enable/disable various trace flags (netTraceBitXXXX)
    netIFSettingGlobalsPtr,             // UInt32, (Read-Only) sinterface's globals ptr
    netIFSettingActualIPAddr,           // UInt32, (Read-Only) the actual IP address that the interface
                                        //   ends up using. The login script executor stores
                                        //   the result of the "g" script command here as does
                                        //   the PPP negotiations. 
    netIFSettingServerIPAddr,           // UInt32, (Read-Only) the IP address of the PPP server
                                        //  we're connected to 
   
   
    // The following setting should be true if this network interface should be
    // brought down when the Pilot is turned off.
    netIFSettingBringDownOnPowerDown,   // UInt8, if true interface will be brought down when
                                        //  Pilot is turned off.

    // The following setting is used by the TCP/IP stack ONLY!! It tells the interface
    //  to pass all received packets as-is to the NetIFCallbacksPtr->raw_rcv() routine. 
    //  This setting gets setup when an application creates a raw socket in the raw domain
    netIFSettingRawMode,                // UInt32, parameter to pass to raw_rcv() along with
                                        //  packet pointer.

    //::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    // 3rd party settings start here...
    //::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    netIFSettingCustom = 0x8000
  );



//=========================================================================================
// Enums for the netIFSettingRadioState setting
//
// JB added for the radio state setting.
// <chg 3-17-98 RM> fixed naming conventions.
//=========================================================================================
  NetRadioStateEnum = (
   netRadioStateOffNotConnected=0,
   netRadioStateOnNotConnected,        // scanning
   netRadioStateOnConnected,           // have channel
   netRadioStateOffConnected
  );



/************************************************************
 * Net Library Macros
 *************************************************************/
// Return current time in milliseconds.
// NetNow()     (TimGetTicks() * 1000L/sysTicksPerSecond)


// File Descriptor macros used for the NetLibSelect() call
  NetFDSetType= UInt32;
Const
  netFDSetSize      =32;

//define  netFDSet(n,p)     ((*p) |= (1L << n))
//define  netFDClr(n,p)     ((*p) &= ~(1L << n))
//define  netFDIsSet(n,p)   ((*p) & (1L << n))
//define  netFDZero(p)      ((*p) = 0)



//-----------------------------------------------------------------------------
// Net error codes
//-----------------------------------------------------------------------------
  netErrAlreadyOpen             =netErrorClass | 1;
  netErrNotOpen                 =netErrorClass | 2;
  netErrStillOpen               =netErrorClass | 3;
  netErrParamErr                =netErrorClass | 4;
  netErrNoMoreSockets           =netErrorClass | 5;
  netErrOutOfResources          =netErrorClass | 6;
  netErrOutOfMemory             =netErrorClass | 7;
  netErrSocketNotOpen           =netErrorClass | 8;
  netErrSocketBusy              =netErrorClass | 9;     //EINPROGRESS
  netErrMessageTooBig           =netErrorClass | 10;
  netErrSocketNotConnected      =netErrorClass | 11;
  netErrNoInterfaces            =netErrorClass | 12;    //ENETUNREACH
  netErrBufTooSmall             =netErrorClass | 13;
  netErrUnimplemented           =netErrorClass | 14;
  netErrPortInUse               =netErrorClass | 15;    //EADDRINUSE
  netErrQuietTimeNotElapsed     =netErrorClass | 16;    //EADDRINUSE
  netErrInternal                =netErrorClass | 17;
  netErrTimeout                 =netErrorClass | 18;    //ETIMEDOUT
  netErrSocketAlreadyConnected  =netErrorClass | 19;    //EISCONN
  netErrSocketClosedByRemote    =netErrorClass | 20;
  netErrOutOfCmdBlocks          =netErrorClass | 21;
  netErrWrongSocketType         =netErrorClass | 22;
  netErrSocketNotListening      =netErrorClass | 23;
  netErrUnknownSetting          =netErrorClass | 24;
  netErrInvalidSettingSize      =netErrorClass | 25;
  netErrPrefNotFound            =netErrorClass | 26;
  netErrInvalidInterface        =netErrorClass | 27;
  netErrInterfaceNotFound       =netErrorClass | 28;
  netErrTooManyInterfaces       =netErrorClass | 29;
  netErrBufWrongSize            =netErrorClass | 30;
  netErrUserCancel              =netErrorClass | 31;
  netErrBadScript               =netErrorClass | 32;
  netErrNoSocket                =netErrorClass | 33;
  netErrSocketRcvBufFull        =netErrorClass | 34;
  netErrNoPendingConnect        =netErrorClass | 35;
  netErrUnexpectedCmd           =netErrorClass | 36;
  netErrNoTCB                   =netErrorClass | 37;
  netErrNilRemoteWindowSize     =netErrorClass | 38;
  netErrNoTimerProc             =netErrorClass | 39;
  netErrSocketInputShutdown     =netErrorClass | 40;    // EOF to sockets API
  netErrCmdBlockNotCheckedOut   =netErrorClass | 41;
  netErrCmdNotDone              =netErrorClass | 42;
  netErrUnknownProtocol         =netErrorClass | 43;
  netErrUnknownService          =netErrorClass | 44;     
  netErrUnreachableDest         =netErrorClass | 45; 
  netErrReadOnlySetting         =netErrorClass | 46;  
  netErrWouldBlock              =netErrorClass | 47;    //EWOULDBLOCK
  netErrAlreadyInProgress       =netErrorClass | 48;    //EALREADY
  netErrPPPTimeout              =netErrorClass | 49;
  netErrPPPBroughtDown          =netErrorClass | 50;
  netErrAuthFailure             =netErrorClass | 51;
  netErrPPPAddressRefused       =netErrorClass | 52;
// The following map into the Epilogue DNS errors declared in DNS.ep.h:
//  and MUST be kept in this order!!
  netErrDNSNameTooLong          =netErrorClass | 53;
  netErrDNSBadName              =netErrorClass | 54;
  netErrDNSBadArgs              =netErrorClass | 55;
  netErrDNSLabelTooLong         =netErrorClass | 56;
  netErrDNSAllocationFailure    =netErrorClass | 57;
  netErrDNSTimeout              =netErrorClass | 58;
  netErrDNSUnreachable          =netErrorClass | 59;
  netErrDNSFormat               =netErrorClass | 60;
  netErrDNSServerFailure        =netErrorClass | 61;
  netErrDNSNonexistantName      =netErrorClass | 62;
  netErrDNSNIY                  =netErrorClass | 63;
  netErrDNSRefused              =netErrorClass | 64;
  netErrDNSImpossible           =netErrorClass | 65;
  netErrDNSNoRRS                =netErrorClass | 66;
  netErrDNSAborted              =netErrorClass | 67;
  netErrDNSBadProtocol          =netErrorClass | 68;
  netErrDNSTruncated            =netErrorClass | 69;
  netErrDNSNoRecursion          =netErrorClass | 70;
  netErrDNSIrrelevant           =netErrorClass | 71;
  netErrDNSNotInLocalCache      =netErrorClass | 72;
  netErrDNSNoPort               =netErrorClass | 73;
// The following map into the Epilogue IP errors declared in IP.ep.h:
//  and MUST be kept in this order!!
  netErrIPCantFragment          =netErrorClass | 74;
  netErrIPNoRoute               =netErrorClass | 75;
  netErrIPNoSrc                 =netErrorClass | 76;
  netErrIPNoDst                 =netErrorClass | 77;
  netErrIPktOverflow            =netErrorClass | 78;
// End of Epilogue IP errors
  netErrTooManyTCPConnections   =netErrorClass | 79;
  netErrNoDNSServers            =netErrorClass | 80;
  netErrInterfaceDown           =netErrorClass | 81;

// Mobitex network radio interface error code returns
  netErrNoChannel               =netErrorClass | 82; // The datalink layer cannot acquire a channel 
  netErrDieState                =netErrorClass | 83; // Mobitex network has issued a DIE command.
  netErrReturnedInMail          =netErrorClass | 84; // The addressed of the transmitted packet was not available, and the message was placed in the network's mailbox.
  netErrReturnedNoTransfer      =netErrorClass | 85; // This message cannot be transferred or put in the network mailbox.
  netErrReturnedIllegal         =netErrorClass | 86; // The message could not be switched to the network
  netErrReturnedCongest         =netErrorClass | 87; // Line, radio channels, or network nodes are congested.
  netErrReturnedError           =netErrorClass | 88; // Technical error in the network.
  netErrReturnedBusy            =netErrorClass | 89; // The B-party is busy.
  netErrGMANState               =netErrorClass | 90; // The modem has not registered with the network.
  netErrQuitOnTxFail            =netErrorClass | 91; // Couldn't get packet through, shutdown.
  netErrFlexListFull            =netErrorClass | 92; // raw IF error message: see Mobitex spec.
  netErrSenderMAN               =netErrorClass | 93; // ditto
  netErrIllegalType             =netErrorClass | 94; // ditto
  netErrIllegalState            =netErrorClass | 95; // ditto
  netErrIllegalFlags            =netErrorClass | 96; // ditto
  netErrIllegalSendlist         =netErrorClass | 97; // ditto
  netErrIllegalMPAKLength       =netErrorClass | 98; // ditto
  netErrIllegalAddressee        =netErrorClass | 99; // ditto
  netErrIllegalPacketClass      =netErrorClass | 100; // ditto
  netErrBufferLength            =netErrorClass | 101; // any
  netErrNiCdLowBattery          =netErrorClass | 102; // any 
  netErrRFinterfaceFatal        =netErrorClass | 103; // any
  netErrIllegalLogout           =netErrorClass | 104; // raw IF error message
  netErrAAARadioLoad            =netErrorClass | 105;   // 7/20/98 JB.  If there is insufficient AAA
  netErrAntennaDown             =netErrorClass | 106;
  netErrNiCdCharging            =netErrorClass | 107;   // just for charging
  netErrAntennaWentDown         =netErrorClass | 108;
  netErrNotActivated            =netErrorClass | 109;   // The unit has not been FULLY activated.  George and Morty completed.
  netErrRadioTemp               =netErrorClass | 110;   // Radio's temp is too high for FCC compliant TX
  netErrNiCdChargeError         =netErrorClass | 111;   // Charging stopped due to NiCd charging characteristic
  netErrNiCdSag                 =netErrorClass | 112;   // the computed sag or actual sag indicates a NiCd with diminished capacity.
  netErrNiCdChargeSuspend       =netErrorClass | 113;   // Charging has been suspended due to low AAA batteries.
// Left room for more Mobitex errors

// Configuration errors
  netErrConfigNotFound          =netErrorClass | 115;
  netErrConfigCantDelete        =netErrorClass | 116;
  netErrConfigTooMany           =netErrorClass | 117;
  netErrConfigBadName           =netErrorClass | 118;
  netErrConfigNotAlias          =netErrorClass | 119;
  netErrConfigCantPointToAlias  =netErrorClass | 120;
  netErrConfigEmpty             =netErrorClass | 121;
  netErrAlreadyOpenWithOtherConfig    =netErrorClass | 122;
  netErrConfigAliasErr          =netErrorClass | 123;
  netErrNoMultiPktAddr          =netErrorClass | 124;
  netErrOutOfPackets            =netErrorClass | 125; 
  netErrMultiPktAddrReset       =netErrorClass | 126;
  netErrStaleMultiPktAddr       =netErrorClass | 127;

// Login scripting plugin errors
  netErrScptPluginMissing       =netErrorClass | 128;
  netErrScptPluginLaunchFail    =netErrorClass | 129;
  netErrScptPluginCmdFail       =netErrorClass | 130;
  netErrScptPluginInvalidCmd    =netErrorClass | 131;

  netErrMobitexStart            =netErrNoChannel;
  netErrMobitexEnd              =netErrNiCdChargeSuspend;

//-----------------------------------------------------------------------------
// Net library call ID's. Each library call gets the trap number:
//   netTrapXXXX which serves as an index into the library's dispatch table.
//   The constant sysLibTrapCustom is the first available trap number after
//   the system predefined library traps Open,Close,Sleep & Wake.
//
// WARNING!!! This order of these traps MUST match the order of the dispatch
//  table in NetDispatch.c!!!
//-----------------------------------------------------------------------------
Type
  NetLibTrapNumberEnum = (
    netLibTrapAddrINToA = sysLibTrapCustom,
    netLibTrapAddrAToIN,
   
    netLibTrapSocketOpen,
    netLibTrapSocketClose,
    netLibTrapSocketOptionSet,
    netLibTrapSocketOptionGet,
    netLibTrapSocketBind,
    netLibTrapSocketConnect,
    netLibTrapSocketListen,
    netLibTrapSocketAccept,
    netLibTrapSocketShutdown,
   
    netLibTrapSendPB,
    netLibTrapSend,
    netLibTrapReceivePB,
    netLibTrapReceive,
    netLibTrapDmReceive,
    netLibTrapSelect,

    netLibTrapPrefsGet,
    netLibTrapPrefsSet,

    // The following traps are for internal and Network interface
    //  use only.
    netLibTrapDrvrWake,
    netLibTrapInterfacePtr,
    netLibTrapMaster,
   
    // New Traps
    netLibTrapGetHostByName,
    netLibTrapSettingGet,
    netLibTrapSettingSet,
    netLibTrapIFAttach,
    netLibTrapIFDetach,
    netLibTrapIFGet,
    netLibTrapIFSettingGet,
    netLibTrapIFSettingSet,
    netLibTrapIFUp,
    netLibTrapIFDown,
    netLibTrapIFMediaUp,
    netLibTrapScriptExecuteV32,
    netLibTrapGetHostByAddr,
    netLibTrapGetServByName,
    netLibTrapSocketAddr,
    netLibTrapFinishCloseWait,
    netLibTrapGetMailExchangeByName,
    netLibTrapPrefsAppend,
    netLibTrapIFMediaDown,
    netLibTrapOpenCount,

    netLibTrapTracePrintF,
    netLibTrapTracePutS,
   
    netLibTrapOpenIfCloseWait,
    netLibTrapHandlePowerOff,
   
    netLibTrapConnectionRefresh,
   
    // Traps added after 1.0 release of NetLib
    netLibTrapBitMove,
    netLibTrapBitPutFixed,
    netLibTrapBitGetFixed,
    netLibTrapBitPutUIntV,
    netLibTrapBitGetUIntV,
    netLibTrapBitPutIntV,
    netLibTrapBitGetIntV,

    // Traps added after 2.0 release of NetLib
    netLibOpenConfig_,
    netLibConfigMakeActive_,
    netLibConfigList_,
    netLibConfigIndexFromName_,
    netLibConfigDelete_,
    netLibConfigSaveAs_,
    netLibConfigRename_,
    netLibConfigAliasSet_,
    netLibConfigAliasGet_,

    // Traps added after 3.2 release of NetLib
    netLibTrapScriptExecute,
   
    netLibTrapLast
  );



/************************************************************
 * Net Library procedures.
 *************************************************************/

//--------------------------------------------------
// Library initialization, shutdown, sleep and wake
//--------------------------------------------------
Function NetLibOpen (libRefnum: UInt16; var netIFErrsP: UInt16): Err;
                  SYS_TRAP(sysLibTrapOpen);

Function NetLibClose (libRefnum: UInt16; immediate: UInt16): Err;
                  SYS_TRAP(sysLibTrapClose);
               
Function NetLibSleep (libRefnum: UInt16): Err;
                  SYS_TRAP(sysLibTrapSleep);
               
Function NetLibWake (libRefnum: UInt16): Err;
                  SYS_TRAP(sysLibTrapWake);
               
               
// This call forces the library to complete a close if it's
//  currently in the close-wait state. Returns 0 if library is closed,
//  Returns netErrFullyOpen if library is still open by some other task.
Function NetLibFinishCloseWait(libRefnum: UInt16): Err;
                  SYS_TRAP(netLibTrapFinishCloseWait);

// This call is for use by the Network preference panel only. It
// causes the NetLib to fully open if it's currently in the close-wait
//  state. If it's not in the close wait state, it returns an error code
Function NetLibOpenIfCloseWait(libRefnum: UInt16): Err;
                  SYS_TRAP(netLibTrapOpenIfCloseWait);
                  
// Get the open Count of the NetLib
Function NetLibOpenCount (refNum: UInt16; var countP: UInt16): Err;
                  SYS_TRAP(netLibTrapOpenCount);
               
// Give NetLib a chance to close the connection down in response
// to a power off event. Returns non-zero if power should not be
//  turned off. EventP points to the event that initiated the power off
//  which is either a keyDownEvent of the hardPowerChr or the autoOffChr.
// Don't include unless building for Viewer
Function NetLibHandlePowerOff (refNum: UInt16; var eventP: SysEventType): Err;
                  SYS_TRAP(netLibTrapHandlePowerOff);

   
// Check status or try and reconnect any interfaces which have come down.
// This call can be made by applications when they suspect that an interface
// has come down (like PPP or SLIP). NOTE: This call can display UI
// (if 'refresh' is true) so it MUST be called from the UI task. 
Function NetLibConnectionRefresh(refNum: UInt16; refresh: Boolean;
                     var allInterfacesUpP: UInt8;
                     var netIFErrP: UInt16): Err;
                  SYS_TRAP(netLibTrapConnectionRefresh);

                  
               
//--------------------------------------------------
// Net address translation and conversion routines.
//--------------------------------------------------

// convert host Int16 to network Int16
function NetHToNS(x: Int16): Int16;

// convert host long to network long
function        NetHToNL(x: Int32): Int32;

// convert network Int16 to host Int16
function        NetNToHS(x: Int16): Int16;

// convert network long to host long
function        NetNToHL(x: Int32): Int32;

// Convert 32-bit IP address to ascii dotted decimal form. The Sockets glue
//  macro inet_ntoa will pass the address of an application global string in
//  spaceP.
Function NetLibAddrINToA(libRefnum: UInt16; inet: NetIPAddr;  spaceP: PChar): PChar;
                  SYS_TRAP(netLibTrapAddrINToA);

// Convert a dotted decimal ascii string format of an IP address into
//  a 32-bit value.
Function NetLibAddrAToIN(libRefnum: UInt16; Const a: String): NetIPAddr;
                  SYS_TRAP(netLibTrapAddrAToIN);



//--------------------------------------------------
// Socket creation and option setting
//--------------------------------------------------

// Create a socket and return a refnum to it. Protocol is normally 0.
// Returns 0 on success, -1 on error. If error, *errP gets filled in with error code.
Function NetLibSocketOpen(libRefnum: UInt16; domain: NetSocketAddrEnum;
                     type_: NetSocketTypeEnum; protocol: Int16; timeout: Int32;
                     var errP: Err): NetSocketRef;
                  SYS_TRAP(netLibTrapSocketOpen);

// Close a socket. 
// Returns 0 on success, -1 on error. If error, *errP gets filled in with error code.
Function NetLibSocketClose(libRefnum: UInt16; socket: NetSocketRef; timeout: Int32;
                     var errP: Err): Int16;
                  SYS_TRAP(netLibTrapSocketClose);

// Set a socket option. Level is usually netSocketOptLevelSocket. Option is one of
//  netSocketOptXXXXX. OptValueP is a pointer to the new value and optValueLen is
//  the length of the option value.
// Returns 0 on success, -1 on error. If error, *errP gets filled in with error code.
Function NetLibSocketOptionSet(libRefnum: UInt16; socket: NetSocketRef;
                     level: UInt16 /*NetSocketOptLevelEnum*/;
                     option: UInt16 /*NetSocketOptEnum*/; 
                     optValueP: Pointer; optValueLen: UInt16;
                     timeout: Int32;
                     var errP: Err): Int16;
                  SYS_TRAP(netLibTrapSocketOptionSet);

// Get a socket option.
// Returns 0 on success, -1 on error. If error, *errP gets filled in with error code.
Function NetLibSocketOptionGet(libRefnum: UInt16; socket: NetSocketRef;
                     level: UInt16 /*NetSocketOptLevelEnum*/;
                     option: UInt16 /*NetSocketOptEnum*/; 
                     optValueP: Pointer; var optValueLenP: UInt16;
                     timeout: Int32;
                     var errP: Err): Int16;
                  SYS_TRAP(netLibTrapSocketOptionGet);
                  

//--------------------------------------------------
// Socket Control
//--------------------------------------------------

// Bind a source address and port number to a socket. This makes the
//  socket accept incoming packets destined for the given socket address.
// Returns 0 on success, -1 on error. If error, *errP gets filled in with error code.
Function NetLibSocketBind(libRefnum: UInt16; socket: NetSocketRef;
                     var sockAddrP: NetSocketAddrType; addrLen: Int16; timeout: Int32;
                     var errP: Err): Int16;
                  SYS_TRAP(netLibTrapSocketBind);
                  
                  
// Connect to a remote socket. For a stream based socket (i.e. TCP), this initiates
//  a 3-way handshake with the remote machine to establish a connection. For
//  non-stream based socket, this merely specifies a destination address and port
//  number for future outgoing packets from this socket.
// Returns 0 on success, -1 on error. If error, *errP gets filled in with error code.
Function NetLibSocketConnect(libRefnum: UInt16; socket: NetSocketRef;
                     var sockAddrP: NetSocketAddrType; addrLen: Int16; timeout: Int32;
                     var errP: Err): Int16;
                  SYS_TRAP(netLibTrapSocketConnect);
                  

// Makes a socket ready to accept incoming connection requests. The queueLen 
//  specifies the max number of pending connection requests that will be enqueued
//  while the server is busy handling other requests.
//  Only applies to stream based (i.e. TCP) sockets.
// Returns 0 on success, -1 on error. If error, *errP gets filled in with error code.
Function NetLibSocketListen(libRefnum: UInt16; socket: NetSocketRef;
                     queueLen: UInt16; timeout: Int32;
                     var errP: Err): Int16;
                  SYS_TRAP(netLibTrapSocketListen);
                  

// Blocks the current process waiting for an incoming connection request. The socket
//  must have previously be put into listen mode through the NetLibSocketListen call.
//  On return, *sockAddrP will have the remote machines address and port number.
//  Only applies to stream based (i.e. TCP) sockets.
// Returns 0 on success, -1 on error. If error, *errP gets filled in with error code.
Function NetLibSocketAccept(libRefnum: UInt16; socket: NetSocketRef;
                     var sockAddrP: NetSocketAddrType; var addrLenP: Int16; timeout: Int32;
                     var errP: Err): Int16;
                  SYS_TRAP(netLibTrapSocketAccept);


// Shutdown a connection in one or both directions.  
//  Only applies to stream based (i.e. TCP) sockets.
// Returns 0 on success, -1 on error. If error, *errP gets filled in with error code.
Function NetLibSocketShutdown(libRefnum: UInt16; socket: NetSocketRef;
                     direction: Int16 /*NetSocketDirEnum*/; 
                     timeout: Int32; var errP: Err): Int16;
                  SYS_TRAP(netLibTrapSocketShutdown);



// Gets the local and remote addresses of a socket. Useful for TCP sockets that
//  get dynamically bound at connect time.
// Returns 0 on success, -1 on error. If error, *errP gets filled in with error code.
Function NetLibSocketAddr(libRefnum: UInt16; socketRef: NetSocketRef;
                     var locAddrP: NetSocketAddrType;
                     var locAddrLenP: Int16;
                     var remAddrP: NetSocketAddrType;
                     var remAddrLenP: Int16;
                     timeout: Int32;
                     var errP: Err): Int16;
                  SYS_TRAP(netLibTrapSocketAddr);
                  
                  

//--------------------------------------------------
// Sending and Receiving
//--------------------------------------------------
// Send data through a socket. The data is specified through the NetIOParamType
//  structure.
// Flags is one or more of netMsgFlagXXX.
// Returns # of bytes sent on success, or -1 on error. If error, *errP gets filled
//  in with error code.
Function NetLibSendPB(libRefNum: UInt16; socket: NetSocketRef;
                     var pbP: NetIOParamType; flags: UInt16; timeout: Int32; var errP: Err): Int16;
                  SYS_TRAP(netLibTrapSendPB);

// Send data through a socket. The data to send is passed in a single buffer,
//  unlike NetLibSendPB. If toAddrP is not nil, the data will be sent to 
//  address *toAddrP.
// Flags is one or more of netMsgFlagXXX.
// Returns # of bytes sent on success, or -1 on error. If error, *errP gets filled 
//  in with error code.
Function NetLibSend(libRefNum: UInt16; socket: NetSocketRef;
                     bufP: Pointer; bufLen: UInt16; flags: UInt16;
                     toAddrP: Pointer; toLen: UInt16; timeout: Int32; var errP: Err): Int16;
                  SYS_TRAP(netLibTrapSend);

// Receive data from a socket. The data is gatthered into buffers specified in the 
//  NetIOParamType structure.
// Flags is one or more of netMsgFlagXXX.
// Timeout is max # of ticks to wait, or -1 for infinite, or 0 for none.
// Returns # of bytes received, or -1 on error. If error, *errP gets filled in 
//  with error code.
Function NetLibReceivePB(libRefNum: UInt16; socket: NetSocketRef;
                     var pbP: NetIOParamType; flags: UInt16; timeout: Int32; var errP: Err): Int16;
                  SYS_TRAP(netLibTrapReceivePB);

// Receive data from a socket. The data is read into a single buffer, unlike
//  NetLibReceivePB. If fromAddrP is not nil, *fromLenP must be initialized to
//  the size of the buffer that fromAddrP points to and on exit *fromAddrP will
//  have the address of the sender in it.
// Flags is one or more of netMsgFlagXXX.
// Timeout is max # of ticks to wait, or -1 for infinite, or 0 for none.
// Returns # of bytes received, or -1 on error. If error, *errP gets filled in 
//  with error code.
Function NetLibReceive(libRefNum: UInt16; socket: NetSocketRef;
                     bufP: Pointer; bufLen: UInt16; flags: UInt16;
                     fromAddrP: Pointer; var fromLenP: UInt16; timeout: Int32; var errP: Err): Int16;
                  SYS_TRAP(netLibTrapReceive);


// Receive data from a socket directly into a (write-protected) Data Manager 
//  record.
// If fromAddrP is not nil, *fromLenP must be initialized to
//  the size of the buffer that fromAddrP points to and on exit *fromAddrP will
//  have the address of the sender in it.
// Flags is one or more of netMsgFlagXXX.
// Timeout is max # of ticks to wait, or -1 for infinite, or 0 for none.
// Returns # of bytes received, or -1 on error. If error, *errP gets filled in 
//  with error code.
Function NetLibDmReceive(libRefNum: UInt16; socket: NetSocketRef;
                     recordP: Pointer; recordOffset: UInt32; rcvLen: UInt16; flags: UInt16;
                     fromAddrP: Pointer; var fromLenP: UInt16; timeout: Int32; var errP: Err): Int16;
                  SYS_TRAP(netLibTrapDmReceive);


//--------------------------------------------------
// Name Lookups
//--------------------------------------------------
Function NetLibGetHostByName(libRefNum: UInt16; Const Name: String;
                     var bufP: NetHostInfoBufType; timeout: Int32; var errP: Err): NetHostInfoPtr;
                  SYS_TRAP(netLibTrapGetHostByName);


Function NetLibGetHostByAddr(libRefNum: UInt16; addrP: NetUInt8Ptr2; len: UInt16; type_: UInt16;
                     var bufP: NetHostInfoBufType; timeout: Int32; var errP: Err): NetHostInfoPtr;
                  SYS_TRAP(netLibTrapGetHostByAddr);


Function NetLibGetServByName(libRefNum: UInt16; Const ServName: String;
                     Const protoNameP: String;  bufP: NetServInfoBufPtr;
                     timeout: Int32; var errP: Err): NetServInfoPtr;
                  SYS_TRAP(netLibTrapGetServByName);

// Looks up a mail exchange name and returns a list of hostnames for it. Caller
//  must pass space for list of return names (hostNames), space for 
//  list of priorities for those hosts (priorities) and max # of names to 
//  return (maxEntries).
// Returns # of entries found, or -1 on error. If error, *errP gets filled in
//  with error code.
Function NetLibGetMailExchangeByName(libRefNum: UInt16; Const MailName: String;
                     maxEntries: UInt16;
                     var hostNames; //Char hostNames[][netDNSMaxDomainName+1],
                     var priorities; //UInt16 priorities[],
                     timeout: Int32; var errP: Err): Int16;
                  SYS_TRAP(netLibTrapGetMailExchangeByName);


//--------------------------------------------------
// Interface setup
//--------------------------------------------------
Function NetLibIFGet(libRefNum: UInt16; index: UInt16; var ifCreatorP: UInt32;
                        var ifInstanceP: UInt16): Err;
                  SYS_TRAP(netLibTrapIFGet);

Function NetLibIFAttach(libRefNum: UInt16; ifCreator: UInt32; ifInstance: UInt16;
                     timeout: Int32): Err;
                  SYS_TRAP(netLibTrapIFAttach);

Function NetLibIFDetach(libRefNum: UInt16; ifCreator: UInt32; ifInstance: UInt16;
                     timeout: Int32): Err;
                  SYS_TRAP(netLibTrapIFDetach);

Function NetLibIFUp(libRefNum: UInt16; ifCreator: UInt32; ifInstance: UInt16): Err;
                  SYS_TRAP(netLibTrapIFUp);

Function NetLibIFDown(libRefNum: UInt16; ifCreator: UInt32; ifInstance: UInt16;
                     timeout: Int32): Err;
                  SYS_TRAP(netLibTrapIFDown);




//--------------------------------------------------
// Settings
//--------------------------------------------------
// General settings
Function NetLibSettingGet(libRefNum: UInt16;
                     setting: UInt16 /*NetSettingEnum*/; 
                     valueP: Pointer; var valueLenP: UInt16): Err;
                  SYS_TRAP(netLibTrapSettingGet);

Function NetLibSettingSet(libRefNum: UInt16;
                     setting: UInt16 /*NetSettingEnum*/; 
                     valueP: Pointer; valueLen: UInt16): Err;
                  SYS_TRAP(netLibTrapSettingSet);
                  
// Network interface specific settings.
Function NetLibIFSettingGet(libRefNum: UInt16; ifCreator: UInt32; ifInstance: UInt16;
                     setting: UInt16 /*NetIFSettingEnum*/; 
                     valueP: Pointer;
                     var valueLenP: UInt16): Err;
                  SYS_TRAP(netLibTrapIFSettingGet);

Function NetLibIFSettingSet(libRefNum: UInt16; ifCreator: UInt32; ifInstance: UInt16;
                     setting: UInt16 /*NetIFSettingEnum*/;
                     valueP: Pointer; valueLen: UInt16): Err;
                  SYS_TRAP(netLibTrapIFSettingSet);



//--------------------------------------------------
// System level
//--------------------------------------------------
Function NetLibSelect(libRefNum: UInt16; width: UInt16;
                     var readFDs: NetFDSetType;
                     var writeFDs: NetFDSetType;
                     var exceptFDs: NetFDSetType;
                     timeout: Int32; var errP: Err): Int16;
                  SYS_TRAP(netLibTrapSelect);



//--------------------------------------------------
// Debugging support
//--------------------------------------------------
Function NetLibMaster(libRefNum: UInt16; cmd: UInt16; pbP: NetMasterPBPtr;
                  timeout: Int32): Err;
                  SYS_TRAP(netLibTrapMaster);

//Function NetLibTracePrintF(libRefNum: UInt16; formatStr: PChar, ...): Err;
//                  SYS_TRAP(netLibTrapTracePrintF);
                  
Function NetLibTracePutS(libRefNum: UInt16; Const Str: String): Err;
                  SYS_TRAP(netLibTrapTracePutS);
                  



                  
//--------------------------------------------------
// Configuration Calls
//--------------------------------------------------
Function NetLibOpenConfig(refNum: UInt16; configIndex: UInt16; openFlags: UInt32;
                     var netIFErrP: UInt16): Err;
                  SYS_TRAP(netLibOpenConfig_);

Function NetLibConfigMakeActive(refNum: UInt16; configIndex: UInt16): Err;
                  SYS_TRAP(netLibConfigMakeActive_);

Function NetLibConfigList(refNum: UInt16;
                     var NetConfigNameType; // nameArray[],
                     var arrayEntriesP: UInt16): Err;
                  SYS_TRAP(netLibConfigList_);
                  
Function NetLibConfigIndexFromName(refNum: UInt16; nameP: NetConfigNamePtr;
                     var indexP: UInt16): Err;
                  SYS_TRAP(netLibConfigIndexFromName_);
                  
Function NetLibConfigDelete(refNum: UInt16; index: UInt16): Err;
                  SYS_TRAP(netLibConfigDelete_);
                  
Function NetLibConfigSaveAs(refNum: UInt16; nameP: NetConfigNamePtr): Err;
                  SYS_TRAP(netLibConfigSaveAs_);
                  
Function NetLibConfigRename(refNum: UInt16; index: UInt16;
                     newNameP: NetConfigNamePtr): Err;
                  SYS_TRAP(netLibConfigRename_);

Function NetLibConfigAliasSet(refNum: UInt16; configIndex: UInt16;
                     aliasToIndex: UInt16): Err;
                  SYS_TRAP(netLibConfigAliasSet_);

Function NetLibConfigAliasGet(refNum: UInt16; aliasIndex: UInt16;
                     var indexP: UInt16; var isAnotherAliasP: Boolean): Err;
                  SYS_TRAP(netLibConfigAliasGet_);

implementation

// convert host Int16 to network Int16
function NetHToNS(x: Int16): Int16;
begin
  NetHToNS:=x
end;

// convert host long to network long
function NetHToNL(x: Int32): Int32;
begin
  NetHToNL:=x
end;

// convert network Int16 to host Int16
function NetNToHS(x: Int16): Int16;
begin
  NetNToHS:=x
end;

// convert network long to host long
function NetNToHL(x: Int32): Int32;
begin
  NetNToHL:=x
end;

end.

