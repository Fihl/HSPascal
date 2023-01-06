/******************************************************************************
 *
 * Copyright (c) 1994-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: ErrorBase.h
 *
 * Description:
 *    Include file for Error Management 
 *
 * History:
 *    10/25/94  RM   Created by Ron Marianetti
 *    10/09/98 Bob   Fill in all macros, fix defns w/ do{}while(0)
 *    08/05/99 kwk   Added menuErrorClass from Gavin's Menu.c
 *
 *-----------------------------------------------------------------------
 * Exception Handling
 *
 *    This unit implements an exception handling mechanism that is similar
 *    to "real" C++ Exceptions. Our Exceptions are untyped, and there
 *    must be one and only one Catch block for each Try block.
 *
 * Try/Catch Syntax:
 *
 *    ErrTry {
 *       // Do something which may fail.
 *       // Call ErrThrow() to signal failure and force jump
 *       // to the following Catch block.
 *    }
 *
 *    ErrCatch(inErr) {
 *       // Recover or cleanup after a failure in the above Try block.
 *       // "inErr" is an ExceptionCode identifying the reason
 *       // for the failure.
 *       
 *       // You may call Throw() if you want to jump out to
 *       // the next Catch block.
 *
 *       // The code in this Catch block does not execute if
 *       // the above Try block completes without a Throw.
 *
 *    } ErrEndCatch
 *
 *    You must structure your code exactly as above. You can't have a
 *    ErrTry { } without a ErrCatch { } ErrEndCatch, or vice versa.
 *
 *
 * ErrThrow
 *
 *    To signal failure, call ErrThrow() from within a Try block. The
 *    Throw can occur anywhere in the Try block, even within functions
 *    called from the Try block. A ErrThrow() will jump execution to the
 *    start of the nearest Catch block, even across function calls.
 *    Destructors for stack-based objects which go out of scope as
 *    a result of the ErrThrow() are called.
 *
 *    You can call ErrThrow() from within a Catch block to "rethrow"
 *    the exception to the next nearest Catch block.
 *
 *
 * Exception Codes
 *
 *    An ExceptionCode is a 32-bit number. You will normally use
 *    Pilot error codes, which are 16-bit numbers. This allows
 *    plently of room for defining codes for your own kinds of errors.
 *
 *
 * Limitations
 *
 *    Try/Catch and Throw are based on setjmp/longjmp. At the
 *    beginning of a Try block, setjmp saves the machine registers.
 *    Throw calls longjmp, which restores the registers and jumps
 *    to the beginning of the Catch block. Therefore, any changes
 *    in the Try block to variables stored in registers will not
 *    be retained when entering the Catch block. 
 *
 *    The solution is to declare variables that you want to use
 *    in both the Try and Catch blocks as "volatile". For example:
 *
 *    volatile long  x = 1;      // Declare volatile local variable
 *    ErrTry {
 *       x = 100;                // Set local variable in Try
 *       ErrThrow(-1);
 *    }
 *
 *    ErrCatch(inErr) {
 *       if (x > 1) {            // Use local variable in Catch   
 *          SysBeep(1);
 *       }
 *    } ErrEndCatch
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit ErrorBase;

interface

Uses Traps33;  // ,SetJmp;

// Max message length supported by ErrCustomAlert
Const errMaxMsgLength=  511;


/************************************************************
 * Error Classes for each manager
 *************************************************************/
Const
  errNone                 =0x0000;   // No error

  memErrorClass           =0x0100;   // Memory Manager
  dmErrorClass            =0x0200;   // Data Manager
  serErrorClass           =0x0300;   // Serial Manager
  slkErrorClass           =0x0400;   // Serial Link Manager
  sysErrorClass           =0x0500;   // System Manager
  fplErrorClass           =0x0600;   // Floating Point Library
  flpErrorClass           =0x0680;   // New Floating Point Library
  evtErrorClass           =0x0700;   // System Event Manager
  sndErrorClass           =0x0800;   // Sound Manager
  almErrorClass           =0x0900;   // Alarm Manager
  timErrorClass           =0x0A00;   // Time Manager
  penErrorClass           =0x0B00;   // Pen Manager
  ftrErrorClass           =0x0C00;   // Feature Manager
  cmpErrorClass           =0x0D00;   // Connection Manager (HotSync)
  dlkErrorClass           =0x0E00;   // Desktop Link Manager
  padErrorClass           =0x0F00;   // PAD Manager
  grfErrorClass           =0x1000;   // Graffiti Manager
  mdmErrorClass           =0x1100;   // Modem Manager
  netErrorClass           =0x1200;   // Net Library
  htalErrorClass          =0x1300;   // HTAL Library
  inetErrorClass          =0x1400;   // INet Library
  exgErrorClass           =0x1500;   // Exg Manager
  fileErrorClass          =0x1600;   // File Stream Manager
  rfutErrorClass          =0x1700;   // RFUT Library
  txtErrorClass           =0x1800;   // Text Manager
  tsmErrorClass           =0x1900;   // Text Services Library
  webErrorClass           =0x1A00;   // Web Library
  secErrorClass           =0x1B00;   // Security Library
  emuErrorClass           =0x1C00;   // Emulator Control Manager
  flshErrorClass          =0x1D00;   // Flash Manager
  pwrErrorClass           =0x1E00;   // Power Manager
  cncErrorClass           =0x1F00;   // Connection Manager (Serial Communication)
  actvErrorClass          =0x2000;   // Activation application
  radioErrorClass         =0x2100;   // Radio Manager (Library)
  dispErrorClass          =0x2200;   // Display Driver Errors.
  bltErrorClass           =0x2300;   // Blitter Driver Errors.
  winErrorClass           =0x2400;   // Window manager.
  omErrorClass            =0x2500;   // Overlay Manager
  menuErrorClass          =0x2600;   // Menu Manager

  oemErrorClass           =0x7000;   // OEM/Licensee errors (0x7000-0x7EFF shared among ALL partners)
  errInfoClass            =0x7F00;   // special class shows information w/o error code
  appErrorClass           =0x8000;   // Application-defined errors



/********************************************************************
 * Try / Catch / Throw support
 *
 * ---------------------------------------------------------------------
 * Exception Handler structure
 *
 * An ErrExceptionType object is created for each ErrTry & ErrCatch block.
 * At any point in the program, there is a linked list of
 * ErrExceptionType objects. GErrFirstException points to the
 * most recently entered block. A ErrExceptionType blocks stores
 * information about the state of the machine (register values)
 * at the start of the Try block
 ********************************************************************/

Type
  ErrJumpBufPtr=^ErrJumpBuf;
  ErrJumpBuf= Array[0..11] of UInt32;        // D3-D7,PC,A2-A7
(**********
#if EMULATION_LEVEL != EMULATION_NONE
   Const ErrJumpBuf  jmp_buf
#else
   long* ErrJumpBuf[12];       // D3-D7,PC,A2-A7
#endif

// Structure used to store Try state.
  ErrExceptionPtr = ^ErrExceptionType;
  ErrExceptionType = Record
    struct ErrExceptionType*   nextP;   // next exception type
    ErrJumpBuf                 state;   // setjmp/longjmp storage
    Int32                      err;     // Error code
  end;


// Try & Catch macros
Const ErrTry                                                \
   {                                                           \
      ErrExceptionType  _TryObject;                            \
      _TryObject.err = 0;                                      \
      _TryObject.nextP = (ErrExceptionPtr)*ErrExceptionList(); \
      *ErrExceptionList() = (MemPtr)&_TryObject;                  \
      if (ErrSetJump(_TryObject.state) == 0) {


// NOTE: All variables referenced in and after the ErrCatch must 
// be declared volatile.  Here's how for variables and pointers:
// volatile UInt16               oldMode;
// ShlDBHdrTablePtr volatile hdrTabP = nil;
// If you have many local variables after the ErrCatch you may
// opt to put the ErrTry and ErrCatch in a separate enclosing function.
Const ErrCatch(theErr)                                   \
         *ErrExceptionList() = (MemPtr)_TryObject.nextP;       \
         }                                                  \
      else {                                                \
         Int32 theErr = _TryObject.err;                     \
         *ErrExceptionList() = (MemPtr)_TryObject.nextP;
         
         
Const ErrEndCatch                                        \
         }                                                  \
   }

(***********)



/********************************************************************
 * Error Manager Routines
 ********************************************************************/
(*******
#if EMULATION_LEVEL != EMULATION_NONE
   Const ErrSetJump(buf)         setjmp(buf)
   Const ErrLongJump(buf,res)    longjmp(buf,res)

#else
(******)
Function ErrSetJump(var buf: ErrJumpBuf): Int16; SYS_TRAP(sysTrapErrSetJump);

Procedure ErrLongJump(var buf: ErrJumpBuf; result: Int16); SYS_TRAP(sysTrapErrLongJump);

Function ErrExceptionList: MemHandle; SYS_TRAP(sysTrapErrExceptionList);

Procedure ErrThrow(err: Int32); SYS_TRAP(sysTrapErrThrow);

Procedure ErrDisplayFileLineMsg(filename: String; lineNo: UInt16; msg: String); SYS_TRAP(sysTrapErrDisplayFileLineMsg);


//---------------------------------------------------------------------
// 2/25/98 - New routine for PalmOS >3.0 to display a UI alert for
// run-time errors. This is most likely to be used by network applications
// that are likely to encounter run-time errors like can't find the server,
//  network down, etc. etc.
//
// This routine will lookup the text associated with 'errCode' and display
//  it in an alert. If errMsgP is not NULL, then that text will be used
//  instead of the associated 'errCode' text. If 'preMsgP' or 'postMsgP'
//  is not null, then that text will be pre-pended or post-pended
//  respectively.
//
// Apps that don't use the extra parameters may want to just use the
//  macro below 'ErrAlert'
//---------------------------------------------------------------------
Function ErrAlertCustom(errCode: Err; Const errMsg,preMsg,postMsg: String): UInt16; SYS_TRAP(sysTrapErrAlertCustom);

Procedure ErrAlert(e: Err);

implementation

Procedure ErrAlert(e: Err);
var N: Integer;
begin
  N:=ErrAlertCustom(e, '', '', '');
end;

end.
