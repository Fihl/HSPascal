/******************************************************************************
 *
 * Copyright (c) 1998-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: IntlMgr.h
 *
 * Description:
 *   This file defines public Int'l Mgr structures and routines.
 *
 * History:
 *    03/21/98 kwk   Created by Ken Krugler.
 *    10/14/98 kwk   Added intlIntlGetRoutineAddress selector and
 *                   IntlGetRoutineAddress routine declaration.
 *    08/05/99 kwk   Added intlIntlHandleEvent selector and the
 *                   IntlHandleEvent routine declaration.
 *    09/22/99 kwk   Added intlTxtParamString selector.
 *    10/20/99 kwk   Moved private stuff to IntlPrv.h
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit IntlMgr;

interface

Uses SysEvent;

/***********************************************************************
 * Public constants
 ***********************************************************************/

// Bits set for the Intl Mgr feature.

Const kIntlMgrExists =1;

// Selectors for routines found in the international manager. The order
// of these selectors MUST match the jump table in IntlDispatch.c.

Type
  IntlSelector = (
    intlIntlInit = 0,
    intlTxtByteAttr,
    intlTxtCharAttr,
    intlTxtCharXAttr,
    intlTxtCharSize,
    intlTxtGetPreviousChar,
    intlTxtGetNextChar,
    intlTxtGetChar,
    intlTxtSetNextChar,
    intlTxtCharBounds,
    intlTxtPrepFindString,
    intlTxtFindString,
    intlTxtReplaceStr,
    intlTxtWordBounds,
    intlTxtCharEncoding,
    intlTxtStrEncoding,
    intlTxtEncodingName,
    intlTxtMaxEncoding,
    intlTxtTransliterate,
    intlTxtCharIsValid,
    intlTxtCompare,
    intlTxtCaselessCompare,
    intlTxtCharWidth,
    intlTxtGetTruncationOffset,
    intlIntlGetRoutineAddress,
    intlIntlHandleEvent,
    intlTxtParamString,

    intlMaxSelector = intlTxtParamString,
    intlBigSelector = 0x7FFF   // Force IntlSelector to be 16 bits.
  );

/***********************************************************************
 * Public routines
 ***********************************************************************/

// Return back the address of the routine indicated by <inSelector>. If
// <inSelector> isn't a valid routine selector, return back NULL.
Function IntlGetRoutineAddress(inSelector: IntlSelector): Pointer;
      SYS_TRAP(sysTrapIntlDispatch, intlIntlGetRoutineAddress);

// Return true if the international support wants to handle the event.
Function IntlHandleEvent(var inEvent: SysEventType; inProcess: Boolean): Boolean;
      SYS_TRAP(sysTrapIntlDispatch, intlIntlHandleEvent);

// Move this, and other routine declarations, into IntlPrv.h which is
// new file in International folder. Rename existing IntlPrv.h in IntlMgr
// extension folder to be something like IntlExtShiftJIS.h

// Dispatcher that uses contents of register D2 to dispatch to the
// appropriate int'l routine. This routine declaration is only used
// when setting up the trap dispatch table; all callers of routines
// accessed via the dispatcher should use the explicit routine declarations
// (e.g. IntlInit below), which set up D2 before calling IntlDispatch.

//Procedure IntlDispatch;

// Initialization routine, called at system reset time by PalmOS..

Procedure IntlInit;
      SYS_TRAP(sysTrapIntlDispatch, intlIntlInit);

implementation

end.

