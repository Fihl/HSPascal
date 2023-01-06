/******************************************************************************
 *
 * Copyright (c) 1994-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: SerialLinkMgr.h
 *
 * Description:
 *    Source for Serial Link Routines on Pilot
 *
 * History:
 *    2/6/95 replaces DSerial.h from Debugger 
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit SerialLinkMgr;

interface

Uses ErrorBase;

//*************************************************************************
//   Pre-defined, fixxed  Socket ID's
//*************************************************************************
Const
  slkSocketDebugger       =0;        // Debugger Socket
  slkSocketConsole        =1;        // Console Socket
  slkSocketRemoteUI       =2;        // Remote UI Socket
  slkSocketDLP            =3;        // Desktop Link Socket
  slkSocketFirstDynamic   =4;        // first dynamic socket ID


//*************************************************************************
//  Packet Types
//*************************************************************************
  slkPktTypeSystem        =0;        // System packets
  slkPktTypeUnused1       =1;        // used to be: Connection Manager packets
  slkPktTypePAD           =2;        // PAD Protocol packets
  slkPktTypeLoopBackTest  =3;        // Loop-back test packets



//*************************************************************************
//
// Packet structure:
//    header
//    body (0-dbgMaxPacketBodyLength bytes of data)
//    footer
//
//*************************************************************************

//----------------------------------------------------------------------
// packet header
// Fields marked with -> must be filled in by caller
// Fields marked with X  will be filled in by SlkSendPacket.
//----------------------------------------------------------------------

Type
  SlkPktHeaderChecksum= UInt8; 

  SlkPktHeaderPtr = ^SlkPktHeaderType;
  SlkPktHeaderType = Record
    signature1: UInt16;                         // X  first 2 bytes of signature
    signature2: UInt8;                          // X  3 and final byte of signature
    dest: UInt8;                                // -> destination socket Id
    src: UInt8;                                 // -> src socket Id
    typ: UInt8;                                 // -> packet type
    bodySize: UInt16;                           // X  size of body
    transId: UInt8;                             // -> transaction Id
                                                //    if 0 specified, it will be replaced
    checksum: SlkPktHeaderChecksum;             // X  check sum of header
  end;

Const
  slkPktHeaderSignature1  =0xBEEF;
  slkPktHeaderSignature2  =0xED;

  slkPktHeaderSigFirst    =0xBE;        // First byte
  slkPktHeaderSigSecond   =0xEF;        // second byte
  slkPktHeaderSigThird    =0xED;        // third byte

//----------------------------------------------------------------------
// packet footer
//----------------------------------------------------------------------
Type
  SlkPktFooterPtr = ^SlkPktFooterType;
  SlkPktFooterType = Record
    crc16: UInt16;                      // header and body crc
  end;


//*************************************************************************
//
// Write Data Structure passed to SlkSendPacket. This structure 
//  Tells SlkSendPacket where each of the chunks that comprise the body are
//  and the size of each. SlkSendPacket accepts a pointer to an array
//  of SlkWriteDataTypes, the last one has a size field of 0.
//
//*************************************************************************
  SlkWriteDataPtr = ^SlkWriteDataType;
  SlkWriteDataType = Record
    size: UInt16;                // last one has size of 0
    dataP: Pointer;              // pointer to data
  end;


//*************************************************************************
//
// CPU-dependent macros for getting/setting values from/to packets
//
//*************************************************************************

//--------------------------------------------------------------------
// macros to get packet values
//--------------------------------------------------------------------

// #define  slkGetPacketByteVal(srcP)  (*(UInt8 *)(srcP))
Function slkGetPacketByteVal(srcP: Pointer): UInt8; Assembler;


//#define  slkGetPacketWordVal(srcP)  ( *((UInt16 *)(srcP)) )
Function slkGetPacketWordVal(srcP: Pointer): UInt16; Assembler;

//#define  slkGetPacketDWordVal(srcP) ( *((UInt32 *)(srcP)) )
Function slkGetPacketDWordVal(srcP: Pointer): UInt32; Assembler;

//Not impl slkGetPacketSignature1(sigP)  slkGetPacketWordVal(sigP)

//Not impl slkGetPacketSignature2(sigP)  slkGetPacketByteVal(sigP)


//Not impl slkGetPacketDest(addressP)    slkGetPacketByteVal(addressP)

//Not impl slkGetPacketSrc(addressP)     slkGetPacketByteVal(addressP)

//Not impl slkGetPacketType(commandP)    slkGetPacketByteVal(commandP)


//Not impl slkGetPacketBodySize(lengthP) slkGetPacketWordVal(lengthP)

//Not impl slkGetPacketTransId(transIDP) slkGetPacketByteVal(transIDP)

//Not impl slkGetPacketHdrChecksum(checksumP)   slkGetPacketByteVal(checksumP)


//Not impl slkGetPacketTotalChecksum(checksumP) slkGetPacketWordVal(checksumP)


//--------------------------------------------------------------------
// macros to set packet values
//--------------------------------------------------------------------


//#define  slkSetPacketByteVal(srcByteVal, destP) ( *(UInt8 *)(destP) = (UInt8)(srcByteVal) )
//#define  slkSetPacketWordVal(srcWordVal, destP) ( *((UInt16 *)(destP)) = (UInt16)(srcWordVal) )
//#define  slkSetPacketDWordVal(srcDWordVal, destP) ( *((UInt32 *)(destP)) = (UInt32)(srcDWordVal) )
Function slkSetPacketByteVal(srcByteVal: UInt8; destP: Pointer): UInt8; Assembler;
Function slkSetPacketWordVal(srcWordVal: UInt16; destP: Pointer): UInt16; Assembler;
Function slkSetPacketDWordVal(srcDWordVal: UInt32; destP: Pointer): UInt32; Assembler;



//Not impl slkSetPacketSignature1(magic, destP) slkSetPacketWordVal(magic, destP)

//Not impl slkSetPacketSignature2(magic, destP) slkSetPacketByteVal(magic, destP)


//Not impl slkSetPacketDest(dest, destP)  slkSetPacketByteVal(dest, destP)

//Not impl slkSetPacketSrc(src, destP)    slkSetPacketByteVal(src, destP)


//Not impl slkSetPacketType(type, destP)  slkSetPacketByteVal(type, destP)


//Not impl slkSetPacketBodySize(numBytes, destP) slkSetPacketWordVal(numBytes, destP)


//Not impl slkSetPacketTransId(transID, destP)   slkSetPacketByteVal(transID, destP)

//Not impl slkSetPacketHdrChecksum(checksum, destP)   slkSetPacketByteVal(checksum, destP)

//Not impl slkSetPacketTotalChecksum(checksum, destP) slkSetPacketWordVal(checksum, destP)



/*******************************************************************
 * Serial Link Manager Errors
 * the constant slkErrorClass is defined in SystemMgr.h
 *******************************************************************/
Const
  slkErrChecksum          =slkErrorClass | 1;
  slkErrFormat            =slkErrorClass | 2;
  slkErrBuffer            =slkErrorClass | 3;
  slkErrTimeOut           =slkErrorClass | 4;
  slkErrHandle            =slkErrorClass | 5;
  slkErrBodyLimit         =slkErrorClass | 6;
  slkErrTransId           =slkErrorClass | 7;
  slkErrResponse          =slkErrorClass | 8;
  slkErrNoDefaultProc     =slkErrorClass | 9;
  slkErrWrongPacketType   =slkErrorClass | 10;
  slkErrBadParam          =slkErrorClass | 11;
  slkErrAlreadyOpen       =slkErrorClass | 12;
  slkErrOutOfSockets      =slkErrorClass | 13;
  slkErrSocketNotOpen     =slkErrorClass | 14;
  slkErrWrongDestSocket   =slkErrorClass | 15;
  slkErrWrongPktType      =slkErrorClass | 16;
  slkErrBusy              =slkErrorClass | 17;
  // called while sending a packet, only returned on single-threaded
  // emulation implementations
  slkErrNotOpen           =slkErrorClass | 18;



/*******************************************************************
 * Type definition for a Serial Link Socket Listener
 *
 *******************************************************************/
Type
//  void (*SlkSocketListenerProcPtr) (SlkPktHeaderPtr headerP, void* bodyP);
//  SlkSocketListenerProcPtr: Function(headerP: SlkPktHeaderPtr; bodyP: Pointer);
  SlkSocketListenerProcPtr = Pointer;

  SlkSocketListenPtr = ^SlkSocketListenType;
  SlkSocketListenType = Record
    listenerP: SlkSocketListenerProcPtr;  
    headerBufferP: SlkPktHeaderPtr;               // App allocated buffer for header
    bodyBufferP: Pointer;                         // App allocated buffer for body
    bodyBufferSize: UInt32;
  End;


/*******************************************************************
 * Prototypes
 *******************************************************************/

//-------------------------------------------------------------------
// Initializes the Serial Link Manager
//-------------------------------------------------------------------
Function SlkOpen: Err;
               SYS_TRAP(sysTrapSlkOpen);

//-------------------------------------------------------------------
// Close down the Serial Link Manager
//-------------------------------------------------------------------
Function SlkClose: Err;
               SYS_TRAP(sysTrapSlkClose);




//-------------------------------------------------------------------
// Open up another Serial Link socket. The caller must have already
//  opened the comm library and set it to the right settings.
//-------------------------------------------------------------------

Function SlkOpenSocket(portID: UInt16; var socketP: UInt16; staticSocket: Boolean): Err;
               SYS_TRAP(sysTrapSlkOpenSocket);


//-------------------------------------------------------------------
// Close up a Serial Link socket.
//  Warning: This routine is assymetrical with SlkOpenSocket because it
//   WILL CLOSE the library for the caller (unless the refNum is the
//   refNum of the debugger comm library).
//-------------------------------------------------------------------
Function SlkCloseSocket(socket: UInt16): Err;
               SYS_TRAP(sysTrapSlkCloseSocket);
               

//-------------------------------------------------------------------
// Get the library refNum for a particular Socket
//-------------------------------------------------------------------


   Function SlkSocketPortID(socket: UInt16; var portIDP: UInt16): Err;
               SYS_TRAP(sysTrapSlkSocketRefNum);

   //#define SlkSocketRefNum SlkSocketPortID


//-------------------------------------------------------------------
// Set the in-packet timeout for a socket
//-------------------------------------------------------------------
Function SlkSocketSetTimeout(socket: UInt16; timeout: Int32): Err;
               SYS_TRAP(sysTrapSlkSocketSetTimeout);





//-------------------------------------------------------------------
// Flush a Socket
//-------------------------------------------------------------------
Function SlkFlushSocket(socket: UInt16; timeout: Int32): Err;
               SYS_TRAP(sysTrapSlkFlushSocket);


//-------------------------------------------------------------------
// Set up a Socket Listener
//-------------------------------------------------------------------
Function SlkSetSocketListener(socket: UInt16;  socketP: SlkSocketListenPtr): Err;
               SYS_TRAP(sysTrapSlkSetSocketListener);


//-------------------------------------------------------------------
// Sends a packet's header, body, footer.  Stuffs the header's
// magic number and checksum fields.  Expects all other
// header fields to be filled in by caller.
// errors returned: dseHandle, dseLine, dseIO, dseParam, dseBodyLimit,
//             dseOther
//-------------------------------------------------------------------
Function SlkSendPacket(headerP: SlkPktHeaderPtr; writeList: SlkWriteDataPtr): Err;
               SYS_TRAP(sysTrapSlkSendPacket);


//-------------------------------------------------------------------
// Receives and validates an entire packet.
// errors returned: dseHandle, dseParam, dseLine, dseIO, dseFormat,
//             dseChecksum, dseBuffer, dseBodyLimit, dseTimeOut,
//             dseOther
//-------------------------------------------------------------------
Function SlkReceivePacket(socket: UInt16; andOtherSockets: Boolean;
                  headerP: SlkPktHeaderPtr; bodyP: Pointer;  bodySize: UInt16;
                  timeout: Int32): Err;
               SYS_TRAP(sysTrapSlkReceivePacket);


//-------------------------------------------------------------------
// Do Default processing of a System packet
//-------------------------------------------------------------------
Function SlkSysPktDefaultResponse(headerP: SlkPktHeaderPtr; bodyP: Pointer): Err;
               SYS_TRAP(sysTrapSlkSysPktDefaultResponse);

//-------------------------------------------------------------------
// Do RPC call
//-------------------------------------------------------------------
Function SlkProcessRPC(headerP: SlkPktHeaderPtr; bodyP: Pointer): Err;
               SYS_TRAP(sysTrapSlkProcessRPC);

implementation

Function slkGetPacketByteVal(srcP: Pointer): UInt8; Assembler;
Asm     MOVE    srcP,A0
        MOVE.B  (A0),12(A6)  //slkGetPacketByteVal
end;

Function slkGetPacketWordVal(srcP: Pointer): UInt16; Assembler;
Asm     MOVE    srcP,A0
        MOVE.W  (A0),12(A6)  //slkGetPacketWordVal
end;

Function slkGetPacketDWordVal(srcP: Pointer): UInt32; Assembler;
Asm     MOVE    srcP,A0
        MOVE.L  (A0),12(A6)  //slkGetPacketDWordVal
end;


Function slkSetPacketByteVal(srcByteVal: UInt8; destP: Pointer): UInt8; Assembler;
Asm     MOVE    destP,A0
        MOVE.B  srcByteVal,(A0)
end;

Function slkSetPacketWordVal(srcWordVal: UInt16; destP: Pointer): UInt16; Assembler;
Asm     MOVE    destP,A0
        MOVE.W  srcWordVal,(A0)
end;

Function slkSetPacketDWordVal(srcDWordVal: UInt32; destP: Pointer): UInt32; Assembler;
Asm     MOVE    destP,A0
        MOVE.L  srcDWordVal,(A0)
end;

end.

