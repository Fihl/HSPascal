/******************************************************************************
 *
 * Copyright (c) 1994-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: ErrorMgr.h
 *
 * Description:
 *    Include file for Error Management that depend on ERROR_CHECK_LEVEL
 *    All the rest of the old ErrorMgr.h is in ErrorBase.h
 *
 * History:
 *    10/25/94  RM - Created by Ron Marianetti
 *    10/9/98  Bob - Fill in all macros, fix defns w/ do{}while(0)
 *    7/21/99  Bob - split invariant stuff out into ErrorBase.h
 *    12/23/99 jmp   Fix <> vs. "" problem.
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit ErrorMgr;

interface

Procedure ErrDisplay(Const msg: String);
Procedure ErrDisplayFileLineMsg(Const FileName: String; lineNo: UInt16; msg: String); SYS_TRAP(sysTrapErrDisplayFileLineMsg);

//HSPascal version of conditional error message
Procedure ErrDisplayFileLineMsgIf(Condition: Boolean; Const FileName: String; LineNo: UInt16; Const msg: String);

implementation

//Uses ErrorBase;

Procedure ErrDisplay(Const msg: String);
begin
  ErrDisplayFileLineMsg('',0,msg);
end;

//HSPascal version of conditional error message
Procedure ErrDisplayFileLineMsgIf(Condition: Boolean; Const FileName: String; LineNo: UInt16; Const msg: String);
begin
  if Condition then begin
    {$ifdef DebuggerOnErr}
    asm trap #8 end;
    {$endif}
    ErrDisplayFileLineMsg('',0,msg);
  end;
end;

end.






#include "PalmOptErrorCheckLevel.h" // #define ERROR_CHECK_LEVEL
//------------------------------------------------------------
// Full Error Checking
//------------------------------------------------------------
#if ERROR_CHECK_LEVEL == ERROR_CHECK_FULL

#define ErrFatalDisplay(msg) \
   ErrDisplayFileLineMsg(__FILE__, (UInt16) __LINE__, msg)

#define ErrFatalDisplayIf(condition, msg) \
   do {if (condition) ErrDisplayFileLineMsg(__FILE__, (UInt16) __LINE__, msg);} while (0)
      
#define ErrNonFatalDisplayIf(condition, msg) \
   do {if (condition) ErrDisplayFileLineMsg(__FILE__, (UInt16) __LINE__, msg);} while (0)

#define ErrNonFatalDisplay(msg) \
   ErrDisplayFileLineMsg(__FILE__, (UInt16) __LINE__, msg)
   
#define ErrDisplay(msg) \
   ErrDisplayFileLineMsg(__FILE__, (UInt16) __LINE__, msg)




//------------------------------------------------------------
// Fatal  Error Checking Only
//------------------------------------------------------------
#elif ERROR_CHECK_LEVEL == ERROR_CHECK_PARTIAL

#define ErrFatalDisplay(msg) \
   ErrDisplayFileLineMsg(__FILE__, (UInt16) __LINE__, msg)

#define ErrFatalDisplayIf(condition, msg) \
   do {if (condition) ErrDisplayFileLineMsg(__FILE__, (UInt16) __LINE__, msg);} while (0)

#define ErrNonFatalDisplayIf(condition, msg) 

#define ErrNonFatalDisplay(msg) 
   
#define ErrDisplay(msg) \
   ErrDisplayFileLineMsg(__FILE__, (UInt16) __LINE__, msg)



//------------------------------------------------------------
// No  Error Checking  
//------------------------------------------------------------
#elif ERROR_CHECK_LEVEL == ERROR_CHECK_NONE

#define ErrFatalDisplay(msg) 

#define ErrFatalDisplayIf(condition, msg) 

#define ErrNonFatalDisplayIf(condition, msg) 

#define ErrNonFatalDisplay(msg) 

#define ErrDisplay(msg)  


//------------------------------------------------------------
// Not Defined...
//------------------------------------------------------------
#else
#error   ERROR: the compiler define 'ERROR_CHECK_LEVEL' must be defined!

#endif // ERROR_CHECK_LEVEL


#endif // __ERRORMGR_H__





