/******************************************************************************
 *
 * Copyright (c) 1994-1999 Palm Computing, Inc. or its subsidiaries.
 * All rights reserved.
 *
 * File: StringMgr.h
 *
 * Description:
 *    String manipulation functions
 *
 * History:
 *    11/09/94 RM    Created by Ron Marianetti
 *    08/26/98 kwk   Changed chr param in StrChr to WChar (was Int16)
 *    07/16/99 kwk   Added maxStrIToALen.
 *
 * (c) HSPascal April-2001, Pascal syntax for HSPascal http://HSPascal.Fihl.net
 *
 *****************************************************************************/

Unit StringMgr;

interface

// Max length of string returned by StrIToA, for -2147483647, plus space
// for the terminating null.
Const
  maxStrIToALen  =12;

// String Manipulation routines
Function StrCopy(dst: pChar; Const Src: String): pChar;
                     SYS_TRAP(sysTrapStrCopy);

Function StrNCopy(dst: pChar; Const Src: String; n: Int16): pChar;
                     SYS_TRAP(sysTrapStrNCopy);

Function StrCat(dst: pChar; Const Src: String): pChar;
                     SYS_TRAP(sysTrapStrCat);

Function StrNCat(dst: pChar; Const Src: String; n: Int16): pChar;
                     SYS_TRAP(sysTrapStrNCat);

Function StrLen(Const Src: String): Int16;
                     SYS_TRAP(sysTrapStrLen);

Function StrCompare(Const s1, s2: String): Int16;
                     SYS_TRAP(sysTrapStrCompare);

Function StrNCompare(Const s1, s2: String; n: Int32): Int16;
                     SYS_TRAP(sysTrapStrNCompare);

Function StrCaselessCompare(Const s1, s2: String): Int16;
                     SYS_TRAP(sysTrapStrCaselessCompare);

Function StrNCaselessCompare(Const s1, s2: String; n: Int32): Int16;
                     SYS_TRAP(sysTrapStrNCaselessCompare);

Function StrToLower(dst: pChar; Const Src: String): pChar;
                     SYS_TRAP(sysTrapStrToLower);

Function StrIToA(dst: pChar; i: Int32): pChar;
                     SYS_TRAP(sysTrapStrIToA);

Function StrIToH(dst: pChar; i: UInt32): pChar;
                     SYS_TRAP(sysTrapStrIToH);

Function StrLocalizeNumber(Const S: String; thousandSeparator, decimalSeparator: Char): pChar;
                     SYS_TRAP(sysTrapStrLocalizeNumber);

Function StrDelocalizeNumber(Const S: String; thousandSeparator, decimalSeparator: Char): pChar;
                     SYS_TRAP(sysTrapStrDelocalizeNumber);

Function StrChr(Const str: String; chr: WChar): pChar;
                     SYS_TRAP(sysTrapStrChr);

Function StrStr(Const str, token: String): pChar;
                     SYS_TRAP(sysTrapStrStr);

Function StrAToI(Const str: String): Int32;
                     SYS_TRAP(sysTrapStrAToI);

(*** Not in Pascal
Function StrPrintF(s: pChar; Const formatstr: String; ...): Int16;
                     SYS_TRAP(sysTrapStrPrintF);

Function StrVPrintF(s: pChar; Const formatstr: String; _Palm_va_list arg): Int16;
                     SYS_TRAP(sysTrapStrVPrintF);
(***)

implementation

end.

